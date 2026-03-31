import 'package:limitless_ui_example/limitless_ui_example.dart';

class BreadcrumbDemoItem {
  const BreadcrumbDemoItem({
    required this.label,
    this.href,
    this.active = false,
    this.disabled = false,
  });

  final String label;
  final String? href;
  final bool active;
  final bool disabled;
}

@Component(
  selector: 'breadcrumbs-page',
  templateUrl: 'breadcrumbs_page.html',
  styleUrls: ['breadcrumbs_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    liBreadcrumbDirectives,
  ],
)
class BreadcrumbsPageComponent {
  final List<BreadcrumbDemoItem> accountTrail = const <BreadcrumbDemoItem>[
    BreadcrumbDemoItem(label: 'Home', href: '#home'),
    BreadcrumbDemoItem(label: 'Accounts', href: '#accounts'),
    BreadcrumbDemoItem(label: 'Enterprise', active: true),
  ];

  final List<BreadcrumbDemoItem> catalogTrail = const <BreadcrumbDemoItem>[
    BreadcrumbDemoItem(label: 'Library', href: '#library'),
    BreadcrumbDemoItem(label: 'Components', href: '#components'),
    BreadcrumbDemoItem(label: 'Navigation', href: '#navigation'),
    BreadcrumbDemoItem(label: 'Breadcrumbs', active: true),
  ];

  final List<BreadcrumbDemoItem> checkoutTrail = const <BreadcrumbDemoItem>[
    BreadcrumbDemoItem(label: 'Cart', href: '#cart'),
    BreadcrumbDemoItem(label: 'Shipping', href: '#shipping'),
    BreadcrumbDemoItem(label: 'Payment', disabled: true),
    BreadcrumbDemoItem(label: 'Review', active: true),
  ];
}
