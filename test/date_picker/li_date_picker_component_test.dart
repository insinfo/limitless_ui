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
        (userValueChange)="userValue = \$event"
        (valueChange)="value = \$event">
    </li-date-picker>
  ''',
  directives: [coreDirectives, LiDatePickerComponent],
)
class DatePickerTestHostComponent {
  @ViewChild('picker')
  LiDatePickerComponent? picker;

  DateTime? value = DateTime(2026, 4, 6);
  DateTime? userValue;
}

@Component(
  selector: 'li-date-picker-mobile-test-host',
  template: '''
    <li-date-picker
        #picker
        [value]="value"
        mobileHeightBreakpoint="9999px"
        (valueChange)="value = \$event">
    </li-date-picker>
  ''',
  directives: [coreDirectives, LiDatePickerComponent],
)
class DatePickerMobileTestHostComponent {
  @ViewChild('picker')
  LiDatePickerComponent? picker;

  DateTime? value = DateTime(2026, 4, 6);
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DatePickerTestHostComponent>(
    ng.DatePickerTestHostComponentNgFactory,
  );
  final mobileTestBed = NgTestBed<DatePickerMobileTestHostComponent>(
    ng.DatePickerMobileTestHostComponentNgFactory,
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

  test('emits userValueChange only for user date selection', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.userValue, isNull);

    await fixture.update((_) {
      host.picker!.toggleOpen();
      host.picker!.selectDay(DateTime(2026, 4, 9));
    });
    await _settle(fixture);

    expect(host.value, DateTime(2026, 4, 9));
    expect(host.userValue, DateTime(2026, 4, 9));

    await fixture.update((component) {
      component.value = DateTime(2026, 4, 11);
    });
    await _settle(fixture);

    expect(host.value, DateTime(2026, 4, 11));
    expect(host.userValue, DateTime(2026, 4, 9));
  });

  test('uses a fullscreen mobile modal by default', () async {
    final fixture = await mobileTestBed.create();
    await _settleMobile(fixture);

    final trigger = fixture.rootElement
        .querySelector('.date-picker-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settleMobile(fixture);

    final panel = html.document.querySelector(
      '.date-picker-open--mobile-modal.is-open',
    );
    expect(panel, isNotNull);
    expect(panel!.getAttribute('role'), 'dialog');
    expect(panel.getAttribute('aria-modal'), 'true');
    expect(
      fixture.rootElement.querySelector('.date-picker-mobile-backdrop'),
      isNotNull,
    );

    final panelRect = panel.getBoundingClientRect();
    final viewportWidth = html.window.innerWidth!;
    final viewportHeight = html.window.innerHeight!;
    expect(panelRect.top.abs(), lessThanOrEqualTo(1));
    expect(panelRect.left.abs(), lessThanOrEqualTo(1));
    expect(panelRect.width, greaterThanOrEqualTo(viewportWidth - 1));
    expect(panelRect.height, greaterThanOrEqualTo(viewportHeight - 1));
    final panelStyle = panel.getComputedStyle();
    expect(panelStyle.overflowX, 'hidden');
    expect(panelStyle.overflowY, 'auto');
  });
}

Future<void> _settle(
  NgTestFixture<DatePickerTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleMobile(
  NgTestFixture<DatePickerMobileTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
