import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

import 'package:popper/popper.dart';

import '../../core/overlay_positioning.dart';

enum DateRangePickerViewMode { day, month, year }

class DateRangePickerMonthOption {
  final int month;
  final String label;

  const DateRangePickerMonthOption({
    required this.month,
    required this.label,
  });
}

class LiDateRangeValue {
  final DateTime? inicio;
  final DateTime? fim;

  const LiDateRangeValue({
    this.inicio,
    this.fim,
  });

  bool get isEmpty => inicio == null && fim == null;
}

class CalendarCell {
  final DateTime date;
  final bool isCurrentMonth;

  const CalendarCell({
    required this.date,
    required this.isCurrentMonth,
  });
}

class LiDateRangePreset {
  final String label;
  final DateTime? inicio;
  final DateTime? fim;
  final String value;
  final bool disabled;

  const LiDateRangePreset({
    required this.label,
    DateTime? inicio,
    DateTime? fim,
    DateTime? start,
    DateTime? end,
    this.value = '',
    this.disabled = false,
  })  : inicio = inicio ?? start,
        fim = fim ?? end;

  DateTime? get start => inicio;

  DateTime? get end => fim;
}

class LiDateRangePickerTriggerContext {
  LiDateRangePickerTriggerContext._(this._component);

  final LiDateRangePickerComponent _component;
  DateTime? _cachedInicio;
  DateTime? _cachedFim;
  LiDateRangeValue _cachedValue = const LiDateRangeValue();

  LiDateRangeValue get value {
    if (_cachedInicio != _component.inicio || _cachedFim != _component.fim) {
      _cachedInicio = _component.inicio;
      _cachedFim = _component.fim;
      _cachedValue = LiDateRangeValue(
        inicio: _cachedInicio,
        fim: _cachedFim,
      );
    }
    return _cachedValue;
  }

  DateTime? get inicio => _component.inicio;

  DateTime? get fim => _component.fim;

  DateTime? get start => _component.start;

  DateTime? get end => _component.end;

  DateTime? get draftInicio => _component.draftInicio;

  DateTime? get draftFim => _component.draftFim;

  String get displayValue => _component.displayValue;

  String get draftDisplayValue => _component.draftDisplayValue;

  String get placeholder => _component.effectivePlaceholder;

  bool get hasValue => _component.hasValue;

  bool get disabled => _component.isDisabled;

  bool get isOpen => _component.isOpen;

  void open() => _component.open();

  void close() => _component.close();

  void toggle() => _component.toggleOpen();

  void clear([html.Event? event]) => _component.clearFromTriggerTemplate(event);
}

