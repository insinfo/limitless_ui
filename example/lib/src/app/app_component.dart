import 'dart:async';
import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
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

class DemoNavbarSearchEntry {
  const DemoNavbarSearchEntry({
    required this.label,
    required this.url,
    required this.iconClass,
    required this.sectionLabel,
    this.aliases = const <String>[],
  });

  final String label;
  final String url;
  final String iconClass;
  final String sectionLabel;
  final List<String> aliases;

  String get searchText {
    final routeSegment = url.replaceAll('/', ' ').trim();
    return <String>[
      label,
      sectionLabel,
      routeSegment,
      ...aliases,
    ].where((value) => value.trim().isNotEmpty).join(' ');
  }

  @override
  String toString() => searchText;
}

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  styleUrls: ['app_component.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiDropdownMenuComponent,
    LiTypeaheadComponent,
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
    _rebuildViewModel();
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

  @ViewChild('sidebarSearchInput')
  InputElement? sidebarSearchInput;

  Messages get t => i18n.t;

  bool isMobileSidebarOpen = false;
  bool isMobileSearchOpen = false;
  bool isSidebarResized = false;
  bool isSidebarUnfolded = false;
  String? expandedSectionId;
  String sidebarFilter = '';

  List<LiDropdownMenuOption> languageOptions = const <LiDropdownMenuOption>[];
  List<LiDropdownMenuOption> themeOptions = const <LiDropdownMenuOption>[];
  List<DemoNavItem> primaryItems = const <DemoNavItem>[];
  List<DemoNavSection> navSections = const <DemoNavSection>[];
  List<DemoNavbarSearchEntry> navbarSearchEntries =
      const <DemoNavbarSearchEntry>[];
  List<DemoNavItem> filteredPrimaryItems = const <DemoNavItem>[];
  List<DemoNavSection> filteredNavSections = const <DemoNavSection>[];
  Set<String> _searchExpandedSectionIds = <String>{};
  Object? navbarSearchSelection;

  bool get _isDesktopViewport => (window.innerWidth ?? 0) >= 992;

  bool get hasSidebarFilter => sidebarFilter.trim().isNotEmpty;

  bool get hasVisibleNavigation =>
      filteredPrimaryItems.isNotEmpty || filteredNavSections.isNotEmpty;

  bool get showMainHeader => hasVisibleNavigation;

  String get sidebarSearchPlaceholder =>
      i18n.isPortuguese ? 'Buscar no menu...' : 'Search menu...';

  String get clearSidebarFilterLabel =>
      i18n.isPortuguese ? 'Limpar busca do menu' : 'Clear menu search';

  String get sidebarSearchEmptyState =>
      i18n.isPortuguese ? 'Nenhum item encontrado.' : 'No menu items found.';

  String get navbarSearchPlaceholder => i18n.isPortuguese
      ? 'Buscar componentes, páginas ou palavras-chave'
      : 'Search components, pages, or keywords';

  List<LiDropdownMenuOption> _buildLanguageOptions() => <LiDropdownMenuOption>[
        LiDropdownMenuOption(
            value: 'pt', label: 'PT', description: t.app.portuguese),
        LiDropdownMenuOption(
            value: 'en', label: 'EN', description: t.app.english),
      ];

  List<LiDropdownMenuOption> _buildThemeOptions() => <LiDropdownMenuOption>[
        LiDropdownMenuOption(
          value: 'light',
          label: t.app.light,
          iconClass: 'ph-sun',
        ),
        LiDropdownMenuOption(
          value: 'blu',
          label: i18n.isPortuguese ? 'Azul' : 'Blue',
          iconClass: 'ph-drop',
        ),
        LiDropdownMenuOption(
          value: 'pink',
          label: i18n.isPortuguese ? 'Rosa' : 'Pink',
          iconClass: 'ph-palette',
        ),
        LiDropdownMenuOption(
          value: 'orange',
          label: i18n.isPortuguese ? 'Laranja' : 'Orange',
          iconClass: 'ph-fire',
        ),
        LiDropdownMenuOption(
          value: 'sali',
          label: 'Retro',
          iconClass: 'ph-buildings',
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
  String get workQueueLabel =>
      i18n.isPortuguese ? 'Fila operacional' : 'Work queue';
  String get colorPickerLabel =>
      i18n.isPortuguese ? 'Color picker' : 'Color picker';
  String get offcanvasLabel => 'Offcanvas';
  String get breadcrumbsLabel => 'Breadcrumbs';
  String get pageHeaderLabel => 'Page Header';
  String get paginationLabel => 'Pagination';
  String get wizardLabel => 'Wizard';
  String get checkboxRadioLabel =>
      i18n.isPortuguese ? 'Checkbox e radios' : 'Checkboxes and radios';
  String get personRegistrationLabel =>
      i18n.isPortuguese ? 'Cadastro de pessoa' : 'Person registration';

  List<DemoNavItem> _buildPrimaryItems() => <DemoNavItem>[
        DemoNavItem(
          label: t.nav.overview,
          iconClass: 'ph-house',
          url: DemoRoutePaths.overview.toUrl(),
        ),
      ];

  List<DemoNavSection> _buildNavSections() => <DemoNavSection>[
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
              label: pageHeaderLabel,
              iconClass: 'ph-layout',
              url: DemoRoutePaths.pageHeader.toUrl(),
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
              label: wizardLabel,
              iconClass: 'ph-list-numbers',
              url: DemoRoutePaths.wizard.toUrl(),
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
            DemoNavItem(
              label: personRegistrationLabel,
              iconClass: 'ph-identification-card',
              url: DemoRoutePaths.personRegistration.toUrl(),
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
              label: workQueueLabel,
              iconClass: 'ph-kanban',
              url: DemoRoutePaths.workQueue.toUrl(),
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

  static const Map<String, List<String>> _navbarSearchAliasesByUrl =
      <String, List<String>>{
    '/overview': <String>['inicio', 'home', 'visao geral', 'overview'],
    '/alerts': <String>['alerta', 'alertas', 'feedback'],
    '/progress': <String>['progresso', 'progress bar', 'loading'],
    '/selection-controls': <String>['checkbox', 'radio', 'toggle', 'selecao'],
    '/select': <String>['combobox', 'dropdown select', 'selecionar'],
    '/multi-select': <String>['multiselect', 'seleção multipla', 'lista'],
    '/currency': <String>['moeda', 'monetaria', 'money', 'monetary'],
    '/inputs': <String>['input', 'campo', 'text field', 'formulario'],
    '/file-upload': <String>['upload', 'arquivo', 'anexo'],
    '/person-registration': <String>[
      'cadastro',
      'pessoa',
      'formulario completo',
      'validation',
      'backend fake',
    ],
    '/color-picker': <String>['cor', 'palette', 'picker'],
    '/date-picker': <String>['data', 'calendario', 'date'],
    '/time-picker': <String>['hora', 'relogio', 'time'],
    '/date-range': <String>['periodo', 'intervalo', 'range'],
    '/datatable': <String>['tabela', 'grid', 'table'],
    '/datatable-select': <String>['tabela seletiva', 'grid select'],
    '/work-queue': <String>[
      'fila',
      'encaminhamento',
      'workflow',
      'tags',
      'etiquetas'
    ],
    '/page-header': <String>[
      'header',
      'cabecalho',
      'page title',
      'breadcrumb header'
    ],
    '/treeview': <String>['arvore', 'tree', 'hierarquia'],
    '/sweet-alert': <String>['sweetalert', 'dialog', 'popup'],
    '/highlight': <String>['codigo', 'syntax', 'highlight'],
    '/typeahead': <String>['autocomplete', 'busca', 'suggestions'],
    '/wizard': <String>['steps', 'stepper', 'form wizard', 'etapas'],
  };

  List<DemoNavbarSearchEntry> _buildNavbarSearchEntries() {
    final entries = <DemoNavbarSearchEntry>[
      for (final item in primaryItems)
        _createNavbarSearchEntry(item, sectionLabel: mainLabel),
      for (final section in navSections)
        for (final item in section.items)
          _createNavbarSearchEntry(item, sectionLabel: section.label),
    ];

    entries.sort((left, right) => left.label.compareTo(right.label));
    return entries;
  }

  DemoNavbarSearchEntry _createNavbarSearchEntry(
    DemoNavItem item, {
    required String sectionLabel,
  }) {
    return DemoNavbarSearchEntry(
      label: item.label,
      url: item.url,
      iconClass: item.iconClass,
      sectionLabel: sectionLabel,
      aliases: _navbarSearchAliasesByUrl[item.url] ?? const <String>[],
    );
  }

  void _rebuildViewModel() {
    languageOptions = List<LiDropdownMenuOption>.unmodifiable(
      _buildLanguageOptions(),
    );
    themeOptions = List<LiDropdownMenuOption>.unmodifiable(
      _buildThemeOptions(),
    );
    primaryItems = List<DemoNavItem>.unmodifiable(_buildPrimaryItems());
    navSections = List<DemoNavSection>.unmodifiable(_buildNavSections());
    navbarSearchEntries = List<DemoNavbarSearchEntry>.unmodifiable(
      _buildNavbarSearchEntries(),
    );
    _applySidebarFilter();
  }

  String navbarSearchInputFormatter(dynamic item) {
    if (item is! DemoNavbarSearchEntry) {
      return item?.toString() ?? '';
    }

    return item.label;
  }

  String navbarSearchResultFormatter(dynamic item) {
    if (item is! DemoNavbarSearchEntry) {
      return item?.toString() ?? '';
    }

    return '${item.label} · ${item.sectionLabel}';
  }

  void onNavbarSearchSelect(DemoNavbarSearchEntry entry) {
    expandedSectionId = _resolveExpandedSectionIdForUrl(entry.url);
    navbarSearchSelection = null;
    closeMobileSidebar();
    closeMobileSearch();

    final targetHash = entry.url.startsWith('/') ? entry.url : '/${entry.url}';
    window.location.hash = targetHash;
  }

  void onSidebarFilterInput(String value) {
    sidebarFilter = value;
    _applySidebarFilter();

    if (hasSidebarFilter && _isDesktopViewport && isSidebarResized) {
      isSidebarUnfolded = true;
    }
  }

  void clearSidebarFilter() {
    if (!hasSidebarFilter) {
      return;
    }

    sidebarFilter = '';
    _applySidebarFilter();

    Future<void>.microtask(() {
      sidebarSearchInput
        ?..focus()
        ..select();
    });
  }

  void openSidebarSearch() {
    if (_isDesktopViewport && isSidebarResized) {
      isSidebarUnfolded = true;
    }

    Future<void>.microtask(() {
      sidebarSearchInput
        ?..focus()
        ..select();
    });
  }

  void _applySidebarFilter() {
    final normalizedQuery = _normalizeSidebarSearch(sidebarFilter);

    if (normalizedQuery.isEmpty) {
      filteredPrimaryItems = primaryItems;
      filteredNavSections = navSections;
      _searchExpandedSectionIds = <String>{};
      return;
    }

    filteredPrimaryItems = List<DemoNavItem>.unmodifiable(
      primaryItems
          .where((item) => _matchesSidebarQuery(item.label, normalizedQuery)),
    );

    final filteredSections = <DemoNavSection>[];
    final expandedSectionIds = <String>{};

    for (final section in navSections) {
      final sectionMatches =
          _matchesSidebarQuery(section.label, normalizedQuery);
      final visibleItems = sectionMatches
          ? section.items
          : List<DemoNavItem>.unmodifiable(
              section.items.where(
                (item) => _matchesSidebarQuery(item.label, normalizedQuery),
              ),
            );

      if (visibleItems.isEmpty) {
        continue;
      }

      filteredSections.add(
        identical(visibleItems, section.items)
            ? section
            : DemoNavSection(
                id: section.id,
                label: section.label,
                iconClass: section.iconClass,
                items: visibleItems,
              ),
      );
      expandedSectionIds.add(section.id);
    }

    filteredNavSections = List<DemoNavSection>.unmodifiable(filteredSections);
    _searchExpandedSectionIds = expandedSectionIds;
  }

  bool _matchesSidebarQuery(String value, String normalizedQuery) {
    return _normalizeSidebarSearch(value).contains(normalizedQuery);
  }

  String _normalizeSidebarSearch(String value) {
    var normalized = value.trim().toLowerCase();

    const replacements = <String, String>{
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'õ': 'o',
      'ô': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    replacements.forEach((source, target) {
      normalized = normalized.replaceAll(source, target);
    });

    return normalized;
  }

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

  void toggleSection(Event event, String sectionId) {
    event.preventDefault();

    if (hasSidebarFilter) {
      return;
    }

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
    } else {
      i18n.usePortuguese();
    }

    _rebuildViewModel();
    if (!hasSidebarFilter) {
      expandedSectionId = _resolveExpandedSectionId();
    }
  }

  void onThemeChange(String value) {
    closeMobileSearch();
    if (value == 'blu') {
      theme.useBlu();
      return;
    }

    if (value == 'sali') {
      theme.useSali();
      return;
    }

    if (value == 'orange') {
      theme.useOrange();
      return;
    }

    if (value == 'pink') {
      theme.usePink();
      return;
    }

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

  bool isSectionExpanded(String sectionId) {
    if (hasSidebarFilter) {
      return _searchExpandedSectionIds.contains(sectionId);
    }

    return expandedSectionId == sectionId;
  }

  String? _resolveExpandedSectionIdForUrl(String url) {
    for (final section in navSections) {
      for (final item in section.items) {
        if (item.url == url) {
          return section.id;
        }
      }
    }

    return null;
  }

  String? _resolveExpandedSectionId() {
    final routeSegment = _currentRouteSegment();
    if (routeSegment == null ||
        routeSegment.isEmpty ||
        routeSegment == 'overview') {
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
      return hash
          .replaceFirst('#', '')
          .split('/')
          .where((part) => part.isNotEmpty)
          .lastOrNull;
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
