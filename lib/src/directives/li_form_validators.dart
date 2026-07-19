import 'dart:async';
import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';

import 'li_form_directive.dart';

const liRequiredValidatorProvider = ExistingProvider.forToken(
  ngValidators,
  LiRequiredValidator,
);

const liDocumentValidatorProvider = ExistingProvider.forToken(
  ngValidators,
  LiDocumentValidator,
);

/// Required validator with explicit `li` API and no visual side effects.
@Directive(
  selector: ''
      '[liRequired][ngControl],'
      '[liRequired][ngFormControl],'
      '[liRequired][ngModel]',
  providers: [liRequiredValidatorProvider],
)
class LiRequiredValidator implements Validator {
  /// Enables or disables the validator.
  @Input('liRequired')
  dynamic liRequired = true;

  /// Optional message returned in the validation error payload.
  @Input()
  String liRequiredMessage = 'Campo obrigatorio.';

  /// Values treated as empty in addition to `null` and blank strings.
  @Input()
  List<dynamic> liRequiredInvalidValues = const <dynamic>[];

  @override
  Map<String, dynamic>? validate(AbstractControl control) {
    if (!_isEnabled(liRequired)) {
      return null;
    }

    final value = control.value;
    if (_hasRequiredValue(value) && !liRequiredInvalidValues.contains(value)) {
      return null;
    }

    return <String, dynamic>{
      'liRequired': <String, dynamic>{
        'message': liRequiredMessage,
        'validator': 'liRequired',
      },
    };
  }
}

/// CPF/CNPJ document validator backed by `essential_core` 1.4.0 helpers.
@Directive(
  selector: ''
      '[liDocumentValidator][ngControl],'
      '[liDocumentValidator][ngFormControl],'
      '[liDocumentValidator][ngModel]',
  providers: [liDocumentValidatorProvider],
)
class LiDocumentValidator implements Validator {
  /// Document kind: `cpf`, `cnpj`, or `cpfOrCnpj`.
  @Input('liDocumentValidator')
  String liDocumentValidator = 'cpfOrCnpj';

  /// Whether blank values should fail validation.
  @Input()
  bool liDocumentRequired = false;

  /// Optional message returned in the validation error payload.
  @Input()
  String liDocumentMessage = 'Documento invalido.';

  /// Uses strict CNPJ mask validation when validating CNPJ values.
  @Input()
  bool liDocumentStrictCnpj = false;

  @override
  Map<String, dynamic>? validate(AbstractControl control) {
    final value = control.value?.toString() ?? '';
    if (value.trim().isEmpty) {
      if (!liDocumentRequired) {
        return null;
      }
      return _error('required');
    }

    final type = liDocumentValidator.trim().toLowerCase();
    final isValid = switch (type) {
      'cpf' => EssentialCoreUtils.validarCPF(value),
      'cnpj' => EssentialCoreUtils.validarCnpj(
          value,
          strict: liDocumentStrictCnpj,
        ),
      _ => _isValidCpfOrCnpj(value),
    };

    return isValid ? null : _error(type);
  }

  Map<String, dynamic> _error(String type) {
    return <String, dynamic>{
      'liDocument': <String, dynamic>{
        'message': liDocumentMessage,
        'validator': 'liDocument',
        'type': type,
      },
    };
  }

  bool _isValidCpfOrCnpj(String value) {
    final cpf = EssentialCoreUtils.sanitizarCpf(value);
    if (cpf.length == 11) {
      return EssentialCoreUtils.validarCPF(cpf);
    }

    final cnpj = EssentialCoreUtils.sanitizarCnpj(value);
    if (cnpj.length == 14) {
      return EssentialCoreUtils.validarCnpj(
        cnpj,
        strict: liDocumentStrictCnpj,
      );
    }

    return false;
  }
}

