import 'dart:async';
import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import '../../directives/li_form_directive.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_validated_field.dart';
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
    with LiValidatedField
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
    connectValidationForm(_formDirective);
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

  @override
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
  String? name;

  @Input()
  String size = '';

  @Input()
  bool valid = false;

  @Input()
  String errorText = '';

  @Input()
  String helperText = '';

  @Input()
  String feedbackClass = '';

  @Input()
  String describedBy = '';

  @ViewChild('inputElement')
  InputElement? inputElement;

  String displayValue = '';

  int? _minorUnits;
  bool _isFocused = false;
  StreamSubscription<Event>? _hostFocusSubscription;
  MutationObserver? _hostClassObserver;

  @override
  dynamic get validationValue => _minorUnits;

  @override
  String get externalErrorText => errorText;

  /// The `valid` input or an `is-valid` class set on the host.
  @override
  bool get externalValid => valid || _hasHostValidState;

  @override
  List<LiRule> buildValidationRules() => <LiRule>[
        if (required) const LiRequiredRule(),
        ...liRules,
      ];

  @override
  void didChangeFormSubmission() {
    _syncValidationClasses();
  }

  /// Also invalid while the host carries `is-invalid` or `data-invalid`.
  @override
  bool get effectiveInvalid =>
      invalid || dataInvalid || effectiveAutoInvalid || _hasHostInvalidState;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String? get resolvedName => name;

  String get resolvedInputClass => _joinClasses(<String>[
        inputClass,
        _formControlSizeClass,
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
    runValidation();
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
      validationDirty = true;
    }

    if (inputElement?.value != sanitized) {
      _syncInputValue();
      _moveCaretToEnd();
    }

    onChange(
      minorUnits,
      rawValue: sanitized,
    );
    runValidation();
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
    if (validationTouched) {
      onTouched();
      runValidation();
      _syncValidationClasses();
      return;
    }

    validationTouched = true;
    onTouched();
    runValidation();
    _syncValidationClasses();
  }

  void _rebuildValidationConfig() {
    rebuildValidationConfig();
    runValidation();
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  String get _normalizedSize {
    final normalized = size.trim().toLowerCase();
    return normalized == 'sm' || normalized == 'lg' ? normalized : '';
  }

  String get _formControlSizeClass {
    switch (_normalizedSize) {
      case 'sm':
        return 'form-control-sm';
      case 'lg':
        return 'form-control-lg';
      default:
        return '';
    }
  }

  bool get _hasHostInvalidState =>
      _hostElement.classes.contains('is-invalid') ||
      _hostElement.attributes['data-invalid'] == 'true';

  bool get _hasHostValidState => _hostElement.classes.contains('is-valid');

  @override
  void ngOnDestroy() {
    _hostFocusSubscription?.cancel();
    disconnectValidationForm();
    _hostClassObserver?.disconnect();
  }
}
