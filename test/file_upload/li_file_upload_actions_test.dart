// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/file_upload/li_file_upload_actions_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_file_upload_actions_test.template.dart' as ng;

@Component(
  selector: 'li-file-upload-actions-test-host',
  template: '''
    <div id="host">
      <li-file-upload
          #upload
          [previewMode]="previewMode"
          [showCaption]="showCaption"
          [showBrowseButton]="showBrowseButton"
          [browseIcon]="browseIcon"
          [showClearButton]="showClearButton"
          [clearLabel]="clearLabel"
          [showDropzoneClearButton]="showDropzoneClearButton"
          [showPreviewButton]="showPreviewButton"
          [showRemoveButton]="showRemoveButton"
          [showFileSize]="showFileSize"
          [showFileName]="showFileName"
          [showUploadIndicator]="showUploadIndicator"
          [dropzoneClickOpensPicker]="dropzoneClickOpensPicker"
          [itemClickAction]="itemClickAction"
          [confirmAction]="confirmAction"
          (beforeAdd)="onBeforeAdd(\$event)"
          (beforeRemove)="onBeforeRemove(\$event)"
          (beforeClear)="onBeforeClear(\$event)"
          (added)="log.add(\$event)"
          (removed)="log.add(\$event)"
          (cleared)="log.add(\$event)"
          (previewOpened)="log.add(\$event)"
          (replaced)="log.add(\$event)">
      </li-file-upload>
    </div>
  ''',
  directives: [
    coreDirectives,
    LiFileUploadComponent,
  ],
)
class FileUploadActionsTestHostComponent {
  @ViewChild('upload')
  LiFileUploadComponent? upload;

  String previewMode = 'limitless';
  bool showCaption = true;
  bool showBrowseButton = true;
  String browseIcon = 'ph-file-plus';
  bool showClearButton = false;
  String clearLabel = '';
  bool showDropzoneClearButton = true;
  bool showPreviewButton = true;
  bool showRemoveButton = true;
  bool showFileSize = true;
  bool showFileName = true;
  bool showUploadIndicator = true;
  bool dropzoneClickOpensPicker = true;
  LiFileItemClickAction itemClickAction = LiFileItemClickAction.dropzone;
  LiFileUploadConfirmAction? confirmAction;

  /// Remove is refused for the first file while this is on.
  bool protectFirstFile = false;

  /// beforeAdd keeps only PDFs while this is on.
  bool onlyPdf = false;

  bool refuseClear = false;

  /// Every after-the-fact event, in order.
  final List<LiFileUploadActionEvent> log = <LiFileUploadActionEvent>[];

  void onBeforeAdd(LiFileUploadActionEvent event) {
    if (onlyPdf) {
      event.files.removeWhere((file) => file.type != 'application/pdf');
    }
  }

  void onBeforeRemove(LiFileUploadActionEvent event) {
    if (protectFirstFile && event.index == 0) {
      event.preventDefault();
    }
  }

