import 'package:limitless_ui/web_compat.dart';

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Converts a nullable browser [Selection] to its selected text.
///
/// This calls the DOM `Selection.toString()` method through
/// `dart:js_interop_unsafe` as a workaround for
/// https://github.com/dart-lang/sdk/issues/47942.
extension ToStringSelectionExtension on Selection? {
  /// Returns the text currently covered by this selection.
  ///
  /// The extension expects the receiver to contain a real [Selection]. A `null`
  /// receiver follows the previous package behavior and throws at runtime.
  String asString() {
    final selection = this as Selection;
    final result = (selection as JSObject).callMethod('toString'.toJS);
    return (result as JSString).toDart;
  }
}

/// Converts a non-null browser [Selection] to its selected text.
extension ToStringNullSafetySelectionExtension on Selection {
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

/// Adds convenience readers to browser [File] values.
extension HtmlFileExtension on File {
  /// Reads this file as an array buffer.
  ///
  /// The returned future completes with [FileReader.result] after the browser
  /// emits `load`.
  Future<dynamic> asArrayBuffer() async {
    final completer = Completer();
    final reader = FileReader();
    EventStreamProviders.loadEvent.forTarget(reader).listen((progressEvent) {
      final loadedFile = progressEvent.currentTarget as FileReader;
      completer.complete(loadedFile.result);
    });
    reader.readAsArrayBuffer(this);
    return completer.future;
  }
}
