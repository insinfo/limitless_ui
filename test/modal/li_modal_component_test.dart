// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/modal/li_modal_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

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

      <li-modal #startOpenModal title-text="Start open" [start-open]="true">
        <div id="start-open-body">Start open body</div>
      </li-modal>
    </div>
  ''',
  directives: [coreDirectives, LiModalComponent],
)
class TestHostComponent {
  @ViewChild('lazyModal')
  LiModalComponent? lazyModal;

  int lazyCloseCount = 0;
}

@Component(
  selector: 'full-modal-test-host',
  template: '''
    <div>
      <button id="open-full" type="button" (click)="fullModal?.open()">Open full</button>

      <li-modal #fullModal title-text="Full" size="modal-full">
        <div id="full-body-content" style="height: 2000px;">Tall body</div>
      </li-modal>
    </div>
  ''',
  directives: [coreDirectives, LiModalComponent],
)
class FullModalTestHostComponent {
  @ViewChild('fullModal')
  LiModalComponent? fullModal;
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
}

void _clickById(String id) {
  final element = html.document.body!.querySelector('#$id');
  expect(element, isNotNull);
  element!.dispatchEvent(html.MouseEvent('click', canBubble: true));
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
