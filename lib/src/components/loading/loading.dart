import 'dart:async';
import 'dart:html';
import 'dart:math' as math;

String _resolveLoadingOverlayColor() {
  final theme = document.documentElement?.attributes['data-color-theme'];
  return theme == 'dark' ? 'rgb(0 0 0 / 36%)' : 'rgb(255 255 255 / 48%)';
}

class LiSimpleLoading {
  static const int defaultBodyZIndex = 500000;
  static const int defaultTargetZIndex = 50000;

  Element _root = DivElement();
  Element? _spinner;
  Element? _target;

  StreamSubscription<Event>? _winScrollSub;
  StreamSubscription<Event>? _containerScrollSub;
  StreamSubscription<Event>? _resizeSub;
  ResizeObserver? _ro;

  double _safeMargin = 64; // px
  EventTarget? _scrollContainer;

  String _overlayColor() => _resolveLoadingOverlayColor();

  int _resolvedZIndex(Element? target, int? zIndex) =>
      zIndex ?? (target == null ? defaultBodyZIndex : defaultTargetZIndex);

  void _prepareTargetForOverlay(Element? target) {
    if (target != null && target.getComputedStyle().position == 'static') {
      target.style.position = 'relative';
    }
  }

  DivElement _createRoot({
    required String position,
    required int zIndex,
    required String height,
    String? background,
  }) {
    final root = DivElement()
      ..classes.add('li-simple-loading')
      ..attributes['data-li-simple-loading'] = 'true'
      ..style.position = position
      ..style.left = '0'
      ..style.top = '0'
      ..style.width = '100%'
      ..style.height = height
      ..style.zIndex = '$zIndex';

    if (background != null) {
      root.style.background = background;
    }

    return root;
  }

  void _mountOverlay(Element? target) {
    if (target != null) {
      target.append(_root);
      return;
    }

    document.body?.append(_root);
  }

  void showOnBody({
    double safeMargin = 64,
    int zIndex = defaultBodyZIndex,
  }) => show(target: null, safeMargin: safeMargin, zIndex: zIndex);

  void show({Element? target, double safeMargin = 64, int? zIndex}) {
    hide();
    _safeMargin = safeMargin;

    _target = target ?? document.body;
    _prepareTargetForOverlay(target);

    _root = _createRoot(
      position: target != null ? 'absolute' : 'fixed',
      zIndex: _resolvedZIndex(target, zIndex),
      height: '100%',
      background: _overlayColor(),
    );

    _spinner = DivElement()
      ..classes.add('li-simple-loading__spinner')
      ..setInnerHtml(
        '<i class="ph-spinner ph-3x spinner text-primary"></i>',
        treeSanitizer: NodeTreeSanitizer.trusted,
      )
      ..style.position = 'absolute'
      ..style.left = '50%'
      ..style.transform = 'translateX(-50%)';
    _spinner!.style.pointerEvents = 'none';

    _root.append(_spinner!);
    _mountOverlay(target);

    _scrollContainer = _findScrollableAncestor(_target!);

    _winScrollSub = window.onScroll.listen((_) => _rafUpdate());

    if (_scrollContainer is Element) {
      _containerScrollSub =
          (_scrollContainer as Element).onScroll.listen((_) => _rafUpdate());
    }

    _resizeSub = window.onResize.listen((_) => _rafUpdate());

    _ro = ResizeObserver((List<dynamic> entries, ResizeObserver observer) {
      _rafUpdate();
    })
      ..observe(_target!);

    _rafUpdate();
  }

  void _rafUpdate() {
    if (_target != null && _target!.isConnected == true) {
      window.requestAnimationFrame((_) => _updateSpinnerPosition());
    } else {
      hide();
    }
  }

  void _updateSpinnerPosition() {
    if (_spinner == null || _target == null) {
      return;
    }

    final Rectangle<num> rect =
        (_target == document.body || _target == document.documentElement)
            ? Rectangle<num>(
                0,
                0,
                (window.innerWidth ?? 0).toDouble(),
                (document.documentElement?.scrollHeight ?? 0).toDouble(),
              )
            : _target!.getBoundingClientRect();

    final double viewportH = (window.innerHeight ?? 0).toDouble();
    final double centerYViewport = (rect.top + rect.height / 2).toDouble();
    final double topClamp = _safeMargin;
    final double bottomClamp = viewportH - _safeMargin;
    final double clampedY =
        math.max(topClamp, math.min(centerYViewport, bottomClamp));
    final double topInTarget = clampedY - rect.top.toDouble();

    _spinner!.style.top = '${topInTarget}px';
  }

