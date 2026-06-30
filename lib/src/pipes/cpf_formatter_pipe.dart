import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';

import '../exceptions/invalid_pipe_argument_exception.dart';

/// Formats CPF values either as a masked document number or as digits only.
///
/// Non-digit characters are stripped before formatting. The pipe accepts
/// `String` and `num` values.
@Pipe('liCpfFormatter', pure: true)
class LiCpfFormatterPipe {
  const LiCpfFormatterPipe();

  /// Transforms [value] according to [pattern].
  ///
  /// Supported patterns:
  /// - `cpfMask`: returns the standard `XXX.XXX.XXX-XX` representation.
  /// - `digits`: returns only numeric characters.
  String? transform(dynamic value, [String pattern = 'cpfMask']) {
    if (value == null) {
      return null;
    }

    final source = switch (value) {
      String stringValue => stringValue,
      num numberValue => numberValue.toString(),
      _ => throw InvalidPipeArgumentException(LiCpfFormatterPipe, value),
    };

    final digits = EssentialCoreUtils.sanitizarCpf(source);
    if (digits.isEmpty) {
      return '';
    }

    switch (pattern.trim()) {
      case 'digits':
        return digits;
      case 'cpfMask':
      default:
        return _formatCpfDisplay(digits);
    }
  }

  /// Applies the standard CPF mask to up to 11 digits.
  String _formatCpfDisplay(String digits) {
    final normalized = digits.length > 11 ? digits.substring(0, 11) : digits;
    if (normalized.length == 11) {
      return EssentialCoreUtils.formatarCpf(normalized);
    }
    return _partialCpfMask.format(normalized, eager: false);
  }

  static final InteractiveTextMask _partialCpfMask =
      InteractiveTextMask.cpf(eager: false);
}
