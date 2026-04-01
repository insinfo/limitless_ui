// ignore_for_file: implementation_imports

import 'package:ngdart/angular.dart';

import 'dart:html';

import 'package:ngforms/src/directives/control_value_accessor.dart'
    show ChangeHandler, ControlValueAccessor, ngValueAccessor, TouchHandler;

const numberValueAccessor2 = ExistingProvider.forToken(
  ngValueAccessor,
  CustomNumberValueAccessor,
);

/// The accessor for writing a number value and listening to changes that is used by the
/// [NgModel], [NgFormControl], and [NgControlName] directives.
///
///  ### Example
///
///  <input type="number" [(ngModel)]="age">
@Directive(
  selector: 'input[type=number][ngControl],'
      'input[type=number][ngFormControl],'
      'input[type=number][ngModel]',
  providers: [numberValueAccessor2],
)
class CustomNumberValueAccessor extends Object
    with TouchHandler, ChangeHandler<double?>
    implements ControlValueAccessor<Object?> {
  final InputElement _element;

  CustomNumberValueAccessor(HtmlElement element)
      : _element = element as InputElement;

  @HostListener('change', ['\$event.target.value'])
  @HostListener('input', ['\$event.target.value'])
  void handleChange(String value) {
    onChange(value == '' ? null : double.parse(value), rawValue: value);
  }

  @Input('precision')
  int? precision;

  @override
  void writeValue(value) {
    if (value is double) {
      final val = value;

      if (precision != null) {
        _element.value = val.toStringAsPrecision(precision!);
      } else {
        _element.value = '$value';
      }
    } else {
      _element.value = '$value';
    }
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    _element.disabled = isDisabled;
  }
}
