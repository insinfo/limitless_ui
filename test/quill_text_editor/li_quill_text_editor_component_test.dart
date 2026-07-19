// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/quill_text_editor/li_quill_text_editor_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:limitless_ui/quill_text_editor.dart';
import 'package:limitless_ui/src/components/quill_text_editor/quill_text_editor_bridge.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
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
        [enableDestructiveToolbarRebuild]="enableDestructiveToolbarRebuild"
        [disabledToolbarItemIds]="disabledToolbarItemIds"
        [hiddenToolbarItemIds]="hiddenToolbarItemIds"
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
  bool enableDestructiveToolbarRebuild = false;
  List<String> disabledToolbarItemIds = const <String>[];
  List<String> hiddenToolbarItemIds = const <String>[];
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

    final toolbarBefore =
        fixture.rootElement.querySelector('.li-quill-text-editor__toolbar');
    final boldButtonBefore = fixture.rootElement.querySelector('.ql-bold');
    final headerSelectBefore = fixture.rootElement.querySelector('.ql-header');
    expect(toolbarBefore, isNotNull);
    expect(boldButtonBefore, isNotNull);
    expect(headerSelectBefore, isNotNull);
    expect(toolbarBefore!.classes, isNot(contains('li-quill-text-editor__toolbar--hidden')));

    await fixture.update((_) {
      host.toolbarVisible = false;
    });
    await _settle(fixture);

    final toolbarHidden = fixture.rootElement.querySelector('.li-quill-text-editor__toolbar');
    final boldButtonHidden = fixture.rootElement.querySelector('.ql-bold');
    final headerSelectHidden = fixture.rootElement.querySelector('.ql-header');
    expect(identical(toolbarBefore, toolbarHidden), isTrue);
    expect(identical(boldButtonBefore, boldButtonHidden), isTrue);
    expect(identical(headerSelectBefore, headerSelectHidden), isTrue);
    expect(toolbarHidden!.classes, contains('li-quill-text-editor__toolbar--hidden'));

    await fixture.update((_) {
      host.toolbarVisible = true;
    });
    await _settle(fixture);

    final toolbarAfter = fixture.rootElement.querySelector('.li-quill-text-editor__toolbar');
    final boldButtonAfter = fixture.rootElement.querySelector('.ql-bold');
    final headerSelectAfter = fixture.rootElement.querySelector('.ql-header');
    expect(identical(toolbarBefore, toolbarAfter), isTrue);
    expect(identical(boldButtonBefore, boldButtonAfter), isTrue);
    expect(identical(headerSelectBefore, headerSelectAfter), isTrue);
    expect(toolbarAfter!.classes, isNot(contains('li-quill-text-editor__toolbar--hidden')));
  });

    test('disables selected toolbar controls without rebuilding them', () async {
    final fakeBridge = FakeLiQuillTextEditorBridge();
    setLiQuillTextEditorBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final orderedButtonBefore = fixture.rootElement
      .querySelector('.ql-list[value="ordered"]') as html.ButtonElement?;
    final alignLeftButtonBefore = fixture.rootElement
      .querySelector('[title="Alinhar à esquerda"]') as html.ButtonElement?;
    final boldButtonBefore =
      fixture.rootElement.querySelector('.ql-bold') as html.ButtonElement?;
    final headerSelectBefore =
      fixture.rootElement.querySelector('select.ql-header') as html.SelectElement?;
    final sizeSelectBefore =
      fixture.rootElement.querySelector('select.ql-size') as html.SelectElement?;
    final colorSelectBefore =
      fixture.rootElement.querySelector('select.ql-color') as html.SelectElement?;
    final backgroundSelectBefore = fixture.rootElement
      .querySelector('select.ql-background') as html.SelectElement?;

    expect(orderedButtonBefore, isNotNull);
    expect(alignLeftButtonBefore, isNotNull);
    expect(boldButtonBefore, isNotNull);
    expect(headerSelectBefore, isNotNull);
    expect(sizeSelectBefore, isNotNull);
    expect(colorSelectBefore, isNotNull);
    expect(backgroundSelectBefore, isNotNull);

    await fixture.update((_) {
      host.disabledToolbarItemIds = <String>[
      LiQuillToolbarItems.orderedList.id,
      LiQuillToolbarItems.alignLeft.id,
      LiQuillToolbarItems.header.id,
      LiQuillToolbarItems.fontSize.id,
      LiQuillToolbarItems.color.id,
      LiQuillToolbarItems.background.id,
      ];
    });
    await _settle(fixture);

    final orderedButtonAfter = fixture.rootElement
      .querySelector('.ql-list[value="ordered"]') as html.ButtonElement?;
    final alignLeftButtonAfter = fixture.rootElement
      .querySelector('[title="Alinhar à esquerda"]') as html.ButtonElement?;
    final boldButtonAfter =
      fixture.rootElement.querySelector('.ql-bold') as html.ButtonElement?;
    final headerSelectAfter =
      fixture.rootElement.querySelector('select.ql-header') as html.SelectElement?;
    final sizeSelectAfter =
      fixture.rootElement.querySelector('select.ql-size') as html.SelectElement?;
    final colorSelectAfter =
      fixture.rootElement.querySelector('select.ql-color') as html.SelectElement?;
    final backgroundSelectAfter = fixture.rootElement
      .querySelector('select.ql-background') as html.SelectElement?;

    expect(identical(orderedButtonBefore, orderedButtonAfter), isTrue);
    expect(identical(alignLeftButtonBefore, alignLeftButtonAfter), isTrue);
    expect(identical(headerSelectBefore, headerSelectAfter), isTrue);
    expect(identical(sizeSelectBefore, sizeSelectAfter), isTrue);
    expect(identical(colorSelectBefore, colorSelectAfter), isTrue);
    expect(identical(backgroundSelectBefore, backgroundSelectAfter), isTrue);
    expect(orderedButtonAfter!.disabled, isTrue);
    expect(alignLeftButtonAfter!.disabled, isTrue);
    expect(headerSelectAfter!.disabled, isTrue);
    expect(sizeSelectAfter!.disabled, isTrue);
    expect(colorSelectAfter!.disabled, isTrue);
    expect(backgroundSelectAfter!.disabled, isTrue);
    expect(boldButtonAfter!.disabled, isFalse);
    expect(
      (orderedButtonAfter.parent as html.Element).classes,
      contains('li-quill-text-editor__toolbar-item--disabled'),
    );

    await fixture.update((_) {
      host.disabledToolbarItemIds = const <String>[];
    });
    await _settle(fixture);

    final orderedButtonReset = fixture.rootElement
      .querySelector('.ql-list[value="ordered"]') as html.ButtonElement?;
    final headerSelectReset =
      fixture.rootElement.querySelector('select.ql-header') as html.SelectElement?;

    expect(identical(orderedButtonBefore, orderedButtonReset), isTrue);
    expect(identical(headerSelectBefore, headerSelectReset), isTrue);
    expect(orderedButtonReset!.disabled, isFalse);
    expect(headerSelectReset!.disabled, isFalse);
    expect(
      (orderedButtonReset.parent as html.Element).classes,
      isNot(contains('li-quill-text-editor__toolbar-item--disabled')),
    );
    });

  test('rebuilds the editor destructively when toolbar structure changes',
      () async {
    final fakeBridge = FakeLiQuillTextEditorBridge();
    setLiQuillTextEditorBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(fakeBridge.createdEditors, hasLength(1));
    expect(
      fixture.rootElement.querySelector('.ql-table-better'),
      isNotNull,
    );

    host.editor!.insertTextAtSelection(' mutado');
    await _settle(fixture);

    final firstHandle = fakeBridge.createdEditors.first;

    await fixture.update((_) {
      host.enableDestructiveToolbarRebuild = true;
      host.enableTableButton = false;
    });
    await _settle(fixture);

    expect(fakeBridge.createdEditors, hasLength(2));
    expect(firstHandle.disposed, isTrue);
    expect(
      fixture.rootElement.querySelector('.ql-table-better'),
      isNull,
    );
    expect(host.editor!.getPlainText(), contains('mutado'));
    expect(host.modelValue, contains('mutado'));
  });

  test('hides selected toolbar controls with the hidden attribute in safe mode',
      () async {
    final fakeBridge = FakeLiQuillTextEditorBridge();
    setLiQuillTextEditorBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final orderedButtonBefore = fixture.rootElement
        .querySelector('.ql-list[value="ordered"]') as html.ButtonElement?;
    final boldButtonBefore =
        fixture.rootElement.querySelector('.ql-bold') as html.ButtonElement?;

    expect(orderedButtonBefore, isNotNull);
    expect(boldButtonBefore, isNotNull);

    await fixture.update((_) {
      host.hiddenToolbarItemIds = <String>[
        LiQuillToolbarItems.orderedList.id,
      ];
    });
    await _settle(fixture);

    final orderedButtonAfter = fixture.rootElement
        .querySelector('.ql-list[value="ordered"]') as html.ButtonElement?;

    expect(fakeBridge.createdEditors, hasLength(1));
    expect(identical(orderedButtonBefore, orderedButtonAfter), isTrue);
    expect(
      (orderedButtonAfter!.parent as html.Element).getAttribute('hidden'),
      isNotNull,
    );
    expect(
      (boldButtonBefore!.parent as html.Element).getAttribute('hidden'),
      isNull,
    );
  });

  test('removes selected toolbar controls when hidden ids change in destructive mode',
      () async {
    final fakeBridge = FakeLiQuillTextEditorBridge();
    setLiQuillTextEditorBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    host.editor!.insertTextAtSelection(' ocultado');
    await _settle(fixture);

    final firstHandle = fakeBridge.createdEditors.first;
    expect(
      fixture.rootElement.querySelector('.ql-list[value="ordered"]'),
      isNotNull,
    );

    await fixture.update((_) {
      host.enableDestructiveToolbarRebuild = true;
      host.hiddenToolbarItemIds = <String>[
        LiQuillToolbarItems.orderedList.id,
      ];
    });
    await _settle(fixture);

    expect(fakeBridge.createdEditors, hasLength(2));
    expect(firstHandle.disposed, isTrue);
    expect(
      fixture.rootElement.querySelector('.ql-list[value="ordered"]'),
      isNull,
    );
    expect(host.editor!.getPlainText(), contains('ocultado'));
  });

  test('neutralizes legacy list-marker pseudos from the theme-bundled Quill CSS',
      () async {
    final legacyStyle = _appendHeadStyle('''
      .ql-editor ol {
        padding-left: 1.5em;
      }

      .ql-editor ul {
        padding-left: 1.5em;
      }

      .ql-editor li {
        list-style-type: none;
        padding-left: 1.5em;
        position: relative;
      }

      .ql-editor li > .ql-ui::before {
        display: inline-block;
        margin-left: -1.5em;
        margin-right: .3em;
        text-align: right;
        white-space: nowrap;
        width: 1.2em;
      }

      .ql-editor li[data-list=ordered] {
        counter-increment: list-0;
      }

      .ql-editor li[data-list=ordered] > .ql-ui::before {
        content: counter(list-0, decimal) '. ';
      }

      .ql-editor li[data-list=bullet] > .ql-ui::before {
        content: '\\2022';
      }

      .ql-editor li.ql-direction-rtl > .ql-ui::before {
        display: inline-block;
        margin-left: .3em;
        margin-right: -1.5em;
        text-align: left;
        white-space: nowrap;
        width: 1.2em;
      }

      .ql-editor ol li::before {
        content: counter(list-0, decimal) '. ';
      }

      .ql-editor ul li::before {
        content: '\\2022';
      }

      .ql-editor li:not(.ql-direction-rtl)::before {
        display: inline-block;
        margin-left: -1.5em;
        margin-right: .3em;
        text-align: right;
        white-space: nowrap;
        width: 1.2em;
      }

      .ql-editor li.ql-direction-rtl::before {
        display: inline-block;
        margin-left: .3em;
        margin-right: -1.5em;
        text-align: left;
        white-space: nowrap;
        width: 1.2em;
      }
    ''');
    addTearDown(legacyStyle.remove);

    final fakeBridge = FakeLiQuillTextEditorBridge();
    setLiQuillTextEditorBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    await _settle(fixture);

    final editorSurface =
      fixture.rootElement.querySelector('.li-quill-text-editor__editor');
    expect(editorSurface, isNotNull);

    final qlEditor = html.DivElement()..classes.add('ql-editor');

    final orderedList = html.OListElement();
    final orderedItem = html.LIElement()..setAttribute('data-list', 'ordered');
    final orderedUi = html.SpanElement()
      ..classes.add('ql-ui')
      ..setAttribute('contenteditable', 'false');
    orderedItem
      ..append(orderedUi)
      ..appendText('Primeiro item');
    orderedList.append(orderedItem);

    final bulletList = html.UListElement();
    final bulletItem = html.LIElement()..setAttribute('data-list', 'bullet');
    final bulletUi = html.SpanElement()
      ..classes.add('ql-ui')
      ..setAttribute('contenteditable', 'false');
    bulletItem
      ..append(bulletUi)
      ..appendText('Item com marcador');
    bulletList.append(bulletItem);

    final rtlList = html.OListElement();
    final rtlItem = html.LIElement()
      ..setAttribute('data-list', 'ordered')
      ..classes.add('ql-direction-rtl');
    final rtlUi = html.SpanElement()
      ..classes.add('ql-ui')
      ..setAttribute('contenteditable', 'false');
    rtlItem
      ..append(rtlUi)
      ..appendText('عنصر');
    rtlList.append(rtlItem);

    qlEditor.append(orderedList);
    qlEditor.append(bulletList);
    qlEditor.append(rtlList);
    editorSurface!.append(qlEditor);
    await _settle(fixture);

    final orderedLegacyMarkerStyle = _pseudoStyle(orderedItem, '::before');
    final orderedQuillUiMarkerStyle = _pseudoStyle(orderedUi, '::before');
    final bulletLegacyMarkerStyle = _pseudoStyle(bulletItem, '::before');
    final bulletQuillUiMarkerStyle = _pseudoStyle(bulletUi, '::before');
    final rtlLegacyMarkerStyle = _pseudoStyle(rtlItem, '::before');
    final rtlQuillUiMarkerStyle = _pseudoStyle(rtlUi, '::before');

    expect(orderedLegacyMarkerStyle.display, 'none');
    expect(orderedLegacyMarkerStyle.content, 'none');
    expect(orderedQuillUiMarkerStyle.display, 'inline-block');
    expect(
      orderedQuillUiMarkerStyle.content,
      isNot(anyOf('none', 'normal', '""')),
    );

    expect(bulletLegacyMarkerStyle.display, 'none');
    expect(bulletLegacyMarkerStyle.content, 'none');
    expect(bulletQuillUiMarkerStyle.display, 'inline-block');
    expect(
      bulletQuillUiMarkerStyle.content,
      isNot(anyOf('none', 'normal', '""')),
    );

    expect(rtlLegacyMarkerStyle.display, 'none');
    expect(rtlLegacyMarkerStyle.content, 'none');
    expect(rtlQuillUiMarkerStyle.display, 'inline-block');
    expect(
      rtlQuillUiMarkerStyle.content,
      isNot(anyOf('none', 'normal', '""')),
    );
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

html.StyleElement _appendHeadStyle(String cssText) {
  final style = html.StyleElement()..text = cssText;
  html.document.head!.append(style);
  return style;
}

html.CssStyleDeclaration _pseudoStyle(html.Element element, String pseudoElement) {
  return js_util.callMethod<html.CssStyleDeclaration>(
    html.window,
    'getComputedStyle',
    <Object?>[element, pseudoElement],
  );
}