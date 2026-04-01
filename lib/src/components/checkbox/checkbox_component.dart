import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

@Component(
  selector: 'li-checkbox',
  templateUrl: 'checkbox_component.html',
  directives: [coreDirectives],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiCheckboxComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiCheckboxComponent implements ControlValueAccessor<bool?> {
  LiCheckboxComponent(this._changeDetectorRef)
      : _generatedId = 'li-checkbox-${_nextId++}';

  static int _nextId = 0;

  final ChangeDetectorRef _changeDetectorRef;
  final String _generatedId;

  bool _value = false;

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

  ChangeFunction<bool?> _onChange = (bool? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  String get resolvedId => id.trim().isEmpty ? _generatedId : id.trim();

  String? get resolvedName => name.trim().isEmpty ? null : name.trim();

  String? get resolvedAriaLabel =>
      ariaLabel.trim().isNotEmpty ? ariaLabel.trim() : null;

  bool get checked => _value;

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

  void handleChange(bool? value) {
    _value = value ?? false;
    _onChange(_value, rawValue: '$_value');
    _markForCheck();
  }

  void handleBlur() {
    _onTouched();
  }

  @override
  void registerOnChange(ChangeFunction<bool?> fn) {
    _onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _onTouched = fn;
  }

  @override
  void writeValue(bool? value) {
    _value = value ?? false;
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
