import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'disclosure-page',
  templateUrl: 'disclosure_page.html',
  styleUrls: ['disclosure_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiAccordionComponent,
    LiAccordionItemComponent,
    LiModalComponent,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class DisclosurePageComponent {
  DisclosurePageComponent(this.i18n);

  final DemoI18nService i18n;
  bool get _isPt => i18n.isPortuguese;

  @ViewChild('demoModal')
  LiModalComponent? demoModal;

  String get pageTitle => _isPt ? 'Components' : 'Components';
  String get pageSubtitle => _isPt ? 'Disclosure' : 'Disclosure';
  String get breadcrumb => _isPt ? 'Accordion, tabs e modal' : 'Accordion, tabs, and modal';
  String get overviewTab => _isPt ? 'Visão geral' : 'Overview';
  String get examplesTab => _isPt ? 'Exemplos' : 'Examples';
  String get intro => _isPt
      ? 'Disclosure reúne padrões de revelar conteúdo sob demanda, combinando accordion, tabs e modal em um único fluxo.'
      : 'Disclosure brings together on-demand content reveal patterns, combining accordion, tabs, and modal in a single flow.';
  String get accordionTitle => 'Accordion';
  String get accordionBody => _isPt
      ? 'Exemplos com allowMultipleOpen, item expandido por padrão e estrutura parecida com a documentação do Limitless.'
      : 'Examples with allowMultipleOpen, a default expanded item, and a structure close to the Limitless documentation.';
  String get collapsedStateTitle => _isPt ? 'Estado recolhido' : 'Collapsed state';
  String get collapsedStateDescription => _isPt ? 'Começa fechado e expande sob demanda.' : 'Starts closed and expands on demand.';
  String get collapsedStateBody => _isPt ? 'Ideal para listas longas que precisam manter foco visual.' : 'Ideal for long lists that need to preserve visual focus.';
  String get expandedStateTitle => _isPt ? 'Estado expandido' : 'Expanded state';
  String get expandedStateDescription => _isPt ? 'Item inicial aberto.' : 'Initially open item.';
  String get expandedStateBody => _isPt ? 'Defina expanded=true no item que precisa abrir ao carregar.' : 'Set expanded=true on the item that must open on load.';
  String get alwaysOpenTitle => _isPt ? 'Sempre aberto' : 'Always open';
  String get alwaysOpenDescription => _isPt ? 'Permite comparar seções ao mesmo tempo.' : 'Allows comparing sections at the same time.';
  String get alwaysOpenBody => _isPt ? 'Ative allowMultipleOpen=true no container principal.' : 'Enable allowMultipleOpen=true on the main container.';
  String get tabsModalTitle => _isPt ? 'Tabs e modal' : 'Tabs and modal';
  String get tokensTab => _isPt ? 'Tokens' : 'Tokens';
  String get tokensBody => _isPt ? 'Use tabs para separar documentação, exemplos e notas de API no mesmo card.' : 'Use tabs to separate documentation, examples, and API notes inside the same card.';
  String get flowTab => _isPt ? 'Fluxo' : 'Flow';
  String get flowBody => _isPt ? 'O componente respeita a composição do Bootstrap/Limitless e se encaixa bem em layouts administrativos.' : 'The component respects Bootstrap/Limitless composition and fits well in administrative layouts.';
  String get actionsTab => _isPt ? 'Ações' : 'Actions';
  String get openModalLabel => _isPt ? 'Abrir modal' : 'Open modal';
  String get modalTitle => _isPt ? 'Exemplo de modal' : 'Modal example';
  String get modalHeading => _isPt ? 'Composição padronizada' : 'Standardized composition';
  String get modalBody => _isPt ? 'O modal reaproveita a camada visual do Limitless e pode hospedar formulários curtos, confirmações ou visualizações detalhadas.' : 'The modal reuses the Limitless visual layer and can host short forms, confirmations, or detailed views.';
  String get closeLabel => _isPt ? 'Fechar' : 'Close';

  void openModal() {
    demoModal?.open();
  }
}
