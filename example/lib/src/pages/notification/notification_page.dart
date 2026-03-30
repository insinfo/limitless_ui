import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'notification-page',
  templateUrl: 'notification_page.html',
  styleUrls: ['notification_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiNotificationOutletComponent,
  ],
)
class NotificationPageComponent {
  NotificationPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  final NotificationToastService notifications = NotificationToastService();
  String lastAction = '';

  void showSuccess() {
    notifications.notify(
      t.pages.notification.successMessage,
      title: t.pages.notification.successTitle,
      type: NotificationToastColor.success,
    );
    lastAction = t.pages.notification.successState;
  }

  void showWarning() {
    notifications.notify(
      t.pages.notification.warningMessage,
      title: t.pages.notification.warningTitle,
      type: NotificationToastColor.warning,
    );
    lastAction = t.pages.notification.warningState;
  }

  void showWithLink() {
    notifications.notify(
      t.pages.notification.linkMessage,
      title: t.pages.notification.linkTitle,
      type: NotificationToastColor.info,
      link: 'datatable',
      durationSeconds: 6,
    );
    lastAction = t.pages.notification.linkState;
  }
}
