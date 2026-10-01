import 'dart:convert';
import 'dart:typed_data';

import 'package:edax_runner/learning_list.dart';
import 'package:test/test.dart';

Uint8List _bytes(final String text) => Uint8List.fromList(utf8.encode(text));

String _text(final Uint8List bytes) => utf8.decode(bytes);

void main() {
  group('findEntry', () {
    test('passes over comment lines and blank lines', () {
      final bytes = _bytes('// comment\n\n  \nf5f6 // comment\n f5d6 \nfix\n');
      final entry = findEntry(bytes)!;
      expect(entry.text, 'f5d6');
      expect(_text(bytes.sublist(entry.start, entry.end)), ' f5d6 \n');
    });

    test('returns null if there is nothing to learn', () {
      expect(findEntry(_bytes('')), isNull);
      expect(findEntry(_bytes('// comment\n\n')), isNull);
    });

    test('ignores BOM', () {
      final bytes = Uint8List.fromList([
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode('f5'),
      ]);
      final entry = findEntry(bytes)!;
      expect(entry.text, 'f5');
      expect(entry.start, 3);
      expect(entry.end, 5);
    });

    test('handles CRLF and the last line without line terminator', () {
      final bytes = _bytes('// comment\r\nf5d6\r\nfix');
      expect(findEntry(bytes)!.text, 'f5d6');
      expect(findEntry(bytes, text: 'fix')!.end, bytes.length);
    });

    test('accepts the comments which are not UTF-8', () {
      // "// 学習" in Shift_JIS
      final bytes = Uint8List.fromList([
        ...[0x2F, 0x2F, 0x20, 0x8A, 0x77, 0x8F, 0x4B, 0x0A],
        ...utf8.encode('f5d6\n'),
      ]);
      expect(findEntry(bytes)!.text, 'f5d6');
    });
  });

  group('takeEntry', () {
    test('takes the first text with the lines above it', () {
      final taken = takeEntry(_bytes('// a\n\nf5d6\n// b\nf5f6\n'), 'f5d6');
      expect(_text(taken.log), '// a\n\nf5d6\n');
      expect(_text(taken.rest), '// b\nf5f6\n');
    });

    test('keeps the bytes as they are', () {
      final sjisComment = [
        0x2F,
        0x2F,
        0x20,
        0x8A,
        0x77,
        0x8F,
        0x4B,
        0x0D,
        0x0A,
      ];
      final bytes = Uint8List.fromList([
        ...sjisComment,
        ...utf8.encode('f5d6\r\n'),
        ...sjisComment,
        ...utf8.encode('fix\r\n'),
      ]);
      final taken = takeEntry(bytes, 'f5d6');
      expect(taken.log, [...sjisComment, ...utf8.encode('f5d6\r\n')]);
      expect(taken.rest, [...sjisComment, ...utf8.encode('fix\r\n')]);
    });

    test('keeps BOM in learning list', () {
      final bom = [0xEF, 0xBB, 0xBF];
      final bytes = Uint8List.fromList([...bom, ...utf8.encode('f5d6\nfix\n')]);
      final taken = takeEntry(bytes, 'f5d6');
      expect(_text(taken.log), 'f5d6\n');
      expect(taken.rest, [...bom, ...utf8.encode('fix\n')]);
    });

    test('terminates the log with a line terminator', () {
      final taken = takeEntry(_bytes('// a\nf5d6'), 'f5d6');
      expect(_text(taken.log), '// a\nf5d6\n');
      expect(taken.rest, isEmpty);
    });

    test('takes only the first one of the same texts', () {
      final taken = takeEntry(_bytes('f5d6\nf5d6\n'), 'f5d6');
      expect(_text(taken.log), 'f5d6\n');
      expect(_text(taken.rest), 'f5d6\n');
    });

    test(
      'takes only the text if lines are inserted above it while learning',
      () {
        final taken = takeEntry(
          _bytes('// new\nf5f6\n// a\nf5d6\nfix\n'),
          'f5d6',
        );
        expect(_text(taken.log), 'f5d6\n');
        expect(_text(taken.rest), '// new\nf5f6\n// a\nfix\n');
      },
    );

    test('leaves learning list if the text is removed while learning', () {
      final bytes = _bytes('// a\nf5f6\n');
      final taken = takeEntry(bytes, 'f5d6');
      expect(_text(taken.log), 'f5d6\n');
      expect(taken.rest, bytes);
    });

    test('logs the skipped text as a comment', () {
      final taken = takeEntry(
        _bytes('// a\r\nf5f5\r\nfix\r\n'),
        'f5f5',
        skipReason: 'illegal move',
      );
      expect(
        _text(taken.log),
        '// a\r\n// [edax_runner] skipped (illegal move): f5f5\r\n',
      );
      expect(_text(taken.rest), 'fix\r\n');
      expect(findEntry(taken.log), isNull);
    });
  });

  test('isUtf16', () {
    expect(isUtf16(Uint8List.fromList([0xFF, 0xFE, 0x66, 0x00])), isTrue);
    expect(isUtf16(Uint8List.fromList([0xFE, 0xFF, 0x00, 0x66])), isTrue);
    expect(isUtf16(_bytes('f5d6')), isFalse);
    expect(isUtf16(_bytes('')), isFalse);
  });
}
