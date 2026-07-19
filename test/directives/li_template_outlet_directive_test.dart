// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/directives/li_template_outlet_directive_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/web_compat.dart' as html;
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_template_outlet_directive_test.template.dart' as ng;

@Component(
  selector: 'li-template-outlet-test-host',
  template: '''
    <div id="context-host">
      <template #contextTemplate let-label="label" let-count="count">
        <span id="context-value">{{ label }}:{{ count }}</span>
      </template>

      <template
        [liTemplateOutlet]="contextTemplate"
        [liTemplateOutletContext]="context">
      </template>
    </div>

    <div id="implicit-host">
      <template #implicitTemplate let-value>
        <span id="implicit-value">{{ value }}</span>
      </template>

      <template
        [liTemplateOutlet]="implicitTemplate"
        [liTemplateOutletValue]="implicitValue">
      </template>
    </div>
  ''',
  directives: [coreDirectives, LiTemplateOutletDirective],
)
class LiTemplateOutletTestHostComponent {
  Map<String, Object?> context = <String, Object?>{
    'label': 'Alpha',
    'count': 1,
  };

  String implicitValue = 'Inicial';
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<LiTemplateOutletTestHostComponent>(
    ng.LiTemplateOutletTestHostComponentNgFactory,
  );

  test('renders named context locals and refreshes mutated context values',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    expect(_text(fixture, '#context-value'), 'Alpha:1');

    await fixture.update((component) {
      component.context['label'] = 'Beta';
      component.context['count'] = 2;
    });
    await _settle(fixture);

    expect(_text(fixture, '#context-value'), 'Beta:2');
  });

  test('renders implicit value shorthand and refreshes on input changes',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    expect(_text(fixture, '#implicit-value'), 'Inicial');

    await fixture.update((component) {
      component.implicitValue = 'Atualizado';
    });
    await _settle(fixture);

    expect(_text(fixture, '#implicit-value'), 'Atualizado');
  });
}

String _text(
  NgTestFixture<LiTemplateOutletTestHostComponent> fixture,
  String selector,
) {
  final element = fixture.rootElement.querySelector(selector);
  return element?.text.trim() ?? '';
}

Future<void> _settle(
  NgTestFixture<LiTemplateOutletTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}
