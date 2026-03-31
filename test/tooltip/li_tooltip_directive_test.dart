// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/tooltip/li_tooltip_directive_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_tooltip_directive_test.template.dart' as ng;

@Component(
  selector: 'tooltip-test-host',
  template: '''
    <div>
      <button
          id="hover-trigger"
          [liTooltip]="hoverText"
          triggers="hover focus"
          placement="top"
          [animation]="false"
          (show)="showCount = showCount + 1"
          (shown)="shownCount = shownCount + 1"
          (hide)="hideCount = hideCount + 1"
          (hidden)="hiddenCount = hiddenCount + 1">
        Hover trigger
      </button>

      <button
          id="manual-trigger"
          #manualTooltip="liTooltip"
          [liTooltip]="manualText"
          triggers="manual"
          placement="right"
          [animation]="false"
          (click)="toggleManualTooltip()"
          tooltipClass="tooltip-info">
        Manual trigger
      </button>

      <button
          id="inside-trigger"
          #insideTooltip="liTooltip"
          [liTooltip]="insideText"
          triggers="click"
          autoClose="inside"
          [animation]="false">
        Inside trigger
      </button>

      <button
          id="config-trigger"
          [liTooltip]="configText"
          [animation]="false">
        Config trigger
      </button>

      <div id="inline-wrapper">
        <button
            id="inline-trigger"
            [liTooltip]="inlineText"
            triggers="click"
            [animation]="false">
          Inline trigger
        </button>
      </div>

      <div id="body-wrapper">
        <button
            id="body-trigger"
            [liTooltip]="bodyText"
            triggers="click"
            container="body"
            [animation]="false">
          Body trigger
        </button>
      </div>

      <template #richTooltip>
        <span class="template-tooltip-body">{{ templateText }}</span>
      </template>

      <button
          id="template-trigger"
          [liTooltip]="richTooltip"
          triggers="click"
          [animation]="false">
        Template trigger
      </button>

      <button id="outside-target" type="button">Outside target</button>
    </div>
  ''',
  providers: [ClassProvider(LiTooltipConfig)],
  directives: [coreDirectives, LiTooltipDirective],
)
class TooltipTestHostComponent {
  TooltipTestHostComponent(this.tooltipConfig) {
    tooltipConfig.triggers = 'click';
    tooltipConfig.placement = 'bottom';
    tooltipConfig.tooltipClass = 'tooltip-config-demo';
    tooltipConfig.autoClose = 'outside';
  }

  final LiTooltipConfig tooltipConfig;

  @ViewChild('manualTooltip')
  LiTooltipDirective? manualTooltip;

  @ViewChild('insideTooltip')
  LiTooltipDirective? insideTooltip;

  String hoverText = 'Hover tooltip body';
  String manualText = 'Manual tooltip body';
  String insideText = 'Inside tooltip body';
  String configText = 'Tooltip driven by config defaults';
  String inlineText = 'Inline tooltip body';
  String bodyText = 'Body tooltip body';
  String templateText = 'Tooltip rendered from TemplateRef';

  int showCount = 0;
  int shownCount = 0;
  int hideCount = 0;
  int hiddenCount = 0;

