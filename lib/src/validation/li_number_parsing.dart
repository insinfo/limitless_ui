import 'package:intl/intl.dart';

/// Number parsing and formatting shared by the numeric `li-input` mode and the
/// numeric rules (`LiRule.min`, `LiRule.max`, `LiRule.integer`).
///
/// Internal to the library: it is not exported by `limitless_ui.dart`.

final Map<String, String> _decimalSeparatorCache = <String, String>{};

/// Decimal separator used by [locale], read from `intl` number symbols.
///
/// Falls back to `.` for English locales and `,` for everything else when the
/// locale is unknown to `intl`.
String liDecimalSeparator(String locale) {
  final normalized = locale.trim();
  return _decimalSeparatorCache.putIfAbsent(normalized, () {
    if (normalized.isEmpty) {
      return ',';
    }
    try {
      final separator =
          NumberFormat.decimalPattern(normalized).symbols.DECIMAL_SEP;
      return separator.isEmpty ? ',' : separator;
    } catch (_) {
      return normalized.toLowerCase().startsWith('en') ? '.' : ',';
    }
  });
}

/// Reads [value] as a number.
///
/// `num` values are returned as they are. Strings are read in machine format
/// first (`3.5`, `-12`), which is how a model or an API usually carries them,
/// and only then in the format of [locale] (`3,5` or `1.234,5` in `pt_BR`).
/// Returns `null` for `null`, blank strings and text that is not a number.
num? liParseNumber(dynamic value, {String locale = 'pt_BR'}) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.isNaN ? null : value;
  }

  final text = value.toString().trim();
  if (text.isEmpty) {
    return null;
  }

  final machine = num.tryParse(text);
  if (machine != null && !machine.isNaN && !machine.isInfinite) {
    return machine;
  }

  return liParseLocalizedNumber(text, liDecimalSeparator(locale));
}

/// Reads [text] written with [decimalSeparator].
///
/// Characters other than digits, a leading `-` and the separator are dropped,
/// so grouping separators (`1.234,5` in `pt_BR`) do not get in the way. An
/// incomplete entry such as `-`, `,` or `-,` reads as `null`; a trailing
/// separator (`3,`) reads as the whole number. Returns an `int` when there is
/// no fractional part in the text and a `double` otherwise.
num? liParseLocalizedNumber(String text, String decimalSeparator) {
  final buffer = StringBuffer();
  var seenSeparator = false;
  var seenDigit = false;
  final trimmed = text.trim();
  for (var i = 0; i < trimmed.length; i++) {
    final character = trimmed[i];
    if (_isDigit(character)) {
      buffer.write(character);
      seenDigit = true;
    } else if (character == '-' && buffer.isEmpty) {
      buffer.write('-');
    } else if (character == decimalSeparator && !seenSeparator) {
      buffer.write('.');
      seenSeparator = true;
    }
  }

  if (!seenDigit) {
    return null;
  }

  var normalized = buffer.toString();
  if (normalized.endsWith('.')) {
    normalized = normalized.substring(0, normalized.length - 1);
    seenSeparator = false;
  }
  if (normalized.startsWith('.')) {
    normalized = '0$normalized';
  } else if (normalized.startsWith('-.')) {
    normalized = '-0${normalized.substring(1)}';
  }

  return seenSeparator
      ? double.tryParse(normalized)
      : int.tryParse(normalized) ?? double.tryParse(normalized);
}

/// Writes [value] with [decimalSeparator] and no grouping.
///
/// Whole numbers are written without a fractional part (`3`, not `3.0`).
/// With [decimalPlaces], the value is rounded to that many places and
/// trailing zeros are dropped (`1.5`, not `1.50`).
String liFormatNumber(
  num value, {
  String decimalSeparator = '.',
  int? decimalPlaces,
}) {
  if (value.isNaN || value.isInfinite) {
    return '';
  }

  String text;
  if (decimalPlaces != null && decimalPlaces >= 0) {
    text = _stripTrailingZeros(value.toStringAsFixed(decimalPlaces));
  } else if (value == value.truncateToDouble() && value.abs() < 1e15) {
    text = value.toInt().toString();
  } else {
    text = value.toString();
    if (text.contains('e')) {
      text = _stripTrailingZeros(value.toStringAsFixed(10));
    }
  }

  if (text == '-0') {
    text = '0';
  }
  return decimalSeparator == '.' ? text : text.replaceAll('.', decimalSeparator);
}

String _stripTrailingZeros(String text) {
  if (!text.contains('.')) {
    return text;
  }
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

bool _isDigit(String character) {
  final code = character.codeUnitAt(0);
  return code >= 0x30 && code <= 0x39;
}
