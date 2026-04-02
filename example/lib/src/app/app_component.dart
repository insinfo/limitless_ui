import 'dart:async';
import 'dart:html';

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

class DemoNavSection {
  const DemoNavSection({
    required this.id,
    required this.label,
    required this.iconClass,
    required this.items,
  });

  final String id;
  final String label;
  final String iconClass;
  final List<DemoNavItem> items;
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
class AppComponent implements OnDestroy {
  AppComponent(this.i18n, this.theme, this._ngZone) {
    expandedSectionId = _resolveExpandedSectionId();
    _resizeSubscription = window.onResize.listen((_) {
      _ngZone.run(_syncViewportState);
    });
  }

  final DemoI18nService i18n;
  final DemoThemeService theme;
  final NgZone _ngZone;

  static const Duration _sidebarHoverDelay = Duration(milliseconds: 150);

  StreamSubscription<Event>? _resizeSubscription;
  Timer? _sidebarHoverInTimer;
  Timer? _sidebarHoverOutTimer;

  Messages get t => i18n.t;

  bool isMobileSidebarOpen = false;
  bool isMobileSearchOpen = false;
  bool isSidebarResized = false;
  bool isSidebarUnfolded = false;
  String? expandedSectionId;

  bool get _isDesktopViewport => (window.innerWidth ?? 0) >= 992;

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

  String get mainLabel => i18n.isPortuguese ? 'Principal' : 'Main';
  String get feedbackLabel => i18n.isPortuguese ? 'Feedback' : 'Feedback';
  String get inputsLabel => i18n.isPortuguese ? 'Inputs' : 'Inputs';
  String get pickersLabel => i18n.isPortuguese ? 'Pickers' : 'Pickers';
  String get dataLabel => i18n.isPortuguese ? 'Dados' : 'Data';
  String get utilitiesLabel => i18n.isPortuguese ? 'Utilitários' : 'Utilities';
  String get colorPickerLabel => i18n.isPortuguese ? 'Color picker' : 'Color picker';
  String get offcanvasLabel => 'Offcanvas';
  String get breadcrumbsLabel => 'Breadcrumbs';
  String get paginationLabel => 'Pagination';
  String get checkboxRadioLabel =>
      i18n.isPortuguese ? 'Checkbox e radios' : 'Checkboxes and radios';

  List<DemoNavItem> get primaryItems => <DemoNavItem>[
        DemoNavItem(
          label: t.nav.overview,
          iconClass: 'ph-house',
          url: DemoRoutePaths.overview.toUrl(),
        ),
      ];

  List<DemoNavSection> get navSections => <DemoNavSection>[
        DemoNavSection(
          id: 'feedback',
          label: feedbackLabel,
          iconClass: 'ph-stack',
          items: <DemoNavItem>[
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
              label: offcanvasLabel,
              iconClass: 'ph-sidebar',
              url: DemoRoutePaths.offcanvas.toUrl(),
            ),
            DemoNavItem(
              label: breadcrumbsLabel,
              iconClass: 'ph-path',
              url: DemoRoutePaths.breadcrumbs.toUrl(),
            ),
            DemoNavItem(
              label: paginationLabel,
              iconClass: 'ph-dots-three-outline',
              url: DemoRoutePaths.pagination.toUrl(),
            ),
            DemoNavItem(
              label: t.nav.carousel,
              iconClass: 'ph-slideshow',
              url: DemoRoutePaths.carousel.toUrl(),
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
              label: 'Toast',
              iconClass: 'ph-notification',
              url: DemoRoutePaths.toast.toUrl(),
            ),
            DemoNavItem(
              label: t.nav.notification,
              iconClass: 'ph-broadcast',
              url: DemoRoutePaths.notification.toUrl(),
            ),
          ],
        ),
        DemoNavSection(
          id: 'inputs',
          label: inputsLabel,
          iconClass: 'ph-textbox',
          items: <DemoNavItem>[
            DemoNavItem(
              label: checkboxRadioLabel,
              iconClass: 'ph-check-square-offset',
              url: DemoRoutePaths.selectionControls.toUrl(),
            ),
            DemoNavItem(
              label: t.nav.select,
              iconClass: 'ph-caret-down',
              url: DemoRoutePaths.select.toUrl(),
            ),
            DemoNavItem(
              label: 'Rating',
              iconClass: 'ph-star',
              url: DemoRoutePaths.rating.toUrl(),
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
              label: 'Inputs',
              iconClass: 'ph-textbox',
              url: DemoRoutePaths.inputs.toUrl(),
            ),
            DemoNavItem(
              label: 'File upload',
              iconClass: 'ph-upload-simple',
              url: DemoRoutePaths.fileUpload.toUrl(),
            ),
          ],
        ),
        DemoNavSection(
          id: 'pickers',
          label: pickersLabel,
          iconClass: 'ph-hand-pointing',
          items: <DemoNavItem>[
            DemoNavItem(
              label: colorPickerLabel,
              iconClass: 'ph-drop',
              url: DemoRoutePaths.colorPicker.toUrl(),
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
          ],
        ),
        DemoNavSection(
          id: 'data',
          label: dataLabel,
          iconClass: 'ph-table',
          items: <DemoNavItem>[
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
              label: t.nav.treeview,
              iconClass: 'ph-tree-structure',
              url: DemoRoutePaths.treeview.toUrl(),
            ),
          ],
        ),
        DemoNavSection(
          id: 'utilities',
          label: utilitiesLabel,
          iconClass: 'ph-wrench',
          items: <DemoNavItem>[
            DemoNavItem(
              label: t.nav.helpers,
              iconClass: 'ph-wrench',
              url: DemoRoutePaths.helpers.toUrl(),
            ),
            DemoNavItem(
              label: 'SweetAlert',
              iconClass: 'ph-sparkle',
              url: DemoRoutePaths.sweetAlert.toUrl(),
            ),
            DemoNavItem(
              label: 'Highlight',
              iconClass: 'ph-code-block',
              url: DemoRoutePaths.highlight.toUrl(),
            ),
            DemoNavItem(
              label: t.nav.button,
              iconClass: 'ph-cursor-click',
              url: DemoRoutePaths.button.toUrl(),
            ),
            DemoNavItem(
              label: t.nav.fab,
              iconClass: 'ph-plus-circle',
              url: DemoRoutePaths.fab.toUrl(),
            ),
          ],
        ),
      ];

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

