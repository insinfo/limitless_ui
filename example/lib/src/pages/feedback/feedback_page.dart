import 'package:limitless_ui_example/limitless_ui_example.dart';
@Component(
  selector: 'feedback-page',
  templateUrl: 'feedback_page.html',
  styleUrls: ['feedback_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiAlertComponent,
    LiProgressComponent,
    LiProgressBarComponent,
  ],
)
class FeedbackPageComponent {
  FeedbackPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  bool releaseAlertVisible = true;

  String get pageTitle => _isPt ? 'Components' : 'Components';
  String get pageSubtitle => 'Feedback';
  String get breadcrumb => 'Feedback';
  String get overviewIntro => _isPt
      ? 'A página combina alertas e barras de progresso para demonstrar padrões de feedback transacional e contínuo em uma interface administrativa.'
      : 'This page combines alerts and progress bars to demonstrate transactional and continuous feedback patterns in an administrative interface.';
  String get descriptionBody => _isPt
      ? 'A tela reúne componentes úteis para mensagens imediatas, estados de atenção, acompanhamento de progresso e comunicação de status.'
      : 'The screen brings together useful components for immediate messages, attention states, progress tracking, and status communication.';
  List<String> get features => _isPt
      ? const <String>[
          'Alertas com variantes, ícones, preenchimento sólido e dismiss.',
          'Barras de progresso simples e empilhadas.',
          'Composição adequada para feedback transacional e operacional.',
        ]
      : const <String>[
          'Alerts with variants, icons, solid fill, and dismiss.',
          'Simple and stacked progress bars.',
          'A composition suited for transactional and operational feedback.',
        ];
  List<String> get limits => _isPt
      ? const <String>[
          'Alertas não substituem fluxo de confirmação crítica.',
          'Progress não faz polling ou sincronização automática.',
          'Estados muito densos pedem hierarquia visual no componente pai.',
        ]
      : const <String>[
          'Alerts do not replace critical confirmation flows.',
          'Progress does not perform polling or automatic synchronization.',
          'Very dense states require visual hierarchy in the parent component.',
        ];
  String get alertExamplesIntro => _isPt
      ? 'Exemplos reais com variant, solid, dismissible, iconMode e iconPosition.'
      : 'Real examples with variant, solid, dismissible, iconMode, and iconPosition.';
  String get alertReleaseBody => _isPt
      ? 'O pacote já está pronto para ser validado no navegador.'
      : 'The package is already ready to be validated in the browser.';
  String get alertSolidBody => _isPt
      ? 'Use solid=true quando quiser mais contraste em avisos importantes.'
      : 'Use solid=true when you want more contrast in important warnings.';
  String get borderlessBody => _isPt
      ? 'Borderless, roundedPill e alertClass permitem compor estilos mais específicos sem criar variantes novas.'
      : 'Borderless, roundedPill, and alertClass let you compose more specific styles without creating new variants.';
  String get alertApiTitle => _isPt ? 'Como utilizar alerts' : 'How to use alerts';
  String get progressApiTitle => _isPt ? 'Como utilizar progress' : 'How to use progress';
  List<String> get alertApiItems => _isPt
      ? const <String>[
          'variant define a cor sem criar classes manuais.',
          '[solid] aumenta contraste em avisos importantes.',
          '[dismissible] e [visible] permitem ciclo controlado pelo componente pai.',
          'iconClass, iconMode e iconPosition ajustam a leitura visual.',
          '[borderless], [roundedPill] e alertClass refinam o acabamento.',
        ]
      : const <String>[
          'variant defines the color without creating manual classes.',
          '[solid] increases contrast for important warnings.',
          '[dismissible] and [visible] allow a cycle controlled by the parent component.',
          'iconClass, iconMode, and iconPosition adjust visual reading.',
          '[borderless], [roundedPill], and alertClass refine the finish.',
        ];
  List<String> get progressApiItems => _isPt
      ? const <String>[
          '[height] controla a espessura da barra.',
          '[rounded], [striped] e [animated] ajustam o tratamento visual.',
          'li-progress-bar recebe [value], label e [showValueLabel].',
          'Barras empilhadas são úteis para composição de capacidade por grupo.',
        ]
      : const <String>[
          '[height] controls the bar thickness.',
          '[rounded], [striped], and [animated] adjust the visual treatment.',
          'li-progress-bar receives [value], label, and [showValueLabel].',
          'Stacked bars are useful for composing capacity by group.',
        ];

  void restoreReleaseAlert() {
    releaseAlertVisible = true;
  }

  void dismissReleaseAlert() {
    releaseAlertVisible = false;
  }
}
