import 'package:limitless_ui/src/components/br_currency_input/br_currency_input_formatter.dart';
import 'package:test/test.dart';

void main() {
  group('BrazilianCurrencyInputFormatter.sanitizeForEditing', () {
    test('keeps valid decimal input and normalizes leading zeros', () {
      expect(
        BrazilianCurrencyInputFormatter.sanitizeForEditing('00012,3'),
        '12,3',
      );
      expect(
        BrazilianCurrencyInputFormatter.sanitizeForEditing('0012.34'),
        '12,34',
      );
    });

    test('treats last separator as decimal when applicable', () {
      expect(
        BrazilianCurrencyInputFormatter.sanitizeForEditing('1.234,56'),
        '1234,56',
      );
      expect(
        BrazilianCurrencyInputFormatter.sanitizeForEditing('1,234.5'),
        '1234,5',
      );
      expect(
        BrazilianCurrencyInputFormatter.sanitizeForEditing('12,'),
        '12,',
      );
    });

    test('drops invalid characters and returns empty when no digits remain', () {
      expect(
        BrazilianCurrencyInputFormatter.sanitizeForEditing('R\$ 1.234,56'),
        '1234,56',
      );
      expect(
        BrazilianCurrencyInputFormatter.sanitizeForEditing('abc'),
        '',
      );
      expect(
        BrazilianCurrencyInputFormatter.sanitizeForEditing(null),
        '',
      );
    });
  });

  group('BrazilianCurrencyInputFormatter conversion helpers', () {
    test('converts sanitized text to minor units', () {
      expect(
        BrazilianCurrencyInputFormatter.minorUnitsFromText('1.234,56'),
        123456,
      );
      expect(
        BrazilianCurrencyInputFormatter.minorUnitsFromText('12,3'),
        1230,
      );
      expect(
        BrazilianCurrencyInputFormatter.minorUnitsFromText(''),
        isNull,
      );
    });

    test('converts numeric value to minor units and back', () {
      expect(
        BrazilianCurrencyInputFormatter.minorUnitsFromValue(12.34),
        1234,
      );
      expect(
        BrazilianCurrencyInputFormatter.valueFromMinorUnits(1234),
        12.34,
      );
      expect(
        BrazilianCurrencyInputFormatter.valueFromMinorUnits(null),
        isNull,
      );
    });

    test('formats values for editing and display including negatives', () {
      expect(
        BrazilianCurrencyInputFormatter.formatForEditing(1234),
        '12,34',
      );
      expect(
        BrazilianCurrencyInputFormatter.formatForDisplay(123456),
        '1.234,56',
      );
      expect(
        BrazilianCurrencyInputFormatter.formatForDisplay(-123456),
        '-1.234,56',
      );
      expect(
        BrazilianCurrencyInputFormatter.formatForEditing(null),
        '',
      );
    });
  });
}
