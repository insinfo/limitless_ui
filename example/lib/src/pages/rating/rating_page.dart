import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'rating-page',
  templateUrl: 'rating_page.html',
  styleUrls: ['rating_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiHighlightComponent,
    LiRatingComponent,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class RatingPageComponent {
  RatingPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  static const String interactiveSnippet = '''
<li-rating
    [(ngModel)]="productRating"
    (hover)="hoverPreview = \$event"
    (leave)="hoverPreview = 0">
</li-rating>''';

  static const String readonlySnippet = '''
<li-rating
    [rate]="readonlyRating"
    [readonly]="true">
</li-rating>

<li-rating
    [rate]="disabledRating"
    [disabled]="true">
</li-rating>''';

  num productRating = 4;
  num serviceRating = 2;
  num readonlyRating = 3.5;
  num disabledRating = 4;
  num hoverPreview = 0;

  String get pageTitle => _isPt ? 'Forms' : 'Forms';
  String get pageSubtitle => 'Rating';
  String get breadcrumb => _isPt ? 'Classificação por estrelas' : 'Star rating';
  String get introTitle => _isPt
      ? 'Avaliação com ngModel e estados do componente'
      : 'Rating with ngModel and component states';
  String get introBody => _isPt
      ? 'O li-rating cobre seleção por clique, navegação por teclado, preview em hover, leitura parcial e modo resetável.'
      : 'li-rating covers click selection, keyboard navigation, hover preview, partial reading, and resettable mode.';
  String get apiIntro => _isPt
      ? 'A API é curta: o valor pode ser ligado em `[(ngModel)]` ou em `[rate]`, com flags para readonly, disabled, resettable e tamanho.'
      : 'The API is short: the value can be bound through `[(ngModel)]` or `[rate]`, with flags for readonly, disabled, resettable, and size.';
  String get mainInputsTitle => _isPt ? 'Entradas principais' : 'Main inputs';
  String get interactiveSnippetTitle =>
      _isPt ? 'Interativo com hover' : 'Interactive with hover';
  String get readonlySnippetTitle =>
      _isPt ? 'Readonly e disabled' : 'Readonly and disabled';
  String get interactiveTitle => _isPt ? 'Interativo' : 'Interactive';
  String get productLabel => _isPt ? 'Avaliação do produto' : 'Product rating';
  String get currentValueLabel => _isPt ? 'Valor atual' : 'Current value';
  String get resettableTitle =>
      _isPt ? 'Resetável e tamanhos' : 'Resettable and sizes';
  String get serviceLabel => _isPt ? 'Atendimento' : 'Service';
  String get sizesLabel => _isPt ? 'Tamanhos' : 'Sizes';
  String get serviceValueLabel => _isPt ? 'Atendimento' : 'Service';
  String get resettableHelp => _isPt
      ? 'Clique na estrela atual para zerar quando resettable estiver ativo.'
      : 'Click the current star to reset when resettable is active.';
  String get readonlyTitle =>
      _isPt ? 'Somente leitura e desabilitado' : 'Readonly and disabled';
  String get readonlyLabel =>
      _isPt ? 'Média consolidada' : 'Consolidated average';
  String get readonlyHelp => _isPt
      ? 'Exemplo com preenchimento parcial inicial.'
      : 'Example with an initial partial fill.';
  String get disabledLabel => _isPt ? 'Campo bloqueado' : 'Locked field';
  String get disabledHelp => _isPt
      ? 'Mantém o valor visível, mas sem interação.'
      : 'Keeps the value visible, but without interaction.';

  String get hoverLabel => hoverPreview <= 0
      ? (_isPt ? 'Passe o mouse nas estrelas.' : 'Hover the stars.')
      : (_isPt ? 'Preview: $hoverPreview' : 'Preview: $hoverPreview');
}
