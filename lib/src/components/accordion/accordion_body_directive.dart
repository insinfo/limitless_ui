import 'package:ngx_dart/angular.dart';

/// Creates a lazily rendered accordion body template.
@Directive(selector: 'template[li-accordion-body]')
class LiAccordionBodyDirective {
  LiAccordionBodyDirective(this.templateRef);

  final TemplateRef templateRef;
}
