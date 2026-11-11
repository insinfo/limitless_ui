// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/pdf_viewer/li_pdf_viewer_fullscreen_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

import 'package:limitless_ui/limitless_ui.dart';
import 'package:limitless_ui/pdf_viewer.dart';
import 'package:limitless_ui/src/components/pdf_viewer/pdf_viewer_browser_bridge.dart';
import 'package:limitless_ui/src/components/pdf_viewer/pdf_viewer_pdfjs_bridge.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_pdf_viewer_fullscreen_test.template.dart' as ng;
import 'pdf_viewer_browser_test_fakes.dart';
import 'pdfjs_test_fakes.dart';

/// A viewer inside a `li-modal` as applications use it: `xxx-large`, without
/// the modal body padding.
@Component(
  selector: 'pdf-viewer-modal-test-host',
  template: '''
    <li-modal
        #modal
        size="xxx-large"
        [enableModalBodyClass]="false"
        title="Documento">
      <div id="modal-viewer-slot" style="height: 480px;">
        <li-pdf-viewer
            *ngIf="showViewer"
            #viewer
            title="Ed nº 2036 de 9 de novembro"
            [showTitle]="showTitle"
            [bytes]="bytes"
            (loadError)="loadErrors.add(\$event)"
            (actionError)="actionErrors.add(\$event)">
        </li-pdf-viewer>
      </div>
    </li-modal>
  ''',
  directives: [coreDirectives, LiModalComponent, liPdfViewerDirectives],
)
class PdfViewerModalTestHostComponent {
  @ViewChild('viewer')
  LiPdfViewerComponent? viewer;

  @ViewChild('modal')
  LiModalComponent? modal;

  bool showViewer = true;
  bool showTitle = true;
  Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3, 4]);
  final List<String> loadErrors = <String>[];
  final List<String> actionErrors = <String>[];
}

/// The Limitless variables the viewer colours come from, as the theme
/// defines them: on `:root`, except `--card-bg` (only inside `.card`) and
/// `--modal-bg` (only inside `.modal`). The test page has no theme otherwise.
const String _themeVariables = '''
:root {
  --white: #fff;
  --dark: #252b36;
  --body-bg: #f1f4f9;
  --border-color: #d1d5db;
}
.card { --card-bg: var(--white); }
''';

