// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/page_header/li_page_header_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_page_header_component_test.template.dart' as ng;

@Component(
  selector: 'li-page-header-test-host',
  template: '''
    <li-pg-header
      titlePrefix="Protocolo"
      title="Incluir Processo"
      breadcrumbDivider="dash"
      [breadcrumbItems]="items">
      <div liPgHeaderActions id="header-actions">
        <button type="button" class="btn btn-primary">Salvar</button>
      </div>
    </li-pg-header>

    <li-pg-header title="Visualiza Processo">
      <div liPgHeaderBottom id="custom-bottom" class="w-100">
        <div class="nav nav-tabs">Abas customizadas</div>
      </div>
    </li-pg-header>
  ''',
  directives: [coreDirectives, liPageHeaderDirectives],
)
class PageHeaderTestHostComponent {
  final List<LiPageHeaderBreadcrumbItem> items =
      const <LiPageHeaderBreadcrumbItem>[
    LiPageHeaderBreadcrumbItem(label: 'Protocolo', href: '#protocolo'),
    LiPageHeaderBreadcrumbItem(label: 'Incluir Processo', active: true),
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<PageHeaderTestHostComponent>(
    ng.PageHeaderTestHostComponentNgFactory,
  );

  test('renders title, breadcrumb items and projected actions', () async {
    final fixture = await testBed.create();
    final root = fixture.rootElement;
    final headers = root.querySelectorAll('.page-header');
    final firstHeader = headers.first;

    expect(firstHeader.text, contains('Protocolo -'));
    expect(firstHeader.text, contains('Incluir Processo'));

    final breadcrumb = firstHeader.querySelector('.breadcrumb');
    expect(breadcrumb, isNotNull);
    expect(breadcrumb!.classes.contains('breadcrumb-dash'), isTrue);
    expect(firstHeader.querySelector('#header-actions'), isNotNull);
    expect(
      firstHeader.querySelectorAll('.breadcrumb-item').length,
      greaterThanOrEqualTo(3),
    );
  });

  test('renders projected bottom content instead of auto breadcrumb row',
      () async {
    final fixture = await testBed.create();
    final root = fixture.rootElement;
    final secondHeader = root.querySelectorAll('.page-header').last;

    expect(secondHeader.querySelector('#custom-bottom'), isNotNull);
    expect(secondHeader.querySelector('#custom-bottom')!.text,
        contains('Abas customizadas'));
    expect(secondHeader.querySelectorAll('.li-breadcrumb').length, 0);
  });
}
