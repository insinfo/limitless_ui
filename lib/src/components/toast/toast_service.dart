import 'dart:async';

/// Immutable configuration used by [LiToastComponent] and [LiToastStackComponent].
class LiToastMessage {
  const LiToastMessage({
    this.header = '',
    this.body = '',
    this.helperText = '',
    this.badgeText = '',
    this.iconClass = '',
    this.toastClass = '',
    this.headerClass = '',
    this.bodyClass = '',
    this.ariaLive = 'polite',
    this.delay = 5000,
    this.animation = true,
    this.autohide = true,
    this.dismissible = true,
    this.pauseOnHover = false,
    this.rounded = false,
  });

  final String header;
  final String body;
  final String helperText;
  final String badgeText;
  final String iconClass;
  final String toastClass;
  final String headerClass;
  final String bodyClass;
  final String ariaLive;
  final int delay;
  final bool animation;
  final bool autohide;
  final bool dismissible;
  final bool pauseOnHover;
  final bool rounded;
}

/// Simple toast store for global stack-style notifications.
class LiToastService {
  final List<LiToastMessage> toasts = <LiToastMessage>[];
  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  Stream<void> get changes => _changesController.stream;

  LiToastMessage show({
    String header = '',
    String body = '',
    String helperText = '',
    String badgeText = '',
    String iconClass = '',
    String toastClass = '',
    String headerClass = '',
    String bodyClass = '',
    String ariaLive = 'polite',
    int delay = 5000,
    bool animation = true,
    bool autohide = true,
    bool dismissible = true,
    bool pauseOnHover = false,
    bool rounded = false,
  }) {
    final toast = LiToastMessage(
      header: header,
      body: body,
      helperText: helperText,
      badgeText: badgeText,
      iconClass: iconClass,
      toastClass: toastClass,
      headerClass: headerClass,
      bodyClass: bodyClass,
      ariaLive: ariaLive,
      delay: delay,
      animation: animation,
      autohide: autohide,
      dismissible: dismissible,
      pauseOnHover: pauseOnHover,
      rounded: rounded,
    );

    toasts.insert(0, toast);
    _changesController.add(null);
    return toast;
  }

  void remove(LiToastMessage toast) {
    if (toasts.remove(toast)) {
      _changesController.add(null);
    }
  }

  void clear() {
    if (toasts.isEmpty) {
      return;
    }

    toasts.clear();
    _changesController.add(null);
  }

  void dispose() {
    _changesController.close();
  }
}
