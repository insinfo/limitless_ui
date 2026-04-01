// GENERATED FILE, do not edit!
// ignore_for_file: annotate_overrides, non_constant_identifier_names, prefer_single_quotes, unused_element, unused_field
import 'package:i18n/i18n.dart' as i18n;

String get _languageCode => 'en';
String _plural(
  int count, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) =>
    i18n.plural(
      count,
      _languageCode,
      zero: zero,
      one: one,
      two: two,
      few: few,
      many: many,
      other: other,
    );
String _ordinal(
  int count, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) =>
    i18n.ordinal(
      count,
      _languageCode,
      zero: zero,
      one: one,
      two: two,
      few: few,
      many: many,
      other: other,
    );
String _cardinal(
  int count, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) =>
    i18n.cardinal(
      count,
      _languageCode,
      zero: zero,
      one: one,
      two: two,
      few: few,
      many: many,
      other: other,
    );

class Messages {
  const Messages();
  String get locale => "en";
  String get languageCode => "en";
  AppMessages get app => AppMessages(this);
  NavMessages get nav => NavMessages(this);
  CommonMessages get common => CommonMessages(this);
  PagesMessages get pages => PagesMessages(this);
}

class AppMessages {
  final Messages _parent;
  const AppMessages(this._parent);

  /// ```dart
  /// "Limitless UI Example"
  /// ```
  String get brand => """Limitless UI Example""";

  /// ```dart
  /// "Documentação viva do pacote"
  /// ```
  String get searchPlaceholder => """Documentação viva do pacote""";

  /// ```dart
  /// "AngularDart + Limitless"
  /// ```
  String get badge => """AngularDart + Limitless""";

  /// ```dart
  /// "Navegação"
  /// ```
  String get navigation => """Navegação""";

  /// ```dart
  /// "Exemplo com ngrouter e componentes reais do pacote."
  /// ```
  String get navigationHelp =>
      """Exemplo com ngrouter e componentes reais do pacote.""";

  /// ```dart
  /// "Componentes"
  /// ```
  String get components => """Componentes""";

  /// ```dart
  /// "Idioma"
  /// ```
  String get language => """Idioma""";

  /// ```dart
  /// "Português"
  /// ```
  String get portuguese => """Português""";

  /// ```dart
  /// "Inglês"
  /// ```
  String get english => """Inglês""";

  /// ```dart
  /// "Tema"
  /// ```
  String get theme => """Tema""";

  /// ```dart
  /// "Claro"
  /// ```
  String get light => """Claro""";

  /// ```dart
  /// "Escuro"
  /// ```
  String get dark => """Escuro""";

  /// ```dart
  /// "Auto"
  /// ```
  String get auto => """Auto""";
}

class NavMessages {
  final Messages _parent;
  const NavMessages(this._parent);

  /// ```dart
  /// "Visão geral"
  /// ```
  String get overview => """Visão geral""";

  /// ```dart
  /// "Alertas"
  /// ```
  String get alerts => """Alertas""";

  /// ```dart
  /// "Progresso"
  /// ```
  String get progress => """Progresso""";

  /// ```dart
  /// "Acordeão"
  /// ```
  String get accordion => """Acordeão""";

  /// ```dart
  /// "Abas"
  /// ```
  String get tabs => """Abas""";

  /// ```dart
  /// "Modal"
  /// ```
  String get modal => """Modal""";

  /// ```dart
  /// "Select"
  /// ```
  String get select => """Select""";

  /// ```dart
  /// "Multi Select"
  /// ```
  String get multiSelect => """Multi Select""";

  /// ```dart
  /// "Moeda"
  /// ```
  String get currency => """Moeda""";

  /// ```dart
  /// "Date Picker"
  /// ```
  String get datePicker => """Date Picker""";

  /// ```dart
  /// "Time Picker"
  /// ```
  String get timePicker => """Time Picker""";

  /// ```dart
  /// "Intervalo de datas"
  /// ```
  String get dateRange => """Intervalo de datas""";

  /// ```dart
  /// "Carousel"
  /// ```
  String get carousel => """Carousel""";

  /// ```dart
  /// "Tooltip"
  /// ```
  String get tooltip => """Tooltip""";

  /// ```dart
  /// "Datatable"
  /// ```
  String get datatable => """Datatable""";

  /// ```dart
  /// "Datatable Select"
  /// ```
  String get datatableSelect => """Datatable Select""";

  /// ```dart
  /// "Notificação"
  /// ```
  String get notification => """Notificação""";

  /// ```dart
  /// "Treeview"
  /// ```
  String get treeview => """Treeview""";

  /// ```dart
  /// "Utilitários"
  /// ```
  String get helpers => """Utilitários""";

  /// ```dart
  /// "Botões"
  /// ```
  String get button => """Botões""";
}

class CommonMessages {
  final Messages _parent;
  const CommonMessages(this._parent);

  /// ```dart
  /// "Restaurar alerta"
  /// ```
  String get restoreAlert => """Restaurar alerta""";

  /// ```dart
  /// "Nenhum"
  /// ```
  String get none => """Nenhum""";

  /// ```dart
  /// "Abrir"
  /// ```
  String get open => """Abrir""";

  /// ```dart
  /// "Fechar"
  /// ```
  String get close => """Fechar""";

  /// ```dart
  /// "Status"
  /// ```
  String get status => """Status""";

  /// ```dart
  /// "Período atual"
  /// ```
  String get currentPeriod => """Período atual""";

  /// ```dart
  /// "Janela restrita"
  /// ```
  String get restrictedWindow => """Janela restrita""";
}

class PagesMessages {
  final Messages _parent;
  const PagesMessages(this._parent);
  OverviewPagesMessages get overview => OverviewPagesMessages(this);
  AlertsPagesMessages get alerts => AlertsPagesMessages(this);
  AccordionPagesMessages get accordion => AccordionPagesMessages(this);
  ProgressPagesMessages get progress => ProgressPagesMessages(this);
  TabsPagesMessages get tabs => TabsPagesMessages(this);
  ModalPagesMessages get modal => ModalPagesMessages(this);
  SelectPagesMessages get select => SelectPagesMessages(this);
  MultiSelectPagesMessages get multiSelect => MultiSelectPagesMessages(this);
  CurrencyPagesMessages get currency => CurrencyPagesMessages(this);
  DateRangePagesMessages get dateRange => DateRangePagesMessages(this);
  TimePickerPagesMessages get timePicker => TimePickerPagesMessages(this);
  DatePickerPagesMessages get datePicker => DatePickerPagesMessages(this);
  CarouselPagesMessages get carousel => CarouselPagesMessages(this);
  TooltipPagesMessages get tooltip => TooltipPagesMessages(this);
  DatatablePagesMessages get datatable => DatatablePagesMessages(this);
  NotificationPagesMessages get notification => NotificationPagesMessages(this);
  TreeviewPagesMessages get treeview => TreeviewPagesMessages(this);
  HelpersPagesMessages get helpers => HelpersPagesMessages(this);
  ButtonPagesMessages get button => ButtonPagesMessages(this);
}

class OverviewPagesMessages {
  final PagesMessages _parent;
  const OverviewPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Visão geral"
  /// ```
  String get subtitle => """Visão geral""";

  /// ```dart
  /// "Visão geral da biblioteca"
  /// ```
  String get breadcrumb => """Visão geral da biblioteca""";

  /// ```dart
  /// "Galeria executável para documentar componentes e configurações"
  /// ```
  String get heroTitle =>
      """Galeria executável para documentar componentes e configurações""";

  /// ```dart
  /// "Este example usa o tema Limitless no index.html, navega com ngrouter e renderiza componentes reais do pacote em cenários mais próximos do produto."
  /// ```
  String get heroLead =>
      """Este example usa o tema Limitless no index.html, navega com ngrouter e renderiza componentes reais do pacote em cenários mais próximos do produto.""";

  /// ```dart
  /// "Componentes"
  /// ```
  String get statComponentsLabel => """Componentes""";

  /// ```dart
  /// "Examples executáveis com API real do pacote."
  /// ```
  String get statComponentsHelp =>
      """Examples executáveis com API real do pacote.""";

  /// ```dart
  /// "Tema"
  /// ```
  String get statThemeLabel => """Tema""";

  /// ```dart
  /// "Layout e classes alinhados com o CSS do Limitless."
  /// ```
  String get statThemeHelp =>
      """Layout e classes alinhados com o CSS do Limitless.""";

  /// ```dart
  /// "Navegação"
  /// ```
  String get statNavigationLabel => """Navegação""";

  /// ```dart
  /// "Rotas explícitas para cada grupo da vitrine."
  /// ```
  String get statNavigationHelp =>
      """Rotas explícitas para cada grupo da vitrine.""";

  /// ```dart
  /// "Como a demo está organizada"
  /// ```
  String get organizationTitle => """Como a demo está organizada""";

  /// ```dart
  /// "Feedback"
  /// ```
  String get feedbackTitle => """Feedback""";

  /// ```dart
  /// "Alerts e progresso com variações visuais e estados."
  /// ```
  String get feedbackBody =>
      """Alerts e progresso com variações visuais e estados.""";

  /// ```dart
  /// "Disclosure"
  /// ```
  String get disclosureTitle => """Disclosure""";

  /// ```dart
  /// "Accordion, tabs e modal para estruturas expansíveis."
  /// ```
  String get disclosureBody =>
      """Accordion, tabs e modal para estruturas expansíveis.""";

  /// ```dart
  /// "Inputs"
  /// ```
  String get inputsTitle => """Inputs""";

  /// ```dart
  /// "Selects, date picker, time picker e date range picker ligados a estado real."
  /// ```
  String get inputsBody =>
      """Selects, date picker, time picker e date range picker ligados a estado real.""";

  /// ```dart
  /// "Showcase"
  /// ```
  String get showcaseTitle => """Showcase""";

  /// ```dart
  /// "Carousel, tooltip e datatable em layout editorial."
  /// ```
  String get showcaseBody =>
      """Carousel, tooltip e datatable em layout editorial.""";

  /// ```dart
  /// "Páginas em destaque"
  /// ```
  String get featureSectionTitle => """Páginas em destaque""";

  /// ```dart
  /// "Links diretos para telas reais da vitrine, sem cards fictícios."
  /// ```
  String get featureSectionBody =>
      """Links diretos para telas reais da vitrine, sem cards fictícios.""";

  /// ```dart
  /// "Date Picker"
  /// ```
  String get featureDatePickerTitle => """Date Picker""";

  /// ```dart
  /// "Página dedicada com variações, API e locale do seletor de data única."
  /// ```
  String get featureDatePickerBody =>
      """Página dedicada com variações, API e locale do seletor de data única.""";

  /// ```dart
  /// "Time Picker"
  /// ```
  String get featureTimePickerTitle => """Time Picker""";

  /// ```dart
  /// "Seletor de horário com dial, AM/PM e integração por ngModel."
  /// ```
  String get featureTimePickerBody =>
      """Seletor de horário com dial, AM/PM e integração por ngModel.""";

  /// ```dart
  /// "Intervalo de datas"
  /// ```
  String get featureDateRangeTitle => """Intervalo de datas""";

  /// ```dart
  /// "Fluxos de período com restrições, locale e API orientada a início e fim."
  /// ```
  String get featureDateRangeBody =>
      """Fluxos de período com restrições, locale e API orientada a início e fim.""";

  /// ```dart
  /// "Carousel"
  /// ```
  String get featureCarouselTitle => """Carousel""";

  /// ```dart
  /// "Transições, grid, captions e exemplos mais próximos do Limitless original."
  /// ```
  String get featureCarouselBody =>
      """Transições, grid, captions e exemplos mais próximos do Limitless original.""";

  /// ```dart
  /// "Datatable"
  /// ```
  String get featureDatatableTitle => """Datatable""";

  /// ```dart
  /// "Busca, seleção, exportação e alternância de visualização em dados reais."
  /// ```
  String get featureDatatableBody =>
      """Busca, seleção, exportação e alternância de visualização em dados reais.""";

  /// ```dart
  /// "Select"
  /// ```
  String get featureSelectTitle => """Select""";

  /// ```dart
  /// "Select simples com exemplos de projeção de conteúdo e fonte de dados."
  /// ```
  String get featureSelectBody =>
      """Select simples com exemplos de projeção de conteúdo e fonte de dados.""";

  /// ```dart
  /// "Abas"
  /// ```
  String get featureTabsTitle => """Abas""";

  /// ```dart
  /// "Estruturas em tabs e pills para organizar documentação e estados da interface."
  /// ```
  String get featureTabsBody =>
      """Estruturas em tabs e pills para organizar documentação e estados da interface.""";

  /// ```dart
  /// "Acordeão"
  /// ```
  String get featureAccordionTitle => """Acordeão""";

  /// ```dart
  /// "Itens expansíveis com lazy, destroyOnCollapse e headers customizados."
  /// ```
  String get featureAccordionBody =>
      """Itens expansíveis com lazy, destroyOnCollapse e headers customizados.""";

  /// ```dart
  /// "Utilitários"
  /// ```
  String get featureHelpersTitle => """Utilitários""";

  /// ```dart
  /// "Loading, dialogs, toasts e popovers prontos para uso."
  /// ```
  String get featureHelpersBody =>
      """Loading, dialogs, toasts e popovers prontos para uso.""";
}

class AlertsPagesMessages {
  final PagesMessages _parent;
  const AlertsPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Alertas"
  /// ```
  String get subtitle => """Alertas""";

  /// ```dart
  /// "Variações de alertas"
  /// ```
  String get breadcrumb => """Variações de alertas""";

  /// ```dart
  /// "Limite visual e estados"
  /// ```
  String get cardTitle => """Limite visual e estados""";

  /// ```dart
  /// "Esta página demonstra solid, dismissible, roundedPill, truncated, alertClass, iconContainerClass, textClass, closeButtonWhite e eventos."
  /// ```
  String get intro =>
      """Esta página demonstra solid, dismissible, roundedPill, truncated, alertClass, iconContainerClass, textClass, closeButtonWhite e eventos.""";

  /// ```dart
  /// "Deploy concluído."
  /// ```
  String get releaseDone => """Deploy concluído.""";

  /// ```dart
  /// "O pacote já está pronto para validação."
  /// ```
  String get releaseBody => """O pacote já está pronto para validação.""";

  /// ```dart
  /// "Atenção."
  /// ```
  String get attention => """Atenção.""";

  /// ```dart
  /// "Use solid=true quando precisar de contraste máximo."
  /// ```
  String get solidHelp =>
      """Use solid=true quando precisar de contraste máximo.""";

  /// ```dart
  /// "Este exemplo combina borderless, roundedPill e icone no fim do texto."
  /// ```
  String get borderlessHelp =>
      """Este exemplo combina borderless, roundedPill e icone no fim do texto.""";

  /// ```dart
  /// "Este alerta demonstra classes customizadas no container e no bloco de ícone para casar com layouts mais editoriais sem trocar o markup base do componente."
  /// ```
  String get customHelp =>
      """Este alerta demonstra classes customizadas no container e no bloco de ícone para casar com layouts mais editoriais sem trocar o markup base do componente.""";

  /// ```dart
  /// "Aguardando interação com os alerts."
  /// ```
  String get waiting => """Aguardando interação com os alerts.""";

  /// ```dart
  /// "Alerta principal restaurado."
  /// ```
  String get restored => """Alerta principal restaurado.""";

  /// ```dart
  /// "Alerta principal dispensado pelo usuário."
  /// ```
  String get dismissed => """Alerta principal dispensado pelo usuário.""";

  /// ```dart
  /// "visibleChange: alerta visível."
  /// ```
  String get visible => """visibleChange: alerta visível.""";

  /// ```dart
  /// "visibleChange: alerta ocultado."
  /// ```
  String get hidden => """visibleChange: alerta ocultado.""";
}

class AccordionPagesMessages {
  final PagesMessages _parent;
  const AccordionPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Acordeão"
  /// ```
  String get subtitle => """Acordeão""";

  /// ```dart
  /// "Itens expansivos"
  /// ```
  String get breadcrumb => """Itens expansivos""";

  /// ```dart
  /// "Configurações do accordion"
  /// ```
  String get cardTitle => """Configurações do accordion""";

