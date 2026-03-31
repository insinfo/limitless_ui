// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/nav/li_nav_directive_test.dart
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

import 'li_nav_directive_test.template.dart' as ng;

@Component(
  selector: 'nav-test-host',
  template: '''
    <div>
      <ul
          id="main-nav"
          liNav
          #nav="liNav"
          class="nav nav-tabs"
          [activeId]="activeId"
          (activeIdChange)="activeId = \$event"
          (navChange)="onNavChange(\$event)">
        <li [liNavItem]="1">
          <button id="nav-link-1" liNavLink>First</button>
          <template liNavContent>First content</template>
        </li>
        <li [liNavItem]="2">
          <button id="nav-link-2" liNavLink>Second</button>
          <template liNavContent>Second content</template>
        </li>
        <li [liNavItem]="3" [disabled]="true">
          <button id="nav-link-3" liNavLink>Third</button>
          <template liNavContent>Third content</template>
        </li>
      </ul>

      <div id="main-outlet" [liNavOutlet]="nav"></div>

      <ul
          id="keyboard-nav"
          liNav
          #keyboardNav="liNav"
          class="nav nav-pills"
          keyboard="changeWithArrows"
          [activeId]="keyboardActiveId"
          (activeIdChange)="keyboardActiveId = \$event">
        <li [liNavItem]="'alpha'">
          <button id="keyboard-link-alpha" liNavLink>Alpha</button>
          <template liNavContent>Alpha content</template>
        </li>
        <li [liNavItem]="'beta'">
          <button id="keyboard-link-beta" liNavLink>Beta</button>
          <template liNavContent>Beta content</template>
        </li>
        <li [liNavItem]="'gamma'">
          <button id="keyboard-link-gamma" liNavLink>Gamma</button>
          <template liNavContent>Gamma content</template>
        </li>
      </ul>

      <div id="keyboard-outlet" [liNavOutlet]="keyboardNav"></div>
    </div>
  ''',
  directives: [
    coreDirectives,
    LiNavDirective,
    LiNavItemDirective,
    LiNavLinkDirective,
    LiNavContentDirective,
    LiNavOutletDirective,
  ],
)
class NavTestHostComponent {
  Object? activeId;
  Object? keyboardActiveId;
  bool preventSelection = false;

  void onNavChange(LiNavChangeEvent event) {
    if (preventSelection) {
      event.preventDefault();
    }
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<NavTestHostComponent>(
    ng.NavTestHostComponentNgFactory,
  );

  test('selects the first item by default and renders its pane', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.activeId, 1);

    final links =
        fixture.rootElement.querySelectorAll('#main-nav button[linavlink]');
    final firstLink = links[0];
    final secondLink = links[1];
    final outlet = fixture.rootElement.querySelector('#main-outlet');

    expect(outlet, isNotNull);
    expect(firstLink.classes.contains('active'), isTrue);
    expect(secondLink.classes.contains('active'), isFalse);
    expect(outlet!.text, contains('First content'));
    expect(outlet.querySelectorAll('.tab-pane'), hasLength(1));
  });

  test('click changes the active nav and updates the outlet', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final secondLink =
        fixture.rootElement.querySelectorAll('#main-nav button[linavlink]')[1];

    await fixture.update((_) {
      secondLink.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final outlet = fixture.rootElement.querySelector('#main-outlet');
    expect(host.activeId, 2);
    expect(secondLink.classes.contains('active'), isTrue);
    expect(outlet!.text, contains('Second content'));
  });

  test('navChange can prevent selection changes', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final secondLink =
        fixture.rootElement.querySelectorAll('#main-nav button[linavlink]')[1];

    host.preventSelection = true;

    await fixture.update((_) {
      secondLink.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final firstLink =
        fixture.rootElement.querySelectorAll('#main-nav button[linavlink]')[0];
    final outlet = fixture.rootElement.querySelector('#main-outlet');
    expect(host.activeId, 1);
    expect(firstLink.classes.contains('active'), isTrue);
    expect(outlet!.text, contains('First content'));
  });

  test('Home and End keyboard shortcuts switch navs', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final links =
        fixture.rootElement.querySelectorAll('#keyboard-nav button[linavlink]');
    final alphaLink = links[0];
    final gammaLink = links[2];

    await fixture.update((_) {
      alphaLink.focus();
      _dispatchKey(alphaLink, 'End');
    });
    await _settle(fixture);

    expect(host.keyboardActiveId, 'gamma');
    expect(html.document.activeElement, same(gammaLink));

    await fixture.update((_) {
      _dispatchKey(gammaLink, 'Home');
    });
    await _settle(fixture);

    expect(host.keyboardActiveId, 'alpha');
    expect(html.document.activeElement, same(alphaLink));
  });
}

Future<void> _settle(NgTestFixture<NavTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
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