  void onBeforeClear(LiFileUploadActionEvent event) {
    if (refuseClear) {
      event.preventDefault();
    }
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<FileUploadActionsTestHostComponent>(
    ng.FileUploadActionsTestHostComponentNgFactory,
  );

  group('defaults', () {
    test('render today\'s layout: no clear button in the bar, the rest on',
        () async {
      final fixture = await testBed.create();
      await _seed(fixture, <html.File>[_image('a.png')]);

      final root = _root(fixture);
      final bar = root.querySelector('.file-caption')!;
      expect(bar.querySelector('.file-caption-name'), isNotNull);
      expect(bar.querySelector('.btn-file input[type=file]'), isNotNull);
      expect(bar.querySelector('.btn-file i.ph-file-plus'), isNotNull);
      expect(bar.querySelector('.fileinput-remove-button'), isNull);
      expect(root.querySelector('.btn-close.fileinput-remove'), isNotNull);
      expect(root.querySelector('.file-upload-indicator'), isNotNull);
      expect(root.querySelector('.li-file-upload__footer-preview'), isNotNull);
      expect(root.querySelector('.li-file-upload__remove-button'), isNotNull);
      expect(root.querySelector('.file-footer-caption')?.text?.trim(), 'a.png');
      expect(root.querySelector('.file-size-info samp'), isNotNull);
      expect(root.querySelector('.li-file-upload__native-input'), isNull);
      expect(root.querySelector('.li-file-upload__dropzone')!.classes,
          contains('clickable'));
    });

    test('a click on a card bubbles to the dropzone and opens the picker',
        () async {
      final fixture = await testBed.create();
      await _seed(fixture, <html.File>[_text('a.txt')]);
      final clicks = _interceptPicker(fixture);

      _root(fixture).querySelector('.li-file-upload__thumb-fallback')!.click();
      await _settle(fixture);

      expect(clicks.length, 1);
      expect(fixture.assertOnlyInstance.upload!.nativeFileInput!.multiple,
          isTrue);
    });
  });

  group('display inputs', () {
    test('showBrowseButton false keeps a detached input for browse()',
        () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.showBrowseButton = false);
      await _settle(fixture);

      final root = _root(fixture);
      expect(root.querySelector('.btn-file'), isNull);
      expect(root.querySelector('.li-file-upload__native-input'), isNotNull);
      expect(root.querySelector('.file-caption')!.classes,
          contains('li-file-upload__caption--no-browse'));

      final clicks = _interceptPicker(fixture);
      final opened = await fixture.assertOnlyInstance.upload!.browse();
      expect(opened, isTrue);
      expect(clicks.length, 1);

      root.querySelector('.file-drop-zone-title')!.click();
      expect(clicks.length, 2, reason: 'the dropzone still opens the picker');
    });

    test('browseIcon changes or drops the icon of the browse button', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.browseIcon = 'ph-upload-simple');
      await _settle(fixture);
      expect(_root(fixture).querySelector('.btn-file i.ph-upload-simple'),
          isNotNull);

      await fixture.update((host) => host.browseIcon = '');
      await _settle(fixture);
      expect(_root(fixture).querySelector('.btn-file i'), isNull);
    });

    test('showClearButton and clearLabel render the bar clear button',
        () async {
      final fixture = await testBed.create();
      await fixture.update((host) {
        host.showClearButton = true;
        host.clearLabel = 'Remover todos';
      });
      await _settle(fixture);
      expect(_root(fixture).querySelector('.fileinput-remove-button'), isNull,
          reason: 'only while there are files');

      await _seed(fixture, <html.File>[_text('a.txt'), _text('b.txt')]);
      final button = _root(fixture).querySelector('.fileinput-remove-button')!;
      expect(button.classes, contains('li-file-upload__clear-button'));
      expect(button.text!.trim(), 'Remover todos');
      expect(
          _root(fixture)
              .querySelector('.btn-close.fileinput-remove')!
              .getAttribute('aria-label'),
          'Remover todos');

      button.click();
      await _settle(fixture);
      final upload = fixture.assertOnlyInstance.upload!;
      expect(upload.hasFiles, isFalse);
      expect(fixture.assertOnlyInstance.log.single.action,
          LiFileUploadAction.clear);
      expect(fixture.assertOnlyInstance.log.single.files.length, 2);
    });

    test('showDropzoneClearButton false drops the dropzone close button',
        () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.showDropzoneClearButton = false);
      await _seed(fixture, <html.File>[_text('a.txt')]);
      expect(_root(fixture).querySelector('.btn-close.fileinput-remove'),
          isNull);
    });

    test('card options drop each part of the card', () async {
      final fixture = await testBed.create();
      await _seed(fixture, <html.File>[_image('a.png')]);

      await fixture.update((host) => host.showPreviewButton = false);
      await _settle(fixture);
      expect(_root(fixture).querySelector('.li-file-upload__footer-preview'),
          isNull);

      await fixture.update((host) => host.showRemoveButton = false);
      await _settle(fixture);
      expect(_root(fixture).querySelector('.li-file-upload__remove-button'),
          isNull);

      await fixture.update((host) => host.showUploadIndicator = false);
      await _settle(fixture);
      expect(_root(fixture).querySelector('.file-upload-indicator'), isNull);
      expect(_root(fixture).querySelector('.file-footer-buttons'), isNull);

      await fixture.update((host) => host.showFileName = false);
      await _settle(fixture);
      expect(_root(fixture).querySelector('.file-footer-caption'), isNull);

      expect(_root(fixture).querySelector('.li-file-upload__footer-bar'),
          isNotNull,
          reason: 'the size is still there');
      await fixture.update((host) => host.showFileSize = false);
      await _settle(fixture);
      expect(_root(fixture).querySelector('.li-file-upload__footer-bar'),
          isNull);
      expect(_root(fixture).querySelector('.file-thumbnail-footer'), isNull,
          reason: 'an empty footer is not rendered');
    });

    test('the thumbnails mode follows the same card options', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.previewMode = 'thumbnails');
      await _seed(fixture, <html.File>[_image('a.png')]);
      expect(_root(fixture).querySelector('.li-file-upload__action--preview'),
          isNotNull);

      await fixture.update((host) => host.showPreviewButton = false);
      await _settle(fixture);
      expect(_root(fixture).querySelector('.li-file-upload__action--preview'),
          isNull);
    });

    test('the compact list follows name, size and remove options', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.previewMode = 'compact');
      await _seed(fixture, <html.File>[_text('a.txt')]);

      final root = _root(fixture);
      expect(root.querySelector('.li-file-upload__file-name')?.text, 'a.txt');
      expect(root.querySelector('.li-file-upload__file-size'), isNotNull);
      expect(root.querySelector('.li-file-upload__compact-remove'), isNotNull);

      await fixture.update((host) {
        host.showFileName = false;
        host.showFileSize = false;
        host.showRemoveButton = false;
      });
      await _settle(fixture);
      expect(root.querySelector('.li-file-upload__file-name'), isNull);
      expect(root.querySelector('.li-file-upload__file-size'), isNull);
      expect(root.querySelector('.li-file-upload__compact-remove'), isNull);
    });

    test('dropzoneClickOpensPicker false ignores clicks and keys', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.dropzoneClickOpensPicker = false);
      await _settle(fixture);
      final clicks = _interceptPicker(fixture);

      final dropzone = _root(fixture).querySelector('.li-file-upload__dropzone')!;
      expect(dropzone.classes, isNot(contains('clickable')));
      dropzone.querySelector('.file-drop-zone-title')!.click();
      dropzone.dispatchEvent(_enterKey());
      await _settle(fixture);
      expect(clicks, isEmpty);

      _root(fixture).querySelector('.btn-file')!.click();
      await _settle(fixture);
      expect(clicks.length, 1, reason: 'the browse button still works');
    });

    test('the bar disappears with caption, browse and clear all off',
        () async {
      final fixture = await testBed.create();
      await fixture.update((host) {
        host.showCaption = false;
        host.showBrowseButton = false;
        host.showClearButton = false;
      });
      await _seed(fixture, <html.File>[_text('a.txt')]);

      final root = _root(fixture);
      expect(root.querySelector('.file-caption'), isNull);
      expect(root.querySelector('.li-file-upload')!.classes,
          contains('li-file-upload--without-bar'));
      expect(root.querySelector('.li-file-upload__native-input'), isNotNull);

      await fixture.update((host) => host.showClearButton = true);
      await _settle(fixture);
      expect(root.querySelector('.file-caption'), isNotNull,
          reason: 'the clear button alone brings the bar back');
      expect(root.querySelector('.li-file-upload')!.classes,
          isNot(contains('li-file-upload--without-bar')));
    });
  });

  group('itemClickAction', () {
    test('replace swaps the clicked file in its position', () async {
      final fixture = await testBed.create();
      await fixture.update(
          (host) => host.itemClickAction = LiFileItemClickAction.replace);
      final first = _text('a.txt');
      final second = _text('b.txt');
      await _seed(fixture, <html.File>[first, second]);
      final clicks = _interceptPicker(fixture);

      final cards = _root(fixture).querySelectorAll('.kv-preview-thumb');
      cards[1].querySelector('.li-file-upload__thumb-fallback')!.click();
      await _settle(fixture);

      final upload = fixture.assertOnlyInstance.upload!;
      expect(clicks.length, 1, reason: 'one picker, not also the dropzone');
      expect(upload.nativeFileInput!.multiple, isFalse);

      final replacement = _text('c.txt');
      upload.onFileInputChange(<html.File>[replacement, _text('d.txt')]);
      await _settle(fixture);

      expect(fixture.assertOnlyInstance.upload!.previewItems
          .map((item) => item.file.name), <String>['a.txt', 'c.txt']);
      final event = fixture.assertOnlyInstance.log.single;
      expect(event.action, LiFileUploadAction.replace);
      expect(event.index, 1);
      expect(identical(event.file, replacement), isTrue);
      expect(identical(event.previousFile, second), isTrue);
    });

    test('preview opens the modal of the clicked file', () async {
      final fixture = await testBed.create();
      await fixture.update(
          (host) => host.itemClickAction = LiFileItemClickAction.preview);
      await _seed(fixture, <html.File>[_image('a.png')]);
      final clicks = _interceptPicker(fixture);

      _root(fixture).querySelector('.li-file-upload__thumb-image')!.click();
      await _settle(fixture);

      final upload = fixture.assertOnlyInstance.upload!;
      expect(upload.activePreviewItem?.file.name, 'a.png');
      expect(clicks, isEmpty);
      expect(fixture.assertOnlyInstance.log.single.action,
          LiFileUploadAction.preview);
      upload.closePreview();
    });

    test('none does nothing', () async {
      final fixture = await testBed.create();
      await fixture
          .update((host) => host.itemClickAction = LiFileItemClickAction.none);
      await _seed(fixture, <html.File>[_image('a.png')]);
      final clicks = _interceptPicker(fixture);

      _root(fixture).querySelector('.li-file-upload__thumb-image')!.click();
      await _settle(fixture);

      expect(clicks, isEmpty);
      expect(fixture.assertOnlyInstance.upload!.activePreviewItem, isNull);
    });
  });

  group('cancelable actions', () {
    test('beforeRemove with preventDefault keeps the file', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.protectFirstFile = true);
      await _seed(fixture, <html.File>[_text('a.txt'), _text('b.txt')]);

      _removeButtons(fixture)[0].click();
      await _settle(fixture);
      expect(_names(fixture), <String>['a.txt', 'b.txt']);
      expect(fixture.assertOnlyInstance.log, isEmpty);

      _removeButtons(fixture)[1].click();
      await _settle(fixture);
      expect(_names(fixture), <String>['a.txt']);
      expect(fixture.assertOnlyInstance.log.single.action,
          LiFileUploadAction.remove);
      expect(fixture.assertOnlyInstance.log.single.file!.name, 'b.txt');
    });

    test('confirmAction completing with false cancels the remove', () async {
      final fixture = await testBed.create();
      final asked = <LiFileUploadAction>[];
      await fixture.update((host) {
        host.confirmAction = (event) async {
          asked.add(event.action);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return false;
        };
      });
      await _seed(fixture, <html.File>[_text('a.txt')]);

      _removeButtons(fixture)[0].click();
      await _settle(fixture);
      expect(asked, <LiFileUploadAction>[LiFileUploadAction.remove]);
      expect(_names(fixture), <String>['a.txt']);
      expect(fixture.assertOnlyInstance.log, isEmpty);
    });

    test('confirmAction completing with true lets the remove run', () async {
      final fixture = await testBed.create();
      await fixture.update((host) {
        host.confirmAction = (event) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return true;
        };
      });
      await _seed(fixture, <html.File>[_text('a.txt'), _text('b.txt')]);

      _removeButtons(fixture)[0].click();
      expect(_names(fixture), <String>['a.txt', 'b.txt'],
          reason: 'nothing happens before the confirmation completes');
      await _settle(fixture);
      expect(_names(fixture), <String>['b.txt']);
      expect(fixture.assertOnlyInstance.log.single.action,
          LiFileUploadAction.remove);
    });

    test('beforeAdd can filter the files that enter', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.onlyPdf = true);
      await _settle(fixture);

      final pdf = _pdf('termo.pdf');
      await fixture.update((host) => host.upload!
          .onFilesSelected(<html.File>[_text('a.txt'), pdf, _image('b.png')]));
      await _settle(fixture);

      expect(_names(fixture), <String>['termo.pdf']);
      final event = fixture.assertOnlyInstance.log.single;
      expect(event.action, LiFileUploadAction.add);
      expect(event.files.length, 1);
      expect(identical(event.files.single, pdf), isTrue);
    });

    test('beforeClear with preventDefault keeps every file', () async {
      final fixture = await testBed.create();
      await fixture.update((host) => host.refuseClear = true);
      await _seed(fixture, <html.File>[_text('a.txt')]);

      _root(fixture).querySelector('.btn-close.fileinput-remove')!.click();
      await _settle(fixture);
      expect(_names(fixture), <String>['a.txt']);
      expect(fixture.assertOnlyInstance.log, isEmpty);
    });
  });
}

