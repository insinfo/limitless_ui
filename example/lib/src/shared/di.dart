// ignore_for_file: uri_has_not_been_generated

import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_router/ngx_router.dart';

import 'di.template.dart' as self;

@GenerateInjector([
  routerProvidersHash,
  formProviders,
])
final InjectorFactory injector = self.injector$Injector;
