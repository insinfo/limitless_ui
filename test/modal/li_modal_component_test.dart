// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/modal/li_modal_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_modal_component_test.template.dart' as ng;

@Component(
  selector: 'modal-test-host',
  template: '''
    <div>
      <button id="open-lazy" type="button" (click)="lazyModal?.open()">Open lazy</button>
      <button id="close-lazy" type="button" (click)="lazyModal?.close()">Close lazy</button>

      <li-modal #lazyModal
                title-text="Lazy"
                [lazyContent]="true"
                (close)="lazyCloseCount = lazyCloseCount + 1">
        <div id="lazy-body">Lazy body</div>
      </li-modal>

      <li-modal #eagerModal title-text="Eager">
        <div id="eager-body">Eager body</div>
      </li-modal>

      <li-modal title-text="Compact" [compactHeader]="true">
        <div id="compact-body">Compact body</div>
      </li-modal>

      <li-modal title-text="Small" [smallHeader]="true">
        <div id="small-body">Small body</div>
      </li-modal>

      <li-modal title-text="XXL" size="xx-large" headerColor="purple">
        <div id="xxl-body">XXL body</div>
      </li-modal>

      <li-modal title-text="XXXL" size="xxx-large" headerColor="teal">
        <div id="xxxl-body">XXXL body</div>
      </li-modal>

      <li-modal title-text="Fluid" size="modal-fluid">
        <div id="fluid-body">Fluid body</div>
      </li-modal>

      <li-modal #startOpenModal title-text="Start open" [start-open]="true">
        <div id="start-open-body">Start open body</div>
      </li-modal>

      <button id="open-projected" type="button" (click)="projectedModal?.open()">Open projected</button>
      <button id="open-no-escape" type="button" (click)="noEscapeModal?.open()">Open no escape</button>
      <button id="open-stack-a" type="button" (click)="stackModalA?.open()">Open stack A</button>
      <button id="open-stack-b" type="button" (click)="stackModalB?.open()">Open stack B</button>

      <li-modal #projectedModal
                [customWidth]="'520px'"
                [customHeight]="'420px'"
                [ariaLabel]="'Projected custom modal'">
        <div modal-header>
          <h5 class="modal-title mb-0" id="projected-title">Projected title</h5>
        </div>

        <div id="projected-body">Projected body</div>

        <div modal-footer>
          <button id="projected-footer-action" type="button" class="btn btn-primary" (click)="projectedModal?.close()">Apply</button>
        </div>
      </li-modal>

      <li-modal #stackModalA title-text="Stack A">
        <div id="stack-a-body">Stack A body</div>
      </li-modal>

      <li-modal #noEscapeModal
                title-text="No ESC"
                size="modal-full"
                [closeOnEscape]="false"
                [closeOnBackdropClick]="false"
                [enableCloseBtn]="false">
        <div id="no-escape-body">No escape body</div>
      </li-modal>

      <li-modal #stackModalB title-text="Stack B">
        <div id="stack-b-body">Stack B body</div>
      </li-modal>
    </div>
  ''',
  directives: [coreDirectives, LiModalComponent],
)
class TestHostComponent {
  @ViewChild('lazyModal')
  LiModalComponent? lazyModal;

  @ViewChild('startOpenModal')
  LiModalComponent? startOpenModal;

  @ViewChild('projectedModal')
  LiModalComponent? projectedModal;

  @ViewChild('noEscapeModal')
  LiModalComponent? noEscapeModal;

  @ViewChild('stackModalA')
  LiModalComponent? stackModalA;

  @ViewChild('stackModalB')
  LiModalComponent? stackModalB;

  int lazyCloseCount = 0;
}

@Component(
  selector: 'full-modal-test-host',
  template: '''
    <div>
      <button id="open-full" type="button" (click)="fullModal?.open()">Open full</button>
      <button id="open-full-shell" type="button" (click)="fullShellModal?.open()">Open full shell</button>

      <li-modal #fullModal title-text="Full" size="modal-full">
        <div id="full-body-content" style="height: 2000px;">Tall body</div>
      </li-modal>

      <li-modal #fullShellModal
                title-text="Full shell"
                size="modal-full"
                [fullScreenShell]="true">
        <div id="full-shell-body-content" style="height: 1200px;">Tall shell body</div>
      </li-modal>
    </div>
  ''',
  directives: [coreDirectives, LiModalComponent],
)
class FullModalTestHostComponent {
  @ViewChild('fullModal')
  LiModalComponent? fullModal;

  @ViewChild('fullShellModal')
  LiModalComponent? fullShellModal;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TestHostComponent>(ng.TestHostComponentNgFactory);
  final fullModalTestBed = NgTestBed<FullModalTestHostComponent>(
      ng.FullModalTestHostComponentNgFactory);

