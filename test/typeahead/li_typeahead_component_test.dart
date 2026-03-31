// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/typeahead/li_typeahead_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_typeahead_component_test.template.dart' as ng;

@Component(
  selector: 'typeahead-test-host',
  template: '''
    <div>
      <li-typeahead
          #basicTypeahead
          container="inline"
          [dataSource]="states"
          [debounceMs]="0"
          [minLength]="1"
          [(ngModel)]="selectedState">
      </li-typeahead>

      <li-typeahead
          #focusTypeahead
          container="inline"
          [dataSource]="states"
          [debounceMs]="0"
          [minLength]="0"
          [openOnFocus]="true"
          [(ngModel)]="selectedOnFocus">
      </li-typeahead>

      <li-typeahead
          #exactTypeahead
          container="inline"
          [dataSource]="states"
          [debounceMs]="0"
          [selectOnExact]="true"
          [(ngModel)]="selectedExact">
      </li-typeahead>

      <li-typeahead
          #strictTypeahead
          container="inline"
          [dataSource]="states"
          [debounceMs]="0"
          [editable]="false"
          [(ngModel)]="selectedStrict">
      </li-typeahead>

      <li-typeahead
          #asyncTypeahead
          container="inline"
          [searchCallback]="searchCities"
          [inputFormatter]="cityInputFormatter"
          [resultMarkupBuilder]="cityResultMarkup"
          [debounceMs]="0"
          [(ngModel)]="selectedAsync">
      </li-typeahead>

      <typeahead-config-host></typeahead-config-host>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiTypeaheadComponent,
    TypeaheadConfigHostComponent,
  ],
)
class TypeaheadTestHostComponent {
  final List<String> states = <String>[
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
  ];

  dynamic selectedState;
  dynamic selectedOnFocus;
  dynamic selectedExact;
  dynamic selectedStrict;
  dynamic selectedAsync;

  final List<Map<String, dynamic>> cities = <Map<String, dynamic>>[
    <String, dynamic>{'code': 'gru', 'name': 'Sao Paulo', 'region': 'BR'},
    <String, dynamic>{'code': 'sfo', 'name': 'San Francisco', 'region': 'US'},
    <String, dynamic>{'code': 'scl', 'name': 'Santiago', 'region': 'CL'},
  ];

  @ViewChild('basicTypeahead')
  LiTypeaheadComponent? basicTypeahead;

  @ViewChild('focusTypeahead')
  LiTypeaheadComponent? focusTypeahead;

  @ViewChild('exactTypeahead')
  LiTypeaheadComponent? exactTypeahead;

  @ViewChild('strictTypeahead')
  LiTypeaheadComponent? strictTypeahead;

  @ViewChild('asyncTypeahead')
  LiTypeaheadComponent? asyncTypeahead;

  Future<List<Map<String, dynamic>>> searchCities(String term) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final normalized = term.toLowerCase();
    return cities.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      return name.contains(normalized);
    }).toList();
  }

  String? cityInputFormatter(dynamic item) => item['name']?.toString();

  String cityResultMarkup(dynamic item, String term) {
    return '<strong>${item['name']}</strong><span class="city-code">${item['code']}</span>';
  }
}

@Component(
  selector: 'typeahead-config-host',
  template: '''
    <li-typeahead
        #configuredTypeahead
        container="inline"
        [dataSource]="options"
        [(ngModel)]="selectedValue">
    </li-typeahead>
  ''',
  directives: [formDirectives, LiTypeaheadComponent],
  providers: [ClassProvider(LiTypeaheadConfig)],
)
class TypeaheadConfigHostComponent {
  TypeaheadConfigHostComponent(this.config) {
    config.minLength = 0;
    config.openOnFocus = true;
    config.showHint = true;
    config.placeholder = 'Configured typeahead';
  }

  final LiTypeaheadConfig config;
  final List<String> options = <String>['Alpha', 'Beta', 'Gamma'];
  dynamic selectedValue;

  @ViewChild('configuredTypeahead')
  LiTypeaheadComponent? configuredTypeahead;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TypeaheadTestHostComponent>(
    ng.TypeaheadTestHostComponentNgFactory,
  );

  test('typing opens popup and selecting with keyboard updates ngModel',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final inputs = fixture.rootElement.querySelectorAll('input');
    final basicInput = inputs[0] as html.InputElement;

    await fixture.update((_) {
      basicInput.focus();
      basicInput.value = 'ala';
      basicInput.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    expect(host.basicTypeahead!.isPopupOpen(), isTrue);
    expect(fixture.rootElement.text, contains('Alabama'));
    expect(fixture.rootElement.text, contains('Alaska'));

    await fixture.update((_) {
      _dispatchKey(basicInput, 'ArrowDown');
      _dispatchKey(basicInput, 'Enter');
    });
    await _settle(fixture);

    expect(host.selectedState, 'Alaska');
    expect(basicInput.value, 'Alaska');
    expect(host.basicTypeahead!.isPopupOpen(), isFalse);
  });

  test('openOnFocus shows suggestions on empty input', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final inputs = fixture.rootElement.querySelectorAll('input');
    final focusInput = inputs[1] as html.InputElement;

    await fixture.update((_) {
      focusInput.focus();
      focusInput.dispatchEvent(html.Event('focus'));
    });
    await _settle(fixture);

    expect(host.focusTypeahead!.isPopupOpen(), isTrue);
    expect(host.focusTypeahead!.visibleItems, isNotEmpty);
  });

  test('selectOnExact resolves the only exact match automatically', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final inputs = fixture.rootElement.querySelectorAll('input');
    final exactInput = inputs[2] as html.InputElement;

    await fixture.update((_) {
      exactInput.focus();
      exactInput.value = 'California';
      exactInput.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedExact, 'California');
    expect(host.exactTypeahead!.isPopupOpen(), isFalse);
  });

  test('editable false keeps model null until a suggestion is selected',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final inputs = fixture.rootElement.querySelectorAll('input');
    final strictInput = inputs[3] as html.InputElement;

    await fixture.update((_) {
      strictInput.focus();
      strictInput.value = 'Ark';
      strictInput.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedStrict, isNull);
    expect(host.strictTypeahead!.isPopupOpen(), isTrue);

    await fixture.update((_) {
      _dispatchKey(strictInput, 'Enter');
    });
    await _settle(fixture);

    expect(host.selectedStrict, 'Arkansas');
    expect(strictInput.value, 'Arkansas');
  });

  test('async search shows loading state and selects remote item', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final inputs = fixture.rootElement.querySelectorAll('input');
    final asyncInput = inputs[4] as html.InputElement;

    await fixture.update((_) {
      asyncInput.focus();
      asyncInput.value = 'san';
      asyncInput.dispatchEvent(html.Event('input', canBubble: true));
    });

    await _settle(fixture, milliseconds: 260);

    expect(host.asyncTypeahead!.isPopupOpen(), isTrue);
    expect(fixture.rootElement.innerHtml, contains('city-code'));
    expect(fixture.rootElement.text, contains('San Francisco'));

    await fixture.update((_) {
      _dispatchKey(asyncInput, 'Enter');
    });
    await _settle(fixture);

    expect(asyncInput.value, 'San Francisco');
    expect(
        (host.selectedAsync as Map<String, dynamic>)['name'], 'San Francisco');
  });

  test('config service provides default values to nested typeahead', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final inputs = fixture.rootElement.querySelectorAll('input');
    final configuredInput = inputs[5] as html.InputElement;

    await fixture.update((_) {
      configuredInput.focus();
      configuredInput.dispatchEvent(html.Event('focus'));
    });
    await _settle(fixture);

    expect(configuredInput.getAttribute('placeholder'), 'Configured typeahead');
    expect(fixture.rootElement.text, contains('Alpha'));
  });
}

Future<void> _settle(
  NgTestFixture<TypeaheadTestHostComponent> fixture, {
  int milliseconds = 30,
}) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
  await fixture.update((_) {});
}

void _dispatchKey(html.Element element, String key) {
  final keyboardEventConstructor =
      js_util.getProperty(html.window, 'KeyboardEvent');
  final event = js_util.callConstructor(
    keyboardEventConstructor,
    <Object>[
      'keydown',
      js_util.jsify(<String, Object>{
        'key': key,
        'bubbles': true,
      }),
    ],
  );
  element.dispatchEvent(event as html.Event);
}
