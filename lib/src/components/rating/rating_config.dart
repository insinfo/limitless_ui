import 'package:ngx_dart/angular.dart';

@Injectable()
class LiRatingConfig {
  int max = 5;
  bool readonly = false;
  bool resettable = false;
  String size = 'lg';
}
