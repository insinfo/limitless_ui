// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/treeview/li_treeview_dropdown_select_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

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
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiTreeviewSelectComponent,
  ],
)
class TreeviewDropdownTestHostComponent {
  TreeviewDropdownTestHostComponent() : staticNodes = _buildStaticNodes();

  final List<TreeViewNode> staticNodes;
  final List<TreeViewLoadRequest> requests = <TreeViewLoadRequest>[];

  dynamic selectedStaticValue;
  dynamic selectedLazyValue;
  List<dynamic> selectedMultiValues = <dynamic>[];

  @ViewChild('staticTree')
  LiTreeviewSelectComponent? staticTree;

  @ViewChild('lazyTree')
  LiTreeviewSelectComponent? lazyTree;

  @ViewChild('multiTree')
  LiTreeviewSelectComponent? multiTree;

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
