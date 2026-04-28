// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/dropdown_menu/li_dropdown_menu_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_dropdown_menu_component_test.template.dart' as ng;

@Component(
  selector: 'li-dropdown-menu-test-host',
  template: '''
    <div style="display: flex; gap: 16px; align-items: flex-start;">
      <li-dropdown-menu
          #inlineMenu
          container="inline"
          [options]="options"
          [value]="selectedValue"
          ariaLabel="inline-actions"
          triggerLabel="Inline"
          triggerIconClass="ph ph-dots-three"
          menuClass=""
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>

      <div style="height: 40px; overflow: hidden; position: relative;">
        <li-dropdown-menu
          #bodyMenu
          [options]="options"
          [value]="selectedValue"
          ariaLabel="body-actions"
          triggerLabel="Acoes"
          triggerIconClass="ph ph-dots-three"
          menuClass=""
          menuMaxHeight="12rem"
          (valueChange)="selectedValue = \$event">
        </li-dropdown-menu>
      </div>

      <li-dropdown-menu
          container="inline"
          [options]="options"
          ariaLabel="fitting-inline-actions"
          triggerLabel="Cabe"
          menuClass=""
          menuMaxHeight="12rem"
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>

      <li-dropdown-menu
          [options]="longOptions"
          ariaLabel="long-body-actions"
          triggerLabel="Longo"
          menuClass=""
          menuMaxHeight="6rem"
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>

      <li-dropdown-menu
          #persistentMenu
          container="inline"
          [options]="options"
          [value]="selectedValue"
          ariaLabel="persistent-actions"
          triggerLabel="Persistente"
          triggerIconClass="ph ph-dots-three"
          menuClass=""
          [closeOtherMenusOnOpen]="false"
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>

      <li-dropdown-menu
          #mobileModalMenu
          container="inline"
          [options]="options"
          ariaLabel="mobile-modal-actions"
          triggerLabel="Modal"
          menuClass=""
          mobilePresentation="modal"
          mobileBreakpoint="9999px"
          mobileMenuTitle="Escolha uma acao"
          menuMaxHeight="10rem"
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>

      <li-dropdown-menu
          #mobileSheetMenu
          container="inline"
          [options]="options"
          ariaLabel="mobile-sheet-actions"
          triggerLabel="Sheet"
          menuClass=""
          mobilePresentation="sheet"
          mobileBreakpoint="9999px"
          mobileMenuTitle="Escolha uma acao"
          menuMaxHeight="10rem"
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>

      <div style="position: fixed; left: 12px; bottom: 4px;">
        <li-dropdown-menu
            #nearViewportEdgeMenu
            container="inline"
            [options]="longOptions"
            ariaLabel="near-viewport-edge-actions"
            triggerLabel="Borda"
            menuClass=""
            (valueChange)="selectedValue = \$event">
        </li-dropdown-menu>
      </div>
    </div>
  ''',
  directives: [coreDirectives, LiDropdownMenuComponent],
)
class DropdownMenuTestHostComponent {
  @ViewChild('inlineMenu')
  LiDropdownMenuComponent? inlineMenu;

  @ViewChild('bodyMenu')
  LiDropdownMenuComponent? bodyMenu;

  @ViewChild('persistentMenu')
  LiDropdownMenuComponent? persistentMenu;

  @ViewChild('mobileModalMenu')
  LiDropdownMenuComponent? mobileModalMenu;

  @ViewChild('mobileSheetMenu')
  LiDropdownMenuComponent? mobileSheetMenu;

  @ViewChild('nearViewportEdgeMenu')
  LiDropdownMenuComponent? nearViewportEdgeMenu;

  String selectedValue = 'copy';

  final List<LiDropdownMenuOption> options = const <LiDropdownMenuOption>[
    LiDropdownMenuOption(value: 'copy', label: 'Copiar'),
    LiDropdownMenuOption(value: 'paste', label: 'Colar'),
    LiDropdownMenuOption(value: 'clear', label: 'Limpar'),
  ];

  final List<LiDropdownMenuOption> longOptions =
      List<LiDropdownMenuOption>.generate(
    24,
    (index) => LiDropdownMenuOption(
      value: 'item-$index',
      label: 'Item $index',
    ),
  );
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DropdownMenuTestHostComponent>(
    ng.DropdownMenuTestHostComponentNgFactory,
  );

