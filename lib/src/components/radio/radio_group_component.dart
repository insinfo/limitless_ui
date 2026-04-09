import 'dart:async';

import 'package:ngdart/angular.dart';

import '../../directives/li_form_directive.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';

@Component(
  selector: 'li-radio-group',
  templateUrl: 'radio_group_component.html',
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiRadioGroupComponent implements AfterChanges, OnDestroy {
  LiRadioGroupComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]);

  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  StreamSubscription<bool>? _formSubmissionSubscription;
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  bool _hasTrackedValue = false;
  dynamic _lastValue;
  LiValidationIssue? _autoValidationIssue;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};

  @Input()
  String legend = '';

  @Input()
  String helperText = '';

  @Input()
  String errorText = '';

  @Input()
  String feedbackClass = '';

  @Input()
  String describedBy = '';

  @Input()
  String containerClass = '';

  @Input()
  String locale = 'pt_BR';

  @Input()
  dynamic value;

  @Input()
  String legendClass = '';

  @Input()
  bool invalid = false;

  @Input()
  bool valid = false;

  @Input()
  bool dataInvalid = false;

  @Input()
  List<LiRule> liRules = const <LiRule>[];

  @Input()
  Map<String, String> liMessages = const <String, String>{};

  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  @Input()
  bool validateOnInput = true;

  bool get hasLegend => legend.trim().isNotEmpty;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  bool get showErrorFeedback =>
      effectiveErrorText.trim().isNotEmpty && effectiveInvalid;

  bool get effectiveAutoInvalid =>
      _shouldShowValidation && _autoValidationIssue != null;

  bool get effectiveInvalid => invalid || dataInvalid || effectiveAutoInvalid;

  bool get effectiveValid =>
      !effectiveInvalid &&
      (valid ||
          (_shouldShowValidation &&
              _effectiveRules.isNotEmpty &&
              _autoValidationIssue == null));

  String get effectiveErrorText {
    final externalMessage = errorText.trim();
    if (externalMessage.isNotEmpty) {
      return externalMessage;
    }

    return _autoValidationIssue?.message ?? '';
  }

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String? get resolvedAriaInvalid => effectiveInvalid ? 'true' : null;

  String? get resolvedDataInvalidAttr => effectiveInvalid ? 'true' : null;

  String get resolvedContainerClass => _joinClasses(<String>[
        'li-selection-group',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
        containerClass,
      ]);

  String get resolvedLegendClass => _joinClasses(<String>[
        'li-selection-group__legend',
        legendClass,
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  @override
  void ngAfterChanges() {
    _formSubmitted = _formDirective?.submitted ?? false;
    _formSubmissionSubscription ??=
        _formDirective?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      _runAutoValidation();
      _markForCheck();
    });

    _effectiveRules = List<LiRule>.unmodifiable(<LiRule>[
      ...liRules,
    ]);
    _effectiveMessages = Map<String, String>.unmodifiable(<String, String>{
      ...liMessages,
    });

    if (_hasTrackedValue && !_areValuesEqual(_lastValue, value)) {
      _dirty = true;
    }
    _hasTrackedValue = true;
    _lastValue = value;

    if (validateOnInput || _shouldShowValidation || _autoValidationIssue != null) {
      _runAutoValidation();
    }
    _markForCheck();
  }

  @HostListener('focusout')
  void handleFocusOut() {
    _markTouched();
    _runAutoValidation();
    _markForCheck();
  }

  bool get _shouldShowValidation => liShouldShowValidation(
        mode: liValidationMode,
        touched: _touched,
        dirty: _dirty,
        submitted: _formSubmitted,
      );

  void _runAutoValidation() {
    if (_effectiveRules.isEmpty) {
      _autoValidationIssue = null;
      return;
    }

    _autoValidationIssue = liValidateValue(
      value: value,
      rules: _effectiveRules,
      context: LiRuleContext(
        fieldName: legend.trim().isEmpty ? null : legend.trim(),
        messages: _effectiveMessages,
        locale: locale,
      ),
    );
  }

  void _markTouched() {
    _touched = true;
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  bool _areValuesEqual(dynamic left, dynamic right) => left == right;

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  @override
  void ngOnDestroy() {
    _formSubmissionSubscription?.cancel();
  }
}
