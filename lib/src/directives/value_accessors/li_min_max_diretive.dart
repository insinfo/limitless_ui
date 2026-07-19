import 'dart:js_interop';

import 'package:web/web.dart' as web;
import 'package:ngx_dart/angular.dart';

/// Clamps numeric input values to the configured `liMin` and `liMax` range.
///
/// The directive listens to keyboard input and normalizes out-of-range values
/// back into the allowed interval.
@Directive(selector: '[liMinMax]')
class LiMinMaxDirective {
  late web.HTMLInputElement inputElement;
  final web.Element _el;

  /// Minimum allowed numeric value.
  @Input('liMin')
  double? liMin;

  /// Maximum allowed numeric value.
  @Input('liMax')
  double? liMax;

  LiMinMaxDirective(this._el) {
    if (!_el.isA<web.HTMLInputElement>()) {
      throw Exception(
          'LiMinMaxDirective has to be applied to an HTMLInputElement');
    }
    inputElement = _el as web.HTMLInputElement;

    inputElement.onKeyUp.listen((e) {
      final valorAtual =
          double.tryParse((e.target as web.HTMLInputElement).value) ?? 0;
      final isDigitKey = RegExp(r'^\d$').hasMatch(e.key) ||
          RegExp(r'^Numpad\d$').hasMatch(e.code);
      if (isDigitKey) {
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
