// Regression test for the bug where a `li-dropdown-menu` (e.g. the PDF viewer's
// zoom / actions / print menus) does not appear once the PDF viewer enters
// fullscreen.
//
// Root cause: when `container="body"` the menu is portaled to `document.body`.
// The browser fullscreen "top layer" only paints the subtree of the element
// that requested fullscreen (the viewer host), so a menu living under
// `document.body` is painted *underneath* the fullscreen surface and is
// effectively invisible. `li-pdf-viewer` works around this by flipping
// `[container]` from `body` to `inline` while fullscreen is active
// (`dropdownOverlayContainer` in pdf_viewer_component.dart), which requires the
// dropdown to (a) actually render inline inside its own DOM subtree when the
// container input changes, and (b) dispose the stale body portal so nothing is
// left behind under `document.body`.
//
// This test reproduces that container flip against a `#fullscreen-host` element
// that stands in for the viewer host, and asserts the open menu ends up *inside*
// that host (i.e. inside the fullscreen top layer) with no leftover body portal.
//
// Runs on dev.34+ (fix present) and fails on dev.33 (the version the SALI app
// currently pins), which is exactly the bug the user still sees.
//
// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/dropdown_menu/li_dropdown_menu_fullscreen_container_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_dropdown_menu_fullscreen_container_test.template.dart' as ng;

@Component(
  selector: 'fullscreen-dropdown-test-host',
  template: '''
    <div #fullscreenHost id="fullscreen-host">
      <li-dropdown-menu
          #menu
          [container]="container"
          [options]="options"
          [value]="selectedValue"
          ariaLabel="fs-zoom"
          triggerLabel="Zoom"
          menuClass=""
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>
    </div>
  ''',
  directives: [coreDirectives, LiDropdownMenuComponent],
)
class FullscreenDropdownTestHostComponent {
  @ViewChild('menu')
  LiDropdownMenuComponent? menu;

  /// Mirrors `LiPdfViewerComponent.dropdownOverlayContainer`:
  /// `body` when not fullscreen, `inline` while fullscreen is active.
  String container = 'body';
  String selectedValue = 'auto';

