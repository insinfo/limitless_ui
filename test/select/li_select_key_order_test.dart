// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/select/li_select_key_order_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_select_key_order_test.template.dart' as ng;

/// Constant data source bound BEFORE the `[labelKey]`/`[valueKey]` bindings: the
/// options are built when `dataSource` arrives, while the keys are still the
/// defaults, and the same constant never arrives again.
@Component(
  selector: 'li-select-key-order-test-host',
  template: '''
    <li-select
        #select
        [dataSource]="options"
        [labelKey]="labelKey"
        [valueKey]="valueKey"
        [(ngModel)]="selected">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectKeyOrderHostComponent {
  @ViewChild('select')
  LiSelectComponent? select;

  String labelKey = 'rotulo';
  String valueKey = 'valor';
  String? selected = 'b';

  static final List<Map<String, dynamic>> constantOptions =
      <Map<String, dynamic>>[
    <String, dynamic>{'valor': 'a', 'rotulo': 'Opção A'},
    <String, dynamic>{'valor': 'b', 'rotulo': 'Opção B'},
  ];

  final List<Map<String, dynamic>> options = constantOptions;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<SelectKeyOrderHostComponent>(
    ng.SelectKeyOrderHostComponentNgFactory,
  );

  test('builds the labels and values when the keys come after the data source',
      () async {
    final fixture = await testBed.create();
    await fixture.update((_) {});

    final select = fixture.assertOnlyInstance.select!;
    expect(select.options.map((o) => o.text), <String?>['Opção A', 'Opção B']);
    expect(select.options.map((o) => o.value), <dynamic>['a', 'b']);
    expect(select.currentValue?.text, 'Opção B');
  });

  test('rebuilds the options when a key changes later', () async {
    final fixture = await testBed.create();
    await fixture.update((host) => host.labelKey = 'valor');

    final select = fixture.assertOnlyInstance.select!;
    expect(select.options.map((o) => o.text), <String?>['a', 'b']);
  });
}
