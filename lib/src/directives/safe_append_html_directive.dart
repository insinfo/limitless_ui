import 'package:limitless_ui/web_compat.dart';

import 'package:ngx_dart/angular.dart';

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
