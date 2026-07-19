import 'dart:html';

import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

const liCheckboxValueAccessor = ExistingProvider.forToken(
  ngValueAccessor,
  LiCheckboxControlValueAccessor,
);

/// Writes boolean values to checkbox inputs and listens to user changes.
@Directive(
  selector: 'input[type=checkbox][ngControl],'
      'input[type=checkbox][ngFormControl],'
      'input[type=checkbox][ngModel]',
  providers: [liCheckboxValueAccessor],
)
class LiCheckboxControlValueAccessor implements ControlValueAccessor<bool?> {
  final InputElement _element;

  LiCheckboxControlValueAccessor(HtmlElement element)
      : _element = element as InputElement;

  ChangeFunction<bool?> onChange = (bool? _, {String? rawValue}) {};
  TouchFunction onTouched = () {};

  @HostListener('change', ['\$event.target.checked'])
  void handleChange(bool checked) {
    onChange(checked, rawValue: '$checked');
  }

  @HostListener('blur')
  void touchHandler() {
    onTouched();
  }

  @override
  void registerOnChange(ChangeFunction<bool?> fn) {
    onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    onTouched = fn;
  }

  @override
  void writeValue(bool? value) {
    _element.checked = value ?? false;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    _element.disabled = isDisabled;
  }
}
