import 'package:ngdart/angular.dart';

const liBreadcrumbDirectives = <Object>[
  LiBreadcrumbComponent,
  LiBreadcrumbItemDirective,
  LiBreadcrumbStartDirective,
  LiBreadcrumbEndDirective,
];

@Directive(selector: '[liBreadcrumbStart]')
class LiBreadcrumbStartDirective {}

@Directive(selector: '[liBreadcrumbEnd]')
class LiBreadcrumbEndDirective {}

@Directive(selector: '[liBreadcrumbItem]')
class LiBreadcrumbItemDirective {
  @Input()
  bool active = false;

  @Input()
  bool disabled = false;

  @Input('aria-label')
  String? ariaLabel;

  @HostBinding('class.breadcrumb-item')
  bool get hostBreadcrumbItemClass => true;

  @HostBinding('class.active')
  bool get hostActiveClass => active;

  @HostBinding('class.disabled')
  bool get hostDisabledClass => disabled;

  @HostBinding('attr.aria-current')
  String? get hostAriaCurrent => active ? 'page' : null;

  @HostBinding('attr.aria-disabled')
  String? get hostAriaDisabled => disabled ? 'true' : null;

  @HostBinding('attr.tabindex')
  String? get hostTabIndex => disabled ? '-1' : null;

  @HostBinding('attr.aria-label')
  String? get hostAriaLabel => ariaLabel;
}

@Component(
  selector: 'li-breadcrumb',
  templateUrl: 'breadcrumbs_component.html',
  styleUrls: ['breadcrumbs_component.css'],
  directives: [coreDirectives],
  encapsulation: ViewEncapsulation.none,
)
class LiBreadcrumbComponent {
  @Input('aria-label')
  String ariaLabel = 'Breadcrumb';

  @Input()
  String divider = 'default';

  @Input()
  String helperText = '';

  @Input()
  String helperTextClass =
      'fs-sm text-uppercase text-muted align-self-center lh-1 me-2';

  @Input()
  String lineClass = '';

  @Input()
  String breadcrumbClass = '';

  @Input()
  bool wrap = true;

  @ContentChildren(LiBreadcrumbStartDirective)
  List<LiBreadcrumbStartDirective> startItems = <LiBreadcrumbStartDirective>[];

  @ContentChildren(LiBreadcrumbEndDirective)
  List<LiBreadcrumbEndDirective> endItems = <LiBreadcrumbEndDirective>[];

  bool get hasStart => startItems.isNotEmpty;

  bool get hasEnd => endItems.isNotEmpty;

  String get shellClasses {
    final classes = <String>['li-breadcrumb-line'];
    if (wrap) {
      classes.add('li-breadcrumb-wrap');
    } else {
      classes.add('li-breadcrumb-nowrap');
    }
    final extraClasses = lineClass.trim();
    if (extraClasses.isNotEmpty) {
      classes.addAll(extraClasses.split(RegExp(r'\s+')));
    }
    return classes.join(' ');
  }

  String get breadcrumbClasses {
    final classes = <String>['breadcrumb'];
    switch (divider) {
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
