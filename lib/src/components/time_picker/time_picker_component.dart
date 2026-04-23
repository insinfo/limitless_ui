import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;
import 'package:popper/popper.dart';

import '../../core/overlay_positioning.dart';
import '../../directives/li_form_directive.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';

enum TimePickerDialMode { hour, minute }

class TimePickerDialLabel {
  final int value;
  final String label;
  final double leftPercent;
  final double topPercent;
  final bool isInnerRing;

  const TimePickerDialLabel({
    required this.value,
    required this.label,
    required this.leftPercent,
    required this.topPercent,
    this.isInnerRing = false,
  });
}

/// Limitless-inspired time picker with a clock dial overlay.
///
/// The component exposes `Duration?` through both `[value]`/`(valueChange)` and
/// AngularDart forms with `[(ngModel)]`.
@Component(
  selector: 'li-time-picker',
  styleUrls: ['time_picker_component.css'],
  templateUrl: 'time_picker_component.html',
  directives: [coreDirectives],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiTimePickerComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTimePickerComponent
    implements ControlValueAccessor<Duration?>, AfterChanges, OnDestroy {
  LiTimePickerComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]);

  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  final StreamController<Duration?> _valueChangeController =
      StreamController<Duration?>.broadcast();

  PopperAnchoredOverlay? _overlay;
  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;
  StreamSubscription<html.MouseEvent>? _documentMouseMoveSubscription;
  StreamSubscription<html.MouseEvent>? _documentMouseUpSubscription;
  StreamSubscription<html.TouchEvent>? _documentTouchMoveSubscription;
  StreamSubscription<html.TouchEvent>? _documentTouchEndSubscription;
  StreamSubscription<bool>? _formSubmissionSubscription;

  @Input()
  Duration? value;

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  String? placeholder;

  @Input()
  String locale = 'pt_BR';

  @Input()
  bool use24Hour = false;

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
  List<LiRule> liRules = const <LiRule>[];

  @Input()
  Map<String, String> liMessages = const <String, String>{};

  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  @Input()
  bool validateOnInput = true;

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

  @Output()
  Stream<Duration?> get valueChange => _valueChangeController.stream;

  @ViewChild('triggerElement')
  html.Element? triggerElement;

  @ViewChild('panelElement')
  html.Element? panelElement;

  @ViewChild('clockFaceElement')
  html.Element? clockFaceElement;

  @ViewChild('hourInput')
  html.InputElement? hourInputElement;

  @ViewChild('minuteInput')
  html.InputElement? minuteInputElement;

  bool isOpen = false;
  TimePickerDialMode dialMode = TimePickerDialMode.hour;
  int draftHour24 = 0;
  int draftMinute = 0;
  String _hourInputText = '';
  String _minuteInputText = '';
  bool _isEditingHour = false;
  bool _isEditingMinute = false;
  bool _isDraggingClock = false;
  int? _dragAnimationFrameId;
  double? _pendingPointerX;
  double? _pendingPointerY;

  ChangeFunction<Duration?> _onChange = (Duration? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _autoValidationIssue;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get effectiveAutoInvalid =>
      _shouldShowValidation && _autoValidationIssue != null;

  bool get effectiveInvalid => invalid || dataInvalid || effectiveAutoInvalid;

  bool get effectiveValid =>
      !effectiveInvalid &&
      (valid ||
          (_shouldShowValidation &&
              _effectiveRules.isNotEmpty &&
              _autoValidationIssue == null));

  bool get hasHelperText => helperText.trim().isNotEmpty;

  String get effectiveErrorText {
    final externalMessage = errorText.trim();
    if (externalMessage.isNotEmpty) {
      return externalMessage;
    }

    return _autoValidationIssue?.message ?? '';
  }

  bool get showErrorFeedback =>
      effectiveErrorText.trim().isNotEmpty && effectiveInvalid;

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String get resolvedInputClass => _joinClasses(<String>[
        'form-control',
        'time-picker-field',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  bool get isHourMode => dialMode == TimePickerDialMode.hour;

  bool get isMinuteMode => dialMode == TimePickerDialMode.minute;

  bool get isPm => draftHour24 >= 12;

  bool get showMeridiem => !use24Hour;

  bool get _isInnerHourSelection =>
      use24Hour && (draftHour24 == 0 || draftHour24 >= 13);

  int get displayHour12 {
    final hour = draftHour24 % 12;
    return hour == 0 ? 12 : hour;
  }

  String get displayHourText =>
      use24Hour ? _twoDigits(draftHour24) : _twoDigits(displayHour12);

  String get displayMinuteText => _twoDigits(draftMinute);

  String get editableHourText =>
      _isEditingHour ? _hourInputText : displayHourText;

  String get editableMinuteText =>
      _isEditingMinute ? _minuteInputText : displayMinuteText;

  String get displayValue => _formatDuration(value);

  String get effectivePlaceholder =>
      placeholder ?? (_isEnglishLocale ? 'Select time' : 'Selecione o horario');

  String get titleLabel =>
      _isEnglishLocale ? 'Select time' : 'Selecionar horario';

  String get cancelLabel => _isEnglishLocale ? 'Cancel' : 'Cancelar';

  String get okLabel => _isEnglishLocale ? 'OK' : 'OK';

  String get clearLabel => _isEnglishLocale ? 'Clear' : 'Limpar';

  String get clearAriaLabel =>
      _isEnglishLocale ? 'Clear selected time' : 'Limpar horário selecionado';

  String get amLabel => 'AM';

  String get pmLabel => 'PM';

  bool get hasValue => value != null;

  bool get _shouldShowValidation => liShouldShowValidation(
        mode: liValidationMode,
        touched: _touched,
        dirty: _dirty,
        submitted: _formSubmitted,
      );

  @override
  void ngAfterChanges() {
    _formSubmitted = _formDirective?.submitted ?? false;
    _formSubmissionSubscription ??=
        _formDirective?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      _runAutoValidation();
      _markForCheck();
    });

    _effectiveRules = List<LiRule>.unmodifiable(<LiRule>[
      if (required) const LiRequiredRule(),
      ...liRules,
    ]);
    _effectiveMessages = Map<String, String>.unmodifiable(<String, String>{
      ...liMessages,
    });
    _runAutoValidation();
    _markForCheck();
  }

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
    return custom.isNotEmpty ? custom : 'ph ph-clock';
  }

  String get resolvedOverlayInputClass => _joinClasses(<String>[
        resolvedInputClass,
        'time-picker-field--overlay',
        showsClearButton ? 'time-picker-field--overlay-clear' : '',
        showsTriggerIcon ? 'time-picker-field--overlay-trigger' : '',
      ]);

  double get handDegrees => isHourMode
      ? ((use24Hour ? draftHour24 % 12 : displayHour12 % 12) * 30).toDouble()
      : draftMinute * 6.0;

  double get handTransformDegrees => handDegrees;

  double get handLengthPercent {
    if (isMinuteMode) {
      return 31;
    }

    if (_isInnerHourSelection) {
      return 18;
    }

    return 31;
  }

  bool get showFloatingSelector => true;

  bool get selectorHasText => isMinuteMode && draftMinute % 5 != 0;

  bool get useCompactSelector => isHourMode && _isInnerHourSelection;

  String get floatingSelectorText =>
      isHourMode ? displayHourText : displayMinuteText;

  String get floatingSelectorLabelTransform =>
      'rotate(${(-handTransformDegrees).toString()}deg)';

  List<TimePickerDialLabel> get visibleDialLabels => isHourMode
      ? (use24Hour ? _hourDialLabels24 : _hourDialLabels)
      : _minuteDialLabels;

  List<TimePickerDialLabel> get _hourDialLabels => _buildDialLabels(
        const <int>[12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        (int value) => '$value',
        radiusPercent: 40,
      );

  List<TimePickerDialLabel> get _hourDialLabels24 => <TimePickerDialLabel>[
        ..._buildDialLabels(
          const <int>[12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
          (int value) => _twoDigits(value),
          radiusPercent: 40,
        ),
        ..._buildDialLabels(
          const <int>[0, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23],
          (int value) => _twoDigits(value),
          radiusPercent: 24,
          isInnerRing: true,
        ),
      ];

  List<TimePickerDialLabel> get _minuteDialLabels => _buildDialLabels(
        List<int>.generate(12, (int index) => index * 5),
        (int value) => _twoDigits(value),
        radiusPercent: 40,
      );

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
    _syncDraftFromValue();
    _syncInputTexts();
    dialMode = TimePickerDialMode.hour;
    isOpen = true;
    _overlay?.startAutoUpdate();
    _overlay?.update();
    _bindDocumentListeners();
    _markForCheck();
  }

  void setHourMode() {
    dialMode = TimePickerDialMode.hour;
    _markForCheck();
  }

  void setMinuteMode() {
    dialMode = TimePickerDialMode.minute;
    _markForCheck();
  }

  void onHourFocus() {
    _isEditingHour = true;
    _hourInputText = displayHourText;
    setHourMode();
    _selectAllText(hourInputElement);
  }

  void onMinuteFocus() {
    _isEditingMinute = true;
    _minuteInputText = displayMinuteText;
    setMinuteMode();
    _selectAllText(minuteInputElement);
  }

  void onHourInput(String? rawValue) {
    _isEditingHour = true;
    _hourInputText = _sanitizeNumericInput(rawValue);

    final parsed = int.tryParse(_hourInputText);
    if (parsed == null) {
      _markForCheck();
      return;
    }

    if (use24Hour) {
      if (parsed <= 23) {
        draftHour24 = parsed;
      }
    } else if (parsed >= 1 && parsed <= 12) {
      _setHourFrom12Hour(parsed);
    }

    if (_hourInputText.length == 2) {
      _moveFocusToMinute();
    }

    _markForCheck();
  }

  void onMinuteInput(String? rawValue) {
    _isEditingMinute = true;
    _minuteInputText = _sanitizeNumericInput(rawValue);

    final parsed = int.tryParse(_minuteInputText);
    if (parsed == null) {
      _markForCheck();
      return;
    }

    if (parsed <= 59) {
      draftMinute = parsed;
    }

    _markForCheck();
  }

  void onHourBlur() {
    _commitHourInput();
  }

  void onMinuteBlur() {
    _commitMinuteInput();
  }

  void onChipKeyDown(html.Event event, bool isHourField) {
    if (event is! html.KeyboardEvent) {
      return;
    }

    if (event.key == 'Enter') {
      event.preventDefault();
      if (isHourField) {
        _commitHourInput();
      } else {
        _commitMinuteInput();
      }
      return;
    }

    if (event.key == 'Escape') {
      event.preventDefault();
      _syncInputTexts();
      _isEditingHour = false;
      _isEditingMinute = false;
      _markForCheck();
    }
  }

  void setMeridiem(bool pm) {
    if (use24Hour) {
      return;
    }

    if (pm == isPm) {
      return;
    }

    if (pm) {
      draftHour24 = draftHour24 < 12 ? draftHour24 + 12 : draftHour24;
    } else {
      draftHour24 = draftHour24 >= 12 ? draftHour24 - 12 : draftHour24;
    }

    _syncInputTexts();
    _markForCheck();
  }

  void onClockMouseDown(html.MouseEvent event) {
    event.preventDefault();
    _beginClockDrag(event.client.x.toDouble(), event.client.y.toDouble());
  }

  void onClockTouchStart(html.TouchEvent event) {
    final touches = event.touches;
    if (touches == null || touches.isEmpty) {
      return;
    }

    event.preventDefault();
    final touch = touches.first;
    _beginClockDrag(touch.client.x.toDouble(), touch.client.y.toDouble());
  }

  void onDialLabelClick(TimePickerDialLabel label, html.MouseEvent event) {
    event.preventDefault();
    event.stopPropagation();

    if (isHourMode) {
      if (use24Hour) {
        draftHour24 = label.value;
      } else {
        _setHourFrom12Hour(label.value);
      }
    } else {
      draftMinute = label.value;
    }

    _syncInputTexts();
    _markForCheck();
  }

  void apply() {
    value = _normalizeDuration(
      Duration(hours: draftHour24, minutes: draftMinute),
    );
    _dirty = true;
    _valueChangeController.add(value);
    _onChange(value);
    _markTouched();
    _runAutoValidation();
    close();
  }

  void clear() {
    value = null;
    _dirty = true;
    _valueChangeController.add(null);
    _onChange(null);
    _markTouched();
    _runAutoValidation();
    close();
  }

  void clearFromTrigger(html.MouseEvent event) {
    event.preventDefault();
    event.stopPropagation();
    clear();
  }

  void close() {
    if (isOpen) {
      _markTouched();
    }
    _unbindDocumentListeners();
    _stopClockDrag();
    _overlay?.stopAutoUpdate();
    isOpen = false;
    dialMode = TimePickerDialMode.hour;
    _syncInputTexts();
    _isEditingHour = false;
    _isEditingMinute = false;
    _markTouched();
    _markForCheck();
  }

  @override
  void writeValue(Duration? value) {
    this.value = _normalizeDuration(value);
    _syncDraftFromValue();
    _syncInputTexts();
    _runAutoValidation();
    _markForCheck();
  }

  @override
  void registerOnChange(ChangeFunction<Duration?> fn) {
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
    _syncInputTexts();
    _markForCheck();
  }

  bool isDialLabelActive(TimePickerDialLabel label) {
    if (isHourMode) {
      return label.value == (use24Hour ? draftHour24 : displayHour12);
    }

    return label.value == draftMinute;
  }

  Object? trackByDialLabel(int index, dynamic label) =>
      (label as TimePickerDialLabel).value;

  String dialLabelClass(TimePickerDialLabel label) {
    final isActive = isDialLabelActive(label);

    final classes = <String>['time-picker-dial-label'];
    if (label.isInnerRing) {
      classes.add('time-picker-dial-label-inner');
    }

    if (isActive) {
      classes.add('active');
    }

    return classes.join(' ');
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
        hostClassName: 'LiTimePickerComponent',
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
        return;
      }

      final clickedTrigger = triggerElement?.contains(target) ?? false;
      final clickedPanel = panelElement?.contains(target) ?? false;
      if (!clickedTrigger && !clickedPanel) {
        close();
      }
    });

    _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
      if (isOpen && event.key == 'Escape') {
        event.preventDefault();
        close();
      }
    });
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription?.cancel();
    _documentKeySubscription = null;
    _detachClockDragListeners();
  }

  void _beginClockDrag(double clientX, double clientY) {
    _isDraggingClock = true;
    _attachClockDragListeners();
    _updateSelectionFromClientOffset(clientX, clientY);
  }

  void _attachClockDragListeners() {
    _documentMouseMoveSubscription ??=
        html.document.onMouseMove.listen((html.MouseEvent event) {
      if (!_isDraggingClock) {
        return;
      }

      event.preventDefault();
      _queuePointerUpdate(event.client.x.toDouble(), event.client.y.toDouble());
    });

    _documentMouseUpSubscription ??=
        html.document.onMouseUp.listen((html.MouseEvent event) {
      if (!_isDraggingClock) {
        return;
      }

      event.preventDefault();
      _stopClockDrag();
    });

    _documentTouchMoveSubscription ??=
        html.document.onTouchMove.listen((html.TouchEvent event) {
      if (!_isDraggingClock) {
        return;
      }

      final touches = event.touches;
      if (touches == null || touches.isEmpty) {
        return;
      }

      event.preventDefault();
      final touch = touches.first;
      _queuePointerUpdate(touch.client.x.toDouble(), touch.client.y.toDouble());
    });

    _documentTouchEndSubscription ??=
        html.document.onTouchEnd.listen((html.TouchEvent event) {
      if (!_isDraggingClock) {
        return;
      }

      event.preventDefault();
      _stopClockDrag();
    });
  }

  void _detachClockDragListeners() {
    _documentMouseMoveSubscription?.cancel();
    _documentMouseMoveSubscription = null;
    _documentMouseUpSubscription?.cancel();
    _documentMouseUpSubscription = null;
    _documentTouchMoveSubscription?.cancel();
    _documentTouchMoveSubscription = null;
    _documentTouchEndSubscription?.cancel();
    _documentTouchEndSubscription = null;
  }

  void _queuePointerUpdate(double clientX, double clientY) {
    _pendingPointerX = clientX;
    _pendingPointerY = clientY;

    if (_dragAnimationFrameId != null) {
      return;
    }

    _dragAnimationFrameId = html.window.requestAnimationFrame((_) {
      _dragAnimationFrameId = null;

      final pendingX = _pendingPointerX;
      final pendingY = _pendingPointerY;
      if (pendingX == null || pendingY == null) {
        return;
      }

      _updateSelectionFromClientOffset(pendingX, pendingY);
    });
  }

  void _stopClockDrag() {
    _isDraggingClock = false;
    _pendingPointerX = null;
    _pendingPointerY = null;

    if (_dragAnimationFrameId != null) {
      html.window.cancelAnimationFrame(_dragAnimationFrameId!);
      _dragAnimationFrameId = null;
    }

    _detachClockDragListeners();
  }

  void _updateSelectionFromClientOffset(double clientX, double clientY) {
    final face = clockFaceElement;
    if (face == null) {
      return;
    }

    final rect = face.getBoundingClientRect();
    final dx = clientX - rect.left - (rect.width / 2);
    final dy = clientY - rect.top - (rect.height / 2);
    final angleDegrees = math.atan2(dy, dx) * 180 / math.pi;
    final normalizedDegrees = (angleDegrees + 90 + 360) % 360;
    final distance = math.sqrt(dx * dx + dy * dy);
    final isInnerCircle = distance < (rect.width / 2) * 0.72;

    if (isHourMode) {
      final rawHour = (normalizedDegrees / 30).round() % 12;

      if (use24Hour) {
        draftHour24 = _hour24FromDialIndex(rawHour, isInnerCircle);
      } else {
        final selectedHour = rawHour == 0 ? 12 : rawHour;
        _setHourFrom12Hour(selectedHour);
      }
    } else {
      draftMinute = (normalizedDegrees / 6).round() % 60;
    }

    _syncInputTexts();
    _markForCheck();
  }

  void _syncDraftFromValue() {
    final currentValue = _normalizeDuration(value);
    if (currentValue == null) {
      final now = DateTime.now();
      draftHour24 = now.hour;
      draftMinute = now.minute;
      _syncInputTexts();
      return;
    }

    draftHour24 = currentValue.inHours % 24;
    draftMinute = currentValue.inMinutes % 60;
    _syncInputTexts();
  }

  void _setHourFrom12Hour(int hour12) {
    if (hour12 == 12) {
      draftHour24 = isPm ? 12 : 0;
      return;
    }

    draftHour24 = isPm ? hour12 + 12 : hour12;
  }

  void _commitHourInput() {
    final parsed = int.tryParse(_hourInputText);
    if (parsed != null) {
      if (use24Hour) {
        draftHour24 = parsed.clamp(0, 23);
      } else {
        final normalized = parsed.clamp(1, 12);
        _setHourFrom12Hour(normalized);
      }
    }

    _isEditingHour = false;
    _hourInputText = displayHourText;
    _markForCheck();
  }

  void _commitMinuteInput() {
    final parsed = int.tryParse(_minuteInputText);
    if (parsed != null) {
      draftMinute = parsed.clamp(0, 59);
    }

    _isEditingMinute = false;
    _minuteInputText = displayMinuteText;
    _markForCheck();
  }

  void _syncInputTexts() {
    _hourInputText = displayHourText;
    _minuteInputText = displayMinuteText;
  }

  void _moveFocusToMinute() {
    Future<void>.microtask(() {
      setMinuteMode();
      final minuteInput = minuteInputElement;
      if (minuteInput == null) {
        _markForCheck();
        return;
      }

      minuteInput.focus();
      _selectAllText(minuteInput);
      _markForCheck();
    });
  }

  void _selectAllText(html.InputElement? input) {
    if (input == null) {
      return;
    }

    final valueLength = input.value?.length ?? 0;
    input.setSelectionRange(0, valueLength);
  }

  String _sanitizeNumericInput(String? rawValue) {
    final normalizedRawValue = rawValue ?? '';
    final digitsOnly = normalizedRawValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length <= 2) {
      return digitsOnly;
    }
    return digitsOnly.substring(0, 2);
  }

  List<TimePickerDialLabel> _buildDialLabels(
    List<int> values,
    String Function(int value) labelBuilder, {
    double radiusPercent = 38,
    bool isInnerRing = false,
  }) {
    final count = values.length;

    return values.asMap().entries.map((entry) {
      final angleDegrees = (entry.key * (360 / count)) - 90;
      final radians = angleDegrees * math.pi / 180;
      return TimePickerDialLabel(
        value: entry.value,
        label: labelBuilder(entry.value),
        leftPercent: 50 + math.cos(radians) * radiusPercent,
        topPercent: 50 + math.sin(radians) * radiusPercent,
        isInnerRing: isInnerRing,
      );
    }).toList(growable: false);
  }

  int _hour24FromDialIndex(int rawHour, bool isInnerCircle) {
    if (isInnerCircle) {
      return rawHour == 0 ? 0 : rawHour + 12;
    }

    return rawHour == 0 ? 12 : rawHour;
  }

  Duration? _normalizeDuration(Duration? value) {
    if (value == null) {
      return null;
    }

    final totalMinutes = value.inMinutes % (24 * 60);
    final normalizedMinutes =
        totalMinutes < 0 ? totalMinutes + (24 * 60) : totalMinutes;
    return Duration(minutes: normalizedMinutes);
  }

  String _formatDuration(Duration? value) {
    final normalized = _normalizeDuration(value);
    if (normalized == null) {
      return '';
    }

    final hours = normalized.inHours % 24;
    final minutes = normalized.inMinutes % 60;

    if (use24Hour) {
      return '${_twoDigits(hours)}:${_twoDigits(minutes)}';
    }

    final period = hours >= 12 ? 'PM' : 'AM';
    final hour12 = hours % 12 == 0 ? 12 : hours % 12;
    return '${_twoDigits(hour12)}:${_twoDigits(minutes)} $period';
  }

  String _twoDigits(int value) {
    if (value < 10) {
      return '0$value';
    }
    return '$value';
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  void _markTouched() {
    if (_touched) {
      _onTouched();
      if (_shouldShowValidation || _autoValidationIssue != null) {
        _runAutoValidation();
      }
      return;
    }
    _touched = true;
    _onTouched();
    _runAutoValidation();
  }

  void _runAutoValidation() {
    if (_effectiveRules.isEmpty) {
      _autoValidationIssue = null;
      return;
    }

    _autoValidationIssue = liValidateValue(
      value: value,
      rules: _effectiveRules,
      context: LiRuleContext(
        fieldName: 'timePicker',
        messages: _effectiveMessages,
        locale: locale,
      ),
    );
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  @override
  void ngOnDestroy() {
    _unbindDocumentListeners();
    _stopClockDrag();
    _overlay?.dispose();
    _formSubmissionSubscription?.cancel();
    _valueChangeController.close();
  }
}
