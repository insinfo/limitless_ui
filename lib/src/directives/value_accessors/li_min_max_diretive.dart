import 'dart:html';

import 'package:ngx_dart/angular.dart';

/// Clamps numeric input values to the configured `liMin` and `liMax` range.
///
/// The directive listens to keyboard input and normalizes out-of-range values
/// back into the allowed interval.
@Directive(selector: '[liMinMax]')
class LiMinMaxDirective {
  late InputElement inputElement;
  final Element _el;

  /// Minimum allowed numeric value.
  @Input('liMin')
  double? liMin;

  /// Maximum allowed numeric value.
  @Input('liMax')
  double? liMax;

  LiMinMaxDirective(this._el) {
    if (_el is! InputElement) {
      throw Exception('LiMinMaxDirective has to be applied to an InputElement');
    }
    inputElement = _el;

    inputElement.onKeyUp.listen((e) {
      final valorAtual =
          double.tryParse((e.target as InputElement).value ?? '') ?? 0;
      if (e.keyCode >= 48 && e.keyCode <= 57 ||
          e.keyCode >= 96 && e.keyCode <= 105) {
        final min = liMin;
        final max = liMax;
        if (min != null && valorAtual < min) {
          //  e.preventDefault();
          inputElement.value = min.toString();
        }
        if (max != null && valorAtual > max) {
          // e.preventDefault();
          inputElement.value = max.toString();
        }
      }
    });
  }
}
