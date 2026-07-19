// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_form_control_name_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:limitless_ui/quill_text_editor.dart';
import 'package:limitless_ui/src/components/quill_text_editor/quill_text_editor_bridge.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import '../quill_text_editor/quill_test_fakes.dart';
import 'li_form_control_name_test.template.dart' as ng;

@Component(
  selector: 'li-form-control-name-host',
  template: '''
    <div>
      <div id="file-upload">
        <li-file-upload name="attachments" [showPreview]="false"></li-file-upload>
      </div>

      <div id="color-picker">
        <li-color-picker name="accent" [showInput]="true"></li-color-picker>
      </div>

      <div id="rating">
        <li-rating name="score"></li-rating>
      </div>

      <div id="slider">
        <li-slider name="progress"></li-slider>
      </div>

      <div id="token-field">
        <li-token-field name="tokens"></li-token-field>
      </div>

      <div id="raw-name-token-field">
        <li-token-field [name]="rawName"></li-token-field>
      </div>

      <div id="quill-editor">
        <li-quill-text-editor
            name="description"
            [toolbarVisible]="false">
        </li-quill-text-editor>
      </div>
    </div>
  ''',
  directives: [
    coreDirectives,
    LiFileUploadComponent,
    LiColorPickerComponent,
    LiRatingComponent,
    LiSliderComponent,
    LiTokenFieldComponent,
    liQuillTextEditorDirectives,
  ],
)
class FormControlNameHostComponent {
  String rawName = '  raw tokens  ';
}

void main() {
  tearDown(() {
    setLiQuillTextEditorBridgeForTesting(null);
    return disposeAnyRunningTest();
  });

  final testBed = NgTestBed<FormControlNameHostComponent>(
    ng.FormControlNameHostComponentNgFactory,
  );

  test('reflects name on additional interactive form controls', () async {
    setLiQuillTextEditorBridgeForTesting(FakeLiQuillTextEditorBridge());

    final fixture = await testBed.create();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await fixture.update((_) {});

    expect(
        _attr(fixture, '#file-upload input.file-input', 'name'), 'attachments');
    expect(
      _attr(fixture, '#file-upload input.file-caption-name', 'name'),
      'attachments',
    );
    expect(_attr(fixture, '#color-picker .sp-replacer', 'name'), 'accent');
    expect(_attr(fixture, '#color-picker .sp-input', 'name'), 'accent');
    expect(_attr(fixture, '#rating .li-rating', 'name'), 'score');
    expect(_attr(fixture, '#slider .li-slider__surface', 'name'), 'progress');
    expect(_attr(fixture, '#slider [role="slider"]', 'name'), 'progress');
    expect(_attr(fixture, '#token-field input', 'name'), 'tokens');
    expect(
      _attr(fixture, '#raw-name-token-field input', 'name'),
      '  raw tokens  ',
    );
    expect(
      _attr(fixture, '#quill-editor .li-quill-text-editor__editor', 'name'),
      'description',
    );
  });
}

String? _attr(
  NgTestFixture<FormControlNameHostComponent> fixture,
  String selector,
  String name,
) {
  final element = fixture.rootElement.querySelector(selector);
  expect(element, isNotNull, reason: 'Missing element: $selector');
  return element!.getAttribute(name);
}
