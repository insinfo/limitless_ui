import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'tooltip-global-config-demo',
  template: '''
    <div class="d-flex flex-wrap gap-2 align-items-center">
      <button
          class="btn btn-outline-secondary"
          type="button"
          [liTooltip]="defaultMessage">
        Tooltip com defaults injetados
      </button>
      <span class="text-muted small">
        Neste bloco, os tooltips herdam click, placement="right", autoClose="outside" e uma classe visual própria.
      </span>
    </div>
  ''',
  directives: [coreDirectives, LiTooltipDirective],
  providers: [ClassProvider(LiTooltipConfig)],
)
class TooltipGlobalConfigDemoComponent {
  TooltipGlobalConfigDemoComponent(this.config) {
    config.triggers = 'click';
    config.placement = 'right';
    config.autoClose = 'outside';
    config.tooltipClass = 'tooltip-config-demo';
  }

  final LiTooltipConfig config;

  final String defaultMessage =
      'Este tooltip herdou seus defaults de um LiTooltipConfig local.';
}

@Component(
  selector: 'tooltip-page',
  templateUrl: 'tooltip_page.html',
  styleUrls: ['tooltip_page.css'],
  encapsulation: ViewEncapsulation.none,
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiTooltipComponent,
    LiTooltipDirective,
    TooltipGlobalConfigDemoComponent,
  ],
)
class TooltipPageComponent {
  TooltipPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  @ViewChild('manualTooltip')
  LiTooltipDirective? manualTooltip;

  @ViewChild('targetedTooltip')
  LiTooltipDirective? targetedTooltip;

  String tooltipEventLog = '';

  void toggleManualTooltip() {
    manualTooltip?.toggle();
  }

  void toggleTargetedTooltip() {
    targetedTooltip?.toggle();
  }

  void onTooltipEvent(String label) {
    tooltipEventLog = t.pages.tooltip.event(label);
  }
}
