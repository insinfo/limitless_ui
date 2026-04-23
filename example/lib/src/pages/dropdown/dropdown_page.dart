import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'dropdown-page',
  templateUrl: 'dropdown_page.html',
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiDropdownDirective,
    LiDropdownAnchorDirective,
    LiDropdownToggleDirective,
    LiDropdownMenuDirective,
    LiDropdownMenuComponent,
    LiDropdownSubmenuDirective,
    LiDropdownSubmenuToggleDirective,
    LiDropdownSubmenuMenuDirective,
    LiDropdownItemDirective,
    LiDropdownButtonItemDirective,
  ],
)
class DropdownPageComponent {
  DropdownPageComponent(this.i18n) {
    dropdownState = waitingState;
  }

  static const String basicApiSnippet = '''
<div liDropdown>
  <button liDropdownToggle>Actions</button>
  <div liDropdownMenu>
    <button liDropdownItem>View details</button>
    <button liDropdownItem>Archive</button>
  </div>
</div>''';

  static const String bodyApiSnippet = '''
<div liDropdown autoClose="inside" container="body">
  <button liDropdownToggle>Open on body</button>
  <div liDropdownMenu>
    <button liDropdownItem>Item 1</button>
    <button liDropdownItem [disabled]="true">Disabled</button>
  </div>
</div>''';

  static const String manualApiSnippet = '''
<div liDropdown #drop="liDropdown" [autoClose]="false">
  <button liDropdownAnchor>Anchor only</button>
  <button type="button" (click)="drop.toggle()">Toggle by API</button>
  <div liDropdownMenu>
    <button liDropdownItem (click)="drop.close()">Close</button>
  </div>
</div>''';

  static const String compactMenuApiSnippet = '''
<li-dropdown-menu
  [options]="primaryOptions"
  triggerLabel="Filters"
  triggerIconClass="ph-funnel"
  container="inline"
  [closeOtherMenusOnOpen]="false"
  (valueChange)="onCompactMenuAction(\$event)">
</li-dropdown-menu>

<li-dropdown-menu
  [options]="secondaryOptions"
  triggerLabel="Columns"
  triggerIconClass="ph-sliders-horizontal"
  container="inline"
  [closeOtherMenusOnOpen]="false"
  (valueChange)="onCompactMenuAction(\$event)">
</li-dropdown-menu>''';

  static const String submenuApiSnippet = '''
<div liDropdown>
  <button liDropdownToggle>Conta</button>
  <div class="dropdown-menu-end" liDropdownMenu>
    <button liDropdownItem>Seu CGM: 140050</button>

    <div liDropdownSubmenu placement="start">
      <button liDropdownItem liDropdownSubmenuToggle>
        Tema
      </button>

      <div liDropdownSubmenuMenu>
        <button liDropdownItem>Tema claro</button>
        <button liDropdownItem>Tema escuro</button>
      </div>
    </div>
  </div>
</div>''';

  final DemoI18nService i18n;
  bool get _isPt => i18n.isPortuguese;

  String dropdownState = '';
  String compactMenuState = '';
  String submenuState = '';
  String selectedSubmenuTheme = 'light';
  bool showDemoStatusBar = true;

  List<LiDropdownMenuOption> get primaryCompactMenuOptions => _isPt
      ? const <LiDropdownMenuOption>[
          LiDropdownMenuOption(
            value: 'pending',
            label: 'Pendentes',
            description: 'Atalha o recorte principal',
            iconClass: 'ph-clock-countdown',
          ),
          LiDropdownMenuOption(
            value: 'review',
            label: 'Em revisão',
            description: 'Fluxos aguardando decisão',
            iconClass: 'ph-eye',
          ),
        ]
      : const <LiDropdownMenuOption>[
          LiDropdownMenuOption(
            value: 'pending',
            label: 'Pending',
            description: 'Shortcuts the main filter slice',
            iconClass: 'ph-clock-countdown',
          ),
          LiDropdownMenuOption(
            value: 'review',
            label: 'In review',
            description: 'Flows waiting for a decision',
            iconClass: 'ph-eye',
          ),
        ];

