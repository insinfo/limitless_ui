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
  ],
)
class FileUploadPageComponent {
  FileUploadPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  static const String uploadSnippet = '''
<li-file-upload
    [(ngModel)]="attachments"
    [maxFiles]="5"
    accept="image/*,application/pdf"
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

  List<html.File> attachments = <html.File>[];
  List<html.File> coverFiles = <html.File>[];
  List<html.File> compactFiles = <html.File>[];
  List<html.File> mediaFiles = <html.File>[];
  List<html.File> directiveFiles = <html.File>[];
  bool directiveDragOver = false;

  String get pageTitle => _isPt ? 'Extensions' : 'Extensions';
  String get pageSubtitle => _isPt ? 'File upload' : 'File upload';
  String get breadcrumb => _isPt ? 'Uploader' : 'Uploader';
  String get overviewIntro => _isPt
      ? 'O uploader cobre drag and drop, seleção tradicional, preview opcional, filtros por tipo, modo desabilitado e diretivas de baixo nível.'
      : 'The uploader covers drag and drop, traditional selection, optional preview, type filters, disabled mode, and low-level directives.';
  String get apiIntro => _isPt
      ? 'A API pode ser usada em alto nível com `li-file-upload` ou em baixo nível com `liFileDrop` e `liFileSelect`.'
      : 'The API can be used at a high level with `li-file-upload` or at a low level with `liFileDrop` and `liFileSelect`.';
  String get mainInputsTitle => _isPt ? 'Pontos principais' : 'Main points';
  String get uploadSnippetTitle => _isPt ? 'Componente principal' : 'Main component';
  String get directivesSnippetTitle => _isPt ? 'Diretivas utilitárias' : 'Utility directives';

  String get attachmentsSummary => attachments.isEmpty
      ? 'Nenhum arquivo selecionado.'
      : '${attachments.length} arquivo(s) na fila.';

  String get coverSummary =>
      coverFiles.isEmpty ? 'Capa não definida.' : coverFiles.first.name;

  String get compactSummary => compactFiles.isEmpty
      ? 'Nenhum arquivo rápido selecionado.'
      : _joinFileNames(compactFiles);

  String get mediaSummary => mediaFiles.isEmpty
      ? 'Nenhum item de mídia selecionado.'
      : _joinFileNames(mediaFiles);

  String get directiveSummary => directiveFiles.isEmpty
      ? 'Nenhum evento recebido ainda.'
      : _joinFileNames(directiveFiles);

  void onDirectiveFiles(List<html.File> files) {
    directiveFiles = List<html.File>.from(files);
  }

  String _joinFileNames(List<html.File> files) {
    return files.map((file) => file.name).join(', ');
  }
}
