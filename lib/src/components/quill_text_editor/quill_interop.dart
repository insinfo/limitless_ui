@JS()
library;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

dynamic jsify(dynamic object) => js_util.jsify(object);

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
class Quill {
  external factory Quill(dynamic container, [QuillOptions? options]);

  external static dynamic import(String path);
  external static void register(dynamic pathOrType,
      [bool? suppressWarning, bool? overwrite]);

  external void on(String event, Function callback);
  external String getText([int? index, int? length]);
  external String getSemanticHTML([int? index, int? length]);
  external JsQuillDelta getContents([int? index, int? length]);
  external dynamic getModule(String name);
  external Clipboard get clipboard;
  external Range? getSelection([bool focus]);
  external void setSelection(dynamic index, [dynamic length, String? source]);
  external void setContents(dynamic delta, [String? source]);
  external void updateContents(dynamic delta, [String? source]);
  external void insertText(int index, String text,
      [dynamic formats, String? source]);
  external void deleteText(int index, int length, [String? source]);
  external void format(String name, dynamic value, [String? source]);
  external void focus();
  external void blur();
  external void enable([bool? enabled]);
}

extension QuillExtension on Quill {
  void setContentsDart(dynamic delta, [String? source]) {
    setContents(js_util.jsify(delta), source);
  }

  void updateContentsDart(dynamic delta, [String? source]) {
    updateContents(js_util.jsify(delta), source);
  }

  List<Map<String, dynamic>> getContentsAsDart([int? index, int? length]) {
    final jsDelta =
        index == null || length == null ? getContents() : getContents(index, length);
    final jsOps = js_util.getProperty(jsDelta, 'ops');
    final dartOps = js_util.dartify(jsOps) as List<dynamic>;
    return _deepListConvert(dartOps).cast<Map<String, dynamic>>();
  }
}

@JS()
@anonymous
class JsQuillDelta {
  external List<dynamic> get ops;
  external factory JsQuillDelta({List<dynamic>? ops});
}

@JS()
@anonymous
class QuillOptions {
  external factory QuillOptions({
    String? theme,
    dynamic modules,
    String? placeholder,
    bool? readOnly,
    dynamic bounds,
  });
}

@JS()
@anonymous
class Range {
  external int get index;
  external int get length;
  external factory Range({required int index, required int length});
}

@JS()
@anonymous
class Clipboard {
  external dynamic convert(String html);
}

@JS()
@anonymous
class Attributor {
  external set whitelist(dynamic value);
}
