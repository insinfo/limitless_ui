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
  Object activeId = 1;
  Object verticalActiveId = 'overview';
  String eventLog = 'Nav: aguardando interação';

  final List<NavShowcaseItem> dynamicItems = <NavShowcaseItem>[
    const NavShowcaseItem(
      id: 1,
      title: 'Overview',
      body: 'Resumo curto do fluxo com uma aba inicial ativa por padrão.',
    ),
    const NavShowcaseItem(
      id: 2,
      title: 'Usage',
      body: 'O container controla seleção, teclado e a região de conteúdo.',
    ),
    const NavShowcaseItem(
      id: 3,
      title: 'Disabled',
      body: 'Abas desabilitadas continuam selecionáveis apenas por API.',
      disabled: true,
    ),
  ];

  void onNavChanged(Object? id) {
    eventLog = 'Nav: activeId mudou para $id';
  }

  void onActiveIdChange(Object? id) {
    activeId = id ?? activeId;
    onNavChanged(activeId);
  }

  void onNavPrevented(LiNavChangeEvent event) {
    if (event.nextId == 3) {
      event.preventDefault();
      eventLog =
          'Nav: troca para a aba 3 bloqueada por navChange.preventDefault()';
    }
  }

  void selectSecond() {
    activeId = 2;
    eventLog = 'Nav: seleção programática da aba 2';
  }

  void selectDisabled() {
    activeId = 3;
    eventLog = 'Nav: seleção programática da aba desabilitada';
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
