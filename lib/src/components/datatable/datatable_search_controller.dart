import 'package:essential_core/essential_core.dart';

import 'datatable_models.dart';

/// Manages datatable search-field selection and filter synchronization.
class DatatableSearchController {
  List<DatatableSearchField> _fields = <DatatableSearchField>[];

  /// Configured searchable fields.
  List<DatatableSearchField> get fields => _fields;

  /// Replaces the search fields and reapplies the selected field to [filter].
  void setFields(List<DatatableSearchField> fields, Filters filter) {
    _fields = fields;
    applySelectedFieldToFilter(filter);
  }

  /// Index of the selected search field, or `null` when none exists.
  int? get selectedSearchFieldIndex {
    if (_fields.isEmpty) {
      return null;
    }

    _ensureSelectedSearchField();
    final index = _fields.indexWhere((field) => field.selected);
    return index < 0 ? null : index;
  }

  /// Applies the currently selected search field to [filter].
  void applySelectedFieldToFilter(Filters filter) {
    final selectedSearchField = _selectedSearchField;
    if (selectedSearchField == null) {
      filter.searchInFields = <FilterSearchField>[];
      return;
    }

    filter.searchInFields = <FilterSearchField>[
      FilterSearchField(
        active: true,
        field: selectedSearchField.field,
        operator: selectedSearchField.operator,
        label: selectedSearchField.label,
      ),
    ];
  }

  /// Selects a search field by index and updates [filter].
  void selectSearchFieldByIndex(int index, Filters filter) {
    if (index < 0 || index >= _fields.length) {
      return;
    }

    for (var i = 0; i < _fields.length; i++) {
      _fields[i].selected = i == index;
    }

    applySelectedFieldToFilter(filter);
  }

  DatatableSearchField? get _selectedSearchField {
    if (_fields.isEmpty) {
      return null;
    }

    _ensureSelectedSearchField();
    return _fields.firstWhere((field) => field.selected);
  }

  void _ensureSelectedSearchField() {
    if (_fields.isEmpty) {
      return;
    }

    if (!_fields.any((field) => field.selected)) {
      _fields.first.select();
    }
  }
}
