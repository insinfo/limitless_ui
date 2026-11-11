import 'dart:html' as html;

import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'file-upload-page',
  templateUrl: 'file_upload_page.html',
  styleUrls: ['file_upload_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiHighlightComponent,
    LiFileUploadComponent,
    LiFileDropDirective,
    LiFileSelectDirective,
    LiTabsComponent,
    LiTabxDirective,
    LiToggleComponent,
  ],
)
class FileUploadPageComponent {
  FileUploadPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  /// Idioma repassado a todos os `li-file-upload` da página, que trocam os
  /// textos padrão junto com o seletor de idioma do topo.
  String get uploadLocale => _isPt ? 'pt_BR' : 'en_US';

  static const String uploadSnippet = '''
<li-file-upload
    [(ngModel)]="attachments"
    [maxFiles]="5"
    accept="image/*,application/pdf"
    previewMode="limitless"
    [enablePreviewModal]="true"
    [showCaption]="false"
    [locale]="locale"
    browseLabel="Selecionar anexos">
</li-file-upload>''';

  static const String directivesSnippet = '''
<div
    liFileDrop
    (fileOver)="directiveDragOver = \$event"
    (filesChange)="onDirectiveFiles(\$event)">
  <input
      liFileSelect
      type="file"
      multiple
      (filesChange)="onDirectiveFiles(\$event)">
</div>''';

  static const String validationSnippet = '''
<li-file-upload
    [(ngModel)]="attachments"
    [liRules]="[LiRule.required()]"
    [liMessages]="{
      'required': 'Adicione ao menos um anexo.'
    }"
    liValidationMode="submitted"
    accept="image/*,application/pdf">
</li-file-upload>''';

  static const String controlSnippet = '''
<li-file-upload
    [(ngModel)]="files"
    previewMode="limitless"
    [showCaption]="false"
    [showClearButton]="true"
    clearLabel="Remover todos"
    [showUploadIndicator]="false"
    [itemClickAction]="replaceOnClick"
    [confirmAction]="confirmar"
    (beforeRemove)="antesDeRemover(\$event)"
    (beforeAdd)="antesDeAdicionar(\$event)"
    (removed)="registrar(\$event)">
</li-file-upload>''';

  static const String cancelSnippet = '''
// Cancelamento síncrono: preventDefault() antes de qualquer await.
void antesDeRemover(LiFileUploadActionEvent event) {
  if (event.index == 0) {
    event.preventDefault();
  }
}

// Filtro: o que sobrar em event.files é o que entra.
void antesDeAdicionar(LiFileUploadActionEvent event) {
  event.files.removeWhere((file) => file.size > 5 * 1024 * 1024);
}

// Cancelamento assíncrono: o componente espera o Future.
Future<bool> confirmar(LiFileUploadActionEvent event) async {
  if (event.action != LiFileUploadAction.clear) {
    return true;
  }
  final result = await SweetAlert.confirm(
    title: 'Remover todos os arquivos?',
    confirmButtonText: 'Remover',
    cancelButtonText: 'Cancelar',
  );
  return result.isConfirmed;
}''';

  List<html.File> attachments = <html.File>[];
  List<html.File> coverFiles = <html.File>[];
  List<html.File> compactFiles = <html.File>[];
  List<html.File> mediaFiles = <html.File>[];
  List<html.File> previewFiles = <html.File>[];
  List<html.File> limitlessFiles = <html.File>[];

  /// Arquivos do exemplo `[showCaption]="false"`.
  List<html.File> captionlessFiles = <html.File>[];
  List<html.File> directiveFiles = <html.File>[];
  bool directiveDragOver = false;

  // --- Controle total -------------------------------------------------------

  /// Arquivos do cartão "Controle total".
  List<html.File> controlFiles = <html.File>[];

