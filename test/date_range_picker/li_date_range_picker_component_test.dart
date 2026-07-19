// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/date_range_picker/li_date_range_picker_component_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'package:limitless_ui/src/web_support/dom_tokens.dart';
import 'package:web/web.dart' as web;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import '../support/web_event_factories.dart';
import '../support/web_node_list.dart';

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
        (fimChange)="onEndChange(\$event)"
        (userValueChange)="userRange = \$event">
    </li-date-range-picker>
  ''',
  directives: [coreDirectives, LiDateRangePickerComponent],
)
class DateRangePickerTestHostComponent {
  @ViewChild('picker')
  LiDateRangePickerComponent? picker;

  DateTime? rangeStart = DateTime(2026, 4, 10);
  DateTime? rangeEnd = DateTime(2026, 4, 12);
  LiDateRangeValue? userRange;
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

@Component(
  selector: 'li-date-range-picker-mobile-test-host',
  template: '''
    <li-date-range-picker
        #picker
        [inicio]="rangeStart"
        [fim]="rangeEnd"
        mobilePresentation="modal"
        mobileHeightBreakpoint="9999px"
        (inicioChange)="onStartChange(\$event)"
        (fimChange)="onEndChange(\$event)">
    </li-date-range-picker>
  ''',
  directives: [coreDirectives, LiDateRangePickerComponent],
)
class DateRangePickerMobileTestHostComponent {
  @ViewChild('picker')
  LiDateRangePickerComponent? picker;

  DateTime? rangeStart = DateTime(2026, 4, 10);
  DateTime? rangeEnd = DateTime(2026, 4, 12);

  void onStartChange(DateTime? value) {
    rangeStart = value;
  }

  void onEndChange(DateTime? value) {
    rangeEnd = value;
  }
}

@Component(
  selector: 'li-date-range-picker-presets-test-host',
  template: '''
    <li-date-range-picker
        #picker
        [start]="rangeStart"
        [end]="rangeEnd"
        [presets]="presets"
        [presetAutoApply]="presetAutoApply"
        [alwaysShowCalendars]="alwaysShowCalendars"
        [showCalendarsForCustomRange]="showCalendarsForCustomRange"
        [showCustomRangePreset]="showCustomRangePreset"
        (startChange)="onStartChange(\$event)"
        (endChange)="onEndChange(\$event)"
        (userValueChange)="userRange = \$event">
    </li-date-range-picker>
  ''',
  directives: [coreDirectives, LiDateRangePickerComponent],
)
class DateRangePickerPresetsTestHostComponent {
  @ViewChild('picker')
  LiDateRangePickerComponent? picker;

  DateTime? rangeStart = DateTime(2026, 6, 1);
  DateTime? rangeEnd = DateTime(2026, 6, 30);
  LiDateRangeValue? userRange;
  bool presetAutoApply = true;
  bool alwaysShowCalendars = false;
  bool showCalendarsForCustomRange = false;
  bool showCustomRangePreset = true;

  final List<LiDateRangePreset> presets = <LiDateRangePreset>[
    LiDateRangePreset(
      label: 'Today',
      value: 'today',
      start: DateTime(2026, 6, 29),
      end: DateTime(2026, 6, 29),
    ),
    LiDateRangePreset(
      label: 'Last 7 Days',
      value: 'last_7_days',
      start: DateTime(2026, 6, 23),
      end: DateTime(2026, 6, 29),
    ),
    LiDateRangePreset(
      label: 'This Month',
      value: 'this_month',
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 30),
    ),
  ];

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
  final mobileTestBed = NgTestBed<DateRangePickerMobileTestHostComponent>(
    ng.DateRangePickerMobileTestHostComponentNgFactory,
  );
  final presetsTestBed = NgTestBed<DateRangePickerPresetsTestHostComponent>(
    ng.DateRangePickerPresetsTestHostComponentNgFactory,
  );

  test('clear button resets the selected range', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    final clearButton = web.document
        .querySelectorAll('.drp-buttons .btn-light')
        .toElementList()[0] as web.HTMLButtonElement;

    await fixture.update((_) {
      clearButton.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.rangeStart, isNull);
    expect(host.rangeEnd, isNull);
    expect(host.userRange, isNull);
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
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    expect(host.userRange, isNull);

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
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
    expect(host.userRange?.inicio, DateTime(2026, 4, 14));
    expect(host.userRange?.fim, DateTime(2026, 4, 18));

    final input = fixture.rootElement.querySelector('.date-range-field')
        as web.HTMLInputElement;
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
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    if (_usesMobileDateRangeLayout()) {
      final panel = await _waitForCenteredPanelElement(
        fixture,
        host.picker!.panelElement,
      );
      final panelRect = panel.getBoundingClientRect();
      final viewportCenterX = web.window.innerWidth / 2;
      final viewportCenterY = web.window.innerHeight / 2;

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
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
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
      yearButton!.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
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
      monthButton!.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
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
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      final headers = web.document
          .querySelectorAll('.date-range-panel-header')
          .toElementList();
      final leftNext = headers[0].querySelector('.calendar-nav.next');
      expect(leftNext, isNotNull);
      leftNext!.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.picker!.leftMonth, DateTime(2026, 5, 1));
    expect(host.picker!.rightMonth, DateTime(2026, 6, 1));

    await fixture.update((_) {
      final headers = web.document
          .querySelectorAll('.date-range-panel-header')
          .toElementList();
      final rightPrev = headers[1].querySelector('.calendar-nav.prev');
      expect(rightPrev, isNotNull);
      rightPrev!.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
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
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
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

  test('can present as a centered mobile modal', () async {
    final fixture = await mobileTestBed.create();
    await _settleMobile(fixture);

    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settleMobile(fixture);

    final panel = fixture.rootElement.querySelector(
      '.date-range-open--mobile-modal.is-open',
    );
    expect(panel, isNotNull);
    expect(panel!.getAttribute('role'), 'dialog');
    expect(panel.getAttribute('aria-modal'), 'true');
    expect(
      fixture.rootElement.querySelector('.date-range-mobile-backdrop'),
      isNotNull,
    );
  });

  test('applies predefined ranges by clicking a preset', () async {
    final fixture = await presetsTestBed.create();
    await _settlePresets(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settlePresets(fixture);

    expect(
      web.document
          .querySelectorAll('.date-range-open.is-open .drp-calendar')
          .toElementList(),
      isEmpty,
    );

    final preset = web.document.querySelector(
      '[data-label="li_drp_preset"][data-value="last_7_days"]',
    ) as web.HTMLButtonElement;

    await fixture.update((_) {
      preset.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settlePresets(fixture);

    expect(host.rangeStart, DateTime(2026, 6, 23));
    expect(host.rangeEnd, DateTime(2026, 6, 29));
    expect(host.userRange?.inicio, DateTime(2026, 6, 23));
    expect(host.userRange?.fim, DateTime(2026, 6, 29));
    expect(host.picker!.isOpen, isFalse);
  });

  test('custom range preset reveals calendars', () async {
    final fixture = await presetsTestBed.create();
    await _settlePresets(fixture);
    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settlePresets(fixture);

    expect(
      web.document
          .querySelectorAll('.date-range-open.is-open .drp-calendar')
          .toElementList(),
      isEmpty,
    );

    final customRangeButton = web.document.querySelector(
      '[data-label="li_drp_range"]',
    ) as web.HTMLButtonElement;

    await fixture.update((_) {
      customRangeButton
          .dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settlePresets(fixture);

    expect(
      web.document
          .querySelectorAll('.date-range-open.is-open .drp-calendar')
          .toElementList(),
      hasLength(2),
    );
    expect(customRangeButton.classList.contains('active'), isTrue);
    expect(
      web.document
          .querySelector(
            '[data-label="li_drp_preset"][data-value="this_month"]',
          )!
          .classList
          .toDartSet()
          .contains('active'),
      isFalse,
    );

    final panel = web.document.querySelector(
      '.date-range-open.is-open',
    ) as web.Element;
    expect(
      panel.classList.contains('date-range-open--with-preset-calendars'),
      isTrue,
    );
    expect(
      panel.getBoundingClientRect().right <= web.window.innerWidth + 1,
      isTrue,
      reason: 'Preset calendar panel should stay inside the viewport.',
    );
    expect(
      web.window.getComputedStyle(panel).overflowX,
      isNot('visible'),
      reason:
          'Preset calendars should be clipped or scrolled inside the panel.',
    );
  });

  test('custom values keep calendars hidden by default on open', () async {
    final fixture = await presetsTestBed.create();
    await fixture.update((host) {
      host.rangeStart = DateTime(2026, 6, 1);
      host.rangeEnd = DateTime(2026, 6, 29);
    });
    await _settlePresets(fixture);
    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settlePresets(fixture);

    expect(
      web.document
          .querySelectorAll('.date-range-open.is-open .drp-calendar')
          .toElementList(),
      isEmpty,
    );
    expect(
      web.document
          .querySelector('[data-label="li_drp_range"]')!
          .classList
          .toDartSet()
          .contains('active'),
      isTrue,
    );
  });

  test('custom values can open calendars when configured', () async {
    final fixture = await presetsTestBed.create();
    await fixture.update((host) {
      host.rangeStart = DateTime(2026, 6, 1);
      host.rangeEnd = DateTime(2026, 6, 29);
      host.showCalendarsForCustomRange = true;
    });
    await _settlePresets(fixture);
    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settlePresets(fixture);

    expect(
      web.document
          .querySelectorAll('.date-range-open.is-open .drp-calendar')
          .toElementList(),
      hasLength(2),
    );
    expect(
      web.document
          .querySelector('[data-label="li_drp_range"]')!
          .classList
          .toDartSet()
          .contains('active'),
      isTrue,
    );
  });

  test('alwaysShowCalendars keeps calendars visible beside presets', () async {
    final fixture = await presetsTestBed.create();
    await fixture.update((host) {
      host.alwaysShowCalendars = true;
    });
    await _settlePresets(fixture);
    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settlePresets(fixture);

    expect(
      web.document
          .querySelectorAll('.date-range-open.is-open .drp-calendar')
          .toElementList(),
      hasLength(2),
    );
    expect(
      web.document
          .querySelectorAll(
            '.date-range-open.is-open [data-label="li_drp_preset"]',
          )
          .toElementList(),
      hasLength(3),
    );
  });

  test('preset can wait for Apply before changing the model', () async {
    final fixture = await presetsTestBed.create();
    await fixture.update((host) {
      host.presetAutoApply = false;
    });
    await _settlePresets(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement
        .querySelector('.date-range-wrapper .input-group') as web.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settlePresets(fixture);

    final preset = web.document.querySelector(
      '[data-label="li_drp_preset"][data-value="last_7_days"]',
    ) as web.HTMLButtonElement;

    await fixture.update((_) {
      preset.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settlePresets(fixture);

    expect(host.rangeStart, DateTime(2026, 6, 1));
    expect(host.rangeEnd, DateTime(2026, 6, 30));
    expect(host.picker!.draftInicio, DateTime(2026, 6, 23));
    expect(host.picker!.draftFim, DateTime(2026, 6, 29));
    expect(host.picker!.isOpen, isTrue);
    expect(
      web.document
          .querySelectorAll('.date-range-open.is-open .drp-calendar')
          .toElementList(),
      hasLength(2),
    );

    final applyButton = web.document.querySelector(
      '[data-label="li_drp_apply"]',
    ) as web.HTMLButtonElement;

    await fixture.update((_) {
      applyButton.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settlePresets(fixture);

    expect(host.rangeStart, DateTime(2026, 6, 23));
    expect(host.rangeEnd, DateTime(2026, 6, 29));
    expect(host.userRange?.inicio, DateTime(2026, 6, 23));
    expect(host.userRange?.fim, DateTime(2026, 6, 29));
    expect(host.picker!.isOpen, isFalse);
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

Future<void> _settleMobile(
  NgTestFixture<DateRangePickerMobileTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settlePresets(
  NgTestFixture<DateRangePickerPresetsTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

web.Element _openDateRangePanel() {
  final panel = web.document.querySelector('.date-range-open.is-open');
  expect(panel, isNotNull);
  return panel!;
}

bool _usesMobileDateRangeLayout() {
  return web.window.innerWidth <= 767;
}

Future<web.Element> _waitForAlignedPanelElement(
  NgTestFixture<DateRangePickerTestHostComponent> fixture,
  web.Element trigger,
  web.Element? panelElement,
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
    'innerWidth: ${web.window.innerWidth}, '
    'inline transform: ${(panel as web.HTMLElement).style.transform}, '
    'computed transform: ${web.window.getComputedStyle(panel).transform}',
  );
}

Future<web.Element> _waitForCenteredPanelElement(
  NgTestFixture<DateRangePickerTestHostComponent> fixture,
  web.Element? panelElement,
) async {
  expect(panelElement, isNotNull);
  final panel = panelElement!;
  num centerXDiff = double.infinity;
  num centerYDiff = double.infinity;

  for (var attempt = 0; attempt < 8; attempt++) {
    final innerWidth = web.window.innerWidth;
    final innerHeight = web.window.innerHeight;
    expect(innerWidth, isNotNull);
    expect(innerHeight, isNotNull);

    final panelRect = panel.getBoundingClientRect();
    centerXDiff =
        ((panelRect.left + (panelRect.width / 2)) - (innerWidth / 2)).abs();
    centerYDiff =
        ((panelRect.top + (panelRect.height / 2)) - (innerHeight / 2)).abs();

    if (centerXDiff <= 2 && centerYDiff <= 2) {
      return panel;
    }

    await Future<void>.delayed(const Duration(milliseconds: 40));
    await fixture.update((_) {});
  }

  fail(
    'Open panel did not center in mobile layout. '
    'centerX diff: $centerXDiff, centerY diff: $centerYDiff, '
    'innerWidth: ${web.window.innerWidth}, innerHeight: ${web.window.innerHeight}, '
    'inline transform: ${(panel as web.HTMLElement).style.transform}, '
    'computed transform: ${web.window.getComputedStyle(panel).transform}',
  );
}
