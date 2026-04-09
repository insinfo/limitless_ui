import 'dart:async';

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

import '../../directives/li_form_directive.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';

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
    implements ControlValueAccessor<dynamic>, AfterChanges, OnDestroy {
  LiCheckboxComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ])
      : _generatedId = 'li-checkbox-${_nextId++}';

  static int _nextId = 0;

  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  final String _generatedId;

  dynamic _value = false;
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _autoValidationIssue;
  StreamSubscription<bool>? _formSubmissionSubscription;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};

  @Input()
  dynamic trueValue = true;

  @Input()
  dynamic falseValue = false;

  @Input()
  String id = '';

  @Input()
  String name = '';

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
  bool invalid = false;

  @Input()
  bool valid = false;

  @Input()
  bool dataInvalid = false;

  @Input()
  bool inline = false;

  @Input()
  bool reverse = false;

  @Input()
  bool disabled = false;

  @Input()
  bool required = false;

  @Input()
  List<LiRule> liRules = const <LiRule>[];

  @Input()
  Map<String, String> liMessages = const <String, String>{};

  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  @Input()
  bool validateOnInput = true;

  ChangeFunction<dynamic> _onChange = (dynamic _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  String get resolvedId => id.trim().isEmpty ? _generatedId : id.trim();

  String? get resolvedName => name.trim().isEmpty ? null : name.trim();

  String? get resolvedAriaLabel =>
      ariaLabel.trim().isNotEmpty ? ariaLabel.trim() : null;

  bool get checked => _value == trueValue;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  bool get hasErrorText => errorText.trim().isNotEmpty;

  String get effectiveErrorText {
    final externalMessage = errorText.trim();
    if (externalMessage.isNotEmpty) {
      return externalMessage;
    }

    return _autoValidationIssue?.message ?? '';
  }

  bool get showErrorFeedback =>
      effectiveErrorText.trim().isNotEmpty && effectiveInvalid;

  bool get effectiveAutoInvalid =>
      _shouldShowValidation && _autoValidationIssue != null;

  bool get effectiveInvalid => invalid || dataInvalid || effectiveAutoInvalid;

  bool get effectiveValid =>
      !effectiveInvalid && (valid || (_shouldShowValidation && _effectiveRules.isNotEmpty && _autoValidationIssue == null));

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String? get resolvedAriaInvalid => effectiveInvalid ? 'true' : null;

  String? get resolvedDataInvalidAttr => effectiveInvalid ? 'true' : null;

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
    _dirty = true;
    _value = (value ?? false) ? trueValue : falseValue;
    _onChange(_value, rawValue: _value?.toString() ?? '');
    if (validateOnInput || _shouldShowValidation || _autoValidationIssue != null) {
      _runAutoValidation();
    }
    _markForCheck();
  }

  void handleBlur() {
    _touched = true;
    _onTouched();
    _runAutoValidation();
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
    _runAutoValidation();
    _markForCheck();
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    _markForCheck();
  }

  @override
  void ngOnDestroy() {
    _formSubmissionSubscription?.cancel();
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
    _formSubmitted = _formDirective?.submitted ?? false;
    _formSubmissionSubscription ??=
        _formDirective?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      _runAutoValidation();
      _markForCheck();
    });

    _effectiveRules = List<LiRule>.unmodifiable(<LiRule>[
      if (required) const LiRequiredTrueRule(),
      ...liRules,
    ]);
    _effectiveMessages = Map<String, String>.unmodifiable(<String, String>{
      ...liMessages,
    });
    _runAutoValidation();
  }

  void _runAutoValidation() {
    if (_effectiveRules.isEmpty) {
      _autoValidationIssue = null;
      return;
    }

    _autoValidationIssue = liValidateValue(
      value: checked,
      rules: _effectiveRules,
      context: LiRuleContext(
        fieldName: resolvedName,
        messages: _effectiveMessages,
        locale: locale,
      ),
    );
  }

  bool get _shouldShowValidation => liShouldShowValidation(
        mode: liValidationMode,
        touched: _touched,
        dirty: _dirty,
        submitted: _formSubmitted,
      );
}
