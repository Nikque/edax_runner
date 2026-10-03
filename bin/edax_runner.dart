import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:edax_runner/learning_list.dart';
import 'package:ffi/ffi.dart';
import 'package:libedax4dart/libedax4dart.dart';

const String _dataDir = 'data';
const String _bookFile = '$_dataDir/book.dat';
const String _learningListFile = 'learning_list.txt';
const String _learnedLogFile = 'learned_log.txt';
const String _configFile = 'config.ini';
const String _oldConfigFile = 'edax.ini';
const String _savingExt = '.saving';
const String _moves = '((?:[a-hA-H][1-8])+)';
final _edaxVsEdaxRegexp = RegExp(
  '^(?:(\\d+)\\s*,\\s*)?$_moves\$',
); // e.g. "f5f6f7", "3,f5f6f7"
final _bookDeviateRegexp = RegExp(
  '^\\[\\s*(\\d+)\\s+(\\d+)\\s*\\]\\s*$_moves\$',
); // e.g. "[1 3] f5f6f7"

/// libedax takes these numbers as 32 bit integers.
const int _maxNumber = 0x7FFFFFFF;

/// The largest `book-randomness` of a game which libedax of Edax 4.5.5 nikque.7 and nikque.8
/// learns with other games. (no limit since nikque.9)
const int _maxRandomnessOfOldGames = 127;
const int _fileRetryCount = 30;
const Duration _fileRetryInterval = Duration(seconds: 1);

void main(final List<String> arguments) {
  _print('launching edax_runner...');
  _useExecutableDirectoryIfNeeded();
  if (!File(_learningListFile).existsSync()) {
    _print('"$_learningListFile" is not found in "${Directory.current.path}".');
    exitCode = 1;
    return;
  }
  // NOTE: edax can't save the book without this directory.
  Directory(_dataDir).createSync(recursive: true);
  _deleteFilesLeftByKilledRun();
  if (File(_oldConfigFile).existsSync() && File(_configFile).existsSync()) {
    _print(
      'WARNING: "$_oldConfigFile" is read, but "$_configFile" is prioritized.'
      ' Move your settings to "$_configFile".',
    );
  }

  var learningList = _readLearningList();
  final libraryPath = _edaxSharedLibraryPath();
  // NOTE: with `book-store-tasks` of `config.ini`, libedax learns several games at the same time.
  final gamesLearner = _nikque = _NikqueLibEdax(libraryPath);
  final edax = LibEdax(libraryPath)
    ..libedaxInitialize([
      '',
      '-book-file',
      _bookFile,
    ]) // NOTE: these are prioritized over `config.ini`.
    ..edaxInit()
    ..edaxMode(3) // NOTE: edax must not move unless edax_runner tells.
    ..edaxEnableBookVerbose()
    ..edaxPlayPrint();

  if (gamesLearner.tasks > 1) {
    _print('learn up to ${gamesLearner.tasks} games at the same time.');
  }

  while (true) {
    final tasks = gamesLearner.tasks;
    final games = tasks > 1
        ? findEntries(
            learningList,
            max: tasks,
            accept: (final text) => _gameLine(text) != null,
          )
        : const <LearningEntry>[];
    if (games.length > 1) {
      learningList = _learnGames(
        edax,
        gamesLearner,
        games.map((final game) => game.text).toList(),
      );
      continue;
    }

    final text = findEntry(learningList)?.text ?? '';
    if (text.isEmpty) break;
    if (text.toLowerCase() == 'exit') {
      _removeLearnedText(text);
      break;
    }
    _print('start to learn "$text".');

    final skipReason = _learn(edax, text);
    if (skipReason == null) {
      _print('has finished learning "$text".');
    } else {
      _print('WARNING: has skipped "$text". ($skipReason)');
    }
    learningList = _removeLearnedText(text, skipReason: skipReason);
    _print('has removed "$text".');
  }

  edax.libedaxTerminate();
  _print('edax has terminated.');
}

/// libedax is built for several levels of CPU.
/// Return the fastest one which the CPU can run.
String _edaxSharedLibraryPath() {
  final List<String> names; // [any CPU, x86-64-v3 (AVX2), x86-64-v4 (AVX-512)]
  if (Platform.isLinux) {
    names = ['libedax.so', 'libedax-v3.so', 'libedax-v4.so'];
  } else if (Platform.isMacOS) {
    names = ['libedax.universal.dylib'];
  } else if (Platform.isWindows) {
    names = ['libedax-x64.dll', 'libedax-x64-v3.dll', 'libedax-x64-v4.dll'];
  } else {
    throw Exception('${Platform.operatingSystem} is not supported');
  }

  var name = names.first;
  if (names.length > 1 && File(name).existsSync()) {
    final cpuLevel = _cpuLevel(_libraryPath(name));
    if (cpuLevel >= 4 && File(names[2]).existsSync()) {
      name = names[2];
    } else if (cpuLevel >= 3 && File(names[1]).existsSync()) {
      name = names[1];
    }
  }
  _print('use "$name".');
  return _libraryPath(name);
}

