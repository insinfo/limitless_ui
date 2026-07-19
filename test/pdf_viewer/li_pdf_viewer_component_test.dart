// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/pdf_viewer/li_pdf_viewer_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'package:limitless_ui/web_compat.dart' as html;
import 'dart:typed_data';

import 'package:limitless_ui/pdf_viewer.dart';
import 'package:limitless_ui/src/components/pdf_viewer/pdf_viewer_browser_bridge.dart';
import 'package:limitless_ui/src/components/pdf_viewer/pdf_viewer_pdfjs_bridge.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_pdf_viewer_component_test.template.dart' as ng;
import 'pdf_viewer_browser_test_fakes.dart';
import 'pdfjs_test_fakes.dart';

@Component(
  selector: 'pdf-viewer-test-host',
  template: '''
    <div style="height: 640px; width: 960px;">
      <li-pdf-viewer
          #viewer
          title="Viewer de teste"
          [bytes]="bytes"
          [showTitle]="false"
          [customToolbarActions]="toolbarActions"
          [sidePanelTitle]="'Assinaturas'"
          [sidePanelOpen]="sidePanelOpen"
          [sidePanelModalOnMobile]="false"
          [enableDownloadAction]="enableDownloadAction"
          [enablePrintAction]="enablePrintAction"
          [enableRotateAction]="false"
          [enableFitWidthAction]="false"
          [enablePanModeAction]="false"
          [enableFullscreenAction]="false"
          [enableGoToPageAction]="false"
          (documentLoaded)="onDocumentLoaded(\$event)"
          (loadError)="onLoadError(\$event)">
        <template liPdfViewerToolbarActions let-ctx>
          <button id="projected-toolbar-action" type="button" class="btn btn-light btn-sm">
            Validacao rapida
          </button>
        </template>

        <template liPdfViewerSidePanel let-ctx>
          <div id="projected-side-panel">
            <span class="projected-side-panel-title">Painel fake</span>
          </div>
        </template>
      </li-pdf-viewer>
    </div>
  ''',
  directives: [coreDirectives, liPdfViewerDirectives],
)
class PdfViewerTestHostComponent {
  @ViewChild('viewer')
  LiPdfViewerComponent? viewer;

  Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3, 4]);
  bool sidePanelOpen = false;
  bool enableDownloadAction = false;
  bool enablePrintAction = false;
  final List<int> documentLoadedEvents = <int>[];
  final List<String> loadErrors = <String>[];

  late final List<LiPdfViewerToolbarAction> toolbarActions =
      <LiPdfViewerToolbarAction>[
    LiPdfViewerToolbarAction(
      id: 'signatures',
      iconClass: 'ph ph-signature',
      label: 'Abrir painel',
      title: 'Abrir painel',
      onPressed: (event) => event.viewer.toggleSidePanel(),
    ),
  ];

  void onDocumentLoaded(int totalPages) {
    documentLoadedEvents.add(totalPages);
  }

  void onLoadError(String message) {
    loadErrors.add(message);
  }
}

