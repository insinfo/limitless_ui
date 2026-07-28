//C:\MyDartProjects\limitless_ui\lib\src\components\quill_text_editor\quill_text_editor_bridge.dart
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:js/js.dart' show allowInterop;

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
  bool get isQuillAvailable => js_util.hasProperty(html.window, 'Quill');

  @override
  bool get isTableBetterAvailable =>
      js_util.hasProperty(html.window, 'QuillTableBetter');

  @override
  Object? getTableBetterKeyboardBindings() {
    if (!isTableBetterAvailable) {
      return null;
    }
    final tableBetter = js_util.getProperty<Object?>(
      html.window,
      'QuillTableBetter',
    );
    if (tableBetter == null) {
      return null;
    }
    return js_util.getProperty<Object?>(tableBetter, 'keyboardBindings');
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

class _JsLiQuillTextEditorHandle implements LiQuillTextEditorHandle {
  _JsLiQuillTextEditorHandle(this._editor);

  final quill.Quill _editor;

  @override
  quill.Quill get rawInstance => _editor;

  @override
  void dispose() {
    _editor.blur();
    _editor.enable(false);
  }

  @override
  void onTextChange(void Function(String source) callback) {
    _editor.on(
      'text-change',
      allowInterop((dynamic _, dynamic __, dynamic source) {
        callback(source?.toString() ?? '');
      }),
    );
  }

  @override
  void onSelectionChange(
    void Function(LiQuillBridgeSelection? selection) callback,
  ) {
    _editor.on(
      'selection-change',
      allowInterop((dynamic range, dynamic _, dynamic __) {
        if (range == null) {
          callback(null);
          return;
        }
        callback(
          LiQuillBridgeSelection(
            index: js_util.getProperty<int>(range, 'index'),
            length: js_util.getProperty<int>(range, 'length'),
          ),
        );
      }),
    );
  }

  @override
  String getText() => _editor.getText();

  @override
  String getSemanticHtml() => _editor.getSemanticHTML();

  @override
  List<Map<String, dynamic>> getContentsAsDart() => _editor.getContentsAsDart();

  @override
  dynamic convertHtml(String html) =>
      _editor.clipboard.convert(quill.ClipboardConvertInput(html: html));

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
    _editor.setSelection(index, length, source);
  }

  @override
  void setContents(dynamic delta, [String source = 'api']) {
    _editor.setContents(delta, source);
  }

  @override
  void setContentsDart(Map<String, dynamic> delta, [String source = 'api']) {
    _editor.setContentsDart(delta, source);
  }

  @override
  void insertText(int index, String text, [String source = 'user']) {
    js_util.callMethod<void>(_editor, 'insertText', <Object?>[
      index,
      text,
      source,
    ]);
  }

  @override
  void deleteText(int index, int length, [String source = 'user']) {
    _editor.deleteText(index, length, source);
  }

  @override
  void format(String name, dynamic value, [String source = 'user']) {
    _editor.format(name, value, source);
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