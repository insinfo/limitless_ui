import 'dart:html' as html;

import 'package:ngdart/angular.dart';

import 'scrollspy_fragment_directive.dart';
import 'scrollspy_service.dart';

@Directive(
  selector: '[liScrollSpy]',
  exportAs: 'liScrollSpy',
  providers: [ClassProvider(LiScrollSpyService)],
)
class LiScrollSpyDirective implements AfterViewInit, OnDestroy, LiScrollSpyRef {
  LiScrollSpyDirective(this._element, this._service, this._changeDetectorRef);

  final html.Element _element;
  final LiScrollSpyService _service;
  final ChangeDetectorRef _changeDetectorRef;

  String? _initialFragment;

  @Input()
  LiScrollSpyProcessChanges? processChanges;

  @Input()
  String? rootMargin;

  @Input()
  String? scrollBehavior;

  @Input()
  Object? threshold;

  @Input()
  set active(String? fragment) {
    final normalized = fragment?.trim();
    if (normalized == null || normalized.isEmpty) {
      return;
    }

    _initialFragment = normalized;
    scrollTo(normalized);
  }

  @Output()
  Stream<String> get activeChange => _service.active$;

  @override
  String get active => _service.active;

  @override
  Stream<String> get active$ => _service.active$;

  @HostBinding('attr.tabindex')
  String hostTabIndex = '0';

  @override
  void ngAfterViewInit() {
    _service.start(
      LiScrollSpyOptions(
        changeDetectorRef: _changeDetectorRef,
        initialFragment: _initialFragment,
        processChanges: processChanges,
        root: _element,
        rootMargin: rootMargin,
        scrollBehavior: scrollBehavior,
        threshold: threshold,
      ),
    );
  }

  void registerFragment(LiScrollSpyFragmentDirective fragment) {
    _service.observe(fragment.id);
  }

  void unregisterFragment(LiScrollSpyFragmentDirective fragment) {
    _service.unobserve(fragment.id);
  }

  @override
  void scrollTo(Object fragment, {LiScrollToOptions? options}) {
    _service.scrollTo(fragment, options: options);
  }

  @override
  void ngOnDestroy() {
    _service.stop();
  }
}
