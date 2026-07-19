import 'dart:js_interop';
import 'dart:async';
import 'package:limitless_ui/web_compat.dart' as html;

import 'package:ngx_dart/angular.dart';

@Directive(selector: '[liFileSelect]')
class LiFileSelectDirective implements OnDestroy {
  final StreamController<List<html.File>> _filesChangeController =
      StreamController<List<html.File>>.broadcast();

  @Output()
  Stream<List<html.File>> get filesChange => _filesChangeController.stream;

  @HostListener('change', ['\$event'])
  void onChange(html.Event event) {
    final input = event.target;
    if (!(input?.isA<html.InputElement>() ?? false)) {
      _filesChangeController.add(const <html.File>[]);
      return;
    }

    _filesChangeController.add(
      List<html.File>.from(
          (input as html.InputElement).files?.toList() ?? const <html.File>[]),
    );
  }

  @override
  void ngOnDestroy() {
    _filesChangeController.close();
  }
}
