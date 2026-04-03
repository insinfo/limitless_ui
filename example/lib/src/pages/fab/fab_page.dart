import 'package:limitless_ui_example/limitless_ui_example.dart';
import 'package:limitless_ui_example/messages_en.i18n.dart' as en;

@Component(
  selector: 'fab-page',
  templateUrl: 'fab_page.html',
  styleUrls: ['fab_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiFabComponent,
    LiHighlightComponent,
  ],
)
class FabPageComponent {
  FabPageComponent(this.i18n)
      : _pt = Messages(),
        _en = en.MessagesEn() {
    _compactActionsPt = _buildCompactActions(_pt);
    _compactActionsEn = _buildCompactActions(_en);
    _sideActionsPt = _buildSideActions(_pt);
    _sideActionsEn = _buildSideActions(_en);
    _visibleLabelActionsPt = _buildVisibleLabelActions(_pt);
    _visibleLabelActionsEn = _buildVisibleLabelActions(_en);
    _lightLabelActionsPt = _buildLightLabelActions(_pt);
    _lightLabelActionsEn = _buildLightLabelActions(_en);
    _labelPositionActionsPt = _buildLabelPositionActions(_pt);
    _labelPositionActionsEn = _buildLabelPositionActions(_en);
    _indigoInnerActionsPt = _buildIndigoInnerActions(_pt);
    _indigoInnerActionsEn = _buildIndigoInnerActions(_en);
    _mixedColorActionsPt = _buildMixedColorActions(_pt);
    _mixedColorActionsEn = _buildMixedColorActions(_en);
    _fixedActionsPt = _buildFixedActions(_pt);
    _fixedActionsEn = _buildFixedActions(_en);
    _fixedNoBackdropActionsPt = _buildFixedNoBackdropActions(_pt);
    _fixedNoBackdropActionsEn = _buildFixedNoBackdropActions(_en);
    _markupSnippetPt = _buildMarkupSnippet(_pt);
    _markupSnippetEn = _buildMarkupSnippet(_en);
    _apiSnippetPt = _buildApiSnippet(_pt);
    _apiSnippetEn = _buildApiSnippet(_en);
    _templateSnippetPt = _buildTemplateSnippet(_pt);
    _templateSnippetEn = _buildTemplateSnippet(_en);
  }

  final DemoI18nService i18n;
  final Messages _pt;
  final en.MessagesEn _en;

  Messages get t => i18n.t;

  bool get _isPt => i18n.isPortuguese;

  String lastAction = '';

  final List<LiFabAction> emptyActions = const <LiFabAction>[];
  late final List<LiFabAction> _compactActionsPt;
  late final List<LiFabAction> _compactActionsEn;
  late final List<LiFabAction> _sideActionsPt;
  late final List<LiFabAction> _sideActionsEn;
  late final List<LiFabAction> _visibleLabelActionsPt;
  late final List<LiFabAction> _visibleLabelActionsEn;
  late final List<LiFabAction> _lightLabelActionsPt;
  late final List<LiFabAction> _lightLabelActionsEn;
  late final List<LiFabAction> _labelPositionActionsPt;
  late final List<LiFabAction> _labelPositionActionsEn;
  late final List<LiFabAction> _indigoInnerActionsPt;
  late final List<LiFabAction> _indigoInnerActionsEn;
  late final List<LiFabAction> _mixedColorActionsPt;
  late final List<LiFabAction> _mixedColorActionsEn;
  late final List<LiFabAction> _fixedActionsPt;
  late final List<LiFabAction> _fixedActionsEn;
  late final List<LiFabAction> _fixedNoBackdropActionsPt;
  late final List<LiFabAction> _fixedNoBackdropActionsEn;
  late final String _markupSnippetPt;
  late final String _markupSnippetEn;
  late final String _apiSnippetPt;
  late final String _apiSnippetEn;
  late final String _templateSnippetPt;
  late final String _templateSnippetEn;

