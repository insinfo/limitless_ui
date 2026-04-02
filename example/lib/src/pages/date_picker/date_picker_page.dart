import 'package:limitless_ui_example/limitless_ui_example.dart';
import 'package:ngrouter/ngrouter.dart';

@Component(
  selector: 'date-picker-page',
  templateUrl: 'date_picker_page.html',
  styleUrls: ['date_picker_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    RouterLink,
    LiTabsComponent,
    LiTabxDirective,
    LiDatePickerComponent,
  ],
  exports: [DemoRoutePaths],
)
class DatePickerPageComponent {
  DatePickerPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  DateTime? selectedDate = DateTime(2026, 3, 20);
  DateTime? restrictedDate = DateTime(2026, 3, 18);
  DateTime? englishDate = DateTime(2026, 11, 4);
  DateTime? disabledDate = DateTime(2026, 3, 12);
  final DateTime minDate = DateTime(2026, 3, 5);
  final DateTime maxDate = DateTime(2026, 3, 25);

    String get dateRangeCtaTitle => _isPt
      ? 'Precisa selecionar um período?'
      : 'Need to select a date range?';

    String get dateRangeCtaBody => _isPt
      ? 'A demo dedicada do Date Range continua disponível com exemplos de início, fim e restrições.'
      : 'The dedicated Date Range demo is still available with start, end, and constrained examples.';

    String get dateRangeCtaButton => _isPt
      ? 'Abrir demo de Date Range'
      : 'Open Date Range demo';

  String get selectedDateLabel {
    final value = selectedDate;
    if (value == null) {
      return t.pages.datePicker.noneSelected;
    }
    return _formatDate(value);
  }

  String get restrictedDateLabel {
    final value = restrictedDate;
    if (value == null) {
      return t.pages.datePicker.noneSelected;
    }
    return _formatDate(value);
  }

  String get englishDateLabel {
    final value = englishDate;
    if (value == null) {
      return t.pages.datePicker.noneSelected;
    }

    return _formatDate(value, english: true);
  }

  String get disabledDateLabel {
    final value = disabledDate;
    if (value == null) {
      return t.pages.datePicker.noneSelected;
    }

    return _formatDate(value);
  }

  String _formatDate(DateTime value, {bool english = false}) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    if (english) {
      return '$month/$day/${value.year}';
    }
    return '$day/$month/${value.year}';
  }
}