  String controlPreviewMode = 'limitless';
  bool controlShowCaption = true;
  bool controlShowBrowseButton = true;
  bool controlShowClearButton = false;
  bool controlShowDropzoneClearButton = true;
  bool controlShowPreviewButton = true;
  bool controlShowRemoveButton = true;
  bool controlShowFileSize = true;
  bool controlShowFileName = true;
  bool controlShowUploadIndicator = true;
  bool controlDropzoneClickOpensPicker = true;
  LiFileItemClickAction controlItemClickAction = LiFileItemClickAction.dropzone;

  /// Liga o `beforeRemove` que impede remover o primeiro arquivo.
  bool protectFirstFile = true;

  /// Liga o `confirmAction` que pede confirmação antes de limpar.
  bool confirmClear = true;

  /// Liga o `beforeAdd` que deixa entrar só imagens e PDFs.
  bool onlyImagesAndPdf = false;

  /// Eventos recebidos, do mais novo para o mais antigo.
  final List<String> eventLog = <String>[];

  static const List<String> previewModes = <String>[
    'compact',
    'thumbnails',
    'limitless',
  ];

  static const List<LiFileItemClickAction> itemClickActions =
      LiFileItemClickAction.values;

  /// `confirmAction` do cartão, só quando a confirmação de limpar está ligada.
  LiFileUploadConfirmAction? get controlConfirmAction =>
      confirmClear ? _confirmControlAction : null;

  /// Nome do valor do enum, para os botões de escolha.
  String itemClickActionName(LiFileItemClickAction action) => action.name;

  /// Pergunta, por SweetAlert, antes de limpar; as outras ações passam.
  Future<bool> _confirmControlAction(LiFileUploadActionEvent event) async {
    if (event.action != LiFileUploadAction.clear) {
      return true;
    }
    final result = await SweetAlert.confirm(
      title: _isPt ? 'Remover todos os arquivos?' : 'Remove every file?',
      message: _isPt
          ? '${event.files.length} arquivo(s) sairão da fila.'
          : '${event.files.length} file(s) will leave the queue.',
      type: SweetAlertType.warning,
      confirmButtonText: _isPt ? 'Remover' : 'Remove',
      cancelButtonText: _isPt ? 'Cancelar' : 'Cancel',
    );
    _log(result.isConfirmed
        ? (_isPt ? 'confirmAction: limpeza confirmada' : 'confirmAction: clear confirmed')
        : (_isPt ? 'confirmAction: limpeza cancelada' : 'confirmAction: clear cancelled'));
    return result.isConfirmed;
  }

  /// `beforeAdd`: registra e, se o filtro estiver ligado, tira o que não for
  /// imagem nem PDF.
  void onControlBeforeAdd(LiFileUploadActionEvent event) {
    final offered = event.files.length;
    if (onlyImagesAndPdf) {
      event.files.removeWhere((file) =>
          !file.type.startsWith('image/') && file.type != 'application/pdf');
    }
    _log('beforeAdd: $offered → ${event.files.length}');
  }

  /// `beforeRemove`: impede remover o primeiro arquivo quando a proteção está
  /// ligada. O cancelamento é síncrono.
  void onControlBeforeRemove(LiFileUploadActionEvent event) {
    if (protectFirstFile && event.index == 0) {
      event.preventDefault();
      _log(_isPt
          ? 'beforeRemove: ${event.file?.name} protegido, cancelado'
          : 'beforeRemove: ${event.file?.name} is protected, cancelled');
      return;
    }
    _log('beforeRemove: ${event.file?.name}');
  }

  /// Registra os eventos `before*` que só observam.
  void onControlBefore(String name, LiFileUploadActionEvent event) {
    final file = event.file?.name;
    _log(file == null ? name : '$name: $file');
  }

  /// Registra os eventos depois da ação.
  void onControlAfter(String name, LiFileUploadActionEvent event) {
    switch (event.action) {
      case LiFileUploadAction.add:
      case LiFileUploadAction.clear:
        _log('$name: ${_joinFileNames(event.files)}');
        break;
      case LiFileUploadAction.replace:
        _log('$name: ${event.previousFile?.name} → ${event.file?.name}');
        break;
      default:
        _log('$name: ${event.file?.name}');
    }
  }

  void clearEventLog() {
    eventLog.clear();
  }

