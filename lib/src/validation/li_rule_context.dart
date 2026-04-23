import 'package:ngforms/ngforms.dart';

class LiRuleContext {
  const LiRuleContext({
    this.fieldName,
    this.control,
    this.inputType,
    this.messages = const <String, String>{},
    this.locale = 'pt_BR',
  });

  final String? fieldName;
  final AbstractControl<dynamic>? control;
  final Object? inputType;
  final Map<String, String> messages;
  final String locale;

  bool get isEnglishLocale => locale.trim().toLowerCase().startsWith('en');
}
