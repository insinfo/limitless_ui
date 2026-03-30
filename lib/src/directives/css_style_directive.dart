import 'dart:html' show Element;

import 'package:ngdart/angular.dart';

/// Applies a CSS style string directly via the CSSOM (`element.style.cssText`)
/// instead of the DOM attribute (`element.setAttribute('style', ...)`).
///
/// This avoids the AngularDart attribute sanitizer that runs on every change
/// detection cycle when using `[attr.style]`, which can cause severe layout
/// thrashing with complex CSS values.
///
/// Usage:
/// ```html
/// <td [cssStyle]="column.styleCss">
/// <tr [cssStyle]="row.styleCss">
/// ```
@Directive(selector: '[cssStyle]')
class CssStyleDirective {
  final Element _element;
  String _lastCss = '';

  CssStyleDirective(this._element);

  @Input('cssStyle')
  set cssStyle(String? value) {
    final css = value ?? '';
    if (_lastCss != css) {
      _lastCss = css;
      _element.style.cssText = css;
    }
  }
}
