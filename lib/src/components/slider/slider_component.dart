import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

@Component(
  selector: 'li-slider',
  templateUrl: 'slider_component.html',
  styleUrls: ['slider_component.css'],
  directives: [coreDirectives],
  providers: [ExistingProvider.forToken(ngValueAccessor, LiSliderComponent)],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiSliderComponent
    implements ControlValueAccessor<dynamic>, AfterChanges, OnDestroy {
  LiSliderComponent(this._changeDetectorRef) {
    _singleValue = min.toDouble();
    _lowerValue = min.toDouble();
    _upperValue = max.toDouble();
    _rebuildViewModels();
  }

  final ChangeDetectorRef _changeDetectorRef;
  final StreamController<num> _valueChangeController =
      StreamController<num>.broadcast();
  final StreamController<List<num>> _rangeValuesChangeController =
      StreamController<List<num>>.broadcast();

  ChangeFunction<dynamic> _onChange = (dynamic _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  StreamSubscription<html.MouseEvent>? _mouseMoveSubscription;
  StreamSubscription<html.MouseEvent>? _mouseUpSubscription;
  StreamSubscription<html.TouchEvent>? _touchMoveSubscription;
  StreamSubscription<html.TouchEvent>? _touchEndSubscription;
  Timer? _tapStateTimer;

  double _singleValue = 0;
  double _lowerValue = 0;
  double _upperValue = 100;
  int? _dragHandleIndex;
  int? _focusedHandleIndex;
  bool _tapActive = false;

  @ViewChild('surface')
  html.Element? surfaceElement;

  @Input()
  bool range = false;

  @Input()
  num min = 0;

  @Input()
  num max = 100;

  @Input()
  num step = 1;

  @Input()
  num margin = 0;

  @Input()
  String connect = 'auto';

  @Input()
  bool disabled = false;

  @Input()
  bool showTooltip = false;

  @Input()
  bool showPips = false;

  @Input()
  int pipCount = 5;

  @Input()
  List<LiSliderPip> customPips = const <LiSliderPip>[];

  @Input()
  String orientation = 'horizontal';

  @Input()
  String direction = 'auto';

  @Input()
  String variant = 'primary';

  @Input()
  String size = 'md';

  @Input()
  String handleStyle = 'default';

  @Input()
  String ariaLabel = 'Slider';

  @Input()
  String inputClass = '';

  @Input()
  String containerClass = '';

  @Input()
  num verticalHeight = 160;

  @Input()
  set value(num? nextValue) {
    if (nextValue == null) {
      return;
    }
    _setSingleValue(nextValue.toDouble(),
        emitOutputs: false, notifyForm: false);
  }

  num get value => _toOutputNum(_singleValue);

  @Input()
  set rangeValues(List<num>? nextValues) {
    _setRangeValues(nextValues, emitOutputs: false, notifyForm: false);
  }

  List<num> get rangeValues => <num>[
        _toOutputNum(_lowerValue),
        _toOutputNum(_upperValue),
      ];

  @Output()
  Stream<num> get valueChange => _valueChangeController.stream;

  @Output()
  Stream<List<num>> get rangeValuesChange =>
      _rangeValuesChangeController.stream;

  List<LiSliderHandleViewModel> handles = <LiSliderHandleViewModel>[];
  List<LiSliderPipViewModel> pips = <LiSliderPipViewModel>[];

  double connectStartPercent = 0;
  double connectSizePercent = 0;

  bool get isVertical => orientation.trim().toLowerCase() == 'vertical';

  bool get shouldRenderPips => showPips || customPips.isNotEmpty;

  bool get showConnect =>
      _effectiveConnectMode != 'none' && connectSizePercent > 0;

  String get effectiveDirection {
    final normalized = direction.trim().toLowerCase();
    if (normalized == 'rtl' || normalized == 'ltr') {
      return normalized;
    }

    final documentDirection = html.document.documentElement?.dir ?? '';
    final normalizedDocumentDirection = documentDirection.trim().toLowerCase();
    if (normalizedDocumentDirection == 'rtl') {
      return 'rtl';
    }
    return 'ltr';
  }

  bool get isRtl => effectiveDirection == 'rtl';

  String get resolvedHostClass => _joinClasses(<String>[
        'li-slider',
        isVertical ? 'li-slider--vertical' : 'li-slider--horizontal',
        containerClass,
      ]);

  String get resolvedSurfaceClass => _joinClasses(<String>[
        'li-slider__surface',
        'noUi-target',
        isVertical ? 'noUi-vertical' : 'noUi-horizontal',
        shouldRenderPips ? 'has-pips' : '',
        _variantClass,
        _sizeClass,
        _handleStyleClass,
        _tapActive ? 'noUi-state-tap' : '',
        disabled ? 'li-slider__surface--disabled' : '',
        inputClass,
      ]);

  String get resolvedSurfaceStyle {
    if (!isVertical) {
      return '';
    }
    return 'height: ${verticalHeight.toDouble()}px;';
  }

  String get resolvedPipsClass => _joinClasses(<String>[
        'noUi-pips',
        isVertical ? 'noUi-pips-vertical' : 'noUi-pips-horizontal',
      ]);

  String get _effectiveConnectMode {
    final normalized = connect.trim().toLowerCase();
    switch (normalized) {
      case 'upper':
      case 'lower':
      case 'range':
      case 'none':
        return range || normalized != 'range' ? normalized : 'lower';
      case 'auto':
      default:
        return range ? 'range' : 'lower';
    }
  }

  String get connectStyle {
    if (isVertical) {
      return 'top: ${connectStartPercent.toStringAsFixed(4)}%; height: ${connectSizePercent.toStringAsFixed(4)}%;';
    }
    return 'left: ${connectStartPercent.toStringAsFixed(4)}%; width: ${connectSizePercent.toStringAsFixed(4)}%;';
  }

  @HostBinding('class.d-block')
  bool get hostClass => true;

  @override
  void ngAfterChanges() {
    _normalizeInputs();
    if (range) {
      _setRangeValues(rangeValues, emitOutputs: false, notifyForm: false);
    } else {
      _setSingleValue(_singleValue, emitOutputs: false, notifyForm: false);
    }
    _rebuildViewModels();
    _markForCheck();
  }

  void onTrackMouseDown(html.MouseEvent event) {
    if (disabled) {
      return;
    }

    final positionPercent = _mouseEventToPositionPercent(event);
    if (positionPercent == null) {
      return;
    }

    final handleIndex = _resolveClosestHandleIndex(positionPercent);
    _applyPointerPosition(handleIndex, positionPercent);
    _startDrag(handleIndex);
    _activateTapState();
    event.preventDefault();
  }

  void onTrackTouchStart(html.TouchEvent event) {
    if (disabled) {
      return;
    }

    final positionPercent = _touchEventToPositionPercent(event);
    if (positionPercent == null) {
      return;
    }

    final handleIndex = _resolveClosestHandleIndex(positionPercent);
    _applyPointerPosition(handleIndex, positionPercent);
    _startDrag(handleIndex);
    _activateTapState();
    event.preventDefault();
  }

  void onHandleMouseDown(int handleIndex, html.MouseEvent event) {
    if (disabled) {
      return;
    }

    _startDrag(handleIndex);
    event.stopPropagation();
    event.preventDefault();
  }

  void onHandleTouchStart(int handleIndex, html.TouchEvent event) {
    if (disabled) {
      return;
    }

    _startDrag(handleIndex);
    event.stopPropagation();
    event.preventDefault();
  }

  void onHandleFocus(int handleIndex) {
    _focusedHandleIndex = handleIndex;
    _syncHandleStateClasses();
    _markForCheck();
  }

  void onHandleBlur() {
    _focusedHandleIndex = null;
    _syncHandleStateClasses();
    _onTouched();
    _markForCheck();
  }

  void onHandleKeyDown(int handleIndex, html.KeyboardEvent event) {
    if (disabled) {
      return;
    }

    final stepSize = step.toDouble() <= 0 ? 1.0 : step.toDouble();
    final currentValue =
        handleIndex == 0 ? _activeLowerOrSingleValue : _upperValue;

    switch (event.key) {
      case 'ArrowLeft':
        _applyKeyboardDelta(handleIndex, _horizontalDecrement(stepSize));
        event.preventDefault();
        return;
      case 'ArrowRight':
        _applyKeyboardDelta(handleIndex, _horizontalIncrement(stepSize));
        event.preventDefault();
        return;
      case 'ArrowUp':
        _applyKeyboardDelta(handleIndex, _verticalIncrement(stepSize));
        event.preventDefault();
        return;
      case 'ArrowDown':
        _applyKeyboardDelta(handleIndex, _verticalDecrement(stepSize));
        event.preventDefault();
        return;
      case 'PageUp':
        _applyKeyboardDelta(handleIndex, stepSize * 10);
        event.preventDefault();
        return;
      case 'PageDown':
        _applyKeyboardDelta(handleIndex, stepSize * -10);
        event.preventDefault();
        return;
      case 'Home':
        _setHandleValue(handleIndex, min.toDouble());
        event.preventDefault();
        return;
      case 'End':
        _setHandleValue(handleIndex, max.toDouble());
        event.preventDefault();
        return;
    }

    if (currentValue.isNaN) {
      event.preventDefault();
    }
  }

  Object trackByHandle(int index, dynamic handle) {
    return (handle as LiSliderHandleViewModel).id;
  }

  Object trackByPip(int index, dynamic pip) {
    return (pip as LiSliderPipViewModel).id;
  }

  @override
  void registerOnChange(ChangeFunction<dynamic> fn) {
    _onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _onTouched = fn;
  }

  @override
  void writeValue(dynamic value) {
    if (value is List) {
      final numericValues = value.whereType<num>().toList(growable: false);
      _setRangeValues(numericValues, emitOutputs: false, notifyForm: false);
      return;
    }

    if (value is num) {
      _setSingleValue(value.toDouble(), emitOutputs: false, notifyForm: false);
      return;
    }

    if (range) {
      _setRangeValues(null, emitOutputs: false, notifyForm: false);
    } else {
      _setSingleValue(min.toDouble(), emitOutputs: false, notifyForm: false);
    }
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    _markForCheck();
  }

  @override
  void ngOnDestroy() {
    _tapStateTimer?.cancel();
    _mouseMoveSubscription?.cancel();
    _mouseUpSubscription?.cancel();
    _touchMoveSubscription?.cancel();
    _touchEndSubscription?.cancel();
    _valueChangeController.close();
    _rangeValuesChangeController.close();
  }

  double get _activeLowerOrSingleValue => range ? _lowerValue : _singleValue;

  String get _variantClass {
    final normalized = variant.trim().toLowerCase();
    switch (normalized) {
      case 'secondary':
      case 'success':
      case 'warning':
      case 'danger':
      case 'info':
        return 'noui-slider-$normalized';
      default:
        return '';
    }
  }

  String get _sizeClass {
    switch (size.trim().toLowerCase()) {
      case 'lg':
      case 'large':
        return 'noui-slider-lg';
      case 'sm':
      case 'small':
        return 'noui-slider-sm';
      default:
        return '';
    }
  }

  String get _handleStyleClass {
    switch (handleStyle.trim().toLowerCase()) {
      case 'solid':
        return 'noui-slider-solid';
      case 'white':
        return 'noui-slider-white';
      default:
        return '';
    }
  }

  int get _precision {
    final values = <num>[min, max, step];
    var precision = 0;
    for (final value in values) {
      final text = value.toString();
      final decimalIndex = text.indexOf('.');
      if (decimalIndex < 0) {
        continue;
      }
      precision = precision < text.length - decimalIndex - 1
          ? text.length - decimalIndex - 1
          : precision;
    }
    return precision;
  }

  void _normalizeInputs() {
    if (step.toDouble() <= 0) {
      step = 1;
    }
    if (max.toDouble() <= min.toDouble()) {
      max = min.toDouble() + step.toDouble();
    }
    if (margin.toDouble() < 0) {
      margin = 0;
    }
    final span = max.toDouble() - min.toDouble();
    if (margin.toDouble() > span) {
      margin = span;
    }
    if (pipCount < 2) {
      pipCount = 2;
    }
    if (verticalHeight.toDouble() <= 0) {
      verticalHeight = 160;
    }
  }

  void _setSingleValue(
    double nextValue, {
    required bool emitOutputs,
    required bool notifyForm,
  }) {
    final normalized = _normalizeSingleValue(nextValue);
    final changed = _singleValue != normalized;
    _singleValue = normalized;
    _rebuildViewModels();
    if (changed && emitOutputs) {
      _valueChangeController.add(_toOutputNum(_singleValue));
    }
    if (changed && notifyForm) {
      final outputValue = _toOutputNum(_singleValue);
      _onChange(outputValue, rawValue: outputValue.toString());
      _onTouched();
    }
    _markForCheck();
  }

  void _setRangeValues(
    List<num>? nextValues, {
    required bool emitOutputs,
    required bool notifyForm,
  }) {
    final resolved = _resolveRangeValues(nextValues);
    final changed =
        _lowerValue != resolved.lower || _upperValue != resolved.upper;
    _lowerValue = resolved.lower;
    _upperValue = resolved.upper;
    _rebuildViewModels();
    if (changed && emitOutputs) {
      _rangeValuesChangeController.add(_snapshotRangeValues());
    }
    if (changed && notifyForm) {
      final outputRange = _snapshotRangeValues();
      _onChange(outputRange, rawValue: outputRange.join(','));
      _onTouched();
    }
    _markForCheck();
  }

  void _applyKeyboardDelta(int handleIndex, double delta) {
    final baseValue =
        handleIndex == 0 ? _activeLowerOrSingleValue : _upperValue;
    _setHandleValue(handleIndex, baseValue + delta);
  }

  void _setHandleValue(int handleIndex, double nextValue) {
    if (range) {
      final proposedLower = handleIndex == 0 ? nextValue : _lowerValue;
      final proposedUpper = handleIndex == 1 ? nextValue : _upperValue;
      _setRangeValues(
        <num>[proposedLower, proposedUpper],
        emitOutputs: true,
        notifyForm: true,
      );
      return;
    }

    _setSingleValue(nextValue, emitOutputs: true, notifyForm: true);
  }

  LiSliderRangeValues _resolveRangeValues(List<num>? nextValues) {
    final source = nextValues == null || nextValues.length < 2
        ? <num>[_lowerValue, _upperValue]
        : nextValues;
    final first = source[0].toDouble();
    final second = source[1].toDouble();
    final lowerCandidate = first <= second ? first : second;
    final upperCandidate = first <= second ? second : first;
    final normalizedLower = _normalizeRawValue(lowerCandidate);
    final normalizedUpper = _normalizeRawValue(upperCandidate);
    final clampedLower = normalizedLower.clamp(
      min.toDouble(),
      (max.toDouble() - margin.toDouble())
          .clamp(min.toDouble(), max.toDouble()),
    );
    final clampedUpper = normalizedUpper.clamp(
      (clampedLower + margin.toDouble()).clamp(min.toDouble(), max.toDouble()),
      max.toDouble(),
    );

    final normalizedClampedLower = _normalizeRawValue(clampedLower.toDouble())
        .clamp(
            min.toDouble(),
            (clampedUpper - margin.toDouble())
                .clamp(min.toDouble(), max.toDouble()))
        .toDouble();
    final normalizedClampedUpper = _normalizeRawValue(clampedUpper.toDouble())
        .clamp(
            (normalizedClampedLower + margin.toDouble())
                .clamp(min.toDouble(), max.toDouble()),
            max.toDouble())
        .toDouble();

    return LiSliderRangeValues(
      normalizedClampedLower,
      normalizedClampedUpper,
    );
  }

  double _normalizeSingleValue(double value) {
    return _normalizeRawValue(value)
        .clamp(min.toDouble(), max.toDouble())
        .toDouble();
  }

  double _normalizeRawValue(num rawValue) {
    final span = max.toDouble() - min.toDouble();
    if (span <= 0) {
      return min.toDouble();
    }

    final clamped = rawValue.toDouble().clamp(min.toDouble(), max.toDouble());
    final stepSize = step.toDouble();
    final snapped =
        ((clamped - min.toDouble()) / stepSize).roundToDouble() * stepSize +
            min.toDouble();
    return _roundToPrecision(
        snapped.clamp(min.toDouble(), max.toDouble()).toDouble());
  }

  double _roundToPrecision(double value) {
    final precision = _precision;
    if (precision <= 0) {
      return value.toDouble();
    }
    return double.parse(value.toStringAsFixed(precision));
  }

  double? _mouseEventToPositionPercent(html.MouseEvent event) {
    final bounds = surfaceElement?.getBoundingClientRect();
    if (bounds == null) {
      return null;
    }
    return _offsetsToPositionPercent(
      clientX: event.client.x.toDouble(),
      clientY: event.client.y.toDouble(),
      bounds: bounds,
    );
  }

  double? _touchEventToPositionPercent(html.TouchEvent event) {
    final touch = _resolveTouch(event);
    final bounds = surfaceElement?.getBoundingClientRect();
    if (touch == null || bounds == null) {
      return null;
    }
    return _offsetsToPositionPercent(
      clientX: touch.client.x.toDouble(),
      clientY: touch.client.y.toDouble(),
      bounds: bounds,
    );
  }

  html.Touch? _resolveTouch(html.TouchEvent event) {
    if (event.changedTouches != null && event.changedTouches!.isNotEmpty) {
      return event.changedTouches![0];
    }
    if (event.touches != null && event.touches!.isNotEmpty) {
      return event.touches![0];
    }
    return null;
  }

  double _offsetsToPositionPercent({
    required double clientX,
    required double clientY,
    required html.Rectangle<num> bounds,
  }) {
    final rawPosition = isVertical
        ? ((clientY - bounds.top) / bounds.height)
        : ((clientX - bounds.left) / bounds.width);
    final clampedPosition = rawPosition.clamp(0, 1).toDouble() * 100;
    return clampedPosition;
  }

  int _resolveClosestHandleIndex(double positionPercent) {
    if (!range) {
      return 0;
    }
    final lowerDistance = (handles[0].positionPercent - positionPercent).abs();
    final upperDistance = (handles[1].positionPercent - positionPercent).abs();
    return lowerDistance <= upperDistance ? 0 : 1;
  }

  void _applyPointerPosition(int handleIndex, double positionPercent) {
    final nextValue = _positionPercentToValue(positionPercent);
    _setHandleValue(handleIndex, nextValue);
  }

  double _positionPercentToValue(double positionPercent) {
    final valuePercent = isRtl ? 100 - positionPercent : positionPercent;
    final ratio = valuePercent.clamp(0, 100) / 100;
    return min.toDouble() + (max.toDouble() - min.toDouble()) * ratio;
  }

  double _valueToPositionPercent(double value) {
    final span = max.toDouble() - min.toDouble();
    if (span <= 0) {
      return 0;
    }
    final ratio = ((value - min.toDouble()) / span).clamp(0, 1);
    final valuePercent = ratio * 100;
    return isRtl ? (100.0 - valuePercent).toDouble() : valuePercent.toDouble();
  }

  double _horizontalIncrement(double stepSize) => isRtl ? -stepSize : stepSize;

  double _horizontalDecrement(double stepSize) => isRtl ? stepSize : -stepSize;

  double _verticalIncrement(double stepSize) => isRtl ? stepSize : -stepSize;

  double _verticalDecrement(double stepSize) => isRtl ? -stepSize : stepSize;

  void _startDrag(int handleIndex) {
    _dragHandleIndex = handleIndex;
    _syncHandleStateClasses();
    _markForCheck();
    _mouseMoveSubscription ??= html.document.onMouseMove.listen((event) {
      if (_dragHandleIndex == null || disabled) {
        return;
      }
      final positionPercent = _mouseEventToPositionPercent(event);
      if (positionPercent == null) {
        return;
      }
      _applyPointerPosition(_dragHandleIndex!, positionPercent);
      event.preventDefault();
    });
    _mouseUpSubscription ??= html.document.onMouseUp.listen((_) {
      _dragHandleIndex = null;
      _syncHandleStateClasses();
      _markForCheck();
    });
    _touchMoveSubscription ??= html.document.onTouchMove.listen((event) {
      if (_dragHandleIndex == null || disabled) {
        return;
      }
      final positionPercent = _touchEventToPositionPercent(event);
      if (positionPercent == null) {
        return;
      }
      _applyPointerPosition(_dragHandleIndex!, positionPercent);
      event.preventDefault();
    });
    _touchEndSubscription ??= html.document.onTouchEnd.listen((_) {
      _dragHandleIndex = null;
      _syncHandleStateClasses();
      _markForCheck();
    });
  }

  void _activateTapState() {
    _tapActive = true;
    _tapStateTimer?.cancel();
    _tapStateTimer = Timer(const Duration(milliseconds: 180), () {
      _tapActive = false;
      _markForCheck();
    });
    _markForCheck();
  }

  List<num> _snapshotRangeValues() => <num>[
        _toOutputNum(_lowerValue),
        _toOutputNum(_upperValue),
      ];

  num _toOutputNum(double value) {
    final rounded = _roundToPrecision(value);
    if (_precision == 0 && rounded == rounded.roundToDouble()) {
      return rounded.round();
    }
    return rounded;
  }

  void _rebuildViewModels() {
    final handleCount = range ? 2 : 1;
    if (handles.length != handleCount) {
      handles = List<LiSliderHandleViewModel>.generate(
        handleCount,
        (int index) => LiSliderHandleViewModel(index),
      );
    }

    final firstPosition = _valueToPositionPercent(_activeLowerOrSingleValue);
    handles[0]
      ..value = _activeLowerOrSingleValue
      ..positionPercent = firstPosition
      ..originStyle = isVertical
          ? 'top: ${firstPosition.toStringAsFixed(4)}%;'
          : 'left: ${firstPosition.toStringAsFixed(4)}%;'
      ..tooltip = _formatValue(_activeLowerOrSingleValue)
      ..cssClass = _handleClassForIndex(0)
      ..ariaLabel = range ? 'Minimum ${ariaLabel.trim()}' : ariaLabel.trim();

    if (range) {
      final secondPosition = _valueToPositionPercent(_upperValue);
      handles[1]
        ..value = _upperValue
        ..positionPercent = secondPosition
        ..originStyle = isVertical
            ? 'top: ${secondPosition.toStringAsFixed(4)}%;'
            : 'left: ${secondPosition.toStringAsFixed(4)}%;'
        ..tooltip = _formatValue(_upperValue)
        ..cssClass = _handleClassForIndex(1)
        ..ariaLabel = 'Maximum ${ariaLabel.trim()}';
    }

    _rebuildConnect();
    _rebuildPips();
  }

  void _rebuildConnect() {
    final mode = _effectiveConnectMode;
    if (mode == 'none' || handles.isEmpty) {
      connectStartPercent = 0;
      connectSizePercent = 0;
      return;
    }

    if (mode == 'range' && range) {
      final lowerPosition = handles[0].positionPercent;
      final upperPosition = handles[1].positionPercent;
      connectStartPercent =
          lowerPosition < upperPosition ? lowerPosition : upperPosition;
      connectSizePercent = (upperPosition - lowerPosition).abs();
      return;
    }

    if (mode == 'upper') {
      final position = range && handles.length > 1
          ? handles[1].positionPercent
          : handles[0].positionPercent;
      _setUpperConnect(position);
      return;
    }

    _setLowerConnect(handles[0].positionPercent);
  }

  void _rebuildPips() {
    if (!shouldRenderPips) {
      pips = const <LiSliderPipViewModel>[];
      return;
    }

    pips = customPips.isNotEmpty ? _buildCustomPips() : _buildGeneratedPips();
  }

  void _setLowerConnect(double position) {
    if (isRtl) {
      connectStartPercent = position;
      connectSizePercent = 100 - position;
      return;
    }

    connectStartPercent = 0;
    connectSizePercent = position;
  }

  void _setUpperConnect(double position) {
    if (isRtl) {
      connectStartPercent = 0;
      connectSizePercent = position;
      return;
    }

    connectStartPercent = position;
    connectSizePercent = 100 - position;
  }

  List<LiSliderPipViewModel> _buildGeneratedPips() {
    final generated = <LiSliderPipViewModel>[];
    final lastIndex = pipCount - 1;

    for (var index = 0; index < pipCount; index++) {
      final ratio = lastIndex == 0 ? 0.0 : index / lastIndex;
      final value = min.toDouble() + (max.toDouble() - min.toDouble()) * ratio;
      final isEdge = index == 0 || index == lastIndex;
      final isSub = !isEdge && index.isOdd;
      generated.add(_createPipViewModel(
        id: index,
        value: value,
        label: _formatValue(value),
        isSub: isSub,
        isLarge: isEdge,
      ));
    }

    return generated;
  }

  List<LiSliderPipViewModel> _buildCustomPips() {
    final sortedPips = customPips.toList(growable: false)
      ..sort((left, right) =>
          left.value.toDouble().compareTo(right.value.toDouble()));

    final generated = <LiSliderPipViewModel>[];
    for (var index = 0; index < sortedPips.length; index++) {
      final pip = sortedPips[index];
      final isEdge = index == 0 || index == sortedPips.length - 1;
      generated.add(_createPipViewModel(
        id: index,
        value: pip.value.toDouble(),
        label: pip.effectiveLabel(_formatValue(pip.value.toDouble())),
        isSub: pip.sub,
        isLarge: pip.large || isEdge,
      ));
    }

    return generated;
  }

  LiSliderPipViewModel _createPipViewModel({
    required int id,
    required double value,
    required String label,
    required bool isSub,
    required bool isLarge,
  }) {
    final clampedValue = value.clamp(min.toDouble(), max.toDouble()).toDouble();
    final positionPercent = _valueToPositionPercent(clampedValue);
    final markerClass = _joinClasses(<String>[
      'noUi-marker',
      isVertical ? 'noUi-marker-vertical' : 'noUi-marker-horizontal',
      isLarge ? 'noUi-marker-large' : '',
      isSub ? 'noUi-marker-sub' : '',
    ]);
    final valueClass = _joinClasses(<String>[
      'noUi-value',
      isVertical ? 'noUi-value-vertical' : 'noUi-value-horizontal',
      isSub ? 'noUi-value-sub' : '',
    ]);
    final style = isVertical
        ? 'top: ${positionPercent.toStringAsFixed(4)}%;'
        : 'left: ${positionPercent.toStringAsFixed(4)}%;';

    return LiSliderPipViewModel(id)
      ..label = label
      ..markerClass = markerClass
      ..valueClass = valueClass
      ..markerStyle = style
      ..valueStyle = style;
  }

  String _formatValue(double value) {
    final outputValue = _toOutputNum(value);
    return outputValue.toString();
  }

  String _handleClassForIndex(int index) {
    final isActive = _dragHandleIndex == index || _focusedHandleIndex == index;
    return _joinClasses(<String>[
      'noUi-handle',
      isActive ? 'li-slider__handle--active' : '',
    ]);
  }

  void _syncHandleStateClasses() {
    for (final handle in handles) {
      handle.cssClass = _handleClassForIndex(handle.id);
    }
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }
}

class LiSliderHandleViewModel {
  LiSliderHandleViewModel(this.id);

  final int id;
  double value = 0;
  double positionPercent = 0;
  String originStyle = '';
  String tooltip = '';
  String ariaLabel = '';
  String cssClass = 'noUi-handle';
}

class LiSliderPipViewModel {
  LiSliderPipViewModel(this.id);

  final int id;
  String label = '';
  String markerClass = '';
  String valueClass = '';
  String markerStyle = '';
  String valueStyle = '';
}

class LiSliderPip {
  const LiSliderPip({
    required this.value,
    this.label,
    this.sub = false,
    this.large = false,
  });

  final num value;
  final String? label;
  final bool sub;
  final bool large;

  String effectiveLabel(String fallback) {
    final customLabel = label?.trim() ?? '';
    return customLabel.isEmpty ? fallback : customLabel;
  }
}

class LiSliderRangeValues {
  const LiSliderRangeValues(this.lower, this.upper);

  final double lower;
  final double upper;
}
