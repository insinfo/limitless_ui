// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/popover/li_popover_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:popper/popper.dart';
import 'package:test/test.dart';

import 'li_popover_component_test.template.dart' as ng;

@Component(
  selector: 'test-host',
  template: '''
    <div class="test-surface">
      <li-popover
        #clickPopover
        [popoverTitle]="clickTitle"
        [popover]="clickBody"
        trigger="click"
        placement="bottom"
        [animation]="false"
        (shown)="onClickShown()"
        (hidden)="onClickHidden()">
        <button id="click-trigger" type="button">Click trigger</button>
      </li-popover>

      <li-popover
        #manualPopover
        [popoverTitle]="manualTitle"
        [popover]="manualBody"
        trigger="manual"
        placement="top"
        [popoverClass]="manualPopoverClass"
        [animation]="false"
        (shown)="onManualShown()"
        (hidden)="onManualHidden()">
        <button id="manual-trigger" type="button">Manual trigger</button>
      </li-popover>

      <li-popover
        #hoverPopover
        [popoverTitle]="hoverTitle"
        [popover]="hoverBody"
        trigger="hover focus"
        placement="top"
        [animation]="false">
        <button id="hover-trigger" type="button">Hover trigger</button>
      </li-popover>

      <li-popover
        #insidePopover
        [popoverTitle]="insideTitle"
        [popover]="insideBodyHtml"
        trigger="click"
        autoClose="inside"
        [html]="true"
        [animation]="false">
        <button id="inside-trigger" type="button">Inside trigger</button>
      </li-popover>

      <li-popover
        #outsidePopover
        [popoverTitle]="outsideTitle"
        [popover]="outsideBodyHtml"
        trigger="click"
        autoClose="outside"
        [html]="true"
        [animation]="false">
        <button id="outside-trigger" type="button">Outside trigger</button>
      </li-popover>

      <div id="body-wrapper">
        <li-popover
          #bodyPopover
          [popoverTitle]="bodyTitle"
          [popover]="bodyText"
          trigger="click"
          container="body"
          [animation]="false">
          <button id="body-trigger" type="button">Body trigger</button>
        </li-popover>
      </div>

      <template #templateTitle let-data>
        <span class="template-popover-title">{{ data?.title }}</span>
      </template>

      <template #templateBody let-data>
        <span class="template-popover-body">{{ data?.body }}</span>
      </template>

      <li-popover
        #templatePopover
        [popoverTitle]="templateTitle"
        [popover]="templateBody"
        [popoverContext]="defaultTemplateContext"
        trigger="manual"
        [animation]="false">
        <button id="template-trigger" type="button">Template trigger</button>
      </li-popover>

      <li-popover
        #configPopover
        [popoverTitle]="configTitle"
        [popover]="configText"
        [animation]="false">
        <button id="config-trigger" type="button">Config trigger</button>
      </li-popover>

      <li-popover
        #optionsPopover
        [popoverTitle]="optionsTitle"
        [popover]="optionsText"
        trigger="manual"
        placement="top"
        [popperOptions]="forceBottomPlacement"
        [animation]="false">
        <button id="options-trigger" type="button">Options trigger</button>
      </li-popover>

      <button
        id="directive-trigger"
        #directivePopover="liPopover"
        [liPopover]="directiveText"
        [popoverTitle]="directiveTitle"
        trigger="manual"
        [animation]="false"
        type="button">
        Directive trigger
      </button>

      <button id="outside-target" type="button">Outside target</button>
    </div>
  ''',
  providers: [ClassProvider(LiPopoverConfig)],
  directives: [coreDirectives, LiPopoverComponent, LiPopoverDirective],
)
class TestHostComponent {
  TestHostComponent(this.popoverConfig) {
    popoverConfig.placement = 'right';
    popoverConfig.popoverClass = 'popover-config-demo';
    popoverConfig.container = 'body';
    popoverConfig.autoClose = 'outside';
  }

  final LiPopoverConfig popoverConfig;

