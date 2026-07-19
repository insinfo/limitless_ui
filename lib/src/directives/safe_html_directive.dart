import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

import '../web_support/html_sinks.dart';

/// Unified directive that renders trusted HTML text and/or appends a trusted
/// DOM [web.Node] into the host element in a single pass, avoiding the
/// double-render / layout-thrashing caused by separate [liSafeInnerHtml] +
/// [liSafeAppendHtml] directives fighting over the same element.
///
/// Usage:
/// ```html
/// <td [liSafeHtml]="column.value" [liSafeHtmlNode]="column.htmlElement"></td>
/// ```
///
/// Priority: if [liSafeHtmlNode] is non-null it wins (the element is cleared and
/// the node is appended).  Otherwise, [liSafeHtml] is written via
/// `setInnerHtml`.  When both are null/empty the element is cleared.
@Directive(selector: '[liSafeHtml],[liSafeHtmlNode]')
class LiSafeHtmlDirective {
  final web.Element _element;

  String? _html;
  web.Node? _node;
  bool _dirty = false;

  LiSafeHtmlDirective(this._element);

  @Input('liSafeHtml')
  set liSafeHtml(String? html) {
    if (_html == html) {
      return;
    }
    _html = html;
    _dirty = true;
    _rebuild();
  }

  @Input('liSafeHtmlNode')
  set liSafeHtmlNode(web.Node? node) {
    if (_node == node) {
      return;
    }
    _node = node;
    _dirty = true;
    _rebuild();
  }

  void _rebuild() {
    if (!_dirty) {
      return;
    }
    _dirty = false;

    if (_node != null) {
      _element.textContent = '';
      _element.appendChild(_node!);
    } else if (_html != null && _html!.isNotEmpty) {
      setTrustedHtml(_element, _html!);
    } else {
      _element.textContent = '';
    }
  }
}
