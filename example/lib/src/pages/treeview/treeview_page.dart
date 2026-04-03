import 'dart:async';

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'treeview-page',
  templateUrl: 'treeview_page.html',
  styleUrls: ['treeview_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiTreeViewComponent,
    LiTreeviewSelectComponent,
    LiTreeviewSelectNodeDirective,
    LiTreeviewSelectTriggerDirective,
  ],
)
class TreeviewPageComponent {
  TreeviewPageComponent(this.i18n)
      : treeNodes = _buildTree(i18n.t),
        staticDropdownNodes = _buildDropdownTree(i18n.t, i18n.isPortuguese),
        _lazyRootCatalog = _buildLazyRootCatalog(i18n.isPortuguese),
        rawFrameNodes = _buildRawFrameNodes(i18n.isPortuguese),
        _lazySerializableCatalog =
            _buildLazySerializableCatalog(i18n.isPortuguese) {
    rawFrameLookup = rawFrameSettings.normalize(rawFrameNodes);
  }

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get isPt => i18n.isPortuguese;

  final List<TreeViewNode> treeNodes;
  final List<TreeViewNode> staticDropdownNodes;
  final List<_LazyNodeSeed> _lazyRootCatalog;
  final DataFrame<Map<String, dynamic>> rawFrameNodes;
  late final List<TreeViewNode> rawFrameLookup;
  final List<_LazySerializableNode> _lazySerializableCatalog;

  final TreeViewSettings rawFrameSettings = const TreeViewSettings(
    idField: 'uuid',
    labelField: 'name',
    valueField: 'code',
    nodesField: 'children',
    iconField: 'icon',
    colorField: 'color',
    enabledField: 'enabled',
  );

  final TreeViewSettings lazySerializableSettings = TreeViewSettings(
    idField: 'uuid',
    labelField: 'title',
    valueField: 'code',
    nodesField: 'children',
    iconField: 'icon',
    colorField: 'color',
    enabledField: 'enabled',
    lazyChildrenResolver: (item, itemMap) => itemMap?['lazy'] == true,
  );

  dynamic selectedStaticTreeValue;
  dynamic selectedLazyTreeValue;
  dynamic selectedRawFrameValue;
  dynamic selectedLazySerializableValue;
  List<dynamic> selectedMultiTreeValues = <dynamic>[];
  String get selectedStaticTreeValueText =>
      selectedStaticTreeValue?.toString() ?? t.common.none;
  String get selectedLazyTreeValueText =>
      selectedLazyTreeValue?.toString() ?? t.common.none;
  String get selectedRawFrameValueText =>
      selectedRawFrameValue?.toString() ?? t.common.none;
  String get selectedLazySerializableValueText =>
      selectedLazySerializableValue?.toString() ?? t.common.none;
  String get selectedMultiTreeValueText => selectedMultiTreeValues.isEmpty
      ? t.common.none
      : selectedMultiTreeValues.join(', ');
  String get selectedStaticTreeLabel =>
      _resolveLabel(staticDropdownNodes, selectedStaticTreeValue) ??
      t.common.none;
  String get selectedLazyTreeLabel =>
      _resolveLazyLabel(selectedLazyTreeValue) ?? t.common.none;
  String get selectedRawFrameLabel =>
      _resolveLabel(rawFrameLookup, selectedRawFrameValue) ?? t.common.none;
  String get selectedLazySerializableLabel =>
      _resolveLazySerializableLabel(selectedLazySerializableValue) ??
      t.common.none;
  String get selectedMultiTreeLabel => selectedMultiTreeValues.isEmpty
      ? t.common.none
      : selectedMultiTreeValues
          .map((value) => _resolveLabel(staticDropdownNodes, value) ?? value)
          .join(', ');

  String customNodeLabel(TreeViewNode node) {
    final valueText = node.value?.toString() ?? (isPt ? 'grupo' : 'group');
    return '${node.treeViewNodeLabel} • $valueText';
  }

