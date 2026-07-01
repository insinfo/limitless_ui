// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/helpers/li_simple_helper_modal_stack_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_simple_helper_modal_stack_test.template.dart' as ng;

@Component(
  selector: 'simple-helper-modal-host',
  template: '''
    <button id="open-helper-modal" type="button" (click)="modal?.open()">Open modal</button>

    <li-modal #modal title-text="Helper modal">
      <div class="d-flex flex-wrap gap-2 mb-3">
        <button id="show-helper-alert" type="button" (click)="showAlert()">Show helper alert</button>
        <button id="show-body-loading" type="button" (click)="showLoadingOnBody()">Show body loading</button>
        <button id="show-narrated-loading" type="button" (click)="showNarratedLoadingOnBody()">Show narrated loading</button>
        <button id="show-target-loading" type="button" (click)="showLoadingOnTarget()">Show target loading</button>
        <button id="hide-loading" type="button" (click)="loading.hide()">Hide loading</button>
      </div>

      <div #loadingHost id="loading-host" style="min-height: 8rem; border: 1px dashed #ccc;">
        Loading target
      </div>
    </li-modal>
  ''',
  directives: [coreDirectives, LiModalComponent],
)
class TestHostComponent {
  @ViewChild('modal')
  LiModalComponent? modal;

  @ViewChild('loadingHost')
  html.DivElement? loadingHost;

  final LiSimpleLoading loading = LiSimpleLoading();
  final LiNarratedFullScreenLoading narratedLoading =
      LiNarratedFullScreenLoading(
    title: 'Narrated helper',
    messages: const <String>['Step one', 'Step two', 'Step three'],
    stepDuration: Duration(milliseconds: 60),
  );

  void showAlert() {
    LiSimpleDialogComponent.showAlert(
      'Helper alert body',
      title: 'Helper alert',
    );
  }

  void showLoadingOnBody() {
    loading.showOnBody();
  }

  void showNarratedLoadingOnBody() {
    narratedLoading.showOnBody();
  }

  void showLoadingOnTarget() {
    final host = loadingHost;
    if (host == null) {
      return;
    }

    loading.show(target: host);
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TestHostComponent>(ng.TestHostComponentNgFactory);

  test('LiSimpleDialogComponent abre acima de li-modal', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-helper-modal');
    });
    await _settle(fixture);

    final modalRoot = _modalRootByTitle('Helper modal');
    final modalBackdrop =
        html.document.body!.querySelector('.li-modal-backdrop');
    expect(modalRoot, isNotNull);
    expect(modalBackdrop, isNotNull);

    await fixture.update((_) {
      _clickById('show-helper-alert');
    });
    await _settle(fixture);

    final helperDialog =
        html.document.body!.querySelector('.li-simple-dialog__modal');
    final helperBackdrop =
        html.document.body!.querySelector('.li-simple-dialog__backdrop');

    expect(helperDialog, isNotNull);
    expect(helperBackdrop, isNotNull);
    expect(helperDialog!.getAttribute('data-label'), 'li_simple_dialog_modal');
    expect(helperDialog.getAttribute('data-open'), 'true');
    expect(helperBackdrop!.getAttribute('data-label'),
        'li_simple_dialog_backdrop');
    expect(
        helperDialog.style.zIndex, '${LiSimpleDialogComponent.defaultZIndex}');
    expect(
      int.parse(helperDialog.style.zIndex),
      greaterThan(int.parse(modalRoot!.style.zIndex)),
    );
    expect(
      int.parse(helperBackdrop.style.zIndex),
      greaterThan(int.parse(modalBackdrop!.style.zIndex)),
    );

    final okButton = helperDialog.querySelector('button.BtnOk');
    expect(okButton, isNotNull);
    okButton!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    await _settle(fixture);

