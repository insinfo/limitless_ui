import 'package:ngdart/angular.dart';

/// Creates a lazily rendered accordion body template.
@Directive(selector: 'template[li-accordion-body]')
class LiAccordionBodyDirective {
  LiAccordionBodyDirective(this.templateRef);

  final TemplateRef templateRef;
}