  String clickTitle = 'Click title';
  String clickBody = 'Click body';
  String manualTitle = 'Manual title';
  String manualBody = 'Manual body';
  String hoverTitle = 'Hover title';
  String hoverBody = 'Hover body';
  String manualPopoverClass =
      'popover-custom bg-primary text-white border-primary';
  String insideTitle = 'Inside title';
  String outsideTitle = 'Outside title';
  String bodyTitle = 'Body title';
  String bodyText = 'Body text';
  String configTitle = 'Config title';
  String configText = 'Config text';
  String optionsTitle = 'Options title';
  String optionsText = 'Options text';
  String directiveTitle = 'Directive title';
  String directiveText = 'Directive body';
  String insideBodyHtml =
      '<button id="inside-close" type="button">Close from inside</button>';
  String outsideBodyHtml =
      '<button id="outside-inside" type="button">Keep open</button>';
  PopoverTemplateContext defaultTemplateContext = const PopoverTemplateContext(
    title: 'Default template title',
    body: 'Default template body',
  );
  PopoverTemplateContext overrideTemplateContext = const PopoverTemplateContext(
    title: 'Override template title',
    body: 'Override template body',
  );
  LiPopoverPopperOptions forceBottomPlacement = forceBottomPopoverPlacement;

  int clickShownCount = 0;
  int clickHiddenCount = 0;
  int manualShownCount = 0;
  int manualHiddenCount = 0;

  @ViewChild('clickPopover')
  LiPopoverComponent? clickPopover;

  @ViewChild('manualPopover')
  LiPopoverComponent? manualPopover;

  @ViewChild('hoverPopover')
  LiPopoverComponent? hoverPopover;

  @ViewChild('insidePopover')
  LiPopoverComponent? insidePopover;

  @ViewChild('outsidePopover')
  LiPopoverComponent? outsidePopover;

  @ViewChild('bodyPopover')
  LiPopoverComponent? bodyPopover;

  @ViewChild('templatePopover')
  LiPopoverComponent? templatePopover;

  @ViewChild('configPopover')
  LiPopoverComponent? configPopover;

  @ViewChild('optionsPopover')
  LiPopoverComponent? optionsPopover;

  @ViewChild('directivePopover')
  LiPopoverDirective? directivePopover;

  void onClickShown() {
    clickShownCount += 1;
  }

  void onClickHidden() {
    clickHiddenCount += 1;
  }

  void onManualShown() {
    manualShownCount += 1;
  }

  void onManualHidden() {
    manualHiddenCount += 1;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TestHostComponent>(
    ng.TestHostComponentNgFactory,
  );

  test('abre por click e fecha ao clicar fora', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final host = fixture.assertOnlyInstance;
    final clickTrigger = fixture.rootElement.querySelector('#click-trigger');
    final outsideTarget = fixture.rootElement.querySelector('#outside-target');

    expect(clickTrigger, isNotNull);
    expect(outsideTarget, isNotNull);
    expect(host.clickPopover, isNotNull);
    expect(host.clickPopover!.isOpen(), isFalse);

    await fixture.update((_) {
      _click(clickTrigger!);
    });
    await _settlePopover(fixture);

    final popover = _popoverElement();

    expect(host.clickPopover!.isOpen(), isTrue);
    expect(popover, isNotNull);
    expect(popover!.text, contains('Click title'));
    expect(popover.text, contains('Click body'));

    await fixture.update((_) {
      _click(outsideTarget!);
    });
    await _settlePopover(fixture);

    expect(host.clickPopover!.isOpen(), isFalse);
    expect(_popoverElement(), isNull);
  });

