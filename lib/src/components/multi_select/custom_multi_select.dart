//C:\MyDartProjects\new_sali\frontend\lib\src\shared\components\custom_multi_select\custom_multi_select.dart
import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:popper/popper.dart';

import '../../directives/click_outside.dart';
import '../../exceptions/invalid_argument_exception.dart';
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
        OnInit,
        OnDestroy,
        AfterContentInit {
  final html.Element nativeElement;
  final ChangeDetectorRef _changeDetectorRef;
  PopperAnchoredOverlay? _overlay;

  @Input('disabled')
  bool isDisabled = false;

  LiMultiSelectComponent(this.nativeElement, this._changeDetectorRef) {
    final seq = _nextSequence++;
    listboxId = 'li-multi-select-listbox-$seq';
    _idPrefix = 'li-multi-select-opt-$seq';
  }

  static int _nextSequence = 0;
  late final String listboxId;
  late final String _idPrefix;

  String optionId(int index) => '$_idPrefix-$index';

  final StreamController<dynamic> _changeController =
      StreamController<dynamic>();
  bool _overlayRelayoutPending = false;

  @Output('currentValueChange')
  Stream<dynamic> get onValueChange => _changeController.stream;

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
  void writeValue(dynamic newVal) {
    for (final option in options) {
      option.selected = false;
    }

    if (newVal is List) {
      for (final value in newVal) {
        for (final option in options) {
          if (value == option.value) {
            option.selected = true;
          }
        }
      }
    }

    _markForCheck();
  }

  dynamic Function(dynamic, {String rawValue})? _callback;

  @override
  void registerOnChange(callback) {
    _callback = callback;
  }

  // optionally you can implement the rest interface methods
  @override
  void registerOnTouched(TouchFunction callback) {}

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

  List<String> get selectedLabels =>
      options.where((opt) => opt.selected).map((e) => e.text).toList();

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
    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: dropdownButtonElement!,
      floatingElement: dropdownContainerEle!,
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

    if (options.isNotEmpty == true) {
      //currentValue = options[0];
    }
  }

  void closeDropdown({bool markForCheck = true}) {
    for (final element in dropdownContainerEle!.querySelectorAll('li')) {
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

    dropdownButtonElement?.focus();

    if (markForCheck) {
      _markForCheck();
    }
  }

  void openDropdown() {
    if (isDisabled) {
      return;
    }

    if (childrenSelectOptions.isNotEmpty) {
      _syncProjectedOptions(markForCheck: false);
    }

    dropdownContainerEle!.setAttribute('aria-expanded', 'true');

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
      closeDropdown();
    }
  }

  @override
  void ngOnDestroy() {
    closeDropdown(markForCheck: false);
    _overlay?.dispose();
    _changeController.close();
  }

  void reset() {
    for (final element in options) {
      element.selected = false;
    }
    _changeController.add(selectedValues);
    if (_callback != null) {
      _callback!(selectedValues);
    }
    _markForCheck();
    _scheduleOverlayUpdate();
  }

  void _toggleOptionSelection(CustomMultiSelectItem option) {
    option.selected = !option.selected;

    _changeController.add(selectedValues);
    if (_callback != null) {
      _callback!(selectedValues);
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
      option.selected = selectedValueSet.contains(option.value);
    }
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

    final selectedValueSet = selectedValues.toSet();
    options = nextOptions;
    for (final option in options) {
      option.selected = selectedValueSet.contains(option.value);
    }

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
}
