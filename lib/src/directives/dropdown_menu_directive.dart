import 'dart:js_interop';
import 'dart:async';
import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';
import 'package:popper/popper.dart';

import '../core/overlay_positioning.dart';
import '../web_support/zone_dom_callbacks.dart';

@Directive(selector: '[liDropdownMenuPosition]')
class LiDropdownMenuPositionDirective implements AfterContentInit, OnDestroy {
  final web.Element rootElement;
  web.Element? _triggerElement;
  web.Element? _menuElement;
  PopperAnchoredOverlay? _overlay;
  StreamSubscription<web.KeyboardEvent>? _documentKeyDownSS;
  bool _overlayRelayoutPending = false;

  @Input('liDropdownMenuPosition')
  String xPlacement = 'bottom-end';

  @Input()
  String liDropdownMenuPositionContainer = 'body';

  StreamSubscription? globalBodyClickSS;

  LiDropdownMenuPositionDirective(this.rootElement);

  bool get _usesBodyOverlay =>
      liDropdownMenuPositionContainer.trim().toLowerCase() == 'body';

  List<String> get _fallbackPlacements {
    switch (xPlacement.trim().toLowerCase()) {
      case 'bottom-start':
        return const <String>['top-start', 'bottom-end', 'top-end'];
      case 'top-start':
        return const <String>['bottom-start', 'top-end', 'bottom-end'];
      case 'top-end':
        return const <String>['bottom-end', 'top-start', 'bottom-start'];
      case 'left-start':
      case 'start':
      case 'dropstart':
        return const <String>['right-start', 'bottom-start', 'top-start'];
      case 'right-start':
      case 'end':
      case 'dropend':
        return const <String>['left-start', 'bottom-end', 'top-end'];
      case 'bottom-end':
      default:
        return const <String>['top-end', 'bottom-start', 'top-start'];
    }
  }

  @override
  void ngAfterContentInit() {
    _triggerElement = rootElement.querySelector('.li-dropdown-trigger');
    _menuElement = rootElement.querySelector('.dropdown-menu');
    rootElement.onClick.listen(onRootClick);

    globalBodyClickSS =
        web.document.querySelector('body')?.onClick.listen(onBodyClick);
    _documentKeyDownSS = web.EventStreamProviders.keyDownEvent
        .forTarget(web.document)
        .listen(onDocumentKeyDown);
    _setExpanded(false);
  }

  void onRootClick(web.MouseEvent event) {
    final target = event.target;
    if (!(target?.isA<web.Element>() ?? false)) {
      return;
    }

    if (_triggerElement != null &&
        _triggerElement!.contains(target as web.Node?)) {
      event.preventDefault();
      event.stopPropagation();
      toogle();
      return;
    }

    if ((target as web.Element).closest('.li-dropdown-close') != null) {
      hide();
    }
  }

  void toogle() {
    final shouldOpen = !rootElement.classList.contains('show');
    rootElement.classList.toggle('show', shouldOpen);
    final dropdownMenu = _menuElement;
    if (dropdownMenu != null) {
      dropdownMenu.classList.toggle('show', shouldOpen);
      _setExpanded(shouldOpen);
      if (!shouldOpen) {
        _overlayRelayoutPending = false;
        _overlay?.stopAutoUpdate();
        return;
      }

      if (_usesBodyOverlay) {
        _ensureOverlay();
        _overlay?.startAutoUpdate();
        _scheduleOverlayUpdate();
      } else {
        final style = (dropdownMenu as web.HTMLElement).style;
        style.removeProperty('top');
        style.removeProperty('left');
      }
    }
  }

  void hide() {
    rootElement.classList.remove('show');
    final dropdownMenu = _menuElement;
    if (dropdownMenu != null) {
      dropdownMenu.classList.remove('show');
      if (!_usesBodyOverlay) {
        final style = (dropdownMenu as web.HTMLElement).style;
        style.removeProperty('top');
        style.removeProperty('left');
      }
    }
    _overlayRelayoutPending = false;
    _overlay?.stopAutoUpdate();
    _setExpanded(false);
  }

  void onBodyClick(web.MouseEvent event) {
    var target = event.target as web.Element;
    final clickedTrigger = _triggerElement?.contains(target) ?? false;
    final clickedMenu = _menuElement?.contains(target) ?? false;
    final clickedCloseAction = target.closest('.li-dropdown-close') != null;

    if (clickedMenu && clickedCloseAction) {
      hide();
      return;
    }

    if (!clickedTrigger && !clickedMenu) {
      hide();
    }
  }

  void onDocumentKeyDown(web.KeyboardEvent event) {
    if (!rootElement.classList.contains('show')) {
      return;
    }

    if (event.key == 'Escape') {
      event.preventDefault();
      hide();
      (_triggerElement as web.HTMLElement?)?.focus();
    }
  }

  void _ensureOverlay() {
    final reference = _triggerElement;
    final floating = _menuElement;
    if (!_usesBodyOverlay ||
        _overlay != null ||
        reference == null ||
        floating == null) {
      return;
    }

    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: reference,
      floatingElement: floating,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'LiDropdownMenuPositionDirective',
        hostZIndex: '10000',
        floatingZIndex: '1056',
      ),
      popperOptions: PopperOptions(
        placement: xPlacement,
        fallbackPlacements: _fallbackPlacements,
        strategy: PopperStrategy.fixed,
        padding: const PopperInsets.all(8),
        offset: const PopperOffset(mainAxis: 4),
        onLayout: _handleOverlayLayout,
      ),
    );
  }

  void _handleOverlayLayout(PopperLayout layout) {
    normalizeOverlayVerticalPosition(
      floatingElement: _menuElement,
      layout: layout,
      gap: 4,
    );
  }

  void _scheduleOverlayUpdate() {
    if (!_usesBodyOverlay ||
        _overlayRelayoutPending ||
        !rootElement.classList.contains('show')) {
      return;
    }

    _overlayRelayoutPending = true;
    requestAnimationFrameInZone((_) {
      _overlayRelayoutPending = false;
      if (!rootElement.classList.contains('show')) {
        return;
      }

      _overlay?.update();
    });
  }

  void _setExpanded(bool expanded) {
    _triggerElement?.setAttribute('aria-expanded', expanded ? 'true' : 'false');
  }

  @override
  void ngOnDestroy() {
    globalBodyClickSS?.cancel();
    _documentKeyDownSS?.cancel();
    _overlay?.stopAutoUpdate();
    _overlay?.dispose();
  }
}
