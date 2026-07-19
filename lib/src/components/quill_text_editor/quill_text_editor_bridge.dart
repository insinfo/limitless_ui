import 'package:limitless_ui/web_compat.dart' as html;

//C:\MyDartProjects\limitless_ui\lib\src\components\quill_text_editor\quill_text_editor_bridge.dart
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'quill_interop.dart' as quill;

class LiQuillBridgeSelection {
  const LiQuillBridgeSelection({
    required this.index,
    required this.length,
  });

  final int index;
  final int length;
}

abstract class LiQuillTextEditorHandle {
  dynamic get rawInstance;

  void dispose();

  void onTextChange(void Function(String source) callback);

  void onSelectionChange(
    void Function(LiQuillBridgeSelection? selection) callback,
  );

  String getText();

  String getSemanticHtml();

  List<Map<String, dynamic>> getContentsAsDart();

  dynamic convertHtml(String html);

  LiQuillBridgeSelection? getSelection({bool focus = false});

  void setSelection(int index, int length, [String source = 'api']);

  void setContents(dynamic delta, [String source = 'api']);

  void setContentsDart(Map<String, dynamic> delta, [String source = 'api']);

  void insertText(int index, String text, [String source = 'user']);

  void deleteText(int index, int length, [String source = 'user']);

  void format(String name, dynamic value, [String source = 'user']);

  void focus();

  void blur();

  void enable(bool enabled);
}

/// Marker for handles backed by a real JavaScript Quill instance.
///
/// Keeping the typed instance on the Dart wrapper avoids runtime `is` checks
/// against the `quill.Quill` extension type, whose representation checks are
/// erased and backend-dependent.
abstract class LiJsQuillTextEditorHandle implements LiQuillTextEditorHandle {
  quill.Quill get quillInstance;
}

abstract class LiQuillTextEditorBridge {
  bool get isQuillAvailable;

  bool get isTableBetterAvailable;

  Object? getTableBetterKeyboardBindings();

  void registerSizeWhitelist(List<String> values);

  LiQuillTextEditorHandle createEditor({
    required html.Element container,
    required html.Element bounds,
    required String theme,
    required Map<String, dynamic> modules,
    String? placeholder,
    required bool readOnly,
  });
}

class DefaultLiQuillTextEditorBridge implements LiQuillTextEditorBridge {
  const DefaultLiQuillTextEditorBridge();

  @override
  bool get isQuillAvailable => (html.window as JSObject).has('Quill');

  @override
  bool get isTableBetterAvailable =>
      (html.window as JSObject).has('QuillTableBetter');

  @override
  Object? getTableBetterKeyboardBindings() {
    if (!isTableBetterAvailable) {
      return null;
    }
    final tableBetter =
        (html.window as JSObject).getProperty('QuillTableBetter'.toJS);
    if (tableBetter == null) {
      return null;
    }
    return (tableBetter as JSObject).getProperty('keyboardBindings'.toJS);
  }

  @override
  void registerSizeWhitelist(List<String> values) {
    try {
      final sizeAttributor =
          quill.Quill.import('attributors/style/size') as quill.Attributor;
      sizeAttributor.whitelist = quill.jsify(values);
      quill.Quill.register(sizeAttributor, true);
    } catch (_) {}
  }

  @override
  LiQuillTextEditorHandle createEditor({
    required html.Element container,
    required html.Element bounds,
    required String theme,
    required Map<String, dynamic> modules,
    String? placeholder,
    required bool readOnly,
  }) {
    final editor = quill.Quill(
      container,
      quill.QuillOptions(
        theme: theme,
        modules: quill.jsify(modules),
        placeholder: placeholder,
        readOnly: readOnly,
        bounds: bounds,
      ),
    );
    return _JsLiQuillTextEditorHandle(editor);
  }
}

class _JsLiQuillTextEditorHandle implements LiJsQuillTextEditorHandle {
  _JsLiQuillTextEditorHandle(this._editor);

  final quill.Quill _editor;

  @override
  quill.Quill get rawInstance => _editor;

  @override
  quill.Quill get quillInstance => _editor;

  @override
  void dispose() {
    _editor.blur();
    _editor.enable(false);
  }

  @override
  void onTextChange(void Function(String source) callback) {
    _editor.on(
      'text-change',
      ((JSAny? _, JSAny? __, JSAny? source) {
        callback((source as JSString?)?.toDart ?? '');
      }).toJS,
    );
  }

  @override
  void onSelectionChange(
    void Function(LiQuillBridgeSelection? selection) callback,
  ) {
    _editor.on(
      'selection-change',
      ((quill.Range? range, JSAny? _, JSAny? __) {
        if (range == null) {
          callback(null);
          return;
        }
        callback(
          LiQuillBridgeSelection(index: range.index, length: range.length),
        );
      }).toJS,
    );
  }

  @override
  String getText() => _editor.getText();

  @override
  String getSemanticHtml() => _editor.getSemanticHTML();

  @override
  List<Map<String, dynamic>> getContentsAsDart() => _editor.getContentsAsDart();

  @override
  dynamic convertHtml(String html) => _editor.clipboard.convert(html);

  @override
  LiQuillBridgeSelection? getSelection({bool focus = false}) {
    final range = _editor.getSelection(focus);
    if (range == null) {
      return null;
    }
    return LiQuillBridgeSelection(index: range.index, length: range.length);
  }

  @override
  void setSelection(int index, int length, [String source = 'api']) {
    _editor.setSelection(index.toJS, length.toJS, source);
  }

  @override
  void setContents(dynamic delta, [String source = 'api']) {
    _editor.setContents(delta as JSAny?, source);
  }

  @override
  void setContentsDart(Map<String, dynamic> delta, [String source = 'api']) {
    _editor.setContentsDart(delta, source);
  }

  @override
  void insertText(int index, String text, [String source = 'user']) {
    _editor.insertTextWithSource(index, text, source);
  }

  @override
  void deleteText(int index, int length, [String source = 'user']) {
    _editor.deleteText(index, length, source);
  }

  @override
  void format(String name, dynamic value, [String source = 'user']) {
    _editor.format(name, (value as Object?).jsify(), source);
  }

  @override
  void focus() => _editor.focus();

  @override
  void blur() => _editor.blur();

  @override
  void enable(bool enabled) => _editor.enable(enabled);
}

LiQuillTextEditorBridge _liQuillTextEditorBridge =
    const DefaultLiQuillTextEditorBridge();

LiQuillTextEditorBridge get liQuillTextEditorBridge => _liQuillTextEditorBridge;

void setLiQuillTextEditorBridgeForTesting(LiQuillTextEditorBridge? bridge) {
  _liQuillTextEditorBridge = bridge ?? const DefaultLiQuillTextEditorBridge();
}
