


import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'alert-page',
  templateUrl: 'alert_page.html',
  styleUrls: ['alert_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiAlertComponent,
  ],
)
class AlertPageComponent {
  AlertPageComponent(this.i18n) {
    alertEventLog = i18n.t.pages.alerts.waiting;
  }

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool releaseAlertVisible = true;
  String alertEventLog = '';

  void restoreReleaseAlert() {
    releaseAlertVisible = true;
    alertEventLog = i18n.t.pages.alerts.restored;
  }

  void dismissReleaseAlert() {
    releaseAlertVisible = false;
    alertEventLog = i18n.t.pages.alerts.dismissed;
  }

  void handleVisibilityChange(bool visible) {
    alertEventLog = visible
        ? i18n.t.pages.alerts.visible
        : i18n.t.pages.alerts.hidden;
  }
}
