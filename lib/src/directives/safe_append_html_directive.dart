import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

/// Appends a trusted DOM node to the host element.
@Directive(selector: '[liSafeAppendHtml]')
class LiSafeAppendHtmlDirective {
  final web.Element _element;

  LiSafeAppendHtmlDirective(this._element);

  @Input()
  set liSafeAppendHtml(web.Node? htmlElement) {
    if (htmlElement != null) {
      _element.appendChild(htmlElement);
    }
  }
}
