// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/scrollspy/li_scrollspy_directive_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_scrollspy_directive_test.template.dart' as ng;

@Component(
  selector: 'scrollspy-test-host',
  template: '''
    <div style="display:grid;grid-template-columns:12rem 1fr;gap:1rem;">
      <nav style="display:flex;flex-direction:column;gap:.5rem;" [liScrollSpyMenu]="spy">
        <button id="item-overview" type="button" liScrollSpyItem="overview">Overview</button>
        <button id="item-service" type="button" liScrollSpyItem="service">Service</button>
        <button id="item-directive" type="button" liScrollSpyItem="directive">Directive</button>
        <div style="padding-left:1rem;display:flex;flex-direction:column;gap:.5rem;">
          <button id="item-items" type="button" [liScrollSpyItem]="spy" fragment="items" parent="directive">Items</button>
          <button id="item-customization" type="button" [liScrollSpyItem]="spy" fragment="customization" parent="directive">Customization</button>
        </div>
      </nav>

      <div
          id="spy-container"
          style="height:140px;overflow-y:auto;"
          liScrollSpy
          #spy="liScrollSpy"
          scrollBehavior="auto"
          (activeChange)="activeLog.add(\$event)">
        <section id="fragment-overview" style="height:110px;margin-bottom:80px;" liScrollSpyFragment="overview">Overview</section>
        <section id="fragment-service" style="height:110px;margin-bottom:80px;" liScrollSpyFragment="service">Service</section>
        <section id="fragment-directive" style="height:110px;margin-bottom:80px;" liScrollSpyFragment="directive">Directive</section>
        <section id="fragment-items" style="height:110px;margin-bottom:80px;" liScrollSpyFragment="items">Items</section>
        <section id="fragment-customization" style="height:110px;margin-bottom:80px;" liScrollSpyFragment="customization">Customization</section>
      </div>
    </div>
  ''',
  directives: [
    coreDirectives,
    LiScrollSpyDirective,
    LiScrollSpyFragmentDirective,
    LiScrollSpyItemDirective,
    LiScrollSpyMenuDirective,
  ],
)
class ScrollspyTestHostComponent {
  @ViewChild('spy')
  LiScrollSpyDirective? spy;

  final List<String> activeLog = <String>[];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<ScrollspyTestHostComponent>(
    ng.ScrollspyTestHostComponentNgFactory,
  );

  test('activates the first visible fragment on startup', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.spy, isNotNull);
    expect(host.spy!.active, 'overview');
    expect(
        fixture.rootElement
            .querySelector('#item-overview')!
            .classes
            .contains('active'),
        isTrue);
  });

  test('updates active fragment when the container scrolls', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final container = fixture.rootElement.querySelector('#spy-container');
    final serviceFragment = fixture.rootElement.querySelector('#service');

    expect(container, isNotNull);
    expect(serviceFragment, isNotNull);

    await fixture.update((_) {
      (container as html.Element).scrollTop =
          serviceFragment!.offsetTop - container.offsetTop;
      container.dispatchEvent(html.Event('scroll'));
    });
    await _settle(fixture);

    expect(host.spy!.active, 'service');
    expect(
        fixture.rootElement
            .querySelector('#item-service')!
            .classes
            .contains('active'),
        isTrue);
  });

  test('keeps the whole menu branch active for nested items', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final customizationItem =
        fixture.rootElement.querySelector('#item-customization');

    expect(customizationItem, isNotNull);

    await fixture.update((_) {
      customizationItem!
          .dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.spy!.active, 'customization');
    expect(
        fixture.rootElement
            .querySelector('#item-customization')!
            .classes
            .contains('active'),
        isTrue);
    expect(
        fixture.rootElement
            .querySelector('#item-directive')!
            .classes
            .contains('active'),
        isTrue);
  });
}

Future<void> _settle(NgTestFixture<ScrollspyTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
