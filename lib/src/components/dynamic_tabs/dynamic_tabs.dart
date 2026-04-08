import 'dart:async';

import 'package:ngdart/angular.dart';

import 'dynamic_tab_directive.dart';
import 'dynamic_tab_header_directive.dart';

/// Directives needed to create a tab-set
const esDynamicTabsDirectives = [
  LiTabxDirective,
  LiTabxHeaderDirective,
  LiTabsComponent
];

@Component(
    selector: 'li-tabsx',
    templateUrl: 'dynamic_tabs.html',
    styleUrls: ['dynamic_tabs.css'],
    directives: [coreDirectives])
class LiTabsComponent implements OnInit, AfterContentInit {
  /// if `true` tabs will be placed vertically
  bool get vertical => placement == 'left' || placement == 'right';

  bool get usesTabNavigation => type != 'pills';

  @HostBinding('class.d-flex')
  bool get usesFlexLayout => vertical || placementBottom;

  @HostBinding('class.gap-3')
  bool get usesFlexGap => vertical || placementBottom;

  @HostBinding('class.align-items-start')
  bool get alignItemsStart => vertical;

  @HostBinding('class.flex-row')
  bool get placementLeft => placement == 'left';

  @HostBinding('class.flex-row-reverse')
  bool get placementRight => placement == 'right';

  @HostBinding('class.flex-column-reverse')
  bool get placementBottom => placement == 'bottom';

  @HostBinding('class.li-tabsx-active-text-body-color')
  bool get usesBodyColorOnActiveTab => activeTextBodyColor;

  @Input()
  @HostBinding('attr.placement')
  String? placement;

  /// if `true` tabs will be justified
  @Input()
  bool justified = false;

  /// navigation context class: 'tabs', 'highlight', 'underline',
  /// 'overline', 'solid' or 'pills'.
  @Input()
  String? type;

  /// Defers non-active tab body rendering until the tab is opened.
  @Input()
  bool lazyLoad = false;

  /// If `true`, removes inactive tab bodies from the DOM after tab changes.
  @Input()
  bool destroyOnHide = false;

  /// Applies the default padding to the tab content wrapper.
  @Input()
  bool contentPadding = true;

  /// Uses the regular body color for the active tab text instead of the theme accent.
  ///
  /// Useful for underline/highlight variants that should keep emphasis only in the tab indicator.
  @Input()
  bool activeTextBodyColor = false;

  /*Map get navTypeMap =>
      {'flex-column': vertical, 'nav-justified': justified, 'nav-tabs': type == 'tabs', 'nav-pills': type == 'pills'};*/

  //Map tabTypeMap(EsTabxDirective tab) => {'active': tab.active, 'disabled': tab.disabled};

  /// List of sub tabs
  @ContentChildren(LiTabxDirective, descendants: false)
  List<LiTabxDirective> tabs = [];

  /// initialize attributes
  @override
  void ngOnInit() {
    type ??= 'tabs';
    placement ??= 'top';
  }

  final _selectCtrl = StreamController<LiTabxDirective>.broadcast();

  /// emits the selected element change
  @Output()
  Stream<LiTabxDirective> get select => _selectCtrl.stream;

  @override
  void ngAfterContentInit() {
    for (final tab in tabs) {
      tab.tabsx = this;
    }

    activateTab(tabs.firstWhere((tab) => tab.active, orElse: () => tabs[0]));

    //selected element change
    for (final t in tabs) {
      t.select.listen((event) {
        _selectCtrl.add(event);
      });
    }
  }

  /// adds a new tab at the end
  void addTab(LiTabxDirective tab) {
    tabs.add(tab);
    tab.active = tabs.length == 1 && tab.active != false;
  }

  /// removes the specified tab
  void removeTab(LiTabxDirective tab) {
    var index = tabs.indexOf(tab);
    if (index == -1) return;

    // Select a new tab if the tab to be removed is selected and not destroyed
    if (tab.active && tabs.length > 1) {
      // If this is the last tab, select the previous tab. else, the next tab.
      var newActiveIndex = index == tabs.length - 1 ? index - 1 : index + 1;
      tabs[newActiveIndex].active = true;
    }
    tabs.remove(tab);
  }

  void activateTab(LiTabxDirective tab) {
    if (tab.disabled) return;

    for (final t in tabs) {
      t.active = t == tab;
    }
  }
}
