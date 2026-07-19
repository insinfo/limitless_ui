// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/rating/li_rating_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/web_compat.dart' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_rating_component_test.template.dart' as ng;

@Component(
  selector: 'rating-test-host',
  template: '''
    <li-rating
        [(ngModel)]="score"
        (userValueChange)="userScore = \$event"
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
  num? userScore;
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
    final buttons = fixture.rootElement.queryAll('li-rating button');
    final fourthStar = buttons[3] as html.ButtonElement;

    expect(host.userScore, isNull);

    await fixture.update((_) {
      fourthStar.dispatchEvent(html.liMouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.score, 4);
    expect(host.userScore, 4);

    await fixture.update((_) {
      fourthStar.dispatchEvent(html.liMouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.score, 0);
    expect(host.userScore, 0);
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
  final event = html.liKeyboardEvent('keydown', key: key);
  element.dispatchEvent(event);
}