html.File _text(String name) =>
    html.File(<Object>['text'], name, <String, String>{'type': 'text/plain'});

html.File _image(String name) =>
    html.File(<Object>['png'], name, <String, String>{'type': 'image/png'});

html.File _pdf(String name) => html.File(
    <Object>['%PDF-1.4'], name, <String, String>{'type': 'application/pdf'});

/// A bubbling Enter keydown; the Dart constructor cannot set `key`.
html.KeyboardEvent _enterKey() {
  return js_util.callConstructor(
    js_util.getProperty(html.window, 'KeyboardEvent'),
    <Object>[
      'keydown',
      js_util.jsify(<String, Object>{'key': 'Enter', 'bubbles': true}),
    ],
  ) as html.KeyboardEvent;
}

/// The uploader element of the host.
html.Element _root(NgTestFixture<FileUploadActionsTestHostComponent> fixture) {
  return fixture.rootElement.querySelector('#host')!;
}

List<html.Element> _removeButtons(
  NgTestFixture<FileUploadActionsTestHostComponent> fixture,
) {
  return _root(fixture).querySelectorAll('.li-file-upload__remove-button');
}

List<String> _names(NgTestFixture<FileUploadActionsTestHostComponent> fixture) {
  return fixture.assertOnlyInstance.upload!.previewItems
      .map((item) => item.file.name)
      .toList();
}

/// Holds back the native file dialog and records each click that would have
/// opened it.
List<html.Event> _interceptPicker(
  NgTestFixture<FileUploadActionsTestHostComponent> fixture,
) {
  final clicks = <html.Event>[];
  fixture.assertOnlyInstance.upload!.nativeFileInput!.onClick.listen((event) {
    event.preventDefault();
    clicks.add(event);
  });
  return clicks;
}

/// Puts [files] in the uploader as the form would, without events.
Future<void> _seed(
  NgTestFixture<FileUploadActionsTestHostComponent> fixture,
  List<html.File> files,
) async {
  await _settle(fixture);
  await fixture.update((host) => host.upload!.writeValue(files));
  await _settle(fixture);
}

/// Lets the OnPush uploader render before reading the DOM.
Future<void> _settle(
  NgTestFixture<FileUploadActionsTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