    expect(
        html.document.body!.querySelector('.li-simple-dialog__modal'), isNull);
  });

  test('LiSimpleLoading showOnBody fica acima de li-modal', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-helper-modal');
    });
    await _settle(fixture);

    final modalRoot = _modalRootByTitle('Helper modal');
    expect(modalRoot, isNotNull);

    await fixture.update((_) {
      _clickById('show-body-loading');
    });
    await _settle(fixture);

    final overlay = html.document.body!.querySelector('.li-simple-loading');
    expect(overlay, isNotNull);
    expect(overlay!.style.zIndex, '${LiSimpleLoading.defaultBodyZIndex}');
    expect(
      int.parse(overlay.style.zIndex),
      greaterThan(int.parse(modalRoot!.style.zIndex)),
    );

    await fixture.update((host) {
      host.loading.hide();
    });
    await _settle(fixture);

    expect(html.document.body!.querySelector('.li-simple-loading'), isNull);
  });

  test('LiNarratedFullScreenLoading showOnBody fica acima de li-modal',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-helper-modal');
    });
    await _settle(fixture);

    final modalRoot = _modalRootByTitle('Helper modal');
    expect(modalRoot, isNotNull);

    await fixture.update((_) {
      _clickById('show-narrated-loading');
    });
    await _settle(fixture);

    final overlay = html.document.body!.querySelector(
      '.li-narrated-full-screen-loading',
    );
    final message = overlay?.querySelector(
      '.li-narrated-full-screen-loading__message',
    );

    expect(overlay, isNotNull);
    expect(
        overlay!.style.zIndex, '${LiNarratedFullScreenLoading.defaultZIndex}');
    expect(
      int.parse(overlay.style.zIndex),
      greaterThan(int.parse(modalRoot!.style.zIndex)),
    );
    expect(message?.text?.trim(), isNotEmpty);

    await fixture.update((host) {
      host.narratedLoading.hide();
    });
    await _settle(fixture);

    expect(
      html.document.body!.querySelector('.li-narrated-full-screen-loading'),
      isNull,
    );
  });

  test(
      'LiNarratedFullScreenLoading updateMessage com stopRotation congela a mensagem',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-helper-modal');
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('show-narrated-loading');
    });
    await _settle(fixture);

    await fixture.update((host) {
      host.narratedLoading.updateMessage('Pinned message', stopRotation: true);
    });
    await _settle(fixture);

    final pinnedMessage = html.document.body!
        .querySelector('.li-narrated-full-screen-loading__message');
    expect(pinnedMessage, isNotNull);
    expect(pinnedMessage!.text, 'Pinned message');

    await Future<void>.delayed(const Duration(milliseconds: 180));
    await _settle(fixture);

    final messageAfterDelay = html.document.body!
        .querySelector('.li-narrated-full-screen-loading__message');
    expect(messageAfterDelay, isNotNull);
    expect(messageAfterDelay!.text, 'Pinned message');

    await fixture.update((host) {
      host.narratedLoading.hide();
    });
    await _settle(fixture);

    expect(
      html.document.body!.querySelector('.li-narrated-full-screen-loading'),
      isNull,
    );
  });

  test('LiSimpleLoading show(target:) ancora overlay dentro do modal',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-helper-modal');
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('show-target-loading');
    });
    await _settle(fixture);

    final loadingHost = html.document.body!.querySelector('#loading-host');
    final overlay = loadingHost?.querySelector('.li-simple-loading');

    expect(loadingHost, isNotNull);
    expect(overlay, isNotNull);
    expect(overlay!.style.position, 'absolute');
    expect(overlay.style.zIndex, '${LiSimpleLoading.defaultTargetZIndex}');

    await fixture.update((host) {
      host.loading.hide();
    });
    await _settle(fixture);

    expect(loadingHost!.querySelector('.li-simple-loading'), isNull);
  });
}

void _clickById(String id) {
  final element = html.document.body!.querySelector('#$id');
  expect(element, isNotNull);
  element!.dispatchEvent(html.MouseEvent('click', canBubble: true));
}

Future<void> _settle<T>(NgTestFixture<T> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
  await Future<void>.delayed(const Duration(milliseconds: 30));
}

html.Element? _modalRootByTitle(String title) {
  for (final modal in html.document.body!.querySelectorAll('.modal')) {
    final titleElement = modal.querySelector('.modal-title');
    if (titleElement?.text?.trim() == title) {
      return modal;
    }
  }

  return null;
}
