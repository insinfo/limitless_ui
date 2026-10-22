import 'li_number_parsing.dart';
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
  const factory LiRule.pattern(String pattern, [String? message]) =
      LiPatternRule;

  /// Fails when the value is a number lower than [min].
  ///
  /// Reads `num` values directly and strings as numbers (machine format
  /// first, then the format of the rule context locale). Empty values pass:
  /// combine with [LiRule.required] when the field is mandatory.
  const factory LiRule.min(num min, [String? message]) = LiMinRule;

  /// Fails when the value is a number greater than [max].
  ///
  /// Same reading as [LiRule.min]. Empty values pass.
  const factory LiRule.max(num max, [String? message]) = LiMaxRule;

  /// Fails when the value is not a whole number.
  ///
  /// `3` and `3.0` pass, `3.5` and text that is not a number fail. Empty
  /// values pass.
  const factory LiRule.integer([String? message]) = LiIntegerRule;

  /// Fails when fewer than [min] items are selected.
  ///
  /// Counts the items of an `Iterable` or `Map` value, such as the selection
  /// of `li-checkbox-group` or `li-multi-select`. An empty selection passes:
  /// combine with [LiRule.required], which on a group means "at least one".
  const factory LiRule.minSelected(int min, [String? message]) =
      LiMinSelectedRule;

  /// Fails when more than [max] items are selected.
  ///
  /// Same counting as [LiRule.minSelected].
  const factory LiRule.maxSelected(int max, [String? message]) =
      LiMaxSelectedRule;
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
      context.isEnglishLocale
          ? 'This field is required.'
          : 'Campo obrigatorio.',
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

class LiMinRule extends _LiBaseRule {
  const LiMinRule(this.min, [super.message]);

  final num min;

  @override
  String get code => 'min';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final number = liParseNumber(value, locale: context.locale);
    if (number == null || number >= min) {
      return null;
    }

    final bound = _formatBound(min, context);
    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Enter a value greater than or equal to $bound.'
          : 'Informe um valor maior ou igual a $bound.',
    );
  }
}

class LiMaxRule extends _LiBaseRule {
  const LiMaxRule(this.max, [super.message]);

  final num max;

  @override
  String get code => 'max';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final number = liParseNumber(value, locale: context.locale);
    if (number == null || number <= max) {
      return null;
    }

    final bound = _formatBound(max, context);
    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Enter a value less than or equal to $bound.'
          : 'Informe um valor menor ou igual a $bound.',
    );
  }
}

class LiIntegerRule extends _LiBaseRule {
  const LiIntegerRule([super.message]);

  @override
  String get code => 'integer';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return null;
    }

    final number = liParseNumber(value, locale: context.locale);
    if (number != null && number == number.truncateToDouble()) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Enter a whole number.'
          : 'Informe um número inteiro.',
    );
  }
}

class LiMinSelectedRule extends _LiBaseRule {
  const LiMinSelectedRule(this.min, [super.message]);

  final int min;

  @override
  String get code => 'minSelected';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final count = _selectionCount(value);
    if (count == 0 || count >= min) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Select at least $min ${min == 1 ? 'option' : 'options'}.'
          : 'Selecione pelo menos $min ${min == 1 ? 'opção' : 'opções'}.',
    );
  }
}

class LiMaxSelectedRule extends _LiBaseRule {
  const LiMaxSelectedRule(this.max, [super.message]);

  final int max;

  @override
  String get code => 'maxSelected';

  @override
  String? validate(dynamic value, LiRuleContext context) {
    final count = _selectionCount(value);
    if (count <= max) {
      return null;
    }

    return resolveMessage(
      context,
      context.isEnglishLocale
          ? 'Select no more than $max ${max == 1 ? 'option' : 'options'}.'
          : 'Selecione no máximo $max ${max == 1 ? 'opção' : 'opções'}.',
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

int _selectionCount(dynamic value) {
  if (value == null) {
    return 0;
  }
  if (value is Iterable) {
    return value.length;
  }
  if (value is Map) {
    return value.length;
  }
  if (value is String) {
    return value.trim().isEmpty ? 0 : 1;
  }
  return 1;
}

String _formatBound(num bound, LiRuleContext context) {
  return liFormatNumber(
    bound,
    decimalSeparator: liDecimalSeparator(context.locale),
  );
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
