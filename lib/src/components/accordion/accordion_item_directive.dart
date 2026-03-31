import 'dart:async';

import 'package:ngdart/angular.dart';

import 'accordion_collapse_directive.dart';
import 'accordion_directive.dart';

/// Declarative accordion item with public API via `#item="liAccordionItem"`.
@Directive(
  selector: '[liAccordionItem]',
  exportAs: 'liAccordionItem',
)
class LiAccordionItemDirective implements AfterContentInit, OnDestroy {
  LiAccordionItemDirective() {
    _id = 'li-accordion-item-${_nextId++}';
  }

  static int _nextId = 0;

  final StreamController<void> _showController =
      StreamController<void>.broadcast();
  final StreamController<void> _shownController =
      StreamController<void>.broadcast();
  final StreamController<void> _hideController =
      StreamController<void>.broadcast();
  final StreamController<void> _hiddenController =
      StreamController<void>.broadcast();
  final StreamController<void> _renderStateChangedController =
      StreamController<void>.broadcast();
  final StreamController<bool> _collapsedChangeController =
      StreamController<bool>.broadcast();

  StreamSubscription<void>? _shownSubscription;
  StreamSubscription<void>? _hiddenSubscription;

  @ContentChild(LiAccordionCollapseDirective)
  LiAccordionCollapseDirective? collapseDirective;

  LiAccordionDirective? accordion;

  String _id = '';
  bool _collapsed = true;
  bool _transitionInProgress = false;
  bool? _destroyOnHide;

  @Input('liAccordionItem')
  set itemId(String? value) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      _id = normalized;
    }
  }

  String get id => _id;

  String get toggleId => '$id-toggle';

  String get collapseId => '$id-collapse';

  @Input()
  bool disabled = false;

  @Input()
  set collapsed(bool value) {
    setCollapsed(value, emitEvents: false, emitCollapsedChange: false);
  }

  bool get collapsed => _collapsed;

  @Input()
  set destroyOnHide(bool value) {
    _destroyOnHide = value;
    _emitRenderStateChanged();
  }

  bool get destroyOnHide => _destroyOnHide ?? accordion?.destroyOnHide ?? true;

  bool get shouldBeInDom =>
      !_collapsed || _transitionInProgress || !destroyOnHide;

  bool get animation => accordion?.animation ?? true;

  @Output()
  Stream<void> get show => _showController.stream;

  @Output()
  Stream<void> get shown => _shownController.stream;

  @Output()
  Stream<void> get hide => _hideController.stream;

  @Output()
  Stream<void> get hidden => _hiddenController.stream;

  @Output()
  Stream<bool> get collapsedChange => _collapsedChangeController.stream;

  Stream<void> get renderStateChanged => _renderStateChangedController.stream;

  @HostBinding('class.accordion-item')
  bool hostAccordionItemClass = true;

  @HostBinding('attr.id')
  String get hostId => id;

  @override
  void ngAfterContentInit() {
    _bindCollapseDirective();
    _scheduleCollapseSync();
  }

  void attachAccordion(LiAccordionDirective parent) {
    accordion = parent;
    _emitRenderStateChanged();
    _scheduleCollapseSync();
  }

  void toggle() {
    setCollapsed(!_collapsed);
  }

  void expand() {
    setCollapsed(false);
  }

  void collapse() {
    setCollapsed(true);
  }

  void setCollapsed(
    bool value, {
    bool emitEvents = true,
    bool emitCollapsedChange = true,
  }) {
    if (_collapsed == value && !_transitionInProgress) {
      return;
    }

    if (!value && accordion != null && !accordion!.ensureCanExpand(this)) {
      return;
    }

    _collapsed = value;
    _transitionInProgress = animation;

    if (emitCollapsedChange) {
      _collapsedChangeController.add(_collapsed);
    }

    if (emitEvents) {
      if (_collapsed) {
        _hideController.add(null);
        accordion?.emitHide(id);
      } else {
        _showController.add(null);
        accordion?.emitShow(id);
      }
    }

    _scheduleCollapseSync();
    _emitRenderStateChanged();

    if (!animation) {
      _settleImmediately();
    }
  }

  @override
  void ngOnDestroy() {
    _shownSubscription?.cancel();
    _hiddenSubscription?.cancel();
    _showController.close();
    _shownController.close();
    _hideController.close();
    _hiddenController.close();
    _renderStateChangedController.close();
    _collapsedChangeController.close();
  }

  void _bindCollapseDirective() {
    _shownSubscription?.cancel();
    _hiddenSubscription?.cancel();

    final collapse = collapseDirective;
    if (collapse == null) {
      return;
    }

    _shownSubscription = collapse.shown.listen((_) {
      _transitionInProgress = false;
      _shownController.add(null);
      accordion?.emitShown(id);
      _emitRenderStateChanged();
    });

    _hiddenSubscription = collapse.hidden.listen((_) {
      _transitionInProgress = false;
      _hiddenController.add(null);
      accordion?.emitHidden(id);
      _emitRenderStateChanged();
    });
  }

  void _scheduleCollapseSync() {
    final collapse = collapseDirective;
    if (collapse == null) {
      return;
    }

    Future<void>.delayed(Duration.zero, () {
      collapse.updateOptions(animation: animation);
      collapse.setCollapsed(_collapsed);
    });
  }

  void _settleImmediately() {
    _transitionInProgress = false;
    if (_collapsed) {
      _hiddenController.add(null);
      accordion?.emitHidden(id);
      _emitRenderStateChanged();
      return;
    }

    _shownController.add(null);
    accordion?.emitShown(id);
    _emitRenderStateChanged();
  }

  void _emitRenderStateChanged() {
    if (!_renderStateChangedController.isClosed) {
      _renderStateChangedController.add(null);
    }
  }
}
