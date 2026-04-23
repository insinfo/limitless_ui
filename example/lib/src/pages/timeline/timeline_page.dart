import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'timeline-page',
  templateUrl: 'timeline_page.html',
  styleUrls: ['timeline_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    liTimelineDirectives,
  ],
)
class TimelinePageComponent {
  TimelinePageComponent(this.i18n);

  final DemoI18nService i18n;

  bool get _isPt => i18n.isPortuguese;
  Messages get t => i18n.t;

  static const String leftSnippet = '''
<li-timeline mode="left">
  <li-timeline-date>Hoje</li-timeline-date>

  <li-timeline-item
      timeLabel="08:30"
      title="Kickoff"
      subtitle="Squad de produto"
      description="Alinhamento inicial do dia com prioridades e dependencias."
      iconClass="ph ph-rocket-launch">
  </li-timeline-item>

  <li-timeline-item>
    <span liTimelineTime>10:10</span>
    <div liTimelineIcon class="bg-primary text-white rounded-pill d-inline-flex align-items-center justify-content-center" style="width:2rem;height:2rem;">
      <i class="ph ph-chat-centered-dots"></i>
    </div>
    <div liTimelineContent class="card mb-0">
      <div class="card-body">
        Conteudo totalmente projetado dentro do item.
      </div>
    </div>
  </li-timeline-item>
</li-timeline>''';

  static const String centerSnippet = '''
<li-timeline mode="center">
  <li-timeline-date>Release</li-timeline-date>

  <li-timeline-item alignment="start" title="Build verde" iconText="CI"></li-timeline-item>
  <li-timeline-item alignment="end" title="QA aprovado" iconClass="ph ph-check-circle"></li-timeline-item>
  <li-timeline-item alignment="full" [card]="false" title="Deploy em producao" description="Entrada de changelog, smoke test e anuncio interno."></li-timeline-item>
</li-timeline>''';

  String get pageTitle => _isPt ? 'Components' : 'Components';
  String get pageSubtitle => 'Timeline';
  String get breadcrumb => 'Timeline';
  String get introTitle => _isPt
      ? 'Timeline nativo, flexivel e alinhado ao Limitless'
      : 'Native, flexible timeline aligned with Limitless';
  String get introBody => _isPt
      ? 'O componente reaproveita a estrutura visual `.timeline-*` do tema e expoe composicao por projecao de conteudo para icone, horario e corpo do item. Isso cobre os layouts left, right e center sem prender a API a um unico tipo de card.'
      : 'The component reuses the theme `.timeline-*` visual structure and exposes composition through content projection for icon, time, and body. That covers left, right, and center layouts without locking the API to a single card shape.';
  String get leftTitle => _isPt ? 'Variante left' : 'Left variant';
  String get leftBody => _isPt
      ? 'Equivalente ao timeline alinhado a esquerda do Limitless. Bom para feeds cronologicos e historicos lineares.'
      : 'Equivalent to the left-aligned Limitless timeline. Useful for chronological feeds and linear histories.';
  String get rightTitle => _isPt ? 'Variante right' : 'Right variant';
  String get rightBody => _isPt
      ? 'Usa a mesma base estrutural, mas desloca a coluna de conteudo para a direita com `mode="right"`.'
      : 'Uses the same structural base, but shifts the content column to the right with `mode="right"`.';
  String get centerTitle => _isPt ? 'Variante center' : 'Center variant';
  String get centerBody => _isPt
      ? 'No modo central, cada item pode escolher `alignment="start"`, `alignment="end"` ou `alignment="full"`.'
      : 'In center mode, each item can choose `alignment="start"`, `alignment="end"`, or `alignment="full"`.';
  String get compositionTitle =>
      _isPt ? 'Composicao por projecao' : 'Projection-based composition';
  String get compositionBody => _isPt
      ? 'Quando os inputs padrao nao bastam, use `[liTimelineIcon]`, `[liTimelineTime]` e `[liTimelineContent]` para assumir o markup interno do item.'
      : 'When the default inputs are not enough, use `[liTimelineIcon]`, `[liTimelineTime]`, and `[liTimelineContent]` to control the item internals.';
  String get apiIntro => _isPt
      ? 'A API foi mantida enxuta: um container com `mode` para o layout geral e itens com fallback declarativo ou conteudo projetado.'
      : 'The API stays compact: a container with `mode` for overall layout and items with either declarative fallbacks or projected content.';
  String get apiTitle => _isPt ? 'Entradas principais' : 'Main inputs';
  String get notesTitle => _isPt ? 'Notas' : 'Notes';
}
