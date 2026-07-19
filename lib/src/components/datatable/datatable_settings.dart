import 'package:web/web.dart' as web;

//datatable_settings.dart

import 'datatable_col.dart';
import 'datatable_row.dart';

typedef RowStyleResolver = String? Function(
  Map<String, dynamic> itemMap,
  dynamic itemInstance,
);

typedef DatatableCardBuilder = web.Element Function(
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
  /// Quando nula, o componente mantém o comportamento legado:
  /// prioriza a primeira coluna visível marcada com
  /// [DatatableCol.responsiveAutoHideRequired] e, na falta dela,
  /// usa a primeira coluna visível.
  String? responsiveControlColumnKey;

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