  test('keeps inline rendering when container="inline"', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
        .querySelector('[aria-label="inline-actions"]') as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final inlineMenu = fixture.rootElement.querySelector(
      '.li-dropdown-menu__menu.show',
    );

    expect(inlineMenu, isNotNull);
    expect(
      html.document.querySelector(
          '.LiDropdownMenuComponent .li-dropdown-menu__menu.show'),
      isNull,
    );
  });

  test('opens menu in a body overlay aligned to the trigger start', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
        .querySelector('[aria-label="body-actions"]') as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final menu = html.document.querySelector(
      '.LiDropdownMenuComponent .li-dropdown-menu__menu.show',
    ) as html.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final menuRect = menu.getBoundingClientRect();

    expect(menu, isNotNull);
    expect(
      fixture.rootElement.querySelector('.li-dropdown-menu__menu.show'),
      isNull,
    );
    expect((menuRect.left - triggerRect.left).abs(), lessThanOrEqualTo(12));
    expect((menuRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(12));
  });

  test('applies max-height when menuMaxHeight is configured', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
            .querySelector('[aria-label="fitting-inline-actions"]')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final menu = fixture.rootElement.querySelector(
      '.li-dropdown-menu__menu.show',
    ) as html.Element;

    expect(menu.style.maxHeight, '12rem');
  });

  test('enables vertical scrolling when max-height clips long content',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger =
        fixture.rootElement.querySelector('[aria-label="long-body-actions"]')
            as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final menu = html.document.querySelector(
      '.LiDropdownMenuComponent .li-dropdown-menu__menu.show',
    ) as html.Element;

    expect(menu.style.maxHeight, '6rem');
    expect(menu.style.overflowY, 'auto');
  });

  test('can present as a centered mobile modal', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger =
        fixture.rootElement.querySelector('[aria-label="mobile-modal-actions"]')
            as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final menu = fixture.rootElement.querySelector(
      '.li-dropdown-menu__menu--mobile-modal.show',
    ) as html.Element;

    expect(menu, isNotNull);
    expect(menu.getAttribute('role'), 'dialog');
    expect(menu.getAttribute('aria-modal'), 'true');
    expect(menu.style.maxHeight, endsWith('px'));
    expect(menu.querySelector('.li-dropdown-menu__mobile-title')!.text,
        'Escolha uma acao');
    expect(
      menu.querySelector('.li-dropdown-menu__items'),
      isNotNull,
    );
    expect(
      fixture.rootElement.querySelector('.li-dropdown-menu__mobile-backdrop'),
      isNotNull,
    );
  });

  test('can present as a mobile bottom sheet', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger =
        fixture.rootElement.querySelector('[aria-label="mobile-sheet-actions"]')
            as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final menu = fixture.rootElement.querySelector(
      '.li-dropdown-menu__menu--mobile-sheet.show',
    ) as html.Element;

    expect(menu, isNotNull);
    expect(menu.getAttribute('role'), 'dialog');
    expect(menu.getAttribute('aria-modal'), 'true');
    expect(menu.style.maxHeight, endsWith('px'));
    expect(
      menu.querySelector('.li-dropdown-menu__items'),
      isNotNull,
    );
    expect(
      fixture.rootElement.querySelector('.li-dropdown-menu__mobile-backdrop'),
      isNotNull,
    );
  });

  test('inline menu flips upward near the viewport bottom by default',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
            .querySelector('[aria-label="near-viewport-edge-actions"]')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final host = trigger.parent as html.Element;

    expect(host.classes.contains('dropup'), isTrue);
    expect(host.classes.contains('dropdown'), isFalse);
  });

  test('opening a dropdown closes other open menus by default', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final inlineTrigger = fixture.rootElement
        .querySelector('[aria-label="inline-actions"]') as html.ButtonElement;
    final bodyTrigger = fixture.rootElement
        .querySelector('[aria-label="body-actions"]') as html.ButtonElement;

    await fixture.update((_) {
      inlineTrigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.inlineMenu!.isOpen, isTrue);

    await fixture.update((_) {
      bodyTrigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.inlineMenu!.isOpen, isFalse);
    expect(host.bodyMenu!.isOpen, isTrue);
    expect(
      fixture.rootElement.querySelector('.li-dropdown-menu__menu.show'),
      isNull,
    );
  });

  test('closeOtherMenusOnOpen false keeps previously opened menus visible',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final inlineTrigger = fixture.rootElement
        .querySelector('[aria-label="inline-actions"]') as html.ButtonElement;
    final persistentTrigger =
        fixture.rootElement.querySelector('[aria-label="persistent-actions"]')
            as html.ButtonElement;

    await fixture.update((_) {
      inlineTrigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      persistentTrigger
          .dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.inlineMenu!.isOpen, isTrue);
    expect(host.persistentMenu!.isOpen, isTrue);
    expect(
      fixture.rootElement
          .querySelectorAll('.li-dropdown-menu__menu.show')
          .length,
      2,
    );
  });

  test('selects an option from the overlay and closes the menu', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final trigger = fixture.rootElement
        .querySelector('[aria-label="body-actions"]') as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final option = html.document
        .querySelectorAll(
            '.LiDropdownMenuComponent .li-dropdown-menu__menu.show .dropdown-item')
        .cast<html.ButtonElement>()
        .firstWhere((element) => (element.text ?? '').contains('Limpar'));

    await fixture.update((_) {
      option.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedValue, 'clear');
    expect(
      html.document.querySelector(
          '.LiDropdownMenuComponent .li-dropdown-menu__menu.show'),
      isNull,
    );
  });
}

Future<void> _settle(
  NgTestFixture<DropdownMenuTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
