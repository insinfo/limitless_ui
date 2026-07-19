// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/tag/li_tag_filter_initial_value_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_tag_filter_initial_value_test.template.dart' as ng;

@Component(
  selector: 'li-tag-filter-async-test-host',
  template: '''
    <li-tag-filter
        #filter
        [dataSource]="tags"
        labelKey="nome"
        valueKey="id"
        [(ngModel)]="selectedIds">
    </li-tag-filter>
  ''',
  directives: [coreDirectives, formDirectives, LiTagFilterComponent],
)
class TagFilterAsyncHostComponent {
  @ViewChild('filter')
  LiTagFilterComponent? filter;

  List<dynamic> selectedIds = <dynamic>[2, 3];

  // Starts empty, as if the tags were still being fetched when the model value
  // was written.
  List<Map<String, dynamic>> tags = <Map<String, dynamic>>[];

  void loadTags() {
    tags = <Map<String, dynamic>>[
      <String, dynamic>{'id': 1, 'nome': 'Aguardar matricula'},
      <String, dynamic>{'id': 2, 'nome': 'Apoio previdenciario'},
      <String, dynamic>{'id': 3, 'nome': 'Assessoria'},
    ];
  }
}

List<dynamic> _selectedValuesOf(LiTagFilterComponent filter) =>
    filter.selectedOptions.map((option) => option.value).toList();

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TagFilterAsyncHostComponent>(
    ng.TagFilterAsyncHostComponentNgFactory,
  );

  test('applies the initial ngModel selection to a late-arriving dataSource',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(_selectedValuesOf(host.filter!), isEmpty);

    await fixture.update((_) {
      host.loadTags();
    });
    await _settle(fixture);

    expect(_selectedValuesOf(host.filter!), containsAll(<int>[2, 3]));
    expect(_selectedValuesOf(host.filter!).length, 2);
    expect(host.selectedIds, containsAll(<int>[2, 3]));
  });

  test('a later selection does not discard the restored one', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      host.loadTags();
    });
    await _settle(fixture);

    // Clicking a further tag must add to the restored selection rather than
    // emit a model containing only the newly clicked one.
    final option =
        host.filter!.options.firstWhere((option) => option.value == 1);
    await fixture.update((_) {
      host.filter!.toggleOptionFromUi(option, html.MouseEvent('click'));
    });
    await _settle(fixture);

    expect(host.selectedIds, containsAll(<int>[1, 2, 3]));
    expect(host.selectedIds.length, 3);
  });

  test('does not restore a stale value over a cleared selection', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      host.loadTags();
    });
    await _settle(fixture);
    expect(_selectedValuesOf(host.filter!).length, 2);

    await fixture.update((_) {
      host.filter!.reset();
    });
    await _settle(fixture);
    expect(_selectedValuesOf(host.filter!), isEmpty);

    // A dataSource resync must not bring the initial [2, 3] back.
    await fixture.update((_) {
      host.tags = <Map<String, dynamic>>[
        <String, dynamic>{'id': 1, 'nome': 'Aguardar matricula'},
        <String, dynamic>{'id': 2, 'nome': 'Apoio previdenciario'},
        <String, dynamic>{'id': 3, 'nome': 'Assessoria'},
        <String, dynamic>{'id': 4, 'nome': 'Novo'},
      ];
    });
    await _settle(fixture);

    expect(_selectedValuesOf(host.filter!), isEmpty);
  });
}

Future<void> _settle(NgTestFixture<TagFilterAsyncHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