  void hide() {
    _winScrollSub?.cancel();
    _containerScrollSub?.cancel();
    _resizeSub?.cancel();
    _ro?.disconnect();

    _winScrollSub = null;
    _containerScrollSub = null;
    _resizeSub = null;
    _ro = null;

    _spinner = null;
    _target = null;
    _scrollContainer = null;

    _root.remove();
  }

  EventTarget _findScrollableAncestor(Element start) {
    Element? el = start;
    while (el != null && el != document.body) {
      final oy = el.getComputedStyle().overflowY;
      if (oy == 'auto' || oy == 'scroll') {
        return el;
      }
      el = el.parent;
    }
    return window;
  }

  void showSimple({Element? target, int? zIndex}) {
    hide();
    _prepareTargetForOverlay(target);
    _root = _createRoot(
      position: target != null ? 'absolute' : 'fixed',
      zIndex: _resolvedZIndex(target, zIndex),
      height: '100%',
      background: _overlayColor(),
    );
    _root.style.display = 'flex';
    _root.style.flexDirection = 'column';
    _root.style.alignItems = 'center';
    _root.style.justifyContent = 'center';

    _root.appendHtml('''
<div>
<i class="ph-spinner ph-3x spinner text-primary"></i>
</div>
''');

    _mountOverlay(target);
  }

  void showHorizontal({Element? target, int? zIndex}) {
    hide();
    _prepareTargetForOverlay(target);
    _root = _createRoot(
      position: target != null ? 'absolute' : 'fixed',
      zIndex: _resolvedZIndex(target, zIndex),
      height: 'auto',
    );

    var backColor = '#2196f3';
    var frontColor = '#fff';

    _root.setInnerHtml(
      '''
<style>
.loader {
  width:100%;
  margin:0 auto;
  position:relative;
  padding:0;
  height: 3px;
  background-color: $backColor;
}
.loader:before {
  content:'';
  position:absolute;
  top:0;
  right:0;
  bottom:0;
  left:0;
}
.loader .loaderBar {
  position:absolute;
  height: 3px;
  border-radius:0;
  top:0;
  right:100%;
  bottom:0;
  left:0;
  background: $frontColor;
  width:0;
  animation:borealisBar 2s linear infinite;
}
@keyframes borealisBar {
  0% {
    left:0%;
    right:100%;
    width:0%;
  }
  10% {
    left:0%;
    right:75%;
    width:25%;
  }
  90% {
    right:0%;
    left:75%;
    width:25%;
  }
  100% {
    left:100%;
    right:0%;
    width:0%;
  }
}
</style>
<div class="loader">
  <div class="loaderBar"></div>
</div>
''',
      treeSanitizer: NodeTreeSanitizer.trusted,
    );

    _mountOverlay(target);
  }