  List<LiFabAction> get compactActions =>
      _isPt ? _compactActionsPt : _compactActionsEn;
  List<LiFabAction> get hoverActions => compactActions;
  List<LiFabAction> get clickActions => compactActions;
  List<LiFabAction> get sideActions => _isPt ? _sideActionsPt : _sideActionsEn;
  List<LiFabAction> get visibleLabelActions =>
      _isPt ? _visibleLabelActionsPt : _visibleLabelActionsEn;
  List<LiFabAction> get lightLabelActions =>
      _isPt ? _lightLabelActionsPt : _lightLabelActionsEn;
  List<LiFabAction> get labelPositionActions =>
      _isPt ? _labelPositionActionsPt : _labelPositionActionsEn;
  List<LiFabAction> get indigoInnerActions =>
      _isPt ? _indigoInnerActionsPt : _indigoInnerActionsEn;
  List<LiFabAction> get mixedColorActions =>
      _isPt ? _mixedColorActionsPt : _mixedColorActionsEn;
  List<LiFabAction> get fixedActions =>
      _isPt ? _fixedActionsPt : _fixedActionsEn;
  List<LiFabAction> get fixedNoBackdropActions =>
      _isPt ? _fixedNoBackdropActionsPt : _fixedNoBackdropActionsEn;
  String get markupSnippet => _isPt ? _markupSnippetPt : _markupSnippetEn;
  String get apiSnippet => _isPt ? _apiSnippetPt : _apiSnippetEn;
  String get templateSnippet => _isPt ? _templateSnippetPt : _templateSnippetEn;
  String get summaryText =>
      lastAction.isEmpty ? t.pages.fab.waitingAction : lastAction;
  String get overviewLead => t.pages.fab.overviewLead;
  String get apiIntro => t.pages.fab.apiIntro;

  List<LiFabAction> _buildCompactActions(Messages text) => <LiFabAction>[
        LiFabAction(
          iconClass: 'ph-pencil',
          label: text.pages.fab.actionComposeEmail,
          value: 'compose',
        ),
        LiFabAction(
          iconClass: 'ph-chats',
          label: text.pages.fab.actionConversations,
          value: 'chat',
        ),
      ];

  List<LiFabAction> _buildSideActions(Messages text) => <LiFabAction>[
        LiFabAction(
          iconClass: 'ph-arrow-left',
          label: text.pages.fab.actionAccountSecurity,
          value: 'security',
          labelAtEnd: true,
        ),
        LiFabAction(
          iconClass: 'ph-chart-bar',
          label: text.pages.fab.actionAnalytics,
          value: 'analytics',
          lightLabel: true,
          labelAtEnd: true,
        ),
        LiFabAction(
          iconClass: 'ph-lock-key',
          label: text.pages.fab.actionPrivacy,
          value: 'privacy',
          labelAtEnd: true,
        ),
      ];

  List<LiFabAction> _buildVisibleLabelActions(Messages text) => <LiFabAction>[
        LiFabAction(
          iconClass: 'ph-pencil',
          label: text.pages.fab.actionComposeEmail,
          value: 'compose',
          labelAtEnd: true,
          alwaysShowLabel: true,
        ),
        LiFabAction(
          iconClass: 'ph-chats',
          label: text.pages.fab.actionConversations,
          value: 'chat',
          labelAtEnd: true,
          lightLabel: true,
          alwaysShowLabel: true,
        ),
      ];

  List<LiFabAction> _buildLightLabelActions(Messages text) => <LiFabAction>[
        LiFabAction(
          iconClass: 'ph-pencil',
          label: text.pages.fab.actionComposeEmail,
          value: 'compose',
          labelAtEnd: true,
          lightLabel: true,
        ),
        LiFabAction(
          iconClass: 'ph-chats',
          label: text.pages.fab.actionConversations,
          value: 'chat',
          labelAtEnd: true,
          lightLabel: true,
        ),
      ];

  List<LiFabAction> _buildLabelPositionActions(Messages text) => <LiFabAction>[
        LiFabAction(
          iconClass: 'ph-pencil',
          label: text.pages.fab.actionComposeEmail,
          value: 'compose',
        ),
        LiFabAction(
          iconClass: 'ph-chats',
          label: text.pages.fab.actionConversations,
          value: 'chat',
          labelAtEnd: true,
        ),
      ];

