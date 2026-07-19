/// Compatibility layer used by the `package:web` migration (ngx9 / 3.x line).
///
/// The public `package:limitless_ui/web_compat.dart` library reexports this
/// implementation together with `package:web/web.dart`. Call sites therefore
/// use one import and one prefix while keeping the transitional aliases and
/// helpers (`html.DivElement`, `element.onClick`, `element.classes`); the
/// underlying DOM types are the `package:web` extension types.
///
/// It provides:
/// - `typedef` aliases for the `dart:html` type names (`HtmlElement`,
///   `DivElement`, `CssStyleDeclaration`, ...);
/// - transitional `createXxxElement()` factories that centralize legacy
///   creation semantics and specialized input defaults. Most corresponding
///   `package:web` 1.1.1 element types also have canonical constructors, which
///   new code should prefer;
/// - `liEvent`/`liMouseEvent`/`liKeyboardEvent` event factories that keep the
///   `dart:html` defaults (`bubbles: true`, settable `keyCode`);
/// - `onXxx` event-stream getters, `classes`, `attributes`-style helpers,
///   `text`, `style`-on-`Element`, `parent`, `nodes` and friends as
///   extensions;
/// - Dart-callback wrappers for `MutationObserver`, `ResizeObserver` and
///   `IntersectionObserver` (the public facade hides the conflicting raw web
///   types while exporting these wrappers);
/// - `KeyCode`, `NodeTreeSanitizer` and `Url` stand-ins.
library;

import 'dart:async';
import 'dart:collection';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:ngx_dart/security.dart' show DomSanitizationService;
import 'package:web/web.dart' as web;

// ---------------------------------------------------------------------------
// dart:html type-name aliases
// ---------------------------------------------------------------------------

// `package:web`'s helper layer (helpers/renames.dart) also carries some of
// these aliases, but marked @Deprecated; importers hide those and use these.
typedef HtmlElement = web.HTMLElement;
typedef ImageElement = web.HTMLImageElement;
typedef CanvasElement = web.HTMLCanvasElement;
typedef AudioElement = web.HTMLAudioElement;
typedef VideoElement = web.HTMLVideoElement;
typedef CssStyleDeclaration = web.CSSStyleDeclaration;
typedef BodyElement = web.HTMLBodyElement;
typedef DivElement = web.HTMLDivElement;
typedef SpanElement = web.HTMLSpanElement;
typedef InputElement = web.HTMLInputElement;
typedef TextInputElement = web.HTMLInputElement;
typedef CheckboxInputElement = web.HTMLInputElement;
typedef RadioButtonInputElement = web.HTMLInputElement;
typedef FileUploadInputElement = web.HTMLInputElement;
typedef ButtonElement = web.HTMLButtonElement;
typedef TextAreaElement = web.HTMLTextAreaElement;
typedef SelectElement = web.HTMLSelectElement;
typedef OptionElement = web.HTMLOptionElement;
typedef AnchorElement = web.HTMLAnchorElement;
typedef LIElement = web.HTMLLIElement;
typedef UListElement = web.HTMLUListElement;
typedef OListElement = web.HTMLOListElement;
typedef StyleElement = web.HTMLStyleElement;
typedef ScriptElement = web.HTMLScriptElement;
typedef LabelElement = web.HTMLLabelElement;
typedef IFrameElement = web.HTMLIFrameElement;
typedef FormElement = web.HTMLFormElement;
typedef HeadingElement = web.HTMLHeadingElement;
typedef ParagraphElement = web.HTMLParagraphElement;
typedef PreElement = web.HTMLPreElement;
typedef TemplateElement = web.HTMLTemplateElement;
typedef TableElement = web.HTMLTableElement;
typedef TableRowElement = web.HTMLTableRowElement;
typedef TableCellElement = web.HTMLTableCellElement;
typedef TableSectionElement = web.HTMLTableSectionElement;
typedef MediaElement = web.HTMLMediaElement;
typedef Rectangle<T extends num> = math.Rectangle<T>;

// ---------------------------------------------------------------------------
// Element factories (dart:html element constructors)
// ---------------------------------------------------------------------------

T _create<T extends JSObject>(String tag) =>
    web.document.createElement(tag) as T;

