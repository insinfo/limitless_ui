// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/select/li_select_open_change_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_select_open_change_test.template.dart' as ng;

@Component(
  selector: 'li-select-open-change-test-host',
  template: '''
    <li-select *ngIf="rendered"
        #select
        [dataSource]="options"
        labelKey="label"
        valueKey="id"
        (openChange)="openEvents.add(\$event)"
        [(ngModel)]="selected">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectOpenChangeHostComponent {
  @ViewChild('select')
  LiSelectComponent? select;

  bool rendered = true;
  String? selected;
  final List<bool> openEvents = <bool>[];

  final List<Map<String, dynamic>> options = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'review', 'label': 'Em revisao'},
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<SelectOpenChangeHostComponent>(
    ng.SelectOpenChangeHostComponentNgFactory,
  );

  test('emits true on open and false on close', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.select!.openDropdown());
    expect(host.openEvents, <bool>[true]);

    await fixture.update((_) => host.select!.closeDropdown());
    expect(host.openEvents, <bool>[true, false]);
  });

  test('emits only on real transitions', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    // Reopening an already open dropdown must stay silent.
    await fixture.update((_) => host.select!.openDropdown());
    await fixture.update((_) => host.select!.openDropdown());
    expect(host.openEvents, <bool>[true]);

    // Closing an already closed one likewise. closeDropdown() runs on paths
    // that do not know whether the dropdown was open (selection, Escape).
    await fixture.update((_) => host.select!.closeDropdown());
    await fixture.update((_) => host.select!.closeDropdown());
    expect(host.openEvents, <bool>[true, false]);
  });

  test('does not emit to a direct subscriber while being destroyed', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    // A template binding is torn down before ngOnDestroy runs, so this is
    // asserted against a direct subscription, which is what a consumer holding
    // the component through a ViewChild would have.
    final seen = <bool>[];
    final subscription = host.select!.openChange.listen(seen.add);
    addTearDown(subscription.cancel);

    await fixture.update((_) => host.select!.openDropdown());
    expect(seen, <bool>[true]);

    // ngOnDestroy calls closeDropdown() to tear the overlay down. That must not
    // reach consumers as a close event on a component that is going away.
    await fixture.update((_) => host.rendered = false);
    await Future<void>.delayed(Duration.zero);

    expect(seen, <bool>[true]);
  });

  test('toggleDropdown drives the event both ways', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.select!.toggleDropdown());
    await fixture.update((_) => host.select!.toggleDropdown());

    expect(host.openEvents, <bool>[true, false]);
  });

  test('selecting an option closes and emits false once', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.select!.openDropdown());
    await fixture.update((_) => host.select!.setSelectedItemByValue('draft'));

    expect(host.openEvents, <bool>[true, false]);
    expect(host.selected, 'draft');
  });
}
