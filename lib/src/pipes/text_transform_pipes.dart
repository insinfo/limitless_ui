import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';

import '../exceptions/invalid_pipe_argument_exception.dart';

/// Converts text to Portuguese-aware title case.
@Pipe('liPortugueseTitleCase', pure: true)
class LiPortugueseTitleCasePipe {
  const LiPortugueseTitleCasePipe();

  /// Transforms [value] with the smart Portuguese title-case rules from
  /// `essential_core`.
  String? transform(
    dynamic value, [
    List<String> lowercaseWords = const <String>[],
    Map<String, String> acronyms = const <String, String>{},
  ]) {
    if (value == null) return null;
    if (value is! String) {
      throw InvalidPipeArgumentException(LiPortugueseTitleCasePipe, value);
    }
    if (value.isEmpty) return '';

    return value.toPortugueseTitleCase(
      lowercaseWords: lowercaseWords,
      acronyms: acronyms,
    );
  }
}

/// Truncates text to a maximum length.
@Pipe('liTruncate', pure: true)
class LiTruncatePipe {
  const LiTruncatePipe();

  /// Returns [value] truncated to [limit], appending [trail] when needed.
  String? transform(dynamic value, int limit, [String trail = '...']) {
    if (value == null) return null;
    if (value is! String) {
      throw InvalidPipeArgumentException(LiTruncatePipe, value);
    }
    if (value.isEmpty) return '';

    return EssentialCoreUtils.truncate(value, limit, trail);
  }
}

/// Converts text to PascalCase.
@Pipe('liPascalCase', pure: true)
class LiPascalCasePipe {
  const LiPascalCasePipe();

  /// Returns [value] in PascalCase, removing separators and preserving letters
  /// and digits.
  String? transform(dynamic value) {
    if (value == null) return null;
    if (value is! String) {
      throw InvalidPipeArgumentException(LiPascalCasePipe, value);
    }
    if (value.isEmpty) return '';

    return _toPascalCase(value);
  }

  static String _toPascalCase(String value) {
    final words = RegExp(r'[\p{L}\p{N}]+', unicode: true)
        .allMatches(value)
        .map((match) => match.group(0)!)
        .where((word) => word.isNotEmpty);

    return words.map(_capitalizeWord).join();
  }

  static String _capitalizeWord(String word) {
    final lower = word.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}
