import 'dart:math' as math;

import 'pagination_item.dart';

class DatatablePaginationHelper {
  static int syncCurrentPageFromOffset({
    required int? limit,
    required int? offset,
  }) {
    final resolvedLimit = limit ?? 1;
    final resolvedOffset = offset ?? 0;
    if (resolvedLimit <= 0) {
      return 1;
    }

    final currentPage = (resolvedOffset ~/ resolvedLimit) + 1;
    return currentPage <= 0 ? 1 : currentPage;
  }

  static List<PaginationItem> buildPaginationItems({
    required int totalRecords,
    required int? limit,
    required int currentPage,
    required int buttonQuantity,
    required PaginationType paginationType,
    required void Function() onPrev,
    required void Function() onNext,
    required void Function(int page) onPageSelected,
  }) {
    final resolvedLimit = limit ?? 0;
    if (resolvedLimit <= 0 || totalRecords < resolvedLimit) {
      return <PaginationItem>[];
    }

    final totalPages = (totalRecords / resolvedLimit).ceil();
    final visibleButtonQuantity =
        buttonQuantity > totalPages ? totalPages : buttonQuantity;
    if (visibleButtonQuantity <= 1) {
      return <PaginationItem>[];
    }

    final items = <PaginationItem>[];

    final previousButton = PaginationItem(
      cssClasses: <String>['paginate_button', 'page-item', 'previous'],
      label: '←',
      paginationButtonType: PaginationButtonType.prev,
      action: onPrev,
    );
    if (currentPage == 1) {
      previousButton.removeClass('disabled');
      previousButton.addClass('disabled');
    }
    items.add(previousButton);

    final nextButton = PaginationItem(
      cssClasses: <String>['paginate_button', 'page-item', 'next'],
      label: '→',
      paginationButtonType: PaginationButtonType.next,
      action: onNext,
    );
    if (currentPage == totalPages) {
      nextButton.removeClass('disabled');
      nextButton.addClass('disabled');
    }

    var idx = 0;
    var loopEnd = 0;

    switch (paginationType) {
      case PaginationType.carousel:
        idx = currentPage - (visibleButtonQuantity ~/ 2);
        if (idx <= 0) {
          idx = 1;
        }
        loopEnd = idx + visibleButtonQuantity;
        if (loopEnd > totalPages + 1) {
          loopEnd = totalPages + 1;
          idx = math.max(1, loopEnd - visibleButtonQuantity);
        }

        while (idx < loopEnd) {
          final button = PaginationItem(
            action: () {},
            cssClasses: <String>[
              'paginate_button',
              'page-item',
              if (idx == currentPage) 'active',
            ],
            label: idx.toString(),
          );
          button.action = () => onPageSelected(int.parse(button.label));
          items.add(button);
          idx++;
        }
        break;
      case PaginationType.cube:
        final facePosition = (currentPage % visibleButtonQuantity) == 0
            ? visibleButtonQuantity
            : currentPage % visibleButtonQuantity;
        loopEnd = visibleButtonQuantity - facePosition + currentPage;
        idx = currentPage - facePosition;
        while (idx < loopEnd) {
          idx++;
          if (idx <= totalPages) {
            final button = PaginationItem(
              action: () {},
              cssClasses: <String>[
                'paginate_button',
                'page-item',
                if (idx == currentPage) 'active',
              ],
              label: idx.toString(),
            );
            button.action = () => onPageSelected(int.parse(button.label));
            items.add(button);
          }
        }
        break;
    }

    items.add(nextButton);
    return items;
  }
}
