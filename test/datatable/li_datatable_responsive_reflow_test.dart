// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/datatable/li_datatable_responsive_reflow_test.dart
@TestOn('browser')
library;

import 'dart:html';

import 'package:limitless_ui/limitless_ui.dart';
import 'package:limitless_ui/src/components/datatable/datatable_responsive_controller.dart';
import 'package:test/test.dart';

/// Two columns that overflow a 300px container by 10px.
List<DatatableCol> _columns() {
  return <DatatableCol>[
    DatatableCol(
      key: 'processo',
      title: 'Processo',
      width: '160px',
      responsiveAutoHideRequired: true,
    ),
    DatatableCol(
      key: 'ondeEsta',
      title: 'Onde está agora',
      width: '150px',
      responsiveAutoHidePriority: 10,
    ),
  ];
}

bool _sync(
  DatatableResponsiveController controller,
  double availableWidth, {
  List<DatatableCol>? columns,
}) {
  return controller.syncAutoHiddenColumns(
    responsiveEnabled: true,
    autoHideEnabled: true,
    gridMode: false,
    availableWidth: availableWidth,
    columns: columns ?? _columns(),
    collapseActive: false,
    showCheckboxToSelectRow: false,
  );
}

/// Monta uma tabela real no documento, no formato que o datatable renderiza.
///
/// [escondidas] recebem as tres classes que o componente usa para tirar uma
/// coluna do layout -- e o ponto do teste e justamente que a medicao tem que
/// enxergar essas colunas mesmo assim.
TableElement _montarTabela({
  required Map<String, String> colunas,
  required Set<String> escondidas,
}) {
  final tabela = TableElement();
  final thead = tabela.createTHead();
  final linhaCabecalho = thead.addRow();
  final tbody = tabela.createTBody();
  final linhaDados = tbody.addRow();

  colunas.forEach((chave, texto) {
    final th = Element.th()
      ..setAttribute('data-key', chave)
      ..text = chave;
    final td = Element.td()..text = texto;
    if (escondidas.contains(chave)) {
      for (final classe in <String>[
        'hide',
        'datatable-mobile-hidden',
        'dtr-hidden',
      ]) {
        th.classes.add(classe);
        td.classes.add(classe);
      }
    }
    linhaCabecalho.append(th);
    linhaDados.append(td);
  });

  // `.hide` so existe no CSS do componente, que nao esta carregado aqui.
  final estilo = StyleElement()
    ..text = '.hide, .datatable-mobile-hidden, .dtr-hidden { display: none; }';
  document.head!.append(estilo);

  final host = DivElement()..style.width = '900px';
  host.append(tabela);
  document.body!.append(host);
  return tabela;
}

