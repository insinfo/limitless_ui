import 'dart:async';

import 'package:ngdart/angular.dart';

import 'scrollspy_directive.dart';
import 'scrollspy_item_directive.dart';
import 'scrollspy_service.dart';

@Directive(
  selector: '[liScrollSpyMenu]',
)
class LiScrollSpyMenuDirective
    implements AfterContentInit, OnDestroy, LiScrollSpyRef {
  LiScrollSpyMenuDirective([@Optional() this._nearestScrollSpy]);

  final LiScrollSpyDirective? _nearestScrollSpy;

  StreamSubscription<String>? _activeSubscription;
  LiScrollSpyRef? _scrollSpyRef;
  Map<String, LiScrollSpyItemDirective> _itemsByFragment =
      <String, LiScrollSpyItemDirective>{};

  @ContentChildren(LiScrollSpyItemDirective)
  List<LiScrollSpyItemDirective> items = const <LiScrollSpyItemDirective>[];

  @Input('liScrollSpyMenu')
  set scrollSpy(Object? value) {
    if (value is LiScrollSpyRef) {
      _scrollSpyRef = value;
    }
  }

  LiScrollSpyRef? get _resolvedScrollSpy => _scrollSpyRef ?? _nearestScrollSpy;

  @override
  String get active => _resolvedScrollSpy?.active ?? '';

  @override
  Stream<String> get active$ =>
      _resolvedScrollSpy?.active$ ?? const Stream<String>.empty();

  @override
  void scrollTo(Object fragment, {LiScrollToOptions? options}) {
    _resolvedScrollSpy?.scrollTo(fragment, options: options);
  }

  @override
  void ngAfterContentInit() {
    _rebuildItemMap();

    final scrollSpy = _resolvedScrollSpy;
    if (scrollSpy == null) {
      return;
    }

    _activeSubscription = scrollSpy.active$.listen(_applyActiveState);
    _applyActiveState(scrollSpy.active);
  }

  void _rebuildItemMap() {
    _itemsByFragment = <String, LiScrollSpyItemDirective>{};
    for (final item in items) {
      if (item.fragment.isNotEmpty) {
        _itemsByFragment[item.fragment] = item;
      }
    }
  }

  void _applyActiveState(String activeId) {
    for (final item in items) {
      item.setActiveState(false);
    }

    var currentId = activeId;
    while (currentId.isNotEmpty) {
      final item = _itemsByFragment[currentId];
      if (item == null) {
        break;
      }

      item.setActiveState(true);
      currentId = item.parent ?? '';
    }
  }

  @override
  void ngOnDestroy() {
    _activeSubscription?.cancel();
  }
}
