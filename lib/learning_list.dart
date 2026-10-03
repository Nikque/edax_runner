/// Functions to handle the content of learning list.
///
/// The content is handled as bytes, not as text. So,
/// * the comments in any encoding (UTF-8, Shift_JIS, ...) are kept as they are.
/// * the line terminators (LF, CRLF) are kept as they are.
/// * a lot of strings aren't created even if learning list has a lot of lines.
library;

import 'dart:convert';
import 'dart:typed_data';

/// A line which contains this is a comment.
const String commentHead = '//';

const int _lf = 0x0A;
const int _cr = 0x0D;

/// A text to learn, which is found in the content of learning list.
class LearningEntry {
  const LearningEntry(this.text, this.start, this.end);

  /// The line without the white spaces of both ends.
  final String text;

  /// The offset of the line.
  final int start;

  /// The offset of the next line.
  final int end;
}

/// The result of [takeEntry].
class TakenEntry {
  const TakenEntry(this.log, this.rest);

  /// The bytes to append to learned log.
  final Uint8List log;

  /// The new content of learning list.
  final Uint8List rest;
}

/// Check if [bytes] is UTF-16, which isn't supported.
bool isUtf16(final Uint8List bytes) =>
    bytes.length >= 2 &&
    ((bytes[0] == 0xFF && bytes[1] == 0xFE) ||
        (bytes[0] == 0xFE && bytes[1] == 0xFF));

int _bomLength(final Uint8List bytes) =>
    bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF
    ? 3
    : 0;

/// Find the first text to learn in [bytes], which is the content of learning list.
///
/// Comment lines and blank lines are passed over. <br>
/// If [text] is specified, find the first one which equals to [text].
LearningEntry? findEntry(final Uint8List bytes, {final String? text}) =>
    _findEntryFrom(bytes, _bomLength(bytes), text: text);

LearningEntry? _findEntryFrom(
  final Uint8List bytes,
  final int from, {
  final String? text,
}) {
  var start = from;
  while (start < bytes.length) {
    final lf = bytes.indexOf(_lf, start);
    final end = lf < 0 ? bytes.length : lf + 1;
    final line = _trim(bytes, start, end);
    if (line.isNotEmpty &&
        !line.contains(commentHead) &&
        (text == null || line == text)) {
      return LearningEntry(line, start, end);
    }
    start = end;
  }
  return null;
}

/// The line of [bytes] from [start] to [end], without the white spaces of both ends.
///
/// NOTE: `String.trim` also removes 0x85 and 0xA0,
/// which can be the last byte of a character. (e.g. of Shift_JIS)
String _trim(final Uint8List bytes, final int start, final int end) {
  var from = start;
  var to = end;
  while (from < to && _isSpace(bytes[from])) {
    from++;
  }
  while (from < to && _isSpace(bytes[to - 1])) {
    to--;
  }
  return latin1.decode(Uint8List.sublistView(bytes, from, to));
}

bool _isSpace(final int byte) => byte == 0x20 || (byte >= 0x09 && byte <= 0x0D);

/// Find the first texts to learn in [bytes], as long as [accept] returns true, up to [max] texts.
///
/// Comment lines and blank lines are passed over.
List<LearningEntry> findEntries(
  final Uint8List bytes, {
  required final int max,
  required final bool Function(String text) accept,
}) {
  final entries = <LearningEntry>[];
  var start = _bomLength(bytes);
  while (entries.length < max) {
    final entry = _findEntryFrom(bytes, start);
    if (entry == null || !accept(entry.text)) break;
    entries.add(entry);
    start = entry.end;
  }
  return entries;
}

/// Take [text] out of [bytes], which is the content of learning list.
///
/// If [text] is still the first text to learn, the lines above it are also taken out. <br>
/// If [skipReason] is specified, [text] is logged as a comment with the reason.
TakenEntry takeEntry(
  final Uint8List bytes,
  final String text, {
  final String? skipReason,
}) {
  final first = findEntry(bytes);
  final isFirst = first != null && first.text == text;
  // NOTE: learning list can be edited while learning.
  final entry = isFirst ? first : findEntry(bytes, text: text);
  final log = BytesBuilder(copy: false);

  if (entry == null) {
    log.add(latin1.encode('${_logText(text, skipReason)}\n'));
    return TakenEntry(log.takeBytes(), bytes);
  }

  final start = isFirst ? _bomLength(bytes) : entry.start;
  log.add(Uint8List.sublistView(bytes, start, entry.start));
  if (skipReason == null) {
    log.add(Uint8List.sublistView(bytes, entry.start, entry.end));
    if (bytes[entry.end - 1] != _lf) log.addByte(_lf);
  } else {
    final isCrLf = entry.end - entry.start >= 2 && bytes[entry.end - 2] == _cr;
    log.add(
      latin1.encode('${_logText(text, skipReason)}${isCrLf ? '\r\n' : '\n'}'),
    );
  }

  final rest = BytesBuilder(copy: false)
    ..add(Uint8List.sublistView(bytes, 0, start))
    ..add(Uint8List.sublistView(bytes, entry.end));
  return TakenEntry(log.takeBytes(), rest.takeBytes());
}

/// Take [texts] out of [bytes] one after the other, as [takeEntry] does.
///
/// [skipReasons] has the reason for each text which hasn't been learned (null if learned).
TakenEntry takeEntries(
  final Uint8List bytes,
  final List<String> texts,
  final List<String?> skipReasons,
) {
  final log = BytesBuilder(copy: false);
  var rest = bytes;
  for (var i = 0; i < texts.length; i++) {
    final taken = takeEntry(rest, texts[i], skipReason: skipReasons[i]);
    log.add(taken.log);
    rest = taken.rest;
  }
  return TakenEntry(log.takeBytes(), rest);
}

String _logText(final String text, final String? skipReason) =>
    skipReason == null
    ? text
    : '$commentHead [edax_runner] skipped ($skipReason): $text';
