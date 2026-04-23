// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/toast/li_toast_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_toast_component_test.template.dart' as ng;

@Component(
  selector: 'toast-test-host',
  template: '''
    <div>
      <li-toast
          #basicToast
          header="Basic header"
          body="Basic body"
          [autohide]="false"
          [animation]="false"
          (shown)="basicShown = basicShown + 1"
          (hidden)="basicHidden = basicHidden + 1">
      </li-toast>

      <li-toast
          #timedToast
          header="Timed header"
          body="Timed body"
          [startOpen]="false"
          [delay]="200"
          [animation]="false"
          (hidden)="timedHidden = timedHidden + 1">
      </li-toast>

      <li-toast
          header="Warning header"
          body="Warning body"
          toastClass="bg-warning text-white border-0"
          [autohide]="false"
          [animation]="false">
      </li-toast>

      <li-toast-stack [service]="toastService" placement="top-end"></li-toast-stack>
    </div>
  ''',
  directives: [coreDirectives, LiToastComponent, LiToastStackComponent],
)
class ToastTestHostComponent {
  final LiToastService toastService = LiToastService();

  int basicShown = 0;
  int basicHidden = 0;
  int timedHidden = 0;

  @ViewChild('basicToast')
  LiToastComponent? basicToast;

  @ViewChild('timedToast')
  LiToastComponent? timedToast;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<ToastTestHostComponent>(
    ng.ToastTestHostComponentNgFactory,
  );

  test('renderiza header/body e expõe hide/show por ViewChild', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.basicToast, isNotNull);
    expect(host.basicToast!.isOpen, isTrue);
    expect(fixture.rootElement.text, contains('Basic header'));
    expect(fixture.rootElement.text, contains('Basic body'));
    expect(host.basicShown, 1);

    await fixture.update((component) {
      component.basicToast!.hide();
    });
    await _settle(fixture);

    expect(host.basicToast!.isOpen, isFalse);
    expect(host.basicHidden, 1);

    await fixture.update((component) {
      component.basicToast!.show();
    });
    await _settle(fixture);

    expect(host.basicToast!.isOpen, isTrue);
    expect(host.basicShown, 2);
  });

  test('autohide fecha o toast após o delay', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.timedToast, isNotNull);
    host.timedToast!.show();
    await _settle(fixture);

    await Future<void>.delayed(const Duration(milliseconds: 260));
    await _settle(fixture);

    expect(host.timedToast!.isOpen, isFalse);
    expect(host.timedHidden, 1);
  });

  test('toast stack remove items when hidden event fires', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.toastService.toasts, isEmpty);

    await fixture.update((component) {
      component.toastService.show(
        header: 'Stack header',
        body: 'Stack body',
        animation: false,
        autohide: false,
      );
    });
    await _settle(fixture);

    expect(host.toastService.toasts, hasLength(1));
    expect(html.document.querySelector('.li-toast-stack .toast'), isNotNull);

    final closeButton =
        html.document.querySelector('.li-toast-stack .btn-close');
    expect(closeButton, isNotNull);

    await fixture.update((_) {
      closeButton!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.toastService.toasts, isEmpty);
    expect(html.document.querySelector('.li-toast-stack .toast'), isNull);
  });

  test('usa header escurecido e close branco em toast sólido', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final solidToast = fixture.rootElement
        .querySelectorAll('.toast')
        .cast<html.Element>()
        .firstWhere((element) => (element.text ?? '').contains('Warning body'));
    final header = solidToast.querySelector('.toast-header');
    final closeButton = solidToast.querySelector('.btn-close');

    expect(solidToast.classes.contains('bg-warning'), isTrue);
    expect(solidToast.classes.contains('text-white'), isTrue);
    expect(header, isNotNull);
    expect(header!.classes.contains('bg-black'), isTrue);
    expect(header.classes.contains('bg-opacity-10'), isTrue);
    expect(header.classes.contains('text-white'), isTrue);
    expect(closeButton, isNotNull);
    expect(closeButton!.classes.contains('btn-close-white'), isTrue);
  });
}

Future<void> _settle(NgTestFixture<ToastTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}
