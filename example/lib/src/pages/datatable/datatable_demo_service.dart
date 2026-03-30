import 'dart:async';

import 'package:essential_core/essential_core.dart';

class DatatableDemoService {
  DatatableDemoService(List<Map<String, dynamic>> records)
      : _records = List<Map<String, dynamic>>.unmodifiable(
          records.map((record) => Map<String, dynamic>.from(record)),
        );

  final List<Map<String, dynamic>> _records;

  Future<DataFrame<Map<String, dynamic>>> query(Filters filters) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    var workingSet = _records
        .map((record) => Map<String, dynamic>.from(record))
        .toList(growable: false);

    workingSet = _applySearch(workingSet, filters);
    workingSet = _applySorting(workingSet, filters);

    final totalRecords = workingSet.length;
    final offset = filters.offset ?? 0;
    final limit = filters.limit ?? totalRecords;
    final start = offset.clamp(0, workingSet.length);
    final end = (start + limit).clamp(0, workingSet.length);

    return DataFrame<Map<String, dynamic>>(
      items: workingSet.sublist(start, end),
      totalRecords: totalRecords,
    );
  }

  List<Map<String, dynamic>> _applySearch(
    List<Map<String, dynamic>> input,
    Filters filters,
  ) {
    final search = filters.searchString?.trim().toLowerCase();
    if (search == null || search.isEmpty) {
      return input;
    }

    final searchFields = filters.searchInFields.where((field) => field.active);
    if (searchFields.isEmpty) {
      return input;
    }

    return input.where((item) {
      for (final field in searchFields) {
        final rawValue = _resolveValue(item, field.field);
        final candidate = rawValue?.toString().toLowerCase() ?? '';
        if (field.operator == '=') {
          if (candidate == search) {
            return true;
          }
          continue;
        }

        if (candidate.contains(search)) {
          return true;
        }
      }
      return false;
    }).toList(growable: false);
  }

  List<Map<String, dynamic>> _applySorting(
    List<Map<String, dynamic>> input,
    Filters filters,
  ) {
    final orderFields = filters.orderFields.isNotEmpty
        ? List<FilterOrderField>.from(filters.orderFields)
        : _singleOrder(filters);

    if (orderFields.isEmpty) {
      return input;
    }

    final sorted = input.toList(growable: true);
    sorted.sort((left, right) {
      for (final orderField in orderFields) {
        final comparison = _compareValues(
          _resolveValue(left, orderField.field),
          _resolveValue(right, orderField.field),
        );
        if (comparison == 0) {
          continue;
        }
        return orderField.direction == 'desc' ? -comparison : comparison;
      }
      return 0;
    });
    return sorted;
  }

  List<FilterOrderField> _singleOrder(Filters filters) {
    final orderBy = filters.orderBy;
    if (orderBy == null || orderBy.trim().isEmpty) {
      return <FilterOrderField>[];
    }

    return <FilterOrderField>[
      FilterOrderField(
        field: orderBy,
        direction: filters.orderDir ?? 'asc',
      ),
    ];
  }

  dynamic _resolveValue(Map<String, dynamic> item, String field) {
    if (!field.contains('.')) {
      return item[field];
    }

    dynamic current = item;
    for (final key in field.split('.')) {
      if (current is! Map<String, dynamic>) {
        return current;
      }
      current = current[key];
    }
    return current;
  }

  int _compareValues(dynamic left, dynamic right) {
    if (left == null && right == null) {
      return 0;
    }
    if (left == null) {
      return -1;
    }
    if (right == null) {
      return 1;
    }
    if (left is num && right is num) {
      return left.compareTo(right);
    }

    return left.toString().toLowerCase().compareTo(
          right.toString().toLowerCase(),
        );
  }
}
