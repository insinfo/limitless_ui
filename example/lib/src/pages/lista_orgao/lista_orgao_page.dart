import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

import 'orgao_legado.dart';

/// Como a tela reflete a mutação feita na instância do item.
enum OrgaoRefreshMode {
  /// `datatable.refresh()` — reconstrói as linhas a partir do `DataFrame` que o
  /// componente já tem, preservando seleção e expansão. O redesenho é
  /// agendado para o próximo animation frame.
  refresh,

  /// `datatable.refresh(immediate: true)` — mesma reconstrução, porém síncrona:
  /// ao retornar da chamada o DOM já está atualizado, sem esperar o frame.
  refreshImmediate,

  /// `datatable.data = orgaos` — além de reconstruir, troca o `DataFrame` do
  /// componente pelo da página.
  reassignData,

  /// `listar()` — vai ao "backend" de novo e substitui o `DataFrame` inteiro.
  reload,

  /// Nada: mostra a tela desatualizada em relação ao modelo.
  none,
}

/// Réplica de uma tela real de listagem (cabeçalho com ações, filtro próprio,
/// datatable paginada pelo servidor) usada para demonstrar quando `refresh()`
/// é necessário.
///
/// A coluna "Habilitar/Desabilitar" é um botão construído em Dart com
/// `customRenderHtml` e listener nativo (`onClick.listen`), fora dos bindings
/// do Angular — o caso em que a mutação da instância não invalida binding
/// nenhum e a tela só acompanha o modelo depois de um redesenho explícito.
@Component(
  selector: 'lista-orgao-page',
  templateUrl: 'lista_orgao_page.html',
  directives: [
    coreDirectives,
    formDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiDataTableComponent,
  ],
)
class ListaOrgaoPageComponent implements OnInit {
  ListaOrgaoPageComponent(this.i18n, this.hostElement, this._changeDetectorRef);

  final DemoI18nService i18n;
  final html.Element hostElement;
  final ChangeDetectorRef _changeDetectorRef;
  final OrgaoDemoService _orgaoService = OrgaoDemoService();

  @ViewChild('datatable')
  LiDataTableComponent? datatable;

  late DatatableSettings dtConfig;

  DataFrame<OrgaoLegado> orgaos = DataFrame(items: [], totalRecords: 0);

  final ListaOrgaoFilters filtros = ListaOrgaoFilters(limit: 8, offset: 0);

  final List<DatatableSearchField> searchInFields = <DatatableSearchField>[
    DatatableSearchField(
      label: 'Nome',
      field: OrgaoLegado.nomeCol,
      operator: 'ilike',
      selected: true,
    ),
    DatatableSearchField(
      label: 'Sigla',
      field: OrgaoLegado.siglaCol,
      operator: 'ilike',
    ),
  ];

  OrgaoRefreshMode refreshMode = OrgaoRefreshMode.refreshImmediate;
  String eventLog = '';
  bool isAdmin = true;

  @override
  void ngOnInit() {
    dtConfig = DatatableSettings(
      colsDefinitions: [
        DatatableCol(
          key: OrgaoLegado.codigoOrgaoCol,
          title: 'Código',
          enableSorting: true,
          sortingBy: OrgaoLegado.codigoOrgaoCol,
          width: '110px',
          hideOnMobile: true,
        ),
        DatatableCol(
          key: OrgaoLegado.nomeCol,
          title: 'Nome',
          enableSorting: true,
          sortingBy: OrgaoLegado.nomeCol,
          minWidth: '260px',
        ),
        DatatableCol(
          key: OrgaoLegado.ordemCol,
          title: 'Ordem',
          enableSorting: true,
          sortingBy: OrgaoLegado.ordemCol,
          width: '100px',
          textAlign: 'center',
          titleTextAlign: 'center',
          hideOnMobile: true,
        ),
        DatatableCol(
          key: OrgaoLegado.ativoCol,
          title: 'ativo',
          width: '100px',
          textAlign: 'center',
          titleTextAlign: 'center',
          hideOnMobile: true,
          format: DatatableFormat.bool,
        ),
        DatatableCol(
          key: 'Habilitar/Desabilitar',
          title: 'Habilitar/Desabilitar',
          width: '170px',
          textAlign: 'center',
          titleTextAlign: 'center',
          customRenderHtml: (map, item) {
            final orgao = item as OrgaoLegado;
            final div = html.DivElement();
            final btn = html.ButtonElement()
              ..type = 'button'
              ..title = 'Habilitar ou desabilitar'
              ..classes.addAll([
                'btn',
                'border-transparent',
                orgao.ativo ? 'btn-flat-danger' : 'btn-flat-success',
                'btn-sm',
              ])
              ..text = orgao.ativo ? 'Desabilitar' : 'Habilitar'
              ..onClick.listen((event) {
                // Interrompe o evento rowClick do datatable.
                event.stopPropagation();
                orgao.ativo = !orgao.ativo;
                updateAtivo(orgao);
              });
            div.append(btn);
            return div;
          },
        ),
        DatatableActionColumn(
          key: 'actions',
          title: 'Ações',
          width: '130px',
          containerClass:
              'datatable-action-cell d-inline-flex align-items-center justify-content-center gap-2 w-100',
          actions: <DatatableAction>[
            DatatableAction(
              label: 'Editar',
              iconClass: 'ph ph-pencil-line',
              appearance: DatatableActionAppearance.button,
              size: 'sm',
              responsiveMode:
                  DatatableActionResponsiveMode.desktopTextMobileIcon,
              onTap: (ctx) => onSelectOrgao(ctx.itemInstance as OrgaoLegado),
            ),
          ],
        ),
      ],
      responsiveControlColumnKey: OrgaoLegado.nomeCol,
    );

    listar();
  }

