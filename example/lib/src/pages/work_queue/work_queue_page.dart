import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

import '../datatable/datatable_demo_service.dart';

@Component(
  selector: 'work-queue-page',
  templateUrl: 'work_queue_page.html',
  styleUrls: ['work_queue_page.css'],
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    DemoPageBreadcrumbComponent,
    LiDataTableComponent,
    LiDateRangePickerComponent,
    LiModalComponent,
    LiSelectComponent,
    LiTagFilterComponent,
    LiTagManagerComponent,
    LiTokenFieldComponent,
  ],
)
class WorkQueuePageComponent implements OnInit, DoCheck {
  WorkQueuePageComponent(this.i18n, this._ngZone)
      : _allRecords = _buildSeedRecords(),
        tagCatalog = _buildTagCatalog() {
    _classificationOptionsPt = _buildClassificationOptions(isEnglish: false);
    _classificationOptionsEn = _buildClassificationOptions(isEnglish: true);
    _subjectOptionsByClassificationPt =
        _buildSubjectOptionsByClassification(isEnglish: false);
    _subjectOptionsByClassificationEn =
        _buildSubjectOptionsByClassification(isEnglish: true);
    _searchFieldsPt = _buildSearchFields(isEnglish: false);
    _searchFieldsEn = _buildSearchFields(isEnglish: true);
    _datatableSettingsPt = _buildDatatableSettings(isEnglish: false);
    _datatableSettingsEn = _buildDatatableSettings(isEnglish: true);

    for (final record in _allRecords) {
      record['tags'] = _resolveTagsFromIds(record['tagIds'] as List<dynamic>);
    }

    _syncSubjectOptions();
  }

  final DemoI18nService i18n;
  final NgZone _ngZone;
  final List<Map<String, dynamic>> _allRecords;

  late final DatatableSettings _datatableSettingsPt;
  late final DatatableSettings _datatableSettingsEn;
  late final List<DatatableSearchField> _searchFieldsPt;
  late final List<DatatableSearchField> _searchFieldsEn;
  late final List<Map<String, dynamic>> _classificationOptionsPt;
  late final List<Map<String, dynamic>> _classificationOptionsEn;
  late final Map<String, List<Map<String, dynamic>>>
      _subjectOptionsByClassificationPt;
  late final Map<String, List<Map<String, dynamic>>>
      _subjectOptionsByClassificationEn;

  @ViewChild('queueTable')
  LiDataTableComponent? queueTable;

  @ViewChild('tagModal')
  LiModalComponent? tagModal;

  Filters tableFilters = Filters(
    limit: 12,
    offset: 0,
    orderBy: 'lastMovementSort',
    orderDir: 'desc',
  );

  DataFrame<Map<String, dynamic>> workItems = DataFrame<Map<String, dynamic>>(
    items: const <Map<String, dynamic>>[],
    totalRecords: 0,
  );
  List<Map<String, dynamic>> tagCatalog;
  List<Map<String, dynamic>> subjectOptions = const <Map<String, dynamic>>[];
  final List<int> limitPerPageOptions = <int>[10, 12, 20, 25, 50];
  final String processTokenPattern = r'\d+/\d+';
  final String processTokenAllowed = r'[0-9/]';

  bool? digitalFilter;
  String requesterQuery = '';
  String selectedClassificationId = '';
  String selectedSubjectId = '';
  String listCodeFilter = '';
  List<String> selectedCodes = <String>[];
  List<dynamic> selectedTagFilterIds = <dynamic>[];
  DateTime? includedStart;
  DateTime? includedEnd;

  int? activeRecordId;
  List<dynamic> activeRecordTagIds = <dynamic>[];
  String lastActionText = '';
  String _lastFilterSignature = '';
  int _loadRequestVersion = 0;

  bool get _isEnglishLocale => i18n.isEnglish;

  String get pageTitle => _isEnglishLocale ? 'Workflow' : 'Fluxo operacional';

  String get pageSubtitle =>
      _isEnglishLocale ? 'Route items' : 'Encaminhar itens';

  String get breadcrumbLabel =>
      _isEnglishLocale ? 'Work queue' : 'Fila operacional';

