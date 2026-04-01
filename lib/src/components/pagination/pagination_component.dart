import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

const liPaginationDirectives = <Object>[
  LiPaginationComponent,
  LiPaginationEllipsisDirective,
  LiPaginationFirstDirective,
  LiPaginationLastDirective,
  LiPaginationNextDirective,
  LiPaginationNumberDirective,
  LiPaginationPagesDirective,
  LiPaginationPreviousDirective,
];

class LiPaginationLinkContext {
  LiPaginationLinkContext({
    this.currentPage = 1,
    this.disabled = false,
  });

  int currentPage;
  bool disabled;
}

class LiPaginationNumberContext extends LiPaginationLinkContext {
  LiPaginationNumberContext({
    this.page = 1,
    super.currentPage = 1,
    super.disabled = false,
  });

  int page;
}

class LiPaginationPagesContext {
  LiPaginationPagesContext({
    this.currentPage = 1,
    this.disabled = false,
    List<int>? pages,
  }) : pages = pages ?? <int>[];

  int currentPage;
  bool disabled;
  final List<int> pages;
}

@Directive(selector: 'template[liPaginationEllipsis]')
class LiPaginationEllipsisDirective {
  LiPaginationEllipsisDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liPaginationFirst]')
class LiPaginationFirstDirective {
  LiPaginationFirstDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liPaginationLast]')
class LiPaginationLastDirective {
  LiPaginationLastDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liPaginationNext]')
class LiPaginationNextDirective {
  LiPaginationNextDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liPaginationNumber]')
class LiPaginationNumberDirective {
  LiPaginationNumberDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liPaginationPages]')
class LiPaginationPagesDirective {
  LiPaginationPagesDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liPaginationPrevious]')
class LiPaginationPreviousDirective {
  LiPaginationPreviousDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liPaginationOutlet]')
class LiPaginationOutletDirective implements AfterChanges, OnDestroy {
  LiPaginationOutletDirective(this._viewContainerRef);

  final ViewContainerRef _viewContainerRef;

  EmbeddedViewRef? _viewRef;
  TemplateRef? _lastTemplate;

  @Input('liPaginationOutlet')
  TemplateRef? template;

  @Input('liPaginationOutletImplicit')
  Object? implicitValue;

  @Input('liPaginationOutletCurrentPage')
  int? currentPage;

  @Input('liPaginationOutletDisabled')
  bool disabled = false;

  @Input('liPaginationOutletPage')
  int? page;

  @Input('liPaginationOutletPages')
  List<int>? pages;

  @Input('liPaginationOutletRevision')
  int revision = 0;

  @override
  void ngAfterChanges() {
    if (!identical(_lastTemplate, template)) {
      _viewRef?.destroy();
      _viewContainerRef.clear();
      _lastTemplate = template;
      final currentTemplate = template;
      if (currentTemplate != null) {
        _viewRef = _viewContainerRef.createEmbeddedView(currentTemplate);
      } else {
        _viewRef = null;
      }
    }

    final viewRef = _viewRef;
    if (viewRef == null) {
      return;
    }

    _setLocal(viewRef, r'$implicit', implicitValue);
    _setLocal(viewRef, 'page', page ?? implicitValue);
    _setLocal(viewRef, 'currentPage', currentPage);
    _setLocal(viewRef, 'disabled', disabled);
    _setLocal(viewRef, 'pages', pages);
    viewRef.markForCheck();
  }

  void _setLocal(EmbeddedViewRef viewRef, String name, Object? value) {
    viewRef.setLocal(name, value);
  }

  @override
  void ngOnDestroy() {
    _viewRef?.destroy();
    _viewContainerRef.clear();
  }
}

class LiPaginationPageItem {
  LiPaginationPageItem({required this.value, required this.ellipsis})
      : linkContext = LiPaginationLinkContext(),
        numberContext = LiPaginationNumberContext();

  final int value;
  final bool ellipsis;
  final LiPaginationLinkContext linkContext;
  final LiPaginationNumberContext numberContext;

  bool active = false;
  bool disabled = false;

  void update({
    required int currentPage,
    required bool paginationDisabled,
  }) {
    active = !ellipsis && value == currentPage;
    disabled = ellipsis || paginationDisabled;
    linkContext
      ..currentPage = currentPage
      ..disabled = disabled;
    numberContext
      ..page = value
      ..currentPage = currentPage
      ..disabled = disabled;
  }
}

