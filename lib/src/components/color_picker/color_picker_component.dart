import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;
import 'package:popper/popper.dart';

import '../../core/overlay_positioning.dart';
import '../../directives/css_style_directive.dart';

class _LiColorValue {
  const _LiColorValue({
    required this.red,
    required this.green,
    required this.blue,
    required this.alpha,
  });

  final int red;
  final int green;
  final int blue;
  final double alpha;

  _LiColorValue copyWith({
    int? red,
    int? green,
    int? blue,
    double? alpha,
  }) {
    return _LiColorValue(
      red: red ?? this.red,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      alpha: alpha ?? this.alpha,
    );
  }
}

class _LiHsvValue {
  const _LiHsvValue({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.alpha,
  });

  final double hue;
  final double saturation;
  final double value;
  final double alpha;

  _LiHsvValue copyWith({
    double? hue,
    double? saturation,
    double? value,
    double? alpha,
  }) {
    return _LiHsvValue(
      hue: hue ?? this.hue,
      saturation: saturation ?? this.saturation,
      value: value ?? this.value,
      alpha: alpha ?? this.alpha,
    );
  }
}

class LiColorPickerEvent {
  const LiColorPickerEvent({
    required this.value,
    required this.source,
  });

  final String? value;
  final String source;
}

class _LiColorPickerSwatchView {
  _LiColorPickerSwatchView({
    required this.id,
    required this.colorText,
    required this.color,
    required this.thumbClass,
    required this.swatchStyle,
  });

  final String id;
  final String colorText;
  final _LiColorValue color;
  String thumbClass;
  final String swatchStyle;
}

class _LiColorPickerPaletteRowView {
  const _LiColorPickerPaletteRowView({
    required this.id,
    required this.rowClass,
    required this.swatches,
  });

  final String id;
  final String rowClass;
  final List<_LiColorPickerSwatchView> swatches;
}

