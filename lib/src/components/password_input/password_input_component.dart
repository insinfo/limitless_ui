import 'dart:js_interop';
import 'dart:async';
import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';

import '../../web_support/zone_dom_callbacks.dart';

import '../../directives/li_form_directive.dart';
import '../../validation/li_built_in_input_types.dart';
import '../../validation/li_input_type.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';

typedef LiPasswordInputValidator = String? Function(String value);

const liPasswordInputDirectives = <Object>[
  LiPasswordInputComponent,
];

@Component(
  selector: 'li-password-input',
  templateUrl: 'password_input_component.html',
  styleUrls: ['password_input_component.css'],
  directives: [coreDirectives],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiPasswordInputComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiPasswordInputComponent
    implements
        ControlValueAccessor<String?>,
        AfterChanges,
        AfterViewInit,
        OnDestroy {
  LiPasswordInputComponent(
    this._hostElement,
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]) : _generatedId = 'li-password-input-${_nextId++}';

  static int _nextId = 0;

  final web.HTMLElement _hostElement;
  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  final String _generatedId;
  final StreamController<web.Event> _blurController =
      StreamController<web.Event>.broadcast();
  final StreamController<web.Event> _focusController =
      StreamController<web.Event>.broadcast();
  final StreamController<web.MouseEvent> _clickController =
      StreamController<web.MouseEvent>.broadcast();
  final StreamController<web.KeyboardEvent> _keydownController =
      StreamController<web.KeyboardEvent>.broadcast();
  final StreamController<web.KeyboardEvent> _enterController =
      StreamController<web.KeyboardEvent>.broadcast();
  StreamSubscription<bool>? _formSubmissionSubscription;

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
  String size = '';

  @Input()
  String ariaLabel = '';

  @Input()
  String autocomplete = 'new-password';

  @Input()
  String inputMode = 'text';

  @Input()
  String locale = 'pt_BR';

  @Input()
  String enterKeyHint = 'done';

  @Input()
  String autocorrect = 'off';

  @Input()
  String autocapitalize = 'off';

  @Input()
  String spellcheck = 'false';

  @Input()
  String dataLpignore = 'true';

  @Input('data1pIgnore')
  String data1pIgnore = 'true';

  @Input()
  String dataBwignore = 'true';

  @Input()
  int minLength = 0;

  @Input()
  int maxLength = 0;

  @Input()
  String pattern = '';

  @Input()
  String titleText = '';

  @Input()
  LiPasswordInputValidator? validator;

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
  String showPasswordLabel = 'Mostrar senha';

  @Input()
  String hidePasswordLabel = 'Ocultar senha';

  @Input()
  String maskChar = '•';

  @Input()
  bool disabled = false;

  @Input()
  bool readonly = false;

  @Input()
  bool required = false;

  @Input()
  bool floatingLabel = false;

  @ViewChild('inputElement')
  web.HTMLInputElement? inputElement;

  @Output('inputBlur')
  Stream<web.Event> get inputBlur => _blurController.stream;

  @Output('inputFocus')
  Stream<web.Event> get inputFocus => _focusController.stream;

  @Output('inputClick')
  Stream<web.MouseEvent> get inputClick => _clickController.stream;

  @Output('inputKeydown')
  Stream<web.KeyboardEvent> get inputKeydown => _keydownController.stream;

  @Output('inputEnter')
  Stream<web.KeyboardEvent> get inputEnter => _enterController.stream;

  String _realValue = '';
  bool _passwordVisible = false;
  bool _updatingView = false;
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _autoValidationIssue;
  LiInputType? _resolvedLiInputType;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};
  ZoneMutationObserver? _hostClassObserver;

  ChangeFunction<String?> _onChange = (String? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  @HostBinding('class.d-block')
  bool get hostClass => true;

  @HostBinding('attr.tabindex')
  String get hostTabIndex => '-1';

  String get resolvedId => id.trim().isEmpty ? _generatedId : id.trim();

  String? get resolvedName => name;

  String? get resolvedAriaLabel =>
      ariaLabel.trim().isEmpty ? null : ariaLabel.trim();

  String get resolvedAutocomplete =>
      _resolvedString(
        autocomplete,
        fallback: resolvedLiInputType?.autocomplete ?? 'new-password',
      ) ??
      'new-password';

  String get resolvedInputMode =>
      _resolvedString(inputMode,
          fallback: resolvedLiInputType?.inputMode ?? 'text') ??
      'text';

  String get resolvedEnterKeyHint =>
      _resolvedString(enterKeyHint, fallback: 'done') ?? 'done';

  String get resolvedAutocorrect =>
      _resolvedString(autocorrect, fallback: 'off') ?? 'off';

  String get resolvedAutocapitalize =>
      _resolvedString(autocapitalize, fallback: 'off') ?? 'off';

  String get resolvedSpellcheck =>
      _resolvedString(spellcheck, fallback: 'false') ?? 'false';

  String get resolvedDataLpignore =>
      _resolvedString(dataLpignore, fallback: 'true') ?? 'true';

  String get resolvedData1pIgnore =>
      _resolvedString(data1pIgnore, fallback: 'true') ?? 'true';

  String get resolvedDataBwignore =>
      _resolvedString(dataBwignore, fallback: 'true') ?? 'true';

  int? get resolvedMinLength => minLength > 0 ? minLength : null;

  int? get resolvedMaxLength => maxLength > 0 ? maxLength : null;

  String? get resolvedPattern => pattern.trim().isEmpty ? null : pattern.trim();

  String? get resolvedTitleText =>
      titleText.trim().isEmpty ? null : titleText.trim();

  LiInputType? get resolvedLiInputType => _resolvedLiInputType;

  bool get effectiveRequired =>
      required || _effectiveRules.any((rule) => rule.code == 'required');

  bool get hasLabel => label.trim().isNotEmpty;

  bool get usesFloatingLabel => floatingLabel && hasLabel;

  bool get showTopLabel => hasLabel && !usesFloatingLabel;

  bool get showHelperText => helperText.trim().isNotEmpty;

  bool get showInvalidFeedback =>
      resolvedInvalidFeedbackText.trim().isNotEmpty && effectiveInvalid;

  bool get showValidFeedback => validFeedbackText.trim().isNotEmpty && isValid;

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
      (_effectiveAutoValid || _hostElement.classList.contains('is-valid'));

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

  String get currentDisplayValue =>
      _passwordVisible ? _realValue : _mask(_realValue.length);

  bool get passwordVisible => _passwordVisible;

  String get passwordToggleIconClass =>
      passwordVisible ? 'ph ph-eye-slash' : 'ph ph-eye';

  String get passwordToggleAriaLabel =>
      passwordVisible ? hidePasswordLabel : showPasswordLabel;

  String get resolvedPlaceholder {
    final effectivePlaceholder = _resolvedString(placeholder);
    if (usesFloatingLabel) {
      final normalized = effectivePlaceholder?.trim() ?? '';
      return normalized.isEmpty ? ' ' : normalized;
    }

    return effectivePlaceholder ?? '';
  }

  String get resolvedContainerClass => _joinClasses(<String>[
        'li-input',
        'li-password-input',
        containerClass,
      ]);

  String get resolvedInputClass => _joinClasses(<String>[
        'form-control',
        size.trim().toLowerCase() == 'sm' ? 'form-control-sm' : '',
        size.trim().toLowerCase() == 'lg' ? 'form-control-lg' : '',
        'li-input__control--with-overlay-toggle',
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
    _renderDisplayedValue();
    _markForCheck();
  }

  @override
  void writeValue(dynamic value) {
    final normalized = switch (value) {
      String v => v,
      null => '',
      _ => value.toString(),
    };
    _realValue = normalized;
    _renderDisplayedValue();
    _runAutoValidation();
    _markForCheck();
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    if (inputElement != null) {
      inputElement!.disabled = isDisabled;
    }
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

    _hostClassObserver = ZoneMutationObserver((_, __) {
      _syncValidationClasses();
      _markForCheck();
    })
      ..observe(
        _hostElement,
        attributes: true,
        attributeFilter: const ['class', 'data-invalid'],
      );

    _renderDisplayedValue();
    _syncValidationClasses();
    _rebuildValidationConfig(normalizeCurrentValue: false);
  }

  void handleInput(web.Event event) {
    final field = inputElement;
    if (field == null || disabled || readonly || _updatingView) {
      return;
    }

    _dirty = true;

    if (_passwordVisible) {
      _realValue = field.value;
      _onChange(_realValue, rawValue: _realValue);
      if (validateOnInput ||
          _shouldShowValidation ||
          _autoValidationIssue != null) {
        _runAutoValidation();
      } else {
        _syncValidationClasses();
      }
      _markForCheck();
      return;
    }

    final newView = field.value;
    final oldView = _mask(_realValue.length);
    if (newView == oldView) {
      return;
    }

    final diff = _calculateDiff(oldView, newView);
    final inserted = diff.inserted.replaceAll(resolvedMaskChar, '');
    _replaceRange(diff.start, diff.endOld, inserted);
  }

  void handlePaste(web.ClipboardEvent event) {
    if (disabled || readonly || _passwordVisible) {
      return;
    }

    event.preventDefault();
    final text = event.clipboardData?.getData('text') ?? '';
    if (text.isEmpty) {
      return;
    }

    final field = inputElement;
    final start = field?.selectionStart ?? _realValue.length;
    final end = field?.selectionEnd ?? start;
    _replaceRange(start, end, text);
  }

  void handleCut(web.Event event) {
    if (!_passwordVisible) {
      event.preventDefault();
    }
  }

  void handleDrop(web.Event event) {
    if (!_passwordVisible) {
      event.preventDefault();
    }
  }

  void handleBlur(web.Event event) {
    _touched = true;
    _onTouched();
    _runAutoValidation();
    _blurController.add(event);
    _markForCheck();
  }

  void handleFocus(web.Event event) {
    _focusController.add(event);
  }

  void handleClick(web.MouseEvent event) {
    _clickController.add(event);
  }

  void handleKeydown(web.Event event) {
    if (!event.isA<web.KeyboardEvent>()) {
      return;
    }

    _keydownController.add(event as web.KeyboardEvent);
    if (event.key == 'Enter' ||
        event.code == 'Enter' ||
        event.code == 'NumpadEnter') {
      _enterController.add(event);
    }

    if (disabled || readonly || _passwordVisible) {
      return;
    }

    final key = event.key;
    final field = inputElement;
    final start = field?.selectionStart ?? _realValue.length;
    final end = field?.selectionEnd ?? start;

    if (_isNavigationKey(key) || _isSafeKey(key)) {
      return;
    }

    if (event.ctrlKey || event.metaKey || event.altKey) {
      return;
    }

    if (key == 'Backspace') {
      event.preventDefault();
      if (start != end) {
        _replaceRange(start, end, '');
      } else if (start > 0) {
        _replaceRange(start - 1, start, '');
      }
      return;
    }

    if (key == 'Delete') {
      event.preventDefault();
      if (start != end) {
        _replaceRange(start, end, '');
      } else if (start < _realValue.length) {
        _replaceRange(start, start + 1, '');
      }
      return;
    }

    if (key.length == 1) {
      event.preventDefault();
      _replaceRange(start, end, key);
      return;
    }

    event.preventDefault();
  }

  @HostListener('focus')
  void handleHostFocus() {
    Future<void>.microtask(_focusInput);
  }

  void handlePasswordToggleMouseDown(web.MouseEvent event) {
    event.preventDefault();
  }

  void togglePasswordVisibility() {
    if (disabled) {
      return;
    }

    final field = inputElement;
    final selectionStart = field?.selectionStart ?? _realValue.length;
    final selectionEnd = field?.selectionEnd ?? selectionStart;
    _passwordVisible = !_passwordVisible;
    _renderDisplayedValue(
      selectionStart: selectionStart,
      selectionEnd: selectionEnd,
    );
    _markForCheck();

    Future<void>.microtask(_focusInput);
  }

  void _focusInput() {
    final field = inputElement;
    if (field == null) {
      return;
    }
    field.focus();
  }

  void _replaceRange(int start, int end, String inserted) {
    final safeStart = start.clamp(0, _realValue.length);
    final safeEnd = end.clamp(safeStart, _realValue.length);

    _realValue = _realValue.substring(0, safeStart) +
        inserted +
        _realValue.substring(safeEnd);

    final caret = safeStart + inserted.length;
    _renderDisplayedValue(selectionStart: caret, selectionEnd: caret);
    _onChange(_realValue, rawValue: _realValue);
    if (validateOnInput ||
        _shouldShowValidation ||
        _autoValidationIssue != null) {
      _runAutoValidation();
    } else {
      _syncValidationClasses();
    }
    _markForCheck();
  }

  void _renderDisplayedValue({int? selectionStart, int? selectionEnd}) {
    final field = inputElement;
    if (field == null) {
      return;
    }

    _updatingView = true;
    field.value = currentDisplayValue;

    final maxPosition = currentDisplayValue.length;
    final start = (selectionStart ?? maxPosition).clamp(0, maxPosition);
    final end = (selectionEnd ?? start).clamp(start, maxPosition);
    field.setSelectionRange(start, end);

    _updatingView = false;
  }

  void _syncValidationClasses() {
    final field = inputElement;
    if (field == null) {
      return;
    }

    final shouldShowInvalid = effectiveInvalid;
    final shouldShowValid = isValid;

    if (shouldShowInvalid) {
      field.classList.add('is-invalid');
    } else {
      field.classList.remove('is-invalid');
    }

    if (shouldShowValid) {
      field.classList.add('is-valid');
    } else {
      field.classList.remove('is-valid');
    }

    if (effectiveInvalid) {
      field.setAttribute('data-invalid', 'true');
    } else {
      field.removeAttribute('data-invalid');
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
      _realValue = _normalizeIncomingValue(_realValue);
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

    final normalizedValue =
        resolvedLiInputType?.normalize(_realValue) ?? _realValue;
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
    final max = resolvedMaxLength;
    if (max == null || value.length <= max) {
      return value;
    }
    return value.substring(0, max);
  }

  String _mask(int length) {
    if (length <= 0) {
      return '';
    }

    return resolvedMaskChar * length;
  }

  String get resolvedMaskChar => maskChar.isEmpty ? '•' : maskChar[0];

  bool _isNavigationKey(String key) {
    return key == 'Tab' ||
        key == 'ArrowLeft' ||
        key == 'ArrowRight' ||
        key == 'ArrowUp' ||
        key == 'ArrowDown' ||
        key == 'Home' ||
        key == 'End' ||
        key == 'Shift' ||
        key == 'Control' ||
        key == 'Alt' ||
        key == 'Meta' ||
        key == 'Escape';
  }

  bool _isSafeKey(String key) {
    return _isNavigationKey(key) || key == 'Enter';
  }

  _InputDiff _calculateDiff(String oldValue, String newValue) {
    var start = 0;

    while (start < oldValue.length &&
        start < newValue.length &&
        oldValue[start] == newValue[start]) {
      start++;
    }

    var oldEnd = oldValue.length;
    var newEnd = newValue.length;

    while (oldEnd > start &&
        newEnd > start &&
        oldValue[oldEnd - 1] == newValue[newEnd - 1]) {
      oldEnd--;
      newEnd--;
    }

    return _InputDiff(
      start: start,
      endOld: oldEnd,
      inserted: newValue.substring(start, newEnd),
    );
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
      _hostElement.classList.contains('is-invalid') ||
      _hostElement.getAttribute('data-invalid') == 'true';

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

class _InputDiff {
  const _InputDiff({
    required this.start,
    required this.endOld,
    required this.inserted,
  });

  final int start;
  final int endOld;
  final String inserted;
}
