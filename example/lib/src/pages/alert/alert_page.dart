


import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'alert-page',
  templateUrl: 'alert_page.html',
  styleUrls: ['alert_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiAlertComponent,
  ],
)
class AlertPageComponent {
  AlertPageComponent(this.i18n) {
    alertEventLog = i18n.t.pages.alerts.waiting;
  }

  static const String apiSnippetTemplate = '''
<li-alert
  variant="warning"
  [solid]="true"
  iconClass="ph-warning-circle"
  [dismissible]="true">
  <strong>Atenção.</strong> __BODY__
</li-alert>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;
  bool releaseAlertVisible = true;
  String alertEventLog = '';

  String get descriptionBody => _isPt
      ? 'O componente destaca estados rápidos, confirmações e avisos operacionais sem depender de JavaScript externo.'
      : 'The component highlights quick states, confirmations, and operational warnings without depending on external JavaScript.';

  List<String> get features => _isPt
      ? const <String>[
          'Variantes cromáticas e ícones inline ou em bloco.',
          'Modo sólido, pill, borderless e dismissible.',
          'Customização por classes auxiliares.',
        ]
      : const <String>[
          'Color variants and inline or block icons.',
          'Solid, pill, borderless, and dismissible modes.',
          'Customization through helper classes.',
        ];

  List<String> get limits => _isPt
      ? const <String>[
          'Alertas não substituem fluxos de confirmação crítica.',
          'Mensagens longas pedem composição mais estruturada.',
          'Estados simultâneos demais reduzem a hierarquia visual.',
        ]
      : const <String>[
          'Alerts do not replace critical confirmation flows.',
          'Long messages require a more structured composition.',
          'Too many simultaneous states reduce visual hierarchy.',
        ];

  String get apiIntro => _isPt
      ? 'Use alertas para mensagens curtas, estados operacionais e avisos de interface. O componente aceita configuração visual sem precisar de wrappers externos.'
      : 'Use alerts for short messages, operational states, and interface warnings. The component supports visual configuration without external wrappers.';

  List<String> get apiItems => _isPt
      ? const <String>[
          'variant define a paleta do alerta.',
          'iconClass, iconMode e iconPosition controlam a leitura visual.',
          '[solid], [dismissible], [roundedPill] e [borderless] ajustam o acabamento.',
          '(visibleChange) e (dismissed) sincronizam o estado com o componente pai.',
          'alertClass, textClass e iconContainerClass refinam a aparência sem criar nova variante.',
        ]
      : const <String>[
          'variant defines the alert palette.',
          'iconClass, iconMode, and iconPosition control visual reading.',
          '[solid], [dismissible], [roundedPill], and [borderless] adjust the finish.',
          '(visibleChange) and (dismissed) synchronize state with the parent component.',
          'alertClass, textClass, and iconContainerClass refine the appearance without creating a new variant.',
        ];

  String get apiSnippetBody => _isPt ? 'Revise a operação.' : 'Review the operation.';

  String get apiSnippet => apiSnippetTemplate.replaceFirst('__BODY__', apiSnippetBody);

  void restoreReleaseAlert() {
    releaseAlertVisible = true;
    alertEventLog = i18n.t.pages.alerts.restored;
  }

  void dismissReleaseAlert() {
    releaseAlertVisible = false;
    alertEventLog = i18n.t.pages.alerts.dismissed;
  }

  void handleVisibilityChange(bool visible) {
    alertEventLog = visible
        ? i18n.t.pages.alerts.visible
        : i18n.t.pages.alerts.hidden;
  }
}