void main() {
  test('mede a coluna escondida, que nao existe no layout da tabela', () {
    final tabela = _montarTabela(
      colunas: <String, String>{
        'processo': '61109/2016',
        'ondeEsta': 'Protocolo Geral do Municipio',
        'situacao': 'OK',
      },
      escondidas: <String>{'situacao'},
    );
    addTearDown(() => tabela.parent?.remove());

    final controller = DatatableResponsiveController();
    controller.measureMinimumColumnWidths(
      tableElement: tabela,
      showCheckboxToSelectRow: false,
    );

    final medidas = controller.measuredColumnWidths;

    // A coluna escondida esta fora do layout: medi-la no lugar daria zero. O
    // clone tem que devolve-la ao fluxo antes de ler -- remover so a classe
    // `hide` deixava as outras duas segurando o `display: none`, e a coluna
    // saia com largura zero, que o calculo trata como "nao ocupa espaco".
    expect(medidas.keys, containsAll(<String>['processo', 'ondeEsta', 'situacao']));
    expect(
      medidas['situacao'],
      isNotNull,
      reason: 'a coluna escondida nem chegou a ser medida',
    );
    expect(
      medidas['situacao']!,
      greaterThan(0),
      reason: 'a coluna escondida mediu zero: continuou fora do layout do clone',
    );

    // E as medidas tem que ser comparaveis entre si: a coluna de texto longo
    // precisa de mais espaco que a de texto curto.
    expect(medidas['ondeEsta']!, greaterThan(medidas['situacao']!));
  });

  test('a medicao so acontece uma vez ate ser invalidada', () {
    final tabela = _montarTabela(
      colunas: <String, String>{'processo': '61109/2016', 'situacao': 'OK'},
      escondidas: <String>{},
    );
    addTearDown(() => tabela.parent?.remove());

    final controller = DatatableResponsiveController();
    expect(controller.hasPendingMeasurement, isTrue);

    controller.measureMinimumColumnWidths(
      tableElement: tabela,
      showCheckboxToSelectRow: false,
    );
    expect(controller.hasPendingMeasurement, isFalse);

    final primeira = Map<String, double>.from(controller.measuredColumnWidths);
    expect(primeira, isNotEmpty);

    // Sem invalidar, medir de novo nao mexe em nada -- e o que evita gastar um
    // clone por desenho.
    controller.measureMinimumColumnWidths(
      tableElement: tabela,
      showCheckboxToSelectRow: false,
    );
    expect(controller.measuredColumnWidths, primeira);

    controller.resetMeasurementCache();
    expect(controller.hasPendingMeasurement, isTrue);
    expect(controller.measuredColumnWidths, isEmpty);
  });

  test('esconde a coluna de menor prioridade quando as colunas nao cabem', () {
    final controller = DatatableResponsiveController();

    expect(_sync(controller, 300), isTrue);
    expect(controller.autoHiddenColumnKeys, <String>{'ondeEsta'});
  });

  test(
      'nao devolve a coluna quando a largura so cresce o que a barra de '
      'rolagem devolveu', () {
    final controller = DatatableResponsiveController();
    _sync(controller, 300);
    expect(controller.autoHiddenColumnKeys, <String>{'ondeEsta'});

    // Esconder a coluna encurta a tabela, a barra de rolagem da pagina some e o
    // container ganha ~16px. Sem histerese as colunas cabem de novo, a barra
    // volta, e o layout fica alternando entre os dois estados para sempre --
    // era o loop infinito com zoom em 110%.
    for (var attempt = 0; attempt < 20; attempt++) {
      expect(_sync(controller, 316), isFalse, reason: 'tentativa $attempt');
      expect(controller.autoHiddenColumnKeys, <String>{'ondeEsta'});
    }
  });

  test('devolve a coluna quando o container cresce de verdade', () {
    final controller = DatatableResponsiveController();
    _sync(controller, 300);
    expect(controller.autoHiddenColumnKeys, <String>{'ondeEsta'});

    expect(_sync(controller, 400), isTrue);
    expect(controller.autoHiddenColumnKeys, isEmpty);

    // E continua estavel: a coluna de volta nao dispara um novo ciclo.
    expect(_sync(controller, 400), isFalse);
    expect(controller.autoHiddenColumnKeys, isEmpty);
  });

  test('a margem de histerese nao consome um container estreito', () {
    final controller = DatatableResponsiveController();
    final narrowColumns = <DatatableCol>[
      DatatableCol(
        key: 'processo',
        title: 'Processo',
        width: '10px',
        responsiveAutoHideRequired: true,
      ),
      DatatableCol(
        key: 'ondeEsta',
        title: 'Onde está agora',
        width: '10px',
        responsiveAutoHidePriority: 10,
      ),
    ];

    _sync(controller, 15, columns: narrowColumns);
    expect(controller.autoHiddenColumnKeys, <String>{'ondeEsta'});

    // 42px de container: uma margem fixa de 24px deixaria 18px de orcamento e
    // as duas colunas (20px) nunca mais voltariam. O piso de metade da largura
    // mantem a histerese proporcional ao espaco que existe.
    expect(_sync(controller, 42, columns: narrowColumns), isTrue);
    expect(controller.autoHiddenColumnKeys, isEmpty);
  });
}