  String get localeCode => _isEnglishLocale ? 'en_US' : 'pt_BR';

  String get digitalLabel => _isEnglishLocale ? 'Digital' : 'Digital';

  String get requesterLabel => _isEnglishLocale ? 'Requester' : 'Solicitante';

  String get requesterPlaceholder => _isEnglishLocale
      ? 'Type to filter requester'
      : 'Digite para filtrar o solicitante';

  String get classificationLabel =>
      _isEnglishLocale ? 'Classification' : 'Classificacao';

  String get subjectLabel => _isEnglishLocale ? 'Subject' : 'Assunto';

  String get multiCodeLabel => _isEnglishLocale
      ? 'Multiple code selection'
      : 'Multipla selecao de codigos';

  String get multiCodePlaceholder => _isEnglishLocale
      ? 'Type a code/year and press enter.'
      : 'Digite o codigo/ano e pressione enter.';

  String get dateRangeLabel =>
      _isEnglishLocale ? 'Included between' : 'Incluido em';

  String get dateRangePlaceholder =>
      _isEnglishLocale ? 'Select a period' : 'Selecione o periodo';

  String get listCodeLabel =>
      _isEnglishLocale ? 'Batch code' : 'Codigo da lista';

  String get listCodePlaceholder =>
      _isEnglishLocale ? 'Filter by batch code' : 'Filtrar por codigo da lista';

  String get tagFilterLabel => _isEnglishLocale ? 'Labels' : 'Etiquetas';

  String get clearButtonLabel => _isEnglishLocale ? 'Clear' : 'Limpar';

  String get primaryActionLabel =>
      _isEnglishLocale ? 'Process selected' : 'Processar selecionados';

  String get tagModalTitle {
    final record = _findRecordById(activeRecordId);
    if (record == null) {
      return _isEnglishLocale ? 'Manage labels' : 'Gerenciar etiquetas';
    }
    return _isEnglishLocale
        ? 'Manage labels - ${record['fullCode']}'
        : 'Gerenciar etiquetas - ${record['fullCode']}';
  }

  List<Map<String, dynamic>> get classificationOptions =>
      _isEnglishLocale ? _classificationOptionsEn : _classificationOptionsPt;

  DatatableSettings get datatableSettings =>
      _isEnglishLocale ? _datatableSettingsEn : _datatableSettingsPt;

  List<DatatableSearchField> get searchFields =>
      _isEnglishLocale ? _searchFieldsEn : _searchFieldsPt;

  @override
  Future<void> ngOnInit() async {
    await _loadWorkItems();
  }

  @override
  void ngDoCheck() {
    _syncSubjectOptions();

    final currentSignature = _buildFilterSignature();
    if (currentSignature == _lastFilterSignature) {
      return;
    }

    _lastFilterSignature = currentSignature;
    tableFilters.offset = 0;
    _loadWorkItems();
  }

  void onRequesterInput(String value) {
    requesterQuery = value;
  }

  void onClassificationChanged(dynamic value) {
    selectedClassificationId = value?.toString() ?? '';
  }

  void onSubjectChanged(dynamic value) {
    selectedSubjectId = value?.toString() ?? '';
  }

  void onListCodeInput(String value) {
    listCodeFilter = value.trim();
  }

  void onSelectedCodesChange(List<String> values) {
    selectedCodes = List<String>.from(values);
  }

  void onSelectedTagFilterChange(List<dynamic> values) {
    selectedTagFilterIds = List<dynamic>.from(values);
  }

  Future<void> onTableRequest(Filters filters) async {
    tableFilters = filters;
    await _loadWorkItems();
  }

  void clearFilters() {
    digitalFilter = null;
    requesterQuery = '';
    selectedClassificationId = '';
    selectedSubjectId = '';
    listCodeFilter = '';
    selectedCodes = <String>[];
    selectedTagFilterIds = <dynamic>[];
    includedStart = null;
    includedEnd = null;
    tableFilters = Filters(
      limit: tableFilters.limit ?? 12,
      offset: 0,
      orderBy: 'lastMovementSort',
      orderDir: 'desc',
      searchString: null,
    );
    _syncSubjectOptions();
    _lastFilterSignature = _buildFilterSignature();
    queueTable?.unSelectAll();
    _loadWorkItems();
  }

