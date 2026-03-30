import 'package:limitless_ui_example/limitless_ui_example.dart';
@Component(
  selector: 'tooltip-page',
  templateUrl: 'tooltip_page.html',
  styleUrls: ['tooltip_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiTooltipComponent,
  ],
)
class TooltipPageComponent {
  TooltipPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  @ViewChild('manualTooltip')
  LiTooltipComponent? manualTooltip;

  String tooltipEventLog = '';

  void toggleManualTooltip() {
    manualTooltip?.toggle();
  }

  void onTooltipEvent(String label) {
    tooltipEventLog = t.pages.tooltip.event(label);
  }
}
