// ignore_for_file: implementation_imports

import 'package:ngx_dart/angular.dart';

import 'package:limitless_ui/web_compat.dart';

import 'package:ngx_forms/src/directives/control_value_accessor.dart'
    show ChangeHandler, ControlValueAccessor, ngValueAccessor, TouchHandler;

const liNumberValueAccessor = ExistingProvider.forToken(
  ngValueAccessor,
  LiNumberValueAccessor,
);

/// Writes `double` values to `<input type="number">` elements and listens to
/// user changes for AngularDart forms.
///
/// Example:
/// ```html
/// <input type="number" [(ngModel)]="age">
/// ```
@Directive(
  selector: 'input[type=number][ngControl],'
      'input[type=number][ngFormControl],'
      'input[type=number][ngModel]',
  providers: [liNumberValueAccessor],
)
class LiNumberValueAccessor extends Object
    with TouchHandler, ChangeHandler<double?>
    implements ControlValueAccessor<Object?> {
  final InputElement _element;

  LiNumberValueAccessor(HTMLElement element)
      : _element = element as InputElement;

  @HostListener('change')
  @HostListener('input')

  /// Parses the raw input string and notifies AngularDart forms.
  void handleChange() {
    final value = _element.value;
    onChange(value == '' ? null : double.parse(value), rawValue: value);
  }

  /// Controls the significant digits used when [writeValue] renders doubles.
  @Input('liPrecision')
  int? liPrecision;

  @override

  /// Writes the current model value into the native input element.
  void writeValue(value) {
    if (value is double) {
      final val = value;

      if (liPrecision != null) {
        _element.value = val.toStringAsPrecision(liPrecision!);
      } else {
        _element.value = '$value';
      }
    } else {
      _element.value = '$value';
    }
  }

  @override

  /// Enables or disables the backing input element.
  void onDisabledChanged(bool isDisabled) {
    _element.disabled = isDisabled;
  }
}
