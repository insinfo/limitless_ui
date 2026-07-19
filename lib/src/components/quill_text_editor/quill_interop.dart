/// Quill.js interop bindings, written with `dart:js_interop` extension types
/// (previously `package:js` classes + `dart:js_util`).
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

JSAny? jsify(Object? object) => object.jsify();

Map<String, dynamic> _deepMapConvert(Map<Object?, Object?> map) {
  final newMap = <String, dynamic>{};
  map.forEach((key, value) {
    final stringKey = key as String?;
    if (stringKey == null) {
      return;
    }
    if (value is Map<Object?, Object?>) {
      newMap[stringKey] = _deepMapConvert(value);
    } else if (value is List) {
      newMap[stringKey] = _deepListConvert(value);
    } else {
      newMap[stringKey] = value;
    }
  });
  return newMap;
}

List<dynamic> _deepListConvert(List<dynamic> list) {
  return list.map((item) {
    if (item is Map<Object?, Object?>) {
      return _deepMapConvert(item);
    }
    if (item is List) {
      return _deepListConvert(item);
    }
    return item;
  }).toList(growable: false);
}

@JS('Quill')
extension type Quill._(JSObject _) implements JSObject {
  external factory Quill(JSObject container, [QuillOptions options]);

  external static JSAny? import(String path);
  external static void register(JSAny? pathOrType,
      [bool suppressWarning, bool overwrite]);

  external void on(String event, JSFunction callback);
  external String getText([int index, int length]);
  external String getSemanticHTML([int index, int length]);
  external JsQuillDelta getContents([int index, int length]);
  external JSAny? getModule(String name);
  external Clipboard get clipboard;
  external Range? getSelection([bool focus]);
  external void setSelection(JSAny? index, [JSAny? length, String source]);
  external void setContents(JSAny? delta, [String source]);
  external void updateContents(JSAny? delta, [String source]);
  external void insertText(int index, String text,
      [JSAny? formats, String source]);
  @JS('insertText')
  external void insertTextWithSource(int index, String text, String source);
  external void deleteText(int index, int length, [String source]);
  external void format(String name, JSAny? value, [String source]);
  external void focus();
  external void blur();
  external void enable([bool enabled]);
}

extension QuillExtension on Quill {
  void setContentsDart(Object? delta, [String source = 'api']) {
    setContents(delta.jsify(), source);
  }

  void updateContentsDart(Object? delta, [String source = 'api']) {
    updateContents(delta.jsify(), source);
  }

  List<Map<String, dynamic>> getContentsAsDart([int? index, int? length]) {
    final jsDelta = index == null || length == null
        ? getContents()
        : getContents(index, length);
    final jsOps = (jsDelta as JSObject).getProperty('ops'.toJS);
    final dartOps = jsOps.dartify() as List<dynamic>;
    return _deepListConvert(dartOps).cast<Map<String, dynamic>>();
  }
}

extension type JsQuillDelta._(JSObject _) implements JSObject {
  external JSArray<JSAny?>? get ops;
  external factory JsQuillDelta({JSArray<JSAny?>? ops});
}

extension type QuillOptions._(JSObject _) implements JSObject {
  external factory QuillOptions({
    String? theme,
    JSAny? modules,
    String? placeholder,
    bool? readOnly,
    JSAny? bounds,
  });
}

extension type Range._(JSObject _) implements JSObject {
  external int get index;
  external int get length;
  external factory Range({required int index, required int length});
}

extension type Clipboard._(JSObject _) implements JSObject {
  external JSAny? convert(String html);
}

extension type Attributor._(JSObject _) implements JSObject {
  external set whitelist(JSAny? value);
}