  void showHorizontal2({Element? target, int? zIndex}) {
    hide();
    _prepareTargetForOverlay(target);
    _root = _createRoot(
      position: target != null ? 'absolute' : 'fixed',
      zIndex: _resolvedZIndex(target, zIndex),
      height: 'auto',
    );

    _root.setInnerHtml(
      '''<style>
        .progress-container.indeterminate {
          background-color: #c6dafc
        }
        .progress-container {
          position: relative;
          height: 100%;
          background-color: #e0e0e0;
          overflow: hidden
        }
        .progress-container.indeterminate.fallback>.secondary-progress {
          animation-name: indeterminate-secondary-progress;
          animation-duration: 2s;
          animation-iteration-count: infinite;
          animation-timing-function: linear
        }
        .progress-container.indeterminate>.secondary-progress {
          background-color: #4285f4
        }
        .secondary-progress {
          background-color: #a1c2fa
        }
        .active-progress,
        .secondary-progress {
          transform-origin: left center;
          transform: scaleX(0);
          position: absolute;
          top: 0;
          transition: transform 218ms cubic-bezier(.4, 0, .2, 1);
          right: 0;
          bottom: 0;
          left: 0;
          will-change: transform
        }
        .progress-container {
          position: relative;
          height: 100%;
          background-color: #e0e0e0;
          overflow: hidden
        }
        .progress-container.indeterminate {
          background-color: #c6dafc
        }
        .progress-container.indeterminate>.secondary-progress {
          background-color: #4285f4
        }
        .active-progress,
        .secondary-progress {
          transform-origin: left center;
          transform: scaleX(0);
          position: absolute;
          top: 0;
          transition: transform 218ms cubic-bezier(.4, 0, .2, 1);
          right: 0;
          bottom: 0;
          left: 0;
          will-change: transform
        }
        .active-progress {
          background-color: #4285f4
        }
        .secondary-progress {
          background-color: #a1c2fa
        }
        .progress-container.indeterminate.fallback>.active-progress {
          animation-name: indeterminate-active-progress;
          animation-duration: 2s;
          animation-iteration-count: infinite;
          animation-timing-function: linear
        }
        .progress-container.indeterminate.fallback>.secondary-progress {
          animation-name: indeterminate-secondary-progress;
          animation-duration: 2s;
          animation-iteration-count: infinite;
          animation-timing-function: linear
        }
        @keyframes indeterminate-active-progress {
          0% {
            transform: translate(0) scaleX(0)
          }
          25% {
            transform: translate(0) scaleX(.5)
          }
          50% {
            transform: translate(25%) scaleX(.75)
          }
          75% {
            transform: translate(100%) scaleX(0)
          }
          100% {
            transform: translate(100%) scaleX(0)
          }
        }
        @keyframes indeterminate-secondary-progress {
          0% {
            transform: translate(0) scaleX(0)
          }
          60% {
            transform: translate(0) scaleX(0)
          }
          80% {
            transform: translate(0) scaleX(.6)
          }
          100% {
            transform: translate(100%) scaleX(.1)
          }
        }
        .loadContainer {
            width: 100%;
        }
        .loadingC {
           width: 100%;
           height: 4px;
        }
      </style>
      <div class="loadContainer">
        <div class="loadingC">
          <div class="progress-container _ngcontent-xao-51 indeterminate fallback" role="progressbar"
            aria-label="loading" aria-valuemin="0" aria-valuemax="100">
            <div class="secondary-progress _ngcontent-xao-51" aria-label="active progress 0 secondary progress 0"
              style="transform: scaleX(0);"></div>
            <div class="active-progress _ngcontent-xao-51" style="transform: scaleX(0);"></div>
          </div>
        </div>
      </div>''',
      treeSanitizer: NodeTreeSanitizer.trusted,
    );

    _mountOverlay(target);
  }
}

class LiNarratedFullScreenLoading {
  static const int defaultZIndex = LiSimpleLoading.defaultBodyZIndex + 1;
  static const List<String> defaultPdfMessages = <String>[
    'Preparando documento...',
    'Analisando conteudo...',
    'Construindo estrutura...',
    'Convertendo para PDF...',
    'Gerando páginas...',
    'Finalizando arquivo...',
  ];

  LiNarratedFullScreenLoading({
    required this.title,
    required this.messages,
    this.stepDuration = const Duration(milliseconds: 1600),
    this.zIndex = defaultZIndex,
  });

  factory LiNarratedFullScreenLoading.pdfGeneration({
    String title = 'Gerando PDF',
    List<String>? messages,
    Duration stepDuration = const Duration(milliseconds: 1600),
    int zIndex = defaultZIndex,
  }) {
    return LiNarratedFullScreenLoading(
      title: title,
      messages: messages ?? defaultPdfMessages,
      stepDuration: stepDuration,
      zIndex: zIndex,
    );
  }

  final String title;
  final List<String> messages;
  final Duration stepDuration;
  final int zIndex;

  Element _root = DivElement();
  DivElement? _messageElement;
  Timer? _messageTimer;
  int _currentMessageIndex = 0;
  bool _rotationStopped = false;

