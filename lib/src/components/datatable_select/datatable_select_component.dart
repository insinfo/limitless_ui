import 'dart:async';
import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import '../../directives/li_form_directive.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';
import '../datatable/datatable_col.dart';
import '../datatable/datatable_component.dart';
import '../datatable/datatable_settings.dart';
import '../modal_component/modal_component.dart';

class LiDatatableSelectTriggerContext {
  LiDatatableSelectTriggerContext({
    required this.selectedValue,
    required this.selectedValues,
    required this.selectedLabel,
    required this.selectedLabels,
    required this.multiple,
    required this.placeholder,
    required this.hasSelection,
    required this.disabled,
    required this.open,
    required this.clear,
  });

  final dynamic selectedValue;
  final List<dynamic> selectedValues;
  final String selectedLabel;
  final List<String> selectedLabels;
  final bool multiple;
  final String placeholder;
  final bool hasSelection;
  final bool disabled;
  final void Function() open;
  final void Function() clear;
}

class LiDatatableSelectModalContext {
  LiDatatableSelectModalContext({
    required this.data,
    required this.dataTableFilter,
    required this.settings,
    required this.searchInFields,
    required this.multiple,
    required this.selectedValue,
    required this.selectedLabel,
    required this.selectedValues,
    required this.selectedLabels,
    required this.select,
    required this.selectItem,
    required this.clear,
    required this.apply,
    required this.close,
    required this.requestData,
  });

  final DataFrame data;
  final Filters dataTableFilter;
  final DatatableSettings settings;
  final List<DatatableSearchField> searchInFields;
  final bool multiple;
  final dynamic selectedValue;
  final String selectedLabel;
  final List<dynamic> selectedValues;
  final List<String> selectedLabels;
  final void Function(dynamic instance) select;
  final void Function(String label, dynamic value) selectItem;
  final void Function() clear;
  final void Function() apply;
  final void Function() close;
  final void Function(Filters filters) requestData;
}

@Directive(selector: 'template[liDatatableSelectTrigger]')
class LiDatatableSelectTriggerDirective {
  LiDatatableSelectTriggerDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liDatatableSelectModalContent]')
class LiDatatableSelectModalContentDirective {
  LiDatatableSelectModalContentDirective(this.templateRef);

  final TemplateRef templateRef;
}

