// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/tag/li_tag_editor_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_tag_editor_component_test.template.dart' as ng;

@Component(
  selector: 'li-tag-editor-test-host',
  template: '''
    <li-tag-editor
        [value]="tag"
        labelKey="nome"
        colorKey="cor"
        (save)="savedValue = \$event">
    </li-tag-editor>
  ''',
  directives: [coreDirectives, LiTagEditorComponent],
)
class TagEditorTestHostComponent {
  Map<String, dynamic> tag = <String, dynamic>{
    'id': 12,
    'nome': 'Etiqueta inicial',
    'cor': '#546e7a',
  };

  Map<String, dynamic>? savedValue;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TagEditorTestHostComponent>(
    ng.TagEditorTestHostComponentNgFactory,
  );

  test('edits name and color and emits save with normalized payload', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final inputs = fixture.rootElement
        .querySelectorAll('input')
        .cast<html.InputElement>()
        .toList(growable: false);
    final nameInput = inputs.first;
    final colorInput = inputs.last;
    final saveButton =
        fixture.rootElement.querySelector('.btn-primary') as html.ButtonElement;

    await fixture.update((_) {
      nameInput.value = 'Etiqueta Retro';
      nameInput.dispatchEvent(html.Event('input', canBubble: true));
      colorInput.value = 'f4511e';
      colorInput.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      saveButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.savedValue, isNotNull);
    expect(host.savedValue!['id'], 12);
    expect(host.savedValue!['nome'], 'Etiqueta Retro');
    expect(host.savedValue!['cor'], '#f4511e');
  });
}

Future<void> _settle(
  NgTestFixture<TagEditorTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
