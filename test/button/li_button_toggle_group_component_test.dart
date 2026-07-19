// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/button/li_button_toggle_group_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'package:web/web.dart' as web;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import '../support/web_event_factories.dart';
import '../support/web_node_list.dart';

import 'li_button_toggle_group_component_test.template.dart' as ng;

@Component(
  selector: 'li-button-toggle-group-test-host',
  template: '''
    <li-button-toggle-group
        [options]="options"
        [value]="selectedValue"
        ariaLabel="display-mode"
        size="lg"
        activeVariant="success"
        inactiveVariant="secondary"
        activeButtonStyle="solid"
        inactiveButtonStyle="outline"
        [rounded]="true"
        groupClass="custom-group"
        buttonClass="custom-button"
        (valueChange)="selectedValue = \$event">
    </li-button-toggle-group>
  ''',
  directives: [coreDirectives, LiButtonToggleGroupComponent],
)
class ButtonToggleGroupTestHostComponent {
  String selectedValue = 'grid';

  final List<LiButtonToggleOption> options = const <LiButtonToggleOption>[
    LiButtonToggleOption(
      value: 'grid',
      label: 'Grade',
      iconClass: 'ph ph-squares-four',
      title: 'Exibir em grade',
    ),
    LiButtonToggleOption(
      value: 'list',
      label: 'Lista',
      iconClass: 'ph ph-list-bullets',
      title: 'Exibir em lista',
    ),
    LiButtonToggleOption(
      value: 'map',
      label: 'Mapa',
      disabled: true,
      title: 'Visualizacao indisponivel',
    ),
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<ButtonToggleGroupTestHostComponent>(
    ng.ButtonToggleGroupTestHostComponentNgFactory,
  );

  test('renders group, active state, and accessibility attributes', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final group = fixture.rootElement.querySelector('[role="group"]');
    final buttons =
        fixture.rootElement.querySelectorAll('button').toElementList();

    expect(group, isNotNull);
    expect(group!.classList.contains('btn-group'), isTrue);
    expect(group.classList.contains('btn-group-lg'), isTrue);
    expect(group.classList.contains('custom-group'), isTrue);
    expect(group.getAttribute('aria-label'), 'display-mode');
    expect(buttons, hasLength(3));

    final activeButton = buttons[0] as web.HTMLButtonElement;
    final inactiveButton = buttons[1] as web.HTMLButtonElement;
    final disabledButton = buttons[2] as web.HTMLButtonElement;

    expect(activeButton.classList.contains('btn-success'), isTrue);
    expect(activeButton.classList.contains('rounded-pill'), isTrue);
    expect(activeButton.classList.contains('custom-button'), isTrue);
    expect(activeButton.getAttribute('aria-pressed'), 'true');
    expect(activeButton.title, 'Exibir em grade');
    expect(activeButton.querySelector('i')?.classList.contains('me-2'), isTrue);

    expect(inactiveButton.classList.contains('btn-outline-secondary'), isTrue);
    expect(inactiveButton.getAttribute('aria-pressed'), 'false');

    expect(disabledButton.disabled, isTrue);
    expect(disabledButton.getAttribute('aria-pressed'), 'false');
  });

  test(
      'emits valueChange through the host binding when selecting another option',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final buttons =
        fixture.rootElement.querySelectorAll('button').toElementList();
    final listButton = buttons[1] as web.HTMLButtonElement;

    await fixture.update((_) {
      listButton.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    final updatedButtons =
        fixture.rootElement.querySelectorAll('button').toElementList();
    final updatedGridButton = updatedButtons[0] as web.HTMLButtonElement;
    final updatedListButton = updatedButtons[1] as web.HTMLButtonElement;

    expect(host.selectedValue, 'list');
    expect(updatedListButton.getAttribute('aria-pressed'), 'true');
    expect(updatedListButton.classList.contains('btn-success'), isTrue);
    expect(
        updatedGridButton.classList.contains('btn-outline-secondary'), isTrue);
  });

  test('ignores clicks on the active option and on disabled options', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final buttons =
        fixture.rootElement.querySelectorAll('button').toElementList();
    final activeButton = buttons[0] as web.HTMLButtonElement;
    final disabledButton = buttons[2] as web.HTMLButtonElement;

    await fixture.update((_) {
      activeButton.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
      disabledButton.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.selectedValue, 'grid');
  });
}

Future<void> _settle(
  NgTestFixture<ButtonToggleGroupTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}
