import 'dart:async';
import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import '../datatable/datatable_col.dart';
import '../datatable/datatable_component.dart';
import '../datatable/datatable_settings.dart';
import '../modal_component/modal_component.dart';

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
  void registerOnTouched(TouchFunction callback) {}

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

  /// The key used to extract the display label from each data row map.
  @Input()
  String labelKey = 'label';

  /// The key used to extract the value from each data row map.
  /// When `null`, the entire row instance is used as the value.
  @Input()
  String? valueKey;

  @Input()
  String placeholder = 'Selecione';

  /// Modal title text.
  @Input('title')
  String titleText = 'Selecionar';

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
  String searchPlaceholder = 'Digite para buscar';

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

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  dynamic _selectedValue;
  String _selectedLabel = '';

  /// The value of the currently selected item.
  dynamic get selectedValue => _selectedValue;

  /// The display label of the currently selected item.
  String get selectedLabel => _selectedLabel;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void openModal() {
    if (isDisabled) return;
    modal?.open();
    _changeDetectorRef.markForCheck();
  }

  void onDatatableRowClick(dynamic instance) {
    _selectInstance(instance);
    modal?.close();
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
    _changeDetectorRef.markForCheck();
  }

  /// Programmatically sets both label and value without needing data loaded.
  void setSelectedItem({required String label, required dynamic value}) {
    _selectedValue = value;
    _selectedLabel = label;
    _valueChangeCtrl.add(_selectedValue);
    _onChange?.call(_selectedValue);
    _changeDetectorRef.markForCheck();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _selectInstance(dynamic instance) {
    if (instance == null) return;

    String label;
    dynamic value;

    if (instance is Map<String, dynamic>) {
      label = (instance[labelKey] ?? '').toString();
      value = valueKey != null ? instance[valueKey] : instance;
    } else {
      // Fallback: try to access as a generic object via noSuchMethod or
      // toString. This covers typed model classes.
      try {
        final map = (instance as dynamic).toMap() as Map<String, dynamic>;
        label = (map[labelKey] ?? '').toString();
        value = valueKey != null ? map[valueKey] : instance;
      } catch (_) {
        label = instance.toString();
        value = instance;
      }
    }

    _selectedValue = value;
    _selectedLabel = label;

    _valueChangeCtrl.add(_selectedValue);
    _onChange?.call(_selectedValue);
  }

  void _syncLabelFromValue() {
    if (_selectedValue == null) {
      _selectedLabel = '';
      return;
    }

    // Try to find the label from currently loaded data.
    for (final item in data.items) {
      Map<String, dynamic>? map;
      if (item is Map<String, dynamic>) {
        map = item;
      } else {
        try {
          map = (item as dynamic).toMap() as Map<String, dynamic>;
        } catch (_) {
          // ignore
        }
      }

      if (map == null) continue;

      final itemValue = valueKey != null ? map[valueKey] : item;
      if (itemValue == _selectedValue) {
        _selectedLabel = (map[labelKey] ?? '').toString();
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
}
