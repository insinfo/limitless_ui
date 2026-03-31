import 'dart:async';

import 'package:ngdart/angular.dart';

import 'accordion_item_directive.dart';

/// Template-backed accordion body that supports real DOM removal.
@Directive(
  selector: 'template[liAccordionBody]',
)
class LiAccordionBodyTemplateDirective implements OnInit, OnDestroy {
  LiAccordionBodyTemplateDirective(
    this._templateRef,
    this._viewContainerRef,
    this._item,
  );

  final TemplateRef _templateRef;
  final ViewContainerRef _viewContainerRef;
  final LiAccordionItemDirective _item;

  StreamSubscription<void>? _renderStateSubscription;
  bool _viewAttached = false;

  @override
  void ngOnInit() {
    _renderStateSubscription = _item.renderStateChanged.listen((_) {
      _syncView();
    });
    _syncView();
  }

  @override
  void ngOnDestroy() {
    _renderStateSubscription?.cancel();
    _viewContainerRef.clear();
    _viewAttached = false;
  }

  void _syncView() {
    if (_item.shouldBeInDom) {
      if (_viewAttached) {
        return;
      }

      _viewContainerRef.createEmbeddedView(_templateRef);
      _viewAttached = true;
      return;
    }

    if (!_viewAttached) {
      return;
    }

    _viewContainerRef.clear();
    _viewAttached = false;
  }
}
