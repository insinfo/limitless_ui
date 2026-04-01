import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'fab-page',
  templateUrl: 'fab_page.html',
  styleUrls: ['fab_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiFabComponent,
    LiHighlightComponent,
  ],
)
class FabPageComponent {
  FabPageComponent(this.i18n);

  final DemoI18nService i18n;

  bool get _isPt => i18n.isPortuguese;

  String lastAction = '';

  final List<LiFabAction> emptyActions = const <LiFabAction>[];

  final List<LiFabAction> compactActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-pencil',
      label: 'Compose email',
      value: 'compose',
    ),
    LiFabAction(
      iconClass: 'ph-chats',
      label: 'Conversations',
      value: 'chat',
    ),
  ];

  final List<LiFabAction> hoverActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-pencil',
      label: 'Compose email',
      value: 'compose',
    ),
    LiFabAction(
      iconClass: 'ph-chats',
      label: 'Conversations',
      value: 'chat',
    ),
  ];

  final List<LiFabAction> clickActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-pencil',
      label: 'Compose email',
      value: 'compose',
    ),
    LiFabAction(
      iconClass: 'ph-chats',
      label: 'Conversations',
      value: 'chat',
    ),
  ];

  final List<LiFabAction> sideActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-arrow-left',
      label: 'Account security',
      value: 'security',
      labelAtEnd: true,
    ),
    LiFabAction(
      iconClass: 'ph-chart-bar',
      label: 'Analytics',
      value: 'analytics',
      lightLabel: true,
      labelAtEnd: true,
    ),
    LiFabAction(
      iconClass: 'ph-lock-key',
      label: 'Privacy',
      value: 'privacy',
      labelAtEnd: true,
    ),
  ];

  final List<LiFabAction> visibleLabelActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-pencil',
      label: 'Compose email',
      value: 'compose',
      labelAtEnd: true,
      alwaysShowLabel: true,
    ),
    LiFabAction(
      iconClass: 'ph-chats',
      label: 'Conversations',
      value: 'chat',
      labelAtEnd: true,
      lightLabel: true,
      alwaysShowLabel: true,
    ),
  ];

  final List<LiFabAction> lightLabelActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-pencil',
      label: 'Compose email',
      value: 'compose',
      labelAtEnd: true,
      lightLabel: true,
    ),
    LiFabAction(
      iconClass: 'ph-chats',
      label: 'Conversations',
      value: 'chat',
      labelAtEnd: true,
      lightLabel: true,
    ),
  ];

  final List<LiFabAction> labelPositionActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-pencil',
      label: 'Compose email',
      value: 'compose',
    ),
    LiFabAction(
      iconClass: 'ph-chats',
      label: 'Conversations',
      value: 'chat',
      labelAtEnd: true,
    ),
  ];

  final List<LiFabAction> indigoInnerActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-pencil',
      label: 'Compose email',
      value: 'compose',
      variant: 'indigo',
    ),
    LiFabAction(
      iconClass: 'ph-chats',
      label: 'Conversations',
      value: 'chat',
      variant: 'indigo',
    ),
  ];

  final List<LiFabAction> mixedColorActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-pencil',
      label: 'Compose email',
      value: 'compose',
      variant: 'teal',
    ),
    LiFabAction(
      iconClass: 'ph-chats',
      label: 'Conversations',
      value: 'chat',
      variant: 'warning',
    ),
  ];

  final List<LiFabAction> fixedActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-pencil-simple',
      label: 'Editar',
      value: 'edit',
      variant: 'primary',
      shortcut: LiFabShortcut(ctrl: true, key: 'e'),
    ),
    LiFabAction(
      iconClass: 'ph-share-network',
      label: 'Compartilhar',
      value: 'share',
      variant: 'indigo',
      shortcut: LiFabShortcut(ctrl: true, shift: true, key: 's'),
    ),
    LiFabAction(
      iconClass: 'ph-archive-box',
      label: 'Arquivar',
      value: 'archive',
      variant: 'warning',
      buttonStyle: 'outline',
    ),
  ];

  final List<LiFabAction> fixedNoBackdropActions = const <LiFabAction>[
    LiFabAction(
      iconClass: 'ph-paper-plane-tilt',
      label: 'Publicar',
      value: 'publish',
      variant: 'primary',
    ),
    LiFabAction(
      iconClass: 'ph-floppy-disk',
      label: 'Salvar rascunho',
      value: 'draft',
      variant: 'light',
    ),
    LiFabAction(
      iconClass: 'ph-eye',
      label: 'Pré-visualizar',
      value: 'preview',
      variant: 'info',
      buttonStyle: 'outline',
    ),
  ];

  final String markupSnippet = '''<div class="fab-menu" data-fab-toggle="click">
  <button type="button" class="fab-menu-btn btn btn-primary btn-icon rounded-pill">
    <div class="m-1">
      <i class="fab-icon-open ph-plus"></i>
      <i class="fab-icon-close ph-x"></i>
    </div>
  </button>

  <ul class="fab-menu-inner">
    <li>
      <div data-fab-label="Executar pipeline">
        <a href="#" class="btn btn-light btn-icon rounded-pill">
          <i class="ph-play m-1"></i>
        </a>
      </div>
    </li>
  </ul>
</div>''';

  final String apiSnippet = '''final actions = <LiFabAction>[
  const LiFabAction(
    iconClass: 'ph-pencil',
    label: 'Compose email',
    value: 'compose',
  ),
  const LiFabAction(
    iconClass: 'ph-chats',
    label: 'Conversations',
    value: 'chat',
  ),
];

<li-fab
    iconClass="ph-plus"
    [actions]="actions"
    toggleMode="click"
    direction="down"
    [fixed]="false"
    (actionSelected)="handleDemoAction(\$event)">
</li-fab>''';

  final String templateSnippet = '''<template #customFabTrigger let-trigger>
  <span class="d-inline-flex align-items-center gap-2">
    <i class="ph" [class.ph-plus]="!trigger.expanded" [class.ph-x]="trigger.expanded"></i>
    <span>{{ trigger.expanded ? 'Fechar' : 'Ações rápidas' }}</span>
  </span>
</template>

<template #customFabAction let-item>
  <span class="d-inline-flex align-items-center gap-2 px-1">
    <i [class]="item.iconClass"></i>
    <span>{{ item.label }}</span>
  </span>
</template>

<li-fab
    [fixed]="false"
    [actions]="compactActions"
    [triggerTemplate]="customFabTrigger"
    [actionTemplate]="customFabAction"
    direction="down"
    toggleMode="click"
    (actionSelected)="handleDemoAction(\$event)">
</li-fab>''';

  String get pageTitle => _isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'FAB';
  String get breadcrumbParent => _isPt ? 'Componentes' : 'Components';
  String get breadcrumb => 'FAB';
  String get intro => _isPt
      ? 'Floating action button (FAB) menu é o componente para exibir um botão flutuante único com ou sem menu aninhado. A demonstração abaixo segue a organização visual do Limitless, com exemplos de interação, direção, labels e cores.'
      : 'Floating action button (FAB) menu is a component for displaying a single floating button with or without a nested menu. The demo below follows the Limitless visual organization with interaction, direction, label, and color examples.';
  String get overviewLead =>
      _isPt ? 'Markup padrão do FAB menu:' : 'Default FAB menu markup:';
  String get apiIntro => _isPt
      ? 'A implementação AngularDart mantém o contrato visual do Limitless e expõe uma API curta para ações, direção, toggle e posicionamento.'
      : 'The AngularDart implementation keeps the Limitless visual contract and exposes a short API for actions, direction, toggle, and positioning.';
  String get summaryText => lastAction.isEmpty
      ? (_isPt ? 'Aguardando ação do FAB.' : 'Waiting for FAB action.')
      : lastAction;

  void handleDemoAction(LiFabAction action) {
    lastAction = _isPt
        ? 'Ação selecionada no FAB: ${action.value ?? action.label}'
        : 'FAB action selected: ${action.value ?? action.label}';
  }

  void handleFixedAction(LiFabAction action) {
    lastAction = _isPt
        ? 'FAB fixo com backdrop acionou: ${action.value ?? action.label}'
        : 'Fixed FAB with backdrop triggered: ${action.value ?? action.label}';
  }

  void handleNoBackdropAction(LiFabAction action) {
    lastAction = _isPt
        ? 'FAB fixo sem backdrop acionou: ${action.value ?? action.label}'
        : 'Fixed FAB without backdrop triggered: ${action.value ?? action.label}';
  }
}
