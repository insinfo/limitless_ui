// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/offcanvas/li_offcanvas_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_offcanvas_component_test.template.dart' as ng;

@Component(
  selector: 'offcanvas-basic-test-host',
  template: '''
    <div>
      <button id="open-basic" type="button" (click)="basicOffcanvas?.open()">Open</button>
      <button id="close-basic" type="button" (click)="basicOffcanvas?.close()">Close</button>

      <li-offcanvas #basicOffcanvas
                    title-text="Basic"
                    [lazyContent]="true"
                    (close)="closeCount = closeCount + 1"
                    (dismiss)="dismissCount = dismissCount + 1">
        <div id="lazy-body">Lazy body</div>
      </li-offcanvas>
    </div>
  ''',
  directives: [coreDirectives, liOffcanvasDirectives],
)
class BasicTestHostComponent {
  @ViewChild('basicOffcanvas')
  LiOffcanvasComponent? basicOffcanvas;

  int closeCount = 0;
  int dismissCount = 0;
}

@Component(
  selector: 'offcanvas-start-open-test-host',
  template: '''
    <li-offcanvas #startOpenOffcanvas title-text="Start open" [start-open]="true">
      <button id="start-focus" type="button" [attr.liOffcanvasAutofocus]="'true'">Focusable</button>
    </li-offcanvas>
  ''',
  directives: [liOffcanvasDirectives],
)
class StartOpenTestHostComponent {}

@Component(
  selector: 'offcanvas-projection-test-host',
  template: '''
    <li-offcanvas #customOffcanvas title-text="Ignored title">
      <div liOffcanvasHeader class="offcanvas-header bg-dark text-white">
        <h5 class="offcanvas-title mb-0">Custom header</h5>
        <button id="custom-close" type="button" class="btn-close btn-close-white" (click)="customOffcanvas?.close()"></button>
      </div>
      <div id="custom-body">Custom body</div>
      <div liOffcanvasFooter class="border-top p-3">
        <button id="custom-footer-button" type="button" class="btn btn-primary">Action</button>
      </div>
    </li-offcanvas>
  ''',
  directives: [coreDirectives, liOffcanvasDirectives],
)
class ProjectionTestHostComponent {
  @ViewChild('customOffcanvas')
  LiOffcanvasComponent? customOffcanvas;
}

@Component(
  selector: 'offcanvas-service-test-host',
  template: '''
    <li-offcanvas #serviceOffcanvas
                  offcanvasId="service-panel"
                  title-text="Service panel"
                  (shown)="shownCount = shownCount + 1"
                  (hidden)="hiddenCount = hiddenCount + 1">
      <div id="service-body">Service body</div>
    </li-offcanvas>
  ''',
  directives: [liOffcanvasDirectives],
  providers: [ClassProvider(LiOffcanvasService)],
)
class ServiceTestHostComponent {
  ServiceTestHostComponent(this.offcanvasService);

  final LiOffcanvasService offcanvasService;
  int shownCount = 0;
  int hiddenCount = 0;
}

@Component(
  selector: 'offcanvas-guarded-test-host',
  template: '''
    <li-offcanvas #guardedOffcanvas
                  title-text="Guarded"
                  [beforeDismiss]="beforeDismiss"
                  (dismiss)="dismissCount = dismissCount + 1">
      <div id="guarded-body">Guarded body</div>
    </li-offcanvas>
  ''',
  directives: [liOffcanvasDirectives],
)
class GuardedTestHostComponent {
  @ViewChild('guardedOffcanvas')
  LiOffcanvasComponent? guardedOffcanvas;

  bool blockDismiss = true;
  int dismissCount = 0;

  Future<bool> beforeDismiss(LiOffcanvasDismissReason reason) async {
    return !blockDismiss;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final basicTestBed =
      NgTestBed<BasicTestHostComponent>(ng.BasicTestHostComponentNgFactory);
  final startOpenTestBed = NgTestBed<StartOpenTestHostComponent>(
    ng.StartOpenTestHostComponentNgFactory,
  );
  final projectionTestBed = NgTestBed<ProjectionTestHostComponent>(
    ng.ProjectionTestHostComponentNgFactory,
  );
  final serviceTestBed = NgTestBed<ServiceTestHostComponent>(
    ng.ServiceTestHostComponentNgFactory,
  );
  final guardedTestBed = NgTestBed<GuardedTestHostComponent>(
    ng.GuardedTestHostComponentNgFactory,
  );

  test('lazy content mounts only while offcanvas is open', () async {
    final fixture = await basicTestBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(html.document.body!.querySelector('#lazy-body'), isNull);

    await fixture.update((_) {
      _clickById('open-basic');
    });
    await _settle(fixture);

    expect(html.document.body!.querySelector('#lazy-body'), isNotNull);
    expect(host.basicOffcanvas!.isOpen, isTrue);
    expect(html.document.body!.classes.contains('offcanvas-open'), isTrue);

    await fixture.update((_) {
      _clickById('close-basic');
    });
    await _settle(fixture);

    expect(html.document.body!.querySelector('#lazy-body'), isNull);
    expect(host.basicOffcanvas!.isOpen, isFalse);
    expect(host.closeCount, 1);
    expect(html.document.body!.classes.contains('offcanvas-open'), isFalse);
  });

  test('startOpen opens immediately and applies autofocus', () async {
    final fixture = await startOpenTestBed.create();
    await _settle(fixture);

    final startFocus = html.document.body!.querySelector('#start-focus');
    expect(startFocus, isNotNull);
    expect(html.document.activeElement, equals(startFocus));
  });

  test('supports custom header and projected footer', () async {
    final fixture = await projectionTestBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.customOffcanvas?.open();
    });
    await _settle(fixture);

    expect(html.document.body!.querySelector('#custom-body'), isNotNull);
    expect(
      html.document.body!.querySelector('#custom-footer-button'),
      isNotNull,
    );
    expect(
      html.document.body!
          .querySelector('.offcanvas-header .offcanvas-title')
          ?.text,
      contains('Custom header'),
    );
  });

  test('service opens a registered offcanvas and returns a reusable ref',
      () async {
    final fixture = await serviceTestBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(html.document.body!.querySelector('#service-body'), isNull);

    final ref = host.offcanvasService.open('service-panel');
    await _settle(fixture);

    expect(ref.isOpen, isTrue);
    expect(html.document.body!.querySelector('#service-body'), isNotNull);
    expect(host.shownCount, 1);

    ref.close();
    await _settle(fixture);

    expect(ref.isOpen, isFalse);
    expect(host.hiddenCount, 1);
  });

  test('beforeDismiss blocks dismiss until the guard allows it', () async {
    final fixture = await guardedTestBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    host.guardedOffcanvas?.open();
    await _settle(fixture);

    await host.guardedOffcanvas?.dismiss(LiOffcanvasDismissReason.escape);
    await _settle(fixture);

    expect(host.guardedOffcanvas?.isOpen, isTrue);
    expect(host.dismissCount, 0);

    host.blockDismiss = false;
    await host.guardedOffcanvas?.dismiss(LiOffcanvasDismissReason.escape);
    await _settle(fixture);

    expect(host.guardedOffcanvas?.isOpen, isFalse);
    expect(host.dismissCount, 1);
  });
}

void _clickById(String id) {
  final element = html.document.body!.querySelector('#$id');
  expect(element, isNotNull);
  element!.dispatchEvent(html.MouseEvent('click', canBubble: true));
}

Future<void> _settle(NgTestFixture<dynamic> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
  await Future<void>.delayed(const Duration(milliseconds: 320));
  await fixture.update((_) {});
}
