import 'dart:async';

import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'treeview-page',
  templateUrl: 'treeview_page.html',
  styleUrls: ['treeview_page.css'],
  directives: [
    coreDirectives,
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
        staticDropdownNodes = _buildDropdownTree(i18n.t);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  final List<TreeViewNode> treeNodes;
  final List<TreeViewNode> staticDropdownNodes;

  dynamic selectedStaticTreeValue;
  dynamic selectedLazyTreeValue;
  List<dynamic> selectedMultiTreeValues = <dynamic>[];

  String get selectedStaticTreeValueText =>
      selectedStaticTreeValue?.toString() ?? 'Nenhum';

  String get selectedLazyTreeValueText =>
      selectedLazyTreeValue?.toString() ?? 'Nenhum';

  String get selectedMultiTreeValueText => selectedMultiTreeValues.isEmpty
      ? 'Nenhum'
      : selectedMultiTreeValues.join(', ');

  String get selectedStaticTreeLabel =>
      _resolveLabel(staticDropdownNodes, selectedStaticTreeValue) ?? 'Nenhum';

  String get selectedLazyTreeLabel =>
      _resolveLazyLabel(selectedLazyTreeValue) ?? 'Nenhum';

  String get selectedMultiTreeLabel => selectedMultiTreeValues.isEmpty
      ? 'Nenhum'
      : selectedMultiTreeValues
          .map((value) => _resolveLabel(staticDropdownNodes, value) ?? value)
          .join(', ');

  String customNodeLabel(TreeViewNode node) {
    final valueText = node.value?.toString() ?? 'grupo';
    return '${node.treeViewNodeLabel} • $valueText';
  }

  bool canSelectOnlyLeafNodes(TreeViewNode node) => !node.canExpand;

  static final List<_LazyNodeSeed> _lazyRootCatalog = <_LazyNodeSeed>[
    _LazyNodeSeed(
      id: 'atendimento',
      label: 'Atendimento',
      lazy: true,
      children: <_LazyNodeSeed>[
        _LazyNodeSeed(id: 'atendimento-triagem', label: 'Triagem'),
        _LazyNodeSeed(id: 'atendimento-plantao', label: 'Plantão social'),
        _LazyNodeSeed(id: 'atendimento-retornos', label: 'Retornos'),
        _LazyNodeSeed(id: 'atendimento-visitas', label: 'Visitas técnicas'),
      ],
    ),
    _LazyNodeSeed(
      id: 'beneficios',
      label: 'Benefícios',
      lazy: true,
      children: <_LazyNodeSeed>[
        _LazyNodeSeed(
          id: 'beneficios-cesta',
          label: 'Cesta básica',
          lazy: true,
          children: <_LazyNodeSeed>[
            _LazyNodeSeed(id: 'beneficios-cesta-analise', label: 'Em análise'),
            _LazyNodeSeed(id: 'beneficios-cesta-aprovado', label: 'Aprovado'),
            _LazyNodeSeed(id: 'beneficios-cesta-entregue', label: 'Entregue'),
          ],
        ),
        _LazyNodeSeed(id: 'beneficios-aluguel', label: 'Auxílio aluguel'),
        _LazyNodeSeed(id: 'beneficios-passagem', label: 'Passagem eventual'),
      ],
    ),
    _LazyNodeSeed(
      id: 'cadastros',
      label: 'Cadastros',
      lazy: true,
      children: <_LazyNodeSeed>[
        _LazyNodeSeed(id: 'cadastros-familias', label: 'Famílias'),
        _LazyNodeSeed(id: 'cadastros-territorios', label: 'Territórios'),
        _LazyNodeSeed(id: 'cadastros-documentos', label: 'Documentos'),
      ],
    ),
    _LazyNodeSeed(
      id: 'relatorios',
      label: 'Relatórios',
      lazy: true,
      children: <_LazyNodeSeed>[
        _LazyNodeSeed(id: 'relatorios-diario', label: 'Diário'),
        _LazyNodeSeed(id: 'relatorios-semanal', label: 'Semanal'),
        _LazyNodeSeed(id: 'relatorios-mensal', label: 'Mensal'),
      ],
    ),
    _LazyNodeSeed(
      id: 'configuracoes',
      label: 'Configurações',
      lazy: true,
      children: <_LazyNodeSeed>[
        _LazyNodeSeed(id: 'configuracoes-permissoes', label: 'Permissões'),
        _LazyNodeSeed(id: 'configuracoes-perfis', label: 'Perfis'),
        _LazyNodeSeed(id: 'configuracoes-integracoes', label: 'Integrações'),
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

  static List<TreeViewNode> _buildDropdownTree(Messages t) {
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
      treeViewNodeLabel: 'Cadastros',
      treeViewNodeLevel: 0,
      value: 'cadastros',
    );
    cadastros.addChild(TreeViewNode(
      treeViewNodeLabel: 'Famílias',
      treeViewNodeLevel: 1,
      value: 'familias',
    ));
    cadastros.addChild(TreeViewNode(
      treeViewNodeLabel: 'Territórios',
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

  static _LazyNodeSeed? _findLazySeed(String? id) {
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

  static String? _resolveLabel(List<TreeViewNode> nodes, dynamic value) {
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

  static String? _resolveLazyLabel(dynamic value) {
    return _findLazySeed(value?.toString())?.label;
  }
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
