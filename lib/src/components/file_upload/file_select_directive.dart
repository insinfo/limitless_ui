import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

@Directive(selector: '[liFileSelect]')
class LiFileSelectDirective implements OnDestroy {
  final StreamController<List<html.File>> _filesChangeController =
      StreamController<List<html.File>>.broadcast();

  @Output()
  Stream<List<html.File>> get filesChange => _filesChangeController.stream;

  @HostListener('change', ['\$event'])
  void onChange(html.Event event) {
    final input = event.target;
    if (input is! html.InputElement) {
      _filesChangeController.add(const <html.File>[]);
      return;
    }

    _filesChangeController.add(
      List<html.File>.from(input.files ?? const <html.File>[]),
    );
  }

  @override
  void ngOnDestroy() {
    _filesChangeController.close();
  }
}
