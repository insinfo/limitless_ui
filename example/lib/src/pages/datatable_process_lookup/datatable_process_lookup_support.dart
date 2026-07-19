import 'package:web/web.dart';

import 'package:limitless_ui/limitless_ui.dart';

class DatatableProcessLookupExampleSupport {
  static const int _seedRecordTargetCount = 3200;

  static DatatableSettings buildSettings({
    required Element Function(Map<String, dynamic>, dynamic)
        digitalBadgeBuilder,
  }) {
    final colsDefinitions = buildBaseCols(
      digitalBadgeBuilder: digitalBadgeBuilder,
    );
    // colsDefinitions.add(
    //   DatatableCol(
    //     key: 'actions',
    //     title: 'Ações',
    //     width: '104px',
    //     minWidth: '104px',
    //     textAlign: 'center',
    //     responsiveAutoHideRequired: true,
    //     exportable: false,
    //   ),
    // );

    return DatatableSettings(
      colsDefinitions: colsDefinitions,
      rowKeyResolver: (itemMap, _, index) => itemMap['processCode'] ?? index,
    );
  }

  static List<DatatableCol> buildBaseCols({
    required Element Function(Map<String, dynamic>, dynamic)
        digitalBadgeBuilder,
  }) {
    return <DatatableCol>[
      DatatableCol(
        key: 'processCode',
        title: 'Código',
        enableSorting: true,
        sortingBy: 'processCodeOrder',
        width: '110px',
        minWidth: '110px',
        nowrap: true,
        responsiveAutoHideRequired: true,
      ),
      DatatableCol(
        key: 'requester',
        title: 'Requerente',
        enableSorting: true,
        sortingBy: 'requester',
        minWidth: '270px',
        responsiveAutoHidePriority: 40,
      ),
      DatatableCol(
        key: 'personType',
        title: 'Tipo Cgm',
        enableSorting: true,
        sortingBy: 'personType',
        width: '120px',
        minWidth: '120px',
        responsiveAutoHidePriority: 10,
      ),
      DatatableCol(
        key: 'classification',
        title: 'Classificação',
        enableSorting: true,
        sortingBy: 'classification',
        minWidth: '130px',
        responsiveAutoHidePriority: 20,
      ),
      DatatableCol(
        key: 'subject',
        title: 'Assunto',
        enableSorting: true,
        sortingBy: 'subject',
        minWidth: '170px',
        responsiveAutoHidePriority: 30,
      ),
      DatatableCol(
        key: 'createdAt',
        title: 'Inclusão',
        enableSorting: true,
        sortingBy: 'createdAtOrder',
        minWidth: '155px',
        nowrap: true,
        responsiveAutoHidePriority: 15,
      ),
      DatatableCol(
        key: 'status',
        title: 'Situação',
        enableSorting: true,
        sortingBy: 'status',
        minWidth: '170px',
        hideOnMobile: true,
        responsiveAutoHidePriority: 50,
      ),
      DatatableCol(
        key: 'digitalLabel',
        title: 'Digital',
        enableSorting: true,
        sortingBy: 'digitalOrder',
        width: '90px',
        minWidth: '90px',
        textAlign: 'center',
        responsiveAutoHidePriority: 5,
        customRenderHtml: digitalBadgeBuilder,
      ),
    ];
  }

  static List<DatatableSearchField> buildSearchFields() {
    return <DatatableSearchField>[
      DatatableSearchField(
        label: 'Nº Processo',
        field: 'processCode',
        operator: 'like',
        selected: true,
      ),
      DatatableSearchField(
        label: 'Objeto/Observações',
        field: 'detail',
        operator: 'like',
      ),
      DatatableSearchField(
        label: 'Assunto Reduzido',
        field: 'subject',
        operator: 'like',
      ),
      DatatableSearchField(
        label: 'CGM requerente',
        field: 'requester',
        operator: 'like',
      ),
    ];
  }

