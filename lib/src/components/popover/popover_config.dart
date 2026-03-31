import 'package:ngdart/angular.dart';
import 'package:popper/popper.dart';

PopperOptions defaultLiPopoverPopperOptions(PopperOptions options) => options;

typedef LiPopoverPopperOptions = PopperOptions Function(PopperOptions options);

/// Default configuration for [LiPopoverComponent].
@Injectable()
class LiPopoverConfig {
  LiPopoverConfig({
    this.animation = true,
    this.autoClose = true,
    this.closeDelay = 0,
    this.container,
    this.disablePopover = false,
    this.openDelay = 0,
    this.placement = 'auto',
    this.popoverClass,
    this.popoverContext,
    this.popperOptions = defaultLiPopoverPopperOptions,
    this.triggers = 'click',
  });

  bool animation;
  dynamic autoClose;
  int closeDelay;
  String? container;
  bool disablePopover;
  int openDelay;
  String placement;
  String? popoverClass;
  Object? popoverContext;
  LiPopoverPopperOptions popperOptions;
  String triggers;
}
