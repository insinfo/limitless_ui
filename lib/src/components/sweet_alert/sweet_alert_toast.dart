import 'sweet_alert.dart';

class SweetAlertSimpleToast {
  static SweetAlertController showToast(
    String message, {
    String? title,
    SweetAlertType type = SweetAlertType.success,
    SweetAlertPosition position = SweetAlertPosition.topEnd,
    int? duration = 3000,
    bool timerProgressBar = true,
  }) {
    return SweetAlert.toast(
      message,
      title: title,
      type: type,
      position: position,
      timer: duration == null ? null : Duration(milliseconds: duration),
      timerProgressBar: timerProgressBar,
    );
  }

  /// [duration] in milliseconds
  static SweetAlertController showWarningToast(
    String message, {
    int? duration = 3000,
  }) {
    return showToast(
      message,
      type: SweetAlertType.warning,
      position: SweetAlertPosition.top,
      duration: duration,
    );
  }

  static SweetAlertController showSuccessToast(
    String message, {
    int? duration = 3000,
  }) {
    return showToast(
      message,
      type: SweetAlertType.success,
      position: SweetAlertPosition.topEnd,
      duration: duration,
    );
  }
}
