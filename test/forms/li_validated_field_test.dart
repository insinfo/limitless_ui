// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_validated_field_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:test/test.dart';
import 'package:ngtest/ngtest.dart';

import 'li_validated_field_test.template.dart' as ng;

/// The smallest field a library user can write on top of [LiValidatedField]:
/// it declares `locale` and `errorText`, says which value the rules see and
/// marks, in the template, the wrapper that carries `data-invalid` and the
/// element that receives the focus. Everything else comes from the mixin.
@Component(
  selector: 'test-validated-field',
  template: '''
    <div class="test-field" [attr.data-invalid]="resolvedDataInvalidAttr">
      <input #control
          type="text"
          [attr.data-li-form-focus-target]="'true'"
          [attr.aria-invalid]="resolvedAriaInvalid"
          [class.is-invalid]="effectiveInvalid"
          [class.is-valid]="effectiveValid"
          [value]="text"
          (input)="handleInput(control.value)"
          (blur)="handleBlur()">
      <div *ngIf="showErrorFeedback" class="invalid-feedback d-block">{{ effectiveErrorText }}</div>
    </div>
  ''',
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class TestValidatedFieldComponent
    with LiValidatedField
    implements AfterChanges, OnDestroy {
  TestValidatedFieldComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]);

  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;

  @override
  @Input()
  String locale = 'pt_BR';

  @Input()
  String errorText = '';

  String text = '';

  @override
  dynamic get validationValue => text;

  @override
  String get externalErrorText => errorText;

  @override
  void didChangeFormSubmission() {
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngAfterChanges() {
    connectValidationForm(_formDirective);
    rebuildValidationConfig();
    runValidation();
  }

  void handleInput(String? value) {
    text = value ?? '';
    validationDirty = true;
    if (shouldRevalidate) {
      runValidation();
    }
  }

  void handleBlur() {
    validationTouched = true;
    runValidation();
  }

  @override
  void ngOnDestroy() {
    disconnectValidationForm();
  }
}

@Component(
  selector: 'li-validated-field-test-host',
  template: '''
    <div liForm #ui="liForm">
      <div id="optional-field">
        <test-validated-field [liRules]="emailRules"></test-validated-field>
      </div>

      <div id="name-field">
        <test-validated-field
            [liRules]="nameRules"
            [liMessages]="nameMessages"
            liValidationMode="submitted">
        </test-validated-field>
      </div>

      <div id="code-field">
        <test-validated-field
            [liRules]="codeRules"
            locale="en_US"
            liValidationMode="submitted"
            [invalid]="externalInvalid"
            [errorText]="externalError">
        </test-validated-field>
      </div>
    </div>
  ''',
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    TestValidatedFieldComponent,
  ],
)
class ValidatedFieldHostComponent {
  static const List<LiRule> emailRules = <LiRule>[LiRule.email()];
  static const List<LiRule> nameRules = <LiRule>[
    LiRule.required(),
    LiRule.minLength(3),
  ];
  static const Map<String, String> nameMessages = <String, String>{
    'required': 'Informe o nome.',
  };
  static const List<LiRule> codeRules = <LiRule>[LiRule.required()];

  bool externalInvalid = false;
  String externalError = '';

  @ViewChild('ui')
  LiFormDirective? form;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<ValidatedFieldHostComponent>(
    ng.ValidatedFieldHostComponentNgFactory,
  );

  html.Element wrapper(NgTestFixture<dynamic> fixture, String fieldId) =>
      fixture.rootElement.querySelector('#$fieldId .test-field')!;

  html.InputElement control(NgTestFixture<dynamic> fixture, String fieldId) =>
      fixture.rootElement.querySelector('#$fieldId input') as html.InputElement;

  String? feedback(NgTestFixture<dynamic> fixture, String fieldId) =>
      fixture.rootElement
          .querySelector('#$fieldId .invalid-feedback')
          ?.text
          ?.trim();

  test('a field built on the mixin takes liRules, liForm and the focus',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    expect(wrapper(fixture, 'name-field').attributes['data-invalid'], isNull,
        reason: 'liValidationMode="submitted" keeps the field quiet.');

    final valid =
        await fixture.assertOnlyInstance.form!.validateAndFocusFirstInvalid();
    await _settle(fixture);

    expect(valid, isFalse);
    expect(wrapper(fixture, 'name-field').attributes['data-invalid'], 'true');
    expect(control(fixture, 'name-field').classes, contains('is-invalid'));
    expect(feedback(fixture, 'name-field'), 'Informe o nome.',
        reason: 'liMessages overrides the default message.');
    expect(html.document.activeElement, same(control(fixture, 'name-field')),
        reason: 'The first invalid field built on the mixin gets the focus.');

    await fixture.update((_) => _type(control(fixture, 'name-field'), 'Jo'));
    await _settle(fixture);
    expect(feedback(fixture, 'name-field'), 'Informe pelo menos 3 caracteres.',
        reason: 'The rules run in order and report the first failure.');

    await fixture.update((_) => _type(control(fixture, 'name-field'), 'Joana'));
    await _settle(fixture);
    expect(wrapper(fixture, 'name-field').attributes['data-invalid'], isNull);
    expect(control(fixture, 'name-field').classes, contains('is-valid'));
  });

  test('the default mode shows a rule once the field is dirty', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    expect(control(fixture, 'optional-field').classes,
        isNot(contains('is-invalid')),
        reason: 'An empty optional field passes LiRule.email().');

    await fixture
        .update((_) => _type(control(fixture, 'optional-field'), 'joana@'));
    await _settle(fixture);
    expect(control(fixture, 'optional-field').classes, contains('is-invalid'));
    expect(feedback(fixture, 'optional-field'), 'Digite um e-mail valido.');
  });

  test('invalid and errorText win over the automatic validation', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await fixture.assertOnlyInstance.form!.validateAndFocusFirstInvalid();
    await _settle(fixture);
    expect(feedback(fixture, 'code-field'), 'This field is required.',
        reason: 'locale="en_US" picks the English default message.');

    await fixture.update((_) => _type(control(fixture, 'code-field'), 'A1'));
    await _settle(fixture);
    expect(wrapper(fixture, 'code-field').attributes['data-invalid'], isNull);

    await fixture.update((host) {
      host.externalInvalid = true;
      host.externalError = 'Code already in use.';
    });
    await _settle(fixture);
    expect(wrapper(fixture, 'code-field').attributes['data-invalid'], 'true');
    expect(feedback(fixture, 'code-field'), 'Code already in use.');

    await fixture.update((_) => _type(control(fixture, 'code-field'), ''));
    await _settle(fixture);
    expect(feedback(fixture, 'code-field'), 'Code already in use.',
        reason: 'The external message wins even while a rule fails.');
  });
}

void _type(html.InputElement input, String value) {
  input.value = value;
  input.dispatchEvent(html.Event('input', canBubble: true));
}

Future<void> _settle(NgTestFixture<dynamic> fixture) async {
  for (var i = 0; i < 2; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await fixture.update((_) {});
  }
}
