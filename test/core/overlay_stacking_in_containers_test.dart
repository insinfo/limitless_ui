// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/core/overlay_stacking_in_containers_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'overlay_stacking_in_containers_test.template.dart' as ng;

/// Overlays reais dentro de contêineres reais.
///
/// `test/core/overlay_layers_test.dart` prova a regra com contêineres
/// falsos; este arquivo monta os componentes de verdade — modal, offcanvas,
/// select, dropdown, popover — e confere o z-index que cada um escreve no
/// DOM. É a versão de unidade do laboratório da página **Overlay layers**:
/// cada caso aqui foi um defeito visto lá primeiro.
@Component(
  selector: 'stacking-test-host',
  template: '''
    <div>
      <button id="open-modal" type="button" (click)="modal?.open()">Open modal</button>

      <li-modal #modal title-text="Host modal">
        <div id="modal-dropdown" liDropdown container="body">
          <button id="modal-dropdown-toggle" type="button" liDropdownToggle>Menu</button>
          <div liDropdownMenu>
            <button id="modal-dropdown-item" liDropdownItem>Item</button>
          </div>
        </div>

        <button id="open-offcanvas-from-modal" type="button" (click)="offcanvas?.open()">
          Open offcanvas
        </button>
      </li-modal>

      <li-offcanvas #offcanvas title-text="Host offcanvas">
        <li-select #offcanvasSelect
            [dataSource]="options"
            labelKey="label"
            valueKey="id"
            [(ngModel)]="selected">
        </li-select>

        <li-popover #offcanvasPopover
            popover="Body"
            popoverTitle="Title"
            trigger="click"
            container="body"
            [animation]="false">
          <button id="offcanvas-popover-trigger" type="button">Popover</button>
        </li-popover>
      </li-offcanvas>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiModalComponent,
    LiPopoverComponent,
    LiSelectComponent,
    liDropdownDirectives,
    liOffcanvasDirectives,
  ],
)
class StackingTestHostComponent {
  @ViewChild('modal')
  LiModalComponent? modal;

  @ViewChild('offcanvas')
  LiOffcanvasComponent? offcanvas;

  @ViewChild('offcanvasSelect')
  LiSelectComponent? offcanvasSelect;

  @ViewChild('offcanvasPopover')
  LiPopoverComponent? offcanvasPopover;

  final List<Map<String, dynamic>> options = <Map<String, dynamic>>[
    <String, dynamic>{'id': 1, 'label': 'One'},
    <String, dynamic>{'id': 2, 'label': 'Two'},
  ];
  dynamic selected;
}

/// Um typeahead com `openOnFocus` e termo vazio: a busca que abre o popup já
/// é válida antes de qualquer foco, e o `ngOnInit` a rodava.
@Component(
  selector: 'typeahead-init-test-host',
  template: '''
    <li-typeahead
        #typeahead
        [dataSource]="cities"
        [openOnFocus]="true"
        [minLength]="0"
        [debounceMs]="0"
        [(ngModel)]="selected">
    </li-typeahead>
  ''',
  directives: [coreDirectives, formDirectives, LiTypeaheadComponent],
)
class TypeaheadInitTestHostComponent {
  @ViewChild('typeahead')
  LiTypeaheadComponent? typeahead;

  final List<String> cities = <String>['Recife', 'Salvador', 'Vitória'];
  dynamic selected;
}

/// `options` vindo de um getter: uma lista nova, de instâncias novas, a cada
/// change detection — o padrão que derrubava a aba.
@Component(
  selector: 'dropdown-menu-getter-test-host',
  template: '''
    <li-dropdown-menu
        #menu
        [options]="options"
        triggerLabel="Menu"
        container="body"
        (valueChange)="chosen = \$event">
    </li-dropdown-menu>
  ''',
  directives: [coreDirectives, LiDropdownMenuComponent],
)
class DropdownMenuGetterTestHostComponent {
  @ViewChild('menu')
  LiDropdownMenuComponent? menu;

  int buildCount = 0;
  String chosen = '';

  List<LiDropdownMenuOption> get options {
    buildCount++;
    return <LiDropdownMenuOption>[
      const LiDropdownMenuOption(value: 'open', label: 'Open'),
      const LiDropdownMenuOption(value: 'edit', label: 'Edit'),
      const LiDropdownMenuOption(value: 'archive', label: 'Archive'),
    ];
  }
}

void main() {
  tearDown(() async {
    await disposeAnyRunningTest();
    for (final node in html.document.body!.querySelectorAll(
        '.modal, .li-modal-backdrop, .LiSelectComponent, .LiPopoverComponent, '
        '.LiTypeaheadComponent, .LiDropdownMenuComponent')) {
      node.remove();
    }
  });

  group('overlays dentro de contêineres reais', () {
    final testBed = NgTestBed<StackingTestHostComponent>(
      ng.StackingTestHostComponentNgFactory,
    );

    test('a casca do offcanvas aberto é um contêiner bloqueante', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.offcanvas!.open());
      await _settle(fixture);

      final shell =
          html.document.querySelector('.li-offcanvas-shell[data-status="open"]');
      expect(shell, isNotNull,
          reason: 'a casca é o nó que leva o z-index e precisa marcar-se aberta');

      final selectHost = html.document.querySelector('li-select')!;
      expect(LiOverlayStack.owningBlockingContainer(selectHost), same(shell));
      expect(
        LiOverlayStack.resolve(
          referenceElement: selectHost,
          baseZIndex: LiOverlayLayers.anchoredMenu,
        ),
        LiOverlayLayers.offcanvas + LiOverlayLayers.stackOffset,
      );

      await fixture.update((host) => host.offcanvas!.close());
      await _settle(fixture);
      expect(
        html.document.querySelector('.li-offcanvas-shell[data-status="open"]'),
        isNull,
      );
    });

    test('um li-select aberto dentro do offcanvas fica acima dele', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.offcanvas!.open());
      await _settle(fixture);

      await fixture.update((_) => _click('[data-label="li_select_toggle"]'));
      await _settle(fixture);

      final portal = html.document.querySelector('.LiSelectComponent');
      expect(portal, isNotNull, reason: 'o painel do select vai para o body');
      expect(
        int.parse(portal!.style.zIndex),
        greaterThan(LiOverlayLayers.offcanvas),
      );
    });

    test('um li-popover aberto dentro do offcanvas fica acima dele', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.offcanvas!.open());
      await _settle(fixture);

      await fixture.update((host) => host.offcanvasPopover!.open());
      await _settle(fixture);

      final portal = html.document.querySelector('.LiPopoverComponent');
      expect(portal, isNotNull);
      // Antes da dev.42 o popover só varria `.modal[data-status="open"]` e
      // ficava no 1080 do tema — embaixo do offcanvas (1150).
      expect(
        int.parse(portal!.style.zIndex),
        greaterThan(LiOverlayLayers.offcanvas),
      );
    });

    test('liDropdown com container="body" dentro do modal fica acima dele',
        () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.modal!.open());
      await _settle(fixture);

      final modalRoot = html.document
          .querySelector('.modal[data-status="open"]') as html.Element;
      final modalZIndex = int.parse(modalRoot.style.zIndex);
      expect(modalZIndex, LiOverlayLayers.modal);

      await fixture.update((_) => _click('#modal-dropdown-toggle'));
      await _settle(fixture);

      // O menu vai para um wrapper no body; era um 1055 fixo, abaixo do modal.
      final item = html.document.querySelector('#modal-dropdown-item')!;
      final wrapper = item.closest('body > div')!;
      expect(wrapper.parent, same(html.document.body));
      expect(int.parse(wrapper.style.zIndex), greaterThan(modalZIndex));
    });

    test('um offcanvas aberto de dentro de um modal sobe pelo modal', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.modal!.open());
      await _settle(fixture);

      final modalRoot = html.document
          .querySelector('.modal[data-status="open"]') as html.Element;
      final modalZIndex = int.parse(modalRoot.style.zIndex);

      // O gatilho está dentro do modal e tem o foco quando o offcanvas abre —
      // é por ele que o offcanvas descobre quem o contém.
      await fixture.update((host) {
        (html.document.querySelector('#open-offcanvas-from-modal')
                as html.ButtonElement)
            .focus();
        host.offcanvas!.open();
      });
      await _settle(fixture);

      final shell = html.document
          .querySelector('.li-offcanvas-shell[data-status="open"]')!;
      expect(int.parse(shell.style.zIndex), greaterThan(modalZIndex));
      expect(shell.getComputedStyle().zIndex, '${modalZIndex + 1}');
    });

    test('um offcanvas aberto sem nada bloqueante fica na camada base',
        () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.offcanvas!.open());
      await _settle(fixture);

      final shell = html.document
          .querySelector('.li-offcanvas-shell[data-status="open"]')!;
      expect(shell.style.zIndex, isEmpty,
          reason: 'sem bloqueante, vale a folha de estilo');
      expect(shell.getComputedStyle().zIndex, '${LiOverlayLayers.offcanvas}');
    });
  });

  group('li-typeahead com openOnFocus', () {
    final testBed = NgTestBed<TypeaheadInitTestHostComponent>(
      ng.TypeaheadInitTestHostComponentNgFactory,
    );

    test('nao abre o popup ao nascer, so no foco', () async {
      final fixture = await testBed.create();
      await _settle(fixture);
      final host = fixture.assertOnlyInstance;

      expect(host.typeahead!.isPopupOpen(), isFalse);
      expect(html.document.querySelector('.LiTypeaheadComponent'), isNull,
          reason: 'sem abrir, nada é portalado ao body');
      final popup = fixture.rootElement.querySelector('[data-label="li_ta_popup"]')!;
      expect(popup.classes, isNot(contains('show')));

      final input = fixture.rootElement.querySelector('input') as html.InputElement;
      await fixture.update((_) {
        input.focus();
        input.dispatchEvent(html.Event('focus'));
      });
      await _settle(fixture);

      expect(host.typeahead!.isPopupOpen(), isTrue);
      expect(host.typeahead!.visibleItems, hasLength(3));
    });
  });

  group('li-dropdown-menu com options vindo de getter', () {
    final testBed = NgTestBed<DropdownMenuGetterTestHostComponent>(
      ng.DropdownMenuGetterTestHostComponentNgFactory,
    );

    test('nao recria os itens a cada change detection', () async {
      final fixture = await testBed.create();
      await _settle(fixture);
      final host = fixture.assertOnlyInstance;

      List<html.Element> items() =>
          html.document.querySelectorAll('[data-label="li_dm_item"]').toList();

      final before = items();
      expect(before, hasLength(3));
      final buildsBefore = host.buildCount;

      for (var i = 0; i < 5; i++) {
        await fixture.update((_) {});
      }

      expect(host.buildCount, greaterThan(buildsBefore),
          reason: 'o getter roda a cada ciclo, é o cenário do teste');
      final after = items();
      for (var i = 0; i < before.length; i++) {
        expect(identical(before[i], after[i]), isTrue,
            reason: 'o item $i foi recriado por uma lista de mesmo conteúdo');
      }
    });

    test('abre, sobrevive a varios ciclos e fecha ao escolher', () async {
      final fixture = await testBed.create();
      await _settle(fixture);
      final host = fixture.assertOnlyInstance;

      await fixture.update((_) => _click('[data-label="li_dm_btn_toggle"]'));
      await _settle(fixture);
      expect(host.menu!.isOpen, isTrue);

      // Com o menu aberto o observer do popper está ligado: era aqui que a
      // recriação virava relayout, e o relayout, recriação.
      for (var i = 0; i < 10; i++) {
        await fixture.update((_) {});
      }
      await _settle(fixture);
      expect(host.menu!.isOpen, isTrue);
      expect(html.document.querySelectorAll('[data-label="li_dm_item"]'),
          hasLength(3));

      await fixture.update((_) => _click('[data-label="li_dm_item"]'));
      await _settle(fixture);
      expect(host.chosen, 'open');
      expect(host.menu!.isOpen, isFalse);
    });
  });
}

void _click(String selector) {
  final element = html.document.querySelector(selector);
  expect(element, isNotNull, reason: 'nao achei $selector');
  element!.dispatchEvent(html.MouseEvent('click', canBubble: true));
}

Future<void> _settle(NgTestFixture<Object> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
