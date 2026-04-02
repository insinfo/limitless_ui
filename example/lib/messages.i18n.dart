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

  /// ```dart
  /// "FAB"
  /// ```
  String get fab => """FAB""";
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
  /// "Limpar"
  /// ```
  String get clear => """Limpar""";

  /// ```dart
  /// "Status"
  /// ```
  String get status => """Status""";

  /// ```dart
  /// "Valor"
  /// ```
  String get value => """Valor""";

  /// ```dart
  /// "Label"
  /// ```
  String get label => """Label""";

  /// ```dart
  /// "Evento"
  /// ```
  String get event => """Evento""";

  /// ```dart
  /// "Período atual"
  /// ```
  String get currentPeriod => """Período atual""";

  /// ```dart
  /// "Janela restrita"
  /// ```
  String get restrictedWindow => """Janela restrita""";

  /// ```dart
  /// "Visão geral"
  /// ```
  String get tabOverview => """Visão geral""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Descrição"
  /// ```
  String get sectionDescription => """Descrição""";

  /// ```dart
  /// "Recursos"
  /// ```
  String get sectionFeatures => """Recursos""";

  /// ```dart
  /// "Limitações"
  /// ```
  String get sectionLimitations => """Limitações""";

  /// ```dart
  /// "Como utilizar"
  /// ```
  String get sectionHowToUse => """Como utilizar""";

  /// ```dart
  /// "Observações"
  /// ```
  String get sectionNotes => """Observações""";

  /// ```dart
  /// "Exemplo visível"
  /// ```
  String get sectionVisibleExample => """Exemplo visível""";

  /// ```dart
  /// "Opções principais"
  /// ```
  String get sectionMainOptions => """Opções principais""";

  /// ```dart
  /// "Boas práticas"
  /// ```
  String get sectionBestPractices => """Boas práticas""";

  /// ```dart
  /// "Outputs"
  /// ```
  String get sectionOutputs => """Outputs""";

  /// ```dart
  /// "Métodos públicos"
  /// ```
  String get sectionPublicMethods => """Métodos públicos""";
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
  DatatableSelectPagesMessages get datatableSelect =>
      DatatableSelectPagesMessages(this);
  NotificationPagesMessages get notification => NotificationPagesMessages(this);
  TreeviewPagesMessages get treeview => TreeviewPagesMessages(this);
  HelpersPagesMessages get helpers => HelpersPagesMessages(this);
  ButtonPagesMessages get button => ButtonPagesMessages(this);
  FabPagesMessages get fab => FabPagesMessages(this);
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

  /// ```dart
  /// "API unificada para modal, confirmação, prompt, toast e também gatilho declarativo."
  /// ```
  String get featureSweetAlertBody =>
      """API unificada para modal, confirmação, prompt, toast e também gatilho declarativo.""";

  /// ```dart
  /// "Bloco leve para snippets de Dart, HTML e CSS na documentação do example."
  /// ```
  String get featureHighlightBody =>
      """Bloco leve para snippets de Dart, HTML e CSS na documentação do example.""";

  /// ```dart
  /// "Campo de texto com ngModel, floating label, textarea e addons de prefixo ou sufixo."
  /// ```
  String get featureInputsFieldBody =>
      """Campo de texto com ngModel, floating label, textarea e addons de prefixo ou sufixo.""";

  /// ```dart
  /// "Speed dial compacto para ações rápidas globais ou inline."
  /// ```
  String get featureFabBody =>
      """Speed dial compacto para ações rápidas globais ou inline.""";
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
  /// "O accordion organiza blocos densos de informação em seções expansíveis, reduzindo ruído visual sem perder contexto."
  /// ```
  String get descriptionBody =>
      """O accordion organiza blocos densos de informação em seções expansíveis, reduzindo ruído visual sem perder contexto.""";

  /// ```dart
  /// "Itens recolhidos, expandidos, desabilitados e com cabeçalho customizado."
  /// ```
  String get featureOne =>
      """Itens recolhidos, expandidos, desabilitados e com cabeçalho customizado.""";

  /// ```dart
  /// "Eventos de abertura por item."
  /// ```
  String get featureTwo => """Eventos de abertura por item.""";

  /// ```dart
  /// "Renderização tardia e destruição opcional do corpo."
  /// ```
  String get featureThree =>
      """Renderização tardia e destruição opcional do corpo.""";

  /// ```dart
  /// "Conteúdo muito interativo exige cuidado com foco."
  /// ```
  String get limitOne =>
      """Conteúdo muito interativo exige cuidado com foco.""";

  /// ```dart
  /// "Seções longas demais ainda pedem hierarquia interna."
  /// ```
  String get limitTwo =>
      """Seções longas demais ainda pedem hierarquia interna.""";

  /// ```dart
  /// "O layout não substitui navegação por rotas."
  /// ```
  String get limitThree => """O layout não substitui navegação por rotas.""";

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

  /// ```dart
  /// "API declarativa por diretivas"
  /// ```
  String get directiveApiTitle => """API declarativa por diretivas""";

  /// ```dart
  /// "Esta versão mantém o markup Bootstrap acessível no DOM e expõe uma API parecida com ng-bootstrap."
  /// ```
  String get directiveApiIntro =>
      """Esta versão mantém o markup Bootstrap acessível no DOM e expõe uma API parecida com ng-bootstrap.""";

  /// ```dart
  /// "Para destroyOnHide físico de verdade, use <template liAccordionBody>. O wrapper simples com <div liAccordionBody> mantém o conteúdo no DOM para casos em que a referência precisa permanecer estável."
  /// ```
  String get directiveApiNote =>
      """Para destroyOnHide físico de verdade, use <template liAccordionBody>. O wrapper simples com <div liAccordionBody> mantém o conteúdo no DOM para casos em que a referência precisa permanecer estável.""";

  /// ```dart
  /// "Visão geral"
  /// ```
  String get declarativeOverviewButton => """Visão geral""";

  /// ```dart
  /// "Conteúdo básico com header e body declarativos, mantendo classes e atributos de acessibilidade."
  /// ```
  String get declarativeOverviewBody =>
      """Conteúdo básico com header e body declarativos, mantendo classes e atributos de acessibilidade.""";

  /// ```dart
  /// "Header customizado"
  /// ```
  String get declarativeCustomHeader => """Header customizado""";

  /// ```dart
  /// "Alternar"
  /// ```
  String get declarativeToggle => """Alternar""";

  /// ```dart
  /// "O header pode ser totalmente customizado sem perder o controle por id, collapse e eventos."
  /// ```
  String get declarativeCustomBody =>
      """O header pode ser totalmente customizado sem perder o controle por id, collapse e eventos.""";

  /// ```dart
  /// "Item desabilitado"
  /// ```
  String get declarativeDisabledButton => """Item desabilitado""";

  /// ```dart
  /// "Este conteúdo continua acessível via API, mas não reage ao clique do usuário."
  /// ```
  String get declarativeDisabledBody =>
      """Este conteúdo continua acessível via API, mas não reage ao clique do usuário.""";

  /// ```dart
  /// "Expandir overview"
  /// ```
  String get expandOverview => """Expandir overview""";

  /// ```dart
  /// "Alternar custom"
  /// ```
  String get toggleCustom => """Alternar custom""";

  /// ```dart
  /// "Fechar todos"
  /// ```
  String get closeAll => """Fechar todos""";

  /// ```dart
  /// "API do item"
  /// ```
  String get itemApi => """API do item""";

  /// ```dart
  /// "Nenhum evento da API declarativa."
  /// ```
  String get declarativeIdle => """Nenhum evento da API declarativa.""";

  /// ```dart
  /// "liCollapse"
  /// ```
  String get collapseTitle => """liCollapse""";

  /// ```dart
  /// "Diretiva genérica para esconder e mostrar blocos com as classes collapse, show e collapsing."
  /// ```
  String get collapseIntro =>
      """Diretiva genérica para esconder e mostrar blocos com as classes collapse, show e collapsing.""";

  /// ```dart
  /// "Abrir painel"
  /// ```
  String get openPanel => """Abrir painel""";

  /// ```dart
  /// "Fechar painel"
  /// ```
  String get closePanel => """Fechar painel""";

  /// ```dart
  /// "Este bloco usa a diretiva genérica de collapse, sem depender do accordion."
  /// ```
  String get collapseBody =>
      """Este bloco usa a diretiva genérica de collapse, sem depender do accordion.""";

  /// ```dart
  /// "[allowMultipleOpen] permite manter mais de um item expandido ao mesmo tempo."
  /// ```
  String get apiOne =>
      """[allowMultipleOpen] permite manter mais de um item expandido ao mesmo tempo.""";

  /// ```dart
  /// "[flush] remove contornos extras para uma composição mais compacta."
  /// ```
  String get apiTwo =>
      """[flush] remove contornos extras para uma composição mais compacta.""";

  /// ```dart
  /// "[lazy] adia a renderização do corpo até a primeira abertura."
  /// ```
  String get apiThree =>
      """[lazy] adia a renderização do corpo até a primeira abertura.""";

  /// ```dart
  /// "[destroyOnCollapse] remove o conteúdo do DOM quando o item fecha."
  /// ```
  String get apiFour =>
      """[destroyOnCollapse] remove o conteúdo do DOM quando o item fecha.""";

  /// ```dart
  /// "[expanded] e (expandedChange) controlam abertura por item."
  /// ```
  String get apiFive =>
      """[expanded] e (expandedChange) controlam abertura por item.""";
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
  /// "A página de tabs demonstra composição horizontal, vertical, cabeçalhos customizados e estados desabilitados."
  /// ```
  String get overviewIntro =>
      """A página de tabs demonstra composição horizontal, vertical, cabeçalhos customizados e estados desabilitados.""";

  /// ```dart
  /// "Tabs organizam conteúdo em camadas sem quebrar o contexto da tela e funcionam bem para documentação, formulários segmentados e painéis administrativos."
  /// ```
  String get descriptionBody =>
      """Tabs organizam conteúdo em camadas sem quebrar o contexto da tela e funcionam bem para documentação, formulários segmentados e painéis administrativos.""";

  /// ```dart
  /// "Modo tabs e pills."
  /// ```
  String get featureOne => """Modo tabs e pills.""";

  /// ```dart
  /// "Posicionamento horizontal ou lateral."
  /// ```
  String get featureTwo => """Posicionamento horizontal ou lateral.""";

  /// ```dart
  /// "Cabeçalho projetado e abas desabilitadas."
  /// ```
  String get featureThree => """Cabeçalho projetado e abas desabilitadas.""";

  /// ```dart
  /// "Muitas abas no mesmo nível prejudicam escaneabilidade."
  /// ```
  String get limitOne =>
      """Muitas abas no mesmo nível prejudicam escaneabilidade.""";

  /// ```dart
  /// "Conteúdo longo demais pede hierarquia adicional."
  /// ```
  String get limitTwo => """Conteúdo longo demais pede hierarquia adicional.""";

  /// ```dart
  /// "Abas aninhadas devem ser isoladas em subcomponentes."
  /// ```
  String get limitThree =>
      """Abas aninhadas devem ser isoladas em subcomponentes.""";

  /// ```dart
  /// "Exemplo visível"
  /// ```
  String get previewTitle => """Exemplo visível""";

  /// ```dart
  /// "O exemplo abaixo mostra pills laterais com cabeçalho customizado e uma aba desabilitada, sem contaminar a navegação da página de documentação."
  /// ```
  String get previewIntro =>
      """O exemplo abaixo mostra pills laterais com cabeçalho customizado e uma aba desabilitada, sem contaminar a navegação da página de documentação.""";

  /// ```dart
  /// "Use o componente para agrupar conteúdo relacionado quando a navegação por seções fizer mais sentido do que empilhar cards ou abrir novas rotas."
  /// ```
  String get apiIntro =>
      """Use o componente para agrupar conteúdo relacionado quando a navegação por seções fizer mais sentido do que empilhar cards ou abrir novas rotas.""";

  /// ```dart
  /// "type aceita tabs ou pills."
  /// ```
  String get apiOne => """type aceita tabs ou pills.""";

  /// ```dart
  /// "placement controla a posição das abas, como topo ou lateral."
  /// ```
  String get apiTwo =>
      """placement controla a posição das abas, como topo ou lateral.""";

  /// ```dart
  /// "[justified] distribui os gatilhos de forma uniforme."
  /// ```
  String get apiThree =>
      """[justified] distribui os gatilhos de forma uniforme.""";

  /// ```dart
  /// "[active] e [disabled] controlam estado por aba."
  /// ```
  String get apiFour => """[active] e [disabled] controlam estado por aba.""";

  /// ```dart
  /// "template li-tabx-header permite cabeçalhos customizados."
  /// ```
  String get apiFive =>
      """template li-tabx-header permite cabeçalhos customizados.""";

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
  /// "A demo de select mostra uso com dataSource estável e com projeção manual de opções, reunindo descrição, recursos, limitações e exemplos visíveis no mesmo fluxo."
  /// ```
  String get overviewIntro =>
      """A demo de select mostra uso com dataSource estável e com projeção manual de opções, reunindo descrição, recursos, limitações e exemplos visíveis no mesmo fluxo.""";

  /// ```dart
  /// "Descrição"
  /// ```
  String get descriptionTitle => """Descrição""";

  /// ```dart
  /// "O componente resolve seleção simples com overlay, opção projetada e ligação direta ao ngModel."
  /// ```
  String get descriptionBody =>
      """O componente resolve seleção simples com overlay, opção projetada e ligação direta ao ngModel.""";

  /// ```dart
  /// "Recursos"
  /// ```
  String get featuresTitle => """Recursos""";

  /// ```dart
  /// "Fonte externa com dataSource."
  /// ```
  String get featureOne => """Fonte externa com dataSource.""";

  /// ```dart
  /// "Projeção manual com li-option."
  /// ```
  String get featureTwo => """Projeção manual com li-option.""";

  /// ```dart
  /// "Placeholder, itens desabilitados e binding simples."
  /// ```
  String get featureThree =>
      """Placeholder, itens desabilitados e binding simples.""";

  /// ```dart
  /// "Limitações"
  /// ```
  String get limitsTitle => """Limitações""";

  /// ```dart
  /// "Evite recriar o dataSource em getters reativos."
  /// ```
  String get limitOne => """Evite recriar o dataSource em getters reativos.""";

  /// ```dart
  /// "O overlay depende de opções consistentes para navegação e altura."
  /// ```
  String get limitTwo =>
      """O overlay depende de opções consistentes para navegação e altura.""";

  /// ```dart
  /// "Para lógica pesada de filtro, mantenha a orquestração no componente pai."
  /// ```
  String get limitThree =>
      """Para lógica pesada de filtro, mantenha a orquestração no componente pai.""";

  /// ```dart
  /// "Como utilizar"
  /// ```
  String get apiTitle => """Como utilizar""";

  /// ```dart
  /// "li-select aceita tanto [dataSource] quanto projeção com li-option. Para evitar travamentos e ciclos de renderização desnecessários, prefira fornecer listas estáveis no componente pai, em vez de getters que recriam o array a cada mudança de estado."
  /// ```
  String get apiIntro =>
      """li-select aceita tanto [dataSource] quanto projeção com li-option. Para evitar travamentos e ciclos de renderização desnecessários, prefira fornecer listas estáveis no componente pai, em vez de getters que recriam o array a cada mudança de estado.""";

  /// ```dart
  /// "lista de opções externas."
  /// ```
  String get apiDataSource => """lista de opções externas.""";

  /// ```dart
  /// "chave usada para o texto visível."
  /// ```
  String get apiLabelKey => """chave usada para o texto visível.""";

  /// ```dart
  /// "chave usada como valor do ngModel."
  /// ```
  String get apiValueKey => """chave usada como valor do ngModel.""";

  /// ```dart
  /// "chave booleana para desabilitar itens."
  /// ```
  String get apiDisabledKey => """chave booleana para desabilitar itens.""";

  /// ```dart
  /// "valor selecionado."
  /// ```
  String get apiNgModel => """valor selecionado.""";

  /// ```dart
  /// "texto exibido quando vazio."
  /// ```
  String get apiPlaceholder => """texto exibido quando vazio.""";

  /// ```dart
  /// "Observações e limites"
  /// ```
  String get notesTitle => """Observações e limites""";

  /// ```dart
  /// "Não recrie o dataSource em getters."
  /// ```
  String get noteOne => """Não recrie o dataSource em getters.""";

  /// ```dart
  /// "O overlay não deve calcular altura com base no próprio painel renderizado."
  /// ```
  String get noteTwo =>
      """O overlay não deve calcular altura com base no próprio painel renderizado.""";

  /// ```dart
  /// "Eventos globais de teclado devem tratar apenas navegação e escape."
  /// ```
  String get noteThree =>
      """Eventos globais de teclado devem tratar apenas navegação e escape.""";

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
  /// "A demo de multiseleção mostra seleção múltipla com dataSource estável, projeção manual e documentação organizada entre visão geral e API."
  /// ```
  String get overviewIntro =>
      """A demo de multiseleção mostra seleção múltipla com dataSource estável, projeção manual e documentação organizada entre visão geral e API.""";

  /// ```dart
  /// "Descrição"
  /// ```
  String get descriptionTitle => """Descrição""";

  /// ```dart
  /// "O componente mantém uma coleção de valores selecionados e projeta o resultado diretamente no trigger."
  /// ```
  String get descriptionBody =>
      """O componente mantém uma coleção de valores selecionados e projeta o resultado diretamente no trigger.""";

  /// ```dart
  /// "Recursos"
  /// ```
  String get featuresTitle => """Recursos""";

  /// ```dart
  /// "Seleção múltipla com badges e placeholder."
  /// ```
  String get featureOne => """Seleção múltipla com badges e placeholder.""";

  /// ```dart
  /// "Botão de limpar seleção ao lado da seta quando há valores marcados."
  /// ```
  String get featureTwo =>
      """Botão de limpar seleção ao lado da seta quando há valores marcados.""";

  /// ```dart
  /// "Integração com dataSource ou li-multi-option."
  /// ```
  String get featureThree =>
      """Integração com dataSource ou li-multi-option.""";

  /// ```dart
  /// "Binding direto com listas no ngModel."
  /// ```
  String get featureFour => """Binding direto com listas no ngModel.""";

  /// ```dart
  /// "Limitações"
  /// ```
  String get limitsTitle => """Limitações""";

  /// ```dart
  /// "Evite recriar listas de opções em getters reativos."
  /// ```
  String get limitOne =>
      """Evite recriar listas de opções em getters reativos.""";

  /// ```dart
  /// "O overlay precisa de atualização consistente ao mudar a seleção."
  /// ```
  String get limitTwo =>
      """O overlay precisa de atualização consistente ao mudar a seleção.""";

  /// ```dart
  /// "Para coleções muito grandes, mantenha paginação ou busca no pai."
  /// ```
  String get limitThree =>
      """Para coleções muito grandes, mantenha paginação ou busca no pai.""";

  /// ```dart
  /// "Como utilizar"
  /// ```
  String get apiTitle => """Como utilizar""";

  /// ```dart
  /// "li-multi-select segue a mesma estratégia do li-select, mas mantém múltiplos valores selecionados e renderiza badges no trigger."
  /// ```
  String get apiIntroOne =>
      """li-multi-select segue a mesma estratégia do li-select, mas mantém múltiplos valores selecionados e renderiza badges no trigger.""";

  /// ```dart
  /// "O padrão recomendado para o demo e para produção é manter dataSource estável e atualizar apenas a coleção de valores selecionados."
  /// ```
  String get apiIntroTwo =>
      """O padrão recomendado para o demo e para produção é manter dataSource estável e atualizar apenas a coleção de valores selecionados.""";

  /// ```dart
  /// "lista de opções externas."
  /// ```
  String get apiDataSource => """lista de opções externas.""";

  /// ```dart
  /// "chave usada para o texto visível."
  /// ```
  String get apiLabelKey => """chave usada para o texto visível.""";

  /// ```dart
  /// "chave usada no array do ngModel."
  /// ```
  String get apiValueKey => """chave usada no array do ngModel.""";

  /// ```dart
  /// "lista de valores selecionados."
  /// ```
  String get apiNgModel => """lista de valores selecionados.""";

  /// ```dart
  /// "texto quando nada está marcado."
  /// ```
  String get apiPlaceholder => """texto quando nada está marcado.""";

  /// ```dart
  /// "mostra o X para limpar tudo no trigger."
  /// ```
  String get apiShowClearButton =>
      """mostra o X para limpar tudo no trigger.""";

  /// ```dart
  /// "Observações e limites"
  /// ```
  String get notesTitle => """Observações e limites""";

  /// ```dart
  /// "Não recrie a lista de opções em getters reativos."
  /// ```
  String get noteOne => """Não recrie a lista de opções em getters reativos.""";

  /// ```dart
  /// "Agende overlay.update() em frame futuro ao mudar a seleção."
  /// ```
  String get noteTwo =>
      """Agende overlay.update() em frame futuro ao mudar a seleção.""";

  /// ```dart
  /// "Calcule maxHeight pelo viewport, não pela altura atual do painel."
  /// ```
  String get noteThree =>
      """Calcule maxHeight pelo viewport, não pela altura atual do painel.""";

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

  /// ```dart
  /// "Visão geral"
  /// ```
  String get tabOverview => """Visão geral""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Descrição"
  /// ```
  String get descriptionTitle => """Descrição""";

  /// ```dart
  /// "O campo monetário resolve formatação visual e conversão para unidades menores sem lógica adicional no template."
  /// ```
  String get descriptionBody =>
      """O campo monetário resolve formatação visual e conversão para unidades menores sem lógica adicional no template.""";

  /// ```dart
  /// "Recursos"
  /// ```
  String get featuresTitle => """Recursos""";

  /// ```dart
  /// "Suporte a locale e currencyCode."
  /// ```
  String get featureOne => """Suporte a locale e currencyCode.""";

  /// ```dart
  /// "Conversão automática para minor units."
  /// ```
  String get featureTwo => """Conversão automática para minor units.""";

  /// ```dart
  /// "Integração com formulários AngularDart."
  /// ```
  String get featureThree => """Integração com formulários AngularDart.""";

  /// ```dart
  /// "Limitações"
  /// ```
  String get limitsTitle => """Limitações""";

  /// ```dart
  /// "O campo não substitui regras fiscais de negócio."
  /// ```
  String get limitOne => """O campo não substitui regras fiscais de negócio.""";

  /// ```dart
  /// "Máscaras muito específicas exigem extensão adicional."
  /// ```
  String get limitTwo =>
      """Máscaras muito específicas exigem extensão adicional.""";

  /// ```dart
  /// "O valor persistido continua sendo numérico."
  /// ```
  String get limitThree => """O valor persistido continua sendo numérico.""";

  /// ```dart
  /// "O mesmo componente agora aceita BRL, USD e EUR trocando apenas currencyCode e locale."
  /// ```
  String get summaryHelp =>
      """O mesmo componente agora aceita BRL, USD e EUR trocando apenas currencyCode e locale.""";

  /// ```dart
  /// "Use o componente para exibir o valor formatado ao usuário e manter no estado um número consistente em unidades menores."
  /// ```
  String get apiIntro =>
      """Use o componente para exibir o valor formatado ao usuário e manter no estado um número consistente em unidades menores.""";

  /// ```dart
  /// "[(ngModel)] trabalha com o valor em minor units."
  /// ```
  String get apiOne => """[(ngModel)] trabalha com o valor em minor units.""";

  /// ```dart
  /// "currencyCode e locale controlam símbolo e separadores."
  /// ```
  String get apiTwo =>
      """currencyCode e locale controlam símbolo e separadores.""";

  /// ```dart
  /// "prefix continua disponível para sobrescrever o símbolo automaticamente resolvido."
  /// ```
  String get apiThree =>
      """prefix continua disponível para sobrescrever o símbolo automaticamente resolvido.""";

  /// ```dart
  /// "[required] integra validação ao formulário."
  /// ```
  String get apiFour => """[required] integra validação ao formulário.""";

  /// ```dart
  /// "inputClass permite aplicar classes utilitárias no campo."
  /// ```
  String get apiFive =>
      """inputClass permite aplicar classes utilitárias no campo.""";
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
  /// "Visão geral"
  /// ```
  String get tabOverview => """Visão geral""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Descrição"
  /// ```
  String get descriptionTitle => """Descrição""";

  /// ```dart
  /// "O date range picker atende fluxos de período contínuo para filtros, sprints, publicações e recortes operacionais."
  /// ```
  String get descriptionBody =>
      """O date range picker atende fluxos de período contínuo para filtros, sprints, publicações e recortes operacionais.""";

  /// ```dart
  /// "Recursos"
  /// ```
  String get featuresTitle => """Recursos""";

  /// ```dart
  /// "Binding separado para início e fim."
  /// ```
  String get featureOne => """Binding separado para início e fim.""";

  /// ```dart
  /// "Restrições por intervalo mínimo e máximo."
  /// ```
  String get featureTwo => """Restrições por intervalo mínimo e máximo.""";

  /// ```dart
  /// "Placeholder e locale configuráveis."
  /// ```
  String get featureThree => """Placeholder e locale configuráveis.""";

  /// ```dart
  /// "Limitações"
  /// ```
  String get limitsTitle => """Limitações""";

  /// ```dart
  /// "O componente não aplica regras de calendário de negócio sozinho."
  /// ```
  String get limitOne =>
      """O componente não aplica regras de calendário de negócio sozinho.""";

  /// ```dart
  /// "Validações mais específicas continuam no pai."
  /// ```
  String get limitTwo => """Validações mais específicas continuam no pai.""";

  /// ```dart
  /// "Fluxos complexos podem exigir presets externos."
  /// ```
  String get limitThree =>
      """Fluxos complexos podem exigir presets externos.""";

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

  /// ```dart
  /// "Use o componente quando o fluxo depender de um intervalo com datas inicial e final claramente controladas pelo componente pai."
  /// ```
  String get apiIntro =>
      """Use o componente quando o fluxo depender de um intervalo com datas inicial e final claramente controladas pelo componente pai.""";

  /// ```dart
  /// "[inicio] e (inicioChange) controlam a data inicial."
  /// ```
  String get apiOne =>
      """[inicio] e (inicioChange) controlam a data inicial.""";

  /// ```dart
  /// "[fim] e (fimChange) controlam a data final."
  /// ```
  String get apiTwo => """[fim] e (fimChange) controlam a data final.""";

  /// ```dart
  /// "[minDate] e [maxDate] restringem a janela selecionável."
  /// ```
  String get apiThree =>
      """[minDate] e [maxDate] restringem a janela selecionável.""";

  /// ```dart
  /// "[placeholder] e locale ajustam a comunicação do campo."
  /// ```
  String get apiFour =>
      """[placeholder] e locale ajustam a comunicação do campo.""";
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
  /// "Suporte aos formatos 12h com AM/PM e 24 horas."
  /// ```
  String get featureThree =>
      """Suporte aos formatos 12h com AM/PM e 24 horas.""";

  /// ```dart
  /// "Limitações"
  /// ```
  String get limitsTitle => """Limitações""";

  /// ```dart
  /// "O formato exibido depende de use24Hour e do locale configurado."
  /// ```
  String get limitOne =>
      """O formato exibido depende de use24Hour e do locale configurado.""";

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
  /// "Time picker 24 horas"
  /// ```
  String get twentyFourHourTitle => """Time picker 24 horas""";

  /// ```dart
  /// "Selecione o horário"
  /// ```
  String get twentyFourHourPlaceholder => """Selecione o horário""";

  /// ```dart
  /// "Horário atual"
  /// ```
  String get twentyFourHourCurrentLabel => """Horário atual""";

  /// ```dart
  /// "Use use24Hour para exibir e editar o valor sem AM/PM."
  /// ```
  String get twentyFourHourHelp =>
      """Use use24Hour para exibir e editar o valor sem AM/PM.""";

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
  /// "A datatable desta biblioteca cobre o fluxo administrativo mais comum: busca por campo, seleção de linhas, exportação, paginação, ordenação, colapso responsivo e uma camada de customização visual por coluna, por linha e por card."
  /// ```
  String get overviewIntro =>
      """A datatable desta biblioteca cobre o fluxo administrativo mais comum: busca por campo, seleção de linhas, exportação, paginação, ordenação, colapso responsivo e uma camada de customização visual por coluna, por linha e por card.""";

  /// ```dart
  /// "O componente atende listagens operacionais que precisam alternar entre tabela e grade sem duplicar fonte de dados, regras de ordenação ou comportamento de busca."
  /// ```
  String get descriptionBody =>
      """O componente atende listagens operacionais que precisam alternar entre tabela e grade sem duplicar fonte de dados, regras de ordenação ou comportamento de busca.""";

  /// ```dart
  /// "Busca direcionada por coluna com campo e operador configuráveis."
  /// ```
  String get featureOne =>
      """Busca direcionada por coluna com campo e operador configuráveis.""";

  /// ```dart
  /// "Exportação para XLSX e PDF usando a própria API do componente."
  /// ```
  String get featureTwo =>
      """Exportação para XLSX e PDF usando a própria API do componente.""";

  /// ```dart
  /// "Modo tabela e modo grade com a mesma fonte de dados."
  /// ```
  String get featureThree =>
      """Modo tabela e modo grade com a mesma fonte de dados.""";

  /// ```dart
  /// "Largura, alinhamento, classes e estilos por coluna e por linha."
  /// ```
  String get featureFour =>
      """Largura, alinhamento, classes e estilos por coluna e por linha.""";

  /// ```dart
  /// "Cards customizados com customCardBuilder em grid mode."
  /// ```
  String get featureFive =>
      """Cards customizados com customCardBuilder em grid mode.""";

  /// ```dart
  /// "cellStyleResolver trabalha com CSS inline, então não substitui um tema completo."
  /// ```
  String get limitOne =>
      """cellStyleResolver trabalha com CSS inline, então não substitui um tema completo.""";

  /// ```dart
  /// "customCardBuilder é ideal para cards ricos, mas exige montagem manual do markup."
  /// ```
  String get limitTwo =>
      """customCardBuilder é ideal para cards ricos, mas exige montagem manual do markup.""";

  /// ```dart
  /// "O colapso mobile continua orientado a colunas, então layouts muito densos pedem curadoria das colunas secundárias."
  /// ```
  String get limitThree =>
      """O colapso mobile continua orientado a colunas, então layouts muito densos pedem curadoria das colunas secundárias.""";

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
  /// "Demo principal com busca, seleção, exportação e alternância entre tabela e grade."
  /// ```
  String get demoIntro =>
      """Demo principal com busca, seleção, exportação e alternância entre tabela e grade.""";

  /// ```dart
  /// "Demos sob demanda"
  /// ```
  String get onDemandTitle => """Demos sob demanda""";

  /// ```dart
  /// "Os exemplos abaixo usam li-accordion com carregamento tardio para evitar que todos os datatables entrem no DOM ao abrir a rota."
  /// ```
  String get onDemandIntro =>
      """Os exemplos abaixo usam li-accordion com carregamento tardio para evitar que todos os datatables entrem no DOM ao abrir a rota.""";

  /// ```dart
  /// "Exemplo somente leitura"
  /// ```
  String get readonlyTitle => """Exemplo somente leitura""";

  /// ```dart
  /// "Busca e ordenação sem clique de linha nem seleção."
  /// ```
  String get readonlyDescription =>
      """Busca e ordenação sem clique de linha nem seleção.""";

  /// ```dart
  /// "Exemplo em modo grade"
  /// ```
  String get gridPreviewTitle => """Exemplo em modo grade""";

  /// ```dart
  /// "Mesmo dataset reaproveitado como cartões."
  /// ```
  String get gridPreviewDescription =>
      """Mesmo dataset reaproveitado como cartões.""";

  /// ```dart
  /// "Tabela com width, cor por coluna e cor por linha"
  /// ```
  String get customTableTitle =>
      """Tabela com width, cor por coluna e cor por linha""";

  /// ```dart
  /// "Combina width fixa, cellStyleResolver e rowStyleResolver no mesmo cenário."
  /// ```
  String get customTableDescription =>
      """Combina width fixa, cellStyleResolver e rowStyleResolver no mesmo cenário.""";

  /// ```dart
  /// "Grid com customCardBuilder"
  /// ```
  String get customGridTitle => """Grid com customCardBuilder""";

  /// ```dart
  /// "Card montado manualmente só quando o item é aberto."
  /// ```
  String get customGridDescription =>
      """Card montado manualmente só quando o item é aberto.""";

  /// ```dart
  /// "Modal lazy loading com datatable"
  /// ```
  String get lazyModalTitle => """Modal lazy loading com datatable""";

  /// ```dart
  /// "Este cenário abre um li-modal com lazyContent e instancia o li-datatable somente depois da abertura."
  /// ```
  String get lazyModalIntro =>
      """Este cenário abre um li-modal com lazyContent e instancia o li-datatable somente depois da abertura.""";

  /// ```dart
  /// "Abrir modal lazy"
  /// ```
  String get openLazyModal => """Abrir modal lazy""";

  /// ```dart
  /// "Modal lazy com datatable"
  /// ```
  String get modalTitle => """Modal lazy com datatable""";

  /// ```dart
  /// "O conteúdo do modal só entra no DOM quando ele abre. O datatable reutiliza o mesmo dataset da página para verificar se o primeiro render funciona corretamente."
  /// ```
  String get modalBody =>
      """O conteúdo do modal só entra no DOM quando ele abre. O datatable reutiliza o mesmo dataset da página para verificar se o primeiro render funciona corretamente.""";

  /// ```dart
  /// "O componente é controlado por três peças: Filters para paginação e busca, DataFrame para os dados e DatatableSettings para as colunas e o comportamento visual."
  /// ```
  String get howToUseBody =>
      """O componente é controlado por três peças: Filters para paginação e busca, DataFrame para os dados e DatatableSettings para as colunas e o comportamento visual.""";

  /// ```dart
  /// "[dataTableFilter]: controla limite, offset, busca e ordenação."
  /// ```
  String get optionOne =>
      """[dataTableFilter]: controla limite, offset, busca e ordenação.""";

  /// ```dart
  /// "[settings]: define colunas, grid e builders customizados."
  /// ```
  String get optionTwo =>
      """[settings]: define colunas, grid e builders customizados.""";

  /// ```dart
  /// "[searchInFields]: informa quais campos aparecem no seletor de busca."
  /// ```
  String get optionThree =>
      """[searchInFields]: informa quais campos aparecem no seletor de busca.""";

  /// ```dart
  /// "[responsiveCollapse]: move colunas secundárias para a linha filha no mobile."
  /// ```
  String get optionFour =>
      """[responsiveCollapse]: move colunas secundárias para a linha filha no mobile.""";

  /// ```dart
  /// "Mantenha o DataFrame estável e atualize apenas filtros e seleção."
  /// ```
  String get practiceOne =>
      """Mantenha o DataFrame estável e atualize apenas filtros e seleção.""";

  /// ```dart
  /// "Use hideOnMobile nas colunas secundárias."
  /// ```
  String get practiceTwo => """Use hideOnMobile nas colunas secundárias.""";

  /// ```dart
  /// "Reserve customCardBuilder para grids que realmente precisam fugir do layout padrão."
  /// ```
  String get practiceThree =>
      """Reserve customCardBuilder para grids que realmente precisam fugir do layout padrão.""";

  /// ```dart
  /// "Colunas e estilos"
  /// ```
  String get columnStylesTitle => """Colunas e estilos""";

  /// ```dart
  /// "width, minWidth e maxWidth controlam a largura efetiva da coluna."
  /// ```
  String get columnStyleOne =>
      """width, minWidth e maxWidth controlam a largura efetiva da coluna.""";

  /// ```dart
  /// "headerClass e cellClass adicionam classes sem mexer no template."
  /// ```
  String get columnStyleTwo =>
      """headerClass e cellClass adicionam classes sem mexer no template.""";

  /// ```dart
  /// "styleCss e cellStyleResolver controlam cor e estilo por coluna."
  /// ```
  String get columnStyleThree =>
      """styleCss e cellStyleResolver controlam cor e estilo por coluna.""";

  /// ```dart
  /// "rowStyleResolver devolve uma string CSS por linha inteira com base nos dados."
  /// ```
  String get columnStyleFour =>
      """rowStyleResolver devolve uma string CSS por linha inteira com base nos dados.""";

  /// ```dart
  /// "textAlign e nowrap ajustam leitura para colunas curtas ou status."
  /// ```
  String get columnStyleFive =>
      """textAlign e nowrap ajustam leitura para colunas curtas ou status.""";

  /// ```dart
  /// "CustomCardBuilder"
  /// ```
  String get customCardEyebrow => """CustomCardBuilder""";

  /// ```dart
  /// "Responsável"
  /// ```
  String get ownerPrefix => """Responsável""";

  /// ```dart
  /// "O card foi montado manualmente para combinar título, estado e metadados sem depender do layout padrão."
  /// ```
  String get customCardSummary =>
      """O card foi montado manualmente para combinar título, estado e metadados sem depender do layout padrão.""";

  /// ```dart
  /// "Sincronizar cadastro com ERP"
  /// ```
  String get featureRow5 => """Sincronizar cadastro com ERP""";

  /// ```dart
  /// "Publicar relatório operacional"
  /// ```
  String get featureRow6 => """Publicar relatório operacional""";

  /// ```dart
  /// "Revisar fila de integração"
  /// ```
  String get featureRow7 => """Revisar fila de integração""";

  /// ```dart
  /// "Atualizar painel de atendimento"
  /// ```
  String get featureRow8 => """Atualizar painel de atendimento""";

  /// ```dart
  /// "Financeiro"
  /// ```
  String get ownerFinance => """Financeiro""";

  /// ```dart
  /// "Atendimento"
  /// ```
  String get ownerSupport => """Atendimento""";

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

class DatatableSelectPagesMessages {
  final PagesMessages _parent;
  const DatatableSelectPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "Datatable Select"
  /// ```
  String get subtitle => """Datatable Select""";

  /// ```dart
  /// "Select com datatable em modal"
  /// ```
  String get breadcrumb => """Select com datatable em modal""";

  /// ```dart
  /// "Um select que abre um modal com um datatable completo, permitindo busca, paginação e ordenação. Ao clicar em uma linha, o item é selecionado e o modal fecha."
  /// ```
  String get overviewIntro =>
      """Um select que abre um modal com um datatable completo, permitindo busca, paginação e ordenação. Ao clicar em uma linha, o item é selecionado e o modal fecha.""";

  /// ```dart
  /// "O componente combina um trigger no formato form-select com um modal que exibe um li-datatable completo. Implementa ControlValueAccessor para compatibilidade com ngModel."
  /// ```
  String get descriptionBody =>
      """O componente combina um trigger no formato form-select com um modal que exibe um li-datatable completo. Implementa ControlValueAccessor para compatibilidade com ngModel.""";

  /// ```dart
  /// "Busca, paginação e ordenação via li-datatable."
  /// ```
  String get featureOne => """Busca, paginação e ordenação via li-datatable.""";

  /// ```dart
  /// "Seleção por clique de linha."
  /// ```
  String get featureTwo => """Seleção por clique de linha.""";

  /// ```dart
  /// "Suporte a ngModel e currentValueChange."
  /// ```
  String get featureThree => """Suporte a ngModel e currentValueChange.""";

  /// ```dart
  /// "Tamanho do modal configurável."
  /// ```
  String get featureFour => """Tamanho do modal configurável.""";

  /// ```dart
  /// "Estados desabilitado e programático."
  /// ```
  String get featureFive => """Estados desabilitado e programático.""";

  /// ```dart
  /// "Requer dataRequest para fornecer dados ao datatable."
  /// ```
  String get limitOne =>
      """Requer dataRequest para fornecer dados ao datatable.""";

  /// ```dart
  /// "O label exibido depende de labelKey sem projeção customizada."
  /// ```
  String get limitTwo =>
      """O label exibido depende de labelKey sem projeção customizada.""";

  /// ```dart
  /// "Não suporta seleção múltipla."
  /// ```
  String get limitThree => """Não suporta seleção múltipla.""";

  /// ```dart
  /// "Uso básico com currentValueChange e controle programático."
  /// ```
  String get demoIntro =>
      """Uso básico com currentValueChange e controle programático.""";

  /// ```dart
  /// "Selecionar Maria Silva"
  /// ```
  String get selectMaria => """Selecionar Maria Silva""";

  /// ```dart
  /// "Selecionar pessoa"
  /// ```
  String get selectPersonLabel => """Selecionar pessoa""";

  /// ```dart
  /// "Selecionar pessoa"
  /// ```
  String get modalTitle => """Selecionar pessoa""";

  /// ```dart
  /// "Clique para selecionar..."
  /// ```
  String get placeholder => """Clique para selecionar...""";

  /// ```dart
  /// "Buscar por nome, e-mail..."
  /// ```
  String get searchPlaceholder => """Buscar por nome, e-mail...""";

  /// ```dart
  /// "Estado desabilitado, o trigger fica inativo e não abre o modal."
  /// ```
  String get disabledIntro =>
      """Estado desabilitado, o trigger fica inativo e não abre o modal.""";

  /// ```dart
  /// "Pessoa (desabilitado)"
  /// ```
  String get disabledLabel => """Pessoa (desabilitado)""";

  /// ```dart
  /// "Campo desabilitado"
  /// ```
  String get disabledPlaceholder => """Campo desabilitado""";

  /// ```dart
  /// "Binding com ngModel. O valor é sincronizado via ControlValueAccessor."
  /// ```
  String get ngModelIntro =>
      """Binding com ngModel. O valor é sincronizado via ControlValueAccessor.""";

  /// ```dart
  /// "Selecionar pessoa (ngModel)"
  /// ```
  String get ngModelLabel => """Selecionar pessoa (ngModel)""";

  /// ```dart
  /// "O componente é controlado por três peças: Filters para paginação e busca, DataFrame para os dados e DatatableSettings para as colunas. Ao clicar no trigger, um modal abre com o datatable; ao clicar numa linha, a seleção é feita."
  /// ```
  String get howToUseBody =>
      """O componente é controlado por três peças: Filters para paginação e busca, DataFrame para os dados e DatatableSettings para as colunas. Ao clicar no trigger, um modal abre com o datatable; ao clicar numa linha, a seleção é feita.""";

  /// ```dart
  /// "[settings]: definições de colunas do datatable."
  /// ```
  String get optionOne => """[settings]: definições de colunas do datatable.""";

  /// ```dart
  /// "[data]: DataFrame com dados paginados."
  /// ```
  String get optionTwo => """[data]: DataFrame com dados paginados.""";

  /// ```dart
  /// "[dataTableFilter]: filtros de busca e paginação."
  /// ```
  String get optionThree =>
      """[dataTableFilter]: filtros de busca e paginação.""";

  /// ```dart
  /// "[searchInFields]: campos de busca."
  /// ```
  String get optionFour => """[searchInFields]: campos de busca.""";

  /// ```dart
  /// "[labelKey]: chave para o texto exibido no trigger."
  /// ```
  String get optionFive =>
      """[labelKey]: chave para o texto exibido no trigger.""";

  /// ```dart
  /// "[valueKey]: chave para o valor; null = instância inteira."
  /// ```
  String get optionSix =>
      """[valueKey]: chave para o valor; null = instância inteira.""";

  /// ```dart
  /// "[placeholder]: texto quando nenhum item está selecionado."
  /// ```
  String get optionSeven =>
      """[placeholder]: texto quando nenhum item está selecionado.""";

  /// ```dart
  /// "[title]: título do modal."
  /// ```
  String get optionEight => """[title]: título do modal.""";

  /// ```dart
  /// "[modalSize]: tamanho do modal (large, xtra-large)."
  /// ```
  String get optionNine =>
      """[modalSize]: tamanho do modal (large, xtra-large).""";

  /// ```dart
  /// "[disabled]: desabilita o componente."
  /// ```
  String get optionTen => """[disabled]: desabilita o componente.""";

  /// ```dart
  /// "[fullScreenOnMobile]: modal fullscreen no mobile."
  /// ```
  String get optionEleven =>
      """[fullScreenOnMobile]: modal fullscreen no mobile.""";

  /// ```dart
  /// "(dataRequest): emitido quando o datatable solicita dados."
  /// ```
  String get outputOne =>
      """(dataRequest): emitido quando o datatable solicita dados.""";

  /// ```dart
  /// "(currentValueChange): emitido quando o valor selecionado muda."
  /// ```
  String get outputTwo =>
      """(currentValueChange): emitido quando o valor selecionado muda.""";

  /// ```dart
  /// "(limitChange): emitido quando o limite por página muda."
  /// ```
  String get outputThree =>
      """(limitChange): emitido quando o limite por página muda.""";

  /// ```dart
  /// "(searchRequest): emitido quando uma busca é submetida."
  /// ```
  String get outputFour =>
      """(searchRequest): emitido quando uma busca é submetida.""";

  /// ```dart
  /// "clear(): limpa a seleção."
  /// ```
  String get methodOne => """clear(): limpa a seleção.""";

  /// ```dart
  /// "setSelectedItem({label, value}): define a seleção programaticamente."
  /// ```
  String get methodTwo =>
      """setSelectedItem({label, value}): define a seleção programaticamente.""";

  /// ```dart
  /// "selectedLabel: getter que retorna o label atual."
  /// ```
  String get methodThree =>
      """selectedLabel: getter que retorna o label atual.""";

  /// ```dart
  /// "Compatível com ngModel via ControlValueAccessor."
  /// ```
  String get noteOne => """Compatível com ngModel via ControlValueAccessor.""";

  /// ```dart
  /// "Mantenha o DataFrame estável; atualize apenas via (dataRequest)."
  /// ```
  String get noteTwo =>
      """Mantenha o DataFrame estável; atualize apenas via (dataRequest).""";

  /// ```dart
  /// "O botão de limpar no trigger aparece quando há valor selecionado."
  /// ```
  String get noteThree =>
      """O botão de limpar no trigger aparece quando há valor selecionado.""";

  /// ```dart
  /// "ID"
  /// ```
  String get columnId => """ID""";

  /// ```dart
  /// "Nome"
  /// ```
  String get columnName => """Nome""";

  /// ```dart
  /// "E-mail"
  /// ```
  String get columnEmail => """E-mail""";

  /// ```dart
  /// "Departamento"
  /// ```
  String get columnDepartment => """Departamento""";

  /// ```dart
  /// "Nome"
  /// ```
  String get searchName => """Nome""";

  /// ```dart
  /// "E-mail"
  /// ```
  String get searchEmail => """E-mail""";

  /// ```dart
  /// "Departamento"
  /// ```
  String get searchDepartment => """Departamento""";

  /// ```dart
  /// "Engenharia"
  /// ```
  String get departmentEngineering => """Engenharia""";

  /// ```dart
  /// "Design"
  /// ```
  String get departmentDesign => """Design""";

  /// ```dart
  /// "Marketing"
  /// ```
  String get departmentMarketing => """Marketing""";

  /// ```dart
  /// "Financeiro"
  /// ```
  String get departmentFinance => """Financeiro""";

  /// ```dart
  /// "RH"
  /// ```
  String get departmentHr => """RH""";

  /// ```dart
  /// "ngModel value"
  /// ```
  String get ngModelValuePrefix => """ngModel value""";
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
  /// "Esta página reúne variações de cor, estilo, tamanho, alinhamento e estados do componente de botão."
  /// ```
  String get overviewIntro =>
      """Esta página reúne variações de cor, estilo, tamanho, alinhamento e estados do componente de botão.""";

  /// ```dart
  /// "Use"
  /// ```
  String get usePrefix => """Use""";

  /// ```dart
  /// "Botão"
  /// ```
  String get demoButton => """Botão""";

  /// ```dart
  /// "Botão light"
  /// ```
  String get lightCardTitle => """Botão light""";

  /// ```dart
  /// "Botão dark"
  /// ```
  String get darkCardTitle => """Botão dark""";

  /// ```dart
  /// "Botão primary"
  /// ```
  String get primaryCardTitle => """Botão primary""";

  /// ```dart
  /// "Botão secondary"
  /// ```
  String get secondaryCardTitle => """Botão secondary""";

  /// ```dart
  /// "Botão danger"
  /// ```
  String get dangerCardTitle => """Botão danger""";

  /// ```dart
  /// "Botão success"
  /// ```
  String get successCardTitle => """Botão success""";

  /// ```dart
  /// "Botão warning"
  /// ```
  String get warningCardTitle => """Botão warning""";

  /// ```dart
  /// "Botão info"
  /// ```
  String get infoCardTitle => """Botão info""";

  /// ```dart
  /// "Botão indigo"
  /// ```
  String get indigoCardTitle => """Botão indigo""";

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

class FabPagesMessages {
  final PagesMessages _parent;
  const FabPagesMessages(this._parent);

  /// ```dart
  /// "Componentes"
  /// ```
  String get title => """Componentes""";

  /// ```dart
  /// "FAB"
  /// ```
  String get subtitle => """FAB""";

  /// ```dart
  /// "Componentes"
  /// ```
  String get breadcrumbParent => """Componentes""";

  /// ```dart
  /// "FAB"
  /// ```
  String get breadcrumb => """FAB""";

  /// ```dart
  /// "O menu de botão de ação flutuante (FAB) exibe um botão flutuante único, com ou sem menu aninhado. A demonstração abaixo segue a organização visual do Limitless, com exemplos de interação, direção, rótulos e cores."
  /// ```
  String get intro =>
      """O menu de botão de ação flutuante (FAB) exibe um botão flutuante único, com ou sem menu aninhado. A demonstração abaixo segue a organização visual do Limitless, com exemplos de interação, direção, rótulos e cores.""";

  /// ```dart
  /// "Exemplos básicos"
  /// ```
  String get basicTitle => """Exemplos básicos""";

  /// ```dart
  /// "Demonstração de botões e listas de botões"
  /// ```
  String get basicSubtitle => """Demonstração de botões e listas de botões""";

  /// ```dart
  /// "Botão flutuante único"
  /// ```
  String get singleTitle => """Botão flutuante único""";

  /// ```dart
  /// "O botão flutuante usa marcação de botão padrão com .fab-menu-btn dentro do container .fab-menu."
  /// ```
  String get singleBody =>
      """O botão flutuante usa marcação de botão padrão com .fab-menu-btn dentro do container .fab-menu.""";

  /// ```dart
  /// "Abrir menu ao passar o cursor"
  /// ```
  String get hoverTitle => """Abrir menu ao passar o cursor""";

  /// ```dart
  /// "Use a semântica data-fab-toggle="hover" para menus que devem expandir ao passar o cursor."
  /// ```
  String get hoverBody =>
      """Use a semântica data-fab-toggle="hover" para menus que devem expandir ao passar o cursor.""";

  /// ```dart
  /// "Abrir menu no clique"
  /// ```
  String get clickTitle => """Abrir menu no clique""";

  /// ```dart
  /// "O caso mais comum é abrir no clique com o trigger padrão somente com ícone."
  /// ```
  String get clickBody =>
      """O caso mais comum é abrir no clique com o trigger padrão somente com ícone.""";

  /// ```dart
  /// "Elementos do menu FAB"
  /// ```
  String get elementsTitle => """Elementos do menu FAB""";

  /// ```dart
  /// "Botões, direções e posicionamento fixo"
  /// ```
  String get elementsSubtitle => """Botões, direções e posicionamento fixo""";

  /// ```dart
  /// "Botões simples"
  /// ```
  String get simpleButtonsTitle => """Botões simples""";

  /// ```dart
  /// "O submenu normalmente contém botões arredondados com um único ícone."
  /// ```
  String get simpleButtonsBody =>
      """O submenu normalmente contém botões arredondados com um único ícone.""";

  /// ```dart
  /// "Ações laterais"
  /// ```
  String get sideActionsTitle => """Ações laterais""";

  /// ```dart
  /// "A direção à esquerda mantém o trigger principal compacto enquanto expõe ações contextuais na lateral."
  /// ```
  String get sideActionsBody =>
      """A direção à esquerda mantém o trigger principal compacto enquanto expõe ações contextuais na lateral.""";

  /// ```dart
  /// "Modelos personalizados"
  /// ```
  String get customTemplatesTitle => """Modelos personalizados""";

  /// ```dart
  /// "Use TemplateRef para personalizar o conteúdo do gatilho e das ações sem substituir o comportamento do FAB, os atalhos de teclado ou o tratamento de links."
  /// ```
  String get customTemplatesBody =>
      """Use TemplateRef para personalizar o conteúdo do gatilho e das ações sem substituir o comportamento do FAB, os atalhos de teclado ou o tratamento de links.""";

  /// ```dart
  /// "Ação de página sem sobreposição"
  /// ```
  String get noBackdropTitle => """Ação de página sem sobreposição""";

  /// ```dart
  /// "A variante sem backdrop é exibida dentro do card para evitar colisão com a barra lateral esquerda. O FAB fixo real continua na borda direita da página."
  /// ```
  String get noBackdropBody =>
      """A variante sem backdrop é exibida dentro do card para evitar colisão com a barra lateral esquerda. O FAB fixo real continua na borda direita da página.""";

  /// ```dart
  /// "Rótulos dos botões internos"
  /// ```
  String get innerLabelsTitle => """Rótulos dos botões internos""";

  /// ```dart
  /// "Tooltips visíveis, rótulos claros e posições do rótulo"
  /// ```
  String get innerLabelsSubtitle =>
      """Tooltips visíveis, rótulos claros e posições do rótulo""";

  /// ```dart
  /// "Rótulos visíveis"
  /// ```
  String get visibleLabelsTitle => """Rótulos visíveis""";

  /// ```dart
  /// "Use .fab-label-visible quando os rótulos precisarem permanecer visíveis enquanto o menu estiver expandido."
  /// ```
  String get visibleLabelsBody =>
      """Use .fab-label-visible quando os rótulos precisarem permanecer visíveis enquanto o menu estiver expandido.""";

  /// ```dart
  /// "Rótulos claros"
  /// ```
  String get lightLabelsTitle => """Rótulos claros""";

  /// ```dart
  /// "Todos os tipos de botão suportam tooltips claros como alternativa aos rótulos escuros padrão."
  /// ```
  String get lightLabelsBody =>
      """Todos os tipos de botão suportam tooltips claros como alternativa aos rótulos escuros padrão.""";

  /// ```dart
  /// "Posições do rótulo"
  /// ```
  String get labelPositionsTitle => """Posições do rótulo""";

  /// ```dart
  /// "A esquerda é o padrão; use .fab-label-end para posicionar os rótulos no lado direito."
  /// ```
  String get labelPositionsBody =>
      """A esquerda é o padrão; use .fab-label-end para posicionar os rótulos no lado direito.""";

  /// ```dart
  /// "Cores padrão dos botões"
  /// ```
  String get defaultColorsTitle => """Cores padrão dos botões""";

  /// ```dart
  /// "Exemplos de cores contextuais predefinidas"
  /// ```
  String get defaultColorsSubtitle =>
      """Exemplos de cores contextuais predefinidas""";

  /// ```dart
  /// "Cor primária do botão"
  /// ```
  String get primaryColorTitle => """Cor primária do botão""";

  /// ```dart
  /// "A variação contextual primária usa o botão principal padrão .btn-primary."
  /// ```
  String get primaryColorBody =>
      """A variação contextual primária usa o botão principal padrão .btn-primary.""";

  /// ```dart
  /// "Cor de sucesso do botão"
  /// ```
  String get successColorTitle => """Cor de sucesso do botão""";

  /// ```dart
  /// "Use .btn-success para uma variante contextual positiva."
  /// ```
  String get successColorBody =>
      """Use .btn-success para uma variante contextual positiva.""";

  /// ```dart
  /// "Cor de alerta do botão"
  /// ```
  String get warningColorTitle => """Cor de alerta do botão""";

  /// ```dart
  /// "A variação warning é uma alternativa contextual forte para ações que exigem atenção."
  /// ```
  String get warningColorBody =>
      """A variação warning é uma alternativa contextual forte para ações que exigem atenção.""";

  /// ```dart
  /// "Opções de cores customizadas"
  /// ```
  String get customColorsTitle => """Opções de cores customizadas""";

  /// ```dart
  /// "Use cores customizadas nos botões principais e internos"
  /// ```
  String get customColorsSubtitle =>
      """Use cores customizadas nos botões principais e internos""";

  /// ```dart
  /// "Cor customizada do botão principal"
  /// ```
  String get customMainColorTitle => """Cor customizada do botão principal""";

  /// ```dart
  /// "Cores da paleta secundária podem ser aplicadas diretamente ao trigger principal."
  /// ```
  String get customMainColorBody =>
      """Cores da paleta secundária podem ser aplicadas diretamente ao trigger principal.""";

  /// ```dart
  /// "Cor customizada do botão interno"
  /// ```
  String get customInnerColorTitle => """Cor customizada do botão interno""";

  /// ```dart
  /// "As ações internas podem usar qualquer cor de botão do Limitless mantendo o trigger principal claro."
  /// ```
  String get customInnerColorBody =>
      """As ações internas podem usar qualquer cor de botão do Limitless mantendo o trigger principal claro.""";

  /// ```dart
  /// "Misturando cores dos botões"
  /// ```
  String get mixedColorsTitle => """Misturando cores dos botões""";

  /// ```dart
  /// "O submenu suporta cores contextuais misturadas sem mudar a marcação estrutural."
  /// ```
  String get mixedColorsBody =>
      """O submenu suporta cores contextuais misturadas sem mudar a marcação estrutural.""";

  /// ```dart
  /// "Aguardando ação do FAB."
  /// ```
  String get waitingAction => """Aguardando ação do FAB.""";

  /// ```dart
  /// "Ação selecionada no FAB: "
  /// ```
  String get demoActionPrefix => """Ação selecionada no FAB: """;

  /// ```dart
  /// "FAB fixo com backdrop acionou: "
  /// ```
  String get fixedActionPrefix => """FAB fixo com backdrop acionou: """;

  /// ```dart
  /// "FAB fixo sem backdrop acionou: "
  /// ```
  String get noBackdropActionPrefix => """FAB fixo sem backdrop acionou: """;

  /// ```dart
  /// "A implementação AngularDart mantém o contrato visual do Limitless e expõe uma API curta para ações, direção, toggle e posicionamento."
  /// ```
  String get apiIntro =>
      """A implementação AngularDart mantém o contrato visual do Limitless e expõe uma API curta para ações, direção, toggle e posicionamento.""";

  /// ```dart
  /// "Markup padrão do menu FAB:"
  /// ```
  String get overviewLead => """Markup padrão do menu FAB:""";

  /// ```dart
  /// "Classes do menu do FAB"
  /// ```
  String get classesTitle => """Classes do menu do FAB""";

  /// ```dart
  /// "O estilo do menu FAB é orientado por classes CSS e atributos de dados. A tabela abaixo resume as classes usadas por este wrapper AngularDart preservando o contrato original do Limitless."
  /// ```
  String get classesIntro =>
      """O estilo do menu FAB é orientado por classes CSS e atributos de dados. A tabela abaixo resume as classes usadas por este wrapper AngularDart preservando o contrato original do Limitless.""";

  /// ```dart
  /// "Classe"
  /// ```
  String get classHeader => """Classe""";

  /// ```dart
  /// "Descrição"
  /// ```
  String get descriptionHeader => """Descrição""";

  /// ```dart
  /// "Classes básicas"
  /// ```
  String get basicClassesGroup => """Classes básicas""";

  /// ```dart
  /// "Direções e posicionamento"
  /// ```
  String get directionsGroup => """Direções e posicionamento""";

  /// ```dart
  /// "Visibilidade e rótulos"
  /// ```
  String get visibilityGroup => """Visibilidade e rótulos""";

  /// ```dart
  /// "Wrapper principal usado pelo componente."
  /// ```
  String get classMenuDesc => """Wrapper principal usado pelo componente.""";

  /// ```dart
  /// "Botão circular principal do trigger."
  /// ```
  String get classMenuBtnDesc => """Botão circular principal do trigger.""";

  /// ```dart
  /// "Container interno da lista de ações."
  /// ```
  String get classMenuInnerDesc => """Container interno da lista de ações.""";

  /// ```dart
  /// "Ícones rotacionados e suavizados pelo CSS do Limitless conforme o estado do menu."
  /// ```
  String get classIconsDesc =>
      """Ícones rotacionados e suavizados pelo CSS do Limitless conforme o estado do menu.""";

  /// ```dart
  /// "O menu abre abaixo do trigger."
  /// ```
  String get classMenuTopDesc => """O menu abre abaixo do trigger.""";

  /// ```dart
  /// "O menu abre acima do trigger."
  /// ```
  String get classMenuBottomDesc => """O menu abre acima do trigger.""";

  /// ```dart
  /// "FAB fixo no viewport usado para ações persistentes da página."
  /// ```
  String get classMenuFixedDesc =>
      """FAB fixo no viewport usado para ações persistentes da página.""";

  /// ```dart
  /// "Extensões horizontais adicionadas pelo wrapper AngularDart."
  /// ```
  String get classDirHorizontalDesc =>
      """Extensões horizontais adicionadas pelo wrapper AngularDart.""";

  /// ```dart
  /// "Comportamento de abrir no clique."
  /// ```
  String get toggleClickDesc => """Comportamento de abrir no clique.""";

  /// ```dart
  /// "Comportamento de abrir ao passar o cursor."
  /// ```
  String get toggleHoverDesc =>
      """Comportamento de abrir ao passar o cursor.""";

  /// ```dart
  /// "Aplicado enquanto o menu está expandido."
  /// ```
  String get stateOpenDesc => """Aplicado enquanto o menu está expandido.""";

  /// ```dart
  /// "Texto de tooltip para ações internas."
  /// ```
  String get dataFabLabelDesc => """Texto de tooltip para ações internas.""";

  /// ```dart
  /// "Modificadores de rótulo alinhado à direita, claro e persistente."
  /// ```
  String get labelModifiersDesc =>
      """Modificadores de rótulo alinhado à direita, claro e persistente.""";

  /// ```dart
  /// "Fechar"
  /// ```
  String get customTriggerClose => """Fechar""";

  /// ```dart
  /// "Ações rápidas"
  /// ```
  String get customTriggerActions => """Ações rápidas""";

  /// ```dart
  /// "Escrever e-mail"
  /// ```
  String get actionComposeEmail => """Escrever e-mail""";

  /// ```dart
  /// "Conversas"
  /// ```
  String get actionConversations => """Conversas""";

  /// ```dart
  /// "Segurança da conta"
  /// ```
  String get actionAccountSecurity => """Segurança da conta""";

  /// ```dart
  /// "Análises"
  /// ```
  String get actionAnalytics => """Análises""";

  /// ```dart
  /// "Privacidade"
  /// ```
  String get actionPrivacy => """Privacidade""";

  /// ```dart
  /// "Editar"
  /// ```
  String get actionEdit => """Editar""";

  /// ```dart
  /// "Compartilhar"
  /// ```
  String get actionShare => """Compartilhar""";

  /// ```dart
  /// "Arquivar"
  /// ```
  String get actionArchive => """Arquivar""";

  /// ```dart
  /// "Publicar"
  /// ```
  String get actionPublish => """Publicar""";

  /// ```dart
  /// "Salvar rascunho"
  /// ```
  String get actionSaveDraft => """Salvar rascunho""";

  /// ```dart
  /// "Pré-visualizar"
  /// ```
  String get actionPreview => """Pré-visualizar""";

  /// ```dart
  /// "Executar pipeline"
  /// ```
  String get markupRunPipeline => """Executar pipeline""";
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
      """nav.fab""": """FAB""",
      """common.restoreAlert""": """Restaurar alerta""",
      """common.none""": """Nenhum""",
      """common.open""": """Abrir""",
      """common.close""": """Fechar""",
      """common.clear""": """Limpar""",
      """common.status""": """Status""",
      """common.value""": """Valor""",
      """common.label""": """Label""",
      """common.event""": """Evento""",
      """common.currentPeriod""": """Período atual""",
      """common.restrictedWindow""": """Janela restrita""",
      """common.tabOverview""": """Visão geral""",
      """common.tabApi""": """API""",
      """common.sectionDescription""": """Descrição""",
      """common.sectionFeatures""": """Recursos""",
      """common.sectionLimitations""": """Limitações""",
      """common.sectionHowToUse""": """Como utilizar""",
      """common.sectionNotes""": """Observações""",
      """common.sectionVisibleExample""": """Exemplo visível""",
      """common.sectionMainOptions""": """Opções principais""",
      """common.sectionBestPractices""": """Boas práticas""",
      """common.sectionOutputs""": """Outputs""",
      """common.sectionPublicMethods""": """Métodos públicos""",
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
      """pages.overview.featureSweetAlertBody""":
          """API unificada para modal, confirmação, prompt, toast e também gatilho declarativo.""",
      """pages.overview.featureHighlightBody""":
          """Bloco leve para snippets de Dart, HTML e CSS na documentação do example.""",
      """pages.overview.featureInputsFieldBody""":
          """Campo de texto com ngModel, floating label, textarea e addons de prefixo ou sufixo.""",
      """pages.overview.featureFabBody""":
          """Speed dial compacto para ações rápidas globais ou inline.""",
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
      """pages.accordion.descriptionBody""":
          """O accordion organiza blocos densos de informação em seções expansíveis, reduzindo ruído visual sem perder contexto.""",
      """pages.accordion.featureOne""":
          """Itens recolhidos, expandidos, desabilitados e com cabeçalho customizado.""",
      """pages.accordion.featureTwo""": """Eventos de abertura por item.""",
      """pages.accordion.featureThree""":
          """Renderização tardia e destruição opcional do corpo.""",
      """pages.accordion.limitOne""":
          """Conteúdo muito interativo exige cuidado com foco.""",
      """pages.accordion.limitTwo""":
          """Seções longas demais ainda pedem hierarquia interna.""",
      """pages.accordion.limitThree""":
          """O layout não substitui navegação por rotas.""",
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
      """pages.accordion.directiveApiTitle""":
          """API declarativa por diretivas""",
      """pages.accordion.directiveApiIntro""":
          """Esta versão mantém o markup Bootstrap acessível no DOM e expõe uma API parecida com ng-bootstrap.""",
      """pages.accordion.directiveApiNote""":
          """Para destroyOnHide físico de verdade, use <template liAccordionBody>. O wrapper simples com <div liAccordionBody> mantém o conteúdo no DOM para casos em que a referência precisa permanecer estável.""",
      """pages.accordion.declarativeOverviewButton""": """Visão geral""",
      """pages.accordion.declarativeOverviewBody""":
          """Conteúdo básico com header e body declarativos, mantendo classes e atributos de acessibilidade.""",
      """pages.accordion.declarativeCustomHeader""": """Header customizado""",
      """pages.accordion.declarativeToggle""": """Alternar""",
      """pages.accordion.declarativeCustomBody""":
          """O header pode ser totalmente customizado sem perder o controle por id, collapse e eventos.""",
      """pages.accordion.declarativeDisabledButton""": """Item desabilitado""",
      """pages.accordion.declarativeDisabledBody""":
          """Este conteúdo continua acessível via API, mas não reage ao clique do usuário.""",
      """pages.accordion.expandOverview""": """Expandir overview""",
      """pages.accordion.toggleCustom""": """Alternar custom""",
      """pages.accordion.closeAll""": """Fechar todos""",
      """pages.accordion.itemApi""": """API do item""",
      """pages.accordion.declarativeIdle""":
          """Nenhum evento da API declarativa.""",
      """pages.accordion.collapseTitle""": """liCollapse""",
      """pages.accordion.collapseIntro""":
          """Diretiva genérica para esconder e mostrar blocos com as classes collapse, show e collapsing.""",
      """pages.accordion.openPanel""": """Abrir painel""",
      """pages.accordion.closePanel""": """Fechar painel""",
      """pages.accordion.collapseBody""":
          """Este bloco usa a diretiva genérica de collapse, sem depender do accordion.""",
      """pages.accordion.apiOne""":
          """[allowMultipleOpen] permite manter mais de um item expandido ao mesmo tempo.""",
      """pages.accordion.apiTwo""":
          """[flush] remove contornos extras para uma composição mais compacta.""",
      """pages.accordion.apiThree""":
          """[lazy] adia a renderização do corpo até a primeira abertura.""",
      """pages.accordion.apiFour""":
          """[destroyOnCollapse] remove o conteúdo do DOM quando o item fecha.""",
      """pages.accordion.apiFive""":
          """[expanded] e (expandedChange) controlam abertura por item.""",
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
      """pages.tabs.overviewIntro""":
          """A página de tabs demonstra composição horizontal, vertical, cabeçalhos customizados e estados desabilitados.""",
      """pages.tabs.descriptionBody""":
          """Tabs organizam conteúdo em camadas sem quebrar o contexto da tela e funcionam bem para documentação, formulários segmentados e painéis administrativos.""",
      """pages.tabs.featureOne""": """Modo tabs e pills.""",
      """pages.tabs.featureTwo""": """Posicionamento horizontal ou lateral.""",
      """pages.tabs.featureThree""":
          """Cabeçalho projetado e abas desabilitadas.""",
      """pages.tabs.limitOne""":
          """Muitas abas no mesmo nível prejudicam escaneabilidade.""",
      """pages.tabs.limitTwo""":
          """Conteúdo longo demais pede hierarquia adicional.""",
      """pages.tabs.limitThree""":
          """Abas aninhadas devem ser isoladas em subcomponentes.""",
      """pages.tabs.previewTitle""": """Exemplo visível""",
      """pages.tabs.previewIntro""":
          """O exemplo abaixo mostra pills laterais com cabeçalho customizado e uma aba desabilitada, sem contaminar a navegação da página de documentação.""",
      """pages.tabs.apiIntro""":
          """Use o componente para agrupar conteúdo relacionado quando a navegação por seções fizer mais sentido do que empilhar cards ou abrir novas rotas.""",
      """pages.tabs.apiOne""": """type aceita tabs ou pills.""",
      """pages.tabs.apiTwo""":
          """placement controla a posição das abas, como topo ou lateral.""",
      """pages.tabs.apiThree""":
          """[justified] distribui os gatilhos de forma uniforme.""",
      """pages.tabs.apiFour""":
          """[active] e [disabled] controlam estado por aba.""",
      """pages.tabs.apiFive""":
          """template li-tabx-header permite cabeçalhos customizados.""",
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
      """pages.select.overviewIntro""":
          """A demo de select mostra uso com dataSource estável e com projeção manual de opções, reunindo descrição, recursos, limitações e exemplos visíveis no mesmo fluxo.""",
      """pages.select.descriptionTitle""": """Descrição""",
      """pages.select.descriptionBody""":
          """O componente resolve seleção simples com overlay, opção projetada e ligação direta ao ngModel.""",
      """pages.select.featuresTitle""": """Recursos""",
      """pages.select.featureOne""": """Fonte externa com dataSource.""",
      """pages.select.featureTwo""": """Projeção manual com li-option.""",
      """pages.select.featureThree""":
          """Placeholder, itens desabilitados e binding simples.""",
      """pages.select.limitsTitle""": """Limitações""",
      """pages.select.limitOne""":
          """Evite recriar o dataSource em getters reativos.""",
      """pages.select.limitTwo""":
          """O overlay depende de opções consistentes para navegação e altura.""",
      """pages.select.limitThree""":
          """Para lógica pesada de filtro, mantenha a orquestração no componente pai.""",
      """pages.select.apiTitle""": """Como utilizar""",
      """pages.select.apiIntro""":
          """li-select aceita tanto [dataSource] quanto projeção com li-option. Para evitar travamentos e ciclos de renderização desnecessários, prefira fornecer listas estáveis no componente pai, em vez de getters que recriam o array a cada mudança de estado.""",
      """pages.select.apiDataSource""": """lista de opções externas.""",
      """pages.select.apiLabelKey""": """chave usada para o texto visível.""",
      """pages.select.apiValueKey""": """chave usada como valor do ngModel.""",
      """pages.select.apiDisabledKey""":
          """chave booleana para desabilitar itens.""",
      """pages.select.apiNgModel""": """valor selecionado.""",
      """pages.select.apiPlaceholder""": """texto exibido quando vazio.""",
      """pages.select.notesTitle""": """Observações e limites""",
      """pages.select.noteOne""": """Não recrie o dataSource em getters.""",
      """pages.select.noteTwo""":
          """O overlay não deve calcular altura com base no próprio painel renderizado.""",
      """pages.select.noteThree""":
          """Eventos globais de teclado devem tratar apenas navegação e escape.""",
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
      """pages.multiSelect.overviewIntro""":
          """A demo de multiseleção mostra seleção múltipla com dataSource estável, projeção manual e documentação organizada entre visão geral e API.""",
      """pages.multiSelect.descriptionTitle""": """Descrição""",
      """pages.multiSelect.descriptionBody""":
          """O componente mantém uma coleção de valores selecionados e projeta o resultado diretamente no trigger.""",
      """pages.multiSelect.featuresTitle""": """Recursos""",
      """pages.multiSelect.featureOne""":
          """Seleção múltipla com badges e placeholder.""",
      """pages.multiSelect.featureTwo""":
          """Botão de limpar seleção ao lado da seta quando há valores marcados.""",
      """pages.multiSelect.featureThree""":
          """Integração com dataSource ou li-multi-option.""",
      """pages.multiSelect.featureFour""":
          """Binding direto com listas no ngModel.""",
      """pages.multiSelect.limitsTitle""": """Limitações""",
      """pages.multiSelect.limitOne""":
          """Evite recriar listas de opções em getters reativos.""",
      """pages.multiSelect.limitTwo""":
          """O overlay precisa de atualização consistente ao mudar a seleção.""",
      """pages.multiSelect.limitThree""":
          """Para coleções muito grandes, mantenha paginação ou busca no pai.""",
      """pages.multiSelect.apiTitle""": """Como utilizar""",
      """pages.multiSelect.apiIntroOne""":
          """li-multi-select segue a mesma estratégia do li-select, mas mantém múltiplos valores selecionados e renderiza badges no trigger.""",
      """pages.multiSelect.apiIntroTwo""":
          """O padrão recomendado para o demo e para produção é manter dataSource estável e atualizar apenas a coleção de valores selecionados.""",
      """pages.multiSelect.apiDataSource""": """lista de opções externas.""",
      """pages.multiSelect.apiLabelKey""":
          """chave usada para o texto visível.""",
      """pages.multiSelect.apiValueKey""":
          """chave usada no array do ngModel.""",
      """pages.multiSelect.apiNgModel""": """lista de valores selecionados.""",
      """pages.multiSelect.apiPlaceholder""":
          """texto quando nada está marcado.""",
      """pages.multiSelect.apiShowClearButton""":
          """mostra o X para limpar tudo no trigger.""",
      """pages.multiSelect.notesTitle""": """Observações e limites""",
      """pages.multiSelect.noteOne""":
          """Não recrie a lista de opções em getters reativos.""",
      """pages.multiSelect.noteTwo""":
          """Agende overlay.update() em frame futuro ao mudar a seleção.""",
      """pages.multiSelect.noteThree""":
          """Calcule maxHeight pelo viewport, não pela altura atual do painel.""",
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
      """pages.currency.tabOverview""": """Visão geral""",
      """pages.currency.tabApi""": """API""",
      """pages.currency.descriptionTitle""": """Descrição""",
      """pages.currency.descriptionBody""":
          """O campo monetário resolve formatação visual e conversão para unidades menores sem lógica adicional no template.""",
      """pages.currency.featuresTitle""": """Recursos""",
      """pages.currency.featureOne""": """Suporte a locale e currencyCode.""",
      """pages.currency.featureTwo""":
          """Conversão automática para minor units.""",
      """pages.currency.featureThree""":
          """Integração com formulários AngularDart.""",
      """pages.currency.limitsTitle""": """Limitações""",
      """pages.currency.limitOne""":
          """O campo não substitui regras fiscais de negócio.""",
      """pages.currency.limitTwo""":
          """Máscaras muito específicas exigem extensão adicional.""",
      """pages.currency.limitThree""":
          """O valor persistido continua sendo numérico.""",
      """pages.currency.summaryHelp""":
          """O mesmo componente agora aceita BRL, USD e EUR trocando apenas currencyCode e locale.""",
      """pages.currency.apiIntro""":
          """Use o componente para exibir o valor formatado ao usuário e manter no estado um número consistente em unidades menores.""",
      """pages.currency.apiOne""":
          """[(ngModel)] trabalha com o valor em minor units.""",
      """pages.currency.apiTwo""":
          """currencyCode e locale controlam símbolo e separadores.""",
      """pages.currency.apiThree""":
          """prefix continua disponível para sobrescrever o símbolo automaticamente resolvido.""",
      """pages.currency.apiFour""":
          """[required] integra validação ao formulário.""",
      """pages.currency.apiFive""":
          """inputClass permite aplicar classes utilitárias no campo.""",
      """pages.dateRange.title""": """Componentes""",
      """pages.dateRange.subtitle""": """Intervalo de datas""",
      """pages.dateRange.breadcrumb""": """Seleção de período""",
      """pages.dateRange.cardTitle""": """Intervalos livres e restritos""",
      """pages.dateRange.tabOverview""": """Visão geral""",
      """pages.dateRange.tabApi""": """API""",
      """pages.dateRange.descriptionTitle""": """Descrição""",
      """pages.dateRange.descriptionBody""":
          """O date range picker atende fluxos de período contínuo para filtros, sprints, publicações e recortes operacionais.""",
      """pages.dateRange.featuresTitle""": """Recursos""",
      """pages.dateRange.featureOne""":
          """Binding separado para início e fim.""",
      """pages.dateRange.featureTwo""":
          """Restrições por intervalo mínimo e máximo.""",
      """pages.dateRange.featureThree""":
          """Placeholder e locale configuráveis.""",
      """pages.dateRange.limitsTitle""": """Limitações""",
      """pages.dateRange.limitOne""":
          """O componente não aplica regras de calendário de negócio sozinho.""",
      """pages.dateRange.limitTwo""":
          """Validações mais específicas continuam no pai.""",
      """pages.dateRange.limitThree""":
          """Fluxos complexos podem exigir presets externos.""",
      """pages.dateRange.sprintPlaceholder""":
          """Selecione o periodo da sprint""",
      """pages.dateRange.publicationPlaceholder""": """Janela de publicação""",
      """pages.dateRange.partial""": """Período parcial ou não definido""",
      """pages.dateRange.unfinished""": """Janela ainda não concluída""",
      """pages.dateRange.constrainedHelp""":
          """O segundo exemplo prende a seleção com minDate e maxDate.""",
      """pages.dateRange.between""": """até""",
      """pages.dateRange.apiIntro""":
          """Use o componente quando o fluxo depender de um intervalo com datas inicial e final claramente controladas pelo componente pai.""",
      """pages.dateRange.apiOne""":
          """[inicio] e (inicioChange) controlam a data inicial.""",
      """pages.dateRange.apiTwo""":
          """[fim] e (fimChange) controlam a data final.""",
      """pages.dateRange.apiThree""":
          """[minDate] e [maxDate] restringem a janela selecionável.""",
      """pages.dateRange.apiFour""":
          """[placeholder] e locale ajustam a comunicação do campo.""",
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
          """Suporte aos formatos 12h com AM/PM e 24 horas.""",
      """pages.timePicker.limitsTitle""": """Limitações""",
      """pages.timePicker.limitOne""":
          """O formato exibido depende de use24Hour e do locale configurado.""",
      """pages.timePicker.limitTwo""":
          """Não aplica regras de janela de negócio por conta própria.""",
      """pages.timePicker.limitThree""":
          """O valor retornado considera apenas hora e minuto.""",
      """pages.timePicker.twentyFourHourTitle""": """Time picker 24 horas""",
      """pages.timePicker.twentyFourHourPlaceholder""":
          """Selecione o horário""",
      """pages.timePicker.twentyFourHourCurrentLabel""": """Horário atual""",
      """pages.timePicker.twentyFourHourHelp""":
          """Use use24Hour para exibir e editar o valor sem AM/PM.""",
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
      """pages.datatable.overviewIntro""":
          """A datatable desta biblioteca cobre o fluxo administrativo mais comum: busca por campo, seleção de linhas, exportação, paginação, ordenação, colapso responsivo e uma camada de customização visual por coluna, por linha e por card.""",
      """pages.datatable.descriptionBody""":
          """O componente atende listagens operacionais que precisam alternar entre tabela e grade sem duplicar fonte de dados, regras de ordenação ou comportamento de busca.""",
      """pages.datatable.featureOne""":
          """Busca direcionada por coluna com campo e operador configuráveis.""",
      """pages.datatable.featureTwo""":
          """Exportação para XLSX e PDF usando a própria API do componente.""",
      """pages.datatable.featureThree""":
          """Modo tabela e modo grade com a mesma fonte de dados.""",
      """pages.datatable.featureFour""":
          """Largura, alinhamento, classes e estilos por coluna e por linha.""",
      """pages.datatable.featureFive""":
          """Cards customizados com customCardBuilder em grid mode.""",
      """pages.datatable.limitOne""":
          """cellStyleResolver trabalha com CSS inline, então não substitui um tema completo.""",
      """pages.datatable.limitTwo""":
          """customCardBuilder é ideal para cards ricos, mas exige montagem manual do markup.""",
      """pages.datatable.limitThree""":
          """O colapso mobile continua orientado a colunas, então layouts muito densos pedem curadoria das colunas secundárias.""",
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
      """pages.datatable.demoIntro""":
          """Demo principal com busca, seleção, exportação e alternância entre tabela e grade.""",
      """pages.datatable.onDemandTitle""": """Demos sob demanda""",
      """pages.datatable.onDemandIntro""":
          """Os exemplos abaixo usam li-accordion com carregamento tardio para evitar que todos os datatables entrem no DOM ao abrir a rota.""",
      """pages.datatable.readonlyTitle""": """Exemplo somente leitura""",
      """pages.datatable.readonlyDescription""":
          """Busca e ordenação sem clique de linha nem seleção.""",
      """pages.datatable.gridPreviewTitle""": """Exemplo em modo grade""",
      """pages.datatable.gridPreviewDescription""":
          """Mesmo dataset reaproveitado como cartões.""",
      """pages.datatable.customTableTitle""":
          """Tabela com width, cor por coluna e cor por linha""",
      """pages.datatable.customTableDescription""":
          """Combina width fixa, cellStyleResolver e rowStyleResolver no mesmo cenário.""",
      """pages.datatable.customGridTitle""": """Grid com customCardBuilder""",
      """pages.datatable.customGridDescription""":
          """Card montado manualmente só quando o item é aberto.""",
      """pages.datatable.lazyModalTitle""":
          """Modal lazy loading com datatable""",
      """pages.datatable.lazyModalIntro""":
          """Este cenário abre um li-modal com lazyContent e instancia o li-datatable somente depois da abertura.""",
      """pages.datatable.openLazyModal""": """Abrir modal lazy""",
      """pages.datatable.modalTitle""": """Modal lazy com datatable""",
      """pages.datatable.modalBody""":
          """O conteúdo do modal só entra no DOM quando ele abre. O datatable reutiliza o mesmo dataset da página para verificar se o primeiro render funciona corretamente.""",
      """pages.datatable.howToUseBody""":
          """O componente é controlado por três peças: Filters para paginação e busca, DataFrame para os dados e DatatableSettings para as colunas e o comportamento visual.""",
      """pages.datatable.optionOne""":
          """[dataTableFilter]: controla limite, offset, busca e ordenação.""",
      """pages.datatable.optionTwo""":
          """[settings]: define colunas, grid e builders customizados.""",
      """pages.datatable.optionThree""":
          """[searchInFields]: informa quais campos aparecem no seletor de busca.""",
      """pages.datatable.optionFour""":
          """[responsiveCollapse]: move colunas secundárias para a linha filha no mobile.""",
      """pages.datatable.practiceOne""":
          """Mantenha o DataFrame estável e atualize apenas filtros e seleção.""",
      """pages.datatable.practiceTwo""":
          """Use hideOnMobile nas colunas secundárias.""",
      """pages.datatable.practiceThree""":
          """Reserve customCardBuilder para grids que realmente precisam fugir do layout padrão.""",
      """pages.datatable.columnStylesTitle""": """Colunas e estilos""",
      """pages.datatable.columnStyleOne""":
          """width, minWidth e maxWidth controlam a largura efetiva da coluna.""",
      """pages.datatable.columnStyleTwo""":
          """headerClass e cellClass adicionam classes sem mexer no template.""",
      """pages.datatable.columnStyleThree""":
          """styleCss e cellStyleResolver controlam cor e estilo por coluna.""",
      """pages.datatable.columnStyleFour""":
          """rowStyleResolver devolve uma string CSS por linha inteira com base nos dados.""",
      """pages.datatable.columnStyleFive""":
          """textAlign e nowrap ajustam leitura para colunas curtas ou status.""",
      """pages.datatable.customCardEyebrow""": """CustomCardBuilder""",
      """pages.datatable.ownerPrefix""": """Responsável""",
      """pages.datatable.customCardSummary""":
          """O card foi montado manualmente para combinar título, estado e metadados sem depender do layout padrão.""",
      """pages.datatable.featureRow5""": """Sincronizar cadastro com ERP""",
      """pages.datatable.featureRow6""": """Publicar relatório operacional""",
      """pages.datatable.featureRow7""": """Revisar fila de integração""",
      """pages.datatable.featureRow8""": """Atualizar painel de atendimento""",
      """pages.datatable.ownerFinance""": """Financeiro""",
      """pages.datatable.ownerSupport""": """Atendimento""",
      """pages.datatable.gridMode""":
          """Datatable alternada para o modo grade.""",
      """pages.datatable.tableMode""":
          """Datatable alternada para o modo tabela.""",
      """pages.datatable.singleMode""": """Seleção única ativada.""",
      """pages.datatable.multiMode""": """Seleção múltipla ativada.""",
      """pages.datatable.exportXlsx""": """Exportação XLSX acionada.""",
      """pages.datatable.exportPdf""": """Exportação em PDF acionada.""",
      """pages.datatableSelect.title""": """Componentes""",
      """pages.datatableSelect.subtitle""": """Datatable Select""",
      """pages.datatableSelect.breadcrumb""":
          """Select com datatable em modal""",
      """pages.datatableSelect.overviewIntro""":
          """Um select que abre um modal com um datatable completo, permitindo busca, paginação e ordenação. Ao clicar em uma linha, o item é selecionado e o modal fecha.""",
      """pages.datatableSelect.descriptionBody""":
          """O componente combina um trigger no formato form-select com um modal que exibe um li-datatable completo. Implementa ControlValueAccessor para compatibilidade com ngModel.""",
      """pages.datatableSelect.featureOne""":
          """Busca, paginação e ordenação via li-datatable.""",
      """pages.datatableSelect.featureTwo""":
          """Seleção por clique de linha.""",
      """pages.datatableSelect.featureThree""":
          """Suporte a ngModel e currentValueChange.""",
      """pages.datatableSelect.featureFour""":
          """Tamanho do modal configurável.""",
      """pages.datatableSelect.featureFive""":
          """Estados desabilitado e programático.""",
      """pages.datatableSelect.limitOne""":
          """Requer dataRequest para fornecer dados ao datatable.""",
      """pages.datatableSelect.limitTwo""":
          """O label exibido depende de labelKey sem projeção customizada.""",
      """pages.datatableSelect.limitThree""":
          """Não suporta seleção múltipla.""",
      """pages.datatableSelect.demoIntro""":
          """Uso básico com currentValueChange e controle programático.""",
      """pages.datatableSelect.selectMaria""": """Selecionar Maria Silva""",
      """pages.datatableSelect.selectPersonLabel""": """Selecionar pessoa""",
      """pages.datatableSelect.modalTitle""": """Selecionar pessoa""",
      """pages.datatableSelect.placeholder""": """Clique para selecionar...""",
      """pages.datatableSelect.searchPlaceholder""":
          """Buscar por nome, e-mail...""",
      """pages.datatableSelect.disabledIntro""":
          """Estado desabilitado, o trigger fica inativo e não abre o modal.""",
      """pages.datatableSelect.disabledLabel""": """Pessoa (desabilitado)""",
      """pages.datatableSelect.disabledPlaceholder""": """Campo desabilitado""",
      """pages.datatableSelect.ngModelIntro""":
          """Binding com ngModel. O valor é sincronizado via ControlValueAccessor.""",
      """pages.datatableSelect.ngModelLabel""":
          """Selecionar pessoa (ngModel)""",
      """pages.datatableSelect.howToUseBody""":
          """O componente é controlado por três peças: Filters para paginação e busca, DataFrame para os dados e DatatableSettings para as colunas. Ao clicar no trigger, um modal abre com o datatable; ao clicar numa linha, a seleção é feita.""",
      """pages.datatableSelect.optionOne""":
          """[settings]: definições de colunas do datatable.""",
      """pages.datatableSelect.optionTwo""":
          """[data]: DataFrame com dados paginados.""",
      """pages.datatableSelect.optionThree""":
          """[dataTableFilter]: filtros de busca e paginação.""",
      """pages.datatableSelect.optionFour""":
          """[searchInFields]: campos de busca.""",
      """pages.datatableSelect.optionFive""":
          """[labelKey]: chave para o texto exibido no trigger.""",
      """pages.datatableSelect.optionSix""":
          """[valueKey]: chave para o valor; null = instância inteira.""",
      """pages.datatableSelect.optionSeven""":
          """[placeholder]: texto quando nenhum item está selecionado.""",
      """pages.datatableSelect.optionEight""": """[title]: título do modal.""",
      """pages.datatableSelect.optionNine""":
          """[modalSize]: tamanho do modal (large, xtra-large).""",
      """pages.datatableSelect.optionTen""":
          """[disabled]: desabilita o componente.""",
      """pages.datatableSelect.optionEleven""":
          """[fullScreenOnMobile]: modal fullscreen no mobile.""",
      """pages.datatableSelect.outputOne""":
          """(dataRequest): emitido quando o datatable solicita dados.""",
      """pages.datatableSelect.outputTwo""":
          """(currentValueChange): emitido quando o valor selecionado muda.""",
      """pages.datatableSelect.outputThree""":
          """(limitChange): emitido quando o limite por página muda.""",
      """pages.datatableSelect.outputFour""":
          """(searchRequest): emitido quando uma busca é submetida.""",
      """pages.datatableSelect.methodOne""": """clear(): limpa a seleção.""",
      """pages.datatableSelect.methodTwo""":
          """setSelectedItem({label, value}): define a seleção programaticamente.""",
      """pages.datatableSelect.methodThree""":
          """selectedLabel: getter que retorna o label atual.""",
      """pages.datatableSelect.noteOne""":
          """Compatível com ngModel via ControlValueAccessor.""",
      """pages.datatableSelect.noteTwo""":
          """Mantenha o DataFrame estável; atualize apenas via (dataRequest).""",
      """pages.datatableSelect.noteThree""":
          """O botão de limpar no trigger aparece quando há valor selecionado.""",
      """pages.datatableSelect.columnId""": """ID""",
      """pages.datatableSelect.columnName""": """Nome""",
      """pages.datatableSelect.columnEmail""": """E-mail""",
      """pages.datatableSelect.columnDepartment""": """Departamento""",
      """pages.datatableSelect.searchName""": """Nome""",
      """pages.datatableSelect.searchEmail""": """E-mail""",
      """pages.datatableSelect.searchDepartment""": """Departamento""",
      """pages.datatableSelect.departmentEngineering""": """Engenharia""",
      """pages.datatableSelect.departmentDesign""": """Design""",
      """pages.datatableSelect.departmentMarketing""": """Marketing""",
      """pages.datatableSelect.departmentFinance""": """Financeiro""",
      """pages.datatableSelect.departmentHr""": """RH""",
      """pages.datatableSelect.ngModelValuePrefix""": """ngModel value""",
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
      """pages.button.overviewIntro""":
          """Esta página reúne variações de cor, estilo, tamanho, alinhamento e estados do componente de botão.""",
      """pages.button.usePrefix""": """Use""",
      """pages.button.demoButton""": """Botão""",
      """pages.button.lightCardTitle""": """Botão light""",
      """pages.button.darkCardTitle""": """Botão dark""",
      """pages.button.primaryCardTitle""": """Botão primary""",
      """pages.button.secondaryCardTitle""": """Botão secondary""",
      """pages.button.dangerCardTitle""": """Botão danger""",
      """pages.button.successCardTitle""": """Botão success""",
      """pages.button.warningCardTitle""": """Botão warning""",
      """pages.button.infoCardTitle""": """Botão info""",
      """pages.button.indigoCardTitle""": """Botão indigo""",
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
      """pages.fab.title""": """Componentes""",
      """pages.fab.subtitle""": """FAB""",
      """pages.fab.breadcrumbParent""": """Componentes""",
      """pages.fab.breadcrumb""": """FAB""",
      """pages.fab.intro""":
          """O menu de botão de ação flutuante (FAB) exibe um botão flutuante único, com ou sem menu aninhado. A demonstração abaixo segue a organização visual do Limitless, com exemplos de interação, direção, rótulos e cores.""",
      """pages.fab.basicTitle""": """Exemplos básicos""",
      """pages.fab.basicSubtitle""":
          """Demonstração de botões e listas de botões""",
      """pages.fab.singleTitle""": """Botão flutuante único""",
      """pages.fab.singleBody""":
          """O botão flutuante usa marcação de botão padrão com .fab-menu-btn dentro do container .fab-menu.""",
      """pages.fab.hoverTitle""": """Abrir menu ao passar o cursor""",
      """pages.fab.hoverBody""":
          """Use a semântica data-fab-toggle="hover" para menus que devem expandir ao passar o cursor.""",
      """pages.fab.clickTitle""": """Abrir menu no clique""",
      """pages.fab.clickBody""":
          """O caso mais comum é abrir no clique com o trigger padrão somente com ícone.""",
      """pages.fab.elementsTitle""": """Elementos do menu FAB""",
      """pages.fab.elementsSubtitle""":
          """Botões, direções e posicionamento fixo""",
      """pages.fab.simpleButtonsTitle""": """Botões simples""",
      """pages.fab.simpleButtonsBody""":
          """O submenu normalmente contém botões arredondados com um único ícone.""",
      """pages.fab.sideActionsTitle""": """Ações laterais""",
      """pages.fab.sideActionsBody""":
          """A direção à esquerda mantém o trigger principal compacto enquanto expõe ações contextuais na lateral.""",
      """pages.fab.customTemplatesTitle""": """Modelos personalizados""",
      """pages.fab.customTemplatesBody""":
          """Use TemplateRef para personalizar o conteúdo do gatilho e das ações sem substituir o comportamento do FAB, os atalhos de teclado ou o tratamento de links.""",
      """pages.fab.noBackdropTitle""": """Ação de página sem sobreposição""",
      """pages.fab.noBackdropBody""":
          """A variante sem backdrop é exibida dentro do card para evitar colisão com a barra lateral esquerda. O FAB fixo real continua na borda direita da página.""",
      """pages.fab.innerLabelsTitle""": """Rótulos dos botões internos""",
      """pages.fab.innerLabelsSubtitle""":
          """Tooltips visíveis, rótulos claros e posições do rótulo""",
      """pages.fab.visibleLabelsTitle""": """Rótulos visíveis""",
      """pages.fab.visibleLabelsBody""":
          """Use .fab-label-visible quando os rótulos precisarem permanecer visíveis enquanto o menu estiver expandido.""",
      """pages.fab.lightLabelsTitle""": """Rótulos claros""",
      """pages.fab.lightLabelsBody""":
          """Todos os tipos de botão suportam tooltips claros como alternativa aos rótulos escuros padrão.""",
      """pages.fab.labelPositionsTitle""": """Posições do rótulo""",
      """pages.fab.labelPositionsBody""":
          """A esquerda é o padrão; use .fab-label-end para posicionar os rótulos no lado direito.""",
      """pages.fab.defaultColorsTitle""": """Cores padrão dos botões""",
      """pages.fab.defaultColorsSubtitle""":
          """Exemplos de cores contextuais predefinidas""",
      """pages.fab.primaryColorTitle""": """Cor primária do botão""",
      """pages.fab.primaryColorBody""":
          """A variação contextual primária usa o botão principal padrão .btn-primary.""",
      """pages.fab.successColorTitle""": """Cor de sucesso do botão""",
      """pages.fab.successColorBody""":
          """Use .btn-success para uma variante contextual positiva.""",
      """pages.fab.warningColorTitle""": """Cor de alerta do botão""",
      """pages.fab.warningColorBody""":
          """A variação warning é uma alternativa contextual forte para ações que exigem atenção.""",
      """pages.fab.customColorsTitle""": """Opções de cores customizadas""",
      """pages.fab.customColorsSubtitle""":
          """Use cores customizadas nos botões principais e internos""",
      """pages.fab.customMainColorTitle""":
          """Cor customizada do botão principal""",
      """pages.fab.customMainColorBody""":
          """Cores da paleta secundária podem ser aplicadas diretamente ao trigger principal.""",
      """pages.fab.customInnerColorTitle""":
          """Cor customizada do botão interno""",
      """pages.fab.customInnerColorBody""":
          """As ações internas podem usar qualquer cor de botão do Limitless mantendo o trigger principal claro.""",
      """pages.fab.mixedColorsTitle""": """Misturando cores dos botões""",
      """pages.fab.mixedColorsBody""":
          """O submenu suporta cores contextuais misturadas sem mudar a marcação estrutural.""",
      """pages.fab.waitingAction""": """Aguardando ação do FAB.""",
      """pages.fab.demoActionPrefix""": """Ação selecionada no FAB: """,
      """pages.fab.fixedActionPrefix""": """FAB fixo com backdrop acionou: """,
      """pages.fab.noBackdropActionPrefix""":
          """FAB fixo sem backdrop acionou: """,
      """pages.fab.apiIntro""":
          """A implementação AngularDart mantém o contrato visual do Limitless e expõe uma API curta para ações, direção, toggle e posicionamento.""",
      """pages.fab.overviewLead""": """Markup padrão do menu FAB:""",
      """pages.fab.classesTitle""": """Classes do menu do FAB""",
      """pages.fab.classesIntro""":
          """O estilo do menu FAB é orientado por classes CSS e atributos de dados. A tabela abaixo resume as classes usadas por este wrapper AngularDart preservando o contrato original do Limitless.""",
      """pages.fab.classHeader""": """Classe""",
      """pages.fab.descriptionHeader""": """Descrição""",
      """pages.fab.basicClassesGroup""": """Classes básicas""",
      """pages.fab.directionsGroup""": """Direções e posicionamento""",
      """pages.fab.visibilityGroup""": """Visibilidade e rótulos""",
      """pages.fab.classMenuDesc""":
          """Wrapper principal usado pelo componente.""",
      """pages.fab.classMenuBtnDesc""":
          """Botão circular principal do trigger.""",
      """pages.fab.classMenuInnerDesc""":
          """Container interno da lista de ações.""",
      """pages.fab.classIconsDesc""":
          """Ícones rotacionados e suavizados pelo CSS do Limitless conforme o estado do menu.""",
      """pages.fab.classMenuTopDesc""": """O menu abre abaixo do trigger.""",
      """pages.fab.classMenuBottomDesc""": """O menu abre acima do trigger.""",
      """pages.fab.classMenuFixedDesc""":
          """FAB fixo no viewport usado para ações persistentes da página.""",
      """pages.fab.classDirHorizontalDesc""":
          """Extensões horizontais adicionadas pelo wrapper AngularDart.""",
      """pages.fab.toggleClickDesc""": """Comportamento de abrir no clique.""",
      """pages.fab.toggleHoverDesc""":
          """Comportamento de abrir ao passar o cursor.""",
      """pages.fab.stateOpenDesc""":
          """Aplicado enquanto o menu está expandido.""",
      """pages.fab.dataFabLabelDesc""":
          """Texto de tooltip para ações internas.""",
      """pages.fab.labelModifiersDesc""":
          """Modificadores de rótulo alinhado à direita, claro e persistente.""",
      """pages.fab.customTriggerClose""": """Fechar""",
      """pages.fab.customTriggerActions""": """Ações rápidas""",
      """pages.fab.actionComposeEmail""": """Escrever e-mail""",
      """pages.fab.actionConversations""": """Conversas""",
      """pages.fab.actionAccountSecurity""": """Segurança da conta""",
      """pages.fab.actionAnalytics""": """Análises""",
      """pages.fab.actionPrivacy""": """Privacidade""",
      """pages.fab.actionEdit""": """Editar""",
      """pages.fab.actionShare""": """Compartilhar""",
      """pages.fab.actionArchive""": """Arquivar""",
      """pages.fab.actionPublish""": """Publicar""",
      """pages.fab.actionSaveDraft""": """Salvar rascunho""",
      """pages.fab.actionPreview""": """Pré-visualizar""",
      """pages.fab.markupRunPipeline""": """Executar pipeline""",
    };
