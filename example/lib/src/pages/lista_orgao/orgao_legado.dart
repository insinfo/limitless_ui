import 'package:essential_core/essential_core.dart';

/// Modelo de domínio da tela de exemplo, no mesmo formato usado em telas reais:
/// uma entidade mutável que implementa [SerializeBase].
///
/// O ponto importante para esta demo é que `ativo` é mutável — a coluna
/// "Habilitar/Desabilitar" altera este campo na própria instância, sem trocar a
/// lista nem o `DataFrame`.
class OrgaoLegado implements SerializeBase {
  static const tableName = 'orgaos';
  static const idCol = 'id';
  static const codigoOrgaoCol = 'codigo_orgao';
  static const nomeCol = 'nome';
  static const siglaCol = 'sigla';
  static const ordemCol = 'ordem';
  static const ativoCol = 'ativo';

  int id;
  int codigoOrgao;
  String nome;
  String sigla;
  int ordem;
  bool ativo;

  OrgaoLegado({
    required this.id,
    required this.codigoOrgao,
    required this.nome,
    required this.sigla,
    required this.ordem,
    required this.ativo,
  });

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: id,
      codigoOrgaoCol: codigoOrgao,
      nomeCol: nome,
      siglaCol: sigla,
      ordemCol: ordem,
      ativoCol: ativo,
    };
  }

  factory OrgaoLegado.fromMap(Map<String, dynamic> map) {
    return OrgaoLegado(
      id: map[idCol] as int,
      codigoOrgao: map[codigoOrgaoCol] as int,
      nome: map[nomeCol] as String,
      sigla: map[siglaCol] as String,
      ordem: map[ordemCol] as int,
      ativo: map[ativoCol] as bool,
    );
  }

  OrgaoLegado copy() => OrgaoLegado.fromMap(toMap());
}

/// Filtros da tela, com um campo extra fora do contrato do datatable.
///
/// Espelha o padrão de projetos que estendem [Filters] para carregar filtros
/// próprios (aqui, o select "Ativo" acima da tabela).
class ListaOrgaoFilters extends Filters {
  ListaOrgaoFilters({super.limit, super.offset});

  bool? ativo;
}

/// Serviço de exemplo que imita um backend REST paginado.
///
/// Cada `all()` devolve um **novo** [DataFrame] com **novas** instâncias de
/// [OrgaoLegado], exatamente como acontece quando os itens vêm desserializados
/// de JSON. Já `updateAtivo` altera apenas o registro do "banco", sem devolver
/// nada — é por isso que a tela precisa decidir como refletir a mudança.
class OrgaoDemoService {
  OrgaoDemoService() : _registros = _seed();

  final List<OrgaoLegado> _registros;

  static List<OrgaoLegado> _seed() {
    const nomes = <List<String>>[
      ['Secretaria Municipal de Saúde', 'SMS'],
      ['Secretaria Municipal de Educação', 'SME'],
      ['Secretaria Municipal de Obras', 'SMO'],
      ['Procuradoria Geral do Município', 'PGM'],
      ['Controladoria Geral do Município', 'CGM'],
      ['Secretaria Municipal de Fazenda', 'SMF'],
      ['Secretaria Municipal de Cultura', 'SMC'],
      ['Secretaria Municipal de Esportes', 'SMEL'],
      ['Secretaria Municipal de Meio Ambiente', 'SMMA'],
      ['Gabinete do Prefeito', 'GAB'],
      ['Secretaria Municipal de Transportes', 'SMTR'],
      ['Secretaria Municipal de Assistência Social', 'SMAS'],
    ];

    return <OrgaoLegado>[
      for (var index = 0; index < nomes.length; index++)
        OrgaoLegado(
          id: index + 1,
          codigoOrgao: 1000 + (index + 1) * 7,
          nome: nomes[index][0],
          sigla: nomes[index][1],
          ordem: index + 1,
          ativo: index % 4 != 3,
        ),
    ];
  }

  Future<DataFrame<OrgaoLegado>> all(ListaOrgaoFilters filtros) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    var resultado = _registros.toList(growable: false);

    if (filtros.ativo != null) {
      resultado = resultado
          .where((orgao) => orgao.ativo == filtros.ativo)
          .toList(growable: false);
    }

    final busca = filtros.searchString?.trim().toLowerCase();
    if (busca != null && busca.isNotEmpty) {
      final campos = filtros.searchInFields
          .where((field) => field.active)
          .map((field) => field.field)
          .toList(growable: false);
      resultado = resultado.where((orgao) {
        final map = orgao.toMap();
        for (final campo in campos) {
          final valor = map[campo]?.toString().toLowerCase() ?? '';
          if (valor.contains(busca)) {
            return true;
          }
        }
        return campos.isEmpty;
      }).toList(growable: false);
    }

    resultado = _ordenar(resultado, filtros);

    final total = resultado.length;
    final offset = (filtros.offset ?? 0).clamp(0, total);
    final limit = filtros.limit ?? total;
    final fim = (offset + limit).clamp(offset, total);

    // Novas instâncias a cada consulta, como numa desserialização de JSON.
    return DataFrame<OrgaoLegado>(
      items: resultado
          .sublist(offset, fim)
          .map((orgao) => orgao.copy())
          .toList(growable: true),
      totalRecords: total,
    );
  }

  List<OrgaoLegado> _ordenar(
    List<OrgaoLegado> entrada,
    ListaOrgaoFilters filtros,
  ) {
    final criterios = filtros.orderFields.isNotEmpty
        ? filtros.orderFields
        : <FilterOrderField>[
            if (filtros.orderBy != null && filtros.orderBy!.trim().isNotEmpty)
              FilterOrderField(
                field: filtros.orderBy!,
                direction: filtros.orderDir ?? 'asc',
              ),
          ];

    if (criterios.isEmpty) {
      return entrada;
    }

    final ordenado = entrada.toList(growable: true);
    ordenado.sort((esquerda, direita) {
      for (final criterio in criterios) {
        final valorEsquerda = esquerda.toMap()[criterio.field];
        final valorDireita = direita.toMap()[criterio.field];
        final comparacao = _comparar(valorEsquerda, valorDireita);
        if (comparacao != 0) {
          return criterio.direction == 'desc' ? -comparacao : comparacao;
        }
      }
      return 0;
    });
    return ordenado;
  }

  int _comparar(dynamic esquerda, dynamic direita) {
    if (esquerda == null && direita == null) {
      return 0;
    }
    if (esquerda == null) {
      return -1;
    }
    if (direita == null) {
      return 1;
    }
    if (esquerda is num && direita is num) {
      return esquerda.compareTo(direita);
    }
    return esquerda
        .toString()
        .toLowerCase()
        .compareTo(direita.toString().toLowerCase());
  }

  /// Persiste apenas o campo `ativo`, como um `PATCH /orgaos/update/ativo/:id`.
  Future<void> updateAtivo(int id, bool ativo) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (final orgao in _registros) {
      if (orgao.id == id) {
        orgao.ativo = ativo;
        return;
      }
    }
  }

  Future<void> desativarTodos() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    for (final orgao in _registros) {
      orgao.ativo = false;
    }
  }

  Future<void> deleteAll(List<OrgaoLegado> itens) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final ids = itens.map((orgao) => orgao.id).toSet();
    _registros.removeWhere((orgao) => ids.contains(orgao.id));
  }
}
