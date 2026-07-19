// ignore_for_file: prefer_is_not_operator

import 'package:essential_core/essential_core.dart';
import 'package:ngx_dart/angular.dart';

/// Masks CPF strings for public display.
///
/// The pipe sanitizes the value with `essential_core` before applying one of
/// the supported display patterns. Values that are `null`, not strings, or do
/// not contain 11 digits return `null`.
@Pipe('liCpfHidden', pure: true)
class LiCpfHiddenPipe {
  /// Transforms [value] using one of the supported patterns.
  ///
  /// Supported patterns:
  /// - `governoFederal` or `federal`: returns `***.456.789-**`.
  /// - `asteriskEnd`: keeps the first four characters visible.
  /// - `asteriskStart`: keeps the last four characters visible.
  String? transform(dynamic value, [String pattern = 'asteriskEnd']) {
    if (value == null) return null;
    if (!(value is String)) return null;
    final cpf = EssentialCoreUtils.sanitizarCpf(value);
    if (cpf.length != 11) return null;

    switch (pattern.trim()) {
      case 'governoFederal':
      case 'federal':
        return EssentialCoreUtils.mascararCpfGovernoFederal(cpf);
      case 'asteriskStart':
        return cpf.substring(cpf.length - 4).padLeft(11, '*');
      case 'asteriskEnd':
      default:
        return EssentialCoreUtils.hidePartsOfString(
          cpf,
          visibleCharacters: 4,
        );
    }
  }

  const LiCpfHiddenPipe();
}
