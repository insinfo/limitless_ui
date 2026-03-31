import 'package:ngdart/angular.dart';

import 'scrollspy_service.dart';

/// Default configuration for [LiScrollSpyService].
@Injectable()
class LiScrollSpyConfig {
  LiScrollSpyConfig({
    this.processChanges = defaultLiScrollSpyProcessChanges,
    this.scrollBehavior = 'smooth',
  });

  LiScrollSpyProcessChanges processChanges;
  String scrollBehavior;
}
