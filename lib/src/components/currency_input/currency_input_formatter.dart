import 'dart:math' as math;

import 'package:intl/intl.dart';

class CurrencyInputFormatter {
  CurrencyInputFormatter({
    this.locale = 'pt_BR',
    this.currencyCode = 'BRL',
    this.decimalDigits = 2,
  })  : assert(decimalDigits >= 0),
        _displayFormat = NumberFormat.currency(
          locale: locale,
          name: currencyCode,
          symbol: '',
          decimalDigits: decimalDigits,
        ),
        _groupingFormat = NumberFormat.decimalPattern(locale);

  final String locale;
  final String currencyCode;
  final int decimalDigits;
  final NumberFormat _displayFormat;
  final NumberFormat _groupingFormat;

  static final RegExp _hasDigit = RegExp(r'\d');
  static final RegExp _nonDigits = RegExp(r'[^0-9]');

  static String currencySymbol(
    String currencyCode, {
    String locale = 'pt_BR',
  }) {
    return NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    ).currencySymbol;
  }

  String get decimalSeparator => _displayFormat.symbols.DECIMAL_SEP;

  String get groupingSeparator => _displayFormat.symbols.GROUP_SEP;

  int get minorUnitFactor => math.pow(10, decimalDigits).toInt();

  String sanitizeForEditing(String? rawValue) {
    final raw = rawValue?.trim() ?? '';
    if (raw.isEmpty) {
      return '';
    }

    final stripped = _stripToSupportedCharacters(raw);
    if (stripped.isEmpty || !_hasDigit.hasMatch(stripped)) {
      return '';
    }

    final lastComma = stripped.lastIndexOf(',');
    final lastDot = stripped.lastIndexOf('.');
    final lastSeparatorIndex = lastComma > lastDot ? lastComma : lastDot;
    final endsWithSeparator = stripped.endsWith(',') || stripped.endsWith('.');

    if (lastSeparatorIndex != -1) {
      final wholeCandidate =
          stripped.substring(0, lastSeparatorIndex).replaceAll(_nonDigits, '');
      final fractionCandidate =
          stripped.substring(lastSeparatorIndex + 1).replaceAll(_nonDigits, '');
      final useSeparatorAsDecimal =
          fractionCandidate.length <= decimalDigits || endsWithSeparator;

      if (useSeparatorAsDecimal) {
        final wholeDigits =
            _normalizeWholeDigits(wholeCandidate, fallbackZero: true);
        final fractionDigits = fractionCandidate.length > decimalDigits
            ? fractionCandidate.substring(0, decimalDigits)
            : fractionCandidate;

        if (decimalDigits == 0) {
          return wholeDigits;
        }

        if (endsWithSeparator && fractionDigits.isEmpty) {
          return '$wholeDigits$decimalSeparator';
        }

        if (fractionDigits.isEmpty) {
          return wholeDigits;
        }

        return '$wholeDigits$decimalSeparator$fractionDigits';
      }
    }

    return _normalizeWholeDigits(stripped.replaceAll(_nonDigits, ''));
  }

  int? minorUnitsFromText(String? rawValue) {
    final sanitized = sanitizeForEditing(rawValue);
    if (sanitized.isEmpty) {
      return null;
    }

    if (decimalDigits == 0) {
      return int.parse(sanitized.replaceAll(_nonDigits, ''));
    }

    final parts = sanitized.split(decimalSeparator);
    final wholePart = parts.first.isEmpty ? '0' : parts.first;
    final fractionPart = parts.length > 1
        ? parts[1].padRight(decimalDigits, '0').substring(0, decimalDigits)
        : ''.padRight(decimalDigits, '0');

    return int.parse(wholePart) * minorUnitFactor + int.parse(fractionPart);
  }

  int? minorUnitsFromValue(num? value) {
    if (value == null) {
      return null;
    }
    return (value * minorUnitFactor).round();
  }

  double? valueFromMinorUnits(int? minorUnits) {
    if (minorUnits == null) {
      return null;
    }
    return minorUnits / minorUnitFactor;
  }

  String formatForEditing(int? minorUnits) {
    if (minorUnits == null) {
      return '';
    }
    return _format(minorUnits, grouped: false);
  }

  String formatForDisplay(int? minorUnits) {
    if (minorUnits == null) {
      return '';
    }
    return _format(minorUnits, grouped: true);
  }

  String _format(int minorUnits, {required bool grouped}) {
    final absMinorUnits = minorUnits.abs();
    final whole = absMinorUnits ~/ minorUnitFactor;
    final fraction = absMinorUnits % minorUnitFactor;
    final wholeText =
        grouped ? _groupingFormat.format(whole) : whole.toString();
    final signal = minorUnits < 0 ? '-' : '';

    if (decimalDigits == 0) {
      return '$signal$wholeText';
    }

    return '$signal$wholeText$decimalSeparator${fraction.toString().padLeft(decimalDigits, '0')}';
  }

  String _stripToSupportedCharacters(String rawValue) {
    final buffer = StringBuffer();
    for (final rune in rawValue.runes) {
      final char = String.fromCharCode(rune);
      if (_hasDigit.hasMatch(char) || char == ',' || char == '.') {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  String _normalizeWholeDigits(
    String digits, {
    bool fallbackZero = false,
  }) {
    final normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (normalized.isEmpty) {
      return fallbackZero ? '0' : '';
    }
    return normalized;
  }
}

class BrazilianCurrencyInputFormatter {
  BrazilianCurrencyInputFormatter._();

  static final CurrencyInputFormatter _formatter = CurrencyInputFormatter(
    locale: 'pt_BR',
    currencyCode: 'BRL',
    decimalDigits: 2,
  );

  static String sanitizeForEditing(String? rawValue) =>
      _formatter.sanitizeForEditing(rawValue);

  static int? minorUnitsFromText(String? rawValue) =>
      _formatter.minorUnitsFromText(rawValue);

  static int? minorUnitsFromValue(num? value) =>
      _formatter.minorUnitsFromValue(value);

  static double? valueFromMinorUnits(int? minorUnits) =>
      _formatter.valueFromMinorUnits(minorUnits);

  static String formatForEditing(int? minorUnits) =>
      _formatter.formatForEditing(minorUnits);

  static String formatForDisplay(int? minorUnits) =>
      _formatter.formatForDisplay(minorUnits);
}
