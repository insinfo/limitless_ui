// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/quill_text_editor/li_quill_text_editor_bridge_test.dart
//
// Exercises DefaultLiQuillTextEditorBridge against a scripted window.Quill
// that mimics the Quill 2.x API surface the bridge touches, so regressions
// at the JS boundary (argument shapes, prototype patches) fail here even
// though the component tests run on Dart fakes.

@TestOn('browser')
library;

import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:js/js.dart' show allowInterop;
import 'package:limitless_ui/src/components/quill_text_editor/quill_text_editor_bridge.dart';
import 'package:test/test.dart';

// Mirrors the parts of Quill 2.0.3 the bridge interacts with. Notably,
// clipboard.convert destructures `{ html, text }` from its first argument
// exactly like the real bundle: a raw string therefore produces
// `html: undefined` and no FROM_HTML marker in the returned delta.
const String _fakeQuillScript = r'''
(function () {
  window.__fakeQuill = { imports: {} };

  class FakeToolbar {
    getTableBetter() {
      return this.quill.getModule('table-better');
    }
  }

  function FakeDelta() {
    this.ops = [{ insert: 'fresh-delta' }];
  }

  window.__fakeQuill.imports['modules/toolbar'] = FakeToolbar;
  window.__fakeQuill.imports['delta'] = FakeDelta;
  window.__fakeQuill.FakeToolbar = FakeToolbar;

  class FakeQuill {
    constructor(container, options) {
      this.container = container;
      this.options = options || {};
      window.__fakeQuill.lastInstance = this;
      this.clipboard = {
        matchers: [],
        convert(input) {
          const { html, text } = input;
          window.__fakeQuill.lastConvert = {
            argType: typeof input,
            html: html,
            text: text,
          };
          if (!html) {
            return { ops: [{ insert: text || '' }] };
          }
          return { ops: [{ insert: 'FROM_HTML:' + html }] };
        },
        addMatcher(selector, callback) {
          this.matchers.push({ selector: selector, callback: callback });
        },
      };
    }

    static import(path) {
      return window.__fakeQuill.imports[path];
    }

    static register() {}

    getModule(name) {
      return undefined;
    }

    on() {}
    getText() { return ''; }
    getSemanticHTML() { return ''; }
    getContents() { return { ops: [] }; }
    getSelection() { return null; }
    setSelection() {}
    setContents(delta, source) {
      window.__fakeQuill.lastSetContents = { delta: delta, source: source };
    }
    updateContents() {}
    insertText() {}
    deleteText() {}
    format() {}
    focus() {}
    blur() {}
    enable() {}
  }

  window.Quill = FakeQuill;
})();
''';

Object _fakeQuillState() =>
    js_util.getProperty<Object>(html.window, '__fakeQuill');

LiQuillTextEditorHandle _createEditor(DefaultLiQuillTextEditorBridge bridge) {
  final container = html.DivElement();
  return bridge.createEditor(
    container: container,
    bounds: container,
    theme: 'snow',
    modules: <String, dynamic>{},
    readOnly: false,
  );
}