  List<LiDropdownMenuOption> get secondaryCompactMenuOptions => _isPt
      ? const <LiDropdownMenuOption>[
          LiDropdownMenuOption(
            value: 'owner',
            label: 'Responsável',
            description: 'Mostra a coluna de ownership',
            iconClass: 'ph-user-circle',
          ),
          LiDropdownMenuOption(
            value: 'deadline',
            label: 'Prazo',
            description: 'Mantém o SLA visível',
            iconClass: 'ph-calendar-blank',
          ),
        ]
      : const <LiDropdownMenuOption>[
          LiDropdownMenuOption(
            value: 'owner',
            label: 'Owner',
            description: 'Keeps the ownership column visible',
            iconClass: 'ph-user-circle',
          ),
          LiDropdownMenuOption(
            value: 'deadline',
            label: 'Deadline',
            description: 'Keeps the SLA visible',
            iconClass: 'ph-calendar-blank',
          ),
        ];

  String get pageTitle => _isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'Dropdown';
  String get breadcrumb => _isPt
      ? 'Toggle, menu, itens e navegação por teclado'
      : 'Toggle, menu, items, and keyboard navigation';
  String get overviewIntro => _isPt
      ? 'O dropdown declarativo cobre abertura controlada, fechamento interno ou externo, navegação por setas, Home, End e suporte a container="body".'
      : 'The declarative dropdown covers controlled opening, inside or outside closing, arrow navigation, Home, End, and container="body" support.';
  String get descriptionBody => _isPt
      ? 'Use liDropdown no host, liDropdownToggle no gatilho, liDropdownMenu no menu e liDropdownItem nos itens focáveis.'
      : 'Use liDropdown on the host, liDropdownToggle on the trigger, liDropdownMenu on the menu, and liDropdownItem on focusable items.';
  List<String> get features => _isPt
      ? const <String>[
          'open(), close() e toggle() via API.',
          'autoClose com modos true, false, inside e outside.',
          'Posicionamento com Popper e fallback para navbar estática.',
        ]
      : const <String>[
          'open(), close(), and toggle() through the API.',
          'autoClose with true, false, inside, and outside modes.',
          'Positioning with Popper and fallback for static navbar usage.',
        ];
  List<String> get limits => _isPt
      ? const <String>[
          'O demo foca o comportamento estrutural do dropdown.',
          'Itens desabilitados saem da navegação por teclado.',
          'Menus muito complexos ainda podem pedir componentização própria.',
        ]
      : const <String>[
          'The demo focuses on the dropdown structural behavior.',
          'Disabled items are removed from keyboard navigation.',
          'Very complex menus may still require their own componentization.',
        ];
  String get defaultTitle => _isPt ? 'Dropdown padrão' : 'Default dropdown';
  String get defaultBody => _isPt
      ? 'Abertura simples com foco por teclado nos itens do menu.'
      : 'Simple opening with keyboard focus on menu items.';
  String get actionsButton => _isPt ? 'Ações' : 'Actions';
  String get viewDetailsLabel => _isPt ? 'Ver detalhes' : 'View details';
  String get duplicateLabel => _isPt ? 'Duplicar' : 'Duplicate';
  String get disabledActionLabel => _isPt ? 'Ação desabilitada' : 'Disabled action';
  String get archiveLabel => _isPt ? 'Arquivar' : 'Archive';
  String get manualTitle => _isPt ? 'Gatilhos manuais e customizados' : 'Manual and custom triggers';
  String get manualBody => _isPt
      ? 'A âncora visual pode ser separada do fluxo de toggle quando você quer controlar a abertura por API.'
      : 'The visual anchor can be separated from the toggle flow when you want to control opening through the API.';
  String get anchorOnlyLabel => _isPt ? 'Somente âncora' : 'Anchor only';
  String get toggleByApiLabel => _isPt ? 'Alternar por API' : 'Toggle by API';
  String get closeFromItemLabel => _isPt ? 'Fechar pelo item' : 'Close from item';
  String get persistentMenuLabel => _isPt ? 'Menu persistente' : 'Persistent menu';
  String get insideTitle => 'autoClose inside';
  String get insideBody => _isPt
      ? 'O menu abaixo ignora clique externo e só fecha quando o clique acontece dentro do próprio menu.'
      : 'The menu below ignores outside clicks and closes only when the click happens inside the menu itself.';
  String get insideCloseLabel => _isPt ? 'Fechar por dentro' : 'Inside close';
  String get saveLabel => _isPt ? 'Salvar' : 'Save';
  String get publishLabel => _isPt ? 'Publicar' : 'Publish';
  String get containerBodyTitle => _isPt ? 'Container body' : 'Container body';
  String get containerBodyText => _isPt
      ? 'Quando existe clipping local, o menu pode ser anexado diretamente ao body.'
      : 'When there is local clipping, the menu can be attached directly to the body.';
  String get openOnBodyLabel => _isPt ? 'Abrir no body' : 'Open on body';
  String get escapesClippingLabel => _isPt ? 'Escapa do clipping local' : 'Escapes local clipping';
  String get usefulInCardsLabel => _isPt ? 'Útil em cards e grids' : 'Useful in cards and grids';
  String get dropupTitle => 'Dropup';
  String get dropupBody => _isPt
      ? 'A primeira placement começando por top troca a classe do host para dropup.'
      : 'The first placement starting with top switches the host class to dropup.';
  String get dropupMenuLabel => _isPt ? 'Menu dropup' : 'Dropup menu';
  String get topAlignedLabel => _isPt ? 'Alinhado ao topo' : 'Top aligned';
  String get goodForFootersLabel => _isPt ? 'Bom para rodapés compactos' : 'Good for tight footers';
  String get navbarTitle => _isPt ? 'Exibição estática em navbar' : 'Static display in navbar';
  String get navbarBody => _isPt
      ? 'Dentro de navbar, o display padrão vira estático para preservar o comportamento responsivo.'
      : 'Inside a navbar, the default display becomes static to preserve responsive behavior.';
  String get compactMenuTitle =>
      _isPt ? 'li-dropdown-menu coexistindo' : 'Coexisting li-dropdown-menu';
  String get compactMenuBody => _isPt
      ? 'Por padrão, abrir um li-dropdown-menu fecha os demais. Aqui a flag closeOtherMenusOnOpen=false fica explícita para casos especiais, como filtros e colunas que precisam permanecer abertos ao mesmo tempo.'
      : 'By default, opening one li-dropdown-menu closes the others. Here closeOtherMenusOnOpen=false is explicit for special cases, such as filters and columns that must remain open at the same time.';
  String get compactMenuUseCase => _isPt
      ? 'Use isso com parcimônia: faz sentido para barras densas, submenus compostos e controles coordenados. Para headers comuns, mantenha o padrão.'
      : 'Use it sparingly: it makes sense for dense toolbars, composed submenus, and coordinated controls. For regular headers, keep the default behavior.';
  String get filtersMenuLabel => _isPt ? 'Filtros' : 'Filters';
  String get columnsMenuLabel => _isPt ? 'Colunas' : 'Columns';
  String get compactMenuStateTitle =>
      _isPt ? 'Última ação dos menus compactos' : 'Last compact menu action';
  String get compactMenuWaitingState => _isPt
      ? 'Menus compactos: aguardando interação'
      : 'Compact menus: waiting for interaction';
  String get navbarDropdownLabel => _isPt ? 'Dropdown da navbar' : 'Navbar dropdown';
  String get profileLabel => _isPt ? 'Perfil' : 'Profile';
  String get billingLabel => _isPt ? 'Cobrança' : 'Billing';
    String get submenuTitle => _isPt
      ? 'Menu de usuário com submenu'
      : 'User menu with submenu';
    String get submenuBody => _isPt
      ? 'Este exemplo reproduz um menu de conta com submenu lateral usando as diretivas de submenu sobre a API declarativa de liDropdown.'
      : 'This example reproduces an account menu with a side submenu using the submenu directives on top of the declarative liDropdown API.';
    String get accountMenuLabel => _isPt ? 'Conta do usuário' : 'User account';
    String get demoUserName => 'Isaque Neves Sant\'Ana';
    String get userCgmLabel => _isPt ? 'Seu CGM: 140050' : 'Your CGM: 140050';
    String get loggedAsLabel => _isPt ? 'Logado como: Portal Integrado' : 'Logged in as: Integrated Portal';
    String get toggleStatusBarLabel => _isPt
      ? 'Exibir Status bar'
      : 'Show status bar';
    String get themeMenuLabel => _isPt ? 'Tema' : 'Theme';
    String get lightThemeLabel => _isPt ? 'Tema claro' : 'Light theme';
    String get mediumThemeLabel => _isPt ? 'Tema médio' : 'Medium theme';
    String get darkThemeLabel => _isPt ? 'Tema escuro' : 'Dark theme';
    String get pinkThemeLabel => _isPt ? 'Tema rosa' : 'Pink theme';
    String get sessionIsolationLabel => _isPt
      ? 'Obs.: abas no mesmo perfil compartilham sessão. Para usuários diferentes simultâneos, use perfis separados ou janela anônima.'
      : 'Note: tabs in the same browser profile share the session. For simultaneous different users, use separate profiles or an incognito window.';
    String get signOutLabel => _isPt ? 'Sair' : 'Sign out';
    String get submenuStateTitle => _isPt
      ? 'Estado do menu de usuário'
      : 'User menu state';
    String get submenuStateSummary {
    final themeLabel = switch (selectedSubmenuTheme) {
      'medium' => mediumThemeLabel,
      'dark' => darkThemeLabel,
      'pink' => pinkThemeLabel,
      _ => lightThemeLabel,
    };

    if (_isPt) {
      return 'Tema ativo: $themeLabel. Status bar: '
        '${showDemoStatusBar ? 'visível' : 'oculta'}. '
        '${submenuState.isEmpty ? 'Aguardando interação.' : submenuState}';
    }

    return 'Active theme: $themeLabel. Status bar: '
      '${showDemoStatusBar ? 'visible' : 'hidden'}. '
      '${submenuState.isEmpty ? 'Waiting for interaction.' : submenuState}';
    }
  String get currentStateTitle => _isPt ? 'Estado atual' : 'Current state';
  String get apiIntro => _isPt
      ? 'A API pública separa claramente host, âncora, toggle, menu, item navegável e agora também submenu reutilizável.'
      : 'The public API clearly separates host, anchor, toggle, menu, navigable item, and now also a reusable submenu layer.';
  List<String> get apiItems => _isPt
      ? const <String>[
          'liDropdown controla estado aberto, autoClose, placement e container.',
          'liDropdownAnchor fornece a âncora visual sem alternar o estado por clique.',
          'liDropdownToggle alterna o menu por clique e por teclado.',
          'liDropdownMenu recebe classes de menu e delega a navegação por teclado.',
          'liDropdownItem marca itens focáveis e retira itens desabilitados da rotação.',
        'liDropdownSubmenu, liDropdownSubmenuToggle e liDropdownSubmenuMenu permitem submenus reaproveitáveis sem fechar o dropdown pai ao acionar o toggle do submenu.',
          'li-dropdown-menu usa listas de opções prontas e fecha outras instâncias por padrão, com opt-out via closeOtherMenusOnOpen.',
        ]
      : const <String>[
          'liDropdown controls open state, autoClose, placement, and container.',
          'liDropdownAnchor provides the visual anchor without toggling the state on click.',
          'liDropdownToggle toggles the menu by click and keyboard.',
          'liDropdownMenu receives menu classes and delegates keyboard navigation.',
          'liDropdownItem marks focusable items and removes disabled items from rotation.',
        'liDropdownSubmenu, liDropdownSubmenuToggle, and liDropdownSubmenuMenu provide reusable submenus without collapsing the parent dropdown when the submenu toggle is activated.',
          'li-dropdown-menu uses ready-made option lists and closes other instances by default, with an opt-out through closeOtherMenusOnOpen.',
        ];
  String get waitingState => _isPt ? 'Dropdown: aguardando interação' : 'Dropdown: waiting for interaction';
  String get openedState => _isPt ? 'Dropdown: menu aberto' : 'Dropdown: menu open';
  String get closedState => _isPt ? 'Dropdown: menu fechado' : 'Dropdown: menu closed';

  void onOpenChange(bool open) {
    dropdownState = open ? openedState : closedState;
  }

  void onCompactMenuAction(String value) {
    compactMenuState = _isPt
        ? 'Menus compactos: ação "$value" disparada.'
        : 'Compact menus: "$value" action fired.';
  }

  void toggleDemoStatusBar() {
    showDemoStatusBar = !showDemoStatusBar;
    submenuState = _isPt
        ? 'Status bar ${showDemoStatusBar ? 'ativada' : 'desativada'}.'
        : 'Status bar ${showDemoStatusBar ? 'enabled' : 'disabled'}.';
  }

  void onDemoThemeSelected(String value) {
    selectedSubmenuTheme = value;
    submenuState = _isPt
        ? 'Tema "$value" selecionado no submenu.'
        : 'Theme "$value" selected from the submenu.';
  }

  void onDemoSignOut() {
    submenuState = _isPt
        ? 'Ação de saída disparada.'
        : 'Sign out action triggered.';
  }
}
