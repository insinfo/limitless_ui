import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:popper/popper.dart';

import '../../core/li_before_open_event.dart';
import '../../core/overlay_positioning.dart';
import '../../directives/li_form_directive.dart';
import '../../exceptions/invalid_argument_exception.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';
import 'li_option.dart';

class CustomSelectItem {
  String text;
  dynamic value;
  bool disabled;
  bool selected = false;
  bool hover = false;
  bool visible = true;
  dynamic instanceObj;

  CustomSelectItem({
    required this.text,
    this.value,
    this.instanceObj,
    this.disabled = false,
  });
}

class LiSelectTriggerContext {
  LiSelectTriggerContext._(this._component);

  final LiSelectComponent _component;

  CustomSelectItem? get selectedItem => _component.currentValue;

  dynamic get selectedValue => _component.currentValue?.value;

  String get selectedLabel => _component.currentValue?.text ?? '';

  String get displayValue =>
      _component.currentValue?.text ?? _component.placeholder;

  String get placeholder => _component.placeholder;

  bool get hasSelection => _component.hasSelection;

  bool get disabled => _component.isDisabled;

  bool get isOpen => _component.dropdownOpen;

  void open() => _component.openDropdown();

  void close() => _component.closeDropdown();

  void toggle() => _component.toggleDropdown();

  void clear([html.Event? event]) => _component.clearSelection(event);
}

@Directive(selector: 'template[liSelectTrigger]')
class LiSelectTriggerDirective {
  LiSelectTriggerDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Component(
  selector: 'li-select',
  changeDetection: ChangeDetectionStrategy.onPush,
  templateUrl: 'li_select.html',
  styleUrls: ['li_select.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiSelectTriggerDirective,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiSelectComponent),
  ],
)
class LiSelectComponent
    implements
        ControlValueAccessor<dynamic>,
        AfterChanges,
        OnInit,
        OnDestroy,
        AfterContentInit {
  final html.Element nativeElement;
  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;

  LiSelectComponent(
    this.nativeElement,
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]) {
    final seq = _nextSequence++;
    listboxId = 'li-select-listbox-$seq';
    _idPrefix = 'li-select-opt-$seq';
  }

  static int _nextSequence = 0;

  PopperAnchoredOverlay? _overlay;
  final StreamController<dynamic> _changeController =
      StreamController<dynamic>();
  final StreamController<dynamic> _modelChangeController =
      StreamController<dynamic>();
  final StreamController<dynamic> _userChangeController =
      StreamController<dynamic>();
  final StreamController<bool> _openChangeController =
      StreamController<bool>.broadcast();

  /// Synchronous so `preventDefault()` runs before the dropdown opens.
  final StreamController<LiBeforeOpenEvent> _beforeOpenController =
      StreamController<LiBeforeOpenEvent>.broadcast(sync: true);
  bool _destroyed = false;
  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;
  StreamSubscription<bool>? _formSubmissionSubscription;
  bool _overlayRelayoutPending = false;
  dynamic _lastWrittenValue;