  void showOnBody({int? zIndex}) {
    hide();
    _currentMessageIndex = 0;
    _rotationStopped = false;

    final resolvedZIndex = zIndex ?? this.zIndex;

    _root = DivElement()
      ..classes.add('li-narrated-full-screen-loading')
      ..attributes['data-li-narrated-full-screen-loading'] = 'true'
      ..style.position = 'fixed'
      ..style.left = '0'
      ..style.top = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.zIndex = '$resolvedZIndex'
      ..style.display = 'flex'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center'
      ..style.padding = '24px'
      ..style.background = _resolveLoadingOverlayColor();

    _root.style.setProperty('backdrop-filter', 'blur(2px)');
    _root.style.setProperty('-webkit-backdrop-filter', 'blur(2px)');

    _root.setInnerHtml(
      '''
<style>
.li-narrated-full-screen-loading__shell {
  display: inline-block;
  width: min(32rem, calc(100vw - 3rem));
  padding: 1.5rem;
  border: 1px solid var(--border-color-translucent);
  border-radius: var(--border-radius-lg, 1rem);
  background: var(--card-bg, #fff);
  box-shadow: 0 1.5rem 3rem rgb(15 23 42 / 18%);
  text-align: center;
}
.li-narrated-full-screen-loading__icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 3.5rem;
  height: 3.5rem;
  margin: 0 auto 1rem;
  border-radius: 999px;
  background: rgb(13 110 253 / 12%);
  color: #0d6efd;
}
.li-narrated-full-screen-loading__icon i {
  animation: liNarratedFullScreenLoadingSpin 1.1s linear infinite;
}
.li-narrated-full-screen-loading__title,
.li-narrated-full-screen-loading__message {
  text-align: center;
}
.li-narrated-full-screen-loading__title {
  margin: 0 0 0.5rem;
  color: var(--body-color, #0f172a);
  font-size: 1.05rem;
  font-weight: 700;
}
.li-narrated-full-screen-loading__message {
  min-height: 1.5rem;
  margin: 0 0 1rem;
  color: rgb(var(--body-color-rgb, 51 65 85) / 80%);
  font-size: 0.95rem;
}
.li-narrated-full-screen-loading__track {
  position: relative;
  width: 100%;
  height: 4px;
  overflow: hidden;
  background-color: #c6dafc;
  border-radius: 999px;
}
.li-narrated-full-screen-loading__bar,
.li-narrated-full-screen-loading__secondary {
  transform-origin: left center;
  transform: scaleX(0);
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  will-change: transform;
}
.li-narrated-full-screen-loading__bar {
  background-color: #4285f4;
  animation: liNarratedFullScreenLoadingPrimary 2000ms linear infinite;
}
.li-narrated-full-screen-loading__secondary {
  background-color: #a1c2fa;
  animation: liNarratedFullScreenLoadingSecondary 2000ms linear infinite;
}
@keyframes liNarratedFullScreenLoadingPrimary {
  0% {
    transform: translate(0%) scaleX(0);
  }
  25% {
    transform: translate(0%) scaleX(0.5);
  }
  50% {
    transform: translate(25%) scaleX(0.75);
  }
  75% {
    transform: translate(100%) scaleX(0);
  }
  100% {
    transform: translate(100%) scaleX(0);
  }
}
@keyframes liNarratedFullScreenLoadingSecondary {
  0% {
    transform: translate(0%) scaleX(0);
  }
  60% {
    transform: translate(0%) scaleX(0);
  }
  80% {
    transform: translate(0%) scaleX(0.6);
  }
  100% {
    transform: translate(100%) scaleX(0.1);
  }
}
@keyframes liNarratedFullScreenLoadingSpin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
<div class="li-narrated-full-screen-loading__shell" role="status" aria-live="polite" aria-busy="true">
  <div class="li-narrated-full-screen-loading__icon"><i class="ph-spinner-gap ph-lg"></i></div>
  <div class="li-narrated-full-screen-loading__title"></div>
  <div class="li-narrated-full-screen-loading__message"></div>
  <div class="li-narrated-full-screen-loading__track">
    <div class="li-narrated-full-screen-loading__secondary"></div>
    <div class="li-narrated-full-screen-loading__bar"></div>
  </div>
</div>
''',
      treeSanitizer: NodeTreeSanitizer.trusted,
    );

    final titleElement =
        _root.querySelector('.li-narrated-full-screen-loading__title')
            as DivElement?;
    _messageElement =
        _root.querySelector('.li-narrated-full-screen-loading__message')
            as DivElement?;

    titleElement?.text = title;
    _applyCurrentMessage();

    document.body?.append(_root);
    _startMessageRotation();
  }

  void _applyCurrentMessage() {
    if (_messageElement == null || messages.isEmpty) {
      return;
    }

    _messageElement!.text = messages[_currentMessageIndex % messages.length];
  }

  void _startMessageRotation() {
    _messageTimer?.cancel();
    if (messages.length <= 1 || _rotationStopped) {
      return;
    }

    _messageTimer = Timer.periodic(stepDuration, (_) {
      _currentMessageIndex = (_currentMessageIndex + 1) % messages.length;
      _applyCurrentMessage();
    });
  }

  void updateMessage(String message, {bool stopRotation = true}) {
    if (stopRotation) {
      _rotationStopped = true;
      _messageTimer?.cancel();
      _messageTimer = null;
    }

    if (_messageElement == null) {
      return;
    }

    _messageElement!.text = message;
  }

  void hide() {
    _messageTimer?.cancel();
    _messageTimer = null;
    _messageElement = null;
    _rotationStopped = false;
    _currentMessageIndex = 0;
    _root.remove();
    _root = DivElement();
  }
}
