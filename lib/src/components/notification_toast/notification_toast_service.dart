
import 'dart:async';
import 'dart:html' as html;

typedef LiToastSoundPlayer = Future<void> Function();

enum LiNotificationToastColor {
  primary,
  secondary,
  success,
  info,
  warning,
  danger,
  pink,
  teal,
  indigo,
  none,
}

extension LiNotificationToastColorExtension on LiNotificationToastColor {
  String asString() {
    switch (this) {
      case LiNotificationToastColor.primary:
        return 'primary';
      case LiNotificationToastColor.secondary:
        return 'secondary';
      case LiNotificationToastColor.success:
        return 'success';
      case LiNotificationToastColor.info:
        return 'info';
      case LiNotificationToastColor.warning:
        return 'warning';
      case LiNotificationToastColor.danger:
        return 'danger';
      case LiNotificationToastColor.pink:
        return 'pink';
      case LiNotificationToastColor.teal:
        return 'teal';
      case LiNotificationToastColor.indigo:
        return 'indigo';
      case LiNotificationToastColor.none:
        return 'none';
    }
  }
}

LiNotificationToastColor _stringAsNotificationCompColor(String val) {
  switch (val) {
    case 'primary':
      return LiNotificationToastColor.primary;
    case 'secondary':
      return LiNotificationToastColor.secondary;
    case 'success':
      return LiNotificationToastColor.success;
    case 'info':
      return LiNotificationToastColor.info;
    case 'warning':
      return LiNotificationToastColor.warning;
    case 'danger':
      return LiNotificationToastColor.danger;
    case 'pink':
      return LiNotificationToastColor.pink;
    case 'teal':
      return LiNotificationToastColor.teal;
    case 'indigo':
      return LiNotificationToastColor.indigo;
    case 'none':
      return LiNotificationToastColor.none;
    default:
      // return 'unknown';
      throw Exception('NotificationCompColor unknown');
  }
}

class LiToastSoundController {
  LiToastSoundController({
    String? audioSrc,
    html.AudioElement? audioElement,
    LiToastSoundPlayer? customPlayer,
  })  : _customPlayer = customPlayer,
        audio = customPlayer == null && (audioSrc != null || audioElement != null)
            ? (audioElement ?? html.AudioElement())
            : null {
    if (audio != null && audioSrc != null) {
      audio!
        ..src = audioSrc
        ..preload = 'auto';
    }
    _registerUserInteraction();
  }

  final html.AudioElement? audio;
  final LiToastSoundPlayer? _customPlayer;
  bool userInteracted = false;

  bool get isConfigured {
    if (_customPlayer != null) {
      return true;
    }

    return audio != null && audio!.src.isNotEmpty;
  }

  void _registerUserInteraction() {
    html.document.onClick.first.then((_) => userInteracted = true);
    html.document.onKeyDown.first.then((_) => userInteracted = true);
  }

  Future<void> playOnceSafely() async {
    if (!userInteracted || !isConfigured) return;
    try {
      if (_customPlayer != null) {
        await _customPlayer();
        return;
      }

      audio!.currentTime = 0;
      await audio!.play();
    } catch (_) {
      // ignore: política do navegador
    }
  }
}

/// A service that manages toasts that should be displayed.
//@Injectable()
class LiNotificationToastService {
  /// A list of toasts that should be displayed.
  List<LiNotificationToast> toasts = <LiNotificationToast>[];

  final StreamController<LiNotificationToast> _onNotifyStreamController;
  Stream<LiNotificationToast> get onNotify => _onNotifyStreamController.stream;
  final StreamController<void> _changesStreamController;
  Stream<void> get changes => _changesStreamController.stream;
  final LiToastSoundController? soundController;

  /// Constructor.
  LiNotificationToastService({this.soundController})
      : _onNotifyStreamController = StreamController<LiNotificationToast>.broadcast(),
        _changesStreamController = StreamController<void>.broadcast();

  LiNotificationToastService.withSound({
    required String audioSrc,
  })  : soundController = LiToastSoundController(audioSrc: audioSrc),
        _onNotifyStreamController = StreamController<LiNotificationToast>.broadcast(),
        _changesStreamController = StreamController<void>.broadcast();

  void notify(
    String message, {
    LiNotificationToastColor type = LiNotificationToastColor.success,
    String? title = 'Informação',
    String? icon,
    int durationSeconds = 3,
    bool enableSound = false,
    String? link,
  }) {
    final toast = LiNotificationToast(
      type: type,
      title: title,
      message: message,
      icon: icon,
      durationSeconds: durationSeconds,
      link: link,
    );
    if (enableSound) {
      try {
        soundController?.playOnceSafely();
      } catch (e) {
        print('NotificationComponentService@notify $e');
      }
    }

    _enqueueToast(toast, emitNotify: true);
  }

