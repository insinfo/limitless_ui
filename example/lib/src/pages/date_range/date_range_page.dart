import 'package:limitless_ui_example/limitless_ui_example.dart';
@Component(
  selector: 'date-range-page',
  templateUrl: 'date_range_page.html',
  styleUrls: ['date_range_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiDateRangePickerComponent,
  ],
)
class DateRangePageComponent {
  DateRangePageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  DateTime? rangeStart = DateTime(2026, 3, 1);
  DateTime? rangeEnd = DateTime(2026, 3, 21);
  DateTime? constrainedStart = DateTime(2026, 3, 10);
  DateTime? constrainedEnd = DateTime(2026, 3, 18);
  final DateTime minDate = DateTime(2026, 3, 5);
  final DateTime maxDate = DateTime(2026, 3, 25);

  String get selectedRangeLabel {
    if (rangeStart == null || rangeEnd == null) {
      return t.pages.dateRange.partial;
    }
    return '${_formatDate(rangeStart!)} ${t.pages.dateRange.between} ${_formatDate(rangeEnd!)}';
  }

  String get constrainedRangeLabel {
    if (constrainedStart == null || constrainedEnd == null) {
      return t.pages.dateRange.unfinished;
    }
    return '${_formatDate(constrainedStart!)} ${t.pages.dateRange.between} ${_formatDate(constrainedEnd!)}';
  }

  void onRangeStartChange(DateTime? value) {
    rangeStart = value;
  }

  void onRangeEndChange(DateTime? value) {
    rangeEnd = value;
  }

  void onConstrainedRangeStartChange(DateTime? value) {
    constrainedStart = value;
  }

  void onConstrainedRangeEndChange(DateTime? value) {
    constrainedEnd = value;
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
