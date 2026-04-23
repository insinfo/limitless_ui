import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'selection-controls-page',
  templateUrl: 'selection_controls_page.html',
  styleUrls: ['selection_controls_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiCheckboxComponent,
    LiCheckboxGroupComponent,
    LiHighlightComponent,
    LiRadioComponent,
    LiRadioGroupComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiToggleComponent,
  ],
)
class SelectionControlsPageComponent {
  SelectionControlsPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  bool get isPt => i18n.isPortuguese;

  static const String checkboxSnippet = '''
<li-checkbox
    [label]="auditTrailLabel"
    [helperText]="auditTrailHelp"
    [(ngModel)]="auditTrailEnabled">
</li-checkbox>''';

  static const String radioSnippet = '''
<li-radio-group
    [legend]="radioFormLegend"
    [helperText]="radioFormHelp"
    [errorText]="radioFormError"
    [invalid]="radioFormInvalid">
  <li-radio
      name="approvalMode"
      value="manual"
      [(ngModel)]="approvalMode">
  </li-radio>
</li-radio-group>''';

  static const String toggleSnippet = '''
<li-toggle
    [label]="toggleFormLabel"
    [helperText]="toggleFormDescription"
    [errorText]="toggleFormError"
    [invalid]="toggleFormInvalid"
    [(ngModel)]="escalationToggleEnabled">
</li-toggle>''';

  static const String validationSnippet = '''
<li-checkbox
    label="Aceito os termos"
    [required]="true"
    [liMessages]="{
      'requiredTrue': 'Confirme o aceite.'
    }"
    liValidationMode="submitted"
    [(ngModel)]="acceptedTerms">
</li-checkbox>

<li-radio-group
    [legend]="radioFormLegend"
    [value]="approvalMode"
    [liRules]="[LiRule.required()]"
    [liMessages]="{
      'required': 'Selecione um modo de aprovação.'
    }"
    liValidationMode="submitted">
  ...
</li-radio-group>''';

  bool auditTrailEnabled = true;
  bool publicPortalEnabled = false;
  bool reviewQueueEnabled = true;
  bool smsChannelEnabled = true;
  bool emailChannelEnabled = false;
  bool pushChannelEnabled = true;
  bool reverseAuditEnabled = true;
  bool reverseClientFeedEnabled = false;
  bool reverseSlaAlertsEnabled = false;
  dynamic secondaryChecksEnabled = 'enabled';
  dynamic dangerChecksEnabled = 'disabled';
  dynamic successChecksEnabled = 'enabled';
  bool inversePinEnabled = true;
  bool inverseReadonlyEnabled = false;
  bool disabledAuditTrailEnabled = true;
  bool disabledPortalEnabled = false;
  String disabledVisibility = 'customers';
  bool disabledDigestEnabled = true;
  String disabledOnboardingState = 'paused';

  String visibility = 'team';
  String density = 'comfortable';
  String reviewFlow = 'manual';
  String contextualTone = 'secondary';
  String inverseFilter = 'internal';
  String? optionalFilter = 'active';
  String approvalMode = '';

  bool nightlyDigest = true;
  String onboardingState = 'enabled';
  String incidentEscalation = 'sms';
  bool automationMirrorEnabled = true;
  bool campaignMirrorEnabled = false;
  bool inlineSyncEnabled = true;
  bool inlineArchiveEnabled = false;
  bool toggleSecondaryEnabled = true;
  bool toggleWarningEnabled = false;
  bool toggleDarkEnabled = true;
  bool inverseMonitoringEnabled = true;
  bool inverseGuestsEnabled = false;
  bool escalationToggleEnabled = false;

  bool requiresValidationWindow = true;
  String? requiredChannel;

  String get pageTitle => isPt ? 'Forms' : 'Forms';
  String get pageSubtitle =>
      isPt ? 'Checkboxes, radios e toggles' : 'Checkboxes, radios, and toggles';
  String get breadcrumb =>
      isPt ? 'Controles de seleção' : 'Selection controls';
  String get introTitle => isPt
      ? 'Controles de seleção no padrão Limitless'
      : 'Limitless-style selection controls';
  String get introBody => isPt
      ? 'A página combina demos visuais e cenários de formulário para mostrar como checkbox, radio e toggle podem sair do showcase e entrar em fluxos reais com validação e feedback.'
      : 'This page combines visual demos and form scenarios to show how checkbox, radio, and toggle can move from showcase samples into real flows with validation and feedback.';
  String get apiIntro => isPt
      ? 'Os três componentes compartilham o mesmo padrão: `[(ngModel)]`, estados visuais, helper text e mensagens inline quando o caso pede validação.'
      : 'All three components share the same pattern: `[(ngModel)]`, visual states, helper text, and inline messages when validation is needed.';

