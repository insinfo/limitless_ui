import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'slider-page',
  templateUrl: 'slider_page.html',
  styleUrls: ['slider_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiSliderComponent,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class SliderPageComponent {
  SliderPageComponent(this.i18n);

  final DemoI18nService i18n;

  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  static const String singleSnippet = '''
<li-slider
    [(ngModel)]="singleValue"
    [min]="0"
    [max]="100"
    [step]="5">
</li-slider>''';

  static const String rangeSnippet = '''
<li-slider
    connect="range"
    [range]="true"
    [(rangeValues)]="budgetRange"
    [min]="0"
    [max]="100"
    [margin]="10"
    [showTooltip]="true"
    [showPips]="true"
    variant="success"
    handleStyle="solid">
</li-slider>''';

  static const String connectSnippet = '''
<li-slider
    connect="upper"
    [(ngModel)]="connectUpperValue"
    [min]="0"
    [max]="100"
    [step]="5"
    variant="warning">
</li-slider>''';

  static const String customPipsSnippet = '''
<li-slider
    [(ngModel)]="releaseValue"
    [min]="0"
    [max]="100"
    [customPips]="releasePips"
    [showTooltip]="true"
    connect="none">
</li-slider>''';

  num singleValue = 35;
  List<num> budgetRange = <num>[20, 75];
  num verticalValue = 60;
  List<num> compactRange = <num>[2, 8];
  num connectUpperValue = 40;
  num noConnectValue = 55;
  num releaseValue = 50;

  final List<LiSliderPip> releasePips = const <LiSliderPip>[
    LiSliderPip(value: 0, label: 'Backlog', large: true),
    LiSliderPip(value: 25, label: 'Spec'),
    LiSliderPip(value: 50, label: 'Beta', large: true),
    LiSliderPip(value: 75, label: 'QA'),
    LiSliderPip(value: 100, label: 'Release', large: true),
  ];

  String get pageTitle => _isPt ? 'Forms' : 'Forms';
  String get pageSubtitle => 'Slider';
  String get breadcrumb => _isPt ? 'Slider nativo' : 'Native slider';
  String get introTitle => _isPt
      ? 'Slider AngularDart nativo com visual do Limitless'
      : 'Native AngularDart slider with Limitless visuals';
  String get introBody => _isPt
      ? 'O li-slider usa a árvore de classes `noUi-*` e `noui-*` do tema, mas toda a interação é implementada em AngularDart. A API cobre valor simples, intervalo, orientação vertical, variantes de cor, tamanhos, tooltips, connect configurável e pips customizados.'
      : 'li-slider uses the theme `noUi-*` and `noui-*` class tree, while all behavior is implemented in AngularDart. The API covers single value, range mode, vertical orientation, color variants, sizes, tooltips, configurable connect behavior, and custom pips.';
  String get singleTitle => _isPt ? 'Valor simples com ngModel' : 'Single value with ngModel';
  String get singleBody => _isPt
      ? 'Clique na trilha, arraste o handle ou use teclado. O componente também funciona como `ControlValueAccessor`.'
      : 'Click the track, drag the handle, or use the keyboard. The component also works as a `ControlValueAccessor`.';
  String get rangeTitle => _isPt ? 'Intervalo com pips e tooltip' : 'Range mode with pips and tooltip';
  String get rangeBody => _isPt
      ? 'Quando `range` está ativo, o binding principal passa a ser `[(rangeValues)]` com uma lista de 2 números. Com `connect="range"`, a barra preenchida fica entre os handles.'
      : 'When `range` is enabled, the primary binding becomes `[(rangeValues)]` with a 2-item numeric list. With `connect="range"`, the filled bar stays between the handles.';
  String get variantsTitle => _isPt ? 'Variantes e tamanhos' : 'Variants and sizes';
  String get variantsBody => _isPt
      ? 'As cores e estilos reaproveitam diretamente as classes do Limitless: `noui-slider-success`, `noui-slider-warning`, `noui-slider-danger`, `noui-slider-lg`, `noui-slider-sm`, `noui-slider-solid` e `noui-slider-white`.'
      : 'Colors and styles reuse the Limitless classes directly: `noui-slider-success`, `noui-slider-warning`, `noui-slider-danger`, `noui-slider-lg`, `noui-slider-sm`, `noui-slider-solid`, and `noui-slider-white`.';
  String get verticalTitle => _isPt ? 'Orientação vertical' : 'Vertical orientation';
  String get verticalBody => _isPt
      ? 'Use `orientation="vertical"` e ajuste `verticalHeight` para demos ou painéis compactos.'
      : 'Use `orientation="vertical"` and adjust `verticalHeight` for demos or compact panels.';
    String get connectTitle => _isPt ? 'Connect configurável' : 'Configurable connect';
    String get connectBody => _isPt
      ? 'A entrada `connect` aceita `auto`, `lower`, `upper`, `range` e `none`. No modo simples, `auto` se comporta como `lower`. Em intervalo, `auto` vira `range`.'
      : 'The `connect` input accepts `auto`, `lower`, `upper`, `range`, and `none`. In single-value mode, `auto` behaves like `lower`. In range mode, `auto` becomes `range`.';
    String get customPipsTitle => _isPt ? 'Pips customizados' : 'Custom pips';
    String get customPipsBody => _isPt
      ? 'Use `customPips` para definir posições e labels explícitos sem depender de `pipCount`. Isso ajuda em escalas semânticas, marcos de produto e thresholds de negócio.'
      : 'Use `customPips` to define explicit positions and labels without relying on `pipCount`. This helps with semantic scales, product milestones, and business thresholds.';
    String get apiIntro => _isPt
      ? 'A API foi mantida curta, mas agora cobre os cenários mais próximos do noUi original: conectores configuráveis e pips declarativos por valor.'
      : 'The API stays compact, but now covers scenarios closer to the original noUi semantics: configurable connectors and declarative value-based pips.';
    String get mainInputsTitle => _isPt ? 'Entradas principais' : 'Main inputs';
    String get notesTitle => _isPt ? 'Observações' : 'Notes';
  String get currentValueLabel => _isPt ? 'Valor atual' : 'Current value';
  String get currentRangeLabel => _isPt ? 'Faixa atual' : 'Current range';
}