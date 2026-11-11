// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/file_upload/li_file_upload_caption_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_file_upload_caption_test.template.dart' as ng;

@Component(
  selector: 'li-file-upload-caption-test-host',
  template: '''
    <div id="with-caption">
      <li-file-upload previewMode="limitless" (filesChange)="defaultFiles = \$event">
      </li-file-upload>
    </div>

    <div id="without-caption">
      <li-file-upload
          #semLegenda
          previewMode="limitless"
          [showCaption]="false"
          (filesChange)="captionlessFiles = \$event">
      </li-file-upload>
    </div>
  ''',
  directives: [
    coreDirectives,
    LiFileUploadComponent,
  ],
)
class FileUploadCaptionTestHostComponent {
  @ViewChild('semLegenda')
  LiFileUploadComponent? captionless;

  List<html.File> defaultFiles = <html.File>[];
  List<html.File> captionlessFiles = <html.File>[];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<FileUploadCaptionTestHostComponent>(
    ng.FileUploadCaptionTestHostComponentNgFactory,
  );

  test('renders the caption field and its icon by default', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final bar = _bar(fixture, '#with-caption');
    expect(bar.querySelector('.file-caption-name'), isNotNull);
    expect(bar.querySelector('.file-caption-icon'), isNotNull);
    expect(bar.querySelector('.btn-file input[type=file]'), isNotNull);
    expect(
        bar.classes, isNot(contains('li-file-upload__caption--buttons-only')));
  });

  test('drops the caption field and its icon with showCaption false', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final bar = _bar(fixture, '#without-caption');
    expect(bar.querySelector('.file-caption-name'), isNull);
    expect(bar.querySelector('.file-caption-icon'), isNull);
    expect(bar.querySelector('.btn-file input[type=file]'), isNotNull);
    expect(bar.classes, contains('li-file-upload__caption--buttons-only'));
  });

  test('keeps the caption field away once files are selected', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.captionless!.writeValue(<html.File>[
        html.File(<Object>['%PDF-1.4'], 'termo.pdf',
            <String, String>{'type': 'application/pdf'}),
      ]);
    });
    await _settle(fixture);

    final upload = fixture.rootElement.querySelector('#without-caption')!;
    expect(upload.querySelector('.li-file-upload__card--limitless'), isNotNull,
        reason: 'the card shows the selected file');
    expect(upload.querySelector('.file-footer-caption')?.text?.trim(),
        'termo.pdf');

    final bar = _bar(fixture, '#without-caption');
    expect(bar.querySelector('.file-caption-name'), isNull);
    expect(bar.querySelector('.file-caption-icon'), isNull);
    expect(bar.querySelector('.fileinput-remove-button'), isNull,
        reason: 'the clear button follows showClearButton (off by default), '
            'not showCaption');
    expect(bar.querySelector('.btn-file input[type=file]'), isNotNull);
  });
}

/// The bottom bar (`.file-caption`) of the uploader inside [hostSelector].
html.Element _bar(
  NgTestFixture<FileUploadCaptionTestHostComponent> fixture,
  String hostSelector,
) {
  return fixture.rootElement.querySelector('$hostSelector .file-caption')!;
}

/// Lets the OnPush uploader render before reading the DOM.
Future<void> _settle(
  NgTestFixture<FileUploadCaptionTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
