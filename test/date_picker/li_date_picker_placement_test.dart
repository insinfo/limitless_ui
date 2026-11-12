// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/date_picker/li_date_picker_placement_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_date_picker_placement_test.template.dart' as ng;

/// Picker on a fixed strip whose `top` the test sets, so the field can sit
/// near the bottom of the window without resizing it.
@Component(
  selector: 'li-date-picker-placement-host',
  template: '''
    <div id="strip" style="position: fixed; left: 40px; width: 260px;"
        [style.top.px]="top">
      <li-date-picker #picker [value]="value"></li-date-picker>
    </div>
  ''',
  directives: [coreDirectives, LiDatePickerComponent],
)
class DatePickerPlacementHostComponent {
  @ViewChild('picker')
  LiDatePickerComponent? picker;

  num top = 20;

  /// Empty, as in the Ciente search form: opening an empty picker changes no
  /// text in the panel, so popper's mutation observer never runs a second
  /// layout that would hide a wrong first one. With a value, the footer
  /// switches from "no date" to the date on open and that second layout
  /// happened to fix the position.
  DateTime? value;
}

/// Picker inside a scroll container, to check the panel follows the field
/// when only the container scrolls.
@Component(
  selector: 'li-date-picker-scroll-host',
  template: '''
    <div id="scroller" style="position: fixed; top: 10px; left: 40px;
        width: 300px; height: 300px; overflow: auto;">
      <div style="height: 120px;"></div>
      <li-date-picker #picker [value]="value"></li-date-picker>
      <div style="height: 1200px;"></div>
    </div>
  ''',
  directives: [coreDirectives, LiDatePickerComponent],
)
class DatePickerScrollHostComponent {
  @ViewChild('picker')
  LiDatePickerComponent? picker;

  DateTime? value = DateTime(2026, 11, 10);
}

