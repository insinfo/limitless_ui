// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/select/li_select_readonly_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_select_readonly_test.template.dart' as ng;

@Component(
  selector: 'li-select-readonly-test-host',
  template: '''
    <li-select
        #select
        [dataSource]="options"
        labelKey="label"
        valueKey="id"
        [readonly]="readonly"
        [showClearButton]="true"
        (openChange)="openEvents.add(\$event)"
        [(ngModel)]="selected">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectReadonlyHostComponent {
  @ViewChild('select')
  LiSelectComponent? select;

  bool readonly = true;
  String? selected = 'review';
  final List<bool> openEvents = <bool>[];

  final List<Map<String, dynamic>> options = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'review', 'label': 'Em revisao'},
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<SelectReadonlyHostComponent>(
    ng.SelectReadonlyHostComponentNgFactory,
  );

  html.ButtonElement trigger(NgTestFixture fixture) =>
      fixture.rootElement.querySelector('[data-label="li_select_toggle"]')
          as html.ButtonElement;

  test('stays focusable and announces itself as read-only', () async {
    final fixture = await testBed.create();
    final button = trigger(fixture);

    expect(button.disabled, isFalse);
    expect(button.getAttribute('aria-readonly'), 'true');
    expect(button.classes, contains('dropdown-button--readonly'));
    expect(button.querySelector('.dropdown-value')!.text, 'Em revisao');
  });

  test('does not open from a click, the keyboard or the API', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => trigger(fixture).click());
    await fixture.update((_) => host.select!.openDropdown());
    await fixture
        .update((_) => trigger(fixture).dispatchEvent(_enterKeydown()));

    expect(host.select!.dropdownOpen, isFalse);
    expect(host.openEvents, isEmpty);
  });

  test('hides the clear button and ignores clearSelection', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    expect(fixture.rootElement.querySelector('.dropdown-clear'), isNull);

    await fixture.update((_) => host.select!.clearSelection());
    expect(host.selected, 'review');
  });

  test('still accepts programmatic writes through ngModel', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((h) => h.selected = 'draft');
    await fixture.update();

    expect(host.select!.currentValue?.value, 'draft');
    expect(trigger(fixture).querySelector('.dropdown-value')!.text, 'Rascunho');
  });

  test('opens again once readonly is turned off', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((h) => h.readonly = false);
    await fixture.update((_) => trigger(fixture).click());

    expect(host.select!.dropdownOpen, isTrue);
    expect(trigger(fixture).getAttribute('aria-readonly'), isNull);
    expect(fixture.rootElement.querySelector('.dropdown-clear'), isNotNull);

    await fixture.update((_) => host.select!.closeDropdown());
  });
}

html.KeyboardEvent _enterKeydown() => js_util.callConstructor(
      js_util.getProperty(html.window, 'KeyboardEvent'),
      <Object>[
        'keydown',
        js_util.jsify(<String, Object>{
          'key': 'Enter',
          'code': 'Enter',
          'bubbles': true,
        }),
      ],
    ) as html.KeyboardEvent;
