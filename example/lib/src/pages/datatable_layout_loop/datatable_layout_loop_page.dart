import 'dart:async';

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

/// Uma linha da lista, com as mesmas colunas da tela do SALI.
///
/// Implementa [SerializeBase] porque é assim que o `li-datatable` lê um item:
/// ou o `DataFrame` já traz `itemsAsMap`, ou o componente chama `toMap()` na
/// instância. Uma classe comum, sem isso, renderiza a linha inteira em branco.
class AcompanhamentoEspecialDemo implements SerializeBase {
  AcompanhamentoEspecialDemo({
    required this.processo,
    required this.ondeEsta,
    required this.grupo,
    required this.ultimoAndamento,
    required this.situacao,
    required this.observacao,
    required this.assunto,
    required this.incluidoPor,
  });

  static const processoCol = 'processo';
  static const ondeEstaCol = 'ondeEsta';
  static const grupoCol = 'grupo';
  static const ultimoAndamentoCol = 'ultimoAndamento';
  static const situacaoCol = 'situacao';
  static const observacaoCol = 'observacao';
  static const assuntoCol = 'assunto';
  static const incluidoPorCol = 'incluidoPor';

  final String processo;
  final String ondeEsta;
  final String grupo;
  final String ultimoAndamento;
  final String situacao;
  final String observacao;
  final String assunto;
  final String incluidoPor;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      processoCol: processo,
      ondeEstaCol: ondeEsta,
      grupoCol: grupo,
      ultimoAndamentoCol: ultimoAndamento,
      situacaoCol: situacao,
      observacaoCol: observacao,
      assuntoCol: assunto,
      incluidoPorCol: incluidoPor,
    };
  }
}

/// Réplica da tela "Protocolo > Acompanhamento Especial" do SALI, montada para
/// reproduzir o loop infinito de layout que ela apresentava com zoom em 110%.
///
/// O ciclo da tela real: as colunas não cabem, o auto-hide esconde uma, a
/// tabela encurta, a barra de rolagem da página some, o container devolve ~16px
/// e tudo cabe de novo — aí a barra volta e o ciclo recomeça, redesenhando a
/// tabela a cada frame. Com zoom em 110% a altura da página caía exatamente em
/// cima desse limiar, e a tela ficava piscando sem parar.
///
/// [simularBarraDeRolagem] reproduz essa realimentação sem depender da altura
/// da janela: enquanto houver coluna escondida o container fica mais largo. O
/// contador de redesenhos ao lado mostra o resultado — hoje ele estabiliza,
/// antes subia para sempre.
@Component(
  selector: 'datatable-layout-loop-page',
  templateUrl: 'datatable_layout_loop_page.html',
  directives: [
    coreDirectives,
    formDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiDataTableComponent,
  ],
)
class DatatableLayoutLoopPageComponent implements OnInit, OnDestroy {
  DatatableLayoutLoopPageComponent(this.i18n, this._changeDetectorRef);

  static const String abaDoSetor = 'SETOR';
  static const String abaPessoal = 'PESSOAL';

  final DemoI18nService i18n;
  final ChangeDetectorRef _changeDetectorRef;

  @ViewChild('datatable')
  LiDataTableComponent? datatable;

  late DatatableSettings colunas;

  DataFrame<AcompanhamentoEspecialDemo> tabela =
      DataFrame<AcompanhamentoEspecialDemo>(
    items: const <AcompanhamentoEspecialDemo>[],
    totalRecords: 0,
  );

  Filters filtros = Filters(limit: 10, offset: 0);

  final List<int> opcoesPorPagina = <int>[10, 25, 50];

  String abaAtual = abaDoSetor;

  /// Se a tabela fica presa a [larguraDoContainer] em vez de usar a largura
  /// toda.
  ///
  /// Desligado por padrão, porque a tela do SALI ocupa a largura inteira —
  /// prender o card num `max-width` descaracterizaria a réplica. Ligue para
  /// colocar a tabela na fresta onde o ciclo se fecha e ver o loop de perto.
  bool limitarLargura = false;

