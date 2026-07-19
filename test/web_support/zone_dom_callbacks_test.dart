@TestOn('browser')
library;

import 'dart:async';

import 'package:limitless_ui/src/web_support/zone_dom_callbacks.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  test('animation frames retain the scheduling Zone', () async {
    final zoneKey = Object();
    final callbackZoneValue = Completer<Object?>();

    Zone.current
        .fork(zoneValues: <Object?, Object?>{zoneKey: 'origin'}).run(() {
      requestAnimationFrameInZone((_) {
        callbackZoneValue.complete(Zone.current[zoneKey]);
      });
    });

    expect(
      await callbackZoneValue.future.timeout(const Duration(seconds: 2)),
      'origin',
    );
  });

  test('mutation observers retain their creation Zone', () async {
    final zoneKey = Object();
    final callbackZoneValue = Completer<Object?>();
    final element = web.HTMLDivElement();
    ZoneMutationObserver? observer;

    try {
      Zone.current
          .fork(zoneValues: <Object?, Object?>{zoneKey: 'origin'}).run(() {
        observer = ZoneMutationObserver((records, _) {
          callbackZoneValue.complete(Zone.current[zoneKey]);
        })
          ..observe(element, attributes: true);
        element.setAttribute('data-zone-probe', 'changed');
      });

      expect(
        await callbackZoneValue.future.timeout(const Duration(seconds: 2)),
        'origin',
      );
    } finally {
      observer?.disconnect();
    }
  });
}
