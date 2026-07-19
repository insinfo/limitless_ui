import 'dart:js_interop';
import 'dart:async';
import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

List<web.File> _filesFromList(web.FileList files) => <web.File>[
      for (var index = 0; index < files.length; index++) files.item(index)!,
    ];

@Directive(selector: '[liFileSelect]')
class LiFileSelectDirective implements OnDestroy {
  final StreamController<List<web.File>> _filesChangeController =
      StreamController<List<web.File>>.broadcast();

  @Output()
  Stream<List<web.File>> get filesChange => _filesChangeController.stream;

  @HostListener('change', ['\$event'])
  void onChange(web.Event event) {
    final input = event.target;
    if (!(input?.isA<web.HTMLInputElement>() ?? false)) {
      _filesChangeController.add(const <web.File>[]);
      return;
    }

    final files = (input as web.HTMLInputElement).files;
    _filesChangeController.add(
      files == null ? const <web.File>[] : _filesFromList(files),
    );
  }

  @override
  void ngOnDestroy() {
    _filesChangeController.close();
  }
}