  void applyPrimaryAction() {
    final selectedRows = queueTable?.getAllSelected<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    if (selectedRows.isEmpty) {
      lastActionText = _isEnglishLocale
          ? 'Select at least one row to simulate the routing action.'
          : 'Selecione ao menos uma linha para simular a acao principal.';
      return;
    }

    lastActionText = _isEnglishLocale
        ? 'Simulated action applied to ${selectedRows.length} items.'
        : 'Acao simulada aplicada a ${selectedRows.length} itens.';
  }

  void openRecordPreview(Map<String, dynamic> record) {
    lastActionText = _isEnglishLocale
        ? 'Preview opened for ${record['fullCode']}.'
        : 'Visualizacao simulada para ${record['fullCode']}.';
  }

  void openTagManager(Map<String, dynamic> record) {
    activeRecordId = record['id'] as int;
    activeRecordTagIds = List<dynamic>.from(record['tagIds'] as List<dynamic>);
    tagModal?.open();
  }

  void onTagManagerSelectionChange(List<dynamic> values) {
    activeRecordTagIds = List<dynamic>.from(values);
  }

  void applyTagsToActiveRecord(LiTagSelectionChange change) {
    final record = _findRecordById(activeRecordId);
    if (record == null) {
      return;
    }

    final nextTagIds = List<dynamic>.from(change.values);
    record['tagIds'] = nextTagIds;
    record['tags'] = _resolveTagsFromIds(nextTagIds);
    activeRecordTagIds = nextTagIds;
    tagModal?.close();
    lastActionText = _isEnglishLocale
        ? 'Labels updated for ${record['fullCode']}.'
        : 'Etiquetas atualizadas para ${record['fullCode']}.';
    _loadWorkItems();
  }

  void createTag(LiTagSaveRequest request) {
    final nextId = tagCatalog.fold<int>(
          0,
          (int currentMax, Map<String, dynamic> item) =>
              (item['id'] as int) > currentMax ? item['id'] as int : currentMax,
        ) +
        1;

    final nextTag = <String, dynamic>{
      'id': nextId,
      'name': request.value['name'] ?? request.value['label'] ?? '',
      'color': request.value['color'] ?? liDefaultTagColor,
    };

    tagCatalog = <Map<String, dynamic>>[
      ...tagCatalog,
      nextTag,
    ];
    lastActionText = _isEnglishLocale
        ? 'Label "${nextTag['name']}" created.'
        : 'Etiqueta "${nextTag['name']}" criada.';
  }

  void updateTag(LiTagSaveRequest request) {
    final original = request.originalValue;
    final originalMap = original is Map<String, dynamic> ? original : null;
    final targetId = (originalMap?['id'] ?? request.value['id']) as int?;
    if (targetId == null) {
      return;
    }

    tagCatalog = tagCatalog.map((Map<String, dynamic> tag) {
      if (tag['id'] != targetId) {
        return tag;
      }
      return <String, dynamic>{
        ...tag,
        'name': request.value['name'] ?? request.value['label'] ?? tag['name'],
        'color': request.value['color'] ?? tag['color'],
      };
    }).toList(growable: false);

    for (final record in _allRecords) {
      record['tags'] = _resolveTagsFromIds(record['tagIds'] as List<dynamic>);
    }

    lastActionText = _isEnglishLocale
        ? 'Label updated successfully.'
        : 'Etiqueta atualizada com sucesso.';
    _loadWorkItems();
  }

  void deleteTag(LiTagDeleteRequest request) {
    final original = request.originalValue;
    final originalMap = original is Map<String, dynamic> ? original : null;
    final targetId = (originalMap?['id'] ?? request.value['id']) as int?;
    if (targetId == null) {
      return;
    }

    tagCatalog = tagCatalog
        .where((Map<String, dynamic> tag) => tag['id'] != targetId)
        .toList(growable: false);

    activeRecordTagIds = activeRecordTagIds
        .where((dynamic value) => value != targetId)
        .toList(growable: false);
    selectedTagFilterIds = selectedTagFilterIds
        .where((dynamic value) => value != targetId)
        .toList(growable: false);

    for (final record in _allRecords) {
      final tagIds = List<dynamic>.from(record['tagIds'] as List<dynamic>)
        ..removeWhere((dynamic value) => value == targetId);
      record['tagIds'] = tagIds;
      record['tags'] = _resolveTagsFromIds(tagIds);
    }

    lastActionText = _isEnglishLocale
        ? 'Label removed from the catalog and affected rows.'
        : 'Etiqueta removida do catalogo e das linhas afetadas.';
    _loadWorkItems();
  }