  /// Largura do container quando [limitarLargura] está ligado, em pixels.
  ///
  /// O ciclo só se fecha numa fresta estreita: onde as colunas passam do
  /// espaço por menos do que a barra de rolagem ocupa, de modo que esconder
  /// uma devolve espaço suficiente para todas voltarem. Mais estreito que
  /// isso elas não cabem nos dois estados; mais largo, cabem nos dois — e o
  /// layout converge sozinho. Foi nessa fresta que o zoom de 110% colocou a
  /// tela do SALI.
  ///
  /// Onde ela fica depende do texto que cada coluna carrega, não só das
  /// larguras declaradas, então o valor é calibrado medindo no navegador e não
  /// dá para deduzir da configuração.
  int larguraDoContainer = 1050;

  /// Liga a realimentação que fecha o ciclo: esconder coluna alarga o container.
  ///
  /// A largura muda só no container -- a janela não muda de tamanho e nenhum
  /// `resize` é disparado. Quem percebe é o `ResizeObserver` do datatable.
  bool simularBarraDeRolagem = true;

  /// Quanto o container ganha quando a barra de rolagem da página some.
  int larguraDaBarraDeRolagem = 16;

  int redesenhos = 0;
  int redesenhosNoUltimoSegundo = 0;
  int mudancasDeAutoHide = 0;
  bool guardaDeReflowDisparou = false;
  List<String> colunasEscondidas = const <String>[];

  bool _colunasEscondidasAgora = false;
  int _redesenhosNaAmostraAnterior = 0;
  Timer? _amostragem;

  final List<AcompanhamentoEspecialDemo> _todos = _seed();

  bool get ehAbaDoSetor => abaAtual == abaDoSetor;

  bool get ehAbaPessoal => abaAtual == abaPessoal;

  /// Largura efetiva: a barra de rolagem só ocupa espaço enquanto a tabela está
  /// comprida, ou seja, enquanto nenhuma coluna foi escondida.
  int get larguraEfetiva {
    if (!simularBarraDeRolagem || !_colunasEscondidasAgora) {
      return larguraDoContainer;
    }

    return larguraDoContainer + larguraDaBarraDeRolagem;
  }

  /// Sem `max-width` a tabela ocupa a largura toda, como no SALI.
  String get estiloDoContainer =>
      limitarLargura ? 'max-width: ${larguraEfetiva}px;' : '';

  bool get pareceEmLoop => redesenhosNoUltimoSegundo > 10;

  String get resumoDoEstado {
    if (pareceEmLoop) {
      return 'A tabela está redesenhando sem parar — é o bug.';
    }

    if (guardaDeReflowDisparou) {
      return 'O guarda de reflow cortou a corrente de redesenhos.';
    }

    return 'Layout estável.';
  }

  String get classeDoResumo {
    if (pareceEmLoop) {
      return 'alert alert-danger mb-0';
    }

    if (guardaDeReflowDisparou) {
      return 'alert alert-warning mb-0';
    }

    return 'alert alert-success mb-0';
  }

  String get colunasEscondidasLabel =>
      colunasEscondidas.isEmpty ? 'nenhuma' : colunasEscondidas.join(', ');

  @override
  void ngOnInit() {
    colunas = _montarColunas();
    _paginar(filtros);

    _amostragem = Timer.periodic(const Duration(seconds: 1), (_) {
      redesenhosNoUltimoSegundo = redesenhos - _redesenhosNaAmostraAnterior;
      _redesenhosNaAmostraAnterior = redesenhos;
      _changeDetectorRef.markForCheck();
    });
  }

  @override
  void ngOnDestroy() {
    _amostragem?.cancel();
    _amostragem = null;
  }

  void abrirAba(String aba) {
    if (abaAtual == aba) {
      return;
    }

    abaAtual = aba;
    filtros = Filters(limit: filtros.limit, offset: 0);
    zerarContadores();
    _paginar(filtros);
  }

  void paginar(Filters novosFiltros) {
    filtros = novosFiltros;
    _paginar(novosFiltros);
  }

  void mudarLargura(String valor) {
    final largura = int.tryParse(valor.trim());
    if (largura == null || largura < 240 || largura > 1600) {
      return;
    }

    larguraDoContainer = largura;
    zerarContadores();
  }

