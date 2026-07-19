import 'dart:js_interop';
import 'dart:async';
import 'package:limitless_ui/web_compat.dart' as html;
import 'dart:math' as math;

import 'package:essential_core/essential_core.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:popper/popper.dart';

import '../../core/li_before_open_event.dart';
import '../../core/overlay_positioning.dart';
import '../../directives/click_outside.dart';
import '../../directives/li_form_directive.dart';
import '../../exceptions/invalid_argument_exception.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';
import 'li_multi_option.dart';

class CustomMultiSelectItem {
  String text;
  dynamic value;
  bool selected = false;
  bool hover = false;
  bool visible = true;
  //Map<String, dynamic>? instanceMap;
  dynamic instanceObj;
  CustomMultiSelectItem(
      {required this.text,
      this.value,
      // this.selected = false,
      // this.hover = false,
      // this.instanceMap,
      this.instanceObj});
}

class LiMultiSelectTriggerContext {
  LiMultiSelectTriggerContext._(this._component);

  final LiMultiSelectComponent _component;
  int? _selectionSignature;
  List<dynamic> _selectedValues = const <dynamic>[];
  List<dynamic> _selectedModels = const <dynamic>[];
  List<String> _selectedLabels = const <String>[];

  List<dynamic> get selectedValues {
    _ensureSelectionCache();
    return _selectedValues;
  }

  List<dynamic> get selectedModels {
    _ensureSelectionCache();
    return _selectedModels;
  }

  List<String> get selectedLabels {
    _ensureSelectionCache();
    return _selectedLabels;
  }

  String get displayValue {
    _ensureSelectionCache();
    return _selectedLabels.isEmpty
        ? _component.placeholder
        : _selectedLabels.join(', ');
  }

  String get placeholder => _component.placeholder;

  bool get hasSelection => _component.hasSelection;

  bool get disabled => _component.isDisabled;

  bool get isOpen => _component.dropdownOpen;

  void open() => _component.openDropdown();

  void close() => _component.closeDropdown(restoreFocus: true);

  void toggle() => _component.toggleDropdown();

  void clear([html.Event? event]) => _component.clearFromTriggerTemplate(event);

  void _ensureSelectionCache() {
    final signature = _currentSelectionSignature();
    if (_selectionSignature == signature) {
      return;
    }

    final values = <dynamic>[];
    final models = <dynamic>[];
    final labels = <String>[];
    for (final option in _component.options) {
      if (!option.selected) {
        continue;
      }
      values.add(option.value);
      models.add(option.instanceObj);
      labels.add(option.text);
    }

    _selectionSignature = signature;
    _selectedValues = List<dynamic>.unmodifiable(values);
    _selectedModels = List<dynamic>.unmodifiable(models);
    _selectedLabels = List<String>.unmodifiable(labels);
  }

  int _currentSelectionSignature() {
    var hash = _component.options.length;
    for (var index = 0; index < _component.options.length; index++) {
      final option = _component.options[index];
      if (!option.selected) {
        continue;
      }
      hash = Object.hash(
        hash,
        index,
        option.text,
        identityHashCode(option.value),
        identityHashCode(option.instanceObj),
      );
    }
    return hash;
  }
}

@Directive(selector: 'template[liMultiSelectTrigger]')
class LiMultiSelectTriggerDirective {
  LiMultiSelectTriggerDirective(this.templateRef);

  final TemplateRef templateRef;
}

