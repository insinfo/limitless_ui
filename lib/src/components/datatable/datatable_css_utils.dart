/// Utility functions for datatable CSS values.
///
/// These helpers are intentionally stateless and pure, which makes them safe to
/// share across the component and future controllers.
class DatatableCssUtils {
  DatatableCssUtils._();

  /// Formats a pixel value while avoiding unnecessary decimal places.
  static String formatPixelValue(double value) {
    final roundedValue = value.roundToDouble();
    if ((value - roundedValue).abs() < 0.01) {
      return '${roundedValue.toInt()}px';
    }

    return '${value.toStringAsFixed(2)}px';
  }

  /// Merges two inline CSS declaration strings.
  ///
  /// Returns `null` when both inputs are empty, allowing callers to avoid
  /// emitting empty `style` attributes.
  static String? mergeDeclarations(String? baseStyle, String? extraStyle) {
    final parts = <String>[];
    final normalizedBase = baseStyle?.trim();
    final normalizedExtra = extraStyle?.trim();

    if (normalizedBase != null && normalizedBase.isNotEmpty) {
      parts.add(normalizedBase);
    }

    if (normalizedExtra != null && normalizedExtra.isNotEmpty) {
      parts.add(normalizedExtra);
    }

    if (parts.isEmpty) {
      return null;
    }

    return parts.join('; ');
  }

  /// Parses a CSS length into pixels when the unit can be resolved locally.
  ///
  /// `px`, `em`, `rem`, and unitless values are supported. Relative viewport or
  /// percentage values return `null` when [allowRelative] is `false`.
  static double? parseLength(
    String? rawValue, {
    bool allowRelative = true,
  }) {
    if (rawValue == null) {
      return null;
    }

    final normalized = rawValue.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    if (!allowRelative &&
        (normalized.endsWith('%') ||
            normalized.endsWith('vw') ||
            normalized.endsWith('vh') ||
            normalized.endsWith('vmin') ||
            normalized.endsWith('vmax'))) {
      return null;
    }

    final numericValue =
        double.tryParse(normalized.replaceAll(RegExp(r'[^0-9\.-]'), ''));
    if (numericValue == null) {
      return null;
    }

    if (normalized.endsWith('rem') || normalized.endsWith('em')) {
      return numericValue * 16;
    }

    if (normalized.endsWith('px')) {
      return numericValue;
    }

    return numericValue;
  }
}
