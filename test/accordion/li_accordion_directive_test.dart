// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/accordion/li_accordion_directive_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_accordion_directive_test.template.dart' as ng;

@Component(
  selector: 'accordion-test-host',
  template: '''
    <div>
      <div
          liAccordion
          #accordion="liAccordion"
          [closeOthers]="true"
          [destroyOnHide]="true"
          [animation]="false"
          (show)="onAccordionShow(\$event)"
          (shown)="onAccordionShown(\$event)"
          (hide)="onAccordionHide(\$event)"
          (hidden)="onAccordionHidden(\$event)">
        <div liAccordionItem="first" #firstItem="liAccordionItem" [collapsed]="false">
          <h2 liAccordionHeader>
            <button id="first-button" liAccordionButton>First</button>
          </h2>
          <div liAccordionCollapse>
            <div liAccordionBody>
              First content
            </div>
          </div>
        </div>

        <div liAccordionItem="second" #secondItem="liAccordionItem">
          <div liAccordionHeader class="accordion-button">
            <span>Second</span>
            <button id="second-toggle" liAccordionToggle type="button">Toggle</button>
          </div>
          <div liAccordionCollapse>
            <template liAccordionBody>
              <div liAccordionBody>
                <span id="second-body-content">Second content</span>
              </div>
            </template>
          </div>
        </div>

      </div>

      <button id="api-expand-second" type="button" (click)="accordion?.expand('second')">Expand second</button>

      <div id="component-accordion-host">
        <li-accordion
            [lazy]="true"
            [destroyOnCollapse]="false"
            [bodyPadding]="componentAccordionBodyPadding"
            [buttonClass]="componentAccordionButtonClass"
            [buttonSemibold]="componentAccordionButtonSemibold">
          <li-accordion-item
              #componentItem
              header="Component item"
              description="Body should remain mounted after first open">
            <div liAccordionBody>
              <span id="component-body-content">Component content</span>
            </div>
          </li-accordion-item>
        </li-accordion>
      </div>

      <div id="collapse-panel" [liCollapse]="panelCollapsed" [animation]="false"
        (shown)="collapseShownCount = collapseShownCount + 1"
        (hidden)="collapseHiddenCount = collapseHiddenCount + 1">
        <div class="border p-2">Standalone collapse</div>
      </div>

      <button id="collapse-toggle" type="button" (click)="togglePanel()">Toggle panel</button>
    </div>
  ''',
  directives: [
    coreDirectives,
    LiAccordionDirective,
    LiAccordionItemDirective,
    LiAccordionHeaderHostDirective,
    LiAccordionButtonDirective,
    LiAccordionToggleDirective,
    LiAccordionCollapseDirective,
    LiAccordionBodyComponent,
    LiAccordionBodyTemplateDirective,
    LiCollapseDirective,
    LiAccordionComponent,
    LiAccordionItemComponent,
  ],
)
class TestHostComponent {
  @ViewChild('accordion')
  LiAccordionDirective? accordion;

  @ViewChild('firstItem')
  LiAccordionItemDirective? firstItem;

  @ViewChild('secondItem')
  LiAccordionItemDirective? secondItem;

  @ViewChild('componentItem')
  LiAccordionItemComponent? componentItem;

  final List<String> accordionEvents = <String>[];
  bool componentAccordionBodyPadding = true;
  String componentAccordionButtonClass = '';
  bool componentAccordionButtonSemibold = true;
  bool panelCollapsed = true;
  int collapseShownCount = 0;
  int collapseHiddenCount = 0;

  void onAccordionShow(String id) {
    accordionEvents.add('show:$id');
  }

  void onAccordionShown(String id) {
    accordionEvents.add('shown:$id');
  }

  void onAccordionHide(String id) {
    accordionEvents.add('hide:$id');
  }

  void onAccordionHidden(String id) {
    accordionEvents.add('hidden:$id');
  }