  /// ```dart
  /// "Esta página cobre allowMultipleOpen, flush, lazy, destroyOnCollapse, item desabilitado, ícones e header customizado."
  /// ```
  String get intro =>
      """Esta página cobre allowMultipleOpen, flush, lazy, destroyOnCollapse, item desabilitado, ícones e header customizado.""";

  /// ```dart
  /// "Estado recolhido"
  /// ```
  String get collapsedHeader => """Estado recolhido""";

  /// ```dart
  /// "Começa fechado e expande sob demanda."
  /// ```
  String get collapsedDescription =>
      """Começa fechado e expande sob demanda.""";

  /// ```dart
  /// "Ideal para listas longas que precisam manter foco visual."
  /// ```
  String get collapsedBody =>
      """Ideal para listas longas que precisam manter foco visual.""";

  /// ```dart
  /// "Estado expandido"
  /// ```
  String get expandedHeader => """Estado expandido""";

  /// ```dart
  /// "Item inicial aberto."
  /// ```
  String get expandedDescription => """Item inicial aberto.""";

  /// ```dart
  /// "Defina expanded=true no item que precisa abrir ao carregar."
  /// ```
  String get expandedBody =>
      """Defina expanded=true no item que precisa abrir ao carregar.""";

  /// ```dart
  /// "Desabilitado"
  /// ```
  String get disabledHeader => """Desabilitado""";

  /// ```dart
  /// "Não responde a clique."
  /// ```
  String get disabledDescription => """Não responde a clique.""";

  /// ```dart
  /// "Este item demonstra o estado disabled."
  /// ```
  String get disabledBody => """Este item demonstra o estado disabled.""";

  /// ```dart
  /// "Header customizado"
  /// ```
  String get customHeader => """Header customizado""";

  /// ```dart
  /// "Template com li-accordion-header."
  /// ```
  String get customDescription => """Template com li-accordion-header.""";

  /// ```dart
  /// "O header pode ser totalmente customizado sem perder a estrutura do accordion."
  /// ```
  String get customBody =>
      """O header pode ser totalmente customizado sem perder a estrutura do accordion.""";

  /// ```dart
  /// "template"
  /// ```
  String get templateBadge => """template""";

  /// ```dart
  /// "Nenhum accordion alterado."
  /// ```
  String get idle => """Nenhum accordion alterado.""";

  /// ```dart
  /// "expandido"
  /// ```
  String get expandedState => """expandido""";

  /// ```dart
  /// "recolhido"
  /// ```
  String get collapsedState => """recolhido""";
}

class ProgressPagesMessages {
  final PagesMessages _parent;
  const ProgressPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Progresso"
  /// ```
  String get subtitle => """Progresso""";

  /// ```dart
  /// "Barras simples e empilhadas"
  /// ```
  String get breadcrumb => """Barras simples e empilhadas""";

  /// ```dart
  /// "Estados de progresso"
  /// ```
  String get cardTitle => """Estados de progresso""";

  /// ```dart
  /// "Pipeline de release"
  /// ```
  String get releasePipeline => """Pipeline de release""";

  /// ```dart
  /// "Config: height, rounded, showValueLabel"
  /// ```
  String get releaseConfig => """Config: height, rounded, showValueLabel""";

  /// ```dart
  /// "Capacidade por squad"
  /// ```
  String get squadCapacity => """Capacidade por squad""";

  /// ```dart
  /// "Config: striped, animated, barras empilhadas"
  /// ```
  String get squadConfig => """Config: striped, animated, barras empilhadas""";

  /// ```dart
  /// "Produto"
  /// ```
  String get teamProduct => """Produto""";

  /// ```dart
  /// "Faixa personalizada"
  /// ```
  String get customRange => """Faixa personalizada""";

  /// ```dart
  /// "Config: min, max e label textual"
  /// ```
  String get customConfig => """Config: min, max e label textual""";
}

class TabsPagesMessages {
  final PagesMessages _parent;
  const TabsPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Abas"
  /// ```
  String get subtitle => """Abas""";

  /// ```dart
  /// "Abas horizontais e verticais"
  /// ```
  String get breadcrumb => """Abas horizontais e verticais""";

  /// ```dart
  /// "Pills com header customizado"
  /// ```
  String get cardTitle => """Pills com header customizado""";

  /// ```dart
  /// "Tokens"
  /// ```
  String get tokens => """Tokens""";

  /// ```dart
  /// "Fluxo"
  /// ```
  String get flow => """Fluxo""";

  /// ```dart
  /// "Bloqueada"
  /// ```
  String get blocked => """Bloqueada""";

  /// ```dart
  /// "Use tabs para separar documentação, exemplos e notas de API."
  /// ```
  String get tokensBody =>
      """Use tabs para separar documentação, exemplos e notas de API.""";

  /// ```dart
  /// "O componente respeita a composição do Bootstrap e do Limitless."
  /// ```
  String get flowBody =>
      """O componente respeita a composição do Bootstrap e do Limitless.""";

  /// ```dart
  /// "Tab desabilitada."
  /// ```
  String get blockedBody => """Tab desabilitada.""";
}

class ModalPagesMessages {
  final PagesMessages _parent;
  const ModalPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Modal"
  /// ```
  String get subtitle => """Modal""";

  /// ```dart
  /// "Dialogs e variações de layout"
  /// ```
  String get breadcrumb => """Dialogs e variações de layout""";

  /// ```dart
  /// "Exemplos de modal"
  /// ```
  String get cardTitle => """Exemplos de modal""";

  /// ```dart
  /// "Abrir modal"
  /// ```
  String get openModal => """Abrir modal""";

  /// ```dart
  /// "Modal scrollable"
  /// ```
  String get scrollableModal => """Modal scrollable""";

  /// ```dart
  /// "Exemplo de modal"
  /// ```
  String get modalTitle => """Exemplo de modal""";

  /// ```dart
  /// "Composição padronizada"
  /// ```
  String get modalHeading => """Composição padronizada""";

  /// ```dart
  /// "O modal reaproveita a camada visual do Limitless e pode hospedar formulários curtos, confirmações ou visualizações detalhadas."
  /// ```
  String get modalBody =>
      """O modal reaproveita a camada visual do Limitless e pode hospedar formulários curtos, confirmações ou visualizações detalhadas.""";

  /// ```dart
  /// "Modal scrollable"
  /// ```
  String get scrollableTitle => """Modal scrollable""";

  /// ```dart
  /// "Este exemplo usa dialogScrollable, fullScreenOnMobile e desabilita o fechamento no backdrop."
  /// ```
  String get scrollableBody =>
      """Este exemplo usa dialogScrollable, fullScreenOnMobile e desabilita o fechamento no backdrop.""";

  /// ```dart
  /// "Linha $index para demonstrar rolagem interna do modal mantendo o header fixo na estrutura padrão do componente."
  /// ```
  String scrollableLine(int index) =>
      """Linha $index para demonstrar rolagem interna do modal mantendo o header fixo na estrutura padrão do componente.""";

  /// ```dart
  /// "Entendi"
  /// ```
  String get understood => """Entendi""";
}

class SelectPagesMessages {
  final PagesMessages _parent;
  const SelectPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Select"
  /// ```
  String get subtitle => """Select""";

  /// ```dart
  /// "Select simples"
  /// ```
  String get breadcrumb => """Select simples""";

  /// ```dart
  /// "Fonte de dados e projeção de conteúdo"
  /// ```
  String get cardTitle => """Fonte de dados e projeção de conteúdo""";

  /// ```dart
  /// "Status da entrega"
  /// ```
  String get deliveryStatus => """Status da entrega""";

  /// ```dart
  /// "Select com li-option"
  /// ```
  String get projectedTitle => """Select com li-option""";

  /// ```dart
  /// "Escolha um nível"
  /// ```
  String get projectedPlaceholder => """Escolha um nível""";

  /// ```dart
  /// "Status projetado"
  /// ```
  String get projectedStatus => """Status projetado""";

  /// ```dart
  /// "Visão geral"
  /// ```
  String get tabOverview => """Visão geral""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Solução de problemas"
  /// ```
  String get tabTroubleshooting => """Solução de problemas""";

  /// ```dart
  /// "Inputs mais usados"
  /// ```
  String get apiInputs => """Inputs mais usados""";

  /// ```dart
  /// "Erros que já apareceram neste componente e como evitar"
  /// ```
  String get troubleshootingIntro =>
      """Erros que já apareceram neste componente e como evitar""";

  /// ```dart
  /// "Rascunho"
  /// ```
  String get optionDraft => """Rascunho""";

  /// ```dart
  /// "Em revisão"
  /// ```
  String get optionReview => """Em revisão""";

  /// ```dart
  /// "Aprovado"
  /// ```
  String get optionApproved => """Aprovado""";

  /// ```dart
  /// "Arquivado"
  /// ```
  String get optionArchived => """Arquivado""";

  /// ```dart
  /// "Prioritário"
  /// ```
  String get optionPriority => """Prioritário""";

  /// ```dart
  /// "Backlog"
  /// ```
  String get optionBacklog => """Backlog""";
}

class MultiSelectPagesMessages {
  final PagesMessages _parent;
  const MultiSelectPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Multi Select"
  /// ```
  String get subtitle => """Multi Select""";

  /// ```dart
  /// "Seleção múltipla"
  /// ```
  String get breadcrumb => """Seleção múltipla""";

  /// ```dart
  /// "Fonte de dados e li-multi-option"
  /// ```
  String get cardTitle => """Fonte de dados e li-multi-option""";

  /// ```dart
  /// "Canais de notificação"
  /// ```
  String get channels => """Canais de notificação""";

  /// ```dart
  /// "Destinos projetados"
  /// ```
  String get projectedTargets => """Destinos projetados""";

  /// ```dart
  /// "Selecione os destinos"
  /// ```
  String get projectedPlaceholder => """Selecione os destinos""";

  /// ```dart
  /// "Projetados"
  /// ```
  String get projectedLabel => """Projetados""";

  /// ```dart
  /// "Visão geral"
  /// ```
  String get tabOverview => """Visão geral""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Solução de problemas"
  /// ```
  String get tabTroubleshooting => """Solução de problemas""";

  /// ```dart
  /// "Inputs mais usados"
  /// ```
  String get apiInputs => """Inputs mais usados""";

  /// ```dart
  /// "Cuidados importantes para evitar regressões"
  /// ```
  String get troubleshootingIntro =>
      """Cuidados importantes para evitar regressões""";

  /// ```dart
  /// "E-mail"
  /// ```
  String get optionEmail => """E-mail""";

  /// ```dart
  /// "Push"
  /// ```
  String get optionPush => """Push""";

  /// ```dart
  /// "SMS"
  /// ```
  String get optionSms => """SMS""";

  /// ```dart
  /// "Webhook"
  /// ```
  String get optionWebhook => """Webhook""";

  /// ```dart
  /// "Portal"
  /// ```
  String get optionPortal => """Portal""";

  /// ```dart
  /// "API"
  /// ```
  String get optionApi => """API""";

  /// ```dart
  /// "Processo batch"
  /// ```
  String get optionBatch => """Processo batch""";
}

class CurrencyPagesMessages {
  final PagesMessages _parent;
  const CurrencyPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Entrada monetária"
  /// ```
  String get subtitle => """Entrada monetária""";

  /// ```dart
  /// "Entrada monetária em minor units"
  /// ```
  String get breadcrumb => """Entrada monetária em minor units""";

  /// ```dart
  /// "Formato brasileiro"
  /// ```
  String get cardTitle => """Formato brasileiro""";

  /// ```dart
  /// "Orçamento"
  /// ```
  String get budget => """Orçamento""";

  /// ```dart
  /// "Minor units"
  /// ```
  String get minorUnits => """Minor units""";

  /// ```dart
  /// "O valor ligado ao ngModel sempre sai como inteiro em centavos."
  /// ```
  String get help =>
      """O valor ligado ao ngModel sempre sai como inteiro em centavos.""";
}

class DateRangePagesMessages {
  final PagesMessages _parent;
  const DateRangePagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Intervalo de datas"
  /// ```
  String get subtitle => """Intervalo de datas""";

  /// ```dart
  /// "Seleção de período"
  /// ```
  String get breadcrumb => """Seleção de período""";

  /// ```dart
  /// "Intervalos livres e restritos"
  /// ```
  String get cardTitle => """Intervalos livres e restritos""";

  /// ```dart
  /// "Selecione o periodo da sprint"
  /// ```
  String get sprintPlaceholder => """Selecione o periodo da sprint""";

  /// ```dart
  /// "Janela de publicação"
  /// ```
  String get publicationPlaceholder => """Janela de publicação""";

  /// ```dart
  /// "Período parcial ou não definido"
  /// ```
  String get partial => """Período parcial ou não definido""";

  /// ```dart
  /// "Janela ainda não concluída"
  /// ```
  String get unfinished => """Janela ainda não concluída""";

  /// ```dart
  /// "O segundo exemplo prende a seleção com minDate e maxDate."
  /// ```
  String get constrainedHelp =>
      """O segundo exemplo prende a seleção com minDate e maxDate.""";

  /// ```dart
  /// "até"
  /// ```
  String get between => """até""";
}

class TimePickerPagesMessages {
  final PagesMessages _parent;
  const TimePickerPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Time Picker"
  /// ```
  String get subtitle => """Time Picker""";

  /// ```dart
  /// "Seleção de horário"
  /// ```
  String get breadcrumb => """Seleção de horário""";

  /// ```dart
  /// "API e variações do Time Picker"
  /// ```
  String get cardTitle => """API e variações do Time Picker""";

