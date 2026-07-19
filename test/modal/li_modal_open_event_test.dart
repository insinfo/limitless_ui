// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/modal/li_modal_open_event_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/web_compat.dart' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_modal_open_event_test.template.dart' as ng;

@Component(
  selector: 'li-modal-open-event-test-host',
  template: '''
    <li-modal #modal
        title-text="Lazy"
        [lazyContent]="true"
        (open)="events.add('open')"
        (close)="events.add('close')">
      <div id="lazy-body">Lazy body</div>
    </li-modal>

    <li-modal #startOpenModal
        title-text="Start open"
        [start-open]="true"
        (open)="startOpenEvents.add('open')">
      <div id="start-open-body">Start open body</div>
    </li-modal>
  ''',
  directives: [coreDirectives, LiModalComponent],
)
class ModalOpenEventHostComponent {
  @ViewChild('modal')
  LiModalComponent? modal;

  @ViewChild('startOpenModal')
  LiModalComponent? startOpenModal;

  final List<String> events = <String>[];
  final List<String> startOpenEvents = <String>[];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<ModalOpenEventHostComponent>(
    ng.ModalOpenEventHostComponentNgFactory,
  );

  test('emits open on open and close on close', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.modal!.open());
    expect(host.events, <String>['open']);

    await fixture.update((_) => host.modal!.close());
    expect(host.events, <String>['open', 'close']);
  });

  test('emits only on real transitions', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) => host.modal!.open());
    await fixture.update((_) => host.modal!.open());
    expect(host.events, <String>['open']);

    await fixture.update((_) => host.modal!.close());
    await fixture.update((_) => host.modal!.close());
    expect(host.events, <String>['open', 'close']);
  });

  test('open fires before lazyContent renders, so data can be loaded for it',
      () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    // The modal moves its root element to document.body on init, so the content
    // is queried from there rather than from the fixture root.
    // With lazyContent the body does not exist until the modal opens.
    expect(html.document.body!.querySelector('#lazy-body'), isNull);

    await fixture.update((_) => host.modal!.open());

    expect(host.events, <String>['open']);
    expect(html.document.body!.querySelector('#lazy-body'), isNotNull);
  });

  test('a start-open modal still reports its open', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;

    // start-open defers open() to a microtask, so the binding is subscribed by
    // the time it runs.
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await fixture.update((_) {});

    expect(host.startOpenEvents, <String>['open']);
    expect(host.startOpenModal!.isOpen, isTrue);
  });
}
