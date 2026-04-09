import 'li_rule.dart';

abstract class LiInputType {
  const LiInputType();

  String? get htmlType;
  String? get mask;
  String? get inputMode;
  int? get maxLength;
  int? get minLength;
  String? get autocomplete;
  String? get placeholder;
  List<LiRule> get rules;
  Map<String, String> get messages;

  dynamic normalize(dynamic value) => value;
}