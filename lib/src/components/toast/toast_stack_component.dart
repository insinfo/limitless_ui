import 'dart:async';

import 'package:ngdart/angular.dart';

import 'toast_component.dart';
import 'toast_service.dart';

/// Fixed-position host for a [LiToastService].
@Component(
  selector: 'li-toast-stack',
  templateUrl: 'toast_stack_component.html',
  styleUrls: ['toast_stack_component.css'],
  directives: [coreDirectives, LiToastComponent],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiToastStackComponent implements OnDestroy {
  LiToastStackComponent(this._changeDetectorRef);

  final ChangeDetectorRef _changeDetectorRef;
  StreamSubscription<void>? _serviceSubscription;

  LiToastService? _service;

  @Input()
  set service(LiToastService? value) {
    if (identical(_service, value)) {
      return;
    }

    _serviceSubscription?.cancel();
    _service = value;
    _serviceSubscription = value?.changes.listen((_) {
      _changeDetectorRef.markForCheck();
    });
    _changeDetectorRef.markForCheck();
  }

  LiToastService? get service => _service;

  /// top-end, top-start, bottom-end, bottom-start, top-center, bottom-center.
  @Input()
  String placement = 'top-end';

  String get resolvedContainerClasses {
    final normalized = placement.trim().toLowerCase();
    switch (normalized) {
      case 'top-start':
        return 'li-toast-stack top-0 start-0 align-items-start';
      case 'bottom-start':
        return 'li-toast-stack bottom-0 start-0 align-items-start';
      case 'bottom-end':
        return 'li-toast-stack bottom-0 end-0 align-items-end';
      case 'top-center':
        return 'li-toast-stack top-0 start-50 translate-middle-x align-items-center';
      case 'bottom-center':
        return 'li-toast-stack bottom-0 start-50 translate-middle-x align-items-center';
      default:
        return 'li-toast-stack top-0 end-0 align-items-end';
    }
  }

  void removeToast(LiToastMessage toast) {
    service?.remove(toast);
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngOnDestroy() {
    _serviceSubscription?.cancel();
  }
}
