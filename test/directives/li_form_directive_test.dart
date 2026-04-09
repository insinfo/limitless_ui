// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/directives/li_form_directive_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_form_directive_test.template.dart' as ng;

@Component(
  selector: 'li-form-test-host',
  template: '''
    <form liForm #ui="liForm">
      <input
          id="first-name"
          required
          ngControl="firstName"
          [(ngModel)]="firstName"
          name="firstName">
      <input
          id="email"
          required
          ngControl="email"
          [(ngModel)]="email"
          name="email">
      <button id="validate" type="button" (click)="runValidation(ui)">Validar</button>
    </form>
  ''',
  directives: [coreDirectives, formDirectives, limitlessFormDirectives],
)
class LiFormDirectiveTestHostComponent {
  String firstName = '';
  String email = '';
  bool? lastValidationResult;

  Future<void> runValidation(LiFormDirective ui) async {
    final isValid = ui.validate();
    lastValidationResult = isValid;
    if (!isValid) {
      await ui.focusFirstInvalidLater();
    }
  }
}

@Component(
  selector: 'li-form-field-test-host',
  template: '''
    <form liForm #ui="liForm">
      <div liFormField="email" [liFormFieldOrder]="20">
        <input
            id="email"
            required
            ngControl="email"
            [(ngModel)]="email"
            name="email">
      </div>

      <div
          id="custom-field"
          liFormField="custom"
          [liFormFieldOrder]="10"
          [class.is-invalid]="customFieldInvalid">
        <button id="custom-trigger" [attr.data-li-form-focus-target]="'true'" type="button">
          Abrir
        </button>
      </div>

      <div
          id="selector-field"
          liFormField="selector"
          [liFormFieldOrder]="5"
          liFormFieldTarget=".selector-target"
          [class.is-invalid]="selectorFieldInvalid">
        <button id="selector-fallback" type="button">Fallback</button>
        <button id="selector-target" class="selector-target" type="button">
          Target
        </button>
      </div>

      <button id="validate-fields" type="button" (click)="runValidation(ui)">Validar</button>
      <button id="focus-fields" type="button" (click)="focusInvalid(ui)">Focar</button>
    </form>
  ''',
  directives: [coreDirectives, formDirectives, limitlessFormDirectives],
)
class LiFormFieldDirectiveTestHostComponent {
  String email = '';
  bool customFieldInvalid = true;
  bool selectorFieldInvalid = false;

  Future<void> runValidation(LiFormDirective ui) async {
    ui.validate();
    await ui.focusFirstInvalidLater();
  }

  Future<void> focusInvalid(LiFormDirective ui) async {
    await ui.focusFirstInvalidLater();
  }
}

@Component(
  selector: 'li-form-field-dom-order-test-host',
  template: '''
    <form liForm #ui="liForm">
      <div liFormField="first" [class.is-invalid]="firstInvalid">
        <button id="dom-first-trigger" [attr.data-li-form-focus-target]="'true'" type="button">
          Primeiro
        </button>
      </div>

      <div liFormField="second" [class.is-invalid]="secondInvalid">
        <button id="dom-second-trigger" [attr.data-li-form-focus-target]="'true'" type="button">
          Segundo
        </button>
      </div>

      <button id="focus-dom-order" type="button" (click)="focusInvalid(ui)">Focar</button>
    </form>
  ''',
  directives: [coreDirectives, formDirectives, limitlessFormDirectives],
)
class LiFormFieldDomOrderTestHostComponent {
  bool firstInvalid = true;
  bool secondInvalid = true;

  Future<void> focusInvalid(LiFormDirective ui) async {
    await ui.focusFirstInvalidLater();
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<LiFormDirectiveTestHostComponent>(
    ng.LiFormDirectiveTestHostComponentNgFactory,
  );
  final fieldTestBed = NgTestBed<LiFormFieldDirectiveTestHostComponent>(
    ng.LiFormFieldDirectiveTestHostComponentNgFactory,
  );
  final domOrderTestBed = NgTestBed<LiFormFieldDomOrderTestHostComponent>(
    ng.LiFormFieldDomOrderTestHostComponentNgFactory,
  );

  test('marca controles como touched e foca o primeiro invalido', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final root = fixture.rootElement;
    final form = root.querySelector('form') as html.FormElement;
    final button = root.querySelector('#validate') as html.ButtonElement;

    await fixture.update((_) {
      button.click();
    });
    await _settle(fixture);

    expect(host.lastValidationResult, isFalse);
    expect(form.getAttribute('data-li-form-submitted'), 'true');
  });

  test('retorna valido quando o formulario nao possui erros', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final root = fixture.rootElement;
    final button = root.querySelector('#validate') as html.ButtonElement;

    await fixture.update((component) {
      component.firstName = 'Maria';
      component.email = 'maria@example.com';
    });
    await _settle(fixture);

    await fixture.update((_) {
      button.click();
    });
    await _settle(fixture);

    expect(host.lastValidationResult, isTrue);
  });

  test('prioriza campos registrados por ordem explicita', () async {
    final fixture = await fieldTestBed.create();
    await _settleFieldFixture(fixture);
    final root = fixture.rootElement;
    final button = root.querySelector('#validate-fields') as html.ButtonElement;

    await fixture.update((_) {
      button.click();
    });
    await _settleFieldFixture(fixture);

    expect(html.document.activeElement?.id, 'custom-trigger');
  });

  test('usa seletor de alvo explicito quando liFormFieldTarget foi definido',
      () async {
    final fixture = await fieldTestBed.create();
    await _settleFieldFixture(fixture);
    final root = fixture.rootElement;
    final button = root.querySelector('#focus-fields') as html.ButtonElement;

    await fixture.update((component) {
      component.customFieldInvalid = false;
      component.selectorFieldInvalid = true;
    });
    await _settleFieldFixture(fixture);

    await fixture.update((_) {
      button.click();
    });
    await _settleFieldFixture(fixture);

    expect(html.document.activeElement?.id, 'selector-target');
  });

  test('usa a ordem da pagina quando liFormFieldOrder nao foi informado',
      () async {
    final fixture = await domOrderTestBed.create();
    await _settleDomOrderFixture(fixture);
    final root = fixture.rootElement;
    final button = root.querySelector('#focus-dom-order') as html.ButtonElement;

    await fixture.update((_) {
      button.click();
    });
    await _settleDomOrderFixture(fixture);

    expect(html.document.activeElement?.id, 'dom-first-trigger');
  });
}

Future<void> _settle(
  NgTestFixture<LiFormDirectiveTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

Future<void> _settleFieldFixture(
  NgTestFixture<LiFormFieldDirectiveTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

Future<void> _settleDomOrderFixture(
  NgTestFixture<LiFormFieldDomOrderTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}