  /// ```dart
  /// "Visão geral"
  /// ```
  String get tabOverview => """Visão geral""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "O time picker usa um dial inspirado no Limitless para seleção de hora e minuto com integração via ngModel."
  /// ```
  String get intro =>
      """O time picker usa um dial inspirado no Limitless para seleção de hora e minuto com integração via ngModel.""";

  /// ```dart
  /// "Descrição"
  /// ```
  String get descriptionTitle => """Descrição""";

  /// ```dart
  /// "O componente atende fluxos de agendamento, revisão, publicação e horários de operação com um overlay leve e direto."
  /// ```
  String get descriptionBody =>
      """O componente atende fluxos de agendamento, revisão, publicação e horários de operação com um overlay leve e direto.""";

  /// ```dart
  /// "Recursos"
  /// ```
  String get featuresTitle => """Recursos""";

  /// ```dart
  /// "Binding direto com ngModel em Duration?."
  /// ```
  String get featureOne => """Binding direto com ngModel em Duration?.""";

  /// ```dart
  /// "Seleção por relógio com alternância entre hora e minuto."
  /// ```
  String get featureTwo =>
      """Seleção por relógio com alternância entre hora e minuto.""";

  /// ```dart
  /// "Toggle AM/PM integrado no próprio painel."
  /// ```
  String get featureThree => """Toggle AM/PM integrado no próprio painel.""";

  /// ```dart
  /// "Limitações"
  /// ```
  String get limitsTitle => """Limitações""";

  /// ```dart
  /// "O componente trabalha no formato de 12 horas com AM e PM."
  /// ```
  String get limitOne =>
      """O componente trabalha no formato de 12 horas com AM e PM.""";

  /// ```dart
  /// "Não aplica regras de janela de negócio por conta própria."
  /// ```
  String get limitTwo =>
      """Não aplica regras de janela de negócio por conta própria.""";

  /// ```dart
  /// "O valor retornado considera apenas hora e minuto."
  /// ```
  String get limitThree =>
      """O valor retornado considera apenas hora e minuto.""";

  /// ```dart
  /// "Time picker padrão"
  /// ```
  String get defaultTitle => """Time picker padrão""";

  /// ```dart
  /// "Time picker em inglês"
  /// ```
  String get englishTitle => """Time picker em inglês""";

  /// ```dart
  /// "Time picker desabilitado"
  /// ```
  String get disabledTitle => """Time picker desabilitado""";

  /// ```dart
  /// "Selecione um horário"
  /// ```
  String get placeholder => """Selecione um horário""";

  /// ```dart
  /// "Select time"
  /// ```
  String get englishPlaceholder => """Select time""";

  /// ```dart
  /// "Horário bloqueado"
  /// ```
  String get disabledPlaceholder => """Horário bloqueado""";

  /// ```dart
  /// "Horário atual"
  /// ```
  String get currentLabel => """Horário atual""";

  /// ```dart
  /// "Horário de revisão"
  /// ```
  String get reviewLabel => """Horário de revisão""";

  /// ```dart
  /// "Horário bloqueado"
  /// ```
  String get disabledLabel => """Horário bloqueado""";

  /// ```dart
  /// "Clique no bloco de hora para trocar a hora e no de minuto para refinar os minutos."
  /// ```
  String get defaultHelp =>
      """Clique no bloco de hora para trocar a hora e no de minuto para refinar os minutos.""";

  /// ```dart
  /// "O locale troca placeholder e textos auxiliares do painel."
  /// ```
  String get englishHelp =>
      """O locale troca placeholder e textos auxiliares do painel.""";

  /// ```dart
  /// "O campo continua exibindo o valor sem abrir o overlay."
  /// ```
  String get disabledHelp =>
      """O campo continua exibindo o valor sem abrir o overlay.""";

  /// ```dart
  /// "Observações de uso"
  /// ```
  String get notesTitle => """Observações de uso""";

  /// ```dart
  /// "O componente retorna Duration normalizada em minutos do dia, o que facilita uso com formulários e filtros sem carregar uma data completa."
  /// ```
  String get notesBody =>
      """O componente retorna Duration normalizada em minutos do dia, o que facilita uso com formulários e filtros sem carregar uma data completa.""";

  /// ```dart
  /// "Nenhum horário selecionado"
  /// ```
  String get noneSelected => """Nenhum horário selecionado""";

  /// ```dart
  /// "Use o li-time-picker quando o formulário precisa escolher apenas um horário, sem data associada, mantendo integração com ngModel."
  /// ```
  String get apiIntro =>
      """Use o li-time-picker quando o formulário precisa escolher apenas um horário, sem data associada, mantendo integração com ngModel.""";

  /// ```dart
  /// "Inputs principais"
  /// ```
  String get apiInputsTitle => """Inputs principais""";

  /// ```dart
  /// "O binding ngModel trabalha com Duration?."
  /// ```
  String get apiInputOne => """O binding ngModel trabalha com Duration?.""";

  /// ```dart
  /// "locale ajusta placeholder e textos do painel."
  /// ```
  String get apiInputTwo => """locale ajusta placeholder e textos do painel.""";

  /// ```dart
  /// "disabled impede a abertura do relógio."
  /// ```
  String get apiInputThree => """disabled impede a abertura do relógio.""";

  /// ```dart
  /// "Comportamento"
  /// ```
  String get apiBehaviorTitle => """Comportamento""";

  /// ```dart
  /// "Clique no relógio para selecionar a hora e depois o minuto."
  /// ```
  String get apiBehaviorOne =>
      """Clique no relógio para selecionar a hora e depois o minuto.""";

  /// ```dart
  /// "O botão OK confirma a seleção e emite valueChange e ngModel."
  /// ```
  String get apiBehaviorTwo =>
      """O botão OK confirma a seleção e emite valueChange e ngModel.""";

  /// ```dart
  /// "AM e PM alteram a metade do dia sem recriar o valor manualmente."
  /// ```
  String get apiBehaviorThree =>
      """AM e PM alteram a metade do dia sem recriar o valor manualmente.""";

  /// ```dart
  /// """
  /// // Exemplo de uso
  /// selectedTime = const Duration(hours: 10, minutes: 48);
  ///
  /// <li-time-picker
  ///   [(ngModel)]="selectedTime"
  ///   locale="pt_BR">
  /// </li-time-picker>
  /// """
  /// ```
  String get apiUsageExample => """// Exemplo de uso
selectedTime = const Duration(hours: 10, minutes: 48);

<li-time-picker
  [(ngModel)]="selectedTime"
  locale="pt_BR">
</li-time-picker>
""";
}

class DatePickerPagesMessages {
  final PagesMessages _parent;
  const DatePickerPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Date Picker"
  /// ```
  String get subtitle => """Date Picker""";

  /// ```dart
  /// "Seleção de data única"
  /// ```
  String get breadcrumb => """Seleção de data única""";

  /// ```dart
  /// "API e variações do Date Picker"
  /// ```
  String get cardTitle => """API e variações do Date Picker""";

  /// ```dart
  /// "Visão geral"
  /// ```
  String get tabOverview => """Visão geral""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Variações"
  /// ```
  String get tabVariations => """Variações""";

  /// ```dart
  /// "Esta página é dedicada ao li-date-picker, com foco em data única, troca rápida por mês/ano, locale e estados comuns do campo."
  /// ```
  String get intro =>
      """Esta página é dedicada ao li-date-picker, com foco em data única, troca rápida por mês/ano, locale e estados comuns do campo.""";

  /// ```dart
  /// "Descrição"
  /// ```
  String get descriptionTitle => """Descrição""";

  /// ```dart
  /// "O date picker atende fluxos de data única como agendamento, publicação, vencimento e filtros pontuais, sem misturar responsabilidades com o seletor de intervalo."
  /// ```
  String get descriptionBody =>
      """O date picker atende fluxos de data única como agendamento, publicação, vencimento e filtros pontuais, sem misturar responsabilidades com o seletor de intervalo.""";

  /// ```dart
  /// "Recursos"
  /// ```
  String get featuresTitle => """Recursos""";

  /// ```dart
  /// "Binding direto com ngModel em DateTime?."
  /// ```
  String get featureOne => """Binding direto com ngModel em DateTime?.""";

  /// ```dart
  /// "Restrição por minDate e maxDate."
  /// ```
  String get featureTwo => """Restrição por minDate e maxDate.""";

  /// ```dart
  /// "Aplicação imediata ao clicar no dia."
  /// ```
  String get featureThree => """Aplicação imediata ao clicar no dia.""";

  /// ```dart
  /// "Navegação direta por mês e ano no overlay."
  /// ```
  String get featureFour => """Navegação direta por mês e ano no overlay.""";

  /// ```dart
  /// "Limitações"
  /// ```
  String get limitsTitle => """Limitações""";

  /// ```dart
  /// "Não substitui regras de negócio específicas de calendário."
  /// ```
  String get limitOne =>
      """Não substitui regras de negócio específicas de calendário.""";

  /// ```dart
  /// "Regras especiais como feriados e datas bloqueadas continuam no componente pai."
  /// ```
  String get limitTwo =>
      """Regras especiais como feriados e datas bloqueadas continuam no componente pai.""";

  /// ```dart
  /// "Datas e mensagens especiais continuam responsabilidade do componente pai."
  /// ```
  String get limitThree =>
      """Datas e mensagens especiais continuam responsabilidade do componente pai.""";

  /// ```dart
  /// "Date picker com ngModel"
  /// ```
  String get ngModelTitle => """Date picker com ngModel""";

  /// ```dart
  /// "Date picker com restrição"
  /// ```
  String get restrictedTitle => """Date picker com restrição""";

  /// ```dart
  /// "Date picker em inglês"
  /// ```
  String get englishLocaleTitle => """Date picker em inglês""";

  /// ```dart
  /// "Date picker desabilitado"
  /// ```
  String get disabledTitle => """Date picker desabilitado""";

  /// ```dart
  /// "Selecione uma data"
  /// ```
  String get placeholder => """Selecione uma data""";

  /// ```dart
  /// "Janela permitida"
  /// ```
  String get restrictedPlaceholder => """Janela permitida""";

  /// ```dart
  /// "Choose a date"
  /// ```
  String get englishPlaceholder => """Choose a date""";

  /// ```dart
  /// "Campo bloqueado"
  /// ```
  String get disabledPlaceholder => """Campo bloqueado""";

  /// ```dart
  /// "Data atual"
  /// ```
  String get currentDateLabel => """Data atual""";

  /// ```dart
  /// "Data restrita"
  /// ```
  String get restrictedLabel => """Data restrita""";

  /// ```dart
  /// "Data em EN"
  /// ```
  String get englishLabel => """Data em EN""";

  /// ```dart
  /// "Valor bloqueado"
  /// ```
  String get disabledLabel => """Valor bloqueado""";

  /// ```dart
  /// "Clique no cabeçalho para trocar o mês e o ano rapidamente."
  /// ```
  String get defaultHelp =>
      """Clique no cabeçalho para trocar o mês e o ano rapidamente.""";

  /// ```dart
  /// "Este exemplo limita a escolha entre minDate e maxDate."
  /// ```
  String get restrictedHelp =>
      """Este exemplo limita a escolha entre minDate e maxDate.""";

  /// ```dart
  /// "O locale altera labels do calendário e o formato da data exibida."
  /// ```
  String get englishHelp =>
      """O locale altera labels do calendário e o formato da data exibida.""";

  /// ```dart
  /// "O campo mantém leitura do valor atual sem abrir o overlay."
  /// ```
  String get disabledHelp =>
      """O campo mantém leitura do valor atual sem abrir o overlay.""";

  /// ```dart
  /// "Nenhuma data selecionada"
  /// ```
  String get noneSelected => """Nenhuma data selecionada""";

  /// ```dart
  /// "Período parcial ou não definido"
  /// ```
  String get partialRange => """Período parcial ou não definido""";

  /// ```dart
  /// "Use o li-date-picker quando o fluxo depende de uma única data com overlay leve, ngModel, locale e restrições básicas."
  /// ```
  String get apiIntro =>
      """Use o li-date-picker quando o fluxo depende de uma única data com overlay leve, ngModel, locale e restrições básicas.""";

  /// ```dart
  /// "Inputs principais"
  /// ```
  String get apiInputsTitle => """Inputs principais""";

  /// ```dart
  /// "O binding [(ngModel)] funciona com DateTime?."
  /// ```
  String get apiInputOne => """O binding [(ngModel)] funciona com DateTime?.""";

  /// ```dart
  /// "[minDate] e [maxDate] restringem a janela navegável e selecionável."
  /// ```
  String get apiInputTwo =>
      """[minDate] e [maxDate] restringem a janela navegável e selecionável.""";

  /// ```dart
  /// "locale ajusta labels e formato visual da data."
  /// ```
  String get apiInputThree =>
      """locale ajusta labels e formato visual da data.""";

  /// ```dart
  /// "[disabled] impede abertura e seleção."
  /// ```
  String get apiInputFour => """[disabled] impede abertura e seleção.""";

  /// ```dart
  /// "Comportamento"
  /// ```
  String get apiBehaviorTitle => """Comportamento""";

  /// ```dart
  /// "Clique em um dia aplica imediatamente e fecha o overlay."
  /// ```
  String get apiBehaviorOne =>
      """Clique em um dia aplica imediatamente e fecha o overlay.""";

  /// ```dart
  /// "Clique no título do calendário para alternar entre dia, mês e ano."
  /// ```
  String get apiBehaviorTwo =>
      """Clique no título do calendário para alternar entre dia, mês e ano.""";

  /// ```dart
  /// "clear() continua disponível no rodapé para limpar o valor atual."
  /// ```
  String get apiBehaviorThree =>
      """clear() continua disponível no rodapé para limpar o valor atual.""";

  /// ```dart
  /// "valueChange e ngModel recebem a data normalizada sem horário."
  /// ```
  String get apiBehaviorFour =>
      """valueChange e ngModel recebem a data normalizada sem horário.""";

  /// ```dart
  /// """
  /// // Exemplo de uso
  /// selectedDate = DateTime(2026, 3, 20);
  ///
  /// <li-date-picker
  ///   [(ngModel)]="selectedDate"
  ///   [minDate]="DateTime(2026, 3, 1)"
  ///   [maxDate]="DateTime(2026, 3, 31)"
  ///   locale="pt_BR">
  /// </li-date-picker>
  /// """
  /// ```
  String get apiUsageExample => """// Exemplo de uso
selectedDate = DateTime(2026, 3, 20);

<li-date-picker
  [(ngModel)]="selectedDate"
  [minDate]="DateTime(2026, 3, 1)"
  [maxDate]="DateTime(2026, 3, 31)"
  locale="pt_BR">
</li-date-picker>
""";

  /// ```dart
  /// "Fluxo padrão"
  /// ```
  String get variationStandardTitle => """Fluxo padrão""";

  /// ```dart
  /// "Melhor opção para formulários em que o usuário escolhe uma data e segue adiante sem confirmação extra."
  /// ```
  String get variationStandardBody =>
      """Melhor opção para formulários em que o usuário escolhe uma data e segue adiante sem confirmação extra.""";

  /// ```dart
  /// "Locale visual"
  /// ```
  String get variationLocaleTitle => """Locale visual""";

  /// ```dart
  /// "A mesma API alterna labels, meses e formato exibido entre português e inglês."
  /// ```
  String get variationLocaleBody =>
      """A mesma API alterna labels, meses e formato exibido entre português e inglês.""";

  /// ```dart
  /// "Estado bloqueado"
  /// ```
  String get variationDisabledTitle => """Estado bloqueado""";

  /// ```dart
  /// "Preserva o valor renderizado quando a data é informativa e não pode ser editada."
  /// ```
  String get variationDisabledBody =>
      """Preserva o valor renderizado quando a data é informativa e não pode ser editada.""";
}

class CarouselPagesMessages {
  final PagesMessages _parent;
  const CarouselPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Carousel"
  /// ```
  String get subtitle => """Carousel""";

  /// ```dart
  /// "Carousel com transições, captions e grid"
  /// ```
  String get breadcrumb => """Carousel com transições, captions e grid""";

  /// ```dart
  /// "Variações do Carousel"
  /// ```
  String get cardTitle => """Variações do Carousel""";

  /// ```dart
  /// "Exemplo"
  /// ```
  String get exampleLabel => """Exemplo""";

  /// ```dart
  /// "Carousel com Caption"
  /// ```
  String get standardTitle => """Carousel com Caption""";

  /// ```dart
  /// "Indicadores e controles no padrão do Limitless, com caption branco centralizado dentro de cada slide."
  /// ```
  String get standardSubtitle =>
      """Indicadores e controles no padrão do Limitless, com caption branco centralizado dentro de cada slide.""";

  /// ```dart
  /// "Carousel em Grid"
  /// ```
  String get gridTitle => """Carousel em Grid""";

  /// ```dart
  /// "Você pode ter até 12 itens por slide usando o grid do Bootstrap, com row e col-* dentro de cada carousel-item."
  /// ```
  String get gridSubtitle =>
      """Você pode ter até 12 itens por slide usando o grid do Bootstrap, com row e col-* dentro de cada carousel-item.""";

  /// ```dart
  /// "Arquitetura"
  /// ```
  String get slideOneLabel => """Arquitetura""";

  /// ```dart
  /// "Primeiro slide"
  /// ```
  String get slideOneTitle => """Primeiro slide""";

  /// ```dart
  /// "Indicadores pequenos na base e navegação lateral no padrão Bootstrap/Limitless."
  /// ```
  String get slideOneBody =>
      """Indicadores pequenos na base e navegação lateral no padrão Bootstrap/Limitless.""";

  /// ```dart
  /// "Composição"
  /// ```
  String get slideTwoLabel => """Composição""";

  /// ```dart
  /// "Segundo slide"
  /// ```
  String get slideTwoTitle => """Segundo slide""";

  /// ```dart
  /// "O caption usa a classe correta do componente e respeita o posicionamento central do tema."
  /// ```
  String get slideTwoBody =>
      """O caption usa a classe correta do componente e respeita o posicionamento central do tema.""";

  /// ```dart
  /// "Entrega"
  /// ```
  String get slideThreeLabel => """Entrega""";

  /// ```dart
  /// "Terceiro slide"
  /// ```
  String get slideThreeTitle => """Terceiro slide""";

  /// ```dart
  /// "A navegação continua consistente mesmo com autoplay e troca manual."
  /// ```
  String get slideThreeBody =>
      """A navegação continua consistente mesmo com autoplay e troca manual.""";

  /// ```dart
  /// "Referência"
  /// ```
  String get slideFourLabel => """Referência""";

  /// ```dart
  /// "Quarto slide"
  /// ```
  String get slideFourTitle => """Quarto slide""";

