import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

List<web.File> _filesFromList(web.FileList files) => <web.File>[
      for (var index = 0; index < files.length; index++) files.item(index)!,
    ];

@Directive(selector: 'li-file-drop,[liFileDrop]')
class LiFileDropDirective implements OnDestroy {
  final StreamController<bool> _fileOverController =
      StreamController<bool>.broadcast();
  final StreamController<List<web.File>> _filesChangeController =
      StreamController<List<web.File>>.broadcast();

  @Output()
  Stream<bool> get fileOver => _fileOverController.stream;

  @Output()
  Stream<List<web.File>> get filesChange => _filesChangeController.stream;

  @HostListener('drop', ['\$event'])
  void onDrop(web.MouseEvent event) {
    _preventAndStop(event);
    final transfer = (event as web.DragEvent).dataTransfer;
    final files =
        transfer == null ? const <web.File>[] : _filesFromList(transfer.files);
    _fileOverController.add(false);
    _filesChangeController.add(
      List<web.File>.from(files),
    );
  }

  @HostListener('dragover', ['\$event'])
  void onDragOver(web.MouseEvent event) {
    _preventAndStop(event);
    final transfer = (event as web.DragEvent).dataTransfer;
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
  void onDragLeave(web.Event event) {
    _preventAndStop(event);
    _fileOverController.add(false);
  }

  void _preventAndStop(web.Event event) {
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
