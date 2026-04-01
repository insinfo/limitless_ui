import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

@Component(
  selector: 'li-radio',
  templateUrl: 'radio_component.html',
  directives: [coreDirectives],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiRadioComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiRadioComponent implements ControlValueAccessor<dynamic> {
  LiRadioComponent(this._changeDetectorRef)
      : _generatedId = 'li-radio-${_nextId++}';

  static int _nextId = 0;

  final ChangeDetectorRef _changeDetectorRef;
  final String _generatedId;

  dynamic _groupValue;

  @Input()
  dynamic value;

  @Input()
  String id = '';

  @Input()
  String name = '';

  @Input()
  String label = '';

  @Input()
  String helperText = '';

  @Input()
  String ariaLabel = '';

  @Input()
  String inputClass = '';

  @Input()
  String labelClass = '';

  @Input()
  String containerClass = '';

  @Input()
  String variant = '';

  @Input()
  bool inline = false;

  @Input()
  bool reverse = false;

  @Input()
  bool disabled = false;

  @Input()
  bool required = false;

  @Input()
  bool uncheckable = false;

  ChangeFunction<dynamic> _onChange = (dynamic _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  String get resolvedId => id.trim().isEmpty ? _generatedId : id.trim();

  String? get resolvedName => name.trim().isEmpty ? null : name.trim();

  String? get resolvedAriaLabel =>
      ariaLabel.trim().isNotEmpty ? ariaLabel.trim() : null;

  bool get checked => _groupValue == value;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  String get resolvedContainerClass => _joinClasses(<String>[
        'form-check',
        inline ? 'form-check-inline' : '',
        reverse ? 'form-check-reverse' : '',
        containerClass,
      ]);

  String get resolvedInputClass => _joinClasses(<String>[
        'form-check-input',
        variant.trim().isNotEmpty ? 'form-check-input-${variant.trim()}' : '',
        inputClass,
      ]);

  String get resolvedLabelClass => _joinClasses(<String>[
        'form-check-label',
        labelClass,
      ]);

  @HostBinding('class.d-block')
  bool get hostClass => true;

  void handleClick(html.MouseEvent event) {
    if (disabled) {
      return;
    }

    if (!uncheckable || !checked) {
      return;
    }

    event.preventDefault();
    final target = event.target;
    if (target is html.InputElement) {
      target.checked = false;
    }

    _groupValue = null;
    _onChange(null, rawValue: '');
    _markForCheck();
  }

  void handleChange(bool isChecked) {
    if (disabled) {
      return;
    }

    final nextValue = isChecked ? value : null;
    _groupValue = nextValue;
    _onChange(nextValue, rawValue: nextValue?.toString() ?? '');
    _markForCheck();
  }

  void handleBlur() {
    _onTouched();
  }

  @override
  void registerOnChange(ChangeFunction<dynamic> fn) {
    _onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _onTouched = fn;
  }

  @override
  void writeValue(value) {
    _groupValue = value;
    _markForCheck();
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    _markForCheck();
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }
}
