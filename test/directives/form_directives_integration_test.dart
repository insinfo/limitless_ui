// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/directives/form_directives_integration_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'form_directives_integration_test.template.dart' as ng;

@Component(
  selector: 'form-directives-test-host',
  template: '''
    <input
      id="masked-input"
      [liTextMask]="liTextMaskConfig"
      [(ngModel)]="maskedValue">

    <input
      id="string-mask-input"
      [liTextMask]="'xxxxx-xxx'"
      [(ngModel)]="stringMaskedValue">

    <input
      id="attribute-mask-input"
      liTextMask="xxxxx-xxx"
      [(ngModel)]="attributeMaskedValue">

    <input
      id="scalar-mask-input"
      liTextMask
      liTextMaskMask="(xx) xxxx-xxxx"
      [(ngModel)]="scalarMaskedValue">

    <div liForm #validationForm="liForm">
      <input
        id="required-native-input"
        type="text"
        class="form-control"
        liRequired
        liRequiredMessage="Campo requerido!"
        [(ngModel)]="requiredNativeValue">
      <button
        id="validate-native-input"
        type="button"
        (click)="validateNativeInput(validationForm)">
        Validar
      </button>
    </div>

    <input
      id="number-input"
      type="number"
      [liPrecision]="4"
      [(ngModel)]="amount">

    <input
      id="datetime-input"
      type="datetime-local"
      [(ngModel)]="scheduledAt">
  ''',
  directives: [coreDirectives, limitlessFormDirectives, LiTextMaskDirective],
)
class FormDirectivesIntegrationTestHostComponent {
  Map<String, dynamic> liTextMaskConfig = <String, dynamic>{
    'mask': 'xx/xx',
    'maxLength': 5,
  };

  String maskedValue = '';
  String stringMaskedValue = '';
  String attributeMaskedValue = '';
  String scalarMaskedValue = '';
  String requiredNativeValue = '';
  bool? requiredNativeValid;
  double? amount = 12.34567;
  DateTime? scheduledAt = DateTime(2024, 6, 5, 13, 45);

  Future<void> validateNativeInput(LiFormDirective form) async {
    requiredNativeValid = await form.validateAndFocusFirstInvalid();
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<FormDirectivesIntegrationTestHostComponent>(
    ng.FormDirectivesIntegrationTestHostComponentNgFactory,
  );

  test('aplica a mascara de texto via binding e reage a fixture.update',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input =
        fixture.rootElement.querySelector('#masked-input') as html.InputElement;

    await fixture.update((_) {
      _typeSequentially(input, '1234');
    });
    await _settle(fixture);

    expect(input.value, '12/34');
    expect(host.maskedValue, '12/34');

    await fixture.update((component) {
      component.liTextMaskConfig = <String, dynamic>{
        'mask': 'xxx-xx',
        'maxLength': 6,
      };
      component.maskedValue = '';
      input.value = '';
    });
    await _settle(fixture);

    await fixture.update((_) {
      _typeSequentially(input, '12345');
    });
    await _settle(fixture);

    expect(input.value, '123-45');
    expect(host.maskedValue, '123-45');
  });

  test('aceita mascara de texto diretamente como string', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input = fixture.rootElement.querySelector('#string-mask-input')
        as html.InputElement;

    await fixture.update((_) {
      _typeSequentially(input, '12345678');
    });
    await _settle(fixture);

    expect(input.value, '12345-678');
    expect(host.stringMaskedValue, '12345-678');
  });

  test('aceita mascara via atributo estatico do template', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input = fixture.rootElement.querySelector('#attribute-mask-input')
        as html.InputElement;

    await fixture.update((_) {
      _typeSequentially(input, '12345678');
    });
    await _settle(fixture);

    expect(input.value, '12345-678');
    expect(host.attributeMaskedValue, '12345-678');
  });

  test('aceita configuracao por inputs escalares', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input = fixture.rootElement.querySelector('#scalar-mask-input')
        as html.InputElement;

    await fixture.update((_) {
      _typeSequentially(input, '4133334444');
    });
    await _settle(fixture);

    expect(input.value, '(41) 3333-4444');
    expect(host.scalarMaskedValue, '(41) 3333-4444');
  });

  test('aplica feedback visual Limitless em input nativo com liRequired',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input = fixture.rootElement.querySelector('#required-native-input')
        as html.InputElement;
    final validateButton = fixture.rootElement
        .querySelector('#validate-native-input') as html.ButtonElement;

    await fixture.update((_) {
      validateButton.click();
    });
    await _settle(fixture);

    final feedback = input.parent?.querySelector('.invalid-feedback');

    expect(host.requiredNativeValid, isFalse);
    expect(html.document.activeElement, same(input));
    expect(input.classes.contains('is-invalid'), isTrue);
    expect(input.getAttribute('aria-invalid'), 'true');
    expect(feedback, isNotNull);
    expect(feedback?.text, 'Campo requerido!');

    await fixture.update((_) {
      input.value = 'ok';
      input.dispatchEvent(html.Event('input', canBubble: true));
      input.dispatchEvent(html.Event('blur', canBubble: true));
    });
    await _settle(fixture);

    expect(input.classes.contains('is-invalid'), isFalse);
    expect(input.classes.contains('is-valid'), isTrue);
    expect(input.getAttribute('aria-invalid'), 'false');
    expect(feedback?.text, isEmpty);
  });

  test('integra o accessor numerico via limitlessFormDirectives', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input =
        fixture.rootElement.querySelector('#number-input') as html.InputElement;

    expect(input.value, '12.35');

    await fixture.update((_) {
      input.value = '9.5';
      input.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    expect(host.amount, 9.5);
  });

  test('integra o accessor datetime-local via limitlessFormDirectives',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input = fixture.rootElement.querySelector('#datetime-input')
        as html.InputElement;

    expect(input.value, '2024-06-05T13:45');

    await fixture.update((_) {
      input.value = '2024-06-06T08:30';
      input.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    expect(host.scheduledAt, isNotNull);
    expect(host.scheduledAt!.year, 2024);
    expect(host.scheduledAt!.month, 6);
    expect(host.scheduledAt!.day, 6);
    expect(host.scheduledAt!.hour, 8);
    expect(host.scheduledAt!.minute, 30);
  });
}

Future<void> _settle(
  NgTestFixture<FormDirectivesIntegrationTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

void _typeSequentially(html.InputElement input, String text) {
  for (final char in text.split('')) {
    input.value = '${input.value ?? ''}$char';
    input.dispatchEvent(html.Event('input', canBubble: true));
  }
}