@Component(
  selector: 'li-color-picker',
  styleUrls: ['color_picker_component.css'],
  templateUrl: 'color_picker_component.html',
  directives: [coreDirectives, CssStyleDirective],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiColorPickerComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiColorPickerComponent
    implements ControlValueAccessor<String?>, OnDestroy {
  LiColorPickerComponent(this._changeDetectorRef);

  static const Map<String, String> _namedColors = <String, String>{
    'black': '#000000',
    'silver': '#c0c0c0',
    'gray': '#808080',
    'white': '#ffffff',
    'maroon': '#800000',
    'red': '#ff0000',
    'purple': '#800080',
    'fuchsia': '#ff00ff',
    'green': '#008000',
    'lime': '#00ff00',
    'olive': '#808000',
    'yellow': '#ffff00',
    'navy': '#000080',
    'blue': '#0000ff',
    'teal': '#008080',
    'aqua': '#00ffff',
    'orange': '#ffa500',
    'orangered': '#ff4500',
  };

  static const List<String> _defaultPalette = <String>[
    '#000000',
    '#444444',
    '#666666',
    '#999999',
    '#CCCCCC',
    '#EEEEEE',
    '#F3F3F3',
    '#FFFFFF',
    '#FF0000',
    '#FF9900',
    '#FFFF00',
    '#00FF00',
    '#00FFFF',
    '#0000FF',
    '#9900FF',
    '#FF00FF',
    '#F4CCCC',
    '#FCE5CD',
    '#FFF2CC',
    '#D9EAD3',
    '#D0E0E3',
    '#CFE2F3',
    '#D9D2E9',
    '#EAD1DC',
    '#EA9999',
    '#F9CB9C',
    '#FFE599',
    '#B6D7A8',
    '#A2C4C9',
    '#9FC5E8',
    '#B4A7D6',
    '#D5A6BD',
    '#E06666',
    '#F6B26B',
    '#FFD966',
    '#93C47D',
    '#76A5AF',
    '#6FA8DC',
    '#8E7CC3',
    '#C27BA0',
    '#CC0000',
    '#E69138',
    '#F1C232',
    '#6AA84F',
    '#45818E',
    '#3D85C6',
    '#674EA7',
    '#A64D79',
    '#990000',
    '#B45F06',
    '#BF9000',
    '#38761D',
    '#134F5C',
    '#0B5394',
    '#351C75',
    '#741B47',
    '#660000',
    '#783F04',
    '#7F6000',
    '#274E13',
    '#0C343D',
    '#073763',
    '#20124D',
    '#4C1130',
  ];

  static const int _paletteRowSize = 8;

  static const _LiColorValue _defaultColorValue = _LiColorValue(
    red: 32,
    green: 191,
    blue: 126,
    alpha: 1,
  );

  final ChangeDetectorRef _changeDetectorRef;
  final StreamController<String?> _valueChangeController =
      StreamController<String?>.broadcast();
  final StreamController<LiColorPickerEvent> _pickerShowController =
      StreamController<LiColorPickerEvent>.broadcast();
  final StreamController<LiColorPickerEvent> _pickerHideController =
      StreamController<LiColorPickerEvent>.broadcast();
  final StreamController<LiColorPickerEvent> _pickerChangeController =
      StreamController<LiColorPickerEvent>.broadcast();
  final StreamController<LiColorPickerEvent> _pickerMoveController =
      StreamController<LiColorPickerEvent>.broadcast();
  final StreamController<LiColorPickerEvent> _pickerDragStartController =
      StreamController<LiColorPickerEvent>.broadcast();
  final StreamController<LiColorPickerEvent> _pickerDragStopController =
      StreamController<LiColorPickerEvent>.broadcast();

  PopperAnchoredOverlay? _overlay;
  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;
  StreamSubscription<html.MouseEvent>? _dragMouseMoveSubscription;
  StreamSubscription<html.MouseEvent>? _dragMouseUpSubscription;
  StreamSubscription<html.TouchEvent>? _dragTouchMoveSubscription;
  StreamSubscription<html.TouchEvent>? _dragTouchEndSubscription;
  int? _dragAnimationFrameId;
  math.Point<double>? _pendingDragPoint;
  String? _pendingDragTarget;
  bool _touched = false;
  bool _isDragging = false;
  bool _ignoreNextDocumentClick = false;
  Timer? _ignoreNextDocumentClickTimer;
  bool _showPaletteOnlyView = false;
  bool _hasDeferredPaletteSync = false;
  String? _activeDragTarget;
  String? _bodyUserSelectStyle;
  String? _bodyWebkitUserSelectStyle;
  String _basePaletteSignature = '';
  String _selectionPaletteSignature = '';
  List<String> _palette = const <String>[];

  html.Element? _draggerElement;
  html.Element? _hueSliderElement;
  html.Element? _alphaInnerElement;
  html.Element? _alphaHandleElement;
  html.InputElement? _textInputElement;
  html.Element? _currentThumbInnerElement;
  html.Element? _triggerPreviewInnerElement;

  ChangeFunction<String?> _onChange = (String? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  @Input()
  String? value;

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  String? placeholder;

  @Input()
  String locale = 'pt_BR';

  @Input()
  String titleText = '';

  @Input()
  String chooseButtonText = '';

  @Input()
  String cancelButtonText = '';

  @Input()
  String clearButtonText = '';

  @Input()
  String preferredFormat = 'hex';

  @Input()
  bool allowEmpty = false;

  @Input()
  bool showInput = false;

  @Input()
  bool showAlpha = false;

  @Input()
  bool showInitial = false;

  @Input()
  bool showPalette = false;

  @Input()
  bool showPaletteOnly = false;

  @Input()
  bool togglePaletteOnly = false;

  @Input()
  bool hideAfterPaletteSelect = false;

  @Input()
  bool showButtons = true;

  @Input()
  bool flat = false;

  @Input()
  bool clickoutFiresChange = true;

  @Input()
  bool showSelectionPalette = false;

  @Input()
  int maxSelectionPalette = 8;

  @Input()
  set palette(List<String> value) {
    _palette = value;
    _syncPaletteCollectionsIfNeeded(force: true);
    _syncPaletteActiveStates();
    _markForCheck();
  }

  List<String> get palette => _palette;

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
  Stream<String?> get valueChange => _valueChangeController.stream;

  @Output()
  Stream<LiColorPickerEvent> get pickerShow => _pickerShowController.stream;

  @Output()
  Stream<LiColorPickerEvent> get pickerHide => _pickerHideController.stream;

  @Output()
  Stream<LiColorPickerEvent> get pickerChange => _pickerChangeController.stream;

  @Output()
  Stream<LiColorPickerEvent> get pickerMove => _pickerMoveController.stream;

  @Output()
  Stream<LiColorPickerEvent> get pickerDragStart =>
      _pickerDragStartController.stream;

  @Output()
  Stream<LiColorPickerEvent> get pickerDragStop =>
      _pickerDragStopController.stream;

  @ViewChild('triggerElement')
  html.Element? triggerElement;

  @ViewChild('panelElement')
  html.Element? panelElement;

  @ViewChild('colorAreaElement')
  html.Element? colorAreaElement;

  @ViewChild('hueElement')
  html.Element? hueElement;

  @ViewChild('alphaElement')
  html.Element? alphaElement;

  _LiColorValue? _committedColor;
  _LiColorValue? _draftColor;
  _LiHsvValue? _draftHsv;
  _LiColorValue? _initialColorAtOpen;
  final List<String> _selectionPalette = <String>[];
  List<_LiColorPickerPaletteRowView> _resolvedPaletteRows =
      const <_LiColorPickerPaletteRowView>[];
  List<_LiColorPickerPaletteRowView> _selectionPaletteRows =
      const <_LiColorPickerPaletteRowView>[];
  String resolvedInputClass = 'form-control sp-input';
  String resolvedFeedbackClass = 'invalid-feedback d-block';
  String? resolvedDescribedBy;
  String displayValue = '';
  String draftValueText = '';
  String manualInputValue = '';
  String triggerTitle = '';
  String previewSwatchStyle = 'background-color: transparent;';
  String currentThumbStyle = 'background-color: transparent;';
  String initialThumbStyle = 'background-color: transparent;';
  String currentThumbTitle = '';
  String initialThumbTitle = '';
  String currentThumbClass = 'sp-thumb-el sp-thumb-light sp-thumb-active';
  String initialThumbClass = 'sp-thumb-el sp-thumb-light';
  String triggerSwatchStyle = 'background-color: transparent;';
  String colorAreaStyle = 'background-color: rgb(32, 191, 126);';
  String draggerStyle = 'left: 100.00%; top: 0.00%;';
  String hueSliderStyle = 'top: 0.00%;';
  String alphaGradientStyle =
      'background: linear-gradient(to right, rgba(32, 191, 126, 0), rgba(32, 191, 126, 1));';
  String alphaHandleStyle = 'left: 100.00%;';
  bool isOpen = false;

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get effectiveInvalid =>
      invalid || dataInvalid || (required && _touched && value == null);

  bool get effectiveValid =>
      !effectiveInvalid && (valid || (required && _touched && value != null));

  bool get hasHelperText => helperText.trim().isNotEmpty;

  bool get showErrorFeedback => errorText.trim().isNotEmpty && effectiveInvalid;

  bool get canClear => allowEmpty && (_draftColor != null || value != null);

  bool get shouldShowButtons => showButtons;

  bool get canShowEditor => !showPaletteOnly && !_showPaletteOnlyView;

  bool get showTogglePaletteButton =>
      togglePaletteOnly && showPalette && !showPaletteOnly;

  bool get isPaletteOnlyView => showPaletteOnly || _showPaletteOnlyView;

  bool get hasSelectionPalette => _selectionPalette.isNotEmpty;

  List<dynamic> get resolvedPaletteRows => _resolvedPaletteRows;

  List<dynamic> get selectionPaletteRows => _selectionPaletteRows;

  bool get shouldRenderSelectionPalette => showSelectionPalette;

  bool get hasPaletteContent => showPalette || hasSelectionPalette;

  bool get hasInitialColor => _initialColorAtOpen != null;

  bool get isDraftEmpty => allowEmpty && _draftColor == null;

  bool get isCommittedEmpty => allowEmpty && _committedColor == null;

  bool get isDragging => _isDragging;

  String get resolvedTitleText =>
      titleText.trim().isNotEmpty ? titleText.trim() : _defaultTitleText;

  String get effectivePlaceholder =>
      placeholder ?? (_isEnglishLocale ? 'Select color' : 'Selecione uma cor');

  String get chooseText => chooseButtonText.trim().isNotEmpty
      ? chooseButtonText.trim()
      : (_isEnglishLocale ? 'Choose' : 'Escolher');

  String get cancelText => cancelButtonText.trim().isNotEmpty
      ? cancelButtonText.trim()
      : (_isEnglishLocale ? 'Cancel' : 'Cancelar');

  String get clearText => clearButtonText.trim().isNotEmpty
      ? clearButtonText.trim()
      : (_isEnglishLocale ? 'Clear' : 'Limpar');

  String get noColorSelectedText =>
      _isEnglishLocale ? 'No color selected' : 'Nenhuma cor selecionada';

  String get togglePaletteMoreText => _isEnglishLocale ? 'More' : 'Mais';

  String get togglePaletteLessText => _isEnglishLocale ? 'Less' : 'Menos';

  String get togglePaletteText =>
      isPaletteOnlyView ? togglePaletteMoreText : togglePaletteLessText;

  String get _defaultTitleText =>
      _isEnglishLocale ? 'Color picker' : 'Seletor de cor';

  _LiColorValue get _fallbackColor =>
      _draftColor ?? _committedColor ?? _defaultColorValue;

  void _refreshStableViewState({bool syncManualInput = false}) {
    _syncPaletteCollectionsIfNeeded();
    _refreshViewState(syncManualInput: syncManualInput);
    _syncPaletteActiveStates();
  }

  void toggleOpen() {
    if (isDisabled || flat) {
      return;
    }

    if (isOpen) {
      close(commit: clickoutFiresChange, source: 'trigger');
      return;
    }

    _open();
  }

  void _open() {
    if (isDisabled || flat) {
      return;
    }

    _ensureOverlay();
    _setDraftColorFromColor(_committedColor);
    _initialColorAtOpen = _cloneColor(_committedColor);
    _showPaletteOnlyView = showPaletteOnly;
    _syncManualInput();
    _refreshStableViewState();
    isOpen = true;
    _overlay?.startAutoUpdate();
    _overlay?.update();
    _bindDocumentListeners();
    _emitEvent(_pickerShowController, source: 'open');
    _markForCheck();
  }

  void close({bool commit = false, String source = 'close'}) {
    if (flat) {
      if (commit) {
        _commitDraft(source: source);
      } else {
        _setDraftColorFromColor(_committedColor);
        _syncManualInput();
        _refreshStableViewState();
        _markForCheck();
      }
      return;
    }

    _unbindDocumentListeners();
    _overlay?.stopAutoUpdate();

    if (commit) {
      _commitDraft(source: source);
    } else {
      _setDraftColorFromColor(_committedColor);
      _syncManualInput();
      _refreshStableViewState();
    }

    final wasOpen = isOpen;
    isOpen = false;
    _markTouched();
    if (wasOpen) {
      _emitEvent(_pickerHideController, source: source);
    }
    _markForCheck();
  }

  void cancel() {
    if (flat) {
      _setDraftColorFromColor(_committedColor);
      _syncManualInput();
      _refreshStableViewState();
      _markTouched();
      _markForCheck();
      return;
    }

    close(commit: false, source: 'cancel');
  }

  void apply() {
    if (flat) {
      _commitDraft(source: 'flat-apply');
    } else {
      close(commit: true, source: 'apply');
    }
  }

  void clear() {
    if (!allowEmpty) {
      return;
    }

    _setDraftColorFromColor(null);
    manualInputValue = '';
    _refreshStableViewState();

    if (!showButtons) {
      _commitDraft(source: 'clear');
      return;
    }

    _markForCheck();
  }

  void togglePaletteOnlyView() {
    _showPaletteOnlyView = !isPaletteOnlyView;
    _refreshStableViewState();
    _markForCheck();
  }

  void restoreInitial() {
    final initial = _initialColorAtOpen;
    if (initial == null) {
      return;
    }
    _setDraftColorFromColor(initial);
    _syncManualInput();
    _notifyMove('initial');
    _autoCommitIfNeeded('initial');
  }

  void onTextInput(String? rawValue) {
    manualInputValue = rawValue?.trim() ?? '';

    if (manualInputValue.isEmpty && allowEmpty) {
      _setDraftColorFromColor(null);
      _notifyMove('input');
      _autoCommitIfNeeded('input');
      return;
    }

    final parsed = _parseColor(manualInputValue);
    if (parsed == null) {
      _refreshStableViewState(syncManualInput: false);
      _markForCheck();
      return;
    }

    _setDraftColorFromColor(parsed);
    _notifyMove('input');
    _autoCommitIfNeeded('input');
  }

  void onTextInputKeyDown(html.KeyboardEvent event) {
    if (event.key != 'Enter') {
      return;
    }

    event.preventDefault();
    final parsed = _parseColor(manualInputValue);
    final canApplyEmpty = allowEmpty && manualInputValue.isEmpty;
    if (parsed == null && !canApplyEmpty) {
      return;
    }

    if (canApplyEmpty) {
      _setDraftColorFromColor(null);
      _syncManualInput();
    }

    if (showButtons) {
      apply();
      return;
    }

    _autoCommitIfNeeded('input-enter');
  }

  void onPaletteSelect(String colorText) {
    final parsed = _parseColor(colorText);
    if (parsed == null) {
      return;
    }

    final currentAlpha = showAlpha ? (_draftColor?.alpha ?? 1.0) : 1.0;
    _setDraftColorFromColor(
      parsed.copyWith(alpha: showAlpha ? currentAlpha : parsed.alpha),
    );
    _syncManualInput();
    _notifyMove('palette');

    if (hideAfterPaletteSelect) {
      if (flat) {
        _commitDraft(source: 'palette');
      } else {
        close(commit: true, source: 'palette');
      }
      return;
    }

    _autoCommitIfNeeded('palette');
  }

  void onPanelClick(html.Event event) {
    event.stopPropagation();
  }

  void onColorMouseDown(html.MouseEvent event) {
    _startDrag('color', event);
  }

  void onColorTouchStart(html.TouchEvent event) {
    _startDrag('color', event);
  }

  void onHueMouseDown(html.MouseEvent event) {
    _startDrag('hue', event);
  }

  void onHueTouchStart(html.TouchEvent event) {
    _startDrag('hue', event);
  }

  void onAlphaMouseDown(html.MouseEvent event) {
    _startDrag('alpha', event);
  }

  void onAlphaTouchStart(html.TouchEvent event) {
    _startDrag('alpha', event);
  }

  void onInteractiveStart() {
    if (_isDragging) {
      return;
    }
    _isDragging = true;
    _disableDocumentTextSelection();
    _emitEvent(_pickerDragStartController, source: 'dragstart');
    _markForCheck();
  }

  void onInteractiveStop() {
    if (!_isDragging) {
      return;
    }
    _isDragging = false;
    _restoreDocumentTextSelection();
    if (_hasDeferredPaletteSync) {
      _hasDeferredPaletteSync = false;
      _rememberColor(value);
      _refreshStableViewState(syncManualInput: false);
      _markForCheck();
    } else {
      _refreshStableViewState(syncManualInput: false);
      _markForCheck();
    }
    _emitEvent(_pickerDragStopController, source: 'dragstop');
  }

  @override
  void writeValue(String? value) {
    final normalized = value?.trim();
    final parsed = _parseColor(normalized);

    if ((normalized == null || normalized.isEmpty) && allowEmpty) {
      this.value = null;
      _committedColor = null;
      _setDraftColorFromColor(null);
    } else {
      final nextColor = parsed ?? _defaultColorValue;
      this.value = normalized == null || normalized.isEmpty
          ? _formatColor(nextColor)
          : normalized;
      _committedColor = nextColor;
      _setDraftColorFromColor(nextColor);
    }

    if (flat || !isOpen) {
      _initialColorAtOpen = _cloneColor(_committedColor);
    }

    _syncManualInput();
    _refreshStableViewState();
    _markForCheck();
  }

  @override
  void registerOnChange(ChangeFunction<String?> fn) {
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
      close(commit: false, source: 'disabled');
    }
    if (isDisabled) {
      _stopDragging();
    }
    _refreshStableViewState(syncManualInput: false);
    _markForCheck();
  }

  Object? trackBySwatch(int index, dynamic swatch) =>
      swatch is _LiColorPickerSwatchView ? swatch.id : index;

  Object? trackByPaletteRow(int index, dynamic row) =>
      row is _LiColorPickerPaletteRowView ? row.id : index;

  void _autoCommitIfNeeded(String source) {
    if (!showButtons) {
      if (_isDragging) {
        _commitDraftDuringDrag(source: source);
      } else {
        _commitDraft(source: source);
      }
    }
  }

  void _commitDraftDuringDrag({required String source}) {
    final nextValue = _normalizeOutputValue(
      _draftColor == null ? null : _formatColor(_draftColor!),
    );

    value = nextValue;
    _committedColor = _cloneColor(_draftColor);
    _hasDeferredPaletteSync = true;

    _syncCurrentColorViewState(syncManualInput: true);
    _onChange(nextValue);
    _valueChangeController.add(nextValue);
    _applyInteractiveDomState(updateTriggerPreview: true);
    _emitEvent(_pickerChangeController, source: source);
    _markTouched();
  }

  void _commitDraft({
    required String source,
    bool rememberColor = true,
    bool refreshViewState = true,
    bool markForCheck = true,
  }) {
    final nextValue = _normalizeOutputValue(
      _draftColor == null ? null : _formatColor(_draftColor!),
    );

    value = nextValue;
    _committedColor = _cloneColor(_draftColor);
    _syncCurrentColorViewState(syncManualInput: true);
    _onChange(nextValue);
    _valueChangeController.add(nextValue);
    if (rememberColor) {
      _rememberColor(nextValue);
    }
    if (refreshViewState) {
      _refreshStableViewState();
    }
    _emitEvent(_pickerChangeController, source: source);
    _markTouched();
    if (markForCheck) {
      _markForCheck();
    }
  }

  void _rememberColor(String? colorText) {
    if (!showSelectionPalette || colorText == null || colorText.isEmpty) {
      return;
    }

    _selectionPalette.remove(colorText);
    _selectionPalette.insert(0, colorText);
    final maxItems = math.max(1, maxSelectionPalette);
    while (_selectionPalette.length > maxItems) {
      _selectionPalette.removeLast();
    }

    _syncPaletteCollectionsIfNeeded(force: true);
    _syncPaletteActiveStates();
  }

  void _notifyMove(String source) {
    _syncCurrentColorViewState(syncManualInput: true);
    _applyInteractiveDomState(updateTriggerPreview: false);
    _emitEvent(_pickerMoveController, source: source);
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
        hostClassName: 'LiColorPickerComponent',
        hostZIndex: '1085',
        floatingZIndex: '1086',
      ),
      popperOptions: PopperOptions(
        placement: 'bottom-start',
        fallbackPlacements: <String>['top-start', 'bottom-end', 'top-end'],
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

      if (_ignoreNextDocumentClick) {
        return;
      }

      final target = event.target;
      if (target is! html.Node) {
        close(commit: clickoutFiresChange, source: 'document');
        return;
      }

      final clickedTrigger = triggerElement?.contains(target) ?? false;
      final clickedPanel = panelElement?.contains(target) ?? false;
      if (!clickedTrigger && !clickedPanel) {
        close(commit: clickoutFiresChange, source: 'document');
      }
    });

    _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
      if (!isOpen) {
        return;
      }

      if (event.key == 'Escape') {
        event.preventDefault();
        cancel();
      }
    });
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription?.cancel();
    _documentKeySubscription = null;
    _restoreDocumentTextSelection();
    _ignoreNextDocumentClickTimer?.cancel();
    _ignoreNextDocumentClickTimer = null;
    _ignoreNextDocumentClick = false;
    _stopDragging();
  }

  void _startDrag(String target, dynamic event) {
    if (isDisabled) {
      return;
    }

    final point = _pointerPositionFromEvent(event);
    if (point == null) {
      return;
    }

    if (event is html.MouseEvent || event is html.TouchEvent) {
      event.preventDefault();
      event.stopPropagation();
    }

    _activeDragTarget = target;
    _bindDragListeners();
    onInteractiveStart();
    _updateDrag(point, target);
  }

  void _bindDragListeners() {
    _cancelDragListeners();
    _dragMouseMoveSubscription =
        html.document.onMouseMove.listen(_handleDocumentMouseMove);
    _dragMouseUpSubscription =
        html.document.onMouseUp.listen(_handleDocumentMouseUp);
    _dragTouchMoveSubscription =
        html.document.onTouchMove.listen(_handleDocumentTouchMove);
    _dragTouchEndSubscription =
        html.document.onTouchEnd.listen(_handleDocumentTouchEnd);
  }

  void _cancelDragListeners() {
    _dragMouseMoveSubscription?.cancel();
    _dragMouseMoveSubscription = null;
    _dragMouseUpSubscription?.cancel();
    _dragMouseUpSubscription = null;
    _dragTouchMoveSubscription?.cancel();
    _dragTouchMoveSubscription = null;
    _dragTouchEndSubscription?.cancel();
    _dragTouchEndSubscription = null;
  }

  void _handleDocumentMouseMove(html.MouseEvent event) {
    final point = _pointerPositionFromEvent(event);
    final target = _activeDragTarget;
    if (point == null || target == null) {
      return;
    }

    event.preventDefault();
    _scheduleDragUpdate(point, target);
  }

  void _handleDocumentMouseUp(html.MouseEvent _) {
    _stopDragging();
  }

  void _handleDocumentTouchMove(html.TouchEvent event) {
    final point = _pointerPositionFromEvent(event);
    final target = _activeDragTarget;
    if (point == null || target == null) {
      return;
    }

    event.preventDefault();
    _scheduleDragUpdate(point, target);
  }

  void _handleDocumentTouchEnd(html.TouchEvent _) {
    _stopDragging();
  }

  void _stopDragging() {
    final hadActiveDrag = _activeDragTarget != null || _isDragging;
    _flushPendingDragUpdate();
    _cancelDragListeners();
    _activeDragTarget = null;
    onInteractiveStop();
    if (hadActiveDrag) {
      _ignoreNextDocumentClick = true;
      _ignoreNextDocumentClickTimer?.cancel();
      _ignoreNextDocumentClickTimer = Timer(Duration.zero, () {
        _ignoreNextDocumentClick = false;
        _ignoreNextDocumentClickTimer = null;
      });
    }
  }

  void _disableDocumentTextSelection() {
    final body = html.document.body;
    if (body == null) {
      return;
    }

    _bodyUserSelectStyle ??= body.style.userSelect;
    _bodyWebkitUserSelectStyle ??=
        body.style.getPropertyValue('-webkit-user-select');
    body.style.userSelect = 'none';
    body.style.setProperty('-webkit-user-select', 'none');
  }

  void _restoreDocumentTextSelection() {
    final body = html.document.body;
    if (body == null) {
      return;
    }

    if (_bodyUserSelectStyle != null) {
      body.style.userSelect = _bodyUserSelectStyle!;
      _bodyUserSelectStyle = null;
    } else {
      body.style.userSelect = '';
    }

    if (_bodyWebkitUserSelectStyle != null) {
      body.style.setProperty(
        '-webkit-user-select',
        _bodyWebkitUserSelectStyle!,
      );
      _bodyWebkitUserSelectStyle = null;
    } else {
      body.style.removeProperty('-webkit-user-select');
    }
  }

  void _scheduleDragUpdate(math.Point<double> point, String target) {
    _pendingDragPoint = point;
    _pendingDragTarget = target;

    if (_dragAnimationFrameId != null) {
      return;
    }

    _dragAnimationFrameId = html.window.requestAnimationFrame((_) {
      _dragAnimationFrameId = null;
      _flushPendingDragUpdate();
    });
  }

  void _flushPendingDragUpdate() {
    if (_dragAnimationFrameId != null) {
      html.window.cancelAnimationFrame(_dragAnimationFrameId!);
      _dragAnimationFrameId = null;
    }

    final point = _pendingDragPoint;
    final target = _pendingDragTarget;

    _pendingDragPoint = null;
    _pendingDragTarget = null;

    if (point == null || target == null) {
      return;
    }

    _updateDrag(point, target);
  }

  math.Point<double>? _pointerPositionFromEvent(dynamic event) {
    if (event is html.MouseEvent) {
      return math.Point<double>(
        event.client.x.toDouble(),
        event.client.y.toDouble(),
      );
    }

    if (event is html.TouchEvent) {
      final touches = event.touches;
      final changedTouches = event.changedTouches;
      final touch = touches != null && touches.isNotEmpty
          ? touches.first
          : changedTouches != null && changedTouches.isNotEmpty
              ? changedTouches.first
              : null;
      if (touch == null) {
        return null;
      }

      return math.Point<double>(
        touch.client.x.toDouble(),
        touch.client.y.toDouble(),
      );
    }

    return null;
  }

  void _updateDrag(math.Point<double> point, String target) {
    switch (target) {
      case 'color':
        _updateColorFromPoint(point);
        break;
      case 'hue':
        _updateHueFromPoint(point);
        break;
      case 'alpha':
        _updateAlphaFromPoint(point);
        break;
    }
  }

  void _updateColorFromPoint(math.Point<double> point) {
    final element = colorAreaElement;
    if (element == null) {
      return;
    }

    final rect = element.getBoundingClientRect();
    if (rect.width <= 0 || rect.height <= 0) {
      return;
    }

    final saturation =
        ((point.x - rect.left) / rect.width).clamp(0, 1).toDouble();
    final value =
        (1 - ((point.y - rect.top) / rect.height).clamp(0, 1)).toDouble();
    final hsv = _draftHsv ?? _colorToHsv(_draftColor ?? _fallbackColor);
    _setDraftColorFromHsv(
      hsv.copyWith(
        saturation: saturation,
        value: value,
        alpha: showAlpha ? hsv.alpha : 1,
      ),
    );
    _notifyMove('color');
    _autoCommitIfNeeded('color');
  }

  void _updateHueFromPoint(math.Point<double> point) {
    final element = hueElement;
    if (element == null) {
      return;
    }

    final rect = element.getBoundingClientRect();
    if (rect.height <= 0) {
      return;
    }

    final hue = ((point.y - rect.top) / rect.height).clamp(0, 1).toDouble();
    final currentHsv = _draftHsv ?? _colorToHsv(_draftColor ?? _fallbackColor);
    _setDraftColorFromHsv(
      currentHsv.copyWith(
        hue: hue,
        alpha: showAlpha ? currentHsv.alpha : 1,
      ),
    );
    _notifyMove('hue');
    _autoCommitIfNeeded('hue');
  }

  void _updateAlphaFromPoint(math.Point<double> point) {
    if (!showAlpha) {
      return;
    }

    final element = alphaElement;
    if (element == null) {
      return;
    }

    final rect = element.getBoundingClientRect();
    if (rect.width <= 0) {
      return;
    }

    final alpha = ((point.x - rect.left) / rect.width).clamp(0, 1).toDouble();
    final currentHsv = _draftHsv ?? _colorToHsv(_draftColor ?? _fallbackColor);
    _setDraftColorFromHsv(currentHsv.copyWith(alpha: alpha));
    _notifyMove('alpha');
    _autoCommitIfNeeded('alpha');
  }

  void _syncManualInput() {
    manualInputValue = _draftColor == null ? '' : _formatColor(_draftColor!);
  }

  void _refreshViewState({bool syncManualInput = false}) {
    resolvedInputClass = _joinClasses(<String>[
      'form-control',
      'sp-input',
      effectiveInvalid ? 'is-invalid' : '',
      effectiveValid ? 'is-valid' : '',
    ]);
    resolvedFeedbackClass = _joinClasses(<String>[
      'invalid-feedback',
      'd-block',
      feedbackClass,
    ]);
    resolvedDescribedBy =
        describedBy.trim().isEmpty ? null : describedBy.trim();

    _syncCurrentColorViewState(syncManualInput: syncManualInput);
  }

  void _syncCurrentColorViewState({
    bool syncManualInput = false,
  }) {
    displayValue =
        _committedColor == null ? '' : _formatColor(_committedColor!);
    draftValueText = _draftColor == null ? '' : _formatColor(_draftColor!);
    if (syncManualInput) {
      manualInputValue = draftValueText;
    }
    triggerTitle = displayValue.isEmpty ? noColorSelectedText : displayValue;

    final fallbackColor = _fallbackColor;
    final draftColor = _draftColor ?? fallbackColor;
    final draftHsv = _draftHsv ?? _colorToHsv(draftColor);
    final hueColor = _colorFromHsv(
      draftHsv.copyWith(saturation: 1, value: 1, alpha: 1),
    );
    final opaqueColor = _colorFromHsv(draftHsv.copyWith(alpha: 1));

    previewSwatchStyle = isDraftEmpty
        ? 'background-color: transparent;'
        : 'background-color: ${_colorToCss(draftColor)};';
    currentThumbStyle = previewSwatchStyle;
    currentThumbTitle =
        draftValueText.isEmpty ? noColorSelectedText : draftValueText;
    currentThumbClass = _swatchThumbClass(draftColor, isActive: true);

    initialThumbStyle = _initialColorAtOpen == null
        ? 'background-color: transparent;'
        : 'background-color: ${_colorToCss(_initialColorAtOpen!)};';
    initialThumbTitle = _initialColorAtOpen == null
        ? noColorSelectedText
        : _formatColor(_initialColorAtOpen!);
    initialThumbClass = _swatchThumbClass(
      _initialColorAtOpen ?? fallbackColor,
      isActive: _colorsEqual(_initialColorAtOpen, _draftColor),
    );

    triggerSwatchStyle = isCommittedEmpty
        ? 'background-color: transparent;'
        : 'background-color: ${_colorToCss(_committedColor ?? fallbackColor)};';
    colorAreaStyle = 'background-color: ${_colorToCss(hueColor)};';
    draggerStyle = _buildDraggerStyle(draftHsv);
    hueSliderStyle = 'top: ${(draftHsv.hue * 100).toStringAsFixed(2)}%;';
    alphaGradientStyle =
        'background: linear-gradient(to right, rgba(${opaqueColor.red}, ${opaqueColor.green}, ${opaqueColor.blue}, 0), rgba(${opaqueColor.red}, ${opaqueColor.green}, ${opaqueColor.blue}, 1));';
    alphaHandleStyle = 'left: ${(draftHsv.alpha * 100).toStringAsFixed(2)}%;';
  }

  void _syncPaletteCollectionsIfNeeded({bool force = false}) {
    final baseSignature = showPalette
        ? '1|${(_palette.isNotEmpty ? _palette : _defaultPalette).join(',')}'
        : '0';
    if (force || _basePaletteSignature != baseSignature) {
      _basePaletteSignature = baseSignature;
      if (!showPalette) {
        _resolvedPaletteRows = const <_LiColorPickerPaletteRowView>[];
      } else {
        final paletteColors = _palette.isNotEmpty ? _palette : _defaultPalette;
        _resolvedPaletteRows = _buildPaletteRows(
          paletteColors,
          prefix: 'base',
        );
      }
    }

    final selectionSignature =
        showSelectionPalette ? '1|${_selectionPalette.join(',')}' : '0';
    if (force || _selectionPaletteSignature != selectionSignature) {
      _selectionPaletteSignature = selectionSignature;
      if (!showSelectionPalette) {
        _selectionPaletteRows = const <_LiColorPickerPaletteRowView>[];
      } else {
        _selectionPaletteRows = _buildPaletteRows(
          _selectionPalette,
          prefix: 'selection',
          startRowIndex: 0,
          rowClassName: 'sp-palette-row sp-palette-row-selection',
        );
      }
    }
  }

  String _buildDraggerStyle(_LiHsvValue hsv) {
    final left = _buildDraggerLeftStyle(hsv);
    final top = _buildDraggerTopStyle(hsv);
    return 'left: $left; top: $top;';
  }

  String _buildDraggerLeftStyle(_LiHsvValue hsv) {
    final saturationPercent = (hsv.saturation * 100).toStringAsFixed(2);
    return 'clamp(calc(-1 * var(--li-color-picker-dragger-edge-offset)), calc($saturationPercent% - var(--li-color-picker-dragger-edge-offset)), calc(100% - var(--li-color-picker-dragger-edge-offset)))';
  }

  String _buildDraggerTopStyle(_LiHsvValue hsv) {
    final valuePercent = ((1 - hsv.value) * 100).toStringAsFixed(2);
    return 'clamp(calc(-1 * var(--li-color-picker-dragger-edge-offset)), calc($valuePercent% - var(--li-color-picker-dragger-edge-offset)), calc(100% - var(--li-color-picker-dragger-edge-offset)))';
  }

  void _syncPaletteActiveStates() {
    _syncSwatchRowActiveStates(_resolvedPaletteRows);
    _syncSwatchRowActiveStates(_selectionPaletteRows);
  }

  void _syncSwatchRowActiveStates(List<_LiColorPickerPaletteRowView> rows) {
    for (final row in rows) {
      for (final swatch in row.swatches) {
        swatch.thumbClass = _swatchThumbClass(
          swatch.color,
          isActive: _isPaletteColorActive(swatch.color),
        );
      }
    }
  }

  void _ensureInteractiveElementRefs() {
    final panel = panelElement;
    if (panel != null) {
      _draggerElement ??= panel.querySelector('.sp-dragger');
      _hueSliderElement ??= panel.querySelector('.sp-slider');
      _alphaInnerElement ??= panel.querySelector('.sp-alpha-inner');
      _alphaHandleElement ??= panel.querySelector('.sp-alpha-handle');
      _textInputElement ??=
          panel.querySelector('.sp-input') as html.InputElement?;
      _currentThumbInnerElement ??= panel.querySelector(
          '.sp-initial .sp-thumb-el:first-child .sp-thumb-inner');
    }
    _triggerPreviewInnerElement ??=
        triggerElement?.querySelector('.sp-preview-inner');
  }

  void _applyInteractiveDomState({required bool updateTriggerPreview}) {
    _ensureInteractiveElementRefs();

    final fallbackColor = _fallbackColor;
    final draftColor = _draftColor ?? fallbackColor;
    final draftHsv = _draftHsv ?? _colorToHsv(draftColor);
    final hueColor = _colorFromHsv(
      draftHsv.copyWith(saturation: 1, value: 1, alpha: 1),
    );
    final opaqueColor = _colorFromHsv(draftHsv.copyWith(alpha: 1));

    colorAreaElement?.style.backgroundColor = _colorToCss(hueColor);
    _draggerElement?.style.left = _buildDraggerLeftStyle(draftHsv);
    _draggerElement?.style.top = _buildDraggerTopStyle(draftHsv);
    _hueSliderElement?.style.top =
        '${(draftHsv.hue * 100).toStringAsFixed(2)}%';
    _alphaInnerElement?.style.background =
        'linear-gradient(to right, rgba(${opaqueColor.red}, ${opaqueColor.green}, ${opaqueColor.blue}, 0), rgba(${opaqueColor.red}, ${opaqueColor.green}, ${opaqueColor.blue}, 1))';
    _alphaHandleElement?.style.left =
        '${(draftHsv.alpha * 100).toStringAsFixed(2)}%';

    if (_textInputElement != null &&
        _textInputElement!.value != manualInputValue) {
      _textInputElement!.value = manualInputValue;
    }

    _currentThumbInnerElement?.style.backgroundColor =
        isDraftEmpty ? 'transparent' : _colorToCss(draftColor);

    if (updateTriggerPreview) {
      _triggerPreviewInnerElement?.style.backgroundColor = isCommittedEmpty
          ? 'transparent'
          : _colorToCss(_committedColor ?? fallbackColor);
    }
  }

  List<_LiColorPickerPaletteRowView> _buildPaletteRows(
    List<String> colors, {
    required String prefix,
    int startRowIndex = 0,
    String? rowClassName,
  }) {
    if (colors.isEmpty) {
      if (rowClassName == null) {
        return const <_LiColorPickerPaletteRowView>[];
      }

      return <_LiColorPickerPaletteRowView>[
        _LiColorPickerPaletteRowView(
          id: '$prefix-row-empty',
          rowClass: 'sp-cf $rowClassName',
          swatches: const <_LiColorPickerSwatchView>[],
        ),
      ];
    }

    final rows = <_LiColorPickerPaletteRowView>[];
    for (var start = 0; start < colors.length; start += _paletteRowSize) {
      final rowIndex = startRowIndex + (start ~/ _paletteRowSize);
      final end = math.min(start + _paletteRowSize, colors.length);
      final rowColors = colors.sublist(start, end);
      rows.add(
        _LiColorPickerPaletteRowView(
          id: '$prefix-row-$rowIndex',
          rowClass: rowClassName == null
              ? 'sp-cf sp-palette-row sp-palette-row-$rowIndex'
              : 'sp-cf $rowClassName',
          swatches:
              _buildSwatchViews(rowColors, prefix: '$prefix-row-$rowIndex'),
        ),
      );
    }

    return List<_LiColorPickerPaletteRowView>.unmodifiable(rows);
  }

  List<_LiColorPickerSwatchView> _buildSwatchViews(
    List<String> colors, {
    required String prefix,
  }) {
    return List<_LiColorPickerSwatchView>.unmodifiable(
      List<_LiColorPickerSwatchView>.generate(colors.length, (index) {
        final colorText = colors[index];
        final parsed = _parseColor(colorText) ?? _fallbackColor;
        return _LiColorPickerSwatchView(
          id: '$prefix-$index-$colorText',
          colorText: colorText,
          color: parsed,
          thumbClass: _swatchThumbClass(
            parsed,
            isActive: _isPaletteColorActive(parsed),
          ),
          swatchStyle: 'background-color: ${_colorToCss(parsed)};',
        );
      }, growable: false),
    );
  }

  bool _isPaletteColorActive(_LiColorValue candidate) {
    final current = _draftColor;
    if (current == null) {
      return false;
    }

    return candidate.red == current.red &&
        candidate.green == current.green &&
        candidate.blue == current.blue;
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

  void _emitEvent(
    StreamController<LiColorPickerEvent> controller, {
    required String source,
  }) {
    controller.add(
      LiColorPickerEvent(
        value: draftValueText.isEmpty ? value : draftValueText,
        source: source,
      ),
    );
  }

  String _formatColor(_LiColorValue color) {
    switch (preferredFormat.toLowerCase()) {
      case 'rgb':
        return _colorToRgbString(color);
      case 'name':
        final name = _nameForColor(color);
        if (name != null && color.alpha >= 1) {
          return name;
        }
        return _colorToRgbString(color);
      case 'hex3':
        if (color.alpha < 1) {
          return _colorToRgbString(color);
        }
        return _toHex3(color);
      case 'hex8':
        return _colorToHex8(color);
      case 'hsl':
        return _colorToHslString(color);
      case 'hsv':
        return _colorToHsvString(color);
      case 'hex':
      default:
        if (color.alpha < 1) {
          return _colorToRgbString(color);
        }
        return _colorToHex(color);
    }
  }

  String? _normalizeOutputValue(String? rawValue) {
    final trimmed = rawValue?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return allowEmpty ? null : _formatColor(_fallbackColor);
    }
    return trimmed;
  }

  _LiColorValue? _parseColor(String? rawValue) {
    final input = rawValue?.trim();
    if (input == null || input.isEmpty) {
      return null;
    }

    if (input.toLowerCase() == 'transparent') {
      return const _LiColorValue(red: 0, green: 0, blue: 0, alpha: 0);
    }

    final named = _namedColors[input.toLowerCase()];
    if (named != null) {
      return _parseHex(named);
    }

    if (input.startsWith('#')) {
      return _parseHex(input);
    }

    final rgbaMatch = RegExp(
      r'^rgba?\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})(?:\s*,\s*([0-9]*\.?[0-9]+))?\s*\)$',
      caseSensitive: false,
    ).firstMatch(input);

    if (rgbaMatch != null) {
      return _LiColorValue(
        red: int.parse(rgbaMatch.group(1)!).clamp(0, 255),
        green: int.parse(rgbaMatch.group(2)!).clamp(0, 255),
        blue: int.parse(rgbaMatch.group(3)!).clamp(0, 255),
        alpha: double.tryParse(rgbaMatch.group(4) ?? '1')
                ?.clamp(0, 1)
                .toDouble() ??
            1,
      );
    }

    final hslMatch = RegExp(
      r'^hsla?\(\s*([-0-9]*\.?[0-9]+)\s*,\s*([-0-9]*\.?[0-9]+)%\s*,\s*([-0-9]*\.?[0-9]+)%(?:\s*,\s*([0-9]*\.?[0-9]+))?\s*\)$',
      caseSensitive: false,
    ).firstMatch(input);

    if (hslMatch != null) {
      return _colorFromHsl(
        hue: double.parse(hslMatch.group(1)!),
        saturation: double.parse(hslMatch.group(2)!) / 100,
        lightness: double.parse(hslMatch.group(3)!) / 100,
        alpha:
            double.tryParse(hslMatch.group(4) ?? '1')?.clamp(0, 1).toDouble() ??
                1,
      );
    }

    final hsvMatch = RegExp(
      r'^hsva?\(\s*([-0-9]*\.?[0-9]+)\s*,\s*([-0-9]*\.?[0-9]+)%\s*,\s*([-0-9]*\.?[0-9]+)%(?:\s*,\s*([0-9]*\.?[0-9]+))?\s*\)$',
      caseSensitive: false,
    ).firstMatch(input);

    if (hsvMatch != null) {
      return _colorFromHsv(
        _LiHsvValue(
          hue: (double.parse(hsvMatch.group(1)!) % 360) / 360,
          saturation:
              (double.parse(hsvMatch.group(2)!) / 100).clamp(0, 1).toDouble(),
          value:
              (double.parse(hsvMatch.group(3)!) / 100).clamp(0, 1).toDouble(),
          alpha: double.tryParse(hsvMatch.group(4) ?? '1')
                  ?.clamp(0, 1)
                  .toDouble() ??
              1,
        ),
      );
    }

    return null;
  }

  _LiColorValue? _parseHex(String input) {
    final normalized = input.replaceAll('#', '').trim();

    if (normalized.length == 3) {
      return _LiColorValue(
        red: int.parse('${normalized[0]}${normalized[0]}', radix: 16),
        green: int.parse('${normalized[1]}${normalized[1]}', radix: 16),
        blue: int.parse('${normalized[2]}${normalized[2]}', radix: 16),
        alpha: 1,
      );
    }

    if (normalized.length == 4) {
      return _LiColorValue(
        red: int.parse('${normalized[0]}${normalized[0]}', radix: 16),
        green: int.parse('${normalized[1]}${normalized[1]}', radix: 16),
        blue: int.parse('${normalized[2]}${normalized[2]}', radix: 16),
        alpha: int.parse('${normalized[3]}${normalized[3]}', radix: 16) / 255,
      );
    }

    if (normalized.length == 6 || normalized.length == 8) {
      final red = int.parse(normalized.substring(0, 2), radix: 16);
      final green = int.parse(normalized.substring(2, 4), radix: 16);
      final blue = int.parse(normalized.substring(4, 6), radix: 16);
      final alpha = normalized.length == 8
          ? int.parse(normalized.substring(6, 8), radix: 16) / 255
          : 1.0;
      return _LiColorValue(
        red: red,
        green: green,
        blue: blue,
        alpha: alpha,
      );
    }

    return null;
  }

  String _colorToHex(_LiColorValue color) {
    return '#${_twoHex(color.red)}${_twoHex(color.green)}${_twoHex(color.blue)}'
        .toUpperCase();
  }

  String _colorToHex8(_LiColorValue color) {
    final alpha = (color.alpha * 255).round().clamp(0, 255);
    return '#${_twoHex(color.red)}${_twoHex(color.green)}${_twoHex(color.blue)}${_twoHex(alpha)}'
        .toUpperCase();
  }

  String _toHex3(_LiColorValue color) {
    final full = _colorToHex(color).replaceAll('#', '');
    final canShorten =
        full[0] == full[1] && full[2] == full[3] && full[4] == full[5];
    if (!canShorten) {
      return '#$full';
    }
    return '#${full[0]}${full[2]}${full[4]}'.toUpperCase();
  }

  String _colorToCss(_LiColorValue color) {
    return _colorToRgbString(color);
  }

  String _colorToRgbString(_LiColorValue color) {
    if (color.alpha >= 1) {
      return 'rgb(${color.red}, ${color.green}, ${color.blue})';
    }
    return 'rgba(${color.red}, ${color.green}, ${color.blue}, ${_formatAlpha(color.alpha)})';
  }

  String _colorToHslString(_LiColorValue color) {
    final r = color.red / 255;
    final g = color.green / 255;
    final b = color.blue / 255;
    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final delta = max - min;
    final lightness = (max + min) / 2;

    double hue = 0;
    double saturation = 0;
    if (delta != 0) {
      saturation =
          lightness > 0.5 ? delta / (2 - max - min) : delta / (max + min);

      if (max == r) {
        hue = ((g - b) / delta + (g < b ? 6 : 0)) / 6;
      } else if (max == g) {
        hue = ((b - r) / delta + 2) / 6;
      } else {
        hue = ((r - g) / delta + 4) / 6;
      }
    }

    final hueDegrees = (hue * 360).round();
    final saturationPercent = (saturation * 100).round();
    final lightnessPercent = (lightness * 100).round();
    if (color.alpha >= 1) {
      return 'hsl($hueDegrees, $saturationPercent%, $lightnessPercent%)';
    }
    return 'hsla($hueDegrees, $saturationPercent%, $lightnessPercent%, ${_formatAlpha(color.alpha)})';
  }

  String _colorToHsvString(_LiColorValue color) {
    final hsv = _colorToHsv(color);
    final hueDegrees = (hsv.hue * 360).round();
    final saturationPercent = (hsv.saturation * 100).round();
    final valuePercent = (hsv.value * 100).round();
    if (color.alpha >= 1) {
      return 'hsv($hueDegrees, $saturationPercent%, $valuePercent%)';
    }
    return 'hsva($hueDegrees, $saturationPercent%, $valuePercent%, ${_formatAlpha(color.alpha)})';
  }

  String _formatAlpha(double alpha) {
    final fixed = alpha.toStringAsFixed(2);
    return fixed.endsWith('00')
        ? alpha.round().toString()
        : fixed.endsWith('0')
            ? fixed.substring(0, fixed.length - 1)
            : fixed;
  }

  String _twoHex(int value) =>
      value.clamp(0, 255).toRadixString(16).padLeft(2, '0');

  String? _nameForColor(_LiColorValue color) {
    for (final entry in _namedColors.entries) {
      final parsed = _parseHex(entry.value);
      if (parsed == null) {
        continue;
      }

      if (parsed.red == color.red &&
          parsed.green == color.green &&
          parsed.blue == color.blue) {
        return entry.key;
      }
    }

    return null;
  }

  _LiColorValue? _cloneColor(_LiColorValue? color) {
    if (color == null) {
      return null;
    }
    return color.copyWith();
  }

  void _setDraftColorFromColor(_LiColorValue? color) {
    _draftColor = _cloneColor(color);
    _draftHsv = color == null ? null : _colorToHsv(color);
  }

  void _setDraftColorFromHsv(_LiHsvValue hsv) {
    _draftHsv = hsv;
    _draftColor = _colorFromHsv(hsv);
  }

  _LiHsvValue _colorToHsv(_LiColorValue color) {
    final red = color.red / 255;
    final green = color.green / 255;
    final blue = color.blue / 255;
    final max = math.max(red, math.max(green, blue));
    final min = math.min(red, math.min(green, blue));
    final delta = max - min;

    double hue = 0;
    if (delta != 0) {
      if (max == red) {
        hue = ((green - blue) / delta + (green < blue ? 6 : 0)) / 6;
      } else if (max == green) {
        hue = ((blue - red) / delta + 2) / 6;
      } else {
        hue = ((red - green) / delta + 4) / 6;
      }
    }

    final saturation = max == 0 ? 0.0 : (delta / max).toDouble();
    return _LiHsvValue(
      hue: hue.toDouble(),
      saturation: saturation,
      value: max.toDouble(),
      alpha: color.alpha,
    );
  }

  _LiColorValue _colorFromHsv(_LiHsvValue hsv) {
    final hue = ((hsv.hue % 1) + 1) % 1;
    final scaledHue = hue * 6;
    final segment = scaledHue.floor();
    final fraction = scaledHue - segment;
    final value = hsv.value.clamp(0, 1).toDouble();
    final saturation = hsv.saturation.clamp(0, 1).toDouble();
    final p = value * (1 - saturation);
    final q = value * (1 - fraction * saturation);
    final t = value * (1 - (1 - fraction) * saturation);

    final rgb = switch (segment % 6) {
      0 => <double>[value, t, p],
      1 => <double>[q, value, p],
      2 => <double>[p, value, t],
      3 => <double>[p, q, value],
      4 => <double>[t, p, value],
      _ => <double>[value, p, q],
    };

    return _LiColorValue(
      red: (rgb[0] * 255).round().clamp(0, 255),
      green: (rgb[1] * 255).round().clamp(0, 255),
      blue: (rgb[2] * 255).round().clamp(0, 255),
      alpha: hsv.alpha.clamp(0, 1).toDouble(),
    );
  }

  _LiColorValue _colorFromHsl({
    required double hue,
    required double saturation,
    required double lightness,
    required double alpha,
  }) {
    final normalizedHue = ((hue % 360) + 360) % 360 / 360;
    final normalizedSaturation = saturation.clamp(0, 1).toDouble();
    final normalizedLightness = lightness.clamp(0, 1).toDouble();

    if (normalizedSaturation == 0) {
      final gray = (normalizedLightness * 255).round().clamp(0, 255);
      return _LiColorValue(
        red: gray,
        green: gray,
        blue: gray,
        alpha: alpha.clamp(0, 1).toDouble(),
      );
    }

    final q = normalizedLightness < 0.5
        ? normalizedLightness * (1 + normalizedSaturation)
        : normalizedLightness +
            normalizedSaturation -
            normalizedLightness * normalizedSaturation;
    final p = 2 * normalizedLightness - q;

    double hueToRgb(double t) {
      var value = t;
      if (value < 0) {
        value += 1;
      }
      if (value > 1) {
        value -= 1;
      }
      if (value < 1 / 6) {
        return p + (q - p) * 6 * value;
      }
      if (value < 1 / 2) {
        return q;
      }
      if (value < 2 / 3) {
        return p + (q - p) * (2 / 3 - value) * 6;
      }
      return p;
    }

    return _LiColorValue(
      red: (hueToRgb(normalizedHue + 1 / 3) * 255).round().clamp(0, 255),
      green: (hueToRgb(normalizedHue) * 255).round().clamp(0, 255),
      blue: (hueToRgb(normalizedHue - 1 / 3) * 255).round().clamp(0, 255),
      alpha: alpha.clamp(0, 1).toDouble(),
    );
  }

  String _swatchThumbClass(_LiColorValue color, {bool isActive = false}) {
    return _joinClasses(<String>[
      'sp-thumb-el',
      _isLightColor(color) ? 'sp-thumb-light' : 'sp-thumb-dark',
      isActive ? 'sp-thumb-active' : '',
    ]);
  }

  bool _isLightColor(_LiColorValue color) {
    final brightness =
        (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
    return brightness >= 186;
  }

  bool _colorsEqual(_LiColorValue? first, _LiColorValue? second) {
    if (first == null || second == null) {
      return first == second;
    }

    return first.red == second.red &&
        first.green == second.green &&
        first.blue == second.blue &&
        (first.alpha - second.alpha).abs() < 0.001;
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
    _cancelDragListeners();
    if (_dragAnimationFrameId != null) {
      html.window.cancelAnimationFrame(_dragAnimationFrameId!);
      _dragAnimationFrameId = null;
    }
    _overlay?.dispose();
    _valueChangeController.close();
    _pickerShowController.close();
    _pickerHideController.close();
    _pickerChangeController.close();
    _pickerMoveController.close();
    _pickerDragStartController.close();
    _pickerDragStopController.close();
  }
}
