import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/src/components/treeview/treeview_settings.dart';
import 'package:test/test.dart';

void main() {
  test('normalizes DataFrame<SerializeBase> using configured fields', () {
    final frame = DataFrame<_SerializableTreeNode>(
      items: <_SerializableTreeNode>[
        _SerializableTreeNode(
          uuid: 'root',
          title: 'Atendimento',
          code: 'service',
          icon: 'ph ph-headset',
          color: '#0d6efd',
          children: <_SerializableTreeNode>[
            _SerializableTreeNode(
              uuid: 'triage',
              title: 'Triagem',
              code: 'triage',
              enabled: false,
            ),
          ],
        ),
      ],
      totalRecords: 1,
    );

    final settings = TreeViewSettings(
      idField: 'uuid',
      labelField: 'title',
      valueField: 'code',
      nodesField: 'children',
      iconField: 'icon',
      colorField: 'color',
      enabledField: 'enabled',
    );

    final nodes = settings.normalize(frame);

    expect(nodes, hasLength(1));
    expect(nodes.single.id, 'root');
    expect(nodes.single.treeViewNodeLabel, 'Atendimento');
    expect(nodes.single.value, 'service');
    expect(nodes.single.icon, 'ph ph-headset');
    expect(nodes.single.color, '#0d6efd');
    expect(nodes.single.source, isA<_SerializableTreeNode>());
    expect(nodes.single.sourceMap?['title'], 'Atendimento');
    expect(nodes.single.treeViewNodes, hasLength(1));
    expect(nodes.single.treeViewNodes.single.id, 'triage');
    expect(nodes.single.treeViewNodes.single.treeViewNodeLabel, 'Triagem');
    expect(nodes.single.treeViewNodes.single.enabled, isFalse);
  });
}

class _SerializableTreeNode implements SerializeBase {
  _SerializableTreeNode({
    required this.uuid,
    required this.title,
    required this.code,
    this.icon,
    this.color,
    this.enabled = true,
    this.children = const <_SerializableTreeNode>[],
  });

  final String uuid;
  final String title;
  final String code;
  final String? icon;
  final String? color;
  final bool enabled;
  final List<_SerializableTreeNode> children;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'title': title,
      'code': code,
      'icon': icon,
      'color': color,
      'enabled': enabled,
      'children':
          children.map((child) => child.toMap()).toList(growable: false),
    };
  }
}
