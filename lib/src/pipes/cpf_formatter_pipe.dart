import 'package:ngdart/angular.dart';

import '../exceptions/invalid_pipe_argument_exception.dart';

/// Formats CPF values either as a masked document number or as digits only.
///
/// Non-digit characters are stripped before formatting. The pipe accepts
/// `String` and `num` values.
@Pipe('cpfFormatter', pure: true)
class CpfFormatterPipe {
  const CpfFormatterPipe();

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
      _ => throw InvalidPipeArgumentException(CpfFormatterPipe, value),
    };

    final digits = source.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return '';
    }

    switch (pattern.trim()) {
      case 'digits':
        return digits;
      case 'cpfMask':
      default:
        return _formatCpf(digits);
    }
  }

  /// Applies the standard CPF mask to up to 11 digits.
  String _formatCpf(String digits) {
    final normalized = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();

    for (var index = 0; index < normalized.length; index++) {
      if (index == 3 || index == 6) {
        buffer.write('.');
      } else if (index == 9) {
        buffer.write('-');
      }
      buffer.write(normalized[index]);
    }

    return buffer.toString();
  }
}
