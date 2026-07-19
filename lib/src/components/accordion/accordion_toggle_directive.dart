import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

import 'accordion_item_directive.dart';

/// Custom toggle directive for declarative accordion headers.
@Directive(selector: '[liAccordionToggle]')
class LiAccordionToggleDirective {
  LiAccordionToggleDirective(this.item);

  final LiAccordionItemDirective item;

  @HostBinding('attr.id')
  String get id => item.toggleId;

  @HostBinding('class.collapsed')
  bool get collapsedClass => item.collapsed;

  @HostBinding('attr.aria-controls')
  String get ariaControls => item.collapseId;

  @HostBinding('attr.aria-expanded')
  String get ariaExpanded => (!item.collapsed).toString();

  @HostBinding('attr.data-label')
  String get dataLabel => 'li_accordion_toggle';

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
