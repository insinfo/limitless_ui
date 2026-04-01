// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/date_range_picker/li_date_range_picker_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_date_range_picker_component_test.template.dart' as ng;

@Component(
  selector: 'li-date-range-picker-test-host',
  template: '''
    <li-date-range-picker
        #picker
        [inicio]="rangeStart"
        [fim]="rangeEnd"
        [minDate]="minDate"
        [maxDate]="maxDate"
        (inicioChange)="onStartChange(\$event)"
        (fimChange)="onEndChange(\$event)">
    </li-date-range-picker>
  ''',
  directives: [coreDirectives, LiDateRangePickerComponent],
)
class DateRangePickerTestHostComponent {
  @ViewChild('picker')
  LiDateRangePickerComponent? picker;

  DateTime? rangeStart = DateTime(2026, 4, 10);
  DateTime? rangeEnd = DateTime(2026, 4, 12);
  final DateTime minDate = DateTime(2026, 4, 1);
  final DateTime maxDate = DateTime(2026, 4, 30);

  void onStartChange(DateTime? value) {
    rangeStart = value;
  }

  void onEndChange(DateTime? value) {
    rangeEnd = value;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DateRangePickerTestHostComponent>(
    ng.DateRangePickerTestHostComponentNgFactory,
  );

  test('clear button resets the selected range', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final clearButton = html.document
        .querySelectorAll('.drp-buttons .btn-light')[0] as html.ButtonElement;

    await fixture.update((_) {
      clearButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.rangeStart, isNull);
    expect(host.rangeEnd, isNull);
  });

  test('selects and applies a new range', () async {
    final fixture = await testBed.create();
    await fixture.update((host) {
      host.rangeStart = null;
      host.rangeEnd = null;
    });
    await _settle(fixture);

    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      host.picker!.selectDay(DateTime(2026, 4, 14));
      host.picker!.selectDay(DateTime(2026, 4, 18));
      host.picker!.apply();
    });
    await _settle(fixture);

    expect(host.rangeStart, DateTime(2026, 4, 14));
    expect(host.rangeEnd, DateTime(2026, 4, 18));

    final input = fixture.rootElement.querySelector('.date-range-field')
        as html.InputElement;
    expect(input.value, contains('14/04/2026'));
    expect(input.value, contains('18/04/2026'));
  });

  test('ignores dates outside the configured bounds', () async {
    final fixture = await testBed.create();
    await fixture.update((host) {
      host.rangeStart = null;
      host.rangeEnd = null;
    });
    await _settle(fixture);

    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      host.picker!.toggleOpen();
      host.picker!.selectDay(DateTime(2026, 3, 31));
    });
    await _settle(fixture);

    expect(host.picker!.draftInicio, isNull);
    expect(host.rangeStart, isNull);
    expect(host.rangeEnd, isNull);
  });
}

Future<void> _settle(
  NgTestFixture<DateRangePickerTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