  test('lazy content mounts only while modal is open', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((host) {
      host.startOpenModal?.close();
    });
    await _settle(fixture);

    expect(html.document.body!.querySelector('#lazy-body'), isNull);
    expect(html.document.body!.querySelector('#eager-body'), isNotNull);

    await fixture.update((_) {
      _clickById('open-lazy');
    });
    await _settle(fixture);

    expect(html.document.body!.querySelector('#lazy-body'), isNotNull);
    expect(host.lazyModal!.isOpen, isTrue);
    expect(html.document.body!.classes.contains('modal-open'), isTrue);

    await fixture.update((_) {
      _clickById('close-lazy');
    });
    await _settle(fixture);

    expect(html.document.body!.querySelector('#lazy-body'), isNull);
    expect(host.lazyModal!.isOpen, isFalse);
    expect(host.lazyCloseCount, 1);
    expect(html.document.body!.classes.contains('modal-open'), isFalse);
  });

  test('startOpen renders content immediately after init', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    expect(
      html.document.body!.querySelector('#start-open-body'),
      isNotNull,
    );

    final openModal = html.document.body!
        .querySelectorAll('[data-status="open"]')
        .where((element) => element.querySelector('#start-open-body') != null);

    expect(openModal, isNotEmpty);
    expect(html.document.body!.classes.contains('modal-open'), isTrue);
  });

  test('compactHeader only applies the compact class when enabled', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final eagerHeader = _modalHeaderByTitle('Eager');
    final compactHeader = _modalHeaderByTitle('Compact');

    expect(eagerHeader, isNotNull);
    expect(compactHeader, isNotNull);
    expect(eagerHeader!.classes.contains('modal-header-compact'), isFalse);
    expect(compactHeader!.classes.contains('modal-header-compact'), isTrue);
  });

  test('smallHeader only applies the small class when enabled', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final eagerHeader = _modalHeaderByTitle('Eager');
    final smallHeader = _modalHeaderByTitle('Small');

    expect(eagerHeader, isNotNull);
    expect(smallHeader, isNotNull);
    expect(eagerHeader!.classes.contains('modal-header-small'), isFalse);
    expect(smallHeader!.classes.contains('modal-header-small'), isTrue);
  });

  test('wide sizes map to the new intermediate dialog classes', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final xxlDialog = _modalDialogByTitle('XXL');
    final xxxlDialog = _modalDialogByTitle('XXXL');
    final fluidDialog = _modalDialogByTitle('Fluid');

    expect(xxlDialog, isNotNull);
    expect(xxxlDialog, isNotNull);
    expect(fluidDialog, isNotNull);

    expect(xxlDialog!.classes.contains('modal-xxl'), isTrue);
    expect(xxxlDialog!.classes.contains('modal-xxxl'), isTrue);
    expect(fluidDialog!.classes.contains('modal-fluid'), isTrue);

    final xxlHeader = _modalHeaderByTitle('XXL');
    final xxxlHeader = _modalHeaderByTitle('XXXL');
    expect(xxlHeader, isNotNull);
    expect(xxxlHeader, isNotNull);
    expect(xxlHeader!.classes.contains('bg-purple'), isTrue);
    expect(xxxlHeader!.classes.contains('bg-teal'), isTrue);
  });

  test('supports projected header/footer and custom dimensions', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.startOpenModal?.close();
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-projected');
    });
    await _settle(fixture);

    final projectedTitle =
        html.document.body!.querySelector('#projected-title');
    final projectedBody = html.document.body!.querySelector('#projected-body');
    final projectedFooterAction =
        html.document.body!.querySelector('#projected-footer-action');

    expect(projectedTitle, isNotNull);
    expect(projectedBody, isNotNull);
    expect(projectedFooterAction, isNotNull);

    final projectedDialog = _closestAncestorWithClass(
      projectedBody as html.Element,
      'modal-dialog',
    );
    expect(projectedDialog, isNotNull);
    expect(projectedDialog!.style.maxWidth, '520px');
    expect(projectedDialog.style.width, '100%');
    expect(projectedDialog.style.height, '420px');

    final projectedRoot = _closestAncestorWithClass(
      projectedDialog,
      'modal',
    );
    expect(projectedRoot, isNotNull);
    expect(projectedRoot!.getAttribute('role'), 'dialog');
    expect(projectedRoot.getAttribute('aria-modal'), 'true');
    expect(projectedRoot.getAttribute('aria-label'), 'Projected custom modal');
  });

  test('escape closes only the topmost modal in the stack', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.startOpenModal?.close();
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-stack-a');
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-stack-b');
    });
    await _settle(fixture);

    expect(fixture.assertOnlyInstance.stackModalA!.isOpen, isTrue);
    expect(fixture.assertOnlyInstance.stackModalB!.isOpen, isTrue);

    _dispatchEscapeKeydown();
    await _settle(fixture);

    expect(fixture.assertOnlyInstance.stackModalA!.isOpen, isTrue);
    expect(fixture.assertOnlyInstance.stackModalB!.isOpen, isFalse);
  });

  test('closeOnEscape false keeps the modal open after Escape', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.startOpenModal?.close();
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-no-escape');
    });
    await _settle(fixture);

    expect(fixture.assertOnlyInstance.noEscapeModal!.isOpen, isTrue);

    _dispatchEscapeKeydown();
    await _settle(fixture);

    expect(fixture.assertOnlyInstance.noEscapeModal!.isOpen, isTrue);
  });

  test('stacked modals receive increasing z-index values', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.startOpenModal?.close();
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-stack-a');
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-stack-b');
    });
    await _settle(fixture);

    final stackADialog = _modalDialogByTitle('Stack A');
    final stackBDialog = _modalDialogByTitle('Stack B');
    expect(stackADialog, isNotNull);
    expect(stackBDialog, isNotNull);

    final stackARoot = _closestAncestorWithClass(stackADialog!, 'modal');
    final stackBRoot = _closestAncestorWithClass(stackBDialog!, 'modal');
    expect(stackARoot, isNotNull);
    expect(stackBRoot, isNotNull);

    expect(int.parse(stackARoot!.style.zIndex),
        lessThan(int.parse(stackBRoot!.style.zIndex)));

    final backdrops =
        html.document.body!.querySelectorAll('.li-modal-backdrop');
    expect(backdrops.length, 2);
    expect(int.parse(backdrops[0].style.zIndex),
        lessThan(int.parse(backdrops[1].style.zIndex)));
  });

  test('modal-full keeps the modal body vertically scrollable', () async {
    final fixture = await fullModalTestBed.create();
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-full');
    });
    await _settle(fixture);

    final content = html.document.body!.querySelector('#full-body-content');
    expect(content, isNotNull);

    final fullBodyContent = content!;
    final modalBody = _closestAncestorWithClass(fullBodyContent, 'modal-body');
    expect(modalBody, isNotNull);

    final resolvedModalBody = modalBody!;

    final style = resolvedModalBody.getComputedStyle();
    expect(style.overflowY, 'auto');

    await fixture.update((host) {
      host.fullModal?.close();
    });
    await _settle(fixture);
  });

  test('modal-full keeps rounded chrome by default', () async {
    final fixture = await fullModalTestBed.create();
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-full');
    });
    await _settle(fixture);

    final fullDialog = _modalDialogByTitle('Full');
    expect(fullDialog, isNotNull);

    final fullContent = fullDialog!.querySelector('.modal-content');
    final fullHeader = fullDialog.querySelector('.modal-header');
    expect(fullContent, isNotNull);
    expect(fullHeader, isNotNull);

    expect(fullContent!.getComputedStyle().borderTopLeftRadius, isNot('0px'));
    expect(fullHeader!.getComputedStyle().borderTopLeftRadius, isNot('0px'));

    await fixture.update((host) {
      host.fullModal?.close();
    });
    await _settle(fixture);
  });

  test('fullScreenShell removes rounded corners from the fullscreen shell',
      () async {
    final fixture = await fullModalTestBed.create();
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-full-shell');
    });
    await _settle(fixture);

    final fullDialog = _modalDialogByTitle('Full shell');
    expect(fullDialog, isNotNull);

    final fullContent = fullDialog!.querySelector('.modal-content');
    final fullHeader = fullDialog.querySelector('.modal-header');
    expect(fullContent, isNotNull);
    expect(fullHeader, isNotNull);

    expect(fullContent!.getComputedStyle().borderTopLeftRadius, '0px');
    expect(fullHeader!.getComputedStyle().borderTopLeftRadius, '0px');

    await fixture.update((host) {
      host.fullShellModal?.close();
    });
    await _settle(fixture);
  });
}

