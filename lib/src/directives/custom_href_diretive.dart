import 'dart:html';

import 'package:ngx_dart/angular.dart';

/// Mirrors a custom href value onto the host element.
///
/// This is useful when the template wants to bind a destination through a
/// directive while still allowing the host element to control navigation.
@Directive(
  selector: '[liCustomHref]',
)
class LiCustomHrefDirective implements AfterChanges {
  @Input()
  String? liCustomHref;

  final Element _element;
  LiCustomHrefDirective(this._element) {
    init();
  }

  @HostListener('click', ['\$event'])

  /// Reserved click hook for future custom navigation behavior.
  void onClick(MouseEvent event) {}

  /// Synchronizes the host `href` attribute with [liCustomHref].
  void init() {
    if (liCustomHref != null && liCustomHref!.isNotEmpty) {
      if (liCustomHref != '#') {
        _element.setAttribute('href', liCustomHref!);
      }
    }
  }

  @override

  /// Reapplies the current href whenever AngularDart updates the input.
  void ngAfterChanges() {
    init();
  }
}
