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
    required this.url,
    required this.accentClass,
  });

  final String title;
  final String body;
  final String iconClass;
  final String url;
  final String accentClass;
}

@Component(
  selector: 'overview-page',
  templateUrl: 'overview_page.html',
  styleUrls: ['overview_page.css'],
  directives: [coreDirectives, RouterLink],
  exports: [DemoRoutePaths],
)
class OverviewPageComponent {
  OverviewPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  List<DemoStat> get stats => <DemoStat>[
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
      ];

  List<OverviewFeatureCard> get featureCards => <OverviewFeatureCard>[
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
          body: i18n.isPortuguese
              ? 'API unificada para modal, confirmação, prompt, toast e também gatilho declarativo.'
              : 'Unified API for modals, confirmation, prompt, toast, and also a declarative trigger.',
          iconClass: 'ph-sparkle',
          url: DemoRoutePaths.sweetAlert.toUrl(),
          accentClass: 'overview-card-primary',
        ),
        OverviewFeatureCard(
          title: 'Highlight',
          body: i18n.isPortuguese
              ? 'Bloco leve para snippets de Dart, HTML e CSS na documentação do example.'
              : 'Lightweight block for Dart, HTML, and CSS snippets in the example documentation.',
          iconClass: 'ph-code-block',
          url: DemoRoutePaths.highlight.toUrl(),
          accentClass: 'overview-card-info',
        ),
        OverviewFeatureCard(
          title: 'Inputs',
          body: i18n.isPortuguese
              ? 'Campo de texto com ngModel, floating label, textarea e addons de prefixo ou sufixo.'
              : 'Text field with ngModel, floating label, textarea, and prefix or suffix addons.',
          iconClass: 'ph-textbox',
          url: DemoRoutePaths.inputs.toUrl(),
          accentClass: 'overview-card-success',
        ),
        OverviewFeatureCard(
          title: 'Floating action button',
          body: i18n.isPortuguese
              ? 'Speed dial compacto para ações rápidas globais ou inline.'
              : 'Compact speed dial for quick global or inline actions.',
          iconClass: 'ph-plus-circle',
          url: DemoRoutePaths.fab.toUrl(),
          accentClass: 'overview-card-warning',
        ),
      ];

  String trackByStat(int index, dynamic item) => (item as DemoStat).label;

  Object? trackByFeatureCard(int index, dynamic item) =>
      (item as OverviewFeatureCard).url;

  String featureCardClass(OverviewFeatureCard item) =>
      'overview-feature-card ${item.accentClass}';
}
