import 'dart:html' as html;

import 'package:ngdart/angular.dart';

import 'scrollspy_directive.dart';

@Directive(
  selector: '[liScrollSpyFragment]',
)
class LiScrollSpyFragmentDirective implements OnInit, OnDestroy {
  LiScrollSpyFragmentDirective(this._element, this._scrollSpy);

  final html.Element _element;
  final LiScrollSpyDirective _scrollSpy;

  String _id = '';

  @Input('liScrollSpyFragment')
  set fragmentId(String? value) {
    _id = value?.trim() ?? '';
    if (_id.isNotEmpty) {
      _element.id = _id;
    }
  }

  String get id => _id;

  @override
  void ngOnInit() {
    if (_id.isNotEmpty) {
      _scrollSpy.registerFragment(this);
    }
  }

  @override
  void ngOnDestroy() {
    if (_id.isNotEmpty) {
      _scrollSpy.unregisterFragment(this);
    }
  }
}