web.HTMLDivElement createDivElement() => _create('div');
web.HTMLSpanElement createSpanElement() => _create('span');
web.HTMLButtonElement createButtonElement() => _create('button');
web.HTMLLIElement createLIElement() => _create('li');
web.HTMLUListElement createUListElement() => _create('ul');
web.HTMLOListElement createOListElement() => _create('ol');
web.HTMLTextAreaElement createTextAreaElement() => _create('textarea');
web.HTMLStyleElement createStyleElement() => _create('style');
web.HTMLOptionElement createOptionElement() => _create('option');
web.HTMLLabelElement createLabelElement() => _create('label');
web.HTMLSelectElement createSelectElement() => _create('select');
web.HTMLImageElement createImageElement({String? src}) {
  final web.HTMLImageElement img = _create('img');
  if (src != null) img.src = src;
  return img;
}

web.HTMLIFrameElement createIFrameElement() => _create('iframe');
web.HTMLCanvasElement createCanvasElement({int? width, int? height}) {
  final web.HTMLCanvasElement canvas = _create('canvas');
  if (width != null) canvas.width = width;
  if (height != null) canvas.height = height;
  return canvas;
}

web.HTMLAudioElement createAudioElement([String? src]) {
  final web.HTMLAudioElement audio = _create('audio');
  if (src != null) audio.src = src;
  return audio;
}

web.HTMLAnchorElement createAnchorElement({String? href}) {
  final web.HTMLAnchorElement a = _create('a');
  if (href != null) a.href = href;
  return a;
}

web.HTMLParagraphElement createParagraphElement() => _create('p');

web.HTMLInputElement createInputElement({String? type}) {
  final web.HTMLInputElement input = _create('input');
  if (type != null) input.type = type;
  return input;
}

web.HTMLInputElement createCheckboxInputElement() =>
    createInputElement(type: 'checkbox');
web.HTMLInputElement createRadioButtonInputElement() =>
    createInputElement(type: 'radio');
web.HTMLInputElement createFileUploadInputElement() =>
    createInputElement(type: 'file');

web.HTMLHeadingElement createHeadingElement(int level) {
  assert(level >= 1 && level <= 6);
  return _create('h$level');
}

/// Returns [value] as a DOM element when it is a JavaScript `Element`.
///
/// Public Angular inputs often arrive as `Object?`. Casting an arbitrary Dart
/// object directly to [JSAny] can throw under dart2wasm, so the representation
/// check is contained here and safely returns `null` for non-JS values.
web.Element? liElementOrNull(Object? value) {
  if (value == null) return null;
  try {
    final jsValue = value as JSAny;
    return jsValue.isA<web.Element>() ? jsValue as web.Element : null;
  } on TypeError {
    return null;
  }
}