  dynamic Function(dynamic, {String rawValue})? _ngModelValueChangeCallback;
  TouchFunction _onTouched = () {};
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _autoValidationIssue;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};

  @Input('disabled')
  bool isDisabled = false;

  @Input()
  bool invalid = false;

  @Input()
  bool valid = false;

  @Input()
  bool dataInvalid = false;

  @Input()
  String errorText = '';

  @Input()
  String helperText = '';

  @Input()
  String feedbackClass = '';

  @Input()
  String describedBy = '';

  @Input()
  bool showClearButton = false;

  /// Supported values: `default`, `overlay`, `addon`, `hidden`.
  @Input()
  String triggerIconMode = 'default';

  @Input()
  String triggerIconClass = '';

  @Input()
  String locale = 'pt_BR';

  @Input()
  String size = '';

  @Input()
  List<LiRule> liRules = const <LiRule>[];

  @Input()
  Map<String, String> liMessages = const <String, String>{};

  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  @Input()
  bool validateOnInput = true;

  /// Whether the search input is displayed in the dropdown.
  ///
  /// **CRITICAL — DO NOT set this to `false` by default.**
  /// The inline search box is the primary reason this custom select exists.
  /// Without it, this component offers no advantage over a plain `<select>`.
  /// Removing or hiding it by default will break every consumer that relies
  /// on filtering through long option lists (e.g. Unidades, Órgãos, Bancos).
  @Input()
  bool searchable = true;

  /// Selects the first enabled option when the written model value is `null`.
  ///
  /// The default is `false` so optional fields can keep an explicit empty
  /// state instead of visually selecting the first business option.
  @Input()
  bool autoSelectFirstOption = false;

  @Input()
  bool Function(dynamic optionValue, dynamic modelValue)? compareWith;

  @Output('currentValueChange')
  Stream<dynamic> get onValueChange => _changeController.stream;

  @Output('modelChange')
  Stream<dynamic> get onModelChange => _modelChangeController.stream;

  @Output('userValueChange')
  Stream<dynamic> get onUserValueChange => _userChangeController.stream;

  /// Emits `true` when the dropdown opens and `false` when it closes.
  ///
  /// Only real transitions are emitted, so repeated `openDropdown()` calls on
  /// an already open dropdown stay silent. Nothing is emitted while the
  /// component is being destroyed.
  ///
  /// Useful to defer loading the option list until the user actually opens the
  /// select.
  @Output()
  Stream<bool> get openChange => _openChangeController.stream;

  /// Emitted right before the dropdown opens, while it is still closed.
  ///
  /// Calling `preventDefault()` on the event keeps the dropdown closed and
  /// suppresses the matching [openChange]. Only emitted for a real open, so an
  /// already open dropdown never re-emits it.
  ///
  /// The stream is synchronous: `preventDefault()` has to be called from the
  /// handler itself, not after an `await`.
  @Output()
  Stream<LiBeforeOpenEvent> get beforeOpen => _beforeOpenController.stream;

  @ContentChildren(LiOptionComponent)
  List<LiOptionComponent> childrenSelectOptions = [];

  @ContentChild(LiSelectTriggerDirective)
  LiSelectTriggerDirective? triggerTemplate;

  @ViewChild('dropdownContainer')
  html.Element? dropdownContainerEle;

  @ViewChild('inputSearch')
  html.InputElement? inputSearch;

  @ViewChild('dropdownButton')
  html.Element? dropdownButtonElement;

  int currentIndex = -1;
  CustomSelectItem? currentValue;
  bool dropdownOpen = false;
  late final LiSelectTriggerContext triggerContext =
      LiSelectTriggerContext._(this);

  late final String listboxId;
  late final String _idPrefix;

  String optionId(int index) => '$_idPrefix-$index';

  String? get activeDescendantId {
    if (!dropdownOpen || currentIndex < 0 || currentIndex >= options.length) {
      return null;
    }
    return optionId(currentIndex);
  }

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

  String get effectiveErrorText {
    final externalMessage = errorText.trim();
    if (externalMessage.isNotEmpty) {
      return externalMessage;
    }

    return _autoValidationIssue?.message ?? '';
  }

  bool get showErrorFeedback =>
      effectiveErrorText.trim().isNotEmpty && effectiveInvalid;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String? get resolvedName => name;

  String get searchPlaceholder => _isEnglishLocale ? 'Search' : 'Buscar';

  String get searchAriaLabel =>
      _isEnglishLocale ? 'Search options' : 'Buscar opções';

  String get resolvedClearButtonLabel =>
      _isEnglishLocale ? 'Clear selection' : 'Limpar seleção';

  String get normalizedTriggerIconMode {
    switch (triggerIconMode.trim().toLowerCase()) {
      case 'overlay':
        return 'overlay';
      case 'addon':
        return 'addon';
      case 'hidden':
        return 'hidden';
      default:
        return 'default';
    }
  }

  bool get usesOverlayTriggerIcon => normalizedTriggerIconMode == 'overlay';

  bool get usesAddonTriggerIcon => normalizedTriggerIconMode == 'addon';

  bool get hidesNativeIndicator => normalizedTriggerIconMode != 'default';

  bool get showsTriggerIcon =>
      normalizedTriggerIconMode == 'overlay' ||
      normalizedTriggerIconMode == 'addon';

  bool get hasSelection => currentValue != null;

  bool get showsClearButton => showClearButton && hasSelection;

  String? get selectedDataValue => currentValue?.value?.toString();

  String? optionDataValue(CustomSelectItem option) => option.value?.toString();

  String get resolvedTriggerIconClass {
    final custom = triggerIconClass.trim();
    return custom.isNotEmpty ? custom : 'ph ph-caret-down';
  }

  String get resolvedButtonClass => _joinClasses(<String>[
        'form-select',
        _formSelectSizeClass,
        'dropdown-button',
        hidesNativeIndicator ? 'dropdown-button--no-native-indicator' : '',
        usesOverlayTriggerIcon ? 'dropdown-button--with-overlay-icon' : '',
        showsClearButton ? 'dropdown-button--with-clear' : '',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
      ]);

  String get resolvedInputGroupClass => _joinClasses(<String>[
        'input-group',
        _inputGroupSizeClass,
      ]);

  String get resolvedSearchInputClass => _joinClasses(<String>[
        'form-control',
        _formControlSizeClass,
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  @Input('id')
  String id = 'li_select_1';

  @Input()
  String? name;

  @Input('labelKey')
  String labelKey = 'label';

  @Input('valueKey')
  String? valueKey;

  @Input('disabledKey')
  String? disabledKey;

  List<CustomSelectItem> options = [];

  int get minHeight {
    final visibleOptions = options.length < 5 ? options.length : 5;
    return visibleOptions * 25;
  }

  html.Element get listElement => dropdownContainerEle!.querySelector('ul')!;

  @override
  void ngAfterContentInit() {
    for (final opt in childrenSelectOptions) {
      opt.parent = this;
    }

    // Projected li-option content may not be fully reflected in the DOM text
    // at the exact moment ngAfterContentInit runs. Read it on the next microtask
    // so projected labels are captured correctly.
    Future.microtask(_syncProjectedOptions);
  }

  @override
  void ngAfterChanges() {
    _rebuildValidationConfig();
    _markForCheck();
  }

  @override
  void writeValue(dynamic newVal) {
    _lastWrittenValue = newVal;
    if (newVal == null) {
      currentValue = null;
      if (autoSelectFirstOption) {
        currentValue = options.where((option) => !option.disabled).firstOrNull;
      }
      _runAutoValidation();
      _markForCheck();
      return;
    }

    _selectCurrentValue(newVal);
    _runAutoValidation();
    _markForCheck();
  }

  @override
  void registerOnChange(callback) {
    _ngModelValueChangeCallback = callback;
  }

  @override
  void registerOnTouched(TouchFunction callback) {
    _onTouched = callback;
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    this.isDisabled = isDisabled;
    _markForCheck();
  }

  @Input()
  set dataSource(dynamic ops) {
    final nextOptions = <CustomSelectItem>[];

    if (ops is List<Map<String, dynamic>>) {
      for (final map in ops) {
        nextOptions.add(
          CustomSelectItem(
            value: valueKey != null ? map[valueKey] : map,
            text: map[labelKey],
            instanceObj: map,
            disabled: disabledKey != null ? map[disabledKey] == true : false,
          ),
        );
      }
      _applyDataSource(nextOptions);
      return;
    }

    if (ops is DataFrame) {
      final opAsMap = ops.itemsAsMap;
      for (var i = 0; i < ops.length; i++) {
        final map = opAsMap[i];
        nextOptions.add(
          CustomSelectItem(
            value: valueKey != null ? map[valueKey] : ops[i],
            text: map[labelKey] ?? '',
            instanceObj: ops[i],
            disabled: disabledKey != null ? map[disabledKey] == true : false,
          ),
        );
      }
      _applyDataSource(nextOptions);
      return;
    }

    throw InvalidArgumentException(LiSelectComponent, ops);
  }

  /// Text rendered in the trigger while no option is selected.
  ///
  /// Set it to an empty string, for example `[placeholder]="''"`, when the
  /// empty state should be visually blank.
  @Input()
  String placeholder = 'Selecione';

  @override
  void ngOnInit() {
    _formSubmitted = _formDirective?.submitted ?? false;
    _formSubmissionSubscription =
        _formDirective?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      _runAutoValidation();
      _markForCheck();
    });
    _rebuildValidationConfig();
    if (_lastWrittenValue != null) {
      _selectCurrentValue(_lastWrittenValue);
    } else if (autoSelectFirstOption) {
      currentValue = options.where((option) => !option.disabled).firstOrNull;
    } else {
      currentValue = null;
    }
    _runAutoValidation();
    _markForCheck();
  }

  void _ensureOverlay() {
    final reference = dropdownButtonElement;
    final floating = dropdownContainerEle;

    if (_overlay != null || reference == null || floating == null) {
      return;
    }

    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: reference,
      floatingElement: floating,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'LiSelectComponent',
        hostZIndex: '10000',
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
        offset: const PopperOffset(mainAxis: 8),
        matchReferenceWidth: triggerTemplate == null,
        onLayout: _handleOverlayLayout,
      ),
    );
  }

  /// Emits [beforeOpen] and reports whether the open should go ahead.
  bool _dispatchBeforeOpen() {
    if (_destroyed) {
      return false;
    }

    final event = LiBeforeOpenEvent();
    _beforeOpenController.add(event);
    return !event.defaultPrevented;
  }

  void closeDropdown({bool markForCheck = true}) {
    final wasOpen = dropdownOpen;

    for (final element in dropdownContainerEle!.querySelectorAll('li')) {
      element.classes.remove('dropdown-item-hover');
    }
    currentIndex = -1;
    dropdownOpen = false;
    _overlayRelayoutPending = false;

    for (final option in options) {
      option.visible = true;
    }

    inputSearch?.value = '';
    _overlay?.stopAutoUpdate();
    _unbindDocumentListeners();

    if (wasOpen) {
      _markTouched();
    }

    if (wasOpen) {
      dropdownButtonElement?.focus();
    }

    if (wasOpen && !_destroyed) {
      _openChangeController.add(false);
    }

    if (markForCheck) {
      _markForCheck();
    }
  }

  void openDropdown() {
    final wasOpen = dropdownOpen;

    if (!wasOpen && !_dispatchBeforeOpen()) {
      return;
    }

    if (childrenSelectOptions.isNotEmpty) {
      _syncProjectedOptions(markForCheck: false);
    }

    _ensureOverlay();
    currentIndex = currentValue == null ? -1 : options.indexOf(currentValue!);
    dropdownOpen = true;
    _overlay?.startAutoUpdate();
    _bindDocumentListeners();

    Future.delayed(const Duration(milliseconds: 20), () {
      _overlay?.update();
      if (searchable) {
        inputSearch?.focus();
      }
    });

    if (!wasOpen) {
      _openChangeController.add(true);
    }

    _markForCheck();
  }

  void setSelectedItemByValue(
    dynamic value, {
    bool isCloseDropDown = true,
    bool isCallNgModelChange = true,
    bool isCallCurrentValueChange = true,
  }) {
    _lastWrittenValue = value;

    for (final option in options) {
      if (!_areValuesEqual(option.value, value) || option.disabled) {
        continue;
      }

      currentValue = option;
      _runAutoValidation();

      if (isCloseDropDown && dropdownOpen) {
        closeDropdown();
      }
      if (isCallCurrentValueChange) {
        _changeController.add(currentValue?.value);
        _modelChangeController.add(currentValue?.instanceObj);
      }
      if (isCallNgModelChange && _ngModelValueChangeCallback != null) {
        _ngModelValueChangeCallback!(currentValue?.value);
      }
      _markForCheck();
      return;
    }
  }

  void select(CustomSelectItem selItem) {
    if (selItem.disabled) {
      return;
    }

    final previousValue = currentValue?.value;
    _dirty = true;
    currentValue = selItem;
    _lastWrittenValue = currentValue?.value;
    closeDropdown();
    _changeController.add(currentValue?.value);
    _modelChangeController.add(currentValue?.instanceObj);
    if (!_areOptionalValuesEqual(previousValue, currentValue?.value)) {
      _userChangeController.add(currentValue?.value);
    }
    _ngModelValueChangeCallback?.call(currentValue?.value);
    _markTouched();
    _runAutoValidation();
    _markForCheck();
  }

  void clearSelection([html.Event? event]) {
    event?.stopPropagation();
    if (isDisabled || currentValue == null) {
      return;
    }

    _clearSelectedItem(isUserInteraction: true);
  }

  void clearSelectedItem({
    bool isCallNgModelChange = true,
    bool isCallCurrentValueChange = true,
  }) {
    _clearSelectedItem(
      isCallNgModelChange: isCallNgModelChange,
      isCallCurrentValueChange: isCallCurrentValueChange,
    );
  }

  void toggleDropdown() {
    if (isDisabled) {
      return;
    }

    if (dropdownOpen) {
      closeDropdown();
    } else {
      openDropdown();
    }
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
      toggleDropdown();
    }
  }

  void _highlightOptionFromIndex() {
    if (currentIndex < 0 || currentIndex >= options.length) {
      return;
    }

    final option = options[currentIndex];
    if (option.disabled || !option.visible) {
      return;
    }

    for (var i = 0; i < options.length; i++) {
      options[i].hover = i == currentIndex;
    }

    for (final element in dropdownContainerEle!.querySelectorAll('li')) {
      element.classes.remove('dropdown-item-hover');
    }

    dropdownContainerEle!
        .querySelectorAll('li')[currentIndex]
        .classes
        .add('dropdown-item-hover');
  }

  @HostListener('keydown')
  void handleKeydownEvents(html.Event event) {
    if (event is! html.KeyboardEvent) {
      return;
    }

    if (dropdownOpen) {
      return;
    }

    _handleKeydownEvent(event);
  }

  void _handleKeydownEvent(html.KeyboardEvent event) {
    if (event.code == 'Enter' || event.code == 'NumpadEnter') {
      event.preventDefault();
      if (dropdownOpen) {
        if (currentIndex >= 0 && currentIndex < options.length) {
          select(options[currentIndex]);
        } else {
          closeDropdown();
        }
      } else {
        openDropdown();
      }
      return;
    }

    if (event.code == 'ArrowUp') {
      event.preventDefault();
      _moveCurrentIndex(-1);
      return;
    }

    if (event.code == 'ArrowDown') {
      event.preventDefault();
      _moveCurrentIndex(1);
      return;
    }

    if (event.code == 'Escape') {
      event.preventDefault();
      closeDropdown();
    }
  }

  void _moveCurrentIndex(int direction) {
    if (options.isEmpty) {
      return;
    }

    var nextIndex = currentIndex;
    if (nextIndex < 0) {
      nextIndex = direction > 0 ? 0 : options.length - 1;
    } else {
      nextIndex += direction;
    }

    while (nextIndex >= 0 && nextIndex < options.length) {
      final option = options[nextIndex];
      if (!option.disabled && option.visible) {
        break;
      }
      nextIndex += direction;
    }

    if (nextIndex < 0 || nextIndex >= options.length) {
      return;
    }

    currentIndex = nextIndex;
    _highlightOptionFromIndex();
  }

  void searchHandle(String? searchString) {
    if (searchString != null && searchString.trim().isNotEmpty) {
      for (final option in options) {
        if (option.text.containsIgnoreAccents(searchString) ||
            option.value.toString() == searchString) {
          option.visible = true;
        } else {
          option.visible = false;
        }
      }
      _markForCheck();
      if (dropdownOpen) {
        _scheduleOverlayUpdate();
      }
      return;
    }

    for (final option in options) {
      option.visible = true;
    }
    _markForCheck();
    if (dropdownOpen) {
      _scheduleOverlayUpdate();
    }
  }

  @override
  void ngOnDestroy() {
    _destroyed = true;
    _unbindDocumentListeners();
    closeDropdown(markForCheck: false);
    _overlay?.dispose();
    _formSubmissionSubscription?.cancel();
    _changeController.close();
    _modelChangeController.close();
    _userChangeController.close();
    _openChangeController.close();
    _beforeOpenController.close();
  }

  void _handleOverlayLayout(PopperLayout layout) {
    _normalizeOverlayVerticalPosition(layout);

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
    // Keep overlay sizing based on the viewport and trigger geometry only.
    // Measuring the rendered dropdown here would feed Popper's auto-update
    // loop and can cause layout thrashing in the browser.
    const chromeHeight = 60.0;
    final availableListHeight = math.max(
      50.0,
      availablePanelHeight - chromeHeight,
    );
    final desiredMaxHeight = '${availableListHeight.floor()}px';

    if (listElement.style.maxHeight != desiredMaxHeight) {
      listElement.style.maxHeight = desiredMaxHeight;
    }
  }

  void _normalizeOverlayVerticalPosition(PopperLayout layout) {
    normalizeOverlayVerticalPosition(
      floatingElement: dropdownContainerEle,
      layout: layout,
    );
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
      final clickedPanel = dropdownContainerEle?.contains(target) ?? false;
      if (!clickedTrigger && !clickedPanel) {
        closeDropdown();
      }
    });

    _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
      if (!dropdownOpen) {
        return;
      }

      final target = event.target;
      final isInsideOverlay = target is html.Node &&
          ((dropdownButtonElement?.contains(target) ?? false) ||
              (dropdownContainerEle?.contains(target) ?? false));

      final isNavigationKey = event.key == 'ArrowUp' ||
          event.key == 'ArrowDown' ||
          event.key == 'Enter';

      if (event.key == 'Escape') {
        _handleKeydownEvent(event);
      } else if (isInsideOverlay && isNavigationKey) {
        _handleKeydownEvent(event);
      }
    });
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription?.cancel();
    _documentKeySubscription = null;
  }

  void _applyDataSource(List<CustomSelectItem> nextOptions) {
    // Consumers often bind dataSource from parent components. If the parent
    // rebuilds an equivalent list on every change detection pass, blindly
    // replacing options and calling markForCheck() here creates a render loop.
    // Ignore semantically identical inputs and preserve the current selection.
    if (_sameOptions(options, nextOptions)) {
      return;
    }

    final currentSelectedValue = _lastWrittenValue ?? currentValue?.value;
    options = nextOptions;
    _selectCurrentValueOrFirstOption(currentSelectedValue);
    _runAutoValidation();
    _markForCheck();
  }

  void _syncProjectedOptions({bool markForCheck = true}) {
    if (childrenSelectOptions.isEmpty) {
      return;
    }

    final nextOptions = <CustomSelectItem>[];
    for (final opt in childrenSelectOptions) {
      nextOptions.add(
        CustomSelectItem(
          value: opt.value,
          text: opt.text,
          instanceObj: opt.value,
        ),
      );
    }

    final didChange = !_sameOptions(options, nextOptions);
    if (!didChange) {
      return;
    }

    final currentSelectedValue = _lastWrittenValue ?? currentValue?.value;
    options = nextOptions;
    _selectCurrentValueOrFirstOption(currentSelectedValue);
    _runAutoValidation();

    if (markForCheck) {
      _markForCheck();
    }
  }

  bool _sameOptions(
    List<CustomSelectItem> currentOptions,
    List<CustomSelectItem> nextOptions,
  ) {
    if (identical(currentOptions, nextOptions)) {
      return true;
    }

    if (currentOptions.length != nextOptions.length) {
      return false;
    }

    for (var i = 0; i < currentOptions.length; i++) {
      final current = currentOptions[i];
      final next = nextOptions[i];
      if (current.text != next.text ||
          current.value != next.value ||
          current.disabled != next.disabled) {
        return false;
      }
    }

    return true;
  }

  void _selectCurrentValue(dynamic value) {
    currentValue = null;
    if (value == null) {
      return;
    }

    for (final option in options) {
      if (_areValuesEqual(option.value, value)) {
        currentValue = option;
        return;
      }
    }
  }

  void _selectCurrentValueOrFirstOption(dynamic value) {
    _selectCurrentValue(value);
    if (currentValue == null && value == null && autoSelectFirstOption) {
      currentValue = options.where((option) => !option.disabled).firstOrNull;
    }
  }

  void _clearSelectedItem({
    bool isCallNgModelChange = true,
    bool isCallCurrentValueChange = true,
    bool isUserInteraction = false,
  }) {
    final hadSelection = currentValue != null;
    currentValue = null;
    _lastWrittenValue = null;

    if (isUserInteraction) {
      _dirty = true;
    }

    if (isCallCurrentValueChange) {
      _changeController.add(null);
      _modelChangeController.add(null);
    }
    if (isUserInteraction && hadSelection) {
      _userChangeController.add(null);
    }
    if (isCallNgModelChange && _ngModelValueChangeCallback != null) {
      _ngModelValueChangeCallback!(null);
    }
    if (isUserInteraction) {
      _markTouched();
    }
    _runAutoValidation();
    _markForCheck();
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  void _rebuildValidationConfig() {
    _effectiveRules = List<LiRule>.unmodifiable(<LiRule>[
      ...liRules,
    ]);
    _effectiveMessages = Map<String, String>.unmodifiable(<String, String>{
      ...liMessages,
    });
    _runAutoValidation();
  }

  void _runAutoValidation() {
    if (_effectiveRules.isEmpty) {
      _autoValidationIssue = null;
      return;
    }

    _autoValidationIssue = liValidateValue(
      value: currentValue?.value,
      rules: _effectiveRules,
      context: LiRuleContext(
        fieldName: id.trim().isEmpty ? null : id.trim(),
        messages: _effectiveMessages,
        locale: locale,
      ),
    );
  }

  void _markTouched() {
    if (_touched) {
      _onTouched();
      return;
    }
    _touched = true;
    _onTouched();
    _runAutoValidation();
  }

  bool get _shouldShowValidation => liShouldShowValidation(
        mode: liValidationMode,
        touched: _touched,
        dirty: _dirty,
        submitted: _formSubmitted,
      );

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

  String get _formSelectSizeClass {
    switch (_normalizedSize) {
      case 'sm':
        return 'form-select-sm';
      case 'lg':
        return 'form-select-lg';
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

  bool _areValuesEqual(dynamic optionValue, dynamic modelValue) {
    final customCompare = compareWith;
    if (customCompare != null) {
      return customCompare(optionValue, modelValue);
    }
    return optionValue == modelValue;
  }

  bool _areOptionalValuesEqual(dynamic optionValue, dynamic modelValue) {
    if (optionValue == null || modelValue == null) {
      return optionValue == modelValue;
    }
    return _areValuesEqual(optionValue, modelValue);
  }
}