  String get checkboxesTitle => 'Checkboxes';
  String get checkboxesSubtitle => isPt
      ? 'Empilhados, reversos, inline, cores, bloco inverso e caso de validação'
      : 'Stacked, reversed, inline, color, inverse block, and validation scenario';
  String get radiosTitle => 'Radios';
  String get radiosSubtitle => isPt
      ? 'Padrao neutro, cores contextuais e casos de formulario mais proximos de fluxos administrativos'
      : 'Neutral defaults, contextual colors, and form cases closer to administrative flows';
  String get togglesTitle => 'Toggles';
  String get togglesSubtitle => isPt
      ? 'Booleanos, valores mapeados, bloco inverso e exemplo com feedback'
      : 'Booleans, mapped values, inverse block, and feedback example';
  String get summaryTitle => isPt ? 'Resumo' : 'Summary';
  String get mainInputsTitle => isPt ? 'Pontos principais' : 'Main points';
  String get checkboxSnippetTitle => 'Checkbox';
  String get radioSnippetTitle => 'Radio group';
  String get toggleSnippetTitle => 'Toggle';

  String get leftStackedTitle => isPt ? 'Pilha à esquerda' : 'Left stacked';
  String get rightStackedTitle => isPt ? 'Pilha à direita' : 'Right stacked';
  String get inlineTitle => 'Inline';
  String get contextualTitle =>
      isPt ? 'Cores contextuais' : 'Contextual colors';
  String get inverseBlockTitle =>
      isPt ? 'Bloco inverso' : 'Inverse block';
  String get neutralTitle => isPt ? 'Padrão neutro' : 'Neutral defaults';
  String get mappedValuesTitle =>
      isPt ? 'Valores mapeados' : 'Mapped values';
  String get inlineReverseTitle =>
      isPt ? 'Inline e reverso' : 'Inline and reverse';
  String get colorSwitchesTitle =>
      isPt ? 'Switches coloridos' : 'Color switches';
  String get formScenarioTitle =>
      isPt ? 'Caso de formulário' : 'Form scenario';
  String get optionalRadioTitle =>
      isPt ? 'Filtro opcional' : 'Optional filter';
    String get disabledStateTitle =>
      isPt ? 'Estado desabilitado' : 'Disabled state';
    String get selectionReadonlyHint => isPt
      ? 'Checkbox, radio e toggle não têm readonly nativo; para exibir o valor sem permitir edição, use disabled.'
      : 'Checkbox, radio, and toggle do not have a native readonly state; use disabled to keep the value visible without allowing edits.';
  String get radioFormCaseTitle =>
      isPt ? 'Fluxo de aprovação' : 'Approval flow';
  String get toggleFormCaseTitle =>
      isPt ? 'Escalação obrigatória' : 'Required escalation';

  String get auditTrailLabel =>
      isPt ? 'Trilha de auditoria' : 'Audit trail';
  String get auditTrailHelp => isPt
      ? 'Mantém histórico completo das alterações.'
      : 'Keeps a full history of changes.';
  String get publicPortalLabel =>
      isPt ? 'Portal público' : 'Public portal';
  String get publicPortalHelp => isPt
      ? 'Expõe o status para acompanhamento externo.'
      : 'Exposes status for external tracking.';
  String get reviewQueueLabel =>
      isPt ? 'Fila de revisão' : 'Review queue';
  String get reviewQueueHelp => isPt
      ? 'Mantém uma etapa manual de aprovação.'
      : 'Keeps a manual approval step in place.';
  String get reverseAuditLabel =>
      isPt ? 'Auditoria externa' : 'External audit';
  String get reverseClientFeedLabel =>
      isPt ? 'Feed do cliente' : 'Client feed';
  String get reverseSlaLabel => isPt ? 'Alertas de SLA' : 'SLA alerts';
  String get smsLabel => 'SMS';
  String get emailLabel => isPt ? 'E-mail' : 'Email';
  String get pushLabel => 'Push';
  String get secondaryLabel => 'Secondary';
  String get dangerLabel => 'Danger';
  String get successLabel => 'Success';
  String get inversePinLabel => isPt
      ? 'Fixar este card no dashboard'
      : 'Pin this card on the dashboard';
  String get inverseReadonlyLabel =>
      isPt ? 'Modo somente leitura' : 'Read-only mode';
  String get complianceLegend =>
      isPt ? 'Checklist de conformidade' : 'Compliance checklist';
  String get complianceHelp => isPt
      ? 'Você pode reutilizar o grupo para um erro único do bloco, sem espalhar toast manual por cada campo.'
      : 'You can reuse the group for a single block-level error instead of scattering manual toasts across each field.';
  String get complianceError => isPt
      ? 'Ative ao menos uma proteção antes de liberar o fluxo.'
      : 'Enable at least one protection before releasing the flow.';
  bool get complianceInvalid =>
      !auditTrailEnabled && !publicPortalEnabled && !reviewQueueEnabled;