void main() {
  tearDown(() {
    setLiPdfViewerBrowserBridgeForTesting(null);
    setLiPdfViewerPdfJsBridgeForTesting(null);
    return disposeAnyRunningTest();
  });

  final testBed = NgTestBed<PdfViewerTestHostComponent>(
    ng.PdfViewerTestHostComponentNgFactory,
  );

  test('renders projected toolbar actions template on desktop toolbar',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final action =
        fixture.rootElement.querySelector('#projected-toolbar-action');
    expect(action, isNotNull);
    expect(action!.text, contains('Validacao rapida'));
  });

  test('loads a document through the PDF.js bridge and emits documentLoaded',
      () async {
    final fakeBridge = FakePdfJsBridge(
      documentFactory: (_) => createFakePdfDocument(numPages: 2),
    );
    setLiPdfViewerPdfJsBridgeForTesting(fakeBridge);

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.viewer, isNotNull);
    expect(host.viewer!.pdfDocument, isNotNull);
    expect(host.viewer!.totalPages, 2);
    expect(host.documentLoadedEvents, <int>[2]);
    expect(host.loadErrors, isEmpty);
    expect(
      fakeBridge.configuredWorkerSrc,
      'assets/js/pdf.js/5.4.149/build/pdf.worker.mjs',
    );
    expect(fakeBridge.documentRequests, hasLength(1));
    expect(fakeBridge.documentRequests.single['data'], isA<Uint8List>());
    expect(
      fakeBridge.documentRequests.single['standardFontDataUrl'],
      'assets/js/pdf.js/5.4.149/web/standard_fonts/',
    );
    expect(
      fakeBridge.documentRequests.single['cMapUrl'],
      'assets/js/pdf.js/5.4.149/web/cmaps/',
    );
    expect(fakeBridge.documentRequests.single['cMapPacked'], isTrue);

    final pages = fixture.rootElement.queryAll('.page');
    expect(pages, hasLength(2));
  });

  test('extracts page text, document text and page info from the PDF API',
      () async {
    setLiPdfViewerPdfJsBridgeForTesting(
      FakePdfJsBridge(
        documentFactory: (_) => createFakePdfDocument(
          numPages: 2,
          pageWidth: 600,
          pageHeight: 800,
          textItems: <dynamic>[
            createFakeTextItem(text: 'Release briefing', hasEndOfLine: true),
            createFakeTextItem(text: 'Checklist concluido.'),
          ],
        ),
      ),
    );

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final pageText = await host.viewer!.extractPageText(1);
    final documentText = await host.viewer!.extractDocumentText(
      pageSeparator: '\n---\n',
    );
    final pageInfo = await host.viewer!.getPageInfo(1);
    final allPagesInfo = await host.viewer!.getAllPageInfo();

    expect(pageText.pageNumber, 1);
    expect(pageText.language, 'pt-BR');
    expect(pageText.items, hasLength(2));
    expect(pageText.text, 'Release briefing\nChecklist concluido.');
    expect(
      documentText,
      'Release briefing\nChecklist concluido.\n---\nRelease briefing\nChecklist concluido.',
    );
    expect(pageInfo.pageNumber, 1);
    expect(pageInfo.width, 600);
    expect(pageInfo.height, 800);
    expect(pageInfo.rotation, 0);
    expect(pageInfo.currentScale, greaterThan(0));
    expect(allPagesInfo, hasLength(2));
  });

  test('opens projected side panel content through custom toolbar action',
      () async {
    setLiPdfViewerPdfJsBridgeForTesting(
      FakePdfJsBridge(
        documentFactory: (_) => createFakePdfDocument(numPages: 1),
      ),
    );

    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement.querySelector('[title="Abrir painel"]')
        as html.ButtonElement?;
    expect(trigger, isNotNull);

    await fixture.update((_) {
      trigger!.dispatchEvent(html.liMouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final sidePanel =
        fixture.rootElement.querySelector('#projected-side-panel');
    expect(sidePanel, isNotNull);
    expect(sidePanel!.text, contains('Painel fake'));
  });

  test('downloadDocument uses getData and triggers a download anchor',
      () async {
    final state = FakePdfDocumentState();
    final browserBridge = FakePdfViewerBrowserBridge();
    setLiPdfViewerBrowserBridgeForTesting(browserBridge);

    setLiPdfViewerPdfJsBridgeForTesting(
      FakePdfJsBridge(
        documentFactory: (_) => createFakePdfDocument(
          numPages: 1,
          state: state,
          data: Uint8List.fromList(<int>[1, 2, 3, 4, 5]),
        ),
      ),
    );

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((host) {
      host.enableDownloadAction = true;
    });
    await _settle(fixture);

    await host.viewer!.downloadDocument();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await _settle(fixture);

    expect(state.getDataCalls, 1);
    expect(browserBridge.createdUrls, hasLength(1));
    expect(browserBridge.clickedDownloads, <String>['document.pdf']);
    expect(
        browserBridge.revokedUrls, contains(browserBridge.createdUrls.single));
    expect(host.loadErrors, isEmpty);
  });

  test(
      'printDocument uses getData, prints the iframe and cleans up after afterprint',
      () async {
    final state = FakePdfDocumentState();
    final browserBridge = FakePdfViewerBrowserBridge();
    setLiPdfViewerBrowserBridgeForTesting(browserBridge);

    setLiPdfViewerPdfJsBridgeForTesting(
      FakePdfJsBridge(
        documentFactory: (_) => createFakePdfDocument(
          numPages: 1,
          state: state,
        ),
      ),
    );

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((host) {
      host.enablePrintAction = true;
    });
    await _settle(fixture);

    final printFuture = host.viewer!.printDocument();
    final printFrame =
        await _waitForElement('#liPdfViewerPrintFrame') as html.IFrameElement;

    printFrame.dispatchEvent(html.liEvent('load'));
    await printFuture;
    await _settle(fixture);

    expect(state.getDataCalls, 1);
    expect(browserBridge.createdUrls, hasLength(1));
    expect(browserBridge.printCalls, 1);
    expect(
        html.document.body!.querySelector('#liPdfViewerPrintFrame'), isNotNull);

    html.window.dispatchEvent(html.liEvent('afterprint'));
    await _settle(fixture);

    expect(html.document.body!.querySelector('#liPdfViewerPrintFrame'), isNull);
    expect(
        browserBridge.revokedUrls, contains(browserBridge.createdUrls.single));
    expect(host.loadErrors, isEmpty);
  });

  test('internal link annotations resolve destinations and page indexes',
      () async {
    final state = FakePdfDocumentState();
    final pageRef = <String, Object>{'num': 7, 'gen': 0};

    setLiPdfViewerPdfJsBridgeForTesting(
      FakePdfJsBridge(
        documentFactory: (_) => createFakePdfDocument(
          numPages: 2,
          state: state,
          annotations: <dynamic>[
            createFakeLinkAnnotation(dest: 'release-section'),
          ],
          destinations: <String, dynamic>{
            'release-section': <dynamic>[pageRef],
          },
          pageIndexResolver: (_) => 1,
        ),
      ),
    );

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final link =
        await _waitForElement('.annotationLayer a') as html.AnchorElement;
    expect(link.getAttribute('href'), '#');

    link.dispatchEvent(html.liMouseEvent('click', canBubble: true));
    await _settle(fixture);

    expect(state.getDestinationsCalls, 1);
    expect(state.getPageIndexCalls, 1);
    expect(state.pageIndexRefs, hasLength(1));
    expect(host.viewer!.currentPage, 2);
  });

  test('surfaces bridge failures through loadError and error overlay',
      () async {
    setLiPdfViewerPdfJsBridgeForTesting(
      FakePdfJsBridge(
        documentFactory: (_) => createFakePdfDocument(numPages: 1),
        loadError: StateError('Falha fake ao carregar PDF'),
      ),
    );

    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.documentLoadedEvents, isEmpty);
    expect(host.loadErrors, hasLength(1));
    expect(host.loadErrors.single, contains('Falha fake ao carregar PDF'));
    expect(host.viewer, isNotNull);
    expect(host.viewer!.pdfDocument, isNull);
    expect(host.viewer!.errorMessage, contains('Falha fake ao carregar PDF'));

    final errorOverlay = fixture.rootElement.querySelector(
      '.li-pdf-viewer__overlay--error',
    );
    expect(errorOverlay, isNotNull);
    expect(errorOverlay!.text, contains('Unable to load PDF:'));
    expect(errorOverlay.text, contains('Falha fake ao carregar PDF'));
  });
}

Future<void> _settle(
  NgTestFixture<PdfViewerTestHostComponent> fixture,
) async {
  await fixture.update((_) {});
  await _nextAnimationFrame();
  await _nextAnimationFrame();
  await fixture.update((_) {});
}

Future<void> _nextAnimationFrame() {
  final completer = Completer<void>();
  html.window.liRequestAnimationFrame((_) {
    completer.complete();
  });
  return completer.future;
}

Future<html.Element> _waitForElement(String selector,
    {int maxFrames = 20}) async {
  for (var attempt = 0; attempt < maxFrames; attempt++) {
    final element = html.document.body?.querySelector(selector);
    if (element != null) {
      return element;
    }
    await _nextAnimationFrame();
  }
  throw StateError('Elemento não encontrado: $selector');
}
