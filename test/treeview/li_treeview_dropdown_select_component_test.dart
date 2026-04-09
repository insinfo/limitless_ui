// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/treeview/li_treeview_dropdown_select_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_treeview_dropdown_select_component_test.template.dart' as ng;

@Component(
  selector: 'treeview-dropdown-test-host',
  template: '''
    <div>
      <li-treeview-select
          #staticTree
          container="inline"
          [data]="staticNodes"
          [searchable]="false"
          [(ngModel)]="selectedStaticValue">
      </li-treeview-select>

      <li-treeview-select
          #lazyTree
          container="inline"
          [pageLoader]="loadChunk"
          [pageSize]="2"
          [(ngModel)]="selectedLazyValue">
      </li-treeview-select>

      <li-treeview-select
          #multiTree
          container="inline"
          [data]="staticNodes"
          [multiple]="true"
          [closeOnSelect]="false"
          [(ngModel)]="selectedMultiValues">
      </li-treeview-select>

      <li-treeview-select
          #frameTree
          container="inline"
          [data]="frameNodes"
          [settings]="frameSettings"
          [(ngModel)]="selectedFrameValue">
      </li-treeview-select>

      <li-treeview-select
          #lazyRawTree
          container="inline"
          [pageLoader]="loadRawChunk"
          [settings]="rawSettings"
          [pageSize]="2"
          [(ngModel)]="selectedLazyRawValue">
      </li-treeview-select>

      <li-treeview-select
          #overlayTree
          [data]="staticNodes"
          [searchable]="false"
          [closeOnSelect]="false"
          [(ngModel)]="selectedOverlayValue">
      </li-treeview-select>

      <li-treeview-select
          #searchToggleTree
          container="inline"
          [data]="staticNodes"
          [multiple]="true"
          [closeOnSelect]="false"
          [showPanelActions]="false"
          expandTogglePlacement="search"
          [(ngModel)]="selectedSearchToggleValues">
      </li-treeview-select>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiTreeviewSelectComponent,
  ],
)
class TreeviewDropdownTestHostComponent {
  TreeviewDropdownTestHostComponent()
      : staticNodes = _buildStaticNodes(),
        frameNodes = _buildFrameNodes();

  final List<TreeViewNode> staticNodes;
  final DataFrame<Map<String, dynamic>> frameNodes;
  final List<TreeViewLoadRequest> requests = <TreeViewLoadRequest>[];
  final List<TreeViewLoadRequest> rawRequests = <TreeViewLoadRequest>[];
  final TreeViewSettings frameSettings = const TreeViewSettings(
    idField: 'uuid',
    labelField: 'name',
    valueField: 'code',
    nodesField: 'children',
    iconField: 'icon',
    colorField: 'color',
    enabledField: 'enabled',
  );
  final TreeViewSettings rawSettings = TreeViewSettings(
    idField: 'uuid',
    labelField: 'title',
    valueField: 'code',
    nodesField: 'children',
    iconField: 'icon',
    colorField: 'color',
    enabledField: 'enabled',
    lazyChildrenResolver: (item, itemMap) => itemMap?['lazy'] == true,
  );

  dynamic selectedStaticValue;
  dynamic selectedLazyValue;
  List<dynamic> selectedMultiValues = <dynamic>[];
  dynamic selectedFrameValue;
  dynamic selectedLazyRawValue;
  dynamic selectedOverlayValue;
  List<dynamic> selectedSearchToggleValues = <dynamic>[];

  @ViewChild('staticTree')
  LiTreeviewSelectComponent? staticTree;

  @ViewChild('lazyTree')
  LiTreeviewSelectComponent? lazyTree;

  @ViewChild('multiTree')
  LiTreeviewSelectComponent? multiTree;

  @ViewChild('frameTree')
  LiTreeviewSelectComponent? frameTree;

  @ViewChild('lazyRawTree')
  LiTreeviewSelectComponent? lazyRawTree;

  @ViewChild('overlayTree')
  LiTreeviewSelectComponent? overlayTree;

  @ViewChild('searchToggleTree')
  LiTreeviewSelectComponent? searchToggleTree;

  Future<TreeViewLoadResult> loadChunk(TreeViewLoadRequest request) async {
    requests.add(request);
    await Future<void>.delayed(const Duration(milliseconds: 80));

    final source = request.parent == null
        ? _lazyCatalog
        : (_findSeed(request.parent!.value?.toString())?.children ??
            const <_Seed>[]);

    final filtered = request.searchTerm.trim().isEmpty
        ? source
        : source
            .where((seed) => seed.label
                .toLowerCase()
                .contains(request.searchTerm.toLowerCase()))
            .toList(growable: false);

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
          treeViewNodeHasLazyChildren: seed.children.isNotEmpty,
          treeViewNodeHasMoreChildren: seed.children.isNotEmpty,
        );
      }).toList(growable: false),
      hasMore: end < filtered.length,
    );
  }

  Future<TreeViewLoadResult> loadRawChunk(TreeViewLoadRequest request) async {
    rawRequests.add(request);
    await Future<void>.delayed(const Duration(milliseconds: 80));

    final source = request.parent == null
        ? _rawCatalog
        : (_findRawSeed(request.parent!.id?.toString())?.children ??
            const <_RawSeed>[]);

    final filtered = request.searchTerm.trim().isEmpty
        ? source
        : source
            .where((seed) => seed.title
                .toLowerCase()
                .contains(request.searchTerm.toLowerCase()))
            .toList(growable: false);

    final start = request.offset.clamp(0, filtered.length);
    final end = (start + request.limit).clamp(0, filtered.length);
    final slice = filtered.sublist(start, end);

    return TreeViewLoadResult.raw(
      items: DataFrame<_RawSeed>(
        items:
            slice.map((seed) => _toLazyPayload(seed)).toList(growable: false),
        totalRecords: filtered.length,
      ),
      hasMore: end < filtered.length,
    );
  }

  static _RawSeed _toLazyPayload(_RawSeed seed) {
    return _RawSeed(
      uuid: seed.uuid,
      title: seed.title,
      code: seed.code,
      icon: seed.icon,
      color: seed.color,
      enabled: seed.enabled,
      lazy: seed.children.isNotEmpty,
    );
  }

  static List<TreeViewNode> _buildStaticNodes() {
    final service = TreeViewNode(
      treeViewNodeLabel: 'Atendimento',
      treeViewNodeLevel: 0,
      value: 'service',
      treeViewNodeIsCollapse: false,
    );
    service.addChild(TreeViewNode(
      treeViewNodeLabel: 'Triagem',
      treeViewNodeLevel: 1,
      value: 'triage',
    ));

    final benefits = TreeViewNode(
      treeViewNodeLabel: 'Benefícios',
      treeViewNodeLevel: 0,
      value: 'benefits',
      treeViewNodeIsCollapse: false,
    );
    final basket = TreeViewNode(
      treeViewNodeLabel: 'Cesta básica',
      treeViewNodeLevel: 1,
      value: 'basket',
      treeViewNodeIsCollapse: false,
    );
    basket.addChild(TreeViewNode(
      treeViewNodeLabel: 'Em análise',
      treeViewNodeLevel: 2,
      value: 'review',
    ));
    basket.addChild(TreeViewNode(
      treeViewNodeLabel: 'Aprovado',
      treeViewNodeLevel: 2,
      value: 'approved',
    ));
    benefits.addChild(basket);

    return <TreeViewNode>[service, benefits];
  }

  static DataFrame<Map<String, dynamic>> _buildFrameNodes() {
    return DataFrame<Map<String, dynamic>>(
      items: <Map<String, dynamic>>[
        <String, dynamic>{
          'uuid': 'benefits',
          'name': 'Benefícios',
          'code': 'benefits',
          'icon': 'ph ph-tree-structure',
          'children': <Map<String, dynamic>>[
            <String, dynamic>{
              'uuid': 'basket',
              'name': 'Cesta básica',
              'code': 'basket',
              'icon': 'ph ph-package',
              'children': <Map<String, dynamic>>[
                <String, dynamic>{
                  'uuid': 'approved',
                  'name': 'Aprovado',
                  'code': 'approved',
                  'color': 'var(--success)',
                  'enabled': true,
                },
                <String, dynamic>{
                  'uuid': 'archived',
                  'name': 'Arquivado',
                  'code': 'archived',
                  'enabled': false,
                },
              ],
            },
          ],
        },
      ],
      totalRecords: 1,
    );
  }

  static const List<_Seed> _lazyCatalog = <_Seed>[
    _Seed(
      id: 'service',
      label: 'Atendimento',
      children: <_Seed>[
        _Seed(id: 'triage', label: 'Triagem'),
        _Seed(id: 'returns', label: 'Retornos'),
      ],
    ),
    _Seed(
      id: 'benefits',
      label: 'Benefícios',
      children: <_Seed>[
        _Seed(
          id: 'basket',
          label: 'Cesta básica',
          children: <_Seed>[
            _Seed(id: 'review', label: 'Em análise'),
            _Seed(id: 'approved', label: 'Aprovado'),
          ],
        ),
        _Seed(id: 'rent', label: 'Auxílio aluguel'),
      ],
    ),
    _Seed(
      id: 'registers',
      label: 'Cadastros',
      children: <_Seed>[
        _Seed(id: 'families', label: 'Famílias'),
      ],
    ),
  ];

  static _Seed? _findSeed(String? id) {
    if (id == null) {
      return null;
    }

    _Seed? walk(Iterable<_Seed> nodes) {
      for (final node in nodes) {
        if (node.id == id) {
          return node;
        }
        final child = walk(node.children);
        if (child != null) {
          return child;
        }
      }
      return null;
    }

    return walk(_lazyCatalog);
  }

  static _RawSeed? _findRawSeed(String? id) {
    if (id == null) {
      return null;
    }

    _RawSeed? walk(Iterable<_RawSeed> nodes) {
      for (final node in nodes) {
        if (node.uuid == id) {
          return node;
        }
        final child = walk(node.children);
        if (child != null) {
          return child;
        }
      }
      return null;
    }

    return walk(_rawCatalog);
  }

  static final List<_RawSeed> _rawCatalog = <_RawSeed>[
    _RawSeed(
      uuid: 'service',
      title: 'Atendimento',
      code: 'service',
      icon: 'ph ph-headset',
      lazy: true,
      children: <_RawSeed>[
        _RawSeed(uuid: 'triage', title: 'Triagem', code: 'triage'),
        _RawSeed(uuid: 'returns', title: 'Retornos', code: 'returns'),
      ],
    ),
    _RawSeed(
      uuid: 'benefits',
      title: 'Benefícios',
      code: 'benefits',
      icon: 'ph ph-tree-structure',
      lazy: true,
      children: <_RawSeed>[
        _RawSeed(
          uuid: 'basket',
          title: 'Cesta básica',
          code: 'basket',
          icon: 'ph ph-package',
          lazy: true,
          children: <_RawSeed>[
            _RawSeed(
              uuid: 'approved',
              title: 'Aprovado',
              code: 'approved',
              color: 'var(--success)',
            ),
            _RawSeed(
              uuid: 'archived',
              title: 'Arquivado',
              code: 'archived',
              enabled: false,
            ),
          ],
        ),
        _RawSeed(uuid: 'rent', title: 'Auxílio aluguel', code: 'rent'),
      ],
    ),
    _RawSeed(
      uuid: 'registers',
      title: 'Cadastros',
      code: 'registers',
      lazy: true,
      children: <_RawSeed>[
        _RawSeed(uuid: 'families', title: 'Famílias', code: 'families'),
      ],
    ),
  ];
}

class _Seed {
  const _Seed({
    required this.id,
    required this.label,
    this.children = const <_Seed>[],
  });

  final String id;
  final String label;
  final List<_Seed> children;
}

class _RawSeed implements SerializeBase {
  const _RawSeed({
    required this.uuid,
    required this.title,
    required this.code,
    this.icon,
    this.color,
    this.enabled = true,
    this.lazy = false,
    this.children = const <_RawSeed>[],
  });

  final String uuid;
  final String title;
  final String code;
  final String? icon;
  final String? color;
  final bool enabled;
  final bool lazy;
  final List<_RawSeed> children;

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

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TreeviewDropdownTestHostComponent>(
    ng.TreeviewDropdownTestHostComponentNgFactory,
  );

  test('selects nested node from static tree', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      _triggerButtons(fixture.rootElement)[0].click();
    });
    await _settle(fixture);

    final approvedLabel = _findLabelButton(fixture.rootElement, 'Aprovado');
    expect(approvedLabel, isNotNull);

    await fixture.update((_) {
      approvedLabel!.click();
    });
    await _settle(fixture);

    expect(host.selectedStaticValue, 'approved');
    expect(host.staticTree!.selectedLabel, 'Aprovado');
    expect(host.staticTree!.isPopupOpen, isFalse);
  });

  test('loads roots and children in chunks for lazy tree', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final lazyHost =
        fixture.rootElement.querySelectorAll('li-treeview-select').elementAt(1);

    await fixture.update((_) {
      _triggerButtons(fixture.rootElement)[1].click();
    });
    await _settle(fixture, milliseconds: 140);

    expect(fixture.rootElement.text, contains('Atendimento'));
    expect(fixture.rootElement.text, contains('Benefícios'));
    expect(fixture.rootElement.text, isNot(contains('Cadastros')));
    expect(host.requests.first.parent, isNull);

    final loadMoreRoot = _findButtonByText(lazyHost, 'Carregar mais');
    expect(loadMoreRoot, isNotNull);

    await fixture.update((_) {
      loadMoreRoot!.click();
    });
    await _settle(fixture, milliseconds: 140);

    expect(fixture.rootElement.text, contains('Cadastros'));

    final expandBenefits = _findExpanderForLabel(lazyHost, 'Benefícios');
    expect(expandBenefits, isNotNull);

    await fixture.update((_) {
      expandBenefits!.click();
    });
    await _settle(fixture, milliseconds: 140);

    expect(lazyHost.text, contains('Cesta básica'));
    expect(lazyHost.text, contains('Auxílio aluguel'));
    expect(
      host.requests.any((request) => request.parent?.value == 'benefits'),
      isTrue,
    );
  });

  test('forwards search term to pageLoader and filters remote roots', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final lazyHost =
        fixture.rootElement.querySelectorAll('li-treeview-select').elementAt(1);

    await fixture.update((_) {
      _triggerButtons(fixture.rootElement)[1].click();
    });
    await _settle(fixture, milliseconds: 140);

    final searchInput = lazyHost
        .querySelectorAll('.treeview-dropdown-select__search input')
        .elementAt(0) as html.InputElement;

    await fixture.update((_) {
      searchInput.value = 'cad';
      searchInput.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture, milliseconds: 260);

    expect(host.requests.last.searchTerm, 'cad');
    expect(lazyHost.text, contains('Cadastros'));
    expect(lazyHost.text, isNot(contains('Atendimento')));
  });

  test('multiple mode keeps popup open and accumulates selections', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final multiHost =
        fixture.rootElement.querySelectorAll('li-treeview-select').elementAt(2);

    await fixture.update((_) {
      _triggerButtons(fixture.rootElement)[2].click();
    });
    await _settle(fixture);

    final triageLabel = _findLabelButton(multiHost, 'Triagem');
    final approvedLabel = _findLabelButton(multiHost, 'Aprovado');

    await fixture.update((_) {
      triageLabel!.click();
      approvedLabel!.click();
    });
    await _settle(fixture);

    expect(
        host.selectedMultiValues, containsAll(<String>['triage', 'approved']));
    expect(host.multiTree!.isPopupOpen, isTrue);
  });

  test('maps DataFrame<Map> with settings and blocks disabled nodes', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final frameHost =
        fixture.rootElement.querySelectorAll('li-treeview-select').elementAt(3);

    await fixture.update((_) {
      _triggerButtons(fixture.rootElement)[3].click();
    });
    await _settle(fixture);

    final expandBenefits = _findExpanderForLabel(frameHost, 'Benefícios');
    expect(expandBenefits, isNotNull);

    await fixture.update((_) {
      expandBenefits!.click();
    });
    await _settle(fixture);

    final expandBasket = _findExpanderForLabel(frameHost, 'Cesta básica');
    expect(expandBasket, isNotNull);

    await fixture.update((_) {
      expandBasket!.click();
    });
    await _settle(fixture);

    final archivedLabel = _findLabelButton(frameHost, 'Arquivado');
    expect(archivedLabel, isNotNull);

    await fixture.update((_) {
      archivedLabel!.click();
    });
    await _settle(fixture);

    expect(host.selectedFrameValue, isNull);

    final approvedLabel = _findLabelButton(frameHost, 'Aprovado');
    expect(approvedLabel, isNotNull);

    await fixture.update((_) {
      approvedLabel!.click();
    });
    await _settle(fixture);

    expect(host.selectedFrameValue, 'approved');
    expect(host.frameTree!.selectedLabel, 'Aprovado');
  });

  test('loads raw SerializeBase chunks with settings in lazy mode', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final rawHost =
        fixture.rootElement.querySelectorAll('li-treeview-select').elementAt(4);

    await fixture.update((_) {
      _triggerButtons(fixture.rootElement)[4].click();
    });
    await _settle(fixture, milliseconds: 140);

    expect(rawHost.text, contains('Atendimento'));
    expect(rawHost.text, contains('Benefícios'));
    expect(rawHost.text, isNot(contains('Cadastros')));
    expect(host.rawRequests.first.parent, isNull);

    final loadMoreRoot = _findButtonByText(rawHost, 'Carregar mais');
    expect(loadMoreRoot, isNotNull);

    await fixture.update((_) {
      loadMoreRoot!.click();
    });
    await _settle(fixture, milliseconds: 140);

    expect(rawHost.text, contains('Cadastros'));

    final expandBenefits = _findExpanderForLabel(rawHost, 'Benefícios');
    expect(expandBenefits, isNotNull);

    await fixture.update((_) {
      expandBenefits!.click();
    });
    await _settle(fixture, milliseconds: 140);

    final expandBasket = _findExpanderForLabel(rawHost, 'Cesta básica');
    expect(expandBasket, isNotNull);

    await fixture.update((_) {
      expandBasket!.click();
    });
    await _settle(fixture, milliseconds: 140);

    final archivedLabel = _findLabelButton(rawHost, 'Arquivado');
    expect(archivedLabel, isNotNull);

    await fixture.update((_) {
      archivedLabel!.click();
    });
    await _settle(fixture);

    expect(host.selectedLazyRawValue, isNull);

    final approvedLabel = _findLabelButton(rawHost, 'Aprovado');
    expect(approvedLabel, isNotNull);

    await fixture.update((_) {
      approvedLabel!.click();
    });
    await _settle(fixture);

    expect(host.selectedLazyRawValue, 'approved');
    expect(host.lazyRawTree!.selectedLabel, 'Aprovado');
    expect(
      host.rawRequests.any((request) => request.parent?.id == 'benefits'),
      isTrue,
    );
  });

  test('keeps overlay open when expanding children in body container', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      _triggerButtons(fixture.rootElement)[5].click();
    });
    await _settle(fixture);

    final popup = html.document
        .querySelector('.treeview-dropdown-select__panel.show') as html.Element;
    final expandBenefits = _findExpanderForLabel(popup, 'Benefícios');
    expect(expandBenefits, isNotNull);
    final benefitsNode = host.overlayTree!.rootNodes
        .firstWhere((node) => node.treeViewNodeLabel == 'Benefícios');
    final initialCollapsed = benefitsNode.treeViewNodeIsCollapse;

    await fixture.update((_) {
      expandBenefits!.click();
    });
    await _settle(fixture);

    expect(host.overlayTree!.isPopupOpen, isTrue);
    expect(benefitsNode.treeViewNodeIsCollapse, isNot(initialCollapsed));
  });

  test('shows actions to toggle all, clear selection, and confirm', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final multiHost =
        fixture.rootElement.querySelectorAll('li-treeview-select').elementAt(2);

    await fixture.update((_) {
      _triggerButtons(fixture.rootElement)[2].click();
    });
    await _settle(fixture);

    await fixture.update((_) {
      final triageLabel = _findLabelButton(multiHost, 'Triagem');
      triageLabel!.click();
    });
    await _settle(fixture);

    await fixture.update((_) {
      final toggleAll = multiHost.querySelector(
        '.treeview-dropdown-select__action-expand',
      ) as html.ButtonElement;
      expect((toggleAll.text ?? '').trim(), 'Recolher tudo');
      toggleAll.click();
    });
    await _settle(fixture, milliseconds: 140);

    final benefits = host.multiTree!.rootNodes
        .firstWhere((node) => node.treeViewNodeLabel == 'Benefícios');
    final basket = benefits.treeViewNodes
        .firstWhere((node) => node.treeViewNodeLabel == 'Cesta básica');

    expect(host.multiTree!.isPopupOpen, isTrue);
    expect(benefits.treeViewNodeIsCollapse, isTrue);
    expect(basket.treeViewNodeIsCollapse, isTrue);

    await fixture.update((_) {
      final toggleAll = multiHost.querySelector(
        '.treeview-dropdown-select__action-expand',
      ) as html.ButtonElement;
      expect((toggleAll.text ?? '').trim(), 'Expandir tudo');
      toggleAll.click();
    });
    await _settle(fixture, milliseconds: 140);

    expect(benefits.treeViewNodeIsCollapse, isFalse);
    expect(basket.treeViewNodeIsCollapse, isFalse);

    await fixture.update((_) {
      final clearButton = multiHost.querySelector(
        '.treeview-dropdown-select__action-clear',
      ) as html.ButtonElement;
      clearButton.click();
    });
    await _settle(fixture);

    expect(host.selectedMultiValues, isEmpty);
    expect(host.multiTree!.isPopupOpen, isTrue);

    await fixture.update((_) {
      final confirmButton = multiHost.querySelector(
        '.treeview-dropdown-select__action-confirm',
      ) as html.ButtonElement;
      confirmButton.click();
    });
    await _settle(fixture);

    expect(host.multiTree!.isPopupOpen, isFalse);
  });

  test('supports showing the expand-collapse toggle beside search', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final searchToggleHost =
        fixture.rootElement.querySelectorAll('li-treeview-select').elementAt(6);

    await fixture.update((_) {
      _triggerButtons(fixture.rootElement)[6].click();
    });
    await _settle(fixture);

    final searchToggleButton = searchToggleHost.querySelector(
      '.treeview-dropdown-select__search-action',
    ) as html.ButtonElement;

    expect(
      searchToggleHost.querySelector('.treeview-dropdown-select__actions'),
      isNull,
    );
    expect(searchToggleButton.classes.contains('btn-sm'), isTrue);
    expect(searchToggleButton.title, 'Recolher tudo');

    await fixture.update((_) {
      searchToggleButton.click();
    });
    await _settle(fixture, milliseconds: 140);

    final benefits = host.searchToggleTree!.rootNodes
        .firstWhere((node) => node.treeViewNodeLabel == 'Benefícios');
    final basket = benefits.treeViewNodes
        .firstWhere((node) => node.treeViewNodeLabel == 'Cesta básica');

    expect(benefits.treeViewNodeIsCollapse, isTrue);
    expect(basket.treeViewNodeIsCollapse, isTrue);

    final refreshedSearchToggleButton = searchToggleHost.querySelector(
      '.treeview-dropdown-select__search-action',
    ) as html.ButtonElement;
    expect(refreshedSearchToggleButton.title, 'Expandir tudo');

    await fixture.update((_) {
      refreshedSearchToggleButton.click();
    });
    await _settle(fixture);

    expect(benefits.treeViewNodeIsCollapse, isFalse);
    expect(basket.treeViewNodeIsCollapse, isFalse);
  });
}

Future<void> _settle(
  NgTestFixture<TreeviewDropdownTestHostComponent> fixture, {
  int milliseconds = 30,
}) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
  await fixture.update((_) {});
}

List<html.ButtonElement> _triggerButtons(html.Element root) {
  return root
      .querySelectorAll('.treeview-dropdown-select__trigger')
      .whereType<html.ButtonElement>()
      .toList(growable: false);
}

html.ButtonElement? _findLabelButton(html.Element root, String text) {
  for (final element
      in root.querySelectorAll('.treeview-dropdown-select__label')) {
    if (element.text?.trim() == text) {
      return element as html.ButtonElement;
    }
  }
  return null;
}

html.ButtonElement? _findButtonByText(html.Element root, String text) {
  for (final element in root.querySelectorAll('button')) {
    if (element.text?.trim() == text) {
      return element as html.ButtonElement;
    }
  }
  return null;
}

html.ButtonElement? _findExpanderForLabel(html.Element root, String label) {
  for (final row in root.querySelectorAll('.treeview-dropdown-select__row')) {
    final labelElement = row.querySelector('.treeview-dropdown-select__label');
    if (labelElement?.text?.trim() == label) {
      final expander = row.querySelector('.treeview-dropdown-select__expander');
      return expander as html.ButtonElement?;
    }
  }
  return null;
}
