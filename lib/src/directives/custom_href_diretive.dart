import 'dart:html';

import 'package:ngdart/angular.dart';

/// Mirrors a custom href value onto the host element.
///
/// This is useful when the template wants to bind a destination through a
/// directive while still allowing the host element to control navigation.
@Directive(
  selector: '[customHref]',
)
class CustomHrefDirective implements AfterChanges {
  @Input()
  String? customHref;

  final Element _element;
  CustomHrefDirective(this._element) {
    init();
  }

  @HostListener('click', ['\$event'])
  /// Reserved click hook for future custom navigation behavior.
  void onClick(MouseEvent event) {
  }

  /// Synchronizes the host `href` attribute with [customHref].
  void init() {
    if (customHref != null && customHref!.isNotEmpty) {
      if (customHref != '#') {
        _element.setAttribute('href', customHref!);
      }
    }
  }

  @override
  /// Reapplies the current href whenever AngularDart updates the input.
  void ngAfterChanges() {
    init();
  }
}
