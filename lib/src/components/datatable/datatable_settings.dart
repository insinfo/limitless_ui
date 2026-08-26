//datatable_settings.dart
import 'dart:html';

import 'datatable_col.dart';
import 'datatable_row.dart';

typedef RowStyleResolver = String? Function(
  Map<String, dynamic> itemMap,
  dynamic itemInstance,
);

typedef DatatableCardBuilder = Element Function(
  Map<String, dynamic> itemMap,
  dynamic itemInstance,
  DatatableRow row,
);

typedef DatatableRowKeyResolver = Object Function(
  Map<String, dynamic> itemMap,
  dynamic itemInstance,
  int index,
);

enum DatatablePerformanceProfile {
  fast,
  flexible,
  full,
  saliPaged,
}

/// What opens the responsive details row.
enum DatatableResponsiveDetailsTrigger {
  /// Only the expand/collapse control opens it, leaving a click anywhere else
  /// in the row free to be reported through `onRowClick`.
  control,

  /// A click anywhere in a collapsed row opens it. Rows with nothing collapsed
  /// still report through `onRowClick`.
  row,
}

/// How the responsive collapse mode exposes the expand/collapse control.
enum DatatableResponsiveControlMode {
  /// The control shares the first eligible visible cell of the row, the whole
  /// cell acting as the hit area.
  inline,

  /// A dedicated leading column holds the control, so it never competes with
  /// the row content for taps.
  column,
}

class DatatableSettings {
  /// define as colunas que vão aparecer na tabela
  List<DatatableCol> colsDefinitions = [];

  bool enableGrouping = false;

  /// exibir a coluna do número de ordem
  bool showOrderNumberColumn = false;

  /// definir índice inicial do numero de ordem
  int _ordemIndex = 1;

  /// definir índice inicial do numero de ordem
  void setOrdemStartIndex(int ordem) {
    _ordemIndex = ordem;
  }

  RowStyleResolver? rowStyleResolver;
  DatatableRowKeyResolver? rowKeyResolver;
  DatatableCardBuilder? customCardBuilder;
  String gridTemplateColumns;
  String gridGap;
  String? gridContainerClass;
  String? gridContainerStyle;

  /// Chave da coluna que deve receber o controle de expandir/recolher
  /// quando houver colunas ocultas no modo responsivo.
  ///
  /// Quando nula, o componente usa a primeira coluna visível elegível
  /// (veja [DatatableCol.responsiveControlEligible]) e, na falta dela,
  /// a primeira coluna visível.
  String? responsiveControlColumnKey;

  /// Define onde fica o controle de expandir/recolher no modo responsivo.
  ///
  /// Em [DatatableResponsiveControlMode.inline] o controle ocupa a primeira
  /// célula visível elegível da linha. Em
  /// [DatatableResponsiveControlMode.column] o datatable acrescenta uma coluna
  /// só para o controle enquanto houver colunas recolhidas, garantindo uma
  /// área de toque própria — útil no mobile, onde o controle inline divide
  /// espaço com o conteúdo da célula.
  DatatableResponsiveControlMode responsiveControlMode;

  /// Define o que abre a linha de detalhes no modo responsivo.
  ///
  /// O padrão [DatatableResponsiveDetailsTrigger.control] deixa a abertura
  /// só para o controle de expandir, mantendo o clique no restante da linha
  /// livre para `onRowClick`. Com [DatatableResponsiveDetailsTrigger.row] o
  /// clique em qualquer ponto de uma linha recolhida a abre — linhas sem
  /// colunas recolhidas continuam emitindo `onRowClick`.
  DatatableResponsiveDetailsTrigger responsiveDetailsTrigger;

  /// [colsDefinitions] define as colunas que vão aparecer na tabela
  /// [showOrderNumberColumn] exibe uma coluna com um numero que enumera as linhas dos dados exbidos no dataTable
  DatatableSettings({
    required this.colsDefinitions,
    this.enableGrouping = false,
    this.showOrderNumberColumn = false,
    this.rowStyleResolver,
    this.rowKeyResolver,
    this.customCardBuilder,
    this.gridTemplateColumns = 'repeat(auto-fit, minmax(280px, 1fr))',
    this.gridGap = '1.25rem',
    this.gridContainerClass,
    this.gridContainerStyle,
    this.responsiveControlColumnKey,
    this.responsiveControlMode = DatatableResponsiveControlMode.inline,
    this.responsiveDetailsTrigger = DatatableResponsiveDetailsTrigger.control,
  }) {
    if (showOrderNumberColumn) {
      final col = DatatableCol(
          key: 'ordem',
          title: 'Ordem',
          visibility: false,
          customRenderString: (itemMap, itemInstance) {
            return '${_ordemIndex++}';
          });
      colsDefinitions.insert(0, col);
    }
  }

  // Iterable<int> countDownFromSyncRecursive(int num) sync* {
  //   if (num > 0) {
  //     yield num;
  //     yield* countDownFromSyncRecursive(num - 1);
  //   }
  // }

  // Iterable<int> genSerial(int num) sync* {
  //   if (num > 0) {
  //     yield num;
  //     yield* genSerial(num + 1);
  //   }
  // }

  // Iterable<int> generateNum() sync* {
  //   int n = 0;
  //   while (true) {
  //     yield n++;
  //   }
  // }

  List<DatatableCol> get visibleColumns =>
      colsDefinitions.where((c) => c.visibility).toList();

  List<DatatableCol> get exportColumns =>
      colsDefinitions.where((c) => c.exportable).toList();

  List<DatatableCol> get visibleExportColumns =>
      colsDefinitions.where((c) => c.visibility && c.exportable).toList();
}
