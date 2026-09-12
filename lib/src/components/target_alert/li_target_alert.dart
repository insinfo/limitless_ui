import 'dart:async';
import 'dart:html';
import 'dart:math' as math;

import '../../core/overlay_layers.dart';

String _resolveTargetAlertOverlayColor() {
  final theme = document.documentElement?.attributes['data-color-theme'];
  return theme == 'dark' ? 'rgb(15 23 42 / 78%)' : 'rgb(248 250 252 / 84%)';
}

/// Where the panel sits inside the target.
enum LiTargetAlertPlacement {
  /// Vertically centred in the visible part of the target.
  center,

  /// Near the top of the visible part, which keeps it in view on a long list.
  top,
}

/// A contextual error panel drawn over an element of the page.
///
/// It answers the question a spinner cannot: the load failed, and now what. It
/// covers the element that should have shown the data, says what went wrong and
/// offers a way out — retry, and optionally an action that lives elsewhere.
///
/// ## One instance per screen, not one per load
///
/// ```dart
/// final LiTargetAlert _erroDaLista = LiTargetAlert();
/// ```
///
/// The instance holds the overlay, the scroll/resize subscriptions and the
/// button callbacks. [show] always calls [hide] first, so the same instance
/// serves every failed attempt on that screen. Call [hide] from `ngOnDestroy`
/// to drop the overlay and its listeners when the route changes.
///
/// This is the opposite of [LiSimpleLoading], which is created per operation,
/// in the same scope as its `show`/`hide` pair — two simultaneous loads sharing
/// one curtain instance leave an orphan overlay on the page.
///
/// ## Why it draws above the loading curtain
///
/// [LiOverlayLayers.targetAlert] is above [LiOverlayLayers.loadingBody] because
/// this panel is what *replaces* a curtain that failed. Under the curtain it
/// would be invisible, and the operator would be left watching a spinner that
/// never stops.
class LiTargetAlert {
  Element _root = DivElement();
  Element? _panel;
  Element? _target;
  double _safeMargin = 64;
  double _topOffset = 40;
  LiTargetAlertPlacement _placement = LiTargetAlertPlacement.center;
  EventTarget? _scrollContainer;
  StreamSubscription<Event>? _retrySub;
  StreamSubscription<Event>? _actionSub;
  StreamSubscription<Event>? _closeSub;
  StreamSubscription<Event>? _winScrollSub;
  StreamSubscription<Event>? _containerScrollSub;
  StreamSubscription<Event>? _resizeSub;
  ResizeObserver? _ro;

