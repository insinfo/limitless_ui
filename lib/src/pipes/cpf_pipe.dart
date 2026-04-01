// ignore_for_file: prefer_is_not_operator

import 'package:ngdart/angular.dart';

/// Masks CPF strings by keeping either the first or the last four characters
/// visible.
///
/// The pipe expects a full 11-character CPF string. Values that are `null`, not
/// strings, or shorter than 11 characters return `null`.
@Pipe('cpfHidden', pure: true)
class CpfHiddenPipe {
  /// Transforms [value] using one of the supported patterns.
  ///
  /// Supported patterns:
  /// - `asteriskEnd`: keeps the first four characters visible.
  /// - `asteriskStart`: keeps the last four characters visible.
  String? transform(dynamic value, [String pattern = 'asteriskEnd']) {
    if (value == null) return null;
    if (!(value is String)) return null;
    if (value.length < 11) return null;

    final cpf = value;

    if (pattern == 'asteriskEnd') {
      return cpf.substring(0, 4).padRight(11, '*');
    } else if (pattern == 'asteriskStart') {
      return value.toString().substring(cpf.length - 4).padLeft(11, '*');
    } else {
      return cpf.substring(0, 4).padRight(11, '*');
    }
  }

  const CpfHiddenPipe();
}
