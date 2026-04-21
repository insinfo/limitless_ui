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

@Component(
  selector: 'li-date-range-picker-alias-test-host',
  template: '''
    <li-date-range-picker
        #picker
        [start]="rangeStart"
        [end]="rangeEnd"
        [minDate]="minDate"
        [maxDate]="maxDate"
        (startChange)="onStartChange(\$event)"
        (endChange)="onEndChange(\$event)">
    </li-date-range-picker>
  ''',
  directives: [coreDirectives, LiDateRangePickerComponent],
)
class DateRangePickerAliasTestHostComponent {
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
  final aliasTestBed = NgTestBed<DateRangePickerAliasTestHostComponent>(
    ng.DateRangePickerAliasTestHostComponentNgFactory,
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

  test('opens overlay in the expected position for the current viewport',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    if (_usesMobileDateRangeLayout()) {
      final panel = await _waitForCenteredPanelElement(
        fixture,
        host.picker!.panelElement,
      );
      final panelRect = panel.getBoundingClientRect();
      final viewportCenterX = html.window.innerWidth! / 2;
      final viewportCenterY = html.window.innerHeight! / 2;

      expect(
        ((panelRect.left + (panelRect.width / 2)) - viewportCenterX).abs(),
        lessThanOrEqualTo(2),
      );
      expect(
        ((panelRect.top + (panelRect.height / 2)) - viewportCenterY).abs(),
        lessThanOrEqualTo(2),
      );
      return;
    }

    final panel = await _waitForAlignedPanelElement(
      fixture,
      trigger,
      host.picker!.panelElement,
    );
    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect((panelRect.left - triggerRect.left).abs(), lessThanOrEqualTo(1.5));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));
  });

  test('keeps overlay open when changing year and month views', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      host.picker!.toggleLeftViewMode();
      host.picker!.toggleLeftViewMode();
    });
    await _settle(fixture);

    await fixture.update((_) {
      final panel = _openDateRangePanel();
      final yearButton = panel.querySelector(
        '.date-range-selection-grid-years .date-range-selection-item.active',
      );
      expect(yearButton, isNotNull);
      yearButton!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.picker!.isOpen, isTrue);
    expect(host.picker!.leftViewMode, DateRangePickerViewMode.month);

    await fixture.update((_) {
      final panel = _openDateRangePanel();
      final monthButton = panel.querySelector(
        '.date-range-selection-grid .date-range-selection-item.active',
      );
      expect(monthButton, isNotNull);
      monthButton!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.picker!.isOpen, isTrue);
    expect(host.picker!.leftViewMode, DateRangePickerViewMode.day);
  });

  test('supports forward and backward navigation from both headers', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      final headers =
          html.document.querySelectorAll('.date-range-panel-header');
      final leftNext = headers[0].querySelector('.calendar-nav.next');
      expect(leftNext, isNotNull);
      leftNext!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.picker!.leftMonth, DateTime(2026, 5, 1));
    expect(host.picker!.rightMonth, DateTime(2026, 6, 1));

    await fixture.update((_) {
      final headers =
          html.document.querySelectorAll('.date-range-panel-header');
      final rightPrev = headers[1].querySelector('.calendar-nav.prev');
      expect(rightPrev, isNotNull);
      rightPrev!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.picker!.leftMonth, DateTime(2026, 4, 1));
    expect(host.picker!.rightMonth, DateTime(2026, 5, 1));
  });

  test('supports start/end aliases with two-way updates', () async {
    final fixture = await aliasTestBed.create();
    await fixture.update((host) {
      host.rangeStart = null;
      host.rangeEnd = null;
    });
    await _settleAlias(fixture);

    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settleAlias(fixture);

    await fixture.update((_) {
      host.picker!.selectDay(DateTime(2026, 4, 8));
      host.picker!.selectDay(DateTime(2026, 4, 20));
      host.picker!.apply();
    });
    await _settleAlias(fixture);

    expect(host.rangeStart, DateTime(2026, 4, 8));
    expect(host.rangeEnd, DateTime(2026, 4, 20));
    expect(host.picker!.inicio, DateTime(2026, 4, 8));
    expect(host.picker!.fim, DateTime(2026, 4, 20));
  });
}

Future<void> _settle(
  NgTestFixture<DateRangePickerTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleAlias(
  NgTestFixture<DateRangePickerAliasTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

html.Element _openDateRangePanel() {
  final panel = html.document.querySelector('.date-range-open.is-open');
  expect(panel, isNotNull);
  return panel!;
}

bool _usesMobileDateRangeLayout() {
  final innerWidth = html.window.innerWidth;
  return innerWidth != null && innerWidth <= 767;
}

Future<html.Element> _waitForAlignedPanelElement(
  NgTestFixture<DateRangePickerTestHostComponent> fixture,
  html.Element trigger,
  html.Element? panelElement,
) async {
  expect(panelElement, isNotNull);
  final triggerRect = trigger.getBoundingClientRect();
  final panel = panelElement!;
  num leftDiff = double.infinity;
  num topDiff = double.infinity;

  for (var attempt = 0; attempt < 8; attempt++) {
    final panelRect = panel.getBoundingClientRect();
    leftDiff = (panelRect.left - triggerRect.left).abs();
    topDiff = (panelRect.top - triggerRect.bottom).abs();

    if (leftDiff <= 1.5 && topDiff <= 1.5) {
      return panel;
    }

    await Future<void>.delayed(const Duration(milliseconds: 40));
    await fixture.update((_) {});
  }

  fail(
    'Open panel did not align below the trigger. '
    'left diff: $leftDiff, top diff: $topDiff, '
    'innerWidth: ${html.window.innerWidth}, '
    'inline transform: ${panel.style.transform}, '
    'computed transform: ${panel.getComputedStyle().transform}',
  );
}

Future<html.Element> _waitForCenteredPanelElement(
  NgTestFixture<DateRangePickerTestHostComponent> fixture,
  html.Element? panelElement,
) async {
  expect(panelElement, isNotNull);
  final panel = panelElement!;
  num centerXDiff = double.infinity;
  num centerYDiff = double.infinity;

  for (var attempt = 0; attempt < 8; attempt++) {
    final innerWidth = html.window.innerWidth;
    final innerHeight = html.window.innerHeight;
    expect(innerWidth, isNotNull);
    expect(innerHeight, isNotNull);

    final panelRect = panel.getBoundingClientRect();
    centerXDiff =
        ((panelRect.left + (panelRect.width / 2)) - (innerWidth! / 2)).abs();
    centerYDiff =
        ((panelRect.top + (panelRect.height / 2)) - (innerHeight! / 2)).abs();

    if (centerXDiff <= 2 && centerYDiff <= 2) {
      return panel;
    }

    await Future<void>.delayed(const Duration(milliseconds: 40));
    await fixture.update((_) {});
  }

  fail(
    'Open panel did not center in mobile layout. '
    'centerX diff: $centerXDiff, centerY diff: $centerYDiff, '
    'innerWidth: ${html.window.innerWidth}, innerHeight: ${html.window.innerHeight}, '
    'inline transform: ${panel.style.transform}, '
    'computed transform: ${panel.getComputedStyle().transform}',
  );
}