  /// Shows the panel over [target], or over the page when it is null.
  ///
  /// [onAction] adds a button before the retry one, for when the error has a
  /// known way out that lives somewhere else — "Go to step 4", "Open mappings".
  /// Without it the operator reads what to do and then has to find where to do
  /// it. [actionLabel] is the button text and [actionIconClass] its icon, in
  /// the Phosphor classes the theme uses.
  ///
  /// [detail] goes into a collapsed block: the technical message belongs on the
  /// screen — it is what gets pasted into a support ticket — but not in the
  /// operator's face.
  ///
  /// The default labels are in Portuguese, like the rest of this library.
  void show({
    Element? target,
    String title = 'Erro ao carregar dados',
    String message = 'Não foi possível concluir esta operação.',
    String? detail,
    String retryLabel = 'Tentar novamente',
    String actionLabel = '',
    String actionIconClass = 'ph ph-arrow-square-out',
    String detailLabel = 'Detalhes técnicos',
    String closeLabel = 'Fechar',
    double safeMargin = 64,
    double topOffset = 40,
    LiTargetAlertPlacement placement = LiTargetAlertPlacement.center,
    void Function()? onRetry,
    void Function()? onAction,
  }) {
    hide();

    _safeMargin = safeMargin;
    _topOffset = topOffset;
    _placement = placement;
    _target = target ?? document.body;
    if (_target == null) {
      return;
    }

    if (target != null && target.getComputedStyle().position == 'static') {
      target.style.position = 'relative';
    }

    _root = DivElement()
      ..classes.add('li-target-alert-overlay')
      ..style.position = target != null ? 'absolute' : 'fixed'
      ..style.left = '0'
      ..style.top = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.minHeight = '240px'
      ..style.zIndex = '${LiOverlayLayers.targetAlert}'
      ..style.padding = '24px'
      ..style.background = _resolveTargetAlertOverlayColor();
    _root.style.setProperty('backdrop-filter', 'blur(1px)');
    _root.style.setProperty('-webkit-backdrop-filter', 'blur(1px)');

    final panel = DivElement()
      ..classes.addAll(['li-target-alert-panel', 'shadow-sm'])
      ..style.width = 'min(560px, 100%)'
      ..style.border = '1px solid rgb(203 213 225)'
      ..style.borderRadius = '8px'
      ..style.background = '#fff'
      ..style.padding = '24px'
      ..style.textAlign = 'center'
      ..style.position = 'absolute'
      ..style.left = '50%';
    panel.style.transform = _placement == LiTargetAlertPlacement.top
        ? 'translateX(-50%)'
        : 'translate(-50%, -50%)';

    final icon = DivElement()
      ..classes.addAll([
        'd-inline-flex',
        'align-items-center',
        'justify-content-center',
        'rounded-circle',
        'bg-danger',
        'bg-opacity-10',
        'text-danger',
        'mb-3',
      ])
      ..style.width = '48px'
      ..style.height = '48px';
    icon.append(Element.tag('i')..classes.addAll(['ph', 'ph-warning']));

    final titleElement = HeadingElement.h5()
      ..classes.addAll(['mb-2', 'fw-semibold'])
      ..text = title;

    final messageElement = ParagraphElement()
      ..classes.addAll(['mb-0', 'text-body'])
      ..text = message;

    panel
      ..append(icon)
      ..append(titleElement)
      ..append(messageElement);

    final normalizedDetail = detail?.trim() ?? '';
    if (normalizedDetail.isNotEmpty) {
      final detailsElement = Element.tag('details')
        ..classes.addAll(['text-start', 'mt-3']);
      final summaryElement = Element.tag('summary')
        ..classes.addAll(['text-primary', 'cursor-pointer'])
        ..text = detailLabel;
      final preElement = PreElement()
        ..classes.addAll(['mt-2', 'mb-0', 'p-3', 'bg-light', 'border'])
        ..style.maxHeight = '180px'
        ..style.overflow = 'auto'
        ..style.whiteSpace = 'pre-wrap'
        ..style.fontSize = '.8125rem'
        ..text = normalizedDetail;
      detailsElement
        ..append(summaryElement)
        ..append(preElement);
      panel.append(detailsElement);
    }

    final actions = DivElement()
      ..classes.addAll([
        'd-flex',
        'align-items-center',
        'justify-content-center',
        'gap-2',
        'mt-4',
      ]);

    if (onAction != null && actionLabel.trim().isNotEmpty) {
      final actionButton = ButtonElement()
        ..type = 'button'
        ..classes.addAll([
          'btn',
          'btn-primary',
          'btn-labeled',
          'btn-labeled-start',
        ]);
      final actionIcon = SpanElement()
        ..classes.addAll([
          'btn-labeled-icon',
          'bg-black',
          'bg-opacity-20',
        ]);
      actionIcon.append(
        Element.tag('i')..classes.addAll(actionIconClass.split(' ')),
      );
      actionButton
        ..append(actionIcon)
        ..append(Text(actionLabel));
      _actionSub = actionButton.onClick.listen((_) {
        hide();
        onAction();
      });
      actions.append(actionButton);
    }

    if (onRetry != null) {
      final retryButton = ButtonElement()
        ..type = 'button'
        ..classes.addAll([
          'btn',
          'btn-primary',
          'btn-labeled',
          'btn-labeled-start',
        ]);
      final retryIcon = SpanElement()
        ..classes.addAll([
          'btn-labeled-icon',
          'bg-black',
          'bg-opacity-20',
        ]);
      retryIcon.append(
        Element.tag('i')..classes.addAll(['ph', 'ph-arrow-clockwise']),
      );
      retryButton
        ..append(retryIcon)
        ..append(Text(retryLabel));
      _retrySub = retryButton.onClick.listen((_) {
        hide();
        onRetry();
      });
      actions.append(retryButton);
    }

    final closeButton = ButtonElement()
      ..type = 'button'
      ..classes.addAll(['btn', 'btn-light'])
      ..text = closeLabel;
    _closeSub = closeButton.onClick.listen((_) => hide());
    actions.append(closeButton);
    panel.append(actions);

    _panel = panel;
    _root.append(_panel!);
    _target!.append(_root);
    _startPositionObservers();
    _rafUpdate();
  }

  /// Removes the panel and releases every listener it created.
  ///
  /// Safe to call when nothing is showing, and called by [show] before opening
  /// a new panel.
  void hide() {
    _retrySub?.cancel();
    _actionSub?.cancel();
    _closeSub?.cancel();
    _retrySub = null;
    _actionSub = null;
    _closeSub = null;
    _winScrollSub?.cancel();
    _containerScrollSub?.cancel();
    _resizeSub?.cancel();
    _ro?.disconnect();
    _winScrollSub = null;
    _containerScrollSub = null;
    _resizeSub = null;
    _ro = null;
    _scrollContainer = null;
    _panel = null;
    _target = null;
    _root.remove();
  }

  void _startPositionObservers() {
    if (_target == null) {
      return;
    }
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
  }

  void _rafUpdate() {
    if (_target != null && _target!.isConnected == true) {
      window.requestAnimationFrame((_) => _updatePanelPosition());
    } else {
      hide();
    }
  }

  void _updatePanelPosition() {
    if (_panel == null || _target == null) {
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

    double topInTarget;
    if (_placement == LiTargetAlertPlacement.top) {
      final visibleTopViewport = math.max(rect.top.toDouble(), _safeMargin);
      topInTarget = visibleTopViewport - rect.top.toDouble() + _topOffset;
    } else {
      final viewportH = (window.innerHeight ?? 0).toDouble();
      final centerYViewport = (rect.top + rect.height / 2).toDouble();
      final topClamp = _safeMargin;
      final bottomClamp = viewportH - _safeMargin;
      final clampedY =
          math.max(topClamp, math.min(centerYViewport, bottomClamp));
      topInTarget = clampedY - rect.top.toDouble();
    }

    _panel!.style.top = '${topInTarget}px';
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
}
