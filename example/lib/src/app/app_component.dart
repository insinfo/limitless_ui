import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:limitless_ui/limitless_ui.dart';

import '../../messages.i18n.dart';
import '../i18n/demo_i18n_service.dart';
import '../shared/routes/route_paths.dart';
import '../shared/routes/routes.dart';
import '../theme/demo_theme_service.dart';

class DemoNavItem {
  const DemoNavItem({
    required this.label,
    required this.iconClass,
    required this.url,
  });

  final String label;
  final String iconClass;
  final String url;
}

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  styleUrls: ['app_component.css'],
  directives: [
    coreDirectives,
    LiDropdownMenuComponent,
    RouterLink,
    RouterLinkActive,
    RouterOutlet,
  ],
  providers: [
    ClassProvider(DemoI18nService),
    ClassProvider(DemoThemeService),
  ],
  exports: [DemoRoutePaths, DemoRoutes],
  encapsulation: ViewEncapsulation.none,
)
class AppComponent {
  AppComponent(this.i18n, this.theme);

  final DemoI18nService i18n;
  final DemoThemeService theme;
  Messages get t => i18n.t;

  bool isMobileSidebarOpen = false;
  bool isMobileSearchOpen = false;
  bool isSidebarCollapsed = false;

  List<LiDropdownMenuOption> get languageOptions => <LiDropdownMenuOption>[
        LiDropdownMenuOption(
            value: 'pt', label: 'PT', description: t.app.portuguese),
        LiDropdownMenuOption(
            value: 'en', label: 'EN', description: t.app.english),
      ];

  List<LiDropdownMenuOption> get themeOptions => <LiDropdownMenuOption>[
        LiDropdownMenuOption(
          value: 'light',
          label: t.app.light,
          iconClass: 'ph-sun',
        ),
        LiDropdownMenuOption(
          value: 'dark',
          label: t.app.dark,
          iconClass: 'ph-moon',
        ),
        LiDropdownMenuOption(
          value: 'auto',
          label: t.app.auto,
          iconClass: 'ph-desktop',
        ),
      ];

  String get selectedLanguage => i18n.isPortuguese ? 'pt' : 'en';
  String get selectedThemeMode => theme.modeValue;

  void toggleMobileSidebar() {
    isMobileSidebarOpen = !isMobileSidebarOpen;
    if (isMobileSidebarOpen) {
      isMobileSearchOpen = false;
    }
  }

  void closeMobileSidebar() {
    isMobileSidebarOpen = false;
  }

  void toggleMobileSearch() {
    isMobileSearchOpen = !isMobileSearchOpen;
    if (isMobileSearchOpen) {
      isMobileSidebarOpen = false;
    }
  }

  void closeMobileSearch() {
    isMobileSearchOpen = false;
  }

  void toggleSidebarCollapsed() {
    isSidebarCollapsed = !isSidebarCollapsed;
  }

  void onNavItemActivate() {
    closeMobileSidebar();
    closeMobileSearch();
  }

  void onLanguageChange(String value) {
    closeMobileSearch();
    if (value == 'en') {
      i18n.useEnglish();
      return;
    }

    i18n.usePortuguese();
  }

  void onThemeChange(String value) {
    closeMobileSearch();
    if (value == 'dark') {
      theme.useDark();
      return;
    }

    if (value == 'auto') {
      theme.useAuto();
      return;
    }

    theme.useLight();
  }

  List<DemoNavItem> get navItems => <DemoNavItem>[
        DemoNavItem(
          label: t.nav.overview,
          iconClass: 'ph-house',
          url: DemoRoutePaths.overview.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.alerts,
          iconClass: 'ph-bell',
          url: DemoRoutePaths.alerts.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.progress,
          iconClass: 'ph-chart-line-up',
          url: DemoRoutePaths.progress.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.accordion,
          iconClass: 'ph-stack',
          url: DemoRoutePaths.accordion.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.tabs,
          iconClass: 'ph-tabs',
          url: DemoRoutePaths.tabs.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.modal,
          iconClass: 'ph-app-window',
          url: DemoRoutePaths.modal.toUrl(),
        ),
        DemoNavItem(
          label: 'Offcanvas',
          iconClass: 'ph-sidebar',
          url: DemoRoutePaths.offcanvas.toUrl(),
        ),
        DemoNavItem(
          label: 'Breadcrumbs',
          iconClass: 'ph-path',
          url: DemoRoutePaths.breadcrumbs.toUrl(),
        ),
        DemoNavItem(
          label: 'Pagination',
          iconClass: 'ph-dots-three-outline',
          url: DemoRoutePaths.pagination.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.select,
          iconClass: 'ph-caret-down',
          url: DemoRoutePaths.select.toUrl(),
        ),
        DemoNavItem(
          label: 'Typeahead',
          iconClass: 'ph-magnifying-glass',
          url: DemoRoutePaths.typeahead.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.multiSelect,
          iconClass: 'ph-list-checks',
          url: DemoRoutePaths.multiSelect.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.currency,
          iconClass: 'ph-currency-circle-dollar',
          url: DemoRoutePaths.currency.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.datePicker,
          iconClass: 'ph-calendar-blank',
          url: DemoRoutePaths.datePicker.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.timePicker,
          iconClass: 'ph-clock',
          url: DemoRoutePaths.timePicker.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.dateRange,
          iconClass: 'ph-calendar',
          url: DemoRoutePaths.dateRange.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.carousel,
          iconClass: 'ph-slideshow',
          url: DemoRoutePaths.carousel.toUrl(),
        ),
        DemoNavItem(
          label: 'Scrollspy',
          iconClass: 'ph-crosshair',
          url: DemoRoutePaths.scrollSpy.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.tooltip,
          iconClass: 'ph-chat-centered-text',
          url: DemoRoutePaths.tooltip.toUrl(),
        ),
        DemoNavItem(
          label: 'Popover',
          iconClass: 'ph-chat-circle-text',
          url: DemoRoutePaths.popover.toUrl(),
        ),
        DemoNavItem(
          label: 'Nav',
          iconClass: 'ph-rows',
          url: DemoRoutePaths.nav.toUrl(),
        ),
        DemoNavItem(
          label: 'Dropdown',
          iconClass: 'ph-caret-circle-down',
          url: DemoRoutePaths.dropdown.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.datatable,
          iconClass: 'ph-table',
          url: DemoRoutePaths.datatable.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.datatableSelect,
          iconClass: 'ph-table',
          url: DemoRoutePaths.datatableSelect.toUrl(),
        ),
        DemoNavItem(
          label: 'Toast',
          iconClass: 'ph-notification',
          url: DemoRoutePaths.toast.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.treeview,
          iconClass: 'ph-tree-structure',
          url: DemoRoutePaths.treeview.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.helpers,
          iconClass: 'ph-wrench',
          url: DemoRoutePaths.helpers.toUrl(),
        ),
        DemoNavItem(
          label: t.nav.button,
          iconClass: 'ph-cursor-click',
          url: DemoRoutePaths.button.toUrl(),
        ),
      ];
}
