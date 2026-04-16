import 'dart:async';
import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import '../../directives/li_form_directive.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';
import 'currency_input_formatter.dart';

@Component(
  selector: 'li-currency-input',
  templateUrl: 'currency_input_component.html',
  styleUrls: ['currency_input_component.css'],
  directives: [coreDirectives],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiCurrencyInputComponent),
  ],
)
class LiCurrencyInputComponent
    implements
        ControlValueAccessor<int?>,
        AfterViewInit,
        OnDestroy,
        AfterChanges {
  final HtmlElement _hostElement;
  final LiFormDirective? _formDirective;

  LiCurrencyInputComponent(
    this._hostElement, [
    @Optional() this._formDirective,
  ]) {
    _formSubmitted = _formDirective?.submitted ?? false;
    _formSubmissionSubscription =
        _formDirective?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      _runAutoValidation();
      _syncValidationClasses();
    });
  }

  String? _customPlaceholder;
  String? _customPrefix;

  @Input()
  set placeholder(String? value) {
    _customPlaceholder = value?.trim().isEmpty ?? true ? null : value!.trim();
  }

  @Input()
  set prefix(String? value) {
    _customPrefix = value?.trim().isEmpty ?? true ? null : value!.trim();
  }

  @Input()
  String locale = 'pt_BR';

  @Input()
  String currencyCode = 'BRL';

  @Input()
  int decimalDigits = 2;

  @Input()
  bool disabled = false;

  @Input()
  bool required = false;

  @Input()
  String inputClass = 'form-control';

  @Input()
  bool invalid = false;

  @Input()
  bool valid = false;

  @Input()
  bool dataInvalid = false;

  @Input()
  String errorText = '';

  @Input()
  String helperText = '';

  @Input()
  String feedbackClass = '';

  @Input()
  String describedBy = '';

  @Input()
  List<LiRule> liRules = const <LiRule>[];

  @Input()
  Map<String, String> liMessages = const <String, String>{};

  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  @Input()
  bool validateOnInput = true;

  @ViewChild('inputElement')
  InputElement? inputElement;

  String displayValue = '';

  int? _minorUnits;
  bool _isFocused = false;
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _autoValidationIssue;
  StreamSubscription<Event>? _hostFocusSubscription;
  StreamSubscription<bool>? _formSubmissionSubscription;
  MutationObserver? _hostClassObserver;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};

  bool get effectiveAutoInvalid =>
      _shouldShowValidation && _autoValidationIssue != null;

  bool get effectiveInvalid =>
      invalid || dataInvalid || effectiveAutoInvalid || _hasHostInvalidState;

  bool get effectiveValid =>
      !effectiveInvalid &&
      (valid ||
          _hasHostValidState ||
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

  bool get showErrorFeedback =>
      effectiveErrorText.trim().isNotEmpty && effectiveInvalid;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String get resolvedInputClass => _joinClasses(<String>[
        inputClass,
        'br-currency-input__field',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  String get resolvedPlaceholder =>
      _customPlaceholder ?? formatter.formatForEditing(0);

  String get resolvedPrefix =>
      _customPrefix ??
      CurrencyInputFormatter.currencySymbol(
        currencyCode,
        locale: locale,
      );

  CurrencyInputFormatter get formatter => CurrencyInputFormatter(
        locale: locale,
        currencyCode: currencyCode,
        decimalDigits: decimalDigits,
      );

  bool get _shouldShowValidation => liShouldShowValidation(
        mode: liValidationMode,
        touched: _touched,
        dirty: _dirty,
        submitted: _formSubmitted,
      );

  ChangeFunction<int?> onChange = (int? _, {String? rawValue}) {};
  TouchFunction onTouched = () {};

  @override
  void registerOnChange(ChangeFunction<int?> fn) {
    onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    onTouched = fn;
  }

  @override
  void writeValue(value) {
    final parsedValue = switch (value) {
      int v => v,
      _ => null,
    };

    _minorUnits = parsedValue;
    displayValue = _isFocused
        ? formatter.formatForEditing(_minorUnits)
        : formatter.formatForDisplay(_minorUnits);
    _syncInputValue();
    _runAutoValidation();
    _syncValidationClasses();
  }

  @override
  void ngAfterChanges() {
    _rebuildValidationConfig();
    writeValue(_minorUnits);
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    if (inputElement != null) {
      inputElement!.disabled = isDisabled;
    }
  }

  @override
  void ngAfterViewInit() {
    _hostElement.tabIndex = -1;
    _hostFocusSubscription = _hostElement.onFocus.listen((_) {
      if (document.activeElement == _hostElement) {
        inputElement?.focus();
      }
    });
    _hostClassObserver = MutationObserver((_, __) {
      _syncValidationClasses();
    })
      ..observe(
        _hostElement,
        attributes: true,
        attributeFilter: const ['class', 'data-invalid'],
      );

    inputElement?.disabled = disabled;
    _syncInputValue();
    _rebuildValidationConfig();
    _syncValidationClasses();
  }

  void handleInput(String rawValue) {
    final sanitized = formatter.sanitizeForEditing(rawValue);
    final minorUnits = formatter.minorUnitsFromText(sanitized);
    final valueChanged = _minorUnits != minorUnits;

    _minorUnits = minorUnits;
    displayValue = sanitized;
    if (valueChanged) {
      _dirty = true;
    }

    if (inputElement?.value != sanitized) {
      _syncInputValue();
      _moveCaretToEnd();
    }

    onChange(
      minorUnits,
      rawValue: sanitized,
    );
    _runAutoValidation();
    _syncValidationClasses();
  }

  void handleInputFocus() {
    _isFocused = true;
    final editingValue = formatter.formatForEditing(_minorUnits);
    if (editingValue != displayValue) {
      displayValue = editingValue;
      _syncInputValue();
    }
    _moveCaretToEnd();
  }

  void handleInputBlur() {
    _isFocused = false;
    displayValue = formatter.formatForDisplay(_minorUnits);
    _syncInputValue();
    _markTouched();
  }

  void _syncInputValue() {
    if (inputElement == null) {
      return;
    }
    inputElement!.value = displayValue;
  }

  void _moveCaretToEnd() {
    Future.microtask(() {
      final input = inputElement;
      if (input == null) {
        return;
      }
      final length = input.value?.length ?? 0;
      input.setSelectionRange(length, length);
    });
  }

  void _syncValidationClasses() {
    final input = inputElement;
    if (input == null) {
      return;
    }

    if (effectiveInvalid) {
      input.classes.add('is-invalid');
    } else {
      input.classes.remove('is-invalid');
    }

    if (effectiveValid) {
      input.classes.add('is-valid');
    } else {
      input.classes.remove('is-valid');
    }

    if (effectiveInvalid) {
      input.attributes['data-invalid'] = 'true';
    } else {
      input.attributes.remove('data-invalid');
    }
  }

  void _markTouched() {
    if (_touched) {
      onTouched();
      _runAutoValidation();
      _syncValidationClasses();
      return;
    }

    _touched = true;
    onTouched();
    _runAutoValidation();
    _syncValidationClasses();
  }

  void _rebuildValidationConfig() {
    _effectiveMessages = Map<String, String>.unmodifiable(<String, String>{
      ...liMessages,
    });
    _effectiveRules = List<LiRule>.unmodifiable(<LiRule>[
      if (required) const LiRequiredRule(),
      ...liRules,
    ]);

    _runAutoValidation();
  }

  void _runAutoValidation() {
    if (_effectiveRules.isEmpty) {
      _autoValidationIssue = null;
      return;
    }

    _autoValidationIssue = liValidateValue(
      value: _minorUnits,
      rules: _effectiveRules,
      context: LiRuleContext(
        messages: _effectiveMessages,
        locale: locale,
      ),
    );
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  bool get _hasHostInvalidState =>
      _hostElement.classes.contains('is-invalid') ||
      _hostElement.attributes['data-invalid'] == 'true';

  bool get _hasHostValidState => _hostElement.classes.contains('is-valid');

  @override
  void ngOnDestroy() {
    _hostFocusSubscription?.cancel();
    _formSubmissionSubscription?.cancel();
    _hostClassObserver?.disconnect();
  }
}
