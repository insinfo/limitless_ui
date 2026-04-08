import 'dart:async';

import 'package:ngdart/angular.dart';

import 'dynamic_tab_header_directive.dart';
import 'dynamic_tabs.dart';

/// Creates a tab which will be inside the [LiTabsComponent]
@Component(
  selector: 'li-tabx',
  template: '''
    <template [ngIf]="shouldRenderBody">
      <ng-content></ng-content>
    </template>
  ''',
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTabxDirective {
  LiTabxDirective(this._ref);

  final ChangeDetectorRef _ref;

  @HostBinding('class.tab-pane')
  bool tabPane = true;

  /// provides the injected parent tabset
  LiTabsComponent? tabsx;

  /// if `true` tab can not be activated
  @Input()
  bool disabled = false;

  /// tab header text
  @Input()
  String? header;

  /// Template reference to the heading template
  @ContentChildren(LiTabxHeaderDirective, descendants: false)
  List<LiTabxHeaderDirective> headerTemplates = [];

  LiTabxHeaderDirective? get headerTemplate =>
      headerTemplates.isEmpty ? null : headerTemplates.first;

  final _selectCtrl = StreamController<LiTabxDirective>.broadcast();

  /// emits the selected element change
  @Output()
  Stream<LiTabxDirective> get select => _selectCtrl.stream;

  final _deselectCtrl = StreamController<LiTabxDirective>.broadcast();

  /// emits the deselected element change
  @Output()
  Stream get deselect => _deselectCtrl.stream;

  bool _active = false;
  bool _hasActivatedOnce = false;

  /// if tab is active equals true, or set `true` to activate tab
  @HostBinding('class.active')
  bool get active => _active;

  @HostBinding('class.show')
  bool get show => _active;

  bool get shouldRenderBody {
    if (!resolvedLazyLoad) {
      return true;
    }

    if (_active) {
      return true;
    }

    if (!resolvedDestroyOnHide && _hasActivatedOnce) {
      return true;
    }

    return false;
  }

  bool get resolvedLazyLoad => tabsx?.lazyLoad ?? false;

  bool get resolvedDestroyOnHide => tabsx?.destroyOnHide ?? false;

  /// if tab is active equals true, or set `true` to activate tab
  @Input()
  set active(bool? activeP) {
    activeP ??= true;
    if (_active != activeP) {
      _active = activeP;
      if (_active) {
        _hasActivatedOnce = true;
      }
      //_ref.detectChanges();
      _ref.markForCheck();
    }
    if (activeP) {
      _selectCtrl.add(this);
    } else {
      _deselectCtrl.add(this);
    }
  }
}
