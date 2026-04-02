import 'package:ngdart/angular.dart';

@Component(
  selector: 'li-checkbox-group',
  templateUrl: 'checkbox_group_component.html',
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiCheckboxGroupComponent {
  @Input()
  String legend = '';

  @Input()
  String helperText = '';

  @Input()
  String errorText = '';

  @Input()
  String feedbackClass = '';

  @Input()
  String describedBy = '';

  @Input()
  String containerClass = '';

  @Input()
  String legendClass = '';

  @Input()
  bool invalid = false;

  @Input()
  bool valid = false;

  @Input()
  bool dataInvalid = false;

  bool get hasLegend => legend.trim().isNotEmpty;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  bool get showErrorFeedback => errorText.trim().isNotEmpty && effectiveInvalid;

  bool get effectiveInvalid => invalid || dataInvalid;

  bool get effectiveValid => !effectiveInvalid && valid;

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String? get resolvedAriaInvalid => effectiveInvalid ? 'true' : null;

  String? get resolvedDataInvalidAttr => effectiveInvalid ? 'true' : null;

  String get resolvedContainerClass => _joinClasses(<String>[
        'li-selection-group',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
        containerClass,
      ]);

  String get resolvedLegendClass => _joinClasses(<String>[
        'li-selection-group__legend',
        legendClass,
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }
}