  void toggleSidebarResized() {
    if (!_isDesktopViewport) {
      return;
    }

    isSidebarResized = !isSidebarResized;
    if (!isSidebarResized) {
      isSidebarUnfolded = false;
    }
  }

  void onSidebarMouseEnter() {
    if (!_isDesktopViewport || !isSidebarResized) {
      return;
    }

    _sidebarHoverOutTimer?.cancel();
    _sidebarHoverInTimer?.cancel();
    _sidebarHoverInTimer = Timer(_sidebarHoverDelay, () {
      _ngZone.run(() {
        if (isSidebarResized && _isDesktopViewport) {
          isSidebarUnfolded = true;
        }
      });
    });
  }

  void onSidebarMouseLeave() {
    _sidebarHoverInTimer?.cancel();
    if (!_isDesktopViewport) {
      return;
    }

    _sidebarHoverOutTimer?.cancel();
    _sidebarHoverOutTimer = Timer(_sidebarHoverDelay, () {
      _ngZone.run(() {
        isSidebarUnfolded = false;
      });
    });
  }

  bool isSectionExpanded(String sectionId) => expandedSectionId == sectionId;

  void toggleSection(Event event, String sectionId) {
    event.preventDefault();
    expandedSectionId = expandedSectionId == sectionId ? null : sectionId;
  }

  void onNavItemActivate([String? sectionId]) {
    if (sectionId != null) {
      expandedSectionId = sectionId;
    }
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

  String? _resolveExpandedSectionId() {
    final routeSegment = _currentRouteSegment();
    if (routeSegment == null || routeSegment.isEmpty || routeSegment == 'overview') {
      return null;
    }

    for (final section in navSections) {
      for (final item in section.items) {
        if (item.url.endsWith(routeSegment)) {
          return section.id;
        }
      }
    }

    return null;
  }

  String? _currentRouteSegment() {
    final hash = window.location.hash;
    if (hash.isNotEmpty) {
      return hash.replaceFirst('#', '').split('/').where((part) => part.isNotEmpty).lastOrNull;
    }

    final pathSegments =
        Uri.base.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (pathSegments.isEmpty) {
      return null;
    }

    return pathSegments.last;
  }

  void _syncViewportState() {
    if (_isDesktopViewport) {
      isMobileSidebarOpen = false;
      return;
    }

    isSidebarUnfolded = false;
  }

  @override
  void ngOnDestroy() {
    _resizeSubscription?.cancel();
    _sidebarHoverInTimer?.cancel();
    _sidebarHoverOutTimer?.cancel();
  }
}
