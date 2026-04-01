import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:ngforms/angular_forms.dart';

/// Writes `DateTime` values to `<input type="datetime-local">` elements and
/// reads them back into AngularDart form controls.
///
/// Example:
/// ```html
/// <input type="datetime-local" [(ngModel)]="scheduledAt">
/// ```
@Directive(
  selector: 'input[type=datetime-local][ngControl],'
      'input[type=datetime-local][ngFormControl],'
      'input[type=datetime-local][ngModel]',
  providers: [
    ExistingProvider.forToken(ngValueAccessor, DateTimeValueAccessor),
  ],
)
class DateTimeValueAccessor implements ControlValueAccessor {
  final InputElement _element;

  DateTimeValueAccessor(HtmlElement element)
      : _element = element as InputElement;

  @HostListener('change', ['\$event.target.value'])
  @HostListener('input', ['\$event.target.value'])
  /// Parses the raw `datetime-local` string and reports model changes.
  void handleChange(String value) {
    DateTime? dec;
    try {
      dec = DateTime.tryParse(value);
    } catch (_) {
      return;
    }
    if (dec == null) return;

    onChange(dec, rawValue: value);
  }

  @override
  /// Writes the current model value to the native input in `yyyy-MM-ddTHH:mm`
  /// format.
  void writeValue(value) {
    DateTime? dec;
    try {
      dec = value as DateTime?;
    } catch (_) {
      return;
    }
    final rawValue = dec != null ? dec.toIso8601String().substring(0, 16) : '';
    _element.value = rawValue;
  }

  @override
  /// Enables or disables the backing input element.
  void onDisabledChanged(bool isDisabled) {
    _element.disabled = isDisabled;
  }

  TouchFunction onTouched = () {};

  @HostListener('blur')
  /// Marks the control as touched when the input loses focus.
  void touchHandler() {
    onTouched();
  }

  @override
  /// Registers the callback used when the control becomes touched.
  void registerOnTouched(TouchFunction fn) {
    onTouched = fn;
  }

  ChangeFunction<DateTime?> onChange = (DateTime? _, {String? rawValue}) {};

  @override
  /// Registers the callback used when the control value changes.
  void registerOnChange(ChangeFunction<DateTime?> fn) {
    onChange = fn;
  }
}