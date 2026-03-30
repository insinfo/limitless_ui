import 'dart:html' as html;

import 'package:ngdart/angular.dart';

/// Limitless/Bootstrap carousel item.
@Component(
  selector: 'li-carousel-item',
  templateUrl: 'carousel_item_component.html',
  styleUrls: ['carousel_item_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiCarouselItemComponent {
  LiCarouselItemComponent(this._hostElement, this._changeDetectorRef);

  final html.Element _hostElement;
  final ChangeDetectorRef _changeDetectorRef;

  @Input()
  set active(bool value) {
    _active = value;
  }

  bool get active => _active;

  /// Optional item-specific autoplay interval in milliseconds.
  @Input()
  int? intervalMs;

  /// Accessible label used by the indicator button.
  @Input()
  String? indicatorLabel;

  @HostBinding('class.carousel-item')
  bool hostCarouselItemClass = true;

  @HostBinding('class.active')
  bool get hostActiveClass => _active;

  @HostBinding('class.carousel-item-next')
  bool isNext = false;

  @HostBinding('class.carousel-item-prev')
  bool isPrev = false;

  @HostBinding('class.carousel-item-start')
  bool isStart = false;

  @HostBinding('class.carousel-item-end')
  bool isEnd = false;

  @HostBinding('attr.aria-hidden')
  String get ariaHidden => (!_active).toString();

  bool _active = false;

  void forceReflow() {
    _hostElement.getBoundingClientRect();
  }

  void setState({
    bool active = false,
    bool isNext = false,
    bool isPrev = false,
    bool isStart = false,
    bool isEnd = false,
  }) {
    _active = active;
    this.isNext = isNext;
    this.isPrev = isPrev;
    this.isStart = isStart;
    this.isEnd = isEnd;
    _changeDetectorRef.markForCheck();
  }
}
