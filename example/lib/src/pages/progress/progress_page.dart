import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'progress-page',
  templateUrl: 'progress_page.html',
  styleUrls: ['progress_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiProgressComponent,
    LiProgressBarComponent,
  ],
)
class ProgressPageComponent {
  ProgressPageComponent(this.i18n);

  static const String apiSnippet = '''
<li-progress [height]="'1rem'" [striped]="true" [animated]="true">
  <li-progress-bar class="bg-success" [value]="42" label="Produto"></li-progress-bar>
  <li-progress-bar class="bg-info" [value]="28" label="UX"></li-progress-bar>
</li-progress>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  String get descriptionBody => _isPt
      ? 'O componente de progresso cobre indicadores lineares simples, barras empilhadas e intervalos customizados para dashboards operacionais.'
      : 'The progress component covers simple linear indicators, stacked bars, and custom ranges for operational dashboards.';

  List<String> get features => _isPt
      ? const <String>[
          'Altura configurável e cantos arredondados.',
          'Faixas com stripes, animação e labels.',
          'Escalas customizadas com min e max.',
        ]
      : const <String>[
          'Configurable height and rounded corners.',
          'Segments with stripes, animation, and labels.',
          'Custom scales with min and max.',
        ];

  List<String> get limits => _isPt
      ? const <String>[
          'O componente não calcula progresso automaticamente.',
          'Escalas muito complexas exigem legenda adicional.',
          'Barras empilhadas pedem curadoria de contraste.',
        ]
      : const <String>[
          'The component does not calculate progress automatically.',
          'Very complex scales require an additional legend.',
          'Stacked bars need contrast curation.',
        ];

  String get uxLabel => 'UX';
  String get qaLabel => 'QA';
  String get customRangeLabel => _isPt ? '120 de 200' : '120 of 200';

  String get apiIntro => _isPt
      ? 'Use o container li-progress para definir contexto visual e os filhos li-progress-bar para cada faixa de progresso.'
      : 'Use the li-progress container to define the visual context and li-progress-bar children for each progress segment.';

  List<String> get apiItems => _isPt
      ? const <String>[
          '[height] controla a espessura da barra.',
          '[rounded], [striped] e [animated] ajustam a aparência.',
          '[min] e [max] permitem escalas além de 0-100.',
          '[value], label e [showValueLabel] controlam o conteúdo de cada faixa.',
        ]
      : const <String>[
          '[height] controls the bar thickness.',
          '[rounded], [striped], and [animated] adjust the appearance.',
          '[min] and [max] allow scales beyond 0-100.',
          '[value], label, and [showValueLabel] control the content of each segment.',
        ];
}
