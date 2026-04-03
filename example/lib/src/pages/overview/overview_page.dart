import 'dart:html';

import 'package:limitless_ui_example/limitless_ui_example.dart';
import 'package:ngrouter/ngrouter.dart';

class DemoStat {
  const DemoStat({
    required this.label,
    required this.value,
    required this.help,
  });

  final String label;
  final String value;
  final String help;
}

class OverviewFeatureCard {
  const OverviewFeatureCard({
    required this.title,
    required this.body,
    required this.iconClass,
    required this.accentClass,
    this.url,
    this.href,
  });

  final String title;
  final String body;
  final String iconClass;
  final String? url;
  final String? href;
  final String accentClass;

  bool get isExternal => href != null && href!.isNotEmpty;

  String get internalUrl => url ?? '';

  String get stableKey => url ?? href ?? title;
}

@Component(
  selector: 'overview-page',
  templateUrl: 'overview_page.html',
  styleUrls: ['overview_page.css'],
  directives: [coreDirectives, RouterLink, DemoPageBreadcrumbComponent],
  exports: [DemoRoutePaths],
)
class OverviewPageComponent {
  OverviewPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  String? _cachedLocaleCode;
  List<DemoStat> _stats = const <DemoStat>[];
  List<OverviewFeatureCard> _featureCards = const <OverviewFeatureCard>[];

  List<DemoStat> get stats {
    _ensureCollections();
    return _stats;
  }

  List<OverviewFeatureCard> get featureCards {
    _ensureCollections();
    return _featureCards;
  }

  String get angulardartDocsUrl {
    final origin = window.location.origin;
    final pathSegments = (window.location.pathname ?? '')
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (window.location.host.contains('github.io') && pathSegments.isNotEmpty) {
      return '$origin/${pathSegments.first}/site_ngdart/guide/setup';
    }

    return 'https://insinfo.github.io/limitless_ui/site_ngdart/guide/setup';
  }

  String trackByStat(int index, dynamic item) => (item as DemoStat).label;

  Object? trackByFeatureCard(int index, dynamic item) =>
      (item as OverviewFeatureCard).stableKey;

  String featureCardClass(OverviewFeatureCard item) =>
      'overview-feature-card ${item.accentClass}';

  void _ensureCollections() {
    final localeCode = i18n.isPortuguese ? 'pt' : 'en';
    if (_cachedLocaleCode == localeCode) {
      return;
    }

    _cachedLocaleCode = localeCode;
    _stats = List<DemoStat>.unmodifiable(<DemoStat>[
      DemoStat(
        label: t.pages.overview.statComponentsLabel,
        value: '23',
        help: t.pages.overview.statComponentsHelp,
      ),
      DemoStat(
        label: t.pages.overview.statThemeLabel,
        value: 'Limitless 4',
        help: t.pages.overview.statThemeHelp,
      ),
      DemoStat(
        label: t.pages.overview.statNavigationLabel,
        value: 'ngrouter',
        help: t.pages.overview.statNavigationHelp,
      ),
    ]);

    _featureCards = List<OverviewFeatureCard>.unmodifiable(<OverviewFeatureCard>[
      OverviewFeatureCard(
        title: t.pages.overview.featureAngularDartDocsTitle,
        body: t.pages.overview.featureAngularDartDocsBody,
        iconClass: 'ph-book-open-text',
        href: angulardartDocsUrl,
        accentClass: 'overview-card-primary',
      ),
      OverviewFeatureCard(
        title: t.pages.overview.featureDatePickerTitle,
        body: t.pages.overview.featureDatePickerBody,
        iconClass: 'ph-calendar-blank',
        url: DemoRoutePaths.datePicker.toUrl(),
        accentClass: 'overview-card-primary',
      ),
      OverviewFeatureCard(
        title: t.pages.overview.featureTimePickerTitle,
        body: t.pages.overview.featureTimePickerBody,
        iconClass: 'ph-clock',
        url: DemoRoutePaths.timePicker.toUrl(),
        accentClass: 'overview-card-info',
      ),
      OverviewFeatureCard(
        title: t.pages.overview.featureDateRangeTitle,
        body: t.pages.overview.featureDateRangeBody,
        iconClass: 'ph-calendar-check',
        url: DemoRoutePaths.dateRange.toUrl(),
        accentClass: 'overview-card-success',
      ),
      OverviewFeatureCard(
        title: t.pages.overview.featureCarouselTitle,
        body: t.pages.overview.featureCarouselBody,
        iconClass: 'ph-slideshow',
        url: DemoRoutePaths.carousel.toUrl(),
        accentClass: 'overview-card-warning',
      ),
      OverviewFeatureCard(
        title: t.pages.overview.featureDatatableTitle,
        body: t.pages.overview.featureDatatableBody,
        iconClass: 'ph-table',
        url: DemoRoutePaths.datatable.toUrl(),
        accentClass: 'overview-card-info',
      ),
      OverviewFeatureCard(
        title: t.pages.overview.featureSelectTitle,
        body: t.pages.overview.featureSelectBody,
        iconClass: 'ph-caret-down',
        url: DemoRoutePaths.select.toUrl(),
        accentClass: 'overview-card-primary',
      ),
      OverviewFeatureCard(
        title: t.pages.overview.featureTabsTitle,
        body: t.pages.overview.featureTabsBody,
        iconClass: 'ph-tabs',
        url: DemoRoutePaths.tabs.toUrl(),
        accentClass: 'overview-card-info',
      ),
      OverviewFeatureCard(
        title: t.pages.overview.featureAccordionTitle,
        body: t.pages.overview.featureAccordionBody,
        iconClass: 'ph-stack',
        url: DemoRoutePaths.accordion.toUrl(),
        accentClass: 'overview-card-success',
      ),
      OverviewFeatureCard(
        title: t.pages.overview.featureHelpersTitle,
        body: t.pages.overview.featureHelpersBody,
        iconClass: 'ph-wrench',
        url: DemoRoutePaths.helpers.toUrl(),
        accentClass: 'overview-card-warning',
      ),
      OverviewFeatureCard(
        title: 'SweetAlert',
        body: t.pages.overview.featureSweetAlertBody,
        iconClass: 'ph-sparkle',
        url: DemoRoutePaths.sweetAlert.toUrl(),
        accentClass: 'overview-card-primary',
      ),
      OverviewFeatureCard(
        title: 'Highlight',
        body: t.pages.overview.featureHighlightBody,
        iconClass: 'ph-code-block',
        url: DemoRoutePaths.highlight.toUrl(),
        accentClass: 'overview-card-info',
      ),
      OverviewFeatureCard(
        title: 'Inputs',
        body: t.pages.overview.featureInputsFieldBody,
        iconClass: 'ph-textbox',
        url: DemoRoutePaths.inputs.toUrl(),
        accentClass: 'overview-card-success',
      ),
      OverviewFeatureCard(
        title: 'Floating action button',
        body: t.pages.overview.featureFabBody,
        iconClass: 'ph-plus-circle',
        url: DemoRoutePaths.fab.toUrl(),
        accentClass: 'overview-card-warning',
      ),
    ]);
  }
}
