import 'package:ngx_dart/angular.dart';

import 'accordion_item_directive.dart';

/// Declarative accordion header wrapper.
@Directive(selector: '[liAccordionHeader]')
class LiAccordionHeaderHostDirective {
  LiAccordionHeaderHostDirective([@Optional() this.item]);

  final LiAccordionItemDirective? item;

  @HostBinding('class.accordion-header')
  bool hostAccordionHeaderClass = true;

  @HostBinding('attr.role')
  String role = 'heading';

  @HostBinding('attr.data-label')
  String get dataLabel => 'li_accordion_header';

  @HostBinding('attr.data-value')
  String get dataValue => item?.id ?? '';

  @HostBinding('attr.data-open')
  String get dataOpen => item == null || item!.collapsed ? 'false' : 'true';
}