@Directive(selector: 'template[liDateRangePickerTrigger]')
class LiDateRangePickerTriggerDirective {
  LiDateRangePickerTriggerDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Component(
  selector: 'li-date-range-picker',
  styleUrls: ['date_range_picker_component.css'],
  templateUrl: 'date_range_picker_component.html',
  directives: [
    coreDirectives,
    LiDateRangePickerTriggerDirective,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiDateRangePickerComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiDateRangePickerComponent
    implements ControlValueAccessor<LiDateRangeValue?>, OnDestroy {
  final ChangeDetectorRef _changeDetectorRef;
  PopperAnchoredOverlay? _overlay;
  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;

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

  final _inicioChangeController = StreamController<DateTime?>.broadcast();
  final _fimChangeController = StreamController<DateTime?>.broadcast();
  final _userValueChangeController =
      StreamController<LiDateRangeValue?>.broadcast();

  DateTime? _inicio;
  DateTime? _fim;

  DateTime? get inicio => _inicio;
  @Input()
  set inicio(DateTime? value) {
    _inicio = _normalize(value);
  }

  /// Alias em inglês para compatibilidade com APIs `start/end`.
  DateTime? get start => _inicio;
  @Input('start')
  set start(DateTime? value) {
    _inicio = _normalize(value);
  }

  DateTime? get fim => _fim;

  @Input()
  set fim(DateTime? value) {
    _fim = _normalize(value);
  }

  /// Alias em inglês para compatibilidade com APIs `start/end`.
  DateTime? get end => _fim;
  @Input('end')
  set end(DateTime? value) {
    _fim = _normalize(value);
  }

  @Input()
  DateTime? minDate;

  @Input()
  DateTime? maxDate;

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  String? placeholder;

  @Input()
  String? name;

  @Input()
  String locale = 'pt_BR';

  @Input()
  String size = '';

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

  /// Supported values: `default`, `overlay`, `addon`, `hidden`.
  @Input()
  String triggerIconMode = 'default';

  @Input()
  String triggerIconClass = '';

  @Input()
  bool showClearButton = true;

  @Input()
  List<LiDateRangePreset> presets = const <LiDateRangePreset>[];

  @Input()
  bool showCustomRangePreset = true;

  @Input()
  bool alwaysShowCalendars = false;

  @Input()
  bool showCalendarsForCustomRange = false;

  @Input()
  bool presetAutoApply = true;

  @Input()
  String customRangePresetLabel = '';

  /// Mobile presentation for small viewports.
  ///
  /// `dropdown` keeps the normal anchored overlay. `modal` shows a fixed
  /// dialog with a backdrop, and `sheet` shows a bottom sheet.
  @Input()
  String mobilePresentation = 'modal';

  /// CSS `max-width` media-query used by [mobilePresentation].
  @Input()
  String mobileBreakpoint = '767.98px';

  /// Optional CSS `max-height` media-query used by [mobilePresentation].
  @Input()
  String mobileHeightBreakpoint = '';

  @Output()
  Stream<DateTime?> get inicioChange => _inicioChangeController.stream;

  @Output('startChange')
  Stream<DateTime?> get startChange => _inicioChangeController.stream;

  @Output()
  Stream<DateTime?> get fimChange => _fimChangeController.stream;

  @Output('endChange')
  Stream<DateTime?> get endChange => _fimChangeController.stream;

  @Output('userValueChange')
  Stream<LiDateRangeValue?> get userValueChange =>
      _userValueChangeController.stream;

  @ViewChild('triggerElement')
  html.Element? triggerElement;

  @ViewChild('panelElement')
  html.Element? panelElement;

  @ContentChild(LiDateRangePickerTriggerDirective)
  LiDateRangePickerTriggerDirective? triggerTemplate;

  DateTime? draftInicio;
  DateTime? draftFim;
  DateTime? hoverDateValue;
  DateTime leftMonth = _monthStart(DateTime.now());
  DateTime rightMonth = _monthStart(DateTime.now().add(Duration(days: 31)));
  late List<List<CalendarCell>> leftCalendar;
  late List<List<CalendarCell>> rightCalendar;
  bool isOpen = false;
  bool isSelectingEnd = false;
  bool _customRangeActive = false;
  bool _presetCalendarReviewActive = false;
  DateRangePickerViewMode leftViewMode = DateRangePickerViewMode.day;
  DateRangePickerViewMode rightViewMode = DateRangePickerViewMode.day;
  late final LiDateRangePickerTriggerContext triggerContext =
      LiDateRangePickerTriggerContext._(this);

  ChangeFunction<LiDateRangeValue?> _onChange =
      (LiDateRangeValue? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};
  bool _touched = false;

  LiDateRangePickerComponent(this._changeDetectorRef) {
    _refreshCalendars();
  }

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get effectiveInvalid =>
      invalid ||
      dataInvalid ||
      (required && _touched && inicio == null && fim == null);

  bool get effectiveValid =>
      !effectiveInvalid &&
      (valid || (required && _touched && (inicio != null || fim != null)));

  bool get hasHelperText => helperText.trim().isNotEmpty;

  bool get showErrorFeedback => errorText.trim().isNotEmpty && effectiveInvalid;

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String? get resolvedName => name;

  String get resolvedInputClass => _joinClasses(<String>[
        'form-control',
        _formControlSizeClass,
        'date-range-field',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
      ]);

  String get resolvedInputGroupClass => _joinClasses(<String>[
        'input-group',
        _inputGroupSizeClass,
        isDisabled ? 'disabled' : '',
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  List<String> get weekdayLabels =>
      _isEnglishLocale ? _weekdayLabelsEn : _weekdayLabelsPt;

  List<DateRangePickerMonthOption> get monthOptions {
    final labels = _isEnglishLocale ? _monthShortLabelsEn : _monthShortLabelsPt;
    return List<DateRangePickerMonthOption>.generate(
      12,
      (int index) => DateRangePickerMonthOption(
        month: index + 1,
        label: labels[index].toUpperCase(),
      ),
    );
  }

  List<int> get leftVisibleYears => _buildYearRange(leftMonth.year);

  List<int> get rightVisibleYears => _buildYearRange(rightMonth.year);

  bool get isLeftDayView => leftViewMode == DateRangePickerViewMode.day;

  bool get isLeftMonthView => leftViewMode == DateRangePickerViewMode.month;

  bool get isLeftYearView => leftViewMode == DateRangePickerViewMode.year;

  bool get isRightDayView => rightViewMode == DateRangePickerViewMode.day;

  bool get isRightMonthView => rightViewMode == DateRangePickerViewMode.month;

  bool get isRightYearView => rightViewMode == DateRangePickerViewMode.year;

  bool get canApply => draftInicio != null || draftFim != null;

  bool get hasPresets => presets.isNotEmpty;

  bool get showCalendars =>
      !hasPresets ||
      alwaysShowCalendars ||
      _customRangeActive ||
      _presetCalendarReviewActive;

  bool get showPresetList => hasPresets;

  String get displayValue => _formatRange(inicio, fim);

  String get draftDisplayValue => _formatRange(draftInicio, draftFim);

  String get effectivePlaceholder =>
      placeholder ??
      (_isEnglishLocale ? 'Select the period' : 'Selecione o periodo');

  String get emptySelectionLabel =>
      _isEnglishLocale ? 'No period selected' : 'Nenhum período selecionado';

  String get clearLabel => _isEnglishLocale ? 'Clear' : 'Limpar';

  String get clearAriaLabel =>
      _isEnglishLocale ? 'Clear selected period' : 'Limpar período selecionado';

  String get cancelLabel => _isEnglishLocale ? 'Cancel' : 'Cancelar';

  String get applyLabel => _isEnglishLocale ? 'Apply' : 'Aplicar';

  String get resolvedCustomRangePresetLabel {
    final custom = customRangePresetLabel.trim();
    if (custom.isNotEmpty) {
      return custom;
    }
    return _isEnglishLocale ? 'Custom Range' : 'Intervalo personalizado';
  }

  bool get hasValue => inicio != null || fim != null;

  String get normalizedTriggerIconMode {
    switch (triggerIconMode.trim().toLowerCase()) {
      case 'overlay':
        return 'overlay';
      case 'hidden':
        return 'hidden';
      case 'addon':
        return 'addon';
      default:
        return 'default';
    }
  }

  bool get usesOverlayTriggerIcon => normalizedTriggerIconMode == 'overlay';

  bool get showsTriggerIcon => normalizedTriggerIconMode != 'hidden';

  bool get showsClearButton => showClearButton && hasValue;

  String get resolvedTriggerIconClass {
    final custom = triggerIconClass.trim();
    return custom.isNotEmpty ? custom : 'ph ph-calendar-blank';
  }

  String get resolvedOverlayInputClass => _joinClasses(<String>[
        resolvedInputClass,
        'date-range-field--overlay',
        showsClearButton ? 'date-range-field--overlay-clear' : '',
        showsTriggerIcon ? 'date-range-field--overlay-trigger' : '',
      ]);

  String get leftHeaderLabel => _headerLabel(leftMonth, leftViewMode);

  String get rightHeaderLabel => _headerLabel(rightMonth, rightViewMode);

  bool get usesMobileModal =>
      isOpen &&
      matchesResponsivePresentation(
        configuredPresentation: mobilePresentation,
        presentation: 'modal',
        widthBreakpoint: mobileBreakpoint,
        heightBreakpoint: mobileHeightBreakpoint,
      );

  bool get usesMobileSheet =>
      isOpen &&
      matchesResponsivePresentation(
        configuredPresentation: mobilePresentation,
        presentation: 'sheet',
        widthBreakpoint: mobileBreakpoint,
        heightBreakpoint: mobileHeightBreakpoint,
      );

  bool get usesMobilePresentation => usesMobileModal || usesMobileSheet;

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

  void open() {
    if (isDisabled || isOpen) {
      return;
    }

    _open();
  }

  void handleTriggerKeydown(html.Event event) {
    if (event is! html.KeyboardEvent) {
      return;
    }

    if (event.code == 'Enter' ||
        event.code == 'NumpadEnter' ||
        event.code == 'Space' ||
        event.key == ' ') {
      event.preventDefault();
      toggleOpen();
    }
  }

  void _open() {
    draftInicio = _normalize(inicio);
    draftFim = _normalize(fim);
    hoverDateValue = null;
    isSelectingEnd = draftInicio != null && draftFim == null;
    _customRangeActive = !alwaysShowCalendars &&
        showCalendarsForCustomRange &&
        hasPresets &&
        !_matchesAnyPreset(inicio, fim);
    _presetCalendarReviewActive = false;
    _syncVisibleMonths();
    leftViewMode = DateRangePickerViewMode.day;
    rightViewMode = DateRangePickerViewMode.day;
    isOpen = true;
    if (!usesMobilePresentation) {
      _ensureOverlay();
      resetOverlayViewportConstraints(floatingElement: panelElement);
      _overlay?.startAutoUpdate();
      _overlay?.update();
    } else {
      _overlay?.stopAutoUpdate();
    }
    _bindDocumentListeners();
    _markForCheck();
  }

  void selectPreset(LiDateRangePreset preset) {
    if (isDisabled || isPresetDisabled(preset)) {
      return;
    }

    final nextInicio = _normalize(preset.inicio);
    final nextFim = _normalize(preset.fim);
    draftInicio = nextInicio;
    draftFim = nextFim;
    hoverDateValue = null;
    isSelectingEnd = false;
    _customRangeActive = false;
    _presetCalendarReviewActive = false;
    _syncVisibleMonths();

    if (presetAutoApply) {
      apply();
      return;
    }

    _presetCalendarReviewActive = true;
    _scheduleOverlayUpdate();
    _markForCheck();
  }

  void showCustomRange() {
    if (isDisabled) {
      return;
    }

    _customRangeActive = true;
    _presetCalendarReviewActive = false;
    _syncVisibleMonths();
    _scheduleOverlayUpdate();
    _markForCheck();
  }

  bool isPresetActive(LiDateRangePreset preset) {
    if (_customRangeActive) {
      return false;
    }

    return _isSameRange(
      draftInicio,
      draftFim,
      _normalize(preset.inicio),
      _normalize(preset.fim),
    );
  }

  bool isCustomRangePresetActive() {
    if (!hasPresets) {
      return false;
    }
    return _customRangeActive || !_matchesAnyPreset(draftInicio, draftFim);
  }

  bool isPresetDisabled(LiDateRangePreset preset) {
    if (preset.disabled) {
      return true;
    }

    final presetInicio = _normalize(preset.inicio);
    final presetFim = _normalize(preset.fim);
    if (presetInicio == null && presetFim == null) {
      return true;
    }

    if (presetInicio != null && isDisabledDate(presetInicio)) {
      return true;
    }

    if (presetFim != null && isDisabledDate(presetFim)) {
      return true;
    }

    return false;
  }

  String presetDataValue(LiDateRangePreset preset, int index) {
    final value = preset.value.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return index.toString();
  }

  void prevMonth() {
    if (isLeftYearView) {
      leftMonth = DateTime(
          leftMonth.year - leftVisibleYears.length, leftMonth.month, 1);
      rightMonth =
          _monthStart(DateTime(leftMonth.year, leftMonth.month + 1, 1));
      _refreshCalendars();
    } else if (isLeftMonthView) {
      leftMonth = DateTime(leftMonth.year - 1, leftMonth.month, 1);
      rightMonth =
          _monthStart(DateTime(leftMonth.year, leftMonth.month + 1, 1));
      _refreshCalendars();
    } else {
      _setVisibleMonths(DateTime(leftMonth.year, leftMonth.month - 1, 1));
    }
    _markForCheck();
  }

  void nextMonth() {
    if (isRightYearView) {
      rightMonth = DateTime(
          rightMonth.year + rightVisibleYears.length, rightMonth.month, 1);
      leftMonth =
          _monthStart(DateTime(rightMonth.year, rightMonth.month - 1, 1));
      _refreshCalendars();
    } else if (isRightMonthView) {
      rightMonth = DateTime(rightMonth.year + 1, rightMonth.month, 1);
      leftMonth =
          _monthStart(DateTime(rightMonth.year, rightMonth.month - 1, 1));
      _refreshCalendars();
    } else {
      _setVisibleMonths(DateTime(leftMonth.year, leftMonth.month + 1, 1));
    }
    _markForCheck();
  }

  void toggleLeftViewMode() {
    leftViewMode = _nextViewMode(leftViewMode);
    _markForCheck();
  }

  void toggleRightViewMode() {
    rightViewMode = _nextViewMode(rightViewMode);
    _markForCheck();
  }

  void selectLeftMonth(int month) {
    if (isMonthDisabled(leftMonth.year, month)) {
      return;
    }

    leftMonth = DateTime(leftMonth.year, month, 1);
    rightMonth = _monthStart(DateTime(leftMonth.year, leftMonth.month + 1, 1));
    leftViewMode = DateRangePickerViewMode.day;
    _refreshCalendars();
    _markForCheck();
  }

  void selectRightMonth(int month) {
    if (isMonthDisabled(rightMonth.year, month)) {
      return;
    }

    rightMonth = DateTime(rightMonth.year, month, 1);
    leftMonth = _monthStart(DateTime(rightMonth.year, rightMonth.month - 1, 1));
    rightViewMode = DateRangePickerViewMode.day;
    _refreshCalendars();
    _markForCheck();
  }

  void selectLeftYear(int year) {
    if (isYearDisabled(year)) {
      return;
    }

    leftMonth = DateTime(year, leftMonth.month, 1);
    rightMonth = _monthStart(DateTime(leftMonth.year, leftMonth.month + 1, 1));
    leftViewMode = DateRangePickerViewMode.month;
    _refreshCalendars();
    _markForCheck();
  }

  void selectRightYear(int year) {
    if (isYearDisabled(year)) {
      return;
    }

    rightMonth = DateTime(year, rightMonth.month, 1);
    leftMonth = _monthStart(DateTime(rightMonth.year, rightMonth.month - 1, 1));
    rightViewMode = DateRangePickerViewMode.month;
    _refreshCalendars();
    _markForCheck();
  }

  void selectDay(DateTime date) {
    final normalized = _normalize(date);
    if (normalized == null || isDisabledDate(normalized)) {
      return;
    }

    if (draftInicio == null || draftFim != null || !isSelectingEnd) {
      draftInicio = normalized;
      draftFim = null;
      hoverDateValue = null;
      isSelectingEnd = true;
      _markForCheck();
      return;
    }

    if (normalized.isBefore(draftInicio!)) {
      draftInicio = normalized;
      draftFim = null;
      hoverDateValue = null;
      isSelectingEnd = true;
      _markForCheck();
      return;
    }

    draftFim = normalized;
    hoverDateValue = null;
    isSelectingEnd = false;
    _markForCheck();
  }

  void hoverDay(DateTime date) {
    if (!isSelectingEnd || draftInicio == null || draftFim != null) {
      return;
    }

    final normalized = _normalize(date);
    if (normalized == null || normalized.isBefore(draftInicio!)) {
      hoverDateValue = null;
      _markForCheck();
      return;
    }

    hoverDateValue = normalized;
    _markForCheck();
  }

  void apply() {
    final previousInicio = inicio;
    final previousFim = fim;
    var inicioAplicado = _normalize(draftInicio);
    var fimAplicado = _normalize(draftFim);

    if (inicioAplicado != null &&
        fimAplicado != null &&
        fimAplicado.isBefore(inicioAplicado)) {
      final temp = inicioAplicado;
      inicioAplicado = fimAplicado;
      fimAplicado = temp;
    }

    inicio = inicioAplicado;
    fim = fimAplicado;
    _inicioChangeController.add(inicioAplicado);
    _fimChangeController.add(fimAplicado);
    if (!_isSameRange(previousInicio, previousFim, inicio, fim)) {
      _userValueChangeController.add(_currentRangeValue());
    }
    _emitModelChange();
    _markTouched();
    close();
    _markForCheck();
  }

  void clear() {
    final hadValue = hasValue;
    draftInicio = null;
    draftFim = null;
    hoverDateValue = null;
    isSelectingEnd = false;
    _customRangeActive = false;
    _presetCalendarReviewActive = false;
    inicio = null;
    fim = null;
    _inicioChangeController.add(null);
    _fimChangeController.add(null);
    if (hadValue) {
      _userValueChangeController.add(null);
    }
    _onChange(null);
    _markTouched();
    close();
    _markForCheck();
  }

  void clearFromTriggerTemplate([html.Event? event]) {
    event?.preventDefault();
    event?.stopPropagation();
    if (isDisabled) {
      return;
    }
    clear();
  }

  void clearFromTrigger(html.MouseEvent event) {
    clearFromTriggerTemplate(event);
  }

  void onPanelClick(html.Event event) {
    event.stopPropagation();
  }

  void close() {
    if (isOpen) {
      _markTouched();
    }
    _unbindDocumentListeners();
    _overlay?.stopAutoUpdate();
    isOpen = false;
    hoverDateValue = null;
    isSelectingEnd = false;
    _customRangeActive = false;
    _presetCalendarReviewActive = false;
    leftViewMode = DateRangePickerViewMode.day;
    rightViewMode = DateRangePickerViewMode.day;
    _markTouched();
    _markForCheck();
  }

  @override
  void writeValue(LiDateRangeValue? value) {
    inicio = _normalize(value?.inicio);
    fim = _normalize(value?.fim);
    draftInicio = inicio;
    draftFim = fim;
    hoverDateValue = null;
    isSelectingEnd = draftInicio != null && draftFim == null;
    _customRangeActive = !alwaysShowCalendars &&
        showCalendarsForCustomRange &&
        hasPresets &&
        !_matchesAnyPreset(inicio, fim);
    _presetCalendarReviewActive = false;
    _syncVisibleMonths();
    _markForCheck();
  }

  @override
  void registerOnChange(ChangeFunction<LiDateRangeValue?> fn) {
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

  void handleOutsideClick() {
    if (!isOpen) {
      return;
    }
    close();
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
      portalOptions: resolveModalAwarePortalOptions(
        hostClassName: 'LiDateRangePickerComponent',
        referenceElement: reference,
        baseHostZIndex: 1085,
        baseFloatingZIndex: 1086,
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
    constrainOverlayHeightToViewport(
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

  bool isStartDate(DateTime date) => _isSameDate(date, draftInicio);

  bool isEndDate(DateTime date) => _isSameDate(date, draftFim);

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

  bool isInRange(DateTime date) {
    if (draftInicio == null) {
      return false;
    }

    final normalized = _normalize(date)!;
    final rangeEnd = draftFim ?? hoverDateValue;
    if (rangeEnd == null || rangeEnd.isBefore(draftInicio!)) {
      return false;
    }

    if (_isSameDate(normalized, draftInicio) ||
        _isSameDate(normalized, draftFim)) {
      return false;
    }

    return normalized.isAfter(draftInicio!) && normalized.isBefore(rangeEnd);
  }

  String monthLabel(DateTime month) {
    final labels = _isEnglishLocale ? _monthLabelsEn : _monthLabelsPt;
    final label = labels[month.month - 1];
    return '$label ${month.year}';
  }

  String dateDataValue(DateTime date) {
    final normalized = _normalize(date)!;
    return '${normalized.year}-${_twoDigits(normalized.month)}-${_twoDigits(normalized.day)}';
  }

  String _headerLabel(DateTime month, DateRangePickerViewMode viewMode) {
    if (viewMode == DateRangePickerViewMode.year) {
      final years = _buildYearRange(month.year);
      return '${years.first} - ${years.last}';
    }

    if (viewMode == DateRangePickerViewMode.month) {
      return '${month.year}';
    }

    return monthLabel(month);
  }

  List<List<CalendarCell>> _buildCalendar(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = firstDay.weekday % 7;
    var cursor = firstDay.subtract(Duration(days: startOffset));
    final weeks = <List<CalendarCell>>[];

    for (var row = 0; row < 6; row++) {
      final week = <CalendarCell>[];
      for (var col = 0; col < 7; col++) {
        week.add(CalendarCell(
          date: cursor,
          isCurrentMonth: cursor.month == month.month,
        ));
        cursor = cursor.add(Duration(days: 1));
      }
      weeks.add(week);
    }

    return weeks;
  }

  void _syncVisibleMonths() {
    final referenceDate = draftInicio ?? draftFim ?? DateTime.now();
    _setVisibleMonths(referenceDate);
  }

  void _setVisibleMonths(DateTime month) {
    leftMonth = _monthStart(month);
    rightMonth = _monthStart(DateTime(leftMonth.year, leftMonth.month + 1, 1));
    _refreshCalendars();
  }

  void _refreshCalendars() {
    leftCalendar = _buildCalendar(leftMonth);
    rightCalendar = _buildCalendar(rightMonth);
  }

  void _scheduleOverlayUpdate() {
    Future<void>.microtask(() {
      if (isOpen && !usesMobilePresentation) {
        _overlay?.update();
      }
    });
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

  void _emitModelChange() {
    if (inicio == null && fim == null) {
      _onChange(null);
      return;
    }

    _onChange(_currentRangeValue());
  }

  LiDateRangeValue? _currentRangeValue() {
    if (inicio == null && fim == null) {
      return null;
    }

    return LiDateRangeValue(
      inicio: inicio,
      fim: fim,
    );
  }

  bool _isSameRange(
    DateTime? leftInicio,
    DateTime? leftFim,
    DateTime? rightInicio,
    DateTime? rightFim,
  ) {
    return _isSameNullableDate(leftInicio, rightInicio) &&
        _isSameNullableDate(leftFim, rightFim);
  }

  bool _isSameNullableDate(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return left == right;
    }
    return _isSameDate(left, right);
  }

  bool _matchesAnyPreset(DateTime? rangeInicio, DateTime? rangeFim) {
    for (final preset in presets) {
      if (_isSameRange(
        rangeInicio,
        rangeFim,
        _normalize(preset.inicio),
        _normalize(preset.fim),
      )) {
        return true;
      }
    }
    return false;
  }

  String _formatRange(DateTime? start, DateTime? end) {
    final startText = _formatDate(start);
    final endText = _formatDate(end);

    if (startText.isEmpty && endText.isEmpty) {
      return '';
    }

    if (startText.isNotEmpty && endText.isNotEmpty) {
      return '$startText - $endText';
    }

    return startText.isNotEmpty ? startText : endText;
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

  DateRangePickerViewMode _nextViewMode(DateRangePickerViewMode current) {
    if (current == DateRangePickerViewMode.day) {
      return DateRangePickerViewMode.month;
    }

    if (current == DateRangePickerViewMode.month) {
      return DateRangePickerViewMode.year;
    }

    return DateRangePickerViewMode.day;
  }

  String get _normalizedSize {
    final normalized = size.trim().toLowerCase();
    return normalized == 'sm' || normalized == 'lg' ? normalized : '';
  }

  String get _formControlSizeClass {
    switch (_normalizedSize) {
      case 'sm':
        return 'form-control-sm';
      case 'lg':
        return 'form-control-lg';
      default:
        return '';
    }
  }

  String get _inputGroupSizeClass {
    switch (_normalizedSize) {
      case 'sm':
        return 'input-group-sm';
      case 'lg':
        return 'input-group-lg';
      default:
        return '';
    }
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  Object? trackByMonthOption(int index, dynamic option) =>
      (option as DateRangePickerMonthOption).month;

  Object? trackByPreset(int index, dynamic preset) {
    final typedPreset = preset as LiDateRangePreset;
    final value = typedPreset.value.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return '${typedPreset.label}-$index';
  }

  Object? trackByYear(int index, dynamic year) => year;

  Object? trackByWeek(int index, dynamic week) {
    final typedWeek = week as List<CalendarCell>;
    return '${typedWeek.first.date.year}-${typedWeek.first.date.month}-${typedWeek.first.date.day}';
  }

  Object? trackByCell(int index, dynamic cell) =>
      (cell as CalendarCell).date.millisecondsSinceEpoch;

  @override
  void ngOnDestroy() {
    _unbindDocumentListeners();
    _overlay?.dispose();
    _inicioChangeController.close();
    _fimChangeController.close();
    _userValueChangeController.close();
  }
}
