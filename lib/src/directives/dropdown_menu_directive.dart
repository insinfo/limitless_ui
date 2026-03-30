import 'dart:async';
import 'dart:html';
import 'dart:math' as math;

import 'package:ngdart/angular.dart';

@Directive(selector: '[dropdownmenu]') //dropdownmenu
class DropdownMenuDirective implements AfterContentInit, OnDestroy {
  final Element rootElement;
  Element? _triggerElement;

  @Input('dropdownmenu')
  String xPlacement = 'bottom-end';

  StreamSubscription? globalBodyClickSS;

  DropdownMenuDirective(this.rootElement);

  @override
  void ngAfterContentInit() {
    _triggerElement = rootElement.querySelector('.li-dropdown-trigger');
    rootElement.onClick.listen(onRootClick);

    globalBodyClickSS =
        document.querySelector('body')?.onClick.listen(onBodyClick);
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
    var dropdownMenu = rootElement.querySelector('.dropdown-menu');
    if (dropdownMenu != null) {
      dropdownMenu.classes.toggle('show', shouldOpen);
      _setExpanded(shouldOpen);
      if (!shouldOpen) {
        dropdownMenu.style.removeProperty('top');
        dropdownMenu.style.removeProperty('left');
        return;
      }

      var rectRoot = rootElement.getBoundingClientRect();
      var rectMenu = dropdownMenu.getBoundingClientRect();

      int vw =
          math.max(document.documentElement!.clientWidth, window.innerWidth!);
      int vh =
          math.max(document.documentElement!.clientHeight, window.innerHeight!);

      var halfViewportHeight = vh / 2;

      var x = (rectMenu.width + rectRoot.left) >= (vw - rectMenu.width)
          ? ((vw - rectMenu.width) - rectRoot.left) - (rectMenu.width / 2)
          : 0;

      num y = rectRoot.height + 4;
      if (rectRoot.top >= halfViewportHeight) {
        y = (rectMenu.height + 4) * -1;
      }

      dropdownMenu.style.top = '${y}px';
      dropdownMenu.style.left = '${x}px';
    }
  }

  void hide() {
    rootElement.classes.remove('show');
    var dropdownMenu = rootElement.querySelector('.dropdown-menu');
    if (dropdownMenu != null) {
      dropdownMenu.classes.remove('show');
      dropdownMenu.style.removeProperty('top');
      dropdownMenu.style.removeProperty('left');
    }
    _setExpanded(false);
  }

  void onBodyClick(MouseEvent event) {
    var target = event.target as Element;
    var hasDescendant = rootElement.contains(target);
    if (!hasDescendant) {
      hide();
    }
  }

  void _setExpanded(bool expanded) {
    _triggerElement?.setAttribute('aria-expanded', expanded ? 'true' : 'false');
  }

  @override
  void ngOnDestroy() {
    globalBodyClickSS?.cancel();
  }
}
