import 'dart:async';
import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

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

  LiCurrencyInputComponent(this._hostElement);

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

  @ViewChild('inputElement')
  InputElement? inputElement;

  String displayValue = '';

  int? _minorUnits;
  bool _isFocused = false;
  StreamSubscription<Event>? _hostFocusSubscription;
  MutationObserver? _hostClassObserver;

  String get resolvedInputClass => '$inputClass br-currency-input__field';

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
    _syncRequiredValidationState();
  }

  @override
  void ngAfterChanges() {
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
    _syncValidationClasses();
  }

  void handleInput(String rawValue) {
    final sanitized = formatter.sanitizeForEditing(rawValue);
    final minorUnits = formatter.minorUnitsFromText(sanitized);

    _minorUnits = minorUnits;
    displayValue = sanitized;

    if (inputElement?.value != sanitized) {
      _syncInputValue();
      _moveCaretToEnd();
    }

    onChange(
      minorUnits,
      rawValue: sanitized,
    );
    _syncRequiredValidationState();
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
    _syncRequiredValidationState();
    onTouched();
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

    for (final cssClass in const ['is-invalid', 'is-valid']) {
      if (_hostElement.classes.contains(cssClass)) {
        input.classes.add(cssClass);
      } else {
        input.classes.remove(cssClass);
      }
    }

    if (_hostElement.attributes.containsKey('data-invalid')) {
      input.attributes['data-invalid'] =
          _hostElement.attributes['data-invalid']!;
    } else {
      input.attributes.remove('data-invalid');
    }
  }

  void _syncRequiredValidationState() {
    if (!required) {
      _hostElement.classes.remove('is-invalid');
      _hostElement.classes.remove('is-valid');
      _hostElement.attributes.remove('data-invalid');
      _syncValidationClasses();
      return;
    }

    final isValid = _minorUnits != null;
    if (isValid) {
      _hostElement.classes.remove('is-invalid');
      _hostElement.classes.remove('is-valid');
      _hostElement.attributes.remove('data-invalid');
    } else {
      _hostElement.classes.remove('is-valid');
      _hostElement.classes.add('is-invalid');
      _hostElement.attributes['data-invalid'] = 'true';
    }

    _syncValidationClasses();
  }

  @override
  void ngOnDestroy() {
    _hostFocusSubscription?.cancel();
    _hostClassObserver?.disconnect();
  }
}
