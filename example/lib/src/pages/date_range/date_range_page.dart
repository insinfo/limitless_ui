import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'date-range-page',
  templateUrl: 'date_range_page.html',
  styleUrls: ['date_range_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiDateRangePickerComponent,
    LiDateRangePickerTriggerDirective,
  ],
)
class DateRangePageComponent {
  DateRangePageComponent(this.i18n) {
    final today = _dateOnly(DateTime.now());
    presetRangeStart = _monthStart(today);
    presetRangeEnd = _monthEnd(today);
    presetRangesPt = _buildPresetRanges(today, portuguese: true);
    presetRangesEn = _buildPresetRanges(today, portuguese: false);
  }

  static const String apiSnippet = '''
<li-date-range-picker
  [start]="rangeStart"
  [end]="rangeEnd"
  [minDate]="minDate"
  [maxDate]="maxDate"
  (startChange)="onRangeStartChange(\$event)"
  (endChange)="onRangeEndChange(\$event)">
</li-date-range-picker>''';

  static const String userValueChangeSnippet = '''
<li-date-range-picker
  [start]="rangeStart"
  [end]="rangeEnd"
  (startChange)="rangeStart = \$event"
  (endChange)="rangeEnd = \$event"
  (userValueChange)="reloadAfterUserRangeChange(\$event)">
</li-date-range-picker>''';

  static const String customTriggerSnippet = '''
<li-date-range-picker
  [start]="badgeRangeStart"
  [end]="badgeRangeEnd"
  (startChange)="onBadgeRangeStartChange(\$event)"
  (endChange)="onBadgeRangeEndChange(\$event)">
  <template liDateRangePickerTrigger let-ctx>
    <span class="badge bg-primary d-inline-flex align-items-center gap-1">
      <i class="ph ph-calendar-blank"></i>
      {{ ctx.hasValue ? ctx.displayValue : ctx.placeholder }}
    </span>
  </template>
</li-date-range-picker>''';

  static const String presetsSnippet = '''
<li-date-range-picker
  [presets]="presetRanges"
  [start]="presetRangeStart"
  [end]="presetRangeEnd"
  (startChange)="onPresetRangeStartChange(\$event)"
  (endChange)="onPresetRangeEndChange(\$event)">
</li-date-range-picker>''';

  static const String automationHooksSnippet = '''
await clickFirstVisible(page, '[data-label="li_date_range_picker_trigger"]');
await clickFirstVisible(page, '[data-label="li_date_range_picker_left_next"]');
await clickVisibleAt(
  page,
  '[data-label="li_date_range_picker_day"][data-calendar="left"].available:not(.off)',
  0,
);
await clickFirstVisible(page, '[data-label="li_date_range_picker_apply"]');''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get isPortuguese => i18n.isPortuguese;

  DateTime? rangeStart = DateTime(2026, 3, 1);
  DateTime? rangeEnd = DateTime(2026, 3, 21);
  DateTime? constrainedStart = DateTime(2026, 3, 10);
  DateTime? constrainedEnd = DateTime(2026, 3, 18);
  DateTime? badgeRangeStart = DateTime(2026, 4, 6);
  DateTime? badgeRangeEnd = DateTime(2026, 4, 17);
  DateTime? presetRangeStart;
  DateTime? presetRangeEnd;
  late final List<LiDateRangePreset> presetRangesPt;
  late final List<LiDateRangePreset> presetRangesEn;
  final DateTime minDate = DateTime(2026, 3, 5);
  final DateTime maxDate = DateTime(2026, 3, 25);

  List<LiDateRangePreset> get presetRanges =>
      isPortuguese ? presetRangesPt : presetRangesEn;

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

  String get badgeRangeLabel {
    if (badgeRangeStart == null || badgeRangeEnd == null) {
      return t.pages.dateRange.partial;
    }
    return '${_formatDate(badgeRangeStart!)} ${t.pages.dateRange.between} ${_formatDate(badgeRangeEnd!)}';
  }

  String get presetRangeLabel {
    if (presetRangeStart == null || presetRangeEnd == null) {
      return t.pages.dateRange.partial;
    }
    return '${_formatDate(presetRangeStart!)} ${t.pages.dateRange.between} ${_formatDate(presetRangeEnd!)}';
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

  void onBadgeRangeStartChange(DateTime? value) {
    badgeRangeStart = value;
  }

  void onBadgeRangeEndChange(DateTime? value) {
    badgeRangeEnd = value;
  }

  void onPresetRangeStartChange(DateTime? value) {
    presetRangeStart = value;
  }

  void onPresetRangeEndChange(DateTime? value) {
    presetRangeEnd = value;
  }

  List<LiDateRangePreset> _buildPresetRanges(
    DateTime today, {
    required bool portuguese,
  }) {
    final yesterday = today.subtract(const Duration(days: 1));
    final currentMonthStart = _monthStart(today);
    final currentMonthEnd = _monthEnd(today);
    final lastMonthReference = DateTime(today.year, today.month - 1, 1);
    final lastMonthStart = _monthStart(lastMonthReference);
    final lastMonthEnd = _monthEnd(lastMonthReference);

    return <LiDateRangePreset>[
      LiDateRangePreset(
        label: portuguese ? 'Hoje' : 'Today',
        value: 'today',
        start: today,
        end: today,
      ),
      LiDateRangePreset(
        label: portuguese ? 'Ontem' : 'Yesterday',
        value: 'yesterday',
        start: yesterday,
        end: yesterday,
      ),
      LiDateRangePreset(
        label: portuguese ? 'Ultimos 7 dias' : 'Last 7 Days',
        value: 'last_7_days',
        start: today.subtract(const Duration(days: 6)),
        end: today,
      ),
      LiDateRangePreset(
        label: portuguese ? 'Ultimos 30 dias' : 'Last 30 Days',
        value: 'last_30_days',
        start: today.subtract(const Duration(days: 29)),
        end: today,
      ),
      LiDateRangePreset(
        label: portuguese ? 'Este mes' : 'This Month',
        value: 'this_month',
        start: currentMonthStart,
        end: currentMonthEnd,
      ),
      LiDateRangePreset(
        label: portuguese ? 'Mes passado' : 'Last Month',
        value: 'last_month',
        start: lastMonthStart,
        end: lastMonthEnd,
      ),
    ];
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime _monthStart(DateTime value) => DateTime(value.year, value.month, 1);

  DateTime _monthEnd(DateTime value) =>
      DateTime(value.year, value.month + 1, 0);

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
