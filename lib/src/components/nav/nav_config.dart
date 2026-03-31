import 'package:ngdart/angular.dart';

/// Default configuration for [LiNavDirective].
@Injectable()
class LiNavConfig {
  LiNavConfig({
    this.animation = false,
    this.destroyOnHide = true,
    this.keyboard = true,
    this.orientation = 'horizontal',
    this.roles = true,
  });

  bool animation;
  bool destroyOnHide;
  dynamic keyboard;
  String orientation;
  bool roles;
}
