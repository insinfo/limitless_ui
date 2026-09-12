/// The one place where this library's stacking order is decided.
///
/// Before `1.0.0-dev.42` the scale lived as literals in about fifteen files and
/// three languages — Dart, SCSS and an inline `style=` in a component template.
/// Nobody could answer "what sits above what" without grepping, and every new
/// overlay was a guess. Two guesses had already collided: the toast stack and
/// the dialog both drew at 2000, and the notification toast and the alert both
/// at 3000, so which one won was decided by the order of the nodes in the DOM.
///
/// ## The scale
///
/// | layer | value | why there |
/// |---|---|---|
/// | [anchored] | 1000 | attached to a field: above the page, below anything blocking |
/// | [anchoredMenu] | 1056 | one above the theme's modal, so a menu inside a modal is usable |
/// | [anchoredTooltip] | 1080 | the theme's own tooltip level |
/// | [anchoredPicker] | 1085 | above the tooltip, because a picker is interactive and a tooltip is not |
/// | [offcanvas] | 1150 | slides over the page, goes under a modal |
/// | [modal] | 1200 | plus [modalStep] for each stacked modal |
/// | [dialog] | 2000 | a question, so it comes over any modal |
/// | [toastStack] | 2100 | a notice has to be readable over the dialog it refers to |
/// | [alert] | 3000 | interrupts everything below to be answered |
/// | [notificationToast] | 3100 | same reasoning as [toastStack], one level up |
/// | [loadingTarget] | 50000 | covers its own container only |
/// | [loadingBody] | 500000 | covers the page, above everything, on purpose |
/// | [targetAlert] | 500100 | replaces a curtain that failed; has to be visible over it |
///
/// ## Why the curtain is on top, and what that costs
///
/// [loadingBody] outranks every dialog deliberately: the curtain exists to keep
/// the operator from navigating, clicking a save button twice or opening another
/// modal while an operation is still running, and a curtain that yielded to a
/// dialog would let exactly those clicks through.
///
/// The price is that a dialog raised while the curtain is up is born underneath
/// it, and with `await` that freezes the page — the `finally` that would hide the
/// curtain only runs once the operator answers. Hiding the curtain where the
/// operation ends is the application's job; [LiSimpleLoading.hideAll] is there
/// for an application that wants to enforce it in one place.
///
/// ## Moving the scale
///
/// Every field is mutable, so an application with its own stacking scale aligns
/// the library to it from `main()` without touching any call site:
///
/// ```dart
/// void main() {
///   LiOverlayLayers.modal = 3200;
///   LiOverlayLayers.dialog = 3400;
///   runApp(...);
/// }
/// ```
///
/// Components read these at the moment they open, so a value changed later still
/// applies to the next overlay.
library;

/// Stacking order of every overlay the library draws.
class LiOverlayLayers {
  LiOverlayLayers._();

  /// Anchored overlay with no special requirement: multi-select, tag filter.
  static int anchored = 1000;

  /// Menu portalled to the body: dropdown menu, select, typeahead, treeview.
  ///
  /// One above the theme's modal (1055) so a menu opened inside a modal is not
  /// swallowed by it.
  static int anchoredMenu = 1056;

  /// Tooltip, at the level the Limitless theme uses for its own.
  static int anchoredTooltip = 1080;

  /// Interactive picker: date, time, colour, date range.
  ///
  /// Above [anchoredTooltip] because a picker receives clicks and a tooltip does
  /// not — a tooltip covering a picker would eat them.
  static int anchoredPicker = 1085;

  /// Panel that slides over the page from an edge.
  ///
  /// Below [modal]: an offcanvas is navigation, a modal is a task. Before
  /// `dev.42` it sat at 1201, which put it under the *second* stacked modal
  /// (1210) while staying over the first — an order nobody chose.
  static int offcanvas = 1150;

  /// First modal of the stack. Each one above it gets [modalStep] more.
  static int modal = 1200;

  /// Distance between two stacked modals.
  static int modalStep = 10;

  /// Blocking dialog: alert, confirmation, prompt.
  static int dialog = 2000;

  /// Stack of toasts.
  ///
  /// Above [dialog] on purpose: a toast reports something that just happened,
  /// and it is usually about the very dialog on screen. They shared 2000 until
  /// `dev.42`, so the winner was whichever node came later in the DOM.
  static int toastStack = 2100;

  /// Modal alert (`SweetAlert`), which interrupts to be answered.
  static int alert = 3000;

  /// Notification toast. Above [alert] for the same reason [toastStack] is
  /// above [dialog]; they shared 3000 until `dev.42`.
  static int notificationToast = 3100;

  /// Loading curtain scoped to one element. Covers its own container, not the
  /// page, so it stays under everything blocking.
  static int loadingTarget = 50000;

  /// Full-page loading curtain. Above everything — see the class docs.
  static int loadingBody = 500000;

  /// Contextual error panel pinned to an element ([LiTargetAlert]).
  ///
  /// Above [loadingBody] because it is what replaces a curtain that failed:
  /// the load ended badly and the panel says so. Under a curtain it would be
  /// invisible, and the operator would be left with a spinner that never stops.
  static int targetAlert = 500100;

  /// Distance from an overlay to the blocking layer it has to clear.
  static int stackOffset = 1;
}
