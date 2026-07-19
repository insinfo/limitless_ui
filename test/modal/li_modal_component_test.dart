// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/modal/li_modal_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'package:web/web.dart' as web;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import '../support/web_event_factories.dart';
import '../support/web_node_list.dart';

import 'li_modal_component_test.template.dart' as ng;

class ModalTemplateContext {
  const ModalTemplateContext(this.message);

  final String message;
}

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
      <button id="open-template-content" type="button" (click)="templateContentModal?.open()">Open template content</button>
      <button id="open-flush-body" type="button" (click)="flushBodyModal?.open()">Open flush body</button>
      <button id="open-raw-body" type="button" (click)="rawBodyModal?.open()">Open raw body</button>
      <button id="open-no-escape" type="button" (click)="noEscapeModal?.open()">Open no escape</button>
      <button id="open-stack-a" type="button" (click)="stackModalA?.open()">Open stack A</button>
      <button id="open-stack-b" type="button" (click)="stackModalB?.open()">Open stack B</button>

      <template #templateContent let-data>
        <div id="template-content-body">{{ data.message }}</div>
      </template>

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

      <li-modal #templateContentModal
                title-text="Template content"
                [lazyContent]="true"
                [contentTemplate]="templateContent"
                [contentTemplateContext]="templateContentContext"
                contentHostClass="template-content-host">
        <div id="template-fallback-body">Fallback body</div>
      </li-modal>

      <li-modal #stackModalA title-text="Stack A">
        <div id="stack-a-body">Stack A body</div>
      </li-modal>

      <li-modal #flushBodyModal
                title-text="Flush body"
                [enableModalBodyClass]="false"
                [enableModalBodyLayout]="true"
                bodyClass="custom-flush-body">
        <div id="flush-body-content">Flush body</div>
      </li-modal>

      <li-modal #rawBodyModal
                title-text="Raw body"
                [enableModalBodyClass]="false"
                [enableModalBodyLayout]="false">
        <div id="raw-body-content">Raw body</div>
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

  @ViewChild('templateContentModal')
  LiModalComponent? templateContentModal;

  @ViewChild('flushBodyModal')
  LiModalComponent? flushBodyModal;

  @ViewChild('rawBodyModal')
  LiModalComponent? rawBodyModal;

  @ViewChild('noEscapeModal')
  LiModalComponent? noEscapeModal;

  @ViewChild('stackModalA')
  LiModalComponent? stackModalA;

  @ViewChild('stackModalB')
  LiModalComponent? stackModalB;

  int lazyCloseCount = 0;

  final ModalTemplateContext templateContentContext =
      const ModalTemplateContext('Template body from input');
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

    expect(web.document.body!.querySelector('#lazy-body'), isNull);
    expect(web.document.body!.querySelector('#eager-body'), isNotNull);

    await fixture.update((_) {
      _clickById('open-lazy');
    });
    await _settle(fixture);

    expect(web.document.body!.querySelector('#lazy-body'), isNotNull);
    expect(host.lazyModal!.isOpen, isTrue);
    expect(web.document.body!.classList.contains('modal-open'), isTrue);
    final lazyDialog = _modalDialogByTitle('Lazy');
    expect(lazyDialog, isNotNull);
    final lazyModal = _closestAncestorWithClass(lazyDialog!, 'modal');
    expect(lazyModal, isNotNull);
    expect(lazyModal!.getAttribute('data-label'), 'li_mdl');
    expect(lazyModal.getAttribute('data-open'), 'true');
    expect(lazyModal.querySelector('[data-label="li_mdl_dialog"]'), isNotNull);
    expect(lazyModal.querySelector('[data-label="li_mdl_content"]'), isNotNull);
    expect(lazyModal.querySelector('[data-label="li_mdl_header"]'), isNotNull);
    expect(lazyModal.querySelector('[data-label="li_mdl_title"]'), isNotNull);
    expect(lazyModal.querySelector('[data-label="li_mdl_close"]'), isNotNull);
    expect(lazyModal.querySelector('[data-label="li_mdl_body"]'), isNotNull);
    expect(lazyModal.querySelector('[data-label="li_mdl_footer"]'), isNotNull);
    expect(
      web.document.body!.querySelector('[data-label="li_mdl_backdrop"]'),
      isNotNull,
    );

    await fixture.update((_) {
      _clickById('close-lazy');
    });
    await _settle(fixture);

    expect(web.document.body!.querySelector('#lazy-body'), isNull);
    expect(host.lazyModal!.isOpen, isFalse);
    expect(host.lazyCloseCount, 1);
    expect(web.document.body!.classList.contains('modal-open'), isFalse);
    expect(lazyModal.getAttribute('data-open'), 'false');
  });

  test('startOpen renders content immediately after init', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final startOpenBody = web.document.body!.querySelector('#start-open-body');
    expect(startOpenBody, isNotNull);

    final bootstrapBody = _closestAncestorWithClass(
      startOpenBody as web.Element,
      'modal-body',
    );
    expect(bootstrapBody, isNotNull);
    expect(bootstrapBody!.classList.contains('li-modal-body'), isFalse);

    final openModal = web.document.body!
        .querySelectorAll('[data-status="open"]')
        .toElementList()
        .where((element) => element.querySelector('#start-open-body') != null);

    expect(openModal, isNotEmpty);
    expect(openModal.first.getAttribute('data-label'), 'li_mdl');
    expect(openModal.first.getAttribute('data-open'), 'true');
    expect(web.document.body!.classList.contains('modal-open'), isTrue);
  });

  test('compactHeader only applies the compact class when enabled', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final eagerHeader = _modalHeaderByTitle('Eager');
    final compactHeader = _modalHeaderByTitle('Compact');

    expect(eagerHeader, isNotNull);
    expect(compactHeader, isNotNull);
    expect(eagerHeader!.classList.contains('modal-header-compact'), isFalse);
    expect(compactHeader!.classList.contains('modal-header-compact'), isTrue);
  });

  test('smallHeader only applies the small class when enabled', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final eagerHeader = _modalHeaderByTitle('Eager');
    final smallHeader = _modalHeaderByTitle('Small');

    expect(eagerHeader, isNotNull);
    expect(smallHeader, isNotNull);
    expect(eagerHeader!.classList.contains('modal-header-small'), isFalse);
    expect(smallHeader!.classList.contains('modal-header-small'), isTrue);
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

    expect(xxlDialog!.classList.contains('modal-xxl'), isTrue);
    expect(xxxlDialog!.classList.contains('modal-xxxl'), isTrue);
    expect(fluidDialog!.classList.contains('modal-fluid'), isTrue);

    final xxlHeader = _modalHeaderByTitle('XXL');
    final xxxlHeader = _modalHeaderByTitle('XXXL');
    expect(xxlHeader, isNotNull);
    expect(xxxlHeader, isNotNull);
    expect(xxlHeader!.classList.contains('bg-purple'), isTrue);
    expect(xxxlHeader!.classList.contains('bg-teal'), isTrue);
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

    final projectedTitle = web.document.body!.querySelector('#projected-title');
    final projectedBody = web.document.body!.querySelector('#projected-body');
    final projectedFooterAction =
        web.document.body!.querySelector('#projected-footer-action');

    expect(projectedTitle, isNotNull);
    expect(projectedBody, isNotNull);
    expect(projectedFooterAction, isNotNull);

    final projectedDialog = _closestAncestorWithClass(
      projectedBody as web.Element,
      'modal-dialog',
    );
    expect(projectedDialog, isNotNull);
    expect((projectedDialog as web.HTMLElement).style.maxWidth, '520px');
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

  test('renders contentTemplate inside the modal body when provided', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.startOpenModal?.close();
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-template-content');
    });
    await _settle(fixture);

    final templatedBody =
        web.document.body!.querySelector('#template-content-body');
    final fallbackBody =
        web.document.body!.querySelector('#template-fallback-body');

    expect(templatedBody, isNotNull);
    expect(templatedBody!.textContent, 'Template body from input');
    expect(fallbackBody, isNull);

    final hostWrapper =
        _closestAncestorWithClass(templatedBody, 'template-content-host');
    expect(hostWrapper, isNotNull);
  });

  test('body layout class keeps fullscreen layout without modal-body padding',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.startOpenModal?.close();
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-flush-body');
    });
    await _settle(fixture);

    final content = web.document.body!.querySelector('#flush-body-content');
    expect(content, isNotNull);

    final layoutBody = _closestAncestorWithClass(
      content as web.Element,
      'li-modal-body',
    );
    expect(layoutBody, isNotNull);
    expect(layoutBody!.classList.contains('modal-body'), isFalse);
    expect(layoutBody.classList.contains('custom-flush-body'), isTrue);

    final style = web.window.getComputedStyle(layoutBody);
    expect(style.paddingTop, '0px');
    expect(style.flexGrow, '1');
    expect(style.minHeight, '0px');
  });

  test('body layout class can be disabled for raw body wrappers', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.startOpenModal?.close();
    });
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-raw-body');
    });
    await _settle(fixture);

    final content = web.document.body!.querySelector('#raw-body-content');
    expect(content, isNotNull);

    final wrapper = (content as web.Element).parentElement;
    expect(wrapper, isNotNull);
    expect(wrapper!.classList.contains('li-modal-body'), isFalse);
    expect(wrapper.classList.contains('modal-body'), isFalse);
    expect(wrapper.classList.contains('position-relative'), isFalse);
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

    expect(int.parse((stackARoot as web.HTMLElement).style.zIndex),
        lessThan(int.parse((stackBRoot as web.HTMLElement).style.zIndex)));

    final backdrops = web.document.body!
        .querySelectorAll('.li-modal-backdrop')
        .toElementList();
    expect(backdrops.length, 2);
    expect(int.parse((backdrops[0] as web.HTMLElement).style.zIndex),
        lessThan(int.parse((backdrops[1] as web.HTMLElement).style.zIndex)));
  });

  test('modal-full keeps the modal body vertically scrollable', () async {
    final fixture = await fullModalTestBed.create();
    await _settle(fixture);

    await fixture.update((_) {
      _clickById('open-full');
    });
    await _settle(fixture);

    final content = web.document.body!.querySelector('#full-body-content');
    expect(content, isNotNull);

    final fullBodyContent = content!;
    final modalBody = _closestAncestorWithClass(fullBodyContent, 'modal-body');
    expect(modalBody, isNotNull);

    final resolvedModalBody = modalBody!;

    final style = web.window.getComputedStyle(resolvedModalBody);
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

    expect(web.window.getComputedStyle(fullContent!).borderTopLeftRadius,
        isNot('0px'));
    expect(web.window.getComputedStyle(fullHeader!).borderTopLeftRadius,
        isNot('0px'));

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

    expect(
        web.window.getComputedStyle(fullContent!).borderTopLeftRadius, '0px');
    expect(web.window.getComputedStyle(fullHeader!).borderTopLeftRadius, '0px');

    await fixture.update((host) {
      host.fullShellModal?.close();
    });
    await _settle(fixture);
  });
}

void _clickById(String id) {
  final element = web.document.body!.querySelector('#$id');
  expect(element, isNotNull);
  element!.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
}

void _dispatchEscapeKeydown() {
  final event = bubblingKeyboardEvent('keydown', key: 'Escape');
  web.document.dispatchEvent(event);
}

Future<void> _settle<T>(NgTestFixture<T> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

web.Element? _closestAncestorWithClass(web.Element element, String className) {
  web.Element? current = element;
  while (current != null) {
    if (current.classList.contains(className)) {
      return current;
    }
    current = current.parentElement;
  }
  return null;
}

web.Element? _modalHeaderByTitle(String title) {
  for (final header
      in web.document.body!.querySelectorAll('.modal-header').toElementList()) {
    final titleElement = header.querySelector('.modal-title');
    if ((titleElement?.textContent ?? '').trim() == title) {
      return header;
    }
  }
  return null;
}

web.Element? _modalDialogByTitle(String title) {
  for (final dialog
      in web.document.body!.querySelectorAll('.modal-dialog').toElementList()) {
    final titleElement = dialog.querySelector('.modal-title');
    if ((titleElement?.textContent ?? '').trim() == title) {
      return dialog;
    }
  }
  return null;
}