  test('modo manual expõe open close toggle e isOpen via ViewChild', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final host = fixture.assertOnlyInstance;
    final manualTrigger = fixture.rootElement.querySelector('#manual-trigger');

    expect(host.manualPopover, isNotNull);
    expect(manualTrigger, isNotNull);
    expect(host.manualPopover!.isOpen(), isFalse);

    await fixture.update((_) {
      _click(manualTrigger!);
    });
    await _settlePopover(fixture);

    expect(host.manualPopover!.isOpen(), isFalse);
    expect(_popoverElement(), isNull);

    await fixture.update((component) {
      component.manualPopover!.open();
    });
    await _settlePopover(fixture);

    final arrow = _popoverArrowElement();
    final header = html.document.querySelector('.popover .popover-header');
    final body = html.document.querySelector('.popover .popover-body');

    expect(host.manualPopover!.isOpen(), isTrue);
    expect(_popoverElement(), isNotNull);
    expect(_popoverElement()!.text, contains('Manual body'));
    expect(arrow, isNotNull);
    expect(header, isNotNull);
    expect(body, isNotNull);
    expect(arrow!.classes.contains('border-primary'), isTrue);
    expect(header!.classes.contains('bg-primary'), isTrue);
    expect(header.classes.contains('text-white'), isTrue);
    expect(header.classes.contains('border-white'), isTrue);
    expect(header.classes.contains('border-opacity-25'), isTrue);
    expect(body!.classes.contains('text-white'), isTrue);
    expect(arrow.style.left, isNotEmpty);
    expect(arrow.style.right, isEmpty);
    expect(arrow.style.bottom, isEmpty);
    expect(arrow.style.getPropertyValue('inset'), isEmpty);

    await fixture.update((component) {
      component.manualPopover!.toggle();
    });
    await _settlePopover(fixture);

    expect(host.manualPopover!.isOpen(), isFalse);
    expect(_popoverElement(), isNull);

    await fixture.update((component) {
      component.manualPopover!.toggle();
    });
    await _settlePopover(fixture);

    expect(host.manualPopover!.isOpen(), isTrue);

    await fixture.update((component) {
      component.manualPopover!.close();
    });
    await _settlePopover(fixture);

    expect(host.manualPopover!.isOpen(), isFalse);
    expect(_popoverElement(), isNull);
  });

  test('usa o primeiro elemento projetado como referência padrão', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final host = fixture.assertOnlyInstance;
    final hoverTrigger = fixture.rootElement.querySelector('#hover-trigger');
    final hoverHost = fixture.rootElement.querySelector('li-popover');

    expect(host.hoverPopover, isNotNull);
    expect(hoverTrigger, isNotNull);
    expect(hoverHost, isNotNull);

    await fixture.update((component) {
      component.hoverPopover!.open();
    });
    await _settlePopover(fixture);

    final describedBy = hoverTrigger!.getAttribute('aria-describedby');

    expect(describedBy, isNotNull);
    expect(describedBy, isNotEmpty);
    expect(hoverHost!.getAttribute('aria-describedby'), isNull);
  });

  test('focusin no gatilho hover visível não reposiciona o popover', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final host = fixture.assertOnlyInstance;
    final hoverTrigger = fixture.rootElement.querySelector('#hover-trigger');

    expect(host.hoverPopover, isNotNull);
    expect(hoverTrigger, isNotNull);

    await fixture.update((component) {
      component.hoverPopover!.open();
    });
    await _settlePopover(fixture);

    final beforeTransform = _popoverElement()!.style.transform;

    await fixture.update((_) {
      _focusIn(hoverTrigger!);
      _click(hoverTrigger);
    });
    await _settlePopover(fixture);

    expect(_popoverElement(), isNotNull);
    expect(_popoverElement()!.style.transform, beforeTransform);
  });

  test('emite shown e hidden ao abrir e fechar o componente declarativo',
      () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final host = fixture.assertOnlyInstance;
    final clickTrigger = fixture.rootElement.querySelector('#click-trigger');
    final outsideTarget = fixture.rootElement.querySelector('#outside-target');

    expect(host.clickShownCount, 0);
    expect(host.clickHiddenCount, 0);
    expect(host.manualShownCount, 0);
    expect(host.manualHiddenCount, 0);

    await fixture.update((_) {
      _click(clickTrigger!);
    });
    await _settlePopover(fixture);

    expect(host.clickShownCount, 1);
    expect(host.clickHiddenCount, 0);

    await fixture.update((_) {
      _click(outsideTarget!);
    });
    await _settlePopover(fixture);

    expect(host.clickShownCount, 1);
    expect(host.clickHiddenCount, 1);

    await fixture.update((component) {
      component.manualPopover!.open();
    });
    await _settlePopover(fixture);

    expect(host.manualShownCount, 1);
    expect(host.manualHiddenCount, 0);

    await fixture.update((component) {
      component.manualPopover!.close();
    });
    await _settlePopover(fixture);

    expect(host.manualShownCount, 1);
    expect(host.manualHiddenCount, 1);
  });

  test('autoClose inside fecha apenas com clique dentro do popover', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final host = fixture.assertOnlyInstance;
    final insideTrigger = fixture.rootElement.querySelector('#inside-trigger');
    final outsideTarget = fixture.rootElement.querySelector('#outside-target');

    expect(host.insidePopover, isNotNull);

    await fixture.update((_) {
      _click(insideTrigger!);
    });
    await _settlePopover(fixture);

    expect(host.insidePopover!.isOpen(), isTrue);

    await fixture.update((_) {
      _click(outsideTarget!);
    });
    await _settlePopover(fixture);

    expect(host.insidePopover!.isOpen(), isTrue);

    final insideButton = html.document.querySelector('#inside-close');

    expect(insideButton, isNotNull);

    await fixture.update((_) {
      _click(insideButton!);
    });
    await _settlePopover(fixture);

    expect(host.insidePopover!.isOpen(), isFalse);
    expect(_popoverElement(), isNull);
  });

  test('autoClose outside ignora clique interno e fecha com clique externo',
      () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final host = fixture.assertOnlyInstance;
    final outsideTrigger =
        fixture.rootElement.querySelector('#outside-trigger');
    final outsideTarget = fixture.rootElement.querySelector('#outside-target');

    expect(host.outsidePopover, isNotNull);

    await fixture.update((_) {
      _click(outsideTrigger!);
    });
    await _settlePopover(fixture);

    expect(host.outsidePopover!.isOpen(), isTrue);

    final insideButton = html.document.querySelector('#outside-inside');

    expect(insideButton, isNotNull);

    await fixture.update((_) {
      _click(insideButton!);
    });
    await _settlePopover(fixture);

    expect(host.outsidePopover!.isOpen(), isTrue);

    await fixture.update((_) {
      _click(outsideTarget!);
    });
    await _settlePopover(fixture);

    expect(host.outsidePopover!.isOpen(), isFalse);
    expect(_popoverElement(), isNull);
  });

  test('container body anexa o popover fora do wrapper local', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final bodyTrigger = fixture.rootElement.querySelector('#body-trigger');
    final bodyWrapper = fixture.rootElement.querySelector('#body-wrapper');

    expect(bodyTrigger, isNotNull);
    expect(bodyWrapper, isNotNull);

    await fixture.update((_) {
      _click(bodyTrigger!);
    });
    await _settlePopover(fixture);

    final popover = _popoverElement();

    expect(popover, isNotNull);
    expect(bodyWrapper!.contains(popover), isFalse);
    expect(html.document.body!.contains(popover), isTrue);
  });

  test('seta usa o offset principal do CSS do placement', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);

    await fixture.update((component) {
      component.bodyPopover!.placement = 'right';
      component.bodyPopover!.open();
    });
    await _settlePopover(fixture);

    final rightArrow = _popoverArrowElement();

    expect(rightArrow, isNotNull);
    expect(rightArrow!.style.left, isNot('-1px'));
    expect(rightArrow.style.right, isNot('-1px'));
    expect(rightArrow.style.top, isNot('-1px'));
    expect(rightArrow.style.bottom, isNot('-1px'));

    await fixture.update((component) {
      component.bodyPopover!.close(false);
    });
    await _settlePopover(fixture);

    await fixture.update((component) {
      component.bodyPopover!.placement = 'bottom';
      component.bodyPopover!.open();
    });
    await _settlePopover(fixture);

    final bottomArrow = _popoverArrowElement();

    expect(bottomArrow, isNotNull);
    expect(bottomArrow!.style.left, isNot('-1px'));
    expect(bottomArrow.style.right, isNot('-1px'));
    expect(bottomArrow.style.top, isNot('-1px'));
    expect(bottomArrow.style.bottom, isNot('-1px'));
  });

  test('TemplateRef usa popoverContext e open(context)', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.templatePopover, isNotNull);

    await fixture.update((component) {
      component.templatePopover!.open();
    });
    await _settlePopover(fixture);

    expect(_popoverTitleText(), 'Default template title');
    expect(_popoverBodyText(), 'Default template body');

    await fixture.update((component) {
      component.templatePopover!.close(false);
    });
    await _settlePopover(fixture);

    await fixture.update((component) {
      component.templatePopover!.open(component.overrideTemplateContext);
    });
    await _settlePopover(fixture);

    expect(_popoverTitleText(), 'Override template title');
    expect(_popoverBodyText(), 'Override template body');
  });

  test('LiPopoverConfig fornece defaults para inputs ausentes', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final configTrigger = fixture.rootElement.querySelector('#config-trigger');

    expect(configTrigger, isNotNull);

    await fixture.update((_) {
      _click(configTrigger!);
    });
    await _settlePopover(fixture);

    final popover = _popoverElement();

    expect(popover, isNotNull);
    expect(popover!.classes.contains('popover-config-demo'), isTrue);
    expect(html.document.body!.contains(popover), isTrue);
  });

  test('hook de popperOptions pode sobrescrever placement base', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.optionsPopover, isNotNull);

    await fixture.update((component) {
      component.optionsPopover!.open();
    });
    await _settlePopover(fixture);

    final popover = _popoverElement();

    expect(popover, isNotNull);
    expect(popover!.classes.contains('bs-popover-bottom'), isTrue);
  });

  test('diretiva [liPopover] expõe API manual paralela ao tooltip', () async {
    final fixture = await testBed.create();
    await _settlePopover(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.directivePopover, isNotNull);
    expect(host.directivePopover!.isOpen(), isFalse);

    await fixture.update((component) {
      component.directivePopover!.open();
    });
    await _settlePopover(fixture);

    final popover = _popoverElement();

    expect(host.directivePopover!.isOpen(), isTrue);
    expect(popover, isNotNull);
    expect(popover!.text, contains('Directive title'));
    expect(popover.text, contains('Directive body'));

    await fixture.update((component) {
      component.directivePopover!.close(false);
    });
    await _settlePopover(fixture);

    expect(host.directivePopover!.isOpen(), isFalse);
    expect(_popoverElement(), isNull);
  });
}

