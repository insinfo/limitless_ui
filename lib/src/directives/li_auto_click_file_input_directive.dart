import 'dart:async';
import 'dart:html' as html;

import 'package:ngx_dart/angular.dart';

/// Opens a file picker when [liAutoClickFileInput] changes from `false` to
/// `true`.
@Directive(selector: 'input[type=file][liAutoClickFileInput]')
class LiAutoClickFileInputDirective implements AfterChanges, OnDestroy {
  LiAutoClickFileInputDirective(html.Element hostElement) {
    if (hostElement is! html.FileUploadInputElement) {
      throw StateError(
        'LiAutoClickFileInputDirective must be used on <input type="file">.',
      );
    }

    _input = hostElement;
    _changeSubscription = _input.onChange.listen((_) {
      _filesSelectedController.add(
        List<html.File>.unmodifiable(_input.files ?? const <html.File>[]),
      );
    });
  }

  late final html.FileUploadInputElement _input;
  StreamSubscription<html.Event>? _changeSubscription;
  bool _previousTrigger = false;

  final _filesSelectedController =
      StreamController<List<html.File>>.broadcast(sync: true);

  /// When set to `true`, opens the native file picker once.
  @Input('liAutoClickFileInput')
  bool liAutoClickFileInput = false;

  /// Emits the selected files after the native input changes.
  @Output('liFilesSelected')
  Stream<List<html.File>> get liFilesSelected =>
      _filesSelectedController.stream;

  @override
  void ngAfterChanges() {
    if (liAutoClickFileInput && !_previousTrigger) {
      scheduleMicrotask(_input.click);
    }
    _previousTrigger = liAutoClickFileInput;
  }

  @override
  void ngOnDestroy() {
    _changeSubscription?.cancel();
    _filesSelectedController.close();
  }
}
