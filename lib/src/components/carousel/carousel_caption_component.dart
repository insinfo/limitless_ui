import 'package:ngdart/angular.dart';

/// Limitless/Bootstrap carousel caption wrapper.
@Component(
  selector: 'li-carousel-caption',
  template: '<ng-content></ng-content>',
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiCarouselCaptionComponent {
  @HostBinding('class.carousel-caption')
  bool isCaption = true;

  @HostBinding('class.d-none')
  bool isHiddenOnSmallScreens = true;

  @HostBinding('class.d-md-block')
  bool isVisibleFromMd = true;
}