  List<LiFabAction> _buildIndigoInnerActions(Messages text) => <LiFabAction>[
        LiFabAction(
          iconClass: 'ph-pencil',
          label: text.pages.fab.actionComposeEmail,
          value: 'compose',
          variant: 'indigo',
        ),
        LiFabAction(
          iconClass: 'ph-chats',
          label: text.pages.fab.actionConversations,
          value: 'chat',
          variant: 'indigo',
        ),
      ];

  List<LiFabAction> _buildMixedColorActions(Messages text) => <LiFabAction>[
        LiFabAction(
          iconClass: 'ph-pencil',
          label: text.pages.fab.actionComposeEmail,
          value: 'compose',
          variant: 'teal',
        ),
        LiFabAction(
          iconClass: 'ph-chats',
          label: text.pages.fab.actionConversations,
          value: 'chat',
          variant: 'warning',
        ),
      ];

  List<LiFabAction> _buildFixedActions(Messages text) => <LiFabAction>[
        LiFabAction(
          iconClass: 'ph-pencil-simple',
          label: text.pages.fab.actionEdit,
          value: 'edit',
          variant: 'primary',
          shortcut: LiFabShortcut(ctrl: true, key: 'e'),
        ),
        LiFabAction(
          iconClass: 'ph-share-network',
          label: text.pages.fab.actionShare,
          value: 'share',
          variant: 'indigo',
          shortcut: LiFabShortcut(ctrl: true, shift: true, key: 's'),
        ),
        LiFabAction(
          iconClass: 'ph-archive-box',
          label: text.pages.fab.actionArchive,
          value: 'archive',
          variant: 'warning',
          buttonStyle: 'outline',
        ),
      ];

  List<LiFabAction> _buildFixedNoBackdropActions(Messages text) =>
      <LiFabAction>[
        LiFabAction(
          iconClass: 'ph-paper-plane-tilt',
          label: text.pages.fab.actionPublish,
          value: 'publish',
          variant: 'primary',
        ),
        LiFabAction(
          iconClass: 'ph-floppy-disk',
          label: text.pages.fab.actionSaveDraft,
          value: 'draft',
          variant: 'light',
        ),
        LiFabAction(
          iconClass: 'ph-eye',
          label: text.pages.fab.actionPreview,
          value: 'preview',
          variant: 'info',
          buttonStyle: 'outline',
        ),
      ];

  String _buildMarkupSnippet(Messages text) =>
      '''<div class="fab-menu" data-fab-toggle="click">
  <button type="button" class="fab-menu-btn btn btn-primary btn-icon rounded-pill">
    <div class="m-1">
      <i class="fab-icon-open ph-plus"></i>
      <i class="fab-icon-close ph-x"></i>
    </div>
  </button>

  <ul class="fab-menu-inner">
    <li>
      <div data-fab-label="${text.pages.fab.markupRunPipeline}">
        <a href="#" class="btn btn-light btn-icon rounded-pill">
          <i class="ph-play m-1"></i>
        </a>
      </div>
    </li>
  </ul>
</div>''';

  String _buildApiSnippet(Messages text) => '''final actions = <LiFabAction>[
  const LiFabAction(
    iconClass: 'ph-pencil',
    label: '${text.pages.fab.actionComposeEmail}',
    value: 'compose',
  ),
  const LiFabAction(
    iconClass: 'ph-chats',
    label: '${text.pages.fab.actionConversations}',
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

  String _buildTemplateSnippet(Messages text) =>
      '''<template #customFabTrigger let-trigger>
  <span class="d-inline-flex align-items-center gap-2">
    <i class="ph" [class.ph-plus]="!trigger.expanded" [class.ph-x]="trigger.expanded"></i>
    <span>{{ trigger.expanded ? '${text.pages.fab.customTriggerClose}' : '${text.pages.fab.customTriggerActions}' }}</span>
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

  void handleDemoAction(LiFabAction action) {
    lastAction = '${t.pages.fab.demoActionPrefix}${action.label}';
  }

  void handleFixedAction(LiFabAction action) {
    lastAction = '${t.pages.fab.fixedActionPrefix}${action.label}';
  }

  void handleNoBackdropAction(LiFabAction action) {
    lastAction = '${t.pages.fab.noBackdropActionPrefix}${action.label}';
  }
}