@Component(
  selector: 'li-pagination',
  templateUrl: 'pagination_component.html',
  styleUrls: ['pagination_component.css'],
  directives: [coreDirectives, LiPaginationOutletDirective],
  encapsulation: ViewEncapsulation.none,
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiPaginationComponent implements AfterChanges, AfterViewInit, OnDestroy {
  LiPaginationComponent();

  final StreamController<int> _pageChangeController =
      StreamController<int>.broadcast();

  final List<int> displayedPages = <int>[];
  final List<LiPaginationPageItem> pageItems = <LiPaginationPageItem>[];

  final LiPaginationLinkContext firstContext = LiPaginationLinkContext();
  final LiPaginationLinkContext previousContext = LiPaginationLinkContext();
  final LiPaginationLinkContext nextContext = LiPaginationLinkContext();
  final LiPaginationLinkContext lastContext = LiPaginationLinkContext();
  final LiPaginationLinkContext ellipsisContext = LiPaginationLinkContext();
  final LiPaginationPagesContext pagesContext = LiPaginationPagesContext();

  int _renderRevision = 0;

  @ContentChild(LiPaginationEllipsisDirective)
  LiPaginationEllipsisDirective? ellipsisTemplate;

  @ContentChild(LiPaginationFirstDirective)
  LiPaginationFirstDirective? firstTemplate;

  @ContentChild(LiPaginationLastDirective)
  LiPaginationLastDirective? lastTemplate;

  @ContentChild(LiPaginationNextDirective)
  LiPaginationNextDirective? nextTemplate;

  @ContentChild(LiPaginationNumberDirective)
  LiPaginationNumberDirective? numberTemplate;

  @ContentChild(LiPaginationPagesDirective)
  LiPaginationPagesDirective? pagesTemplate;

  @ContentChild(LiPaginationPreviousDirective)
  LiPaginationPreviousDirective? previousTemplate;

  @ViewChild('defaultEllipsisTemplate')
  TemplateRef? defaultEllipsisTemplate;

  @ViewChild('defaultFirstTemplate')
  TemplateRef? defaultFirstTemplate;

  @ViewChild('defaultLastTemplate')
  TemplateRef? defaultLastTemplate;

  @ViewChild('defaultNextTemplate')
  TemplateRef? defaultNextTemplate;

  @ViewChild('defaultNumberTemplate')
  TemplateRef? defaultNumberTemplate;

  @ViewChild('defaultPreviousTemplate')
  TemplateRef? defaultPreviousTemplate;

  @Input('aria-label')
  String ariaLabel = 'Pagination';

  @Input()
  bool boundaryLinks = false;

  @Input('collectionSize')
  int? collectionSize;

  @Input()
  bool directionLinks = true;

  @Input()
  bool disabled = false;

  @Input()
  bool ellipses = true;

  @Input()
  int maxSize = 0;

  @Input()
  int page = 1;

  @Input()
  int pageSize = 10;

  @Input()
  String paginationClass = '';

  @Input()
  String linkClass = '';

  @Input()
  bool rotate = false;

  @Input()
  String size = '';

  @Input()
  String variant = 'default';

  @Input()
  String alignment = 'start';

  @Input()
  String appearance = 'default';

  int pageCount = 0;

  TemplateRef? get resolvedEllipsisTemplate =>
      ellipsisTemplate?.templateRef ?? defaultEllipsisTemplate;

  TemplateRef? get resolvedFirstTemplate =>
      firstTemplate?.templateRef ?? defaultFirstTemplate;

  TemplateRef? get resolvedLastTemplate =>
      lastTemplate?.templateRef ?? defaultLastTemplate;

  TemplateRef? get resolvedNextTemplate =>
      nextTemplate?.templateRef ?? defaultNextTemplate;

  TemplateRef? get resolvedNumberTemplate =>
      numberTemplate?.templateRef ?? defaultNumberTemplate;

  TemplateRef? get resolvedPreviousTemplate =>
      previousTemplate?.templateRef ?? defaultPreviousTemplate;

  bool get hasPagesTemplate => pagesTemplate != null;

  int get renderRevision => _renderRevision;

  String get paginationClasses {
    final classes = <String>['pagination'];

    final trimmedSize = size.trim();
    if (trimmedSize.isNotEmpty) {
      classes.add('pagination-$trimmedSize');
    }

    switch (variant) {
      case 'flat':
        classes.add('pagination-flat');
        break;
      case 'spaced':
        classes.add('pagination-spaced');
        break;
      case 'linked':
        classes.add('pagination-linked');
        break;
    }

    switch (alignment) {
      case 'center':
        classes.add('justify-content-center');
        break;
      case 'end':
        classes.add('justify-content-end');
        break;
    }

    final extraClasses = paginationClass.trim();
    if (extraClasses.isNotEmpty) {
      classes.addAll(extraClasses.split(RegExp(r'\s+')));
    }

    if (appearance.trim() == 'datatable') {
      classes.add('li-pagination-datatable');
    }

    return classes.join(' ');
  }

  String get pageLinkClasses {
    final classes = <String>['page-link'];

    if (appearance.trim() == 'datatable') {
      classes.add('li-pagination-datatable__link');
    }

    final extraClasses = linkClass.trim();
    if (extraClasses.isNotEmpty) {
      classes.addAll(extraClasses.split(RegExp(r'\s+')));
    }
    return classes.join(' ');
  }

  bool get previousDisabled => disabled || page <= 1 || pageCount <= 1;

  bool get nextDisabled => disabled || pageCount <= 1 || page >= pageCount;

  @Output('pageChange')
  Stream<int> get onPageChange => _pageChangeController.stream;

  @override
  void ngAfterChanges() {
    _refreshPaginationState();
  }

  @override
  void ngAfterViewInit() {
    scheduleMicrotask(_refreshPaginationState);
  }

  void selectPage(int requestedPage, [html.Event? event]) {
    event?.preventDefault();
    if (disabled || pageCount <= 0) {
      return;
    }

    _updatePages(requestedPage, emitPageChange: true);
  }

  @override
  void ngOnDestroy() {
    _pageChangeController.close();
  }

  void _refreshPaginationState() {
    _updatePages(page, emitPageChange: false);
  }

  void _updatePages(int requestedPage, {required bool emitPageChange}) {
    final previousPage = page;
    pageCount = _calculatePageCount();
    page = _clampPage(requestedPage, pageCount);

    _rebuildDisplayedPages();
    _rebuildViewModels();
    _syncContexts();

    if (emitPageChange &&
        previousPage != page &&
        collectionSize != null &&
        collectionSize! >= 0 &&
        pageCount > 0) {
      _pageChangeController.add(page);
    }
  }

  int _calculatePageCount() {
    final size = collectionSize;
    if (size == null || size <= 0 || pageSize <= 0) {
      return 0;
    }
    return (size / pageSize).ceil();
  }

  int _clampPage(int requestedPage, int totalPages) {
    if (totalPages <= 0) {
      return 1;
    }
    if (requestedPage < 1) {
      return 1;
    }
    if (requestedPage > totalPages) {
      return totalPages;
    }
    return requestedPage;
  }

  void _rebuildDisplayedPages() {
    displayedPages.clear();

    if (pageCount <= 0) {
      return;
    }

    final allPages = List<int>.generate(pageCount, (int index) => index + 1);
    if (maxSize <= 0 || pageCount <= maxSize) {
      displayedPages.addAll(allPages);
      return;
    }

    int startIndex;
    int endIndex;
    if (rotate) {
      final leftOffset = maxSize ~/ 2;
      final rightOffset = maxSize.isEven ? leftOffset - 1 : leftOffset;
      if (page <= leftOffset + 1) {
        startIndex = 0;
        endIndex = maxSize;
      } else if (pageCount - page < leftOffset) {
        startIndex = pageCount - maxSize;
        endIndex = pageCount;
      } else {
        startIndex = page - leftOffset - 1;
        endIndex = page + rightOffset;
      }
    } else {
      final chunkIndex = ((page - 1) / maxSize).floor();
      startIndex = chunkIndex * maxSize;
      endIndex = startIndex + maxSize;
      if (endIndex > pageCount) {
        endIndex = pageCount;
      }
    }

    displayedPages.addAll(allPages.sublist(startIndex, endIndex));
    _applyEllipses(startIndex, endIndex);
  }

  void _applyEllipses(int startIndex, int endIndex) {
    if (!ellipses) {
      return;
    }

    if (startIndex > 0) {
      if (startIndex > 2) {
        displayedPages.insert(0, -1);
      } else if (startIndex == 2) {
        displayedPages.insert(0, 2);
      }
      displayedPages.insert(0, 1);
    }

    if (endIndex < pageCount) {
      if (endIndex < pageCount - 2) {
        displayedPages.add(-1);
      } else if (endIndex == pageCount - 2) {
        displayedPages.add(pageCount - 1);
      }
      displayedPages.add(pageCount);
    }
  }

  void _rebuildViewModels() {
    pageItems.clear();
    for (final value in displayedPages) {
      final item = LiPaginationPageItem(
        value: value,
        ellipsis: value == -1,
      );
      item.update(currentPage: page, paginationDisabled: disabled);
      pageItems.add(item);
    }
  }

  void _syncContexts() {
    firstContext
      ..currentPage = page
      ..disabled = previousDisabled;
    previousContext
      ..currentPage = page
      ..disabled = previousDisabled;
    nextContext
      ..currentPage = page
      ..disabled = nextDisabled;
    lastContext
      ..currentPage = page
      ..disabled = nextDisabled;
    ellipsisContext
      ..currentPage = page
      ..disabled = true;

    pagesContext
      ..currentPage = page
      ..disabled = disabled;
    pagesContext.pages
      ..clear()
      ..addAll(displayedPages);

    _renderRevision++;
  }
}
