// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/date_picker/li_date_picker_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_date_picker_component_test.template.dart' as ng;

@Component(
  selector: 'li-date-picker-test-host',
  template: '''
    <li-date-picker
        #picker
        [value]="value"
        (valueChange)="value = \$event">
    </li-date-picker>
  ''',
  directives: [coreDirectives, LiDatePickerComponent],
)
class DatePickerTestHostComponent {
  @ViewChild('picker')
  LiDatePickerComponent? picker;

  DateTime? value = DateTime(2026, 4, 6);
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DatePickerTestHostComponent>(
    ng.DatePickerTestHostComponentNgFactory,
  );

  test('opens overlay aligned directly below the trigger', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
        .querySelector('.date-picker-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final panel = html.document.querySelector('.date-picker-open.is-open')
        as html.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect((panelRect.left - triggerRect.left).abs(), lessThanOrEqualTo(1.5));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));
  });
}

Future<void> _settle(
  NgTestFixture<DatePickerTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
