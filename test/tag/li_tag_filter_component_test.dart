// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/tag/li_tag_filter_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:web/web.dart' as web;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import '../support/web_event_factories.dart';
import '../support/web_node_list.dart';

import 'li_tag_filter_component_test.template.dart' as ng;

@Component(
  selector: 'li-tag-filter-test-host',
  template: '''
    <div [style.width.px]="wrapperWidth">
      <li-tag-filter
          #filter
          [dataSource]="tags"
          labelKey="nome"
          valueKey="id"
          colorKey="cor"
          [showReloadButton]="true"
          [wrapSelectedBadges]="wrapSelectedBadges"
          (modelChange)="selectedModels = \$event"
          (reloadRequest)="reloadCount = reloadCount + 1"
          [(ngModel)]="selectedIds">
      </li-tag-filter>
    </div>
  ''',
  directives: [coreDirectives, formDirectives, LiTagFilterComponent],
)
class TagFilterTestHostComponent {
  @ViewChild('filter')
  LiTagFilterComponent? filter;

  List<dynamic> selectedIds = <dynamic>[2];
  List<dynamic> selectedModels = <dynamic>[];
  int wrapperWidth = 360;
  bool wrapSelectedBadges = true;
  int reloadCount = 0;

  final List<Map<String, dynamic>> tags = <Map<String, dynamic>>[
    <String, dynamic>{'id': 1, 'nome': 'Aguardar matrícula', 'cor': '#f4511e'},
    <String, dynamic>{
      'id': 2,
      'nome': 'Apoio previdenciário',
      'cor': '#43a047'
    },
    <String, dynamic>{'id': 3, 'nome': 'Assessoria', 'cor': '#d81b60'},
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TagFilterTestHostComponent>(
    ng.TagFilterTestHostComponentNgFactory,
  );

  test('toggles options and updates ngModel/modelChange', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.li-tag-filter__button')
        as web.HTMLButtonElement;

    expect(fixture.rootElement.textContent, contains('Apoio previdenciário'));

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    final options = web.document
        .querySelectorAll('.li-tag-filter__panel--open .li-tag-filter__option')
        .toElementList()
        .cast<web.Element>()
        .toList(growable: false);
    final assessoria = options.firstWhere(
      (element) => ((element.textContent ?? '')).contains('Assessoria'),
    );

    await fixture.update((_) {
      assessoria.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.selectedIds, containsAll(<int>[2, 3]));
    expect(
      host.selectedModels
          .map((dynamic item) => (item as Map<String, dynamic>)['id']),
      containsAll(<int>[2, 3]),
    );
  });

  test('clear button resets the bound value', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final clearButton =
        fixture.rootElement.querySelector('.dropdown-clear') as web.Element;

    await fixture.update((_) {
      clearButton.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.selectedIds, isEmpty);
    expect(fixture.rootElement.querySelector('.dropdown-clear'), isNull);
  });

  test('permite quebrar badges selecionados quando configurado', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.wrapperWidth = 180;
      component.wrapSelectedBadges = true;
      component.selectedIds = <dynamic>[1, 2, 3];
    });
    await _settle(fixture);

    final trigger = fixture.rootElement.querySelector('.li-tag-filter__button')
        as web.HTMLButtonElement;
    final selection = fixture.rootElement
        .querySelector('.li-tag-filter__selection') as web.Element;
    final badges = fixture.rootElement
        .querySelectorAll('.li-tag-filter__selection-badge')
        .toElementList();
    final badgeRows = badges
        .map((element) => element.getBoundingClientRect().top.round())
        .toSet();

    expect(
        trigger.classList.contains('li-tag-filter__button--wrapped'), isTrue);
    expect(
      selection.classList.contains('li-tag-filter__selection--wrapped'),
      isTrue,
    );
    expect(badgeRows.length, greaterThan(1));
  });

  test('opens overlay aligned below the trigger and emits reload requests',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.li-tag-filter__button')
        as web.HTMLButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    final panel = web.document.querySelector(
      '.li-tag-filter__panel--open',
    ) as web.Element;
    final reloadButton = panel.querySelector('.btn-icon') as web.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect((panelRect.left - triggerRect.left).abs(), lessThanOrEqualTo(1.5));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));

    await fixture.update((_) {
      reloadButton.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.reloadCount, 1);
  });
}

Future<void> _settle(
  NgTestFixture<TagFilterTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