  void onTagFilterReloadRequest() {
    lastActionText = _isEnglishLocale
        ? 'Catalog refresh simulated.'
        : 'Recarregamento do catalogo simulado.';
  }

  Map<String, dynamic>? _findRecordById(int? id) {
    if (id == null) {
      return null;
    }
    for (final record in _allRecords) {
      if (record['id'] == id) {
        return record;
      }
    }
    return null;
  }

  Future<void> _loadWorkItems() async {
    final requestVersion = ++_loadRequestVersion;
    final filteredRecords = _applyExternalFilters(_allRecords);
    final service = DatatableDemoService(filteredRecords);
    final result = await service.query(tableFilters);

    if (requestVersion != _loadRequestVersion) {
      return;
    }

    workItems = result;
  }

  List<Map<String, dynamic>> _applyExternalFilters(
    List<Map<String, dynamic>> records,
  ) {
    final requesterFilter = requesterQuery.trim().toLowerCase();
    final codeListFilter = listCodeFilter.trim().toLowerCase();
    final selectedCodeSet = selectedCodes.toSet();
    final selectedTagSet = selectedTagFilterIds.toSet();

    return records.where((Map<String, dynamic> record) {
      if (digitalFilter != null && record['digital'] != digitalFilter) {
        return false;
      }

      if (requesterFilter.isNotEmpty) {
        final requester = (record['requester'] as String).toLowerCase();
        if (!requester.contains(requesterFilter)) {
          return false;
        }
      }

      if (selectedClassificationId.isNotEmpty &&
          record['classificationId'] != selectedClassificationId) {
        return false;
      }

      if (selectedSubjectId.isNotEmpty &&
          record['subjectId'] != selectedSubjectId) {
        return false;
      }

      if (codeListFilter.isNotEmpty) {
        final listCode = (record['listCode'] as String).toLowerCase();
        if (!listCode.contains(codeListFilter)) {
          return false;
        }
      }

      if (selectedCodeSet.isNotEmpty &&
          !selectedCodeSet.contains(record['fullCode'])) {
        return false;
      }

      if (selectedTagSet.isNotEmpty) {
        final recordTagIds = (record['tagIds'] as List<dynamic>).toSet();
        if (!recordTagIds.containsAll(selectedTagSet)) {
          return false;
        }
      }

      final includedAt = record['includedAt'] as DateTime;
      if (includedStart != null &&
          includedAt.isBefore(_atStartOfDay(includedStart!))) {
        return false;
      }
      if (includedEnd != null &&
          includedAt.isAfter(_atEndOfDay(includedEnd!))) {
        return false;
      }

      return true;
    }).map((Map<String, dynamic> record) {
      return Map<String, dynamic>.from(record)
        ..['tags'] =
            List<Map<String, dynamic>>.from(record['tags'] as List<dynamic>)
        ..['tagIds'] = List<dynamic>.from(record['tagIds'] as List<dynamic>);
    }).toList(growable: false);
  }

  void _syncSubjectOptions() {
    final optionsByClassification = _isEnglishLocale
        ? _subjectOptionsByClassificationEn
        : _subjectOptionsByClassificationPt;
    final nextOptions = optionsByClassification[selectedClassificationId] ??
        optionsByClassification[''] ??
        const <Map<String, dynamic>>[];
    final nextIds = nextOptions
        .map((Map<String, dynamic> item) => item['id']?.toString() ?? '')
        .toSet();

    if (!nextIds.contains(selectedSubjectId)) {
      selectedSubjectId = '';
    }

    if (identical(subjectOptions, nextOptions)) {
      return;
    }

    subjectOptions = nextOptions;
  }

