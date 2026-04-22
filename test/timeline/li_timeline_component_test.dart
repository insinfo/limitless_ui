// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/timeline/li_timeline_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_timeline_component_test.template.dart' as ng;

@Component(
  selector: 'timeline-test-host',
  template: '''
    <li-timeline mode="center">
      <li-timeline-date>Hoje</li-timeline-date>

      <li-timeline-item
          alignment="start"
          timeLabel="08:30"
          title="Kickoff"
          description="Inicio do fluxo"
          iconText="A">
      </li-timeline-item>

      <li-timeline-item alignment="end">
        <span liTimelineTime>10:15</span>
        <div liTimelineIcon class="custom-icon">B</div>
        <div liTimelineContent class="custom-card">Conteudo customizado</div>
      </li-timeline-item>
    </li-timeline>

    <li-timeline mode="right">
      <li-timeline-item title="Right side" iconClass="ph ph-arrow-right"></li-timeline-item>
    </li-timeline>
  ''',
  directives: [coreDirectives, liTimelineDirectives],
)
class TimelineTestHostComponent {}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TimelineTestHostComponent>(
    ng.TimelineTestHostComponentNgFactory,
  );

  test('renders center and right timeline mode classes', () async {
    final fixture = await testBed.create();
    final timelines = fixture.rootElement.querySelectorAll('li-timeline');

    expect(timelines[0].classes.contains('timeline-center'), isTrue);
    expect(timelines[1].classes.contains('timeline-end'), isTrue);
  });

  test('applies row alignment classes in center mode', () async {
    final fixture = await testBed.create();
    final items = fixture.rootElement.querySelectorAll('li-timeline-item');

    expect(items[0].classes.contains('timeline-row-start'), isTrue);
    expect(items[1].classes.contains('timeline-row-end'), isTrue);
  });

  test('renders projected icon, time and content slots', () async {
    final fixture = await testBed.create();
    final projectedItem = fixture.rootElement.querySelectorAll('li-timeline-item')[1];

    expect(projectedItem.querySelector('.custom-icon')?.text?.trim(), 'B');
    expect(projectedItem.querySelector('.timeline-time')?.text?.trim(), '10:15');
    expect(projectedItem.querySelector('.custom-card')?.text?.trim(),
        'Conteudo customizado');
  });
}