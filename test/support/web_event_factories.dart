import 'package:web/web.dart' as web;

/// Creates a bubbling DOM event for component tests.
///
/// Native Web IDL event constructors default to non-bubbling events. Most
/// Angular handlers exercised by this suite depend on browser-style event
/// propagation, so the test intent is explicit at the call site.
web.Event bubblingEvent(
  String type, {
  bool bubbles = true,
  bool cancelable = true,
}) =>
    web.Event(
      type,
      web.EventInit(bubbles: bubbles, cancelable: cancelable),
    );

web.MouseEvent bubblingMouseEvent(
  String type, {
  web.Window? view,
  int detail = 0,
  int screenX = 0,
  int screenY = 0,
  int clientX = 0,
  int clientY = 0,
  int button = 0,
  bool bubbles = true,
  bool cancelable = true,
  bool ctrlKey = false,
  bool altKey = false,
  bool shiftKey = false,
  bool metaKey = false,
  web.EventTarget? relatedTarget,
}) =>
    web.MouseEvent(
      type,
      web.MouseEventInit(
        view: view ?? web.window,
        detail: detail,
        screenX: screenX,
        screenY: screenY,
        clientX: clientX,
        clientY: clientY,
        button: button,
        bubbles: bubbles,
        cancelable: cancelable,
        ctrlKey: ctrlKey,
        altKey: altKey,
        shiftKey: shiftKey,
        metaKey: metaKey,
        relatedTarget: relatedTarget,
      ),
    );

web.KeyboardEvent bubblingKeyboardEvent(
  String type, {
  web.Window? view,
  bool bubbles = true,
  bool cancelable = true,
  String key = '',
  String code = '',
  int location = 1,
  bool ctrlKey = false,
  bool altKey = false,
  bool shiftKey = false,
  bool metaKey = false,
}) =>
    web.KeyboardEvent(
      type,
      web.KeyboardEventInit(
        view: view ?? web.window,
        bubbles: bubbles,
        cancelable: cancelable,
        key: key,
        code: code,
        location: location,
        ctrlKey: ctrlKey,
        altKey: altKey,
        shiftKey: shiftKey,
        metaKey: metaKey,
      ),
    );