  static List<Map<String, dynamic>> buildSeedRecords() {
    final records = <Map<String, dynamic>>[
      _buildRecord(
        processCode: '1860/96',
        requester: 'TEREZINHA GROLA',
        personType: 'Padrão',
        classification: 'Solicitação, faz',
        subject: 'Solicitação',
        detail: 'Solicitação do processo',
        createdAt: '21/10/2016 15:29:33',
        createdAtOrder: 20161021152933,
        status: 'Anexado',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildRecord(
        processCode: '16269/2026',
        requester: 'CINTIA MARIA PIMENTEL HERMIDA DOS SANTOS',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Abono de permanência - requerimento principal',
        createdAt: '20/04/2026 15:55:28',
        createdAtOrder: 20260420155528,
        status: 'Em andamento, recebido',
        digitalLabel: 'Sim',
        digitalOrder: 1,
      ),
      _buildRecord(
        processCode: '16268/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Observações do abono de permanência',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Em andamento, recebido',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildRecord(
        processCode: '16267/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Processo aguardando conferência',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Em andamento, a receber',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildRecord(
        processCode: '16266/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Recebimento pendente de digitalização',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Em andamento, a receber',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildRecord(
        processCode: '16265/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Fluxo recebido na unidade',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Em andamento, recebido',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildRecord(
        processCode: '16264/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Processo anexado ao volume principal',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Anexado',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildRecord(
        processCode: '16263/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Recebimento pela unidade de protocolo',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Em andamento, recebido',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildRecord(
        processCode: '16262/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Tramitação em andamento',
        createdAt: '18/04/2026 01:00:33',
        createdAtOrder: 20260418010033,
        status: 'Em andamento, recebido',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildRecord(
        processCode: '16261/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Arquivado definitivamente',
        createdAt: '18/04/2026 01:00:33',
        createdAtOrder: 20260418010033,
        status: 'Arquivado definitivo',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildRecord(
        processCode: '16260/2026',
        requester: 'Jorgito Inocencio Santos',
        personType: 'Padrão',
        classification: 'Cadastro',
        subject: 'Atualização cadastral',
        detail: 'Objeto e observações do cadastro',
        createdAt: '16/04/2026 10:12:20',
        createdAtOrder: 20260416101220,
        status: 'Em análise',
        digitalLabel: 'Sim',
        digitalOrder: 1,
      ),
      _buildRecord(
        processCode: '16259/2026',
        requester: 'JULIA RAMOS',
        personType: 'Padrão',
        classification: 'Licença',
        subject: 'Licença especial',
        detail: 'Observações sobre licença especial',
        createdAt: '15/04/2026 09:05:10',
        createdAtOrder: 20260415090510,
        status: 'Em andamento, recebido',
        digitalLabel: 'Sim',
        digitalOrder: 1,
      ),
    ];

    final extraRecordsNeeded = _seedRecordTargetCount - records.length;
    if (extraRecordsNeeded <= 0) {
      _normalizeSequentialProcessCodes(records, year: 2026);
      return records;
    }

    const requesters = <String>[
      'MARIA CLARA SOUZA',
      'JOAO PEDRO LIMA',
      'ANA BEATRIZ COSTA',
      'CARLOS EDUARDO ALVES',
      'FERNANDA MORAIS',
      'LUCAS GABRIEL PEREIRA',
      'PATRICIA NUNES',
      'RODRIGO HENRIQUE DIAS',
      'MARIANA TAVARES',
      'GUSTAVO MARTINS',
      'HELENA BARBOSA',
      'RAFAEL MONTEIRO',
      'CAMILA SANTOS',
      'VICTOR HUGO MELO',
      'BRUNA QUEIROZ',
      'LEONARDO COSTA',
      'AMANDA FREITAS',
      'THIAGO MOREIRA',
      'PRISCILA LOPES',
      'ISABELA RIBEIRO',
    ];

    const classifications = <Map<String, String>>[
      <String, String>{
        'classification': 'Abono',
        'subject': 'Abono de Permanência',
        'detail': 'Requerimento de abono de permanência em análise',
      },
      <String, String>{
        'classification': 'Cadastro',
        'subject': 'Atualização cadastral',
        'detail': 'Atualização cadastral com documentação complementar',
      },
      <String, String>{
        'classification': 'Licença',
        'subject': 'Licença especial',
        'detail': 'Licença especial com observações adicionais',
      },
      <String, String>{
        'classification': 'Solicitação',
        'subject': 'Solicitação administrativa',
        'detail': 'Solicitação administrativa registrada no protocolo',
      },
      <String, String>{
        'classification': 'Despacho',
        'subject': 'Despacho interno',
        'detail': 'Despacho interno encaminhado para unidade responsável',
      },
      <String, String>{
        'classification': 'Revisão',
        'subject': 'Revisão documental',
        'detail': 'Revisão documental aguardando validação final',
      },
    ];

    const statuses = <String>[
      'Em andamento, recebido',
      'Em andamento, a receber',
      'Em análise',
      'Anexado',
      'Arquivado definitivo',
      'Aguardando assinatura',
      'Aguardando conferência',
    ];

    const personTypes = <String>[
      'Padrão',
      'Interno',
      'Externo',
    ];

    final baseDate = DateTime(2026, 4, 14, 8, 0, 0);
    for (var index = 0; index < extraRecordsNeeded; index++) {
      final descriptor = classifications[index % classifications.length];
      final createdAtDate = baseDate.subtract(Duration(minutes: index * 17));
      final isDigital = index % 4 == 0 || index % 7 == 0;

      records.add(
        _buildRecord(
          processCode: '',
          requester: requesters[index % requesters.length],
          personType: personTypes[index % personTypes.length],
          classification: descriptor['classification']!,
          subject: descriptor['subject']!,
          detail: '${descriptor['detail']} #${index + 1}',
          createdAt: _formatDateTime(createdAtDate),
          createdAtOrder: _toCreatedAtOrder(createdAtDate),
          status: statuses[index % statuses.length],
          digitalLabel: isDigital ? 'Sim' : 'Não',
          digitalOrder: isDigital ? 1 : 0,
        ),
      );
    }

    _normalizeSequentialProcessCodes(records, year: 2026);

    return records;
  }

  static void _normalizeSequentialProcessCodes(
    List<Map<String, dynamic>> records, {
    required int year,
  }) {
    for (var index = 0; index < records.length; index++) {
      final processNumber = index + 1;
      records[index]['processCode'] = '$processNumber/$year';
      records[index]['processCodeOrder'] = processNumber;
    }
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString().padLeft(4, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute:$second';
  }

  static int _toCreatedAtOrder(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return int.parse('$year$month$day$hour$minute$second');
  }

  static Map<String, dynamic> _buildRecord({
    required String processCode,
    required String requester,
    required String personType,
    required String classification,
    required String subject,
    required String detail,
    required String createdAt,
    required int createdAtOrder,
    required String status,
    required String digitalLabel,
    required int digitalOrder,
  }) {
    return <String, dynamic>{
      'processCode': processCode,
      'processCodeOrder': 0,
      'requester': requester,
      'personType': personType,
      'classification': classification,
      'subject': subject,
      'detail': detail,
      'createdAt': createdAt,
      'createdAtOrder': createdAtOrder,
      'status': status,
      'digitalLabel': digitalLabel,
      'digitalOrder': digitalOrder,
    };
  }
}
