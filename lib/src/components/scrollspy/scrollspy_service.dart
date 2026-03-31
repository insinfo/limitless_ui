import 'dart:async';
import 'dart:collection';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

import 'scrollspy_config.dart';

abstract class LiScrollSpyRef {
  String get active;

  Stream<String> get active$;

  void scrollTo(Object fragment, {LiScrollToOptions? options});
}

typedef LiScrollSpyProcessChanges = void Function(
  LiScrollSpyState state,
  void Function(String active) changeActive,
  Map<String, Object?> context,
);

class LiScrollSpyOptions {
  const LiScrollSpyOptions({
    this.changeDetectorRef,
    this.fragments = const <Object>[],
    this.initialFragment,
    this.processChanges,
    this.root,
    this.rootMargin,
    this.scrollBehavior,
    this.threshold,
  });

  final ChangeDetectorRef? changeDetectorRef;
  final List<Object> fragments;
  final Object? initialFragment;
  final LiScrollSpyProcessChanges? processChanges;
  final html.Element? root;
  final String? rootMargin;
  final String? scrollBehavior;
  final Object? threshold;
}

class LiScrollToOptions {
  const LiScrollToOptions({
    this.behavior,
  });

  final String? behavior;
}

class LiScrollSpyFragmentState {
  const LiScrollSpyFragmentState({
    required this.element,
    required this.id,
    required this.rect,
    required this.visible,
  });

  final html.Element element;
  final String id;
  final html.Rectangle<num> rect;
  final bool visible;
}

class LiScrollSpyState {
  const LiScrollSpyState({
    required this.fragments,
    required this.options,
    required this.rootElement,
    required this.rootRect,
    required this.scrollSpy,
  });

  final List<LiScrollSpyFragmentState> fragments;
  final LiScrollSpyOptions options;
  final html.Element rootElement;
  final html.Rectangle<num> rootRect;
  final LiScrollSpyService scrollSpy;
}

void defaultLiScrollSpyProcessChanges(
  LiScrollSpyState state,
  void Function(String active) changeActive,
  Map<String, Object?> context,
) {
  final fragments = state.fragments;
  if (fragments.isEmpty) {
    changeActive('');
    return;
  }

  final anchorTop = state.rootRect.top +
      _resolveTopRootMargin(state.options.rootMargin, state.rootRect.height);
  LiScrollSpyFragmentState? candidate;

  for (final fragment in fragments) {
    if (fragment.rect.top <= anchorTop + 1) {
      candidate = fragment;
      continue;
    }

    if (fragment.visible) {
      candidate ??= fragment;
      break;
    }
  }

  if (candidate == null) {
    for (final fragment in fragments) {
      if (fragment.visible) {
        candidate = fragment;
        break;
      }
    }
  }

  changeActive(candidate?.id ?? '');
}

double _resolveTopRootMargin(String? rootMargin, num rootHeight) {
  if (rootMargin == null || rootMargin.trim().isEmpty) {
    return 0;
  }

  final token = rootMargin.trim().split(RegExp(r'\s+')).first;
  if (token.endsWith('px')) {
    return double.tryParse(token.substring(0, token.length - 2)) ?? 0;
  }
  if (token.endsWith('%')) {
    final percent = double.tryParse(token.substring(0, token.length - 1)) ?? 0;
    return rootHeight.toDouble() * percent / 100;
  }

  return double.tryParse(token) ?? 0;
}

