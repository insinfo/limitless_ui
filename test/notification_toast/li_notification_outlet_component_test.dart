// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/notification_toast/li_notification_outlet_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'package:limitless_ui/src/components/notification_toast/notification_toast.template.dart'
    as ng;

class NavigationCall {
  NavigationCall(this.path, this.navigationParams);

  final String path;
  final NavigationParams? navigationParams;
}

class FakeRouter implements Router {
  final List<NavigationCall> calls = <NavigationCall>[];

  final StreamController<String> _navigationStartController =
      StreamController<String>.broadcast();
  final StreamController<RouterState> _routeResolvedController =
      StreamController<RouterState>.broadcast();
  final StreamController<RouterState> _routeActivatedController =
      StreamController<RouterState>.broadcast();

  @override
  RouterState? get current => null;

  @override
  Stream<String> get onNavigationStart => _navigationStartController.stream;

  @override
  Stream<RouterState> get onRouteResolved => _routeResolvedController.stream;

  @override
  Stream<RouterState> get onRouteActivated => _routeActivatedController.stream;

  @override
  Stream<RouterState> get stream => _routeActivatedController.stream;

  @override
  Future<NavigationResult> navigate(
    String path, [
    NavigationParams? navigationParams,
  ]) async {
    calls.add(NavigationCall(path, navigationParams));
    return NavigationResult.success;
  }

  @override
  Future<NavigationResult> navigateByUrl(
    String url, {
    bool reload = false,
    bool replace = false,
  }) async {
    calls.add(
      NavigationCall(
        url,
        NavigationParams(reload: reload, replace: replace),
      ),
    );
    return NavigationResult.success;
  }

  @override
  void registerRootOutlet(RouterOutlet routerOutlet) {}

  @override
  void unregisterRootOutlet(RouterOutlet routerOutlet) {}

  void dispose() {
    _navigationStartController.close();
    _routeResolvedController.close();
    _routeActivatedController.close();
  }
}

void main() {
  late NgTestBed<LiNotificationOutletComponent> testBed;
  late NgTestFixture<LiNotificationOutletComponent> fixture;
  late FakeRouter router;
  late LiNotificationToastService service;

  Future<void> createFixture() async {
    fixture = await testBed.create(
      beforeChangeDetection: (component) {
        component.service = service;
      },
    );
    await _settle(fixture);
  }

  setUp(() {
    router = FakeRouter();
    service = LiNotificationToastService();
    testBed = NgTestBed<LiNotificationOutletComponent>(
      ng.LiNotificationOutletComponentNgFactory,
      rootInjector: (Injector parent) => Injector.map(
        <Object, Object>{Router: router},
        parent,
      ),
    );
  });

  tearDown(() async {
    service.dispose();
    router.dispose();
    await disposeAnyRunningTest();
  });

  test('renderiza toast no DOM', () async {
    await createFixture();

    service.notify(
      'Alteracoes salvas.',
      title: 'Sucesso',
      type: LiNotificationToastColor.success,
      durationSeconds: 5,
    );

    await _settle(fixture);

    expect(fixture.text, contains('Sucesso'));
    expect(fixture.text, contains('Alteracoes salvas.'));

    final items =
        fixture.rootElement.querySelectorAll('[data-label="notification_item"]');
    expect(items, hasLength(1));

    final body = fixture.rootElement.querySelector(
      '[data-label="notification_item_body"]',
    );
    expect(body, isNotNull);
    expect(body!.text, contains('Alteracoes salvas.'));
  });

  test('renderiza mais de um toast', () async {
    await createFixture();

    service.notify('Primeiro aviso', title: 'Primeiro', durationSeconds: 5);
    service.notify('Segundo aviso', title: 'Segundo', durationSeconds: 5);

    await _settle(fixture);

    final items =
        fixture.rootElement.querySelectorAll('[data-label="notification_item"]');

    expect(items, hasLength(2));
    expect(fixture.text, contains('Primeiro'));
    expect(fixture.text, contains('Segundo'));
  });

  test('botao fechar remove toast sem navegar', () async {
    await createFixture();

    service.notify(
      'Abrir detalhes',
      title: 'Linkado',
      durationSeconds: 5,
      link: '/detalhes?id=42&tab=history',
    );

    await _settle(fixture);

    final closeButton = fixture.rootElement.querySelector('.btn-close');

    expect(closeButton, isNotNull);

    await fixture.update((_) {
      closeButton!.dispatchEvent(
        html.MouseEvent('click', canBubble: true),
      );
    });
    await _settle(fixture);

    expect(service.toasts, isEmpty);
    expect(router.calls, isEmpty);
  });

  test('click no toast navega quando ha link simples', () async {
    await createFixture();

    service.notify(
      'Ir para dashboard',
      title: 'Dashboard',
      durationSeconds: 5,
      link: '/dashboard',
    );

    await _settle(fixture);

    final toastElement =
      fixture.rootElement.querySelector('[data-label="notification_item"]');

    expect(toastElement, isNotNull);

    await fixture.update((_) {
      toastElement!.dispatchEvent(
        html.MouseEvent('click', canBubble: true),
      );
    });
    await _settle(fixture);

    expect(router.calls, hasLength(1));
    expect(router.calls.single.path, '/dashboard');
    expect(router.calls.single.navigationParams, isNull);
    expect(service.toasts, isEmpty);
  });

  test('click no toast navega com query params e remove item', () async {
    await createFixture();

    service.notify(
      'Abrir detalhes',
      title: 'Linkado',
      durationSeconds: 5,
      link: '/detalhes?id=42&tab=history',
    );

    await _settle(fixture);

    final toastElement =
      fixture.rootElement.querySelector('[data-label="notification_item"]');

    expect(toastElement, isNotNull);

    await fixture.update((_) {
      toastElement!.dispatchEvent(
        html.MouseEvent('click', canBubble: true),
      );
    });
    await _settle(fixture);

    expect(router.calls, hasLength(1));
    expect(router.calls.single.path, '/detalhes');
    expect(
      router.calls.single.navigationParams?.queryParameters,
      equals(<String, String>{'id': '42', 'tab': 'history'}),
    );
    expect(service.toasts, isEmpty);
  });

  test('sem link, click nao navega', () async {
    await createFixture();

    service.notify(
      'Toast sem link',
      title: 'Info',
      durationSeconds: 5,
    );

    await _settle(fixture);

    final toastElement =
      fixture.rootElement.querySelector('[data-label="notification_item"]');

    expect(toastElement, isNotNull);

    await fixture.update((_) {
      toastElement!.dispatchEvent(
        html.MouseEvent('click', canBubble: true),
      );
    });
    await _settle(fixture);

    expect(router.calls, isEmpty);
    expect(service.toasts, hasLength(1));
  });

  test('instancia do componente mantem styleTop funcionando', () async {
    await createFixture();

    expect(fixture.assertOnlyInstance.styleTop(0), '0px');
    expect(fixture.assertOnlyInstance.styleTop(1), '20px');
    expect(fixture.assertOnlyInstance.styleTop(3), '60px');
  });
}

Future<void> _settle(
  NgTestFixture<LiNotificationOutletComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}