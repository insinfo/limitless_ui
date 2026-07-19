import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

import '../collapse/collapse_directive.dart';
import 'accordion_item_directive.dart';

/// Accordion collapse region powered by [LiCollapseController].
@Directive(
  selector: '[liAccordionCollapse]',
  exportAs: 'liAccordionCollapse',
)
class LiAccordionCollapseDirective implements OnInit, OnDestroy {
  LiAccordionCollapseDirective(web.HTMLElement element, this.item)
      : _controller = LiCollapseController(element);

  final LiAccordionItemDirective item;
  final LiCollapseController _controller;

  @HostBinding('class.accordion-collapse')
  bool hostAccordionCollapseClass = true;

  @HostBinding('attr.role')
  String role = 'region';

  @HostBinding('attr.id')
  String get id => item.collapseId;

  @HostBinding('attr.aria-labelledby')
  String get ariaLabelledBy => item.toggleId;

  @HostBinding('attr.data-label')
  String get dataLabel => 'li_accordion_panel';

  @HostBinding('attr.data-value')
  String get dataValue => item.id;

  @HostBinding('attr.data-open')
  String get dataOpen => item.collapsed ? 'false' : 'true';

  Stream<void> get shown => _controller.shown;

  Stream<void> get hidden => _controller.hidden;

  bool get collapsed => _controller.collapsed;

  @override
  void ngOnInit() {
    _controller.initialize(
      collapsed: item.collapsed,
      animation: item.animation,
      horizontal: false,
    );
  }

  void updateOptions({required bool animation}) {
    _controller.updateOptions(animation: animation, horizontal: false);
  }

  void setCollapsed(bool value) {
    _controller.setCollapsed(value);
  }

  @override
  void ngOnDestroy() {
    _controller.ngOnDestroy();
  }
}