/// NOTE: a library in the current directory isn't found by its name on some OS.
String _libraryPath(final String name) => File(name).existsSync()
    ? '${Directory.current.path}${Platform.pathSeparator}$name'
    : name;

/// Ask the level of the CPU to libedax which any CPU can run.
///
/// 4: x86-64-v4 (AVX-512), 3: x86-64-v3 (AVX2), otherwise: lower or unknown.
int _cpuLevel(final String libraryPath) {
  try {
    final library = DynamicLibrary.open(libraryPath);
    final level = library.lookupFunction<Int32 Function(), int Function()>(
      'libedax_cpu_level',
    )();
    library.close();
    return level;
  } on ArgumentError {
    return 0; // NOTE: the original libedax doesn't have this function.
  }
}

/// What libedax did with a game of `edax_book_store_games`.
enum _GameResult { learned, illegalMove, failed }

/// The functions of libedax (Edax 4.5.5 nikque) which libedax4dart doesn't have.
late final _NikqueLibEdax _nikque;

class _NikqueLibEdax {
  _NikqueLibEdax(final String libraryPath) {
    final DynamicLibrary library;
    try {
      library = DynamicLibrary.open(libraryPath);
      _storeTasks = library.lookupFunction<Int32 Function(), int Function()>(
        'edax_book_store_tasks',
      );
      _storeGames = library
          .lookupFunction<
            Int32 Function(Pointer<Utf8>, Pointer<Utf8>),
            int Function(Pointer<Utf8>, Pointer<Utf8>)
          >('edax_book_store_games');
    } on ArgumentError {
      return; // NOTE: the original libedax doesn't have these functions.
    }
    try {
      _saveTo = library
          .lookupFunction<
            Int32 Function(Pointer<Utf8>),
            int Function(Pointer<Utf8>)
          >('edax_book_save_checked');
    } on ArgumentError {
      // NOTE: libedax of Edax 4.5.5 nikque.7 and nikque.8 doesn't have this function.
    }
    try {
      _failed = library.lookupFunction<Int32 Function(), int Function()>(
        'edax_book_failed',
      );
    } on ArgumentError {
      // NOTE: the same.
    }
  }

  int Function()? _storeTasks;
  int Function(Pointer<Utf8>, Pointer<Utf8>)? _storeGames;
  int Function(Pointer<Utf8>)? _saveTo;
  int Function()? _failed;

  /// The number of games to learn at the same time. (`book-store-tasks`)
  int get tasks => _storeGames == null ? 1 : (_storeTasks?.call() ?? 1);

  /// The largest `book-randomness` of a game which libedax learns with other games.
  int get maxRandomnessOfGames =>
      _saveTo == null ? _maxRandomnessOfOldGames : _maxNumber;

  /// Play and learn the games of [lines] (`{book-randomness},{moves}` for each),
  /// and return what has been done with each game.
  List<_GameResult> learn(final List<String> lines) {
    final games = lines.join('\n').toNativeUtf8();
    final status = calloc<Uint8>(lines.length + 1);
    try {
      _storeGames!(games, status.cast());
      return [
        for (var i = 0; i < lines.length; i++)
          switch (status[i]) {
            0x31 => _GameResult.learned,
            0x30 => _GameResult.illegalMove,
            _ => _GameResult.failed, // '2' (since nikque.9), or nothing
          },
      ];
    } finally {
      calloc
        ..free(games)
        ..free(status);
    }
  }

  /// Throw [StateError] if the last book function of edax couldn't add a position to the book.
  /// (an older libedax doesn't tell it)
  void checkBook() {
    if ((_failed?.call() ?? 0) != 0) {
      // NOTE: the line is kept in learning list: it is learned at the next run.
      throw StateError(
        'edax could not add a position to the book (not enough memory?).'
        ' "$_learningListFile" and "$_bookFile" are not changed.',
      );
    }
  }

  /// Save the book to [path], and return whether it has been saved.
  /// Return null if libedax doesn't have the function which tells it.
  bool? saveBook(final String path) {
    final saveTo = _saveTo;
    if (saveTo == null) return null;
    final file = path.toNativeUtf8();
    try {
      return saveTo(file) != 0;
    } finally {
      calloc.free(file);
    }
  }
}