  /// ```dart
  /// "Estrutura equivalente ao exemplo clássico do arquivo components_carousel.html."
  /// ```
  String get slideFourBody =>
      """Estrutura equivalente ao exemplo clássico do arquivo components_carousel.html.""";

  /// ```dart
  /// "Coleção 1"
  /// ```
  String get gridSlideOneLabel => """Coleção 1""";

  /// ```dart
  /// "Coleção 2"
  /// ```
  String get gridSlideTwoLabel => """Coleção 2""";

  /// ```dart
  /// "Coleção 3"
  /// ```
  String get gridSlideThreeLabel => """Coleção 3""";

  /// ```dart
  /// "Workspace editorial"
  /// ```
  String get gridCardOneTitle => """Workspace editorial""";

  /// ```dart
  /// "Painel visual para documentos, destaques e layouts mais narrativos."
  /// ```
  String get gridCardOneBody =>
      """Painel visual para documentos, destaques e layouts mais narrativos.""";

  /// ```dart
  /// "Produto em destaque"
  /// ```
  String get gridCardTwoTitle => """Produto em destaque""";

  /// ```dart
  /// "Estrutura pronta para vitrine de cards, mídia ou campanhas."
  /// ```
  String get gridCardTwoBody =>
      """Estrutura pronta para vitrine de cards, mídia ou campanhas.""";

  /// ```dart
  /// "Jornada do usuário"
  /// ```
  String get gridCardThreeTitle => """Jornada do usuário""";

  /// ```dart
  /// "Um slide pode reunir várias entradas sem perder legibilidade."
  /// ```
  String get gridCardThreeBody =>
      """Um slide pode reunir várias entradas sem perder legibilidade.""";

  /// ```dart
  /// "Identidade visual"
  /// ```
  String get gridCardFourTitle => """Identidade visual""";

  /// ```dart
  /// "Imagens maiores ajudam a validar contraste, recorte e sobreposição."
  /// ```
  String get gridCardFourBody =>
      """Imagens maiores ajudam a validar contraste, recorte e sobreposição.""";

  /// ```dart
  /// "Módulos componíveis"
  /// ```
  String get gridCardFiveTitle => """Módulos componíveis""";

  /// ```dart
  /// "Carousel, Caption e Grid funcionam juntos sem markup acoplado."
  /// ```
  String get gridCardFiveBody =>
      """Carousel, Caption e Grid funcionam juntos sem markup acoplado.""";

  /// ```dart
  /// "Demo executável"
  /// ```
  String get gridCardSixTitle => """Demo executável""";

  /// ```dart
  /// "A vitrine deixa de ser estática e passa a mostrar comportamento real."
  /// ```
  String get gridCardSixBody =>
      """A vitrine deixa de ser estática e passa a mostrar comportamento real.""";

  /// ```dart
  /// "Coleção expandida"
  /// ```
  String get gridCardSevenTitle => """Coleção expandida""";

  /// ```dart
  /// "Mais um slide para validar indicadores e transição contínua no grid."
  /// ```
  String get gridCardSevenBody =>
      """Mais um slide para validar indicadores e transição contínua no grid.""";

  /// ```dart
  /// "Navegação estável"
  /// ```
  String get gridCardEightTitle => """Navegação estável""";

  /// ```dart
  /// "Controles laterais permanecem previsíveis porque o row fica dentro do item."
  /// ```
  String get gridCardEightBody =>
      """Controles laterais permanecem previsíveis porque o row fica dentro do item.""";

  /// ```dart
  /// "Estrutura correta"
  /// ```
  String get gridCardNineTitle => """Estrutura correta""";

  /// ```dart
  /// "O item continua sendo o slide real; o grid é apenas conteúdo interno."
  /// ```
  String get gridCardNineBody =>
      """O item continua sendo o slide real; o grid é apenas conteúdo interno.""";

  /// ```dart
  /// "Carousel com Fade"
  /// ```
  String get fadeTitle => """Carousel com Fade""";

  /// ```dart
  /// "Troca de slides por opacidade, sem deslocamento lateral, útil para hero banners e conteúdo com caption forte."
  /// ```
  String get fadeSubtitle =>
      """Troca de slides por opacidade, sem deslocamento lateral, útil para hero banners e conteúdo com caption forte.""";

  /// ```dart
  /// "Fade 1"
  /// ```
  String get fadeSlideOneLabel => """Fade 1""";

  /// ```dart
  /// "Fade editorial"
  /// ```
  String get fadeSlideOneTitle => """Fade editorial""";

  /// ```dart
  /// "O slide entra por opacidade, sem disputar atenção com movimento lateral."
  /// ```
  String get fadeSlideOneBody =>
      """O slide entra por opacidade, sem disputar atenção com movimento lateral.""";

  /// ```dart
  /// "Fade 2"
  /// ```
  String get fadeSlideTwoLabel => """Fade 2""";

  /// ```dart
  /// "Leitura mais limpa"
  /// ```
  String get fadeSlideTwoTitle => """Leitura mais limpa""";

  /// ```dart
  /// "Funciona bem quando a imagem já tem muita textura e você quer uma troca mais discreta."
  /// ```
  String get fadeSlideTwoBody =>
      """Funciona bem quando a imagem já tem muita textura e você quer uma troca mais discreta.""";

  /// ```dart
  /// "Fade 3"
  /// ```
  String get fadeSlideThreeLabel => """Fade 3""";

  /// ```dart
  /// "Transição suave"
  /// ```
  String get fadeSlideThreeTitle => """Transição suave""";

  /// ```dart
  /// "O controle, indicadores e autoplay continuam iguais; muda apenas a linguagem visual da transição."
  /// ```
  String get fadeSlideThreeBody =>
      """O controle, indicadores e autoplay continuam iguais; muda apenas a linguagem visual da transição.""";

  /// ```dart
  /// "Carousel com Zoom"
  /// ```
  String get zoomTitle => """Carousel com Zoom""";

  /// ```dart
  /// "Entrada com escala e opacidade para uma sensação mais cinematográfica, sem alterar a estrutura do componente."
  /// ```
  String get zoomSubtitle =>
      """Entrada com escala e opacidade para uma sensação mais cinematográfica, sem alterar a estrutura do componente.""";

  /// ```dart
  /// "Zoom 1"
  /// ```
  String get zoomSlideOneLabel => """Zoom 1""";

  /// ```dart
  /// "Zoom in"
  /// ```
  String get zoomSlideOneTitle => """Zoom in""";

  /// ```dart
  /// "O próximo slide entra com escala maior e assenta no plano principal ao fim da transição."
  /// ```
  String get zoomSlideOneBody =>
      """O próximo slide entra com escala maior e assenta no plano principal ao fim da transição.""";

  /// ```dart
  /// "Zoom 2"
  /// ```
  String get zoomSlideTwoLabel => """Zoom 2""";

  /// ```dart
  /// "Ênfase visual"
  /// ```
  String get zoomSlideTwoTitle => """Ênfase visual""";

  /// ```dart
  /// "É uma boa variação para showcases de campanha, portfólio ou telas mais editoriais."
  /// ```
  String get zoomSlideTwoBody =>
      """É uma boa variação para showcases de campanha, portfólio ou telas mais editoriais.""";

  /// ```dart
  /// "Zoom 3"
  /// ```
  String get zoomSlideThreeLabel => """Zoom 3""";

  /// ```dart
  /// "Mesmo markup"
  /// ```
  String get zoomSlideThreeTitle => """Mesmo markup""";

  /// ```dart
  /// "A API continua igual: o efeito muda por input, sem markup alternativo nos itens."
  /// ```
  String get zoomSlideThreeBody =>
      """A API continua igual: o efeito muda por input, sem markup alternativo nos itens.""";

  /// ```dart
  /// "Carousel Vertical"
  /// ```
  String get verticalTitle => """Carousel Vertical""";

  /// ```dart
  /// "A transição acontece no eixo Y, útil quando a composição da página já tem muito movimento horizontal."
  /// ```
  String get verticalSubtitle =>
      """A transição acontece no eixo Y, útil quando a composição da página já tem muito movimento horizontal.""";

  /// ```dart
  /// "Vertical 1"
  /// ```
  String get verticalSlideOneLabel => """Vertical 1""";

  /// ```dart
  /// "Deslocamento vertical"
  /// ```
  String get verticalSlideOneTitle => """Deslocamento vertical""";

  /// ```dart
  /// "O comportamento do carousel permanece o mesmo, mas a percepção muda completamente."
  /// ```
  String get verticalSlideOneBody =>
      """O comportamento do carousel permanece o mesmo, mas a percepção muda completamente.""";

  /// ```dart
  /// "Vertical 2"
  /// ```
  String get verticalSlideTwoLabel => """Vertical 2""";

  /// ```dart
  /// "Fluxo alternativo"
  /// ```
  String get verticalSlideTwoTitle => """Fluxo alternativo""";

  /// ```dart
  /// "Esse modo pode combinar melhor com layouts em coluna e conteúdo mais documental."
  /// ```
  String get verticalSlideTwoBody =>
      """Esse modo pode combinar melhor com layouts em coluna e conteúdo mais documental.""";

  /// ```dart
  /// "Vertical 3"
  /// ```
  String get verticalSlideThreeLabel => """Vertical 3""";

  /// ```dart
  /// "API consistente"
  /// ```
  String get verticalSlideThreeTitle => """API consistente""";

  /// ```dart
  /// "Assim como no zoom, a mudança está encapsulada no componente e pode ser reutilizada em outras telas."
  /// ```
  String get verticalSlideThreeBody =>
      """Assim como no zoom, a mudança está encapsulada no componente e pode ser reutilizada em outras telas.""";

  /// ```dart
  /// "Carousel com Blur"
  /// ```
  String get blurTitle => """Carousel com Blur""";

  /// ```dart
  /// "Uma transição com desfoque e opacidade que suaviza a troca entre imagens mais detalhadas."
  /// ```
  String get blurSubtitle =>
      """Uma transição com desfoque e opacidade que suaviza a troca entre imagens mais detalhadas.""";

  /// ```dart
  /// "Blur 1"
  /// ```
  String get blurSlideOneLabel => """Blur 1""";

  /// ```dart
  /// "Entrada difusa"
  /// ```
  String get blurSlideOneTitle => """Entrada difusa""";

  /// ```dart
  /// "O slide emerge com blur reduzido e opacidade crescente, criando uma mudança mais atmosférica."
  /// ```
  String get blurSlideOneBody =>
      """O slide emerge com blur reduzido e opacidade crescente, criando uma mudança mais atmosférica.""";

  /// ```dart
  /// "Blur 2"
  /// ```
  String get blurSlideTwoLabel => """Blur 2""";

  /// ```dart
  /// "Textura sob controle"
  /// ```
  String get blurSlideTwoTitle => """Textura sob controle""";

  /// ```dart
  /// "Esse modo funciona bem quando a fotografia tem muito detalhe e o fade puro parece discreto demais."
  /// ```
  String get blurSlideTwoBody =>
      """Esse modo funciona bem quando a fotografia tem muito detalhe e o fade puro parece discreto demais.""";

  /// ```dart
  /// "Blur 3"
  /// ```
  String get blurSlideThreeLabel => """Blur 3""";

  /// ```dart
  /// "Variação reutilizável"
  /// ```
  String get blurSlideThreeTitle => """Variação reutilizável""";

  /// ```dart
  /// "O efeito continua encapsulado no componente e pode ser aplicado em qualquer carousel via input."
  /// ```
  String get blurSlideThreeBody =>
      """O efeito continua encapsulado no componente e pode ser aplicado em qualquer carousel via input.""";

  /// ```dart
  /// "Carousel com Parallax"
  /// ```
  String get parallaxTitle => """Carousel com Parallax""";

  /// ```dart
  /// "Desloca a imagem com profundidade aparente, criando uma transição mais espacial entre os slides."
  /// ```
  String get parallaxSubtitle =>
      """Desloca a imagem com profundidade aparente, criando uma transição mais espacial entre os slides.""";

  /// ```dart
  /// "Parallax 1"
  /// ```
  String get parallaxSlideOneLabel => """Parallax 1""";

  /// ```dart
  /// "Profundidade lateral"
  /// ```
  String get parallaxSlideOneTitle => """Profundidade lateral""";

  /// ```dart
  /// "O slide entra com deslocamento e escala levemente maior, sugerindo um plano de fundo em movimento."
  /// ```
  String get parallaxSlideOneBody =>
      """O slide entra com deslocamento e escala levemente maior, sugerindo um plano de fundo em movimento.""";

  /// ```dart
  /// "Parallax 2"
  /// ```
  String get parallaxSlideTwoLabel => """Parallax 2""";

  /// ```dart
  /// "Movimento editorial"
  /// ```
  String get parallaxSlideTwoTitle => """Movimento editorial""";

  /// ```dart
  /// "Esse modo funciona bem em vitrines visuais e páginas onde a troca de imagem precisa parecer mais física."
  /// ```
  String get parallaxSlideTwoBody =>
      """Esse modo funciona bem em vitrines visuais e páginas onde a troca de imagem precisa parecer mais física.""";

  /// ```dart
  /// "Parallax 3"
  /// ```
  String get parallaxSlideThreeLabel => """Parallax 3""";

  /// ```dart
  /// "Camadas sutis"
  /// ```
  String get parallaxSlideThreeTitle => """Camadas sutis""";

  /// ```dart
  /// "A sensação de parallax é discreta e reutilizável, sem exigir markup especial nos itens."
  /// ```
  String get parallaxSlideThreeBody =>
      """A sensação de parallax é discreta e reutilizável, sem exigir markup especial nos itens.""";
}

class TooltipPagesMessages {
  final PagesMessages _parent;
  const TooltipPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Tooltip"
  /// ```
  String get subtitle => """Tooltip""";

  /// ```dart
  /// "Hover, click e modo manual"
  /// ```
  String get breadcrumb => """Hover, click e modo manual""";

  /// ```dart
  /// "Triggers e posicionamento"
  /// ```
  String get cardTitle => """Triggers e posicionamento""";

  /// ```dart
  /// "Mostra dicas ao passar o mouse."
  /// ```
  String get hoverText => """Mostra dicas ao passar o mouse.""";

  /// ```dart
  /// "Hover tooltip"
  /// ```
  String get hoverButton => """Hover tooltip""";

  /// ```dart
  /// "<strong>HTML</strong> também funciona com trigger de click."
  /// ```
  String get clickText =>
      """<strong>HTML</strong> também funciona com trigger de click.""";

  /// ```dart
  /// "Click tooltip"
  /// ```
  String get clickButton => """Click tooltip""";

  /// ```dart
  /// "Tooltip manual com controle programático."
  /// ```
  String get manualText => """Tooltip manual com controle programático.""";

  /// ```dart
  /// "Manual tooltip"
  /// ```
  String get manualButton => """Manual tooltip""";

  /// ```dart
  /// "Sem eventos de tooltip até o momento."
  /// ```
  String get idle => """Sem eventos de tooltip até o momento.""";

  /// ```dart
  /// "Tooltip: $label"
  /// ```
  String event(String label) => """Tooltip: $label""";
}

class DatatablePagesMessages {
  final PagesMessages _parent;
  const DatatablePagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Datatable"
  /// ```
  String get subtitle => """Datatable""";

  /// ```dart
  /// "Busca, seleção e exportação"
  /// ```
  String get breadcrumb => """Busca, seleção e exportação""";

  /// ```dart
  /// "Operações da tabela"
  /// ```
  String get cardTitle => """Operações da tabela""";

  /// ```dart
  /// "Alternar grid"
  /// ```
  String get toggleGrid => """Alternar grid""";

  /// ```dart
  /// "Seleção única"
  /// ```
  String get singleSelection => """Seleção única""";

  /// ```dart
  /// "Buscar sprint"
  /// ```
  String get searchLabel => """Buscar sprint""";

  /// ```dart
  /// "Digite para buscar"
  /// ```
  String get searchPlaceholder => """Digite para buscar""";

  /// ```dart
  /// "Entrega"
  /// ```
  String get featureCol => """Entrega""";

  /// ```dart
  /// "Squad"
  /// ```
  String get ownerCol => """Squad""";

