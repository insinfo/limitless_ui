// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/pipes/utility_pipes_test.dart

@TestOn('browser')
library;

import 'package:limitless_ui/src/exceptions/invalid_pipe_argument_exception.dart';
import 'package:limitless_ui/src/pipes/cpf_formatter_pipe.dart';
import 'package:limitless_ui/src/pipes/cpf_pipe.dart';
import 'package:limitless_ui/src/pipes/hide_string_pipe.dart';
import 'package:limitless_ui/src/pipes/text_transform_pipes.dart';
import 'package:test/test.dart';

void main() {
  group('LiCpfFormatterPipe', () {
    const pipe = LiCpfFormatterPipe();

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

  group('LiCpfHiddenPipe', () {
    const pipe = LiCpfHiddenPipe();

    test('masks the end of the CPF by default', () {
      expect(pipe.transform('12345678901'), '1234*******');
    });

    test('can keep only the last four characters visible', () {
      expect(pipe.transform('12345678901', 'asteriskStart'), '*******8901');
    });

    test('can use the federal public display pattern', () {
      expect(
          pipe.transform('123.456.789-01', 'governoFederal'), '***.456.789-**');
    });

    test('returns null for incomplete values', () {
      expect(pipe.transform('1234567890'), isNull);
      expect(pipe.transform(12345678901), isNull);
    });
  });

  group('LiHideStringPipe', () {
    const pipe = LiHideStringPipe();

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

  group('LiPortugueseTitleCasePipe', () {
    const pipe = LiPortugueseTitleCasePipe();

    test('uses Portuguese connector and acronym rules', () {
      expect(pipe.transform('PARCELAMENTO DE IPTU'), 'Parcelamento de IPTU');
      expect(
        pipe.transform("SANTA BÁRBARA D'OESTE"),
        "Santa Bárbara D'Oeste",
      );
    });

    test('accepts custom lowercase words and acronyms', () {
      expect(
        pipe.transform(
          'relatório conforme norma abc',
          const <String>['conforme'],
          const <String, String>{'abc': 'ABC'},
        ),
        'Relatório conforme Norma ABC',
      );
    });

    test('rejects unsupported argument types', () {
      expect(
        () => pipe.transform(12345),
        throwsA(isA<InvalidPipeArgumentException>()),
      );
    });
  });

  group('LiTruncatePipe', () {
    const pipe = LiTruncatePipe();

    test('truncates text with the default trail', () {
      expect(pipe.transform('How to truncate text in angular', 6), 'How...');
    });

    test('supports custom trail and empty values', () {
      expect(pipe.transform('abcdef', 4, '#'), 'abc#');
      expect(pipe.transform('', 4), '');
      expect(pipe.transform(null, 4), isNull);
    });

    test('rejects unsupported argument types', () {
      expect(
        () => pipe.transform(12345, 2),
        throwsA(isA<InvalidPipeArgumentException>()),
      );
    });
  });

  group('LiPascalCasePipe', () {
    const pipe = LiPascalCasePipe();

    test('converts separated words to PascalCase', () {
      expect(pipe.transform('How to text in angular'), 'HowToTextInAngular');
      expect(pipe.transform('relatório de IPTU'), 'RelatórioDeIptu');
    });

    test('returns null and empty values unchanged', () {
      expect(pipe.transform(null), isNull);
      expect(pipe.transform(''), '');
    });

    test('rejects unsupported argument types', () {
      expect(
        () => pipe.transform(12345),
        throwsA(isA<InvalidPipeArgumentException>()),
      );
    });
  });
}
