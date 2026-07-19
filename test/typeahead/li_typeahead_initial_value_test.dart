// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/typeahead/li_typeahead_initial_value_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:web/web.dart' as web;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import '../support/web_event_factories.dart';

import 'li_typeahead_initial_value_test.template.dart' as ng;

@Component(
  selector: 'li-typeahead-async-test-host',
  template: '''
    <li-typeahead
        #typeahead
        container="inline"
        [dataSource]="cities"
        labelKey="name"
        valueKey="code"
        [debounceMs]="0"
        [editable]="false"
        [(ngModel)]="selectedCity">
    </li-typeahead>
  ''',
  directives: [coreDirectives, formDirectives, LiTypeaheadComponent],
)
class TypeaheadAsyncHostComponent {
  @ViewChild('typeahead')
  LiTypeaheadComponent? typeahead;

  dynamic selectedCity = 'sfo';

  // Starts empty, as if the cities were still being fetched when the model
  // value was written.
  List<Map<String, dynamic>> cities = <Map<String, dynamic>>[];

  void loadCities() {
    cities = <Map<String, dynamic>>[
      <String, dynamic>{'code': 'gru', 'name': 'Sao Paulo'},
      <String, dynamic>{'code': 'sfo', 'name': 'San Francisco'},
      <String, dynamic>{'code': 'scl', 'name': 'Santiago'},
    ];
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TypeaheadAsyncHostComponent>(
    ng.TypeaheadAsyncHostComponentNgFactory,
  );

  test('resolves the initial ngModel value once the dataSource arrives',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input =
        fixture.rootElement.querySelector('input') as web.HTMLInputElement;

    // Nothing to resolve against yet, so the raw value stands in for the label.
    expect(input.value, 'sfo');

    await fixture.update((_) {
      host.loadCities();
    });
    await _settle(fixture);

    // The retained value is matched against the items that just arrived, so the
    // raw "sfo" becomes its label instead of staying unresolved forever.
    expect(input.value, 'San Francisco');
    expect(host.selectedCity, 'sfo');
  });

  test('the resolved value survives a blur with editable=false', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input =
        fixture.rootElement.querySelector('input') as web.HTMLInputElement;

    await fixture.update((_) {
      host.loadCities();
    });
    await _settle(fixture);

    // With no item resolved, a blur wipes the field because editable is false.
    await fixture.update((_) {
      host.typeahead!.handleBlur();
    });
    await _settle(fixture);

    expect(input.value, 'San Francisco');
    expect(host.selectedCity, 'sfo');
  });

  test('does not restore a stale value over a cleared selection', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input =
        fixture.rootElement.querySelector('input') as web.HTMLInputElement;

    await fixture.update((_) {
      host.loadCities();
    });
    await _settle(fixture);
    expect(input.value, 'San Francisco');

    // Clearing the field goes through the same model-emit path a user edit does.
    await fixture.update((_) {
      input.value = '';
      input.dispatchEvent(bubblingEvent('input'));
    });
    await _settle(fixture);
    expect(host.selectedCity, isNull);

    // A dataSource resync must not bring "sfo" back.
    await fixture.update((_) {
      host.cities = <Map<String, dynamic>>[
        <String, dynamic>{'code': 'gru', 'name': 'Sao Paulo'},
        <String, dynamic>{'code': 'sfo', 'name': 'San Francisco'},
        <String, dynamic>{'code': 'scl', 'name': 'Santiago'},
        <String, dynamic>{'code': 'rio', 'name': 'Rio de Janeiro'},
      ];
    });
    await _settle(fixture);

    expect(host.selectedCity, isNull);
    expect(input.value, isEmpty);
  });
}

Future<void> _settle(NgTestFixture<TypeaheadAsyncHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