  void mudarSimulacao(bool ligada) {
    simularBarraDeRolagem = ligada;
    zerarContadores();
  }

  void mudarLimiteDeLargura(bool ligado) {
    limitarLargura = ligado;
    zerarContadores();
  }

  void zerarContadores() {
    redesenhos = 0;
    redesenhosNoUltimoSegundo = 0;
    mudancasDeAutoHide = 0;
    _redesenhosNaAmostraAnterior = 0;
    guardaDeReflowDisparou = false;
  }

  /// Acompanha o datatable pelo stream de instrumentação.
  ///
  /// `draw.finish` conta os redesenhos, `responsiveAutoHideSync.changed` fecha o
  /// ciclo alterando a largura do container, e `responsiveReflow.suspended`
  /// avisa que o guarda cortou a corrente.
  void aoInstrumentar(LiDatatableInstrumentationEvent evento) {
    switch (evento.stage) {
      case 'draw.finish':
        redesenhos++;
        // Tambem aqui, e nao so na mudanca de auto-hide: quem esconde a coluna
        // pode ter sido o modo colapsado, que nao passa por aquele evento.
        _sincronizarColunasEscondidas();
        break;
      case 'responsiveReflow.suspended':
        guardaDeReflowDisparou = true;
        break;
      case 'responsiveReflow.resumed':
        guardaDeReflowDisparou = false;
        break;
      case 'responsiveAutoHideSync.changed':
        mudancasDeAutoHide++;
        final escondidas = evento.details['autoHiddenColumns'] as int? ?? 0;
        _colunasEscondidasAgora = escondidas > 0;
        _sincronizarColunasEscondidas();
        break;
      default:
        return;
    }

    _changeDetectorRef.markForCheck();
  }

  /// Lê o estado do próprio componente.
  ///
  /// `renderedRows` ainda descreve o desenho anterior no momento em que o
  /// evento chega — `isRuntimeResponsiveHidden` já reflete a decisão nova.
  void _sincronizarColunasEscondidas() {
    final tabelaAtual = datatable;
    if (tabelaAtual == null) {
      colunasEscondidas = const <String>[];
      return;
    }

    colunasEscondidas = colunas.colsDefinitions
        .where(tabelaAtual.isRuntimeResponsiveHidden)
        .map((coluna) => coluna.title)
        .toList(growable: false);
  }

  void _paginar(Filters novosFiltros) {
    final itens = ehAbaDoSetor
        ? _todos
        : _todos.take(6).toList(growable: false);
    final offset = novosFiltros.offset ?? 0;
    final fim = offset + (novosFiltros.limit ?? opcoesPorPagina.first);

    tabela = DataFrame<AcompanhamentoEspecialDemo>(
      items: itens.sublist(
        offset.clamp(0, itens.length),
        fim.clamp(0, itens.length),
      ),
      totalRecords: itens.length,
    );
    _changeDetectorRef.markForCheck();
  }

