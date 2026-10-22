import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

import '../../directives/li_form_directive.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_validated_field.dart';
import 'checkbox_group_component.dart';

@Component(
  selector: 'li-checkbox',
  templateUrl: 'checkbox_component.html',
  directives: [coreDirectives],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiCheckboxComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiCheckboxComponent
    with LiValidatedField
    implements ControlValueAccessor<dynamic>, AfterChanges, OnDestroy {
  LiCheckboxComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
    @Optional() this._group,
  ]) : _generatedId = 'li-checkbox-${_nextId++}' {
    _group?.registerCheckbox(this);
  }

  static int _nextId = 0;

  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;

  /// Group this checkbox belongs to, told about every change of [checked] so
  /// its rules see the current selection.
  final LiCheckboxGroupComponent? _group;
  final String _generatedId;

  dynamic _value = false;

  @Input()
  dynamic trueValue = true;

  @Input()
  dynamic falseValue = false;

  @Input()
  String id = '';

  @Input()
  String? name;

  @Input()
  String label = '';

  @Input()
  String helperText = '';

  @Input()
  String errorText = '';

  @Input()
  String feedbackClass = '';

  @Input()
  String describedBy = '';

  @override
  @Input()
  String locale = 'pt_BR';

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
  bool valid = false;

  @Input()
  bool inline = false;

  @Input()
  bool reverse = false;

  @Input()
  bool disabled = false;

  @Input()
  bool required = false;

  ChangeFunction<dynamic> _onChange = (dynamic _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  String get resolvedId => id.trim().isEmpty ? _generatedId : id.trim();

  String? get resolvedName => name;

  String? get resolvedAriaLabel =>
      ariaLabel.trim().isNotEmpty ? ariaLabel.trim() : null;

  bool get checked => _value == trueValue;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  bool get hasErrorText => errorText.trim().isNotEmpty;

  @override
  dynamic get validationValue => checked;

  @override
  String get externalErrorText => errorText;

  @override
  String? get validationFieldName => resolvedName;

  @override
  bool get externalValid => valid;

  @override
  List<LiRule> buildValidationRules() => <LiRule>[
        if (required) const LiRequiredTrueRule(),
        ...liRules,
      ];

  @override
  void didChangeFormSubmission() {
    _markForCheck();
  }

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String? get currentDataValue => _value?.toString();

  String? get trueDataValue => trueValue?.toString();

  String? get falseDataValue => falseValue?.toString();

  String get resolvedContainerClass => _joinClasses(<String>[
        'form-check',
        inline ? 'form-check-inline' : '',
        reverse ? 'form-check-reverse' : '',
        containerClass,
      ]);

  String get resolvedInputClass => _joinClasses(<String>[
        'form-check-input',
        variant.trim().isNotEmpty ? 'form-check-input-${variant.trim()}' : '',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
        inputClass,
      ]);

  String get resolvedLabelClass => _joinClasses(<String>[
        'form-check-label',
        labelClass,
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  @HostBinding('class.d-block')
  bool get hostClass => true;

  @override
  void ngAfterChanges() {
    _rebuildValidationConfig();
    _markForCheck();
  }

  void handleChange(bool? value) {
    validationDirty = true;
    _value = (value ?? false) ? trueValue : falseValue;
    _onChange(_value, rawValue: _value?.toString() ?? '');
    _group?.handleCheckboxChange(userInteraction: true);
    if (shouldRevalidate) {
      runValidation();
    }
    _markForCheck();
  }

  void handleBlur() {
    validationTouched = true;
    _onTouched();
    runValidation();
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
  void writeValue(dynamic value) {
    _value = value ?? falseValue;
    _group?.handleCheckboxChange(userInteraction: false);
    runValidation();
    _markForCheck();
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    _markForCheck();
  }

  @override
  void ngOnDestroy() {
    disconnectValidationForm();
    _group?.unregisterCheckbox(this);
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

  void _rebuildValidationConfig() {
    connectValidationForm(_formDirective);
    rebuildValidationConfig();
    runValidation();
  }
}