/// Adds Limitless/Bootstrap validation classes and feedback to native controls.
///
/// The directive is applied automatically alongside [LiRequiredValidator] and
/// [LiDocumentValidator]. It is intended for native `input`, `select`, and
/// `textarea` elements; library components keep their own richer validation UI.
@Directive(
  selector: ''
      '[liRequired][ngControl],'
      '[liRequired][ngFormControl],'
      '[liRequired][ngModel],'
      '[liDocumentValidator][ngControl],'
      '[liDocumentValidator][ngFormControl],'
      '[liDocumentValidator][ngModel]',
)
class LiNativeValidationFeedbackDirective implements AfterViewInit, OnDestroy {
  LiNativeValidationFeedbackDirective(
    this._element,
    @Self() this._ngControl, [
    @Optional() this._formDirective,
  ]) {
    _formSubmitted = _formDirective?.submitted ?? false;
    _formSubmissionSubscription =
        _formDirective?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      if (_feedbackElement == null) {
        _scheduleSync();
      } else {
        _sync();
      }
    });
  }

  final html.Element _element;
  final NgControl _ngControl;
  final LiFormDirective? _formDirective;
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  StreamSubscription<bool>? _formSubmissionSubscription;
  html.HtmlElement? _feedbackElement;
  bool _formSubmitted = false;
  bool _scheduled = false;

  /// Enables or disables automatic visual feedback for this field.
  @Input()
  dynamic liValidationFeedback = true;

  /// Controls when visual state is shown: `always`, `touched`, `dirty`,
  /// `submitted`, `touchedOrDirty`, `submittedOrTouched`, or
  /// `submittedOrTouchedOrDirty`.
  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  /// Whether valid values should receive the `is-valid` class.
  @Input()
  dynamic liValidationShowValid = true;

  /// CSS selector used to find an existing feedback element near the control.
  @Input()
  String liValidationFeedbackSelector = '.invalid-feedback';

  /// Class added to the control when invalid.
  @Input()
  String liValidationInvalidClass = 'is-invalid';

  /// Class added to the control when valid and [liValidationShowValid] is true.
  @Input()
  String liValidationValidClass = 'is-valid';

  /// Fallback message when a validator did not provide one.
  @Input()
  String liValidationDefaultMessage = 'Campo invalido.';

  @override
  void ngAfterViewInit() {
    _feedbackElement = _resolveFeedbackElement();

    final control = _ngControl.control;
    if (control != null) {
      _subscriptions.add(control.valueChanges.listen((_) => _scheduleSync()));
      _subscriptions.add(control.statusChanges.listen((_) => _scheduleSync()));
    }

    _subscriptions
      ..add(_element.onBlur.listen((_) => _scheduleSync()))
      ..add(_element.onChange.listen((_) => _scheduleSync()))
      ..add(_element.onInput.listen((_) => _scheduleSync()))
      ..add(_element.onPaste.listen((_) => _scheduleSync()));

    _scheduleSync();
  }

  void _scheduleSync() {
    if (_scheduled) {
      return;
    }
    _scheduled = true;
    Timer.run(() {
      _scheduled = false;
      _sync();
    });
  }

  void _sync() {
    if (!_isEnabled(liValidationFeedback)) {
      _clearVisualState();
      return;
    }

    final control = _ngControl.control;
    if (control == null || control.disabled || !_shouldShow(control)) {
      _clearVisualState();
      return;
    }

    if (control.invalid) {
      _element.classes
        ..remove(liValidationValidClass)
        ..add(liValidationInvalidClass);
      _element.setAttribute('aria-invalid', 'true');
      _setFeedbackText(_messageFromErrors(control.errors));
      return;
    }

    _element.classes.remove(liValidationInvalidClass);
    _element.setAttribute('aria-invalid', 'false');
    _setFeedbackText('');

    if (_isEnabled(liValidationShowValid) && _hasRequiredValue(control.value)) {
      _element.classes.add(liValidationValidClass);
    } else {
      _element.classes.remove(liValidationValidClass);
    }
  }

  bool _shouldShow(AbstractControl control) {
    final mode = liValidationMode.trim().toLowerCase();
    final submitted = _formSubmitted || (_formDirective?.submitted ?? false);
    return switch (mode) {
      'always' => true,
      'submitted' => submitted,
      'touched' => control.touched,
      'dirty' => control.dirty,
      'submittedortouched' => submitted || control.touched,
      'submittedortouchedordirty' =>
        submitted || control.touched || control.dirty,
      _ => control.touched || control.dirty,
    };
  }

  String _messageFromErrors(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) {
      return '';
    }

    for (final value in errors.values) {
      if (value is Map) {
        final message = value['message']?.toString().trim() ?? '';
        if (message.isNotEmpty) {
          return message;
        }
      }
    }

    if (errors.containsKey('required')) {
      return 'Campo obrigatorio.';
    }
    return liValidationDefaultMessage;
  }

  html.HtmlElement? _resolveFeedbackElement() {
    final selector = liValidationFeedbackSelector.trim();
    final parent = _element.parent;
    if (parent == null) {
      return null;
    }

    if (selector.isNotEmpty) {
      final existing = parent.querySelector(selector);
      if (existing is html.HtmlElement) {
        return existing;
      }
    }

    final created = html.DivElement()
      ..classes.add('invalid-feedback')
      ..setAttribute('data-li-validation-feedback', 'true');
    parent.append(created);
    return created;
  }

  void _setFeedbackText(String message) {
    final feedbackElement = _feedbackElement;
    if (feedbackElement == null) {
      return;
    }
    feedbackElement.text = message;
  }

  void _clearVisualState() {
    _element.classes
      ..remove(liValidationInvalidClass)
      ..remove(liValidationValidClass);
    _element.attributes.remove('aria-invalid');
    _setFeedbackText('');
  }

  @override
  void ngOnDestroy() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _formSubmissionSubscription?.cancel();
  }
}

bool _isEnabled(dynamic value) {
  if (value is bool) {
    return value;
  }
  return EssentialCoreUtils.parseBoolLoose(value) ?? true;
}

bool _hasRequiredValue(dynamic value) {
  if (value == null) {
    return false;
  }
  if (value is String) {
    return value.trim().isNotEmpty;
  }
  if (value is Iterable) {
    return value.isNotEmpty;
  }
  if (value is Map) {
    return value.isNotEmpty;
  }
  return true;
}
