// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/page_header/li_page_header_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import '../support/web_node_list.dart';

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
    final headers = root.querySelectorAll('.page-header').toElementList();
    final firstHeader = headers.first;

    expect(firstHeader.textContent, contains('Protocolo -'));
    expect(firstHeader.textContent, contains('Incluir Processo'));

    final breadcrumb = firstHeader.querySelector('.breadcrumb');
    expect(breadcrumb, isNotNull);
    expect(breadcrumb!.classList.contains('breadcrumb-dash'), isTrue);
    expect(firstHeader.querySelector('#header-actions'), isNotNull);
    expect(
      firstHeader.querySelectorAll('.breadcrumb-item').toElementList().length,
      greaterThanOrEqualTo(3),
    );
  });

  test('renders projected bottom content instead of auto breadcrumb row',
      () async {
    final fixture = await testBed.create();
    final root = fixture.rootElement;
    final secondHeader =
        root.querySelectorAll('.page-header').toElementList().last;

    expect(secondHeader.querySelector('#custom-bottom'), isNotNull);
    expect(secondHeader.querySelector('#custom-bottom')!.textContent,
        contains('Abas customizadas'));
    expect(
        secondHeader.querySelectorAll('.li-breadcrumb').toElementList().length,
        0);
  });
}
