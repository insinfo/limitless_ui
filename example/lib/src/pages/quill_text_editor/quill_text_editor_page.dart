import 'dart:convert';

import 'package:limitless_ui/quill_text_editor.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'quill-text-editor-page',
  templateUrl: 'quill_text_editor_page.html',
  styleUrls: ['quill_text_editor_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    liQuillTextEditorDirectives,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class QuillTextEditorPageComponent {
  QuillTextEditorPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get isPt => i18n.isPortuguese;

  static const String importSnippet =
      '''import 'package:limitless_ui/quill_text_editor.dart';''';

  static const String assetSnippet = '''<script src="assets/js/quill/2.0.3/quill.js"></script>
<script src="assets/js/quill_table_better/1.2.3/quill_table_better.js"></script>''';

  static const String basicSnippet = '''<li-quill-text-editor
    [(ngModel)]="htmlValue"
    [labels]="editorLabels"
    minHeight="20rem">
</li-quill-text-editor>''';

  static const String disabledItemsSnippet = '''final disabledToolbarItemIds = <String>[
  LiQuillToolbarItems.orderedList.id,
  LiQuillToolbarItems.header.id,
  LiQuillToolbarItems.fontSize.id,
  LiQuillToolbarItems.alignLeft.id,
  LiQuillToolbarItems.alignCenter.id,
  LiQuillToolbarItems.alignRight.id,
  LiQuillToolbarItems.alignJustify.id,
  LiQuillToolbarItems.color.id,
  LiQuillToolbarItems.background.id,
];

<li-quill-text-editor
    [(ngModel)]="htmlValue"
    [disabledToolbarItemIds]="disabledToolbarItemIds">
</li-quill-text-editor>''';

  static const String destructiveModeSnippet = '''<li-quill-text-editor
    [(ngModel)]="htmlValue"
    [enableDestructiveToolbarRebuild]="true"
    [enableTableButton]="showTableButton"
    [toolbarItems]="customToolbarItems">
</li-quill-text-editor>''';

  static const String customSnippet = '''final actions = <LiQuillToolbarAction>[
  LiQuillToolbarAction(
    id: 'append-signature',
    iconClass: 'ph ph-signature',
    label: 'Assinar',
    onPressed: (event) => event.editor.insertTextAtSelection(' [assinado]'),
  ),
];

<li-quill-text-editor
    [(ngModel)]="htmlValue"
    [labels]="editorLabels"
    [toolbarActions]="actions"
    [enableTableSupport]="true"
    [enableTableButton]="true">
  <template liQuillTextEditorToolbarActions let-ctx>
    <button type="button" (click)="captureEditorState()">
      Snapshot
    </button>
  </template>
</li-quill-text-editor>''';

  static final List<String> _apiItemsPt = List<String>.unmodifiable(
    const <String>[
      'Toolbar configurável por itens, desativação seletiva, rebuild destrutivo opcional, ações Dart e template projetado.',
      'Integração com forms via ControlValueAccessor e ngModel.',
      'APIs públicas para HTML, texto simples, delta JSON, formatação e inserção de texto.',
      'Suporte opcional a tabelas com Quill Table Better.',
    ],
  );

  static final List<String> _apiItemsEn = List<String>.unmodifiable(
    const <String>[
      'Configurable toolbar through item ids, selective disabling, optional destructive rebuilds, custom actions, and a projected template.',
      'Forms integration through ControlValueAccessor and ngModel.',
      'Public APIs for HTML, plain text, delta JSON, formatting, and text insertion.',
      'Optional table support through Quill Table Better.',
    ],
  );

  static final List<LiQuillToolbarAction> _toolbarActionsPt =
      List<LiQuillToolbarAction>.unmodifiable(<LiQuillToolbarAction>[
    LiQuillToolbarAction(
      id: 'append-signature',
      iconClass: 'ph ph-signature',
      label: 'Assinar',
      title: 'Inserir assinatura',
      onPressed: _insertSignedSuffix,
    ),
  ]);

  static final List<LiQuillToolbarAction> _toolbarActionsEn =
      List<LiQuillToolbarAction>.unmodifiable(<LiQuillToolbarAction>[
    LiQuillToolbarAction(
      id: 'append-signature',
      iconClass: 'ph ph-signature',
      label: 'Sign',
      title: 'Insert signature tag',
      onPressed: _insertReviewedSuffix,
    ),
  ]);

  static void _insertSignedSuffix(LiQuillToolbarActionEvent event) {
    event.editor.insertTextAtSelection(' [assinado]');
  }

  static void _insertReviewedSuffix(LiQuillToolbarActionEvent event) {
    event.editor.insertTextAtSelection(' [reviewed]');
  }

  @ViewChild('editor')
  set editorRef(LiQuillTextEditorComponent? value) {
    editor = value;
    _refreshSnapshots();
  }

  LiQuillTextEditorComponent? editor;

  bool toolbarVisible = true;
  bool readOnly = false;
  bool updateModelOnBlur = false;
  bool enableTableSupport = true;
  bool enableTableButton = true;
  bool enableDestructiveToolbarRebuild = true;
  bool disableOrderedList = false;
  bool disableHeadings = false;
  bool disableFontSize = false;
  bool disableAlignment = false;
  bool disableTextColor = false;
  bool disableBackgroundColor = false;
  List<String> disabledToolbarItemIds = const <String>[];
  String toolbarEvent = '';

  String _htmlValue = '<p><strong>Limitless UI</strong> editor pronto para notas, pareceres e orientações rápidas.</p>';
  String plainTextPreview = '';
  String deltaPreview = '';

  String get htmlValue => _htmlValue;

  set htmlValue(String? value) {
    _htmlValue = value ?? '';
    _refreshSnapshots();
  }

  LiQuillTextEditorLabels get editorLabels =>
      isPt ? LiQuillTextEditorLabels.portuguese : LiQuillTextEditorLabels.english;

  List<LiQuillToolbarAction> get toolbarActions =>
      isPt ? _toolbarActionsPt : _toolbarActionsEn;

  List<String> get apiItems => isPt ? _apiItemsPt : _apiItemsEn;

  String get pageTitle => isPt ? 'Utilitários' : 'Utilities';
  String get pageSubtitle => isPt ? 'Editor Quill' : 'Quill editor';
  String get breadcrumb => isPt
      ? 'Editor de texto rico genérico com Quill 2.0.3'
      : 'Generic rich text editor with Quill 2.0.3';
  String get intro => isPt
      ? 'LiQuillTextEditorComponent oferece um editor genérico e isolado, sem acoplamento com exportação para PDF ou integrações proprietárias, com toolbar configurável e API pública para manipular o conteúdo.'
      : 'LiQuillTextEditorComponent provides a generic isolated editor with no PDF export coupling or proprietary integrations, plus a configurable toolbar and public content APIs.';
  String get capabilityTitle => isPt ? 'Capacidades' : 'Capabilities';
  String get capabilityBody => isPt
      ? 'O componente aceita ações extras na toolbar, templates projetados e leitura ou escrita de HTML, texto simples e delta JSON.'
      : 'The component accepts extra toolbar actions, projected templates, and HTML, plain text, and delta JSON read/write operations.';
  String get integrationTitle => isPt ? 'Integração' : 'Integration';
  String get integrationBody => isPt
      ? 'O editor implementa ControlValueAccessor, então funciona com ngModel e fluxos de formulário sem wrappers adicionais.'
      : 'The editor implements ControlValueAccessor so it works with ngModel and form flows without additional wrappers.';
  String get customizationTitle => isPt ? 'Customização' : 'Customization';
  String get customizationBody => isPt
      ? 'Você pode alternar modo leitura, toolbar, suporte a tabela, labels bilíngues, desativar controles nativos da toolbar, ativar rebuild destrutivo quando a estrutura mudar e adicionar ações customizadas sem reescrever a shell do editor.'
      : 'You can toggle read-only mode, the toolbar, table support, bilingual labels, disable native toolbar controls, enable destructive rebuilds when the structure changes, and add custom actions without rewriting the editor shell.';
  String get controlsTitle => isPt ? 'Controles da demo' : 'Demo controls';
  String get controlsBody => isPt
      ? 'Use estes toggles para validar a toolbar dinâmica, o modo somente leitura, o suporte opcional a tabelas, o rebuild destrutivo para mudanças estruturais e a desativação seletiva dos controles padrão.'
      : 'Use these toggles to validate the dynamic toolbar, read-only mode, optional table support, destructive rebuilds for structural changes, and selective disabling of default controls.';
  String get liveEditorTitle => isPt ? 'Editor ao vivo' : 'Live editor';
  String get previewTitle => isPt ? 'Snapshot do conteúdo' : 'Content snapshot';
  String get htmlPreviewLabel => 'HTML';
  String get plainTextPreviewLabel => isPt ? 'Texto simples' : 'Plain text';
  String get deltaPreviewLabel => 'Delta JSON';
  String get statusLabel => isPt ? 'Última ação' : 'Last action';
  String get defaultStatus => isPt
      ? 'Toolbar pronta para receber ações e templates.'
      : 'Toolbar ready to receive actions and templates.';
  String get destructiveModeLabel => isPt
      ? 'Modo destrutivo da toolbar'
      : 'Destructive toolbar mode';
  String get disableOrderedListLabel =>
      isPt ? 'Desativar lista ordenada' : 'Disable ordered list';
  String get disableHeadingsLabel =>
      isPt ? 'Desativar títulos' : 'Disable headings';
  String get disableFontSizeLabel =>
      isPt ? 'Desativar tamanho da fonte' : 'Disable font size';
  String get disableAlignmentLabel =>
      isPt ? 'Desativar alinhamento' : 'Disable alignment';
  String get disableTextColorLabel =>
      isPt ? 'Desativar cor do texto' : 'Disable text color';
  String get disableBackgroundColorLabel =>
      isPt ? 'Desativar cor de fundo' : 'Disable background color';
  String get disabledToolbarNote => isPt
      ? 'A toolbar padrão não inclui seletor de família de fonte. Se você fornecer um item customizado com id "font", o mesmo input disabledToolbarItemIds também consegue desativá-lo.'
      : 'The default toolbar does not include a font-family picker. If you provide a custom item with id "font", the same disabledToolbarItemIds input can disable it as well.';
  String get destructiveModeNote => isPt
      ? 'Use o modo destrutivo só quando a estrutura real da toolbar precisar mudar em runtime. Ele recria a instância do Quill preservando o conteúdo atual.'
      : 'Use destructive mode only when the real toolbar structure must change at runtime. It recreates the Quill instance while preserving the current content.';
  String get projectedStampLabel => isPt ? 'Carimbo' : 'Stamp';
  String get projectedSnapshotLabel => isPt ? 'Atualizar snapshot' : 'Refresh snapshot';
  String get checklistButtonLabel => isPt ? 'Aplicar checklist' : 'Apply checklist';

  void syncDisabledToolbarItemIds() {
    disabledToolbarItemIds = List<String>.unmodifiable(<String>[
      if (disableOrderedList) LiQuillToolbarItems.orderedList.id,
      if (disableHeadings) LiQuillToolbarItems.header.id,
      if (disableFontSize) LiQuillToolbarItems.fontSize.id,
      if (disableAlignment) ...<String>[
        LiQuillToolbarItems.alignLeft.id,
        LiQuillToolbarItems.alignCenter.id,
        LiQuillToolbarItems.alignRight.id,
        LiQuillToolbarItems.alignJustify.id,
      ],
      if (disableTextColor) LiQuillToolbarItems.color.id,
      if (disableBackgroundColor) LiQuillToolbarItems.background.id,
    ]);
    toolbarEvent = isPt
        ? 'Controles nativos da toolbar atualizados.'
        : 'Native toolbar controls updated.';
  }

  void onDisableOrderedListChange(bool value) {
    disableOrderedList = value;
    syncDisabledToolbarItemIds();
  }

  void onDisableHeadingsChange(bool value) {
    disableHeadings = value;
    syncDisabledToolbarItemIds();
  }

  void onDisableFontSizeChange(bool value) {
    disableFontSize = value;
    syncDisabledToolbarItemIds();
  }

  void onDisableAlignmentChange(bool value) {
    disableAlignment = value;
    syncDisabledToolbarItemIds();
  }

  void onDisableTextColorChange(bool value) {
    disableTextColor = value;
    syncDisabledToolbarItemIds();
  }

  void onDisableBackgroundColorChange(bool value) {
    disableBackgroundColor = value;
    syncDisabledToolbarItemIds();
  }

  void insertStamp() {
    final currentEditor = editor;
    if (currentEditor == null) {
      return;
    }
    currentEditor.insertTextAtSelection(isPt ? ' [carimbo]' : ' [stamp]');
    captureEditorState(
      isPt ? 'Carimbo inserido pela template toolbar.' : 'Stamp inserted from the template toolbar.',
    );
  }

  Future<void> applyChecklistTemplate() async {
    final currentEditor = editor;
    if (currentEditor == null) {
      return;
    }

    final delta = isPt
        ? <String, dynamic>{
            'ops': <Map<String, dynamic>>[
              <String, dynamic>{'insert': 'Checklist de revisão\n', 'attributes': <String, dynamic>{'header': 2}},
              <String, dynamic>{'insert': 'Objetivo validado\nPrazo confirmado\nAtores notificados\n'},
            ],
          }
        : <String, dynamic>{
            'ops': <Map<String, dynamic>>[
              <String, dynamic>{'insert': 'Review checklist\n', 'attributes': <String, dynamic>{'header': 2}},
              <String, dynamic>{'insert': 'Goal validated\nDeadline confirmed\nStakeholders notified\n'},
            ],
          };

    await currentEditor.setDeltaJson(jsonEncode(delta));
    captureEditorState(
      isPt ? 'Template de checklist aplicado.' : 'Checklist template applied.',
    );
  }

  void captureEditorState([String? message]) {
    final currentEditor = editor;
    if (currentEditor != null) {
      _htmlValue = currentEditor.getHtml();
    }
    _refreshSnapshots();
    toolbarEvent = message ?? (isPt ? 'Snapshot atualizado.' : 'Snapshot refreshed.');
  }

  void _refreshSnapshots() {
    final currentEditor = editor;
    if (currentEditor != null && currentEditor.isReady) {
      plainTextPreview = currentEditor.getPlainText();
      deltaPreview = currentEditor.getDeltaJson();
      return;
    }

    plainTextPreview = _htmlValue
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .trim();
    deltaPreview = jsonEncode(<String, dynamic>{
      'ops': <Map<String, String>>[
        <String, String>{'insert': plainTextPreview.isEmpty ? '\n' : '$plainTextPreview\n'},
      ],
    });
  }
}