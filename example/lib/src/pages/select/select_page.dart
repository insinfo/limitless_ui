import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'select-page',
  templateUrl: 'select_page.html',
  styleUrls: ['select_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiOptionComponent,
    LiSelectComponent,
  ],
)
class SelectPageComponent {
  SelectPageComponent(this.i18n) {
    // Keep demo data stable across change detection cycles so the page itself
    // demonstrates the recommended usage pattern for li-select.
    statusOptions = <Map<String, dynamic>>[
      <String, dynamic>{'id': 'draft', 'label': t.pages.select.optionDraft},
      <String, dynamic>{'id': 'review', 'label': t.pages.select.optionReview},
      <String, dynamic>{'id': 'approved', 'label': t.pages.select.optionApproved},
      <String, dynamic>{
        'id': 'archived',
        'label': t.pages.select.optionArchived,
        'disabled': true,
      },
    ];

    projectedOptions = <Map<String, dynamic>>[
      <String, dynamic>{'id': 'priority', 'label': t.pages.select.optionPriority},
      <String, dynamic>{'id': 'backlog', 'label': t.pages.select.optionBacklog},
      <String, dynamic>{'id': 'archived', 'label': t.pages.select.optionArchived},
    ];
  }

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  late final List<Map<String, dynamic>> statusOptions;
  late final List<Map<String, dynamic>> projectedOptions;

  String selectedStatus = 'review';
  String projectedStatus = 'priority';

  String get selectedStatusLabel => _labelFor(selectedStatus, statusOptions);

  String get projectedStatusLabel => _labelFor(projectedStatus, projectedOptions);

  String _labelFor(String id, List<Map<String, dynamic>> source) {
    for (final item in source) {
      if (item['id'] == id) {
        return item['label'] as String;
      }
    }
    return id;
  }
}
