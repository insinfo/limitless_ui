// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/select/li_select_before_open_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_select_before_open_test.template.dart' as ng;

@Component(
  selector: 'li-select-before-open-test-host',
  template: '''
    <li-select
        #select
        [dataSource]="options"
        labelKey="label"
        valueKey="id"
        (beforeOpen)="onBeforeOpen(\$event)"
        (openChange)="openEvents.add(\$event)"
        [(ngModel)]="selected">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectBeforeOpenHostComponent {
  @ViewChild('select')
  LiSelectComponent? select;

  String? selected;
  bool prevent = false;
  int beforeOpenCount = 0;

  /// Whether the dropdown was still closed when the handler ran.
  final List<bool> openStateDuringHandler = <bool>[];
  final List<bool> openEvents = <bool>[];

  final List<Map<String, dynamic>> options = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'review', 'label': 'Em revisao'},
  ];

  void onBeforeOpen(LiBeforeOpenEvent event) {
    beforeOpenCount++;
    openStateDuringHandler.add(select!.dropdownOpen);
    if (prevent) {
      event.preventDefault();
    }
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<SelectBeforeOpenHostComponent>(
    ng.SelectBeforeOpenHostComponentNgFactory,
  );

  test('fires while the dropdown is still closed, before openChange', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.select!.openDropdown());

    expect(host.beforeOpenCount, 1);
    // The whole point of beforeOpen: the handler runs before the state flips.
    expect(host.openStateDuringHandler, <bool>[false]);
    expect(host.select!.dropdownOpen, isTrue);
    expect(host.openEvents, <bool>[true]);
  });

  test('preventDefault keeps the dropdown closed and suppresses openChange',
      () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    host.prevent = true;
    await fixture.update((_) => host.select!.openDropdown());

    expect(host.beforeOpenCount, 1);
    expect(host.select!.dropdownOpen, isFalse);
    expect(host.openEvents, isEmpty);
  });

  test('a vetoed open leaves the select openable afterwards', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    host.prevent = true;
    await fixture.update((_) => host.select!.openDropdown());
    expect(host.select!.dropdownOpen, isFalse);

    host.prevent = false;
    await fixture.update((_) => host.select!.openDropdown());

    expect(host.beforeOpenCount, 2);
    expect(host.select!.dropdownOpen, isTrue);
    expect(host.openEvents, <bool>[true]);
  });

  test('toggleDropdown respects the veto', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    host.prevent = true;
    await fixture.update((_) => host.select!.toggleDropdown());

    expect(host.select!.dropdownOpen, isFalse);
    expect(host.openEvents, isEmpty);
  });

  test('does not fire when the dropdown is already open', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.select!.openDropdown());
    await fixture.update((_) => host.select!.openDropdown());

    expect(host.beforeOpenCount, 1);
  });

  test('does not fire on close', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.select!.openDropdown());
    await fixture.update((_) => host.select!.closeDropdown());

    expect(host.beforeOpenCount, 1);
    expect(host.openEvents, <bool>[true, false]);
  });
}
