import 'dart:html';

import 'package:limitless_ui_example/limitless_ui_example.dart';
import 'package:ngrouter/ngrouter.dart';

@Component(
  selector: 'demo-page-breadcrumb',
  template: '''
<li-breadcrumb breadcrumbClass="py-2">
  <a *ngIf="hasSection" liBreadcrumbItem [routerLink]="DemoRoutePaths.overview.toUrl()" [attr.aria-label]="homeLabel"><i class="ph-house"></i></a>
  <span *ngIf="hasSection" liBreadcrumbItem>{{ sectionLabel }}</span>
  <span liBreadcrumbItem [active]="true">{{ currentLabel }}</span>
</li-breadcrumb>
''',
  directives: [coreDirectives, RouterLink, liBreadcrumbDirectives],
  exports: [DemoRoutePaths],
)
class DemoPageBreadcrumbComponent {
  DemoPageBreadcrumbComponent(this.i18n);

  final DemoI18nService i18n;

  static const Set<String> _feedbackPaths = <String>{
    'alerts',
    'progress',
    'accordion',
    'tabs',
    'modal',
    'offcanvas',
    'breadcrumbs',
    'page-header',
    'pagination',
    'carousel',
    'tooltip',
    'popover',
    'nav',
    'dropdown',
    'toast',
    'notification',
  };

  static const Set<String> _inputPaths = <String>{
    'selection-controls',
    'select',
    'rating',
    'slider',
    'timeline',
    'typeahead',
    'wizard',
    'multi-select',
    'currency',
    'inputs',
    'file-upload',
  };

  static const Set<String> _pickerPaths = <String>{
    'color-picker',
    'date-picker',
    'time-picker',
    'date-range',
  };

  static const Set<String> _dataPaths = <String>{
    'datatable',
    'datatable-select',
    'treeview',
  };

  static const Set<String> _utilityPaths = <String>{
    'helpers',
    'sweet-alert',
    'highlight',
    'button',
    'fab',
  };

  @Input()
  String currentLabel = '';

  String get homeLabel => i18n.isPortuguese ? 'Visao geral' : 'Overview';

  String? get sectionLabel {
    final path = _currentPathSegment;
    if (path.isEmpty || path == 'overview') {
      return null;
    }
    if (_feedbackPaths.contains(path)) {
      return i18n.isPortuguese ? 'Feedback' : 'Feedback';
    }
    if (_inputPaths.contains(path)) {
      return i18n.isPortuguese ? 'Inputs' : 'Inputs';
    }
    if (_pickerPaths.contains(path)) {
      return i18n.isPortuguese ? 'Pickers' : 'Pickers';
    }
    if (_dataPaths.contains(path)) {
      return i18n.isPortuguese ? 'Dados' : 'Data';
    }
    if (_utilityPaths.contains(path)) {
      return i18n.isPortuguese ? 'Utilitarios' : 'Utilities';
    }
    return null;
  }

  bool get hasSection => sectionLabel != null && sectionLabel!.isNotEmpty;

  String get _currentPathSegment {
    final hash = window.location.hash.trim();
    if (hash.isEmpty) {
      return 'overview';
    }

    var path = hash.startsWith('#') ? hash.substring(1) : hash;
    final queryIndex = path.indexOf('?');
    if (queryIndex >= 0) {
      path = path.substring(0, queryIndex);
    }

    path = path.replaceFirst(RegExp(r'^/+'), '');
    if (path.isEmpty) {
      return 'overview';
    }

    final segments = path.split('/');
    return segments.isEmpty ? 'overview' : segments.last;
  }
}