void main() {
  late FakePdfViewerBrowserBridge browserBridge;
  html.StyleElement? theme;

  setUp(() {
    theme = html.StyleElement()..text = _themeVariables;
    html.document.head!.append(theme!);
    browserBridge = FakePdfViewerBrowserBridge();
    setLiPdfViewerBrowserBridgeForTesting(browserBridge);
    setLiPdfViewerPdfJsBridgeForTesting(FakePdfJsBridge(
      documentFactory: (_) => createFakePdfDocument(
        numPages: 3,
        data: Uint8List.fromList(<int>[1, 2, 3, 4, 5]),
      ),
    ));
  });

  tearDown(() {
    theme?.remove();
    setLiPdfViewerBrowserBridgeForTesting(null);
    setLiPdfViewerPdfJsBridgeForTesting(null);
    return disposeAnyRunningTest();
  });

  final testBed = NgTestBed<PdfViewerModalTestHostComponent>(
    ng.PdfViewerModalTestHostComponentNgFactory,
  );

  Future<NgTestFixture<PdfViewerModalTestHostComponent>> openModal() async {
    final fixture = await testBed.create();
    await fixture.update((host) => host.modal!.open());
    await _settle(fixture);
    return fixture;
  }

  group('full screen inside a li-modal', () {
    test('without the Fullscreen API, the CSS mode covers the modal',
        () async {
      browserBridge.fullscreenAllowed = false;
      final fixture = await openModal();
      final viewer = fixture.assertOnlyInstance.viewer!;
      final hostEl = _viewerHost();
      final slot = html.document.querySelector('#modal-viewer-slot')!;
      final before = _counts();

      await viewer.toggleFullscreen();
      await _settle(fixture);

      expect(browserBridge.fullscreenRequests, isEmpty,
          reason: 'fullscreenEnabled false: the API is not even called');
      expect(viewer.isFullscreenActive, isTrue);
      expect(hostEl.parent, html.document.body);
      expect(hostEl.classes, contains('pdf-viewer-viewport-fullscreen'));

      final hostZ = int.parse(hostEl.getComputedStyle().zIndex);
      final modalZ = int.parse(
          html.document.querySelector('.modal')!.getComputedStyle().zIndex);
      expect(hostZ, LiOverlayLayers.fullscreenFallback);
      expect(hostZ, greaterThan(modalZ));

      final center = html.document.elementFromPoint(
          html.window.innerWidth! ~/ 2, html.window.innerHeight! ~/ 2);
      expect(center != null && hostEl.contains(center), isTrue,
          reason: 'the viewer is what the user sees and clicks, not the '
              'modal or its backdrop');
      expect(_counts(), before, reason: 'no repeated toolbar or pages');
      expect(_isTransparent(_toolbar().getComputedStyle().backgroundColor),
          isFalse);

      await viewer.toggleFullscreen();
      await _settle(fixture);

      expect(viewer.isFullscreenActive, isFalse);
      expect(hostEl.parent, slot, reason: 'back in its place in the modal');
      expect(hostEl.style.zIndex, isEmpty);
      expect(_counts(), before);
      expect(fixture.assertOnlyInstance.loadErrors, isEmpty);
    });

    test('a refused request falls back to the CSS mode', () async {
      browserBridge.refuseFullscreen = true;
      final fixture = await openModal();
      final viewer = fixture.assertOnlyInstance.viewer!;
      final before = _counts();

      await viewer.toggleFullscreen();
      await _settle(fixture);

      expect(browserBridge.fullscreenRequests, hasLength(1));
      expect(viewer.isFullscreenActive, isTrue);
      expect(_viewerHost().parent, html.document.body);

      await viewer.toggleFullscreen();
      await _settle(fixture);
      await viewer.toggleFullscreen();
      await _settle(fixture);
      await viewer.toggleFullscreen();
      await _settle(fixture);

      expect(viewer.isFullscreenActive, isFalse);
      expect(_counts(), before,
          reason: 'entering and leaving twice keeps one toolbar and the pages');
    });

    test('Escape leaves the CSS mode and keeps the modal open', () async {
      browserBridge.fullscreenAllowed = false;
      final fixture = await openModal();
      final viewer = fixture.assertOnlyInstance.viewer!;
      await viewer.toggleFullscreen();
      await _settle(fixture);

      html.document.body!.dispatchEvent(_escape());
      await _settle(fixture);

      expect(viewer.isFullscreenActive, isFalse);
      expect(_viewerHost().parent?.id, 'modal-viewer-slot');
      expect(fixture.assertOnlyInstance.modal!.isOpen, isTrue);
    });

    test('a viewer destroyed while in the CSS mode leaves no copy behind',
        () async {
      browserBridge.fullscreenAllowed = false;
      final fixture = await openModal();
      await fixture.assertOnlyInstance.viewer!.toggleFullscreen();
      await _settle(fixture);

      await fixture.update((host) => host.showViewer = false);
      await _settle(fixture);

      expect(html.document.querySelectorAll('li-pdf-viewer'), isEmpty);
      expect(html.document.body!.style.overflow, isNot('hidden'));
    });
  });

  group('toolbar', () {
    test('has its own background inside a modal, not the card\'s', () async {
      final fixture = await openModal();
      expect(_isTransparent(_toolbar().getComputedStyle().backgroundColor),
          isFalse);
      expect(fixture.assertOnlyInstance.viewer, isNotNull);
    });

    test('showTitle false drops the title from the toolbar', () async {
      final fixture = await openModal();
      expect(_toolbar().querySelector('.li-pdf-viewer__title')?.text?.trim(),
          'Ed nº 2036 de 9 de novembro');

      await fixture.update((host) => host.showTitle = false);
      await _settle(fixture);
      expect(_toolbar().querySelector('.li-pdf-viewer__title'), isNull);
    });
  });

  group('go to page', () {
    test('typing a page, then Enter, goes there without errors', () async {
      final fixture = await openModal();
      final viewer = fixture.assertOnlyInstance.viewer!;

      viewer.openGoToPageModal();
      await _settle(fixture);
      final input =
          await _waitForElement('#pdfGoToPageInput') as html.InputElement;

      final header = input
          .closest('.modal-content')!
          .querySelector('.modal-header')!;
      expect(header.classes, contains('modal-header-compact'));

      input.value = '2';
      input.dispatchEvent(html.Event('input'));
      await _settle(fixture);
      expect(viewer.goToPageValue, 2,
          reason: 'the number accessor delivers a num into a num? field');
      expect(_confirmButton().disabled, isFalse);

      input.dispatchEvent(_key('keydown', 'Enter'));
      await _settle(fixture);
      expect(viewer.currentPage, 2);
      expect(fixture.assertOnlyInstance.loadErrors, isEmpty);
    });

    test('empty, out of range or fractional pages disable OK', () async {
      final fixture = await openModal();
      final viewer = fixture.assertOnlyInstance.viewer!;
      viewer.openGoToPageModal();
      await _settle(fixture);
      final input =
          await _waitForElement('#pdfGoToPageInput') as html.InputElement;

      for (final value in <String>['', '0', '4', '1.5']) {
        input.value = value;
        input.dispatchEvent(html.Event('input'));
        await _settle(fixture);
        expect(viewer.goToPageInvalid, isTrue, reason: '"$value"');
        expect(_confirmButton().disabled, isTrue, reason: '"$value"');
        expect(input.classes, contains('is-invalid'), reason: '"$value"');
      }

      input.value = '3';
      input.dispatchEvent(html.Event('input'));
      await _settle(fixture);
      _confirmButton().click();
      await _settle(fixture);
      expect(viewer.currentPage, 3);
    });
  });

  group('print', () {
    test('hands the JS window of the iframe, with print, to the bridge',
        () async {
      final fixture = await openModal();
      final viewer = fixture.assertOnlyInstance.viewer!;

      final printing = viewer.printDocument();
      final frame =
          await _waitForElement('#liPdfViewerPrintFrame') as html.IFrameElement;
      frame.dispatchEvent(html.Event('load'));
      await printing;
      await _settle(fixture);

      expect(browserBridge.printCalls, 1);
      final target = browserBridge.lastPrintTarget;
      expect(target, isNotNull);
      expect(js_util.hasProperty(target!, 'print'), isTrue);
      expect(
          js_util.typeofEquals<Object?>(
              js_util.getProperty<Object?>(target, 'print'), 'function'),
          isTrue);
      expect(viewer.actionNotice, isNull);
      expect(fixture.assertOnlyInstance.actionErrors, isEmpty);
    });

    test('a failure shows a notice and keeps the document', () async {
      browserBridge.failPrint = true;
      final fixture = await openModal();
      final viewer = fixture.assertOnlyInstance.viewer!;
      final before = _counts();

      final printing = viewer.printDocument();
      final frame =
          await _waitForElement('#liPdfViewerPrintFrame') as html.IFrameElement;
      frame.dispatchEvent(html.Event('load'));
      await printing;
      await _settle(fixture);

      final root = _viewerHost();
      expect(root.querySelector('.li-pdf-viewer__notice'), isNotNull);
      expect(root.querySelector('.li-pdf-viewer__overlay--error'), isNull);
      expect(viewer.errorMessage, isNull);
      expect(_counts(), before, reason: 'the pages are still there');
      expect(fixture.assertOnlyInstance.loadErrors, isEmpty);
      expect(fixture.assertOnlyInstance.actionErrors.single,
          contains('print refused'));
      expect(html.document.querySelector('#liPdfViewerPrintFrame'), isNull,
          reason: 'the iframe goes away on failure');
      expect(browserBridge.revokedUrls,
          contains(browserBridge.createdUrls.single));

      root.querySelector('.li-pdf-viewer__notice .btn-close')!.click();
      await _settle(fixture);
      expect(root.querySelector('.li-pdf-viewer__notice'), isNull);
    });
  });
}