/// Return the moves and the book-randomness (0 by default; null if too large)
/// if [text] is a game of edax vs edax.
({String moves, int? randomness})? _parseGame(final String text) {
  final match = _edaxVsEdaxRegexp.firstMatch(text);
  if (match == null) return null;
  return (moves: match.group(2)!, randomness: _parseNumber(match.group(1)));
}

/// Return the number of [digits] (0 if null), or null if it's too large.
int? _parseNumber(final String? digits) {
  final number = digits == null ? 0 : int.tryParse(digits);
  return number == null || number > _maxNumber ? null : number;
}

/// Return `{book-randomness},{moves}` if [text] is a game of edax vs edax
/// which can be learned with other games.
String? _gameLine(final String text) {
  final game = _parseGame(text);
  final randomness = game?.randomness;
  // NOTE: `edax_book_store_games` of an old libedax doesn't learn a game with a larger randomness.
  // Such a game is learned alone, as before.
  if (randomness == null || randomness > _nikque.maxRandomnessOfGames) {
    return null;
  }
  return '$randomness,${game!.moves}';
}

/// Learn the games of [texts] at the same time, and return the new content of learning list.
Uint8List _learnGames(
  final LibEdax edax,
  final _NikqueLibEdax gamesLearner,
  final List<String> texts,
) {
  _print('start to learn ${texts.length} games.');
  texts.forEach(stdout.writeln);
  stdout.writeln();
  final results = gamesLearner.learn(
    texts.map((final text) => _gameLine(text)!).toList(),
  );
  stdout.writeln();
  if (results.contains(_GameResult.failed)) {
    // NOTE: the games are kept in learning list: they are learned at the next run.
    throw StateError(
      'edax could not learn the games (not enough memory?).'
      ' "$_learningListFile" and "$_bookFile" are not changed.',
    );
  }
  final skipReasons = [
    for (final result in results)
      result == _GameResult.learned ? null : 'illegal move',
  ];
  _print(
    'has finished edax vs edax and book store of '
    '${results.where((final result) => result == _GameResult.learned).length} games.',
  );
  for (var i = 0; i < texts.length; i++) {
    if (skipReasons[i] != null) {
      _print('WARNING: has skipped "${texts[i]}". (${skipReasons[i]})');
    }
  }
  _saveBook(edax);
  final rest = _removeLearnedTexts(texts, skipReasons);
  _print('has removed ${texts.length} games.');
  return rest;
}

/// edax_runner uses the files in the current directory.
/// If they aren't there (e.g. launched from another directory), use the directory of the executable.
void _useExecutableDirectoryIfNeeded() {
  if (File(_learningListFile).existsSync()) return;
  final dir = File(Platform.resolvedExecutable).parent;
  if (!File('${dir.path}/$_learningListFile').existsSync()) return;
  Directory.current = dir;
  _print('has moved to "${dir.path}".');
}

/// Learn [text], and return the reason if [text] can't be learned.
String? _learn(final LibEdax edax, final String text) {
  if (text.toLowerCase() == 'fix') {
    _doEdaxBookFix(edax);
    return null;
  }

  final game = _parseGame(text);
  if (game != null) {
    final randomness = game.randomness;
    if (randomness == null) return 'too large number';
    return _doEdaxVsEdaxWithRandomness(edax, game.moves, randomness);
  }

  final match = _bookDeviateRegexp.firstMatch(text);
  if (match != null) {
    final relativeError = _parseNumber(match.group(1));
    final absoluteError = _parseNumber(match.group(2));
    if (relativeError == null || absoluteError == null) {
      return 'too large number';
    }
    return _doEdaxBookDeviate(
      edax,
      match.group(3)!,
      relativeError,
      absoluteError,
    );
  }

  return 'unknown format';
}

Uint8List _readLearningList() {
  final bytes = _retry(() => File(_learningListFile).readAsBytesSync());
  if (isUtf16(bytes)) {
    throw FormatException(
      '"$_learningListFile" is UTF-16, which is not supported.'
      ' Save it as UTF-8.',
    );
  }
  return bytes;
}

/// Move [text] from learning list to learned log, and return the new content of learning list.
Uint8List _removeLearnedText(final String text, {final String? skipReason}) =>
    _removeLearnedTexts([text], [skipReason]);

