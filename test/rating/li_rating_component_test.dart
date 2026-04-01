// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/rating/li_rating_component_test.dart
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

import 'li_rating_component_test.template.dart' as ng;

@Component(
  selector: 'rating-test-host',
  template: '''
    <li-rating
        [(ngModel)]="score"
        [resettable]="true"
        [max]="5">
    </li-rating>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiRatingComponent,
  ],
)
class RatingTestHostComponent {
  num score = 2;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<RatingTestHostComponent>(
    ng.RatingTestHostComponentNgFactory,
  );

  test('click selects and resets the chosen rating', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final buttons = fixture.rootElement.querySelectorAll('li-rating button');
    final fourthStar = buttons[3] as html.ButtonElement;

    await fixture.update((_) {
      fourthStar.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.score, 4);

    await fixture.update((_) {
      fourthStar.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.score, 0);
  });

  test('keyboard arrows update the rating value', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final root = fixture.rootElement.querySelector('li-rating .li-rating')
        as html.DivElement;

    await fixture.update((_) {
      root.focus();
      _dispatchKey(root, 'ArrowRight');
    });
    await _settle(fixture);

    expect(host.score, 3);

    await fixture.update((_) {
      _dispatchKey(root, 'Home');
    });
    await _settle(fixture);

    expect(host.score, 0);
  });
}

Future<void> _settle(
  NgTestFixture<RatingTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
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
