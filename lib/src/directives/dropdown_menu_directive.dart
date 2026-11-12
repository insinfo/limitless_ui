import 'dart:async';
import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:popper/popper.dart';
import '../core/overlay_layers.dart';

import '../core/outside_click.dart';
import '../core/overlay_positioning.dart';

@Directive(selector: '[liDropdownMenuPosition]')
class LiDropdownMenuPositionDirective implements AfterContentInit, OnDestroy {
  final Element rootElement;
  Element? _triggerElement;
  Element? _menuElement;
  PopperAnchoredOverlay? _overlay;

  /// Re-runs the layout when the menu or the trigger changes size while open.
  late final LiOverlayResizeWatch _resizeWatch =
      LiOverlayResizeWatch(() => _overlay?.update());
  StreamSubscription<KeyboardEvent>? _documentKeyDownSS;
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

    globalBodyClickSS = listenOutsideClick(onBodyClick);
    _documentKeyDownSS = document.onKeyDown.listen(onDocumentKeyDown);
    _setExpanded(false);
  }

  void onRootClick(MouseEvent event) {
    final target = event.target;
    if (target is! Element) {
      return;
    }

    if (_triggerElement != null && _triggerElement!.contains(target)) {
      event.preventDefault();
      event.stopPropagation();
      toogle();
      return;
    }

    if (target.closest('.li-dropdown-close') != null) {
      hide();
    }
  }

  void toogle() {
    final shouldOpen = !rootElement.classes.contains('show');
    rootElement.classes.toggle('show', shouldOpen);
    final dropdownMenu = _menuElement;
    if (dropdownMenu != null) {
      dropdownMenu.classes.toggle('show', shouldOpen);
      _setExpanded(shouldOpen);
      if (!shouldOpen) {
        _overlayRelayoutPending = false;
        _overlay?.stopAutoUpdate();
        _resizeWatch.disconnect();
        resetOverlayViewportConstraints(floatingElement: dropdownMenu);
        return;
      }

      if (_usesBodyOverlay) {
        _ensureOverlay();
        _overlay?.startAutoUpdate();
        _resizeWatch.observe(<Element?>[_triggerElement, dropdownMenu]);
        _scheduleOverlayUpdate();
      } else {
        dropdownMenu.style.removeProperty('top');
        dropdownMenu.style.removeProperty('left');
      }
    }
  }

  void hide() {
    rootElement.classes.remove('show');
    final dropdownMenu = _menuElement;
    if (dropdownMenu != null) {
      dropdownMenu.classes.remove('show');
      resetOverlayViewportConstraints(floatingElement: dropdownMenu);
      if (!_usesBodyOverlay) {
        dropdownMenu.style.removeProperty('top');
        dropdownMenu.style.removeProperty('left');
      }
    }
    _overlayRelayoutPending = false;
    _overlay?.stopAutoUpdate();
    _resizeWatch.disconnect();
    _setExpanded(false);
  }

  void onBodyClick(MouseEvent event) {
    final target = event.target;
    if (target is! Element) {
      hide();
      return;
    }

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

  void onDocumentKeyDown(KeyboardEvent event) {
    if (!rootElement.classes.contains('show')) {
      return;
    }

    if (event.key == 'Escape') {
      event.preventDefault();
      hide();
      _triggerElement?.focus();
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
      portalOptions: resolveModalAwarePortalOptions(
        hostClassName: 'LiDropdownMenuPositionDirective',
        referenceElement: reference,
        baseHostZIndex: LiOverlayLayers.anchoredMenu,
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

  /// Puts the menu on the side [xPlacement] asks for when it fits, on the
  /// other one when only that fits, otherwise on the roomier side capped and
  /// scrolling; always 4px from the trigger.
  void _handleOverlayLayout(PopperLayout layout) {
    placeAnchoredOverlay(
      floatingElement: _menuElement,
      layout: layout,
      preferredSide:
          xPlacement.trim().toLowerCase().startsWith('top') ? 'top' : 'bottom',
      gap: 4,
    );
  }

  void _scheduleOverlayUpdate() {
    if (!_usesBodyOverlay ||
        _overlayRelayoutPending ||
        !rootElement.classes.contains('show')) {
      return;
    }

    _overlayRelayoutPending = true;
    window.requestAnimationFrame((_) {
      _overlayRelayoutPending = false;
      if (!rootElement.classes.contains('show')) {
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
    _resizeWatch.disconnect();
    _overlay?.stopAutoUpdate();
    _overlay?.dispose();
  }
}
