// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/pipes/utility_pipes_test.dart

@TestOn('browser')
library;

import 'package:limitless_ui/src/exceptions/invalid_pipe_argument_exception.dart';
import 'package:limitless_ui/src/pipes/cpf_formatter_pipe.dart';
import 'package:limitless_ui/src/pipes/cpf_pipe.dart';
import 'package:limitless_ui/src/pipes/hide_string_pipe.dart';
import 'package:test/test.dart';

void main() {
  group('CpfFormatterPipe', () {
    const pipe = CpfFormatterPipe();

    test('formats CPF values with the default mask', () {
      expect(pipe.transform('12345678901'), '123.456.789-01');
      expect(pipe.transform('123.456.789-01'), '123.456.789-01');
      expect(pipe.transform('1234567890123'), '123.456.789-01');
    });

    test('returns digits only when requested', () {
      expect(pipe.transform('123.456.789-01', 'digits'), '12345678901');
      expect(pipe.transform(12345678901, 'digits'), '12345678901');
    });

    test('rejects unsupported argument types', () {
      expect(
        () => pipe.transform(const <int>[1, 2, 3]),
        throwsA(isA<InvalidPipeArgumentException>()),
      );
    });
  });

  group('CpfHiddenPipe', () {
    const pipe = CpfHiddenPipe();

    test('masks the end of the CPF by default', () {
      expect(pipe.transform('12345678901'), '1234*******');
    });

    test('can keep only the last four characters visible', () {
      expect(pipe.transform('12345678901', 'asteriskStart'), '*******8901');
    });

    test('returns null for incomplete values', () {
      expect(pipe.transform('1234567890'), isNull);
      expect(pipe.transform(12345678901), isNull);
    });
  });

  group('HideStringPipe', () {
    const pipe = HideStringPipe();

    test('keeps a visible prefix and masks the rest', () {
      expect(pipe.transform('abcdef', 3), 'abc***');
      expect(pipe.transform('abcdef', 3, '#'), 'abc###');
    });

    test('returns the original value when it is shorter than the prefix', () {
      expect(pipe.transform('ab', 3), 'ab');
      expect(pipe.transform('', 3), '');
    });

    test('rejects unsupported argument types', () {
      expect(
        () => pipe.transform(12345),
        throwsA(isA<InvalidPipeArgumentException>()),
      );
    });
  });
}