void _clickById(String id) {
  final element = html.document.body!.querySelector('#$id');
  expect(element, isNotNull);
  element!.dispatchEvent(html.MouseEvent('click', canBubble: true));
}

void _dispatchEscapeKeydown() {
  final keyboardEventConstructor =
      js_util.getProperty(html.window, 'KeyboardEvent');
  final event = js_util.callConstructor(
    keyboardEventConstructor,
    <Object?>[
      'keydown',
      js_util.jsify(<String, Object?>{
        'key': 'Escape',
        'bubbles': true,
        'cancelable': true,
      }),
    ],
  );
  js_util.callMethod(html.document, 'dispatchEvent', <Object?>[event]);
}

Future<void> _settle<T>(NgTestFixture<T> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

html.Element? _closestAncestorWithClass(
    html.Element element, String className) {
  html.Element? current = element;
  while (current != null) {
    if (current.classes.contains(className)) {
      return current;
    }
    current = current.parent;
  }
  return null;
}

html.Element? _modalHeaderByTitle(String title) {
  for (final header in html.document.body!.querySelectorAll('.modal-header')) {
    final titleElement = header.querySelector('.modal-title');
    if (titleElement?.text?.trim() == title) {
      return header;
    }
  }
  return null;
}

html.Element? _modalDialogByTitle(String title) {
  for (final dialog in html.document.body!.querySelectorAll('.modal-dialog')) {
    final titleElement = dialog.querySelector('.modal-title');
    if (titleElement?.text?.trim() == title) {
      return dialog;
    }
  }
  return null;
}