void main() {
  tearDown(() async {
    html.document.getElementById('li-dp-placement-tall')?.remove();
    await disposeAnyRunningTest();
  });

  final testBed = NgTestBed<DatePickerPlacementHostComponent>(
    ng.DatePickerPlacementHostComponentNgFactory,
  );
  final scrollTestBed = NgTestBed<DatePickerScrollHostComponent>(
    ng.DatePickerScrollHostComponentNgFactory,
  );

  double viewportHeight() =>
      (html.document.documentElement?.clientHeight ?? 0).toDouble();

  Future<html.Element> openAt(
    NgTestFixture<DatePickerPlacementHostComponent> fixture,
    num top,
  ) async {
    await fixture.update((host) => host.top = top);
    await _frames();
    final trigger = _trigger(fixture.rootElement);
    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _frames();
    return _openPanel();
  }

  test('opens below the field when it fits', () async {
    final fixture = await testBed.create();
    final panel = await openAt(fixture, 20);

    final triggerRect = _trigger(fixture.rootElement).getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect(panel.getAttribute('data-popper-placement'), startsWith('bottom'));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));
    expect((panelRect.left - triggerRect.left).abs(), lessThanOrEqualTo(1.5));
    expect(panelRect.bottom, lessThanOrEqualTo(viewportHeight()));
  });

  test(
      'opens above, glued to the field, when it does not fit below — '
      'already on the first open, with no resize', () async {
    final fixture = await testBed.create();
    await fixture.update((host) => host.top = viewportHeight() - 60);
    await _frames();
    final trigger = _trigger(fixture.rootElement);
    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _frames(1);
    final panel = _openPanel();

    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();
    final header = panel.querySelector('.date-picker-panel-header')!;

    expect(panel.getAttribute('data-popper-placement'), startsWith('top'));
    expect((panelRect.bottom - triggerRect.top).abs(), lessThanOrEqualTo(1.5),
        reason: 'panel ${_describe(panelRect)}, '
            'trigger ${_describe(triggerRect)}');
    expect(panelRect.top, greaterThanOrEqualTo(0));
    expect(panel.style.maxHeight, isEmpty,
        reason: 'it fits above, so there is no cap');
    _expectHeaderVisible(header);
  });

  test(
      'with no room on either side stays on the roomier side, glued, '
      'capped and scrollable, with the month header visible — on the first '
      'open, with no resize', () async {
    // The Ciente case: a panel about 60% of the window tall and a field a
    // little below the middle, so it fits neither below nor above.
    final tall = html.StyleElement()
      ..id = 'li-dp-placement-tall'
      ..text = '[data-label="li_dp_panel"] .calendar-table '
          '{ min-height: ${(viewportHeight() * 0.6).round()}px; }';
    html.document.head!.append(tall);

    final fixture = await testBed.create();
    final top = viewportHeight() * 0.55;
    await fixture.update((host) => host.top = top);
    await _frames();
    final trigger = _trigger(fixture.rootElement);
    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    // A single frame: the first layout has to be right, not a later one.
    await _frames(1);
    final panel = _openPanel();

    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();
    final header = panel.querySelector('.date-picker-panel-header')!;

    expect(panel.getAttribute('data-popper-placement'), startsWith('top'));
    expect((panelRect.bottom - triggerRect.top).abs(), lessThanOrEqualTo(1.5),
        reason: 'panel ${_describe(panelRect)}, '
            'trigger ${_describe(triggerRect)}');
    expect(panelRect.top, greaterThanOrEqualTo(7.5));
    expect(panel.style.maxHeight, isNotEmpty);
    expect(panel.getComputedStyle().overflowY, 'auto');
    expect(panel.scrollHeight, greaterThan(panel.clientHeight));
    _expectHeaderVisible(header);

    // Still there a few frames later: nothing moves it afterwards.
    await _frames();
    final settledRect = panel.getBoundingClientRect();
    expect(settledRect.top, closeTo(panelRect.top, 1));
    expect(settledRect.bottom, closeTo(panelRect.bottom, 1));
  });

  test('with no room on either side and more room below, opens below capped',
      () async {
    final tall = html.StyleElement()
      ..id = 'li-dp-placement-tall'
      ..text = '[data-label="li_dp_panel"] .calendar-table '
          '{ min-height: ${(viewportHeight() * 0.6).round()}px; }';
    html.document.head!.append(tall);

    final fixture = await testBed.create();
    final panel = await openAt(fixture, viewportHeight() * 0.35);

    final triggerRect = _trigger(fixture.rootElement).getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect(panel.getAttribute('data-popper-placement'), startsWith('bottom'));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));
    expect(panelRect.bottom, lessThanOrEqualTo(viewportHeight() - 7.5));
    expect(panel.style.maxHeight, isNotEmpty);
    _expectHeaderVisible(panel.querySelector('.date-picker-panel-header')!);
  });

  test('keeps the panel glued above when the content changes height',
      () async {
    final fixture = await testBed.create();
    final panel = await openAt(fixture, viewportHeight() - 60);
    final heightBefore = panel.getBoundingClientRect().height;

    await fixture.update((host) => host.picker!.toggleViewMode());
    await _frames();

    final triggerRect = _trigger(fixture.rootElement).getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();
    expect(panelRect.height, isNot(closeTo(heightBefore, 1)),
        reason: 'the month grid should not be as tall as the day grid');
    expect((panelRect.bottom - triggerRect.top).abs(), lessThanOrEqualTo(1.5),
        reason: 'panel ${_describe(panelRect)}, '
            'trigger ${_describe(triggerRect)}');
  });

  test(
      'keeps the panel glued above when it changes size with no DOM '
      'mutation (a stylesheet, a web font)', () async {
    final fixture = await testBed.create();
    final panel = await openAt(fixture, viewportHeight() - 60);
    final heightBefore = panel.getBoundingClientRect().height;

    final taller = html.StyleElement()
      ..id = 'li-dp-placement-tall'
      ..text = '[data-label="li_dp_panel"] .drp-buttons '
          '{ padding-bottom: 60px; }';
    html.document.head!.append(taller);
    await _frames();

    final triggerRect = _trigger(fixture.rootElement).getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();
    expect(panelRect.height, greaterThan(heightBefore + 30));
    expect((panelRect.bottom - triggerRect.top).abs(), lessThanOrEqualTo(1.5),
        reason: 'panel ${_describe(panelRect)}, '
            'trigger ${_describe(triggerRect)}');
  });

  test('follows the field when a scroll container scrolls', () async {
    final fixture = await scrollTestBed.create();
    await _frames();
    final trigger = _trigger(fixture.rootElement);
    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _frames();
    final panel = _openPanel();

    final scroller = fixture.rootElement.querySelector('#scroller')!;
    scroller.scrollTop = 60;
    scroller.dispatchEvent(html.Event('scroll'));
    await _frames();

    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();
    expect(triggerRect.top, closeTo(10 + 120 - 60, 2));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5),
        reason: 'panel ${_describe(panelRect)}, '
            'trigger ${_describe(triggerRect)}');
  });
}

html.Element _trigger(html.Element root) =>
    root.querySelector('[data-label="li_dp_trigger"]')!;

html.Element _openPanel() =>
    html.document.querySelector('[data-label="li_dp_panel"].is-open')!;

/// The header row (month and arrows) is entirely inside the viewport and is
/// what the browser hits at its centre.
void _expectHeaderVisible(html.Element header) {
  final rect = header.getBoundingClientRect();
  final viewportHeight =
      (html.document.documentElement?.clientHeight ?? 0).toDouble();
  expect(rect.top, greaterThanOrEqualTo(0), reason: 'header ${_describe(rect)}');
  expect(rect.bottom, lessThanOrEqualTo(viewportHeight));
  final hit = html.document.elementFromPoint(
    (rect.left + rect.width / 2).round(),
    (rect.top + rect.height / 2).round(),
  );
  expect(hit != null && header.contains(hit), isTrue,
      reason: 'the month header should be on top at its centre');
}

String _describe(html.Rectangle<num> rect) =>
    'top ${rect.top.toStringAsFixed(1)} bottom ${rect.bottom.toStringAsFixed(1)} '
    'height ${rect.height.toStringAsFixed(1)}';

/// A few animation frames: enough for change detection, the popper update
/// queued on rAF and a ResizeObserver round trip.
Future<void> _frames([int count = 4]) async {
  for (var i = 0; i < count; i++) {
    final completer = Completer<void>();
    html.window.requestAnimationFrame((_) => completer.complete());
    await completer.future;
  }
  await Future<void>.delayed(const Duration(milliseconds: 20));
}
