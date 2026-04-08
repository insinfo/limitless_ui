import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'carousel-page',
  templateUrl: 'carousel_page.html',
  styleUrls: ['carousel_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiCarouselComponent,
    LiCarouselCaptionComponent,
    LiCarouselItemComponent,
  ],
)
class CarouselPageComponent {
  CarouselPageComponent(this.i18n);

  static const String standardSnippet = '''
<li-carousel
    [showIndicators]="true"
    [showControls]="true"
    [autoPlay]="true"
    [intervalMs]="4500">
  <li-carousel-item indicatorLabel="Slide 1">
    <img src="assets/images/carousel/slide-01.jpg" class="d-block w-100">
  </li-carousel-item>
</li-carousel>''';

  static const String gridSnippet = '''
<li-carousel
    [gridMode]="true"
    [showIndicators]="true"
    [showControls]="true">
  <li-carousel-item indicatorLabel="Grupo 1">
    <div class="row">...</div>
  </li-carousel-item>
</li-carousel>''';

  static const String transitionSnippet = '''
<li-carousel
    transition="zoom"
    [showIndicators]="true"
    [showControls]="true"
    [autoPlay]="false">
</li-carousel>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  String get overviewIntro => _isPt
      ? 'A página do carousel reúne modos padrão, grid e transições adicionais, mantendo a mesma API do componente base.'
      : 'The carousel page brings together default mode, grid mode, and additional transitions while keeping the same base component API.';
  String get apiIntro => _isPt
      ? 'A API principal combina itens projetados, controles, indicadores, autoplay, grid mode e transições nomeadas.'
      : 'The main API combines projected items, controls, indicators, autoplay, grid mode, and named transitions.';
  String get mainInputsTitle => _isPt ? 'Pontos principais' : 'Main points';
  String get standardSnippetTitle => _isPt ? 'Uso padrão' : 'Standard usage';
  String get gridSnippetTitle => _isPt ? 'Modo grid' : 'Grid mode';
  String get transitionSnippetTitle => _isPt ? 'Transições' : 'Transitions';
}
