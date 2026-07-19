import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

import '../web_support/html_sinks.dart';

/// Writes trusted HTML into the host element.
@Directive(selector: '[liSafeInnerHtml]')
class LiSafeInnerHtmlDirective {
  final web.Element _element;

  LiSafeInnerHtmlDirective(this._element);

  @Input()
  set liSafeInnerHtml(String? html) {
    setTrustedHtml(_element, html ?? '');
  }
}