class PopoverTemplateContext {
  const PopoverTemplateContext({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

PopperOptions forceBottomPopoverPlacement(PopperOptions options) {
  return PopperOptions(
    placement: 'bottom',
    fallbackPlacements: options.fallbackPlacements,
    allowedAutoPlacements: options.allowedAutoPlacements,
    strategy: options.strategy,
    boundary: options.boundary,
    padding: options.padding,
    offset: options.offset,
    flip: options.flip,
    shift: options.shift,
    shiftCrossAxis: options.shiftCrossAxis,
    matchReferenceWidth: options.matchReferenceWidth,
    matchReferenceMinWidth: options.matchReferenceMinWidth,
    hideWhenDetached: options.hideWhenDetached,
    roundByDevicePixelRatio: options.roundByDevicePixelRatio,
    observeMutations: options.observeMutations,
    arrowElement: options.arrowElement,
    arrowPadding: options.arrowPadding,
    inline: options.inline,
    middleware: options.middleware,
    onLayout: options.onLayout,
  );
}

void _click(html.Element element) {
  element.dispatchEvent(html.MouseEvent('click', canBubble: true));
}

void _focusIn(html.Element element) {
  element.dispatchEvent(html.Event('focusin', canBubble: true));
}

html.DivElement? _popoverElement() {
  final popover = html.document.querySelector('.popover');
  return popover is html.DivElement ? popover : null;
}

html.DivElement? _popoverArrowElement() {
  final arrow = html.document.querySelector('.popover .popover-arrow');
  return arrow is html.DivElement ? arrow : null;
}

String? _popoverTitleText() {
  final title = html.document.querySelector('.popover .template-popover-title');
  return title?.text?.trim();
}

String? _popoverBodyText() {
  final body = html.document.querySelector('.popover .template-popover-body');
  return body?.text?.trim();
}

Future<void> _settlePopover(NgTestFixture<TestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
  await fixture.update((_) {});
}
