// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_numeric_and_selection_rules_test.dart

@TestOn('browser')
library;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:limitless_ui/src/validation/li_number_parsing.dart';
import 'package:test/test.dart';

void main() {
  const pt = LiRuleContext();
  const en = LiRuleContext(locale: 'en_US');

  group('LiRule.min / LiRule.max', () {
    test('compare numbers and pass on empty values', () {
      expect(const LiRule.min(1).validate(1, pt), isNull);
      expect(const LiRule.min(1).validate(0, pt),
          'Informe um valor maior ou igual a 1.');
      expect(const LiRule.min(1).validate(null, pt), isNull);
      expect(const LiRule.min(1).validate('', pt), isNull);
      expect(const LiRule.max(2.5).validate(3, pt),
          'Informe um valor menor ou igual a 2,5.');
      expect(const LiRule.max(2.5).validate(3, en),
          'Enter a value less than or equal to 2.5.');
      expect(const LiRule.min(10).validate(9, en),
          'Enter a value greater than or equal to 10.');
    });

    test('read strings in machine format and in the locale format', () {
      expect(const LiRule.min(3).validate('2.5', pt), isNotNull);
      expect(const LiRule.min(3).validate('2,5', pt), isNotNull);
      expect(const LiRule.max(3).validate('2,5', pt), isNull);
      expect(const LiRule.min(3).validate('abc', pt), isNull,
          reason: 'Text that is not a number is not their concern.');
    });

    test('use the message from the rule, then liMessages', () {
      expect(const LiRule.min(1, 'Mínimo 1.').validate(0, pt), 'Mínimo 1.');
      expect(
        const LiRule.min(1).validate(
          0,
          const LiRuleContext(messages: <String, String>{'min': 'Pouco.'}),
        ),
        'Pouco.',
      );
    });
  });

  group('LiRule.integer', () {
    test('accepts whole numbers and rejects fractions and text', () {
      const rule = LiRule.integer();
      expect(rule.code, 'integer');
      expect(rule.validate(3, pt), isNull);
      expect(rule.validate(3.0, pt), isNull);
      expect(rule.validate('12', pt), isNull);
      expect(rule.validate(null, pt), isNull);
      expect(rule.validate('', pt), isNull);
      expect(rule.validate(3.5, pt), 'Informe um número inteiro.');
      expect(rule.validate('3,5', pt), 'Informe um número inteiro.');
      expect(rule.validate('abc', en), 'Enter a whole number.');
    });
  });

  group('LiRule.minSelected / LiRule.maxSelected', () {
    test('count iterables and maps', () {
      const minRule = LiRule.minSelected(2);
      const maxRule = LiRule.maxSelected(1);
      expect(minRule.validate(<int>[1, 2], pt), isNull);
      expect(minRule.validate(<int>[1], pt), 'Selecione pelo menos 2 opções.');
      expect(minRule.validate(<int>[1], en), 'Select at least 2 options.');
      expect(minRule.validate(<int>[], pt), isNull,
          reason: 'Empty passes; LiRule.required() covers it.');
      expect(minRule.validate(null, pt), isNull);
      expect(maxRule.validate(<String, int>{'a': 1}, pt), isNull);
      expect(maxRule.validate(<int>{1, 2}, pt), 'Selecione no máximo 1 opção.');
      expect(maxRule.validate(<int>[1, 2], en), 'Select no more than 1 option.');
    });

    test('required on a selection means at least one', () {
      expect(const LiRule.required().validate(<int>[], pt), isNotNull);
      expect(const LiRule.required().validate(<int>[1], pt), isNull);
    });
  });

  group('number parsing helpers', () {
    test('parse machine format first, then the locale', () {
      expect(liParseNumber('3.5'), 3.5);
      expect(liParseNumber('3,5'), 3.5);
      expect(liParseNumber('1.234,5'), 1234.5);
      expect(liParseNumber('1,234.5', locale: 'en_US'), 1234.5);
      expect(liParseNumber('-'), isNull);
      expect(liParseNumber(','), isNull);
      expect(liParseNumber(7), 7);
      expect(liParseNumber(null), isNull);
    });

    test('format without grouping and with the locale separator', () {
      expect(liDecimalSeparator('pt_BR'), ',');
      expect(liDecimalSeparator('en_US'), '.');
      expect(liFormatNumber(3, decimalSeparator: ','), '3');
      expect(liFormatNumber(3.5, decimalSeparator: ','), '3,5');
      expect(liFormatNumber(1.005, decimalPlaces: 2), anyOf('1', '1.01'));
      expect(liFormatNumber(1.5, decimalPlaces: 2), '1.5');
      expect(liFormatNumber(-0.0), '0');
    });
  });
}
