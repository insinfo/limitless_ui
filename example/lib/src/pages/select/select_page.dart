import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'select-page',
  templateUrl: 'select_page.html',
  styleUrls: ['select_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiOptionComponent,
    LiSelectComponent,
  ],
)
class SelectPageComponent {
  SelectPageComponent(this.i18n);

  static const String apiSnippet = '''
<li-select
  [dataSource]="statusOptions"
  labelKey="label"
  valueKey="id"
  disabledKey="disabled"
  [(ngModel)]="selectedStatus">
</li-select>''';

  static const String notesSnippet = '''
// Bom: lista estável criada uma vez
late final List<Map<String, dynamic>> statusOptions;

// Evite: getter que recria a lista a cada change detection
// List<Map<String, dynamic>> get statusOptions => [...];''';

  static const String compareWithSnippet = '''
<li-select
  [dataSource]="users"
  labelKey="name"
  [compareWith]="compareUserById"
  [(ngModel)]="selectedUser">
</li-select>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  List<Map<String, dynamic>>? _statusOptionsPt;
  List<Map<String, dynamic>>? _statusOptionsEn;
  List<Map<String, dynamic>>? _projectedOptionsPt;
  List<Map<String, dynamic>>? _projectedOptionsEn;

  List<Map<String, dynamic>> get statusOptions {
    if (i18n.isPortuguese) {
      return _statusOptionsPt ??= _buildStatusOptions();
    }
    return _statusOptionsEn ??= _buildStatusOptions();
  }

  List<Map<String, dynamic>> get projectedOptions {
    if (i18n.isPortuguese) {
      return _projectedOptionsPt ??= _buildProjectedOptions();
    }
    return _projectedOptionsEn ??= _buildProjectedOptions();
  }

  String selectedStatus = 'review';
  String projectedStatus = 'priority';

  String get selectedStatusLabel => _labelFor(selectedStatus, statusOptions);

  String get projectedStatusLabel => _labelFor(projectedStatus, projectedOptions);

  List<Map<String, dynamic>> _buildStatusOptions() => <Map<String, dynamic>>[
        <String, dynamic>{'id': 'draft', 'label': t.pages.select.optionDraft},
        <String, dynamic>{'id': 'review', 'label': t.pages.select.optionReview},
        <String, dynamic>{'id': 'approved', 'label': t.pages.select.optionApproved},
        <String, dynamic>{
          'id': 'archived',
          'label': t.pages.select.optionArchived,
          'disabled': true,
        },
      ];

  List<Map<String, dynamic>> _buildProjectedOptions() =>
      <Map<String, dynamic>>[
        <String, dynamic>{'id': 'priority', 'label': t.pages.select.optionPriority},
        <String, dynamic>{'id': 'backlog', 'label': t.pages.select.optionBacklog},
        <String, dynamic>{'id': 'archived', 'label': t.pages.select.optionArchived},
      ];

  String _labelFor(String id, List<Map<String, dynamic>> source) {
    for (final item in source) {
      if (item['id'] == id) {
        return item['label'] as String;
      }
    }
    return id;
  }
}