  /// ```dart
  /// "Status"
  /// ```
  String get statusCol => """Status""";

  /// ```dart
  /// "Saúde"
  /// ```
  String get healthCol => """Saúde""";

  /// ```dart
  /// "Painel executivo"
  /// ```
  String get featureRow1 => """Painel executivo""";

  /// ```dart
  /// "Exportação em PDF"
  /// ```
  String get featureRow2 => """Exportação em PDF""";

  /// ```dart
  /// "Fluxo de aprovação"
  /// ```
  String get featureRow3 => """Fluxo de aprovação""";

  /// ```dart
  /// "Alertas em tempo real"
  /// ```
  String get featureRow4 => """Alertas em tempo real""";

  /// ```dart
  /// "Produto"
  /// ```
  String get ownerProduct => """Produto""";

  /// ```dart
  /// "Backoffice"
  /// ```
  String get ownerBackoffice => """Backoffice""";

  /// ```dart
  /// "Operações"
  /// ```
  String get ownerOperations => """Operações""";

  /// ```dart
  /// "Infra"
  /// ```
  String get ownerInfra => """Infra""";

  /// ```dart
  /// "Em andamento"
  /// ```
  String get statusInProgress => """Em andamento""";

  /// ```dart
  /// "Concluído"
  /// ```
  String get statusDone => """Concluído""";

  /// ```dart
  /// "Planejado"
  /// ```
  String get statusPlanned => """Planejado""";

  /// ```dart
  /// "Bloqueado"
  /// ```
  String get statusBlocked => """Bloqueado""";

  /// ```dart
  /// "Atenção"
  /// ```
  String get healthWarning => """Atenção""";

  /// ```dart
  /// "Ok"
  /// ```
  String get healthOk => """Ok""";

  /// ```dart
  /// "Crítico"
  /// ```
  String get healthCritical => """Crítico""";

  /// ```dart
  /// "Tabela pronta para interação."
  /// ```
  String get ready => """Tabela pronta para interação.""";

  /// ```dart
  /// "Datatable alternada para o modo grade."
  /// ```
  String get gridMode => """Datatable alternada para o modo grade.""";

  /// ```dart
  /// "Datatable alternada para o modo tabela."
  /// ```
  String get tableMode => """Datatable alternada para o modo tabela.""";

  /// ```dart
  /// "Seleção única ativada."
  /// ```
  String get singleMode => """Seleção única ativada.""";

  /// ```dart
  /// "Seleção múltipla ativada."
  /// ```
  String get multiMode => """Seleção múltipla ativada.""";

  /// ```dart
  /// "Exportação XLSX acionada."
  /// ```
  String get exportXlsx => """Exportação XLSX acionada.""";

  /// ```dart
  /// "Exportação em PDF acionada."
  /// ```
  String get exportPdf => """Exportação em PDF acionada.""";

  /// ```dart
  /// "Linha clicada: $feature."
  /// ```
  String rowClicked(String feature) => """Linha clicada: $feature.""";

  /// ```dart
  /// "Itens selecionados: $count."
  /// ```
  String selectedItems(int count) => """Itens selecionados: $count.""";
}

class NotificationPagesMessages {
  final PagesMessages _parent;
  const NotificationPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Área de notificações"
  /// ```
  String get subtitle => """Área de notificações""";

  /// ```dart
  /// "Toasts fixos no viewport"
  /// ```
  String get breadcrumb => """Toasts fixos no viewport""";

  /// ```dart
  /// "Disparo de notificações"
  /// ```
  String get cardTitle => """Disparo de notificações""";

  /// ```dart
  /// "Com link"
  /// ```
  String get withLink => """Com link""";

  /// ```dart
  /// "Nenhuma notificação disparada."
  /// ```
  String get idle => """Nenhuma notificação disparada.""";

  /// ```dart
  /// "Sincronização concluída com sucesso."
  /// ```
  String get successMessage => """Sincronização concluída com sucesso.""";

  /// ```dart
  /// "Fila de eventos"
  /// ```
  String get successTitle => """Fila de eventos""";

  /// ```dart
  /// "Notificação success disparada."
  /// ```
  String get successState => """Notificação success disparada.""";

  /// ```dart
  /// "Existem itens aguardando validação manual."
  /// ```
  String get warningMessage => """Existem itens aguardando validação manual.""";

  /// ```dart
  /// "Atenção"
  /// ```
  String get warningTitle => """Atenção""";

  /// ```dart
  /// "Notificação warning disparada."
  /// ```
  String get warningState => """Notificação warning disparada.""";

  /// ```dart
  /// "Clique para abrir a demonstração de datatable."
  /// ```
  String get linkMessage =>
      """Clique para abrir a demonstração de datatable.""";

  /// ```dart
  /// "Atalho"
  /// ```
  String get linkTitle => """Atalho""";

  /// ```dart
  /// "Notificação com link para datatable disparada."
  /// ```
  String get linkState => """Notificação com link para datatable disparada.""";
}

class TreeviewPagesMessages {
  final PagesMessages _parent;
  const TreeviewPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Treeview"
  /// ```
  String get subtitle => """Treeview""";

  /// ```dart
  /// "Estrutura hierárquica"
  /// ```
  String get breadcrumb => """Estrutura hierárquica""";

  /// ```dart
  /// "Busca, expandir e selecionar"
  /// ```
  String get cardTitle => """Busca, expandir e selecionar""";

  /// ```dart
  /// "O treeview inclui busca, expandir/recolher e seleção em cascata."
  /// ```
  String get intro =>
      """O treeview inclui busca, expandir/recolher e seleção em cascata.""";

  /// ```dart
  /// "Busque por módulo ou status"
  /// ```
  String get searchPlaceholder => """Busque por módulo ou status""";

  /// ```dart
  /// "Atendimento"
  /// ```
  String get nodeService => """Atendimento""";

  /// ```dart
  /// "Triagem"
  /// ```
  String get nodeTriage => """Triagem""";

  /// ```dart
  /// "Encaminhamentos"
  /// ```
  String get nodeReferrals => """Encaminhamentos""";

  /// ```dart
  /// "Benefícios"
  /// ```
  String get nodeBenefits => """Benefícios""";

  /// ```dart
  /// "Cesta básica"
  /// ```
  String get nodeFoodBasket => """Cesta básica""";

  /// ```dart
  /// "Em análise"
  /// ```
  String get nodeReview => """Em análise""";

  /// ```dart
  /// "Aprovado"
  /// ```
  String get nodeApproved => """Aprovado""";

  /// ```dart
  /// "Auxílio aluguel"
  /// ```
  String get nodeRentAid => """Auxílio aluguel""";
}

class HelpersPagesMessages {
  final PagesMessages _parent;
  const HelpersPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Utilitarios"
  /// ```
  String get subtitle => """Utilitarios""";

  /// ```dart
  /// "Loading, dialogs, popovers e toasts"
  /// ```
  String get breadcrumb => """Loading, dialogs, popovers e toasts""";

  /// ```dart
  /// "SimpleLoading"
  /// ```
  String get loadingTitle => """SimpleLoading""";

  /// ```dart
  /// "Mostrar overlay"
  /// ```
  String get showOverlay => """Mostrar overlay""";

  /// ```dart
  /// "Area alvo do loading"
  /// ```
  String get loadingTarget => """Area alvo do loading""";

  /// ```dart
  /// "A overlay fica presa ao container."
  /// ```
  String get loadingTargetHelp => """A overlay fica presa ao container.""";

  /// ```dart
  /// "Dialogs, toasts e popovers"
  /// ```
  String get actionTitle => """Dialogs, toasts e popovers""";

  /// ```dart
  /// "Dialog alert"
  /// ```
  String get dialogAlert => """Dialog alert""";

  /// ```dart
  /// "Dialog confirm"
  /// ```
  String get dialogConfirm => """Dialog confirm""";

  /// ```dart
  /// "Simple popover"
  /// ```
  String get simplePopover => """Simple popover""";

  /// ```dart
  /// "Sweet popover"
  /// ```
  String get sweetPopover => """Sweet popover""";

  /// ```dart
  /// "Simple success toast"
  /// ```
  String get simpleSuccessToast => """Simple success toast""";

  /// ```dart
  /// "Simple warning toast"
  /// ```
  String get simpleWarningToast => """Simple warning toast""";

  /// ```dart
  /// "Sweet success toast"
  /// ```
  String get sweetSuccessToast => """Sweet success toast""";

  /// ```dart
  /// "Sweet warning toast"
  /// ```
  String get sweetWarningToast => """Sweet warning toast""";

  /// ```dart
  /// "Sweet modal"
  /// ```
  String get sweetModal => """Sweet modal""";

  /// ```dart
  /// "Sweet confirm"
  /// ```
  String get sweetConfirm => """Sweet confirm""";

  /// ```dart
  /// "Sweet prompt"
  /// ```
  String get sweetPrompt => """Sweet prompt""";

  /// ```dart
  /// "Sweet error toast"
  /// ```
  String get sweetErrorToast => """Sweet error toast""";

  /// ```dart
  /// "Use os botões para acionar os helpers estáticos."
  /// ```
  String get idle => """Use os botões para acionar os helpers estáticos.""";

  /// ```dart
  /// "Overlay de loading exibida por 2 segundos."
  /// ```
  String get loadingShown => """Overlay de loading exibida por 2 segundos.""";

  /// ```dart
  /// "Overlay de loading finalizada."
  /// ```
  String get loadingHidden => """Overlay de loading finalizada.""";

  /// ```dart
  /// "A operação foi iniciada e será monitorada em background."
  /// ```
  String get dialogAlertBody =>
      """A operação foi iniciada e será monitorada em background.""";

  /// ```dart
  /// "Execução iniciada"
  /// ```
  String get dialogAlertTitle => """Execução iniciada""";

  /// ```dart
  /// "SimpleDialog.showAlert executado."
  /// ```
  String get dialogAlertState => """SimpleDialog.showAlert executado.""";

  /// ```dart
  /// "Deseja continuar com a publicação desta configuração?"
  /// ```
  String get dialogConfirmBody =>
      """Deseja continuar com a publicação desta configuração?""";

  /// ```dart
  /// "Confirmação"
  /// ```
  String get dialogConfirmTitle => """Confirmação""";

  /// ```dart
  /// "Publicar"
  /// ```
  String get dialogConfirmOk => """Publicar""";

  /// ```dart
  /// "Cancelar"
  /// ```
  String get dialogConfirmCancel => """Cancelar""";

  /// ```dart
  /// "Confirmação positiva retornou true."
  /// ```
  String get dialogConfirmTrue => """Confirmação positiva retornou true.""";

  /// ```dart
  /// "Confirmação retornou false."
  /// ```
  String get dialogConfirmFalse => """Confirmação retornou false.""";

  /// ```dart
  /// "Popover simples ancorado ao botao usando markup Bootstrap/Limitless."
  /// ```
  String get simplePopoverBody =>
      """Popover simples ancorado ao botao usando markup Bootstrap/Limitless.""";

  /// ```dart
  /// "SimplePopover exibido."
  /// ```
  String get simplePopoverState => """SimplePopover exibido.""";

  /// ```dart
  /// "Versão baseada em SweetAlert com overlay Popper."
  /// ```
  String get sweetPopoverBody =>
      """Versão baseada em SweetAlert com overlay Popper.""";

  /// ```dart
  /// "Sweet popover"
  /// ```
  String get sweetPopoverTitle => """Sweet popover""";

  /// ```dart
  /// "SweetAlertPopover exibido."
  /// ```
  String get sweetPopoverState => """SweetAlertPopover exibido.""";

  /// ```dart
  /// "Toast simples de sucesso exibido."
  /// ```
  String get simpleSuccessBody => """Toast simples de sucesso exibido.""";

  /// ```dart
  /// "SimpleToast.showSuccess executado."
  /// ```
  String get simpleSuccessState => """SimpleToast.showSuccess executado.""";

  /// ```dart
  /// "Toast simples de alerta exibido."
  /// ```
  String get simpleWarningBody => """Toast simples de alerta exibido.""";

  /// ```dart
  /// "SimpleToast.showWarning executado."
  /// ```
  String get simpleWarningState => """SimpleToast.showWarning executado.""";

  /// ```dart
  /// "Toast SweetAlert de sucesso exibido."
  /// ```
  String get sweetSuccessBody => """Toast SweetAlert de sucesso exibido.""";

  /// ```dart
  /// "SweetAlertSimpleToast.showSuccessToast executado."
  /// ```
  String get sweetSuccessState =>
      """SweetAlertSimpleToast.showSuccessToast executado.""";

  /// ```dart
  /// "Toast SweetAlert de alerta exibido."
  /// ```
  String get sweetWarningBody => """Toast SweetAlert de alerta exibido.""";

  /// ```dart
  /// "SweetAlertSimpleToast.showWarningToast executado."
  /// ```
  String get sweetWarningState =>
      """SweetAlertSimpleToast.showWarningToast executado.""";

  /// ```dart
  /// "O pipeline terminou com sucesso e gerou um resumo pronto para revisão."
  /// ```
  String get sweetModalBody =>
      """O pipeline terminou com sucesso e gerou um resumo pronto para revisão.""";

  /// ```dart
  /// "Build concluído"
  /// ```
  String get sweetModalTitle => """Build concluído""";

  /// ```dart
  /// "SweetAlert.show confirmado."
  /// ```
  String get sweetModalState => """SweetAlert.show confirmado.""";

  /// ```dart
  /// "SweetAlert.show foi fechado sem confirmação."
  /// ```
  String get sweetModalDismissed =>
      """SweetAlert.show foi fechado sem confirmação.""";

  /// ```dart
  /// "Deseja promover este release para produção agora?"
  /// ```
  String get sweetConfirmBody =>
      """Deseja promover este release para produção agora?""";

  /// ```dart
  /// "Promover release"
  /// ```
  String get sweetConfirmTitle => """Promover release""";

  /// ```dart
  /// "Promover"
  /// ```
  String get sweetConfirmOk => """Promover""";

  /// ```dart
  /// "Revisar"
  /// ```
  String get sweetConfirmCancel => """Revisar""";

  /// ```dart
  /// "SweetAlert.confirm retornou confirmação positiva."
  /// ```
  String get sweetConfirmTrue =>
      """SweetAlert.confirm retornou confirmação positiva.""";

  /// ```dart
  /// "SweetAlert.confirm foi cancelado."
  /// ```
  String get sweetConfirmFalse => """SweetAlert.confirm foi cancelado.""";

  /// ```dart
  /// "Informe o identificador do lote que deve receber monitoramento prioritário."
  /// ```
  String get sweetPromptBody =>
      """Informe o identificador do lote que deve receber monitoramento prioritário.""";

  /// ```dart
  /// "Prioridade do lote"
  /// ```
  String get sweetPromptTitle => """Prioridade do lote""";

  /// ```dart
  /// "Ex.: lote-42"
  /// ```
  String get sweetPromptPlaceholder => """Ex.: lote-42""";

  /// ```dart
  /// "Salvar prioridade"
  /// ```
  String get sweetPromptOk => """Salvar prioridade""";

  /// ```dart
  /// "Agora não"
  /// ```
  String get sweetPromptCancel => """Agora não""";

  /// ```dart
  /// "Informe um identificador antes de continuar."
  /// ```
  String get sweetPromptValidation =>
      """Informe um identificador antes de continuar.""";

  /// ```dart
  /// "SweetAlert.prompt confirmou com valor"
  /// ```
  String get sweetPromptFilledPrefix =>
      """SweetAlert.prompt confirmou com valor""";

  /// ```dart
  /// "SweetAlert.prompt foi cancelado."
  /// ```
  String get sweetPromptDismissed => """SweetAlert.prompt foi cancelado.""";

  /// ```dart
  /// "Toast SweetAlert de erro exibido no canto inferior."
  /// ```
  String get sweetErrorBody =>
      """Toast SweetAlert de erro exibido no canto inferior.""";

  /// ```dart
  /// "SweetAlert.toast executado com tipo error."
  /// ```
  String get sweetErrorState =>
      """SweetAlert.toast executado com tipo error.""";
}

