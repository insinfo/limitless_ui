import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

import 'accordion_item_directive.dart';

/// Standard Bootstrap accordion button directive.
@Directive(selector: 'button[liAccordionButton]')
class LiAccordionButtonDirective {
  LiAccordionButtonDirective(this.item);

  final LiAccordionItemDirective item;

  @HostBinding('class.accordion-button')
  bool hostAccordionButtonClass = true;

  @HostBinding('class.fw-semibold')
  bool hostSemiboldClass = true;

  @HostBinding('class.collapsed')
  bool get collapsedClass => item.collapsed;

  @HostBinding('attr.type')
  String type = 'button';

  @HostBinding('attr.id')
  String get id => item.toggleId;

  @HostBinding('attr.aria-controls')
  String get ariaControls => item.collapseId;

  @HostBinding('attr.aria-expanded')
  String get ariaExpanded => (!item.collapsed).toString();

  @HostBinding('attr.disabled')
  String? get disabledAttribute => item.disabled ? '' : null;

  @HostBinding('attr.data-label')
  String get dataLabel => 'li_accordion_button';

  @HostBinding('attr.data-value')
  String get dataValue => item.id;

  @HostBinding('attr.data-open')
  String get dataOpen => item.collapsed ? 'false' : 'true';

  @HostBinding('attr.data-disabled')
  String get dataDisabled => item.disabled ? 'true' : 'false';

  @HostListener('click', ['\$event'])
  void onClick(web.Event event) {
    if (item.disabled) {
      event.preventDefault();
      return;
    }

    item.toggle();
  }
}
