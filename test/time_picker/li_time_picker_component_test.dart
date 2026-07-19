// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/time_picker/li_time_picker_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_time_picker_component_test.template.dart' as ng;

@Component(
  selector: 'li-time-picker-test-host',
  template: '''
    <li-time-picker
        #picker
        [value]="value"
        [use24Hour]="true"
        (userValueChange)="userValue = \$event"
        (valueChange)="value = \$event">
    </li-time-picker>
  ''',
  directives: [coreDirectives, LiTimePickerComponent],
)
class TimePickerTestHostComponent {
  @ViewChild('picker')
  LiTimePickerComponent? picker;

  Duration? value = const Duration(hours: 18, minutes: 30);
  Duration? userValue;
}

@Component(
  selector: 'li-time-picker-mobile-test-host',
  template: '''
    <li-time-picker
        #picker
        [value]="value"
        [use24Hour]="true"
        mobileHeightBreakpoint="9999px"
        (valueChange)="value = \$event">
    </li-time-picker>
  ''',
  directives: [coreDirectives, LiTimePickerComponent],
)
class TimePickerMobileTestHostComponent {
  @ViewChild('picker')
  LiTimePickerComponent? picker;

  Duration? value = const Duration(hours: 18, minutes: 30);
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TimePickerTestHostComponent>(
    ng.TimePickerTestHostComponentNgFactory,
  );
  final mobileTestBed = NgTestBed<TimePickerMobileTestHostComponent>(
    ng.TimePickerMobileTestHostComponentNgFactory,
  );

  test('opens overlay aligned directly below the trigger', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
        .querySelector('.time-picker-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final panel = html.document.querySelector(
      '.time-picker-panel.is-open',
    ) as html.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect((panelRect.left - triggerRect.left).abs(), lessThanOrEqualTo(1.5));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));
  });

  test('renders footer separator across the panel', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
        .querySelector('.time-picker-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final panel = html.document.querySelector(
      '.time-picker-panel.is-open',
    ) as html.Element;
    final footer = panel.querySelector('.time-picker-footer') as html.Element;
    final footerStyle = footer.getComputedStyle();
    final panelRect = panel.getBoundingClientRect();
    final footerRect = footer.getBoundingClientRect();

    expect(footerStyle.borderTopStyle, 'solid');
    expect(footerStyle.borderTopWidth, isNot('0px'));
    expect((footerRect.left - panelRect.left).abs(), lessThanOrEqualTo(1.5));
    expect((footerRect.width - panelRect.width).abs(), lessThanOrEqualTo(2));
  });

  test('emits userValueChange when applying a changed time', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.userValue, isNull);

    await fixture.update((_) {
      host.picker!.toggleOpen();
      host.picker!.draftHour24 = 9;
      host.picker!.draftMinute = 45;
      host.picker!.apply();
    });
    await _settle(fixture);

    expect(host.value, const Duration(hours: 9, minutes: 45));
    expect(host.userValue, const Duration(hours: 9, minutes: 45));

    await fixture.update((component) {
      component.value = const Duration(hours: 10, minutes: 15);
    });
    await _settle(fixture);

    expect(host.value, const Duration(hours: 10, minutes: 15));
    expect(host.userValue, const Duration(hours: 9, minutes: 45));
  });

  test('uses a fullscreen mobile modal by default', () async {
    final fixture = await mobileTestBed.create();
    await _settleMobile(fixture);

    final trigger = fixture.rootElement
        .querySelector('.time-picker-wrapper .input-group') as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settleMobile(fixture);

    final panel = html.document.querySelector(
      '.time-picker-panel--mobile-modal.is-open',
    );
    expect(panel, isNotNull);
    expect(panel!.getAttribute('role'), 'dialog');
    expect(panel.getAttribute('aria-modal'), 'true');
    expect(
      fixture.rootElement.querySelector('.time-picker-mobile-backdrop'),
      isNotNull,
    );

    final panelRect = panel.getBoundingClientRect();
    final viewportWidth = html.window.innerWidth!;
    final viewportHeight = html.window.innerHeight!;
    expect(panelRect.top.abs(), lessThanOrEqualTo(1));
    expect(panelRect.left.abs(), lessThanOrEqualTo(1));
    expect(panelRect.width, greaterThanOrEqualTo(viewportWidth - 1));
    expect(panelRect.height, greaterThanOrEqualTo(viewportHeight - 1));
    expect(panel.getComputedStyle().overflow, 'hidden');
  });
}

Future<void> _settle(
  NgTestFixture<TimePickerTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleMobile(
  NgTestFixture<TimePickerMobileTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