/// Example:
/// `<li-multi-select [dataSource]="dropdownOptions" [fields]="{'text': 'name', 'value': 'value'}" (currentValueChange)="dropdownValueChanged($event)"></li-multi-select>`
@Component(
  selector: 'li-multi-select',
  templateUrl: 'li_multi_select.html',
  styleUrls: ['li_multi_select.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiClickOutsideDirective,
    LiMultiSelectTriggerDirective,
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiMultiSelectComponent),
  ],
)
class LiMultiSelectComponent
    implements
        ControlValueAccessor<dynamic>,
        AfterChanges,
        OnInit,
        OnDestroy,
        AfterContentInit {
  final html.Element nativeElement;
  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  PopperAnchoredOverlay? _overlay;

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

  @Input()
  bool showClearButton = true;

  @Input()
  String clearButtonLabel = '';

  @Input()
  String triggerIconMode = 'default';

  @Input()
  String triggerIconClass = '';

  @Input()
  bool searchable = true;

  @Input()
  bool Function(dynamic optionValue, dynamic modelValue)? compareWith;

  LiMultiSelectComponent(
    this.nativeElement,
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]) {
    final seq = _nextSequence++;
    listboxId = 'li-multi-select-listbox-$seq';
    _idPrefix = 'li-multi-select-opt-$seq';
  }

  static int _nextSequence = 0;
  late final String listboxId;
  late final String _idPrefix;
  TouchFunction _onTouched = () {};
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _autoValidationIssue;
  StreamSubscription<bool>? _formSubmissionSubscription;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};

  /// Last value written by the form model. `writeValue` can run before the
  /// options exist (projected `li-multi-option` children are only readable
  /// after `ngAfterContentInit`, and `dataSource` may resolve asynchronously),
  /// so the value is retained here and reapplied once options arrive.
  List<dynamic>? _lastWrittenValues;

  String optionId(int index) => '$_idPrefix-$index';

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

  String get resolvedClearButtonLabel => clearButtonLabel.trim().isNotEmpty
      ? clearButtonLabel.trim()
      : (_isEnglishLocale ? 'Clear selection' : 'Limpar seleção');

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

  String get selectedDataValue => selectedValues.join(',');

  String? optionDataValue(CustomMultiSelectItem option) =>
      option.value?.toString();

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
        showClearButton && hasSelection ? 'dropdown-button--with-clear' : '',
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

  final StreamController<dynamic> _changeController =
      StreamController<dynamic>();
  final StreamController<List<dynamic>> _modelChangeController =
      StreamController<List<dynamic>>();
  final StreamController<dynamic> _userChangeController =
      StreamController<dynamic>();
  final StreamController<bool> _openChangeController =
      StreamController<bool>.broadcast();

  /// Synchronous so `preventDefault()` runs before the dropdown opens.
  final StreamController<LiBeforeOpenEvent> _beforeOpenController =
      StreamController<LiBeforeOpenEvent>.broadcast(sync: true);
  bool _destroyed = false;
  bool _overlayRelayoutPending = false;

  @Output('currentValueChange')
  Stream<dynamic> get onValueChange => _changeController.stream;

  @Output('modelChange')
  Stream<List<dynamic>> get onModelChange => _modelChangeController.stream;

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

  @ContentChildren(LiMultiOptionComponent)
  List<LiMultiOptionComponent> childrenSelectOptions = [];

  @ContentChild(LiMultiSelectTriggerDirective)
  LiMultiSelectTriggerDirective? triggerTemplate;

  @override
  void ngAfterContentInit() {
    for (final opt in childrenSelectOptions) {
      opt.parent = this;
    }

    // Projected li-multi-option labels are safer to read after the current
    // rendering microtask, otherwise empty labels can be captured.
    Future.microtask(_syncProjectedOptions);
  }

  @override
  void ngAfterChanges() {
    _rebuildValidationConfig();
    _markForCheck();
  }

  @override
  void writeValue(dynamic newVal) {
    _lastWrittenValues =
        newVal is List ? List<dynamic>.from(newVal) : const <dynamic>[];
    _applySelectedValues(_lastWrittenValues!);
    _runAutoValidation();
    _markForCheck();
  }

  void _applySelectedValues(List<dynamic> values) {
    for (final option in options) {
      option.selected = values.any(
        (value) => _areValuesEqual(option.value, value),
      );
    }
  }

  dynamic Function(dynamic, {String rawValue})? _callback;

  @override
  void registerOnChange(callback) {
    _callback = callback;
  }

  // optionally you can implement the rest interface methods
  @override
  void registerOnTouched(TouchFunction callback) {
    _onTouched = callback;
  }

  @override
  void onDisabledChanged(bool state) {
    isDisabled = state;
    _markForCheck();
  }

  @ViewChild('dropdownContainer')
  html.Element? dropdownContainerEle;

  @ViewChild('inputSearch')
  html.InputElement? inputSearch;

  @ViewChild('dropdownButton')
  html.Element? dropdownButtonElement;

  List<dynamic> get selectedValues =>
      options.where((opt) => opt.selected).map((e) => e.value).toList();

  List<dynamic> get selectedModels =>
      options.where((opt) => opt.selected).map((e) => e.instanceObj).toList();

  List<String> get selectedLabels =>
      options.where((opt) => opt.selected).map((e) => e.text).toList();

  bool get hasSelection => options.any((option) => option.selected);

  bool dropdownOpen = false;
  late final LiMultiSelectTriggerContext triggerContext =
      LiMultiSelectTriggerContext._(this);

  @Input()
  String? name;

  /// define de key used get label to diplay from data source options
  @Input('labelKey')
  String labelKey = 'label';

  @Input('valueKey')
  String? valueKey;

  List<CustomMultiSelectItem> options = [];

  int get minHeight {
    var mh = options.length < 5 ? options.length * 25 : 5 * 25;
    return mh;
  }

  html.Element get listElement => dropdownContainerEle!.querySelector('ul')!;

  /// dataSource
  @Input()
  set dataSource(dynamic ops) {
    final nextOptions = <CustomMultiSelectItem>[];
    if (ops is List<Map<String, dynamic>>) {
      for (final map in ops) {
        nextOptions.add(
          CustomMultiSelectItem(
            value: valueKey != null ? map[valueKey] : map,
            text: map[labelKey],
            instanceObj: map,
          ),
        );
      }
      _applyDataSource(nextOptions);
    } else if (ops is DataFrame) {
      var opAsMap = ops.itemsAsMap;
      for (var i = 0; i < ops.length; i++) {
        var map = opAsMap[i];
        nextOptions.add(
          CustomMultiSelectItem(
            value: valueKey != null ? map[valueKey] : ops[i],
            text: map[labelKey] ?? '',
            instanceObj: ops[i],
          ),
        );
      }
      _applyDataSource(nextOptions);
    } else {
      throw InvalidArgumentException(LiMultiSelectComponent, ops);
    }
  }

  //placeholder
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
    final pendingValues = _lastWrittenValues;
    if (pendingValues != null) {
      _applySelectedValues(pendingValues);
      _runAutoValidation();
      _markForCheck();
    }
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
      portalOptions: resolveModalAwarePortalOptions(
        hostClassName: 'LiMultiSelectComponent',
        referenceElement: reference,
        baseHostZIndex: 1000,
        baseFloatingZIndex: 1000,
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

  /// Emits [beforeOpen] and reports whether the open should go ahead.
  bool _dispatchBeforeOpen() {
    if (_destroyed) {
      return false;
    }

    final event = LiBeforeOpenEvent();
    _beforeOpenController.add(event);
    return !event.defaultPrevented;
  }

  void closeDropdown({
    bool markForCheck = true,
    bool restoreFocus = false,
    html.Element? preserveFocusTarget,
  }) {
    final wasOpen = dropdownOpen;

    for (final element
        in dropdownContainerEle?.queryAll('li') ?? const <html.Element>[]) {
      if (element.classes.contains('dropdown-item-hover')) {
        element.classes.remove('dropdown-item-hover');
      }
    }

    dropdownOpen = false;
    _overlayRelayoutPending = false;

    for (final option in options) {
      option.visible = true;
    }
    inputSearch?.value = '';

    _overlay?.stopAutoUpdate();

    if (wasOpen) {
      _markTouched();
    }

    if (restoreFocus && wasOpen) {
      dropdownButtonElement?.focus();
    } else if (_canPreserveFocus(preserveFocusTarget)) {
      Future<void>.microtask(() {
        final focusTarget = preserveFocusTarget;
        if ((focusTarget?.isA<html.HtmlElement>() ?? false) &&
            focusTarget?.isConnected == true) {
          focusTarget!.focus();
        }
      });
    }

    if (wasOpen && !_destroyed) {
      _openChangeController.add(false);
    }

    if (markForCheck) {
      _markForCheck();
    }
  }

  void openDropdown() {
    if (isDisabled) {
      return;
    }

    final wasOpen = dropdownOpen;

    if (!wasOpen && !_dispatchBeforeOpen()) {
      return;
    }

    _ensureOverlay();

    if (childrenSelectOptions.isNotEmpty) {
      _syncProjectedOptions(markForCheck: false);
    }

    dropdownContainerEle?.setAttribute('aria-expanded', 'true');

    dropdownOpen = true;
    _overlay?.startAutoUpdate();
    Future.delayed(const Duration(milliseconds: 20), () {
      _overlay?.update();
    });

    if (!wasOpen) {
      _openChangeController.add(true);
    }

    _markForCheck();
  }

  void onLiClickHandle(dynamic event, CustomMultiSelectItem value) {
    if (isDisabled) {
      return;
    }

    event.preventDefault();
    _toggleOptionSelection(value);
  }

  void onCheckboxClickHandle(dynamic event, CustomMultiSelectItem option) {
    if (isDisabled) {
      return;
    }

    event.stopPropagation();
    _toggleOptionSelection(option);
  }

  void toggleDropdown() {
    if (isDisabled) {
      return;
    }

    // openDropdown/closeDropdown own `dropdownOpen`; flipping it here first
    // made both of them read the already-updated state as their previous one.
    if (dropdownOpen) {
      closeDropdown(restoreFocus: true);
    } else {
      openDropdown();
    }
  }

  void handleTriggerKeydown(html.Event event) {
    if (!event.isA<html.KeyboardEvent>()) {
      return;
    }

    if ((event as html.KeyboardEvent).code == 'Enter' ||
        event.code == 'NumpadEnter' ||
        event.code == 'Space' ||
        event.key == ' ') {
      event.preventDefault();
      toggleDropdown();
    }
  }

  @override
  void ngOnDestroy() {
    _destroyed = true;
    closeDropdown(markForCheck: false);
    _overlay?.dispose();
    _formSubmissionSubscription?.cancel();
    _changeController.close();
    _modelChangeController.close();
    _userChangeController.close();
    _openChangeController.close();
    _beforeOpenController.close();
  }

  void reset({bool emitUserValueChange = false}) {
    _dirty = true;
    for (final element in options) {
      element.selected = false;
    }
    _lastWrittenValues = <dynamic>[];
    _changeController.add(selectedValues);
    _modelChangeController.add(selectedModels);
    if (emitUserValueChange) {
      _userChangeController.add(selectedValues);
    }
    if (_callback != null) {
      _callback!(selectedValues);
    }
    _markTouched();
    _runAutoValidation();
    _markForCheck();
    _scheduleOverlayUpdate();
  }

  void clearFromTriggerTemplate([html.Event? event]) {
    event?.preventDefault();
    event?.stopPropagation();

    if (isDisabled || !hasSelection) {
      return;
    }

    reset(emitUserValueChange: true);
    dropdownButtonElement?.focus();
  }

  void clearSelection(html.Event event) {
    clearFromTriggerTemplate(event);
  }

  void _toggleOptionSelection(CustomMultiSelectItem option) {
    _dirty = true;
    option.selected = !option.selected;
    _lastWrittenValues = selectedValues;

    _changeController.add(selectedValues);
    _modelChangeController.add(selectedModels);
    _userChangeController.add(selectedValues);
    if (_callback != null) {
      _callback!(selectedValues);
    }
    _markTouched();
    _runAutoValidation();
    _markForCheck();
    _scheduleOverlayUpdate();
  }

  bool _canPreserveFocus(html.Element? element) {
    if (!(element?.isA<html.HtmlElement>() ?? false) ||
        element?.isConnected != true) {
      return false;
    }

    final tabIndex = (element as html.HtmlElement).tabIndex;
    if (tabIndex >= 0) {
      return true;
    }

    return element.isA<html.InputElement>() ||
        element.isA<html.ButtonElement>() ||
        element.isA<html.SelectElement>() ||
        element.isA<html.TextAreaElement>() ||
        element.hasAttribute('contenteditable');
  }

  void searchHandle(String? searchString) {
    final query = searchString?.trim() ?? '';
    if (query.isEmpty) {
      for (final option in options) {
        option.visible = true;
      }
      _markForCheck();
      _scheduleOverlayUpdate();
      return;
    }

    for (final option in options) {
      option.visible = option.text.containsIgnoreAccents(query) ||
          option.value.toString() == query;
    }
    _markForCheck();
    _scheduleOverlayUpdate();
  }

  void _applyDataSource(List<CustomMultiSelectItem> nextOptions) {
    // Ignore equivalent option lists so parent change detection does not keep
    // rebuilding the same state and retriggering this component indefinitely.
    if (_sameOptions(options, nextOptions)) {
      return;
    }

    final valuesToRestore = _lastWrittenValues ?? selectedValues;
    options = nextOptions;
    _applySelectedValues(valuesToRestore);
    _runAutoValidation();
    _markForCheck();
  }

  void _syncProjectedOptions({bool markForCheck = true}) {
    if (childrenSelectOptions.isEmpty) {
      return;
    }

    final nextOptions = <CustomMultiSelectItem>[];
    for (final opt in childrenSelectOptions) {
      nextOptions.add(
        CustomMultiSelectItem(
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

    final valuesToRestore = _lastWrittenValues ?? selectedValues;
    options = nextOptions;
    _applySelectedValues(valuesToRestore);

    _runAutoValidation();

    if (markForCheck) {
      _markForCheck();
    }
  }

  bool _sameOptions(
    List<CustomMultiSelectItem> currentOptions,
    List<CustomMultiSelectItem> nextOptions,
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
      if (current.text != next.text || current.value != next.value) {
        return false;
      }
    }

    return true;
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
    // Compute height from viewport space only. Using the panel's current
    // rendered size in this callback can cause Popper to relayout forever.
    final availablePanelHeight = basePlacement == 'top'
        ? referenceTop - clippingTop - 8
        : clippingBottom - referenceBottom;
    final availableListHeight = math.max(50.0, availablePanelHeight - 20.0);
    final desiredMaxHeight = '${availableListHeight.floor()}px';
    final desiredMinHeight =
        '${math.min(minHeight.toDouble(), availableListHeight).floor()}px';

    if (listElement.style.maxHeight != desiredMaxHeight ||
        listElement.style.minHeight != desiredMinHeight) {
      listElement.style.maxHeight = desiredMaxHeight;
      listElement.style.minHeight = desiredMinHeight;
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
    html.window.liRequestAnimationFrame((_) {
      _overlayRelayoutPending = false;
      if (!dropdownOpen) {
        return;
      }
      _overlay?.update();
    });
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
      value: selectedValues,
      rules: _effectiveRules,
      context: LiRuleContext(
        fieldName: listboxId,
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
}