  String get teamLabel => isPt ? 'Equipe interna' : 'Internal team';
  String get customersLabel => isPt ? 'Clientes' : 'Customers';
  String get publicLabel => isPt ? 'Público' : 'Public';
  String get compactLabel => isPt ? 'Compacto' : 'Compact';
  String get comfortableLabel => isPt ? 'Confortável' : 'Comfortable';
  String get spaciousLabel => isPt ? 'Espaçado' : 'Spacious';
  String get manualLabel => isPt ? 'Manual' : 'Manual';
  String get assistedLabel => isPt ? 'Assistido' : 'Assisted';
  String get automaticLabel => isPt ? 'Automático' : 'Automatic';
  String get internalLabel => isPt ? 'Interno' : 'Internal';
  String get partnersLabel => isPt ? 'Parceiros' : 'Partners';
  String get activeLabel => isPt ? 'Ativo' : 'Active';
  String get pendingLabel => isPt ? 'Pendente' : 'Pending';
  String get radioUncheckableHelp => isPt
      ? 'Aqui o rádio usa `[uncheckable]="true"` com `String?` no host.'
      : 'This radio uses `[uncheckable]="true"` with `String?` on the host.';
  String get radioFormLegend => isPt
      ? 'Como a solicitação será aprovada?'
      : 'How will this request be approved?';
  String get radioFormHelp => isPt
      ? 'Exemplo de grupo único com legenda, descrição e mensagem de erro para o conjunto.'
      : 'Example of a single group with legend, description, and one error message for the whole set.';
  String get radioFormError => isPt
      ? 'Selecione um modo de aprovação antes de continuar.'
      : 'Select an approval mode before continuing.';
  bool get radioFormInvalid => approvalMode.trim().isEmpty;

  String get digestLabel =>
      isPt ? 'Digest noturno' : 'Nightly digest';
  String get digestHelp => isPt
      ? 'Envia um resumo automático no fim do expediente.'
      : 'Sends an automatic summary at the end of the workday.';
  String get onboardingLabel =>
      isPt ? 'Fluxo de onboarding' : 'Onboarding flow';
  String get onboardingHelp => isPt
      ? 'Usa `trueValue` e `falseValue` customizados.'
      : 'Uses custom `trueValue` and `falseValue`.';
  String get incidentLabel =>
      isPt ? 'Escalonamento crítico por SMS' : 'Critical escalation by SMS';
  String get incidentHelp => isPt
      ? 'Quando desligado, o fluxo cai para e-mail.'
      : 'When off, the flow falls back to email.';
  String get automationMirrorLabel =>
      isPt ? 'Espelhar automações' : 'Mirror automations';
  String get campaignMirrorLabel =>
      isPt ? 'Campanhas externas' : 'External campaigns';
  String get syncLabel => 'Sync';
  String get archiveLabel => isPt ? 'Arquivo' : 'Archive';
  String get warningLabel => 'Warning';
  String get darkLabel => 'Dark';
  String get inverseMonitoringLabel =>
      isPt ? 'Monitoramento ativo' : 'Active monitoring';
  String get inverseGuestsLabel =>
      isPt ? 'Convidados liberados' : 'Guests enabled';
  String get toggleFormLegend => isPt
      ? 'Notificações de escalonamento'
      : 'Escalation notifications';
  String get toggleFormHelp => isPt
      ? 'Caso comum de toggle usado como decisão obrigatória em formulário administrativo.'
      : 'Common toggle case used as a required decision in an administrative form.';
  String get toggleFormError => isPt
      ? 'Ative a notificação antes de salvar o fluxo.'
      : 'Enable the notification before saving the flow.';
  String get toggleFormLabel => isPt
      ? 'Enviar notificação de escalonamento'
      : 'Send escalation notification';
  String get toggleFormDescription => isPt
      ? 'Replica o padrao da interface administrativa em campos binarios com feedback inline.'
      : 'Mirrors the administrative UI pattern for binary fields with inline feedback.';
  bool get toggleFormInvalid => requiresValidationWindow && !escalationToggleEnabled;

