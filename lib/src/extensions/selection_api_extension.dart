import 'package:web/web.dart' as web;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Converts a nullable browser [web.Selection] to its selected text.
///
/// This calls the DOM `web.Selection.toString()` method through
/// `dart:js_interop_unsafe` as a workaround for
/// https://github.com/dart-lang/sdk/issues/47942.
extension ToStringSelectionExtension on web.Selection? {
  /// Returns the text currently covered by this selection.
  ///
  /// The extension expects the receiver to contain a real [web.Selection]. A `null`
  /// receiver follows the previous package behavior and throws at runtime.
  String asString() {
    final selection = this as web.Selection;
    final result = (selection as JSObject).callMethod('toString'.toJS);
    return (result as JSString).toDart;
  }
}

/// Converts a non-null browser [web.Selection] to its selected text.
extension ToStringNullSafetySelectionExtension on web.Selection {
  /// Returns the text currently covered by this selection.
  ///
  /// The DOM implementation is invoked through `dart:js_interop_unsafe` to
  /// avoid the SDK interop issue documented in
  /// https://github.com/dart-lang/sdk/issues/47942.
  String asString() {
    final result = (this as JSObject).callMethod('toString'.toJS);
    return (result as JSString).toDart;
  }
}

/// Adds convenience readers to browser [web.File] values.
extension HtmlFileExtension on web.File {
  /// Reads this file as an array buffer.
  ///
  /// The returned future completes with [web.FileReader.result] after the browser
  /// emits `load`.
  Future<dynamic> asArrayBuffer() async {
    final completer = Completer();
    final reader = web.FileReader();
    web.EventStreamProviders.loadEvent
        .forTarget(reader)
        .listen((progressEvent) {
      final loadedFile = progressEvent.currentTarget as web.FileReader;
      completer.complete(loadedFile.result);
    });
    reader.readAsArrayBuffer(this);
    return completer.future;
  }
}
