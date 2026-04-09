import 'li_input_type.dart';
import 'li_rule.dart';

typedef LiInputNormalizer = dynamic Function(dynamic value);

class LiPresetInputType implements LiInputType {
  const LiPresetInputType({
    this.htmlType,
    this.mask,
    this.inputMode,
    this.maxLength,
    this.minLength,
    this.autocomplete,
    this.placeholder,
    this.rules = const <LiRule>[],
    this.messages = const <String, String>{},
    this.normalizer,
  });

  @override
  final String? htmlType;

  @override
  final String? mask;

  @override
  final String? inputMode;

  @override
  final int? maxLength;

  @override
  final int? minLength;

  @override
  final String? autocomplete;

  @override
  final String? placeholder;

  @override
  final List<LiRule> rules;

  @override
  final Map<String, String> messages;

  final LiInputNormalizer? normalizer;

  @override
  dynamic normalize(dynamic value) {
    final resolver = normalizer;
    return resolver == null ? value : resolver(value);
  }
}