class ButtonPagesMessages {
  final PagesMessages _parent;
  const ButtonPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Botões"
  /// ```
  String get subtitle => """Botões""";

  /// ```dart
  /// "Estilos e variações de botões"
  /// ```
  String get breadcrumb => """Estilos e variações de botões""";

  /// ```dart
  /// "Cores de botões"
  /// ```
  String get colorsTitle => """Cores de botões""";

  /// ```dart
  /// "Opções predefinidas de cores para botões"
  /// ```
  String get colorsSubtitle => """Opções predefinidas de cores para botões""";

  /// ```dart
  /// "Botões sólidos"
  /// ```
  String get solidTitle => """Botões sólidos""";

  /// ```dart
  /// "Botões com cor de fundo sólida"
  /// ```
  String get solidSubtitle => """Botões com cor de fundo sólida""";

  /// ```dart
  /// "Botões outline"
  /// ```
  String get outlineTitle => """Botões outline""";

  /// ```dart
  /// "Botões com fundo transparente no estado padrão"
  /// ```
  String get outlineSubtitle =>
      """Botões com fundo transparente no estado padrão""";

  /// ```dart
  /// "Botões flat"
  /// ```
  String get flatTitle => """Botões flat""";

  /// ```dart
  /// "Botões com fundo semi-transparente"
  /// ```
  String get flatSubtitle => """Botões com fundo semi-transparente""";

  /// ```dart
  /// "Botões link"
  /// ```
  String get linkTitle => """Botões link""";

  /// ```dart
  /// "Botões com estilo de link textual"
  /// ```
  String get linkSubtitle => """Botões com estilo de link textual""";

  /// ```dart
  /// "Tamanhos de botões"
  /// ```
  String get sizesTitle => """Tamanhos de botões""";

  /// ```dart
  /// "Botões nos tamanhos large, default e small"
  /// ```
  String get sizesSubtitle => """Botões nos tamanhos large, default e small""";

  /// ```dart
  /// "Alinhamento de ícones"
  /// ```
  String get alignTitle => """Alinhamento de ícones""";

  /// ```dart
  /// "Exemplos de alinhamento de ícones à esquerda e à direita"
  /// ```
  String get alignSubtitle =>
      """Exemplos de alinhamento de ícones à esquerda e à direita""";

  /// ```dart
  /// "Botões desabilitados"
  /// ```
  String get disabledTitle => """Botões desabilitados""";

  /// ```dart
  /// "Botões no estado disabled"
  /// ```
  String get disabledSubtitle => """Botões no estado disabled""";
}

