// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/dropdown/li_dropdown_directive_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_dropdown_directive_test.template.dart' as ng;

@Component(
  selector: 'dropdown-test-host',
  template: '''
    <div>
      <div id="basic-dropdown" liDropdown #basicDrop="liDropdown">
        <button id="basic-toggle" liDropdownToggle>Toggle</button>
        <div id="basic-menu" liDropdownMenu>
          <button id="basic-item-1" liDropdownItem>First</button>
          <button id="basic-item-2" liDropdownItem>Second</button>
          <button id="basic-item-3" liDropdownItem>Third</button>
        </div>
      </div>

      <div id="inside-dropdown" liDropdown autoClose="inside" #insideDrop="liDropdown">
        <button id="inside-toggle" liDropdownToggle>Inside</button>
        <div id="inside-menu" liDropdownMenu>
          <button id="inside-item-1" liDropdownItem>Inside item</button>
        </div>
      </div>

      <div id="body-dropdown" liDropdown container="body">
        <button id="body-toggle" liDropdownToggle>Body</button>
        <div id="body-menu" liDropdownMenu>
          <button id="body-item-1" liDropdownItem>Body item</button>
        </div>
      </div>

      <div id="body-end-dropdown"
          style="position: fixed; top: 24px; right: 24px;"
          liDropdown
          container="body"
          placement="bottom-end">
        <button id="body-end-toggle" liDropdownToggle>Body end</button>
        <div id="body-end-menu" class="dropdown-menu-end" liDropdownMenu style="min-width: 22rem;">
          <button id="body-end-item-1" liDropdownItem>Body end item</button>
        </div>
      </div>

      <div id="body-start-dropdown"
          style="position: fixed; top: 96px; left: 48px;"
          liDropdown
          container="body"
          placement="bottom-start">
        <button id="body-start-toggle" liDropdownToggle>Body start</button>
        <div id="body-start-menu" liDropdownMenu style="min-width: 18rem;">
          <button id="body-start-item-1" liDropdownItem>Body start item</button>
        </div>
      </div>

      <div id="fallback-dropdown"
          style="position: fixed; top: 16px; right: 16px;"
          liDropdown
          container="body"
          placement="right-start">
        <button id="fallback-toggle" liDropdownToggle>Fallback</button>
        <div id="fallback-menu" liDropdownMenu style="min-width: 20rem;">
          <button id="fallback-item-1" liDropdownItem>Long body item</button>
        </div>
      </div>

      <div id="adaptive-dropdown"
          style="position: fixed; top: 64px; right: 8px;"
          liDropdown
          container="body"
          placement="bottom-end">
        <button id="adaptive-toggle" liDropdownToggle>Adaptive</button>
        <div id="adaptive-menu" class="dropdown-menu-end" liDropdownMenu style="width: max-content; max-width: none; white-space: nowrap;">
          <button id="adaptive-item-1" liDropdownItem style="white-space: nowrap;">
            DepartamentoSuperExtraordinariamenteExtensoDeRegistrosEDesenvolvimentoDePessoalComNomeMuitoLongo-637
          </button>
        </div>
      </div>

      <div id="adaptive-bottom-dropdown"
          style="position: fixed; right: 8px; bottom: 8px;"
          liDropdown
          container="body"
          placement="bottom-end">
        <button id="adaptive-bottom-toggle" liDropdownToggle>Adaptive bottom</button>
        <div id="adaptive-bottom-menu" class="dropdown-menu-end" liDropdownMenu style="width: 18rem;">
          <button
              *ngFor="let item of tallMenuItems"
              liDropdownItem>
            {{ item }}
          </button>
        </div>
      </div>

      <div id="capped-dropdown"
          style="position: fixed; top: 112px; right: 24px;"
          liDropdown
          container="body"
          placement="bottom-end"
          menuMaxWidth="22rem">
        <button id="capped-toggle" liDropdownToggle>Capped</button>
        <div id="capped-menu" class="dropdown-menu-end" liDropdownMenu style="width: 1200px; max-width: none; white-space: nowrap;">
          <button id="capped-item-1" liDropdownItem style="white-space: nowrap;">
            MenuDeUsuarioComConteudoMuitoMaiorDoQueOEsperadoParaValidarLimiteDeLargura
          </button>
        </div>
      </div>

      <div id="caret-dropdown" liDropdown>
        <button id="caret-toggle" liDropdownToggle>Caret default</button>
        <button id="no-caret-toggle" liDropdownToggle liDropdownShowCaret="false">
          Caret disabled
        </button>
        <div id="caret-menu" liDropdownMenu>
          <button id="caret-item-1" liDropdownItem>Item</button>
        </div>
      </div>

      <div id="submenu-dropdown" liDropdown>
        <button id="submenu-toggle" liDropdownToggle>User</button>
        <div id="submenu-menu" class="dropdown-menu-end" liDropdownMenu>
          <button id="submenu-profile" liDropdownItem>Profile</button>

          <div id="theme-submenu" liDropdownSubmenu placement="start"
              (openChange)="onSubmenuOpenChange(\$event)">
            <button id="theme-submenu-toggle" liDropdownItem liDropdownSubmenuToggle>
              Theme
            </button>

            <div id="theme-submenu-menu" liDropdownSubmenuMenu>
              <button id="theme-light" liDropdownItem>Light</button>
              <button id="theme-dark" liDropdownItem>Dark</button>
            </div>
          </div>

          <button id="submenu-logout" liDropdownItem>Logout</button>
        </div>
      </div>

      <button id="outside-target" type="button">Outside</button>
    </div>
  ''',
  directives: [
    coreDirectives,
    LiDropdownDirective,
    LiDropdownAnchorDirective,
    LiDropdownToggleDirective,
    LiDropdownMenuDirective,
    LiDropdownItemDirective,
    LiDropdownButtonItemDirective,
    LiDropdownSubmenuDirective,
    LiDropdownSubmenuToggleDirective,
    LiDropdownSubmenuMenuDirective,
  ],
)
class DropdownTestHostComponent {
  final List<bool> submenuOpenEvents = <bool>[];
  final List<String> tallMenuItems = List<String>.generate(
    40,
    (index) => 'Tall item ${index + 1}',
    growable: false,
  );

