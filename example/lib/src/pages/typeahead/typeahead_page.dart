import 'dart:async';
import 'dart:convert';

import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'typeahead-global-config-demo',
  template: '''
    <div class="card card-body h-100">
      <h6 class="mb-2">Global config demo</h6>
      <p class="text-muted mb-3">
        Este bloco injeta <code>LiTypeaheadConfig</code> localmente com openOnFocus,
        minLength=0 e showHint ligados por padrão.
      </p>

      <li-typeahead
          [dataSource]="options"
          [(ngModel)]="selectedValue">
      </li-typeahead>

      <div class="small text-muted mt-3">Selecionado: {{ selectedValue ?? 'nenhum' }}</div>
    </div>
  ''',
  directives: [coreDirectives, formDirectives, LiTypeaheadComponent],
  providers: [ClassProvider(LiTypeaheadConfig)],
)
class TypeaheadGlobalConfigDemoComponent {
  TypeaheadGlobalConfigDemoComponent(this.config) {
    config.minLength = 0;
    config.openOnFocus = true;
    config.showHint = true;
    config.placeholder = 'Focus to browse with injected defaults';
  }

  final LiTypeaheadConfig config;

  final List<String> options = <String>[
    'AngularDart',
    'Bootstrap',
    'Limitless',
    'Popper',
    'Typeahead',
  ];

  dynamic selectedValue;
}

@Component(
  selector: 'typeahead-page',
  templateUrl: 'typeahead_page.html',
  styleUrls: ['typeahead_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiTypeaheadComponent,
    LiTypeaheadHighlightComponent,
    TypeaheadGlobalConfigDemoComponent,
  ],
)
class TypeaheadPageComponent {
  TypeaheadPageComponent(this.i18n) {
    states = <String>[
      'Alabama',
      'Alaska',
      'Arizona',
      'Arkansas',
      'California',
      'Colorado',
      'Connecticut',
      'Delaware',
      'Florida',
      'Georgia',
      'Hawaii',
      'Idaho',
    ];

    cityOptions = <Map<String, dynamic>>[
      <String, dynamic>{'code': 'nyc', 'name': 'New York', 'region': 'US'},
      <String, dynamic>{'code': 'sfo', 'name': 'San Francisco', 'region': 'US'},
      <String, dynamic>{'code': 'lon', 'name': 'London', 'region': 'UK'},
      <String, dynamic>{'code': 'lis', 'name': 'Lisbon', 'region': 'PT'},
      <String, dynamic>{'code': 'gru', 'name': 'Sao Paulo', 'region': 'BR'},
    ];
  }

  final DemoI18nService i18n;

  late final List<String> states;
  late final List<Map<String, dynamic>> cityOptions;
  final List<String> highlightTerms = const <String>['sao', 'san'];

  dynamic selectedState;
  dynamic selectedOnFocus;
  dynamic selectedExact;
  dynamic selectedCity;
  dynamic strictSelection;
  dynamic remoteSelection;

  String lastEvent = 'Nenhuma interação com typeahead ainda.';

  String? cityInputFormatter(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item['name']?.toString();
    }
    return item?.toString();
  }

  String? cityResultFormatter(dynamic item) {
    if (item is Map<String, dynamic>) {
      return '${item['name']} (${item['region']})';
    }
    return item?.toString();
  }

  String remoteResultMarkup(dynamic item, String term) {
    if (item is! Map<String, dynamic>) {
      return item?.toString() ?? '';
    }

    final escapedName = htmlEscape.convert(item['name']?.toString() ?? '');
    final escapedRegion = htmlEscape.convert(item['region']?.toString() ?? '');
    final escapedCode = htmlEscape.convert(item['code']?.toString() ?? '');
    final escapedTerm = htmlEscape.convert(term);

    return '''
<div class="d-flex align-items-center justify-content-between gap-3">
  <div>
    <div class="fw-semibold">$escapedName</div>
    <div class="small text-muted">$escapedRegion • term: $escapedTerm</div>
  </div>
  <span class="badge bg-light text-body border">$escapedCode</span>
</div>''';
  }

  Future<List<Map<String, dynamic>>> remoteCitySearch(String term) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final normalized = term.trim().toLowerCase();
    if (normalized.isEmpty) {
      return cityOptions.take(5).toList();
    }

    return cityOptions.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      final region = item['region']?.toString().toLowerCase() ?? '';
      return name.contains(normalized) || region.contains(normalized);
    }).toList();
  }

  void onSelectedStateChange(dynamic value) {
    selectedState = value;
    lastEvent = 'Modelo básico atualizado: ${value ?? 'nenhum'}.';
  }

  void onOpenFocusChange(dynamic value) {
    selectedOnFocus = value;
    lastEvent = 'Typeahead com openOnFocus recebeu: ${value ?? 'nenhum'}.';
  }

  void onExactChange(dynamic value) {
    selectedExact = value;
    lastEvent = 'selectOnExact resolveu para: ${value ?? 'nenhum'}.';
  }

  void onCityChange(dynamic value) {
    selectedCity = value;
    lastEvent = 'Typeahead formatado selecionou: ${value ?? 'nenhum'}.';
  }

  void onStrictChange(dynamic value) {
    strictSelection = value;
    lastEvent = 'Modo não-editável agora vale: ${value ?? 'nenhum'}.';
  }

  void onRemoteChange(dynamic value) {
    remoteSelection = value;
    lastEvent = 'Busca remota selecionou: ${value ?? 'nenhum'}.';
  }

  static const HtmlEscape htmlEscape = HtmlEscape();
}
