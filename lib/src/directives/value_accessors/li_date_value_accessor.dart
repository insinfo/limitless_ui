import 'package:limitless_ui/web_compat.dart';

import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

/// Writes `DateTime` values to `<input type="date">` elements and reads them
/// back into AngularDart form controls.
///
/// Example:
/// ```html
/// <input type="date" [(ngModel)]="birthday">
/// ```
@Directive(
  selector: 'input[type=date][ngControl],'
      'input[type=date][ngFormControl],'
      'input[type=date][ngModel]',
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiDateValueAccessor),
  ],
)
class LiDateValueAccessor implements ControlValueAccessor {
  final InputElement _element;

  LiDateValueAccessor(HTMLElement element) : _element = element as InputElement;

  @HostListener('change', ['\$event.target.value'])
  @HostListener('input', ['\$event.target.value'])
  void handleChange(String value) {
    DateTime? parsedValue;
    try {
      parsedValue = DateTime.tryParse(value);
    } catch (_) {
      return;
    }
    onChange(value.isEmpty ? null : parsedValue, rawValue: value);
  }

  @override
  void writeValue(value) {
    DateTime? parsedValue;
    try {
      parsedValue = value as DateTime?;
    } catch (_) {
      return;
    }
    final rawValue = parsedValue != null
        ? parsedValue.toIso8601String().substring(0, 10)
        : '';
    _element.value = rawValue;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    _element.disabled = isDisabled;
  }

  TouchFunction onTouched = () {};

  @HostListener('blur')
  void touchHandler() {
    onTouched();
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    onTouched = fn;
  }

  ChangeFunction<DateTime?> onChange = (DateTime? _, {String? rawValue}) {};

  @override
  void registerOnChange(ChangeFunction<DateTime?> fn) {
    onChange = fn;
  }
}
