// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/dropdown_menu/li_dropdown_menu_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_dropdown_menu_component_test.template.dart' as ng;

@Component(
  selector: 'li-dropdown-menu-test-host',
  template: '''
    <div style="display: flex; gap: 16px; align-items: flex-start;">
      <li-dropdown-menu
          container="inline"
          [options]="options"
          [value]="selectedValue"
          ariaLabel="inline-actions"
          triggerLabel="Inline"
          triggerIconClass="ph ph-dots-three"
          menuClass=""
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>

      <div style="height: 40px; overflow: hidden; position: relative;">
        <li-dropdown-menu
          [options]="options"
          [value]="selectedValue"
          ariaLabel="body-actions"
          triggerLabel="Acoes"
          triggerIconClass="ph ph-dots-three"
          menuClass=""
          (valueChange)="selectedValue = \$event">
        </li-dropdown-menu>
      </div>
    </div>
  ''',
  directives: [coreDirectives, LiDropdownMenuComponent],
)
class DropdownMenuTestHostComponent {
  String selectedValue = 'copy';

  final List<LiDropdownMenuOption> options = const <LiDropdownMenuOption>[
    LiDropdownMenuOption(value: 'copy', label: 'Copiar'),
    LiDropdownMenuOption(value: 'paste', label: 'Colar'),
    LiDropdownMenuOption(value: 'clear', label: 'Limpar'),
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DropdownMenuTestHostComponent>(
    ng.DropdownMenuTestHostComponentNgFactory,
  );

  test('keeps inline rendering when container="inline"', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
        .querySelector('[aria-label="inline-actions"]') as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final inlineMenu = fixture.rootElement.querySelector(
      '.li-dropdown-menu__menu.show',
    );

    expect(inlineMenu, isNotNull);
    expect(
      html.document.querySelector(
          '.LiDropdownMenuComponent .li-dropdown-menu__menu.show'),
      isNull,
    );
  });

  test('opens menu in a body overlay aligned to the trigger start', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
        .querySelector('[aria-label="body-actions"]') as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final menu = html.document.querySelector(
      '.LiDropdownMenuComponent .li-dropdown-menu__menu.show',
    ) as html.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final menuRect = menu.getBoundingClientRect();

    expect(menu, isNotNull);
    expect(
      fixture.rootElement.querySelector('.li-dropdown-menu__menu.show'),
      isNull,
    );
    expect((menuRect.left - triggerRect.left).abs(), lessThanOrEqualTo(12));
    expect((menuRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(12));
  });

  test('selects an option from the overlay and closes the menu', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final trigger = fixture.rootElement
        .querySelector('[aria-label="body-actions"]') as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final option = html.document
        .querySelectorAll(
            '.LiDropdownMenuComponent .li-dropdown-menu__menu.show .dropdown-item')
        .cast<html.ButtonElement>()
        .firstWhere((element) => (element.text ?? '').contains('Limpar'));

    await fixture.update((_) {
      option.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedValue, 'clear');
    expect(
      html.document.querySelector(
          '.LiDropdownMenuComponent .li-dropdown-menu__menu.show'),
      isNull,
    );
  });
}

Future<void> _settle(
  NgTestFixture<DropdownMenuTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
