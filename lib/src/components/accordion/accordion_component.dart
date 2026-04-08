import 'package:ngdart/angular.dart';

import 'accordion_body_component.dart';
import 'accordion_body_directive.dart';
import 'accordion_button_directive.dart';
import 'accordion_collapse_directive.dart';
import 'accordion_directive.dart';
import 'accordion_header_host_directive.dart';
import 'accordion_item_component.dart';
import 'accordion_item_directive.dart';
import 'accordion_toggle_directive.dart';

/// Public directives used by the accordion component suite.
const liAccordionDirectives = <Object>[
  LiAccordionComponent,
  LiAccordionDirective,
  LiAccordionBodyComponent,
  LiAccordionBodyDirective,
  LiAccordionButtonDirective,
  LiAccordionCollapseDirective,
  LiAccordionHeaderHostDirective,
  LiAccordionItemComponent,
  LiAccordionItemDirective,
  LiAccordionToggleDirective,
];

/// Limitless/Bootstrap accordion container.
@Component(
  selector: 'li-accordion',
  templateUrl: 'accordion_component.html',
  styleUrls: ['accordion_component.css'],
  directives: [coreDirectives, LiAccordionItemComponent],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiAccordionComponent implements AfterContentInit {
  @ContentChildren(LiAccordionItemComponent)
  List<LiAccordionItemComponent> items = <LiAccordionItemComponent>[];

  /// Allows multiple items to stay open simultaneously.
  @Input()
  bool allowMultipleOpen = false;

  /// Applies the Limitless/Bootstrap flush style.
  @Input()
  bool flush = false;

  /// Defers body rendering until the item is opened for the first time.
  @Input()
  bool lazy = false;

  /// If `true`, removes the body from the DOM whenever the item closes.
  @Input()
  bool destroyOnCollapse = false;

  /// Applies the default padding to each accordion body.
  @Input()
  bool bodyPadding = true;

  /// Extra CSS classes applied to each accordion item button.
  @Input()
  String buttonClass = '';

  /// Applies the semibold utility class to item buttons.
  @Input()
  bool buttonSemibold = true;

  @HostBinding('class.accordion')
  bool hostAccordionClass = true;

  @HostBinding('class.accordion-flush')
  bool get hostFlushClass => flush;

  @HostBinding('class.open')
  bool get hostOpenClass => items.any((item) => item.isExpanded);

  @override
  void ngAfterContentInit() {
    for (final item in items) {
      item.parent = this;
      item.syncInitialState();
    }

    _normalizeExpandedState();
  }

  void toggleItem(LiAccordionItemComponent item) {
    if (item.disabled) {
      return;
    }

    if (allowMultipleOpen) {
      item.setExpanded(!item.isExpanded);
      return;
    }

    if (item.isExpanded) {
      item.setExpanded(false);
      return;
    }

    for (final currentItem in items) {
      currentItem.setExpanded(identical(currentItem, item));
    }
  }

  void _normalizeExpandedState() {
    if (allowMultipleOpen) {
      return;
    }

    LiAccordionItemComponent? expandedItem;
    for (final item in items) {
      if (!item.isExpanded) {
        continue;
      }

      expandedItem ??= item;
      if (!identical(expandedItem, item)) {
        item.setExpanded(false);
      }
    }
  }
}
