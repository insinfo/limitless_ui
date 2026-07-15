// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/multi_select/li_multi_select_before_open_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_multi_select_before_open_test.template.dart' as ng;

@Component(
  selector: 'li-multi-select-before-open-test-host',
  template: '''
    <li-multi-select
        #select
        [dataSource]="options"
        labelKey="label"
        valueKey="id"
        (beforeOpen)="onBeforeOpen(\$event)"
        (openChange)="openEvents.add(\$event)"
        [(ngModel)]="selected">
    </li-multi-select>
  ''',
  directives: [coreDirectives, formDirectives, LiMultiSelectComponent],
)
class MultiSelectBeforeOpenHostComponent {
  @ViewChild('select')
  LiMultiSelectComponent? select;

  List<dynamic> selected = <dynamic>[];
  bool prevent = false;
  int beforeOpenCount = 0;

  /// Whether the dropdown was still closed when the handler ran.
  final List<bool> openStateDuringHandler = <bool>[];
  final List<bool> openEvents = <bool>[];

  final List<Map<String, dynamic>> options = <Map<String, dynamic>>[
    <String, dynamic>{'id': 1, 'label': 'Rascunho'},
    <String, dynamic>{'id': 2, 'label': 'Em revisao'},
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

  final testBed = NgTestBed<MultiSelectBeforeOpenHostComponent>(
    ng.MultiSelectBeforeOpenHostComponentNgFactory,
  );

  test('fires while the dropdown is still closed, before openChange', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.select!.openDropdown());

    expect(host.beforeOpenCount, 1);
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

  test('toggleDropdown drives beforeOpen and openChange both ways', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    // toggleDropdown used to flip dropdownOpen before delegating, so both
    // openDropdown and closeDropdown saw the new state as the previous one and
    // emitted nothing. This is the path the trigger click uses.
    await fixture.update((_) => host.select!.toggleDropdown());
    expect(host.beforeOpenCount, 1);
    expect(host.openEvents, <bool>[true]);

    await fixture.update((_) => host.select!.toggleDropdown());
    expect(host.openEvents, <bool>[true, false]);
  });

  test('clicking the trigger emits beforeOpen and openChange', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    final trigger = fixture.rootElement
        .querySelector('[data-label="li_ms_toggle"]') as html.HtmlElement;

    await fixture.update((_) => trigger.click());

    expect(host.beforeOpenCount, 1);
    expect(host.openStateDuringHandler, <bool>[false]);
    expect(host.openEvents, <bool>[true]);
    expect(host.select!.dropdownOpen, isTrue);
  });

  test('a vetoed trigger click leaves the dropdown closed', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    host.prevent = true;
    final trigger = fixture.rootElement
        .querySelector('[data-label="li_ms_toggle"]') as html.HtmlElement;

    await fixture.update((_) => trigger.click());

    expect(host.beforeOpenCount, 1);
    expect(host.select!.dropdownOpen, isFalse);
    expect(host.openEvents, isEmpty);
  });
}
