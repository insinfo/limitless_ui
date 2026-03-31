import 'package:limitless_ui/src/components/currency_input/currency_input_formatter.dart';
import 'package:test/test.dart';

void main() {
  group('BrazilianCurrencyInputFormatter compatibility wrapper', () {
    test('keeps the Brazilian behaviour intact', () {
      expect(
        BrazilianCurrencyInputFormatter.sanitizeForEditing('1.234,56'),
        '1234,56',
      );
      expect(
        BrazilianCurrencyInputFormatter.minorUnitsFromText('12,3'),
        1230,
      );
      expect(
        BrazilianCurrencyInputFormatter.formatForDisplay(123456),
        '1.234,56',
      );
    });
  });

  group('CurrencyInputFormatter for BRL', () {
    final formatter = CurrencyInputFormatter(
      locale: 'pt_BR',
      currencyCode: 'BRL',
    );

    test('sanitizes and formats values with comma decimals', () {
      expect(formatter.sanitizeForEditing('R\$ 0012,3'), '12,3');
      expect(formatter.minorUnitsFromText('1.234,56'), 123456);
      expect(formatter.formatForEditing(1234), '12,34');
      expect(formatter.formatForDisplay(123456), '1.234,56');
    });
  });

  group('CurrencyInputFormatter for USD', () {
    final formatter = CurrencyInputFormatter(
      locale: 'en_US',
      currencyCode: 'USD',
    );

    test('supports dot decimals and comma group separators', () {
      expect(formatter.sanitizeForEditing('\$ 0012.3'), '12.3');
      expect(formatter.minorUnitsFromText('1,234.56'), 123456);
      expect(formatter.formatForEditing(1234), '12.34');
      expect(formatter.formatForDisplay(123456), '1,234.56');
    });
  });

  group('CurrencyInputFormatter for EUR', () {
    final formatter = CurrencyInputFormatter(
      locale: 'de_DE',
      currencyCode: 'EUR',
    );

    test('supports European decimal/group formatting', () {
      expect(formatter.sanitizeForEditing('€ 0012,3'), '12,3');
      expect(formatter.minorUnitsFromText('1.234,56'), 123456);
      expect(formatter.formatForEditing(1234), '12,34');
      expect(formatter.formatForDisplay(123456), '1.234,56');
    });
  });

  group('CurrencyInputFormatter shared helpers', () {
    test('converts numeric value to minor units and back', () {
      final formatter = CurrencyInputFormatter(
        locale: 'en_US',
        currencyCode: 'USD',
      );

      expect(formatter.minorUnitsFromValue(12.34), 1234);
      expect(formatter.valueFromMinorUnits(1234), 12.34);
      expect(formatter.valueFromMinorUnits(null), isNull);
    });

    test('resolves common currency symbols', () {
      expect(
        CurrencyInputFormatter.currencySymbol('BRL', locale: 'pt_BR'),
        'R\$',
      );
      expect(
        CurrencyInputFormatter.currencySymbol('USD', locale: 'en_US'),
        '\$',
      );
      expect(
        CurrencyInputFormatter.currencySymbol('EUR', locale: 'de_DE'),
        '€',
      );
    });
  });
}
