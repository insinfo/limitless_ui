import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

/// Opens a file picker when [liAutoClickFileInput] changes from `false` to
/// `true`.
@Directive(selector: 'input[type=file][liAutoClickFileInput]')
class LiAutoClickFileInputDirective implements AfterChanges, OnDestroy {
  LiAutoClickFileInputDirective(web.Element hostElement) {
    if (!hostElement.isA<web.HTMLInputElement>()) {
      throw StateError(
        'LiAutoClickFileInputDirective must be used on <input type="file">.',
      );
    }

    final input = hostElement as web.HTMLInputElement;
    if (input.type.toLowerCase() != 'file') {
      throw StateError(
        'LiAutoClickFileInputDirective must be used on <input type="file">.',
      );
    }

    _input = input;
    _changeSubscription = _input.onChange.listen((_) {
      final files = _input.files;
      _filesSelectedController.add(
        List<web.File>.unmodifiable(
          files == null
              ? const <web.File>[]
              : <web.File>[
                  for (var index = 0; index < files.length; index++)
                    files.item(index)!,
                ],
        ),
      );
    });
  }

  late final web.HTMLInputElement _input;
  StreamSubscription<web.Event>? _changeSubscription;
  bool _previousTrigger = false;

  final _filesSelectedController =
      StreamController<List<web.File>>.broadcast(sync: true);

  /// When set to `true`, opens the native file picker once.
  @Input('liAutoClickFileInput')
  bool liAutoClickFileInput = false;

  /// Emits the selected files after the native input changes.
  @Output('liFilesSelected')
  Stream<List<web.File>> get liFilesSelected => _filesSelectedController.stream;

  @override
  void ngAfterChanges() {
    if (liAutoClickFileInput && !_previousTrigger) {
      scheduleMicrotask(() => _input.click());
    }
    _previousTrigger = liAutoClickFileInput;
  }

  @override
  void ngOnDestroy() {
    _changeSubscription?.cancel();
    _filesSelectedController.close();
  }
}
