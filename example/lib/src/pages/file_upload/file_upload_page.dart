import 'dart:html' as html;

import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'file-upload-page',
  templateUrl: 'file_upload_page.html',
  styleUrls: ['file_upload_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiFileUploadComponent,
    LiFileDropDirective,
    LiFileSelectDirective,
  ],
)
class FileUploadPageComponent {
  List<html.File> attachments = <html.File>[];
  List<html.File> coverFiles = <html.File>[];
  List<html.File> compactFiles = <html.File>[];
  List<html.File> mediaFiles = <html.File>[];
  List<html.File> directiveFiles = <html.File>[];
  bool directiveDragOver = false;

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
