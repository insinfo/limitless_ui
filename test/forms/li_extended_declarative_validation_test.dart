// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_extended_declarative_validation_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:async';
import 'package:web/web.dart' as web;
import 'package:limitless_ui/src/web_support/blob_parts.dart';

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_extended_declarative_validation_test.template.dart' as ng;

@Component(
  selector: 'li-extended-declarative-validation-test-host',
  template: '''
    <form liForm #ui="liForm">
      <div id="approval-field">
        <li-radio-group
            legend="Aprovacao"
            [value]="approvalMode"
            [liRules]="requiredRules"
            [liMessages]="approvalMessages"
            liValidationMode="submitted">
          <li-radio
              name="approvalMode"
              label="Manual"
              value="manual"
              [(ngModel)]="approvalMode">
          </li-radio>
          <li-radio
              name="approvalMode"
              label="Automatico"
              value="automatic"
              [(ngModel)]="approvalMode">
          </li-radio>
        </li-radio-group>
      </div>

      <div id="date-field">
        <li-date-picker
            [liRules]="requiredRules"
            [liMessages]="dateMessages"
            liValidationMode="submitted"
            [(ngModel)]="selectedDate">
        </li-date-picker>
      </div>

      <div id="time-field">
        <li-time-picker
            [liRules]="requiredRules"
            [liMessages]="timeMessages"
            liValidationMode="submitted"
            [(ngModel)]="selectedTime">
        </li-time-picker>
      </div>

      <div id="upload-field">
        <li-file-upload
            [previewMode]="uploadPreviewMode"
            [enablePreviewModal]="uploadPreviewModal"
            [liRules]="requiredRules"
            [liMessages]="uploadMessages"
            liValidationMode="submitted"
            [(ngModel)]="files">
        </li-file-upload>
      </div>

      <button id="validate-extended" type="button" (click)="validate(ui)">Validar</button>
    </form>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    limitlessFormDirectives,
    LiRadioComponent,
    LiRadioGroupComponent,
    LiDatePickerComponent,
    LiTimePickerComponent,
    LiFileUploadComponent,
  ],
)
class ExtendedDeclarativeValidationTestHostComponent {
  String approvalMode = '';
  DateTime? selectedDate;
  Duration? selectedTime;
  List<web.File> files = <web.File>[];
  bool? lastValidationResult;
  String uploadPreviewMode = 'compact';
  bool uploadPreviewModal = true;

  final List<LiRule> requiredRules = const <LiRule>[
    LiRule.required(),
  ];

  final Map<String, String> approvalMessages = const <String, String>{
    'required': 'Selecione um modo de aprovacao.',
  };

  final Map<String, String> dateMessages = const <String, String>{
    'required': 'Selecione uma data.',
  };

  final Map<String, String> timeMessages = const <String, String>{
    'required': 'Selecione um horario.',
  };

  final Map<String, String> uploadMessages = const <String, String>{
    'required': 'Adicione ao menos um anexo.',
  };

  void validate(LiFormDirective ui) {
    lastValidationResult = ui.validate();
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<ExtendedDeclarativeValidationTestHostComponent>(
    ng.ExtendedDeclarativeValidationTestHostComponentNgFactory,
  );

  test(
      'applies submitted-mode declarative validation to radio, date, time and upload',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final validateButton = fixture.rootElement
        .querySelector('#validate-extended') as web.HTMLButtonElement;

    await fixture.update((_) {
      validateButton.click();
    });
    await _settle(fixture);

    final radioFieldset = fixture.rootElement
        .querySelector('#approval-field fieldset') as web.Element;
    final dateInput =
        fixture.rootElement.querySelector('#date-field input.form-control')
            as web.HTMLInputElement;
    final timeInput =
        fixture.rootElement.querySelector('#time-field input.form-control')
            as web.HTMLInputElement;
    final uploadDropzone = fixture.rootElement
            .querySelector('#upload-field .li-file-upload__dropzone')
        as web.Element;

    expect(radioFieldset.classList.contains('is-invalid'), isTrue);
    expect(dateInput.classList.contains('is-invalid'), isTrue);
    expect(timeInput.classList.contains('is-invalid'), isTrue);
    expect(uploadDropzone.classList.contains('is-invalid'), isTrue);
    expect(fixture.rootElement.textContent,
        contains('Selecione um modo de aprovacao.'));
    expect(fixture.rootElement.textContent, contains('Selecione uma data.'));
    expect(fixture.rootElement.textContent, contains('Selecione um horario.'));
    expect(fixture.rootElement.textContent,
        contains('Adicione ao menos um anexo.'));
  });

  test('renders selected files inside the dashed upload area', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    expect(
      fixture.rootElement.querySelector(
        '#upload-field .fileinput-remove-button',
      ),
      isNull,
    );

    await fixture.update((host) {
      host.files = <web.File>[
        fileFromDartParts(<Object>['demo'], 'comprovante.pdf',
            type: 'application/pdf'),
      ];
    });
    await _settle(fixture);

    final uploadDropzone = fixture.rootElement
            .querySelector('#upload-field .li-file-upload__dropzone')
        as web.Element;
    final preview = uploadDropzone.querySelector('.li-file-upload__preview');
    final clearButton = fixture.rootElement.querySelector(
      '#upload-field .fileinput-remove-button',
    );
    final previewStatus = uploadDropzone.querySelector('.file-preview-status');

    expect(preview, isNotNull);
    expect(clearButton, isNotNull);
    expect(previewStatus, isNotNull);
    expect((previewStatus?.textContent ?? '').trim(), isEmpty);
    expect(uploadDropzone.textContent, contains('comprovante.pdf'));
  });

  test('opens the native picker when clicking the dashed dropzone area',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final uploadDropzone = fixture.rootElement
            .querySelector('#upload-field .li-file-upload__dropzone')
        as web.Element;
    final fileInput = fixture.rootElement.querySelector(
      '#upload-field input.file-input',
    ) as web.HTMLInputElement;
    var clickCount = 0;
    late final StreamSubscription<web.MouseEvent> subscription;
    subscription = fileInput.onClick.listen((_) {
      clickCount += 1;
    });
    addTearDown(() async {
      await subscription.cancel();
    });

    await fixture.update((_) {
      (uploadDropzone as web.HTMLElement).click();
    });
    await _settle(fixture);

    expect(clickCount, 1);
  });

  test('renders thumbnail preview cards and opens the preview modal', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.uploadPreviewMode = 'thumbnails';
      host.files = <web.File>[
        fileFromDartParts(<Object>['demo'], 'comprovante.pdf',
            type: 'application/pdf'),
      ];
    });
    await _settle(fixture);

    final uploadDropzone = fixture.rootElement
            .querySelector('#upload-field .li-file-upload__dropzone')
        as web.Element;
    final previewFrame =
        uploadDropzone.querySelector('.li-file-upload__thumb-frame');
    final previewButton =
        uploadDropzone.querySelector('.li-file-upload__action--preview')
            as web.HTMLButtonElement;

    expect(previewFrame, isNotNull);

    await fixture.update((_) {
      previewButton.click();
    });
    await _settle(fixture);

    final modalViewer =
        web.document.body?.querySelector('.li-file-upload__modal-viewer');
    final fullscreenButton =
        web.document.body?.querySelector('.btn-kv-fullscreen');
    final modalFrame =
        web.document.body?.querySelector('.li-file-upload__modal-frame');

    expect(modalViewer, isNotNull);
    expect(fullscreenButton, isNotNull);
    expect(modalFrame, isNotNull);
  });

  test('renders limitless preview cards with overlay actions and footer bar',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.uploadPreviewMode = 'limitless';
      host.files = <web.File>[
        fileFromDartParts(<Object>['demo'], 'copilot-color.png',
            type: 'image/png'),
      ];
    });
    await _settle(fixture);

    final uploadDropzone = fixture.rootElement
            .querySelector('#upload-field .li-file-upload__dropzone')
        as web.Element;
    final limitlessCard =
        uploadDropzone.querySelector('.li-file-upload__card--limitless');
    final overlay =
        uploadDropzone.querySelector('.li-file-upload__card-overlay');
    final footerBar =
        uploadDropzone.querySelector('.li-file-upload__footer-bar');
    final footerPreview =
        uploadDropzone.querySelector('.li-file-upload__footer-preview')
            as web.HTMLButtonElement;

    expect(limitlessCard, isNotNull);
    expect(overlay, isNotNull);
    expect(footerBar, isNotNull);

    await fixture.update((_) {
      footerPreview.click();
    });
    await _settle(fixture);

    final modalImage =
        web.document.body?.querySelector('.li-file-upload__modal-image');
    final rotateButton = web.document.body?.querySelector('.btn-kv-rotate')
        as web.HTMLButtonElement?;
    final fullscreenButton =
        web.document.body?.querySelector('.btn-kv-fullscreen');
    final borderlessButton = web.document.body
        ?.querySelector('.btn-kv-borderless') as web.HTMLButtonElement?;
    final zoomInButton = web.document.body
        ?.querySelector('.li-file-upload__zoom-in') as web.HTMLButtonElement?;
    final zoomBodyBefore =
        web.document.body?.querySelector('.li-file-upload__zoom-body');

    expect(modalImage, isNotNull);
    expect(rotateButton, isNotNull);
    expect(fullscreenButton, isNotNull);
    expect(borderlessButton, isNotNull);
    expect(zoomInButton, isNotNull);
    expect((zoomBodyBefore as web.HTMLElement?)?.style.overflowX,
        anyOf('hidden', ''));

    await fixture.update((_) {
      zoomInButton!.click();
    });
    await _settle(fixture);

    final zoomBodyAfter =
        web.document.body?.querySelector('.li-file-upload__zoom-body');
    expect((zoomBodyAfter as web.HTMLElement?)?.style.overflowX, 'auto');

    await fixture.update((_) {
      rotateButton!.click();
    });
    await _settle(fixture);

    final rotatedImage =
        web.document.body?.querySelector('.li-file-upload__modal-image')
            as web.HTMLImageElement?;
    expect(rotatedImage?.style.transform, contains('rotate(90deg)'));

    await fixture.update((_) {
      borderlessButton!.click();
    });
    await _settle(fixture);

    final borderlessShell = web.document.body?.querySelector(
      '.li-file-upload__zoom-shell--borderless',
    );
    expect(borderlessShell, isNotNull);
  });
}

Future<void> _settle(
  NgTestFixture<ExtendedDeclarativeValidationTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