/// Move [texts] from learning list to learned log, and return the new content of learning list.
Uint8List _removeLearnedTexts(
  final List<String> texts,
  final List<String?> skipReasons,
) {
  final taken = takeEntries(_readLearningList(), texts, skipReasons);
  _retry(
    () => File(
      _learnedLogFile,
    ).writeAsBytesSync(taken.log, mode: FileMode.append, flush: true),
  );
  // NOTE: don't overwrite learning list directly,
  // so that it isn't broken even if edax_runner is killed while saving.
  final saving = File('$_learningListFile$_savingExt');
  _retry(() => saving.writeAsBytesSync(taken.rest, flush: true));
  _retry(() => saving.renameSync(_learningListFile));
  return taken.rest;
}

/// Retry [action] for a while,
/// because a file can be temporarily locked by an editor, an antivirus software and so on.
T _retry<T>(final T Function() action) {
  for (var count = 1; ; count++) {
    try {
      return action();
    } on FileSystemException catch (e) {
      if (count >= _fileRetryCount) rethrow;
      if (count == 1) _print('WARNING: retrying... ($e)');
      sleep(_fileRetryInterval);
    }
  }
}

/// edax_runner and edax replace a file after saving to another file.
/// Remove the files left by the previous run which was killed while saving.
void _deleteFilesLeftByKilledRun() {
  final leftByEdax = RegExp(r'^book\.dat(\.\w+)?\.tmp\.\d+$');
  final files = [
    File('$_learningListFile$_savingExt'),
    File('$_bookFile$_savingExt'),
    ...Directory(_dataDir).listSync().whereType<File>().where(
      (final file) => leftByEdax.hasMatch(file.uri.pathSegments.last),
    ),
  ];
  for (final file in files) {
    if (file.existsSync()) _retry(file.deleteSync);
  }
}

void _print(final String msg) => stdout.writeln('\n[edax_runner] $msg\n');

/// Play [moves] from the initial position.
///
/// Return false if [moves] has an illegal move.
/// (edax ignores an illegal move and the following ones without any error)
bool _play(final LibEdax edax, final String moves) {
  edax
    ..edaxInit()
    ..edaxPlay(moves);
  final played = edax.edaxGetMoves().toLowerCase().replaceAll('pa', '');
  edax.edaxPlayPrint();
  return played == moves.toLowerCase();
}

/// Save the book, or throw [FileSystemException] if it can't be saved.
void _saveBook(final LibEdax edax) {
  _print('book save...');
  // NOTE: `edax_book_save` doesn't tell whether it has saved the book
  // (e.g. it can't replace the book while another program opens it).
  // So, let edax save to another file, check the result (`edax_book_save_checked`, since Edax 4.5.5 nikque.9)
  // and the file, and replace the book with it.
  // The book isn't broken even if edax_runner is killed while saving.
  final saving = File('$_bookFile$_savingExt');
  _retry(() {
    if (saving.existsSync()) saving.deleteSync();
    final saved = _nikque.saveBook(saving.path);
    if (saved == null) edax.edaxBookSave(saving.path);
    if (saved == false || !saving.existsSync()) {
      throw FileSystemException('edax could not save the book', saving.path);
    }
  });
  _retry(() => saving.renameSync(_bookFile));
  _print('has finished book save.');
}

void _doEdaxBookFix(final LibEdax edax) {
  edax
    ..edaxBookFix()
    ..edaxPlayPrint();
  _nikque.checkBook();
  _print('has finished book fix.');
  _saveBook(edax);
}

String? _doEdaxVsEdaxWithRandomness(
  final LibEdax edax,
  final String moves,
  final int randomness,
) {
  edax.edaxSetOption('book-randomness', randomness.toString());
  if (!_play(edax, moves)) return 'illegal move';
  while (!edax.edaxIsGameOver()) {
    edax.edaxGo();
    stdout.writeln();
    edax.edaxPlayPrint();
  }
  _print(
    'has finished edax vs edax.'
    ' moves: $moves, randomness: $randomness.',
  );
  _print('book store...');
  edax.edaxBookStore();
  _nikque.checkBook();
  _print('has finished book store.');
  _saveBook(edax);
  return null;
}

String? _doEdaxBookDeviate(
  final LibEdax edax,
  final String moves,
  final int relativeError,
  final int absoluteError,
) {
  if (!_play(edax, moves)) return 'illegal move';
  stdout.writeln();
  edax.edaxBookDeviate(relativeError, absoluteError);
  _nikque.checkBook();
  _print(
    'has finished book deviate.'
    ' moves: $moves, relativeError: $relativeError, absoluteError: $absoluteError.',
  );
  _saveBook(edax);
  return null;
}
