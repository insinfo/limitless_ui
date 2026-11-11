// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/file_upload/li_file_upload_locale_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_file_upload_locale_test.template.dart' as ng;

@Component(
  selector: 'li-file-upload-locale-test-host',
  template: '''
    <div id="host">
      <li-file-upload
          #upload
          previewMode="limitless"
          [locale]="locale"
          [maxSize]="2"
          [showClearButton]="true"
          [browseLabel]="browseLabel">
      </li-file-upload>
    </div>
  ''',
  directives: [
    coreDirectives,
    LiFileUploadComponent,
  ],
)
class FileUploadLocaleTestHostComponent {
  @ViewChild('upload')
  LiFileUploadComponent? upload;

  String locale = 'pt_BR';
  String browseLabel = '';
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<FileUploadLocaleTestHostComponent>(
    ng.FileUploadLocaleTestHostComponentNgFactory,
  );

  test('switches every default text with the locale input, live', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final root = fixture.rootElement.querySelector('#host')!;

    String title() =>
        root.querySelector('.file-drop-zone-title span')!.text!.trim();
    String subtitle() =>
        root.querySelector('.li-file-upload__subtitle')!.text!.trim();
    String placeholder() =>
        (root.querySelector('.file-caption-name') as html.InputElement)
            .placeholder;
    String browse() => root.querySelector('.btn-file span')!.text!.trim();

    expect(title(), 'Arraste arquivos aqui');
    expect(subtitle(), 'Ou selecione arquivos do seu dispositivo');
    expect(placeholder(), 'Selecionar arquivos ...');
    expect(browse(), 'Selecionar arquivos');

    await fixture.update((host) => host.locale = 'en_US');
    await _settle(fixture);
    expect(title(), 'Drop files here');
    expect(subtitle(), 'Or choose files from your device');
    expect(placeholder(), 'Select files ...');
    expect(browse(), 'Browse files');

    await fixture.update((host) => host.upload!.writeValue(<html.File>[
          html.File(<Object>['png!'], 'big.png',
              <String, String>{'type': 'image/png'}),
        ]));
    await _settle(fixture);

    expect(root.querySelector('.li-file-upload__clear-button')!.text!.trim(),
        'Clear');
    expect(
        root
            .querySelector('.li-file-upload__remove-button')!
            .getAttribute('title'),
        'Remove');
    expect(
        root
            .querySelector('.li-file-upload__footer-preview')!
            .getAttribute('aria-label'),
        'Open preview: big.png');
    expect(
        root.querySelector('.file-upload-indicator')!.getAttribute('title'),
        'Not uploaded yet');
    expect(root.querySelector('.file-error-message')!.text,
        contains('File exceeds the maximum size of 2 B.'));

    await fixture.update((host) => host.locale = 'pt_BR');
    await _settle(fixture);
    expect(root.querySelector('.li-file-upload__clear-button')!.text!.trim(),
        'Limpar');
    expect(
        root
            .querySelector('.li-file-upload__remove-button')!
            .getAttribute('title'),
        'Remover');
    expect(
        root
            .querySelector('.li-file-upload__footer-preview')!
            .getAttribute('aria-label'),
        'Abrir visualização: big.png');
    expect(
        root.querySelector('.file-upload-indicator')!.getAttribute('title'),
        'Ainda não enviado');
    expect(root.querySelector('.file-error-message')!.text,
        contains('Arquivo excede o tamanho máximo de 2 B.'),
        reason: 'existing errors follow the new locale too');
  });

  test('an input set by the application wins over the locale', () async {
    final fixture = await testBed.create();
    await fixture.update((host) {
      host.locale = 'en_US';
      host.browseLabel = 'Anexar';
    });
    await _settle(fixture);

    expect(
        fixture.rootElement.querySelector('.btn-file span')!.text!.trim(),
        'Anexar');
  });
}

/// Lets the OnPush uploader render before reading the DOM.
Future<void> _settle(
  NgTestFixture<FileUploadLocaleTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
