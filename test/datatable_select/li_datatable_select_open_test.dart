// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/datatable_select/li_datatable_select_open_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_datatable_select_open_test.template.dart' as ng;

class Person {
  const Person(this.id, this.name);

  final int id;
  final String name;
}

@Component(
  selector: 'li-datatable-select-open-test-host',
  template: '''
    <li-datatable-select
      #eager
      [settings]="settings"
      [dataTableFilter]="filter"
      [data]="data"
      [itemLabelBuilder]="personLabel"
      [itemValueBuilder]="personValue"
      (openChange)="openEvents.add(\$event)"
      (dataRequest)="onDataRequest(\$event)">
    </li-datatable-select>

    <li-datatable-select
      #lazy
      [settings]="settings"
      [dataTableFilter]="filter"
      [data]="data"
      [itemLabelBuilder]="personLabel"
      [itemValueBuilder]="personValue"
      [requestDataOnOpen]="true"
      (dataRequest)="onLazyDataRequest(\$event)">
    </li-datatable-select>
  ''',
  directives: [coreDirectives, formDirectives, LiDatatableSelectComponent],
)
class DatatableSelectOpenHostComponent {
  @ViewChild('eager')
  LiDatatableSelectComponent? eager;

  @ViewChild('lazy')
  LiDatatableSelectComponent? lazy;

  Filters filter = Filters(limit: 5, offset: 0);

  final List<bool> openEvents = <bool>[];
  final List<Filters> dataRequests = <Filters>[];
  final List<Filters> lazyDataRequests = <Filters>[];

  DataFrame<Person> data = DataFrame<Person>(
    items: const <Person>[
      Person(1, 'Ana Souza'),
      Person(2, 'Maria Silva'),
    ],
    totalRecords: 2,
  );

  DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(
        key: 'name',
        title: 'Nome',
        customRenderString: (Map<String, dynamic> _, dynamic row) =>
            (row as Person).name,
      ),
    ],
  );

  void onDataRequest(Filters filters) => dataRequests.add(filters);

  void onLazyDataRequest(Filters filters) => lazyDataRequests.add(filters);

  String personLabel(dynamic instance) => (instance as Person).name;

  dynamic personValue(dynamic instance) => (instance as Person).id;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DatatableSelectOpenHostComponent>(
    ng.DatatableSelectOpenHostComponentNgFactory,
  );

  test('openChange emits true on open and false on close', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.eager!.openModal());
    expect(host.openEvents, <bool>[true]);

    await fixture.update((_) => host.eager!.closeModal());
    expect(host.openEvents, <bool>[true, false]);
  });

  test('openChange emits only on real transitions', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.eager!.openModal());
    await fixture.update((_) => host.eager!.openModal());
    expect(host.openEvents, <bool>[true]);

    await fixture.update((_) => host.eager!.closeModal());
    await fixture.update((_) => host.eager!.closeModal());
    expect(host.openEvents, <bool>[true, false]);
  });

  test('does not request data on open unless asked to', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.eager!.openModal());

    // The inner datatable only emits dataRequest on user action, so an opt-out
    // component stays silent and keeps whatever the parent preloaded.
    expect(host.dataRequests, isEmpty);
  });

  test('requestDataOnOpen requests data on first open, with the current filter',
      () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    expect(host.lazyDataRequests, isEmpty);

    await fixture.update((_) => host.lazy!.openModal());

    expect(host.lazyDataRequests.length, 1);
    expect(host.lazyDataRequests.single, same(host.filter));
    expect(host.lazyDataRequests.single.limit, 5);
  });

  test('requestDataOnOpen does not re-request on reopen', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.lazy!.openModal());
    await fixture.update((_) => host.lazy!.closeModal());
    await fixture.update((_) => host.lazy!.openModal());

    expect(host.lazyDataRequests.length, 1);
  });
}
