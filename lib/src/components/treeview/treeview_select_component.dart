import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;
import 'package:popper/popper.dart';
import 'package:essential_core/essential_core.dart';

import '../../core/overlay_positioning.dart';
import 'tree_view_base.dart';
import 'treeview_settings.dart';

typedef LiTreeViewPageLoader = FutureOr<TreeViewLoadResult> Function(
  TreeViewLoadRequest request,
);

class LiTreeviewSelectNodeContext {
  LiTreeviewSelectNodeContext({
    required this.node,
    required this.selected,
    required this.disabled,
    required this.multiple,
    required this.label,
  });

  final TreeViewNode node;
  final bool selected;
  final bool disabled;
  final bool multiple;
  final String label;
}

class LiTreeviewSelectTriggerContext {
  LiTreeviewSelectTriggerContext({
    required this.selectedNode,
    required this.selectedNodes,
    required this.multiple,
    required this.hasSelection,
    required this.label,
    required this.labels,
    required this.values,
    required this.placeholder,
  });

  final TreeViewNode? selectedNode;
  final List<TreeViewNode> selectedNodes;
  final bool multiple;
  final bool hasSelection;
  final String label;
  final List<String> labels;
  final List<dynamic> values;
  final String placeholder;
}

@Directive(selector: 'template[liTreeviewSelectNode]')
class LiTreeviewSelectNodeDirective {
  LiTreeviewSelectNodeDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liTreeviewSelectTrigger]')
