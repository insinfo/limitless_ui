import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:popper/popper.dart';

import '../../exceptions/invalid_argument_exception.dart';
import 'custom_option.dart';

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

@Component(
  selector: 'li-select',
  changeDetection: ChangeDetectionStrategy.onPush,
  templateUrl: 'custom_select.html',
  styleUrls: ['custom_select.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiSelectComponent),
  ],
)
class LiSelectComponent
    implements
        ControlValueAccessor<dynamic>,
        OnInit,
        OnDestroy,
        AfterContentInit {
  final html.Element nativeElement;
  final ChangeDetectorRef _changeDetectorRef;

  LiSelectComponent(this.nativeElement, this._changeDetectorRef) {
    final seq = _nextSequence++;
    listboxId = 'li-select-listbox-$seq';
    _idPrefix = 'li-select-opt-$seq';
  }

  static int _nextSequence = 0;

  PopperAnchoredOverlay? _overlay;
  final StreamController<dynamic> _changeController =
      StreamController<dynamic>();
  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;
  bool _overlayRelayoutPending = false;

  dynamic Function(dynamic, {String rawValue})? _ngModelValueChangeCallback;

  @Input('disabled')
  bool isDisabled = false;

  /// Whether the search input is displayed in the dropdown.
  ///
  /// **CRITICAL — DO NOT set this to `false` by default.**
  /// The inline search box is the primary reason this custom select exists.
  /// Without it, this component offers no advantage over a plain `<select>`.
  /// Removing or hiding it by default will break every consumer that relies
  /// on filtering through long option lists (e.g. Unidades, Órgãos, Bancos).
  @Input()
  bool searchable = true;

  @Output('currentValueChange')
  Stream<dynamic> get onValueChange => _changeController.stream;

  @ContentChildren(LiOptionComponent)
  List<LiOptionComponent> childrenSelectOptions = [];

  @ViewChild('dropdownContainer')
  html.Element? dropdownContainerEle;

  @ViewChild('inputSearch')
  html.InputElement? inputSearch;

  @ViewChild('dropdownButton')
  html.Element? dropdownButtonElement;

  int currentIndex = -1;
  CustomSelectItem? currentValue;
  bool dropdownOpen = false;

  late final String listboxId;
  late final String _idPrefix;

  String optionId(int index) => '$_idPrefix-$index';

  String? get activeDescendantId {
    if (!dropdownOpen || currentIndex < 0 || currentIndex >= options.length) {
      return null;
    }
    return optionId(currentIndex);
  }

  @Input('id')
  String id = 'custom_select_1';

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
  void writeValue(dynamic newVal) {
    if (newVal == null) {
      currentValue = null;
      _markForCheck();
      return;
    }

    currentValue = null;
    for (final option in options) {
      if (option.value == newVal) {
        currentValue = option;
        break;
      }
    }
    _markForCheck();
  }

  @override
  void registerOnChange(callback) {
    _ngModelValueChangeCallback = callback;
  }

  @override
  void registerOnTouched(TouchFunction callback) {}

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

  @Input()
  String placeholder = 'Selecione';

  @override
  void ngOnInit() {
    currentValue = options.where((option) => !option.disabled).firstOrNull;
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
        offset: const PopperOffset(mainAxis: 4),
        matchReferenceWidth: true,
        onLayout: _handleOverlayLayout,
      ),
    );
  }

  void closeDropdown({bool markForCheck = true}) {
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

    dropdownButtonElement?.focus();

    if (markForCheck) {
      _markForCheck();
    }
  }

  void openDropdown() {
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

    _markForCheck();
  }

  void setSelectedItemByValue(
    dynamic value, {
    bool isCloseDropDown = true,
    bool isCallNgModelChange = true,
    bool isCallCurrentValueChange = true,
  }) {
    for (final option in options) {
      if (option.value != value || option.disabled) {
        continue;
      }

      currentValue = option;

      if (isCloseDropDown && dropdownOpen) {
        closeDropdown();
      }
      if (isCallCurrentValueChange) {
        _changeController.add(currentValue?.value);
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

    currentValue = selItem;
    closeDropdown();
    _changeController.add(currentValue?.value);
    _ngModelValueChangeCallback?.call(currentValue?.value);
    _markForCheck();
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
  void handleKeydownEvents(html.KeyboardEvent event) {
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
    _unbindDocumentListeners();
    closeDropdown(markForCheck: false);
    _overlay?.dispose();
    _changeController.close();
  }

  void _handleOverlayLayout(PopperLayout layout) {
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

    final currentSelectedValue = currentValue?.value;
    options = nextOptions;
    currentValue = options
        .where((option) => option.value == currentSelectedValue)
        .firstOrNull;
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

    final currentSelectedValue = currentValue?.value;
    options = nextOptions;
    currentValue = options
        .where((option) => option.value == currentSelectedValue)
        .firstOrNull;

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

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }
}
