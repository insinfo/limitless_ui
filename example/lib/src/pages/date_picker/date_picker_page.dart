import 'package:limitless_ui_example/limitless_ui_example.dart';
import 'package:ngrouter/ngrouter.dart';

@Component(
  selector: 'date-picker-page',
  templateUrl: 'date_picker_page.html',
  styleUrls: ['date_picker_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    RouterLink,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiDatePickerComponent,
    LiDatePickerTriggerDirective,
  ],
  exports: [DemoRoutePaths],
)
class DatePickerPageComponent {
  DatePickerPageComponent(this.i18n);

  static const String ngModelApiSnippet = '''
<li-date-picker
  [(ngModel)]="selectedDate"
  [minDate]="minDate"
  [maxDate]="maxDate"
  [placeholder]="placeholder"
  locale="en_US">
</li-date-picker>''';

  static const String validationSnippet = '''
<li-date-picker
  [(ngModel)]="selectedDate"
  [liRules]="[LiRule.required()]"
  [liMessages]="{
    'required': 'Selecione uma data.'
  }"
  liValidationMode="submitted">
</li-date-picker>''';

  static const String userValueChangeSnippet = '''
<li-date-picker
  [(ngModel)]="selectedDate"
  (currentValueChange)="syncSelectedDate(\$event)"
  (userValueChange)="reloadAfterUserDateChange(\$event)">
</li-date-picker>''';

  static const String automationHooksSnippet = '''
await clickFirstVisible(page, '[data-label="li_dp_trigger"]');
await clickFirstVisible(page, '[data-label="li_dp_next"]');
await clickFirstVisible(
  page,
  '[data-label="li_dp_day"].available:not(.off)',
);
await clickFirstVisible(page, '[data-label="li_dp_clear_trigger"]');''';

  static const String customTriggerSnippet = '''
<li-date-picker [(ngModel)]="badgeDate">
  <template liDatePickerTrigger let-ctx>
    <span class="badge bg-primary d-inline-flex align-items-center gap-1">
      <i class="ph ph-calendar-blank"></i>
      {{ ctx.hasValue ? ctx.displayValue : ctx.placeholder }}
    </span>
  </template>
</li-date-picker>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;
  bool get isPortuguese => i18n.isPortuguese;

  DateTime? selectedDate = DateTime(2026, 3, 20);
  DateTime? restrictedDate = DateTime(2026, 3, 18);
  DateTime? englishDate = DateTime(2026, 11, 4);
  DateTime? disabledDate = DateTime(2026, 3, 12);
  DateTime? badgeDate = DateTime(2026, 4, 17);
  final DateTime minDate = DateTime(2026, 3, 5);
  final DateTime maxDate = DateTime(2026, 3, 25);

  String get dateRangeCtaTitle =>
      _isPt ? 'Precisa selecionar um período?' : 'Need to select a date range?';

  String get dateRangeCtaBody => _isPt
      ? 'A demo dedicada do Date Range continua disponível com exemplos de início, fim e restrições.'
      : 'The dedicated Date Range demo is still available with start, end, and constrained examples.';

  String get dateRangeCtaButton =>
      _isPt ? 'Abrir demo de Date Range' : 'Open Date Range demo';

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

  String get badgeDateLabel {
    final value = badgeDate;
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
