import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'scrollspy-page',
  templateUrl: 'scrollspy_page.html',
  styleUrls: ['scrollspy_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiScrollSpyDirective,
    LiScrollSpyFragmentDirective,
    LiScrollSpyItemDirective,
    LiScrollSpyMenuDirective,
  ],
)
class ScrollspyPageComponent {
  ScrollspyPageComponent(this.i18n);

  final DemoI18nService i18n;
  bool get _isPt => i18n.isPortuguese;

  @ViewChild('demoSpy')
  LiScrollSpyDirective? demoSpy;

  String activeSection = 'overview';

  String get pageTitle => _isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'Scrollspy';
  String get breadcrumb => _isPt
    ? 'Service, diretivas e menu ativo'
    : 'Service, directives, and active menu';
  String get overviewIntro => _isPt
    ? 'O scrollspy acompanha a rolagem de um container, atualiza o fragmento ativo e sincroniza menus simples ou hierárquicos.'
    : 'Scrollspy follows a container scroll position, updates the active fragment, and synchronizes simple or hierarchical menus.';
  String get syncedMenuTitle => _isPt ? 'Menu sincronizado' : 'Synchronized menu';
  String get syncedMenuBody => _isPt
    ? 'Os itens usam liScrollSpyItem e herdam o estado ativo do menu.'
    : 'Items use liScrollSpyItem and inherit the active state from the menu.';
  String get overviewLabel => 'Overview';
  String get serviceLabel => 'Service';
  String get directiveLabel => _isPt ? 'Diretiva' : 'Directive';
  String get itemsLabel => _isPt ? 'Itens em destaque' : 'Highlighting items';
  String get customizationLabel => _isPt ? 'Customização' : 'Customization';
  String get activeNowLabel => _isPt ? 'Ativo agora' : 'Active now';
  String get goToServiceLabel => _isPt ? 'Ir para service' : 'Go to service';
  String get goToCustomizationLabel =>
    _isPt ? 'Ir para customization' : 'Go to customization';
  String get observedContainerTitle => _isPt ? 'Container observado' : 'Observed container';
  String get observedContainerBody => _isPt
    ? 'A diretiva abaixo observa a rolagem local do painel e emite activeChange.'
    : 'The directive below observes the panel local scroll and emits activeChange.';
  String get basicServiceTitle => _isPt ? 'Service básico' : 'Basic service';
  String get basicServiceBody1 => _isPt
    ? 'O serviço pode observar fragments por id, iniciar quando o container estiver pronto e publicar o fragmento ativo para qualquer menu ou painel auxiliar.'
    : 'The service can observe fragments by id, start when the container is ready, and publish the active fragment to any menu or auxiliary panel.';
  String get basicServiceBody2 => _isPt
    ? 'Essa versão usa um algoritmo configurável e leve, adequado para containers locais em dashboards, sidebars de documentação e áreas de preview.'
    : 'This version uses a configurable lightweight algorithm suitable for local containers in dashboards, documentation sidebars, and preview areas.';
  String get imperativeApiTitle => _isPt ? 'API imperativa' : 'Imperative API';
  String get imperativeApiBody1 => _isPt
    ? 'scrollTo() permite navegar programaticamente para um fragmento, enquanto observe() e unobserve() controlam quais seções participam do cálculo.'
    : 'scrollTo() lets you navigate programmatically to a fragment, while observe() and unobserve() control which sections participate in the calculation.';
  String get imperativeApiBody2 => _isPt
    ? 'Isso cobre o caso de páginas com conteúdo montado dinamicamente ou quando você quer integrar o scrollspy com botões externos ao menu.'
    : 'This covers pages with dynamically assembled content or cases where you want to integrate scrollspy with buttons outside the menu.';
  String get directiveSugarTitle => _isPt ? 'Açúcar sintático por diretiva' : 'Directive sugar';
  String get directiveSugarBody1 => _isPt
    ? 'liScrollSpy instancia o serviço no container, registra fragments filhos e faz o cleanup automaticamente quando a view some.'
    : 'liScrollSpy instantiates the service on the container, registers child fragments, and cleans up automatically when the view disappears.';
  String get directiveSugarBody2 => _isPt
    ? 'O fragmento ativo também pode ser refletido via active, active\$ e (activeChange).'
    : 'The active fragment can also be reflected through active, active\$, and (activeChange).';
  String get highlightingTitle => _isPt ? 'Itens em destaque' : 'Highlighting active items';
  String get highlightingBody1 => _isPt
    ? 'Itens ligados por liScrollSpyItem recebem .active automaticamente e podem disparar a navegação do próprio fragmento ao clique.'
    : 'Items bound through liScrollSpyItem receive .active automatically and can trigger navigation to their own fragment on click.';
  String get highlightingBody2 => _isPt
    ? 'Menus simples e aninhados usam a mesma base, então a API fica consistente para pills, listas laterais e índices de documentação.'
    : 'Simple and nested menus use the same base, so the API stays consistent for pills, side lists, and documentation indexes.';
  String get customizationBody1 => _isPt
    ? 'Você pode trocar o algoritmo com processChanges, ajustar rootMargin e definir o comportamento padrão de rolagem via LiScrollSpyConfig.'
    : 'You can replace the algorithm with processChanges, adjust rootMargin, and define default scroll behavior through LiScrollSpyConfig.';
  String get customizationBody2 => _isPt
    ? 'Isso é útil quando o topo visual da área observada não coincide com o topo físico do container ou quando a página tem header fixo.'
    : 'This is useful when the observed area visual top does not match the physical container top or when the page has a fixed header.';
  String get apiIntro => _isPt
    ? 'A API pública segue a mesma ideia do ng-bootstrap: container, fragments, items, menu hierárquico e um serviço compartilhado.'
    : 'The public API follows the same idea as ng-bootstrap: container, fragments, items, hierarchical menu, and a shared service.';
  List<String> get apiItems => _isPt
    ? const <String>[
      'liScrollSpy instancia e exporta o controller do container.',
      'liScrollSpyFragment define seções observadas com id único.',
      'liScrollSpyItem sincroniza navegação e classe active.',
      'liScrollSpyMenu propaga o ativo para a branch inteira em menus aninhados.',
      'LiScrollSpyConfig fornece defaults para algoritmo e comportamento de rolagem.',
    ]
    : const <String>[
      'liScrollSpy instantiates and exports the container controller.',
      'liScrollSpyFragment defines observed sections with a unique id.',
      'liScrollSpyItem synchronizes navigation and the active class.',
      'liScrollSpyMenu propagates the active state through the entire branch in nested menus.',
      'LiScrollSpyConfig provides defaults for the algorithm and scroll behavior.',
    ];

  void onActiveChange(String fragment) {
    activeSection = fragment.isEmpty ? 'overview' : fragment;
  }

  void scrollToFragment(String fragment) {
    demoSpy?.scrollTo(fragment,
        options: const LiScrollToOptions(behavior: 'auto'));
  }
}
