import 'package:ngdart/angular.dart';

/// Default configuration for [LiDropdownDirective].
@Injectable()
class LiDropdownConfig {
  LiDropdownConfig({
    this.autoClose = true,
    this.container,
    this.display,
    this.placement = 'bottom-start bottom-end top-start top-end',
  });

  dynamic autoClose;
  String? container;
  String? display;
  dynamic placement;
}
