import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'nav-page',
  templateUrl: 'nav_page.html',
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiNavDirective,
    LiNavItemDirective,
    LiNavLinkDirective,
    LiNavContentDirective,
    LiNavOutletDirective,
  ],
)
class NavPageComponent {
  NavPageComponent(this.i18n) : eventLog = '' {
    eventLog = waitingState;
  }

  final DemoI18nService i18n;
  bool get _isPt => i18n.isPortuguese;

  Object activeId = 1;
  Object verticalActiveId = 'overview';
  String eventLog;

  late final List<NavShowcaseItem> _dynamicItemsPt = <NavShowcaseItem>[
    const NavShowcaseItem(
      id: 1,
      title: 'Overview',
      body: 'Resumo curto do fluxo com uma aba inicial ativa por padrão.',
    ),
    const NavShowcaseItem(
      id: 2,
      title: 'Uso',
      body: 'O container controla seleção, teclado e a região de conteúdo.',
    ),
    const NavShowcaseItem(
      id: 3,
      title: 'Desabilitada',
      body: 'Abas desabilitadas continuam selecionáveis apenas por API.',
      disabled: true,
    ),
  ];

  late final List<NavShowcaseItem> _dynamicItemsEn = <NavShowcaseItem>[
    const NavShowcaseItem(
      id: 1,
      title: 'Overview',
      body: 'Short flow summary with one tab active by default.',
    ),
    const NavShowcaseItem(
      id: 2,
      title: 'Usage',
      body: 'The container controls selection, keyboard handling, and the content region.',
    ),
    const NavShowcaseItem(
      id: 3,
      title: 'Disabled',
      body: 'Disabled tabs remain selectable only through the API.',
      disabled: true,
    ),
  ];

  List<NavShowcaseItem> get dynamicItems =>
      _isPt ? _dynamicItemsPt : _dynamicItemsEn;

