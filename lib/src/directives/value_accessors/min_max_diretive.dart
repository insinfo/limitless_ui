import 'dart:html';

import 'package:ngdart/angular.dart';

@Directive(selector: '[min]')
class MinMaxDirective {
  late InputElement inputElement;
  final Element _el;

  @Input('min')
  double? min;

  @Input('max')
  double? max;

  MinMaxDirective(this._el) {
    if (_el is! InputElement) {
      throw Exception('MinMaxDirective has to be applied to an InputElement');
    }
    inputElement = _el;

    inputElement.onKeyUp.listen((e) {
      final valorAtual =
          double.tryParse((e.target as InputElement).value ?? '') ?? 0;
      if (e.keyCode >= 48 && e.keyCode <= 57 ||
          e.keyCode >= 96 && e.keyCode <= 105) {
        if (valorAtual < min!) {
          //  e.preventDefault();
          inputElement.value = min.toString();
        }
        if (valorAtual > max!) {
          // e.preventDefault();
          inputElement.value = max.toString();
        }
      }
    });
  }
}
