import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;
import 'package:popper/popper.dart';

import '../../core/overlay_positioning.dart';

enum DatePickerViewMode { day, month, year }

class DatePickerMonthOption {
  final int month;
  final String label;

  const DatePickerMonthOption({
    required this.month,
    required this.label,
  });
}

class DatePickerCalendarCell {
  final DateTime date;
  final bool isCurrentMonth;

  const DatePickerCalendarCell({
    required this.date,
    required this.isCurrentMonth,
  });
}

/// Single-date picker built from the same visual and behavioral foundation as
/// `LiDateRangePickerComponent`.
///
/// The component supports both explicit `[value]`/`(valueChange)` bindings and
/// AngularDart forms via `[(ngModel)]` through `ControlValueAccessor`.
@Component(
  selector: 'li-date-picker',
  styleUrls: ['date_picker_component.css'],
  templateUrl: 'date_picker_component.html',
  directives: [coreDirectives],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiDatePickerComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiDatePickerComponent
    implements ControlValueAccessor<DateTime?>, OnDestroy {
  LiDatePickerComponent(this._changeDetectorRef) {
    _refreshCalendar();
  }

  static const List<String> _weekdayLabelsPt = <String>[
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sab',
  ];

  static const List<String> _monthLabelsPt = <String>[
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const List<String> _weekdayLabelsEn = <String>[
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  static const List<String> _monthLabelsEn = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _monthShortLabelsPt = <String>[
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  static const List<String> _monthShortLabelsEn = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final ChangeDetectorRef _changeDetectorRef;
  final StreamController<DateTime?> _valueChangeController =
      StreamController<DateTime?>.broadcast();

  PopperAnchoredOverlay? _overlay;
  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;

  @Input()
  DateTime? value;

  @Input()
  DateTime? minDate;

  @Input()
  DateTime? maxDate;

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  String? placeholder;

  @Input()
  String locale = 'pt_BR';

  @Input()
  bool invalid = false;

  @Input()
  bool valid = false;

  @Input()
  bool dataInvalid = false;

  @Input()
  bool required = false;

  @Input()
  String errorText = '';

  @Input()
  String helperText = '';

  @Input()
  String feedbackClass = '';

  @Input()
  String describedBy = '';

  @Output()
  Stream<DateTime?> get valueChange => _valueChangeController.stream;

  @ViewChild('triggerElement')
  html.Element? triggerElement;

  @ViewChild('panelElement')
  html.Element? panelElement;

  DateTime? draftValue;
  DateTime visibleMonth = _monthStart(DateTime.now());
  late List<List<DatePickerCalendarCell>> calendar;
  bool isOpen = false;
  DatePickerViewMode viewMode = DatePickerViewMode.day;

  ChangeFunction<DateTime?> _onChange = (DateTime? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};
  bool _touched = false;

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get effectiveInvalid =>
      invalid || dataInvalid || (required && _touched && value == null);

  bool get effectiveValid =>
      !effectiveInvalid && (valid || (required && _touched && value != null));

  bool get hasHelperText => helperText.trim().isNotEmpty;

  bool get showErrorFeedback => errorText.trim().isNotEmpty && effectiveInvalid;

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String get resolvedInputClass => _joinClasses(<String>[
        'form-control',
        'date-picker-field',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  List<String> get weekdayLabels =>
      _isEnglishLocale ? _weekdayLabelsEn : _weekdayLabelsPt;

  List<DatePickerMonthOption> get monthOptions {
    final labels = _isEnglishLocale ? _monthShortLabelsEn : _monthShortLabelsPt;
    return List<DatePickerMonthOption>.generate(
      12,
      (int index) => DatePickerMonthOption(
        month: index + 1,
        label: labels[index].toUpperCase(),
      ),
    );
  }

  List<int> get visibleYearRange => _buildYearRange(visibleMonth.year);

  bool get isDayView => viewMode == DatePickerViewMode.day;

  bool get isMonthView => viewMode == DatePickerViewMode.month;

  bool get isYearView => viewMode == DatePickerViewMode.year;

  String get displayValue => _formatDate(value);

  String get draftDisplayValue => _formatDate(draftValue);

  String get effectivePlaceholder =>
      placeholder ?? (_isEnglishLocale ? 'Select a date' : 'Selecione a data');

  String get emptySelectionLabel =>
      _isEnglishLocale ? 'No date selected' : 'Nenhuma data selecionada';

  String get clearLabel => _isEnglishLocale ? 'Clear' : 'Limpar';

  String get cancelLabel => _isEnglishLocale ? 'Cancel' : 'Cancelar';

  String get currentHeaderLabel {
    if (isYearView) {
      return '${visibleYearRange.first} - ${visibleYearRange.last}';
    }

    if (isMonthView) {
      return '${visibleMonth.year}';
    }

    return monthLabel(visibleMonth);
  }

  void toggleOpen() {
    if (isDisabled) {
      return;
    }

    if (isOpen) {
      close();
      return;
    }

    _open();
  }

  void _open() {
    _ensureOverlay();
    draftValue = _normalize(value);
    _syncVisibleMonth();
    viewMode = DatePickerViewMode.day;
    isOpen = true;
    _overlay?.startAutoUpdate();
    _overlay?.update();
    _bindDocumentListeners();
    _markForCheck();
  }

  void toggleViewMode() {
    if (isDayView) {
      viewMode = DatePickerViewMode.month;
    } else if (isMonthView) {
      viewMode = DatePickerViewMode.year;
    } else {
      viewMode = DatePickerViewMode.day;
    }
    _markForCheck();
  }

  void navigateBackward() {
    if (isYearView) {
      visibleMonth = DateTime(
          visibleMonth.year - visibleYearRange.length, visibleMonth.month, 1);
    } else if (isMonthView) {
      visibleMonth = DateTime(visibleMonth.year - 1, visibleMonth.month, 1);
    } else {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1, 1);
    }
    _refreshCalendar();
    _markForCheck();
  }

  void navigateForward() {
    if (isYearView) {
      visibleMonth = DateTime(
          visibleMonth.year + visibleYearRange.length, visibleMonth.month, 1);
    } else if (isMonthView) {
      visibleMonth = DateTime(visibleMonth.year + 1, visibleMonth.month, 1);
    } else {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 1);
    }
    _refreshCalendar();
    _markForCheck();
  }

  void selectMonth(int month) {
    if (isMonthDisabled(visibleMonth.year, month)) {
      return;
    }

    visibleMonth = DateTime(visibleMonth.year, month, 1);
    viewMode = DatePickerViewMode.day;
    _refreshCalendar();
    _markForCheck();
  }

  void selectYear(int year) {
    if (isYearDisabled(year)) {
      return;
    }

    visibleMonth = DateTime(year, visibleMonth.month, 1);
    viewMode = DatePickerViewMode.month;
    _refreshCalendar();
    _markForCheck();
  }

  void selectDay(DateTime date) {
    final normalized = _normalize(date);
    if (normalized == null || isDisabledDate(normalized)) {
      return;
    }

    draftValue = normalized;
    value = _normalize(draftValue);
    _valueChangeController.add(value);
    _onChange(value);
    _markTouched();
    close();
    _markForCheck();
  }

  void clear() {
    draftValue = null;
    value = null;
    _valueChangeController.add(null);
    _onChange(null);
    _markTouched();
    close();
    _markForCheck();
  }

  void close() {
    if (isOpen) {
      _markTouched();
    }
    _unbindDocumentListeners();
    _overlay?.stopAutoUpdate();
    isOpen = false;
    viewMode = DatePickerViewMode.day;
    _markTouched();
    _markForCheck();
  }

  @override
  void writeValue(DateTime? value) {
    this.value = _normalize(value);
    draftValue = this.value;
    _syncVisibleMonth();
    _markForCheck();
  }

  @override
  void registerOnChange(ChangeFunction<DateTime?> fn) {
    _onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _onTouched = fn;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    this.isDisabled = isDisabled;
    if (isDisabled && isOpen) {
      close();
    }
    _markForCheck();
  }

  void _ensureOverlay() {
    final reference = triggerElement;
    final floating = panelElement;

    if (_overlay != null || reference == null || floating == null) {
      return;
    }

    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: reference,
      floatingElement: floating,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'LiDatePickerComponent',
        hostZIndex: '1085',
        floatingZIndex: '1086',
      ),
      popperOptions: PopperOptions(
        placement: 'bottom-start',
        fallbackPlacements: <String>[
          'top-start',
          'bottom-end',
          'top-end',
        ],
        strategy: PopperStrategy.fixed,
        padding: PopperInsets.all(8),
        offset: PopperOffset(mainAxis: 8),
        onLayout: _handleOverlayLayout,
      ),
    );
  }

  void _handleOverlayLayout(PopperLayout layout) {
    normalizeOverlayVerticalPosition(
      floatingElement: panelElement,
      layout: layout,
    );
  }

  void _bindDocumentListeners() {
    _documentClickSubscription ??= html.document.onClick.listen((event) {
      if (!isOpen) {
        return;
      }

      final target = event.target;
      if (target is! html.Node) {
        close();
        _markForCheck();
        return;
      }

      final clickedTrigger = triggerElement?.contains(target) ?? false;
      final clickedPanel = panelElement?.contains(target) ?? false;

      if (!clickedTrigger && !clickedPanel) {
        close();
        _markForCheck();
      }
    });

    _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
      if (isOpen && event.key == 'Escape') {
        event.preventDefault();
        close();
        _markForCheck();
      }
    });
  }

  void onPanelClick(html.Event event) {
    event.stopPropagation();
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription?.cancel();
    _documentKeySubscription = null;
  }

  bool isDisabledDate(DateTime date) {
    final normalized = _normalize(date);
    if (normalized == null) {
      return true;
    }

    if (minDate != null && normalized.isBefore(_normalize(minDate!)!)) {
      return true;
    }

    if (maxDate != null && normalized.isAfter(_normalize(maxDate!)!)) {
      return true;
    }

    return false;
  }

  bool isToday(DateTime date) => _isSameDate(date, DateTime.now());

  bool isSelectedDate(DateTime date) => _isSameDate(date, draftValue);

  bool isMonthDisabled(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    final normalizedMinDate = _normalize(minDate);
    if (normalizedMinDate != null && lastDay.isBefore(normalizedMinDate)) {
      return true;
    }

    final normalizedMaxDate = _normalize(maxDate);
    if (normalizedMaxDate != null && firstDay.isAfter(normalizedMaxDate)) {
      return true;
    }

    return false;
  }

  bool isYearDisabled(int year) {
    for (var month = 1; month <= 12; month++) {
      if (!isMonthDisabled(year, month)) {
        return false;
      }
    }

    return true;
  }

  String monthLabel(DateTime month) {
    final labels = _isEnglishLocale ? _monthLabelsEn : _monthLabelsPt;
    final label = labels[month.month - 1];
    return '$label ${month.year}';
  }

  List<List<DatePickerCalendarCell>> _buildCalendar(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = firstDay.weekday % 7;
    var cursor = firstDay.subtract(Duration(days: startOffset));
    final weeks = <List<DatePickerCalendarCell>>[];

    for (var row = 0; row < 6; row++) {
      final week = <DatePickerCalendarCell>[];
      for (var col = 0; col < 7; col++) {
        week.add(DatePickerCalendarCell(
          date: cursor,
          isCurrentMonth: cursor.month == month.month,
        ));
        cursor = cursor.add(Duration(days: 1));
      }
      weeks.add(week);
    }

    return weeks;
  }

  void _syncVisibleMonth() {
    visibleMonth = _monthStart(draftValue ?? value ?? DateTime.now());
    _refreshCalendar();
  }

  void _refreshCalendar() {
    calendar = _buildCalendar(visibleMonth);
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  void _markTouched() {
    if (_touched) {
      _onTouched();
      return;
    }
    _touched = true;
    _onTouched();
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }

    final normalized = _normalize(value)!;
    if (_isEnglishLocale) {
      return '${_twoDigits(normalized.month)}/${_twoDigits(normalized.day)}/${normalized.year}';
    }
    return '${_twoDigits(normalized.day)}/${_twoDigits(normalized.month)}/${normalized.year}';
  }

  static DateTime _monthStart(DateTime value) =>
      DateTime(value.year, value.month, 1);

  DateTime? _normalize(DateTime? value) {
    if (value == null) {
      return null;
    }
    return DateTime(value.year, value.month, value.day);
  }

  bool _isSameDate(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return false;
    }

    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _twoDigits(int value) {
    if (value < 10) {
      return '0$value';
    }
    return '$value';
  }

  List<int> _buildYearRange(int year) {
    final startYear = year - (year % 24);
    return List<int>.generate(24, (int index) => startYear + index);
  }

  Object? trackByMonthOption(int index, dynamic option) =>
      (option as DatePickerMonthOption).month;

  Object? trackByYear(int index, dynamic year) => year;

  Object? trackByWeek(int index, dynamic week) {
    final typedWeek = week as List<DatePickerCalendarCell>;
    return '${typedWeek.first.date.year}-${typedWeek.first.date.month}-${typedWeek.first.date.day}';
  }

  Object? trackByCell(int index, dynamic cell) =>
      (cell as DatePickerCalendarCell).date.millisecondsSinceEpoch;

  @override
  void ngOnDestroy() {
    _unbindDocumentListeners();
    _overlay?.dispose();
    _valueChangeController.close();
  }
}
