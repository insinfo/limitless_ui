import 'dart:async';

import 'package:essential_core/essential_core.dart';

import 'datatable_settings.dart';

/// Owns pagination state and request streams for the datatable.
class DatatablePaginationController {
  final StreamController<Filters> _dataRequestController =
      StreamController<Filters>();
  final StreamController<Filters> _limitChangeController =
      StreamController<Filters>();
  final StreamController<Filters> _searchRequestController =
      StreamController<Filters>();

  int _currentPage = 1;

  /// Current one-based page number.
  int get currentPage => _currentPage;

  /// Emits when the parent should load data.
  Stream<Filters> get dataRequest => _dataRequestController.stream;

  /// Emits when only the page-size changed.
  Stream<Filters> get limitChange => _limitChangeController.stream;

  /// Emits when a search is requested.
  Stream<Filters> get searchRequest => _searchRequestController.stream;

  /// Total pages based on [totalRecords] and [filter.limit].
  int numPages(Filters filter, int totalRecords) {
    final limit = filter.limit ?? 1;
    if (limit <= 0) {
      return 1;
    }

    final totalPages = (totalRecords / limit).ceil();
    return totalPages <= 0 ? 1 : totalPages;
  }

  /// Number of items represented by the current page boundary.
  int currentTotalItems(Filters filter, int totalRecords) {
    if (totalRecords <= 0) {
      return 0;
    }

    final limit = filter.limit ?? 0;
    final offset = filter.offset ?? 0;
    final total = offset + limit;
    return total > totalRecords ? totalRecords : total;
  }

  /// Synchronizes [currentPage] from the filter offset.
  void syncCurrentPageFromOffset(Filters filter) {
    final resolvedLimit = filter.limit ?? 1;
    final resolvedOffset = filter.offset ?? 0;
    if (resolvedLimit <= 0) {
      _currentPage = 1;
      return;
    }

    final page = (resolvedOffset ~/ resolvedLimit) + 1;
    _currentPage = page <= 0 ? 1 : page;
  }

  /// Moves to [page].
  void setPage(int page) {
    _currentPage = page <= 0 ? 1 : page;
  }

  /// Moves to the previous page when possible.
  bool previousPage() {
    if (_currentPage <= 1) {
      return false;
    }

    _currentPage--;
    return true;
  }

  /// Moves to the next page when possible.
  bool nextPage(Filters filter, int totalRecords) {
    if (_currentPage >= numPages(filter, totalRecords)) {
      return false;
    }

    _currentPage++;
    return true;
  }

  /// Moves to the last page.
  int goToLastPage(Filters filter, int totalRecords) {
    _currentPage = numPages(filter, totalRecords);
    return _currentPage;
  }

  /// Moves to the first page.
  int goToFirstPage() {
    _currentPage = 1;
    return _currentPage;
  }

  /// Emits a data request using the current page and filter limit.
  void requestData(Filters filter, DatatableSettings settings) {
    final zeroBasedPage = _currentPage == 1 ? 0 : _currentPage - 1;
    filter.offset = zeroBasedPage * (filter.limit ?? 0);
    settings.setOrdemStartIndex(filter.offset ?? 0);
    _dataRequestController.add(filter);
  }

  /// Updates page size and emits the appropriate request.
  bool changeItemsPerPage(
    int? limit,
    Filters filter,
    DatatableSettings settings, {
    required bool requestDataOnItemsPerPageChange,
  }) {
    if (limit == null) {
      return false;
    }

    _currentPage = 1;
    filter.limit = limit;
    if (requestDataOnItemsPerPageChange) {
      requestData(filter, settings);
      return true;
    }

    _limitChangeController.add(filter);
    return false;
  }

  /// Emits a search request and resets pagination to page one.
  void search(Filters filter) {
    _currentPage = 1;
    _searchRequestController.add(filter);
  }

  /// Closes owned stream controllers.
  void close() {
    _dataRequestController.close();
    _limitChangeController.close();
    _searchRequestController.close();
  }
}
