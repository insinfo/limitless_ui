// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_extended_declarative_validation_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
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
  List<html.File> files = <html.File>[];
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
        .querySelector('#validate-extended') as html.ButtonElement;

    await fixture.update((_) {
      validateButton.click();
    });
    await _settle(fixture);

    final radioFieldset = fixture.rootElement
        .querySelector('#approval-field fieldset') as html.Element;
    final dateInput = fixture.rootElement
        .querySelector('#date-field input.form-control') as html.InputElement;
    final timeInput = fixture.rootElement
        .querySelector('#time-field input.form-control') as html.InputElement;
    final uploadDropzone = fixture.rootElement
            .querySelector('#upload-field .li-file-upload__dropzone')
        as html.Element;

    expect(radioFieldset.classes.contains('is-invalid'), isTrue);
    expect(dateInput.classes.contains('is-invalid'), isTrue);
    expect(timeInput.classes.contains('is-invalid'), isTrue);
    expect(uploadDropzone.classes.contains('is-invalid'), isTrue);
    expect(
        fixture.rootElement.text, contains('Selecione um modo de aprovacao.'));
    expect(fixture.rootElement.text, contains('Selecione uma data.'));
    expect(fixture.rootElement.text, contains('Selecione um horario.'));
    expect(fixture.rootElement.text, contains('Adicione ao menos um anexo.'));
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
      host.files = <html.File>[
        html.File(
            <Object>['demo'],
            'comprovante.pdf',
            <String, String>{
              'type': 'application/pdf',
            }),
      ];
    });
    await _settle(fixture);

    final uploadDropzone = fixture.rootElement
            .querySelector('#upload-field .li-file-upload__dropzone')
        as html.Element;
    final preview = uploadDropzone.querySelector('.li-file-upload__preview');
    final clearButton = fixture.rootElement.querySelector(
      '#upload-field .fileinput-remove-button',
    );
    final previewStatus = uploadDropzone.querySelector('.file-preview-status');

    expect(preview, isNotNull);
    expect(clearButton, isNotNull);
    expect(previewStatus, isNotNull);
    expect(previewStatus?.text?.trim(), isEmpty);
    expect(uploadDropzone.text, contains('comprovante.pdf'));
  });

  test('opens the native picker when clicking the dashed dropzone area',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final uploadDropzone = fixture.rootElement
            .querySelector('#upload-field .li-file-upload__dropzone')
        as html.Element;
    final fileInput = fixture.rootElement.querySelector(
      '#upload-field input.file-input',
    ) as html.InputElement;
    var clickCount = 0;
    late final StreamSubscription<html.MouseEvent> subscription;
    subscription = fileInput.onClick.listen((_) {
      clickCount += 1;
    });
    addTearDown(() async {
      await subscription.cancel();
    });

    await fixture.update((_) {
      uploadDropzone.click();
    });
    await _settle(fixture);

    expect(clickCount, 1);
  });

  test('renders thumbnail preview cards and opens the preview modal', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.uploadPreviewMode = 'thumbnails';
      host.files = <html.File>[
        html.File(
            <Object>['demo'],
            'comprovante.pdf',
            <String, String>{
              'type': 'application/pdf',
            }),
      ];
    });
    await _settle(fixture);

    final uploadDropzone = fixture.rootElement
            .querySelector('#upload-field .li-file-upload__dropzone')
        as html.Element;
    final previewFrame =
        uploadDropzone.querySelector('.li-file-upload__thumb-frame');
    final previewButton =
        uploadDropzone.querySelector('.li-file-upload__action--preview')
            as html.ButtonElement;

    expect(previewFrame, isNotNull);

    await fixture.update((_) {
      previewButton.click();
    });
    await _settle(fixture);

    final modalViewer =
        html.document.body?.querySelector('.li-file-upload__modal-viewer');
    final fullscreenButton =
        html.document.body?.querySelector('.btn-kv-fullscreen');
    final modalFrame =
        html.document.body?.querySelector('.li-file-upload__modal-frame');

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
      host.files = <html.File>[
        html.File(
            <Object>['demo'],
            'copilot-color.png',
            <String, String>{
              'type': 'image/png',
            }),
      ];
    });
    await _settle(fixture);

    final uploadDropzone = fixture.rootElement
            .querySelector('#upload-field .li-file-upload__dropzone')
        as html.Element;
    final limitlessCard =
        uploadDropzone.querySelector('.li-file-upload__card--limitless');
    final overlay =
        uploadDropzone.querySelector('.li-file-upload__card-overlay');
    final footerBar =
        uploadDropzone.querySelector('.li-file-upload__footer-bar');
    final footerPreview = uploadDropzone
        .querySelector('.li-file-upload__footer-preview') as html.ButtonElement;

    expect(limitlessCard, isNotNull);
    expect(overlay, isNotNull);
    expect(footerBar, isNotNull);

    await fixture.update((_) {
      footerPreview.click();
    });
    await _settle(fixture);

    final modalImage =
        html.document.body?.querySelector('.li-file-upload__modal-image');
    final rotateButton = html.document.body?.querySelector('.btn-kv-rotate')
        as html.ButtonElement?;
    final fullscreenButton =
        html.document.body?.querySelector('.btn-kv-fullscreen');
    final borderlessButton = html.document.body
        ?.querySelector('.btn-kv-borderless') as html.ButtonElement?;
    final zoomInButton = html.document.body
        ?.querySelector('.li-file-upload__zoom-in') as html.ButtonElement?;
    final zoomBodyBefore =
        html.document.body?.querySelector('.li-file-upload__zoom-body');

    expect(modalImage, isNotNull);
    expect(rotateButton, isNotNull);
    expect(fullscreenButton, isNotNull);
    expect(borderlessButton, isNotNull);
    expect(zoomInButton, isNotNull);
    expect(zoomBodyBefore?.style.overflowX, anyOf('hidden', ''));

    await fixture.update((_) {
      zoomInButton!.click();
    });
    await _settle(fixture);

    final zoomBodyAfter =
        html.document.body?.querySelector('.li-file-upload__zoom-body');
    expect(zoomBodyAfter?.style.overflowX, 'auto');

    await fixture.update((_) {
      rotateButton!.click();
    });
    await _settle(fixture);

    final rotatedImage = html.document.body
        ?.querySelector('.li-file-upload__modal-image') as html.ImageElement?;
    expect(rotatedImage?.style.transform, contains('rotate(90deg)'));

    await fixture.update((_) {
      borderlessButton!.click();
    });
    await _settle(fixture);

    final borderlessShell = html.document.body?.querySelector(
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