  void _log(String entry) {
    eventLog.insert(0, entry);
    if (eventLog.length > 14) {
      eventLog.removeLast();
    }
  }

  // --- Textos da página -----------------------------------------------------

  String get pageTitle => 'Extensions';
  String get pageSubtitle => 'File upload';
  String get breadcrumb => 'Uploader';
  String get overviewTitle => _isPt
      ? 'Upload com drag and drop, preview e diretivas utilitárias'
      : 'Drag and drop upload, preview and utility directives';
  String get overviewIntro => _isPt
      ? 'O uploader cobre drag and drop, lista compacta, miniaturas, um modo visual inspirado no fileinput do Limitless com overlay e barra inferior, preview em modal, filtros por tipo, modo desabilitado e diretivas de baixo nível.'
      : 'The uploader covers drag and drop, compact lists, thumbnails, a Limitless-inspired fileinput mode with overlay and footer bar, modal preview, type filters, disabled mode, and low-level directives.';
  String get apiIntro => _isPt
      ? 'A API pode ser usada em alto nível com `li-file-upload` ou em baixo nível com `liFileDrop` e `liFileSelect`.'
      : 'The API can be used at a high level with `li-file-upload` or at a low level with `liFileDrop` and `liFileSelect`.';
  String get mainInputsTitle => _isPt ? 'Pontos principais' : 'Main points';
  String get uploadSnippetTitle =>
      _isPt ? 'Componente principal' : 'Main component';
  String get directivesSnippetTitle =>
      _isPt ? 'Diretivas utilitárias' : 'Utility directives';
  String get validationTitle =>
      _isPt ? 'Validação declarativa' : 'Declarative validation';
  String get controlSnippetTitle =>
      _isPt ? 'Exibição e eventos' : 'Display and events';
  String get cancelSnippetTitle =>
      _isPt ? 'Cancelar e filtrar ações' : 'Cancel and filter actions';

  String get summaryLabel => _isPt ? 'Resumo' : 'Summary';
  String get noteLabel => _isPt ? 'Observação' : 'Note';
  String get receivedLabel => _isPt ? 'Arquivos recebidos' : 'Files received';

  String get compactTitle => _isPt ? 'Lista compacta' : 'Compact file list';
  String get compactHelper => _isPt
      ? 'Use `maxFiles`, `accept`, `showPreview` e `[(ngModel)]` no componente principal.'
      : 'Use `maxFiles`, `accept`, `showPreview` and `[(ngModel)]` on the main component.';
  String get compactBrowse => _isPt ? 'Selecionar anexos' : 'Choose attachments';

  String get limitlessTitle =>
      _isPt ? 'Fila no estilo Limitless' : 'Limitless overlay queue';
  String get limitlessDropTitle => _isPt
      ? 'Fila visual com ações sobrepostas'
      : 'Visual queue with overlaid actions';
  String get limitlessDropSubtitle => _isPt
      ? 'Cada miniatura ganha ações de zoom e remoção e uma barra inferior com metadados.'
      : 'Each thumbnail gets zoom and remove actions and a footer bar with metadata.';
  String get limitlessBrowse =>
      _isPt ? 'Montar fila visual' : 'Build the visual queue';

  String get captionlessTitle =>
      _isPt ? 'Limitless sem legenda' : 'Limitless without caption';
  String get captionlessDropTitle => _isPt
      ? 'Fila visual sem o campo de legenda'
      : 'Visual queue without the caption field';
  String get captionlessDropSubtitle => _isPt
      ? 'Os nomes já aparecem embaixo de cada miniatura; a barra fica só com o botão.'
      : 'The names already show under each thumbnail; the bar keeps only the button.';
  String get captionlessBrowse =>
      _isPt ? 'Selecionar arquivos' : 'Choose files';
  String get captionlessHelper => _isPt
      ? 'Com showCaption desligado, a barra de baixo não repete os nomes num campo somente leitura.'
      : 'With showCaption off, the bottom bar does not repeat the names in a read-only field.';

