import 'dart:async';
import 'dart:convert';

import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'typeahead-global-config-demo',
  template: '''
    <div class="card card-body h-100">
      <h6 class="mb-2">{{ title }}</h6>
      <p class="text-muted mb-3">{{ intro }}</p>

      <li-typeahead
          [dataSource]="options"
          [(ngModel)]="selectedValue">
      </li-typeahead>

      <div class="small text-muted mt-3">{{ selectedLabel }}: {{ selectedValue ?? noneLabel }}</div>
    </div>
  ''',
  directives: [coreDirectives, formDirectives, LiTypeaheadComponent],
  providers: [ClassProvider(LiTypeaheadConfig)],
)
class TypeaheadGlobalConfigDemoComponent {
  TypeaheadGlobalConfigDemoComponent(this.i18n, this.config) {
    config.minLength = 0;
    config.openOnFocus = true;
    config.showHint = true;
    config.placeholder = i18n.isPortuguese
        ? 'Foque para navegar com defaults injetados'
        : 'Focus to browse with injected defaults';
  }

  final DemoI18nService i18n;
  final LiTypeaheadConfig config;
  bool get _isPt => i18n.isPortuguese;

  final List<String> options = <String>[
    'AngularDart',
    'Bootstrap',
    'Limitless',
    'Popper',
    'Typeahead',
  ];

  dynamic selectedValue;

  String get title => _isPt ? 'Demo de config global' : 'Global config demo';
  String get intro => _isPt
      ? 'Este bloco injeta LiTypeaheadConfig localmente com openOnFocus, minLength=0 e showHint ligados por padrão.'
      : 'This block injects LiTypeaheadConfig locally with openOnFocus, minLength=0, and showHint enabled by default.';
  String get selectedLabel => _isPt ? 'Selecionado' : 'Selected';
  String get noneLabel => _isPt ? 'nenhum' : 'none';
}

