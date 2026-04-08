import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';

import '../breadcrumbs/breadcrumbs_component.dart';

const liPageHeaderDirectives = <Object>[
  LiPageHeaderComponent,
  LiPageHeaderBreadcrumbItemDirective,
  LiPageHeaderBottomDirective,
  LiPageHeaderActionsDirective,
];

@Directive(
  selector:
      'li-pg-crumb-item,li-pg-breadcrumb-item,[liPgCrumbItem],[liPgBreadcrumbItem]',
)
class LiPageHeaderBreadcrumbItemDirective {
  @Input()
  String label = '';

  @Input()
  String? href;

  @Input()
  String? routerLink;

  @Input()
  bool active = false;

  @Input()
  bool disabled = false;

  @Input('aria-label')
  String? ariaLabel;

  @Input()
  String? iconClass;

  bool get hasHref => href != null && href!.trim().isNotEmpty;

  bool get hasRouterLink => routerLink != null && routerLink!.trim().isNotEmpty;

  bool get hasIcon => iconClass != null && iconClass!.trim().isNotEmpty;

  String get hrefValue => href ?? '';

  String get routerLinkValue => routerLink ?? '';

  String get iconClassValue => iconClass ?? '';
}

@Directive(selector: '[liPgHeaderBottom]')
class LiPageHeaderBottomDirective {}

@Directive(selector: '[liPgHeaderActions]')
class LiPageHeaderActionsDirective {}

class LiPageHeaderBreadcrumbItem {
  const LiPageHeaderBreadcrumbItem({
    required this.label,
    this.href,
    this.routerLink,
    this.active = false,
    this.disabled = false,
    this.ariaLabel,
    this.iconClass,
  });

  final String label;
  final String? href;
  final String? routerLink;
  final bool active;
  final bool disabled;
  final String? ariaLabel;
  final String? iconClass;

  bool get hasHref => href != null && href!.trim().isNotEmpty;

  bool get hasRouterLink => routerLink != null && routerLink!.trim().isNotEmpty;

  bool get hasIcon => iconClass != null && iconClass!.trim().isNotEmpty;

  String get hrefValue => href ?? '';

  String get routerLinkValue => routerLink ?? '';

  String get iconClassValue => iconClass ?? '';
}

@Component(
  selector: 'li-pg-header',
  templateUrl: 'page_header_component.html',
  styleUrls: ['page_header_component.css'],
  directives: [
    coreDirectives,
    routerDirectives,
    LiBreadcrumbItemDirective,
  ],
  encapsulation: ViewEncapsulation.none,
)
class LiPageHeaderComponent {
  @Input()
  String titlePrefix = '';

  @Input()
  String titlePrefixSeparator = ' - ';

  @Input()
  String title = '';

  @Input()
  String titleClass = 'fw-normal';

  @Input()
  bool showBreadcrumbSection = true;

  @Input()
  List<LiPageHeaderBreadcrumbItem> breadcrumbItems =
      const <LiPageHeaderBreadcrumbItem>[];

  @Input()
  String breadcrumbDivider = 'default';

  @Input()
  String breadcrumbClass = 'py-2';

  @Input()
  String breadcrumbLineClass = 'w-100';

  @Input()
  bool breadcrumbWrap = true;

  @Input()
  bool showHomeBreadcrumb = true;

  @Input()
  String homeHref = '/';

  @Input()
  String homeRouterLink = '';

  @Input()
  String homeAriaLabel = 'Início';

  @Input()
  String homeIconClass = 'ph-house';

  /// Compatibility input for applications that previously depended on a
  /// built-in favorite action. In this package the actual action content must
  /// still be projected through [LiPageHeaderActionsDirective].
  @Input()
  bool showFavoriteAction = false;

  @ContentChildren(LiPageHeaderBottomDirective, descendants: true)
  List<LiPageHeaderBottomDirective> projectedBottom =
      <LiPageHeaderBottomDirective>[];

  @ContentChildren(LiPageHeaderBreadcrumbItemDirective, descendants: true)
  List<LiPageHeaderBreadcrumbItemDirective> projectedBreadcrumbItems =
      <LiPageHeaderBreadcrumbItemDirective>[];

  @ContentChildren(LiPageHeaderActionsDirective, descendants: true)
  List<LiPageHeaderActionsDirective> projectedActions =
      <LiPageHeaderActionsDirective>[];

  bool get hasTitlePrefix => titlePrefix.trim().isNotEmpty;

  bool get hasProjectedBottom => projectedBottom.isNotEmpty;

  bool get hasProjectedBreadcrumbItems => projectedBreadcrumbItems.isNotEmpty;

  bool get hasProjectedActions => projectedActions.isNotEmpty;

  bool get hasHomeRouterLink => homeRouterLink.trim().isNotEmpty;

  String attrOrEmpty(String? value) => value ?? '';

  bool get shouldRenderAutoBottom {
    return showHomeBreadcrumb ||
        breadcrumbItems.isNotEmpty ||
        hasProjectedBreadcrumbItems ||
        showFavoriteAction ||
        hasProjectedActions;
  }

  String get shellClasses {
    final classes = <String>['li-breadcrumb-line'];
    if (breadcrumbWrap) {
      classes.add('li-breadcrumb-wrap');
    } else {
      classes.add('li-breadcrumb-nowrap');
    }

    final extraClasses = breadcrumbLineClass.trim();
    if (extraClasses.isNotEmpty) {
      classes.addAll(extraClasses.split(RegExp(r'\s+')));
    }

    return classes.join(' ');
  }

  String get breadcrumbClasses {
    final classes = <String>['breadcrumb'];
    switch (breadcrumbDivider) {
      case 'dash':
        classes.add('breadcrumb-dash');
        break;
      case 'arrows':
        classes.add('breadcrumb-arrows');
        break;
      case 'caret':
        classes.add('breadcrumb-caret');
        break;
      case 'arrow':
        classes.add('breadcrumb-arrow');
        break;
    }

    final extraClasses = breadcrumbClass.trim();
    if (extraClasses.isNotEmpty) {
      classes.addAll(extraClasses.split(RegExp(r'\s+')));
    }

    return classes.join(' ');
  }
}
