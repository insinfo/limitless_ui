import 'dart:html';

import 'package:ngdart/angular.dart';

/// Appends a trusted DOM node to the host element.
@Directive(selector: '[liSafeAppendHtml]')
class LiSafeAppendHtmlDirective {
  final Element _element;

  LiSafeAppendHtmlDirective(this._element);

  @Input()
  set liSafeAppendHtml(Node? htmlElement) {
    if (htmlElement != null) {
      _element.append(htmlElement);
    }
  }
}
