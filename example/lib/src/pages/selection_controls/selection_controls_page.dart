import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'selection-controls-page',
  templateUrl: 'selection_controls_page.html',
  styleUrls: ['selection_controls_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiCheckboxComponent,
    LiRadioComponent,
    LiToggleComponent,
  ],
)
class SelectionControlsPageComponent {
  bool auditTrailEnabled = true;
  bool publicPortalEnabled = false;
  bool reviewQueueEnabled = true;
  bool smsChannelEnabled = true;
  bool emailChannelEnabled = false;
  bool pushChannelEnabled = true;
  bool reverseAuditEnabled = true;
  bool reverseClientFeedEnabled = false;
  bool reverseSlaAlertsEnabled = false;
  bool secondaryChecksEnabled = true;
  bool dangerChecksEnabled = false;
  bool successChecksEnabled = true;
  bool inversePinEnabled = true;
  bool inverseReadonlyEnabled = false;

  String visibility = 'team';
  String density = 'comfortable';
  String reviewFlow = 'manual';
  String contextualTone = 'secondary';
  String inverseFilter = 'internal';
  String? optionalFilter = 'active';

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

  String get checkboxSummary {
    final enabled = <String>[];
    if (auditTrailEnabled) {
      enabled.add('Auditoria');
    }
    if (publicPortalEnabled) {
      enabled.add('Portal publico');
    }
    if (reviewQueueEnabled) {
      enabled.add('Fila de revisao');
    }
    return enabled.isEmpty ? 'Nenhum recurso ativo.' : enabled.join(', ');
  }

  String get checkboxChannelSummary {
    final enabled = <String>[];
    if (smsChannelEnabled) {
      enabled.add('SMS');
    }
    if (emailChannelEnabled) {
      enabled.add('E-mail');
    }
    if (pushChannelEnabled) {
      enabled.add('Push');
    }
    return enabled.isEmpty ? 'Nenhum canal inline ativo.' : enabled.join(', ');
  }

  String get radioSummary => 'Visibilidade: ${_visibilityLabel(visibility)} | '
      'Densidade: ${_densityLabel(density)} | '
      'Fluxo: ${_reviewFlowLabel(reviewFlow)} | '
      'Filtro opcional: ${optionalFilter ?? 'limpo'}';

  String get toggleSummary =>
      'Digest: ${nightlyDigest ? 'ativo' : 'inativo'} | '
      'Onboarding: $onboardingState | '
      'Incidente: $incidentEscalation';

  String _visibilityLabel(String value) {
    switch (value) {
      case 'team':
        return 'Equipe interna';
      case 'customers':
        return 'Clientes';
      case 'public':
        return 'Público';
      default:
        return value;
    }
  }

  String _densityLabel(String value) {
    switch (value) {
      case 'compact':
        return 'Compacto';
      case 'comfortable':
        return 'Confortável';
      case 'spacious':
        return 'Espaçado';
      default:
        return value;
    }
  }

  String _reviewFlowLabel(String value) {
    switch (value) {
      case 'manual':
        return 'Manual';
      case 'assisted':
        return 'Assistido';
      case 'automatic':
        return 'Automático';
      default:
        return value;
    }
  }
}
