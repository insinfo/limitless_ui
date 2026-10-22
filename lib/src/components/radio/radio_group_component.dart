import 'package:ngdart/angular.dart';

import '../../directives/li_form_directive.dart';
import '../../validation/li_validated_field.dart';

@Component(
  selector: 'li-radio-group',
  templateUrl: 'radio_group_component.html',
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiRadioGroupComponent
    with LiValidatedField
    implements AfterChanges, OnDestroy {
  LiRadioGroupComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]);

  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  bool _hasTrackedValue = false;
  dynamic _lastValue;

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

  @override
  @Input()
  String locale = 'pt_BR';

  @Input()
  dynamic value;

  @Input()
  String legendClass = '';

  @Input()
  bool valid = false;

  @override
  dynamic get validationValue => value;

  @override
  String get externalErrorText => errorText;

  @override
  String? get validationFieldName =>
      legend.trim().isEmpty ? null : legend.trim();

  @override
  bool get externalValid => valid;

  @override
  void didChangeFormSubmission() {
    _markForCheck();
  }

  bool get hasLegend => legend.trim().isNotEmpty;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

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

  @override
  void ngAfterChanges() {
    connectValidationForm(_formDirective);
    rebuildValidationConfig();

    if (_hasTrackedValue && !_areValuesEqual(_lastValue, value)) {
      validationDirty = true;
    }
    _hasTrackedValue = true;
    _lastValue = value;

    if (shouldRevalidate) {
      runValidation();
    }
    _markForCheck();
  }

  @HostListener('focusout')
  void handleFocusOut() {
    validationTouched = true;
    runValidation();
    _markForCheck();
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  bool _areValuesEqual(dynamic left, dynamic right) => left == right;

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  @override
  void ngOnDestroy() {
    disconnectValidationForm();
  }
}
