import 'dart:io';
import 'dart:typed_data';

import 'package:edax_runner/learning_list.dart';
import 'package:libedax4dart/libedax4dart.dart';

const String _dataDir = 'data';
const String _bookFile = '$_dataDir/book.dat';
const String _learningListFile = 'learning_list.txt';
const String _learnedLogFile = 'learned_log.txt';
const String _savingExt = '.saving';
const String _moves = '((?:[a-hA-H][1-8])+)';
final _edaxVsEdaxRegexp = RegExp('^$_moves\$'); // e.g. "f5f6f7"
final _edaxVsEdaxWithRandomnessRegexp = RegExp(
  '^(\\d+)\\s*,\\s*$_moves\$',
); // e.g. "3,f5f6f7"
final _bookDeviateRegexp = RegExp(
  '^\\[\\s*(\\d+)\\s+(\\d+)\\s*\\]\\s*$_moves\$',
); // e.g. "[1 3] f5f6f7"
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
  // remove the files left by the previous run which was killed while saving.
  _deleteIfExists('$_bookFile$_savingExt');
  _deleteIfExists('$_learningListFile$_savingExt');

  var learningList = _readLearningList();
  final edax = LibEdax(_edaxSharedLibraryPath)
    ..libedaxInitialize([
      '',
      '-book-file',
      _bookFile,
    ]) // NOTE: these are prioritized over `edax.ini`.
    ..edaxInit()
    ..edaxMode(3) // NOTE: edax must not move unless edax_runner tells.
    ..edaxEnableBookVerbose()
    ..edaxPlayPrint();

  while (true) {
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

String get _edaxSharedLibraryPath {
  if (Platform.isLinux) return 'libedax.so';
  if (Platform.isMacOS) return 'libedax.universal.dylib';
  if (Platform.isWindows) return 'libedax-x64.dll';
  throw Exception('${Platform.operatingSystem} is not supported');
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

  var match = _edaxVsEdaxRegexp.firstMatch(text);
  if (match != null) {
    return _doEdaxVsEdaxWithRandomness(edax, match.group(1)!, 0);
  }

  match = _edaxVsEdaxWithRandomnessRegexp.firstMatch(text);
  if (match != null) {
    final randomness = int.tryParse(match.group(1)!);
    if (randomness == null) return 'too large number';
    return _doEdaxVsEdaxWithRandomness(edax, match.group(2)!, randomness);
  }

  match = _bookDeviateRegexp.firstMatch(text);
  if (match != null) {
    final relativeError = int.tryParse(match.group(1)!);
    final absoluteError = int.tryParse(match.group(2)!);
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
Uint8List _removeLearnedText(final String text, {final String? skipReason}) {
  final taken = takeEntry(_readLearningList(), text, skipReason: skipReason);
  _retry(
    () => File(
      _learnedLogFile,
    ).writeAsBytesSync(taken.log, mode: FileMode.append, flush: true),
  );
  // NOTE: don't overwrite learning list directly,
  // so that it isn't broken even if edax_runner is killed while saving.
  _retry(() {
    File(
      '$_learningListFile$_savingExt',
    ).writeAsBytesSync(taken.rest, flush: true);
  });
  _retry(
    () => File('$_learningListFile$_savingExt').renameSync(_learningListFile),
  );
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

void _deleteIfExists(final String path) {
  final file = File(path);
  if (file.existsSync()) _retry(file.deleteSync);
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

void _saveBook(final LibEdax edax) {
  _print('book save...');
  // NOTE: don't overwrite the book directly,
  // so that it isn't broken even if edax_runner is killed while saving.
  edax.edaxBookSave('$_bookFile$_savingExt');
  _retry(() => File('$_bookFile$_savingExt').renameSync(_bookFile));
  _print('has finished book save.');
}

void _doEdaxBookFix(final LibEdax edax) {
  edax
    ..edaxBookFix()
    ..edaxPlayPrint();
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
  _print(
    'has finished book deviate.'
    ' moves: $moves, relativeError: $relativeError, absoluteError: $absoluteError.',
  );
  _saveBook(edax);
  return null;
}