  String get descriptionBody => isPt
      ? 'O treeview organiza estruturas hierárquicas como módulos, permissões, pastas e mapas de navegação em uma única área de leitura.'
      : 'The treeview organizes hierarchical structures such as modules, permissions, folders, and navigation maps in a single reading area.';
  List<String> get features => isPt
      ? const <String>[
          'Hierarquia com pai e filhos.',
          'Busca contextual pelo placeholder configurado.',
          'Expansão e recolhimento da árvore.',
        ]
      : const <String>[
          'Hierarchy with parent and child nodes.',
          'Contextual search through the configured placeholder.',
          'Tree expand and collapse behavior.',
        ];
  List<String> get limits => isPt
      ? const <String>[
          'Estruturas muito grandes pedem estratégia de carregamento.',
          'Rótulos longos exigem cuidado com densidade visual.',
          'Regras de seleção continuam no componente pai.',
        ]
      : const <String>[
          'Very large structures call for a loading strategy.',
          'Long labels require care with visual density.',
          'Selection rules still belong in the parent component.',
        ];
  String get classicTreeTitle =>
      isPt ? 'Treeview clássico' : 'Classic treeview';
  String get classicTreeBody => isPt
      ? 'Mantém a leitura hierárquica completa na própria página, com busca local, expandir/recolher e seleção em cascata.'
      : 'Keeps the full hierarchical reading on the page itself, with local search, expand/collapse, and cascading selection.';
  String get staticSelectTitle => isPt
      ? 'Dropdown select com árvore estática'
      : 'Dropdown select with static tree';
  String get staticSelectBody => isPt
      ? 'Usa ngModel para retornar o value do nó selecionado sem abrir a árvore inteira fora do fluxo do formulário.'
      : 'Uses ngModel to return the selected node value without opening the whole tree outside the form flow.';
  String get staticSelectLabel =>
      isPt ? 'Módulo ou status' : 'Module or status';
  String get staticSearchPlaceholder =>
      isPt ? 'Buscar por módulo ou status' : 'Search by module or status';
  String get staticPlaceholder =>
      isPt ? 'Selecione um nó da árvore' : 'Select a tree node';
  String get currentValueLabel => isPt ? 'Valor atual' : 'Current value';
  String get currentLabelLabel => t.common.label;
  String get lazySelectTitle => isPt
      ? 'Dropdown select com carregamento em partes'
      : 'Dropdown select with paged loading';
  String get lazySelectBody => isPt
      ? 'O pageLoader busca apenas páginas da raiz e dos filhos expandidos. O mesmo contrato recebe searchTerm, então a busca remota já pode ser resolvida pelo backend sem materializar a árvore inteira no cliente.'
      : 'The pageLoader fetches only root pages and expanded child pages. The same contract receives searchTerm, so remote search can already be handled by the backend without materializing the whole tree on the client.';
  String get largeCatalogLabel => isPt ? 'Catálogo grande' : 'Large catalog';
  String get lazySearchPlaceholder =>
      isPt ? 'Buscar no catálogo lazy' : 'Search in the lazy catalog';
  String get lazyPlaceholder =>
      isPt ? 'Carregar catálogo por páginas' : 'Load catalog by pages';
  String get customRenderTitle => isPt
      ? 'Custom render + múltipla seleção'
      : 'Custom render + multiple selection';
  String get customRenderBody => isPt
      ? 'A API aceita TemplateRef para o trigger e para cada nó, além de labelBuilder e canSelectNode para regras de exibição e seleção.'
      : 'The API accepts TemplateRef for the trigger and for each node, plus labelBuilder and canSelectNode for display and selection rules.';
  String get finalNodesLabel =>
      isPt ? 'Nós finais do catálogo' : 'Leaf nodes from the catalog';
  String get multiPlaceholder => isPt
      ? 'Selecione um ou mais nós finais'
      : 'Select one or more leaf nodes';
  String get readonlyBadge => isPt ? 'Somente leitura' : 'Read only';
  String get currentValuesLabel => isPt ? 'Valores atuais' : 'Current values';
  String get currentLabelsLabel => isPt ? 'Rótulos' : 'Labels';
  String get rawFrameTitle =>
      isPt ? 'DataFrame<Map> com settings' : 'DataFrame<Map> with settings';
  String get rawFrameBody => isPt
      ? 'O mesmo componente recebe DataFrame<Map<String, dynamic>> e usa settings para mapear uuid, name, code e children sem converter a árvore manualmente.'
      : 'The same component accepts DataFrame<Map<String, dynamic>> and uses settings to map uuid, name, code, and children without manually converting the tree.';
  String get rawFrameLabel =>
      isPt ? 'Catálogo por DataFrame' : 'Catalog from DataFrame';
  String get rawFramePlaceholder => isPt
      ? 'Selecione um item do DataFrame'
      : 'Select an item from the DataFrame';
  String get rawFrameSearchPlaceholder =>
      isPt ? 'Buscar no DataFrame mapeado' : 'Search in the mapped DataFrame';
  String get rawLazyTitle => isPt
      ? 'Lazy bruto com SerializeBase'
      : 'Raw lazy mode with SerializeBase';
  String get rawLazyBody => isPt
      ? 'O pageLoader pode retornar TreeViewLoadResult.raw(items: ...) com DataFrame<SerializeBase>. O settings reutiliza o mesmo mapeamento do modo estático para montar os nós paginados.'
      : 'The pageLoader can return TreeViewLoadResult.raw(items: ...) with DataFrame<SerializeBase>. Settings reuses the same mapping from static mode to build paged nodes.';
  String get rawLazyLabel =>
      isPt ? 'Catálogo remoto bruto' : 'Raw remote catalog';
  String get rawLazyPlaceholder => isPt
      ? 'Carregar catálogo bruto por páginas'
      : 'Load raw catalog by pages';
  String get rawLazySearchPlaceholder =>
      isPt ? 'Buscar no catálogo bruto' : 'Search in the raw catalog';
  String get apiIntro => isPt
      ? 'Use o componente para representar relações hierárquicas quando a leitura por níveis for mais clara do que uma tabela simples.'
      : 'Use the component to represent hierarchical relationships when level-based reading is clearer than a simple table.';
  List<String> get apiItems => isPt
      ? const <String>[
          '[data] recebe a lista hierárquica de nós.',
          '[settings] mapeia id, label, value, nodes, icon, color e enabled quando os dados chegam como Map, DataFrame ou SerializeBase.',
          '[searchPlaceholder] ajusta o texto da busca.',
          'A expansão e o recolhimento são controlados pela estrutura da árvore.',
          'O componente é indicado para navegação técnica, permissões e catálogos.',
          'li-treeview-select oferece seleção única em dropdown com ngModel.',
          '[multiple] troca o modelo para List<dynamic> e mantém o dropdown aberto se [closeOnSelect]="false".',
          '[pageLoader] permite carregar páginas da raiz e dos filhos sob demanda.',
          'TreeViewLoadResult.raw(items: ...) permite que o pageLoader devolva payload bruto e delegue a conversão para o settings.',
          '[labelBuilder] e [canSelectNode] customizam rótulo e regra de seleção.',
          'template[liTreeviewSelectNode] e template[liTreeviewSelectTrigger] permitem custom render.',
          '[pageSize] controla quantos nós entram por lote em cada expansão.',
        ]
      : const <String>[
          '[data] receives the hierarchical node list.',
          '[settings] maps id, label, value, nodes, icon, color, and enabled when data comes as Map, DataFrame, or SerializeBase.',
          '[searchPlaceholder] adjusts the search text.',
          'Expand and collapse are controlled by the tree structure.',
          'The component fits technical navigation, permissions, and catalogs.',
          'li-treeview-select offers single selection in a dropdown with ngModel.',
          '[multiple] switches the model to List<dynamic> and keeps the dropdown open when [closeOnSelect]="false".',
          '[pageLoader] allows loading root and child pages on demand.',
          'TreeViewLoadResult.raw(items: ...) lets pageLoader return raw payloads and delegates conversion to settings.',
          '[labelBuilder] and [canSelectNode] customize labels and selection rules.',
          'template[liTreeviewSelectNode] and template[liTreeviewSelectTrigger] enable custom rendering.',
          '[pageSize] controls how many nodes are loaded per expansion batch.',
        ];

