import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

/// Applies a CSS style string directly via the CSSOM (`element.style.cssText`)
/// instead of the DOM attribute (`element.setAttribute('style', ...)`).
///
/// This avoids the AngularDart attribute sanitizer that runs on every change
/// detection cycle when using `[attr.style]`, which can cause severe layout
/// thrashing with complex CSS values.
///
/// Usage:
/// ```html
/// <td [liCssStyle]="column.styleCss">
/// <tr [liCssStyle]="row.styleCss">
/// ```
@Directive(selector: '[liCssStyle]')
class LiCssStyleDirective {
  final web.Element _element;
  String _lastCss = '';

  LiCssStyleDirective(this._element);

  @Input('liCssStyle')
  set liCssStyle(String? value) {
    final css = value ?? '';
    if (_lastCss != css) {
      _lastCss = css;
      (_element as web.HTMLElement).style.cssText = css;
    }
  }
}
