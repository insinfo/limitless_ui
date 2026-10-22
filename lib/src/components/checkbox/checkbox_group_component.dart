import 'package:ngdart/angular.dart';

import '../../directives/li_form_directive.dart';
import '../../validation/li_validated_field.dart';
import 'checkbox_component.dart';

/// Groups `li-checkbox` controls under one legend, one error and one set of
/// declarative rules.
///
/// The value the rules see is the selection of the group:
///
/// - when `[value]` is bound, that value as given — usually the list the
///   page keeps of the selected ids;
/// - otherwise, a list with the `trueValue` of every projected `li-checkbox`
///   that is checked, so a group of boolean fields validates without any
///   extra state on the page.
///
/// `LiRule.required()` therefore means "at least one checked", and
/// `LiRule.minSelected(n)`/`LiRule.maxSelected(n)` bound the count.
@Component(
  selector: 'li-checkbox-group',
  templateUrl: 'checkbox_group_component.html',
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
  // The projected checkboxes find the group through DI. `Visibility.all`
  // keeps that working when they come from an `*ngFor` or a child component.
  visibility: Visibility.all,
)
class LiCheckboxGroupComponent
    with LiValidatedField
    implements AfterChanges, OnDestroy {
  LiCheckboxGroupComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]);

  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  final List<LiCheckboxComponent> _checkboxes = <LiCheckboxComponent>[];
  bool _hasTrackedValue = false;
  bool _hasExplicitValue = false;
  dynamic _explicitValue;
  dynamic _lastValue;

  @Input()
  String legend = '';

  @Input()
  String helperText = '';

  /// External error message, typically from the backend.
  ///
  /// Wins over the message of the automatic validation.
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

  /// Locale of the default rule messages.
  @override
  @Input()
  String locale = 'pt_BR';

  @Input()
  bool valid = false;

  /// Selection validated by the rules.
  ///
  /// Optional. When bound — even to `null` — it replaces the selection read
  /// from the projected checkboxes. Bind it when the page keeps the selection
  /// as a collection of its own, such as a list of ids.
  @Input()
  set value(dynamic value) {
    _hasExplicitValue = true;
    _explicitValue = value;
  }

  dynamic get value => _hasExplicitValue ? _explicitValue : _checkedValues();

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

    if (_hasExplicitValue) {
      if (_hasTrackedValue && !_areValuesEqual(_lastValue, _explicitValue)) {
        validationDirty = true;
      }
      _hasTrackedValue = true;
      _lastValue = _explicitValue is Iterable
          ? List<dynamic>.of(_explicitValue as Iterable)
          : _explicitValue;
    }

    runValidation();
    _markForCheck();
  }

  @HostListener('focusout')
  void handleFocusOut() {
    validationTouched = true;
    runValidation();
    _markForCheck();
  }

  /// Called by a projected `li-checkbox` when it is created.
  ///
  /// Part of the contract between the two components, not meant to be called
  /// by applications.
  void registerCheckbox(LiCheckboxComponent checkbox) {
    if (_checkboxes.contains(checkbox)) {
      return;
    }
    _checkboxes.add(checkbox);
    runValidation();
    _markForCheck();
  }

  /// Called by a projected `li-checkbox` when it is destroyed.
  void unregisterCheckbox(LiCheckboxComponent checkbox) {
    if (!_checkboxes.remove(checkbox)) {
      return;
    }
    runValidation();
    _markForCheck();
  }

  /// Called by a projected `li-checkbox` whenever its checked state changes.
  ///
  /// [userInteraction] is `true` for a click and `false` for a value written
  /// by the form model; only the first marks the group as dirty.
  void handleCheckboxChange({required bool userInteraction}) {
    if (userInteraction) {
      validationDirty = true;
    }
    if (shouldRevalidate) {
      runValidation();
    }
    _markForCheck();
  }

  List<dynamic> _checkedValues() => _checkboxes
      .where((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.trueValue)
      .toList(growable: false);

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  bool _areValuesEqual(dynamic left, dynamic right) {
    if (left is Iterable && right is Iterable) {
      final leftList = left.toList(growable: false);
      final rightList = right.toList(growable: false);
      if (leftList.length != rightList.length) {
        return false;
      }
      for (var i = 0; i < leftList.length; i++) {
        if (leftList[i] != rightList[i]) {
          return false;
        }
      }
      return true;
    }
    return left == right;
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  @override
  void ngOnDestroy() {
    disconnectValidationForm();
    _checkboxes.clear();
  }
}