  String _buildFilterSignature() {
    return <String>[
      digitalFilter?.toString() ?? 'null',
      requesterQuery.trim(),
      selectedClassificationId,
      selectedSubjectId,
      listCodeFilter.trim(),
      selectedCodes.join('|'),
      selectedTagFilterIds.join('|'),
      includedStart?.toIso8601String() ?? '',
      includedEnd?.toIso8601String() ?? '',
    ].join('::');
  }

  List<Map<String, dynamic>> _resolveTagsFromIds(List<dynamic> tagIds) {
    final tagIdSet = tagIds.toSet();
    return tagCatalog
        .where((Map<String, dynamic> tag) => tagIdSet.contains(tag['id']))
        .map((Map<String, dynamic> tag) => Map<String, dynamic>.from(tag))
        .toList(growable: false);
  }

  DatatableSettings _buildDatatableSettings({required bool isEnglish}) {
    return DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'fullCode',
          title: isEnglish ? 'Code' : 'Codigo',
          sortingBy: 'fullCode',
          enableSorting: true,
        ),
        DatatableCol(
          key: 'requester',
          title: isEnglish ? 'Requester' : 'Solicitante',
          sortingBy: 'requester',
          enableSorting: true,
        ),
        DatatableCol(
          key: 'classificationLabel',
          title: isEnglish ? 'Classification' : 'Classificacao',
          sortingBy: 'classificationLabel',
          enableSorting: true,
          hideOnMobile: true,
        ),
        DatatableCol(
          key: 'subjectLabel',
          title: isEnglish ? 'Subject' : 'Assunto',
          sortingBy: 'subjectLabel',
          enableSorting: true,
        ),
        DatatableCol(
          key: 'lastMovement',
          title: isEnglish ? 'Last movement' : 'Ultimo andamento',
          format: DatatableFormat.dateTimeShort,
          sortingBy: 'lastMovementSort',
          enableSorting: true,
        ),
        DatatableCol(
          key: 'digital',
          title: 'Digital',
          format: DatatableFormat.boolHighlightedBadge,
          sortingBy: 'digital',
          enableSorting: true,
          width: '110px',
        ),
        DatatableCol(
          key: 'tags',
          title: isEnglish ? 'Labels' : 'Etiquetas',
          customRenderHtml:
              (Map<String, dynamic> itemMap, dynamic itemInstance) {
            final wrapper = html.DivElement()
              ..classes.addAll(<String>['d-flex', 'flex-wrap', 'gap-1']);
            final tags = itemMap['tags'] as List<dynamic>? ?? const <dynamic>[];
            if (tags.isEmpty) {
              return html.SpanElement()
                ..classes.add('text-muted')
                ..text = '-';
            }

            for (final rawTag in tags) {
              if (rawTag is! Map) {
                continue;
              }

              final tag = rawTag.map(
                (dynamic key, dynamic value) => MapEntry(key.toString(), value),
              );
              wrapper.append(
                html.SpanElement()
                  ..classes.addAll(<String>['badge', 'rounded-pill'])
                  ..text = tag['name']?.toString() ?? ''
                  ..style.background =
                      tag['color']?.toString() ?? liDefaultTagColor,
              );
            }

            return wrapper;
          },
        ),
        DatatableCol(
          key: 'actions',
          title: isEnglish ? 'Actions' : 'Acoes',
          customRenderHtml:
              (Map<String, dynamic> itemMap, dynamic itemInstance) {
            final previewButton = html.ButtonElement()
              ..type = 'button'
              ..title = isEnglish ? 'Preview' : 'Visualizar'
              ..classes.addAll(<String>[
                'btn',
                'btn-flat-primary',
                'border-transparent',
                'btn-icon',
                'btn-sm',
              ])
              ..appendHtml('<i class="ph ph-eye"></i>');
            previewButton.onClick.listen((html.MouseEvent event) {
              event.stopPropagation();
              _ngZone.run(() {
                openRecordPreview(itemMap);
              });
            });

            final tagButton = html.ButtonElement()
              ..type = 'button'
              ..title = isEnglish ? 'Labels' : 'Etiquetas'
              ..classes.addAll(<String>[
                'btn',
                'btn-flat-primary',
                'border-transparent',
                'btn-icon',
                'btn-sm',
              ])
              ..appendHtml('<i class="ph ph-tag"></i>');
            tagButton.onClick.listen((html.MouseEvent event) {
              event.stopPropagation();
              _ngZone.run(() {
                openTagManager(itemMap);
              });
            });

            final wrapper = html.DivElement()
              ..classes.addAll(<String>['d-flex', 'flex-wrap', 'gap-1']);
            wrapper
              ..append(previewButton)
              ..append(tagButton);
            return wrapper;
          },
        ),
      ],
    );
  }

  static List<DatatableSearchField> _buildSearchFields({
    required bool isEnglish,
  }) {
    return <DatatableSearchField>[
      DatatableSearchField(
        field: 'fullCode',
        operator: '=',
        label: isEnglish ? 'Code' : 'Codigo',
      ),
      DatatableSearchField(
        field: 'requester',
        operator: 'like',
        label: isEnglish ? 'Requester' : 'Solicitante',
      ),
      DatatableSearchField(
        field: 'subjectLabel',
        operator: 'like',
        label: isEnglish ? 'Subject' : 'Assunto',
      ),
    ];
  }

  static List<Map<String, dynamic>> _buildClassificationOptions({
    required bool isEnglish,
  }) {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'id': '',
        'label': isEnglish ? 'Select to filter' : 'Selecione para filtrar',
      },
      <String, dynamic>{
        'id': 'request',
        'label': isEnglish ? 'Request' : 'Solicitacao',
      },
      <String, dynamic>{
        'id': 'contract',
        'label': isEnglish ? 'Contract' : 'Contrato',
      },
      <String, dynamic>{
        'id': 'service',
        'label': isEnglish ? 'Service' : 'Atendimento',
      },
    ];
  }

  static Map<String, List<Map<String, dynamic>>>
      _buildSubjectOptionsByClassification({
    required bool isEnglish,
  }) {
    final firstClassificationLabel = isEnglish
        ? 'Select a classification first'
        : 'Selecione uma classificacao antes';
    final filterLabel =
        isEnglish ? 'Select to filter' : 'Selecione para filtrar';

    List<Map<String, dynamic>> buildOptions(
      String leadingLabel,
      List<Map<String, dynamic>> items,
    ) {
      return <Map<String, dynamic>>[
        <String, dynamic>{'id': '', 'label': leadingLabel},
        ...items,
      ];
    }

    return <String, List<Map<String, dynamic>>>{
      '': buildOptions(
          firstClassificationLabel, const <Map<String, dynamic>>[]),
      'request': buildOptions(filterLabel, <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'onboarding',
          'label': isEnglish ? 'Demand intake' : 'Entrada de demanda',
        },
        <String, dynamic>{
          'id': 'review',
          'label': isEnglish ? 'Document review' : 'Revisao documental',
        },
      ]),
      'contract': buildOptions(filterLabel, <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'renewal',
          'label': isEnglish ? 'Contract renewal' : 'Renovacao contratual',
        },
        <String, dynamic>{
          'id': 'amendment',
          'label': isEnglish ? 'Internal amendment' : 'Aditivo interno',
        },
      ]),
      'service': buildOptions(filterLabel, <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'support',
          'label': isEnglish ? 'Operational support' : 'Apoio operacional',
        },
        <String, dynamic>{
          'id': 'triage',
          'label': isEnglish ? 'Initial triage' : 'Triagem inicial',
        },
      ]),
    };
  }

  static List<Map<String, dynamic>> _buildTagCatalog() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'name': 'Aguardando analise',
        'color': '#f4511e'
      },
      <String, dynamic>{'id': 2, 'name': 'Apoio interno', 'color': '#43a047'},
      <String, dynamic>{'id': 3, 'name': 'Assessoria', 'color': '#d81b60'},
      <String, dynamic>{
        'id': 4,
        'name': 'Calculo de verba',
        'color': '#1e88e5'
      },
      <String, dynamic>{'id': 5, 'name': 'Cessao', 'color': '#c0ca33'},
    ];
  }

  static List<Map<String, dynamic>> _buildSeedRecords() {
    return <Map<String, dynamic>>[
      _record(
        id: 1,
        fullCode: '35910/2011',
        requester: 'Helena Maria Nica Scatolini',
        classificationId: 'request',
        classificationLabel: 'Solicitacao',
        subjectId: 'onboarding',
        subjectLabel: 'Entrada de demanda',
        digital: false,
        includedAt: DateTime(2017, 1, 20, 9, 0),
        lastMovement: DateTime(2017, 1, 27, 10, 0),
        listCode: '1624',
        tagIds: <int>[1, 2],
      ),
      _record(
        id: 2,
        fullCode: '40596/2012',
        requester: 'Tatiane Pacheco da Silva',
        classificationId: 'request',
        classificationLabel: 'Solicitacao',
        subjectId: 'review',
        subjectLabel: 'Revisao documental',
        digital: false,
        includedAt: DateTime(2017, 1, 21, 8, 30),
        lastMovement: DateTime(2017, 1, 27, 10, 0),
        listCode: '1624',
        tagIds: <int>[3],
      ),
      _record(
        id: 3,
        fullCode: '33512/2012',
        requester: 'Vanderlea Moreira Jorge Duarte',
        classificationId: 'contract',
        classificationLabel: 'Contrato',
        subjectId: 'renewal',
        subjectLabel: 'Renovacao contratual',
        digital: true,
        includedAt: DateTime(2017, 1, 22, 11, 45),
        lastMovement: DateTime(2017, 1, 28, 8, 15),
        listCode: '1842',
        tagIds: <int>[2, 4],
      ),
      _record(
        id: 4,
        fullCode: '11773/2016',
        requester: 'Zilnea Quintana Fernandes',
        classificationId: 'contract',
        classificationLabel: 'Contrato',
        subjectId: 'amendment',
        subjectLabel: 'Aditivo interno',
        digital: false,
        includedAt: DateTime(2017, 1, 23, 14, 10),
        lastMovement: DateTime(2017, 1, 29, 16, 40),
        listCode: '1842',
        tagIds: <int>[5],
      ),
      _record(
        id: 5,
        fullCode: '39326/2012',
        requester: 'Secretaria de Gestao de Pessoas',
        classificationId: 'service',
        classificationLabel: 'Atendimento',
        subjectId: 'support',
        subjectLabel: 'Apoio operacional',
        digital: false,
        includedAt: DateTime(2017, 1, 24, 13, 20),
        lastMovement: DateTime(2017, 1, 30, 9, 0),
        listCode: '2101',
        tagIds: <int>[2],
      ),
      _record(
        id: 6,
        fullCode: '34557/2012',
        requester: 'Secretaria de Gestao de Pessoas',
        classificationId: 'service',
        classificationLabel: 'Atendimento',
        subjectId: 'triage',
        subjectLabel: 'Triagem inicial',
        digital: true,
        includedAt: DateTime(2017, 1, 25, 15, 15),
        lastMovement: DateTime(2017, 1, 30, 11, 0),
        listCode: '2101',
        tagIds: <int>[4, 5],
      ),
    ].map((Map<String, dynamic> item) {
      final record = Map<String, dynamic>.from(item);
      record['tags'] = <Map<String, dynamic>>[];
      return record;
    }).toList(growable: false);
  }

  static Map<String, dynamic> _record({
    required int id,
    required String fullCode,
    required String requester,
    required String classificationId,
    required String classificationLabel,
    required String subjectId,
    required String subjectLabel,
    required bool digital,
    required DateTime includedAt,
    required DateTime lastMovement,
    required String listCode,
    required List<int> tagIds,
  }) {
    return <String, dynamic>{
      'id': id,
      'fullCode': fullCode,
      'requester': requester,
      'classificationId': classificationId,
      'classificationLabel': classificationLabel,
      'subjectId': subjectId,
      'subjectLabel': subjectLabel,
      'digital': digital,
      'includedAt': includedAt,
      'lastMovement': lastMovement,
      'lastMovementSort': lastMovement.toIso8601String(),
      'listCode': listCode,
      'tagIds': List<dynamic>.from(tagIds),
    };
  }

  static DateTime _atStartOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static DateTime _atEndOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
  }
}
