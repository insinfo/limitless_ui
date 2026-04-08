import 'dart:async';
import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import '../datatable/datatable_col.dart';
import '../datatable/datatable_component.dart';
import '../datatable/datatable_settings.dart';
import '../modal_component/modal_component.dart';

class LiDatatableSelectTriggerContext {
  LiDatatableSelectTriggerContext({
    required this.selectedValue,
    required this.selectedLabel,
    required this.placeholder,
    required this.hasSelection,
    required this.disabled,
    required this.open,
    required this.clear,
  });

  final dynamic selectedValue;
  final String selectedLabel;
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
    required this.selectedValue,
    required this.selectedLabel,
    required this.select,
    required this.selectItem,
    required this.close,
    required this.requestData,
  });

  final DataFrame data;
  final Filters dataTableFilter;
  final DatatableSettings settings;
  final List<DatatableSearchField> searchInFields;
  final dynamic selectedValue;
  final String selectedLabel;
  final void Function(dynamic instance) select;
  final void Function(String label, dynamic value) selectItem;
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
    implements ControlValueAccessor<dynamic>, OnDestroy {
  final ChangeDetectorRef _changeDetectorRef;

  LiDatatableSelectComponent(this._changeDetectorRef);

  // ---------------------------------------------------------------------------
  // ControlValueAccessor
  // ---------------------------------------------------------------------------

  dynamic Function(dynamic, {String rawValue})? _onChange;
  TouchFunction _onTouched = () {};
  bool _touched = false;

  @override
  void writeValue(dynamic newVal) {
    if (newVal == _selectedValue) return;
    _selectedValue = newVal;
    _syncLabelFromValue();
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

  /// When `true`, the datatable is rendered in grid/card mode.
  @Input()
  bool gridMode = false;

  /// When `true`, responsible collapse is enabled in the datatable.
  @Input()
  bool responsiveCollapse = false;

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

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  dynamic _selectedValue;
  String _selectedLabel = '';

  /// The value of the currently selected item.
  dynamic get selectedValue => _selectedValue;

  /// The display label of the currently selected item.
  String get selectedLabel => _selectedLabel;

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get hasSelection => selectedValue != null;

  bool get effectiveInvalid => invalid || dataInvalid;

  bool get effectiveValid => !effectiveInvalid && valid;

  bool get showErrorFeedback => errorText.trim().isNotEmpty && effectiveInvalid;

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

  String get resolvedTriggerClass => _joinClasses(<String>[
        'form-select',
        'datatable-select-trigger',
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
        selectedLabel: selectedLabel,
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
        selectedValue: selectedValue,
        selectedLabel: selectedLabel,
        select: onDatatableRowClick,
        selectItem: setSelectedItemFromTemplate,
        close: closeModal,
        requestData: onDatatableDataRequest,
      );

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void openModal() {
    if (isDisabled) return;
    modal?.open();
    _markTouched();
    _changeDetectorRef.markForCheck();
  }

  void closeModal() {
    modal?.close();
    _markTouched();
    _changeDetectorRef.markForCheck();
  }

  void onDatatableRowClick(dynamic instance) {
    _selectInstance(instance);
    closeModal();
    triggerButtonElement?.focus();
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
    _selectedValue = null;
    _selectedLabel = '';
    _valueChangeCtrl.add(null);
    _onChange?.call(null);
    _markTouched();
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
    _selectedValue = value;
    _syncLabelFromValue();
    _valueChangeCtrl.add(_selectedValue);
    _onChange?.call(_selectedValue);
    _markTouched();
    _changeDetectorRef.markForCheck();
  }

  /// Programmatically sets both label and value without needing data loaded.
  void setSelectedItem({required String label, required dynamic value}) {
    _selectedValue = value;
    _selectedLabel = label;
    _valueChangeCtrl.add(_selectedValue);
    _onChange?.call(_selectedValue);
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

    _valueChangeCtrl.add(_selectedValue);
    _onChange?.call(_selectedValue);
    _markTouched();
  }

  void _syncLabelFromValue() {
    if (_selectedValue == null) {
      _selectedLabel = '';
      return;
    }

    // Try to find the label from currently loaded data.
    for (final item in data.items) {
      final map = _tryMap(item);
      final itemValue = _extractValue(item, fallbackMap: map);
      if (_areValuesEqual(itemValue, _selectedValue)) {
        _selectedLabel = _extractLabel(item, fallbackMap: map);
        return;
      }
    }

    // Data not loaded yet — keep existing label or show value as fallback.
    if (_selectedLabel.isEmpty) {
      _selectedLabel = _selectedValue.toString();
    }
  }

  @override
  void ngOnDestroy() {
    _valueChangeCtrl.close();
    _dataRequestCtrl.close();
    _limitChangeCtrl.close();
    _searchRequestCtrl.close();
  }

  void _markTouched() {
    if (_touched) {
      _onTouched();
      return;
    }
    _touched = true;
    _onTouched();
  }

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
}