@Component(
  selector: 'typeahead-page',
  templateUrl: 'typeahead_page.html',
  styleUrls: ['typeahead_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiTypeaheadComponent,
    LiTypeaheadHighlightComponent,
    TypeaheadGlobalConfigDemoComponent,
  ],
)
class TypeaheadPageComponent {
  TypeaheadPageComponent(this.i18n) {
    _statesPt = <String>[
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

    _statesEn = List<String>.from(_statesPt);

    _cityOptionsPt = <Map<String, dynamic>>[
      <String, dynamic>{'code': 'nyc', 'name': 'New York', 'region': 'US'},
      <String, dynamic>{'code': 'sfo', 'name': 'San Francisco', 'region': 'US'},
      <String, dynamic>{'code': 'lon', 'name': 'London', 'region': 'UK'},
      <String, dynamic>{'code': 'lis', 'name': 'Lisbon', 'region': 'PT'},
      <String, dynamic>{'code': 'gru', 'name': 'Sao Paulo', 'region': 'BR'},
    ];

    _cityOptionsEn = List<Map<String, dynamic>>.from(_cityOptionsPt);
    lastEvent = idleState;
  }

  static const String apiSnippet = '''
<li-typeahead
  [searchCallback]="remoteCitySearch"
  [inputFormatter]="cityInputFormatter"
  [resultMarkupBuilder]="remoteResultMarkup"
  [debounceMs]="220"
  placeholder="Remote city search"
  [(ngModel)]="remoteSelection">
</li-typeahead>''';

  static const String bestPracticesSnippet = '''
final cities = <Map<String, dynamic>>[
  {'code': 'gru', 'name': 'Sao Paulo', 'region': 'BR'},
  {'code': 'lis', 'name': 'Lisbon', 'region': 'PT'},
];

Future<List<Map<String, dynamic>>> remoteCitySearch(String term) async {
  await Future<void>.delayed(const Duration(milliseconds: 350));
  return cities.where((item) => item['name'].toLowerCase().contains(term.toLowerCase())).toList();
}''';

  final DemoI18nService i18n;
  bool get _isPt => i18n.isPortuguese;

  late final List<String> _statesPt;
  late final List<String> _statesEn;
  late final List<Map<String, dynamic>> _cityOptionsPt;
  late final List<Map<String, dynamic>> _cityOptionsEn;
  final List<String> highlightTerms = const <String>['sao', 'san'];

  List<String> get states => _isPt ? _statesPt : _statesEn;
  List<Map<String, dynamic>> get cityOptions =>
      _isPt ? _cityOptionsPt : _cityOptionsEn;

  dynamic selectedState;
  dynamic selectedOnFocus;
  dynamic selectedExact;
  dynamic selectedCity;
  dynamic strictSelection;
  dynamic remoteSelection;

  String lastEvent = '';

  String get pageTitle => 'Typeahead';
  String get pageSubtitle =>
      _isPt ? 'Busca com sugestões' : 'Search with suggestions';
  String get breadcrumb => _isPt
      ? 'Autocomplete com lista filtrada'
      : 'Autocomplete with filtered suggestions';
  String get overviewIntro => _isPt
      ? 'li-typeahead cobre o fluxo mais comum de autocomplete no formulário: digitação com debounce, navegação por teclado, seleção por Enter/Tab, highlight configurável, busca assíncrona e integração direta com ngModel.'
      : 'li-typeahead covers the most common form autocomplete flow: typing with debounce, keyboard navigation, Enter/Tab selection, configurable highlight, asynchronous search, and direct ngModel integration.';
  String get descriptionBody => _isPt
      ? 'É a opção intermediária entre li-select e li-datatable-select, quando a escolha precisa de busca rápida, mas não de uma tabela completa.'
      : 'It is the middle-ground option between li-select and li-datatable-select when the choice needs quick search but not a full table.';
  List<String> get features => _isPt
      ? const <String>[
          'dataSource com lista estável ou DataFrame.',
          'searchCallback para busca remota/assíncrona.',
          'resultMarkupBuilder para renderização rica do item.',
          'LiTypeaheadConfig e li-typeahead-highlight.',
        ]
      : const <String>[
          'dataSource with a stable list or DataFrame.',
          'searchCallback for remote/asynchronous search.',
          'resultMarkupBuilder for rich item rendering.',
          'LiTypeaheadConfig and li-typeahead-highlight.',
        ];
  List<String> get limits => _isPt
      ? const <String>[
          'O resultado customizado rico usa callback HTML seguro, não TemplateRef contextual.',
          'Quando editable=true, o ngModel pode refletir texto livre até a seleção.',
          'Se a busca remota falhar, o popup mostra uma mensagem simples de erro.',
        ]
      : const <String>[
          'Rich custom results use a safe HTML callback, not a contextual TemplateRef.',
          'When editable=true, ngModel may reflect free text until selection.',
          'If remote search fails, the popup shows a simple error message.',
        ];
  String get simpleSearchTitle => _isPt ? 'Busca simples' : 'Simple search';
  String get simpleSearchBody => _isPt
      ? 'Lista estática de estados com highlight e debounce curto.'
      : 'Static state list with highlight and short debounce.';
  String get simpleSearchPlaceholder =>
      _isPt ? 'Busque um estado' : 'Search for a state';
  String get openOnFocusTitle => _isPt ? 'Open on focus' : 'Open on focus';
  String get openOnFocusBody => _isPt
      ? 'Abre a lista completa ao focar no campo, mesmo vazio.'
      : 'Opens the full list when the field receives focus, even when empty.';
  String get openOnFocusPlaceholder =>
      _isPt ? 'Foque para navegar pelos estados' : 'Focus to browse states';
  String get selectOnExactTitle =>
      _isPt ? 'Select on exact' : 'Select on exact';
  String get selectOnExactBody => _isPt
      ? 'Se houver um único match exato, o item é selecionado automaticamente.'
      : 'If there is a single exact match, the item is selected automatically.';
  String get selectOnExactPlaceholder =>
      _isPt ? 'Digite um estado exato' : 'Type an exact state';
  String get formattedResultsTitle =>
      _isPt ? 'Resultados formatados' : 'Formatted results';
  String get formattedResultsBody => _isPt
      ? 'Usa inputFormatter e resultFormatter sobre objetos.'
      : 'Uses inputFormatter and resultFormatter on objects.';
  String get cityPlaceholder =>
      _isPt ? 'Busque uma cidade' : 'Search for a city';
  String get asyncTitle => _isPt
      ? 'Busca assíncrona + markup customizado'
      : 'Async search + custom markup';
  String get asyncBody => _isPt
      ? 'Usa searchCallback com atraso simulado e resultMarkupBuilder para mostrar layout mais rico por item.'
      : 'Uses searchCallback with a simulated delay and resultMarkupBuilder to show a richer layout per item.';
  String get remotePlaceholder =>
      _isPt ? 'Busca remota de cidades' : 'Remote city search';
  String get strictTitle =>
      _isPt ? 'Bloquear entrada manual' : 'Prevent manual entry';
  String get strictBody => _isPt
      ? 'Com editable=false, o modelo só aceita um item selecionado.'
      : 'With editable=false, the model only accepts a selected item.';
  String get strictPlaceholder =>
      _isPt ? 'Selecione só nas sugestões' : 'Select only from suggestions';
  String get highlightTitle =>
      _isPt ? 'Highlight configurável' : 'Configurable highlight';
  String get highlightBody => _isPt
      ? 'O componente separado li-typeahead-highlight também pode ser usado fora do typeahead.'
      : 'The separate li-typeahead-highlight component can also be used outside the typeahead.';
  String get apiUsageTitle => _isPt ? 'Como utilizar' : 'How to use';
  String get apiUsageBody => _isPt
      ? 'O componente recebe uma coleção em dataSource, mantém o filtro local e devolve o valor selecionado por [(ngModel)] e (currentValueChange).'
      : 'The component receives a collection in dataSource, keeps the filter local, and returns the selected value through [(ngModel)] and (currentValueChange).';
  List<String> get apiUsageItems => _isPt
      ? const <String>[
          'labelKey, valueKey e disabledKey para listas de mapas.',
          'inputFormatter e resultFormatter para objetos.',
          'searchCallback para busca assíncrona retornando Future ou lista imediata.',
          'resultMarkupBuilder para markup HTML do item.',
          'openOnFocus, showHint, editable e selectOnExact.',
          'minLength, maxResults, debounceMs e LiTypeaheadConfig.',
        ]
      : const <String>[
          'labelKey, valueKey, and disabledKey for map lists.',
          'inputFormatter and resultFormatter for objects.',
          'searchCallback for asynchronous search returning a Future or immediate list.',
          'resultMarkupBuilder for item HTML markup.',
          'openOnFocus, showHint, editable, and selectOnExact.',
          'minLength, maxResults, debounceMs, and LiTypeaheadConfig.',
        ];
  String get bestPracticesTitle => _isPt ? 'Boas práticas' : 'Best practices';
  List<String> get bestPractices => _isPt
      ? const <String>[
          'Mantenha o dataSource estável no pai.',
          'Prefira searchCallback quando o backend já expõe busca filtrada.',
          'Use LiTypeaheadConfig para defaults locais por área da tela.',
          'Use li-datatable-select quando a escolha exigir colunas, paginação ou ordenação.',
          'Prefira editable=false em formulários cujo valor final precisa ser estritamente validado.',
        ]
      : const <String>[
          'Keep the dataSource stable in the parent.',
          'Prefer searchCallback when the backend already exposes filtered search.',
          'Use LiTypeaheadConfig for local defaults per screen area.',
          'Use li-datatable-select when the choice requires columns, paging, or sorting.',
          'Prefer editable=false in forms whose final value must be strictly validated.',
        ];
  String get idleState => _isPt
      ? 'Nenhuma interação com typeahead ainda.'
      : 'No typeahead interaction yet.';
  String get noneLabel => _isPt ? 'nenhum' : 'none';

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
    final termLabel = _isPt ? 'termo' : 'term';

    return '''
<div class="d-flex align-items-center justify-content-between gap-3">
  <div>
    <div class="fw-semibold">$escapedName</div>
    <div class="small text-muted">$escapedRegion • $termLabel: $escapedTerm</div>
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
    lastEvent = _isPt
        ? 'Modelo básico atualizado: ${value ?? noneLabel}.'
        : 'Basic model updated: ${value ?? noneLabel}.';
  }

  void onOpenFocusChange(dynamic value) {
    selectedOnFocus = value;
    lastEvent = _isPt
        ? 'Typeahead com openOnFocus recebeu: ${value ?? noneLabel}.'
        : 'Typeahead with openOnFocus received: ${value ?? noneLabel}.';
  }

  void onExactChange(dynamic value) {
    selectedExact = value;
    lastEvent = _isPt
        ? 'selectOnExact resolveu para: ${value ?? noneLabel}.'
        : 'selectOnExact resolved to: ${value ?? noneLabel}.';
  }

  void onCityChange(dynamic value) {
    selectedCity = value;
    lastEvent = _isPt
        ? 'Typeahead formatado selecionou: ${value ?? noneLabel}.'
        : 'Formatted typeahead selected: ${value ?? noneLabel}.';
  }

  void onStrictChange(dynamic value) {
    strictSelection = value;
    lastEvent = _isPt
        ? 'Modo não-editável agora vale: ${value ?? noneLabel}.'
        : 'Non-editable mode now holds: ${value ?? noneLabel}.';
  }

  void onRemoteChange(dynamic value) {
    remoteSelection = value;
    lastEvent = _isPt
        ? 'Busca remota selecionou: ${value ?? noneLabel}.'
        : 'Remote search selected: ${value ?? noneLabel}.';
  }

  static const HtmlEscape htmlEscape = HtmlEscape();
}
