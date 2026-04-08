import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'page-header-page',
  templateUrl: 'page_header_page.html',
  styleUrls: ['page_header_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiPageHeaderComponent,
    LiPageHeaderBreadcrumbItemDirective,
    LiPageHeaderBottomDirective,
    LiPageHeaderActionsDirective,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class PageHeaderPageComponent {
  PageHeaderPageComponent(this.i18n);

  static const String basicSnippet = '''
<li-pg-header titlePrefix="Protocolo" title="Incluir Processo">
  <li-pg-crumb-item label="Protocolo"></li-pg-crumb-item>
  <li-pg-crumb-item label="Incluir Processo" [active]="true"></li-pg-crumb-item>

  <div liPgHeaderActions>
    <button type="button" class="btn btn-primary">Salvar</button>
  </div>
</li-pg-header>''';

  static const String customBottomSnippet = '''
<li-pg-header title="Visualiza Processo">
  <div liPgHeaderBottom class="w-100">
    <ul class="nav nav-tabs nav-tabs-underline mb-0">
      <li class="nav-item"><a class="nav-link active">Visão Geral</a></li>
      <li class="nav-item"><a class="nav-link">Trâmites</a></li>
    </ul>
  </div>
</li-pg-header>''';

  static const String migrationSnippet = '''
<li-pg-header titlePrefix="Protocolo" title="Incluir Processo">
  <li-pg-crumb-item label="Protocolo"></li-pg-crumb-item>
  <li-pg-crumb-item label="Incluir Processo" [active]="true"></li-pg-crumb-item>

  <div liPgHeaderActions class="collapse d-lg-block ms-lg-auto">
    <acao-favorita-comp></acao-favorita-comp>
  </div>
</li-pg-header>''';

  final DemoI18nService i18n;

  bool get isPt => i18n.isPortuguese;

  String get pageTitle => isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'Page Header';
  String get breadcrumb => isPt
      ? 'Cabeçalho reutilizável com breadcrumb, ações e faixa inferior customizada'
      : 'Reusable page header with breadcrumb, actions, and custom bottom row';
  String get overviewIntro => isPt
      ? 'LiPageHeaderComponent encapsula o padrão visual usado em telas administrativas: título, breadcrumb, ações à direita e, quando necessário, uma segunda faixa projetada para abas ou ferramentas.'
      : 'LiPageHeaderComponent encapsulates the visual pattern used in admin screens: title, breadcrumb, right-side actions, and, when needed, a projected second row for tabs or tools.';
  String get descriptionTitle => isPt ? 'Quando usar' : 'When to use';
  String get descriptionBody => isPt
      ? 'Use quando a página precisar manter consistência entre título, navegação contextual e ações globais.'
      : 'Use it when the page needs consistent title, contextual navigation, and global actions.';
  String get featuresTitle => isPt ? 'O que a API cobre' : 'What the API covers';
  String get featureOne => isPt
      ? 'Breadcrumb automático por lista de itens ou por projeção de `li-pg-crumb-item`.'
      : 'Automatic breadcrumb from a list of items or projected `li-pg-crumb-item`.';
  String get featureTwo => isPt
      ? 'Slot de ações à direita com `[liPgHeaderActions]`.'
      : 'Right-side actions slot with `[liPgHeaderActions]`.';
  String get featureThree => isPt
      ? 'Faixa inferior projetada com `[liPgHeaderBottom]` para tabs ou filtros.'
      : 'Projected bottom row with `[liPgHeaderBottom]` for tabs or filters.';
  String get apiIntro => isPt
      ? 'O formato canônico usa `li-pg-header`, `li-pg-crumb-item`, `[liPgHeaderActions]` e `[liPgHeaderBottom]`.'
      : 'The canonical format uses `li-pg-header`, `li-pg-crumb-item`, `[liPgHeaderActions]`, and `[liPgHeaderBottom]`.';
  String get compatibilityTitle => isPt
      ? 'Compatibilidade com showFavoriteAction'
      : 'showFavoriteAction compatibility';
  String get compatibilityBody => isPt
      ? '`showFavoriteAction` permanece disponível para migração, mas o padrão recomendado no pacote é projetar o conteúdo real em `[liPgHeaderActions]`.'
      : '`showFavoriteAction` remains available for migration, but the recommended package pattern is to project the real content into `[liPgHeaderActions]`.';
}
