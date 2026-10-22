import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import '../../directives/li_form_directive.dart';
import '../../validation/li_built_in_input_types.dart';
import '../../validation/li_input_type.dart';
import '../../validation/li_number_parsing.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_validated_field.dart';

typedef LiInputValidator = String? Function(String value);
typedef LiInputMaskFormatter = String Function(String value);

const liInputDirectives = <Object>[
  LiInputComponent,
];

@Component(
  selector: 'li-input',
  templateUrl: 'input_component.html',
  styleUrls: ['input_component.css'],
  directives: [coreDirectives],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiInputComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiInputComponent
    with LiValidatedField
    implements
        ControlValueAccessor<dynamic>,
        AfterChanges,
        AfterViewInit,
        OnDestroy {
  LiInputComponent(
    this._hostElement,
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]) : _generatedId = 'li-input-${_nextId++}';

  static int _nextId = 0;

  final html.HtmlElement _hostElement;
  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  final String _generatedId;
  final StreamController<html.Event> _blurController =
      StreamController<html.Event>.broadcast();
  final StreamController<html.Event> _focusController =
      StreamController<html.Event>.broadcast();
  final StreamController<html.MouseEvent> _clickController =
      StreamController<html.MouseEvent>.broadcast();
  final StreamController<html.KeyboardEvent> _keydownController =
      StreamController<html.KeyboardEvent>.broadcast();
  final StreamController<html.KeyboardEvent> _enterController =
      StreamController<html.KeyboardEvent>.broadcast();

  @Input()
  String id = '';

  @Input()
  String? name;

  @Input()
  String label = '';

  @Input()
  String helperText = '';

  @Input()
  String invalidFeedbackText = '';

  @Input()
  String validFeedbackText = '';

  @Input()
  String placeholder = '';

  @Input()
  String type = '';

  @Input()
  String size = '';

  @Input()
  String ariaLabel = '';

  @Input()
  String autocomplete = '';

  @Input()
  String inputMode = '';

  /// Locale of the default rule messages and, with a numeric [valueType],
  /// of the decimal separator typed and displayed in the field.
  @override
  @Input()
  String locale = 'pt_BR';

  /// Type of the value the model receives.
  ///
  /// - `text` (default): the model receives the text of the field, as a
  ///   `String`. Unchanged from earlier versions.
  /// - `integer`: the model receives an `int?`; only digits can be typed
  ///   (and a leading `-` with [allowNegative]).
  /// - `decimal`: the model receives a `double?`; digits and the decimal
  ///   separator of [locale] can be typed, with at most [decimalPlaces]
  ///   digits after it.
  ///
  /// In both numeric types an empty field is `null`, `writeValue` accepts
  /// `num`, `String` or `null`, the native input stays `type="text"` (so the
  /// locale separator can be typed and the browser does not sanitize the
  /// value away) and `inputmode` defaults to `numeric`/`decimal`. Masks and
  /// `liType` normalizers do not apply. `min` and `max`, when they hold a
  /// number, become `LiRule.min`/`LiRule.max` rules.
  @Input()
  String valueType = 'text';

  /// Whether a leading `-` can be typed in a numeric [valueType].
  ///
  /// Off by default. When on, `inputmode` is not set by default, because the
  /// numeric keypads of iOS have no minus key; pass [inputMode] to choose.
  @Input()
  bool allowNegative = false;

  /// Maximum number of digits after the decimal separator when [valueType]
  /// is `decimal`. `null` (default) does not limit them; `0` blocks the
  /// separator. Ignored for other value types.
  @Input()
  int? decimalPlaces;

  @Input()
  String enterKeyHint = '';

  @Input()
  String autocorrect = '';

  @Input()
  String autocapitalize = '';

  @Input()
  String spellcheck = '';

  @Input()
  String dataLpignore = '';

  @Input('data1pIgnore')
  String data1pIgnore = '';

  @Input()
  String dataBwignore = '';

  @Input()
  String min = '';

  @Input()
  String max = '';

  @Input()
  String step = '';

  @Input()
  int minLength = 0;

  @Input()
  String pattern = '';

  @Input()
  String titleText = '';

  @Input()
  String mask = '';

  @Input()
  String maskSlot = 'x';

  @Input()
  LiInputMaskFormatter? maskFormatter;

  @Input()
  LiInputValidator? validator;

  @Input()
  String errorText = '';

  @Input()
  String liType = '';

  @Input()
  LiInputType? liInputType;

  @Input()
  int maxLength = 0;

  @Input()
  String inputClass = '';

  @Input()
  String labelClass = '';

  @Input()
  String containerClass = '';

  @Input()
  String helperClass = '';

  @Input()
  String invalidFeedbackClass = '';

  @Input()
  String validFeedbackClass = '';

  @Input()
  String prefixText = '';

  @Input()
  String suffixText = '';

  @Input()
  String prefixIconClass = '';

  @Input()
  String suffixIconClass = '';

  @Input()
  bool passwordToggle = false;

  @Input()
  bool passwordToggleOverlay = false;

  @Input()
  String showPasswordLabel = 'Mostrar senha';

  @Input()
  String hidePasswordLabel = 'Ocultar senha';

  @Input()
  bool disabled = false;

  @Input()
  bool readonly = false;

  @Input()
  bool required = false;

  @Input()
  bool floatingLabel = false;

  @Input()
  bool multiline = false;

  @Input()
  int rows = 3;

  @ViewChild('inputElement')
  html.Element? inputElement;

  @Output('inputBlur')
  Stream<html.Event> get inputBlur => _blurController.stream;

  @Output('inputFocus')
  Stream<html.Event> get inputFocus => _focusController.stream;

  @Output('inputClick')
  Stream<html.MouseEvent> get inputClick => _clickController.stream;

  @Output('inputKeydown')
  Stream<html.KeyboardEvent> get inputKeydown => _keydownController.stream;

  @Output('inputEnter')
  Stream<html.KeyboardEvent> get inputEnter => _enterController.stream;

  String _value = '';
  num? _numericValue;
  String _numericFormatSignature = '';
  LiInputType? _resolvedLiInputType;
  html.MutationObserver? _hostClassObserver;

  ChangeFunction<dynamic> _onChange = (dynamic _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  @HostBinding('class.d-block')
  bool get hostClass => true;

  @HostBinding('attr.tabindex')
  String get hostTabIndex => '-1';

  String get resolvedId => id.trim().isEmpty ? _generatedId : id.trim();

  String? get resolvedName => name;

  String? get resolvedAriaLabel =>
      ariaLabel.trim().isEmpty ? null : ariaLabel.trim();

  String? get resolvedAutocomplete => _resolvedString(autocomplete,
      fallback: resolvedLiInputType?.autocomplete);

  String? get resolvedInputMode => _resolvedString(
        inputMode,
        fallback: isNumeric
            ? _defaultNumericInputMode
            : resolvedLiInputType?.inputMode,
      );

  /// Normalized [valueType]: `text`, `integer` or `decimal`.
  String get resolvedValueType {
    switch (valueType.trim().toLowerCase()) {
      case 'integer':
        return 'integer';
      case 'decimal':
        return 'decimal';
      default:
        return 'text';
    }
  }

  /// Whether [valueType] is `integer` or `decimal`.
  bool get isNumeric => resolvedValueType != 'text';

  bool get _isDecimal => resolvedValueType == 'decimal';

  /// Value held by the model in a numeric [valueType]: `int`, `double` or
  /// `null`. Always `null` in `text` mode.
  num? get numericValue => isNumeric ? _numericValue : null;

  String get _decimalSeparator => liDecimalSeparator(locale);

  int? get _effectiveDecimalPlaces {
    final places = decimalPlaces;
    if (!_isDecimal || places == null) {
      return null;
    }
    return places < 0 ? null : places;
  }

  String? get _defaultNumericInputMode {
    if (allowNegative) {
      return null;
    }
    return _isDecimal ? 'decimal' : 'numeric';
  }

  String? get resolvedEnterKeyHint =>
      enterKeyHint.trim().isEmpty ? null : enterKeyHint.trim();

  String? get resolvedAutocorrect =>
      autocorrect.trim().isEmpty ? null : autocorrect.trim();

  String? get resolvedAutocapitalize =>
      autocapitalize.trim().isEmpty ? null : autocapitalize.trim();

  String? get resolvedSpellcheck =>
      spellcheck.trim().isEmpty ? null : spellcheck.trim();

  String? get resolvedDataLpignore =>
      dataLpignore.trim().isEmpty ? null : dataLpignore.trim();

  String? get resolvedData1pIgnore =>
      data1pIgnore.trim().isEmpty ? null : data1pIgnore.trim();

  String? get resolvedDataBwignore =>
      dataBwignore.trim().isEmpty ? null : dataBwignore.trim();

  String? get resolvedMin => min.trim().isEmpty ? null : min.trim();

  String? get resolvedMax => max.trim().isEmpty ? null : max.trim();

  String? get resolvedStep => step.trim().isEmpty ? null : step.trim();

  int? get resolvedMinLength => minLength > 0 ? minLength : null;

  String? get resolvedPattern => pattern.trim().isEmpty ? null : pattern.trim();

  String? get resolvedTitleText =>
      titleText.trim().isEmpty ? null : titleText.trim();

  int? get resolvedMaxLength => maxLength > 0 ? maxLength : null;

  LiInputType? get resolvedLiInputType => _resolvedLiInputType;

  /// The number in a numeric [valueType]; otherwise the text, normalized by
  /// the field preset when there is one.
  @override
  dynamic get validationValue => isNumeric
      ? _numericValue
      : resolvedLiInputType?.normalize(_value) ?? _value;

  @override
  String get externalErrorText => errorText;

  @override
  String? get validationFieldName => resolvedName;

  @override
  Object? get validationInputType => resolvedLiInputType;

  /// Preset rules, then the rules derived from [required], [minLength],
  /// [maxLength], [pattern] and the numeric [min]/[max], then [liRules], then
  /// the legacy [validator].
  @override
  List<LiRule> buildValidationRules() => _buildEffectiveRules();

  @override
  Map<String, String> buildValidationMessages() => <String, String>{
        ...?_resolvedLiInputType?.messages,
        ...liMessages,
      };

  @override
  void didRunValidation() {
    _syncValidationClasses();
  }

  @override
  void didChangeFormSubmission() {
    _syncValidationClasses();
    _markForCheck();
  }

  int? get effectiveMinLength =>
      minLength > 0 ? minLength : resolvedLiInputType?.minLength;

  int? get effectiveMaxLength =>
      maxLength > 0 ? maxLength : resolvedLiInputType?.maxLength;

  bool get effectiveRequired =>
      required || effectiveRules.any((rule) => rule.code == 'required');

  String get effectiveHtmlType {
    final explicitType = type.trim();
    if (explicitType.isNotEmpty) {
      return explicitType;
    }

    return resolvedLiInputType?.htmlType?.trim().isNotEmpty == true
        ? resolvedLiInputType!.htmlType!.trim()
        : 'text';
  }

  String get effectiveMask {
    final explicitMask = mask.trim();
    if (explicitMask.isNotEmpty) {
      return explicitMask;
    }

    return resolvedLiInputType?.mask?.trim() ?? '';
  }

  bool get hasMask => effectiveMask.isNotEmpty && !multiline && !isNumeric;

  bool get hasLabel => label.trim().isNotEmpty;

  bool get hasPrefix =>
      prefixText.trim().isNotEmpty || prefixIconClass.trim().isNotEmpty;

  bool get hasExplicitSuffix =>
      suffixText.trim().isNotEmpty || suffixIconClass.trim().isNotEmpty;

  bool get hasSuffix => hasExplicitSuffix || showsAddonPasswordToggle;

  bool get hasAddons => hasPrefix || hasSuffix;

  bool get usesFloatingLabel => floatingLabel && hasLabel && !hasAddons;

  bool get showTopLabel => hasLabel && !usesFloatingLabel;

  bool get showHelperText => helperText.trim().isNotEmpty;

  bool get showInvalidFeedback =>
      resolvedInvalidFeedbackText.trim().isNotEmpty && effectiveInvalid;

  bool get showValidFeedback => validFeedbackText.trim().isNotEmpty && isValid;

  bool get hasCustomMaskFormatter =>
      maskFormatter != null && resolvedType != 'number' && !isNumeric;

  String get resolvedInvalidFeedbackText => effectiveErrorText;

  /// Also invalid while the host carries `is-invalid` or `data-invalid`.
  @override
  bool get effectiveInvalid =>
      invalid || dataInvalid || _hasHostInvalidState || effectiveAutoInvalid;

  /// An `is-valid` class set on the host.
  @override
  bool get externalValid => _hostElement.classes.contains('is-valid');

  bool get isInvalid => effectiveInvalid;

  bool get isValid => effectiveValid;

  /// [errorText] first, then the legacy [invalidFeedbackText] while the field
  /// is invalid, then the message of the automatic validation.
  @override
  String get effectiveErrorText {
    final externalMessage = errorText.trim();
    if (externalMessage.isNotEmpty) {
      return externalMessage;
    }

    final legacyMessage = invalidFeedbackText.trim();
    if (legacyMessage.isNotEmpty && effectiveInvalid) {
      return legacyMessage;
    }

    return validationIssue?.message ?? '';
  }

  int get resolvedRows => rows < 2 ? 2 : rows;

  String get currentValue => _value;

  bool get passwordVisible => _passwordVisible;

  bool get showsPasswordToggle =>
      passwordToggle && resolvedBaseType == 'password' && !multiline;

  bool get usesOverlayPasswordToggle =>
      showsPasswordToggle && passwordToggleOverlay;

  bool get showsAddonPasswordToggle =>
      showsPasswordToggle && !usesOverlayPasswordToggle;

  String get passwordToggleIconClass =>
      passwordVisible ? 'ph ph-eye-slash' : 'ph ph-eye';

  String get passwordToggleAriaLabel =>
      passwordVisible ? hidePasswordLabel : showPasswordLabel;

  String get resolvedType {
    if (showsPasswordToggle && passwordVisible) {
      return 'text';
    }

    return resolvedBaseType;
  }

  String get resolvedBaseType {
    if (isNumeric) {
      return 'text';
    }
    switch (effectiveHtmlType.trim().toLowerCase()) {
      case 'email':
      case 'number':
      case 'password':
      case 'search':
      case 'tel':
      case 'url':
      case 'date':
      case 'time':
        return effectiveHtmlType.trim().toLowerCase();
      case 'text':
      default:
        return 'text';
    }
  }

  bool _passwordVisible = false;
  String get resolvedPlaceholder {
    final effectivePlaceholder = _resolvedString(
      placeholder,
      fallback: resolvedLiInputType?.placeholder,
    );
    if (usesFloatingLabel) {
      final normalized = effectivePlaceholder?.trim() ?? '';
      return normalized.isEmpty ? ' ' : normalized;
    }

    return effectivePlaceholder ?? '';
  }

  String get resolvedContainerClass => _joinClasses(<String>[
        'li-input',
        containerClass,
      ]);

  String get resolvedInputClass => _joinClasses(<String>[
        'form-control',
        size.trim().toLowerCase() == 'sm' ? 'form-control-sm' : '',
        size.trim().toLowerCase() == 'lg' ? 'form-control-lg' : '',
        usesOverlayPasswordToggle
            ? 'li-input__control--with-overlay-toggle'
            : '',
        inputClass,
      ]);

  String get resolvedLabelClass => _joinClasses(<String>[
        'form-label',
        labelClass,
      ]);

  String get resolvedHelperClass => _joinClasses(<String>[
        'form-text',
        helperClass,
      ]);

  String get resolvedInvalidFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        invalidFeedbackClass,
      ]);

  String get resolvedValidFeedbackClass => _joinClasses(<String>[
        'valid-feedback',
        'd-block',
        validFeedbackClass,
      ]);

  String get resolvedInputGroupClass => _joinClasses(<String>[
        'input-group',
        size.trim().toLowerCase() == 'sm' ? 'input-group-sm' : '',
        size.trim().toLowerCase() == 'lg' ? 'input-group-lg' : '',
      ]);

  @override
  void registerOnChange(ChangeFunction<dynamic> fn) {
    _onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _onTouched = fn;
  }

  @override
  void ngAfterChanges() {
    _refreshNumericDisplayIfFormatChanged();
    _rebuildValidationConfig(normalizeCurrentValue: true);
    _syncInputValue();
    _markForCheck();
  }

  @override
  void writeValue(dynamic value) {
    if (isNumeric) {
      _writeNumericValue(value);
      _syncInputValue();
      runValidation();
      _markForCheck();
      return;
    }

    final normalized = switch (value) {
      String v => v,
      null => '',
      _ => value.toString(),
    };
    _value = _normalizeIncomingValue(normalized);
    _syncInputValue();
    runValidation();
    _markForCheck();
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    _markForCheck();
  }

  @override
  void ngAfterViewInit() {
    connectValidationForm(_formDirective);

    _hostClassObserver = html.MutationObserver((_, __) {
      _syncValidationClasses();
      _markForCheck();
    })
      ..observe(
        _hostElement,
        attributes: true,
        attributeFilter: const ['class', 'data-invalid'],
      );

    _syncInputValue();
    _syncValidationClasses();
    _rebuildValidationConfig(normalizeCurrentValue: false);
  }

  void handleInput(String value) {
    validationDirty = true;
    if (isNumeric) {
      _handleNumericInput(value);
    } else {
      _value = _normalizeIncomingValue(value);
      _syncInputValue();
      _onChange(_value, rawValue: value);
    }
    if (shouldRevalidate) {
      runValidation();
    } else {
      _syncValidationClasses();
    }
    _markForCheck();
  }

  void handleBlur(html.Event event) {
    validationTouched = true;
    _onTouched();
    runValidation();
    _blurController.add(event);
    _markForCheck();
  }

  void handleFocus(html.Event event) {
    _focusController.add(event);
  }

  void handleClick(html.MouseEvent event) {
    _clickController.add(event);
  }

  void handleKeydown(html.Event event) {
    if (event is! html.KeyboardEvent) {
      return;
    }

    _keydownController.add(event);
    if (event.key == 'Enter' ||
        event.code == 'Enter' ||
        event.code == 'NumpadEnter') {
      _enterController.add(event);
    }
  }

  @HostListener('focus')
  void handleHostFocus() {
    Future<void>.microtask(_focusInput);
  }

  void handlePasswordToggleMouseDown(html.MouseEvent event) {
    event.preventDefault();
  }

  void togglePasswordVisibility() {
    if (!showsPasswordToggle || disabled) {
      return;
    }

    _passwordVisible = !_passwordVisible;
    _markForCheck();

    Future<void>.microtask(() {
      _focusInput();
    });
  }

  void _focusInput() {
    final element = inputElement;
    if (element is html.InputElement) {
      element.focus();
      return;
    }
    if (element is html.TextAreaElement) {
      element.focus();
    }
  }

  void _syncInputValue() {
    final element = inputElement;
    if (element is html.InputElement) {
      element.value = _value;
      return;
    }
    if (element is html.TextAreaElement) {
      element.value = _value;
    }
  }

  void _syncValidationClasses() {
    final element = inputElement;
    if (element == null) {
      return;
    }

    final shouldShowInvalid = effectiveInvalid;
    final shouldShowValid = isValid;

    if (shouldShowInvalid) {
      element.classes.add('is-invalid');
    } else {
      element.classes.remove('is-invalid');
    }

    if (shouldShowValid) {
      element.classes.add('is-valid');
    } else {
      element.classes.remove('is-valid');
    }

    if (effectiveInvalid) {
      element.attributes['data-invalid'] = 'true';
    } else {
      element.attributes.remove('data-invalid');
    }
  }

  /// Applies a value written by the model in a numeric [valueType].
  void _writeNumericValue(dynamic value) {
    final parsed = liParseNumber(value, locale: locale);
    if (parsed == null) {
      _numericValue = null;
      _value = '';
      return;
    }

    if (_isDecimal) {
      _numericValue = parsed.toDouble();
    } else {
      // A fractional value written into an integer field is kept as it is:
      // the model is not silently changed, and `LiRule.integer()` reports it.
      _numericValue =
          parsed == parsed.truncateToDouble() ? parsed.toInt() : parsed;
    }
    _value = _formatNumericValue(_numericValue!);
  }

  String _formatNumericValue(num value) => liFormatNumber(
        value,
        decimalSeparator: _decimalSeparator,
        decimalPlaces: _effectiveDecimalPlaces,
      );

  /// Keeps only what can be typed in a numeric [valueType].
  ///
  /// A single left-to-right pass, so sanitizing the text before the caret
  /// gives exactly the part of the result before the new caret position.
  String _sanitizeNumericText(String raw) {
    final separator = _decimalSeparator;
    final places = _effectiveDecimalPlaces;
    final acceptsSeparator = _isDecimal && places != 0;
    final buffer = StringBuffer();
    var seenSeparator = false;
    var fractionDigits = 0;

    for (var i = 0; i < raw.length; i++) {
      final character = raw[i];
      final code = character.codeUnitAt(0);
      if (code >= 0x30 && code <= 0x39) {
        if (seenSeparator) {
          if (places != null && fractionDigits >= places) {
            continue;
          }
          fractionDigits++;
        }
        buffer.write(character);
      } else if (character == '-' && allowNegative && buffer.isEmpty) {
        buffer.write(character);
      } else if (acceptsSeparator &&
          !seenSeparator &&
          character == separator) {
        buffer.write(character);
        seenSeparator = true;
      }
    }

    return buffer.toString();
  }

  num? _parseNumericText(String text) {
    if (_isDecimal) {
      return liParseLocalizedNumber(text, _decimalSeparator)?.toDouble();
    }
    final digits = text.trim();
    if (digits.isEmpty || digits == '-') {
      return null;
    }
    return int.tryParse(digits);
  }

  void _handleNumericInput(String raw) {
    final element = inputElement;
    int? caret;
    if (element is html.InputElement) {
      try {
        caret = element.selectionStart;
      } catch (_) {
        caret = null;
      }
    }

    final sanitized = _sanitizeNumericText(raw);
    _value = sanitized;
    _numericValue = _parseNumericText(sanitized);

    if (sanitized != raw) {
      _syncInputValue();
      if (element is html.InputElement && caret != null) {
        final caretInRaw = caret.clamp(0, raw.length);
        final position =
            _sanitizeNumericText(raw.substring(0, caretInRaw)).length;
        try {
          element.setSelectionRange(position, position);
        } catch (_) {
          // Some input types do not support selection; nothing to restore.
        }
      }
    }

    _onChange(_numericValue, rawValue: sanitized);
  }

  /// Re-renders the field when an input that changes how a number is shown
  /// ([valueType], [locale], [decimalPlaces], [allowNegative]) changes.
  ///
  /// Other input changes leave the text alone, so a half-typed `3,` survives
  /// an unrelated binding update.
  void _refreshNumericDisplayIfFormatChanged() {
    final signature =
        '$resolvedValueType|${locale.trim()}|$decimalPlaces|$allowNegative';
    if (signature == _numericFormatSignature) {
      return;
    }
    _numericFormatSignature = signature;

    if (!isNumeric) {
      return;
    }

    final current = _numericValue ??
        (_value.trim().isEmpty ? null : liParseNumber(_value, locale: locale));
    _writeNumericValue(current);
  }

  void _rebuildValidationConfig({required bool normalizeCurrentValue}) {
    _resolvedLiInputType = liInputType ?? LiBuiltInInputTypes.resolve(liType);
    rebuildValidationConfig();

    if (normalizeCurrentValue) {
      _value = _normalizeIncomingValue(_value);
    }

    runValidation();
  }

  List<LiRule> _buildEffectiveRules() {
    final rules = <LiRule>[
      ...?_resolvedLiInputType?.rules,
      if (required) const LiRequiredRule(),
      if (minLength > 0) LiRule.minLength(minLength),
      if (maxLength > 0) LiRule.maxLength(maxLength),
      if (pattern.trim().isNotEmpty) LiRule.pattern(pattern.trim()),
      ..._numericBoundRules(),
      ...liRules,
    ];

    final legacyValidator = validator;
    if (legacyValidator != null) {
      rules.add(LiRule.custom(
        (value) => legacyValidator.call(value?.toString() ?? ''),
        code: 'legacyValidator',
      ));
    }

    return rules;
  }

  /// `min` and `max` hold numbers for the native `type="number"` input. In a
  /// numeric [valueType] the native input is `type="text"` and ignores them,
  /// so they become rules instead.
  List<LiRule> _numericBoundRules() {
    if (!isNumeric) {
      return const <LiRule>[];
    }
    final minValue = liParseNumber(min);
    final maxValue = liParseNumber(max);
    return <LiRule>[
      if (minValue != null) LiRule.min(minValue),
      if (maxValue != null) LiRule.max(maxValue),
    ];
  }

  String _normalizeIncomingValue(String value) {
    if (isNumeric) {
      return value;
    }

    if (hasCustomMaskFormatter) {
      return maskFormatter!(value);
    }

    if (!hasMask || resolvedType == 'number') {
      return value;
    }

    return _applyMask(value, effectiveMask,
        maskSlot.trim().isEmpty ? 'x' : maskSlot.trim()[0]);
  }

  String _applyMask(String rawValue, String pattern, String slotCharacter) {
    final sanitized = rawValue
        .split('')
        .where((character) => RegExp(r'[A-Za-z0-9]').hasMatch(character))
        .toList(growable: false);
    final maxSlots = pattern
        .split('')
        .where((character) => character == slotCharacter)
        .length;
    final limited = sanitized.take(maxSlots).toList(growable: false);

    if (limited.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    var sourceIndex = 0;

    for (final character in pattern.split('')) {
      if (character == slotCharacter) {
        if (sourceIndex >= limited.length) {
          break;
        }
        buffer.write(limited[sourceIndex]);
        sourceIndex++;
        continue;
      }

      if (sourceIndex >= limited.length) {
        break;
      }

      buffer.write(character);
    }

    return buffer.toString();
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

  bool get _hasHostInvalidState =>
      _hostElement.classes.contains('is-invalid') ||
      _hostElement.attributes['data-invalid'] == 'true';

  String? _resolvedString(String value, {String? fallback}) {
    final normalized = value.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }

    final resolvedFallback = fallback?.trim() ?? '';
    return resolvedFallback.isEmpty ? null : resolvedFallback;
  }

  @override
  void ngOnDestroy() {
    _hostClassObserver?.disconnect();
    disconnectValidationForm();
    _blurController.close();
    _focusController.close();
    _clickController.close();
    _keydownController.close();
    _enterController.close();
  }
}