Map<String, String> get messagesMap => {
      """app.brand""": """Limitless UI Example""",
      """app.searchPlaceholder""": """Documentação viva do pacote""",
      """app.badge""": """AngularDart + Limitless""",
      """app.navigation""": """Navegação""",
      """app.navigationHelp""":
          """Exemplo com ngrouter e componentes reais do pacote.""",
      """app.components""": """Componentes""",
      """app.language""": """Idioma""",
      """app.portuguese""": """Português""",
      """app.english""": """Inglês""",
      """app.theme""": """Tema""",
      """app.light""": """Claro""",
      """app.dark""": """Escuro""",
      """app.auto""": """Auto""",
      """nav.overview""": """Visão geral""",
      """nav.alerts""": """Alertas""",
      """nav.progress""": """Progresso""",
      """nav.accordion""": """Acordeão""",
      """nav.tabs""": """Abas""",
      """nav.modal""": """Modal""",
      """nav.select""": """Select""",
      """nav.multiSelect""": """Multi Select""",
      """nav.currency""": """Moeda""",
      """nav.datePicker""": """Date Picker""",
      """nav.timePicker""": """Time Picker""",
      """nav.dateRange""": """Intervalo de datas""",
      """nav.carousel""": """Carousel""",
      """nav.tooltip""": """Tooltip""",
      """nav.datatable""": """Datatable""",
      """nav.datatableSelect""": """Datatable Select""",
      """nav.notification""": """Notificação""",
      """nav.treeview""": """Treeview""",
      """nav.helpers""": """Utilitários""",
      """nav.button""": """Botões""",
      """common.restoreAlert""": """Restaurar alerta""",
      """common.none""": """Nenhum""",
      """common.open""": """Abrir""",
      """common.close""": """Fechar""",
      """common.status""": """Status""",
      """common.currentPeriod""": """Período atual""",
      """common.restrictedWindow""": """Janela restrita""",
      """pages.overview.title""": """Componentes""",
      """pages.overview.subtitle""": """Visão geral""",
      """pages.overview.breadcrumb""": """Visão geral da biblioteca""",
      """pages.overview.heroTitle""":
          """Galeria executável para documentar componentes e configurações""",
      """pages.overview.heroLead""":
          """Este example usa o tema Limitless no index.html, navega com ngrouter e renderiza componentes reais do pacote em cenários mais próximos do produto.""",
      """pages.overview.statComponentsLabel""": """Componentes""",
      """pages.overview.statComponentsHelp""":
          """Examples executáveis com API real do pacote.""",
      """pages.overview.statThemeLabel""": """Tema""",
      """pages.overview.statThemeHelp""":
          """Layout e classes alinhados com o CSS do Limitless.""",
      """pages.overview.statNavigationLabel""": """Navegação""",
      """pages.overview.statNavigationHelp""":
          """Rotas explícitas para cada grupo da vitrine.""",
      """pages.overview.organizationTitle""": """Como a demo está organizada""",
      """pages.overview.feedbackTitle""": """Feedback""",
      """pages.overview.feedbackBody""":
          """Alerts e progresso com variações visuais e estados.""",
      """pages.overview.disclosureTitle""": """Disclosure""",
      """pages.overview.disclosureBody""":
          """Accordion, tabs e modal para estruturas expansíveis.""",
      """pages.overview.inputsTitle""": """Inputs""",
      """pages.overview.inputsBody""":
          """Selects, date picker, time picker e date range picker ligados a estado real.""",
      """pages.overview.showcaseTitle""": """Showcase""",
      """pages.overview.showcaseBody""":
          """Carousel, tooltip e datatable em layout editorial.""",
      """pages.overview.featureSectionTitle""": """Páginas em destaque""",
      """pages.overview.featureSectionBody""":
          """Links diretos para telas reais da vitrine, sem cards fictícios.""",
      """pages.overview.featureDatePickerTitle""": """Date Picker""",
      """pages.overview.featureDatePickerBody""":
          """Página dedicada com variações, API e locale do seletor de data única.""",
      """pages.overview.featureTimePickerTitle""": """Time Picker""",
      """pages.overview.featureTimePickerBody""":
          """Seletor de horário com dial, AM/PM e integração por ngModel.""",
      """pages.overview.featureDateRangeTitle""": """Intervalo de datas""",
      """pages.overview.featureDateRangeBody""":
          """Fluxos de período com restrições, locale e API orientada a início e fim.""",
      """pages.overview.featureCarouselTitle""": """Carousel""",
      """pages.overview.featureCarouselBody""":
          """Transições, grid, captions e exemplos mais próximos do Limitless original.""",
      """pages.overview.featureDatatableTitle""": """Datatable""",
      """pages.overview.featureDatatableBody""":
          """Busca, seleção, exportação e alternância de visualização em dados reais.""",
      """pages.overview.featureSelectTitle""": """Select""",
      """pages.overview.featureSelectBody""":
          """Select simples com exemplos de projeção de conteúdo e fonte de dados.""",
      """pages.overview.featureTabsTitle""": """Abas""",
      """pages.overview.featureTabsBody""":
          """Estruturas em tabs e pills para organizar documentação e estados da interface.""",
      """pages.overview.featureAccordionTitle""": """Acordeão""",
      """pages.overview.featureAccordionBody""":
          """Itens expansíveis com lazy, destroyOnCollapse e headers customizados.""",
      """pages.overview.featureHelpersTitle""": """Utilitários""",
      """pages.overview.featureHelpersBody""":
          """Loading, dialogs, toasts e popovers prontos para uso.""",
      """pages.alerts.title""": """Componentes""",
      """pages.alerts.subtitle""": """Alertas""",
      """pages.alerts.breadcrumb""": """Variações de alertas""",
      """pages.alerts.cardTitle""": """Limite visual e estados""",
      """pages.alerts.intro""":
          """Esta página demonstra solid, dismissible, roundedPill, truncated, alertClass, iconContainerClass, textClass, closeButtonWhite e eventos.""",
      """pages.alerts.releaseDone""": """Deploy concluído.""",
      """pages.alerts.releaseBody""":
          """O pacote já está pronto para validação.""",
      """pages.alerts.attention""": """Atenção.""",
      """pages.alerts.solidHelp""":
          """Use solid=true quando precisar de contraste máximo.""",
      """pages.alerts.borderlessHelp""":
          """Este exemplo combina borderless, roundedPill e icone no fim do texto.""",
      """pages.alerts.customHelp""":
          """Este alerta demonstra classes customizadas no container e no bloco de ícone para casar com layouts mais editoriais sem trocar o markup base do componente.""",
      """pages.alerts.waiting""": """Aguardando interação com os alerts.""",
      """pages.alerts.restored""": """Alerta principal restaurado.""",
      """pages.alerts.dismissed""":
          """Alerta principal dispensado pelo usuário.""",
      """pages.alerts.visible""": """visibleChange: alerta visível.""",
      """pages.alerts.hidden""": """visibleChange: alerta ocultado.""",
      """pages.accordion.title""": """Componentes""",
      """pages.accordion.subtitle""": """Acordeão""",
      """pages.accordion.breadcrumb""": """Itens expansivos""",
      """pages.accordion.cardTitle""": """Configurações do accordion""",
      """pages.accordion.intro""":
          """Esta página cobre allowMultipleOpen, flush, lazy, destroyOnCollapse, item desabilitado, ícones e header customizado.""",
      """pages.accordion.collapsedHeader""": """Estado recolhido""",
      """pages.accordion.collapsedDescription""":
          """Começa fechado e expande sob demanda.""",
      """pages.accordion.collapsedBody""":
          """Ideal para listas longas que precisam manter foco visual.""",
      """pages.accordion.expandedHeader""": """Estado expandido""",
      """pages.accordion.expandedDescription""": """Item inicial aberto.""",
      """pages.accordion.expandedBody""":
          """Defina expanded=true no item que precisa abrir ao carregar.""",
      """pages.accordion.disabledHeader""": """Desabilitado""",
      """pages.accordion.disabledDescription""": """Não responde a clique.""",
      """pages.accordion.disabledBody""":
          """Este item demonstra o estado disabled.""",
      """pages.accordion.customHeader""": """Header customizado""",
      """pages.accordion.customDescription""":
          """Template com li-accordion-header.""",
      """pages.accordion.customBody""":
          """O header pode ser totalmente customizado sem perder a estrutura do accordion.""",
      """pages.accordion.templateBadge""": """template""",
      """pages.accordion.idle""": """Nenhum accordion alterado.""",
      """pages.accordion.expandedState""": """expandido""",
      """pages.accordion.collapsedState""": """recolhido""",
      """pages.progress.title""": """Componentes""",
      """pages.progress.subtitle""": """Progresso""",
      """pages.progress.breadcrumb""": """Barras simples e empilhadas""",
      """pages.progress.cardTitle""": """Estados de progresso""",
      """pages.progress.releasePipeline""": """Pipeline de release""",
      """pages.progress.releaseConfig""":
          """Config: height, rounded, showValueLabel""",
      """pages.progress.squadCapacity""": """Capacidade por squad""",
      """pages.progress.squadConfig""":
          """Config: striped, animated, barras empilhadas""",
      """pages.progress.teamProduct""": """Produto""",
      """pages.progress.customRange""": """Faixa personalizada""",
      """pages.progress.customConfig""": """Config: min, max e label textual""",
      """pages.tabs.title""": """Componentes""",
      """pages.tabs.subtitle""": """Abas""",
      """pages.tabs.breadcrumb""": """Abas horizontais e verticais""",
      """pages.tabs.cardTitle""": """Pills com header customizado""",
      """pages.tabs.tokens""": """Tokens""",
      """pages.tabs.flow""": """Fluxo""",
      """pages.tabs.blocked""": """Bloqueada""",
      """pages.tabs.tokensBody""":
          """Use tabs para separar documentação, exemplos e notas de API.""",
      """pages.tabs.flowBody""":
          """O componente respeita a composição do Bootstrap e do Limitless.""",
      """pages.tabs.blockedBody""": """Tab desabilitada.""",
      """pages.modal.title""": """Componentes""",
      """pages.modal.subtitle""": """Modal""",
      """pages.modal.breadcrumb""": """Dialogs e variações de layout""",
      """pages.modal.cardTitle""": """Exemplos de modal""",
      """pages.modal.openModal""": """Abrir modal""",
      """pages.modal.scrollableModal""": """Modal scrollable""",
      """pages.modal.modalTitle""": """Exemplo de modal""",
      """pages.modal.modalHeading""": """Composição padronizada""",
      """pages.modal.modalBody""":
          """O modal reaproveita a camada visual do Limitless e pode hospedar formulários curtos, confirmações ou visualizações detalhadas.""",
      """pages.modal.scrollableTitle""": """Modal scrollable""",
      """pages.modal.scrollableBody""":
          """Este exemplo usa dialogScrollable, fullScreenOnMobile e desabilita o fechamento no backdrop.""",
      """pages.modal.understood""": """Entendi""",
      """pages.select.title""": """Componentes""",
      """pages.select.subtitle""": """Select""",
      """pages.select.breadcrumb""": """Select simples""",
      """pages.select.cardTitle""": """Fonte de dados e projeção de conteúdo""",
      """pages.select.deliveryStatus""": """Status da entrega""",
      """pages.select.projectedTitle""": """Select com li-option""",
      """pages.select.projectedPlaceholder""": """Escolha um nível""",
      """pages.select.projectedStatus""": """Status projetado""",
      """pages.select.tabOverview""": """Visão geral""",
      """pages.select.tabApi""": """API""",
      """pages.select.tabTroubleshooting""": """Solução de problemas""",
      """pages.select.apiInputs""": """Inputs mais usados""",
      """pages.select.troubleshootingIntro""":
          """Erros que já apareceram neste componente e como evitar""",
      """pages.select.optionDraft""": """Rascunho""",
      """pages.select.optionReview""": """Em revisão""",
      """pages.select.optionApproved""": """Aprovado""",
      """pages.select.optionArchived""": """Arquivado""",
      """pages.select.optionPriority""": """Prioritário""",
      """pages.select.optionBacklog""": """Backlog""",
      """pages.multiSelect.title""": """Componentes""",
      """pages.multiSelect.subtitle""": """Multi Select""",
      """pages.multiSelect.breadcrumb""": """Seleção múltipla""",
      """pages.multiSelect.cardTitle""": """Fonte de dados e li-multi-option""",
      """pages.multiSelect.channels""": """Canais de notificação""",
      """pages.multiSelect.projectedTargets""": """Destinos projetados""",
      """pages.multiSelect.projectedPlaceholder""": """Selecione os destinos""",
      """pages.multiSelect.projectedLabel""": """Projetados""",
      """pages.multiSelect.tabOverview""": """Visão geral""",
      """pages.multiSelect.tabApi""": """API""",
      """pages.multiSelect.tabTroubleshooting""": """Solução de problemas""",
      """pages.multiSelect.apiInputs""": """Inputs mais usados""",
      """pages.multiSelect.troubleshootingIntro""":
          """Cuidados importantes para evitar regressões""",
      """pages.multiSelect.optionEmail""": """E-mail""",
      """pages.multiSelect.optionPush""": """Push""",
      """pages.multiSelect.optionSms""": """SMS""",
      """pages.multiSelect.optionWebhook""": """Webhook""",
      """pages.multiSelect.optionPortal""": """Portal""",
      """pages.multiSelect.optionApi""": """API""",
      """pages.multiSelect.optionBatch""": """Processo batch""",
      """pages.currency.title""": """Componentes""",
      """pages.currency.subtitle""": """Entrada monetária""",
      """pages.currency.breadcrumb""": """Entrada monetária em minor units""",
      """pages.currency.cardTitle""": """Formato brasileiro""",
      """pages.currency.budget""": """Orçamento""",
      """pages.currency.minorUnits""": """Minor units""",
      """pages.currency.help""":
          """O valor ligado ao ngModel sempre sai como inteiro em centavos.""",
      """pages.dateRange.title""": """Componentes""",
      """pages.dateRange.subtitle""": """Intervalo de datas""",
      """pages.dateRange.breadcrumb""": """Seleção de período""",
      """pages.dateRange.cardTitle""": """Intervalos livres e restritos""",
      """pages.dateRange.sprintPlaceholder""":
          """Selecione o periodo da sprint""",
      """pages.dateRange.publicationPlaceholder""": """Janela de publicação""",
      """pages.dateRange.partial""": """Período parcial ou não definido""",
      """pages.dateRange.unfinished""": """Janela ainda não concluída""",
      """pages.dateRange.constrainedHelp""":
          """O segundo exemplo prende a seleção com minDate e maxDate.""",
      """pages.dateRange.between""": """até""",
      """pages.timePicker.title""": """Componentes""",
      """pages.timePicker.subtitle""": """Time Picker""",
      """pages.timePicker.breadcrumb""": """Seleção de horário""",
      """pages.timePicker.cardTitle""": """API e variações do Time Picker""",
      """pages.timePicker.tabOverview""": """Visão geral""",
      """pages.timePicker.tabApi""": """API""",
      """pages.timePicker.intro""":
          """O time picker usa um dial inspirado no Limitless para seleção de hora e minuto com integração via ngModel.""",
      """pages.timePicker.descriptionTitle""": """Descrição""",
      """pages.timePicker.descriptionBody""":
          """O componente atende fluxos de agendamento, revisão, publicação e horários de operação com um overlay leve e direto.""",
      """pages.timePicker.featuresTitle""": """Recursos""",
      """pages.timePicker.featureOne""":
          """Binding direto com ngModel em Duration?.""",
      """pages.timePicker.featureTwo""":
          """Seleção por relógio com alternância entre hora e minuto.""",
      """pages.timePicker.featureThree""":
          """Toggle AM/PM integrado no próprio painel.""",
      """pages.timePicker.limitsTitle""": """Limitações""",
      """pages.timePicker.limitOne""":
          """O componente trabalha no formato de 12 horas com AM e PM.""",
      """pages.timePicker.limitTwo""":
          """Não aplica regras de janela de negócio por conta própria.""",
      """pages.timePicker.limitThree""":
          """O valor retornado considera apenas hora e minuto.""",
      """pages.timePicker.defaultTitle""": """Time picker padrão""",
      """pages.timePicker.englishTitle""": """Time picker em inglês""",
      """pages.timePicker.disabledTitle""": """Time picker desabilitado""",
      """pages.timePicker.placeholder""": """Selecione um horário""",
      """pages.timePicker.englishPlaceholder""": """Select time""",
      """pages.timePicker.disabledPlaceholder""": """Horário bloqueado""",
      """pages.timePicker.currentLabel""": """Horário atual""",
      """pages.timePicker.reviewLabel""": """Horário de revisão""",
      """pages.timePicker.disabledLabel""": """Horário bloqueado""",
      """pages.timePicker.defaultHelp""":
          """Clique no bloco de hora para trocar a hora e no de minuto para refinar os minutos.""",
      """pages.timePicker.englishHelp""":
          """O locale troca placeholder e textos auxiliares do painel.""",
      """pages.timePicker.disabledHelp""":
          """O campo continua exibindo o valor sem abrir o overlay.""",
      """pages.timePicker.notesTitle""": """Observações de uso""",
      """pages.timePicker.notesBody""":
          """O componente retorna Duration normalizada em minutos do dia, o que facilita uso com formulários e filtros sem carregar uma data completa.""",
      """pages.timePicker.noneSelected""": """Nenhum horário selecionado""",
      """pages.timePicker.apiIntro""":
          """Use o li-time-picker quando o formulário precisa escolher apenas um horário, sem data associada, mantendo integração com ngModel.""",
      """pages.timePicker.apiInputsTitle""": """Inputs principais""",
      """pages.timePicker.apiInputOne""":
          """O binding ngModel trabalha com Duration?.""",
      """pages.timePicker.apiInputTwo""":
          """locale ajusta placeholder e textos do painel.""",
      """pages.timePicker.apiInputThree""":
          """disabled impede a abertura do relógio.""",
      """pages.timePicker.apiBehaviorTitle""": """Comportamento""",
      """pages.timePicker.apiBehaviorOne""":
          """Clique no relógio para selecionar a hora e depois o minuto.""",
      """pages.timePicker.apiBehaviorTwo""":
          """O botão OK confirma a seleção e emite valueChange e ngModel.""",
      """pages.timePicker.apiBehaviorThree""":
          """AM e PM alteram a metade do dia sem recriar o valor manualmente.""",
      """pages.timePicker.apiUsageExample""": """// Exemplo de uso
selectedTime = const Duration(hours: 10, minutes: 48);

<li-time-picker
  [(ngModel)]="selectedTime"
  locale="pt_BR">
</li-time-picker>
""",
      """pages.datePicker.title""": """Componentes""",
      """pages.datePicker.subtitle""": """Date Picker""",
      """pages.datePicker.breadcrumb""": """Seleção de data única""",
      """pages.datePicker.cardTitle""": """API e variações do Date Picker""",
      """pages.datePicker.tabOverview""": """Visão geral""",
      """pages.datePicker.tabApi""": """API""",
      """pages.datePicker.tabVariations""": """Variações""",
      """pages.datePicker.intro""":
          """Esta página é dedicada ao li-date-picker, com foco em data única, troca rápida por mês/ano, locale e estados comuns do campo.""",
      """pages.datePicker.descriptionTitle""": """Descrição""",
      """pages.datePicker.descriptionBody""":
          """O date picker atende fluxos de data única como agendamento, publicação, vencimento e filtros pontuais, sem misturar responsabilidades com o seletor de intervalo.""",
      """pages.datePicker.featuresTitle""": """Recursos""",
      """pages.datePicker.featureOne""":
          """Binding direto com ngModel em DateTime?.""",
      """pages.datePicker.featureTwo""": """Restrição por minDate e maxDate.""",
      """pages.datePicker.featureThree""":
          """Aplicação imediata ao clicar no dia.""",
      """pages.datePicker.featureFour""":
          """Navegação direta por mês e ano no overlay.""",
      """pages.datePicker.limitsTitle""": """Limitações""",
      """pages.datePicker.limitOne""":
          """Não substitui regras de negócio específicas de calendário.""",
      """pages.datePicker.limitTwo""":
          """Regras especiais como feriados e datas bloqueadas continuam no componente pai.""",
      """pages.datePicker.limitThree""":
          """Datas e mensagens especiais continuam responsabilidade do componente pai.""",
      """pages.datePicker.ngModelTitle""": """Date picker com ngModel""",
      """pages.datePicker.restrictedTitle""": """Date picker com restrição""",
      """pages.datePicker.englishLocaleTitle""": """Date picker em inglês""",
      """pages.datePicker.disabledTitle""": """Date picker desabilitado""",
      """pages.datePicker.placeholder""": """Selecione uma data""",
      """pages.datePicker.restrictedPlaceholder""": """Janela permitida""",
      """pages.datePicker.englishPlaceholder""": """Choose a date""",
      """pages.datePicker.disabledPlaceholder""": """Campo bloqueado""",
      """pages.datePicker.currentDateLabel""": """Data atual""",
      """pages.datePicker.restrictedLabel""": """Data restrita""",
      """pages.datePicker.englishLabel""": """Data em EN""",
      """pages.datePicker.disabledLabel""": """Valor bloqueado""",
      """pages.datePicker.defaultHelp""":
          """Clique no cabeçalho para trocar o mês e o ano rapidamente.""",
      """pages.datePicker.restrictedHelp""":
          """Este exemplo limita a escolha entre minDate e maxDate.""",
      """pages.datePicker.englishHelp""":
          """O locale altera labels do calendário e o formato da data exibida.""",
      """pages.datePicker.disabledHelp""":
          """O campo mantém leitura do valor atual sem abrir o overlay.""",
      """pages.datePicker.noneSelected""": """Nenhuma data selecionada""",
      """pages.datePicker.partialRange""":
          """Período parcial ou não definido""",
      """pages.datePicker.apiIntro""":
          """Use o li-date-picker quando o fluxo depende de uma única data com overlay leve, ngModel, locale e restrições básicas.""",
      """pages.datePicker.apiInputsTitle""": """Inputs principais""",
      """pages.datePicker.apiInputOne""":
          """O binding [(ngModel)] funciona com DateTime?.""",
      """pages.datePicker.apiInputTwo""":
          """[minDate] e [maxDate] restringem a janela navegável e selecionável.""",
      """pages.datePicker.apiInputThree""":
          """locale ajusta labels e formato visual da data.""",
      """pages.datePicker.apiInputFour""":
          """[disabled] impede abertura e seleção.""",
      """pages.datePicker.apiBehaviorTitle""": """Comportamento""",
      """pages.datePicker.apiBehaviorOne""":
          """Clique em um dia aplica imediatamente e fecha o overlay.""",
      """pages.datePicker.apiBehaviorTwo""":
          """Clique no título do calendário para alternar entre dia, mês e ano.""",
      """pages.datePicker.apiBehaviorThree""":
          """clear() continua disponível no rodapé para limpar o valor atual.""",
      """pages.datePicker.apiBehaviorFour""":
          """valueChange e ngModel recebem a data normalizada sem horário.""",
      """pages.datePicker.apiUsageExample""": """// Exemplo de uso
selectedDate = DateTime(2026, 3, 20);

<li-date-picker
  [(ngModel)]="selectedDate"
  [minDate]="DateTime(2026, 3, 1)"
  [maxDate]="DateTime(2026, 3, 31)"
  locale="pt_BR">
</li-date-picker>
""",
      """pages.datePicker.variationStandardTitle""": """Fluxo padrão""",
      """pages.datePicker.variationStandardBody""":
          """Melhor opção para formulários em que o usuário escolhe uma data e segue adiante sem confirmação extra.""",
      """pages.datePicker.variationLocaleTitle""": """Locale visual""",
      """pages.datePicker.variationLocaleBody""":
          """A mesma API alterna labels, meses e formato exibido entre português e inglês.""",
      """pages.datePicker.variationDisabledTitle""": """Estado bloqueado""",
      """pages.datePicker.variationDisabledBody""":
          """Preserva o valor renderizado quando a data é informativa e não pode ser editada.""",
      """pages.carousel.title""": """Componentes""",
      """pages.carousel.subtitle""": """Carousel""",
      """pages.carousel.breadcrumb""":
          """Carousel com transições, captions e grid""",
      """pages.carousel.cardTitle""": """Variações do Carousel""",
      """pages.carousel.exampleLabel""": """Exemplo""",
      """pages.carousel.standardTitle""": """Carousel com Caption""",
      """pages.carousel.standardSubtitle""":
          """Indicadores e controles no padrão do Limitless, com caption branco centralizado dentro de cada slide.""",
      """pages.carousel.gridTitle""": """Carousel em Grid""",
      """pages.carousel.gridSubtitle""":
          """Você pode ter até 12 itens por slide usando o grid do Bootstrap, com row e col-* dentro de cada carousel-item.""",
      """pages.carousel.slideOneLabel""": """Arquitetura""",
      """pages.carousel.slideOneTitle""": """Primeiro slide""",
      """pages.carousel.slideOneBody""":
          """Indicadores pequenos na base e navegação lateral no padrão Bootstrap/Limitless.""",
      """pages.carousel.slideTwoLabel""": """Composição""",
      """pages.carousel.slideTwoTitle""": """Segundo slide""",
      """pages.carousel.slideTwoBody""":
          """O caption usa a classe correta do componente e respeita o posicionamento central do tema.""",
      """pages.carousel.slideThreeLabel""": """Entrega""",
      """pages.carousel.slideThreeTitle""": """Terceiro slide""",
      """pages.carousel.slideThreeBody""":
          """A navegação continua consistente mesmo com autoplay e troca manual.""",
      """pages.carousel.slideFourLabel""": """Referência""",
      """pages.carousel.slideFourTitle""": """Quarto slide""",
      """pages.carousel.slideFourBody""":
          """Estrutura equivalente ao exemplo clássico do arquivo components_carousel.html.""",
      """pages.carousel.gridSlideOneLabel""": """Coleção 1""",
      """pages.carousel.gridSlideTwoLabel""": """Coleção 2""",
      """pages.carousel.gridSlideThreeLabel""": """Coleção 3""",
      """pages.carousel.gridCardOneTitle""": """Workspace editorial""",
      """pages.carousel.gridCardOneBody""":
          """Painel visual para documentos, destaques e layouts mais narrativos.""",
      """pages.carousel.gridCardTwoTitle""": """Produto em destaque""",
      """pages.carousel.gridCardTwoBody""":
          """Estrutura pronta para vitrine de cards, mídia ou campanhas.""",
      """pages.carousel.gridCardThreeTitle""": """Jornada do usuário""",
      """pages.carousel.gridCardThreeBody""":
          """Um slide pode reunir várias entradas sem perder legibilidade.""",
      """pages.carousel.gridCardFourTitle""": """Identidade visual""",
      """pages.carousel.gridCardFourBody""":
          """Imagens maiores ajudam a validar contraste, recorte e sobreposição.""",
      """pages.carousel.gridCardFiveTitle""": """Módulos componíveis""",
      """pages.carousel.gridCardFiveBody""":
          """Carousel, Caption e Grid funcionam juntos sem markup acoplado.""",
      """pages.carousel.gridCardSixTitle""": """Demo executável""",
      """pages.carousel.gridCardSixBody""":
          """A vitrine deixa de ser estática e passa a mostrar comportamento real.""",
      """pages.carousel.gridCardSevenTitle""": """Coleção expandida""",
      """pages.carousel.gridCardSevenBody""":
          """Mais um slide para validar indicadores e transição contínua no grid.""",
      """pages.carousel.gridCardEightTitle""": """Navegação estável""",
      """pages.carousel.gridCardEightBody""":
          """Controles laterais permanecem previsíveis porque o row fica dentro do item.""",
      """pages.carousel.gridCardNineTitle""": """Estrutura correta""",
      """pages.carousel.gridCardNineBody""":
          """O item continua sendo o slide real; o grid é apenas conteúdo interno.""",
      """pages.carousel.fadeTitle""": """Carousel com Fade""",
      """pages.carousel.fadeSubtitle""":
          """Troca de slides por opacidade, sem deslocamento lateral, útil para hero banners e conteúdo com caption forte.""",
      """pages.carousel.fadeSlideOneLabel""": """Fade 1""",
      """pages.carousel.fadeSlideOneTitle""": """Fade editorial""",
      """pages.carousel.fadeSlideOneBody""":
          """O slide entra por opacidade, sem disputar atenção com movimento lateral.""",
      """pages.carousel.fadeSlideTwoLabel""": """Fade 2""",
      """pages.carousel.fadeSlideTwoTitle""": """Leitura mais limpa""",
      """pages.carousel.fadeSlideTwoBody""":
          """Funciona bem quando a imagem já tem muita textura e você quer uma troca mais discreta.""",
      """pages.carousel.fadeSlideThreeLabel""": """Fade 3""",
      """pages.carousel.fadeSlideThreeTitle""": """Transição suave""",
      """pages.carousel.fadeSlideThreeBody""":
          """O controle, indicadores e autoplay continuam iguais; muda apenas a linguagem visual da transição.""",
      """pages.carousel.zoomTitle""": """Carousel com Zoom""",
      """pages.carousel.zoomSubtitle""":
          """Entrada com escala e opacidade para uma sensação mais cinematográfica, sem alterar a estrutura do componente.""",
      """pages.carousel.zoomSlideOneLabel""": """Zoom 1""",
      """pages.carousel.zoomSlideOneTitle""": """Zoom in""",
      """pages.carousel.zoomSlideOneBody""":
          """O próximo slide entra com escala maior e assenta no plano principal ao fim da transição.""",
      """pages.carousel.zoomSlideTwoLabel""": """Zoom 2""",
      """pages.carousel.zoomSlideTwoTitle""": """Ênfase visual""",
      """pages.carousel.zoomSlideTwoBody""":
          """É uma boa variação para showcases de campanha, portfólio ou telas mais editoriais.""",
      """pages.carousel.zoomSlideThreeLabel""": """Zoom 3""",
      """pages.carousel.zoomSlideThreeTitle""": """Mesmo markup""",
      """pages.carousel.zoomSlideThreeBody""":
          """A API continua igual: o efeito muda por input, sem markup alternativo nos itens.""",
      """pages.carousel.verticalTitle""": """Carousel Vertical""",
      """pages.carousel.verticalSubtitle""":
          """A transição acontece no eixo Y, útil quando a composição da página já tem muito movimento horizontal.""",
      """pages.carousel.verticalSlideOneLabel""": """Vertical 1""",
      """pages.carousel.verticalSlideOneTitle""": """Deslocamento vertical""",
      """pages.carousel.verticalSlideOneBody""":
          """O comportamento do carousel permanece o mesmo, mas a percepção muda completamente.""",
      """pages.carousel.verticalSlideTwoLabel""": """Vertical 2""",
      """pages.carousel.verticalSlideTwoTitle""": """Fluxo alternativo""",
      """pages.carousel.verticalSlideTwoBody""":
          """Esse modo pode combinar melhor com layouts em coluna e conteúdo mais documental.""",
      """pages.carousel.verticalSlideThreeLabel""": """Vertical 3""",
      """pages.carousel.verticalSlideThreeTitle""": """API consistente""",
      """pages.carousel.verticalSlideThreeBody""":
          """Assim como no zoom, a mudança está encapsulada no componente e pode ser reutilizada em outras telas.""",
      """pages.carousel.blurTitle""": """Carousel com Blur""",
      """pages.carousel.blurSubtitle""":
          """Uma transição com desfoque e opacidade que suaviza a troca entre imagens mais detalhadas.""",
      """pages.carousel.blurSlideOneLabel""": """Blur 1""",
      """pages.carousel.blurSlideOneTitle""": """Entrada difusa""",
      """pages.carousel.blurSlideOneBody""":
          """O slide emerge com blur reduzido e opacidade crescente, criando uma mudança mais atmosférica.""",
      """pages.carousel.blurSlideTwoLabel""": """Blur 2""",
      """pages.carousel.blurSlideTwoTitle""": """Textura sob controle""",
      """pages.carousel.blurSlideTwoBody""":
          """Esse modo funciona bem quando a fotografia tem muito detalhe e o fade puro parece discreto demais.""",
      """pages.carousel.blurSlideThreeLabel""": """Blur 3""",
      """pages.carousel.blurSlideThreeTitle""": """Variação reutilizável""",
      """pages.carousel.blurSlideThreeBody""":
          """O efeito continua encapsulado no componente e pode ser aplicado em qualquer carousel via input.""",
      """pages.carousel.parallaxTitle""": """Carousel com Parallax""",
      """pages.carousel.parallaxSubtitle""":
          """Desloca a imagem com profundidade aparente, criando uma transição mais espacial entre os slides.""",
      """pages.carousel.parallaxSlideOneLabel""": """Parallax 1""",
      """pages.carousel.parallaxSlideOneTitle""": """Profundidade lateral""",
      """pages.carousel.parallaxSlideOneBody""":
          """O slide entra com deslocamento e escala levemente maior, sugerindo um plano de fundo em movimento.""",
      """pages.carousel.parallaxSlideTwoLabel""": """Parallax 2""",
      """pages.carousel.parallaxSlideTwoTitle""": """Movimento editorial""",
      """pages.carousel.parallaxSlideTwoBody""":
          """Esse modo funciona bem em vitrines visuais e páginas onde a troca de imagem precisa parecer mais física.""",
      """pages.carousel.parallaxSlideThreeLabel""": """Parallax 3""",
      """pages.carousel.parallaxSlideThreeTitle""": """Camadas sutis""",
      """pages.carousel.parallaxSlideThreeBody""":
          """A sensação de parallax é discreta e reutilizável, sem exigir markup especial nos itens.""",
      """pages.tooltip.title""": """Componentes""",
      """pages.tooltip.subtitle""": """Tooltip""",
      """pages.tooltip.breadcrumb""": """Hover, click e modo manual""",
      """pages.tooltip.cardTitle""": """Triggers e posicionamento""",
      """pages.tooltip.hoverText""": """Mostra dicas ao passar o mouse.""",
      """pages.tooltip.hoverButton""": """Hover tooltip""",
      """pages.tooltip.clickText""":
          """<strong>HTML</strong> também funciona com trigger de click.""",
      """pages.tooltip.clickButton""": """Click tooltip""",
      """pages.tooltip.manualText""":
          """Tooltip manual com controle programático.""",
      """pages.tooltip.manualButton""": """Manual tooltip""",
      """pages.tooltip.idle""": """Sem eventos de tooltip até o momento.""",
      """pages.datatable.title""": """Componentes""",
      """pages.datatable.subtitle""": """Datatable""",
      """pages.datatable.breadcrumb""": """Busca, seleção e exportação""",
      """pages.datatable.cardTitle""": """Operações da tabela""",
      """pages.datatable.toggleGrid""": """Alternar grid""",
      """pages.datatable.singleSelection""": """Seleção única""",
      """pages.datatable.searchLabel""": """Buscar sprint""",
      """pages.datatable.searchPlaceholder""": """Digite para buscar""",
      """pages.datatable.featureCol""": """Entrega""",
      """pages.datatable.ownerCol""": """Squad""",
      """pages.datatable.statusCol""": """Status""",
      """pages.datatable.healthCol""": """Saúde""",
      """pages.datatable.featureRow1""": """Painel executivo""",
      """pages.datatable.featureRow2""": """Exportação em PDF""",
      """pages.datatable.featureRow3""": """Fluxo de aprovação""",
      """pages.datatable.featureRow4""": """Alertas em tempo real""",
      """pages.datatable.ownerProduct""": """Produto""",
      """pages.datatable.ownerBackoffice""": """Backoffice""",
      """pages.datatable.ownerOperations""": """Operações""",
      """pages.datatable.ownerInfra""": """Infra""",
      """pages.datatable.statusInProgress""": """Em andamento""",
      """pages.datatable.statusDone""": """Concluído""",
      """pages.datatable.statusPlanned""": """Planejado""",
      """pages.datatable.statusBlocked""": """Bloqueado""",
      """pages.datatable.healthWarning""": """Atenção""",
      """pages.datatable.healthOk""": """Ok""",
      """pages.datatable.healthCritical""": """Crítico""",
      """pages.datatable.ready""": """Tabela pronta para interação.""",
      """pages.datatable.gridMode""":
          """Datatable alternada para o modo grade.""",
      """pages.datatable.tableMode""":
          """Datatable alternada para o modo tabela.""",
      """pages.datatable.singleMode""": """Seleção única ativada.""",
      """pages.datatable.multiMode""": """Seleção múltipla ativada.""",
      """pages.datatable.exportXlsx""": """Exportação XLSX acionada.""",
      """pages.datatable.exportPdf""": """Exportação em PDF acionada.""",
      """pages.notification.title""": """Componentes""",
      """pages.notification.subtitle""": """Área de notificações""",
      """pages.notification.breadcrumb""": """Toasts fixos no viewport""",
      """pages.notification.cardTitle""": """Disparo de notificações""",
      """pages.notification.withLink""": """Com link""",
      """pages.notification.idle""": """Nenhuma notificação disparada.""",
      """pages.notification.successMessage""":
          """Sincronização concluída com sucesso.""",
      """pages.notification.successTitle""": """Fila de eventos""",
      """pages.notification.successState""":
          """Notificação success disparada.""",
      """pages.notification.warningMessage""":
          """Existem itens aguardando validação manual.""",
      """pages.notification.warningTitle""": """Atenção""",
      """pages.notification.warningState""":
          """Notificação warning disparada.""",
      """pages.notification.linkMessage""":
          """Clique para abrir a demonstração de datatable.""",
      """pages.notification.linkTitle""": """Atalho""",
      """pages.notification.linkState""":
          """Notificação com link para datatable disparada.""",
      """pages.treeview.title""": """Componentes""",
      """pages.treeview.subtitle""": """Treeview""",
      """pages.treeview.breadcrumb""": """Estrutura hierárquica""",
      """pages.treeview.cardTitle""": """Busca, expandir e selecionar""",
      """pages.treeview.intro""":
          """O treeview inclui busca, expandir/recolher e seleção em cascata.""",
      """pages.treeview.searchPlaceholder""": """Busque por módulo ou status""",
      """pages.treeview.nodeService""": """Atendimento""",
      """pages.treeview.nodeTriage""": """Triagem""",
      """pages.treeview.nodeReferrals""": """Encaminhamentos""",
      """pages.treeview.nodeBenefits""": """Benefícios""",
      """pages.treeview.nodeFoodBasket""": """Cesta básica""",
      """pages.treeview.nodeReview""": """Em análise""",
      """pages.treeview.nodeApproved""": """Aprovado""",
      """pages.treeview.nodeRentAid""": """Auxílio aluguel""",
      """pages.helpers.title""": """Componentes""",
      """pages.helpers.subtitle""": """Utilitarios""",
      """pages.helpers.breadcrumb""": """Loading, dialogs, popovers e toasts""",
      """pages.helpers.loadingTitle""": """SimpleLoading""",
      """pages.helpers.showOverlay""": """Mostrar overlay""",
      """pages.helpers.loadingTarget""": """Area alvo do loading""",
      """pages.helpers.loadingTargetHelp""":
          """A overlay fica presa ao container.""",
      """pages.helpers.actionTitle""": """Dialogs, toasts e popovers""",
      """pages.helpers.dialogAlert""": """Dialog alert""",
      """pages.helpers.dialogConfirm""": """Dialog confirm""",
      """pages.helpers.simplePopover""": """Simple popover""",
      """pages.helpers.sweetPopover""": """Sweet popover""",
      """pages.helpers.simpleSuccessToast""": """Simple success toast""",
      """pages.helpers.simpleWarningToast""": """Simple warning toast""",
      """pages.helpers.sweetSuccessToast""": """Sweet success toast""",
      """pages.helpers.sweetWarningToast""": """Sweet warning toast""",
      """pages.helpers.sweetModal""": """Sweet modal""",
      """pages.helpers.sweetConfirm""": """Sweet confirm""",
      """pages.helpers.sweetPrompt""": """Sweet prompt""",
      """pages.helpers.sweetErrorToast""": """Sweet error toast""",
      """pages.helpers.idle""":
          """Use os botões para acionar os helpers estáticos.""",
      """pages.helpers.loadingShown""":
          """Overlay de loading exibida por 2 segundos.""",
      """pages.helpers.loadingHidden""": """Overlay de loading finalizada.""",
      """pages.helpers.dialogAlertBody""":
          """A operação foi iniciada e será monitorada em background.""",
      """pages.helpers.dialogAlertTitle""": """Execução iniciada""",
      """pages.helpers.dialogAlertState""":
          """SimpleDialog.showAlert executado.""",
      """pages.helpers.dialogConfirmBody""":
          """Deseja continuar com a publicação desta configuração?""",
      """pages.helpers.dialogConfirmTitle""": """Confirmação""",
      """pages.helpers.dialogConfirmOk""": """Publicar""",
      """pages.helpers.dialogConfirmCancel""": """Cancelar""",
      """pages.helpers.dialogConfirmTrue""":
          """Confirmação positiva retornou true.""",
      """pages.helpers.dialogConfirmFalse""": """Confirmação retornou false.""",
      """pages.helpers.simplePopoverBody""":
          """Popover simples ancorado ao botao usando markup Bootstrap/Limitless.""",
      """pages.helpers.simplePopoverState""": """SimplePopover exibido.""",
      """pages.helpers.sweetPopoverBody""":
          """Versão baseada em SweetAlert com overlay Popper.""",
      """pages.helpers.sweetPopoverTitle""": """Sweet popover""",
      """pages.helpers.sweetPopoverState""": """SweetAlertPopover exibido.""",
      """pages.helpers.simpleSuccessBody""":
          """Toast simples de sucesso exibido.""",
      """pages.helpers.simpleSuccessState""":
          """SimpleToast.showSuccess executado.""",
      """pages.helpers.simpleWarningBody""":
          """Toast simples de alerta exibido.""",
      """pages.helpers.simpleWarningState""":
          """SimpleToast.showWarning executado.""",
      """pages.helpers.sweetSuccessBody""":
          """Toast SweetAlert de sucesso exibido.""",
      """pages.helpers.sweetSuccessState""":
          """SweetAlertSimpleToast.showSuccessToast executado.""",
      """pages.helpers.sweetWarningBody""":
          """Toast SweetAlert de alerta exibido.""",
      """pages.helpers.sweetWarningState""":
          """SweetAlertSimpleToast.showWarningToast executado.""",
      """pages.helpers.sweetModalBody""":
          """O pipeline terminou com sucesso e gerou um resumo pronto para revisão.""",
      """pages.helpers.sweetModalTitle""": """Build concluído""",
      """pages.helpers.sweetModalState""": """SweetAlert.show confirmado.""",
      """pages.helpers.sweetModalDismissed""":
          """SweetAlert.show foi fechado sem confirmação.""",
      """pages.helpers.sweetConfirmBody""":
          """Deseja promover este release para produção agora?""",
      """pages.helpers.sweetConfirmTitle""": """Promover release""",
      """pages.helpers.sweetConfirmOk""": """Promover""",
      """pages.helpers.sweetConfirmCancel""": """Revisar""",
      """pages.helpers.sweetConfirmTrue""":
          """SweetAlert.confirm retornou confirmação positiva.""",
      """pages.helpers.sweetConfirmFalse""":
          """SweetAlert.confirm foi cancelado.""",
      """pages.helpers.sweetPromptBody""":
          """Informe o identificador do lote que deve receber monitoramento prioritário.""",
      """pages.helpers.sweetPromptTitle""": """Prioridade do lote""",
      """pages.helpers.sweetPromptPlaceholder""": """Ex.: lote-42""",
      """pages.helpers.sweetPromptOk""": """Salvar prioridade""",
      """pages.helpers.sweetPromptCancel""": """Agora não""",
      """pages.helpers.sweetPromptValidation""":
          """Informe um identificador antes de continuar.""",
      """pages.helpers.sweetPromptFilledPrefix""":
          """SweetAlert.prompt confirmou com valor""",
      """pages.helpers.sweetPromptDismissed""":
          """SweetAlert.prompt foi cancelado.""",
      """pages.helpers.sweetErrorBody""":
          """Toast SweetAlert de erro exibido no canto inferior.""",
      """pages.helpers.sweetErrorState""":
          """SweetAlert.toast executado com tipo error.""",
      """pages.button.title""": """Componentes""",
      """pages.button.subtitle""": """Botões""",
      """pages.button.breadcrumb""": """Estilos e variações de botões""",
      """pages.button.colorsTitle""": """Cores de botões""",
      """pages.button.colorsSubtitle""":
          """Opções predefinidas de cores para botões""",
      """pages.button.solidTitle""": """Botões sólidos""",
      """pages.button.solidSubtitle""": """Botões com cor de fundo sólida""",
      """pages.button.outlineTitle""": """Botões outline""",
      """pages.button.outlineSubtitle""":
          """Botões com fundo transparente no estado padrão""",
      """pages.button.flatTitle""": """Botões flat""",
      """pages.button.flatSubtitle""": """Botões com fundo semi-transparente""",
      """pages.button.linkTitle""": """Botões link""",
      """pages.button.linkSubtitle""": """Botões com estilo de link textual""",
      """pages.button.sizesTitle""": """Tamanhos de botões""",
      """pages.button.sizesSubtitle""":
          """Botões nos tamanhos large, default e small""",
      """pages.button.alignTitle""": """Alinhamento de ícones""",
      """pages.button.alignSubtitle""":
          """Exemplos de alinhamento de ícones à esquerda e à direita""",
      """pages.button.disabledTitle""": """Botões desabilitados""",
      """pages.button.disabledSubtitle""": """Botões no estado disabled""",
    };