class LiTreeviewSelectTriggerDirective {
  LiTreeviewSelectTriggerDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Component(
  selector: 'li-treeview-select',
  templateUrl: 'treeview_select_component.html',
  styleUrls: ['treeview_select_component.css'],
  directives: [coreDirectives],
  providers: [
    ExistingProvider.forToken(
      ngValueAccessor,
      LiTreeviewSelectComponent,
    ),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTreeviewSelectComponent
    implements ControlValueAccessor<dynamic>, OnInit, AfterChanges, OnDestroy {
  LiTreeviewSelectComponent(this._changeDetectorRef) {
    final seq = _nextSequence++;
    listboxId = 'li-treeview-dropdown-$seq';
  }

  static int _nextSequence = 0;

  final ChangeDetectorRef _changeDetectorRef;
  final StreamController<dynamic> _changeController =
      StreamController<dynamic>.broadcast();

  PopperAnchoredOverlay? _overlay;
  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;
  Timer? _searchDebounceTimer;
  bool _destroyed = false;
  bool _overlayRelayoutPending = false;
  dynamic _pendingModelValue;

  ChangeFunction<dynamic>? _ngModelValueChangeCallback;
  TouchFunction _touchCallback = () {};
  bool _touched = false;

  dynamic _sourceData;
  TreeViewSettings _settings = const TreeViewSettings();
  List<TreeViewNode> _staticNodes = <TreeViewNode>[];

  @Input()
  set data(dynamic value) {
    _sourceData = value;
    _staticNodes = _settings.normalize(value);
  }

  dynamic get data => _sourceData;

  @Input('settings')
  set settings(TreeViewSettings? value) {
    _settings = value ?? const TreeViewSettings();
    _staticNodes = _settings.normalize(_sourceData);
  }

  TreeViewSettings get settings => _settings;

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  String placeholder = '';

  @Input()
  String searchPlaceholder = '';

  @Input()
  String locale = 'pt_BR';

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
  bool searchable = true;

  @Input()
  bool openOnFocus = false;

  @Input()
  int pageSize = 25;

  @Input()
  String container = 'body';

  @Input()
  String emptyLabel = '';

  @Input()
  String loadingLabel = '';

  @Input()
  String loadMoreLabel = '';

  @Input()
  bool returnNode = false;

  @Input()
  bool multiple = false;

  @Input()
  bool showClearButton = true;

  @Input()
  bool closeOnSelect = true;

  @Input()
  String clearButtonLabel = '';

  @Input()
  String summarySuffix = '';

  @Input()
  String Function(TreeViewNode node)? labelBuilder;

  @Input()
  bool Function(TreeViewNode node)? canSelectNode;

  @Input()
  bool Function(TreeViewNode node, String term)? searchMatcher;

  @Input()
  LiTreeViewPageLoader? pageLoader;

  @Output('currentValueChange')
  Stream<dynamic> get currentValueChange => _changeController.stream;

  @ViewChild('triggerButton')
  html.ButtonElement? triggerButtonElement;

  @ViewChild('dropdownPanel')
  html.Element? dropdownPanelElement;

  @ViewChild('searchInput')
  html.InputElement? searchInputElement;

  @ViewChild('scrollContainer')
  html.Element? scrollContainerElement;

  @ContentChild(LiTreeviewSelectNodeDirective)
  LiTreeviewSelectNodeDirective? nodeTemplate;

  @ContentChild(LiTreeviewSelectTriggerDirective)
  LiTreeviewSelectTriggerDirective? triggerTemplate;

  late final String listboxId;

  bool dropdownOpen = false;
  bool loadingRootNodes = false;
  bool hasMoreRootNodes = false;
  String searchTerm = '';
  List<TreeViewNode> rootNodes = <TreeViewNode>[];
  List<TreeViewNode> visibleRootNodes = <TreeViewNode>[];
  TreeViewNode? selectedNode;
  List<TreeViewNode> selectedNodes = <TreeViewNode>[];

  bool get isPopupOpen => dropdownOpen;

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get effectiveInvalid => invalid || dataInvalid;

  bool get effectiveValid => !effectiveInvalid && valid;

  bool get showErrorFeedback => errorText.trim().isNotEmpty && effectiveInvalid;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String get resolvedPlaceholder => placeholder.trim().isNotEmpty
      ? placeholder
      : (_isEnglishLocale ? 'Select an item' : 'Selecione um item');

  String get resolvedSearchPlaceholder => searchPlaceholder.trim().isNotEmpty
      ? searchPlaceholder
      : (_isEnglishLocale ? 'Search node' : 'Buscar no');

  String get resolvedEmptyLabel => emptyLabel.trim().isNotEmpty
      ? emptyLabel
      : (_isEnglishLocale ? 'No items found' : 'Nenhum item encontrado');

  String get resolvedLoadingLabel => loadingLabel.trim().isNotEmpty
      ? loadingLabel
      : (_isEnglishLocale ? 'Loading...' : 'Carregando...');

  String get resolvedLoadMoreLabel => loadMoreLabel.trim().isNotEmpty
      ? loadMoreLabel
      : (_isEnglishLocale ? 'Load more' : 'Carregar mais');

  String get resolvedClearButtonLabel => clearButtonLabel.trim().isNotEmpty
      ? clearButtonLabel
      : (_isEnglishLocale ? 'Clear' : 'Limpar');

  String get resolvedSummarySuffix => summarySuffix.trim().isNotEmpty
      ? summarySuffix
      : (_isEnglishLocale ? 'items' : 'itens');

  String get searchAriaLabel =>
      _isEnglishLocale ? 'Search nodes' : 'Buscar nos';

  String get resolvedTriggerClass => _joinClasses(<String>[
        'form-select',
        'treeview-dropdown-select__trigger',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  bool get hasSelection =>
      multiple ? selectedNodes.isNotEmpty : selectedNode != null;

  LiTreeviewSelectTriggerContext get triggerContext =>
      LiTreeviewSelectTriggerContext(
        selectedNode: selectedNode,
        selectedNodes: selectedNodes,
        multiple: multiple,
        hasSelection: hasSelection,
        label: selectedLabel,
        labels: selectedNodes.map(resolvedNodeLabel).toList(growable: false),
        values: selectedNodes
            .map<dynamic>(_selectedValueFor)
            .toList(growable: false),
        placeholder: resolvedPlaceholder,
      );

  String get selectedLabel {
    if (multiple) {
      if (selectedNodes.isEmpty) {
        return '';
      }
      if (selectedNodes.length == 1) {
        return resolvedNodeLabel(selectedNodes.first);
      }
      if (selectedNodes.length == 2) {
        return selectedNodes.map(resolvedNodeLabel).join(', ');
      }
      return '${resolvedNodeLabel(selectedNodes[0])}, ${resolvedNodeLabel(selectedNodes[1])} +${selectedNodes.length - 2} $resolvedSummarySuffix';
    }
    return selectedNode == null ? '' : resolvedNodeLabel(selectedNode!);
  }

  bool get isEmptyStateVisible =>
      !loadingRootNodes && visibleRootNodes.isEmpty && !hasMoreRootNodes;

  @override
  void ngOnInit() {
    _staticNodes = _settings.normalize(_sourceData);
    _applyInitialData();
    if (pageLoader != null && _staticNodes.isEmpty) {
      unawaited(_loadRootNodes(reset: true));
    }
  }

  @override
  void ngAfterChanges() {
    if (pageLoader == null || _staticNodes.isNotEmpty) {
      _applyInitialData();
    }
  }

  @override
  void ngOnDestroy() {
    _destroyed = true;
    _searchDebounceTimer?.cancel();
    _unbindDocumentListeners();
    _overlay?.dispose();
    _changeController.close();
  }

  @override
  void writeValue(dynamic value) {
    _pendingModelValue = value;
    if (multiple) {
      _clearSelectedState(rootNodes);
      selectedNodes = <TreeViewNode>[];
      _applySelectionFromPendingValue();
    } else {
      selectedNode = _findNodeByValue(rootNodes, value);
    }
    _markForCheck();
  }

  @override
  void registerOnChange(ChangeFunction<dynamic> fn) {
    _ngModelValueChangeCallback = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _touchCallback = fn;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    this.isDisabled = isDisabled;
    if (isDisabled) {
      closeDropdown();
    }
    _markForCheck();
  }

  void toggleDropdown() {
    if (isDisabled) {
      return;
    }

    if (dropdownOpen) {
      closeDropdown();
    } else {
      openDropdown();
    }
  }

  void openDropdown() {
    if (isDisabled) {
      return;
    }

    dropdownOpen = true;
    _ensureOverlay();
    _overlay?.startAutoUpdate();
    _bindDocumentListeners();

    if (pageLoader != null && rootNodes.isEmpty && !loadingRootNodes) {
      unawaited(_loadRootNodes(reset: true));
    } else {
      _scheduleOverlayUpdate();
    }

    Future<void>.delayed(const Duration(milliseconds: 20), () {
      if (!dropdownOpen) {
        return;
      }

      _overlay?.update();
      if (searchable) {
        searchInputElement?.focus();
      }
    });

    _markForCheck();
  }

  void closeDropdown({bool markTouched = true}) {
    if (!dropdownOpen) {
      if (markTouched) {
        _markTouched();
      }
      return;
    }

    dropdownOpen = false;
    _overlay?.stopAutoUpdate();
    _unbindDocumentListeners();

    if (markTouched) {
      _markTouched();
    }

    _markForCheck();
  }

  void handleFocus() {
    _markTouched();
    if (openOnFocus && !dropdownOpen) {
      openDropdown();
    }
  }

  void handleSearchInput(String? value) {
    searchTerm = value?.trim() ?? '';
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(
      const Duration(milliseconds: 180),
      () => unawaited(_handleSearchChanged()),
    );
  }

  Future<void> _handleSearchChanged() async {
    if (_destroyed) {
      return;
    }

    if (pageLoader != null) {
      await _loadRootNodes(reset: true);
      return;
    }

    _applyLocalFilter();
    _markForCheck();
    _scheduleOverlayUpdate();
  }

  Future<void> toggleNode(TreeViewNode node) async {
    if (!node.canExpand) {
      return;
    }

    if (node.treeViewNodeIsCollapse) {
      node.treeViewNodeIsCollapse = false;
      if (_shouldLoadNodeChildren(node)) {
        await _loadNodeChildren(node, reset: true);
      }
    } else {
      node.treeViewNodeIsCollapse = true;
    }

    _markForCheck();
    _scheduleOverlayUpdate();
  }

  Future<void> loadMoreRootNodes() async {
    await _loadRootNodes(reset: false);
  }

  Future<void> loadMoreChildren(TreeViewNode node) async {
    await _loadNodeChildren(node, reset: false);
  }

  void selectNode(TreeViewNode node) {
    if (!isSelectable(node)) {
      return;
    }

    if (multiple) {
      final isSelected = _isNodeSelected(node);
      node.treeViewNodeIsSelected = !isSelected;
      if (node.treeViewNodeIsSelected) {
        selectedNodes = <TreeViewNode>[...selectedNodes, node];
      } else {
        selectedNodes = selectedNodes
            .where((selected) => !identical(selected, node))
            .toList(growable: false);
      }
      _pendingModelValue = _selectedValues();
      _changeController.add(_pendingModelValue);
      _ngModelValueChangeCallback?.call(_pendingModelValue);
      _markTouched();
      if (!closeOnSelect) {
        _scheduleOverlayUpdate();
      }
      _markForCheck();
      return;
    }

    selectedNode = node;
    _pendingModelValue = _selectedValueFor(node);
    _changeController.add(_pendingModelValue);
    _ngModelValueChangeCallback?.call(_pendingModelValue);
    _markTouched();
    if (closeOnSelect) {
      closeDropdown();
    } else {
      _markForCheck();
      _scheduleOverlayUpdate();
    }
  }

  bool isNodeSelected(TreeViewNode node) => _isNodeSelected(node);

  bool isSelectable(TreeViewNode node) =>
      node.enabled && (canSelectNode?.call(node) ?? true);

  String resolvedNodeLabel(TreeViewNode node) =>
      labelBuilder?.call(node) ?? node.treeViewNodeLabel;

  bool hasNodeIcon(TreeViewNode node) => (node.icon ?? '').trim().isNotEmpty;

  String nodeIconClass(TreeViewNode node) =>
      'treeview-dropdown-select__node-icon ${node.icon ?? ''}'.trim();

  LiTreeviewSelectNodeContext nodeContext(TreeViewNode node) =>
      LiTreeviewSelectNodeContext(
        node: node,
        selected: isNodeSelected(node),
        disabled: !isSelectable(node),
        multiple: multiple,
        label: resolvedNodeLabel(node),
      );

  void clearSelection([html.Event? event]) {
    event?.stopPropagation();
    if (isDisabled || !hasSelection) {
      return;
    }

    _pendingModelValue = multiple ? <dynamic>[] : null;
    selectedNode = null;
    _clearSelectedState(rootNodes);
    selectedNodes = <TreeViewNode>[];
    _changeController.add(_pendingModelValue);
    _ngModelValueChangeCallback?.call(_pendingModelValue);
    _markTouched();
    _markForCheck();
  }

  bool showLoadMoreForNode(TreeViewNode node) =>
      !node.treeViewNodeIsLoadingChildren && node.treeViewNodeHasMoreChildren;

  bool _shouldLoadNodeChildren(TreeViewNode node) {
    return pageLoader != null &&
        node.treeViewNodeHasLazyChildren &&
        (!node.treeViewNodeChildrenLoaded ||
            (node.treeViewNodes.isEmpty && node.treeViewNodeHasMoreChildren));
  }

  Future<void> _loadRootNodes({required bool reset}) async {
    final loader = pageLoader;
    if (loader == null || loadingRootNodes) {
      return;
    }

    loadingRootNodes = true;
    if (reset) {
      hasMoreRootNodes = false;
      rootNodes = <TreeViewNode>[];
    }
    _markForCheck();
    _scheduleOverlayUpdate();

    try {
      final result = await loader(
        TreeViewLoadRequest(
          parent: null,
          offset: reset ? 0 : rootNodes.length,
          limit: pageSize,
          searchTerm: searchTerm,
        ),
      );

      if (_destroyed) {
        return;
      }

      if (reset) {
        rootNodes = <TreeViewNode>[];
      }

      _appendNodes(
        target: rootNodes,
        nodes: _resolveLoadedNodes(result),
        parent: null,
      );
      hasMoreRootNodes = result.hasMore;
      _applySelectionFromPendingValue();
      _refreshVisibleRootNodes();
    } finally {
      if (!_destroyed) {
        loadingRootNodes = false;
        _markForCheck();
        _scheduleOverlayUpdate();
      }
    }
  }

  Future<void> _loadNodeChildren(
    TreeViewNode parent, {
    required bool reset,
  }) async {
    final loader = pageLoader;
    if (loader == null || parent.treeViewNodeIsLoadingChildren) {
      return;
    }

    parent.treeViewNodeIsLoadingChildren = true;
    if (reset) {
      parent.clearChildren();
      parent.treeViewNodeChildrenLoaded = false;
      parent.treeViewNodeHasMoreChildren = false;
    }
    _markForCheck();
    _scheduleOverlayUpdate();

    try {
      final result = await loader(
        TreeViewLoadRequest(
          parent: parent,
          offset: reset ? 0 : parent.treeViewNodes.length,
          limit: pageSize,
          searchTerm: searchTerm,
        ),
      );

      if (_destroyed) {
        return;
      }

      if (reset) {
        parent.clearChildren();
      }

      _appendNodes(
        target: parent.treeViewNodes,
        nodes: _resolveLoadedNodes(result),
        parent: parent,
      );
      parent.treeViewNodeChildrenLoaded = true;
      parent.treeViewNodeHasMoreChildren = result.hasMore;
      parent.treeViewNodeHasLazyChildren =
          result.hasMore || parent.treeViewNodes.isNotEmpty;
      _applySelectionFromPendingValue();

      if (searchTerm.isNotEmpty) {
        _applyLocalFilter();
      } else {
        _refreshVisibleRootNodes();
      }
    } finally {
      if (!_destroyed) {
        parent.treeViewNodeIsLoadingChildren = false;
        _markForCheck();
        _scheduleOverlayUpdate();
      }
    }
  }

  void _appendNodes({
    required List<TreeViewNode> target,
    required List<TreeViewNode> nodes,
    required TreeViewNode? parent,
  }) {
    for (final node in nodes) {
      node.parent = parent;
      node.treeViewNodeLevel =
          parent == null ? 0 : parent.treeViewNodeLevel + 1;
      node.treeViewNodeFilter = true;
      node.treeViewNodeIsSelected = _containsValue(_pendingModelValue, node);
      target.add(node);
    }
  }

  List<TreeViewNode> _resolveLoadedNodes(TreeViewLoadResult result) {
    if (result.items != null) {
      return _settings.normalize(result.items);
    }

    return result.nodes;
  }

  void _applyInitialData() {
    rootNodes = <TreeViewNode>[];
    _appendNodes(target: rootNodes, nodes: _staticNodes, parent: null);
    _applySelectionFromPendingValue();
    _applyLocalFilter();
  }

  void _applySelectionFromPendingValue() {
    if (_pendingModelValue == null) {
      if (multiple) {
        selectedNodes = <TreeViewNode>[];
      }
      return;
    }

    if (multiple) {
      _clearSelectedState(rootNodes);
      selectedNodes = _findNodesByValues(rootNodes, _pendingModelValue);
      for (final node in selectedNodes) {
        node.treeViewNodeIsSelected = true;
      }
      return;
    }

    selectedNode = _findNodeByValue(rootNodes, _pendingModelValue);
  }

  TreeViewNode? _findNodeByValue(List<TreeViewNode> nodes, dynamic value) {
    if (value == null) {
      return null;
    }

    for (final node in nodes) {
      if (_selectedValueFor(node) == value || identical(node, value)) {
        return node;
      }

      final childMatch = _findNodeByValue(node.treeViewNodes, value);
      if (childMatch != null) {
        return childMatch;
      }
    }
    return null;
  }

  dynamic _selectedValueFor(TreeViewNode node) {
    if (returnNode) {
      return node;
    }
    return node.value ?? node;
  }

  List<dynamic> _selectedValues() {
    return selectedNodes
        .map<dynamic>((node) => _selectedValueFor(node))
        .toList(growable: false);
  }

  bool _containsValue(dynamic currentValue, TreeViewNode node) {
    if (!multiple || currentValue is! List) {
      return false;
    }
    final nodeValue = _selectedValueFor(node);
    return currentValue
        .any((value) => value == nodeValue || identical(value, node));
  }

  bool _isNodeSelected(TreeViewNode node) {
    return selectedNodes.any((selected) => identical(selected, node));
  }

  void _clearSelectedState(List<TreeViewNode> nodes) {
    for (final node in nodes) {
      node.treeViewNodeIsSelected = false;
      _clearSelectedState(node.treeViewNodes);
    }
  }

  List<TreeViewNode> _findNodesByValues(
      List<TreeViewNode> nodes, dynamic values) {
    if (values is! List || values.isEmpty) {
      return <TreeViewNode>[];
    }

    final found = <TreeViewNode>[];

    void walk(List<TreeViewNode> current) {
      for (final node in current) {
        final nodeValue = _selectedValueFor(node);
        if (values
            .any((value) => value == nodeValue || identical(value, node))) {
          found.add(node);
        }
        walk(node.treeViewNodes);
      }
    }

    walk(nodes);
    return found;
  }

  void _applyLocalFilter() {
    final normalizedTerm = searchTerm.trim();
    if (normalizedTerm.isEmpty) {
      _resetNodeVisibility(rootNodes);
      _refreshVisibleRootNodes();
      return;
    }

    for (final node in rootNodes) {
      _filterNode(node, normalizedTerm);
    }

    _refreshVisibleRootNodes();
  }

  bool _filterNode(TreeViewNode node, String term) {
    final normalizedTerm =
        EssentialCoreUtils.removerAcentos(term).toLowerCase();
    final selfMatch = searchMatcher?.call(node, normalizedTerm) ??
        EssentialCoreUtils.removerAcentos(resolvedNodeLabel(node))
            .toLowerCase()
            .contains(normalizedTerm);
    var childMatch = false;

    for (final child in node.treeViewNodes) {
      child.parent = node;
      childMatch = _filterNode(child, normalizedTerm) || childMatch;
    }

    final visible = selfMatch || childMatch;
    node.treeViewNodeFilter = visible;
    if (childMatch) {
      node.treeViewNodeIsCollapse = false;
    }
    return visible;
  }

  void _resetNodeVisibility(List<TreeViewNode> nodes) {
    for (final node in nodes) {
      node.treeViewNodeFilter = true;
      _resetNodeVisibility(node.treeViewNodes);
    }
  }

  void _refreshVisibleRootNodes() {
    visibleRootNodes = rootNodes
        .where((node) => node.treeViewNodeFilter)
        .toList(growable: false);
  }

  void _ensureOverlay() {
    if (container != 'body') {
      return;
    }

    final reference = triggerButtonElement;
    final floating = dropdownPanelElement;
    if (_overlay != null || reference == null || floating == null) {
      return;
    }

    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: reference,
      floatingElement: floating,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'LiTreeviewSelectComponent',
        hostZIndex: '10000',
        floatingZIndex: '1056',
      ),
      popperOptions: PopperOptions(
        placement: 'bottom-start',
        fallbackPlacements: <String>[
          'top-start',
          'bottom-end',
          'top-end',
        ],
        strategy: PopperStrategy.fixed,
        padding: PopperInsets.all(8),
        offset: PopperOffset(mainAxis: 4),
        matchReferenceWidth: true,
        onLayout: _handleOverlayLayout,
      ),
    );
  }

  void _handleOverlayLayout(PopperLayout layout) {
    normalizeOverlayVerticalPosition(
      floatingElement: dropdownPanelElement,
      layout: layout,
    );
    _syncPopupMaxHeight();
  }

  void _scheduleOverlayUpdate() {
    if (!dropdownOpen || _overlayRelayoutPending || container != 'body') {
      return;
    }

    _overlayRelayoutPending = true;
    html.window.requestAnimationFrame((_) {
      _overlayRelayoutPending = false;
      if (!dropdownOpen) {
        return;
      }

      _overlay?.update();
      _syncPopupMaxHeight();
    });
  }

  void _syncPopupMaxHeight() {
    final popup = dropdownPanelElement;
    final scroll = scrollContainerElement;
    final trigger = triggerButtonElement;
    if (popup == null || scroll == null || trigger == null) {
      return;
    }

    final viewportHeight = html.window.innerHeight?.toDouble() ?? 900.0;
    final triggerRect = trigger.getBoundingClientRect();
    final popupRect = popup.getBoundingClientRect();
    final opensUpward = popupRect.top < triggerRect.top;
    final availableHeight = opensUpward
        ? triggerRect.top - 16
        : viewportHeight - triggerRect.bottom - 16;
    final nextHeight = math.max(160.0, availableHeight - 8);
    scroll.style.maxHeight = '${nextHeight.floor()}px';
  }

  void _bindDocumentListeners() {
    _documentClickSubscription ??= html.document.onClick.listen((event) {
      if (!dropdownOpen) {
        return;
      }

      final target = event.target;
      if (target is! html.Node) {
        closeDropdown();
        return;
      }

      final clickedTrigger = triggerButtonElement?.contains(target) ?? false;
      final clickedPanel = dropdownPanelElement?.contains(target) ?? false;
      if (!clickedTrigger && !clickedPanel) {
        closeDropdown();
      }
    });

    _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
      if (!dropdownOpen) {
        return;
      }

      if (event.key == 'Escape') {
        event.preventDefault();
        closeDropdown();
      }
    });
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription?.cancel();
    _documentKeySubscription = null;
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  void _markTouched() {
    if (_touched) {
      _touchCallback();
      return;
    }
    _touched = true;
    _touchCallback();
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }
}
