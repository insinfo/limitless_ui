import 'dart:async';

import 'package:ngdart/angular.dart';

import 'accordion_item_directive.dart';

/// Declarative accordion container similar to ng-bootstrap.
@Directive(
  selector: '[liAccordion]',
  exportAs: 'liAccordion',
)
class LiAccordionDirective implements AfterContentInit {
  @ContentChildren(LiAccordionItemDirective, descendants: false)
  List<LiAccordionItemDirective> items = <LiAccordionItemDirective>[];

  final StreamController<String> _showController =
      StreamController<String>.broadcast();
  final StreamController<String> _shownController =
      StreamController<String>.broadcast();
  final StreamController<String> _hideController =
      StreamController<String>.broadcast();
  final StreamController<String> _hiddenController =
      StreamController<String>.broadcast();

  @Input()
  bool closeOthers = false;

  @Input()
  bool destroyOnHide = true;

  @Input()
  bool animation = true;

  @Input()
  bool flush = false;

  @Output()
  Stream<String> get show => _showController.stream;

  @Output()
  Stream<String> get shown => _shownController.stream;

  @Output()
  Stream<String> get hide => _hideController.stream;

  @Output()
  Stream<String> get hidden => _hiddenController.stream;

  @HostBinding('class.accordion')
  bool hostAccordionClass = true;

  @HostBinding('class.accordion-flush')
  bool get hostFlushClass => flush;

  @override
  void ngAfterContentInit() {
    for (final item in items) {
      item.attachAccordion(this);
    }

    _normalizeInitialState();
  }

  void toggle(String itemId) {
    _getItem(itemId)?.toggle();
  }

  void expand(String itemId) {
    _getItem(itemId)?.expand();
  }

  void collapse(String itemId) {
    _getItem(itemId)?.collapse();
  }

  void expandAll() {
    if (closeOthers) {
      final firstCollapsed = items.cast<LiAccordionItemDirective?>().firstWhere(
            (item) => item != null && item.collapsed,
            orElse: () => items.isNotEmpty ? items.first : null,
          );
      firstCollapsed?.expand();
      return;
    }

    for (final item in items) {
      item.expand();
    }
  }

  void collapseAll() {
    for (final item in items) {
      item.collapse();
    }
  }

  bool isExpanded(String itemId) => !(_getItem(itemId)?.collapsed ?? true);

  bool ensureCanExpand(LiAccordionItemDirective toExpand) {
    if (!closeOthers) {
      return true;
    }

    for (final item in items) {
      if (!identical(item, toExpand) && !item.collapsed) {
        item.collapse();
      }
    }

    return true;
  }

  void emitShow(String itemId) => _showController.add(itemId);

  void emitShown(String itemId) => _shownController.add(itemId);

  void emitHide(String itemId) => _hideController.add(itemId);

  void emitHidden(String itemId) => _hiddenController.add(itemId);

  LiAccordionItemDirective? _getItem(String itemId) {
    for (final item in items) {
      if (item.id == itemId) {
        return item;
      }
    }
    return null;
  }

  void _normalizeInitialState() {
    if (!closeOthers) {
      return;
    }

    LiAccordionItemDirective? expandedItem;
    for (final item in items) {
      if (item.collapsed) {
        continue;
      }

      expandedItem ??= item;
      if (!identical(expandedItem, item)) {
        item.setCollapsed(true, emitEvents: false, emitCollapsedChange: false);
      }
    }
  }
}
