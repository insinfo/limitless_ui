import 'package:ngx_dart/angular.dart';

import 'accordion_item_directive.dart';

/// Accordion body wrapper for declarative accordion markup.
@Directive(
  selector: '[liAccordionBody]',
)
class LiAccordionBodyComponent {
  LiAccordionBodyComponent([@Optional() this.item]);

  final LiAccordionItemDirective? item;

  @HostBinding('class.accordion-body')
  bool hostAccordionBodyClass = true;

  @HostBinding('attr.data-label')
  String get dataLabel => 'li_accordion_body';

  @HostBinding('attr.data-value')
  String get dataValue => item?.id ?? '';
}