  static DataFrame<Map<String, dynamic>> _buildRawFrameNodes(bool isPt) {
    return DataFrame<Map<String, dynamic>>(
      items: <Map<String, dynamic>>[
        <String, dynamic>{
          'uuid': 'benefits',
          'name': isPt ? 'Benefícios' : 'Benefits',
          'code': 'benefits',
          'icon': 'ph ph-tree-structure',
          'children': <Map<String, dynamic>>[
            <String, dynamic>{
              'uuid': 'basket',
              'name': isPt ? 'Cesta básica' : 'Food basket',
              'code': 'basket',
              'icon': 'ph ph-package',
              'children': <Map<String, dynamic>>[
                <String, dynamic>{
                  'uuid': 'approved',
                  'name': isPt ? 'Aprovado' : 'Approved',
                  'code': 'approved',
                  'color': 'var(--success)',
                  'enabled': true,
                },
                <String, dynamic>{
                  'uuid': 'archived',
                  'name': isPt ? 'Arquivado' : 'Archived',
                  'code': 'archived',
                  'enabled': false,
                },
              ],
            },
            <String, dynamic>{
              'uuid': 'rent',
              'name': isPt ? 'Auxílio aluguel' : 'Rent aid',
              'code': 'rent',
            },
          ],
        },
      ],
      totalRecords: 1,
    );
  }

