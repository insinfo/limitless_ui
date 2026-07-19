import 'package:ngx_dart/angular.dart';

/// Renders a [TemplateRef] with optional local variables.
///
/// Use `[liTemplateOutlet]` to provide the template, then pass local values
/// with `[liTemplateOutletContext]` or the shorthand `[liTemplateOutletValue]`.
///
/// The context map keys are exposed to `let-` bindings in the rendered
/// template. Use the `'$implicit'` key to provide the default `let-value`.
@Directive(selector: '[liTemplateOutlet]')
class LiTemplateOutletDirective implements DoCheck, OnDestroy {
  LiTemplateOutletDirective(this._viewContainerRef);

  final ViewContainerRef _viewContainerRef;

  Map<String, Object?>? _context;
  EmbeddedViewRef? _insertedViewRef;
  TemplateRef? _templateRef;

  /// Template rendered at the directive location.
  ///
  /// Passing `null` removes the currently rendered embedded view.
  @Input('liTemplateOutlet')
  set liTemplateOutlet(TemplateRef? templateRef) {
    if (identical(_templateRef, templateRef)) {
      return;
    }

    _templateRef = templateRef;
    _clearView();

    if (templateRef != null) {
      _insertedViewRef = _viewContainerRef.createEmbeddedView(templateRef);
      _applyContext();
    }
  }

  /// Local variables exposed to the rendered template.
  ///
  /// The map key `'$implicit'` sets the default `let-value` binding.
  @Input('liTemplateOutletContext')
  set liTemplateOutletContext(Map<String, Object?>? context) {
    _context = context;
    _applyContext();
  }

  /// Shorthand for setting the template `'$implicit'` local value.
  @Input('liTemplateOutletValue')
  set liTemplateOutletValue(Object? value) {
    _context = {r'$implicit': value};
    _applyContext();
  }

  @override
  void ngDoCheck() {
    _applyContext();
  }

  @override
  void ngOnDestroy() {
    _clearView();
  }

  void _applyContext() {
    final insertedViewRef = _insertedViewRef;
    if (insertedViewRef == null) {
      return;
    }

    _context?.forEach(insertedViewRef.setLocal);
    insertedViewRef.markForCheck();
  }

  void _clearView() {
    _insertedViewRef?.destroy();
    _viewContainerRef.clear();
    _insertedViewRef = null;
  }
}
