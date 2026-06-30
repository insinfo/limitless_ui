import 'dart:async';
import 'dart:js_util' as js_util;
import 'dart:html';

/// Converts a nullable browser [Selection] to its selected text.
///
/// This calls the DOM `Selection.toString()` method through `dart:js_util` as
/// a workaround for https://github.com/dart-lang/sdk/issues/47942.
extension ToStringSelectionExtension on Selection? {
  /// Returns the text currently covered by this selection.
  ///
  /// The extension expects the receiver to contain a real [Selection]. A `null`
  /// receiver follows the previous package behavior and throws at runtime.
  String asString() {
    var result = js_util.callMethod(this as Selection, 'toString', []);
    return result.toString();
  }
}

/// Converts a non-null browser [Selection] to its selected text.
extension ToStringNullSafetySelectionExtension on Selection {
  /// Returns the text currently covered by this selection.
  ///
  /// The DOM implementation is invoked through `dart:js_util` to avoid the
  /// SDK interop issue documented in
  /// https://github.com/dart-lang/sdk/issues/47942.
  String asString() {
    var result = js_util.callMethod(this, 'toString', []);
    return result.toString();
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
    reader.onLoad.listen((progressEvent) {
      final loadedFile = progressEvent.currentTarget as FileReader;
      completer.complete(loadedFile.result);
    });
    reader.readAsArrayBuffer(this);
    return completer.future;
  }
}