  void onSubmenuOpenChange(bool open) {
    submenuOpenEvents.add(open);
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DropdownTestHostComponent>(
    ng.DropdownTestHostComponentNgFactory,
  );

  test('toggle opens and closes the dropdown', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final toggle = fixture.rootElement.querySelector('#basic-toggle');
    final dropdown = fixture.rootElement.querySelector('#basic-dropdown');
    final menu = fixture.rootElement.querySelector('#basic-menu');

    expect(toggle, isNotNull);
    expect(dropdown, isNotNull);
    expect(menu, isNotNull);
    expect(dropdown!.classes.contains('show'), isFalse);
    expect(menu!.classes.contains('show'), isFalse);

    await fixture.update((_) {
      toggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(dropdown.classes.contains('show'), isTrue);
    expect(menu.classes.contains('show'), isTrue);

    await fixture.update((_) {
      toggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(dropdown.classes.contains('show'), isFalse);
    expect(menu.classes.contains('show'), isFalse);
  });

  test('Home and End move focus between enabled dropdown items', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final toggle = fixture.rootElement.querySelector('#basic-toggle');
    final firstItem = fixture.rootElement.querySelector('#basic-item-1');
    final thirdItem = fixture.rootElement.querySelector('#basic-item-3');

    expect(toggle, isNotNull);
    expect(firstItem, isNotNull);
    expect(thirdItem, isNotNull);

    await fixture.update((_) {
      toggle!.focus();
      _dispatchKey(toggle, 'ArrowDown');
    });
    await _settle(fixture);

    expect(html.document.activeElement, same(firstItem));

    await fixture.update((_) {
      _dispatchKey(firstItem!, 'End');
    });
    await _settle(fixture);

    expect(html.document.activeElement, same(thirdItem));

    await fixture.update((_) {
      _dispatchKey(thirdItem!, 'Home');
    });
    await _settle(fixture);

    expect(html.document.activeElement, same(firstItem));
  });

  test('autoClose inside ignores outside clicks and closes on inside click',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final toggle = fixture.rootElement.querySelector('#inside-toggle');
    final item = fixture.rootElement.querySelector('#inside-item-1');
    final menu = fixture.rootElement.querySelector('#inside-menu');
    final outside = fixture.rootElement.querySelector('#outside-target');

    expect(toggle, isNotNull);
    expect(item, isNotNull);
    expect(menu, isNotNull);
    expect(outside, isNotNull);

    await fixture.update((_) {
      toggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(menu!.classes.contains('show'), isTrue);

    await fixture.update((_) {
      outside!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(menu.classes.contains('show'), isTrue);

    await fixture.update((_) {
      item!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(menu.classes.contains('show'), isFalse);
  });

  test('container body moves the menu outside the local dropdown host',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final toggle = fixture.rootElement.querySelector('#body-toggle');
    final dropdown = fixture.rootElement.querySelector('#body-dropdown');
    final menu = fixture.rootElement.querySelector('#body-menu');

    expect(toggle, isNotNull);
    expect(dropdown, isNotNull);
    expect(menu, isNotNull);

    await fixture.update((_) {
      toggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(dropdown!.contains(menu), isFalse);
    expect(html.document.body!.contains(menu), isTrue);
  });

  test('container body uses fallback placement near the right viewport edge',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final toggle = fixture.rootElement.querySelector('#fallback-toggle');
    final menu = fixture.rootElement.querySelector('#fallback-menu');

    expect(toggle, isNotNull);
    expect(menu, isNotNull);

    await fixture.update((_) {
      toggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final wrapper = menu!.parent;
    expect(wrapper, isNotNull);
    expect(
      wrapper!.getAttribute('data-popper-placement'),
      'left-start',
    );
  });

  test('container body keeps bottom-end menu aligned to the trigger',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final toggle = fixture.rootElement.querySelector('#body-end-toggle');
    final menu = fixture.rootElement.querySelector('#body-end-menu');

    expect(toggle, isNotNull);
    expect(menu, isNotNull);

    await fixture.update((_) {
      toggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final toggleRect = toggle!.getBoundingClientRect();
    final menuRect = menu!.getBoundingClientRect();

    expect((menuRect.right - toggleRect.right).abs(), lessThanOrEqualTo(3));
    expect(menuRect.top, greaterThanOrEqualTo(toggleRect.bottom - 1));
  });

  test('container body keeps bottom-start menu aligned to the trigger',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final toggle = fixture.rootElement.querySelector('#body-start-toggle');
    final menu = fixture.rootElement.querySelector('#body-start-menu');

    expect(toggle, isNotNull);
    expect(menu, isNotNull);

    await fixture.update((_) {
      toggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final toggleRect = toggle!.getBoundingClientRect();
    final menuRect = menu!.getBoundingClientRect();

    expect((menuRect.left - toggleRect.left).abs(), lessThanOrEqualTo(3));
    expect(menuRect.top, greaterThanOrEqualTo(toggleRect.bottom - 1));
  });

  test('body overlay adapta menu largo para permanecer dentro da viewport',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final toggle = fixture.rootElement.querySelector('#adaptive-toggle');
    final menu = fixture.rootElement.querySelector('#adaptive-menu');

    expect(toggle, isNotNull);
    expect(menu, isNotNull);

    await fixture.update((_) {
      toggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final viewportWidth = (html.window.innerWidth ?? 0).toDouble();
    final menuRect = menu!.getBoundingClientRect();

    expect(menuRect.width, lessThanOrEqualTo(viewportWidth - 14));
    expect(menuRect.left, greaterThanOrEqualTo(7));
    expect(menuRect.right, lessThanOrEqualTo(viewportWidth - 7));
  });

  test('body overlay adapta menu alto para nao sair da viewport', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final toggle = fixture.rootElement.querySelector('#adaptive-bottom-toggle');
    final menu = fixture.rootElement.querySelector('#adaptive-bottom-menu');

    expect(toggle, isNotNull);
    expect(menu, isNotNull);

    await fixture.update((_) {
      toggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final viewportHeight = (html.window.innerHeight ?? 0).toDouble();
    final menuRect = menu!.getBoundingClientRect();

    expect(menuRect.height, lessThanOrEqualTo(viewportHeight - 14));
    expect(menuRect.top, greaterThanOrEqualTo(7));
    expect(menuRect.bottom, lessThanOrEqualTo(viewportHeight - 7));
  });

  test('menuMaxWidth limita largura sem perder alinhamento quando ha espaco',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final toggle = fixture.rootElement.querySelector('#capped-toggle');
    final menu = fixture.rootElement.querySelector('#capped-menu');

    expect(toggle, isNotNull);
    expect(menu, isNotNull);

    await fixture.update((_) {
      toggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    const rootFontSize = 16.0;
    final maxExpectedWidth = (22 * rootFontSize) + 1;
    final toggleRect = toggle!.getBoundingClientRect();
    final menuRect = menu!.getBoundingClientRect();

    expect(menuRect.width, lessThanOrEqualTo(maxExpectedWidth));
    expect((menuRect.right - toggleRect.right).abs(), lessThanOrEqualTo(3));
    expect(menuRect.top, greaterThanOrEqualTo(toggleRect.bottom - 1));
  });

  test('liDropdownShowCaret controls dropdown-toggle class on trigger',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final defaultToggle = fixture.rootElement.querySelector('#caret-toggle');
    final noCaretToggle =
        fixture.rootElement.querySelector('#no-caret-toggle');

    expect(defaultToggle, isNotNull);
    expect(noCaretToggle, isNotNull);
    expect(defaultToggle!.classes.contains('dropdown-toggle'), isTrue);
    expect(noCaretToggle!.classes.contains('dropdown-toggle'), isFalse);
  });

  test('submenu toggle opens nested menu without closing parent dropdown',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final rootToggle = fixture.rootElement.querySelector('#submenu-toggle');
    final rootMenu = fixture.rootElement.querySelector('#submenu-menu');
    final submenuHost = fixture.rootElement.querySelector('#theme-submenu');
    final submenuToggle =
        fixture.rootElement.querySelector('#theme-submenu-toggle');
    final submenuMenu =
        fixture.rootElement.querySelector('#theme-submenu-menu');

    await fixture.update((_) {
      rootToggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      submenuToggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(rootMenu!.classes.contains('show'), isTrue);
    expect(submenuHost!.classes.contains('show'), isTrue);
    expect(submenuMenu!.classes.contains('show'), isTrue);
  });

  test('submenu nao fecha quando hover sintetico precede o click', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final rootToggle = fixture.rootElement.querySelector('#submenu-toggle');
    final submenuHost = fixture.rootElement.querySelector('#theme-submenu');
    final submenuToggle =
        fixture.rootElement.querySelector('#theme-submenu-toggle');
    final submenuMenu =
        fixture.rootElement.querySelector('#theme-submenu-menu');

    await fixture.update((_) {
      rootToggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      submenuHost!.dispatchEvent(html.MouseEvent('mouseenter'));
    });
    await _settle(fixture);

    expect(submenuHost!.classes.contains('show'), isTrue);
    expect(submenuMenu!.classes.contains('show'), isTrue);

    await fixture.update((_) {
      submenuToggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(submenuHost.classes.contains('show'), isTrue);
    expect(submenuMenu.classes.contains('show'), isTrue);
  });

  test('closed submenu items are skipped by parent keyboard navigation',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final rootToggle = fixture.rootElement.querySelector('#submenu-toggle');
    final profile = fixture.rootElement.querySelector('#submenu-profile');
    final submenuToggle =
        fixture.rootElement.querySelector('#theme-submenu-toggle');

    await fixture.update((_) {
      rootToggle!.focus();
      _dispatchKey(rootToggle, 'ArrowDown');
    });
    await _settle(fixture);

    expect(html.document.activeElement?.id, 'submenu-profile');

    await fixture.update((_) {
      _dispatchKey(profile!, 'ArrowDown');
    });
    await _settle(fixture);

    expect(html.document.activeElement?.id, 'theme-submenu-toggle');

    await fixture.update((_) {
      _dispatchKey(submenuToggle!, 'ArrowDown');
    });
    await _settle(fixture);

    expect(html.document.activeElement?.id, 'submenu-logout');
  });

  test('submenu item selection closes the parent dropdown by default',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final rootToggle = fixture.rootElement.querySelector('#submenu-toggle');
    final rootMenu = fixture.rootElement.querySelector('#submenu-menu');
    final submenuHost = fixture.rootElement.querySelector('#theme-submenu');
    final submenuToggle =
        fixture.rootElement.querySelector('#theme-submenu-toggle');
    final submenuItem = fixture.rootElement.querySelector('#theme-light');

    await fixture.update((_) {
      rootToggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      submenuToggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      submenuItem!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(rootMenu!.classes.contains('show'), isFalse);
    expect(submenuHost!.classes.contains('show'), isFalse);
  });

  test('submenu start abre com ArrowLeft e fecha com ArrowRight', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final rootToggle = fixture.rootElement.querySelector('#submenu-toggle');
    final submenuHost = fixture.rootElement.querySelector('#theme-submenu');
    final submenuToggle =
        fixture.rootElement.querySelector('#theme-submenu-toggle');
    final submenuItem = fixture.rootElement.querySelector('#theme-light');

    await fixture.update((_) {
      rootToggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      submenuToggle!.focus();
      _dispatchKey(submenuToggle, 'ArrowLeft');
    });
    await _settle(fixture);

    expect(submenuHost!.classes.contains('show'), isTrue);
    expect(html.document.activeElement?.id, 'theme-light');

    await fixture.update((_) {
      _dispatchKey(submenuItem!, 'ArrowRight');
    });
    await _settle(fixture);

    expect(submenuHost.classes.contains('show'), isFalse);
    expect(html.document.activeElement?.id, 'theme-submenu-toggle');
  });

  test('submenu emite openChange para estado controlado pelo consumidor',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final rootToggle = fixture.rootElement.querySelector('#submenu-toggle');
    final submenuToggle =
        fixture.rootElement.querySelector('#theme-submenu-toggle');
    final submenuItem = fixture.rootElement.querySelector('#theme-light');

    await fixture.update((_) {
      rootToggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      submenuToggle!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      submenuItem!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.submenuOpenEvents, <bool>[true, false]);
  });
}

Future<void> _settle(NgTestFixture<DropdownTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}

void _dispatchKey(html.Element element, String key) {
  final keyboardEventConstructor =
      js_util.getProperty(html.window, 'KeyboardEvent');
  final event = js_util.callConstructor(
    keyboardEventConstructor,
    <Object>[
      'keydown',
      js_util.jsify(<String, Object>{
        'key': key,
        'bubbles': true,
      }),
    ],
  );
  element.dispatchEvent(event as html.Event);
}
