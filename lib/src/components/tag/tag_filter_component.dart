import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;
import 'package:popper/popper.dart';

import '../../core/overlay_positioning.dart';
import '../../directives/css_style_directive.dart';
import 'tag_models.dart';

class LiTagFilterOptionView {
  LiTagFilterOptionView({
    required this.label,
    required this.value,
    required this.color,
    required this.model,
    required this.sourceMap,
    required this.badgeStyle,
    required this.swatchStyle,
    this.disabled = false,
  });

  final String label;
  final dynamic value;
  final String color;
  final dynamic model;
  final Map<String, dynamic> sourceMap;
  final String badgeStyle;
  final String swatchStyle;
  bool disabled;
  bool selected = false;
  bool visible = true;
}

@Component(
  selector: 'li-tag-filter',
  templateUrl: 'tag_filter_component.html',
  styleUrls: ['tag_filter_component.css'],
  directives: [coreDirectives, CssStyleDirective],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiTagFilterComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTagFilterComponent
    implements ControlValueAccessor<List<dynamic>>, OnDestroy {
  LiTagFilterComponent(this.nativeElement, this._changeDetectorRef) {
    final sequence = _nextSequence++;
    listboxId = 'li-tag-filter-listbox-$sequence';
    _optionIdPrefix = 'li-tag-filter-option-$sequence';
  }

  static int _nextSequence = 0;

  final html.Element nativeElement;
  final ChangeDetectorRef _changeDetectorRef;

  final StreamController<List<dynamic>> _valueChangeController =
      StreamController<List<dynamic>>.broadcast();
  final StreamController<List<dynamic>> _modelChangeController =
      StreamController<List<dynamic>>.broadcast();
  final StreamController<LiTagSelectionChange> _selectionChangeController =
      StreamController<LiTagSelectionChange>.broadcast();
  final StreamController<void> _reloadRequestController =
      StreamController<void>.broadcast();

  PopperAnchoredOverlay? _overlay;
  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;
  ChangeFunction<List<dynamic>>? _onChange;
  TouchFunction _onTouched = () {};
  bool _touched = false;
  bool _overlayRelayoutPending = false;
  List<dynamic> _boundValues = <dynamic>[];
  String _searchQuery = '';
  late final String listboxId;
  late final String _optionIdPrefix;

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  String placeholder = 'Filtrar por etiquetas';

  @Input()
  String searchPlaceholder = '';

  @Input()
  String emptyText = '';

  @Input()
  String locale = 'pt_BR';

  @Input()
  String labelKey = 'label';

  @Input()
  String valueKey = 'value';

  @Input()
  String colorKey = 'color';

  @Input()
  String disabledKey = 'disabled';

  @Input()
  bool searchable = true;

  @Input()
  bool showClearButton = true;

  @Input()
  bool showFooterClearAction = true;

  @Input()
  bool showReloadButton = false;

  @Input()
  bool closeOnSelect = false;

  @Input()
  bool showInlineRemove = true;

  @Input()
  bool wrapSelectedBadges = true;

  @Input()
  bool Function(dynamic optionValue, dynamic modelValue)? compareWith;

  @Input()
  set dataSource(dynamic value) {
    _applyDataSource(_buildOptions(value));
  }

  @Output('currentValueChange')
  Stream<List<dynamic>> get onValueChange => _valueChangeController.stream;

  @Output('modelChange')
  Stream<List<dynamic>> get onModelChange => _modelChangeController.stream;

  @Output('selectionChange')
  Stream<LiTagSelectionChange> get onSelectionChange =>
      _selectionChangeController.stream;

  @Output('reloadRequest')
  Stream<void> get onReloadRequest => _reloadRequestController.stream;

  @ViewChild('dropdownButton')
  html.Element? dropdownButtonElement;

  @ViewChild('dropdownContainer')
  html.Element? dropdownContainerElement;

  @ViewChild('searchInput')
  html.InputElement? searchInputElement;

  List<LiTagFilterOptionView> options = <LiTagFilterOptionView>[];
  List<LiTagFilterOptionView> selectedOptions = <LiTagFilterOptionView>[];
  List<dynamic> _selectedValues = <dynamic>[];
  List<dynamic> _selectedModels = <dynamic>[];
  int visibleOptionCount = 0;
  bool dropdownOpen = false;

  bool get hasSelection => selectedOptions.isNotEmpty;

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  String get resolvedPlaceholder {
    final value = placeholder.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Filter tags' : 'Filtrar etiquetas';
  }

  String get resolvedSearchPlaceholder {
    final value = searchPlaceholder.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'Search tags...' : 'Buscar etiquetas...';
  }

  String get resolvedEmptyText {
    final value = emptyText.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return _isEnglishLocale ? 'No tags found.' : 'Nenhuma etiqueta encontrada.';
  }

  String get resolvedClearButtonLabel =>
      _isEnglishLocale ? 'Clear selection' : 'Limpar seleção';

  String get resolvedReloadButtonLabel =>
      _isEnglishLocale ? 'Reload tags' : 'Recarregar etiquetas';

  String get resolvedButtonClass => _joinClasses(<String>[
        'form-select',
        'li-tag-filter__button',
        wrapSelectedBadges ? 'li-tag-filter__button--wrapped' : '',
        hasSelection && showClearButton
            ? 'li-tag-filter__button--with-clear'
            : '',
      ]);

  String optionId(int index) => '$_optionIdPrefix-$index';

  @override
  void writeValue(List<dynamic>? value) {
    _boundValues = List<dynamic>.from(value ?? const <dynamic>[]);
    _applySelection(_boundValues, emit: false, markForCheck: true);
  }

  @override
  void registerOnChange(ChangeFunction<List<dynamic>> callback) {
    _onChange = callback;
  }

  @override
  void registerOnTouched(TouchFunction callback) {
    _onTouched = callback;
  }

  @override
  void onDisabledChanged(bool state) {
    isDisabled = state;
    _markForCheck();
  }

  void toggleDropdown() {
    if (isDisabled) {
      return;
    }

    if (dropdownOpen) {
      closeDropdown(restoreFocus: true);
      return;
    }

    openDropdown();
  }

  void openDropdown() {
    if (isDisabled || dropdownOpen) {
      return;
    }

    _ensureOverlay();
    _bindDocumentListeners();
    dropdownOpen = true;
    _overlay?.startAutoUpdate();
    Future<void>.delayed(const Duration(milliseconds: 20), () {
      _overlay?.update();
      if (searchable) {
        searchInputElement?.focus();
      }
    });
    _markForCheck();
  }

  void closeDropdown({bool restoreFocus = false}) {
    if (!dropdownOpen) {
      return;
    }

    dropdownOpen = false;
    _overlayRelayoutPending = false;
    _overlay?.stopAutoUpdate();
    _unbindDocumentListeners();
    _resetSearch(markForCheck: false);
    _markTouched();

    if (restoreFocus) {
      dropdownButtonElement?.focus();
    }

    _markForCheck();
  }

  void onSearchInput(String? value) {
    _searchQuery = value?.trim() ?? '';
    _applySearchQuery(_searchQuery, markForCheck: true);
  }

  void toggleOptionFromUi(LiTagFilterOptionView option, html.Event event) {
    event.preventDefault();
    event.stopPropagation();
    if (isDisabled || option.disabled) {
      return;
    }

    option.selected = !option.selected;
    _rebuildSelectionState(emit: true);
    if (closeOnSelect) {
      closeDropdown();
    }
  }

  void removeSelection(LiTagFilterOptionView option, html.Event event) {
    event.preventDefault();
    event.stopPropagation();
    if (isDisabled || option.disabled) {
      return;
    }

    option.selected = false;
    _rebuildSelectionState(emit: true);
  }

  void clearSelectionFromUi(html.Event event) {
    event.preventDefault();
    event.stopPropagation();
    reset();
    dropdownButtonElement?.focus();
  }

  void requestReload(html.Event event) {
    event.preventDefault();
    event.stopPropagation();
    if (isDisabled) {
      return;
    }

    _reloadRequestController.add(null);
  }

  void reset() {
    for (final option in options) {
      option.selected = false;
    }
    _boundValues = <dynamic>[];
    _rebuildSelectionState(emit: true);
  }

  @override
  void ngOnDestroy() {
    _unbindDocumentListeners();
    closeDropdown();
    _overlay?.dispose();
    _valueChangeController.close();
    _modelChangeController.close();
    _selectionChangeController.close();
    _reloadRequestController.close();
  }

  void _applyDataSource(List<LiTagFilterOptionView> nextOptions) {
    options = nextOptions;
    _applySelection(_boundValues, emit: false, markForCheck: false);
    _applySearchQuery(_searchQuery, markForCheck: false);
    _markForCheck();
  }

  List<LiTagFilterOptionView> _buildOptions(dynamic source) {
    final nextOptions = <LiTagFilterOptionView>[];

    if (source == null) {
      return nextOptions;
    }

    if (source is DataFrame) {
      final itemsAsMap = source.itemsAsMap;
      for (var index = 0; index < source.length; index++) {
        final model = source[index];
        final map = _coerceMap(itemsAsMap[index]);
        nextOptions.add(_buildOption(model, map));
      }
      return nextOptions;
    }

    if (source is List) {
      for (final item in source) {
        if (item is Map) {
          nextOptions.add(_buildOption(item, _coerceMap(item)));
          continue;
        }

        nextOptions.add(
          _buildOption(
            item,
            <String, dynamic>{
              labelKey: item?.toString() ?? '',
              valueKey: item,
              colorKey: liDefaultTagColor,
            },
          ),
        );
      }
    }

    return nextOptions;
  }

  LiTagFilterOptionView _buildOption(
    dynamic model,
    Map<String, dynamic> sourceMap,
  ) {
    final rawLabel = sourceMap[labelKey] ?? model;
    final rawValue =
        sourceMap.containsKey(valueKey) ? sourceMap[valueKey] : model;
    final color = _normalizeColor(sourceMap[colorKey]?.toString());
    final disabled = _parseBool(sourceMap[disabledKey]);
    final label = rawLabel?.toString().trim() ?? '';

    return LiTagFilterOptionView(
      label: label.isNotEmpty ? label : rawValue?.toString() ?? '',
      value: rawValue,
      color: color,
      model: model,
      sourceMap: sourceMap,
      badgeStyle: _buildBadgeStyle(color),
      swatchStyle: _buildSwatchStyle(color),
      disabled: disabled,
    );
  }

  Map<String, dynamic> _coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    return <String, dynamic>{};
  }

  void _applySelection(
    List<dynamic> selectedValues, {
    required bool emit,
    required bool markForCheck,
  }) {
    for (final option in options) {
      option.selected = selectedValues.any(
        (dynamic selectedValue) => _areValuesEqual(option.value, selectedValue),
      );
    }
    _rebuildSelectionState(emit: emit, markForCheck: markForCheck);
  }

  void _rebuildSelectionState({
    required bool emit,
    bool markForCheck = true,
  }) {
    final nextSelectedOptions = <LiTagFilterOptionView>[];
    final nextSelectedValues = <dynamic>[];
    final nextSelectedModels = <dynamic>[];

    for (final option in options) {
      if (!option.selected) {
        continue;
      }
      nextSelectedOptions.add(option);
      nextSelectedValues.add(option.value);
      nextSelectedModels.add(option.model);
    }

    selectedOptions = nextSelectedOptions;
    _selectedValues = nextSelectedValues;
    _selectedModels = nextSelectedModels;
    _boundValues = List<dynamic>.from(nextSelectedValues);

    if (emit) {
      final emittedValues = List<dynamic>.unmodifiable(_selectedValues);
      final emittedModels = List<dynamic>.unmodifiable(_selectedModels);
      _valueChangeController.add(emittedValues);
      _modelChangeController.add(emittedModels);
      _selectionChangeController.add(
        LiTagSelectionChange(values: emittedValues, models: emittedModels),
      );
      _onChange?.call(emittedValues);
      _markTouched();
    }

    if (markForCheck) {
      _markForCheck();
      if (dropdownOpen) {
        _scheduleOverlayUpdate();
      }
    }
  }

  void _applySearchQuery(String query, {required bool markForCheck}) {
    if (query.isEmpty) {
      for (final option in options) {
        option.visible = true;
      }
    } else {
      for (final option in options) {
        option.visible = option.label.containsIgnoreAccents(query) ||
            (option.value?.toString() ?? '').containsIgnoreAccents(query);
      }
    }

    visibleOptionCount = 0;
    for (final option in options) {
      if (option.visible) {
        visibleOptionCount++;
      }
    }

    if (markForCheck) {
      _markForCheck();
      if (dropdownOpen) {
        _scheduleOverlayUpdate();
      }
    }
  }

  void _resetSearch({required bool markForCheck}) {
    _searchQuery = '';
    searchInputElement?.value = '';
    _applySearchQuery('', markForCheck: markForCheck);
  }

  bool _areValuesEqual(dynamic optionValue, dynamic modelValue) {
    final comparator = compareWith;
    if (comparator != null) {
      return comparator(optionValue, modelValue);
    }
    return optionValue == modelValue;
  }

  bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  String _normalizeColor(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return liDefaultTagColor;
    }
    if (trimmed.startsWith('#') || trimmed.startsWith('rgb')) {
      return trimmed;
    }
    return '#$trimmed';
  }

  String _buildBadgeStyle(String color) {
    final textColor = _resolveContrastColor(color);
    return 'background-color: $color; color: $textColor;';
  }

  String _buildSwatchStyle(String color) {
    final borderColor = 'color-mix(in srgb, $color 72%, #111827 28%)';
    return 'background-color: $color; box-shadow: inset 0 0 0 1px $borderColor;';
  }

  String _resolveContrastColor(String color) {
    final hex = color.trim();
    if (!hex.startsWith('#')) {
      return '#ffffff';
    }

    final normalized = hex.length == 4
        ? '#${hex[1]}${hex[1]}${hex[2]}${hex[2]}${hex[3]}${hex[3]}'
        : hex;
    if (normalized.length != 7) {
      return '#ffffff';
    }

    final red = int.tryParse(normalized.substring(1, 3), radix: 16);
    final green = int.tryParse(normalized.substring(3, 5), radix: 16);
    final blue = int.tryParse(normalized.substring(5, 7), radix: 16);
    if (red == null || green == null || blue == null) {
      return '#ffffff';
    }

    final luminance = ((red * 299) + (green * 587) + (blue * 114)) / 1000;
    return luminance >= 160 ? '#111827' : '#ffffff';
  }

  void _ensureOverlay() {
    final reference = dropdownButtonElement;
    final floating = dropdownContainerElement;
    if (_overlay != null || reference == null || floating == null) {
      return;
    }

    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: reference,
      floatingElement: floating,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'LiTagFilterComponent',
        hostZIndex: '1000',
        floatingZIndex: '1000',
      ),
      popperOptions: PopperOptions(
        placement: 'bottom-start',
        fallbackPlacements: const <String>[
          'top-start',
          'bottom-end',
          'top-end',
        ],
        strategy: PopperStrategy.fixed,
        padding: const PopperInsets.all(8),
        offset: const PopperOffset(mainAxis: 4),
        matchReferenceWidth: true,
        onLayout: _handleOverlayLayout,
      ),
    );
  }

  void _handleOverlayLayout(PopperLayout layout) {
    normalizeOverlayVerticalPosition(
      floatingElement: dropdownContainerElement,
      layout: layout,
    );

    final listElement =
        dropdownContainerElement?.querySelector('.li-tag-filter__list');
    if (listElement == null) {
      return;
    }

    final basePlacement = layout.placement.split('-').first;
    final clippingTop = layout.clippingRect.top.toDouble();
    final clippingBottom =
        clippingTop + layout.clippingRect.height.toDouble() - 8;
    final referenceTop = layout.referenceRect.top.toDouble();
    final referenceBottom =
        referenceTop + layout.referenceRect.height.toDouble();
    final availablePanelHeight = basePlacement == 'top'
        ? referenceTop - clippingTop - 8
        : clippingBottom - referenceBottom;
    const chromeHeight = 92.0;
    final availableListHeight =
        math.max(64.0, availablePanelHeight - chromeHeight);
    final desiredMaxHeight = '${availableListHeight.floor()}px';

    if (listElement.style.maxHeight != desiredMaxHeight) {
      listElement.style.maxHeight = desiredMaxHeight;
    }
  }

  void _bindDocumentListeners() {
    _documentClickSubscription ??= html.document.onClick.listen((event) {
      if (!dropdownOpen) {
        return;
      }

      final target = event.target;
      if (target is! html.Node) {
        closeDropdown();
        return;
      }

      final clickedTrigger = dropdownButtonElement?.contains(target) ?? false;
      final clickedPanel = dropdownContainerElement?.contains(target) ?? false;
      if (!clickedTrigger && !clickedPanel) {
        closeDropdown();
      }
    });

    _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
      if (!dropdownOpen) {
        return;
      }

      if (event.key == 'Escape') {
        event.preventDefault();
        closeDropdown(restoreFocus: true);
      }
    });
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription?.cancel();
    _documentKeySubscription = null;
  }

  void _scheduleOverlayUpdate() {
    if (_overlayRelayoutPending || !dropdownOpen) {
      return;
    }

    _overlayRelayoutPending = true;
    html.window.requestAnimationFrame((_) {
      _overlayRelayoutPending = false;
      if (!dropdownOpen) {
        return;
      }
      _overlay?.update();
    });
  }

  void _markTouched() {
    if (_touched) {
      return;
    }
    _touched = true;
    _onTouched();
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  String _joinClasses(List<String> classes) {
    return classes.where((String value) => value.trim().isNotEmpty).join(' ');
  }
}
