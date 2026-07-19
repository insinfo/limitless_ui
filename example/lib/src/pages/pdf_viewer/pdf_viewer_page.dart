import 'dart:convert';
import 'dart:typed_data';

import 'package:limitless_ui/pdf_viewer.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

import 'pdf_viewer_signature_demo_panel_component.dart';

@Component(
  selector: 'pdf-viewer-page',
  templateUrl: 'pdf_viewer_page.html',
  styleUrls: ['pdf_viewer_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    liPdfViewerDirectives,
    PdfViewerSignatureDemoPanelComponent,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class PdfViewerPageComponent {
  PdfViewerPageComponent(this.i18n) {
    _buildViewerToolbarActions();
    loadReleasePreview();
  }

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get isPt => i18n.isPortuguese;

  static const String importSnippet =
      '''import 'package:limitless_ui/pdf_viewer.dart';''';

  static const String scriptSnippet =
      '''<script src="assets/js/pdf.js/5.4.149/build/pdf.export.js" type="module"></script>''';

  static const String basicSnippet = '''<div style="height: 72vh;">
  <li-pdf-viewer
      [bytes]="documentBytes"
      title="Release briefing"
      pdfJsBasePath="assets/js/pdf.js/5.4.149">
  </li-pdf-viewer>
</div>''';

  static const String customSnippet =
      '''const labels = LiPdfViewerLabels.portuguese;
const zoomOptions = defaultLiPdfViewerZoomOptionsPt;

final toolbarActions = <LiPdfViewerToolbarAction>[
  LiPdfViewerToolbarAction(
    id: 'signatures',
    iconClass: 'ph ph-signature',
    titleBuilder: (viewer) => viewer.sidePanelOpen ? 'Ocultar assinaturas' : 'Mostrar assinaturas',
    activeBuilder: (viewer) => viewer.sidePanelOpen,
    onPressed: (event) => event.viewer.toggleSidePanel(),
  ),
];

<li-pdf-viewer
    [bytes]="documentBytes"
    [labels]="labels"
    [zoomOptions]="zoomOptions"
    [customToolbarActions]="toolbarActions"
    [sidePanelTitle]="'Inspector'"
    [enableDownloadAction]="true"
    [enablePrintAction]="true"
    [enablePanModeAction]="true"
    [enableFullscreenAction]="true"
    downloadFileName="release-note.pdf">
  <template liPdfViewerToolbarActions let-ctx>
    <button type="button" class="btn btn-sm btn-light border-transparent rounded-pill" (click)="runQuickValidation()">Validação rápida</button>
  </template>

  <template liPdfViewerSidePanel let-ctx>
    <pdf-viewer-signature-demo-panel
      [activeMode]="activeValidationMode"
      [documentIntact]="activeDocumentIntact"
      [signatureValidationSummary]="activeValidationSummary"
      [signatureValidationElapsedLabel]="activeValidationElapsedLabel"
      [signatureEntries]="activeSignatureEntries"
      (quickValidation)="runQuickValidation()"
      (advancedValidation)="runAdvancedValidation()"
      (entryOpen)="onSignatureEntryOpen(ctx, \$event)">
    </pdf-viewer-signature-demo-panel>
  </template>
</li-pdf-viewer>''';

  bool toolbarVisible = true;
  bool showTitle = true;
  bool enableDownloadAction = true;
  bool enablePrintAction = true;
  bool enableRotateAction = true;
  bool enableFitWidthAction = true;
  bool enablePanModeAction = true;
  bool enableFullscreenAction = true;
  bool enableGoToPageAction = true;
  bool sidePanelOpen = true;
  List<LiPdfViewerToolbarAction> viewerToolbarActions =
      const <LiPdfViewerToolbarAction>[];
  PdfViewerDemoValidationMode activeValidationMode =
      PdfViewerDemoValidationMode.quick;

  Uint8List? activePdfBytes;
  String activeDocumentKey = 'release';
  int loadedPages = 0;
  int observedPage = 1;
  double observedScale = 1.0;
  String lastError = '';

  static const List<PdfViewerDemoSignatureEntry> _quickEntriesPt =
      <PdfViewerDemoSignatureEntry>[
    PdfViewerDemoSignatureEntry(
      pageNumber: 1,
      label: 'Assinatura da minuta',
      signerName: 'Maria Oliveira',
      reason: 'Aprovação inicial',
      policyDisplay: 'ICP-Brasil PAdES',
      valid: true,
    ),
    PdfViewerDemoSignatureEntry(
      pageNumber: 1,
      label: 'Assinatura da chefia',
      signerName: 'Carlos Mendes',
      reason: 'Liberação do despacho',
      policyDisplay: 'ICP-Brasil PAdES',
      valid: true,
    ),
  ];

  static const List<PdfViewerDemoSignatureEntry> _advancedEntriesPt =
      <PdfViewerDemoSignatureEntry>[
    PdfViewerDemoSignatureEntry(
      pageNumber: 1,
      label: 'Assinatura da minuta',
      signerName: 'Maria Oliveira',
      reason: 'Aprovação inicial',
      policyDisplay: 'ICP-Brasil PAdES Baseline B-T',
      valid: true,
    ),
    PdfViewerDemoSignatureEntry(
      pageNumber: 1,
      label: 'Assinatura da chefia',
      signerName: 'Carlos Mendes',
      reason: 'Liberação do despacho',
      policyDisplay: 'ICP-Brasil PAdES Baseline B-T',
      valid: true,
    ),
    PdfViewerDemoSignatureEntry(
      pageNumber: 1,
      label: 'Carimbo de protocolo',
      signerName: 'Sistema SALI',
      reason: 'Registro de tramitação',
      policyDisplay: 'Carimbo de tempo',
      valid: true,
    ),
  ];

  static const List<PdfViewerDemoSignatureEntry> _quickEntriesEn =
      <PdfViewerDemoSignatureEntry>[
    PdfViewerDemoSignatureEntry(
      pageNumber: 1,
      label: 'Draft signature',
      signerName: 'Maria Oliveira',
      reason: 'Initial approval',
      policyDisplay: 'ICP-Brasil PAdES',
      valid: true,
    ),
    PdfViewerDemoSignatureEntry(
      pageNumber: 1,
      label: 'Manager signature',
      signerName: 'Carlos Mendes',
      reason: 'Dispatch release',
      policyDisplay: 'ICP-Brasil PAdES',
      valid: true,
    ),
  ];

  static const List<PdfViewerDemoSignatureEntry> _advancedEntriesEn =
      <PdfViewerDemoSignatureEntry>[
    PdfViewerDemoSignatureEntry(
      pageNumber: 1,
      label: 'Draft signature',
      signerName: 'Maria Oliveira',
      reason: 'Initial approval',
      policyDisplay: 'ICP-Brasil PAdES Baseline B-T',
      valid: true,
    ),
    PdfViewerDemoSignatureEntry(
      pageNumber: 1,
      label: 'Manager signature',
      signerName: 'Carlos Mendes',
      reason: 'Dispatch release',
      policyDisplay: 'ICP-Brasil PAdES Baseline B-T',
      valid: true,
    ),
    PdfViewerDemoSignatureEntry(
      pageNumber: 1,
      label: 'Protocol timestamp',
      signerName: 'SALI System',
      reason: 'Workflow registration',
      policyDisplay: 'Timestamp authority',
      valid: true,
    ),
  ];

  String get pageTitle => isPt ? 'Utilitários' : 'Utilities';
  String get pageSubtitle => 'PDF Viewer';
  String get breadcrumb => isPt
      ? 'Visualização genérica de PDF com PDF.js'
      : 'Generic PDF viewing with PDF.js';
  String get intro => isPt
      ? 'LiPdfViewerComponent oferece visualização genérica de PDF com PDF.js, zoom, paginação, fullscreen, impressão e download, sem acoplamento a backend específico ou fluxos de assinatura.'
      : 'LiPdfViewerComponent provides generic PDF viewing with PDF.js, zoom, paging, fullscreen, print, and download without coupling to a specific backend or signature flow.';
  String get descriptionTitle => isPt ? 'Escopo' : 'Scope';
  String get descriptionBody => isPt
      ? 'O componente aceita `bytes` ou `url`, renderiza via PDF.js e mantém o contrato focado em leitura, navegação e ações de arquivo.'
      : 'The component accepts `bytes` or `url`, renders through PDF.js, and keeps the contract focused on reading, navigation, and file actions.';
  String get flexibilityTitle => isPt ? 'Customização' : 'Customization';
  String get flexibilityBody => isPt
      ? 'É possível alternar toolbar, fullscreen, pan, impressão, download, rotação, labels, opções de zoom e caminhos dos assets do PDF.js.'
      : 'You can toggle toolbar, fullscreen, pan, print, download, rotation, labels, zoom options, and PDF.js asset paths.';
  String get requirementTitle =>
      isPt ? 'Requisito de layout' : 'Layout requirement';
  String get requirementBody => isPt
      ? 'O container pai precisa ter altura explícita. No exemplo abaixo, a shell do viewer usa altura fixa para que o canvas e a rolagem funcionem corretamente.'
      : 'The parent container needs an explicit height. In the live example below the viewer shell uses a fixed height so the canvas and scrolling behave correctly.';
  String get controlsTitle => isPt ? 'Controles da demo' : 'Demo controls';
  String get controlsBody => isPt
      ? 'Use estes toggles para validar rapidamente os principais pontos de customização do viewer.'
      : 'Use these toggles to validate the main viewer customization points quickly.';
  String get extensibilityTitle => isPt ? 'Extensão' : 'Extension';
  String get extensibilityBody => isPt
      ? 'A toolbar agora aceita ações via API Dart e templates projetados, e o viewer expõe um painel lateral genérico para cenários como assinatura, inspeção e metadados.'
      : 'The toolbar now accepts actions through a Dart API and projected templates, and the viewer exposes a generic side panel for signature, inspection, and metadata scenarios.';
  String get sidePanelTitle =>
      isPt ? 'Assinaturas do documento' : 'Document signatures';
  String get inspectorSummary => isPt
      ? 'O painel lateral é genérico: o host decide o conteúdo e pode abri-lo por ação Dart ou botão customizado de template.'
      : 'The side panel is generic: the host owns the content and can open it through a Dart action or a custom template button.';
  String get inspectorJumpLabel =>
      isPt ? 'Ir para a página atual' : 'Jump to current page';
  String get inspectorFitLabel => isPt ? 'Ajustar largura' : 'Fit width';
  String get inspectorToggleLabel => isPt
      ? (sidePanelOpen ? 'Ocultar painel' : 'Mostrar painel')
      : (sidePanelOpen ? 'Hide panel' : 'Show panel');
  String get releaseDocLabel =>
      isPt ? 'Carregar release note' : 'Load release note';
  String get handbookDocLabel => isPt ? 'Carregar handbook' : 'Load handbook';
  String get apiIntro => isPt
      ? 'Para usar o viewer no app hospedeiro, carregue o bridge `pdf.export.js`, importe o barrel separado `package:limitless_ui/pdf_viewer.dart` se quiser uma dependência mais estreita, e renderize o componente dentro de um container com altura definida.'
      : 'To use the viewer in the host app, load the `pdf.export.js` bridge, import the separate barrel `package:limitless_ui/pdf_viewer.dart` if you want a narrower dependency, and render the component inside a container with an explicit height.';
  List<String> get apiItems => isPt
      ? const <String>[
          '`bytes` e `url` cobrem os dois cenários principais de carregamento.',
          '`pdfJsBasePath`, `workerSource`, `standardFontDataUrl` e `cMapUrl` desacoplam o componente da estrutura de assets do app.',
          '`labels` e `zoomOptions` permitem adaptar idioma e menu de zoom.',
          'Os inputs `enable*Action` permitem esconder ações sem CSS local.',
          '`customToolbarActions`, `toolbarActionsTemplate` e `sidePanelTemplate` permitem encaixar fluxos como assinatura, inspeção e ações de negócio sem acoplar o viewer.',
          'Os outputs `documentLoaded`, `pageChange`, `scaleChange` e `loadError` permitem reagir ao estado do viewer.',
        ]
      : const <String>[
          '`bytes` and `url` cover the two main loading scenarios.',
          '`pdfJsBasePath`, `workerSource`, `standardFontDataUrl`, and `cMapUrl` decouple the component from the host app asset layout.',
          '`labels` and `zoomOptions` let you adapt language and the zoom menu.',
          'The `enable*Action` inputs let you hide actions without local CSS.',
          '`customToolbarActions`, `toolbarActionsTemplate`, and `sidePanelTemplate` let you plug in signature, inspection, and business-specific actions without coupling the viewer.',
          'The `documentLoaded`, `pageChange`, `scaleChange`, and `loadError` outputs expose viewer state.',
        ];
  String get statusSummary => isPt
      ? 'Documento: $activeDocumentTitle | Paginas: $loadedPages | Pagina atual: $observedPage | Zoom: ${(observedScale * 100).round()}%'
      : 'Document: $activeDocumentTitle | Pages: $loadedPages | Current page: $observedPage | Zoom: ${(observedScale * 100).round()}%';
  String get errorSummary => lastError.trim().isEmpty
      ? (isPt ? 'Nenhum erro reportado.' : 'No reported errors.')
      : lastError;

  LiPdfViewerLabels get viewerLabels =>
      isPt ? LiPdfViewerLabels.portuguese : LiPdfViewerLabels.english;
  List<LiDropdownMenuOption> get viewerZoomOptions =>
      isPt ? defaultLiPdfViewerZoomOptionsPt : defaultLiPdfViewerZoomOptions;

  List<PdfViewerDemoSignatureEntry> get activeSignatureEntries {
    switch (activeValidationMode) {
      case PdfViewerDemoValidationMode.advanced:
        return isPt ? _advancedEntriesPt : _advancedEntriesEn;
      case PdfViewerDemoValidationMode.quick:
        return isPt ? _quickEntriesPt : _quickEntriesEn;
    }
  }

  bool get activeDocumentIntact => true;

  String get activeValidationSummary {
    switch (activeValidationMode) {
      case PdfViewerDemoValidationMode.advanced:
        return isPt
            ? 'Validação avançada concluída com cadeia e política verificadas.'
            : 'Advanced validation finished with chain and policy checks.';
      case PdfViewerDemoValidationMode.quick:
        return isPt
            ? 'Validação rápida concluída com integridade e assinaturas visíveis.'
            : 'Quick validation finished with integrity and visible signatures.';
    }
  }

  String get activeValidationElapsedLabel {
    switch (activeValidationMode) {
      case PdfViewerDemoValidationMode.advanced:
        return '00:01.42';
      case PdfViewerDemoValidationMode.quick:
        return '00:00.38';
    }
  }

  void _buildViewerToolbarActions() {
    viewerToolbarActions = <LiPdfViewerToolbarAction>[
      LiPdfViewerToolbarAction(
        id: 'signatures',
        iconClass: 'ph ph-signature',
        titleBuilder: (viewer) => isPt
            ? (viewer.sidePanelOpen
                ? 'Ocultar assinaturas'
                : 'Abrir assinaturas')
            : (viewer.sidePanelOpen ? 'Hide signatures' : 'Open signatures'),
        labelBuilder: (viewer) => isPt
            ? (viewer.sidePanelOpen
                ? 'Ocultar assinaturas'
                : 'Abrir assinaturas')
            : (viewer.sidePanelOpen ? 'Hide signatures' : 'Open signatures'),
        activeBuilder: (viewer) => viewer.sidePanelOpen,
        onPressed: (event) => event.viewer.toggleSidePanel(),
      ),
    ];
  }

  void runQuickValidation() {
    activeValidationMode = PdfViewerDemoValidationMode.quick;
    sidePanelOpen = true;
  }

  void runAdvancedValidation() {
    activeValidationMode = PdfViewerDemoValidationMode.advanced;
    sidePanelOpen = true;
  }

  String get activeDocumentTitle {
    switch (activeDocumentKey) {
      case 'handbook':
        return isPt ? 'Handbook operacional' : 'Operations handbook';
      case 'release':
      default:
        return isPt ? 'Release briefing' : 'Release briefing';
    }
  }

  void loadReleasePreview() {
    activeDocumentKey = 'release';
    activePdfBytes = _buildDemoPdf(
      title: isPt ? 'Release briefing' : 'Release briefing',
      lines: <String>[
        isPt
            ? 'Resumo executivo da janela de publicacao da sexta-feira.'
            : 'Executive summary of the Friday deployment window.',
        isPt
            ? 'Checklist: backup concluido, smoke test pendente e rollback pronto.'
            : 'Checklist: backup finished, smoke test pending, rollback ready.',
        isPt
            ? 'Acompanhar metricas de erro e latencia por 30 minutos.'
            : 'Track error and latency metrics for 30 minutes.',
      ],
    );
    _resetObservedState();
  }

  void loadHandbookPreview() {
    activeDocumentKey = 'handbook';
    activePdfBytes = _buildDemoPdf(
      title: isPt ? 'Handbook operacional' : 'Operations handbook',
      lines: <String>[
        isPt
            ? 'Fluxo de resposta: triagem, validacao, mitigacao e encerramento.'
            : 'Response flow: triage, validation, mitigation, and closure.',
        isPt
            ? 'Use o viewer generico para exibir documentos internos ou anexos de processo.'
            : 'Use the generic viewer to display internal documents or process attachments.',
        isPt
            ? 'A integracao pode escolher bytes, URL direta e customizacao de labels.'
            : 'The integration can choose bytes, direct URL, and label customization.',
      ],
    );
    _resetObservedState();
  }

  void onDocumentLoaded(int totalPages) {
    loadedPages = totalPages;
    lastError = '';
  }

  void onPageChanged(int pageNumber) {
    observedPage = pageNumber;
  }

  void onScaleChanged(double scale) {
    observedScale = scale;
  }

  void onLoadError(String message) {
    lastError = message;
  }

  void onSignatureEntryOpen(
    LiPdfViewerTemplateContext ctx,
    PdfViewerDemoSignatureEntry entry,
  ) {
    ctx.scrollToPage(entry.pageNumber);
  }

  void onViewerSidePanelOpenChange(bool value) {
    sidePanelOpen = value;
  }

  void _resetObservedState() {
    loadedPages = 0;
    observedPage = 1;
    observedScale = 1.0;
    lastError = '';
  }
}

Uint8List _buildDemoPdf({
  required String title,
  required List<String> lines,
}) {
  final stream = StringBuffer()
    ..writeln('BT')
    ..writeln('/F1 18 Tf')
    ..writeln('40 780 Td')
    ..writeln('(${_escapePdfText(title)}) Tj')
    ..writeln('ET');

  var y = 748;
  for (final line in lines) {
    stream
      ..writeln('BT')
      ..writeln('/F1 12 Tf')
      ..writeln('40 $y Td')
      ..writeln('(${_escapePdfText(line)}) Tj')
      ..writeln('ET');
    y -= 24;
  }

  final content = stream.toString();
  final contentLength = ascii.encode(content).length;

  final objects = <String>[
    '1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n',
    '2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n',
    '3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>\nendobj\n',
    '4 0 obj\n<< /Length $contentLength >>\nstream\n$content\nendstream\nendobj\n',
    '5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n',
  ];

  final buffer = StringBuffer()..write('%PDF-1.4\n');
  final offsets = <int>[0];
  var currentLength = ascii.encode(buffer.toString()).length;

  for (final object in objects) {
    offsets.add(currentLength);
    buffer.write(object);
    currentLength += ascii.encode(object).length;
  }

  final xrefOffset = currentLength;
  buffer.write('xref\n0 ${objects.length + 1}\n');
  buffer.write('0000000000 65535 f \n');
  for (var index = 1; index < offsets.length; index++) {
    buffer.write('${offsets[index].toString().padLeft(10, '0')} 00000 n \n');
  }
  buffer.write(
    'trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n$xrefOffset\n%%EOF\n',
  );

  return Uint8List.fromList(ascii.encode(buffer.toString()));
}

String _escapePdfText(String value) {
  return value
      .replaceAll('\\', '\\\\')
      .replaceAll('(', '\\(')
      .replaceAll(')', '\\)');
}