class _ResolvedRootMargin {
  const _ResolvedRootMargin({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  final double top;
  final double right;
  final double bottom;
  final double left;
}

_ResolvedRootMargin _resolveRootMargin(
  String? rootMargin,
  html.Rectangle<num> rootRect,
) {
  if (rootMargin == null || rootMargin.trim().isEmpty) {
    return const _ResolvedRootMargin(top: 0, right: 0, bottom: 0, left: 0);
  }

  final tokens = rootMargin
      .trim()
      .split(RegExp(r'\s+'))
      .where((token) => token.trim().isNotEmpty)
      .toList(growable: false);
  if (tokens.isEmpty) {
    return const _ResolvedRootMargin(top: 0, right: 0, bottom: 0, left: 0);
  }

  String topToken;
  String rightToken;
  String bottomToken;
  String leftToken;

  switch (tokens.length) {
    case 1:
      topToken = rightToken = bottomToken = leftToken = tokens[0];
      break;
    case 2:
      topToken = bottomToken = tokens[0];
      rightToken = leftToken = tokens[1];
      break;
    case 3:
      topToken = tokens[0];
      rightToken = leftToken = tokens[1];
      bottomToken = tokens[2];
      break;
    default:
      topToken = tokens[0];
      rightToken = tokens[1];
      bottomToken = tokens[2];
      leftToken = tokens[3];
      break;
  }

  return _ResolvedRootMargin(
    top: _resolveMarginToken(topToken, rootRect.height.toDouble()),
    right: _resolveMarginToken(rightToken, rootRect.width.toDouble()),
    bottom: _resolveMarginToken(bottomToken, rootRect.height.toDouble()),
    left: _resolveMarginToken(leftToken, rootRect.width.toDouble()),
  );
}

double _resolveMarginToken(String token, double referenceSize) {
  final normalized = token.trim();
  if (normalized.isEmpty) {
    return 0;
  }
  if (normalized.endsWith('px')) {
    return double.tryParse(
          normalized.substring(0, normalized.length - 2),
        ) ??
        0;
  }
  if (normalized.endsWith('%')) {
    final percent = double.tryParse(
          normalized.substring(0, normalized.length - 1),
        ) ??
        0;
    return referenceSize * percent / 100;
  }

  return double.tryParse(normalized) ?? 0;
}

@Injectable()
class LiScrollSpyService implements LiScrollSpyRef, OnDestroy {
  LiScrollSpyService([LiScrollSpyConfig? config])
      : _config = config ?? LiScrollSpyConfig();

  final LiScrollSpyConfig _config;
  final LinkedHashSet<html.Element> _fragments = LinkedHashSet<html.Element>();
  final LinkedHashSet<Object> _preRegisteredFragments = LinkedHashSet<Object>();
  final StreamController<String> _activeController =
      StreamController<String>.broadcast();
  final Map<String, Object?> _processContext = <String, Object?>{};

  StreamSubscription<html.Event>? _rootScrollSubscription;
  StreamSubscription<html.Event>? _windowScrollSubscription;
  StreamSubscription<html.Event>? _windowResizeSubscription;

  LiScrollSpyOptions _options = const LiScrollSpyOptions();
  html.Element? _rootElement;
  String _active = '';
  bool _started = false;
  bool _updateQueued = false;
  bool _disposed = false;

  @override
  String get active => _active;

  @override
  Stream<String> get active$ => _activeController.stream.distinct();

  void start([LiScrollSpyOptions options = const LiScrollSpyOptions()]) {
    if (_disposed) {
      return;
    }

    _cleanup(resetActive: false);
    _options = options;
    _rootElement = options.root ?? html.document.documentElement;
    _started = true;

    if (_rootElement != null && _rootElement != html.document.documentElement) {
      _rootScrollSubscription =
          _rootElement!.onScroll.listen((_) => _queueUpdate());
    } else {
      _windowScrollSubscription =
          html.window.onScroll.listen((_) => _queueUpdate());
    }
    _windowResizeSubscription =
        html.window.onResize.listen((_) => _queueUpdate());

    for (final fragment
        in _preRegisteredFragments.followedBy(options.fragments)) {
      observe(fragment);
    }
    _preRegisteredFragments.clear();

    if (options.initialFragment != null) {
      Future<void>.delayed(Duration.zero, () {
        scrollTo(options.initialFragment!);
      });
      return;
    }

    _queueUpdate();
  }

  void stop() {
    _cleanup(resetActive: true);
  }

  void observe(Object fragment) {
    if (!_started) {
      _preRegisteredFragments.add(fragment);
      return;
    }

    final fragmentElement = _resolveFragmentElement(fragment);
    if (fragmentElement == null || _fragments.contains(fragmentElement)) {
      return;
    }

    _fragments.add(fragmentElement);
    _queueUpdate();
  }

  void unobserve(Object fragment) {
    if (!_started) {
      _preRegisteredFragments.remove(fragment);
      return;
    }

    final fragmentElement = _resolveFragmentElement(fragment);
    if (fragmentElement == null) {
      return;
    }

    if (_fragments.remove(fragmentElement)) {
      _queueUpdate();
    }
  }

  @override
  void scrollTo(Object fragment, {LiScrollToOptions? options}) {
    final rootElement = _rootElement;
    final fragmentElement = _resolveFragmentElement(fragment);
    if (rootElement == null || fragmentElement == null) {
      return;
    }

    final behavior =
        options?.behavior ?? _options.scrollBehavior ?? _config.scrollBehavior;
    final targetTop = _resolveTargetTop(rootElement, fragmentElement);

    if (rootElement == html.document.documentElement ||
        rootElement == html.document.body) {
      html.document.documentElement?.scrollTop = targetTop;
      html.document.body?.scrollTop = targetTop;
    } else {
      rootElement.scrollTop = targetTop;
    }

    if (behavior == 'smooth') {
      Future<void>.delayed(const Duration(milliseconds: 32), () {
        _setActive(fragmentElement.id);
      });
      return;
    }

    _setActive(fragmentElement.id);
  }

  @override
  void ngOnDestroy() {
    _disposed = true;
    _cleanup(resetActive: false);
    _activeController.close();
  }

  html.Element? _resolveFragmentElement(Object? fragment) {
    final rootElement = _rootElement ?? html.document.documentElement;
    if (rootElement == null || fragment == null) {
      return null;
    }

    if (fragment is html.Element) {
      return fragment;
    }

    final id = fragment.toString().trim();
    if (id.isEmpty) {
      return null;
    }

    return rootElement.querySelector('#$id') ??
        html.document.querySelector('#$id');
  }

  int _resolveTargetTop(
      html.Element rootElement, html.Element fragmentElement) {
    if (rootElement == html.document.documentElement ||
        rootElement == html.document.body) {
      final rect = fragmentElement.getBoundingClientRect();
      return (rect.top + html.window.pageYOffset).round();
    }

    return fragmentElement.offsetTop - rootElement.offsetTop;
  }

  void _queueUpdate() {
    if (!_started || _updateQueued || _disposed) {
      return;
    }

    _updateQueued = true;
    html.window.requestAnimationFrame((_) {
      _updateQueued = false;
      if (_disposed || !_started) {
        return;
      }

      _recomputeActive();
    });
  }

  void _recomputeActive() {
    final rootElement = _rootElement;
    if (rootElement == null) {
      return;
    }

    final rootRect = _measureRootRect(rootElement);
    final fragments = _fragments
        .where((fragment) => fragment.id.trim().isNotEmpty)
        .map((fragment) => LiScrollSpyFragmentState(
              element: fragment,
              id: fragment.id,
              rect: fragment.getBoundingClientRect(),
              visible: _isVisible(fragment.getBoundingClientRect(), rootRect),
            ))
        .toList()
      ..sort((a, b) => a.rect.top.compareTo(b.rect.top));

    final state = LiScrollSpyState(
      fragments: fragments,
      options: _options,
      rootElement: rootElement,
      rootRect: rootRect,
      scrollSpy: this,
    );

    final processChanges = _options.processChanges ?? _config.processChanges;
    processChanges(state, _setActive, _processContext);
  }

  html.Rectangle<num> _measureRootRect(html.Element rootElement) {
    if (rootElement == html.document.documentElement ||
        rootElement == html.document.body) {
      return html.Rectangle<num>(
        0,
        0,
        html.window.innerWidth?.toDouble() ?? 0,
        html.window.innerHeight?.toDouble() ?? 0,
      );
    }

    return rootElement.getBoundingClientRect();
  }

  bool _isVisible(
      html.Rectangle<num> fragmentRect, html.Rectangle<num> rootRect) {
    final effectiveRootRect = _effectiveRootRect(rootRect);
    final intersectionWidth =
        (fragmentRect.right < effectiveRootRect.right
                    ? fragmentRect.right
                    : effectiveRootRect.right) -
                (fragmentRect.left > effectiveRootRect.left
                    ? fragmentRect.left
                    : effectiveRootRect.left)
            .toDouble();
    final intersectionHeight =
        (fragmentRect.bottom < effectiveRootRect.bottom
                    ? fragmentRect.bottom
                    : effectiveRootRect.bottom) -
                (fragmentRect.top > effectiveRootRect.top
                    ? fragmentRect.top
                    : effectiveRootRect.top)
            .toDouble();

    if (intersectionWidth <= 0 || intersectionHeight <= 0) {
      return false;
    }

    final fragmentArea =
        fragmentRect.width.toDouble() * fragmentRect.height.toDouble();
    if (fragmentArea <= 0) {
      return false;
    }

    final ratio =
        (intersectionWidth * intersectionHeight) / fragmentArea;
    return ratio >= _thresholdFloor;
  }

  html.Rectangle<num> _effectiveRootRect(html.Rectangle<num> rootRect) {
    final rootMargin = _resolveRootMargin(_options.rootMargin, rootRect);
    return html.Rectangle<num>(
      rootRect.left - rootMargin.left,
      rootRect.top - rootMargin.top,
      rootRect.width + rootMargin.left + rootMargin.right,
      rootRect.height + rootMargin.top + rootMargin.bottom,
    );
  }

  double get _thresholdFloor {
    final threshold = _options.threshold;
    if (threshold is num) {
      return threshold.clamp(0, 1).toDouble();
    }
    if (threshold is Iterable) {
      final values = threshold
          .whereType<num>()
          .map((value) => value.clamp(0, 1).toDouble())
          .toList(growable: false);
      if (values.isNotEmpty) {
        values.sort();
        return values.first;
      }
    }
    return 0;
  }

  void _setActive(String value) {
    if (_active == value) {
      return;
    }

    _active = value;
    _activeController.add(value);
    _options.changeDetectorRef?.markForCheck();
  }

  void _cleanup({required bool resetActive}) {
    _rootScrollSubscription?.cancel();
    _windowScrollSubscription?.cancel();
    _windowResizeSubscription?.cancel();
    _rootScrollSubscription = null;
    _windowScrollSubscription = null;
    _windowResizeSubscription = null;
    _fragments.clear();
    _rootElement = null;
    _started = false;
    _updateQueued = false;
    _options = const LiScrollSpyOptions();

    if (resetActive) {
      _setActive('');
    }
  }
}
