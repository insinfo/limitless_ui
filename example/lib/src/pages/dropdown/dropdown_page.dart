import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'dropdown-page',
  templateUrl: 'dropdown_page.html',
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiDropdownDirective,
    LiDropdownAnchorDirective,
    LiDropdownToggleDirective,
    LiDropdownMenuDirective,
    LiDropdownItemDirective,
    LiDropdownButtonItemDirective,
  ],
)
class DropdownPageComponent {
  DropdownPageComponent(this.i18n) {
    dropdownState = waitingState;
  }

  final DemoI18nService i18n;
  bool get _isPt => i18n.isPortuguese;

  String dropdownState = '';

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
  String get navbarDropdownLabel => _isPt ? 'Dropdown da navbar' : 'Navbar dropdown';
  String get profileLabel => _isPt ? 'Perfil' : 'Profile';
  String get billingLabel => _isPt ? 'Cobrança' : 'Billing';
  String get currentStateTitle => _isPt ? 'Estado atual' : 'Current state';
  String get apiIntro => _isPt
      ? 'A API pública separa claramente host, âncora, toggle, menu e item navegável.'
      : 'The public API clearly separates host, anchor, toggle, menu, and navigable item.';
  List<String> get apiItems => _isPt
      ? const <String>[
          'liDropdown controla estado aberto, autoClose, placement e container.',
          'liDropdownAnchor fornece a âncora visual sem alternar o estado por clique.',
          'liDropdownToggle alterna o menu por clique e por teclado.',
          'liDropdownMenu recebe classes de menu e delega a navegação por teclado.',
          'liDropdownItem marca itens focáveis e retira itens desabilitados da rotação.',
        ]
      : const <String>[
          'liDropdown controls open state, autoClose, placement, and container.',
          'liDropdownAnchor provides the visual anchor without toggling the state on click.',
          'liDropdownToggle toggles the menu by click and keyboard.',
          'liDropdownMenu receives menu classes and delegates keyboard navigation.',
          'liDropdownItem marks focusable items and removes disabled items from rotation.',
        ];
  String get waitingState => _isPt ? 'Dropdown: aguardando interação' : 'Dropdown: waiting for interaction';
  String get openedState => _isPt ? 'Dropdown: menu aberto' : 'Dropdown: menu open';
  String get closedState => _isPt ? 'Dropdown: menu fechado' : 'Dropdown: menu closed';

  void onOpenChange(bool open) {
    dropdownState = open ? openedState : closedState;
  }
}
