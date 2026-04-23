import 'package:ngdart/angular.dart';

/// Creates a custom header template for [LiAccordionItemComponent].
@Directive(selector: 'template[li-accordion-header]')
class LiAccordionHeaderDirective {
  LiAccordionHeaderDirective(this.templateRef);

  final TemplateRef templateRef;
}