  /// As larguras somam [larguraTotalDasColunas], poucos pixels acima da largura
  /// base do container.
  ///
  /// É o que faz o ciclo existir: com a barra de rolagem na tela as colunas não
  /// cabem, sem ela cabem. Colunas muito mais largas que o container ficariam
  /// escondidas nas duas larguras e não haveria loop nenhum — foi exatamente o
  /// aperto da tela do SALI com zoom em 110%.
  /// Colunas da tela do SALI, com a prioridade refletindo a importância real.
  ///
  /// `responsiveAutoHidePriority` menor some primeiro. A ordem escolhida é a
  /// que o operador usaria: o número do processo nunca sai, "Onde está agora"
  /// é a última a sair (é o que a tela existe para responder), e a observação
  /// — texto longo e auxiliar — é a primeira.
  ///
  /// `hideOnMobile` é outro mecanismo: no celular o auto-hide sozinho mantém
  /// tudo que couber, e caberia mais de uma coluna. Marcando as secundárias, o
  /// modo colapsado deixa só o processo e manda o resto para o detalhe da
  /// linha, que é o que se espera de uma lista no celular.
  DatatableSettings _montarColunas() {
    return DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: AcompanhamentoEspecialDemo.processoCol,
          title: 'Processo',
          width: '110px',
          minWidth: '110px',
          nowrap: true,
          responsiveAutoHideRequired: true,
        ),
        DatatableCol(
          key: AcompanhamentoEspecialDemo.ondeEstaCol,
          title: 'Onde está agora',
          // Carrega o nome inteiro do setor ("GOVTIC - Secretaria de
          // Governança e Transformação Digital"): estreita demais, vira uma
          // coluna de cinco linhas.
          width: '230px',
          minWidth: '230px',
          hideOnMobile: true,
          responsiveAutoHidePriority: 70,
        ),
        DatatableCol(
          key: AcompanhamentoEspecialDemo.situacaoCol,
          title: 'Situação',
          width: '130px',
          minWidth: '130px',
          hideOnMobile: true,
          responsiveAutoHidePriority: 60,
        ),
        DatatableCol(
          key: AcompanhamentoEspecialDemo.ultimoAndamentoCol,
          title: 'Último andamento',
          width: '130px',
          minWidth: '130px',
          hideOnMobile: true,
          responsiveAutoHidePriority: 50,
        ),
        DatatableCol(
          key: AcompanhamentoEspecialDemo.grupoCol,
          title: 'Grupo',
          width: '120px',
          minWidth: '120px',
          hideOnMobile: true,
          responsiveAutoHidePriority: 40,
        ),
        DatatableCol(
          key: AcompanhamentoEspecialDemo.assuntoCol,
          title: 'Assunto',
          width: '130px',
          minWidth: '130px',
          hideOnMobile: true,
          responsiveAutoHidePriority: 30,
        ),
        DatatableCol(
          key: AcompanhamentoEspecialDemo.incluidoPorCol,
          title: 'Incluído por',
          width: '140px',
          minWidth: '140px',
          hideOnMobile: true,
          responsiveAutoHidePriority: 20,
        ),
        DatatableCol(
          key: AcompanhamentoEspecialDemo.observacaoCol,
          title: 'Observação',
          width: '150px',
          minWidth: '150px',
          hideOnMobile: true,
          responsiveAutoHidePriority: 10,
        ),
      ],
    );
  }

  static List<AcompanhamentoEspecialDemo> _seed() {
    return <AcompanhamentoEspecialDemo>[
      AcompanhamentoEspecialDemo(
        processo: '34076/2026',
        ondeEsta: 'GOVTIC - Secretaria de Governança e Transformação Digital',
        grupo: 'aguardando pagamento',
        ultimoAndamento: '28/08/2026 16:25:12',
        situacao: 'Em andamento, recebido',
        observacao: 'Conferir a folha antes de encaminhar',
        assunto: 'Abono de Permanência',
        incluidoPor: "Isaque Neves Sant'Ana",
      ),
      AcompanhamentoEspecialDemo(
        processo: '26188/2026',
        ondeEsta: 'GOVTIC - Secretaria de Governança e Transformação Digital',
        grupo: 'Aguardando parecer jurídico',
        ultimoAndamento: '02/07/2026 10:39:23',
        situacao: 'Em andamento, recebido',
        observacao: 'Minuta em análise na Procuradoria',
        assunto: 'Memorando',
        incluidoPor: "Isaque Neves Sant'Ana",
      ),
      AcompanhamentoEspecialDemo(
        processo: '61109/2016',
        ondeEsta: 'Protocolo Geral',
        grupo: 'Prioritários',
        ultimoAndamento: '31/01/2017 08:30:41',
        situacao: 'Em andamento, recebido',
        observacao: 'Aguardando resposta da Procuradoria',
        assunto: 'Revisão documental',
        incluidoPor: 'Núcleo de Governança',
      ),
      AcompanhamentoEspecialDemo(
        processo: '48210/2019',
        ondeEsta: 'Engenharia',
        grupo: 'Obras',
        ultimoAndamento: '28/01/2017 08:15:02',
        situacao: 'Em andamento, recebido',
        observacao: 'Falta o laudo do engenheiro responsável',
        assunto: 'Licença de construção',
        incluidoPor: 'Secretaria de Obras',
      ),
      AcompanhamentoEspecialDemo(
        processo: '17734/2021',
        ondeEsta: 'Recursos Humanos',
        grupo: 'Pessoal',
        ultimoAndamento: '27/01/2017 10:00:37',
        situacao: 'Em andamento, recebido',
        observacao: 'Conferir tempo de serviço averbado',
        assunto: 'Progressão funcional',
        incluidoPor: 'Departamento de Pessoal',
      ),
      AcompanhamentoEspecialDemo(
        processo: '90455/2018',
        ondeEsta: 'Procuradoria',
        grupo: 'Convênios',
        ultimoAndamento: '26/01/2017 14:20:11',
        situacao: 'Em andamento, recebido',
        observacao: 'Minuta em análise jurídica desde maio',
        assunto: 'Convênio com o Estado',
        incluidoPor: 'Gabinete',
      ),
      AcompanhamentoEspecialDemo(
        processo: '33120/2022',
        ondeEsta: 'Fiscalização',
        grupo: 'Fiscalização',
        ultimoAndamento: '25/01/2017 09:05:48',
        situacao: 'Em andamento, recebido',
        observacao: 'Prazo de defesa encerra no fim do mês',
        assunto: 'Auto de infração',
        incluidoPor: 'Vigilância Sanitária',
      ),
      AcompanhamentoEspecialDemo(
        processo: '75988/2017',
        ondeEsta: 'Compras',
        grupo: 'Obras',
        ultimoAndamento: '24/01/2017 16:40:19',
        situacao: 'Em andamento, recebido',
        observacao: 'Licitação suspensa por impugnação',
        assunto: 'Reforma de escola',
        incluidoPor: 'Educação',
      ),
      AcompanhamentoEspecialDemo(
        processo: '11002/2023',
        ondeEsta: 'Meio Ambiente',
        grupo: 'Prioritários',
        ultimoAndamento: '23/01/2017 11:15:53',
        situacao: 'Em andamento, recebido',
        observacao: 'Vistoria agendada para a próxima semana',
        assunto: 'Licenciamento ambiental',
        incluidoPor: 'Meio Ambiente',
      ),
      AcompanhamentoEspecialDemo(
        processo: '58471/2020',
        ondeEsta: 'Cadastro Imobiliário',
        grupo: 'Tributos',
        ultimoAndamento: '22/01/2017 08:50:26',
        situacao: 'Em andamento, recebido',
        observacao: 'Contribuinte apresentou nova planta',
        assunto: 'Revisão de IPTU',
        incluidoPor: 'Tributos',
      ),
      AcompanhamentoEspecialDemo(
        processo: '26630/2015',
        ondeEsta: 'Almoxarifado',
        grupo: 'Saúde',
        ultimoAndamento: '21/01/2017 15:30:04',
        situacao: 'Em andamento, recebido',
        observacao: 'Entrega parcial registrada',
        assunto: 'Aquisição de insumos',
        incluidoPor: 'Saúde',
      ),
      AcompanhamentoEspecialDemo(
        processo: '84019/2024',
        ondeEsta: 'CRAS Centro',
        grupo: 'Assistência',
        ultimoAndamento: '20/01/2017 10:10:33',
        situacao: 'Em andamento, recebido',
        observacao: 'Documentação da família incompleta',
        assunto: 'Benefício eventual',
        incluidoPor: 'Assistência Social',
      ),
    ];
  }

  final String snippetDaBarraDeRolagem = 'html {\n'
      '    /* Reserva o espaco da barra para sempre: ela aparecer ou sumir\n'
      '       deixa de mudar a largura de tudo que esta na pagina. */\n'
      '    scrollbar-gutter: stable;\n'
      '}';

  final String snippetDaTela = '<li-datatable\n'
      '    [data]="tabelaDoSetor"\n'
      '    [settings]="colunasDoSetor"\n'
      '    [dataTableFilter]="filtrosDoSetor"\n'
      '    (dataRequest)="paginarSetor(\$event)"\n'
      '    [responsiveCollapse]="true"\n'
      '    [responsiveCollapseMaxWidth]="991"\n'
      '    [responsiveAutoHideColumns]="true">\n'
      '</li-datatable>';
}
