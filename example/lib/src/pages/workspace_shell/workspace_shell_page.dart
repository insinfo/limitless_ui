import 'package:limitless_ui_example/limitless_ui_example.dart';

class WorkspaceShellOrgEntry {
  const WorkspaceShellOrgEntry(this.name, this.id);

  final String name;
  final String id;

  String get stableKey => '$id:$name';
}

class WorkspaceShellNavEntry {
  const WorkspaceShellNavEntry(
    this.label,
    this.iconClass, {
    this.active = false,
    this.badge,
  });

  final String label;
  final String iconClass;
  final bool active;
  final String? badge;
}

class WorkspaceShellToastEntry {
  const WorkspaceShellToastEntry(
    this.message,
    this.time,
  );

  final String message;
  final String time;
}

class WorkspaceShellNotificationEntry {
  const WorkspaceShellNotificationEntry(
    this.title,
    this.body,
    this.time,
  );

  final String title;
  final String body;
  final String time;
}

class WorkspaceShellMetricEntry {
  const WorkspaceShellMetricEntry(
    this.label,
    this.value,
    this.help,
  );

  final String label;
  final String value;
  final String help;
}

@Component(
  selector: 'workspace-shell-page',
  templateUrl: 'workspace_shell_page.html',
  styleUrls: ['workspace_shell_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DemoPageBreadcrumbComponent,
    LiDropdownDirective,
    LiDropdownToggleDirective,
    LiDropdownMenuDirective,
    LiDropdownItemDirective,
    LiDropdownSubmenuDirective,
    LiDropdownSubmenuToggleDirective,
    LiDropdownSubmenuMenuDirective,
  ],
)
class WorkspaceShellPageComponent {
  WorkspaceShellPageComponent(this.i18n);

  final DemoI18nService i18n;

  bool showBannerTestVersion = true;
  bool statusBarVisible = true;
  bool statusBarExpanded = false;
  String selectedTheme = 'light';
  String processLookup = '24123/2026';
  String lookupStatus =
      'Pronto para consultar um processo usando a busca central.';

  final List<WorkspaceShellNavEntry> sidebarEntries =
      const <WorkspaceShellNavEntry>[
    WorkspaceShellNavEntry('Painel', 'ph-squares-four', active: true),
    WorkspaceShellNavEntry('Fila de analise', 'ph-hourglass-medium',
        badge: '18'),
    WorkspaceShellNavEntry('Atendimento', 'ph-headset', badge: '6'),
    WorkspaceShellNavEntry('Protocolos', 'ph-files'),
    WorkspaceShellNavEntry('Agenda', 'ph-calendar-blank'),
    WorkspaceShellNavEntry('Configuracoes', 'ph-gear-six'),
  ];

  final List<WorkspaceShellOrgEntry> orgEntries =
      const <WorkspaceShellOrgEntry>[
    WorkspaceShellOrgEntry(
      'Secretaria de Desenvolvimento e Assistencia Social',
      '574',
    ),
    WorkspaceShellOrgEntry(
      'Departamento de Gerenciamento de Registros e Desenvolvimento de Pessoal',
      '637',
    ),
    WorkspaceShellOrgEntry('Nucleo de Baixas', '1191'),
    WorkspaceShellOrgEntry(
      'Gerencia de Sistemas e Solucoes Tecnologicas',
      '1235',
    ),
  ];

  final List<WorkspaceShellToastEntry> toastEntries =
      const <WorkspaceShellToastEntry>[
    WorkspaceShellToastEntry(
      'Processo 24123/2026 encaminhado para analise tecnica.',
      '22/05/2026 10:12',
    ),
    WorkspaceShellToastEntry(
      'Assinatura aguardando revisao da chefia imediata.',
      '22/05/2026 09:40',
    ),
    WorkspaceShellToastEntry(
      'Integracao com protocolo externo sincronizada com sucesso.',
      '22/05/2026 09:08',
    ),
  ];

  final List<WorkspaceShellNotificationEntry> notificationEntries =
      const <WorkspaceShellNotificationEntry>[
    WorkspaceShellNotificationEntry(
      'Fila atualizada',
      'A triagem recebeu 4 novos itens prioritarios no ultimo minuto.',
      'Ha instantes',
    ),
    WorkspaceShellNotificationEntry(
      'Agenda confirmada',
      'A pauta da tarde foi publicada para a equipe de atendimento.',
      '5 min',
    ),
    WorkspaceShellNotificationEntry(
      'Resumo diario',
      'O fechamento parcial indica 82% das tarefas do turno concluidas.',
      '18 min',
    ),
  ];

  final List<WorkspaceShellMetricEntry> metricEntries =
      const <WorkspaceShellMetricEntry>[
    WorkspaceShellMetricEntry(
      'Pendencias criticas',
      '18',
      'Itens que exigem acao antes do fechamento do expediente.',
    ),
    WorkspaceShellMetricEntry(
      'Atendimentos do dia',
      '42',
      'Movimentacoes registradas pela equipe na jornada atual.',
    ),
    WorkspaceShellMetricEntry(
      'Tempo medio',
      '12 min',
      'Intervalo medio entre triagem, despacho e atualizacao do status.',
    ),
  ];

  int _currentOrgIndex = 3;

  bool get _isPt => i18n.isPortuguese;

  WorkspaceShellOrgEntry get currentOrg => orgEntries[_currentOrgIndex];

  int get notificationCount => notificationEntries.length;

  String get pageTitle => _isPt ? 'Exemplos' : 'Examples';

  String get pageSubtitle => _isPt ? 'Shell de trabalho' : 'Workspace shell';

