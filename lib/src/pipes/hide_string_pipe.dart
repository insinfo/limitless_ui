import 'package:essential_core/essential_core.dart';

import 'package:ngx_dart/angular.dart';
import '../exceptions/invalid_pipe_argument_exception.dart';

/// Masks part of a string while keeping a visible prefix.
///
/// This pipe delegates the masking logic to `EssentialCoreUtils`, the
/// platform-agnostic helper added to the shared core package.
@Pipe('liHideString', pure: true)
class LiHideStringPipe {
  const LiHideStringPipe();

  /// Returns [value] with only [visibleCharacters] left untouched and the
  /// remaining characters replaced by [trail].
  String? transform(dynamic value,
      [int visibleCharacters = 2, String trail = '*']) {
    if (value == null) return null;
    if (value is String) {
      if (value.isEmpty) {
        return '';
      }
      return EssentialCoreUtils.hidePartsOfString(value,
          visibleCharacters: visibleCharacters, trail: trail);
    } else {
      throw InvalidPipeArgumentException(LiHideStringPipe, value);
    }
  }
}
