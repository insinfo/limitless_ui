import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:popper/popper.dart';

import '../../directives/safe_inner_html_directive.dart';
import 'typeahead_config.dart';
import 'typeahead_highlight_component.dart';

class LiTypeaheadItem {
  LiTypeaheadItem({
    required this.text,
    required this.value,
    required this.instanceObj,
    this.disabled = false,
  });

  final String text;
  final dynamic value;
  final dynamic instanceObj;
  final bool disabled;
}

class LiTypeaheadSelectItemEvent<T> {
  LiTypeaheadSelectItemEvent(this.item);

  final T item;
  bool _defaultPrevented = false;

  void preventDefault() {
    _defaultPrevented = true;
  }

  bool get defaultPrevented => _defaultPrevented;
}

typedef LiTypeaheadSearchCallback = FutureOr<dynamic> Function(String term);
typedef LiTypeaheadResultMarkupBuilder = String Function(
  dynamic item,
  String term,
);

@Component(
  selector: 'li-typeahead',
  changeDetection: ChangeDetectionStrategy.onPush,
  templateUrl: 'typeahead_component.html',
  styleUrls: ['typeahead_component.css'],
  directives: [
    coreDirectives,
    formDirectives,
    SafeInnerHtmlDirective,
    LiTypeaheadHighlightComponent,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiTypeaheadComponent),
  ],
)
class LiTypeaheadComponent
    implements ControlValueAccessor<dynamic>, OnInit, OnDestroy {
  LiTypeaheadComponent(
    this._changeDetectorRef, [
    @Optional() LiTypeaheadConfig? config,
  ]) : _config = config ?? LiTypeaheadConfig() {
    final seq = _nextSequence++;
    popupId = 'li-typeahead-popup-$seq';
    _idPrefix = 'li-typeahead-opt-$seq';

    autocomplete = _config.autocomplete;
    placeholder = _config.placeholder;
    container = _config.container;
    minLength = _config.minLength;
    maxResults = _config.maxResults;
    debounceMs = _config.debounceMs;
    openOnFocus = _config.openOnFocus;
    editable = _config.editable;
    focusFirst = _config.focusFirst;
    selectOnExact = _config.selectOnExact;
    showHint = _config.showHint;
    showLoadingIndicator = _config.showLoadingIndicator;
    loadingText = _config.loadingText;
    errorText = _config.errorText;
    highlightClass = _config.highlightClass;
    highlightAccentSensitive = _config.highlightAccentSensitive;
  }

  static int _nextSequence = 0;

  final ChangeDetectorRef _changeDetectorRef;
  final LiTypeaheadConfig _config;
  final StreamController<dynamic> _changeController =
      StreamController<dynamic>.broadcast();
  final StreamController<LiTypeaheadSelectItemEvent<dynamic>>
      _selectController =
      StreamController<LiTypeaheadSelectItemEvent<dynamic>>.broadcast();

  PopperAnchoredOverlay? _overlay;
  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;
  Timer? _debounceTimer;
  bool _overlayRelayoutPending = false;
  int _searchRequestId = 0;
  bool _destroyed = false;

  ChangeFunction<dynamic>? _ngModelValueChangeCallback;
  TouchFunction? _touchCallback;

  List<LiTypeaheadItem> _allItems = <LiTypeaheadItem>[];
  LiTypeaheadItem? _selectedItem;
  String _committedInputValue = '';
  String rawSearchTerm = '';
  String? _asyncErrorMessage;

  @Input()
  late String autocomplete;

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  late String placeholder;

  @Input()
  late String container;

  @Input()
  String labelKey = 'label';

  @Input()
  String? valueKey;

  @Input()
  String? disabledKey;

  @Input()
  late int minLength;

  @Input()
  late int maxResults;

  @Input()
  late int debounceMs;

  @Input()
  late bool openOnFocus;

  @Input()
  late bool editable;

  @Input()
  late bool focusFirst;

  @Input()
  late bool selectOnExact;

  @Input()
  late bool showHint;

  @Input()
  late bool showLoadingIndicator;

  @Input()
  late String loadingText;

  @Input()
  late String errorText;

  @Input()
  late String highlightClass;

  @Input()
  late bool highlightAccentSensitive;

  @Input()
  String? popupClass;

  @Input()
  LiTypeaheadSearchCallback? searchCallback;

  @Input()
  String? Function(dynamic item)? inputFormatter;

  @Input()
  String? Function(dynamic item)? resultFormatter;

  @Input()
  LiTypeaheadResultMarkupBuilder? resultMarkupBuilder;

  @Output('currentValueChange')
  Stream<dynamic> get currentValueChange => _changeController.stream;

  @Output()
  Stream<LiTypeaheadSelectItemEvent<dynamic>> get selectItem =>
      _selectController.stream;

  @ViewChild('inputElement')
  html.InputElement? inputElement;

  @ViewChild('popupElement')
  html.Element? popupElement;

  @ViewChild('resultsList')
  html.Element? resultsListElement;

  late final String popupId;
  late final String _idPrefix;

  bool popupOpen = false;
  bool loading = false;
  int activeIndex = -1;
  List<LiTypeaheadItem> visibleItems = <LiTypeaheadItem>[];

  String optionId(int index) => '$_idPrefix-$index';

  String? get activeDescendantId {
    if (!popupOpen || activeIndex < 0 || activeIndex >= visibleItems.length) {
      return null;
    }
    return optionId(activeIndex);
  }

  @Input()
  set dataSource(dynamic value) {
    _applyDataSource(_normalizeItems(value));
  }

  @override
  void ngOnInit() {
    _syncVisibleItemsFromTerm(rawSearchTerm, markForCheck: false);
  }

  @override
  void writeValue(dynamic value) {
    if (value == null) {
      _selectedItem = null;
      _committedInputValue = '';
      rawSearchTerm = '';
      _writeInputValue('');
      _markForCheck();
      return;
    }

    final matched = _findItemByValue(value);
    if (matched != null) {
      _selectedItem = matched;
      _committedInputValue = _formatItemForInput(matched);
      rawSearchTerm = _committedInputValue;
      _writeInputValue(_committedInputValue);
      _markForCheck();
      return;
    }

    _selectedItem = null;
    _committedInputValue = value.toString();
    rawSearchTerm = _committedInputValue;
    _writeInputValue(_committedInputValue);
    _markForCheck();
  }

  @override
  void registerOnChange(ChangeFunction<dynamic> callback) {
    _ngModelValueChangeCallback = callback;
  }

  @override
  void registerOnTouched(TouchFunction callback) {
    _touchCallback = callback;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    this.isDisabled = isDisabled;
    if (isDisabled) {
      dismissPopup();
    }
    _markForCheck();
  }

  @override
  void ngOnDestroy() {
    _destroyed = true;
    _debounceTimer?.cancel();
    _unbindDocumentListeners();
    _overlay?.dispose();
    _changeController.close();
    _selectController.close();
  }

  bool isPopupOpen() => popupOpen;

  void dismissPopup() {
    if (!popupOpen) {
      return;
    }

    popupOpen = false;
    loading = false;
    activeIndex = -1;
    _asyncErrorMessage = null;
    _overlayRelayoutPending = false;
    _overlay?.stopAutoUpdate();
    _unbindDocumentListeners();
    _markForCheck();
  }

  void handleFocus() {
    if (isDisabled) {
      return;
    }

    if (openOnFocus || _currentInputValue.isNotEmpty) {
      _scheduleSearch(immediate: true);
    }
  }

  void handleBlur() {
    _touchCallback?.call();

    if (showHint) {
      _writeInputValue(_committedInputValue);
    }

    if (!editable) {
      if (_selectedItem != null) {
        _committedInputValue = _formatItemForInput(_selectedItem!);
      } else {
        _committedInputValue = '';
      }
      _writeInputValue(_committedInputValue);
    }
  }

  void handleInput(String? value) {
    final nextValue = value ?? '';
    rawSearchTerm = nextValue;
    _committedInputValue = nextValue;

    if (!editable) {
      _selectedItem = null;
      _emitModelValue(null);
    } else {
      _emitModelValue(nextValue);
    }

    _scheduleSearch();
  }

  void handleKeydown(html.Event event) {
    if (event is! html.KeyboardEvent) {
      return;
    }

    if (event.key == 'ArrowDown') {
      event.preventDefault();
      if (!popupOpen) {
        _scheduleSearch(immediate: true);
        return;
      }
      _moveActiveIndex(1);
      return;
    }

    if (event.key == 'ArrowUp') {
      event.preventDefault();
      if (!popupOpen) {
        _scheduleSearch(immediate: true);
        return;
      }
      _moveActiveIndex(-1);
      return;
    }

    if (event.key == 'Enter' || event.key == 'Tab') {
      if (!popupOpen) {
        return;
      }

      final item = activeItem;
      if (item == null) {
        dismissPopup();
        return;
      }

      event.preventDefault();
      _selectResult(item);
      dismissPopup();
      return;
    }

    if (event.key == 'Escape') {
      event.preventDefault();
      dismissPopup();
    }
  }

  void markActive(int index) {
    if (index < 0 || index >= visibleItems.length) {
      return;
    }

    activeIndex = index;
    _showHintIfNeeded();
    _markForCheck();
  }

  void select(LiTypeaheadItem item) {
    _selectResult(item);
    dismissPopup();
  }

  void preventPopupBlur(html.Event event) {
    event.preventDefault();
  }

  LiTypeaheadItem? get activeItem {
    if (activeIndex < 0 || activeIndex >= visibleItems.length) {
      return null;
    }
    return visibleItems[activeIndex];
  }

  String get searchTerm => rawSearchTerm;

  String renderResultLabel(LiTypeaheadItem item) {
    return _formatItemForResult(item);
  }

  String renderResultMarkup(LiTypeaheadItem item) {
    return resultMarkupBuilder?.call(item.instanceObj, rawSearchTerm) ??
        renderResultLabel(item);
  }

  bool get hasStatusRow => loading || _asyncErrorMessage != null;

  String get statusText {
    if (_asyncErrorMessage != null) {
      return _asyncErrorMessage!;
    }
    return loadingText;
  }

  String _formatItemForInput(LiTypeaheadItem item) {
    final formatted = inputFormatter?.call(item.instanceObj);
    if (formatted != null && formatted.isNotEmpty) {
      return formatted;
    }
    return item.text;
  }

  String _formatItemForResult(LiTypeaheadItem item) {
    final formatted = resultFormatter?.call(item.instanceObj);
    if (formatted != null && formatted.isNotEmpty) {
      return formatted;
    }
    return _formatItemForInput(item);
  }

  void _scheduleSearch({bool immediate = false}) {
    _debounceTimer?.cancel();

    if (immediate || debounceMs <= 0) {
      unawaited(_syncVisibleItemsFromTerm(_currentInputValue));
      return;
    }

    _debounceTimer = Timer(
      Duration(milliseconds: debounceMs),
      () => unawaited(_syncVisibleItemsFromTerm(_currentInputValue)),
    );
  }

  Future<void> _syncVisibleItemsFromTerm(
    String term, {
    bool markForCheck = true,
  }) async {
    final normalizedTerm = term.trim();
    final hasEnoughChars =
        normalizedTerm.isNotEmpty && normalizedTerm.length >= minLength;
    final canSearch = hasEnoughChars || (openOnFocus && normalizedTerm.isEmpty);

    if (!canSearch) {
      visibleItems = const <LiTypeaheadItem>[];
      dismissPopup();
      if (markForCheck) {
        _markForCheck();
      }
      return;
    }

    List<LiTypeaheadItem> nextItems;
    if (searchCallback != null) {
      final requestId = ++_searchRequestId;
      loading = true;
      _asyncErrorMessage = null;
      visibleItems = const <LiTypeaheadItem>[];
      popupOpen = showLoadingIndicator;
      activeIndex = -1;
      if (popupOpen) {
        _ensureOverlay();
        _overlay?.startAutoUpdate();
        _bindDocumentListeners();
        _scheduleOverlayUpdate();
      }
      if (markForCheck) {
        _markForCheck();
      }

      try {
        final result = await searchCallback!(normalizedTerm);
        if (_destroyed || requestId != _searchRequestId) {
          return;
        }
        nextItems = _normalizeItems(result);
      } catch (_) {
        if (_destroyed || requestId != _searchRequestId) {
          return;
        }
        loading = false;
        _asyncErrorMessage = errorText;
        popupOpen = true;
        activeIndex = -1;
        if (markForCheck) {
          _ensureOverlay();
          _overlay?.startAutoUpdate();
          _bindDocumentListeners();
          _scheduleOverlayUpdate();
          _markForCheck();
        }
        return;
      }
      loading = false;
      _asyncErrorMessage = null;
    } else {
      nextItems = _filterItems(normalizedTerm);
    }

    if (selectOnExact && nextItems.length == 1) {
      final single = nextItems.first;
      if (_formatItemForInput(single).toLowerCase() ==
          normalizedTerm.toLowerCase()) {
        _selectResult(single);
        dismissPopup();
        return;
      }
    }

    visibleItems = nextItems.take(math.max(1, maxResults)).toList();
    if (visibleItems.isEmpty) {
      dismissPopup();
      if (markForCheck) {
        _markForCheck();
      }
      return;
    }

    popupOpen = true;
    activeIndex = focusFirst ? 0 : -1;
    _ensureOverlay();
    _overlay?.startAutoUpdate();
    _bindDocumentListeners();
    _scheduleOverlayUpdate();
    _showHintIfNeeded();

    if (markForCheck) {
      _markForCheck();
    }
  }

  List<LiTypeaheadItem> _filterItems(String term) {
    if (term.isEmpty) {
      return _allItems.where((item) => !item.disabled).toList();
    }

    return _allItems.where((item) {
      if (item.disabled) {
        return false;
      }

      final resultLabel = _formatItemForResult(item);
      final inputLabel = _formatItemForInput(item);
      return resultLabel.containsIgnoreAccents(term) ||
          inputLabel.containsIgnoreAccents(term) ||
          item.text.containsIgnoreAccents(term);
    }).toList();
  }

  List<LiTypeaheadItem> _normalizeItems(dynamic value) {
    final nextItems = <LiTypeaheadItem>[];
    if (value == null) {
      return nextItems;
    }

    if (value is List<Map<String, dynamic>>) {
      for (final map in value) {
        nextItems.add(
          LiTypeaheadItem(
            text: map[labelKey]?.toString() ?? '',
            value: valueKey != null ? map[valueKey] : map,
            instanceObj: map,
            disabled: disabledKey != null ? map[disabledKey] == true : false,
          ),
        );
      }
      return nextItems;
    }

    if (value is DataFrame) {
      final itemsAsMap = value.itemsAsMap;
      for (var i = 0; i < value.length; i++) {
        final map = itemsAsMap[i];
        nextItems.add(
          LiTypeaheadItem(
            text: map[labelKey]?.toString() ?? '',
            value: valueKey != null ? map[valueKey] : value[i],
            instanceObj: value[i],
            disabled: disabledKey != null ? map[disabledKey] == true : false,
          ),
        );
      }
      return nextItems;
    }

    if (value is List) {
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          nextItems.add(
            LiTypeaheadItem(
              text: item[labelKey]?.toString() ?? '',
              value: valueKey != null ? item[valueKey] : item,
              instanceObj: item,
              disabled: disabledKey != null ? item[disabledKey] == true : false,
            ),
          );
        } else {
          nextItems.add(
            LiTypeaheadItem(
              text: item?.toString() ?? '',
              value: item,
              instanceObj: item,
            ),
          );
        }
      }
      return nextItems;
    }

    throw ArgumentError.value(
      value,
      'dataSource',
      'LiTypeaheadComponent only supports List and DataFrame values.',
    );
  }

  void _selectResult(LiTypeaheadItem item) {
    final event = LiTypeaheadSelectItemEvent<dynamic>(item.instanceObj);
    _selectController.add(event);
    if (event.defaultPrevented) {
      return;
    }

    _selectedItem = item;
    _committedInputValue = _formatItemForInput(item);
    rawSearchTerm = _committedInputValue;
    _writeInputValue(_committedInputValue);
    _emitModelValue(item.value);
    _changeController.add(item.value);
    inputElement?.focus();
    _markForCheck();
  }

  void _moveActiveIndex(int delta) {
    if (visibleItems.isEmpty) {
      return;
    }

    var nextIndex = activeIndex;
    if (nextIndex < 0) {
      nextIndex = delta > 0 ? 0 : visibleItems.length - 1;
    } else {
      nextIndex += delta;
    }

    if (nextIndex < 0) {
      nextIndex = focusFirst ? visibleItems.length - 1 : -1;
    } else if (nextIndex >= visibleItems.length) {
      nextIndex = focusFirst ? 0 : -1;
    }

    activeIndex = nextIndex;
    _showHintIfNeeded();
    _markForCheck();
  }

  void _showHintIfNeeded() {
    if (!showHint) {
      return;
    }

    final input = inputElement;
    final item = activeItem;
    final raw = rawSearchTerm;
    if (input == null || item == null || raw.isEmpty) {
      return;
    }

    final formatted = _formatItemForInput(item);
    if (!formatted.toLowerCase().startsWith(raw.toLowerCase())) {
      _writeInputValue(_committedInputValue);
      return;
    }

    _writeInputValue(formatted);
    input.setSelectionRange(raw.length, formatted.length);
  }

  void _applyDataSource(List<LiTypeaheadItem> nextItems) {
    final selectedValue = _selectedItem?.value;
    _allItems = nextItems;
    _selectedItem = _findItemByValue(selectedValue);

    if (_selectedItem != null) {
      _committedInputValue = _formatItemForInput(_selectedItem!);
      rawSearchTerm = _committedInputValue;
      _writeInputValue(_committedInputValue);
    } else if (_committedInputValue.isEmpty) {
      rawSearchTerm = '';
    }

    if (popupOpen) {
      unawaited(
          _syncVisibleItemsFromTerm(_currentInputValue, markForCheck: false));
    }

    _markForCheck();
  }

  LiTypeaheadItem? _findItemByValue(dynamic value) {
    if (value == null) {
      return null;
    }

    for (final item in _allItems) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }

  void _emitModelValue(dynamic value) {
    _ngModelValueChangeCallback?.call(value);
  }

  String get _currentInputValue => inputElement?.value ?? _committedInputValue;

  void _writeInputValue(String value) {
    _committedInputValue = value;
    if (inputElement != null && inputElement!.value != value) {
      inputElement!.value = value;
    }
  }

  void _ensureOverlay() {
    if (container != 'body') {
      return;
    }

    final reference = inputElement;
    final floating = popupElement;
    if (_overlay != null || reference == null || floating == null) {
      return;
    }

    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: reference,
      floatingElement: floating,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'LiTypeaheadComponent',
        hostZIndex: '10000',
        floatingZIndex: '1056',
      ),
      popperOptions: const PopperOptions(
        placement: 'bottom-start',
        fallbackPlacements: <String>[
          'top-start',
          'bottom-end',
          'top-end',
        ],
        strategy: PopperStrategy.fixed,
        padding: PopperInsets.all(8),
        offset: PopperOffset(mainAxis: 4),
        matchReferenceWidth: true,
      ),
    );
  }

  void _scheduleOverlayUpdate() {
    if (!popupOpen || _overlayRelayoutPending || container != 'body') {
      return;
    }

    _overlayRelayoutPending = true;
    html.window.requestAnimationFrame((_) {
      _overlayRelayoutPending = false;
      if (!popupOpen) {
        return;
      }

      _overlay?.update();
      _syncPopupMaxHeight();
    });
  }

  void _syncPopupMaxHeight() {
    final popup = popupElement;
    final list = resultsListElement;
    final input = inputElement;
    if (popup == null || list == null || input == null) {
      return;
    }

    final viewportHeight = html.window.innerHeight?.toDouble() ?? 900.0;
    final inputRect = input.getBoundingClientRect();
    final popupRect = popup.getBoundingClientRect();
    final opensUpward = popupRect.top < inputRect.top;
    final availableHeight = opensUpward
        ? inputRect.top - 16
        : viewportHeight - inputRect.bottom - 16;
    final nextHeight = math.max(120.0, availableHeight - 8);
    list.style.maxHeight = '${nextHeight.floor()}px';
  }

  void _bindDocumentListeners() {
    _documentClickSubscription ??= html.document.onClick.listen((event) {
      if (!popupOpen) {
        return;
      }

      final target = event.target;
      if (target is! html.Node) {
        dismissPopup();
        return;
      }

      final clickedInput = inputElement?.contains(target) ?? false;
      final clickedPopup = popupElement?.contains(target) ?? false;
      if (!clickedInput && !clickedPopup) {
        dismissPopup();
      }
    });

    _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
      if (!popupOpen || event.key != 'Escape') {
        return;
      }
      dismissPopup();
    });
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription?.cancel();
    _documentKeySubscription = null;
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }
}
