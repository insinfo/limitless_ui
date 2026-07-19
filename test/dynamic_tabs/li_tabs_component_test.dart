// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/dynamic_tabs/li_tabs_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_tabs_component_test.template.dart' as ng;

@Component(
  selector: 'tabs-padding-test-host',
  template: '''
    <li-tabsx [contentPadding]="contentPadding">
      <li-tabx header="Overview" [active]="true">
        <div id="tab-body">Tab body</div>
      </li-tabx>
    </li-tabsx>
  ''',
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class TestHostComponent {
  bool contentPadding = true;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TestHostComponent>(ng.TestHostComponentNgFactory);

  test('tabs keep content padding by default and can disable it', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    html.Element? tabContent =
        fixture.rootElement.querySelector('.tab-content');
    expect(tabContent, isNotNull);
    expect(tabContent!.classes.contains('p-1'), isTrue);
    final tabs = fixture.rootElement.querySelector('li-tabsx');
    final navLink = fixture.rootElement.querySelector(
      '[data-label="li_tab_link"][data-value="0"]',
    );

    expect(tabs, isNotNull);
    expect(tabs!.getAttribute('data-label'), 'li_tab');
    expect(tabs.getAttribute('data-value'), '0');
    expect(
      fixture.rootElement.querySelector('[data-label="li_tab_nav"]'),
      isNotNull,
    );
    expect(navLink, isNotNull);
    expect(navLink!.getAttribute('data-active'), 'true');
    expect(
      fixture.rootElement.querySelector('[data-label="li_tab_content"]'),
      isNotNull,
    );
    expect(
      fixture.rootElement.querySelector('[data-label="li_tab_panel"]'),
      isNotNull,
    );

    await fixture.update((component) {
      component.contentPadding = false;
    });
    await _settle(fixture);

    tabContent = fixture.rootElement.querySelector('.tab-content');
    expect(tabContent, isNotNull);
    expect(tabContent!.classes.contains('p-1'), isFalse);
  });
}

Future<void> _settle(NgTestFixture<TestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}
