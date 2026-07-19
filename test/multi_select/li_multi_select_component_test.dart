// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/multi_select/li_multi_select_component_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'package:web/web.dart' as web;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import '../support/web_event_factories.dart';
import '../support/web_node_list.dart';

import 'li_multi_select_component_test.template.dart' as ng;

@Component(
  selector: 'li-multi-select-test-host',
  template: '''
    <li-multi-select
        #multi
        [dataSource]="channelOptions"
        labelKey="label"
        valueKey="id"
        triggerIconMode="overlay"
        (modelChange)="selectedChannelModels = \$event"
        (userValueChange)="userSelectedChannels = \$event"
        [(ngModel)]="selectedChannels">
    </li-multi-select>
  ''',
  directives: [coreDirectives, formDirectives, LiMultiSelectComponent],
)
class MultiSelectTestHostComponent {
  @ViewChild('multi')
  LiMultiSelectComponent? multi;

  List<dynamic> selectedChannels = <dynamic>['email'];
  List<dynamic>? userSelectedChannels;
  List<dynamic> selectedChannelModels = <dynamic>[];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'E-mail'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
  ];
}

class MultiSelectCompareValue {
  const MultiSelectCompareValue(this.id, this.label);

  final int id;
  final String label;
}

@Component(
  selector: 'li-multi-select-compare-test-host',
  template: '''
    <li-multi-select
      [dataSource]="channelOptions"
      labelKey="label"
      valueKey="value"
      [compareWith]="compareById"
      [(ngModel)]="selectedChannels">
    </li-multi-select>
  ''',
  directives: [coreDirectives, formDirectives, LiMultiSelectComponent],
)
class MultiSelectCompareTestHostComponent {
  List<dynamic> selectedChannels = <dynamic>[
    const MultiSelectCompareValue(2, 'Push antigo'),
  ];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{
      'label': 'E-mail',
      'value': const MultiSelectCompareValue(1, 'E-mail'),
    },
    <String, dynamic>{
      'label': 'Push',
      'value': const MultiSelectCompareValue(2, 'Push'),
    },
  ];

  bool compareById(dynamic optionValue, dynamic modelValue) {
    return optionValue is MultiSelectCompareValue &&
        modelValue is MultiSelectCompareValue &&
        optionValue.id == modelValue.id;
  }
}

@Component(
  selector: 'li-multi-select-validation-test-host',
  template: '''
    <div id="validation-multi-select-field">
      <li-multi-select
          [dataSource]="channelOptions"
          labelKey="label"
          valueKey="id"
          [liRules]="channelRules"
          liValidationMode="dirty"
          [(ngModel)]="selectedChannels">
      </li-multi-select>
    </div>
  ''',
  directives: [coreDirectives, formDirectives, LiMultiSelectComponent],
)
class MultiSelectValidationTestHostComponent {
  List<dynamic> selectedChannels = <dynamic>['email', 'push'];

