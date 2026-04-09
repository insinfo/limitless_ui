import 'li_input_type.dart';
import 'li_preset_input_type.dart';
import 'li_rule.dart';

abstract final class LiBuiltInInputTypes {
  static final Map<String, LiInputType> registry = <String, LiInputType>{
    'cpf': LiPresetInputType(
      htmlType: 'text',
      mask: 'xxx.xxx.xxx-xx',
      inputMode: 'numeric',
      maxLength: 14,
      autocomplete: 'off',
      normalizer: _digitsOnly,
      rules: const <LiRule>[
        LiRule.required(),
        LiRule.cpf(),
      ],
    ),
    'cnpj': LiPresetInputType(
      htmlType: 'text',
      mask: 'xx.xxx.xxx/xxxx-xx',
      inputMode: 'numeric',
      maxLength: 18,
      autocomplete: 'off',
      normalizer: _digitsOnly,
      rules: const <LiRule>[
        LiRule.required(),
        LiRule.cnpj(),
      ],
    ),
    'cpforcnpj': LiPresetInputType(
      htmlType: 'text',
      inputMode: 'numeric',
      maxLength: 18,
      autocomplete: 'off',
      normalizer: _digitsOnly,
      rules: const <LiRule>[
        LiRule.required(),
        LiRule.cpfOrCnpj(),
      ],
    ),
    'email': LiPresetInputType(
      htmlType: 'email',
      inputMode: 'email',
      autocomplete: 'email',
      rules: const <LiRule>[
        LiRule.required(),
        LiRule.email(),
      ],
    ),
    'phone': LiPresetInputType(
      htmlType: 'tel',
      inputMode: 'tel',
      mask: '(xx) xxxxx-xxxx',
      maxLength: 15,
      normalizer: _digitsOnly,
      rules: const <LiRule>[
        LiRule.required(),
        LiRule.minLength(10),
        LiRule.maxLength(11),
      ],
    ),
    'textmin3': LiPresetInputType(
      htmlType: 'text',
      minLength: 3,
      rules: const <LiRule>[
        LiRule.required(),
        LiRule.minLength(3),
      ],
    ),
    'requiredtext': LiPresetInputType(
      htmlType: 'text',
      rules: const <LiRule>[
        LiRule.required(),
      ],
    ),
    'onlynumbers': LiPresetInputType(
      htmlType: 'text',
      inputMode: 'numeric',
      rules: const <LiRule>[
        LiRule.required(),
        LiRule.onlyNumbers(),
      ],
    ),
  };

  static LiInputType? resolve(String? key) {
    final normalized = key?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return null;
    }

    return registry[normalized];
  }
}

String _digitsOnly(dynamic value) {
  return value?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
}