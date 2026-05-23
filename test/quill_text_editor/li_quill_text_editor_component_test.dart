// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/quill_text_editor/li_quill_text_editor_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/quill_text_editor.dart';
import 'package:limitless_ui/src/components/quill_text_editor/quill_text_editor_bridge.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_quill_text_editor_component_test.template.dart' as ng;
import 'quill_test_fakes.dart';

@Component(
  selector: 'li-quill-text-editor-test-host',
  template: '''
    <li-quill-text-editor
        #editor
        [(ngModel)]="modelValue"
        [labels]="labels"
        [placeholder]="placeholder"
        [toolbarVisible]="toolbarVisible"
        [updateModelOnBlur]="updateModelOnBlur"
        [enableTableSupport]="enableTableSupport"
        [enableTableButton]="enableTableButton"
        [toolbarActions]="toolbarActions">
      <template liQuillTextEditorToolbarActions let-ctx>
        <button id="projected-toolbar-action" type="button" class="btn btn-light btn-sm" (click)="projectedClicks = projectedClicks + 1">
          {{ projectedActionLabel }}
        </button>
      </template>
    </li-quill-text-editor>
  ''',
  directives: [coreDirectives, formDirectives, liQuillTextEditorDirectives],
)
class QuillTextEditorTestHostComponent {
  @ViewChild('editor')
  LiQuillTextEditorComponent? editor;

  String? modelValue = '<p>Texto inicial</p>';
  String placeholder = 'Digite aqui';
  bool toolbarVisible = true;
  bool updateModelOnBlur = false;
  bool enableTableSupport = true;
  bool enableTableButton = true;
  int projectedClicks = 0;
  int toolbarActionClicks = 0;
  String projectedActionLabel = 'Acao projetada';
  LiQuillTextEditorLabels labels = LiQuillTextEditorLabels.portuguese;

  late final List<LiQuillToolbarAction> toolbarActions =
      <LiQuillToolbarAction>[
    LiQuillToolbarAction(
      id: 'append-signature',
      iconClass: 'ph ph-signature',
      label: 'Assinar',
      title: 'Inserir assinatura',
      placement: LiQuillToolbarActionPlacement.trailing,
      onPressed: (event) {
        toolbarActionClicks += 1;
        event.editor.insertTextAtSelection(' [assinado]');
      },
    ),
  ];
}

void main() {
  tearDown(() {
    setLiQuillTextEditorBridgeForTesting(null);
    return disposeAnyRunningTest();
  });

  final testBed = NgTestBed<QuillTextEditorTestHostComponent>(
    ng.QuillTextEditorTestHostComponentNgFactory,
  );

  test('initializes through the bridge and renders projected toolbar content',
      () async {
    final fakeBridge = FakeLiQuillTextEditorBridge();
    setLiQuillTextEditorBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    await _settle(fixture);

    expect(fakeBridge.createdEditors, hasLength(1));
    expect(fakeBridge.registeredWhitelists, isNotEmpty);
    expect(
      fixture.rootElement.querySelector('#projected-toolbar-action'),
      isNotNull,
    );

    final boldButton = fixture.rootElement.querySelector('.ql-bold');
    expect(boldButton, isNotNull);
    expect(boldButton!.getAttribute('title'), 'Negrito');
  });

  test('updates ngModel and exposes editor APIs through the fake bridge',
      () async {
    final fakeBridge = FakeLiQuillTextEditorBridge();
    setLiQuillTextEditorBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.editor, isNotNull);
    expect(host.editor!.getPlainText(), 'Texto inicial');

    host.editor!.insertTextAtSelection(' atualizado');
    await _settle(fixture);

    expect(host.modelValue, contains('atualizado'));
    expect(host.editor!.getPlainText(), contains('atualizado'));
    expect(host.editor!.getDeltaJson(), contains('atualizado'));

    await host.editor!.setDeltaJson('{"ops":[{"insert":"Linha 1\\n"}]}');
    await _settle(fixture);

    expect(host.editor!.getPlainText(), 'Linha 1');
    expect(host.editor!.getHtml(), contains('Linha 1'));
  });

  test('executes toolbar action callbacks against the editor API', () async {
    final fakeBridge = FakeLiQuillTextEditorBridge();
    setLiQuillTextEditorBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final toolbarAction = fixture.rootElement
        .querySelector('[title="Inserir assinatura"]') as html.ButtonElement?;
    expect(toolbarAction, isNotNull);

    await fixture.update((_) {
      toolbarAction!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.toolbarActionClicks, 1);
    expect(host.modelValue, contains('[assinado]'));
  });

  test('shows a localized error when Quill is unavailable', () async {
    setLiQuillTextEditorBridgeForTesting(
      FakeLiQuillTextEditorBridge(isQuillAvailable: false),
    );

    final fixture = await testBed.create();
    await _settle(fixture);

    final error = fixture.rootElement.querySelector('.li-quill-text-editor__error');
    expect(error, isNotNull);
    expect(error!.text, contains('não está disponível'));
  });

  test('keeps the same toolbar DOM when toggling visibility', () async {
    final fakeBridge = FakeLiQuillTextEditorBridge();
    setLiQuillTextEditorBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final toolbarBefore = fixture.rootElement.querySelector('.li-quill-text-editor__toolbar');
    expect(toolbarBefore, isNotNull);
    expect(toolbarBefore!.classes, isNot(contains('li-quill-text-editor__toolbar--hidden')));

    await fixture.update((_) {
      host.toolbarVisible = false;
    });
    await _settle(fixture);

    final toolbarHidden = fixture.rootElement.querySelector('.li-quill-text-editor__toolbar');
    expect(identical(toolbarBefore, toolbarHidden), isTrue);
    expect(toolbarHidden!.classes, contains('li-quill-text-editor__toolbar--hidden'));

    await fixture.update((_) {
      host.toolbarVisible = true;
    });
    await _settle(fixture);

    final toolbarAfter = fixture.rootElement.querySelector('.li-quill-text-editor__toolbar');
    expect(identical(toolbarBefore, toolbarAfter), isTrue);
    expect(toolbarAfter!.classes, isNot(contains('li-quill-text-editor__toolbar--hidden')));
  });

  test('defers ngModel updates until blur when configured', () async {
    final fakeBridge = FakeLiQuillTextEditorBridge();
    setLiQuillTextEditorBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      host.updateModelOnBlur = true;
    });
    await _settle(fixture);

    host.editor!.insertTextAtSelection(' lento');
    await _settle(fixture);

    expect(host.editor!.getPlainText(), contains('lento'));
    expect(host.modelValue, isNot(contains('lento')));

    host.editor!.blur();
    await _settle(fixture);

    expect(host.modelValue, contains('lento'));
  });
}

Future<void> _settle(NgTestFixture<QuillTextEditorTestHostComponent> fixture) async {
  await fixture.update();
  await Future<void>.delayed(Duration.zero);
  await fixture.update();
}