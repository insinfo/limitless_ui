import 'dart:html' show Element, Node, NodeTreeSanitizer;

import 'package:ngdart/angular.dart';

/// Unified directive that renders trusted HTML text and/or appends a trusted
/// DOM [Node] into the host element in a single pass, avoiding the
/// double-render / layout-thrashing caused by separate [safeInnerHtml] +
/// [safeAppendHtml] directives fighting over the same element.
///
/// Usage:
/// ```html
/// <td [safeHtml]="column.value" [safeHtmlNode]="column.htmlElement"></td>
/// ```
///
/// Priority: if [safeHtmlNode] is non-null it wins (the element is cleared and
/// the node is appended).  Otherwise, [safeHtml] is written via
/// `setInnerHtml`.  When both are null/empty the element is cleared.
@Directive(selector: '[safeHtml],[safeHtmlNode]')
class SafeHtmlDirective {
  final Element _element;

  String? _html;
  Node? _node;
  bool _dirty = false;

  SafeHtmlDirective(this._element);

  @Input('safeHtml')
  set safeHtml(String? html) {
    if (_html == html) {
      return;
    }
    _html = html;
    _dirty = true;
    _rebuild();
  }

  @Input('safeHtmlNode')
  set safeHtmlNode(Node? node) {
    if (identical(_node, node)) {
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
      _element.nodes.clear();
      _element.append(_node!);
    } else if (_html != null && _html!.isNotEmpty) {
      // ignore: unsafe_html
      _element.setInnerHtml(_html, treeSanitizer: NodeTreeSanitizer.trusted);
    } else {
      _element.nodes.clear();
    }
  }
}
