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
  ],
)
class DropdownTestHostComponent {}

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
}

Future<void> _settle(NgTestFixture<DropdownTestHostComponent> fixture) async {
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
