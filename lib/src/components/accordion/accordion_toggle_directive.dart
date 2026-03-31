import 'dart:html' as html;

import 'package:ngdart/angular.dart';

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

  @HostListener('click', ['\$event'])
  void onClick(html.Event event) {
    if (item.disabled) {
      event.preventDefault();
      return;
    }

    item.toggle();
  }
}