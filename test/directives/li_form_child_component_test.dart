// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/directives/li_form_child_component_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_form_child_component_test.template.dart' as ng;

/// A section of a larger form, declared in its own component.
///
/// Splitting a long form into child components is the usual way to keep it
/// readable; the fields still belong to the `liForm` of the page around them.
@Component(
  selector: 'li-form-child-section',
  template: '''
    <li-input
        id="child-li-input"
        label="Street"
        [liRules]="requiredRules"
        [(ngModel)]="street">
    </li-input>
    <input
        id="child-native-input"
        class="form-control"
        liRequired
        liRequiredMessage="Inform the district."
        [(ngModel)]="district">
  ''',
  directives: [coreDirectives, formDirectives, limitlessFormDirectives, LiInputComponent],
)
class LiFormChildSectionComponent {
  static const List<LiRule> requiredRules = <LiRule>[LiRule.required()];

  String street = '';
  String district = '';
}

@Component(
  selector: 'li-form-child-host',
  template: '''
    <div liForm #ui="liForm">
      <li-form-child-section></li-form-child-section>
    </div>
  ''',
  directives: [coreDirectives, limitlessFormDirectives, LiFormChildSectionComponent],
)
class LiFormChildHostComponent {
  @ViewChild('ui')
  LiFormDirective? form;
}

void main() {
  tearDown(disposeAnyRunningTest);

  Future<void> settle(NgTestFixture<LiFormChildHostComponent> fixture) async {
    // Native feedback and focus run on Timer.run / animation frames.
    for (var i = 0; i < 3; i++) {
      await fixture.update((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }
  }

  test('fields inside a child component take part in the page form', () async {
    final fixture = await NgTestBed<LiFormChildHostComponent>(
      ng.LiFormChildHostComponentNgFactory,
    ).create();
    final form = fixture.assertOnlyInstance.form!;

    final valid = await form.validateAndFocusFirstInvalid();
    await settle(fixture);

    expect(valid, isFalse,
        reason: 'The required fields of the child component are empty.');

    final liInput = html.document
        .querySelector('#child-li-input input') as html.InputElement;
    expect(liInput.classes, contains('is-invalid'),
        reason: 'li-input inside a child component must see the submit of the '
            'liForm declared by the page. Before 1.0.0-dev.45 the form was '
            'Visibility.local and the field received null.');

    final nativeInput =
        html.document.querySelector('#child-native-input') as html.InputElement;
    expect(nativeInput.classes, contains('is-invalid'),
        reason: 'Native feedback inside a child component follows the same '
            'form.');
  });
}
