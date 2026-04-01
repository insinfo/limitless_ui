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
        [(ngModel)]="selectedChannels">
    </li-multi-select>
  ''',
  directives: [coreDirectives, formDirectives, LiMultiSelectComponent],
)
class MultiSelectTestHostComponent {
  @ViewChild('multi')
  LiMultiSelectComponent? multi;

  List<dynamic> selectedChannels = <dynamic>['email'];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'E-mail'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<MultiSelectTestHostComponent>(
    ng.MultiSelectTestHostComponentNgFactory,
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

    await fixture.update((_) {
      pushOption.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedChannels, <String>['email']);
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
}

Future<void> _settle(
    NgTestFixture<MultiSelectTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