  Future<void> listar() async {
    final loading = LiSimpleLoading();
    try {
      loading.show(target: hostElement);
      // Novo DataFrame, com novas instâncias — como um retorno de API.
      orgaos = await _orgaoService.all(filtros);
    } catch (e, s) {
      LiSimpleDialogComponent.showAlert(
        'Erro ao obter Órgãos.',
        subMessage: '$e $s',
      );
    } finally {
      loading.hide();
      _flushView();
    }
  }

  void onRequestData(Filters dtf) {
    filtros.fillFromFilters(dtf);
    listar();
  }

  /// Muta a instância, persiste no "backend" e então reflete na tela conforme o
  /// [refreshMode] escolhido.
  ///
  /// Repare que `orgaos` e `orgaos.items` continuam os mesmos objetos: nenhum
  /// binding do Angular mudou, então sem um redesenho explícito a célula segue
  /// mostrando o HTML montado no draw anterior.
  Future<void> updateAtivo(OrgaoLegado orgao) async {
    try {
      await _orgaoService.updateAtivo(orgao.id, orgao.ativo);

      switch (refreshMode) {
        case OrgaoRefreshMode.refresh:
          datatable?.refresh();
          _log('${orgao.sigla}.ativo = ${orgao.ativo} → datatable.refresh()');
          break;
        case OrgaoRefreshMode.refreshImmediate:
          datatable?.refresh(immediate: true);
          // As linhas já foram reconstruídas nesta mesma linha de código — sem
          // esperar o próximo animation frame. A escrita no DOM ainda depende
          // do ciclo de detecção de mudanças (o _flushView abaixo).
          _log(
            '${orgao.sigla}.ativo = ${orgao.ativo} → '
            'datatable.refresh(immediate: true) — linha já reconstruída: '
            '${_valorAtivoNaLinhaReconstruida(orgao)}',
          );
          break;
        case OrgaoRefreshMode.reassignData:
          datatable?.data = orgaos;
          _log(
              '${orgao.sigla}.ativo = ${orgao.ativo} → datatable.data = orgaos');
          break;
        case OrgaoRefreshMode.reload:
          await listar();
          _log('${orgao.sigla}.ativo = ${orgao.ativo} → listar() no servidor');
          break;
        case OrgaoRefreshMode.none:
          _log(
            '${orgao.sigla}.ativo = ${orgao.ativo} → nenhum redesenho: '
            'a tela ficou desatualizada em relação ao modelo',
          );
          break;
      }
    } catch (e, s) {
      // A instância já foi mutada pelo botão: sem desfazer, a tela passa a
      // divergir do backend quando a chamada falha.
      orgao.ativo = !orgao.ativo;
      datatable?.refresh();
      LiSimpleDialogComponent.showAlert(
        'Erro ao atualizar Órgão',
        subMessage: '$e $s',
      );
    } finally {
      _flushView();
    }
  }

  void deleteAction() {
    final selecionados =
        datatable?.getAllSelected<OrgaoLegado>() ?? const <OrgaoLegado>[];
    if (selecionados.isEmpty) {
      LiSimpleDialogComponent.showAlert('Selecione um item para exclusão');
      return;
    }

    LiSimpleDialogComponent.showConfirm(
      'Tem certeza que deseja remover o(s) órgão(s)?',
      confirmAction: () async {
        await _orgaoService.deleteAll(selecionados);
        _log('${selecionados.length} órgão(s) removido(s)');
        await listar();
      },
    );
  }

  Future<void> desativarTodos() async {
    LiSimpleDialogComponent.showConfirm(
      'Tem certeza, esta operação não poderá ser desfeita?',
      confirmAction: () async {
        final loading = LiSimpleLoading();
        try {
          loading.show(target: hostElement);
          await _orgaoService.desativarTodos();
          await listar();
          _log('Todos os órgãos foram desativados');
        } catch (e, s) {
          LiSimpleDialogComponent.showAlert(
            'Erro ao desativar todos',
            subMessage: '$e $s',
          );
        } finally {
          loading.hide();
          _flushView();
        }
      },
    );
  }

  void onSelectOrgao(OrgaoLegado orgao) {
    _log('Editar ${orgao.nome} (id ${orgao.id})');
    _flushView();
  }

  void register() {
    _log('Cadastrar novo órgão');
    _flushView();
  }

