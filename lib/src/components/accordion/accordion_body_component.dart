import 'package:ngdart/angular.dart';

/// Accordion body wrapper for declarative accordion markup.
@Directive(
  selector: '[liAccordionBody]',
)
class LiAccordionBodyComponent {
  @HostBinding('class.accordion-body')
  bool hostAccordionBodyClass = true;
}
