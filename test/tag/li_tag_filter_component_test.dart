// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/tag/li_tag_filter_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_tag_filter_component_test.template.dart' as ng;

@Component(
  selector: 'li-tag-filter-test-host',
  template: '''
    <li-tag-filter
        #filter
        [dataSource]="tags"
        labelKey="nome"
        valueKey="id"
        colorKey="cor"
        [showReloadButton]="true"
        (modelChange)="selectedModels = \$event"
        (reloadRequest)="reloadCount = reloadCount + 1"
        [(ngModel)]="selectedIds">
    </li-tag-filter>
  ''',
  directives: [coreDirectives, formDirectives, LiTagFilterComponent],
)
class TagFilterTestHostComponent {
  @ViewChild('filter')
  LiTagFilterComponent? filter;

  List<dynamic> selectedIds = <dynamic>[2];
  List<dynamic> selectedModels = <dynamic>[];
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
        as html.ButtonElement;

    expect(fixture.rootElement.text, contains('Apoio previdenciário'));

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final options = html.document
        .querySelectorAll('.li-tag-filter__panel--open .li-tag-filter__option')
        .cast<html.Element>()
        .toList(growable: false);
    final assessoria = options.firstWhere(
      (element) => (element.text ?? '').contains('Assessoria'),
    );

    await fixture.update((_) {
      assessoria.dispatchEvent(html.MouseEvent('click', canBubble: true));
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
        fixture.rootElement.querySelector('.dropdown-clear') as html.Element;

    await fixture.update((_) {
      clearButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedIds, isEmpty);
    expect(fixture.rootElement.querySelector('.dropdown-clear'), isNull);
  });

  test('opens overlay aligned below the trigger and emits reload requests',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.li-tag-filter__button')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final panel = html.document.querySelector(
      '.li-tag-filter__panel--open',
    ) as html.Element;
    final reloadButton = panel.querySelector('.btn-icon') as html.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect((panelRect.left - triggerRect.left).abs(), lessThanOrEqualTo(1.5));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));

    await fixture.update((_) {
      reloadButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
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
