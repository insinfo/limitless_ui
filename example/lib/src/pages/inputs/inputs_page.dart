import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'inputs-page',
  templateUrl: 'inputs_page.html',
  styleUrls: ['inputs_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiDateRangePickerComponent,
    LiMultiSelectComponent,
    LiSelectComponent,
  ],
)
class InputsPageComponent {
  final List<Map<String, dynamic>> statusOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'review', 'label': 'Em revisao'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
    <String, dynamic>{'id': 'archived', 'label': 'Arquivado', 'disabled': true},
  ];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'E-mail'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
    <String, dynamic>{'id': 'webhook', 'label': 'Webhook'},
  ];

  String selectedStatus = 'review';
  List<dynamic> selectedChannels = <dynamic>['email', 'push'];
  DateTime? rangeStart = DateTime(2026, 3, 1);
  DateTime? rangeEnd = DateTime(2026, 3, 21);

  String get selectedStatusLabel => _labelFor(selectedStatus, statusOptions);

  String get selectedChannelsLabel => selectedChannels
      .map((dynamic id) => _labelFor(id.toString(), channelOptions))
      .join(', ');

  String get selectedRangeLabel {
    if (rangeStart == null || rangeEnd == null) {
      return 'Periodo parcial ou nao definido';
    }

    return '${_formatDate(rangeStart!)} ate ${_formatDate(rangeEnd!)}';
  }

  void onRangeStartChange(DateTime? value) {
    rangeStart = value;
  }

  void onRangeEndChange(DateTime? value) {
    rangeEnd = value;
  }

  String _labelFor(String id, List<Map<String, dynamic>> source) {
    for (final item in source) {
      if (item['id'] == id) {
        return item['label'] as String;
      }
    }
    return id;
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
