// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/breadcrumbs/li_breadcrumb_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_breadcrumb_component_test.template.dart' as ng;

@Component(
  selector: 'breadcrumb-test-host',
  template: '''
    <li-breadcrumb
      helperText="Library"
      divider="dash"
      [wrap]="false"
      lineClass="line-demo"
      breadcrumbClass="crumb-demo">
      <span id="crumb-start" liBreadcrumbStart class="badge bg-primary">v2.0</span>
      <a id="crumb-home" liBreadcrumbItem href="#home">Home</a>
      <a id="crumb-components" liBreadcrumbItem href="#components">Components</a>
      <span id="crumb-current" liBreadcrumbItem [active]="true">Breadcrumbs</span>
      <button id="crumb-disabled" type="button" liBreadcrumbItem [disabled]="true">Archived</button>
      <div id="crumb-end" liBreadcrumbEnd class="btn-group">
        <button type="button">Publish</button>
      </div>
    </li-breadcrumb>
  ''',
  directives: [coreDirectives, liBreadcrumbDirectives],
)
class BreadcrumbTestHostComponent {}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<BreadcrumbTestHostComponent>(
    ng.BreadcrumbTestHostComponentNgFactory,
  );

  test('renders helper text, slots and divider classes', () async {
    final fixture = await testBed.create();
    final root = fixture.rootElement;

    final shell = root.querySelector('.li-breadcrumb-line');
    final breadcrumb = root.querySelector('.li-breadcrumb .breadcrumb');

    expect(shell, isNotNull);
    expect(shell!.classes.contains('li-breadcrumb-nowrap'), isTrue);
    expect(shell.classes.contains('line-demo'), isTrue);

    expect(breadcrumb, isNotNull);
    expect(breadcrumb!.classes.contains('breadcrumb-dash'), isTrue);
    expect(breadcrumb.classes.contains('crumb-demo'), isTrue);
    expect(breadcrumb.text, contains('Library'));

    expect(root.querySelector('#crumb-start'), isNotNull);
    expect(root.querySelector('#crumb-end'), isNotNull);
  });

  test('applies active and disabled semantics on breadcrumb items', () async {
    final fixture = await testBed.create();
    final root = fixture.rootElement;

    final current = root.querySelector('#crumb-current');
    final disabled = root.querySelector('#crumb-disabled');

    expect(current, isNotNull);
    expect(current!.classes.contains('breadcrumb-item'), isTrue);
    expect(current.classes.contains('active'), isTrue);
    expect(current.getAttribute('aria-current'), 'page');

    expect(disabled, isNotNull);
    expect(disabled!.classes.contains('breadcrumb-item'), isTrue);
    expect(disabled.classes.contains('disabled'), isTrue);
    expect(disabled.getAttribute('aria-disabled'), 'true');
    expect(disabled.getAttribute('tabindex'), '-1');
  });
}
