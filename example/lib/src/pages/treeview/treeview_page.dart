import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'treeview-page',
  templateUrl: 'treeview_page.html',
  styleUrls: ['treeview_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiTreeViewComponent,
  ],
)
class TreeviewPageComponent {
  TreeviewPageComponent(this.i18n)
      : treeNodes = _buildTree(i18n.t);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  final List<TreeViewNode> treeNodes;

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
}
