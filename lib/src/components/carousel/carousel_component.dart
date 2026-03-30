import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

import 'carousel_caption_component.dart';
import 'carousel_item_component.dart';

/// Public directives used by the carousel component suite.
const liCarouselDirectives = <Object>[
  LiCarouselComponent,
  LiCarouselCaptionComponent,
  LiCarouselItemComponent,
];

/// Limitless/Bootstrap carousel container.
///
/// IMPORTANT:
/// This component intentionally mirrors the original Bootstrap/Limitless
/// carousel markup contract for indicators and controls.
///
/// In particular, the generated DOM must keep:
/// - a stable host `id`
/// - `data-bs-target` on indicator buttons
/// - `data-bs-slide-to` on indicators
/// - `data-bs-slide` on prev/next controls
///
/// Limitless styles target those exact selectors. If they are removed or
/// renamed, the default indicator/control visuals break even if navigation
/// logic still works.
@Component(
  selector: 'li-carousel',
  templateUrl: 'carousel_component.html',
  styleUrls: ['carousel_component.css'],
  directives: [coreDirectives, LiCarouselItemComponent],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiCarouselComponent implements AfterContentInit, OnDestroy {
  LiCarouselComponent(this._changeDetectorRef) {
    final seq = _nextSequence++;
    _generatedId = 'li-carousel-$seq';
  }

  static int _nextSequence = 0;

  static const Duration _transitionDuration = Duration(milliseconds: 600);

  final ChangeDetectorRef _changeDetectorRef;
  final StreamController<int> _activeIndexChangeController =
      StreamController<int>.broadcast();

  @ContentChildren(LiCarouselItemComponent)
  List<LiCarouselItemComponent> items = <LiCarouselItemComponent>[];

  /// Shows previous/next navigation buttons.
  @Input()
  bool showControls = true;

  /// Shows indicator buttons at the bottom of the carousel.
  @Input()
  bool showIndicators = true;

  /// Enables the dark carousel variant from Limitless/Bootstrap.
  @Input()
  bool dark = false;

  /// Applies Bootstrap fade transition styles.
  @Input()
  bool fade = false;

  /// Selects the transition style used by the carousel.
  ///
  /// Supported values are `slide`, `fade`, `zoom`, `vertical`, `blur`, and
  /// `parallax`.
  /// When [fade] is true it takes precedence over this input.
  @Input()
  set transition(String? value) {
    final normalizedValue = value?.trim().toLowerCase();
    _transition = switch (normalizedValue) {
      'fade' => 'fade',
      'zoom' => 'zoom',
      'vertical' => 'vertical',
      'blur' => 'blur',
      'parallax' => 'parallax',
      _ => 'slide',
    };
  }

  String get transition => _transition;

  /// Allows the carousel to loop from last to first slide and back.
  @Input()
  bool wrap = true;

  /// Enables touch swipe navigation.
  @Input()
  bool touchEnabled = true;

  /// Enables keyboard navigation with arrow keys.
  @Input()
  bool keyboardEnabled = true;

  /// Pauses autoplay while the pointer is over the carousel.
  @Input()
  bool pauseOnHover = true;

  /// Starts automatic slide rotation.
  @Input()
  bool autoPlay = false;

  /// Default autoplay interval in milliseconds.
  @Input()
  int intervalMs = 5000;

  /// Initial slide index when no item is explicitly active.
  @Input()
  int initialIndex = 0;

  @Input()
  String previousLabel = 'Previous';

  @Input()
  String nextLabel = 'Next';

  /// Adds row semantics to the inner wrapper for multi-item slides.
  @Input()
  bool gridMode = false;

  /// Optional DOM id used to mirror Bootstrap/Limitless carousel markup.
  ///
  /// Indicator and control buttons expose `data-bs-target` so the original
  /// Limitless selectors keep styling them correctly. If no id is supplied,
  /// a stable generated id is used.
  @Input()
  String? id;

  @Output('activeIndexChange')
  Stream<int> get activeIndexChange => _activeIndexChangeController.stream;

  @HostBinding('class.carousel')
  bool hostCarouselClass = true;

  @HostBinding('class.slide')
  bool get hostSlideClass => !_usesFadeTransition;

  @HostBinding('class.carousel-fade')
  bool get hostFadeClass => _usesFadeTransition;

  @HostBinding('class.carousel-zoom')
  bool get hostZoomClass => _effectiveTransition == 'zoom';

  @HostBinding('class.carousel-vertical')
  bool get hostVerticalClass => _effectiveTransition == 'vertical';

  @HostBinding('class.carousel-blur')
  bool get hostBlurClass => _effectiveTransition == 'blur';

  @HostBinding('class.carousel-parallax')
  bool get hostParallaxClass => _effectiveTransition == 'parallax';

  @HostBinding('class.carousel-dark')
  bool get hostDarkClass => dark;

  @HostBinding('attr.id')
  String get hostId => id?.trim().isNotEmpty == true ? id!.trim() : _generatedId;

  @HostBinding('attr.tabindex')
  String? get hostTabIndex => keyboardEnabled ? '0' : null;

  int _activeIndex = 0;
  Timer? _autoPlayTimer;
  Timer? _transitionTimer;
  bool _hoverPaused = false;
  bool _isAnimating = false;
  num? _touchStartX;
  String _transition = 'slide';
  late final String _generatedId;

  String get carouselTargetSelector => '#$hostId';

  int get activeIndex => _activeIndex;

  bool get canNavigate => items.length > 1;

  String get _effectiveTransition => fade ? 'fade' : _transition;

  bool get _usesFadeTransition => _effectiveTransition == 'fade';

  @override
  void ngAfterContentInit() {
    _syncInitialState();
    _startAutoPlayIfNeeded();
  }

  void previous() {
    _navigate(false);
  }

  void next() {
    _navigate(true);
  }

  void goTo(int index) {
    if (_isAnimating ||
        items.isEmpty ||
        index < 0 ||
        index >= items.length ||
        index == _activeIndex) {
      return;
    }

    _animateToIndex(index, isNext: index > _activeIndex);
  }

  String indicatorLabelFor(int index) {
    final item = items[index];
    final customLabel = item.indicatorLabel?.trim();
    if (customLabel != null && customLabel.isNotEmpty) {
      return customLabel;
    }

    return 'Slide ${index + 1}';
  }

  @HostListener('mouseenter')
  void onMouseEnter() {
    if (!pauseOnHover) {
      return;
    }

    _hoverPaused = true;
    _cancelAutoPlay();
  }

  @HostListener('mouseleave')
  void onMouseLeave() {
    if (!pauseOnHover) {
      return;
    }

    _hoverPaused = false;
    _startAutoPlayIfNeeded();
  }

  @HostListener('keydown', ['\$event'])
  void onKeyDown(html.KeyboardEvent event) {
    if (!keyboardEnabled || !canNavigate) {
      return;
    }

    if (event.key == 'ArrowLeft') {
      event.preventDefault();
      previous();
      return;
    }

    if (event.key == 'ArrowRight') {
      event.preventDefault();
      next();
    }
  }

  @HostListener('touchstart', ['\$event'])
  void onTouchStart(html.TouchEvent event) {
    if (!touchEnabled || event.touches == null || event.touches!.isEmpty) {
      return;
    }

    _touchStartX = event.touches!.first.client.x;
  }

  @HostListener('touchend', ['\$event'])
  void onTouchEnd(html.TouchEvent event) {
    if (!touchEnabled || _touchStartX == null) {
      return;
    }

    final changedTouches = event.changedTouches;
    if (changedTouches == null || changedTouches.isEmpty) {
      _touchStartX = null;
      return;
    }

    final endX = changedTouches.first.client.x;
    final deltaX = endX - _touchStartX!;
    _touchStartX = null;

    if (deltaX.abs() < 40) {
      return;
    }

    if (deltaX > 0) {
      previous();
      return;
    }

    next();
  }

  void _syncInitialState() {
    if (items.isEmpty) {
      _activeIndex = 0;
      return;
    }

    final requestedInitialIndex = initialIndex.clamp(0, items.length - 1);
    final explicitActiveIndex = items.indexWhere((item) => item.active);
    _activeIndex = explicitActiveIndex >= 0 ? explicitActiveIndex : requestedInitialIndex;

    for (var index = 0; index < items.length; index++) {
      items[index].setState(active: index == _activeIndex);
    }

    _changeDetectorRef.markForCheck();
  }

  void _navigate(bool isNext) {
    if (items.isEmpty || _isAnimating) {
      return;
    }

    final newIndex = isNext
        ? (_activeIndex < items.length - 1
            ? _activeIndex + 1
            : (wrap ? 0 : _activeIndex))
        : (_activeIndex > 0
            ? _activeIndex - 1
            : (wrap ? items.length - 1 : _activeIndex));

    if (newIndex == _activeIndex) {
      return;
    }

    _animateToIndex(newIndex, isNext: isNext);
  }

  void _animateToIndex(int nextIndex, {required bool isNext}) {
    if (_isAnimating ||
        nextIndex < 0 ||
        nextIndex >= items.length ||
        nextIndex == _activeIndex) {
      return;
    }

    _isAnimating = true;
    _cancelAutoPlay();
    _transitionTimer?.cancel();

    final previousIndex = _activeIndex;
    final currentItem = items[previousIndex];
    final nextItem = items[nextIndex];

    // Bootstrap updates the active indicator immediately on interaction.
    // Keep the same behavior here so the control state does not lag behind
    // the slide transition animation.
    _activeIndex = nextIndex;
    _activeIndexChangeController.add(_activeIndex);
    _changeDetectorRef.markForCheck();

    nextItem.setState(
      isNext: isNext,
      isPrev: !isNext,
    );

    html.window.requestAnimationFrame((_) {
      nextItem.forceReflow();

      currentItem.setState(
        active: true,
        isStart: isNext,
        isEnd: !isNext,
      );
      nextItem.setState(
        isNext: isNext,
        isPrev: !isNext,
        isStart: isNext,
        isEnd: !isNext,
      );

      _transitionTimer = Timer(_transitionDuration, () => _finalizeTransition(nextIndex));
    });
  }

  void _finalizeTransition(int newIndex) {
    for (var index = 0; index < items.length; index++) {
      items[index].setState(active: index == newIndex);
    }

    _isAnimating = false;
    _changeDetectorRef.markForCheck();
    _startAutoPlayIfNeeded();
  }

  void _startAutoPlayIfNeeded() {
    if (!autoPlay || items.length <= 1 || _hoverPaused) {
      return;
    }

    final duration = _resolvedInterval;
    if (duration == null || duration <= Duration.zero) {
      return;
    }

    _cancelAutoPlay();
    _autoPlayTimer = Timer.periodic(duration, (_) => next());
  }

  void _cancelAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  Duration? get _resolvedInterval {
    if (items.isEmpty) {
      return null;
    }

    final itemInterval = items[_activeIndex].intervalMs;
    final effectiveInterval = itemInterval ?? intervalMs;
    if (effectiveInterval <= 0) {
      return null;
    }

    return Duration(milliseconds: effectiveInterval);
  }

  @override
  void ngOnDestroy() {
    _cancelAutoPlay();
    _transitionTimer?.cancel();
    _activeIndexChangeController.close();
  }
}
