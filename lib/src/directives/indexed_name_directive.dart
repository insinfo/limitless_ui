import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

@Directive(selector: '[liIndexedName]')
class LiIndexedNameDirective {
  final web.Element _element;

  LiIndexedNameDirective(this._element);

  String? _baseName;
  int? _index;

  @Input('liIndexedName')
  set baseName(String? value) {
    _baseName = value;
    _updateName();
  }

  @Input()
  set liIndexedNameIndex(int? value) {
    _index = value;
    _updateName();
  }

  void _updateName() {
    final baseName = _baseName;
    final index = _index;

    if (baseName == null || baseName.isEmpty || index == null) {
      _element.removeAttribute('name');
      return;
    }

    _element.setAttribute('name', '$baseName$index');
  }
}
