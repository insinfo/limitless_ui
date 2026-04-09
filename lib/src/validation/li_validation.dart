import 'li_rule.dart';
import 'li_rule_context.dart';
import 'li_validation_issue.dart';

LiValidationIssue? liValidateValue({
  required dynamic value,
  required Iterable<LiRule> rules,
  required LiRuleContext context,
}) {
  for (final rule in rules) {
    final validationMessage = rule.validate(value, context)?.trim() ?? '';
    if (validationMessage.isEmpty) {
      continue;
    }

    return LiValidationIssue(code: rule.code, message: validationMessage);
  }

  return null;
}

bool liShouldShowValidation({
  required String mode,
  required bool touched,
  required bool dirty,
  required bool submitted,
}) {
  switch (_normalizeValidationMode(mode)) {
    case 'never':
      return false;
    case 'dirty':
      return dirty;
    case 'touched':
      return touched;
    case 'submitted':
      return submitted;
    case 'submittedortouchedordirty':
    case 'submittedordirtyortouched':
      return submitted || touched || dirty;
    case 'submittedortouched':
      return submitted || touched;
    case 'touchedordirty':
    default:
      return touched || dirty;
  }
}

String _normalizeValidationMode(String value) {
  return value.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
}