// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/tag/li_tag_manager_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_tag_manager_component_test.template.dart' as ng;

@Component(
  selector: 'li-tag-manager-test-host',
  template: '''
    <li-tag-manager
        [dataSource]="tags"
        [selectedValues]="selectedIds"
        labelKey="nome"
        valueKey="id"
        colorKey="cor"
        (currentValueChange)="liveSelectedIds = \$event"
        (applySelection)="lastApplied = \$event"
        (createRequest)="lastCreate = \$event"
        (updateRequest)="lastUpdate = \$event"
        (deleteRequest)="lastDelete = \$event">
    </li-tag-manager>
  ''',
  directives: [coreDirectives, LiTagManagerComponent],
)
class TagManagerTestHostComponent {
  List<dynamic> selectedIds = <dynamic>[1];
  List<dynamic> liveSelectedIds = <dynamic>[];
  LiTagSelectionChange? lastApplied;
  LiTagSaveRequest? lastCreate;
  LiTagSaveRequest? lastUpdate;
  LiTagDeleteRequest? lastDelete;

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

  final testBed = NgTestBed<TagManagerTestHostComponent>(
    ng.TagManagerTestHostComponentNgFactory,
  );

  test('toggles selection and emits applySelection', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final rows = fixture.rootElement
        .querySelectorAll('.li-tag-manager__item-main')
        .cast<html.Element>()
        .toList(growable: false);
    final supportRow = rows.firstWhere(
      (element) => (element.text ?? '').contains('Apoio previdenciário'),
    );

    await fixture.update((_) {
      supportRow.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.liveSelectedIds, containsAll(<int>[1, 2]));

    final applyButton = fixture.rootElement
        .querySelector('.li-tag-manager__apply') as html.ButtonElement;
    await fixture.update((_) {
      applyButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.lastApplied, isNotNull);
    expect(host.lastApplied!.values, containsAll(<int>[1, 2]));
  });

  test('creates a tag through the embedded editor', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final createButton =
        fixture.rootElement.querySelector('.li-tag-manager__footer .btn-link')
            as html.ButtonElement;
    await fixture.update((_) {
      createButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final inputs = fixture.rootElement
        .querySelectorAll('.li-tag-manager__editor input')
        .cast<html.InputElement>()
        .toList(growable: false);
    final nameInput = inputs.first;
    final colorInput = inputs.last;
    final saveButton = fixture.rootElement
            .querySelector('.li-tag-manager__editor .btn-primary')
        as html.ButtonElement;

    await fixture.update((_) {
      nameInput.value = 'Etiqueta global';
      nameInput.dispatchEvent(html.Event('input', canBubble: true));
      colorInput.value = '#ff6600';
      colorInput.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      saveButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.lastCreate, isNotNull);
    expect(host.lastCreate!.isEditing, isFalse);
    expect(host.lastCreate!.value['nome'], 'Etiqueta global');
    expect(host.lastCreate!.value['cor'], '#ff6600');
  });

  test('emits update and delete requests for existing tags', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final items = fixture.rootElement
        .querySelectorAll('.li-tag-manager__item')
        .cast<html.Element>()
        .toList(growable: false);
    final assessoriaItem = items.firstWhere(
      (element) => (element.text ?? '').contains('Assessoria'),
    );
    final actionButtons = assessoriaItem
        .querySelectorAll('.li-tag-manager__action-button')
        .cast<html.ButtonElement>()
        .toList(growable: false);
    final editButton = actionButtons.first;
    await fixture.update((_) {
      editButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final nameInput = fixture.rootElement
        .querySelector('.li-tag-manager__editor input') as html.InputElement;
    final saveButton = fixture.rootElement
            .querySelector('.li-tag-manager__editor .btn-primary')
        as html.ButtonElement;

    await fixture.update((_) {
      nameInput.value = 'Assessoria técnica';
      nameInput.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      saveButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.lastUpdate, isNotNull);
    expect(host.lastUpdate!.isEditing, isTrue);
    expect(host.lastUpdate!.value['nome'], 'Assessoria técnica');

    final refreshedItems = fixture.rootElement
        .querySelectorAll('.li-tag-manager__item')
        .cast<html.Element>()
        .toList(growable: false);
    final assessoriaRefreshed = refreshedItems.firstWhere(
      (element) => (element.text ?? '').contains('Assessoria'),
    );
    final refreshedButtons = assessoriaRefreshed
        .querySelectorAll('.li-tag-manager__action-button')
        .cast<html.ButtonElement>()
        .toList(growable: false);

    await fixture.update((_) {
      refreshedButtons.last
          .dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.lastDelete, isNotNull);
    expect(host.lastDelete!.value['id'], 3);
  });
}

Future<void> _settle(
  NgTestFixture<TagManagerTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
