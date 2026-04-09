// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_extended_declarative_validation_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

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

  test('applies submitted-mode declarative validation to radio, date, time and upload', () async {
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
        .querySelector('#upload-field .li-file-upload__dropzone') as html.Element;

    expect(radioFieldset.classes.contains('is-invalid'), isTrue);
    expect(dateInput.classes.contains('is-invalid'), isTrue);
    expect(timeInput.classes.contains('is-invalid'), isTrue);
    expect(uploadDropzone.classes.contains('is-invalid'), isTrue);
    expect(fixture.rootElement.text, contains('Selecione um modo de aprovacao.'));
    expect(fixture.rootElement.text, contains('Selecione uma data.'));
    expect(fixture.rootElement.text, contains('Selecione um horario.'));
    expect(fixture.rootElement.text, contains('Adicione ao menos um anexo.'));
  });
}

Future<void> _settle(
  NgTestFixture<ExtendedDeclarativeValidationTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}