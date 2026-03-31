import 'package:ngdart/angular.dart';

/// Default configuration for [LiTooltipComponent] and [LiTooltipDirective].
@Injectable()
class LiTooltipConfig {
  LiTooltipConfig({
    this.animation = true,
    this.autoClose = true,
    this.closeDelay = 0,
    this.container,
    this.disableTooltip = false,
    this.openDelay = 0,
    this.placement = 'top',
    this.tooltipClass,
    this.triggers = 'hover focus',
  });

  bool animation;
  dynamic autoClose;
  int closeDelay;
  String? container;
  bool disableTooltip;
  int openDelay;
  String placement;
  String? tooltipClass;
  String triggers;
}
