// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/pagination/li_pagination_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_pagination_component_test.template.dart' as ng;

@Component(
  selector: 'pagination-test-host',
  template: '''
    <div id="basic-wrapper">
      <li-pagination
        [collectionSize]="96"
        [pageSize]="10"
        [page]="page"
        [maxSize]="5"
        [boundaryLinks]="true"
        (pageChange)="onPageChange(
          \$event,
        )">
      </li-pagination>
    </div>

    <div id="template-wrapper">
      <li-pagination
        [collectionSize]="70"
        [pageSize]="10"
        [page]="templatePage"
        [maxSize]="5"
        (pageChange)="templatePage = \$event">
        <template liPaginationNumber let-page let-currentPage="currentPage">
          <span
            class="custom-page"
            [attr.data-page]="page.toString()"
            [class.fw-bold]="page == currentPage">
            Pg {{ page }}
          </span>
        </template>
      </li-pagination>
    </div>

    <div id="disabled-wrapper">
      <li-pagination
        [collectionSize]="40"
        [pageSize]="10"
        [page]="disabledPage"
        [disabled]="true"
        (pageChange)="disabledPage = \$event">
      </li-pagination>
    </div>
  ''',
  directives: [coreDirectives, liPaginationDirectives],
)
class PaginationTestHostComponent {
  int page = 1;
  int templatePage = 2;
  int disabledPage = 2;
  int changeCount = 0;

  void onPageChange(int nextPage) {
    page = nextPage;
    changeCount += 1;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<PaginationTestHostComponent>(
    ng.PaginationTestHostComponentNgFactory,
  );

  test('renders ellipsis and updates the active page on click', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final wrapper = fixture.rootElement.querySelector('#basic-wrapper');

    expect(wrapper, isNotNull);
    expect(wrapper!.text, contains('...'));
    expect(wrapper.text, contains('10'));

    final fourthPageLink = _findLinkByText(wrapper, '4');
    expect(fourthPageLink, isNotNull);

    await fixture.update((_) {
      fourthPageLink!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.page, 4);
    expect(host.changeCount, 1);
    final activeItem = wrapper.querySelector('.page-item.active');
    expect(activeItem, isNotNull);
    expect(activeItem!.text, contains('4'));
  });

  test('renders the custom number template with current page context',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final wrapper = fixture.rootElement.querySelector('#template-wrapper');

    expect(wrapper, isNotNull);
    final customPage = wrapper!.querySelector('.custom-page[data-page="2"]');
    expect(customPage, isNotNull);
    expect(customPage!.text, contains('Pg 2'));
    expect(customPage.classes.contains('fw-bold'), isTrue);
  });

  test('does not emit changes while disabled', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final wrapper = fixture.rootElement.querySelector('#disabled-wrapper');

    final thirdPageLink = _findLinkByText(wrapper!, '3');
    expect(thirdPageLink, isNotNull);

    await fixture.update((_) {
      thirdPageLink!.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.disabledPage, 2);
  });
}

Future<void> _settle(NgTestFixture<PaginationTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

html.AnchorElement? _findLinkByText(html.Element root, String text) {
  for (final element in root.querySelectorAll('a.page-link')) {
    if ((element.text ?? '').trim() == text) {
      return element as html.AnchorElement;
    }
  }
  return null;
}