  String get breadcrumb => _isPt
      ? 'Navbar densa com sidebar, busca e dropdowns reais'
      : 'Dense navbar with sidebar, search, and realistic dropdowns';

  String get intro => _isPt
      ? 'Esta tela simula um shell administrativo completo dentro do example para validar navbar compacta, dropdown de setor em overlay body, menu de usuario com submenu lateral e status bar no rodape.'
      : 'This page simulates a full administrative shell inside the example to validate a compact navbar, a body-overlay organization dropdown, a user menu with lateral submenu, and a bottom status bar.';

  String get heroEyebrow =>
      _isPt ? 'Ambiente operacional' : 'Operational shell';

  String get heroTitle => _isPt
      ? 'Layout de trabalho com navbar, sidebar e rodape de status'
      : 'Workspace layout with navbar, sidebar, and status footer';

  String get heroBody => _isPt
      ? 'Use esta demo para exercitar truncamento do badge, alinhamento bottom-end, overlay em body perto da borda direita e o submenu de tema em um contexto mais proximo do uso real.'
      : 'Use this demo to exercise badge truncation, bottom-end alignment, a body overlay near the right edge, and the theme submenu in a layout that is closer to real usage.';

  String get bannerLabel => _isPt ? 'Ambiente de teste' : 'Test environment';

  String get searchPlaceholder => _isPt
      ? 'Digite numero/ano e pressione Enter'
      : 'Type number/year and press Enter';

  String get searchStatusLabel => _isPt ? 'Ultima acao' : 'Last action';

  String get shellStateTitle => _isPt ? 'Estado da demonstracao' : 'Demo state';

  String get quickPanelTitle => _isPt ? 'Fila priorizada' : 'Priority queue';

  String get quickPanelBody => _isPt
      ? 'Uma combinacao de cards, chips e linhas de acao para representar o conteudo principal do modulo.'
      : 'A combination of cards, chips, and action rows to represent the module main content.';

  String get notificationMenuTitle =>
      _isPt ? 'Notificacoes recentes' : 'Recent notifications';

  String get statusBarActionLabel => statusBarVisible
      ? (_isPt ? 'Ocultar status bar' : 'Hide status bar')
      : (_isPt ? 'Exibir status bar' : 'Show status bar');

  String get statusBarStateLabel {
    if (!statusBarVisible) {
      return _isPt ? 'Status bar oculta' : 'Status bar hidden';
    }
    return statusBarExpanded
        ? (_isPt ? 'Status bar expandida' : 'Status bar expanded')
        : (_isPt ? 'Status bar compacta' : 'Status bar compact');
  }

  String get themeMenuLabel => _isPt ? 'Tema' : 'Theme';

  String get sessionNote => _isPt
      ? 'Obs.: abas no mesmo perfil compartilham sessao. Para usuarios diferentes simultaneos, use perfis separados ou janela anonima.'
      : 'Note: tabs in the same profile share the session. For different users at the same time, use separate profiles or an incognito window.';

  String get selectedThemeLabel {
    switch (selectedTheme) {
      case 'dark':
        return _isPt ? 'Escuro' : 'Dark';
      case 'blu':
        return _isPt ? 'Medio' : 'Medium';
      case 'pin':
        return _isPt ? 'Rosa' : 'Pink';
      default:
        return _isPt ? 'Claro' : 'Light';
    }
  }

  String themeOptionLabel(String theme) {
    switch (theme) {
      case 'dark':
        return _isPt ? 'Tema escuro' : 'Dark theme';
      case 'blu':
        return _isPt ? 'Tema medio' : 'Medium theme';
      case 'pin':
        return _isPt ? 'Tema rosa' : 'Pink theme';
      default:
        return _isPt ? 'Tema claro' : 'Light theme';
    }
  }

  String themeIconClass(String theme) {
    switch (theme) {
      case 'dark':
        return 'ph-moon';
      case 'blu':
        return 'ph-star-half';
      case 'pin':
        return 'ph-heart-half';
      default:
        return 'ph-sun';
    }
  }

  void submitSearch() {
    final normalized = processLookup.trim();
    if (normalized.isEmpty) {
      lookupStatus = _isPt
          ? 'Informe numero/ano para abrir uma consulta simulada.'
          : 'Provide number/year to run a simulated lookup.';
      return;
    }

    lookupStatus = _isPt
        ? 'A busca abriria o processo $normalized no painel principal.'
        : 'The search would open process $normalized in the main panel.';
  }

  void changeOrganogramaAtual(WorkspaceShellOrgEntry org) {
    _currentOrgIndex = orgEntries.indexOf(org);
  }

  void toggleStatusBar() {
    statusBarVisible = !statusBarVisible;
    if (!statusBarVisible) {
      statusBarExpanded = false;
    }
  }

  void toggleExpandStatusBar() {
    if (!statusBarVisible) {
      return;
    }
    statusBarExpanded = !statusBarExpanded;
  }

  void changeTheme(String theme) {
    selectedTheme = theme;
  }

  Object trackByOrg(int index, dynamic item) =>
      (item as WorkspaceShellOrgEntry).stableKey;

  Object trackBySidebar(int index, dynamic item) =>
      (item as WorkspaceShellNavEntry).label;

  Object trackByToast(int index, dynamic item) =>
      (item as WorkspaceShellToastEntry).message;

  Object trackByNotification(int index, dynamic item) =>
      (item as WorkspaceShellNotificationEntry).title;

  Object trackByMetric(int index, dynamic item) =>
      (item as WorkspaceShellMetricEntry).label;
}
