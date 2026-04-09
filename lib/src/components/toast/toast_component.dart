import 'dart:async';

import 'package:ngdart/angular.dart';

/// Declarative Bootstrap/Limitless toast component.
@Component(
  selector: 'li-toast',
  templateUrl: 'toast_component.html',
  styleUrls: ['toast_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiToastComponent implements OnInit, OnDestroy {
  static const Duration _animationDuration = Duration(milliseconds: 150);

  LiToastComponent(this._changeDetectorRef);

  final ChangeDetectorRef _changeDetectorRef;

  final StreamController<void> _shownController =
      StreamController<void>.broadcast();
  final StreamController<void> _hiddenController =
      StreamController<void>.broadcast();

  Timer? _autohideTimer;
  Timer? _transitionTimer;
  bool _mounted = false;
  bool _showClass = false;

  @Input()
  String header = '';

  @Input()
  String body = '';

  @Input()
  String helperText = '';

  @Input()
  String badgeText = '';

  @Input()
  String iconClass = '';

  @Input()
  String toastClass = '';

  @Input()
  String headerClass = '';

  @Input()
  String bodyClass = '';

  @Input()
  String ariaLive = 'polite';

  @Input()
  int delay = 5000;

  @Input()
  bool animation = true;

  @Input()
  bool autohide = true;

  @Input()
  bool dismissible = true;

  @Input()
  bool pauseOnHover = false;

  @Input()
  bool rounded = false;

  @Input()
  bool startOpen = true;

  @Output()
  Stream<void> get shown => _shownController.stream;

  @Output()
  Stream<void> get hidden => _hiddenController.stream;

  bool get isMounted => _mounted;
  bool get isOpen => _mounted;
  bool get hasHeader => hasHeaderChrome;
  bool get hasBody => body.trim().isNotEmpty;
  bool get hasHeaderChrome =>
      helperText.trim().isNotEmpty ||
      badgeText.trim().isNotEmpty ||
      iconClass.trim().isNotEmpty ||
      header.trim().isNotEmpty;
  bool get hasIcon => iconClass.trim().isNotEmpty;
  bool get hasBadge => badgeText.trim().isNotEmpty;
  bool get hasHelperText => helperText.trim().isNotEmpty;
  bool get usesLightText =>
      toastClass.contains('text-white') || headerClass.contains('text-white');
  bool get useSolidHeaderChrome =>
      headerClass.trim().isEmpty && toastClass.contains('text-white');

  String get resolvedToastClasses => _joinClasses(<String>[
        'toast',
        animation ? 'fade' : '',
        _showClass ? 'show' : '',
        rounded ? 'rounded-pill' : '',
        toastClass,
      ]);

  String get resolvedHeaderClasses => _joinClasses(<String>[
        'toast-header',
        useSolidHeaderChrome ? 'bg-black bg-opacity-10 text-white' : '',
        headerClass,
      ]);

  String get resolvedBodyClasses => _joinClasses(<String>[
        'toast-body',
        bodyClass,
      ]);

  String get resolvedIconClasses => _joinClasses(<String>[
        iconClass,
        'me-2',
      ]);

  String get resolvedBadgeClasses => _joinClasses(<String>[
        'badge',
        usesLightText ? 'bg-black bg-opacity-20 text-white' : 'bg-primary text-white',
        'me-2',
      ]);

  String get resolvedHelperTextClasses => _joinClasses(<String>[
        usesLightText ? 'text-white text-opacity-75' : 'text-muted',
        'me-2',
      ]);

  String get resolvedCloseButtonClasses => _joinClasses(<String>[
        'btn-close',
        usesLightText ? 'btn-close-white' : '',
      ]);

  @override
  void ngOnInit() {
    if (startOpen) {
      show();
    }
  }

  @HostListener('mouseenter')
  void onMouseEnter() {
    if (pauseOnHover) {
      _cancelAutohideTimer();
    }
  }

  @HostListener('mouseleave')
  void onMouseLeave() {
    if (pauseOnHover && isOpen) {
      _scheduleAutohide();
    }
  }

  void show() {
    _cancelTransitionTimer();
    _cancelAutohideTimer();

    if (_mounted) {
      _scheduleAutohide();
      return;
    }

    _mounted = true;
    _showClass = false;

    if (!animation) {
      _showClass = true;
      _changeDetectorRef.markForCheck();
      _shownController.add(null);
      _scheduleAutohide();
      return;
    }

    Future<void>.microtask(() {
      if (!_mounted) {
        return;
      }
      _showClass = true;
      _changeDetectorRef.markForCheck();
    });

    _transitionTimer = Timer(_animationDuration, () {
      if (_mounted) {
        _changeDetectorRef.markForCheck();
        _shownController.add(null);
        _scheduleAutohide();
      }
    });
  }

  void hide() {
    if (!_mounted) {
      return;
    }

    _cancelAutohideTimer();
    _cancelTransitionTimer();

    if (!animation) {
      _showClass = false;
      _mounted = false;
      _changeDetectorRef.markForCheck();
      _hiddenController.add(null);
      return;
    }

    _showClass = false;
    _changeDetectorRef.markForCheck();
    _transitionTimer = Timer(_animationDuration, () {
      _mounted = false;
      _changeDetectorRef.markForCheck();
      _hiddenController.add(null);
    });
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  void _scheduleAutohide() {
    if (!autohide || delay <= 0) {
      return;
    }

    _autohideTimer = Timer(Duration(milliseconds: delay), hide);
  }

  void _cancelAutohideTimer() {
    _autohideTimer?.cancel();
    _autohideTimer = null;
  }

  void _cancelTransitionTimer() {
    _transitionTimer?.cancel();
    _transitionTimer = null;
  }

  @override
  void ngOnDestroy() {
    _cancelAutohideTimer();
    _cancelTransitionTimer();
    _shownController.close();
    _hiddenController.close();
  }
}
