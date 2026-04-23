// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/carousel/li_carousel_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_carousel_component_test.template.dart' as ng;

@Component(
  selector: 'li-carousel-test-host',
  template: '''
    <li-carousel
        #carousel
        [id]="carouselId"
        [initialIndex]="initialIndex"
        [wrap]="wrap"
        [keyboardEnabled]="keyboardEnabled"
        previousLabel="Anterior"
        nextLabel="Proximo"
        (activeIndexChange)="lastActiveIndex = \$event">
      <li-carousel-item indicatorLabel="Primeiro slide">
        <div class="slide-body" id="slide-1">Primeiro</div>
      </li-carousel-item>
      <li-carousel-item>
        <div class="slide-body" id="slide-2">Segundo</div>
      </li-carousel-item>
      <li-carousel-item indicatorLabel="Terceiro slide">
        <div class="slide-body" id="slide-3">Terceiro</div>
      </li-carousel-item>
    </li-carousel>
  ''',
  directives: [
    coreDirectives,
    LiCarouselComponent,
    LiCarouselItemComponent,
  ],
)
class CarouselTestHostComponent {
  @ViewChild('carousel')
  LiCarouselComponent? carousel;

  String carouselId = 'hero-carousel';
  int initialIndex = 1;
  bool wrap = true;
  bool keyboardEnabled = true;
  int lastActiveIndex = -1;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<CarouselTestHostComponent>(
    ng.CarouselTestHostComponentNgFactory,
  );

  test('renders the requested initial slide and bootstrap target attributes',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final carousel = fixture.rootElement.querySelector('li-carousel');
    final indicators = fixture.rootElement.querySelectorAll(
      '.carousel-indicators button',
    );
    final nextControl = fixture.rootElement.querySelector(
      '.carousel-control-next',
    ) as html.ButtonElement?;

    expect(carousel, isNotNull);
    expect(carousel!.id, 'hero-carousel');
    expect(carousel.getAttribute('tabindex'), '0');
    expect(_activeSlideId(fixture), 'slide-2');
    expect(indicators, hasLength(3));
    expect(indicators[0].getAttribute('data-bs-target'), '#hero-carousel');
    expect(indicators[0].getAttribute('aria-label'), 'Primeiro slide');
    expect(indicators[1].getAttribute('aria-label'), 'Slide 2');
    expect(indicators[1].classes.contains('active'), isTrue);
    expect(indicators[1].getAttribute('aria-current'), 'true');
    expect(nextControl?.getAttribute('data-bs-slide'), 'next');
  });

  test('navigates with controls and emits the active index change', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final nextControl = fixture.rootElement.querySelector(
      '.carousel-control-next',
    ) as html.ButtonElement;

    await fixture.update((_) {
      nextControl.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settleTransition(fixture);

    expect(_activeSlideId(fixture), 'slide-3');
    expect(host.lastActiveIndex, 2);

    final previousControl = fixture.rootElement.querySelector(
      '.carousel-control-prev',
    ) as html.ButtonElement;

    await fixture.update((_) {
      previousControl.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settleTransition(fixture);

    expect(_activeSlideId(fixture), 'slide-2');
    expect(host.lastActiveIndex, 1);
  });

  test('responds to keyboard arrows when keyboard navigation is enabled',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final carousel = fixture.rootElement.querySelector('li-carousel')!;

    await fixture.update((_) {
      _dispatchKeyboardEvent(carousel, 'ArrowRight');
    });
    await _settleTransition(fixture);

    expect(_activeSlideId(fixture), 'slide-3');

    await fixture.update((_) {
      _dispatchKeyboardEvent(carousel, 'ArrowLeft');
    });
    await _settleTransition(fixture);

    expect(_activeSlideId(fixture), 'slide-2');
  });

  test('respects wrap=false at the carousel boundaries', () async {
    final fixture = await testBed.create();

    await fixture.update((host) {
      host.wrap = false;
      host.initialIndex = 0;
    });
    await _settle(fixture);

    final previousControl = fixture.rootElement.querySelector(
      '.carousel-control-prev',
    ) as html.ButtonElement;

    await fixture.update((_) {
      previousControl.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(_activeSlideId(fixture), 'slide-1');

    await fixture.update((host) {
      host.carousel?.goTo(2);
    });
    await _settleTransition(fixture);

    final nextControl = fixture.rootElement.querySelector(
      '.carousel-control-next',
    ) as html.ButtonElement;

    await fixture.update((_) {
      nextControl.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(_activeSlideId(fixture), 'slide-3');
  });
}

String? _activeSlideId(NgTestFixture<CarouselTestHostComponent> fixture) {
  return fixture.rootElement
      .querySelector('li-carousel-item.active .slide-body')
      ?.id;
}

Future<void> _settle(NgTestFixture<CarouselTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleTransition(
  NgTestFixture<CarouselTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 700));
  await fixture.update((_) {});
}

void _dispatchKeyboardEvent(html.Element target, String key) {
  final event = js_util.callConstructor(
    js_util.getProperty(html.window, 'KeyboardEvent'),
    <Object>[
      'keydown',
      js_util.jsify(<String, Object>{
        'key': key,
        'bubbles': true,
      }),
    ],
  ) as html.KeyboardEvent;
  target.dispatchEvent(event);
}