  /// Display a toast.
  void add(LiNotificationToastColor type, String title, String message,
      {String? icon, int durationSeconds = 3, String? link}) {
    final toast = LiNotificationToast(
      type: type,
      title: title,
      message: message,
      icon: icon,
      durationSeconds: durationSeconds,
      link: link,
    );
    _enqueueToast(toast);
  }

  void remove(LiNotificationToast toast) {
    final nextToasts = List<LiNotificationToast>.from(toasts)..remove(toast);
    if (nextToasts.length != toasts.length) {
      toasts = nextToasts;
      _emitChanges();
    }
  }

  void _enqueueToast(LiNotificationToast toast, {bool emitNotify = false}) {
    toasts = <LiNotificationToast>[toast, ...toasts];
    if (emitNotify) {
      _onNotifyStreamController.add(toast);
    }
    _emitChanges();

    final milliseconds = ((1000 * toast.durationSeconds) + 300).round();
    Timer(Duration(milliseconds: milliseconds), () {
      toast.toBeDeleted = true;
      toasts = List<LiNotificationToast>.from(toasts);
      _emitChanges();

      Timer(const Duration(milliseconds: 300), () {
        remove(toast);
      });
    });
  }

  void _emitChanges() {
    if (!_changesStreamController.isClosed) {
      _changesStreamController.add(null);
    }
  }

  void dispose() {
    _onNotifyStreamController.close();
    _changesStreamController.close();
  }
}

/// Data model for a toast, a.k.a. pop-up notification.
class LiNotificationToast {
  /// The type (color) of this toast.
  LiNotificationToastColor type;

  /// The title to display (optional).
  String? title;

  /// The message to diplay.
  String message;

  /// The icon to display. If not specified, an icon is selected automatically
  /// based on `type`.
  String? icon;

  /// Link para redirecionamento ao clicar (opcional)
  String? link;

  /// How long to display the toast before removing it.
  int durationSeconds;

  /// Duration as a CSS property string.
  String get cssDuration => '${durationSeconds}s';

  /// Set to true before the item is deleted. This allows time to fade the
  /// item out.
  bool toBeDeleted = false;

  /// data de criação
  late DateTime created;

  String get cssAnimation => toBeDeleted == true
      ? 'toast-fade-out 0.3s ease-out'
      : 'toast-fade-in 0.3s ease-in';

  /// Constructor
  LiNotificationToast(
      {this.type = LiNotificationToastColor.info,
      this.title,
      required this.message,
      this.icon,
      this.link,
      this.durationSeconds = 3}) {
    created = DateTime.now();
    if (icon == null) {
      if (type == LiNotificationToastColor.success) {
        icon = 'check';
      } else if (type == LiNotificationToastColor.info) {
        icon = 'info';
      } else if (type == LiNotificationToastColor.warning) {
        icon = 'exclamation';
      } else if (type == LiNotificationToastColor.danger) {
        icon = 'times';
      } else {
        icon = 'bullhorn';
      }
    }
  }

  factory LiNotificationToast.fromMap(Map<String, dynamic> map) {
    final t = LiNotificationToast(
      message: map['message'],
      icon: map['icon'],
      title: map['title'],
      durationSeconds: map['durationSeconds'],
    );
    t.type = _stringAsNotificationCompColor(map['type']);
    t.toBeDeleted = map['toBeDeleted'];
    if (map.containsKey('created')) {
      final dt = DateTime.tryParse(map['created']);
      if (dt != null) {
        t.created = dt;
      }
    }
    return t;
  }

  Map<String, dynamic> toMap() {
    final map = {
      'type': type.asString(),
      'title': title,
      'message': message,
      'icon': icon,
      'durationSeconds': durationSeconds,
      'toBeDeleted': toBeDeleted,
      'created': created.toIso8601String(),
    };
    return map;
  }

  String get bgColor {
    if (type == LiNotificationToastColor.primary) {
      return 'bg-primary';
    } else if (type == LiNotificationToastColor.secondary) {
      return 'bg-secondary';
    } else if (type == LiNotificationToastColor.success) {
      return 'bg-success';
    } else if (type == LiNotificationToastColor.info) {
      return 'bg-info';
    } else if (type == LiNotificationToastColor.warning) {
      return 'bg-warning';
    } else if (type == LiNotificationToastColor.danger) {
      return 'bg-danger';
    } else if (type == LiNotificationToastColor.primary) {
      return 'bg-primary';
    } else if (type == LiNotificationToastColor.pink) {
      return 'bg-pink';
    } else if (type == LiNotificationToastColor.teal) {
      return 'bg-teal';
    } else if (type == LiNotificationToastColor.indigo) {
      return 'bg-indigo';
    } else {
      return 'bg-white';
    }
  }
}
