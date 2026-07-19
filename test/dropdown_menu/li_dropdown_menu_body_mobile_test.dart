// Regression test for the bug where a `li-dropdown-menu` configured with
// BOTH `container="body"` AND a mobile presentation (`mobilePresentation="sheet"`
// or `"modal"`) renders only the backdrop while the menu panel itself is
// invisible or mispositioned (the SALI "Ações"/"Imprimir"/"Gerar" header menus
// on iPhone / Chrome mobile emulation).
//
// Root cause: `container="body"` moves the menu element into a body portal
// (`div.LiDropdownMenuComponent`), but every mobile-presentation style is scoped
// under `:host` in the component SCSS. Angular emulated encapsulation compiles
// `:host .x` to `[_nghost-N] .x[_ngcontent-N]`, which requires the menu to stay
// a DESCENDANT of the host. Once portaled out to `<body>` those rules stop
// matching, so the panel loses `display:flex` and its fixed sheet/modal
// positioning and falls back to Bootstrap `.dropdown-menu.show`
// (`display:block; position:absolute`) at 0,0 — visible as an empty backdrop or
// a broken menu stuck in the top-left corner.
//
// The fix de-scopes the mobile-presentation rules from `:host` so the
// `_ngcontent-N` attribute alone binds them and they survive the move to the
// body portal.
//
// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/dropdown_menu/li_dropdown_menu_body_mobile_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'package:limitless_ui/web_compat.dart' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_dropdown_menu_body_mobile_test.template.dart' as ng;

@Component(
  selector: 'body-mobile-dropdown-test-host',
  template: '''
    <li-dropdown-menu
        #sheetMenu
        container="body"
        [options]="options"
        ariaLabel="body-sheet"
        triggerLabel="Ações"
        menuClass="dropdown-menu-end w-100 w-lg-auto"
        mobilePresentation="sheet"
        mobileBreakpoint="9999px"
        mobileMenuTitle="Ações do processo"
        (valueChange)="selectedValue = \$event">
    </li-dropdown-menu>

    <li-dropdown-menu
        #modalMenu
        container="body"
        [options]="options"
        ariaLabel="body-modal"
        triggerLabel="Gerar"
        menuClass="dropdown-menu-end"
        mobilePresentation="modal"
        mobileBreakpoint="9999px"
        mobileMenuTitle="Gerar"
        (valueChange)="selectedValue = \$event">
    </li-dropdown-menu>
  ''',
  directives: [coreDirectives, LiDropdownMenuComponent],
)
class BodyMobileDropdownTestHostComponent {
  @ViewChild('sheetMenu')
  LiDropdownMenuComponent? sheetMenu;

  @ViewChild('modalMenu')
  LiDropdownMenuComponent? modalMenu;

  String selectedValue = '';

  final List<LiDropdownMenuOption> options = const <LiDropdownMenuOption>[
    LiDropdownMenuOption(value: 'print', label: 'Imprimir capa'),
    LiDropdownMenuOption(value: 'save', label: 'Salvar capa'),
    LiDropdownMenuOption(value: 'sign', label: 'Solicitar assinatura'),
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<BodyMobileDropdownTestHostComponent>(
    ng.BodyMobileDropdownTestHostComponentNgFactory,
  );

  test(
    'body-container bottom sheet stays visible as a fixed panel after being '
    'portaled (not an invisible/absolute Bootstrap dropdown)',
    () async {
      final fixture = await testBed.create();
      await _settle(fixture);

      _openMenu(fixture, 'body-sheet');
      await _settle(fixture);

      // container="body" => the panel is moved into the body portal.
      final menu = html.document.querySelector(
        '.LiDropdownMenuComponent .li-dropdown-menu__menu--mobile-sheet.show',
      );
      expect(menu, isNotNull,
          reason: 'sheet panel must be portaled into the body overlay');

      final style = (menu as html.Element).getComputedStyle();
      // The mobile sheet must keep its own layout after portaling.
      expect(style.display, 'flex',
          reason: 'portaled sheet must render as a flex panel, not '
              'Bootstrap display:block');
      expect(style.position, 'fixed',
          reason: 'portaled sheet must stay viewport-fixed, not absolute');

      final rect = menu.getBoundingClientRect();
      expect(rect.width, greaterThan(0));
      expect(rect.height, greaterThan(0),
          reason: 'sheet must have a visible height, not collapse to 0');
      // A bottom sheet sits near the bottom of the viewport, never pinned to
      // the top-left corner like a broken absolute dropdown.
      expect(rect.bottom, lessThanOrEqualTo(html.window.innerHeight.toDouble()),
          reason: 'sheet stays within the viewport');
      expect(rect.top, greaterThan(0),
          reason: 'sheet is not stuck at the very top (0,0)');
    },
  );

  test(
    'body-container centered modal stays visible and centered after being '
    'portaled',
    () async {
      final fixture = await testBed.create();
      await _settle(fixture);

      _openMenu(fixture, 'body-modal');
      await _settle(fixture);

      final menu = html.document.querySelector(
        '.LiDropdownMenuComponent .li-dropdown-menu__menu--mobile-modal.show',
      );
      expect(menu, isNotNull,
          reason: 'modal panel must be portaled into the body overlay');

      final style = (menu as html.Element).getComputedStyle();
      expect(style.display, 'flex');
      expect(style.position, 'fixed');

      final rect = menu.getBoundingClientRect();
      expect(rect.width, greaterThan(0));
      expect(rect.height, greaterThan(0));

      // Centered modal: its center is near the viewport center.
      final centerX = rect.left + rect.width / 2;
      final centerY = rect.top + rect.height / 2;
      expect((centerX - html.window.innerWidth / 2).abs(), lessThan(40),
          reason: 'modal should be horizontally centered');
      expect((centerY - html.window.innerHeight / 2).abs(), lessThan(40),
          reason: 'modal should be vertically centered');
    },
  );

  test('portaled mobile sheet still renders its option items', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    _openMenu(fixture, 'body-sheet');
    await _settle(fixture);

    final items = html.document.queryAll(
      '.LiDropdownMenuComponent .li-dropdown-menu__menu--mobile-sheet.show '
      '.dropdown-item',
    );
    expect(items, hasLength(3));
    for (final item in items) {
      final rect = item.getBoundingClientRect();
      expect(rect.height, greaterThan(0),
          reason: 'each option must be visible in the portaled sheet');
    }
  });
}

void _openMenu(
  NgTestFixture<BodyMobileDropdownTestHostComponent> fixture,
  String ariaLabel,
) {
  final trigger = fixture.rootElement.querySelector('[aria-label="$ariaLabel"]')
      as html.ButtonElement;
  trigger.dispatchEvent(html.liMouseEvent('click', canBubble: true));
}

Future<void> _settle(
  NgTestFixture<BodyMobileDropdownTestHostComponent> fixture,
) async {
  await fixture.update((_) {});
  await _nextAnimationFrame();
  await _nextAnimationFrame();
  await Future<void>.delayed(Duration.zero);
  await fixture.update((_) {});
}

Future<void> _nextAnimationFrame() {
  final completer = Completer<void>();
  html.window.liRequestAnimationFrame((_) {
    completer.complete();
  });
  return completer.future;
}