  String get checkboxSummary {
    final enabled = <String>[];
    if (auditTrailEnabled) {
      enabled.add(isPt ? 'Auditoria' : 'Audit');
    }
    if (publicPortalEnabled) {
      enabled.add(isPt ? 'Portal público' : 'Public portal');
    }
    if (reviewQueueEnabled) {
      enabled.add(isPt ? 'Fila de revisão' : 'Review queue');
    }
    return enabled.isEmpty
        ? (isPt ? 'Nenhum recurso ativo.' : 'No enabled capability.')
        : enabled.join(', ');
  }

  String get checkboxChannelSummary {
    final enabled = <String>[];
    if (smsChannelEnabled) {
      enabled.add('SMS');
    }
    if (emailChannelEnabled) {
      enabled.add(emailLabel);
    }
    if (pushChannelEnabled) {
      enabled.add('Push');
    }
    return enabled.isEmpty
        ? (isPt ? 'Nenhum canal inline ativo.' : 'No inline channel enabled.')
        : enabled.join(', ');
  }

  String get radioSummary => isPt
      ? 'Visibilidade: ${_visibilityLabel(visibility)} | Densidade: ${_densityLabel(density)} | Aprovação: ${approvalMode.trim().isEmpty ? 'não definida' : _reviewFlowLabel(approvalMode)} | Filtro opcional: ${optionalFilter == null ? 'limpo' : _optionalFilterLabel(optionalFilter!)}'
      : 'Visibility: ${_visibilityLabel(visibility)} | Density: ${_densityLabel(density)} | Approval: ${approvalMode.trim().isEmpty ? 'not set' : _reviewFlowLabel(approvalMode)} | Optional filter: ${optionalFilter == null ? 'cleared' : _optionalFilterLabel(optionalFilter!)}';

  String get toggleSummary => isPt
      ? 'Digest: ${nightlyDigest ? 'ativo' : 'inativo'} | Onboarding: ${_onboardingStateLabel(onboardingState)} | Incidente: ${_incidentLabel(incidentEscalation)}'
      : 'Digest: ${nightlyDigest ? 'enabled' : 'disabled'} | Onboarding: ${_onboardingStateLabel(onboardingState)} | Incident: ${_incidentLabel(incidentEscalation)}';

  String _visibilityLabel(String value) {
    switch (value) {
      case 'team':
        return teamLabel;
      case 'customers':
        return customersLabel;
      case 'public':
        return publicLabel;
      default:
        return value;
    }
  }

  String _densityLabel(String value) {
    switch (value) {
      case 'compact':
        return compactLabel;
      case 'comfortable':
        return comfortableLabel;
      case 'spacious':
        return spaciousLabel;
      default:
        return value;
    }
  }

  String _reviewFlowLabel(String value) {
    switch (value) {
      case 'manual':
        return manualLabel;
      case 'assisted':
        return assistedLabel;
      case 'automatic':
        return automaticLabel;
      default:
        return value;
    }
  }

  String _optionalFilterLabel(String value) {
    switch (value) {
      case 'active':
        return activeLabel;
      case 'pending':
        return pendingLabel;
      default:
        return value;
    }
  }

  String _onboardingStateLabel(String value) {
    switch (value) {
      case 'enabled':
        return isPt ? 'habilitado' : 'enabled';
      case 'paused':
        return isPt ? 'pausado' : 'paused';
      default:
        return value;
    }
  }

  String _incidentLabel(String value) {
    switch (value) {
      case 'sms':
        return 'SMS';
      case 'email':
        return emailLabel;
      default:
        return value;
    }
  }
}
