# limitless_ui

[![CI](https://github.com/insinfo/limitless_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/insinfo/limitless_ui/actions/workflows/ci.yml)

Reusable AngularDart UI components, directives and small browser helpers for applications built on the Limitless visual language https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/css/all.min.css.

This package is browser-only. It depends on `dart:html`, `ngdart`, `ngforms` and `ngrouter`.

demo page: https://insinfo.github.io/limitless_ui/

## Publication status

The package is prepared for publication and currently versioned as `1.0.0-dev.2`, because it still depends on AngularDart pre-release packages:

- `ngdart: ^8.0.0-dev.4`
- `ngforms: ^5.0.0-dev.3`
- `ngrouter: ^4.0.0-dev.3`

Publication metadata is configured in [pubspec.yaml](/c:/MyDartProjects/limitless_ui/pubspec.yaml) and CI is defined in [ci.yml](/c:/MyDartProjects/limitless_ui/.github/workflows/ci.yml).

## Installation

```yaml
dependencies:
  limitless_ui: ^1.0.0-dev.2
```

For local development:

```yaml
dependencies:
  limitless_ui:
    path: ../limitless_ui
```

## Import

```dart
import 'package:limitless_ui/limitless_ui.dart';
```

## Theme and icons

The package follows the Limitless visual language, but some visual affordances are provided by the theme CSS instead of component Dart code.

For the demo application we load Limitless CSS plus the Phosphor icon font in [example/web/index.html](/c:/MyDartProjects/limitless_ui/example/web/index.html). One practical detail is the dropdown caret: if your theme renders `.dropdown-toggle::after` with a glyph that does not exist in the loaded icon font, the caret will appear broken.

In the example this is fixed with a global override in [example/web/style.scss](/c:/MyDartProjects/limitless_ui/example/web/style.scss):

```scss
.dropdown-toggle::after {
  font-family: var(--icon-font-family), "Phosphor" !important;
  content: "\e9fe";
}
```

`\e9fe` is the `ph-caret-down` glyph from the Phosphor font bundle used by the demo.

## AngularDart stylesheets

- In this repository, component styles are authored in `.scss` and compiled by `sass_builder`.
- In `@Component(styleUrls: ...)`, always reference the generated `.css` path, not `.scss`.
- Do not create or commit manual duplicate `.css` files next to component `.scss` sources just to satisfy `styleUrls`.
- If a component has `toast_component.scss`, the correct AngularDart annotation is `styleUrls: ['toast_component.css']`.

## Included modules

- Inputs: currency input, date picker, time picker, date range picker, select, multi-select, typeahead.
- Data display: datatable, datatable select, tree view.
- Structure: accordion, collapse, buttons, carousel, modal, tabs, nav.
- Overlay and menus: dropdown, tooltip, popover, sweet alert, notification toast.
- Navigation helpers: scrollspy service and directives.
- Utilities: HTML directives, form value accessors, pipes, PDF generator and XLSX generator.

## Public API highlights

The barrel export in [limitless_ui.dart](/c:/MyDartProjects/limitless_ui/lib/limitless_ui.dart) now exposes these families of APIs:

- Accordion:
  `LiAccordionComponent`, `LiAccordionItemComponent`, `LiAccordionDirective`,
  `LiAccordionItemDirective`, `LiAccordionBodyDirective`,
  `LiAccordionBodyTemplateDirective`, `LiAccordionButtonDirective`,
  `LiAccordionToggleDirective`, `LiAccordionCollapseDirective`,
  `LiAccordionHeaderDirective`, `LiAccordionHeaderHostDirective`.
- Collapse:
  `LiCollapseDirective`, `LiCollapseController`, `LiCollapseConfig`.
- Dropdown:
  `LiDropdownDirective`, `LiDropdownMenuDirective`, `LiDropdownAnchorDirective`,
  `LiDropdownToggleDirective`, `LiDropdownItemDirective`,
  `LiDropdownButtonItemDirective`, `LiDropdownConfig`.
- Nav:
  `LiNavDirective`, `LiNavItemDirective`, `LiNavLinkDirective`,
  `LiNavOutletDirective`, `LiNavContentDirective`, `LiNavConfig`.
- Popover and tooltip:
  `LiPopoverComponent`, `LiPopoverDirective`, `LiPopoverConfig`,
  `LiTooltipComponent`, `LiTooltipDirective`, `LiTooltipConfig`.
- Scrollspy:
  `LiScrollSpyService`, `LiScrollSpyDirective`,
  `LiScrollSpyFragmentDirective`, `LiScrollSpyItemDirective`,
  `LiScrollSpyMenuDirective`, `LiScrollSpyConfig`.
- Modal:
  `LiModalComponent` with lazy content support.
- Toast:
  `LiToastComponent`, `LiToastStackComponent`, `LiToastService`.
- Typeahead:
  `LiTypeaheadComponent`, `LiTypeaheadItem`, `LiTypeaheadSelectItemEvent`, `LiTypeaheadConfig`, `LiTypeaheadHighlightComponent`.
- Treeview:
  `LiTreeViewComponent`, `LiTreeviewSelectComponent`,
  `LiTreeViewPageLoader`, `TreeViewLoadRequest`, `TreeViewLoadResult`,
  `LiTreeviewSelectNodeDirective`, `LiTreeviewSelectTriggerDirective`.

## Recent additions in `1.0.0-dev.2`

- Added first-class dropdown, nav, popover and scrollspy modules to the public API.
- Expanded accordion into a fuller directive set for host-driven and template-driven compositions.
- Added collapse as a reusable directive/config pair.
- Added injectable config objects for tooltip, popover, dropdown, nav and scrollspy.
- Added `lazyContent` support to `li-modal` so heavy projected content can be created only while the modal is open.
- Expanded the demo app with pages for dropdown, nav, popover and scrollspy, plus richer modal, tooltip, accordion and datatable examples.
- Added tests for the new surface area, including accordion lazy rendering, modal lazy content and overlay/navigation components.
- Added the new toast component family, toast stack service flow and a dedicated demo page.
- Added CI coverage for toast browser tests and documented the AngularDart `.scss` to `.css` stylesheet convention used in this repository.
- Added `li-typeahead` for autocomplete-style selection with local filtering, keyboard navigation and `ngModel`.
- Expanded `li-typeahead` with async search, rich result markup, a separate highlight component and injectable defaults via `LiTypeaheadConfig`.
- Added `li-treeview-select` for dropdown selection over hierarchical data.
- Expanded `li-treeview-select` with lazy page loading, remote search via `pageLoader(searchTerm)`, `multiple`, `labelBuilder`, `canSelectNode` and projected templates for trigger and node rendering.

## Quick examples

### Alert

```dart
@Component(
  selector: 'demo-alert',
  template: '''
    <li-alert
      variant="warning"
      iconMode="block"
      iconClass="ph-warning-circle"
      [dismissible]="true">
      Conteudo do alerta
    </li-alert>
  ''',
  directives: [coreDirectives, LiAlertComponent],
)
class DemoAlertComponent {}
```

### Datatable

`li-datatable` cobre o fluxo administrativo mais comum da biblioteca: busca por
campo, paginação, ordenação, seleção de linhas, exportação, colapso responsivo
em mobile e alternância entre tabela e grade sem duplicar fonte de dados.

O componente gira em torno de três objetos:

- `Filters`: limite, offset, busca e ordenação da requisição atual.
- `DataFrame<T>`: coleção retornada pela fonte de dados mais `totalRecords`.
- `DatatableSettings`: colunas e comportamento visual da tabela ou grade.

Recursos mais úteis:

- busca direcionada por coluna com `searchInFields`;
- eventos como `(dataRequest)`, `(searchRequest)` e `(limitChange)` para fluxo server-driven;
- colunas com `enableSorting`, `sortingBy`, `hideOnMobile`, `textAlign`, `nowrap`, `width` e classes;
- estilos por célula com `cellStyleResolver` e por linha com `rowStyleResolver`;
- modo grade com `gridMode`, `gridTemplateColumns`, `gridGap` e `customCardBuilder`;
- exportação para XLSX e PDF pela própria API do componente.

```dart
final filters = Filters(limit: 10, offset: 0);

final settings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(
      key: 'feature',
      title: 'Feature',
      sortingBy: 'feature',
      enableSorting: true,
    ),
    DatatableCol(
      key: 'owner',
      title: 'Owner',
      hideOnMobile: true,
    ),
    DatatableCol(
      key: 'status',
      title: 'Status',
      enableSorting: true,
      sortingBy: 'status',
      hideOnMobile: true,
    ),
  ],
);

final searchFields = <DatatableSearchField>[
  DatatableSearchField(
    label: 'Feature',
    field: 'feature',
    operator: 'like',
  ),
  DatatableSearchField(
    label: 'Status',
    field: 'status',
    operator: '=',
  ),
];
```

```html
<li-datatable
  [data]="usersFrame"
  [settings]="settings"
  [dataTableFilter]="filters"
  [searchInFields]="searchFields"
  [responsiveCollapse]="true"
  [searchPlaceholder]="'Type to search'"
  (dataRequest)="loadUsers($event)"
  (limitChange)="loadUsers($event)"
  (searchRequest)="loadUsers($event)">
</li-datatable>
```

Para cenários visuais mais densos, o mesmo dataset pode ser reaproveitado em
modo grade:

```dart
final gridSettings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(key: 'feature', title: 'Feature', width: '240px'),
    DatatableCol(key: 'owner', title: 'Owner'),
    DatatableCol(key: 'status', title: 'Status'),
  ],
  gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
  gridGap: '1rem',
);
```

```html
<li-datatable
  [data]="usersFrame"
  [settings]="gridSettings"
  [dataTableFilter]="filters"
  [gridMode]="true"
  [showCheckboxToSelectRow]="false"
  [disableRowClick]="true">
</li-datatable>
```

Customização de coluna, linha e grid:

```dart
final advancedSettings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(
      key: 'status',
      title: 'Status',
      width: '160px',
      textAlign: 'center',
      nowrap: true,
      cellStyleResolver: (itemMap, itemInstance) {
        final status = itemMap['status']?.toString() ?? '';
        return status == 'Blocked'
            ? 'color: #b91c1c; font-weight: 700;'
            : 'color: #0f766e; font-weight: 700;';
      },
    ),
  ],
  rowStyleResolver: (itemMap, itemInstance) {
    if (itemMap['health'] == 'Critical') {
      return 'background-color: rgba(239, 68, 68, 0.08);';
    }
    return null;
  },
  customCardBuilder: (itemMap, itemInstance, row) {
    final root = DivElement()..classes.add('my-card');
    root.text = itemMap['feature']?.toString() ?? '';
    return root;
  },
);
```

Boas práticas:

- mantenha `Filters`, `DatatableSettings` e `searchInFields` estáveis, em vez
  de recriá-los em getters;
- use `hideOnMobile` nas colunas secundárias para alimentar o colapso
  responsivo;
- reserve `customCardBuilder` para grids que realmente precisam fugir do layout
  padrão;
- em conteúdos pesados, prefira carregar o datatable sob demanda em accordion
  lazy ou modal com `lazyContent`.

O demo mais completo está em
[datatable_page.dart](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/datatable/datatable_page.dart)
e
[datatable_page.html](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/datatable/datatable_page.html).

### Datatable Select

`li-datatable-select` é o componente mais indicado quando um `select` simples não
resolve porque o usuário precisa pesquisar, paginar e ordenar antes de escolher
um item. Ele combina um trigger no estilo `form-select` com um `li-modal`
interno que hospeda um `li-datatable`.

Fluxo principal:

- o host fornece `Filters`, `DataFrame<T>` e `DatatableSettings`;
- o componente emite `(dataRequest)` sempre que a tabela interna pede dados;
- ao clicar em uma linha, o item é selecionado, o label é atualizado no trigger
  e o modal fecha;
- o valor pode ser controlado por `[(ngModel)]` ou por
  `(currentValueChange)`.

Entradas e recursos mais relevantes:

- `labelKey` e `valueKey` para separar o texto visível do valor persistido;
- `searchInFields` para o seletor de busca dentro do modal;
- `modalSize`, `title`, `placeholder`, `disabled` e `fullScreenOnMobile`;
- métodos públicos como `clear()`, `setSelectedItem(...)` e `selectedLabel`.

```html
<li-datatable-select
  [settings]="personSettings"
  [dataTableFilter]="personFilter"
  [data]="personFrame"
  [searchInFields]="personSearchFields"
  labelKey="name"
  valueKey="id"
  title="Selecionar pessoa"
  placeholder="Clique para selecionar..."
  (dataRequest)="loadPeople($event)"
  (currentValueChange)="onPersonChanged($event)">
</li-datatable-select>
```

```html
<li-datatable-select
  [settings]="personSettings"
  [dataTableFilter]="personFilter"
  [data]="personFrame"
  [searchInFields]="personSearchFields"
  labelKey="name"
  valueKey="id"
  [(ngModel)]="selectedPersonId"
  (dataRequest)="loadPeople($event)">
</li-datatable-select>
```

Boas práticas:

- mantenha `Filters`, `DatatableSettings` e `searchInFields` estáveis;
- trate o carregamento de dados no pai, como num datatable comum;
- use `valueKey` para persistir apenas IDs, e não o mapa inteiro, quando o
  campo fizer parte de formulários;
- use `@ViewChild` apenas para ações programáticas pontuais, como
  `clear()` ou `setSelectedItem(...)`.

O demo de referência está em
[datatable_select_page.dart](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/datatable_select/datatable_select_page.dart)
e
[datatable_select_page.html](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/datatable_select/datatable_select_page.html).

### Select and Multi-Select

`li-select` e `li-multi-select` cobrem dois cenários próximos, mas com contratos
diferentes:

- `li-select`: uma única escolha com busca inline, suporte a `dataSource` ou
  opções projetadas e integração com `ngModel`;
- `li-multi-select`: múltiplos valores selecionados, normalmente renderizados
  como badges no trigger.

`li-select` aceita `List<Map<String, dynamic>>` ou `DataFrame` em
`[dataSource]`, além de projeção manual com `li-option`. As chaves principais
são `labelKey`, `valueKey` e `disabledKey`. O componente é pesquisável por
padrão, usa overlay com Popper e já evita loops ignorando `dataSource`
semanticamente idêntico.

```html
<li-select
  [dataSource]="users"
  labelKey="name"
  valueKey="id"
  placeholder="Selecione"
  [(ngModel)]="selectedUserId">
</li-select>
```

`li-multi-select` segue a mesma ideia, mas o `ngModel` passa a ser uma
`List<dynamic>`:

```html
<li-multi-select
  [dataSource]="channelOptions"
  labelKey="label"
  valueKey="id"
  [(ngModel)]="selectedChannels">
</li-multi-select>
```

Também é possível projetar as opções manualmente:

```html
<li-multi-select [(ngModel)]="targets">
  <li-multi-option value="portal">Portal</li-multi-option>
  <li-multi-option value="api">API</li-multi-option>
  <li-multi-option value="batch">Batch</li-multi-option>
</li-multi-select>
```

Boas práticas:

- não recrie `dataSource` em getters usados no template;
- mantenha listas estáveis e atualize apenas o `ngModel`;
- para coleções muito grandes, trate busca/paginação no componente pai;
- prefira `li-datatable-select` quando a escolha exigir tabela, colunas e
  busca estruturada.

Referências:

- [custom_select.dart](/c:/MyDartProjects/limitless_ui/lib/src/components/custom_select/custom_select.dart)
- [multi_select_page.dart](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/multi_select/multi_select_page.dart)
- [multi_select_page.html](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/multi_select/multi_select_page.html)

### Typeahead

`li-typeahead` cobre o espaço entre `li-select` e `li-datatable-select`: busca local ou assíncrona com sugestões, highlight configurável, navegação por teclado e integração com `[(ngModel)]`.

Recursos principais:

- `dataSource` com `List` estável ou `DataFrame`
- `searchCallback` para busca remota retornando `Future` ou lista imediata
- `minLength`, `maxResults` e `debounceMs`
- `openOnFocus`, `editable`, `selectOnExact` e `showHint`
- `inputFormatter` e `resultFormatter` para listas de objetos
- `resultMarkupBuilder` para itens com markup rico
- `LiTypeaheadConfig` para defaults locais e `LiTypeaheadHighlightComponent` para highlight reutilizável

```html
<li-typeahead
  [searchCallback]="remoteCitySearch"
  [inputFormatter]="cityInputFormatter"
  [resultMarkupBuilder]="remoteResultMarkup"
  [debounceMs]="220"
  placeholder="Search for a city"
  [(ngModel)]="selectedCity">
</li-typeahead>
```

Para listas de mapas:

```html
<li-typeahead
  [dataSource]="cities"
  labelKey="name"
  valueKey="code"
  [inputFormatter]="cityInputFormatter"
  [resultFormatter]="cityResultFormatter"
  [(ngModel)]="selectedCityCode">
</li-typeahead>
```

Para defaults locais via config:

```dart
@Component(
  selector: 'typeahead-config-host',
  providers: [ClassProvider(LiTypeaheadConfig)],
  template: '''
    <li-typeahead [dataSource]="options"></li-typeahead>
  ''',
)
class TypeaheadConfigHostComponent {
  TypeaheadConfigHostComponent(LiTypeaheadConfig config) {
    config.minLength = 0;
    config.openOnFocus = true;
    config.showHint = true;
  }
}
```

Boas práticas:

- mantenha o `dataSource` estável no componente pai
- prefira `searchCallback` quando a API remota já expõe busca filtrada
- use `editable=false` quando o valor final precisar vir apenas da lista
- prefira `li-datatable-select` quando a escolha exigir tabela, paginação ou ordenação

O demo dedicado está em
[typeahead_page.dart](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/typeahead/typeahead_page.dart)
e
[typeahead_page.html](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/typeahead/typeahead_page.html).

### Treeview Select

`li-treeview-select` cobre seleção hierárquica em dropdown quando um `select`
plano perde contexto. Ele funciona com árvore estática via `[data]` ou com
carregamento em partes via `[pageLoader]`.

Recursos principais:

- seleção única ou múltipla com `[(ngModel)]`
- `pageLoader` com `TreeViewLoadRequest(parent, offset, limit, searchTerm)`
- `labelBuilder` para customizar o rótulo padrão
- `canSelectNode` para impor regra de seleção por item
- `template[liTreeviewSelectNode]` e `template[liTreeviewSelectTrigger]`
  para custom render
- `closeOnSelect`, `showClearButton`, `searchable` e `openOnFocus`

```html
<li-treeview-select
  [pageLoader]="loadTreeChunk"
  [pageSize]="20"
  [multiple]="true"
  [closeOnSelect]="false"
  [labelBuilder]="buildNodeLabel"
  [canSelectNode]="canSelectLeafNode"
  [(ngModel)]="selectedValues">

  <template liTreeviewSelectTrigger let-ctx>
    <span *ngIf="ctx.selectedNodes.isEmpty">{{ ctx.placeholder }}</span>
    <span *ngIf="ctx.selectedNodes.isNotEmpty">
      {{ ctx.selectedNodes.length }} item(ns)
    </span>
  </template>

  <template liTreeviewSelectNode let-ctx>
    <strong>{{ ctx.node.treeViewNodeLabel }}</strong>
    <small>{{ ctx.node.value }}</small>
  </template>
</li-treeview-select>
```

Boas práticas:

- use `[data]` quando a árvore já estiver carregada em memória
- use `[pageLoader]` para catálogos grandes ou organogramas profundos
- deixe a busca remota no backend usando `request.searchTerm`
- use `canSelectNode` para regras como “somente folhas” ou “somente recebe processo”

Referências:

- [treeview_select_component.dart](/c:/MyDartProjects/limitless_ui/lib/src/components/treeview/treeview_select_component.dart)
- [treeview_page.dart](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/treeview/treeview_page.dart)
- [treeview_page.html](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/treeview/treeview_page.html)

### Tabs

`li-tabsx` organiza conteúdo por seções sem trocar de rota. Ele suporta
`type="tabs"` ou `type="pills"`, posicionamento horizontal ou lateral,
`[justified]`, abas desabilitadas e cabeçalhos projetados com
`template li-tabx-header`.

```html
<li-tabsx type="pills" placement="left" [justified]="true">
  <li-tabx header="Tokens" [active]="true">
    <div class="p-3">Conteúdo</div>
  </li-tabx>

  <li-tabx [disabled]="true" header="Bloqueada"></li-tabx>
</li-tabsx>
```

Use tabs para documentação, formulários segmentados e painéis administrativos.
Quando o conteúdo da aba ficar pesado ou muito aninhado, isole-o em
subcomponentes.

O demo mostra pills laterais, abas desabilitadas e cabeçalho customizado em
[tabs_page.dart](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/tabs/tabs_page.dart)
e
[tabs_page.html](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/tabs/tabs_page.html).

### Date Picker

`li-date-picker` cobre seleção simples de data com integração direta a
`[(ngModel)]`, além de restrições por intervalo e mudança de locale.

Recursos principais:

- `minDate` e `maxDate` para limitar o intervalo permitido;
- `locale` para formatos como `pt_BR` e `en_US`;
- `placeholder`, `value` e `disabled`;
- bom encaixe com formulários AngularDart sem precisar de wrapper extra.

```html
<li-date-picker
  [(ngModel)]="selectedDate"
  [minDate]="minDate"
  [maxDate]="maxDate"
  locale="en_US"
  [placeholder]="'Select a date'">
</li-date-picker>
```

O demo cobre quatro cenários úteis: uso padrão, data restrita, locale inglês e
campo desabilitado. Referências:

- [date_picker_page.dart](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/date_picker/date_picker_page.dart)
- [date_picker_page.html](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/date_picker/date_picker_page.html)

### Modal with lazy content

```html
<li-modal
  title-text="Heavy report"
  size="xtra-large"
  [lazyContent]="true"
  [dialogScrollable]="true">
  <li-datatable
    [data]="reportFrame"
    [settings]="reportSettings"
    [dataTableFilter]="filters"
    (dataRequest)="loadReport($event)">
  </li-datatable>
</li-modal>
```

This pattern is useful for expensive content such as datatables, forms with many controls, or projected content that should not exist in the DOM until the dialog opens.

### Toast

`li-toast` cobre o caso declarativo inline. Ele renderiza o markup do toast,
expõe `show()`, `hide()` e `isOpen`, e suporta `header`, `body`,
`helperText`, `badgeText`, `iconClass`, `autohide`, `delay`, `dismissible`,
`pauseOnHover` e `rounded`.

```html
<li-toast
  header="Processamento concluído"
  body="A operação foi concluída com sucesso."
  helperText="agora"
  iconClass="ph-check-circle"
  [autohide]="false">
</li-toast>
```

Para notificações globais em overlay, o pacote também expõe
`LiToastService` + `li-toast-stack`:

```html
<li-toast-stack [service]="toastService" placement="top-end"></li-toast-stack>
```

```dart
final toastService = LiToastService();

toastService.show(
  header: 'Atualização disponível',
  body: 'Há uma nova ação aguardando revisão.',
  badgeText: 'Update',
  iconClass: 'ph-bell-ringing',
  toastClass: 'border-primary',
  headerClass: 'bg-primary text-white border-primary',
  autohide: false,
);
```

`placement` do stack aceita `top-end`, `top-start`, `bottom-end`,
`bottom-start`, `top-center` e `bottom-center`.

Boas práticas:

- use `li-toast` quando o toast fizer parte do layout da própria página;
- use `LiToastService` + `li-toast-stack` para mensagens globais;
- mantenha `autohide: false` apenas para mensagens que exigem ação humana;
- quando precisar de layout mais rico, projete markup próprio dentro de
  `li-toast`.

O demo dedicado está em
[toast_page.dart](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/toast/toast_page.dart)
e
[toast_page.html](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/toast/toast_page.html).

### Popover

O pacote expõe duas camadas de popover:

- helpers imperativos, como `SimplePopover.showWarning(...)` e
  `SweetAlertPopover.showPopover(...)`;
- API declarativa com `LiPopoverComponent` e `LiPopoverDirective`.

Use popover quando o conteúdo precisa ser mais rico que um tooltip, mas ainda
não justifica um modal. O componente declarativo suporta `click`, `hover` e
controle manual via `@ViewChild`, além de `TemplateRef`, `container="body"` e
hooks de posicionamento.

```html
<button
  class="btn btn-outline-primary"
  [liPopover]="'Mais contexto sem sair da tela'"
  popoverTitle="Detalhes"
  triggers="click">
  Abrir popover
</button>
```

Quando o conteúdo crescer demais, migre para modal, drawer ou card expansível.
O demo mais rico está em
[popover_page.dart](/c:/MyDartProjects/limitless_ui/example/lib/src/pages/popover/popover_page.dart).

### Dropdown Menu

`li-dropdown-menu` é um menu de ações compacto orientado por lista de opções.
Ele serve bem para botões de overflow, ações por card e menus pequenos de
toolbar, sem a complexidade do módulo dropdown completo.

Cada item é um `LiDropdownMenuOption` com:

- `value`
- `label`
- `iconClass`
- `description`
- `disabled`
- `divider`

O componente também suporta `triggerLabel`, `triggerIconClass`, `triggerClass`,
`menuClass`, `placement`, `rounded`, `showCaret` e `closeOnSelect`.

```dart
final options = <LiDropdownMenuOption>[
  const LiDropdownMenuOption(
    value: 'edit',
    label: 'Editar',
    iconClass: 'ph-pencil-simple',
  ),
  const LiDropdownMenuOption(
    value: 'archive',
    label: 'Arquivar',
    description: 'Remove da listagem principal',
  ),
];
```

```html
<li-dropdown-menu
  [options]="options"
  value="edit"
  triggerLabel="Ações"
  placement="dropend"
  (valueChange)="onAction($event)">
</li-dropdown-menu>
```

O menu fecha em clique externo, `Escape` ou seleção, conforme `closeOnSelect`.
Referência principal:
[dropdown_menu_component.dart](/c:/MyDartProjects/limitless_ui/lib/src/components/dropdown_menu/dropdown_menu_component.dart).

### Scrollspy

```html
<div liScrollSpy [spyOn]="scrollContainer">
  <section liScrollSpyFragment="overview">...</section>
  <section liScrollSpyFragment="api">...</section>
</div>

<nav liScrollSpyMenu>
  <a liScrollSpyItem="overview">Overview</a>
  <a liScrollSpyItem="api">API</a>
</nav>
```

Use `LiScrollSpyService` directly when you need imperative control over fragment observation or scrolling.

### Currency formatting

```dart
final brFormatter = CurrencyInputFormatter(
  locale: 'pt_BR',
  currencyCode: 'BRL',
);
final usdFormatter = CurrencyInputFormatter(
  locale: 'en_US',
  currencyCode: 'USD',
);

final cents = brFormatter.minorUnitsFromText('1.234,56');
final displayBr = brFormatter.formatForDisplay(cents);
final displayUsd = usdFormatter.formatForDisplay(123456);
```

## Development

Install dependencies:

```bash
dart pub get
```

Run static analysis:

```bash
dart analyze
```

Run VM-safe tests:

```bash
dart test test/br_currency_input_formatter_test.dart test/lite_xlsx_test.dart test/tine_pdf_test.dart
```

Run browser and AngularDart tests in Chrome:

```bash
dart run build_runner test -- -p chrome -j 1 test/alerts/alert_component_test.dart test/alerts/li_alert_component_test.dart test/progress_component_test.dart test/datatable/li_datatable_component_test.dart test/accordion/li_accordion_directive_test.dart test/dropdown/li_dropdown_directive_test.dart test/modal/li_modal_component_test.dart test/nav/li_nav_directive_test.dart test/popover/li_popover_component_test.dart test/scrollspy/li_scrollspy_directive_test.dart test/typeahead/li_typeahead_component_test.dart test/toast/li_toast_component_test.dart test/tooltip/li_tooltip_directive_test.dart
```

Validate the package before publishing:

```bash
dart pub publish --dry-run
```

## AngularDart Template Performance

- Do not expose getters used by templates that recreate lists, maps, style objects, or view models on every change-detection pass.
- In particular, avoid patterns like a getter returning a fresh collection consumed by `*ngFor`, because AngularDart will treat the result as changed and can rebuild rich component trees continuously.
- Prefer stable references: `final` fields, cached lazy fields, or explicit recomputation only when the source input actually changes.
- Avoid binding dynamically recreated objects in templates such as `[style]="..."`, inline maps, or other expressions that allocate on every pass unless the value is intentionally memoized.
- The popover example hit this exact failure mode when `palettePopovers` recreated 11 items in a getter, which caused the page to churn and freeze the browser.

## AngularDart Change Detection Notes

- In this repository, do not treat `ChangeDetectorRef.markForCheck()` as a generic fix for async rendering bugs on components using the default `ChangeDetectionStrategy.checkAlways`.
- Practical rule: `markForCheck()` is dependable mainly when the relevant host tree is `ChangeDetectionStrategy.onPush`. On default-strategy pages, it may not resolve lazy async rendering by itself.
- For async content inside deferred UI such as accordion bodies, tabs, and modals, prefer one of these options:
  - use `ChangeDetectionStrategy.onPush` intentionally and then rely on `markForCheck()`;
  - force a synchronous refresh only in a narrow, justified point;
  - or change the flow so data is available before the deferred child component is created.
- Always validate the rendered DOM after the async update. If the UI still only refreshes after an extra click, the change-detection issue is not solved.
- Specific lesson learned in this repository: a lazy accordion body that projects async content from the host must not be wrapped by an `onPush` accordion item unless that projection path is explicitly handled. The datatable demo only started rendering correctly after removing `ChangeDetectionStrategy.onPush` from [accordion_item_component.dart](/c:/MyDartProjects/limitless_ui/lib/src/components/accordion/accordion_item_component.dart), because the projected lazy body needed to receive host-side async updates after first render.

## Demo application

The demo app under [example](/c:/MyDartProjects/limitless_ui/example) now includes dedicated routes for:

- accordion
- datatable
- dropdown
- modal
- nav
- popover
- scrollspy
- toast
- typeahead
- tooltip

Use the demo app as the reference for real template usage, especially for lazy accordion bodies, lazy modal content, scrollspy menus, and overlay components that depend on browser geometry.

## Release checklist

- `dart analyze`
- VM-safe tests
- Chrome/browser tests
- `dart pub publish --dry-run`
- clean git state before publishing

## Notes

- The demo application is in [example](/c:/MyDartProjects/limitless_ui/example).
- The package is not intended for Flutter or server-side Dart.
- Some components depend on data structures from `essential_core`.