  String get pageTitle => _isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'Nav';
  String get breadcrumb => _isPt
      ? 'Seleção, outlet e atalhos de teclado'
      : 'Selection, outlet, and keyboard shortcuts';
  String get overviewIntro => _isPt
      ? 'O helper de nav entrega seleção controlada, outlet desacoplado, suporte a abas desabilitadas e atalhos de teclado como Home, End e setas.'
      : 'The nav helper provides controlled selection, a decoupled outlet, support for disabled tabs, and keyboard shortcuts such as Home, End, and arrow keys.';
  String get descriptionBody => _isPt
      ? 'Use liNav no container, liNavItem nas abas, liNavLink no gatilho e liNavOutlet para renderizar o conteúdo ativo em qualquer parte da página.'
      : 'Use liNav on the container, liNavItem on the tabs, liNavLink on the trigger, and liNavOutlet to render the active content anywhere on the page.';
  List<String> get features => _isPt
      ? const <String>[
          'activeId com binding e seleção programática.',
          'navChange.preventDefault() para bloquear trocas específicas.',
          'Suporte a nav horizontal, vertical e outlet fora do markup principal.',
        ]
      : const <String>[
          'activeId with binding and programmatic selection.',
          'navChange.preventDefault() to block specific changes.',
          'Support for horizontal nav, vertical nav, and an outlet outside the main markup.',
        ];
  List<String> get limits => _isPt
      ? const <String>[
          'O demo cobre o fluxo essencial, não animação complexa.',
          'O conteúdo é renderizado a partir de template[liNavContent].',
          'Para navegação com URL, continue usando router normalmente.',
        ]
      : const <String>[
          'The demo covers the essential flow, not complex animation.',
          'Content is rendered from template[liNavContent].',
          'For URL-based navigation, keep using the router normally.',
        ];
  String get basicNavsTitle => _isPt ? 'Navs básicas' : 'Basic navs';
  String get basicNavsBody => _isPt
      ? 'A seleção abaixo usa [(activeId)] e mantém o outlet fora da lista.'
      : 'The selection below uses [(activeId)] and keeps the outlet outside the list.';
  String get selectSecondLabel =>
      _isPt ? 'Selecionar aba 2' : 'Select tab 2';
  String get selectDisabledLabel =>
      _isPt ? 'Selecionar aba desabilitada' : 'Select disabled tab';
  String get verticalPillsTitle => _isPt ? 'Pills verticais' : 'Vertical pills';
  String get verticalPillsBody => _isPt
      ? 'Com orientation="vertical" o nav se comporta como uma coluna de pills.'
      : 'With orientation="vertical", the nav behaves like a column of pills.';
  String get verticalOverviewLabel => 'Overview';
  String get verticalOverviewBody => _isPt
      ? 'Entrada inicial para uma stack vertical de conteúdo contextual.'
      : 'Initial entry point for a vertical stack of contextual content.';
  String get verticalSettingsLabel => _isPt ? 'Configurações' : 'Settings';
  String get verticalSettingsBody => _isPt
      ? 'Mostra que o outlet pode permanecer ao lado da coluna de pills.'
      : 'Shows that the outlet can remain beside the pills column.';
  String get verticalHistoryLabel => _isPt ? 'Histórico' : 'History';
  String get verticalHistoryBody => _isPt
      ? 'Setas, Home e End trocam a aba porque o keyboard está em changeWithArrows.'
      : 'Arrows, Home, and End switch the tab because keyboard is set to changeWithArrows.';
  String get currentStateTitle => _isPt ? 'Estado atual' : 'Current state';
  String get apiIntro => _isPt
      ? 'A API pública segue a divisão clássica de container, item, link, conteúdo e outlet.'
      : 'The public API follows the classic split between container, item, link, content, and outlet.';
  List<String> get apiItems => _isPt
      ? const <String>[
          'liNav controla estado, teclado, roles e eventos.',
          'liNavItem define id, estado disabled e destroyOnHide por item.',
          'liNavLink aplica classes Bootstrap e atributos ARIA no botão ou link.',
          'template[liNavContent] descreve o conteúdo da aba.',
          '[liNavOutlet] renderiza o conteúdo ativo em outro ponto do DOM.',
        ]
      : const <String>[
          'liNav controls state, keyboard, roles, and events.',
          'liNavItem defines id, disabled state, and destroyOnHide per item.',
          'liNavLink applies Bootstrap classes and ARIA attributes to the button or link.',
          'template[liNavContent] describes the tab content.',
          '[liNavOutlet] renders the active content in another DOM location.',
        ];
  String get waitingState =>
      _isPt ? 'Nav: aguardando interação' : 'Nav: waiting for interaction';

  void onNavChanged(Object? id) {
    eventLog = _isPt
        ? 'Nav: activeId mudou para $id'
        : 'Nav: activeId changed to $id';
  }

  void onActiveIdChange(Object? id) {
    activeId = id ?? activeId;
    onNavChanged(activeId);
  }

  void onNavPrevented(LiNavChangeEvent event) {
    if (event.nextId == 3) {
      event.preventDefault();
      eventLog = _isPt
          ? 'Nav: troca para a aba 3 bloqueada por navChange.preventDefault()'
          : 'Nav: switch to tab 3 blocked by navChange.preventDefault()';
    }
  }

  void selectSecond() {
    activeId = 2;
    eventLog = _isPt
        ? 'Nav: seleção programática da aba 2'
        : 'Nav: programmatic selection of tab 2';
  }

  void selectDisabled() {
    activeId = 3;
    eventLog = _isPt
        ? 'Nav: seleção programática da aba desabilitada'
        : 'Nav: programmatic selection of the disabled tab';
  }
}

class NavShowcaseItem {
  const NavShowcaseItem({
    required this.id,
    required this.title,
    required this.body,
    this.disabled = false,
  });

  final Object id;
  final String title;
  final String body;
  final bool disabled;
}
