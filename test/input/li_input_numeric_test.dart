// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/input/li_input_numeric_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_input_numeric_test.template.dart' as ng;

@Component(
  selector: 'li-input-numeric-test-host',
  template: '''
    <div liForm #ui="liForm">
      <li-input
          id="quantity"
          label="Quantity"
          valueType="integer"
          [liRules]="quantityRules"
          liValidationMode="submitted"
          [invalid]="quantityExternalInvalid"
          [errorText]="quantityExternalError"
          [(ngModel)]="quantity">
      </li-input>

      <li-input
          id="weight"
          label="Weight"
          valueType="decimal"
          [decimalPlaces]="2"
          [(ngModel)]="weight">
      </li-input>

      <li-input
          id="price"
          label="Price"
          valueType="decimal"
          locale="en_US"
          [liRules]="priceRules"
          [(ngModel)]="price">
      </li-input>

      <li-input
          id="whole"
          label="Whole"
          valueType="decimal"
          [liRules]="integerRules"
          [(ngModel)]="whole">
      </li-input>

      <li-input
          id="year"
          label="Year"
          valueType="integer"
          min="1900"
          max="2100"
          [(ngModel)]="year">
      </li-input>

      <li-input
          id="balance"
          label="Balance"
          valueType="integer"
          [allowNegative]="true"
          [(ngModel)]="balance">
      </li-input>

      <li-input
          id="loose"
          label="Loose"
          valueType="integer"
          [(ngModel)]="loose">
      </li-input>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    limitlessFormDirectives,
    LiInputComponent,
  ],
)
class NumericInputHostComponent {
  static const List<LiRule> quantityRules = <LiRule>[
    LiRule.required(),
    LiRule.min(1),
    LiRule.max(99),
  ];
  static const List<LiRule> priceRules = <LiRule>[LiRule.max(10.5)];
  static const List<LiRule> integerRules = <LiRule>[LiRule.integer()];

  /// `num?` on purpose: with a `String` model this field raises
  /// `TypeError: type 'String' is not a subtype of type 'num?'`.
  num? quantity;
  double? weight;
  double? price;
  double? whole;
  int? year;
  int? balance;
  dynamic loose;
  bool quantityExternalInvalid = false;
  String quantityExternalError = '';

  @ViewChild('ui')
  LiFormDirective? form;
}

/// A section of a larger form declared in its own component.
@Component(
  selector: 'li-input-numeric-child-section',
  template: '''
    <li-input
        id="child-amount"
        label="Amount"
        valueType="integer"
        [liRules]="requiredRules"
        [(ngModel)]="amount">
    </li-input>
  ''',
  directives: [coreDirectives, formDirectives, LiInputComponent],
)
class NumericChildSectionComponent {
  static const List<LiRule> requiredRules = <LiRule>[LiRule.required()];

  int? amount;
}

@Component(
  selector: 'li-input-numeric-child-host',
  template: '''
    <div liForm #ui="liForm">
      <li-input-numeric-child-section></li-input-numeric-child-section>
    </div>
  ''',
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    NumericChildSectionComponent,
  ],
)
class NumericChildHostComponent {
  @ViewChild('ui')
  LiFormDirective? form;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<NumericInputHostComponent>(
    ng.NumericInputHostComponentNgFactory,
  );

  html.InputElement inputOf(NgTestFixture<dynamic> fixture, String id) =>
      fixture.rootElement.querySelector('input#$id') as html.InputElement;

  String? feedbackOf(NgTestFixture<dynamic> fixture, String id) => fixture
      .rootElement
      .querySelector('#$id')
      ?.parent
      ?.parent
      ?.querySelector('.invalid-feedback')
      ?.text
      ?.trim();

  test('integer mode hands an int to the model and null when empty', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input = inputOf(fixture, 'quantity');

    expect(input.type, 'text');
    expect(input.getAttribute('inputmode'), 'numeric');

    await fixture.update((_) => _type(input, '42'));
    await _settle(fixture);
    expect(host.quantity, 42);
    expect(host.quantity, isA<int>());

    await fixture.update((_) => _type(input, '4a2.'));
    await _settle(fixture);
    expect(input.value, '42', reason: 'Only digits can be typed.');
    expect(host.quantity, 42);

    await fixture.update((_) => _type(input, ''));
    await _settle(fixture);
    expect(host.quantity, isNull);
  });

  test('writeValue accepts num, String and null', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.update((host) {
      host.quantity = 7;
      host.weight = 3.5;
      host.price = 1234.25;
      host.loose = '12';
    });
    await _settle(fixture);

    expect(inputOf(fixture, 'quantity').value, '7');
    expect(inputOf(fixture, 'weight').value, '3,5',
        reason: 'pt_BR writes the decimal part after a comma.');
    expect(inputOf(fixture, 'price').value, '1234.25');
    expect(inputOf(fixture, 'loose').value, '12');

    await fixture.update((host) {
      host.quantity = null;
      host.loose = null;
    });
    await _settle(fixture);
    expect(inputOf(fixture, 'quantity').value, '');
    expect(inputOf(fixture, 'loose').value, '');
  });

  test('decimal mode follows the locale separator and decimalPlaces',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final weight = inputOf(fixture, 'weight');
    final price = inputOf(fixture, 'price');

    expect(weight.getAttribute('inputmode'), 'decimal');

    await fixture.update((_) => _type(weight, '3,456'));
    await _settle(fixture);
    expect(weight.value, '3,45', reason: 'decimalPlaces caps the fraction.');
    expect(host.weight, 3.45);
    expect(host.weight, isA<double>());

    await fixture.update((_) => _type(weight, '1.5'));
    await _settle(fixture);
    expect(weight.value, '15',
        reason: 'In pt_BR the dot is not the decimal separator.');
    expect(host.weight, 15);

    await fixture.update((_) => _type(weight, '2,'));
    await _settle(fixture);
    expect(weight.value, '2,', reason: 'A half-typed number stays on screen.');
    expect(host.weight, 2);

    await fixture.update((_) => _type(price, '1,5.25'));
    await _settle(fixture);
    expect(price.value, '15.25');
    expect(host.price, 15.25);
  });

  test('min, max and integer rules report in the field', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final price = inputOf(fixture, 'price');
    final whole = inputOf(fixture, 'whole');
    final year = inputOf(fixture, 'year');

    await fixture.update((_) => _type(price, '10.75'));
    await _settle(fixture);
    expect(price.classes, contains('is-invalid'));
    expect(feedbackOf(fixture, 'price'),
        'Enter a value less than or equal to 10.5.');

    await fixture.update((_) => _type(price, '10.5'));
    await _settle(fixture);
    expect(price.classes, isNot(contains('is-invalid')));

    await fixture.update((_) => _type(whole, '2,5'));
    await _settle(fixture);
    expect(whole.classes, contains('is-invalid'));
    expect(feedbackOf(fixture, 'whole'), 'Informe um número inteiro.');

    await fixture.update((_) => _type(whole, '2'));
    await _settle(fixture);
    expect(whole.classes, isNot(contains('is-invalid')));

    await fixture.update((_) => _type(year, '1850'));
    await _settle(fixture);
    expect(year.classes, contains('is-invalid'),
        reason: 'min="1900" becomes LiRule.min(1900) in numeric mode.');
    expect(feedbackOf(fixture, 'year'), 'Informe um valor maior ou igual a 1900.');

    await fixture.update((_) => _type(year, '2200'));
    await _settle(fixture);
    expect(feedbackOf(fixture, 'year'), 'Informe um valor menor ou igual a 2100.');
  });

  test('allowNegative controls the leading minus sign', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final year = inputOf(fixture, 'year');
    final balance = inputOf(fixture, 'balance');

    expect(balance.getAttribute('inputmode'), isNull,
        reason: 'iOS numeric keypads have no minus key.');

    await fixture.update((_) {
      _type(year, '-5');
      _type(balance, '-5-');
    });
    await _settle(fixture);
    expect(year.value, '5');
    expect(host.year, 5);
    expect(balance.value, '-5');
    expect(host.balance, -5);

    await fixture.update((_) => _type(balance, '-'));
    await _settle(fixture);
    expect(host.balance, isNull, reason: 'A lone minus sign is not a number.');
  });

  test('submitted mode, external error precedence and focus on submit',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final quantity = inputOf(fixture, 'quantity');

    await fixture.update((_) => _type(quantity, '0'));
    await _settle(fixture);
    expect(quantity.classes, isNot(contains('is-invalid')),
        reason: 'liValidationMode="submitted" waits for the submit.');

    final valid = await host.form!.validateAndFocusFirstInvalid();
    await _settle(fixture);
    expect(valid, isFalse);
    expect(quantity.classes, contains('is-invalid'));
    expect(feedbackOf(fixture, 'quantity'),
        'Informe um valor maior ou igual a 1.');
    expect(html.document.activeElement, same(quantity));

    await fixture.update((host) {
      host.quantityExternalInvalid = true;
      host.quantityExternalError = 'Estoque insuficiente.';
    });
    await _settle(fixture);
    expect(feedbackOf(fixture, 'quantity'), 'Estoque insuficiente.');

    await fixture.update((_) => _type(quantity, '5'));
    await _settle(fixture);
    expect(quantity.classes, contains('is-invalid'),
        reason: 'The external state wins even with the rules passing.');
    expect(feedbackOf(fixture, 'quantity'), 'Estoque insuficiente.');
  });

  test('a numeric field inside a child component takes part in the page form',
      () async {
    final fixture = await NgTestBed<NumericChildHostComponent>(
      ng.NumericChildHostComponentNgFactory,
    ).create();
    await _settle(fixture);

    final valid = await fixture.assertOnlyInstance.form!
        .validateAndFocusFirstInvalid();
    await _settle(fixture);

    expect(valid, isFalse);
    final input = fixture.rootElement.querySelector('input#child-amount')
        as html.InputElement;
    expect(input.classes, contains('is-invalid'));
    expect(html.document.activeElement, same(input));
  });
}

void _type(html.InputElement input, String text) {
  input.value = text;
  input.dispatchEvent(html.Event('input', canBubble: true));
}

Future<void> _settle(NgTestFixture<dynamic> fixture) async {
  for (var i = 0; i < 2; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await fixture.update((_) {});
  }
}