  void onAtivoFilterChange(String? value) {
    filtros.ativo = value == null || value.isEmpty ? null : value == 'true';
    filtros.offset = 0;
    listar();
  }

  void limparAtivoFilter() {
    filtros.ativo = null;
    filtros.offset = 0;
    listar();
  }

  String get ativoFilterValue {
    final ativo = filtros.ativo;
    return ativo == null ? '' : ativo.toString();
  }

  /// Lê o valor já reconstruído na linha do datatable, logo após um
  /// `refresh(immediate: true)`.
  ///
  /// Serve para evidenciar que a reconstrução foi síncrona: com o `refresh()`
  /// normal, neste ponto a linha ainda seria a do desenho anterior.
  String _valorAtivoNaLinhaReconstruida(OrgaoLegado orgao) {
    final rows = datatable?.rows ?? const <DatatableRow>[];
    for (final row in rows) {
      if (!identical(row.instance, orgao)) {
        continue;
      }
      for (final column in row.columns) {
        if (column.key == OrgaoLegado.ativoCol) {
          return 'ativo = "${column.value}"';
        }
      }
    }
    return 'linha fora da página atual';
  }

  /// Redesenha sob demanda, sem alterar nada no modelo.
  ///
  /// Serve para sair de um estado desatualizado depois de alternar itens com o
  /// modo `nenhum`.
  void aplicarRefresh() {
    final immediate = refreshMode == OrgaoRefreshMode.refreshImmediate;
    datatable?.refresh(immediate: immediate);
    _log(
      immediate
          ? 'datatable.refresh(immediate: true) aplicado manualmente'
          : 'datatable.refresh() aplicado manualmente',
    );
    _flushView();
  }

  void changeRefreshMode(String? value) {
    refreshMode = OrgaoRefreshMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => OrgaoRefreshMode.refreshImmediate,
    );
    _flushView();
  }

  String get refreshModeName => refreshMode.name;

  /// Estado das instâncias que a página tem em mãos, para comparar com o que
  /// está desenhado na tabela.
  String get modelStateLog {
    if (orgaos.items.isEmpty) {
      return 'Modelo: (vazio)';
    }
    final estado =
        orgaos.items.map((orgao) => '${orgao.sigla}=${orgao.ativo}').join(', ');
    return 'Modelo: $estado';
  }

  void _log(String message) {
    eventLog = message;
  }

  // ignore: deprecated_member_use
  void _flushView() => _changeDetectorRef.detectChanges();

  String get pageTitle => i18n.isPortuguese ? 'Lista' : 'List';

  String get pageSubtitle => i18n.isPortuguese ? 'Órgãos' : 'Departments';

  String get breadcrumbLabel =>
      i18n.isPortuguese ? 'Lista de Órgãos' : 'Department list';

  String get demoIntro => i18n.isPortuguese
      ? 'Réplica de uma tela de listagem real: cabeçalho com ações, filtro próprio e datatable paginada pelo servidor. A coluna "Habilitar/Desabilitar" é um botão criado em customRenderHtml com listener nativo que altera orgao.ativo na instância — troque o modo abaixo para comparar como cada estratégia reflete (ou não) a mudança na tela.'
      : 'A replica of a real list screen: header actions, a custom filter, and a server-paginated datatable. The "Habilitar/Desabilitar" column is a button built in customRenderHtml with a native listener that flips orgao.ativo on the instance — switch the mode below to compare how each strategy does (or does not) show up on screen.';

  final String pageSnippet = '''DatatableCol(
  key: 'Habilitar/Desabilitar',
  title: 'Habilitar/Desabilitar',
  customRenderHtml: (map, item) {
    final orgao = item as OrgaoLegado;
    final div = html.DivElement();
    final btn = html.ButtonElement()
      ..type = 'button'
      ..classes.addAll([
        'btn', 'border-transparent', 'btn-sm',
        orgao.ativo ? 'btn-flat-danger' : 'btn-flat-success',
      ])
      ..text = orgao.ativo ? 'Desabilitar' : 'Habilitar'
      ..onClick.listen((event) {
        // interrompe o evento rowClick do DataTable
        event.stopPropagation();
        orgao.ativo = !orgao.ativo;
        updateAtivo(orgao);
      });
    div.append(btn);
    return div;
  },
),

Future<void> updateAtivo(OrgaoLegado orgao) async {
  try {
    await _orgaoService.updateAtivo(orgao.id, orgao.ativo);

    // `orgaos` e `orgaos.items` continuam os mesmos objetos: nenhum binding
    // do Angular mudou. refresh() reconstrói as linhas a partir deles e
    // preserva a seleção dos checkboxes.
    datatable?.refresh();
  } catch (e, s) {
    // O botão já mutou a instância: sem desfazer, a tela diverge do backend.
    orgao.ativo = !orgao.ativo;
    datatable?.refresh();
    LiSimpleDialogComponent.showAlert('Erro ao atualizar Órgão',
        subMessage: '\$e \$s');
  }
}''';
}