/// A select-like input that opens a modal with a full [LiDataTableComponent]
/// for searching, sorting, and paginating through large data sets.
///
/// Clicking a row selects the entity, closes the modal, and displays the
/// selected label in the trigger button.
///
/// Implements [ControlValueAccessor] so it can be used with `[(ngModel)]`.
///
/// Example:
/// ```html
/// <li-datatable-select
///     [settings]="datatableSettings"
///     [dataTableFilter]="filter"
///     [data]="dataFrame"
///     [searchInFields]="searchFields"
///     [labelKey]="'nome'"
///     [valueKey]="'id'"
///     (dataRequest)="loadData($event)"
///     [(ngModel)]="selectedId">
/// </li-datatable-select>
/// ```
@Component(
  selector: 'li-datatable-select',
  templateUrl: 'datatable_select_component.html',
  styleUrls: ['datatable_select_component.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiDataTableComponent,
    LiModalComponent,
    LiDatatableSelectTriggerDirective,
    LiDatatableSelectModalContentDirective,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiDatatableSelectComponent),
  ],
)
class LiDatatableSelectComponent
    implements ControlValueAccessor<dynamic>, AfterChanges, OnDestroy {
  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;

  LiDatatableSelectComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]) {
    _formSubmitted = _formDirective?.submitted ?? false;
    _formSubmissionSubscription =
        _formDirective?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      _runAutoValidation();
      _changeDetectorRef.markForCheck();
    });
  }

  // ---------------------------------------------------------------------------
  // ControlValueAccessor
  // ---------------------------------------------------------------------------

  dynamic Function(dynamic, {String rawValue})? _onChange;
  TouchFunction _onTouched = () {};
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _autoValidationIssue;
  StreamSubscription<bool>? _formSubmissionSubscription;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};

  @override
  void writeValue(dynamic newVal) {
    if (newVal == _selectedValue) return;
    _selectedValue = newVal;
    _syncLabelFromValue();
    _runAutoValidation();
    _changeDetectorRef.markForCheck();
  }

  @override
  void registerOnChange(callback) {
    _onChange = callback;
  }

  @override
  void registerOnTouched(TouchFunction callback) {
    _onTouched = callback;
  }

  @override
  void onDisabledChanged(bool state) {
    isDisabled = state;
    _changeDetectorRef.markForCheck();
  }

  // ---------------------------------------------------------------------------
  // Inputs
  // ---------------------------------------------------------------------------

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  bool invalid = false;

  @Input()
  bool valid = false;

  @Input()
  bool dataInvalid = false;

  @Input()
  String errorText = '';

  @Input()
  String helperText = '';

  @Input()
  String feedbackClass = '';

  @Input()
  String describedBy = '';

  @Input()
  String locale = 'pt_BR';

  @Input()
  List<LiRule> liRules = const <LiRule>[];

  @Input()
  Map<String, String> liMessages = const <String, String>{};

  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  @Input()
  bool validateOnInput = true;

  /// The key used to extract the display label from each data row map.
  @Input()
  String labelKey = 'label';

  /// The key used to extract the value from each data row map.
  /// When `null`, the entire row instance is used as the value.
  @Input()
  String? valueKey;

  /// Optional custom extractor for labels when rows are typed objects instead
  /// of maps or when the selected content comes from an arbitrary component.
  @Input()
  String Function(dynamic instance)? itemLabelBuilder;

  /// Optional custom extractor for values when rows are typed objects instead
  /// of maps or when the selected content comes from an arbitrary component.
  @Input()
  dynamic Function(dynamic instance)? itemValueBuilder;

  /// Optional value comparer used to keep the trigger label synchronized when
  /// the selected value is an object rebuilt outside the component.
  @Input()
  bool Function(dynamic itemValue, dynamic selectedValue)? compareWith;

  @Input()
  String placeholder = '';

  /// Modal title text.
  @Input('title')
  String titleText = '';

  /// Modal size. See [LiModalComponent.size].
  @Input()
  String modalSize = 'large';

  /// When `true`, the modal occupies the full screen on mobile devices.
  @Input()
  bool fullScreenOnMobile = true;

  @Input()
  bool modalCompactHeader = false;

  @Input()
  bool modalSmallHeader = false;

  // -- Datatable pass-through inputs --

  @Input()
  Filters dataTableFilter = Filters();

  @Input()
  DatatableSettings settings =
      DatatableSettings(colsDefinitions: <DatatableCol>[]);

  @Input()
  DataFrame data = DataFrame(items: <dynamic>[], totalRecords: 0);

  @Input()
  List<DatatableSearchField> searchInFields = <DatatableSearchField>[];

  @Input()
  List<int> limitPerPageOptions = [5, 10, 12, 20, 25];

  @Input()
  bool showCheckboxToSelectRow = false;

  @Input()
  bool showExportMenu = false;

  @Input()
  String searchPlaceholder = '';

  @Input()
  String clearButtonLabel = '';

  @Input()
  bool showClearButton = true;

  @Input()
  bool multiple = false;

  @Input()
  String confirmButtonLabel = '';

  /// Supported values: `default`, `overlay`, `addon`, `hidden`.
  @Input()
  String triggerIconMode = 'default';

  @Input()
  String triggerIconClass = '';

  /// When `true`, the datatable is rendered in grid/card mode.
  @Input()
  bool gridMode = false;

  /// When `true`, responsible collapse is enabled in the datatable.
  @Input()
  bool responsiveCollapse = false;

  /// When `true`, changing items per page reloads data through
  /// the inner datatable `dataRequest` output.
  @Input()
  bool requestDataOnItemsPerPageChange = false;

  // ---------------------------------------------------------------------------
  // Outputs
  // ---------------------------------------------------------------------------

  final _valueChangeCtrl = StreamController<dynamic>();

  /// Emitted when the selected value changes.
  @Output('currentValueChange')
  Stream<dynamic> get onValueChange => _valueChangeCtrl.stream;

  final _dataRequestCtrl = StreamController<Filters>();

  /// Forwards the datatable's `dataRequest` event so the parent can load data.
  @Output()
  Stream<Filters> get dataRequest => _dataRequestCtrl.stream;

  final _limitChangeCtrl = StreamController<Filters>();

  @Output()
  Stream<Filters> get limitChange => _limitChangeCtrl.stream;

  final _searchRequestCtrl = StreamController<Filters>();

  @Output()
  Stream<Filters> get searchRequest => _searchRequestCtrl.stream;

  // ---------------------------------------------------------------------------
  // ViewChildren
  // ---------------------------------------------------------------------------

  @ViewChild('modal')
  LiModalComponent? modal;

  @ViewChild('datatable')
  LiDataTableComponent? datatable;

  @ViewChild('triggerButton')
  html.Element? triggerButtonElement;

  @ContentChild(LiDatatableSelectTriggerDirective)
  LiDatatableSelectTriggerDirective? triggerTemplate;

  @ContentChild(LiDatatableSelectModalContentDirective)
  LiDatatableSelectModalContentDirective? modalContentTemplate;

  @ContentChild(LiDatatableHeaderDirective)
  LiDatatableHeaderDirective? datatableHeaderTemplate;

  @ContentChild(LiDatatableFooterDirective)
  LiDatatableFooterDirective? datatableFooterTemplate;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  dynamic _selectedValue;
  String _selectedLabel = '';
  List<String> _selectedLabels = <String>[];
  List<dynamic> _pendingSelectedValues = <dynamic>[];
  List<String> _pendingSelectedLabels = <String>[];

  /// The value of the currently selected item.
  dynamic get selectedValue => multiple ? selectedValues : _selectedValue;

  List<dynamic> get selectedValues {
    if (_selectedValue is List) {
      return List<dynamic>.from(_selectedValue as List);
    }
    if (_selectedValue == null) {
      return <dynamic>[];
    }
    return <dynamic>[_selectedValue];
  }

  /// The display label of the currently selected item.
  String get selectedLabel {
    if (!multiple) {
      return _selectedLabel;
    }
    if (_selectedLabels.isEmpty) {
      return '';
    }
    if (_selectedLabels.length == 1) {
      return _selectedLabels.first;
    }
    if (_selectedLabels.length == 2) {
      return _selectedLabels.join(', ');
    }
    return '${_selectedLabels[0]}, ${_selectedLabels[1]} +${_selectedLabels.length - 2}';
  }

  List<String> get selectedLabels => List<String>.from(_selectedLabels);

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get hasSelection {
    if (multiple) {
      return selectedValues.isNotEmpty;
    }

    return _selectedValue != null;
  }

  bool get effectiveAutoInvalid =>
      _shouldShowValidation && _autoValidationIssue != null;

  bool get effectiveInvalid => invalid || dataInvalid || effectiveAutoInvalid;

  bool get effectiveValid =>
      !effectiveInvalid &&
      (valid ||
          (_shouldShowValidation &&
              _effectiveRules.isNotEmpty &&
              _autoValidationIssue == null));

  String get effectiveErrorText {
    final externalMessage = errorText.trim();
    if (externalMessage.isNotEmpty) {
      return externalMessage;
    }

    return _autoValidationIssue?.message ?? '';
  }

  bool get showErrorFeedback =>
      effectiveErrorText.trim().isNotEmpty && effectiveInvalid;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String get resolvedPlaceholder => placeholder.trim().isNotEmpty
      ? placeholder
      : (_isEnglishLocale ? 'Select' : 'Selecione');

  String get resolvedTitleText => titleText.trim().isNotEmpty
      ? titleText
      : (_isEnglishLocale ? 'Select item' : 'Selecionar');

  String get resolvedSearchPlaceholder => searchPlaceholder.trim().isNotEmpty
      ? searchPlaceholder
      : (_isEnglishLocale ? 'Type to search' : 'Digite para buscar');

  String get resolvedClearButtonLabel => clearButtonLabel.trim().isNotEmpty
      ? clearButtonLabel
      : (_isEnglishLocale ? 'Clear selection' : 'Limpar selecao');

  String get resolvedConfirmButtonLabel => confirmButtonLabel.trim().isNotEmpty
      ? confirmButtonLabel
      : 'OK';

  String get normalizedTriggerIconMode {
    switch (triggerIconMode.trim().toLowerCase()) {
      case 'overlay':
        return 'overlay';
      case 'addon':
        return 'addon';
      case 'hidden':
        return 'hidden';
      default:
        return 'default';
    }
  }

  bool get usesOverlayTriggerIcon => normalizedTriggerIconMode == 'overlay';

  bool get usesAddonTriggerIcon => normalizedTriggerIconMode == 'addon';

  bool get showsTriggerIcon =>
      normalizedTriggerIconMode == 'overlay' ||
      normalizedTriggerIconMode == 'addon';

  bool get showsClearButton => showClearButton && hasSelection;

  String get resolvedTriggerIconClass {
    final custom = triggerIconClass.trim();
    return custom.isNotEmpty ? custom : 'ph ph-caret-down';
  }

  String get resolvedTriggerClass => _joinClasses(<String>[
        'form-select',
        'datatable-select-trigger',
      usesAddonTriggerIcon ? 'datatable-select-trigger--with-addon-icon' : '',
        usesOverlayTriggerIcon ? 'datatable-select-trigger--with-overlay-icon' : '',
        showsClearButton ? 'datatable-select-trigger--with-clear' : '',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  LiDatatableSelectTriggerContext get triggerContext =>
      LiDatatableSelectTriggerContext(
        selectedValue: selectedValue,
        selectedValues: selectedValues,
        selectedLabel: selectedLabel,
        selectedLabels: selectedLabels,
        multiple: multiple,
        placeholder: resolvedPlaceholder,
        hasSelection: hasSelection,
        disabled: isDisabled,
        open: openModal,
        clear: clear,
      );

  LiDatatableSelectModalContext get modalContext =>
      LiDatatableSelectModalContext(
        data: data,
        dataTableFilter: dataTableFilter,
        settings: settings,
        searchInFields: searchInFields,
        multiple: multiple,
        selectedValue: selectedValue,
        selectedLabel: selectedLabel,
        selectedValues: selectedValues,
        selectedLabels: selectedLabels,
        select: onDatatableRowClick,
        selectItem: setSelectedItemFromTemplate,
        clear: clear,
        apply: applyModalSelection,
        close: closeModal,
        requestData: onDatatableDataRequest,
      );

  bool get hasPendingSelection => _pendingSelectedValues.isNotEmpty;

  bool get useCheckboxSelection => multiple || showCheckboxToSelectRow;

  @override
  void ngAfterChanges() {
    _syncLabelFromValue();
    _rebuildValidationConfig();
    if (multiple && modal?.isOpen == true) {
      _scheduleDatatableSelectionSync();
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void openModal() {
    if (isDisabled) return;
    if (multiple) {
      _syncPendingSelectionFromCommitted();
    }
    modal?.open();
    _markTouched();
    _changeDetectorRef.markForCheck();
    if (multiple) {
      _scheduleDatatableSelectionSync();
    }
  }

  void closeModal() {
    modal?.close();
    _markTouched();
    _changeDetectorRef.markForCheck();
  }

  void onModalClosed() {
    if (multiple && _hasPendingSelectionChanged()) {
      _commitPendingSelection();
    }

    _markTouched();
    _changeDetectorRef.markForCheck();
  }

  void onDatatableRowClick(dynamic instance) {
    if (multiple) {
      return;
    }
    _selectInstance(instance);
    closeModal();
    triggerButtonElement?.focus();
    _changeDetectorRef.markForCheck();
  }

  void onDatatableSelectionChange(List<dynamic> instances) {
    if (!multiple) {
      return;
    }

    final nextValues = <dynamic>[];
    final nextLabels = <String>[];

    for (var index = 0; index < _pendingSelectedValues.length; index++) {
      final pendingValue = _pendingSelectedValues[index];
      if (_isValuePresentInCurrentPage(pendingValue)) {
        continue;
      }

      nextValues.add(pendingValue);
      nextLabels.add(
        index < _pendingSelectedLabels.length ? _pendingSelectedLabels[index] : pendingValue.toString(),
      );
    }

    for (final instance in instances) {
      final value = _extractValue(instance);
      final label = _extractLabel(instance);
      final existingIndex = nextValues.indexWhere(
        (selected) => _areValuesEqual(selected, value),
      );

      if (existingIndex >= 0) {
        nextLabels[existingIndex] = label;
        continue;
      }

      nextValues.add(value);
      nextLabels.add(label);
    }

    _pendingSelectedValues = List<dynamic>.unmodifiable(nextValues);
    _pendingSelectedLabels = List<String>.unmodifiable(nextLabels);
    _changeDetectorRef.markForCheck();
  }

  void onDatatableDataRequest(Filters filters) {
    _dataRequestCtrl.add(filters);
  }

  void onDatatableLimitChange(Filters filters) {
    _limitChangeCtrl.add(filters);
  }

  void onDatatableSearchRequest(Filters filters) {
    _searchRequestCtrl.add(filters);
  }

  /// Clears the current selection.
  void clear() {
    _selectedValue = multiple ? <dynamic>[] : null;
    _selectedLabel = '';
    _selectedLabels = <String>[];
    _pendingSelectedValues = <dynamic>[];
    _pendingSelectedLabels = <String>[];
    _dirty = true;
    _valueChangeCtrl.add(selectedValue);
    _onChange?.call(selectedValue);
    _markTouched();
    _changeDetectorRef.markForCheck();
  }

  void clearModalSelection() {
    if (!multiple) {
      clear();
      return;
    }

    _pendingSelectedValues = <dynamic>[];
    _pendingSelectedLabels = <String>[];
    datatable?.unSelectAll();
    _changeDetectorRef.markForCheck();
  }

  void applyModalSelection() {
    if (!multiple) {
      closeModal();
      return;
    }

    _commitPendingSelection();
    closeModal();
    triggerButtonElement?.focus();
    _changeDetectorRef.markForCheck();
  }

  /// Handles the clear icon click, preventing the event from reaching the
  /// trigger button (which would re-open the modal).
  void onClearClick(html.MouseEvent event) {
    event.stopPropagation();
    clear();
  }

  /// Programmatically sets the selected value, updating the display label.
  void setSelectedValue(dynamic value) {
    _selectedValue = multiple
        ? (value == null
            ? <dynamic>[]
            : (value is List ? List<dynamic>.from(value) : <dynamic>[value]))
        : value;
    _syncLabelFromValue();
    _dirty = true;
    _valueChangeCtrl.add(_selectedValue);
    _onChange?.call(_selectedValue);
    _markTouched();
    _changeDetectorRef.markForCheck();
  }

  /// Programmatically sets both label and value without needing data loaded.
  void setSelectedItem({required String label, required dynamic value}) {
    _selectedValue = multiple ? <dynamic>[value] : value;
    _selectedLabel = label;
    _selectedLabels = label.isEmpty ? <String>[] : <String>[label];
    _dirty = true;
    _valueChangeCtrl.add(selectedValue);
    _onChange?.call(selectedValue);
    _markTouched();
    _changeDetectorRef.markForCheck();
  }

  void setSelectedItemFromTemplate(String label, dynamic value) {
    setSelectedItem(label: label, value: value);
    closeModal();
    triggerButtonElement?.focus();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _selectInstance(dynamic instance) {
    if (instance == null) return;

    _selectedValue = _extractValue(instance);
    _selectedLabel = _extractLabel(instance);
    _selectedLabels = _selectedLabel.isEmpty ? <String>[] : <String>[_selectedLabel];

    _dirty = true;
    _valueChangeCtrl.add(_selectedValue);
    _onChange?.call(_selectedValue);
    _markTouched();
  }

  void _syncLabelFromValue() {
    if (multiple) {
      final values = selectedValues;
      if (values.isEmpty) {
        _selectedLabels = <String>[];
        _selectedLabel = '';
        return;
      }

      final nextLabels = <String>[];
      for (final selected in values) {
        String? resolvedLabel;
        for (final item in data.items) {
          final map = _tryMap(item);
          final itemValue = _extractValue(item, fallbackMap: map);
          if (_areValuesEqual(itemValue, selected)) {
            resolvedLabel = _extractLabel(item, fallbackMap: map);
            break;
          }
        }
        nextLabels.add(resolvedLabel ?? selected.toString());
      }
      _selectedLabels = nextLabels;
      _selectedLabel = '';
      return;
    }

    if (_selectedValue == null) {
      _selectedLabel = '';
      _selectedLabels = <String>[];
      return;
    }

    // Try to find the label from currently loaded data.
    for (final item in data.items) {
      final map = _tryMap(item);
      final itemValue = _extractValue(item, fallbackMap: map);
      if (_areValuesEqual(itemValue, _selectedValue)) {
        _selectedLabel = _extractLabel(item, fallbackMap: map);
        _selectedLabels =
            _selectedLabel.isEmpty ? <String>[] : <String>[_selectedLabel];
        return;
      }
    }

    // Data not loaded yet — keep existing label or show value as fallback.
    if (_selectedLabel.isEmpty) {
      _selectedLabel = _selectedValue.toString();
    }
    _selectedLabels =
        _selectedLabel.isEmpty ? <String>[] : <String>[_selectedLabel];
  }

  @override
  void ngOnDestroy() {
    _formSubmissionSubscription?.cancel();
    _valueChangeCtrl.close();
    _dataRequestCtrl.close();
    _limitChangeCtrl.close();
    _searchRequestCtrl.close();
  }

  void _markTouched() {
    if (_touched) {
      _onTouched();
      _runAutoValidation();
      return;
    }
    _touched = true;
    _onTouched();
    _runAutoValidation();
  }

  void _rebuildValidationConfig() {
    _effectiveRules = List<LiRule>.unmodifiable(<LiRule>[
      ...liRules,
    ]);
    _effectiveMessages = Map<String, String>.unmodifiable(<String, String>{
      ...liMessages,
    });
    _runAutoValidation();
  }

  void _runAutoValidation() {
    if (_effectiveRules.isEmpty) {
      _autoValidationIssue = null;
      return;
    }

    _autoValidationIssue = liValidateValue(
      value: selectedValue,
      rules: _effectiveRules,
      context: LiRuleContext(
        fieldName: resolvedTitleText.trim().isEmpty ? null : resolvedTitleText,
        messages: _effectiveMessages,
        locale: locale,
      ),
    );
  }

  bool get _shouldShowValidation => liShouldShowValidation(
        mode: liValidationMode,
        touched: _touched,
        dirty: _dirty,
        submitted: _formSubmitted,
      );

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  String _extractLabel(
    dynamic instance, {
    Map<String, dynamic>? fallbackMap,
  }) {
    final customBuilder = itemLabelBuilder;
    if (customBuilder != null) {
      return customBuilder(instance);
    }

    final map = fallbackMap ?? _tryMap(instance);
    if (map != null) {
      return (map[labelKey] ?? '').toString();
    }

    return instance.toString();
  }

  dynamic _extractValue(
    dynamic instance, {
    Map<String, dynamic>? fallbackMap,
  }) {
    final customBuilder = itemValueBuilder;
    if (customBuilder != null) {
      return customBuilder(instance);
    }

    final map = fallbackMap ?? _tryMap(instance);
    if (map != null) {
      return valueKey != null ? map[valueKey] : instance;
    }

    return instance;
  }

  Map<String, dynamic>? _tryMap(dynamic instance) {
    if (instance is Map<String, dynamic>) {
      return instance;
    }

    try {
      return (instance as dynamic).toMap() as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  bool _areValuesEqual(dynamic itemValue, dynamic selectedValue) {
    final customCompare = compareWith;
    if (customCompare != null) {
      return customCompare(itemValue, selectedValue);
    }
    return itemValue == selectedValue;
  }

  bool _isValuePresentInCurrentPage(dynamic value) {
    for (final item in data.items) {
      final itemValue = _extractValue(item);
      if (_areValuesEqual(itemValue, value)) {
        return true;
      }
    }

    return false;
  }

  void _syncPendingSelectionFromCommitted() {
    _pendingSelectedValues = List<dynamic>.from(selectedValues);
    _pendingSelectedLabels = List<String>.from(selectedLabels);
  }

  void _commitPendingSelection() {
    _selectedValue = List<dynamic>.from(_pendingSelectedValues);
    _selectedLabels = List<String>.from(_pendingSelectedLabels);
    _selectedLabel = '';
    _dirty = true;
    _valueChangeCtrl.add(selectedValue);
    _onChange?.call(selectedValue);
  }

  bool _hasPendingSelectionChanged() {
    final committedValues = selectedValues;
    if (committedValues.length != _pendingSelectedValues.length) {
      return true;
    }

    for (final committedValue in committedValues) {
      final exists = _pendingSelectedValues.any(
        (pendingValue) => _areValuesEqual(pendingValue, committedValue),
      );
      if (!exists) {
        return true;
      }
    }

    return false;
  }

  void _scheduleDatatableSelectionSync() {
    if (!multiple) {
      return;
    }

    Future<void>.microtask(() {
      html.window.requestAnimationFrame((_) {
        _syncDatatableSelection();
      });
    });
  }

  void _syncDatatableSelection() {
    if (!multiple) {
      return;
    }

    final table = datatable;
    if (table == null) {
      return;
    }

    table.syncSelection((instance) {
      final instanceValue = _extractValue(instance);
      return _pendingSelectedValues.any(
        (selected) => _areValuesEqual(instanceValue, selected),
      );
    });
  }
}