  final List<LiRule> channelRules = <LiRule>[
    LiRule.custom(
      (dynamic value) {
        final total = value is Iterable ? value.length : 0;
        return total >= 2 ? null : 'Selecione ao menos 2 canais.';
      },
      code: 'minItems',
    ),
  ];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'E-mail'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);
  tearDown(() {
    web.document.documentElement?.removeAttribute('data-color-theme');
  });

  final testBed = NgTestBed<MultiSelectTestHostComponent>(
    ng.MultiSelectTestHostComponentNgFactory,
  );
  final compareTestBed = NgTestBed<MultiSelectCompareTestHostComponent>(
    ng.MultiSelectCompareTestHostComponentNgFactory,
  );
  final validationTestBed = NgTestBed<MultiSelectValidationTestHostComponent>(
    ng.MultiSelectValidationTestHostComponentNgFactory,
  );

  test('toggles options and updates ngModel', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as web.HTMLButtonElement;

    expect(host.userSelectedChannels, isNull);

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    final pushOption = web.document
        .querySelectorAll('.dropdown-container .dropdown-item')
        .toElementList()
        .cast<web.Element>()
        .firstWhere(
            (element) => ((element.textContent ?? '')).contains('Push'));

    await fixture.update((_) {
      pushOption.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.selectedChannels, containsAll(<String>['email', 'push']));
    expect(host.userSelectedChannels, containsAll(<String>['email', 'push']));
    expect(
      host.selectedChannelModels
          .map((dynamic item) => (item as Map<String, dynamic>)['id']),
      containsAll(<String>['email', 'push']),
    );

    await fixture.update((_) {
      pushOption.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.selectedChannels, <String>['email']);
    expect(host.userSelectedChannels, <String>['email']);
    expect(
      host.selectedChannelModels
          .map((dynamic item) => (item as Map<String, dynamic>)['id']),
      <String>['email'],
    );
  });

  test('reset clears selected values and badges', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(fixture.rootElement.querySelectorAll('.badge').toElementList(),
        isNotEmpty);
    expect(host.userSelectedChannels, isNull);

    await fixture.update((_) {
      host.multi!.reset();
    });
    await _settle(fixture);

    expect(host.selectedChannels, isEmpty);
    expect(host.userSelectedChannels, isNull);
    expect(host.selectedChannelModels, isEmpty);
    expect(fixture.rootElement.querySelectorAll('.badge').toElementList(),
        isEmpty);
  });

  test('clear button resets selected values without opening the dropdown',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as web.HTMLButtonElement;
    final clearButton =
        fixture.rootElement.querySelector('.dropdown-clear') as web.Element;

    expect(trigger.getAttribute('aria-expanded'), 'false');

    await fixture.update((_) {
      clearButton.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.selectedChannels, isEmpty);
    expect(trigger.getAttribute('aria-expanded'), 'false');
    expect(fixture.rootElement.querySelector('.dropdown-clear'), isNull);
  });

  test('opens overlay aligned directly below the trigger', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as web.HTMLButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    final panel = web.document.querySelector(
      '.dropdown-container.dropdown-open',
    ) as web.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect((panelRect.left - triggerRect.left).abs(), lessThanOrEqualTo(1.5));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));
  });

  test('keeps dark theme styling delegated to dropdown-menu classes', () async {
    web.document.documentElement?.setAttribute('data-color-theme', 'dark');

    final fixture = await testBed.create();
    await _settle(fixture);
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as web.HTMLButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    final panel = web.document.querySelector(
      '.dropdown-container.dropdown-open',
    ) as web.Element;

    expect(panel.classList.contains('dropdown-menu'), isTrue);
    expect((panel as web.HTMLElement).style.backgroundColor, isEmpty);
    expect(panel.style.boxShadow, isEmpty);
    expect(panel.style.borderColor, isEmpty);
  });

  test('matches object values with compareWith', () async {
    final fixture = await compareTestBed.create();
    await _settleCompare(fixture);

    expect(
        fixture.rootElement.querySelectorAll('.badge').toElementList().length,
        1);
    expect(fixture.rootElement.textContent, contains('Push'));
  });

  test('applies declarative validation rules on selection changes', () async {
    final fixture = await validationTestBed.create();
    await _settleValidation(fixture);
    final host = fixture.assertOnlyInstance;
    final field =
        fixture.rootElement.querySelector('#validation-multi-select-field')!;
    final trigger =
        field.querySelector('.dropdown-button') as web.HTMLButtonElement;
    final clearButton = field.querySelector('.dropdown-clear') as web.Element;

    await fixture.update((_) {
      clearButton.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settleValidation(fixture);

    expect(host.selectedChannels, isEmpty);
    expect(trigger.classList.contains('is-invalid'), isTrue);
    expect(fixture.rootElement.textContent,
        contains('Selecione ao menos 2 canais.'));

    await fixture.update((_) {
      trigger.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settleValidation(fixture);

    final options = web.document
        .querySelectorAll('.dropdown-container.dropdown-open .dropdown-item')
        .toElementList()
        .cast<web.Element>()
        .toList(growable: false);
    final emailOption = options.firstWhere(
      (element) => ((element.textContent ?? '')).contains('E-mail'),
    );
    final pushOption = options.firstWhere(
      (element) => ((element.textContent ?? '')).contains('Push'),
    );

    await fixture.update((_) {
      emailOption.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
      pushOption.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settleValidation(fixture);

    expect(host.selectedChannels, containsAll(<String>['email', 'push']));
    expect(trigger.classList.contains('is-invalid'), isFalse);
  });
}

Future<void> _settle(
    NgTestFixture<MultiSelectTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleCompare(
    NgTestFixture<MultiSelectCompareTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleValidation(
    NgTestFixture<MultiSelectValidationTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