  void togglePanel() {
    panelCollapsed = !panelCollapsed;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TestHostComponent>(ng.TestHostComponentNgFactory);

  test('accordion container API respects closeOthers', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.accordion, isNotNull);
    expect(host.firstItem, isNotNull);
    expect(host.secondItem, isNotNull);
    expect(host.firstItem!.collapsed, isFalse);
    expect(host.secondItem!.collapsed, isTrue);

    await fixture.update((component) {
      component.accordion!.expand('second');
    });
    await _settle(fixture);

    expect(host.firstItem!.collapsed, isTrue);
    expect(host.secondItem!.collapsed, isFalse);
    expect(host.accordion!.isExpanded('second'), isTrue);
    expect(host.accordion!.isExpanded('first'), isFalse);
  });

  test('item API and accordion events work through declarative directives',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.secondItem!.toggle();
    });
    await _settle(fixture);

    expect(host.secondItem!.collapsed, isFalse);
    expect(
        host.accordionEvents,
        containsAllInOrder(<String>[
          'hide:first',
          'hidden:first',
          'show:second',
          'shown:second',
        ]));

    final collapseRegion = html.document.querySelector('#second-collapse');
    expect(collapseRegion, isNotNull);
    expect(collapseRegion!.classes.contains('show'), isTrue);
  });

  test('destroyOnHide removes and recreates template-backed body content',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector('#second-body-content'),
      isNull,
    );

    await fixture.update((component) {
      component.secondItem!.expand();
    });
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector('#second-body-content'),
      isNotNull,
    );

    await fixture.update((component) {
      component.secondItem!.collapse();
    });
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector('#second-body-content'),
      isNull,
    );
  });

  test('lazy body can remain mounted when destroyOnCollapse is false', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector('#component-body-content'),
      isNull,
    );

    await fixture.update((component) {
      component.componentItem!.setExpanded(true);
    });
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector('#component-body-content'),
      isNotNull,
    );

    await fixture.update((component) {
      component.componentItem!.setExpanded(false);
    });
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector('#component-body-content'),
      isNotNull,
    );
  });

  test('component accordion keeps body padding by default and can disable it',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    html.Element? body = fixture.rootElement
        .querySelector('#component-accordion-host .accordion-body');
    expect(body, isNotNull);
    expect(body!.classes.contains('p-0'), isFalse);

    await fixture.update((component) {
      component.componentAccordionBodyPadding = false;
    });
    await _settle(fixture);

    body = fixture.rootElement
        .querySelector('#component-accordion-host .accordion-body');
    expect(body, isNotNull);
    expect(body!.classes.contains('p-0'), isTrue);
  });

  test('component accordion can forward custom button classes', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    html.Element? button = fixture.rootElement
        .querySelector('#component-accordion-host .accordion-button');
    expect(button, isNotNull);
    expect(button!.classes.contains('text-muted'), isFalse);

    await fixture.update((component) {
      component.componentAccordionButtonClass = 'text-muted';
    });
    await _settle(fixture);

    button = fixture.rootElement
        .querySelector('#component-accordion-host .accordion-button');
    expect(button, isNotNull);
    expect(button!.classes.contains('text-muted'), isTrue);
  });

  test('component accordion can disable semibold button text', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    html.Element? button = fixture.rootElement
        .querySelector('#component-accordion-host .accordion-button');
    expect(button, isNotNull);
    expect(button!.classes.contains('fw-semibold'), isTrue);

    await fixture.update((component) {
      component.componentAccordionButtonSemibold = false;
    });
    await _settle(fixture);

    button = fixture.rootElement
        .querySelector('#component-accordion-host .accordion-button');
    expect(button, isNotNull);
    expect(button!.classes.contains('fw-semibold'), isFalse);
  });

  test('liCollapse toggles classes and emits lifecycle events', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final panel = fixture.rootElement.querySelector('#collapse-panel');
    final toggleButton = fixture.rootElement.querySelector('#collapse-toggle');

    expect(panel, isNotNull);
    expect(toggleButton, isNotNull);
    expect(panel!.classes.contains('show'), isFalse);
    expect(host.collapseShownCount, 0);
    expect(host.collapseHiddenCount, 0);

    await fixture.update((_) {
      _click(toggleButton!);
    });
    await _settle(fixture);

    expect(panel.classes.contains('show'), isTrue);
    expect(host.collapseShownCount, 1);

    await fixture.update((_) {
      _click(toggleButton!);
    });
    await _settle(fixture);

    expect(panel.classes.contains('show'), isFalse);
    expect(host.collapseHiddenCount, 1);
  });
}

void _click(html.Element element) {
  element.dispatchEvent(html.MouseEvent('click', canBubble: true));
}

Future<void> _settle(NgTestFixture<TestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}
