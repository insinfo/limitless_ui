import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Schedules an animation frame while retaining the Zone that requested it.
int requestAnimationFrameInZone(
  void Function(num highResolutionTime) callback, {
  web.Window? target,
}) {
  final boundCallback = Zone.current.bindUnaryCallbackGuarded<num>(callback);
  return (target ?? web.window).requestAnimationFrame(
    ((JSNumber highResolutionTime) {
      boundCallback(highResolutionTime.toDartDouble);
    }).toJS,
  );
}

/// A Dart-callback MutationObserver that preserves its creation Zone.
final class ZoneMutationObserver {
  late final web.MutationObserver _delegate;

  ZoneMutationObserver(
    void Function(
      List<web.MutationRecord> records,
      ZoneMutationObserver observer,
    ) callback,
  ) {
    final boundCallback = Zone.current.bindBinaryCallbackGuarded<
        List<web.MutationRecord>, ZoneMutationObserver>(callback);
    _delegate = web.MutationObserver(
      (JSArray<web.MutationRecord> records, web.MutationObserver _) {
        boundCallback(records.toDart, this);
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
    final options = web.MutationObserverInit(
      childList: childList,
      attributes: attributes,
      characterData: characterData,
      subtree: subtree,
      attributeOldValue: attributeOldValue,
      characterDataOldValue: characterDataOldValue,
    );
    if (attributeFilter != null) {
      options.attributeFilter = [
        for (final name in attributeFilter) name.toJS,
      ].toJS;
    }
    _delegate.observe(target, options);
  }

  void disconnect() => _delegate.disconnect();
}

/// A Dart-callback ResizeObserver that preserves its creation Zone.
final class ZoneResizeObserver {
  late final web.ResizeObserver _delegate;

  ZoneResizeObserver(
    void Function(
      List<web.ResizeObserverEntry> entries,
      ZoneResizeObserver observer,
    ) callback,
  ) {
    final boundCallback = Zone.current.bindBinaryCallbackGuarded<
        List<web.ResizeObserverEntry>, ZoneResizeObserver>(callback);
    _delegate = web.ResizeObserver(
      (JSArray<web.ResizeObserverEntry> entries, web.ResizeObserver _) {
        boundCallback(entries.toDart, this);
      }.toJS,
    );
  }

  void observe(web.Element target) => _delegate.observe(target);

  void unobserve(web.Element target) => _delegate.unobserve(target);

  void disconnect() => _delegate.disconnect();
}

/// A typed IntersectionObserver with a Dart callback bound to its creation
/// Zone. Options intentionally expose Web IDL concepts instead of a dynamic
/// map.
final class ZoneIntersectionObserver {
  late final web.IntersectionObserver _delegate;

  ZoneIntersectionObserver(
    void Function(
      List<web.IntersectionObserverEntry> entries,
      ZoneIntersectionObserver observer,
    ) callback, {
    web.Element? root,
    String? rootMargin,
    num? threshold,
    List<num>? thresholds,
  }) {
    if (threshold != null && thresholds != null) {
      throw ArgumentError('Use either threshold or thresholds, not both.');
    }

    final options = web.IntersectionObserverInit();
    if (root != null) options.root = root;
    if (rootMargin != null) options.rootMargin = rootMargin;
    if (threshold != null) options.threshold = threshold.toJS;
    if (thresholds != null) {
      options.threshold = [for (final value in thresholds) value.toJS].toJS;
    }

    final boundCallback = Zone.current.bindBinaryCallbackGuarded<
        List<web.IntersectionObserverEntry>, ZoneIntersectionObserver>(
      callback,
    );
    _delegate = web.IntersectionObserver(
      (JSArray<web.IntersectionObserverEntry> entries,
          web.IntersectionObserver _) {
        boundCallback(entries.toDart, this);
      }.toJS,
      options,
    );
  }

  void observe(web.Element target) => _delegate.observe(target);

  void unobserve(web.Element target) => _delegate.unobserve(target);

  void disconnect() => _delegate.disconnect();
}
