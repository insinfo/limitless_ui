import 'dart:async';

import 'package:ngdart/angular.dart';

import '../directives/li_form_directive.dart';
import 'li_rule.dart';
import 'li_rule_context.dart';
import 'li_validation.dart';
import 'li_validation_issue.dart';

/// Declarative validation layer shared by the form fields of the library.
///
/// Mix it into a component to get the validation inputs ([liRules],
/// [liMessages], [liValidationMode], [validateOnInput], [invalid] and
/// [dataInvalid]), the touched/dirty/submitted state, the integration with an
/// enclosing `liForm` and the getters the template paints from
/// ([effectiveInvalid], [effectiveValid], [effectiveErrorText],
/// [showErrorFeedback], [resolvedAriaInvalid], [resolvedDataInvalidAttr]).
///
/// The component provides the rest:
///
/// - [locale] and [externalErrorText] — usually an `errorText` input;
/// - [validationValue], the value the rules see;
/// - calls to [connectValidationForm] (once, with the optional
///   `LiFormDirective` injected in the constructor), [rebuildValidationConfig]
///   and [runValidation] when its inputs change, [disconnectValidationForm]
///   in `ngOnDestroy`;
/// - [validationDirty] when the user changes the value and
///   [validationTouched] when the field loses focus;
/// - in the template, `[attr.data-invalid]="resolvedDataInvalidAttr"` around
///   the element that should receive the focus, and
///   `[attr.data-li-form-focus-target]="'true'"` on that element, so
///   `liForm.validateAndFocusFirstInvalid()` finds it.
///
/// The precedence is fixed: [invalid] and [dataInvalid] win over the automatic
/// invalid state, and [externalErrorText] wins over the message of the
/// automatic validation.
///
/// Components with `ChangeDetectionStrategy.onPush` mark themselves for check
/// in [didChangeFormSubmission], because the submission of the form arrives
/// outside of their own event handlers.
mixin LiValidatedField {
  /// Declarative rules evaluated against [validationValue].
  ///
  /// They run after the rules the component derives from its own inputs, in
  /// the order returned by [buildValidationRules].
  @Input()
  List<LiRule> liRules = const <LiRule>[];

  /// Per-field message overrides keyed by rule code.
  @Input()
  Map<String, String> liMessages = const <String, String>{};

  /// When the automatic validation becomes visible.
  ///
  /// One of `never`, `dirty`, `touched`, `touchedOrDirty`, `submitted`,
  /// `submittedOrTouched` and `submittedOrTouchedOrDirty` (default).
  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  /// Whether the rules run again on every change of the value, even before the
  /// result is visible.
  @Input()
  bool validateOnInput = true;

  /// External invalid state, typically from the backend. Wins over the
  /// automatic validation.
  @Input()
  bool invalid = false;

  /// External invalid state, same as [invalid].
  @Input()
  bool dataInvalid = false;

  bool _validationTouched = false;
  bool _validationDirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _validationIssue;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};
  StreamSubscription<bool>? _formSubmissionSubscription;

  /// Locale of the default rule messages.
  String get locale;

  /// Value the rules see.
  dynamic get validationValue;

  /// External error message, typically from the backend. Wins over the
  /// message of the automatic validation.
  String get externalErrorText;

  /// Field name handed to the rules through [LiRuleContext.fieldName].
  String? get validationFieldName => null;

  /// Field preset handed to the rules through [LiRuleContext.inputType].
  Object? get validationInputType => null;

  /// External valid state, such as a `valid` input. Ignored while the field is
  /// invalid.
  bool get externalValid => false;

  /// Rules in effect, rebuilt by [rebuildValidationConfig].
  ///
  /// Defaults to [liRules]. Override to add rules derived from other inputs,
  /// such as a `required` flag.
  List<LiRule> buildValidationRules() => liRules;

  /// Messages in effect, rebuilt by [rebuildValidationConfig].
  ///
  /// Defaults to [liMessages]. Override to merge the messages of a preset.
  Map<String, String> buildValidationMessages() => liMessages;

  /// Called at the end of every [runValidation].
  void didRunValidation() {}

  /// Called after the submission state of the enclosing `liForm` changed and
  /// the rules ran again.
  void didChangeFormSubmission() {}

  /// Whether the field lost focus at least once.
  bool get validationTouched => _validationTouched;

  set validationTouched(bool value) {
    _validationTouched = value;
  }

  /// Whether the user changed the value at least once.
  bool get validationDirty => _validationDirty;

  set validationDirty(bool value) {
    _validationDirty = value;
  }

  /// Whether the enclosing `liForm` was submitted.
  bool get formSubmitted => _formSubmitted;

  /// Result of the last [runValidation]: the first failing rule, or `null`.
  LiValidationIssue? get validationIssue => _validationIssue;

  /// Rules in effect since the last [rebuildValidationConfig].
  List<LiRule> get effectiveRules => _effectiveRules;

  /// Messages in effect since the last [rebuildValidationConfig].
  Map<String, String> get effectiveMessages => _effectiveMessages;

  /// Whether [liValidationMode] lets the automatic validation show now.
  bool get shouldShowValidation => liShouldShowValidation(
        mode: liValidationMode,
        touched: _validationTouched,
        dirty: _validationDirty,
        submitted: _formSubmitted,
      );

  /// Whether a change of the value should run the rules again: always with
  /// [validateOnInput], otherwise only while the result is visible or a
  /// failure is pending.
  bool get shouldRevalidate =>
      validateOnInput || shouldShowValidation || _validationIssue != null;

  /// Whether the automatic validation failed and is visible.
  bool get effectiveAutoInvalid =>
      shouldShowValidation && _validationIssue != null;

  /// Whether the automatic validation passed, has rules and is visible.
  bool get effectiveAutoValid =>
      shouldShowValidation &&
      _effectiveRules.isNotEmpty &&
      _validationIssue == null;

  /// Invalid state painted by the field.
  bool get effectiveInvalid => invalid || dataInvalid || effectiveAutoInvalid;

  /// Valid state painted by the field.
  bool get effectiveValid =>
      !effectiveInvalid && (externalValid || effectiveAutoValid);

  /// Message shown under the field: [externalErrorText] when set, otherwise
  /// the message of the automatic validation.
  String get effectiveErrorText {
    final externalMessage = externalErrorText.trim();
    if (externalMessage.isNotEmpty) {
      return externalMessage;
    }

    return _validationIssue?.message ?? '';
  }

  /// Whether the error message is rendered.
  bool get showErrorFeedback =>
      effectiveErrorText.trim().isNotEmpty && effectiveInvalid;

  /// Value of `aria-invalid`.
  String? get resolvedAriaInvalid => effectiveInvalid ? 'true' : null;

  /// Value of `data-invalid`, the attribute `liForm` looks for.
  String? get resolvedDataInvalidAttr => effectiveInvalid ? 'true' : null;

  /// Reads the submission state of [form] and follows its changes.
  ///
  /// Safe to call more than once: the subscription is made only the first
  /// time, while the submission state is read again on every call.
  void connectValidationForm(LiFormDirective? form) {
    _formSubmitted = form?.submitted ?? false;
    _formSubmissionSubscription ??=
        form?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      runValidation();
      didChangeFormSubmission();
    });
  }

  /// Stops following the enclosing `liForm`. Call it in `ngOnDestroy`.
  void disconnectValidationForm() {
    _formSubmissionSubscription?.cancel();
  }

  /// Rebuilds [effectiveRules] and [effectiveMessages] from the inputs.
  ///
  /// Does not run the rules; call [runValidation] afterwards.
  void rebuildValidationConfig() {
    _effectiveRules = List<LiRule>.unmodifiable(buildValidationRules());
    _effectiveMessages =
        Map<String, String>.unmodifiable(buildValidationMessages());
  }

  /// Runs [effectiveRules] against [validationValue] and stores the result in
  /// [validationIssue].
  void runValidation() {
    if (_effectiveRules.isEmpty) {
      _validationIssue = null;
    } else {
      _validationIssue = liValidateValue(
        value: validationValue,
        rules: _effectiveRules,
        context: LiRuleContext(
          fieldName: validationFieldName,
          inputType: validationInputType,
          messages: _effectiveMessages,
          locale: locale,
        ),
      );
    }
    didRunValidation();
  }
}