  void toggleManualTooltip() {
    manualTooltip?.toggle();
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TooltipTestHostComponent>(
    ng.TooltipTestHostComponentNgFactory,
  );

  test('hover trigger opens and closes with lifecycle events', () async {
    final fixture = await testBed.create();
    await _settleTooltip(fixture);
    final host = fixture.assertOnlyInstance;
    final hoverTrigger = fixture.rootElement.querySelector('#hover-trigger');

    expect(hoverTrigger, isNotNull);

    await fixture.update((_) {
      hoverTrigger!
          .dispatchEvent(html.MouseEvent('mouseenter', canBubble: true));
    });
    await _settleTooltip(fixture);

    final tooltip = _tooltipElement();
    expect(tooltip, isNotNull);
    expect(tooltip!.text, contains('Hover tooltip body'));
    expect(host.showCount, 1);
    expect(host.shownCount, 1);

    await fixture.update((_) {
      hoverTrigger!
          .dispatchEvent(html.MouseEvent('mouseleave', canBubble: true));
    });
    await _settleTooltip(fixture);

    expect(_tooltipElement(), isNull);
    expect(host.hideCount, 1);
    expect(host.hiddenCount, 1);
  });

  test('manual API opens toggles and closes through ViewChild', () async {
    final fixture = await testBed.create();
    await _settleTooltip(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.manualTooltip, isNotNull);
    expect(host.manualTooltip!.isOpen(), isFalse);

    await fixture.update((component) {
      component.manualTooltip!.open();
    });
    await _settleTooltip(fixture);

    final tooltip = _tooltipElement();
    expect(host.manualTooltip!.isOpen(), isTrue);
    expect(tooltip, isNotNull);
    expect(tooltip!.classes.contains('tooltip-info'), isTrue);
    expect(tooltip.text, contains('Manual tooltip body'));

    await fixture.update((component) {
      component.manualTooltip!.toggle();
    });
    await _settleTooltip(fixture);

    expect(host.manualTooltip!.isOpen(), isFalse);
    expect(_tooltipElement(), isNull);

    await fixture.update((component) {
      component.manualTooltip!.open();
    });
    await _settleTooltip(fixture);

    await fixture.update((component) {
      component.manualTooltip!.close(false);
    });
    await _settleTooltip(fixture);

    expect(host.manualTooltip!.isOpen(), isFalse);
  });

  test('manual tooltip can open from host click handler', () async {
    final fixture = await testBed.create();
    await _settleTooltip(fixture);
    final host = fixture.assertOnlyInstance;
    final manualTrigger = fixture.rootElement.querySelector('#manual-trigger');

    expect(host.manualTooltip, isNotNull);
    expect(manualTrigger, isNotNull);

    await fixture.update((_) {
      _click(manualTrigger!);
    });
    await _settleTooltip(fixture);

    expect(host.manualTooltip!.isOpen(), isTrue);
    expect(_tooltipElement(), isNotNull);
  });

  test('autoClose inside closes only after inside click', () async {
    final fixture = await testBed.create();
    await _settleTooltip(fixture);
    final host = fixture.assertOnlyInstance;
    final insideTrigger = fixture.rootElement.querySelector('#inside-trigger');
    final outsideTarget = fixture.rootElement.querySelector('#outside-target');

    expect(host.insideTooltip, isNotNull);

    await fixture.update((_) {
      _click(insideTrigger!);
    });
    await _settleTooltip(fixture);

    expect(host.insideTooltip!.isOpen(), isTrue);

    await fixture.update((_) {
      _click(outsideTarget!);
    });
    await _settleTooltip(fixture);

    expect(host.insideTooltip!.isOpen(), isTrue);

    final tooltip = _tooltipElement();
    expect(tooltip, isNotNull);

    await fixture.update((_) {
      _click(tooltip!);
    });
    await _settleTooltip(fixture);

    expect(host.insideTooltip!.isOpen(), isFalse);
    expect(_tooltipElement(), isNull);
  });

  test('LiTooltipConfig provides local default trigger and class', () async {
    final fixture = await testBed.create();
    await _settleTooltip(fixture);
    final configTrigger = fixture.rootElement.querySelector('#config-trigger');

    expect(configTrigger, isNotNull);

    await fixture.update((_) {
      _click(configTrigger!);
    });
    await _settleTooltip(fixture);

    final tooltip = _tooltipElement();
    expect(tooltip, isNotNull);
    expect(tooltip!.classes.contains('tooltip-config-demo'), isTrue);
    expect(tooltip.text, contains('Tooltip driven by config defaults'));
  });

  test('container body appends tooltip outside local wrapper', () async {
    final fixture = await testBed.create();
    await _settleTooltip(fixture);

    final inlineTrigger = fixture.rootElement.querySelector('#inline-trigger');
    final bodyTrigger = fixture.rootElement.querySelector('#body-trigger');
    final inlineWrapper = fixture.rootElement.querySelector('#inline-wrapper');
    final bodyWrapper = fixture.rootElement.querySelector('#body-wrapper');

    expect(inlineTrigger, isNotNull);
    expect(bodyTrigger, isNotNull);
    expect(inlineWrapper, isNotNull);
    expect(bodyWrapper, isNotNull);

    await fixture.update((_) {
      _click(inlineTrigger!);
    });
    await _settleTooltip(fixture);

    final inlineTooltip = _tooltipElement();
    expect(inlineTooltip, isNotNull);
    expect(inlineWrapper!.contains(inlineTooltip), isTrue);

    await fixture.update((_) {
      _click(inlineTrigger!);
    });
    await _settleTooltip(fixture);

    await fixture.update((_) {
      _click(bodyTrigger!);
    });
    await _settleTooltip(fixture);

    final bodyTooltip = _tooltipElement();
    expect(bodyTooltip, isNotNull);
    expect(bodyWrapper!.contains(bodyTooltip), isFalse);
    expect(html.document.body!.contains(bodyTooltip), isTrue);
  });

  test('TemplateRef tooltip content renders rich DOM nodes', () async {
    final fixture = await testBed.create();
    await _settleTooltip(fixture);
    final templateTrigger =
        fixture.rootElement.querySelector('#template-trigger');

    expect(templateTrigger, isNotNull);

    await fixture.update((_) {
      _click(templateTrigger!);
    });
    await _settleTooltip(fixture);

    final tooltip = _tooltipElement();
    final templateBody = tooltip?.querySelector('.template-tooltip-body');

    expect(tooltip, isNotNull);
    expect(templateBody, isNotNull);
    expect(templateBody!.text, contains('Tooltip rendered from TemplateRef'));
  });
}

void _click(html.Element element) {
  element.dispatchEvent(html.MouseEvent('click', canBubble: true));
}

html.DivElement? _tooltipElement() {
  final tooltip = html.document.querySelector('.tooltip');
  return tooltip is html.DivElement ? tooltip : null;
}

Future<void> _settleTooltip(
  NgTestFixture<TooltipTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}
