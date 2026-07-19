// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/directives/li_document_mask_directives_integration_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
@Timeout(Duration(seconds: 60))
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_document_mask_directives_integration_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  group('LiCpfMaskDirective |', () {
    test('aplica mascara ao colar/digitar CPF cru e sincroniza ngModel',
        () async {
      final fixture = await NgTestBed<LiCpfHostComponent>(
        ng.LiCpfHostComponentNgFactory,
      ).create();
      final input = _input(fixture);

      _setRawInput(input, '52998224725');
      await fixture.update();

      expect(input.value, equals('529.982.247-25'));
      expect(fixture.assertOnlyInstance.value, equals('529.982.247-25'));
    });

    test('ignora letras e caracteres invalidos no CPF', () async {
      final fixture = await NgTestBed<LiCpfHostComponent>(
        ng.LiCpfHostComponentNgFactory,
      ).create();
      final input = _input(fixture);

      _setRawInput(input, '123abc456');
      await fixture.update();

      expect(input.value, equals('123.456.'));
      expect(fixture.assertOnlyInstance.value, equals('123.456.'));
    });

    test('nao bloqueia evento de paste antes da formatacao', () async {
      final fixture = await NgTestBed<LiCpfHostComponent>(
        ng.LiCpfHostComponentNgFactory,
      ).create();
      final input = _input(fixture);

      final paste = html.Event('paste', canBubble: true, cancelable: true);
      final allowed = input.dispatchEvent(paste);

      expect(allowed, isTrue);
      expect(paste.defaultPrevented, isFalse);
    });

    test('marca CPF matematicamente invalido como invalido', () async {
      final fixture = await NgTestBed<LiCpfValidatedHostComponent>(
        ng.LiCpfValidatedHostComponentNgFactory,
      ).create();
      final input = _input(fixture);

      _setRawInput(input, '00000000000');
      await _flushScheduledValidation(fixture);

      expect(input.value, equals('000.000.000-00'));
      expect(
        fixture.assertOnlyInstance.model?.control.errors?['liDocument']
            ?['type'],
        equals('cpf'),
      );
      expect(input.classes.contains('is-invalid'), isTrue);
      expect(input.getAttribute('aria-invalid'), equals('true'));
      expect(
        input.parent?.querySelector('.invalid-feedback')?.text,
        equals('Documento invalido.'),
      );
    });
  });

  group('LiCnpjMaskDirective |', () {
    test('aplica mascara de CNPJ alfanumerico e sincroniza ngModel', () async {
      final fixture = await NgTestBed<LiCnpjHostComponent>(
        ng.LiCnpjHostComponentNgFactory,
      ).create();
      final input = _input(fixture);

      _setRawInput(input, '12ABC34501DE35');
      await fixture.update();

      expect(input.value, equals('12.ABC.345/01DE-35'));
      expect(fixture.assertOnlyInstance.value, equals('12.ABC.345/01DE-35'));
    });

    test('converte letras minusculas para maiusculas no CNPJ parcial',
        () async {
      final fixture = await NgTestBed<LiCnpjHostComponent>(
        ng.LiCnpjHostComponentNgFactory,
      ).create();
      final input = _input(fixture);

      _setRawInput(input, 'cd98765');
      await fixture.update();

      expect(input.value, equals('CD.987.65'));
      expect(fixture.assertOnlyInstance.value, equals('CD.987.65'));
    });

    test('ignora letras nas duas posicoes finais de digito verificador',
        () async {
      final fixture = await NgTestBed<LiCnpjHostComponent>(
        ng.LiCnpjHostComponentNgFactory,
      ).create();
      final input = _input(fixture);

      _setRawInput(input, 'AB1234560001XX');
      await fixture.update();

      expect(input.value, equals('AB.123.456/0001-'));
      expect(fixture.assertOnlyInstance.value, equals('AB.123.456/0001-'));
    });

    test('marca CNPJ matematicamente invalido como invalido', () async {
      final fixture = await NgTestBed<LiCnpjValidatedHostComponent>(
        ng.LiCnpjValidatedHostComponentNgFactory,
      ).create();
      final input = _input(fixture);

      _setRawInput(input, '45465465465465');
      await _flushScheduledValidation(fixture);

      expect(input.value, equals('45.465.465/4654-65'));
      expect(
        fixture.assertOnlyInstance.model?.control.errors?['liDocument']
            ?['type'],
        equals('cnpj'),
      );
      expect(input.classes.contains('is-invalid'), isTrue);
      expect(
        input.parent?.querySelector('.invalid-feedback')?.text,
        equals('Documento invalido.'),
      );
    });

    test('marca CNPJ alfanumerico valido como valido', () async {
      final fixture = await NgTestBed<LiCnpjValidatedHostComponent>(
        ng.LiCnpjValidatedHostComponentNgFactory,
      ).create();
      final input = _input(fixture);

      _setRawInput(input, '12ABC34501DE35');
      await _flushScheduledValidation(fixture);

      expect(input.value, equals('12.ABC.345/01DE-35'));
      expect(fixture.assertOnlyInstance.model?.control.errors, isNull);
      expect(input.classes.contains('is-invalid'), isFalse);
      expect(input.classes.contains('is-valid'), isTrue);
      expect(input.getAttribute('aria-invalid'), equals('false'));
      expect(input.parent?.querySelector('.invalid-feedback')?.text, isEmpty);
    });
  });
}

html.InputElement _input(NgTestFixture<dynamic> fixture) {
  return fixture.rootElement.querySelector('input')! as html.InputElement;
}

void _setRawInput(html.InputElement input, String value) {
  input.value = value;
  input.setSelectionRange(value.length, value.length);
  input.dispatchEvent(html.Event('input', canBubble: true));
}

Future<void> _flushScheduledValidation(NgTestFixture<dynamic> fixture) async {
  await fixture.update();
  await Future<void>.delayed(Duration.zero);
  await fixture.update();
}

@Component(
  selector: 'li-cpf-host',
  template: '<input type="text" liCpfMask [(ngModel)]="value">',
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    LiCpfMaskDirective,
  ],
)
class LiCpfHostComponent {
  String value = '';
}

@Component(
  selector: 'li-cnpj-host',
  template: '<input type="text" liCnpjMask [(ngModel)]="value">',
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    LiCnpjMaskDirective,
  ],
)
class LiCnpjHostComponent {
  String value = '';
}

@Component(
  selector: 'li-cpf-validated-host',
  template: '''
    <input
      #model="ngForm"
      type="text"
      liCpfMask
      liDocumentValidator="cpf"
      [(ngModel)]="value">
  ''',
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    LiCpfMaskDirective,
    LiDocumentValidator,
  ],
)
class LiCpfValidatedHostComponent {
  String value = '';

  @ViewChild('model')
  NgModel? model;
}

@Component(
  selector: 'li-cnpj-validated-host',
  template: '''
    <input
      #model="ngForm"
      type="text"
      liCnpjMask
      liDocumentValidator="cnpj"
      [(ngModel)]="value">
  ''',
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    LiCnpjMaskDirective,
    LiDocumentValidator,
  ],
)
class LiCnpjValidatedHostComponent {
  String value = '';

  @ViewChild('model')
  NgModel? model;
}
