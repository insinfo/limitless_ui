import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import '../../directives/li_form_directive.dart';
import '../../validation/li_built_in_input_types.dart';
import '../../validation/li_input_type.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';

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
    implements
        ControlValueAccessor<String?>,
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
  StreamSubscription<bool>? _formSubmissionSubscription;

  @Input()
  String id = '';

  @Input()
  String name = '';

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

  @Input()
  String locale = 'pt_BR';

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
  bool invalid = false;

  @Input()
  bool dataInvalid = false;

  @Input()
  String errorText = '';

  @Input()
  String liType = '';

  @Input()
  LiInputType? liInputType;

  @Input()
  List<LiRule> liRules = const <LiRule>[];

  @Input()
  Map<String, String> liMessages = const <String, String>{};

  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  @Input()
  bool validateOnInput = true;

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
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _autoValidationIssue;
  LiInputType? _resolvedLiInputType;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};
  html.MutationObserver? _hostClassObserver;

  ChangeFunction<String?> _onChange = (String? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  @HostBinding('class.d-block')
  bool get hostClass => true;

  @HostBinding('attr.tabindex')
  String get hostTabIndex => '-1';

  String get resolvedId => id.trim().isEmpty ? _generatedId : id.trim();

  String? get resolvedName => name.trim().isEmpty ? null : name.trim();

  String? get resolvedAriaLabel =>
      ariaLabel.trim().isEmpty ? null : ariaLabel.trim();

  String? get resolvedAutocomplete => _resolvedString(autocomplete,
      fallback: resolvedLiInputType?.autocomplete);

  String? get resolvedInputMode =>
      _resolvedString(inputMode, fallback: resolvedLiInputType?.inputMode);

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

  int? get effectiveMinLength =>
      minLength > 0 ? minLength : resolvedLiInputType?.minLength;

  int? get effectiveMaxLength =>
      maxLength > 0 ? maxLength : resolvedLiInputType?.maxLength;

  bool get effectiveRequired =>
      required || _effectiveRules.any((rule) => rule.code == 'required');

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

  bool get hasMask => effectiveMask.isNotEmpty && !multiline;

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
      maskFormatter != null && resolvedType != 'number';

  String get resolvedInvalidFeedbackText => effectiveErrorText;

  bool get effectiveInvalid =>
      invalid || dataInvalid || _hasHostInvalidState || effectiveAutoInvalid;

  bool get effectiveAutoInvalid =>
      _shouldShowValidation && _autoValidationIssue != null;

  bool get _effectiveAutoValid =>
      _shouldShowValidation &&
      _effectiveRules.isNotEmpty &&
      _autoValidationIssue == null;

  bool get isInvalid => effectiveInvalid;

  bool get isValid =>
      !isInvalid &&
      (_effectiveAutoValid || _hostElement.classes.contains('is-valid'));

  String get effectiveErrorText {
    final externalMessage = errorText.trim();
    if (externalMessage.isNotEmpty) {
      return externalMessage;
    }

    final legacyMessage = invalidFeedbackText.trim();
    if (legacyMessage.isNotEmpty && effectiveInvalid) {
      return legacyMessage;
    }

    return _autoValidationIssue?.message ?? '';
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
  void registerOnChange(ChangeFunction<String?> fn) {
    _onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _onTouched = fn;
  }

  @override
  void ngAfterChanges() {
    _rebuildValidationConfig(normalizeCurrentValue: true);
    _syncInputValue();
    _markForCheck();
  }

  @override
  void writeValue(dynamic value) {
    final normalized = switch (value) {
      String v => v,
      null => '',
      _ => value.toString(),
    };
    _value = _normalizeIncomingValue(normalized);
    _syncInputValue();
    _runAutoValidation();
    _markForCheck();
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    _markForCheck();
  }

  @override
  void ngAfterViewInit() {
    _formSubmitted = _formDirective?.submitted ?? false;
    _formSubmissionSubscription =
        _formDirective?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      _runAutoValidation();
      _syncValidationClasses();
      _markForCheck();
    });

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
    _dirty = true;
    _value = _normalizeIncomingValue(value);
    _syncInputValue();
    _onChange(_value, rawValue: value);
    if (validateOnInput ||
        _shouldShowValidation ||
        _autoValidationIssue != null) {
      _runAutoValidation();
    } else {
      _syncValidationClasses();
    }
    _markForCheck();
  }

  void handleBlur(html.Event event) {
    _touched = true;
    _onTouched();
    _runAutoValidation();
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

  void _rebuildValidationConfig({required bool normalizeCurrentValue}) {
    _resolvedLiInputType = liInputType ?? LiBuiltInInputTypes.resolve(liType);
    _effectiveMessages = Map<String, String>.unmodifiable(<String, String>{
      ...?_resolvedLiInputType?.messages,
      ...liMessages,
    });
    _effectiveRules = List<LiRule>.unmodifiable(_buildEffectiveRules());

    if (normalizeCurrentValue) {
      _value = _normalizeIncomingValue(_value);
    }

    _runAutoValidation();
  }

  List<LiRule> _buildEffectiveRules() {
    final rules = <LiRule>[
      ...?_resolvedLiInputType?.rules,
      if (required) const LiRequiredRule(),
      if (minLength > 0) LiRule.minLength(minLength),
      if (maxLength > 0) LiRule.maxLength(maxLength),
      if (pattern.trim().isNotEmpty) LiRule.pattern(pattern.trim()),
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

  void _runAutoValidation() {
    if (_effectiveRules.isEmpty) {
      _autoValidationIssue = null;
      _syncValidationClasses();
      return;
    }

    final normalizedValue = resolvedLiInputType?.normalize(_value) ?? _value;
    _autoValidationIssue = liValidateValue(
      value: normalizedValue,
      rules: _effectiveRules,
      context: LiRuleContext(
        fieldName: resolvedName,
        inputType: resolvedLiInputType,
        messages: _effectiveMessages,
        locale: locale,
      ),
    );
    _syncValidationClasses();
  }

  String _normalizeIncomingValue(String value) {
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

  bool get _shouldShowValidation => liShouldShowValidation(
        mode: liValidationMode,
        touched: _touched,
        dirty: _dirty,
        submitted: _formSubmitted,
      );

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
    _formSubmissionSubscription?.cancel();
    _blurController.close();
    _focusController.close();
    _clickController.close();
    _keydownController.close();
    _enterController.close();
  }
}
