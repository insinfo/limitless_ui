// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/multi_select/li_multi_select_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_multi_select_component_test.template.dart' as ng;

@Component(
  selector: 'li-multi-select-test-host',
  template: '''
    <li-multi-select
        #multi
        [dataSource]="channelOptions"
        labelKey="label"
        valueKey="id"
        (modelChange)="selectedChannelModels = \$event"
        [(ngModel)]="selectedChannels">
    </li-multi-select>
  ''',
  directives: [coreDirectives, formDirectives, LiMultiSelectComponent],
)
class MultiSelectTestHostComponent {
  @ViewChild('multi')
  LiMultiSelectComponent? multi;

  List<dynamic> selectedChannels = <dynamic>['email'];
  List<dynamic> selectedChannelModels = <dynamic>[];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'E-mail'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
  ];
}

class MultiSelectCompareValue {
  const MultiSelectCompareValue(this.id, this.label);

  final int id;
  final String label;
}

@Component(
  selector: 'li-multi-select-compare-test-host',
  template: '''
    <li-multi-select
      [dataSource]="channelOptions"
      labelKey="label"
      valueKey="value"
      [compareWith]="compareById"
      [(ngModel)]="selectedChannels">
    </li-multi-select>
  ''',
  directives: [coreDirectives, formDirectives, LiMultiSelectComponent],
)
class MultiSelectCompareTestHostComponent {
  List<dynamic> selectedChannels = <dynamic>[
    const MultiSelectCompareValue(2, 'Push antigo'),
  ];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{
      'label': 'E-mail',
      'value': const MultiSelectCompareValue(1, 'E-mail'),
    },
    <String, dynamic>{
      'label': 'Push',
      'value': const MultiSelectCompareValue(2, 'Push'),
    },
  ];

  bool compareById(dynamic optionValue, dynamic modelValue) {
    return optionValue is MultiSelectCompareValue &&
        modelValue is MultiSelectCompareValue &&
        optionValue.id == modelValue.id;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);
  tearDown(() {
    html.document.documentElement?.attributes.remove('data-color-theme');
  });

  final testBed = NgTestBed<MultiSelectTestHostComponent>(
    ng.MultiSelectTestHostComponentNgFactory,
  );
  final compareTestBed = NgTestBed<MultiSelectCompareTestHostComponent>(
    ng.MultiSelectCompareTestHostComponentNgFactory,
  );

  test('toggles options and updates ngModel', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final pushOption = html.document
        .querySelectorAll('.dropdown-container .dropdown-item')
        .cast<html.Element>()
        .firstWhere((element) => (element.text ?? '').contains('Push'));

    await fixture.update((_) {
      pushOption.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedChannels, containsAll(<String>['email', 'push']));
    expect(
      host.selectedChannelModels
          .map((dynamic item) => (item as Map<String, dynamic>)['id']),
      containsAll(<String>['email', 'push']),
    );

    await fixture.update((_) {
      pushOption.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedChannels, <String>['email']);
    expect(
      host.selectedChannelModels
          .map((dynamic item) => (item as Map<String, dynamic>)['id']),
      <String>['email'],
    );
  });

  test('reset clears selected values and badges', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(fixture.rootElement.querySelectorAll('.badge'), isNotEmpty);

    await fixture.update((_) {
      host.multi!.reset();
    });
    await _settle(fixture);

    expect(host.selectedChannels, isEmpty);
    expect(host.selectedChannelModels, isEmpty);
    expect(fixture.rootElement.querySelectorAll('.badge'), isEmpty);
  });

  test('clear button resets selected values without opening the dropdown',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;
    final clearButton =
        fixture.rootElement.querySelector('.dropdown-clear') as html.Element;

    expect(trigger.getAttribute('aria-expanded'), 'false');

    await fixture.update((_) {
      clearButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedChannels, isEmpty);
    expect(trigger.getAttribute('aria-expanded'), 'false');
    expect(fixture.rootElement.querySelector('.dropdown-clear'), isNull);
  });

  test('opens overlay aligned directly below the trigger', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final panel = html.document.querySelector(
      '.dropdown-container.dropdown-open',
    ) as html.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect((panelRect.left - triggerRect.left).abs(), lessThanOrEqualTo(1.5));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));
  });

  test('keeps dark theme styling delegated to dropdown-menu classes', () async {
    html.document.documentElement?.setAttribute('data-color-theme', 'dark');

    final fixture = await testBed.create();
    await _settle(fixture);
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final panel = html.document.querySelector(
      '.dropdown-container.dropdown-open',
    ) as html.Element;

    expect(panel.classes.contains('dropdown-menu'), isTrue);
    expect(panel.style.backgroundColor, isEmpty);
    expect(panel.style.boxShadow, isEmpty);
    expect(panel.style.borderColor, isEmpty);
  });

  test('matches object values with compareWith', () async {
    final fixture = await compareTestBed.create();
    await _settleCompare(fixture);

    expect(fixture.rootElement.querySelectorAll('.badge').length, 1);
    expect(fixture.rootElement.text, contains('Push'));
  });
}

Future<void> _settle(
    NgTestFixture<MultiSelectTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleCompare(
    NgTestFixture<MultiSelectCompareTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
