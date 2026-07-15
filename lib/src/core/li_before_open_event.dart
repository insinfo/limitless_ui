/// A cancelable event emitted right before a component opens.
///
/// Calling [preventDefault] keeps the component closed, so it can be used to
/// gate opening on something the consumer has to resolve first — a permission
/// check, an unsaved-changes confirmation, or a required field elsewhere in the
/// form.
///
/// The stream carrying this event is synchronous, so [preventDefault] must be
/// called from the handler itself. An `await` before it happens too late: the
/// component has already opened by then. To gate opening on asynchronous work,
/// prevent the default, run the work, and call `openDropdown()` when it
/// resolves.
class LiBeforeOpenEvent {
  bool _defaultPrevented = false;

  bool get defaultPrevented => _defaultPrevented;

  /// Cancels the open, leaving the component closed.
  void preventDefault() {
    _defaultPrevented = true;
  }
}
