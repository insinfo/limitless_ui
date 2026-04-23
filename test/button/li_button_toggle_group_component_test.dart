// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/button/li_button_toggle_group_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

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
    final buttons = fixture.rootElement.querySelectorAll('button');

    expect(group, isNotNull);
    expect(group!.classes.contains('btn-group'), isTrue);
    expect(group.classes.contains('btn-group-lg'), isTrue);
    expect(group.classes.contains('custom-group'), isTrue);
    expect(group.getAttribute('aria-label'), 'display-mode');
    expect(buttons, hasLength(3));

    final activeButton = buttons[0] as html.ButtonElement;
    final inactiveButton = buttons[1] as html.ButtonElement;
    final disabledButton = buttons[2] as html.ButtonElement;

    expect(activeButton.classes.contains('btn-success'), isTrue);
    expect(activeButton.classes.contains('rounded-pill'), isTrue);
    expect(activeButton.classes.contains('custom-button'), isTrue);
    expect(activeButton.getAttribute('aria-pressed'), 'true');
    expect(activeButton.title, 'Exibir em grade');
    expect(activeButton.querySelector('i')?.classes.contains('me-2'), isTrue);

    expect(inactiveButton.classes.contains('btn-outline-secondary'), isTrue);
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

    final buttons = fixture.rootElement.querySelectorAll('button');
    final listButton = buttons[1] as html.ButtonElement;

    await fixture.update((_) {
      listButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final updatedButtons = fixture.rootElement.querySelectorAll('button');
    final updatedGridButton = updatedButtons[0] as html.ButtonElement;
    final updatedListButton = updatedButtons[1] as html.ButtonElement;

    expect(host.selectedValue, 'list');
    expect(updatedListButton.getAttribute('aria-pressed'), 'true');
    expect(updatedListButton.classes.contains('btn-success'), isTrue);
    expect(updatedGridButton.classes.contains('btn-outline-secondary'), isTrue);
  });

  test('ignores clicks on the active option and on disabled options', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final buttons = fixture.rootElement.querySelectorAll('button');
    final activeButton = buttons[0] as html.ButtonElement;
    final disabledButton = buttons[2] as html.ButtonElement;

    await fixture.update((_) {
      activeButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
      disabledButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
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