  final List<LiDropdownMenuOption> options = const <LiDropdownMenuOption>[
    LiDropdownMenuOption(value: 'auto', label: 'Zoom automático'),
    LiDropdownMenuOption(value: 'actual', label: 'Tamanho real'),
    LiDropdownMenuOption(value: 'page-fit', label: 'Ajustar à janela'),
    LiDropdownMenuOption(value: 'page-width', label: 'Largura da página'),
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<FullscreenDropdownTestHostComponent>(
    ng.FullscreenDropdownTestHostComponentNgFactory,
  );

  test(
    'baseline: container="body" portals the open menu outside the '
    'fullscreen host (this is what breaks the fullscreen PDF viewer)',
    () async {
      final fixture = await testBed.create();
      await _settle(fixture);

      final host = _fullscreenHost(fixture);
      _openMenu(fixture);
      await _settle(fixture);

      final shownMenu = _onlyShownMenu();
      // With a body portal the menu escapes to `document.body`, i.e. it is NOT
      // a descendant of the element that would go fullscreen. That is precisely
      // why it disappears behind the browser fullscreen top layer.
      expect(host.contains(shownMenu), isFalse,
          reason: 'body-container menu should live under document.body');
      expect(
        html.document.querySelector(
            '.LiDropdownMenuComponent .li-dropdown-menu__menu.show'),
        isNotNull,
        reason: 'body-container menu renders inside a body portal host',
      );
    },
  );

  test(
    'entering fullscreen (container "body" -> "inline") renders the menu '
    'inside the fullscreen host with no leftover body portal',
    () async {
      final fixture = await testBed.create();
      await _settle(fixture);

      // Simulate the PDF viewer entering fullscreen: the viewer flips
      // `[container]` from `body` to `inline` before the user opens the menu.
      await fixture.update((host) => host.container = 'inline');
      await _settle(fixture);

      final host = _fullscreenHost(fixture);
      _openMenu(fixture);
      await _settle(fixture);

      final shownMenu = _onlyShownMenu();

      // The open menu must live INSIDE the fullscreen host so it is painted in
      // the browser fullscreen top layer.
      expect(host.contains(shownMenu), isTrue,
          reason: 'fullscreen menu must render inline inside the viewer host');

      // No stale body portal may keep a shown menu under document.body.
      expect(
        html.document.querySelectorAll(
            '.LiDropdownMenuComponent .li-dropdown-menu__menu.show'),
        isEmpty,
        reason: 'switching to inline must not leave a shown body portal',
      );
    },
  );

  test(
    'opening in body, then entering fullscreen disposes the stale body '
    'portal so the reopened menu is inline and visible',
    () async {
      final fixture = await testBed.create();
      await _settle(fixture);
      final instance = fixture.assertOnlyInstance;

      // 1) Not fullscreen: open then close a body-portal menu.
      _openMenu(fixture);
      await _settle(fixture);
      expect(
        html.document.querySelector('.LiDropdownMenuComponent'),
        isNotNull,
        reason: 'body portal host is created on first open',
      );

      await fixture.update((_) => instance.menu!.closeDropdown());
      await _settle(fixture);

      // 2) Enter fullscreen: flip the container. The stale body portal host
      //    (kept alive after close) must be disposed by the container setter.
      await fixture.update((host) => host.container = 'inline');
      await _settle(fixture);

      expect(
        html.document.querySelector('body > .LiDropdownMenuComponent'),
        isNull,
        reason: 'stale body portal host must be disposed on container change',
      );

      // 3) Reopen in fullscreen: the menu must render inline and visible.
      _openMenu(fixture);
      await _settle(fixture);

      final host = _fullscreenHost(fixture);
      final shownMenu = _onlyShownMenu();
      expect(host.contains(shownMenu), isTrue);
      expect(
        html.document.querySelectorAll(
            '.LiDropdownMenuComponent .li-dropdown-menu__menu.show'),
        isEmpty,
      );
    },
  );

  test(
    'exiting fullscreen (container "inline" -> "body") restores the body '
    'portal without leaving an orphan inline menu',
    () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.container = 'inline');
      await _settle(fixture);

      final host = _fullscreenHost(fixture);

      _openMenu(fixture);
      await _settle(fixture);
      expect(host.contains(_onlyShownMenu()), isTrue);

      await fixture.update((instance) => instance.menu!.closeDropdown());
      await _settle(fixture);

      // Exit fullscreen -> back to body portal.
      await fixture.update((instance) => instance.container = 'body');
      await _settle(fixture);

      _openMenu(fixture);
      await _settle(fixture);

      final shownMenu = _onlyShownMenu();
      expect(host.contains(shownMenu), isFalse,
          reason: 'body-container menu must portal back to document.body');
      expect(
        html.document.querySelector(
            '.LiDropdownMenuComponent .li-dropdown-menu__menu.show'),
        isNotNull,
      );
    },
  );
}

html.Element _fullscreenHost(
  NgTestFixture<FullscreenDropdownTestHostComponent> fixture,
) {
  final host = fixture.rootElement.querySelector('#fullscreen-host');
  expect(host, isNotNull, reason: 'fullscreen host element must exist');
  return host as html.Element;
}

void _openMenu(NgTestFixture<FullscreenDropdownTestHostComponent> fixture) {
  final trigger = fixture.rootElement.querySelector('[aria-label="fs-zoom"]')
      as html.ButtonElement;
  trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
}

html.Element _onlyShownMenu() {
  final shown = html.document.querySelectorAll('.li-dropdown-menu__menu.show');
  expect(shown, hasLength(1),
      reason: 'exactly one dropdown menu should be visible');
  return shown.first;
}

Future<void> _settle(
  NgTestFixture<FullscreenDropdownTestHostComponent> fixture,
) async {
  await fixture.update((_) {});
  await _nextAnimationFrame();
  await _nextAnimationFrame();
  // The container setter reopens via Timer.run when the menu was open; give
  // microtasks/timers a chance to flush before asserting.
  await Future<void>.delayed(Duration.zero);
  await fixture.update((_) {});
}

Future<void> _nextAnimationFrame() {
  final completer = Completer<void>();
  html.window.requestAnimationFrame((_) {
    completer.complete();
  });
  return completer.future;
}
