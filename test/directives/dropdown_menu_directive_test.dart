// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/directives/dropdown_menu_directive_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'dropdown_menu_directive_test.template.dart' as ng;

@Component(
  selector: 'dropdown-menu-directive-test-host',
  template: '''
    <div style="display:flex; gap:16px; align-items:flex-start;">
      <div class="dropdown" dropdownmenu="bottom-end" dropdownmenuContainer="inline">
        <button type="button" class="btn btn-light li-dropdown-trigger" aria-label="inline-trigger">
          Inline
        </button>
        <div class="dropdown-menu dropdown-menu-end">
          <button type="button" class="dropdown-item li-dropdown-close">Fechar</button>
          <label class="dropdown-item">
            <input type="checkbox" class="form-check-input m-0 me-3">
            Coluna
          </label>
        </div>
      </div>

      <div style="height:40px; overflow:hidden; position:relative;">
        <div class="dropdown" dropdownmenu="bottom-end">
          <button type="button" class="btn btn-light li-dropdown-trigger" aria-label="body-trigger">
            Body
          </button>
          <div class="dropdown-menu dropdown-menu-end">
            <button type="button" class="dropdown-item li-dropdown-close">Fechar</button>
            <label class="dropdown-item">
              <input type="checkbox" class="form-check-input m-0 me-3">
              Coluna
            </label>
          </div>
        </div>
      </div>
    </div>
  ''',
  directives: [coreDirectives, DropdownMenuDirective],
)
class DropdownMenuDirectiveTestHostComponent {}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DropdownMenuDirectiveTestHostComponent>(
    ng.DropdownMenuDirectiveTestHostComponentNgFactory,
  );

  test('keeps inline rendering when container is inline', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement.querySelector(
      '[aria-label="inline-trigger"]',
    ) as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(fixture.rootElement.querySelector('.dropdown-menu.show'), isNotNull);
    expect(
      html.document.querySelector('.DropdownMenuDirective .dropdown-menu.show'),
      isNull,
    );
  });

  test('renders menu in body overlay by default', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement.querySelector(
      '[aria-label="body-trigger"]',
    ) as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final menu = html.document.querySelector(
      '.DropdownMenuDirective .dropdown-menu.show',
    ) as html.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final menuRect = menu.getBoundingClientRect();

    expect(menu, isNotNull);
    expect(fixture.rootElement.querySelector('.dropdown-menu.show'), isNull);
    expect(menuRect.width, greaterThan(80));
    expect((menuRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(8));
  });

  test(
      'keeps body overlay open for checkbox clicks and closes on li-dropdown-close',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement.querySelector(
      '[aria-label="body-trigger"]',
    ) as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final checkbox = html.document.querySelector(
      '.DropdownMenuDirective .dropdown-menu.show input[type="checkbox"]',
    ) as html.InputElement;

    await fixture.update((_) {
      checkbox.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(
      html.document.querySelector('.DropdownMenuDirective .dropdown-menu.show'),
      isNotNull,
    );

    final closeButton = html.document.querySelector(
      '.DropdownMenuDirective .dropdown-menu.show .li-dropdown-close',
    ) as html.ButtonElement;

    await fixture.update((_) {
      closeButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(
      html.document.querySelector('.DropdownMenuDirective .dropdown-menu.show'),
      isNull,
    );
  });
}

Future<void> _settle(
  NgTestFixture<DropdownMenuDirectiveTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