  String get thumbnailsTitle =>
      _isPt ? 'Miniaturas e modal' : 'Thumbnail preview and modal';
  String get thumbnailsDropTitle => _isPt
      ? 'Solte imagens ou PDFs para visualizar'
      : 'Drop images or PDFs to preview';
  String get thumbnailsDropSubtitle => _isPt
      ? 'Miniaturas aparecem dentro do card e podem ser ampliadas em modal.'
      : 'Thumbnails show inside the card and open larger in a modal.';
  String get thumbnailsBrowse =>
      _isPt ? 'Selecionar arquivos visuais' : 'Choose visual files';

  String get coverTitle => _isPt ? 'Imagem de capa única' : 'Single cover image';
  String get coverDropTitle =>
      _isPt ? 'Solte uma imagem de capa' : 'Drop a cover image';
  String get coverDropSubtitle => _isPt
      ? 'Aceita uma única imagem para a página ou card.'
      : 'Takes a single image for the page or card.';
  String get coverBrowse => _isPt ? 'Selecionar capa' : 'Choose cover';

  String get hiddenPreviewTitle =>
      _isPt ? 'Sem pré-visualização' : 'Hidden preview';
  String get hiddenPreviewDropTitle =>
      _isPt ? 'Seleção rápida sem preview' : 'Quick pick without preview';
  String get hiddenPreviewDropSubtitle => _isPt
      ? 'Ideal para fluxos em que a lista final aparece em outro lugar da tela.'
      : 'For flows where the final list shows elsewhere on the screen.';
  String get hiddenPreviewBrowse =>
      _isPt ? 'Escolher documentos' : 'Choose documents';
  String get hiddenPreviewHelper => _isPt
      ? 'Pré-visualização desligada; o resumo abaixo recebe os nomes selecionados.'
      : 'Preview off; the summary below receives the selected names.';

  String get mediaTitle =>
      _isPt ? 'Tipos de arquivo aceitos' : 'Accepted file types';
  String get mediaDropTitle => _isPt ? 'Imagens e vídeos' : 'Images and videos';
  String get mediaDropSubtitle => _isPt
      ? 'Aceita apenas mídia para prévia de campanha, banner ou card.'
      : 'Takes only media for a campaign, banner or card preview.';
  String get mediaBrowse => _isPt ? 'Selecionar mídia' : 'Choose media';
  String get mediaHelper => _isPt
      ? 'Combina `accept` com `maxFiles` para um fluxo mais controlado.'
      : 'Combines `accept` with `maxFiles` for a tighter flow.';

  String get disabledTitle => _isPt ? 'Estado desabilitado' : 'Disabled state';
  String get disabledDropTitle =>
      _isPt ? 'Uploader desabilitado' : 'Disabled uploader';
  String get disabledDropSubtitle => _isPt
      ? 'Útil quando a permissão do usuário ainda não foi concedida.'
      : 'Useful while the user permission is not granted yet.';
  String get disabledBrowse =>
      _isPt ? 'Aguardando liberação' : 'Waiting for access';
  String get disabledHelper => _isPt
      ? 'O botão e a área de drop ficam indisponíveis sem exigir tratamento extra no host.'
      : 'The button and the drop area are unavailable with no extra handling in the host.';
  String get disabledNote => _isPt
      ? 'Esse card reproduz o estado bloqueado, semelhante aos exemplos de componentes desabilitados do Limitless.'
      : 'This card reproduces the locked state, like the disabled component samples of Limitless.';

  String get directivesTitle =>
      _isPt ? 'Diretivas de baixo nível' : 'Low-level directives';
  String get directivesHint => _isPt
      ? 'Arraste arquivos para esta área ou use o input acima. Esse bloco mostra o uso manual das diretivas sem o wrapper `li-file-upload`.'
      : 'Drag files to this area or use the input above. This block shows the directives used by hand, without the `li-file-upload` wrapper.';

