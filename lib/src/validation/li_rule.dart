import 'li_rule_context.dart';

abstract class LiRule {
  const LiRule();

  String get code;

  String? validate(dynamic value, LiRuleContext context);

  const factory LiRule.required([String? message]) = LiRequiredRule;
  const factory LiRule.requiredTrue([String? message]) = LiRequiredTrueRule;
  const factory LiRule.minLength(int min, [String? message]) = LiMinLengthRule;
  const factory LiRule.maxLength(int max, [String? message]) = LiMaxLengthRule;
  const factory LiRule.email([String? message]) = LiEmailRule;
  const factory LiRule.cpf([String? message]) = LiCpfRule;
  const factory LiRule.cnpj([String? message]) = LiCnpjRule;
  const factory LiRule.cpfOrCnpj([String? message]) = LiCpfOrCnpjRule;
  const factory LiRule.onlyNumbers([String? message]) = LiOnlyNumbersRule;
  const factory LiRule.pattern(String pattern, [String? message]) = LiPatternRule;
  factory LiRule.custom(
    String? Function(dynamic value) fn, {
    String? code,
  }) {
    return LiCustomRule(fn, customCode: code ?? 'custom');
  }
}

abstract class _LiBaseRule implements LiRule {
  const _LiBaseRule(this.message);

  final String? message;

  String resolveMessage(LiRuleContext context, String fallback) {
    final explicitMessage = message?.trim() ?? '';
    if (explicitMessage.isNotEmpty) {
      return explicitMessage;
    }

    final contextualMessage = context.messages[code]?.trim() ?? '';
    if (contextualMessage.isNotEmpty) {
      return contextualMessage;
    }

    return fallback;
  }
}

class LiRequiredRule extends _LiBaseRule {
  const LiRequiredRule([super.message]);

  @override
  String get code => 'required';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    if (_hasRequiredValue(value)) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale ? 'This field is required.' : 'Campo obrigatorio.',
    );
  }
}

class LiRequiredTrueRule extends _LiBaseRule {
  const LiRequiredTrueRule([super.message]);

  @override
  String get code => 'requiredTrue';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    if (value == true) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'You need to accept this field.'
          : 'Voce precisa aceitar este campo.',
    );
  }
}

class LiMinLengthRule extends _LiBaseRule {
  const LiMinLengthRule(this.min, [super.message]);

  final int min;

  @override
  String get code => 'minLength';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final length = _valueLength(value);
    if (length == null || length == 0 || length >= min) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Enter at least $min characters.'
          : 'Informe pelo menos $min caracteres.',
    );
  }
}

class LiMaxLengthRule extends _LiBaseRule {
  const LiMaxLengthRule(this.max, [super.message]);

  final int max;

  @override
  String get code => 'maxLength';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final length = _valueLength(value);
    if (length == null || length <= max) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Enter no more than $max characters.'
          : 'Informe no maximo $max caracteres.',
    );
  }
}

class LiEmailRule extends _LiBaseRule {
  const LiEmailRule([super.message]);

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  String get code => 'email';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final normalized = _stringValue(value).trim();
    if (normalized.isEmpty || _emailPattern.hasMatch(normalized)) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Enter a valid email address.'
          : 'Digite um e-mail valido.',
    );
  }
}

class LiCpfRule extends _LiBaseRule {
  const LiCpfRule([super.message]);

  @override
  String get code => 'cpf';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final digits = _digitsOnly(value);
    if (digits.isEmpty || _isValidCpf(digits)) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale ? 'Enter a valid CPF.' : 'Digite um CPF valido.',
    );
  }
}

class LiCnpjRule extends _LiBaseRule {
  const LiCnpjRule([super.message]);

  @override
  String get code => 'cnpj';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final digits = _digitsOnly(value);
    if (digits.isEmpty || _isValidCnpj(digits)) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Enter a valid CNPJ.'
          : 'Digite um CNPJ valido.',
    );
  }
}

class LiCpfOrCnpjRule extends _LiBaseRule {
  const LiCpfOrCnpjRule([super.message]);

  @override
  String get code => 'cpfOrCnpj';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final digits = _digitsOnly(value);
    if (digits.isEmpty) {
      return null;
    }

    final isValid = switch (digits.length) {
      11 => _isValidCpf(digits),
      14 => _isValidCnpj(digits),
      _ => false,
    };
    if (isValid) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Enter a valid CPF or CNPJ.'
          : 'Digite um CPF ou CNPJ valido.',
    );
  }
}

class LiOnlyNumbersRule extends _LiBaseRule {
  const LiOnlyNumbersRule([super.message]);

  static final RegExp _onlyNumbersPattern = RegExp(r'^\d+$');

  @override
  String get code => 'onlyNumbers';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final normalized = _stringValue(value).trim();
    if (normalized.isEmpty || _onlyNumbersPattern.hasMatch(normalized)) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale ? 'Use numbers only.' : 'Use apenas numeros.',
    );
  }
}

class LiPatternRule extends _LiBaseRule {
  const LiPatternRule(this.pattern, [super.message]);

  final String pattern;

  @override
  String get code => 'pattern';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final normalized = _stringValue(value);
    if (normalized.trim().isEmpty) {
      return null;
    }

    if (RegExp(pattern).hasMatch(normalized)) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Value does not match the expected format.'
          : 'O valor nao corresponde ao formato esperado.',
    );
  }
}

class LiCustomRule implements LiRule {
  LiCustomRule(
    this._validator, {
    this.customCode = 'custom',
  });

  final String? Function(dynamic value) _validator;
  final String customCode;

  @override
  String get code => customCode;

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final result = _validator(value)?.trim() ?? '';
    return result.isEmpty ? null : result;
  }
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

int? _valueLength(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is String) {
    return value.trim().length;
  }

  if (value is Iterable) {
    return value.length;
  }

  if (value is Map) {
    return value.length;
  }

  return value.toString().trim().length;
}

String _stringValue(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

String _digitsOnly(dynamic value) {
  return _stringValue(value).replaceAll(RegExp(r'\D'), '');
}

bool _isValidCpf(String value) {
  if (value.length != 11) {
    return false;
  }
  if (RegExp(r'^(\d)\1{10}$').hasMatch(value)) {
    return false;
  }

  int calculateDigit(String source, int factor) {
    var total = 0;
    for (var i = 0; i < source.length; i++) {
      total += int.parse(source[i]) * factor--;
    }
    final remainder = total % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  final firstDigit = calculateDigit(value.substring(0, 9), 10);
  final secondDigit = calculateDigit('${value.substring(0, 9)}$firstDigit', 11);
  return value == '${value.substring(0, 9)}$firstDigit$secondDigit';
}

bool _isValidCnpj(String value) {
  if (value.length != 14) {
    return false;
  }
  if (RegExp(r'^(\d)\1{13}$').hasMatch(value)) {
    return false;
  }

  int calculateDigit(String source, List<int> weights) {
    var total = 0;
    for (var i = 0; i < source.length; i++) {
      total += int.parse(source[i]) * weights[i];
    }
    final remainder = total % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  final firstDigit = calculateDigit(
    value.substring(0, 12),
    const <int>[5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2],
  );
  final secondDigit = calculateDigit(
    '${value.substring(0, 12)}$firstDigit',
    const <int>[6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2],
  );
  return value == '${value.substring(0, 12)}$firstDigit$secondDigit';
}