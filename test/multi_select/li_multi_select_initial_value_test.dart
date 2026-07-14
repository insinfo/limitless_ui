// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/multi_select/li_multi_select_initial_value_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_multi_select_initial_value_test.template.dart' as ng;

@Component(
  selector: 'li-multi-select-projected-test-host',
  template: '''
    <li-multi-select #multi [(ngModel)]="selectedChannels">
      <li-multi-option [value]="'email'">E-mail</li-multi-option>
      <li-multi-option [value]="'push'">Push</li-multi-option>
      <li-multi-option [value]="'sms'">SMS</li-multi-option>
    </li-multi-select>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiMultiSelectComponent,
    LiMultiOptionComponent,
  ],
)
class MultiSelectProjectedHostComponent {
  @ViewChild('multi')
  LiMultiSelectComponent? multi;

  List<dynamic> selectedChannels = <dynamic>['email', 'sms'];
}

@Component(
  selector: 'li-multi-select-async-source-test-host',
  template: '''
    <li-multi-select
        #multi
        [dataSource]="channelOptions"
        labelKey="label"
        valueKey="id"
        [(ngModel)]="selectedChannels">
    </li-multi-select>
  ''',
  directives: [coreDirectives, formDirectives, LiMultiSelectComponent],
)
class MultiSelectAsyncSourceHostComponent {
  @ViewChild('multi')
  LiMultiSelectComponent? multi;

  List<dynamic> selectedChannels = <dynamic>['push'];

  // Starts empty, as if the options were still being fetched when the model
  // value was written.
  List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[];

  void loadOptions() {
    channelOptions = <Map<String, dynamic>>[
      <String, dynamic>{'id': 'email', 'label': 'E-mail'},
      <String, dynamic>{'id': 'push', 'label': 'Push'},
      <String, dynamic>{'id': 'sms', 'label': 'SMS'},
    ];
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final projectedTestBed = NgTestBed<MultiSelectProjectedHostComponent>(
    ng.MultiSelectProjectedHostComponentNgFactory,
  );
  final asyncSourceTestBed = NgTestBed<MultiSelectAsyncSourceHostComponent>(
    ng.MultiSelectAsyncSourceHostComponentNgFactory,
  );

  test('keeps the initial ngModel selection with projected li-multi-option',
      () async {
    final fixture = await projectedTestBed.create();
    await _settleProjected(fixture);
    final host = fixture.assertOnlyInstance;

    // writeValue runs before ngAfterContentInit populates `options`, so the
    // written value must survive until the projected options exist.
    expect(host.multi!.selectedValues, containsAll(<String>['email', 'sms']));
    expect(host.multi!.selectedValues.length, 2);
    expect(host.selectedChannels, containsAll(<String>['email', 'sms']));
    expect(fixture.rootElement.querySelectorAll('.badge').length, 2);
  });

  test('does not overwrite a user selection when options are resynced',
      () async {
    final fixture = await projectedTestBed.create();
    await _settleProjected(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      host.multi!.reset();
    });
    await _settleProjected(fixture);

    expect(host.multi!.selectedValues, isEmpty);

    // Reopening resyncs the projected options; the cleared state must hold.
    await fixture.update((_) {
      host.multi!.openDropdown();
    });
    await _settleProjected(fixture);

    expect(host.multi!.selectedValues, isEmpty);
    expect(host.selectedChannels, isEmpty);
  });

  test('applies the initial ngModel selection to a late-arriving dataSource',
      () async {
    final fixture = await asyncSourceTestBed.create();
    await _settleAsyncSource(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.multi!.selectedValues, isEmpty);

    await fixture.update((_) {
      host.loadOptions();
    });
    await _settleAsyncSource(fixture);

    expect(host.multi!.selectedValues, <String>['push']);
    expect(fixture.rootElement.querySelectorAll('.badge').length, 1);
  });
}

Future<void> _settleProjected(
    NgTestFixture<MultiSelectProjectedHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleAsyncSource(
    NgTestFixture<MultiSelectAsyncSourceHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