  String get controlTitle => _isPt ? 'Controle total' : 'Full control';
  String get controlIntro => _isPt
      ? 'Ligue e desligue cada parte do uploader ao vivo. O log mostra os eventos antes e depois de cada ação; a remoção do primeiro arquivo é cancelada no beforeRemove e a limpeza pede confirmação pelo confirmAction.'
      : 'Turn each part of the uploader on and off live. The log shows the events before and after each action; removing the first file is cancelled in beforeRemove and clearing asks for confirmation through confirmAction.';
  String get displayGroupLabel => _isPt ? 'Exibição' : 'Display';
  String get behaviorGroupLabel => _isPt ? 'Comportamento' : 'Behavior';
  String get cancelGroupLabel => _isPt ? 'Cancelamento' : 'Cancellation';
  String get previewModeLabel => _isPt ? 'Modo de preview' : 'Preview mode';
  String get itemClickLabel =>
      _isPt ? 'Clique no arquivo (itemClickAction)' : 'File click (itemClickAction)';
  String get protectFirstLabel => _isPt
      ? 'Impedir remover o 1º arquivo (beforeRemove)'
      : 'Block removing the 1st file (beforeRemove)';
  String get confirmClearLabel => _isPt
      ? 'Confirmar antes de limpar (confirmAction)'
      : 'Confirm before clearing (confirmAction)';
  String get onlyImagesLabel => _isPt
      ? 'Aceitar só imagens e PDFs (beforeAdd)'
      : 'Accept only images and PDFs (beforeAdd)';
  String get eventLogLabel => _isPt ? 'Eventos' : 'Events';
  String get emptyLogLabel =>
      _isPt ? 'Nenhum evento ainda.' : 'No events yet.';
  String get clearLogLabel => _isPt ? 'Limpar log' : 'Clear log';
  String get controlDropTitle => _isPt
      ? 'Solte arquivos ou clique para escolher'
      : 'Drop files or click to choose';
  String get controlClearLabel => _isPt ? 'Remover todos' : 'Remove all';

  String get attachmentsSummary => attachments.isEmpty
      ? (_isPt ? 'Nenhum arquivo selecionado.' : 'No file selected.')
      : (_isPt
          ? '${attachments.length} arquivo(s) na fila.'
          : '${attachments.length} file(s) in the queue.');

  String get coverSummary => coverFiles.isEmpty
      ? (_isPt ? 'Capa não definida.' : 'No cover set.')
      : coverFiles.first.name;

  String get compactSummary => compactFiles.isEmpty
      ? (_isPt
          ? 'Nenhum arquivo rápido selecionado.'
          : 'No quick file selected.')
      : _joinFileNames(compactFiles);

  String get mediaSummary => mediaFiles.isEmpty
      ? (_isPt
          ? 'Nenhum item de mídia selecionado.'
          : 'No media item selected.')
      : _joinFileNames(mediaFiles);

  String get previewSummary => previewFiles.isEmpty
      ? (_isPt ? 'Nenhuma miniatura carregada.' : 'No thumbnail loaded.')
      : _joinFileNames(previewFiles);

  String get limitlessSummary => limitlessFiles.isEmpty
      ? (_isPt ? 'Nenhuma fila visual carregada.' : 'No visual queue loaded.')
      : _joinFileNames(limitlessFiles);

  /// Nomes escolhidos no exemplo sem legenda: o que a barra deixou de repetir.
  String get captionlessSummary => captionlessFiles.isEmpty
      ? (_isPt
          ? 'Nenhum arquivo na fila sem legenda.'
          : 'No file in the captionless queue.')
      : _joinFileNames(captionlessFiles);

  String get controlSummary => controlFiles.isEmpty
      ? (_isPt ? 'Nenhum arquivo na fila.' : 'No file in the queue.')
      : _joinFileNames(controlFiles);

  String get directiveSummary => directiveFiles.isEmpty
      ? (_isPt ? 'Nenhum evento recebido ainda.' : 'No event received yet.')
      : _joinFileNames(directiveFiles);

  void onDirectiveFiles(List<html.File> files) {
    directiveFiles = List<html.File>.from(files);
  }

  String _joinFileNames(List<html.File> files) {
    return files.map((file) => file.name).join(', ');
  }
}
