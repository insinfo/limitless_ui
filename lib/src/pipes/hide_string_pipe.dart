import 'package:essential_core/essential_core.dart';

import 'package:ngdart/angular.dart';
import '../exceptions/invalid_pipe_argument_exception.dart';

/// Masks part of a string while keeping a visible prefix.
///
/// This pipe delegates the masking logic to `EssentialCoreUtils` so the same
/// behavior can be reused outside AngularDart templates.
@Pipe('hideString', pure: true)
class HideStringPipe {
  const HideStringPipe();

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
      throw InvalidPipeArgumentException(HideStringPipe, value);
    }
  }
}
