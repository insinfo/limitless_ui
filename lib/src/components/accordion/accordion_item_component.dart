import 'dart:async';

import 'package:ngdart/angular.dart';

import 'accordion_body_directive.dart';
import 'accordion_component.dart';
import 'accordion_header_directive.dart';

/// Limitless/Bootstrap accordion item with optional lazy body rendering.
@Component(
  selector: 'li-accordion-item',
  templateUrl: 'accordion_item_component.html',
  styleUrls: ['accordion_item_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiAccordionItemComponent implements AfterContentInit, OnDestroy {
  LiAccordionItemComponent(this._changeDetectorRef) {
    final sequence = _nextSequence++;
    headerId = 'li-accordion-header-$sequence';
    contentId = 'li-accordion-content-$sequence';
  }

  static int _nextSequence = 0;

  final ChangeDetectorRef _changeDetectorRef;
  final StreamController<bool> _expandedChangeController =
      StreamController<bool>.broadcast();

  LiAccordionComponent? parent;

  @ContentChild(LiAccordionHeaderDirective)
  LiAccordionHeaderDirective? headerTemplate;

  @ContentChild(LiAccordionBodyDirective)
  LiAccordionBodyDirective? bodyTemplate;

  @Input()
  String header = '';

  @Input()
  String? description;

  @Input()
  String? iconClass;

  @Input()
  bool disabled = false;

  @Input()
  bool? lazy;

  @Input()
  bool? destroyOnCollapse;

  @Input()
  set expanded(bool value) {
    _expanded = value;
    if (_expanded) {
      _hasOpenedOnce = true;
    }
  }

  bool get expanded => _expanded;

  @Output('expandedChange')
  Stream<bool> get expandedChange => _expandedChangeController.stream;

  @HostBinding('class.accordion-item')
  bool hostAccordionItemClass = true;

  late final String headerId;
  late final String contentId;

  bool _expanded = false;
  bool _hasOpenedOnce = false;
  bool _contentInitialized = false;

  bool get isExpanded => _expanded;

  bool get hasDescription => description != null && description!.trim().isNotEmpty;

  bool get hasIcon => iconClass != null && iconClass!.trim().isNotEmpty;

  String get resolvedIconClass => iconClass ?? '';

  bool get shouldRenderBody {
    if (!resolvedLazy) {
      return true;
    }

    if (_expanded) {
      return true;
    }

    if (!resolvedDestroyOnCollapse && _hasOpenedOnce) {
      return true;
    }

    return false;
  }

  bool get resolvedLazy => lazy ?? parent?.lazy ?? false;

  bool get resolvedDestroyOnCollapse =>
      destroyOnCollapse ?? parent?.destroyOnCollapse ?? false;

  bool get hasLazyBodyTemplate => bodyTemplate != null;

  bool get shouldRenderLazyTemplate =>
      _contentInitialized && hasLazyBodyTemplate && shouldRenderBody;

  bool get shouldRenderProjectedBody {
    if (!_contentInitialized) {
      return !resolvedLazy;
    }

    return !hasLazyBodyTemplate && shouldRenderBody;
  }

  @override
  void ngAfterContentInit() {
    _contentInitialized = true;
    _changeDetectorRef.markForCheck();
  }

  void syncInitialState() {
    if (_expanded) {
      _hasOpenedOnce = true;
    }
  }

  void toggle() {
    if (disabled) {
      return;
    }

    if (parent != null) {
      parent!.toggleItem(this);
      return;
    }

    setExpanded(!_expanded);
  }

  void setExpanded(bool value) {
    if (_expanded == value) {
      return;
    }

    _expanded = value;
    if (_expanded) {
      _hasOpenedOnce = true;
    }

    _expandedChangeController.add(_expanded);
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngOnDestroy() {
    _expandedChangeController.close();
  }

  String get buttonClassName {
    final classes = <String>['accordion-button', 'fw-semibold'];
    if (!_expanded) {
      classes.add('collapsed');
    }
    if (disabled) {
      classes.add('disabled');
    }
    return classes.join(' ');
  }
}
