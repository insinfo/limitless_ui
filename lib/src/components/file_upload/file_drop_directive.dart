import 'dart:async';
import 'dart:js_interop';
import 'package:limitless_ui/web_compat.dart' as html;

import 'package:ngx_dart/angular.dart';

@Directive(selector: 'li-file-drop,[liFileDrop]')
class LiFileDropDirective implements OnDestroy {
  final StreamController<bool> _fileOverController =
      StreamController<bool>.broadcast();
  final StreamController<List<html.File>> _filesChangeController =
      StreamController<List<html.File>>.broadcast();

  @Output()
  Stream<bool> get fileOver => _fileOverController.stream;

  @Output()
  Stream<List<html.File>> get filesChange => _filesChangeController.stream;

  @HostListener('drop', ['\$event'])
  void onDrop(html.MouseEvent event) {
    _preventAndStop(event);
    final transfer = (event as html.DragEvent).dataTransfer;
    final files = transfer?.files.toList() ?? const <html.File>[];
    _fileOverController.add(false);
    _filesChangeController.add(
      List<html.File>.from(files),
    );
  }

  @HostListener('dragover', ['\$event'])
  void onDragOver(html.MouseEvent event) {
    _preventAndStop(event);
    final transfer = (event as html.DragEvent).dataTransfer;
    if (transfer == null) {
      return;
    }
    final types = transfer.types.toDart;
    if (!types.any((type) => type.toDart == 'Files')) {
      return;
    }
    transfer.dropEffect = 'copy';
    _fileOverController.add(true);
  }

  @HostListener('dragleave', ['\$event'])
  void onDragLeave(html.Event event) {
    _preventAndStop(event);
    _fileOverController.add(false);
  }

  void _preventAndStop(html.Event event) {
    event
      ..preventDefault()
      ..stopPropagation();
  }

  @override
  void ngOnDestroy() {
    _fileOverController.close();
    _filesChangeController.close();
  }
}