  static List<_LazySerializableNode> _buildLazySerializableCatalog(bool isPt) =>
      <_LazySerializableNode>[
        _LazySerializableNode(
          uuid: 'service',
          title: isPt ? 'Atendimento' : 'Support',
          code: 'service',
          icon: 'ph ph-headset',
          lazy: true,
          children: <_LazySerializableNode>[
            _LazySerializableNode(
              uuid: 'triage',
              title: isPt ? 'Triagem' : 'Triage',
              code: 'triage',
            ),
            _LazySerializableNode(
              uuid: 'returns',
              title: isPt ? 'Retornos' : 'Follow-ups',
              code: 'returns',
            ),
          ],
        ),
        _LazySerializableNode(
          uuid: 'benefits',
          title: isPt ? 'Benefícios' : 'Benefits',
          code: 'benefits',
          icon: 'ph ph-tree-structure',
          lazy: true,
          children: <_LazySerializableNode>[
            _LazySerializableNode(
              uuid: 'basket',
              title: isPt ? 'Cesta básica' : 'Food basket',
              code: 'basket',
              icon: 'ph ph-package',
              lazy: true,
              children: <_LazySerializableNode>[
                _LazySerializableNode(
                  uuid: 'approved',
                  title: isPt ? 'Aprovado' : 'Approved',
                  code: 'approved',
                  color: 'var(--success)',
                ),
                _LazySerializableNode(
                  uuid: 'readonly',
                  title: isPt ? 'Somente leitura' : 'Read only',
                  code: 'readonly',
                  enabled: false,
                ),
              ],
            ),
            _LazySerializableNode(
              uuid: 'rent',
              title: isPt ? 'Auxílio aluguel' : 'Rent aid',
              code: 'rent',
            ),
          ],
        ),
        _LazySerializableNode(
          uuid: 'registers',
          title: isPt ? 'Cadastros' : 'Registrations',
          code: 'registers',
          lazy: true,
          children: <_LazySerializableNode>[
            _LazySerializableNode(
              uuid: 'families',
              title: isPt ? 'Famílias' : 'Families',
              code: 'families',
            ),
          ],
        ),
      ];