/// Returns [value] as a DOM file when it is a JavaScript `File`.
///
/// As with [liElementOrNull], the guarded representation cast keeps ordinary
/// Dart values from throwing when this code is compiled to dart2wasm.
web.File? liFileOrNull(Object? value) {
  if (value == null) return null;
  try {
    final jsValue = value as JSAny;
    return jsValue.isA<web.File>() ? jsValue as web.File : null;
  } on TypeError {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Event factories (dart:html event constructors, with dart:html defaults)
// ---------------------------------------------------------------------------

web.Event liEvent(
  String type, {
  bool canBubble = true,
  bool cancelable = true,
}) =>
    web.Event(
      type,
      web.EventInit(bubbles: canBubble, cancelable: cancelable),
    );

web.CustomEvent liCustomEvent(
  String type, {
  bool canBubble = true,
  bool cancelable = true,
  Object? detail,
}) =>
    web.CustomEvent(
      type,
      web.CustomEventInit(
        bubbles: canBubble,
        cancelable: cancelable,
        detail: detail?.jsify(),
      ),
    );

web.MouseEvent liMouseEvent(
  String type, {
  web.Window? view,
  int detail = 0,
  int screenX = 0,
  int screenY = 0,
  int clientX = 0,
  int clientY = 0,
  int button = 0,
  bool canBubble = true,
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
        bubbles: canBubble,
        cancelable: cancelable,
        ctrlKey: ctrlKey,
        altKey: altKey,
        shiftKey: shiftKey,
        metaKey: metaKey,
        relatedTarget: relatedTarget,
      ),
    );

web.KeyboardEvent liKeyboardEvent(
  String type, {
  web.Window? view,
  bool canBubble = true,
  bool cancelable = true,
  String key = '',
  String code = '',
  int location = 1,
  int? keyCode,
  bool ctrlKey = false,
  bool altKey = false,
  bool shiftKey = false,
  bool metaKey = false,
}) {
  final init = web.KeyboardEventInit(
    view: view ?? web.window,
    bubbles: canBubble,
    cancelable: cancelable,
    key: key,
    code: code,
    location: location,
    ctrlKey: ctrlKey,
    altKey: altKey,
    shiftKey: shiftKey,
    metaKey: metaKey,
  );
  if (keyCode != null) {
    // `keyCode` is a legacy member Chrome honors when present in the init
    // dictionary but package:web does not expose on KeyboardEventInit.
    (init as JSObject).setProperty('keyCode'.toJS, keyCode.toJS);
    (init as JSObject).setProperty('which'.toJS, keyCode.toJS);
  }
  return web.KeyboardEvent(type, init);
}

web.File liFile(List<Object> parts, String name, {String? type}) => web.File(
      _blobParts(parts),
      name,
      type == null ? web.FilePropertyBag() : web.FilePropertyBag(type: type),
    );

web.Blob liBlob(List<Object> parts, [String? type]) => web.Blob(
      _blobParts(parts),
      type == null ? web.BlobPropertyBag() : web.BlobPropertyBag(type: type),
    );

JSArray<web.BlobPart> _blobParts(List<Object> parts) => [
      for (final part in parts)
        switch (part) {
          final String s => s.toJS,
          final List<int> bytes => Uint8List.fromList(bytes).toJS,
          _ => part.jsify()!,
        }
    ].toJS;

// ---------------------------------------------------------------------------
// Event streams (dart:html `onXxx` getters)
// ---------------------------------------------------------------------------

extension LiDocumentEventStreams on web.Document {
  Stream<web.MouseEvent> get onClick =>
      web.EventStreamProviders.clickEvent.forTarget(this);
  Stream<web.MouseEvent> get onMouseDown =>
      web.EventStreamProviders.mouseDownEvent.forTarget(this);
  Stream<web.MouseEvent> get onMouseUp =>
      web.EventStreamProviders.mouseUpEvent.forTarget(this);
  Stream<web.MouseEvent> get onMouseMove =>
      web.EventStreamProviders.mouseMoveEvent.forTarget(this);
  Stream<web.KeyboardEvent> get onKeyDown =>
      web.EventStreamProviders.keyDownEvent.forTarget(this);
  Stream<web.KeyboardEvent> get onKeyUp =>
      web.EventStreamProviders.keyUpEvent.forTarget(this);
  Stream<web.Event> get onScroll =>
      web.EventStreamProviders.scrollEvent.forTarget(this);
  Stream<web.TouchEvent> get onTouchStart =>
      web.EventStreamProviders.touchStartEvent.forTarget(this);
  Stream<web.TouchEvent> get onTouchMove =>
      web.EventStreamProviders.touchMoveEvent.forTarget(this);
  Stream<web.TouchEvent> get onTouchEnd =>
      web.EventStreamProviders.touchEndEvent.forTarget(this);
  Stream<web.Event> get onFullscreenChange =>
      web.EventStreamProviders.fullscreenChangeEvent.forTarget(this);
  Stream<web.Event> get onSelectionChange =>
      const web.EventStreamProvider<web.Event>('selectionchange')
          .forTarget(this);
}

// ---------------------------------------------------------------------------
// Element helpers (dart:html members missing from package:web)
// ---------------------------------------------------------------------------

/// A live `dart:html` `CssClassSet`-style view over [web.DOMTokenList].
///
/// `CssClassSet` implemented `Set<String>`. Keeping that contract matters to
/// generic collection consumers such as test matchers, in addition to the
/// explicit `add`/`remove` helpers used by components.
class LiCssClassSet extends SetBase<String> {
  final web.DOMTokenList _list;

  LiCssClassSet(this._list);

  @override
  bool contains(Object? element) =>
      element is String && _list.contains(element);

  @override
  bool add(String value) {
    final had = _list.contains(value);
    _list.add(value);
    return !had;
  }

  @override
  bool remove(Object? value) {
    if (value is! String) return false;
    final had = _list.contains(value);
    _list.remove(value);
    return had;
  }

  @override
  void addAll(Iterable<String> elements) {
    for (final value in elements) {
      _list.add(value);
    }
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    for (final value in elements) {
      if (value is String) _list.remove(value);
    }
  }

  bool toggle(String value, [bool? shouldAdd]) =>
      shouldAdd == null ? _list.toggle(value) : _list.toggle(value, shouldAdd);

  @override
  Set<String> toSet() =>
      {for (var i = 0; i < _list.length; i++) _list.item(i)!};

  @override
  Iterator<String> get iterator => toSet().iterator;

  @override
  String? lookup(Object? element) =>
      contains(element) ? element as String : null;

  @override
  bool get isEmpty => _list.length == 0;

  @override
  bool get isNotEmpty => _list.length != 0;

  @override
  int get length => _list.length;

  @override
  void clear() {
    while (_list.length > 0) {
      _list.remove(_list.item(0)!);
    }
  }
}

extension LiElementCompat on web.Element {
  LiCssClassSet get classes => LiCssClassSet(classList);

  /// `dart:html` `Element.style` existed on every element; `package:web`
  /// declares it on `HTMLElement` only. Extension-type casts are erased, so
  /// this also works for SVG elements, which expose `style` in JS.
  web.CSSStyleDeclaration get style => (this as web.HTMLElement).style;

  web.CSSStyleDeclaration getComputedStyle([String? pseudoElement]) =>
      web.window.getComputedStyle(this, pseudoElement ?? '');

  void focus() => (this as web.HTMLElement).focus();
  void blur() => (this as web.HTMLElement).blur();
  void click() => (this as web.HTMLElement).click();

  int get offsetWidth => (this as web.HTMLElement).offsetWidth;
  int get offsetHeight => (this as web.HTMLElement).offsetHeight;
  int get offsetTop => (this as web.HTMLElement).offsetTop;
  int get offsetLeft => (this as web.HTMLElement).offsetLeft;
  web.Element? get offsetParent => (this as web.HTMLElement).offsetParent;

  String get innerHtml => (innerHTML as JSString?)?.toDart ?? '';
  set innerHtml(String value) => innerHTML = _sanitizeHtml(value).toJS;

  void setInnerHtml(
    String html, {
    Object? validator,
    Object? treeSanitizer,
  }) {
    final value = identical(treeSanitizer, NodeTreeSanitizer.trusted)
        ? html
        : _sanitizeHtml(html);
    innerHTML = value.toJS;
  }

  void appendHtml(
    String html, {
    Object? validator,
    Object? treeSanitizer,
  }) {
    final value = identical(treeSanitizer, NodeTreeSanitizer.trusted)
        ? html
        : _sanitizeHtml(html);
    insertAdjacentHTML('beforeend', value.toJS);
  }

  void appendText(String text) =>
      appendChild(web.document.createTextNode(text));

  List<web.Element> get childElements => [
        for (var i = 0; i < children.length; i++) children.item(i)!,
      ];

  List<web.Element> queryAll(String selectors) {
    final list = querySelectorAll(selectors);
    return [for (var i = 0; i < list.length; i++) list.item(i)! as web.Element];
  }
}

final DomSanitizationService _domSanitizer = DomSanitizationService();

String _sanitizeHtml(String value) => _domSanitizer.sanitizeHtml(value) ?? '';

// `package:web`'s NodeGlue extension offers `text`/`append`/`clone` too, but
// deprecated; it is hidden by the importers of this library, which get these
// non-deprecated equivalents instead.
extension LiNodeCompat on web.Node {
  String get text => textContent ?? '';

  set text(String value) => textContent = value;

  web.Node append(web.Node other) => appendChild(other);

  web.Node clone(bool? deep) => cloneNode(deep ?? false);

  web.Element? get parent => parentElement;

  /// A live, mutable view of [childNodes], like `dart:html`'s `Node.nodes`
  /// (`nodes.clear()` really empties the node, `add` appends, ...).
  LiLiveNodeList get nodes => LiLiveNodeList(this);
}

class LiLiveNodeList extends ListBase<web.Node> {
  final web.Node _owner;

  LiLiveNodeList(this._owner);

  @override
  int get length => _owner.childNodes.length;

  @override
  set length(int newLength) {
    while (_owner.childNodes.length > newLength) {
      _owner.removeChild(_owner.lastChild!);
    }
    if (_owner.childNodes.length < newLength) {
      throw UnsupportedError('Cannot extend a node list');
    }
  }

  @override
  web.Node operator [](int index) => _owner.childNodes.item(index)!;

  @override
  void operator []=(int index, web.Node value) {
    _owner.replaceChild(value, this[index]);
  }

  @override
  void add(web.Node element) {
    _owner.appendChild(element);
  }

  @override
  void addAll(Iterable<web.Node> iterable) {
    for (final node in List<web.Node>.of(iterable)) {
      _owner.appendChild(node);
    }
  }
}

// Replaces package:web's deprecated EventGlue.client (hidden by importers).
extension LiMouseEventCompat on web.MouseEvent {
  math.Point<num> get client => math.Point(clientX, clientY);

  math.Point<num> get page => math.Point(pageX, pageY);

  math.Point<num> get screen => math.Point(screenX, screenY);
}

extension LiDocumentCompat on web.Document {
  List<web.Element> queryAll(String selectors) {
    final list = querySelectorAll(selectors);
    return [for (var i = 0; i < list.length; i++) list.item(i)! as web.Element];
  }
}

extension LiDocumentFragmentCompat on web.DocumentFragment {
  List<web.Element> queryAll(String selectors) {
    final list = querySelectorAll(selectors);
    return [for (var i = 0; i < list.length; i++) list.item(i)! as web.Element];
  }
}

extension LiHTMLCollectionCompat on web.HTMLCollection {
  List<web.Element> toList() => [for (var i = 0; i < length; i++) item(i)!];

  bool get isEmpty => length == 0;
  bool get isNotEmpty => length != 0;

  /// `dart:html`'s `children.clear()`: removes every element from the parent.
  void clear() {
    while (length > 0) {
      item(0)!.remove();
    }
  }
}

extension LiNodeListCompat on web.NodeList {
  List<web.Node> toList() => [for (var i = 0; i < length; i++) item(i)!];
}

extension LiTouchListCompat on web.TouchList {
  List<web.Touch> toList() => [for (var i = 0; i < length; i++) item(i)!];

  web.Touch operator [](int index) => item(index)!;

  web.Touch get first {
    if (length == 0) throw StateError('No elements');
    return item(0)!;
  }

  bool get isEmpty => length == 0;
  bool get isNotEmpty => length != 0;
}

/// `dart:html`-style `target.on['custom-event']` custom-event stream map.
class LiElementEvents {
  final web.EventTarget _target;

  LiElementEvents(this._target);

  Stream<web.Event> operator [](String type) =>
      web.EventStreamProvider<web.Event>(type).forTarget(_target);
}

extension LiElementOnCompat on web.Element {
  LiElementEvents get on => LiElementEvents(this);
}

extension LiDocumentOnCompat on web.Document {
  LiElementEvents get on => LiElementEvents(this);
}

extension LiWindowOnCompat on web.Window {
  LiElementEvents get on => LiElementEvents(this);
}

extension LiFileListCompat on web.FileList {
  List<web.File> toList() => [for (var i = 0; i < length; i++) item(i)!];
}

// Only the getters missing from package:web's sparse WindowEventGetters
// (which already has onKeyDown/onKeyPress/onLoad/onMessage/onPopState/
// onTouchMove/onMouseWheel/onTransitionEnd).
extension LiWindowEventCompat on web.Window {
  Stream<web.Event> get onResize =>
      web.EventStreamProviders.resizeEvent.forTarget(this);
  Stream<web.Event> get onScroll =>
      web.EventStreamProviders.scrollEvent.forTarget(this);
  Stream<web.MouseEvent> get onClick =>
      web.EventStreamProviders.clickEvent.forTarget(this);
  Stream<web.MouseEvent> get onMouseDown =>
      web.EventStreamProviders.mouseDownEvent.forTarget(this);
  Stream<web.MouseEvent> get onMouseUp =>
      web.EventStreamProviders.mouseUpEvent.forTarget(this);
  Stream<web.MouseEvent> get onMouseMove =>
      web.EventStreamProviders.mouseMoveEvent.forTarget(this);
  Stream<web.KeyboardEvent> get onKeyUp =>
      web.EventStreamProviders.keyUpEvent.forTarget(this);
  Stream<web.TouchEvent> get onTouchStart =>
      web.EventStreamProviders.touchStartEvent.forTarget(this);
  Stream<web.TouchEvent> get onTouchEnd =>
      web.EventStreamProviders.touchEndEvent.forTarget(this);
  Stream<web.Event> get onHashChange =>
      web.EventStreamProviders.hashChangeEvent.forTarget(this);
}

extension LiWindowCompat on web.Window {
  int liRequestAnimationFrame(void Function(num highResTime) callback) {
    // `dart:html` bound animation-frame callbacks to the scheduling zone.
    // `Function.toJS` does not provide that behavior, so preserve it here for
    // Angular change detection, timer tracking, and error handling.
    final boundCallback = Zone.current.bindUnaryCallbackGuarded<num>(callback);
    return requestAnimationFrame(((JSNumber highResTime) {
      boundCallback(highResTime.toDartDouble);
    }).toJS);
  }

  num get pageXOffset => scrollX;
  num get pageYOffset => scrollY;
}

// ---------------------------------------------------------------------------
// Misc dart:html stand-ins
// ---------------------------------------------------------------------------

/// `dart:html` `NodeTreeSanitizer` stand-in.
///
/// Normal HTML writes are sanitized by ngx_dart's [DomSanitizationService].
/// Passing [trusted] explicitly preserves the old opt-in bypass behavior.
abstract class NodeTreeSanitizer {
  static const NodeTreeSanitizer trusted = _TrustedNodeTreeSanitizer();

  void sanitizeTree(web.Node node);
}

class _TrustedNodeTreeSanitizer implements NodeTreeSanitizer {
  const _TrustedNodeTreeSanitizer();

  @override
  void sanitizeTree(web.Node node) {}
}

/// `dart:html` `Url` stand-in over `web.URL` statics.
abstract final class Url {
  static String createObjectUrl(web.Blob blobOrFile) =>
      web.URL.createObjectURL(blobOrFile);

  static String createObjectUrlFromBlob(web.Blob blob) =>
      web.URL.createObjectURL(blob);

  static void revokeObjectUrl(String url) => web.URL.revokeObjectURL(url);
}

/// Dart-callback `MutationObserver` in the `dart:html` shape.
class MutationObserver {
  late final web.MutationObserver _observer;

  MutationObserver(
    void Function(List<web.MutationRecord> mutations, MutationObserver observer)
        callback,
  ) {
    // `dart:html` used `_wrapBinaryZone` here. Keep the callback in the Zone
    // where the observer was created so Angular change detection and guarded
    // error handling retain their pre-migration behavior.
    final boundCallback = Zone.current
        .bindBinaryCallbackGuarded<List<web.MutationRecord>, MutationObserver>(
            callback);
    _observer = web.MutationObserver(
      (JSArray<web.MutationRecord> mutations, web.MutationObserver _) {
        boundCallback(mutations.toDart, this);
      }.toJS,
    );
  }

  void observe(
    web.Node target, {
    bool childList = false,
    bool attributes = false,
    bool characterData = false,
    bool subtree = false,
    bool attributeOldValue = false,
    bool characterDataOldValue = false,
    List<String>? attributeFilter,
  }) {
    final init = web.MutationObserverInit(
      childList: childList,
      attributes: attributes,
      characterData: characterData,
      subtree: subtree,
      attributeOldValue: attributeOldValue,
      characterDataOldValue: characterDataOldValue,
    );
    if (attributeFilter != null) {
      (init as JSObject).setProperty(
        'attributeFilter'.toJS,
        [for (final name in attributeFilter) name.toJS].toJS,
      );
    }
    _observer.observe(target, init);
  }

  void disconnect() => _observer.disconnect();
}

/// Dart-callback `ResizeObserver` in the `dart:html` shape.
class ResizeObserver {
  late final web.ResizeObserver _observer;

  ResizeObserver(
    void Function(
            List<web.ResizeObserverEntry> entries, ResizeObserver observer)
        callback,
  ) {
    _observer = web.ResizeObserver(
      (JSArray<web.ResizeObserverEntry> entries, web.ResizeObserver _) {
        callback(entries.toDart, this);
      }.toJS,
    );
  }

  void observe(web.Element target) => _observer.observe(target);

  void unobserve(web.Element target) => _observer.unobserve(target);

  void disconnect() => _observer.disconnect();
}

/// Dart-callback `IntersectionObserver` in the `dart:html` shape.
class IntersectionObserver {
  late final web.IntersectionObserver _observer;

  IntersectionObserver(
    void Function(List<web.IntersectionObserverEntry> entries,
            IntersectionObserver observer)
        callback, [
    Map<String, dynamic>? options,
  ]) {
    final init = web.IntersectionObserverInit();
    final root = options?['root'];
    if (root != null) init.root = root as web.Element;
    final rootMargin = options?['rootMargin'];
    if (rootMargin != null) init.rootMargin = rootMargin as String;
    final threshold = options?['threshold'];
    if (threshold != null) {
      (init as JSObject).setProperty('threshold'.toJS, threshold.jsify());
    }
    _observer = web.IntersectionObserver(
      (JSArray<web.IntersectionObserverEntry> entries,
          web.IntersectionObserver _) {
        callback(entries.toDart, this);
      }.toJS,
      init,
    );
  }

  void observe(web.Element target) => _observer.observe(target);

  void unobserve(web.Element target) => _observer.unobserve(target);

  void disconnect() => _observer.disconnect();
}
