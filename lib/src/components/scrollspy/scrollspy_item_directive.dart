import 'dart:async';

import 'dart:html' as html;

import 'package:ngdart/angular.dart';

import 'scrollspy_directive.dart';
import 'scrollspy_menu_directive.dart';
import 'scrollspy_service.dart';

@Directive(
  selector: '[liScrollSpyItem]',
  exportAs: 'liScrollSpyItem',
)
class LiScrollSpyItemDirective implements OnInit, OnDestroy {
  LiScrollSpyItemDirective(
    @Optional() this._menu, [
    @Optional() this._nearestScrollSpy,
  ]);

  final LiScrollSpyMenuDirective? _menu;
  final LiScrollSpyDirective? _nearestScrollSpy;

  StreamSubscription<String>? _activeSubscription;
  LiScrollSpyRef? _scrollSpyRef;
  bool _active = false;
  String _fragment = '';
  String? _parent;

  @Input('liScrollSpyItem')
  set data(Object? value) {
    if (value is LiScrollSpyRef) {
      _scrollSpyRef = value;
      return;
    }

    if (value is List && value.isNotEmpty) {
      final reference = value[0];
      if (reference is LiScrollSpyRef) {
        _scrollSpyRef = reference;
      }
      if (value.length > 1 && value[1] != null) {
        fragment = value[1].toString();
      }
      if (value.length > 2 && value[2] != null) {
        parent = value[2].toString();
      }
      return;
    }

    if (value != null) {
      fragment = value.toString();
    }
  }

  @Input()
  set fragment(String? value) {
    _fragment = value?.trim() ?? '';
  }

  String get fragment => _fragment;

  @Input()
  set parent(String? value) {
    _parent = value?.trim();
  }

  String? get parent => _parent;

  @HostBinding('class.active')
  bool get hostActive => _active;

  @override
  void ngOnInit() {
    if (_menu != null) {
      return;
    }

    final scrollSpy = _resolvedScrollSpy;
    if (scrollSpy == null) {
      return;
    }

    _activeSubscription = scrollSpy.active$.listen((activeId) {
      _active = activeId == fragment;
    });
    _active = scrollSpy.active == fragment;
  }

  @HostListener('click', ['\$event'])
  void onClick(html.MouseEvent event) {
    if (fragment.isEmpty) {
      return;
    }

    scrollTo();
  }

  bool isActive() => _active;

  void scrollTo({LiScrollToOptions? options}) {
    final scrollSpy = _resolvedScrollSpy;
    if (scrollSpy == null || fragment.isEmpty) {
      return;
    }

    scrollSpy.scrollTo(fragment, options: options);
  }

  void setActiveState(bool value) {
    _active = value;
  }

  LiScrollSpyRef? get _resolvedScrollSpy =>
      _scrollSpyRef ?? _menu ?? _nearestScrollSpy;

  @override
  void ngOnDestroy() {
    _activeSubscription?.cancel();
  }
}
