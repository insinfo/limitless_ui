import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';

import 'di.template.dart' as self;

@GenerateInjector([
  routerProvidersHash,
])
final InjectorFactory injector = self.injector$Injector;
