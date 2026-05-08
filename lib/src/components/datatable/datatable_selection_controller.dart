import 'datatable_row.dart';
import 'datatable_settings.dart';

/// Maintains row-selection state that is independent from Angular bindings.
///
/// The controller exists mainly to keep virtual-scroll selection out of the
/// component. It preserves the same O(n) operations used previously: selecting
/// all virtual rows, syncing by predicate, and collecting selected instances all
/// scan the data list once.
class DatatableSelectionController {
  final Set<Object> _virtualSelectedRowKeys = <Object>{};

  /// Creates a stable selection key for a virtual row item.
  Object selectionKeyForItem(
    dynamic instance, {
    required int index,
    Map<String, dynamic>? itemMap,
    DatatableRowKeyResolver? rowKeyResolver,
  }) {
    final resolvedMap = itemMap ?? _coerceItemMap(instance);
    if (rowKeyResolver != null) {
      try {
        return rowKeyResolver(resolvedMap, instance, index);
      } catch (_) {
        // Fall back to common identifiers when a consumer resolver fails.
      }
    }

    return _defaultRowKey(resolvedMap, instance, index);
  }

  /// Creates a selection key from a built datatable row.
  Object selectionKeyForRow(
    DatatableRow row, {
    DatatableRowKeyResolver? rowKeyResolver,
  }) {
    if (row.id != null) {
      return row.id as Object;
    }

    return selectionKeyForItem(
      row.instance,
      index: row.index,
      itemMap: row.itemMap,
      rowKeyResolver: rowKeyResolver,
    );
  }

  /// Clears every virtual-scroll selection key.
  void clearVirtualSelection() {
    _virtualSelectedRowKeys.clear();
  }

  /// Adds the row to the virtual-scroll selection set.
  void selectVirtualRow(
    DatatableRow row, {
    DatatableRowKeyResolver? rowKeyResolver,
  }) {
    _virtualSelectedRowKeys.add(
      selectionKeyForRow(row, rowKeyResolver: rowKeyResolver),
    );
  }

  /// Removes the row from the virtual-scroll selection set.
  void unselectVirtualRow(
    DatatableRow row, {
    DatatableRowKeyResolver? rowKeyResolver,
  }) {
    _virtualSelectedRowKeys.remove(
      selectionKeyForRow(row, rowKeyResolver: rowKeyResolver),
    );
  }

  /// Replaces virtual-scroll selection with a single row.
  void selectSingleVirtualRow(
    DatatableRow row, {
    DatatableRowKeyResolver? rowKeyResolver,
  }) {
    _virtualSelectedRowKeys
      ..clear()
      ..add(selectionKeyForRow(row, rowKeyResolver: rowKeyResolver));
  }

  /// Marks every item in [items] as selected for virtual scrolling.
  void selectAllVirtualItems(
    List<dynamic> items, {
    List<Map<String, dynamic>>? itemMaps,
    DatatableRowKeyResolver? rowKeyResolver,
  }) {
    _virtualSelectedRowKeys.clear();
    for (var index = 0; index < items.length; index++) {
      _virtualSelectedRowKeys.add(
        selectionKeyForItem(
          items[index],
          index: index,
          itemMap: _itemMapAt(itemMaps, index),
          rowKeyResolver: rowKeyResolver,
        ),
      );
    }
  }

  /// Synchronizes virtual-scroll selection using [predicate].
  void syncVirtualSelection(
    List<dynamic> items,
    bool Function(dynamic instance) predicate, {
    List<Map<String, dynamic>>? itemMaps,
    DatatableRowKeyResolver? rowKeyResolver,
  }) {
    _virtualSelectedRowKeys.clear();
    for (var index = 0; index < items.length; index++) {
      final instance = items[index];
      if (predicate(instance)) {
        _virtualSelectedRowKeys.add(
          selectionKeyForItem(
            instance,
            index: index,
            itemMap: _itemMapAt(itemMaps, index),
            rowKeyResolver: rowKeyResolver,
          ),
        );
      }
    }
  }

  /// Removes every matching [item] occurrence from the virtual selection set.
  void unselectItemInstance(
    List<dynamic> items,
    dynamic item, {
    List<Map<String, dynamic>>? itemMaps,
    DatatableRowKeyResolver? rowKeyResolver,
  }) {
    for (var index = 0; index < items.length; index++) {
      if (items[index] == item) {
        _virtualSelectedRowKeys.remove(
          selectionKeyForItem(
            item,
            index: index,
            itemMap: _itemMapAt(itemMaps, index),
            rowKeyResolver: rowKeyResolver,
          ),
        );
      }
    }
  }

  /// Applies virtual-scroll selection flags to currently rendered rows.
  void applyVirtualSelectionState(
    List<DatatableRow> rowsToSync, {
    DatatableRowKeyResolver? rowKeyResolver,
  }) {
    for (final row in rowsToSync) {
      if (row.type != DatatableRowType.normal) {
        continue;
      }
      row.selected = _virtualSelectedRowKeys.contains(
        selectionKeyForRow(row, rowKeyResolver: rowKeyResolver),
      );
    }
  }

  /// Collects selected item instances from the full virtual-scroll data list.
  List<dynamic> collectVirtualSelectedInstances(
    List<dynamic> items, {
    List<Map<String, dynamic>>? itemMaps,
    DatatableRowKeyResolver? rowKeyResolver,
  }) {
    final selected = <dynamic>[];
    for (var index = 0; index < items.length; index++) {
      final instance = items[index];
      if (_virtualSelectedRowKeys.contains(
        selectionKeyForItem(
          instance,
          index: index,
          itemMap: _itemMapAt(itemMaps, index),
          rowKeyResolver: rowKeyResolver,
        ),
      )) {
        selected.add(instance);
      }
    }
    return selected;
  }

  Map<String, dynamic>? _itemMapAt(
    List<Map<String, dynamic>>? itemMaps,
    int index,
  ) {
    if (itemMaps == null || index < 0 || index >= itemMaps.length) {
      return null;
    }
    return itemMaps[index];
  }

  Object _defaultRowKey(
    Map<String, dynamic> itemMap,
    dynamic instance,
    int index,
  ) {
    for (final key in const <String>[
      'id',
      'uuid',
      'key',
      'codigo',
      'code',
      'cod_processo',
      'processCode',
    ]) {
      final value = itemMap[key];
      if (value != null) {
        return value as Object;
      }
    }

    return Object.hash(instance?.hashCode, index);
  }

  Map<String, dynamic> _coerceItemMap(dynamic itemInstance) {
    if (itemInstance is Map<String, dynamic>) {
      return itemInstance;
    }

    if (itemInstance is Map) {
      try {
        return Map<String, dynamic>.from(itemInstance);
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    try {
      final dynamic rawMap = (itemInstance as dynamic).toMap();
      if (rawMap is Map<String, dynamic>) {
        return rawMap;
      }
      if (rawMap is Map) {
        return Map<String, dynamic>.from(rawMap);
      }
    } catch (_) {
      // Keep the fallback key path available for opaque instances.
    }

    return <String, dynamic>{};
  }
}
