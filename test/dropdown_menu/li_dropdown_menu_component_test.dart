// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/dropdown_menu/li_dropdown_menu_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
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
          [mobileFooterTemplate]="mobileFooter"
          [mobileFooterContext]="mobileFooterLabel"
          menuMaxHeight="10rem"
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>

      <template #mobileFooter let-data>
        <button id="mobile-footer-action" type="button" class="btn btn-light btn-sm" (click)="mobileFooterClicks = mobileFooterClicks + 1">
          {{ data }}
        </button>
      </template>

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

      <li-dropdown-menu
          #keepOpenMenu
          container="inline"
          [options]="options"
          ariaLabel="keep-open-actions"
          triggerLabel="Fica aberto"
          menuClass=""
          [closeOnSelect]="false"
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>

      <li-dropdown-menu
          container="inline"
          [options]="optionsWithDisabled"
          ariaLabel="disabled-option-actions"
          triggerLabel="Desabilitado"
          menuClass=""
          (valueChange)="selectedValue = \$event">
      </li-dropdown-menu>
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

  @ViewChild('keepOpenMenu')
  LiDropdownMenuComponent? keepOpenMenu;

  String selectedValue = 'copy';
  String mobileFooterLabel = 'Validação avançada';
  int mobileFooterClicks = 0;

  final List<LiDropdownMenuOption> options = const <LiDropdownMenuOption>[
    LiDropdownMenuOption(value: 'copy', label: 'Copiar'),
    LiDropdownMenuOption(value: 'paste', label: 'Colar'),
    LiDropdownMenuOption(value: 'clear', label: 'Limpar'),
  ];

  final List<LiDropdownMenuOption> optionsWithDisabled =
      const <LiDropdownMenuOption>[
    LiDropdownMenuOption(value: 'copy', label: 'Copiar'),
    LiDropdownMenuOption(value: 'blocked', label: 'Bloqueado', disabled: true),
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

    final menuNode = html.document.querySelector(
      '.LiDropdownMenuComponent .li-dropdown-menu__menu.show',
    );
    expect(menuNode, isNotNull);
    final menu = menuNode as html.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final menuRect = menu.getBoundingClientRect();

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

    final menuNode = fixture.rootElement.querySelector(
      '.li-dropdown-menu__menu.show',
    );
    expect(menuNode, isNotNull);
    final menu = menuNode as html.Element;
    final menuItems =
        menu.querySelector('.li-dropdown-menu__items') as html.Element;

    expect(menu.style.maxHeight, isEmpty);
    expect(menuItems.style.maxHeight, '12rem');
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

    final menuNode = html.document.querySelector(
      '.LiDropdownMenuComponent .li-dropdown-menu__menu.show',
    );
    expect(menuNode, isNotNull);
    final menu = menuNode as html.Element;
    final menuItems =
        menu.querySelector('.li-dropdown-menu__items') as html.Element;

    expect(menu.style.maxHeight, isEmpty);
    expect(menuItems.style.maxHeight, '6rem');
    expect(menuItems.style.overflowY, 'auto');
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

    final menuNode = fixture.rootElement.querySelector(
      '.li-dropdown-menu__menu--mobile-modal.show',
    );
    expect(menuNode, isNotNull);
    final menu = menuNode as html.Element;

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

    final menuNode = fixture.rootElement.querySelector(
      '.li-dropdown-menu__menu--mobile-sheet.show',
    );
    expect(menuNode, isNotNull);
    final menu = menuNode as html.Element;

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

  test('renders projected mobile footer content and closes the sheet on click',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final trigger =
        fixture.rootElement.querySelector('[aria-label="mobile-sheet-actions"]')
            as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final footerButton = fixture.rootElement
        .querySelector('#mobile-footer-action') as html.ButtonElement?;

    expect(footerButton, isNotNull);
    expect(footerButton!.text, contains('Validação avançada'));

    await fixture.update((_) {
      footerButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.mobileFooterClicks, 1);
    expect(host.mobileSheetMenu!.isOpen, isFalse);
  });

  test('inline menu near viewport edge stays open with viewport adaptation',
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
    final menuNode =
        fixture.rootElement.querySelector('.li-dropdown-menu__menu.show');
    expect(menuNode, isNotNull);
    final menu = menuNode as html.Element;
    final items =
        menu.querySelector('.li-dropdown-menu__items') as html.Element;

    expect(host.classes.contains('dropdown') || host.classes.contains('dropup'),
        isTrue);
    expect(items, isNotNull);
  });

  test('closes when Escape is pressed', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
        .querySelector('[aria-label="inline-actions"]') as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector('.li-dropdown-menu__menu.show'),
      isNotNull,
    );

    _dispatchEscapeKeydown();
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector('.li-dropdown-menu__menu.show'),
      isNull,
    );
  });

  test('closes when clicking outside', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement
        .querySelector('[aria-label="inline-actions"]') as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector('.li-dropdown-menu__menu.show'),
      isNotNull,
    );

    html.document.body!
        .dispatchEvent(html.MouseEvent('click', canBubble: true));
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector('.li-dropdown-menu__menu.show'),
      isNull,
    );
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

  test('does not emit valueChange when disabled option is clicked', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    host.selectedValue = 'copy';

    final trigger = fixture.rootElement
            .querySelector('[aria-label="disabled-option-actions"]')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final disabledOption = fixture.rootElement.querySelector(
            '.li-dropdown-menu__menu.show .dropdown-item[disabled]')
        as html.ButtonElement?;
    expect(disabledOption, isNotNull);

    await fixture.update((_) {
      disabledOption!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedValue, 'copy');
  });

  test('keeps menu open when closeOnSelect is false', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final trigger =
        fixture.rootElement.querySelector('[aria-label="keep-open-actions"]')
            as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final option = fixture.rootElement
            .querySelector('.li-dropdown-menu__menu.show .dropdown-item')
        as html.ButtonElement?;
    expect(option, isNotNull);

    await fixture.update((_) {
      option!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.keepOpenMenu!.isOpen, isTrue);
    expect(
      fixture.rootElement.querySelector('.li-dropdown-menu__menu.show'),
      isNotNull,
    );
  });
}

Future<void> _settle(
  NgTestFixture<DropdownMenuTestHostComponent> fixture,
) async {
  await fixture.update((_) {});
  await _nextAnimationFrame();
  await _nextAnimationFrame();
  await fixture.update((_) {});
}

Future<void> _nextAnimationFrame() {
  final completer = Completer<void>();
  html.window.requestAnimationFrame((_) {
    completer.complete();
  });
  return completer.future;
}

void _dispatchEscapeKeydown() {
  final keyboardEventConstructor =
      js_util.getProperty(html.window, 'KeyboardEvent');
  final event = js_util.callConstructor(
    keyboardEventConstructor,
    <Object?>[
      'keydown',
      js_util.jsify(<String, Object?>{
        'key': 'Escape',
        'bubbles': true,
        'cancelable': true,
      }),
    ],
  );
  js_util.callMethod(html.document, 'dispatchEvent', <Object?>[event]);
}
