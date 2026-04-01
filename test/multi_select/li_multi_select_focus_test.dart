// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/multi_select/li_multi_select_focus_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_multi_select_focus_test.template.dart' as ng;

@Component(
  selector: 'li-multi-select-focus-test-host',
  template: '''
    <div>
      <li-input id="external-input" label="External" [(ngModel)]="externalValue">
      </li-input>

      <li-multi-select
          [dataSource]="channelOptions"
          labelKey="label"
          valueKey="id"
          [(ngModel)]="selectedChannels">
      </li-multi-select>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiInputComponent,
    LiMultiSelectComponent,
  ],
)
class MultiSelectFocusTestHostComponent {
  String externalValue = '';
  List<dynamic> selectedChannels = <dynamic>['email'];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'E-mail'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<MultiSelectFocusTestHostComponent>(
    ng.MultiSelectFocusTestHostComponentNgFactory,
  );

  test(
      'outside clicks keep focus on the clicked input instead of the multi select',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;
    final input =
        fixture.rootElement.querySelector('input#external-input') as dynamic;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(trigger.getAttribute('aria-expanded'), 'true');

    await fixture.update((_) {
      input.focus();
      input.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(html.document.activeElement, same(input as html.Element));
    expect(trigger.getAttribute('aria-expanded'), 'false');
  });
}

Future<void> _settle(
  NgTestFixture<MultiSelectFocusTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