  static List<_LazyNodeSeed> _buildLazyRootCatalog(bool isPt) =>
      <_LazyNodeSeed>[
        _LazyNodeSeed(
          id: 'atendimento',
          label: isPt ? 'Atendimento' : 'Support',
          lazy: true,
          children: <_LazyNodeSeed>[
            _LazyNodeSeed(
                id: 'atendimento-triagem', label: isPt ? 'Triagem' : 'Triage'),
            _LazyNodeSeed(
                id: 'atendimento-plantao',
                label: isPt ? 'Plantão social' : 'On-call desk'),
            _LazyNodeSeed(
                id: 'atendimento-retornos',
                label: isPt ? 'Retornos' : 'Follow-ups'),
            _LazyNodeSeed(
                id: 'atendimento-visitas',
                label: isPt ? 'Visitas técnicas' : 'Technical visits'),
          ],
        ),
        _LazyNodeSeed(
          id: 'beneficios',
          label: isPt ? 'Benefícios' : 'Benefits',
          lazy: true,
          children: <_LazyNodeSeed>[
            _LazyNodeSeed(
              id: 'beneficios-cesta',
              label: isPt ? 'Cesta básica' : 'Food basket',
              lazy: true,
              children: <_LazyNodeSeed>[
                _LazyNodeSeed(
                    id: 'beneficios-cesta-analise',
                    label: isPt ? 'Em análise' : 'Under review'),
                _LazyNodeSeed(
                    id: 'beneficios-cesta-aprovado',
                    label: isPt ? 'Aprovado' : 'Approved'),
                _LazyNodeSeed(
                    id: 'beneficios-cesta-entregue',
                    label: isPt ? 'Entregue' : 'Delivered'),
              ],
            ),
            _LazyNodeSeed(
                id: 'beneficios-aluguel',
                label: isPt ? 'Auxílio aluguel' : 'Rent aid'),
            _LazyNodeSeed(
                id: 'beneficios-passagem',
                label: isPt ? 'Passagem eventual' : 'Temporary ticket'),
          ],
        ),
        _LazyNodeSeed(
          id: 'cadastros',
          label: isPt ? 'Cadastros' : 'Registrations',
          lazy: true,
          children: <_LazyNodeSeed>[
            _LazyNodeSeed(
                id: 'cadastros-familias',
                label: isPt ? 'Famílias' : 'Families'),
            _LazyNodeSeed(
                id: 'cadastros-territorios',
                label: isPt ? 'Territórios' : 'Territories'),
            _LazyNodeSeed(
                id: 'cadastros-documentos',
                label: isPt ? 'Documentos' : 'Documents'),
          ],
        ),
        _LazyNodeSeed(
          id: 'relatorios',
          label: isPt ? 'Relatórios' : 'Reports',
          lazy: true,
          children: <_LazyNodeSeed>[
            _LazyNodeSeed(
                id: 'relatorios-diario', label: isPt ? 'Diário' : 'Daily'),
            _LazyNodeSeed(
                id: 'relatorios-semanal', label: isPt ? 'Semanal' : 'Weekly'),
            _LazyNodeSeed(
                id: 'relatorios-mensal', label: isPt ? 'Mensal' : 'Monthly'),
          ],
        ),
        _LazyNodeSeed(
          id: 'configuracoes',
          label: isPt ? 'Configurações' : 'Settings',
          lazy: true,
          children: <_LazyNodeSeed>[
            _LazyNodeSeed(
                id: 'configuracoes-permissoes',
                label: isPt ? 'Permissões' : 'Permissions'),
            _LazyNodeSeed(
                id: 'configuracoes-perfis',
                label: isPt ? 'Perfis' : 'Profiles'),
            _LazyNodeSeed(
                id: 'configuracoes-integracoes',
                label: isPt ? 'Integrações' : 'Integrations'),
          ],
        ),
      ];

