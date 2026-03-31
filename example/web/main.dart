// ignore_for_file: uri_has_not_been_generated

import 'package:ngdart/angular.dart';

import 'package:limitless_ui_example/src/app/app_component.template.dart' as ng;
import 'package:limitless_ui_example/src/shared/di.dart';

void main() {
  runApp(
    ng.AppComponentNgFactory,
    createInjector: injector,
  );
}
