// ignore_for_file: uri_has_not_been_generated

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngrouter/ngrouter.dart';

import 'di.template.dart' as self;

@GenerateInjector([
  routerProvidersHash,
  formProviders,
])
final InjectorFactory injector = self.injector$Injector;
