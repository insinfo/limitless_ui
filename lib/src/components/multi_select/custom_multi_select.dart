//C:\MyDartProjects\new_sali\frontend\lib\src\shared\components\custom_multi_select\custom_multi_select.dart
import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:popper/popper.dart';

import '../../core/overlay_positioning.dart';
import '../../directives/click_outside.dart';
import '../../directives/li_form_directive.dart';
import '../../exceptions/invalid_argument_exception.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';
import 'custom_multi_option.dart';

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

/// Example:
/// `<li-multi-select [dataSource]="dropdownOptions" [fields]="{'text': 'name', 'value': 'value'}" (currentValueChange)="dropdownValueChanged($event)"></li-multi-select>`
@Component(
  selector: 'li-multi-select',
  templateUrl: 'custom_multi_select.html',
  styleUrls: ['custom_multi_select.css'],
  directives: [
    coreDirectives,
    formDirectives,
    ClickOutsideDirective,
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

  String optionId(int index) => '$_idPrefix-$index';

  bool get _isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get effectiveAutoInvalid =>
      _shouldShowValidation && _autoValidationIssue != null;

  bool get effectiveInvalid => invalid || dataInvalid || effectiveAutoInvalid;

  bool get effectiveValid =>
      !effectiveInvalid && (valid || (_shouldShowValidation && _effectiveRules.isNotEmpty && _autoValidationIssue == null));

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

  String get resolvedTriggerIconClass {
    final custom = triggerIconClass.trim();
    return custom.isNotEmpty ? custom : 'ph ph-caret-down';
  }

  String get resolvedButtonClass => _joinClasses(<String>[
        'form-select',
        'dropdown-button',
        hidesNativeIndicator ? 'dropdown-button--no-native-indicator' : '',
        usesOverlayTriggerIcon ? 'dropdown-button--with-overlay-icon' : '',
        showClearButton && hasSelection ? 'dropdown-button--with-clear' : '',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
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
  bool _overlayRelayoutPending = false;

  @Output('currentValueChange')
  Stream<dynamic> get onValueChange => _changeController.stream;

  @Output('modelChange')
  Stream<List<dynamic>> get onModelChange => _modelChangeController.stream;

  @ContentChildren(LiMultiOptionComponent)
  List<LiMultiOptionComponent> childrenSelectOptions = [];

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
    for (final option in options) {
      option.selected = false;
    }

    if (newVal is List) {
      for (final value in newVal) {
        for (final option in options) {
          if (_areValuesEqual(option.value, value)) {
            option.selected = true;
          }
        }
      }
    }

    _runAutoValidation();
    _markForCheck();
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
    if (options.isNotEmpty == true) {
      //currentValue = options[0];
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
      portalOptions: const PopperPortalOptions(
        hostClassName: 'LiMultiSelectComponent',
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

  void closeDropdown({
    bool markForCheck = true,
    bool restoreFocus = false,
    html.Element? preserveFocusTarget,
  }) {
    final wasOpen = dropdownOpen;

    for (final element in dropdownContainerEle?.querySelectorAll('li') ??
        const <html.Element>[]) {
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
        if (focusTarget is html.HtmlElement &&
            focusTarget.isConnected == true) {
          focusTarget.focus();
        }
      });
    }

    if (markForCheck) {
      _markForCheck();
    }
  }

  void openDropdown() {
    if (isDisabled) {
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

    dropdownOpen = !dropdownOpen;
    //dropdownElement.setAttribute( 'aria-expanded', dropdownOpen ? 'true' : 'false');
    if (dropdownOpen) {
      openDropdown();
    } else {
      closeDropdown(restoreFocus: true);
    }
  }

  @override
  void ngOnDestroy() {
    closeDropdown(markForCheck: false);
    _overlay?.dispose();
    _formSubmissionSubscription?.cancel();
    _changeController.close();
    _modelChangeController.close();
  }

  void reset() {
    _dirty = true;
    for (final element in options) {
      element.selected = false;
    }
    _changeController.add(selectedValues);
    _modelChangeController.add(selectedModels);
    if (_callback != null) {
      _callback!(selectedValues);
    }
    _markTouched();
    _runAutoValidation();
    _markForCheck();
    _scheduleOverlayUpdate();
  }

  void clearSelection(html.Event event) {
    if (isDisabled || !hasSelection) {
      return;
    }

    event.preventDefault();
    event.stopPropagation();
    reset();
    dropdownButtonElement?.focus();
  }

  void _toggleOptionSelection(CustomMultiSelectItem option) {
    _dirty = true;
    option.selected = !option.selected;

    _changeController.add(selectedValues);
    _modelChangeController.add(selectedModels);
    if (_callback != null) {
      _callback!(selectedValues);
    }
    _markTouched();
    _runAutoValidation();
    _markForCheck();
    _scheduleOverlayUpdate();
  }

  bool _canPreserveFocus(html.Element? element) {
    if (element is! html.HtmlElement || element.isConnected != true) {
      return false;
    }

    final tabIndex = element.tabIndex;
    if (tabIndex != null && tabIndex >= 0) {
      return true;
    }

    return element is html.InputElement ||
        element is html.ButtonElement ||
        element is html.SelectElement ||
        element is html.TextAreaElement ||
        element.attributes.containsKey('contenteditable');
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

    final selectedValueSet = selectedValues.toSet();
    options = nextOptions;
    for (final option in options) {
      option.selected = selectedValueSet.any(
        (selectedValue) => _areValuesEqual(option.value, selectedValue),
      );
    }
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

    final selectedValueSet = selectedValues.toList(growable: false);
    options = nextOptions;
    for (final option in options) {
      option.selected = selectedValueSet.any(
        (selectedValue) => _areValuesEqual(option.value, selectedValue),
      );
    }

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
    html.window.requestAnimationFrame((_) {
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
