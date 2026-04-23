// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/directives/custom_href_directive_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'custom_href_directive_test.template.dart' as ng;

@Component(
  selector: 'custom-href-test-host',
  template: '''
    <a id="link" [customHref]="href">Detalhes</a>
  ''',
  directives: [coreDirectives, CustomHrefDirective],
)
class CustomHrefDirectiveTestHostComponent {
  String href = '/details/42';
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<CustomHrefDirectiveTestHostComponent>(
    ng.CustomHrefDirectiveTestHostComponentNgFactory,
  );

  test('aplica o href inicial vindo do binding', () async {
    final fixture = await testBed.create();
    final link =
        fixture.rootElement.querySelector('#link') as html.AnchorElement;

    expect(link.getAttribute('href'), '/details/42');
  });

  test('atualiza o href quando o host muda', () async {
    final fixture = await testBed.create();

    await fixture.update((component) {
      component.href = '/details/99';
    });

    final link =
        fixture.rootElement.querySelector('#link') as html.AnchorElement;
    expect(link.getAttribute('href'), '/details/99');
  });

  test('ignora o valor invalido e preserva o href anterior', () async {
    final fixture = await testBed.create();

    await fixture.update((component) {
      component.href = '#';
    });

    final link =
        fixture.rootElement.querySelector('#link') as html.AnchorElement;
    expect(link.getAttribute('href'), '/details/42');
  });
}