  static List<TreeViewNode> _buildTree(Messages t) {
    final atendimento = TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeService,
      treeViewNodeLevel: 0,
    );
    atendimento.addChild(TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeTriage,
      treeViewNodeLevel: 1,
      value: 'triagem',
    ));
    atendimento.addChild(TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeReferrals,
      treeViewNodeLevel: 1,
      value: 'encaminhamentos',
    ));

    final beneficios = TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeBenefits,
      treeViewNodeLevel: 0,
    );
    final cestaBasica = TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeFoodBasket,
      treeViewNodeLevel: 1,
      value: 'cesta-basica',
    );
    cestaBasica.addChild(TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeReview,
      treeViewNodeLevel: 2,
      value: 'analise',
    ));
    cestaBasica.addChild(TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeApproved,
      treeViewNodeLevel: 2,
      value: 'aprovado',
    ));
    beneficios.addChild(cestaBasica);
    beneficios.addChild(TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeRentAid,
      treeViewNodeLevel: 1,
      value: 'auxilio-aluguel',
    ));

    return <TreeViewNode>[atendimento, beneficios];
  }

  static List<TreeViewNode> _buildDropdownTree(Messages t, bool isPt) {
    final atendimento = TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeService,
      treeViewNodeLevel: 0,
      value: 'atendimento',
    );
    atendimento.addChild(TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeTriage,
      treeViewNodeLevel: 1,
      value: 'triagem',
    ));
    atendimento.addChild(TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeReferrals,
      treeViewNodeLevel: 1,
      value: 'encaminhamentos',
    ));

    final beneficios = TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeBenefits,
      treeViewNodeLevel: 0,
      value: 'beneficios',
    );
    final cestaBasica = TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeFoodBasket,
      treeViewNodeLevel: 1,
      value: 'cesta-basica',
    );
    cestaBasica.addChild(TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeReview,
      treeViewNodeLevel: 2,
      value: 'analise',
    ));
    cestaBasica.addChild(TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeApproved,
      treeViewNodeLevel: 2,
      value: 'aprovado',
    ));
    beneficios.addChild(cestaBasica);
    beneficios.addChild(TreeViewNode(
      treeViewNodeLabel: t.pages.treeview.nodeRentAid,
      treeViewNodeLevel: 1,
      value: 'auxilio-aluguel',
    ));

    final cadastros = TreeViewNode(
      treeViewNodeLabel: isPt ? 'Cadastros' : 'Registrations',
      treeViewNodeLevel: 0,
      value: 'cadastros',
    );
    cadastros.addChild(TreeViewNode(
      treeViewNodeLabel: isPt ? 'Famílias' : 'Families',
      treeViewNodeLevel: 1,
      value: 'familias',
    ));
    cadastros.addChild(TreeViewNode(
      treeViewNodeLabel: isPt ? 'Territórios' : 'Territories',
      treeViewNodeLevel: 1,
      value: 'territorios',
    ));

    return <TreeViewNode>[atendimento, beneficios, cadastros];
  }

  Future<TreeViewLoadResult> loadTreeChunk(TreeViewLoadRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    final search = request.searchTerm.trim().toLowerCase();
    final children = request.parent == null
        ? _lazyRootCatalog
        : (_findLazySeed(request.parent!.value?.toString())?.children ??
            <_LazyNodeSeed>[]);
    final filtered = children.where((node) {
      if (search.isEmpty) {
        return true;
      }
      return node.label.toLowerCase().contains(search);
    }).toList(growable: false);

    final start = request.offset.clamp(0, filtered.length);
    final end = (start + request.limit).clamp(0, filtered.length);
    final slice = filtered.sublist(start, end);

    return TreeViewLoadResult(
      nodes: slice.map((seed) {
        return TreeViewNode(
          treeViewNodeLabel: seed.label,
          treeViewNodeLevel: request.parent == null
              ? 0
              : request.parent!.treeViewNodeLevel + 1,
          value: seed.id,
          treeViewNodeHasLazyChildren: seed.lazy,
          treeViewNodeHasMoreChildren: seed.lazy && seed.children.isNotEmpty,
        );
      }).toList(growable: false),
      hasMore: end < filtered.length,
    );
  }

  Future<TreeViewLoadResult> loadRawTreeChunk(
      TreeViewLoadRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    final search = request.searchTerm.trim().toLowerCase();
    final children = request.parent == null
        ? _lazySerializableCatalog
        : (_findLazySerializableSeed(request.parent!.id?.toString())
                ?.children ??
            <_LazySerializableNode>[]);
    final filtered = children.where((node) {
      if (search.isEmpty) {
        return true;
      }
      return node.title.toLowerCase().contains(search);
    }).toList(growable: false);

    final start = request.offset.clamp(0, filtered.length);
    final end = (start + request.limit).clamp(0, filtered.length);
    final slice = filtered.sublist(start, end);

    return TreeViewLoadResult.raw(
      items: DataFrame<_LazySerializableNode>(
        items: slice
            .map((node) => _toLazySerializablePayload(node))
            .toList(growable: false),
        totalRecords: filtered.length,
      ),
      hasMore: end < filtered.length,
    );
  }

  static _LazySerializableNode _toLazySerializablePayload(
    _LazySerializableNode node,
  ) {
    return _LazySerializableNode(
      uuid: node.uuid,
      title: node.title,
      code: node.code,
      icon: node.icon,
      color: node.color,
      enabled: node.enabled,
      lazy: node.children.isNotEmpty,
    );
  }

  _LazyNodeSeed? _findLazySeed(String? id) {
    if (id == null) {
      return null;
    }

    _LazyNodeSeed? walk(Iterable<_LazyNodeSeed> nodes) {
      for (final node in nodes) {
        if (node.id == id) {
          return node;
        }
        final found = walk(node.children);
        if (found != null) {
          return found;
        }
      }
      return null;
    }

    return walk(_lazyRootCatalog);
  }

  _LazySerializableNode? _findLazySerializableSeed(String? id) {
    if (id == null) {
      return null;
    }

    _LazySerializableNode? walk(Iterable<_LazySerializableNode> nodes) {
      for (final node in nodes) {
        if (node.uuid == id) {
          return node;
        }
        final found = walk(node.children);
        if (found != null) {
          return found;
        }
      }
      return null;
    }

    return walk(_lazySerializableCatalog);
  }

  String? _resolveLabel(List<TreeViewNode> nodes, dynamic value) {
    if (value == null) {
      return null;
    }

    TreeViewNode? walk(Iterable<TreeViewNode> current) {
      for (final node in current) {
        if (node.value == value) {
          return node;
        }
        final found = walk(node.treeViewNodes);
        if (found != null) {
          return found;
        }
      }
      return null;
    }

    final fromTree = walk(nodes);
    if (fromTree != null) {
      return fromTree.treeViewNodeLabel;
    }

    final fromCatalog = _findLazySeed(value?.toString());
    return fromCatalog?.label;
  }

  String? _resolveLazyLabel(dynamic value) {
    return _findLazySeed(value?.toString())?.label;
  }

  String? _resolveLazySerializableLabel(dynamic value) {
    return _findLazySerializableSeed(value?.toString())?.title;
  }

  bool canSelectOnlyLeafNodes(TreeViewNode node) => node.treeViewNodes.isEmpty;
}

class _LazyNodeSeed {
  const _LazyNodeSeed({
    required this.id,
    required this.label,
    this.lazy = false,
    this.children = const <_LazyNodeSeed>[],
  });

  final String id;
  final String label;
  final bool lazy;
  final List<_LazyNodeSeed> children;
}

class _LazySerializableNode implements SerializeBase {
  const _LazySerializableNode({
    required this.uuid,
    required this.title,
    required this.code,
    this.icon,
    this.color,
    this.enabled = true,
    this.lazy = false,
    this.children = const <_LazySerializableNode>[],
  });

  final String uuid;
  final String title;
  final String code;
  final String? icon;
  final String? color;
  final bool enabled;
  final bool lazy;
  final List<_LazySerializableNode> children;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'title': title,
      'code': code,
      'icon': icon,
      'color': color,
      'enabled': enabled,
      'lazy': lazy,
      'children':
          children.map((child) => child.toMap()).toList(growable: false),
    };
  }
}
