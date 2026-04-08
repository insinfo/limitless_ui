import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'accordion-page',
  templateUrl: 'accordion_page.html',
  styleUrls: ['accordion_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiAccordionBodyComponent,
    LiAccordionBodyTemplateDirective,
    LiAccordionButtonDirective,
    LiAccordionCollapseDirective,
    LiAccordionDirective,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiTabxHeaderDirective,
    LiCollapseDirective,
    LiAccordionComponent,
    LiAccordionHeaderDirective,
    LiAccordionHeaderHostDirective,
    LiAccordionItemComponent,
    LiAccordionItemDirective,
    LiAccordionToggleDirective,
  ],
  pipes: [
    commonPipes,
  ],
)
class AccordionPageComponent {
  AccordionPageComponent(this.i18n);

  static const String componentApiSnippet = '''
<li-accordion [allowMultipleOpen]="true" [flush]="true" [bodyPadding]="false">
  <li-accordion-item [header]="'Dados do Requerente'" [expanded]="true">
    <div class="p-3">...conteúdo da seção...</div>
  </li-accordion-item>

  <li-accordion-item [header]="'Dados do Processo'">
    <div class="p-3">...conteúdo da seção...</div>
  </li-accordion-item>
</li-accordion>''';

  static const String itemApiSnippet = '''
<li-accordion [allowMultipleOpen]="true">
  <li-accordion-item
    [header]="'Título'"
    [expanded]="true"
    (expandedChange)="onChange(\$event)">
  </li-accordion-item>
</li-accordion>''';

  static const String directiveApiSnippet = '''
<div liAccordion [closeOthers]="true" [destroyOnHide]="true" #accordion="liAccordion">
  <div liAccordionItem="first" #first="liAccordionItem" [collapsed]="false">
    <h2 liAccordionHeader>
      <button liAccordionButton>Primeiro</button>
    </h2>
    <div liAccordionCollapse>
      <template liAccordionBody>
        <div liAccordionBody>Conteúdo do primeiro item</div>
      </template>
    </div>
  </div>
</div>''';

  static const String collapseApiSnippet = '''
<div [liCollapse]="isCollapsed">
  <div class="border rounded p-3">Conteúdo colapsável</div>
</div>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  String get initialAccordionEventLog => t.pages.accordion.idle;
  String accordionEventLog = '';
  String declarativeAccordionEventLog = '';
  bool standaloneCollapsed = true;

  void onAccordionStateChange(String label, bool expanded) {
    accordionEventLog =
        '$label: ${expanded ? t.pages.accordion.expandedState : t.pages.accordion.collapsedState}.';
  }

  void onDeclarativeAccordionEvent(String eventName, String itemId) {
    declarativeAccordionEventLog = '$itemId: $eventName.';
  }

  void toggleStandaloneCollapse() {
    standaloneCollapsed = !standaloneCollapsed;
  }
}
