import 'dart:html' show Element, NodeTreeSanitizer;

import 'package:ngdart/angular.dart';

/// Writes trusted HTML into the host element.
@Directive(selector: '[liSafeInnerHtml]')
class LiSafeInnerHtmlDirective {
  final Element _element;

  LiSafeInnerHtmlDirective(this._element);

  @Input()
  set liSafeInnerHtml(String? html) {
    // ignore: unsafe_html
    _element.setInnerHtml(html, treeSanitizer: NodeTreeSanitizer.trusted);
  }
}
