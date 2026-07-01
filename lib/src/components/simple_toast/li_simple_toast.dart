import '../sweet_alert/sweet_alert_toast.dart';

/// Lightweight SweetAlert-inspired toast helper for quick feedback messages.
class LiSimpleToast {
  /// Shows a warning toast.
  static void showWarning(String message, {int duration = 3000}) {
    SweetAlertSimpleToast.showWarningToast(message, duration: duration);
  }

  /// Shows a success toast.
  static void showSuccess(String message, {int duration = 3000}) {
    SweetAlertSimpleToast.showSuccessToast(message, duration: duration);
  }
}