void main() {
  setUp(() {
    html.document.head!.append(html.ScriptElement()..text = _fakeQuillScript);
  });

  test('convertHtml passes an { html } object to clipboard.convert', () {
    const bridge = DefaultLiQuillTextEditorBridge();
    final handle = _createEditor(bridge);

    final delta = handle.convertHtml('<p>Olá</p>');

    final lastConvert =
        js_util.getProperty<Object>(_fakeQuillState(), 'lastConvert');
    expect(js_util.getProperty(lastConvert, 'argType'), 'object');
    expect(js_util.getProperty(lastConvert, 'html'), '<p>Olá</p>');

    final ops = js_util.getProperty<Object>(delta as Object, 'ops');
    final firstOp = js_util.getProperty<Object>(ops, '0');
    expect(js_util.getProperty(firstOp, 'insert'), 'FROM_HTML:<p>Olá</p>');
  });

  test('setContents forwards the converted delta with the given source', () {
    const bridge = DefaultLiQuillTextEditorBridge();
    final handle = _createEditor(bridge);

    handle.setContents(handle.convertHtml('<p>x</p>'), 'silent');

    final lastSetContents =
        js_util.getProperty<Object>(_fakeQuillState(), 'lastSetContents');
    expect(js_util.getProperty(lastSetContents, 'source'), 'silent');
    final delta = js_util.getProperty<Object>(lastSetContents, 'delta');
    final firstOp = js_util.getProperty<Object>(
      js_util.getProperty<Object>(delta, 'ops'),
      '0',
    );
    expect(js_util.getProperty(firstOp, 'insert'), 'FROM_HTML:<p>x</p>');
  });

  group('getTableBetter toolbar patch', () {
    Object newToolbarInstance({Object? tableBetterModule}) {
      final toolbarClass =
          js_util.getProperty<Object>(_fakeQuillState(), 'FakeToolbar');
      final instance = js_util.callConstructor<Object>(
        toolbarClass,
        const <Object?>[],
      );
      final quill = js_util.newObject<Object>();
      js_util.setProperty(
        quill,
        'getModule',
        allowInterop((String name) =>
            name == 'table-better' ? tableBetterModule : null),
      );
      js_util.setProperty(instance, 'quill', quill);
      return instance;
    }

    test('falls back to an empty object when the module is missing', () {
      const bridge = DefaultLiQuillTextEditorBridge();
      _createEditor(bridge);

      final toolbar = newToolbarInstance();
      final result = js_util.callMethod<Object?>(
        toolbar,
        'getTableBetter',
        const <Object?>[],
      );

      // The pre-patch behavior returned undefined/null here, which made
      // quill-table-better's `const { cellSelection } = ...` throw on every
      // toolbar click of editors without table support.
      expect(result, isNotNull);
      expect(js_util.getProperty(result!, 'cellSelection'), isNull);
    });

    test('still resolves the real module when it is registered', () {
      const bridge = DefaultLiQuillTextEditorBridge();
      _createEditor(bridge);

      final module = js_util.newObject<Object>();
      js_util.setProperty(module, 'marker', 'real-module');
      final toolbar = newToolbarInstance(tableBetterModule: module);
      final result = js_util.callMethod<Object?>(
        toolbar,
        'getTableBetter',
        const <Object?>[],
      );

      expect(js_util.getProperty(result!, 'marker'), 'real-module');
    });

    test('is applied once and marker-guarded across editors', () {
      const bridge = DefaultLiQuillTextEditorBridge();
      _createEditor(bridge);

      final toolbarClass =
          js_util.getProperty<Object>(_fakeQuillState(), 'FakeToolbar');
      final proto = js_util.getProperty<Object>(toolbarClass, 'prototype');
      expect(
        js_util.getProperty(proto, '_liQuillGetTableBetterPatched'),
        isTrue,
      );
      final patched = js_util.getProperty<Object>(proto, 'getTableBetter');

      _createEditor(bridge);

      expect(
        js_util.getProperty<Object>(proto, 'getTableBetter'),
        same(patched),
      );
    });
  });

  test('blockImageInserts registers an img matcher returning a fresh delta',
      () {
    const bridge = DefaultLiQuillTextEditorBridge();
    final handle = _createEditor(bridge);

    handle.blockImageInserts();

    final instance =
        js_util.getProperty<Object>(_fakeQuillState(), 'lastInstance');
    final clipboard = js_util.getProperty<Object>(instance, 'clipboard');
    final matchers = js_util.getProperty<Object>(clipboard, 'matchers');
    expect(js_util.getProperty(matchers, 'length'), 1);

    final matcher = js_util.getProperty<Object>(matchers, '0');
    expect(js_util.getProperty(matcher, 'selector'), 'img');

    final callback = js_util.getProperty<Object>(matcher, 'callback');
    final replacement = js_util.callMethod<Object?>(
      callback,
      'call',
      <Object?>[null, js_util.newObject<Object>(), js_util.newObject<Object>()],
    );

    // The matcher must discard the matched <img> by returning an empty
    // freshly-constructed delta (FakeDelta stamps its ops so we can tell).
    final firstOp = js_util.getProperty<Object>(
      js_util.getProperty<Object>(replacement!, 'ops'),
      '0',
    );
    expect(js_util.getProperty(firstOp, 'insert'), 'fresh-delta');
  });
}
