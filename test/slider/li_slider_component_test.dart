// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/slider/li_slider_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/web_compat.dart' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_slider_component_test.template.dart' as ng;

@Component(
  selector: 'slider-test-host',
  template: '''
    <div style="width: 320px; padding: 24px;">
      <li-slider
          [(ngModel)]="singleValue"
          [min]="0"
          [max]="100"
          [step]="10">
      </li-slider>

      <li-slider
          connect="range"
          [range]="true"
          [(rangeValues)]="rangeValue"
          [min]="0"
          [max]="100"
          [step]="10"
          [showTooltip]="true"
          [showPips]="true"
          [pipCount]="4"
          variant="success"
          handleStyle="solid">
      </li-slider>

          <li-slider
            connect="upper"
            [value]="upperValue"
            [min]="0"
            [max]="100"
            [step]="10">
          </li-slider>

          <li-slider
            connect="none"
            [value]="customPipsValue"
            [min]="0"
            [max]="100"
            [customPips]="customPips"
            [showTooltip]="true">
          </li-slider>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiSliderComponent,
  ],
)
class SliderTestHostComponent {
  num singleValue = 40;
  List<num> rangeValue = <num>[20, 80];
  num upperValue = 30;
  num customPipsValue = 50;

  final List<LiSliderPip> customPips = const <LiSliderPip>[
    LiSliderPip(value: 0, label: 'Start', large: true),
    LiSliderPip(value: 40, label: 'Alpha'),
    LiSliderPip(value: 70, label: 'Beta', large: true),
    LiSliderPip(value: 100, label: 'Live', large: true),
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<SliderTestHostComponent>(
    ng.SliderTestHostComponentNgFactory,
  );

  test('keyboard updates a single slider bound with ngModel', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final sliders = fixture.rootElement.queryAll('li-slider');
    final handle = sliders.first.querySelector('.noUi-handle') as html.Element;

    await fixture.update((_) {
      handle.focus();
      _dispatchKey(handle, 'ArrowRight');
    });
    await _settle(fixture);

    expect(host.singleValue, 50);

    await fixture.update((_) {
      _dispatchKey(handle, 'End');
    });
    await _settle(fixture);

    expect(host.singleValue, 100);
  });

  test('range slider updates upper handle and renders tooltip and pips',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final sliders = fixture.rootElement.queryAll('li-slider');
    final rangeSlider = sliders[1];
    final handles = rangeSlider.queryAll('.noUi-handle');
    final upperHandle = handles[1];

    expect(rangeSlider.queryAll('.noUi-tooltip').length, 2);
    expect(rangeSlider.queryAll('.noUi-value').length, 4);

    await fixture.update((_) {
      upperHandle.focus();
      _dispatchKey(upperHandle, 'ArrowLeft');
    });
    await _settle(fixture);

    expect(host.rangeValue, orderedEquals(<num>[20, 70]));
  });

  test('connect upper renders the connector from handle to the end', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final sliders = fixture.rootElement.queryAll('li-slider');
    final upperSlider = sliders[2];
    final connect = upperSlider.querySelector('.noUi-connect') as html.Element;
    final style = connect.getAttribute('style') ?? '';

    expect(style, contains('left: 30.0000%'));
    expect(style, contains('width: 70.0000%'));
  });

  test('custom pips render explicit labels and connect none hides the bar',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final sliders = fixture.rootElement.queryAll('li-slider');
    final customPipsSlider = sliders[3];
    final labels = customPipsSlider
        .queryAll('.noUi-value')
        .map((element) => element.text.trim())
        .toList();

    expect(labels, orderedEquals(<String>['Start', 'Alpha', 'Beta', 'Live']));
    expect(customPipsSlider.querySelector('.noUi-connect'), isNull);
  });

  test('active handle class stays applied during drag and clears on mouse up',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final slider = fixture.rootElement.querySelector('li-slider')!;
    final handle = slider.querySelector('.noUi-handle') as html.Element;

    await fixture.update((_) {
      _dispatchMouse(handle, 'mousedown');
    });
    await _settle(fixture);

    expect(handle.classes.contains('li-slider__handle--active'), isTrue);

    await fixture.update((_) {
      _dispatchMouse(html.document.body!, 'mouseup');
    });
    await _settle(fixture);

    expect(handle.classes.contains('li-slider__handle--active'), isFalse);
  });
}

Future<void> _settle(
  NgTestFixture<SliderTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

void _dispatchKey(html.Element element, String key) {
  final event = html.liKeyboardEvent('keydown', key: key);
  element.dispatchEvent(event);
}

void _dispatchMouse(html.Element element, String type) {
  final event = html.liMouseEvent(type, clientX: 120, clientY: 20);
  element.dispatchEvent(event);
}