html.Element _viewerHost() => html.document.querySelector('li-pdf-viewer')!;

html.Element _toolbar() => html.document.querySelector('#toolbarContainer')!;

html.ButtonElement _confirmButton() =>
    html.document.querySelector('.li-pdf-viewer__go-to-page-confirm')
        as html.ButtonElement;

/// Toolbars, viewers and pages in the whole document.
List<int> _counts() => <int>[
      html.document.querySelectorAll('#toolbarContainer').length,
      html.document.querySelectorAll('li-pdf-viewer').length,
      html.document.querySelectorAll('.page').length,
    ];

bool _isTransparent(String color) {
  final normalized = color.replaceAll(' ', '');
  return normalized == 'transparent' || normalized == 'rgba(0,0,0,0)';
}

html.KeyboardEvent _escape() => _key('keydown', 'Escape');

/// A bubbling keyboard event; the Dart constructor cannot set `key`.
html.KeyboardEvent _key(String type, String key) {
  return js_util.callConstructor(
    js_util.getProperty(html.window, 'KeyboardEvent'),
    <Object>[
      type,
      js_util.jsify(<String, Object>{
        'key': key,
        'bubbles': true,
        'cancelable': true,
      }),
    ],
  ) as html.KeyboardEvent;
}

Future<void> _nextAnimationFrame() {
  final completer = Completer<void>();
  html.window.requestAnimationFrame((_) => completer.complete());
  return completer.future;
}

Future<html.Element> _waitForElement(String selector,
    {int maxFrames = 30}) async {
  for (var attempt = 0; attempt < maxFrames; attempt++) {
    final element = html.document.querySelector(selector);
    if (element != null) {
      return element;
    }
    await _nextAnimationFrame();
  }
  throw StateError('Elemento não encontrado: $selector');
}

Future<void> _settle(
  NgTestFixture<PdfViewerModalTestHostComponent> fixture,
) async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await fixture.update((_) {});
  }
}
