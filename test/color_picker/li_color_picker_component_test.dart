// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/color_picker/li_color_picker_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_color_picker_component_test.template.dart' as ng;

@Component(
  selector: 'li-color-picker-test-host',
  template: '''
    <li-color-picker
        #picker
        [value]="value"
        (valueChange)="value = \$event">
    </li-color-picker>
  ''',
  directives: [coreDirectives, LiColorPickerComponent],
)
class ColorPickerTestHostComponent {
  @ViewChild('picker')
  LiColorPickerComponent? picker;

  String? value = '#20bf7e';
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<ColorPickerTestHostComponent>(
    ng.ColorPickerTestHostComponentNgFactory,
  );

  test('opens overlay aligned directly below the trigger', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement.querySelector(
      '.color-picker-trigger .sp-replacer',
    ) as html.Element;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final panel = html.document.querySelector(
      '.sp-container:not(.sp-hidden)',
    ) as html.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect((panelRect.left - triggerRect.left).abs(), lessThanOrEqualTo(1.5));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));
  });
}

Future<void> _settle(
  NgTestFixture<ColorPickerTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
