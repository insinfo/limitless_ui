import 'package:essential_core/essential_core.dart';

import 'datatable_col.dart';

/// Applies datatable sorting rules to a [Filters] instance.
///
/// This controller is intentionally small and allocation-compatible with the
/// previous component code: it only creates a copied order-field list when the
/// existing implementation already needed one.
class DatatableSortController {
  /// Returns the effective order fields for the current filter.
  List<FilterOrderField> resolveOrderFields(
    Filters filter, {
    required bool enableMultiColumnSorting,
  }) {
    if (enableMultiColumnSorting && filter.orderFields.isNotEmpty) {
      return List<FilterOrderField>.from(filter.orderFields);
    }

    final orderBy = filter.orderBy;
    if (orderBy == null || orderBy.trim().isEmpty) {
      return <FilterOrderField>[];
    }

    return <FilterOrderField>[
      FilterOrderField(
        field: orderBy,
        direction: filter.orderDir ?? 'desc',
      ),
    ];
  }

  /// Resolves the next direction for [sortingBy].
  String nextSortDirection(
    Filters filter, {
    required bool enableMultiColumnSorting,
    required String sortingBy,
    required String defaultSortDirection,
  }) {
    for (final orderField in resolveOrderFields(
      filter,
      enableMultiColumnSorting: enableMultiColumnSorting,
    )) {
      if (orderField.field == sortingBy) {
        return orderField.direction == 'asc' ? 'desc' : 'asc';
      }
    }

    return defaultSortDirection;
  }

  /// Mutates [filter] with the next sorting state for [column].
  void applyColumnSort(
    Filters filter, {
    required DatatableCol column,
    required bool enableMultiColumnSorting,
  }) {
    final sortingBy = column.sortingBy;
    if (sortingBy == null) {
      return;
    }

    final nextDirection = nextSortDirection(
      filter,
      enableMultiColumnSorting: enableMultiColumnSorting,
      sortingBy: sortingBy,
      defaultSortDirection: column.defaultSortDirection,
    );

    if (enableMultiColumnSorting) {
      final orderFields = resolveOrderFields(
        filter,
        enableMultiColumnSorting: enableMultiColumnSorting,
      ).toList(growable: true);
      final existingIndex =
          orderFields.indexWhere((field) => field.field == sortingBy);
      if (existingIndex >= 0) {
        orderFields[existingIndex] = FilterOrderField(
          field: sortingBy,
          direction: nextDirection,
        );
      } else {
        orderFields.add(
          FilterOrderField(
            field: sortingBy,
            direction: column.defaultSortDirection,
          ),
        );
      }
      filter.orderFields = orderFields;
    } else {
      filter.orderBy = sortingBy;
      filter.orderDir = nextDirection;
      filter.orderFields = <FilterOrderField>[];
    }
  }
}
