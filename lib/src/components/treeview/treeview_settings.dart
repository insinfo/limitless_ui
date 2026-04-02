import 'package:essential_core/essential_core.dart';

import 'tree_view_base.dart';

typedef TreeViewItemMapResolver = Map<String, dynamic>? Function(dynamic item);
typedef TreeViewFieldResolver<T> = T? Function(
  dynamic item,
  Map<String, dynamic>? itemMap,
);
typedef TreeViewNodesResolver = Iterable<dynamic>? Function(
  dynamic item,
  Map<String, dynamic>? itemMap,
);
typedef TreeViewNodeDecorator = void Function(
  TreeViewNode node,
  dynamic item,
  Map<String, dynamic>? itemMap,
);

class TreeViewSettings {
  const TreeViewSettings({
    this.idField = 'id',
    this.labelField = 'label',
    this.valueField = 'id',
    this.nodesField = 'nodes',
    this.iconField = 'icon',
    this.colorField = 'color',
    this.enabledField = 'enabled',
    this.itemMapResolver,
    this.idResolver,
    this.labelResolver,
    this.valueResolver,
    this.nodesResolver,
    this.iconResolver,
    this.colorResolver,
    this.enabledResolver,
    this.initiallyCollapsedResolver,
    this.initiallySelectedResolver,
    this.lazyChildrenResolver,
    this.hasMoreChildrenResolver,
    this.nodeDecorator,
  });

  final String idField;
  final String labelField;
  final String? valueField;
  final String nodesField;
  final String? iconField;
  final String? colorField;
  final String? enabledField;

  final TreeViewItemMapResolver? itemMapResolver;
  final TreeViewFieldResolver<dynamic>? idResolver;
  final TreeViewFieldResolver<String>? labelResolver;
  final TreeViewFieldResolver<dynamic>? valueResolver;
  final TreeViewNodesResolver? nodesResolver;
  final TreeViewFieldResolver<String>? iconResolver;
  final TreeViewFieldResolver<String>? colorResolver;
  final TreeViewFieldResolver<bool>? enabledResolver;
  final TreeViewFieldResolver<bool>? initiallyCollapsedResolver;
  final TreeViewFieldResolver<bool>? initiallySelectedResolver;
  final TreeViewFieldResolver<bool>? lazyChildrenResolver;
  final TreeViewFieldResolver<bool>? hasMoreChildrenResolver;
  final TreeViewNodeDecorator? nodeDecorator;

  List<TreeViewNode> normalize(dynamic data) {
    return _buildNodes(_normalizeItems(data), level: 0, parent: null);
  }

  Map<String, dynamic>? itemAsMap(dynamic item) {
    final customMap = itemMapResolver?.call(item);
    if (customMap != null) {
      return customMap;
    }

    if (item is Map<String, dynamic>) {
      return item;
    }

    if (item is Map) {
      return item.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    if (item is SerializeBase) {
      return item.toMap();
    }

    try {
      final dynamic rawMap = (item as dynamic).toMap();
      if (rawMap is Map<String, dynamic>) {
        return rawMap;
      }
      if (rawMap is Map) {
        return rawMap.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  List<TreeViewNode> _buildNodes(
    List<dynamic> items, {
    required int level,
    required TreeViewNode? parent,
  }) {
    final nodes = <TreeViewNode>[];
    for (final item in items) {
      final node = _buildNode(item, level: level, parent: parent);
      if (node != null) {
        nodes.add(node);
      }
    }
    return nodes;
  }

  TreeViewNode? _buildNode(
    dynamic item, {
    required int level,
    required TreeViewNode? parent,
  }) {
    if (item == null) {
      return null;
    }

    if (item is TreeViewNode) {
      _prepareExistingNode(item, level: level, parent: parent);
      return item;
    }

    final itemMap = itemAsMap(item);
    final rawChildren = _resolveChildren(item, itemMap);
    final lazyChildren = lazyChildrenResolver?.call(item, itemMap) ?? false;
    final hasMoreChildren =
        hasMoreChildrenResolver?.call(item, itemMap) ?? false;
    final children = _buildNodes(
      _normalizeItems(rawChildren),
      level: level + 1,
      parent: null,
    );

    final node = TreeViewNode(
      id: idResolver?.call(item, itemMap) ??
          _readField(itemMap, idField) ??
          valueResolver?.call(item, itemMap) ??
          item,
      treeViewNodeLabel: labelResolver?.call(item, itemMap) ??
          (_readField(itemMap, labelField)?.toString() ?? item.toString()),
      treeViewNodeLevel: level,
      treeViewNodeIsCollapse:
          initiallyCollapsedResolver?.call(item, itemMap) ?? true,
      treeViewNodeIsSelected:
          initiallySelectedResolver?.call(item, itemMap) ?? false,
      treeViewNodeHasLazyChildren: lazyChildren,
      treeViewNodeChildrenLoaded: !lazyChildren || children.isNotEmpty,
      treeViewNodeHasMoreChildren: hasMoreChildren,
      value: valueResolver?.call(item, itemMap) ??
          (valueField == null ? item : _readField(itemMap, valueField!)) ??
          _readField(itemMap, idField) ??
          item,
      source: item,
      sourceMap: itemMap,
      icon: iconResolver?.call(item, itemMap) ??
          (iconField == null
              ? null
              : _readField(itemMap, iconField!)?.toString()),
      color: colorResolver?.call(item, itemMap) ??
          (colorField == null
              ? null
              : _readField(itemMap, colorField!)?.toString()),
      enabled: enabledResolver?.call(item, itemMap) ??
          _readBool(itemMap, enabledField) ??
          true,
    );

    node.parent = parent;
    for (final child in children) {
      node.addChild(child);
    }
    nodeDecorator?.call(node, item, itemMap);
    return node;
  }

  void _prepareExistingNode(
    TreeViewNode node, {
    required int level,
    required TreeViewNode? parent,
  }) {
    node.parent = parent;
    node.treeViewNodeLevel = level;
    node.source ??= node;
    for (final child in node.treeViewNodes) {
      _prepareExistingNode(
        child,
        level: level + 1,
        parent: node,
      );
    }
  }

  List<dynamic> _normalizeItems(dynamic data) {
    if (data == null) {
      return const <dynamic>[];
    }

    if (data is DataFrame) {
      return List<dynamic>.from(data.items, growable: false);
    }

    if (data is Iterable) {
      return List<dynamic>.from(data, growable: false);
    }

    return const <dynamic>[];
  }

  Iterable<dynamic>? _resolveChildren(
    dynamic item,
    Map<String, dynamic>? itemMap,
  ) {
    final resolved = nodesResolver?.call(item, itemMap);
    if (resolved != null) {
      return resolved;
    }

    return _readField(itemMap, nodesField) as dynamic;
  }

  dynamic _readField(Map<String, dynamic>? itemMap, String field) {
    if (itemMap == null || field.trim().isEmpty) {
      return null;
    }
    return itemMap[field];
  }

  bool? _readBool(Map<String, dynamic>? itemMap, String? field) {
    if (itemMap == null || field == null || field.trim().isEmpty) {
      return null;
    }

    final rawValue = itemMap[field];
    if (rawValue is bool) {
      return rawValue;
    }
    if (rawValue is num) {
      return rawValue != 0;
    }
    if (rawValue is String) {
      final normalized = rawValue.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'sim') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'nao') {
        return false;
      }
    }

    return null;
  }
}
