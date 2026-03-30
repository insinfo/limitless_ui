import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'multi-select-page',
  templateUrl: 'multi_select_page.html',
  styleUrls: ['multi_select_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiMultiOptionComponent,
    LiMultiSelectComponent,
  ],
)
class MultiSelectPageComponent {
  MultiSelectPageComponent(this.i18n) {
    // Keep demo data stable across change detection cycles so the page avoids
    // recreating equivalent inputs on every render.
    channelOptions = <Map<String, dynamic>>[
      <String, dynamic>{'id': 'email', 'label': t.pages.multiSelect.optionEmail},
      <String, dynamic>{'id': 'push', 'label': t.pages.multiSelect.optionPush},
      <String, dynamic>{'id': 'sms', 'label': t.pages.multiSelect.optionSms},
      <String, dynamic>{'id': 'webhook', 'label': t.pages.multiSelect.optionWebhook},
    ];

    projectedOptions = <Map<String, dynamic>>[
      <String, dynamic>{'id': 'portal', 'label': t.pages.multiSelect.optionPortal},
      <String, dynamic>{'id': 'api', 'label': t.pages.multiSelect.optionApi},
      <String, dynamic>{'id': 'batch', 'label': t.pages.multiSelect.optionBatch},
    ];
  }

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  late final List<Map<String, dynamic>> channelOptions;
  late final List<Map<String, dynamic>> projectedOptions;

  List<dynamic> selectedChannels = <dynamic>['email', 'push'];
  List<dynamic> projectedChannels = <dynamic>['portal', 'api'];

  String get selectedChannelsLabel => selectedChannels
      .map((dynamic id) => _labelFor(id.toString(), channelOptions))
      .join(', ');

  String get projectedChannelsLabel => projectedChannels
      .map((dynamic id) => _labelFor(id.toString(), projectedOptions))
      .join(', ');

  String _labelFor(String id, List<Map<String, dynamic>> source) {
    for (final item in source) {
      if (item['id'] == id) {
        return item['label'] as String;
      }
    }
    return id;
  }
}
