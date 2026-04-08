import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'multi-select-page',
  templateUrl: 'multi_select_page.html',
  styleUrls: ['multi_select_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiMultiOptionComponent,
    LiMultiSelectComponent,
  ],
)
class MultiSelectPageComponent {
  MultiSelectPageComponent(this.i18n);

  static const String apiSnippet = '''
<li-multi-select
  [dataSource]="channelOptions"
  labelKey="label"
  valueKey="id"
  [(ngModel)]="selectedChannels">
</li-multi-select>''';

  static const String notesSnippet = '''
// Bom: opções criadas uma única vez
late final List<Map<String, dynamic>> channelOptions;

// O ngModel muda, mas o dataSource continua estável
List<dynamic> selectedChannels = <dynamic>['email', 'push'];''';

  static const String compareWithSnippet = '''
<li-multi-select
  [dataSource]="people"
  labelKey="name"
  [compareWith]="comparePersonById"
  [(ngModel)]="selectedPeople">
</li-multi-select>''';

  static const String modelChangeSnippet = '''
<li-multi-select
  [dataSource]="people"
  labelKey="name"
  valueKey="id"
  [(ngModel)]="selectedPeopleIds"
  (modelChange)="onSelectedPeopleModelsChange(\$event)">
</li-multi-select>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  List<Map<String, dynamic>>? _channelOptionsPt;
  List<Map<String, dynamic>>? _channelOptionsEn;
  List<Map<String, dynamic>>? _projectedOptionsPt;
  List<Map<String, dynamic>>? _projectedOptionsEn;

  List<Map<String, dynamic>> get channelOptions {
    if (i18n.isPortuguese) {
      return _channelOptionsPt ??= _buildChannelOptions();
    }
    return _channelOptionsEn ??= _buildChannelOptions();
  }

  List<Map<String, dynamic>> get projectedOptions {
    if (i18n.isPortuguese) {
      return _projectedOptionsPt ??= _buildProjectedOptions();
    }
    return _projectedOptionsEn ??= _buildProjectedOptions();
  }

  List<dynamic> selectedChannels = <dynamic>['email', 'push'];
  List<dynamic> projectedChannels = <dynamic>['portal', 'api'];
  List<dynamic> selectedChannelModels = <dynamic>[];

  String get selectedChannelsLabel => selectedChannels
      .map((dynamic id) => _labelFor(id.toString(), channelOptions))
      .join(', ');

  String get projectedChannelsLabel => projectedChannels
      .map((dynamic id) => _labelFor(id.toString(), projectedOptions))
      .join(', ');

  String get selectedChannelModelsLabel {
    if (selectedChannelModels.isEmpty) {
      return selectedChannelsLabel;
    }
    return selectedChannelModels
        .map((dynamic item) => (item as Map<String, dynamic>)['label'])
        .join(', ');
  }

  List<Map<String, dynamic>> _buildChannelOptions() => <Map<String, dynamic>>[
        <String, dynamic>{'id': 'email', 'label': t.pages.multiSelect.optionEmail},
        <String, dynamic>{'id': 'push', 'label': t.pages.multiSelect.optionPush},
        <String, dynamic>{'id': 'sms', 'label': t.pages.multiSelect.optionSms},
        <String, dynamic>{'id': 'webhook', 'label': t.pages.multiSelect.optionWebhook},
      ];

  List<Map<String, dynamic>> _buildProjectedOptions() =>
      <Map<String, dynamic>>[
        <String, dynamic>{'id': 'portal', 'label': t.pages.multiSelect.optionPortal},
        <String, dynamic>{'id': 'api', 'label': t.pages.multiSelect.optionApi},
        <String, dynamic>{'id': 'batch', 'label': t.pages.multiSelect.optionBatch},
      ];

  String _labelFor(String id, List<Map<String, dynamic>> source) {
    for (final item in source) {
      if (item['id'] == id) {
        return item['label'] as String;
      }
    }
    return id;
  }

  void onChannelModelsChange(List<dynamic> models) {
    selectedChannelModels = models;
  }
}
