import 'dart:async';

import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'notification_toast_service.dart';

/// Top navigation component.
@Component(
  selector: 'li-notification-outlet',
  templateUrl: 'notification_toast.html',
  styleUrls: ['notification_toast.css'],
  directives: [
    coreDirectives,
  ],
  exports: [
    LiNotificationToastColor,
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiNotificationOutletComponent implements OnDestroy {
  final Router _router;
  final ChangeDetectorRef _changeDetectorRef;
  StreamSubscription<void>? _serviceChangesSubscription;
  LiNotificationToastService? _service;

  @Input()
  set service(LiNotificationToastService? value) {
    if (identical(value, _service)) {
      return;
    }

    _serviceChangesSubscription?.cancel();
    _service = value;
    _serviceChangesSubscription =
        value?.changes.listen((_) => _changeDetectorRef.markForCheck());
    _changeDetectorRef.markForCheck();
  }

  LiNotificationToastService? get service => _service;

  LiNotificationOutletComponent(this._router, this._changeDetectorRef);

  /// Produce a CSS style for the `top` property.
  String styleTop(int i) {
    return '${i * 20}px';
  }

  void closeToast(LiNotificationToast toast, [dynamic event]) {
    event?.stopPropagation();
    service?.remove(toast);
  }

  void onToastClick(LiNotificationToast toast) {
    if (toast.link != null && toast.link!.isNotEmpty) {
      final link = toast.link!;
      if (link.contains('?')) {
        final parts = link.split('?');
        final path = parts[0];
        final query = parts[1];
        final queryParams = Uri.splitQueryString(query);
        _router.navigate(path, NavigationParams(queryParameters: queryParams));
      } else {
        _router.navigate(link);
      }
      closeToast(toast);
    }
  }

  @override
  void ngOnDestroy() {
    _serviceChangesSubscription?.cancel();
  }
}
