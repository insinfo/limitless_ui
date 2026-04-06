// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/fab/li_fab_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_fab_component_test.template.dart' as ng;

@Component(
  selector: 'li-fab-test-host',
  template: '''
    <li-fab
        #fab
        label="Actions"
        [fixed]="false"
        [actions]="actions"
      (actionSelected)="handleAction(\$event)">
    </li-fab>
  ''',
  directives: [liFabDirectives],
)
class FabTestHostComponent {
  @ViewChild('fab')
  LiFabComponent? fab;

  final List<LiFabAction> actions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-play',
      label: 'Run',
      value: 'run',
      shortcut: LiFabShortcut(ctrl: true, key: 'r'),
    ),
    LiFabAction(
      iconClass: 'ph-book-open-text',
      label: 'Docs',
      value: 'docs',
      href: '#docs',
    ),
  ];

  LiFabAction? lastAction;

  void handleAction(LiFabAction action) {
    lastAction = action;
  }
}

@Component(
  selector: 'li-fab-template-test-host',
  template: '''
    <template #customTrigger let-trigger>
      <span class="custom-trigger-content">
        <i class="custom-trigger-icon ph" [class.ph-plus]="!trigger.expanded" [class.ph-x]="trigger.expanded"></i>
        {{ trigger.expanded ? 'Fechar ações' : 'Abrir ações' }}
      </span>
    </template>

    <template #customAction let-item>
      <span class="custom-action-content">
        <i [class]="item.iconClass"></i>
        <span>{{ item.label }}</span>
      </span>
    </template>

    <li-fab
        #fab
        label="Actions"
        [fixed]="false"
        [actions]="actions"
        [triggerTemplate]="customTrigger"
        [actionTemplate]="customAction"
      (actionSelected)="handleAction(\$event)">
    </li-fab>
  ''',
  directives: [coreDirectives, liFabDirectives],
)
class FabTemplateTestHostComponent {
  @ViewChild('fab')
  LiFabComponent? fab;

  final List<LiFabAction> actions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-play',
      label: 'Run',
      value: 'run',
    ),
  ];

  LiFabAction? lastAction;

  void handleAction(LiFabAction action) {
    lastAction = action;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);
  tearDown(() {
    html.window.location.hash = '';
  });
  tearDown(_removeInjectedFabIconStyles);

  final testBed = NgTestBed<FabTestHostComponent>(
    ng.FabTestHostComponentNgFactory,
  );
  final templateTestBed = NgTestBed<FabTemplateTestHostComponent>(
    ng.FabTemplateTestHostComponentNgFactory,
  );

  test('opens the menu and emits the selected button action', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.fab-menu-btn')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final runAction = fixture.rootElement.querySelectorAll(
      '.fab-menu-inner .btn',
    )[0] as html.ButtonElement;

    await fixture.update((_) {
      runAction.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.lastAction?.value, 'run');
    expect(trigger.getAttribute('aria-expanded'), 'false');
  });

  test('activates actions from keyboard shortcuts', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      host.fab!.triggerShortcut(key: 'r', ctrl: true, keyCode: 82);
    });
    await _settle(fixture);

    expect(host.lastAction?.value, 'run');
  });

  test('renders link actions as anchors and still emits selection', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.fab-menu-btn')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final link = fixture.rootElement.querySelector('a[href="#docs"]')
        as html.AnchorElement;
    expect(link, isNotNull);

    await fixture.update((_) {
      link.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.lastAction?.value, 'docs');
  });

  test('renders custom trigger and action templates from TemplateRef inputs',
      () async {
    final fixture = await templateTestBed.create();
    await _settleTemplate(fixture);

    expect(
      fixture.rootElement.querySelector('.custom-trigger-content')?.text,
      contains('Abrir ações'),
    );

    final trigger = fixture.rootElement.querySelector('.li-fab__trigger')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settleTemplate(fixture);

    expect(
      fixture.rootElement.querySelector('.custom-trigger-content')?.text,
      contains('Fechar ações'),
    );
    expect(
      fixture.rootElement.querySelector('.custom-action-content')?.text,
      contains('Run'),
    );
  });

  test(
      'keeps custom trigger icons in normal flow when global fab icon rules are present',
      () async {
    final fixture = await templateTestBed.create();
    await _settleTemplate(fixture);
    _injectFabIconStyles();

    final triggerIcon = fixture.rootElement
        .querySelector('.custom-trigger-icon') as html.Element;

    expect(triggerIcon.getComputedStyle().position, 'static');
    expect(triggerIcon.getComputedStyle().transform, 'none');
  });
}

Future<void> _settle(NgTestFixture<FabTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

Future<void> _settleTemplate(
  NgTestFixture<FabTemplateTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

void _injectFabIconStyles() {
  if (html.document.head!.querySelector('#fab-icon-style-test') != null) {
    return;
  }

  final style = html.StyleElement()
    ..id = 'fab-icon-style-test'
    ..text = '''
.fab-menu-btn i {
  position: absolute;
  top: 50%;
  left: 50%;
  margin-top: -10px;
  margin-left: -10px;
  transform: translate(0, 0);
}
''';

  html.document.head!.append(style);
}

void _removeInjectedFabIconStyles() {
  html.document.head!.querySelector('#fab-icon-style-test')?.remove();
}
