import 'package:ngdart/angular.dart';

/// Declarative accordion header wrapper.
@Directive(selector: '[liAccordionHeader]')
class LiAccordionHeaderHostDirective {
  @HostBinding('class.accordion-header')
  bool hostAccordionHeaderClass = true;

  @HostBinding('attr.role')
  String role = 'heading';
}