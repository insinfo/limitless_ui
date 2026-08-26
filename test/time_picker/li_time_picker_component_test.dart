// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/time_picker/li_time_picker_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;
import 'dart:math' as math;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
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

  test('aneis do relogio 24h nao se sobrepoem', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      host.picker!.toggleOpen();
    });
    await _settle(fixture);

    final labels = host.picker!.visibleDialLabels;
    final outer = labels.firstWhere((label) => !label.isInnerRing);
    final inner = labels.firstWhere((label) => label.isInnerRing);

    double radiusOf(TimePickerDialLabel label) {
      final dx = label.leftPercent - 50;
      final dy = label.topPercent - 50;
      return math.sqrt(dx * dx + dy * dy);
    }

    final clock = html.document.querySelector('.time-picker-clock')
        as html.Element;
    final width = clock.getBoundingClientRect().width;
    final separation = (radiusOf(outer) - radiusOf(inner)) / 100 * width;

    final outerLabel = html.document.querySelector(
      '.time-picker-dial-label:not(.time-picker-dial-label-inner)',
    ) as html.Element;
    final innerLabel = html.document.querySelector(
      '.time-picker-dial-label-inner',
    ) as html.Element;

    // A etiqueta interna precisa ser menor que a externa, e a distância entre
    // os raios precisa passar da soma das metades das alturas — senão os dois
    // anéis se encostam, que era o caso quando a classe do anel interno não
    // tinha nenhuma regra de CSS.
    final outerHeight = outerLabel.getBoundingClientRect().height;
    final innerHeight = innerLabel.getBoundingClientRect().height;

    expect(innerHeight, lessThan(outerHeight));
    expect(separation, greaterThan((outerHeight + innerHeight) / 2));
  });

  test('disco do seletor cai em cima da etiqueta, nos dois aneis', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    Future<void> selectHour(int hour24) async {
      await fixture.update((_) {
        host.picker!.draftHour24 = hour24;
      });
      await _settle(fixture);
    }

    Future<void> expectSelectorOverLabel(int hour24) async {
      await selectHour(hour24);

      final selector = html.document.querySelector(
        '.time-picker-selector-label',
      ) as html.Element;
      final active = html.document.querySelector(
        '.time-picker-dial-label.active',
      );

      expect(active, isNotNull, reason: 'nenhuma etiqueta ativa para $hour24');

      final selectorRect = selector.getBoundingClientRect();
      final labelRect = active!.getBoundingClientRect();
      final dx = (selectorRect.left + selectorRect.width / 2) -
          (labelRect.left + labelRect.width / 2);
      final dy = (selectorRect.top + selectorRect.height / 2) -
          (labelRect.top + labelRect.height / 2);

      expect(dx.abs(), lessThanOrEqualTo(1.5),
          reason: 'seletor fora do eixo x em $hour24');
      expect(dy.abs(), lessThanOrEqualTo(1.5),
          reason: 'seletor fora do eixo y em $hour24');
    }

    await fixture.update((_) {
      host.picker!.toggleOpen();
    });
    await _settle(fixture);

    // Anel externo, nos quatro quadrantes.
    await expectSelectorOverLabel(12);
    await expectSelectorOverLabel(3);
    await expectSelectorOverLabel(6);
    await expectSelectorOverLabel(9);

    // Anel interno, que é onde o desencontro aparecia.
    await expectSelectorOverLabel(0);
    await expectSelectorOverLabel(15);
    await expectSelectorOverLabel(18);
    await expectSelectorOverLabel(21);
  });

  test('fronteira de clique entre os aneis acompanha o desenho', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      host.picker!.toggleOpen();
    });
    await _settle(fixture);

    final clock = html.document.querySelector('.time-picker-clock')
        as html.Element;
    final rect = clock.getBoundingClientRect();
    final centerX = rect.left + rect.width / 2;
    final centerY = rect.top + rect.height / 2;
    final halfWidth = rect.width / 2;

    Future<void> pressAtRadius(double fraction) async {
      await fixture.update((_) {
        host.picker!.clockFaceElement!.dispatchEvent(
          html.MouseEvent(
            'mousedown',
            canBubble: true,
            clientX: centerX.round(),
            clientY: (centerY - halfWidth * fraction).round(),
          ),
        );
      });
      await _settle(fixture);
    }

    // 12 horas, logo acima do centro. Perto da borda é o anel externo (12);
    // perto do centro é o interno (0). O limiar antigo era 0.72 do raio, então
    // 0.70 caía no anel interno mesmo estando visualmente no externo.
    await pressAtRadius(0.70);
    expect(host.picker!.draftHour24, 12);

    await pressAtRadius(0.35);
    expect(host.picker!.draftHour24, 0);
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
