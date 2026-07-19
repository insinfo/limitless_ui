@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:limitless_ui/web_compat.dart' as html;
import 'package:test/test.dart';

void main() {
  test('liBlob preserves binary List<int> parts', () async {
    final blob = html.liBlob(
      <Object>[
        <int>[0, 1, 127, 128, 255],
      ],
      'application/octet-stream',
    );

    final buffer = (await blob.arrayBuffer().toDart).toDart;

    expect(buffer.asUint8List(), <int>[0, 1, 127, 128, 255]);
    expect(blob.size, 5);
    expect(blob.type, 'application/octet-stream');
  });

  test('HTML writes sanitize by default and require an explicit bypass', () {
    final element = html.createDivElement();

    element.innerHtml = '''
      <img src="x" onerror="window.__unsafe = true">
      <script>window.__unsafe = true</script>
      <b>safe text</b>
    ''';

    expect(element.querySelector('script'), isNull);
    expect(element.querySelector('img')?.hasAttribute('onerror'), isFalse);
    expect(element.text, contains('safe text'));

    element.setInnerHtml(
      '<span onclick="window.__trusted = true">trusted</span>',
      treeSanitizer: html.NodeTreeSanitizer.trusted,
    );

    expect(element.querySelector('span')?.hasAttribute('onclick'), isTrue);
  });

  test('liElementOrNull rejects ordinary Dart objects safely', () {
    final element = html.createDivElement();

    expect(html.liElementOrNull(element), equals(element));
    expect(html.liElementOrNull(Object()), isNull);
    expect(html.liElementOrNull(<String, Object?>{}), isNull);
    expect(html.liElementOrNull(null), isNull);
  });

  test('liFileOrNull accepts files and rejects other values safely', () {
    final file = html.liFile(<Object>['contents'], 'example.txt');
    final blob = html.liBlob(<Object>['contents']);

    expect(html.liFileOrNull(file), equals(file));
    expect(html.liFileOrNull(blob), isNull);
    expect(html.liFileOrNull(Object()), isNull);
    expect(html.liFileOrNull(<String, Object?>{}), isNull);
    expect(html.liFileOrNull(null), isNull);
  });

  test('classes remains a live Set<String>', () {
    final element = html.createDivElement()..classes.addAll(<String>['a', 'b']);
    final classes = element.classes;

    expect(classes, containsAll(<String>['a', 'b']));

    element.classList.add('c');
    expect(classes, contains('c'));
    expect(classes.toSet(), <String>{'a', 'b', 'c'});
  });

  test('event factories preserve dart:html constructor defaults', () {
    final event = html.liEvent('compat-event');
    final mouseEvent = html.liMouseEvent('compat-mouse');
    final keyboardEvent = html.liKeyboardEvent('compat-keyboard');

    expect(event.bubbles, isTrue);
    expect(event.cancelable, isTrue);
    expect(event.composed, isFalse);
    expect(mouseEvent.view == html.window, isTrue);
    expect(mouseEvent.composed, isFalse);
    expect(keyboardEvent.view == html.window, isTrue);
    expect(keyboardEvent.location, 1);
    expect(keyboardEvent.composed, isFalse);
  });

  test('liRequestAnimationFrame preserves the scheduling zone', () async {
    final zoneKey = Object();
    final callbackZoneValue = Completer<Object?>();

    Zone.current
        .fork(zoneValues: <Object?, Object?>{zoneKey: 'origin'}).run(() {
      html.window.liRequestAnimationFrame((_) {
        callbackZoneValue.complete(Zone.current[zoneKey]);
      });
    });

    expect(
      await callbackZoneValue.future.timeout(const Duration(seconds: 2)),
      'origin',
    );
  });

  test('MutationObserver preserves the Zone where it was created', () async {
    final zoneKey = Object();
    final callbackZoneValue = Completer<Object?>();
    final element = html.createDivElement();
    html.MutationObserver? observer;

    try {
      Zone.current
          .fork(zoneValues: <Object?, Object?>{zoneKey: 'origin'}).run(() {
        observer = html.MutationObserver((records, _) {
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
