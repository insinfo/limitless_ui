import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

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
