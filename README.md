# limitless_ui

[![CI](https://github.com/insinfo/limitless_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/insinfo/limitless_ui/actions/workflows/ci.yml)

Reusable AngularDart UI components, directives, and browser helpers for applications built on the Limitless visual language and Bootstrap-based CSS: https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/css/all.min.css https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/icons/phosphor/2.0.3/styles.min.css.

This package is browser-only. It depends on `dart:html`, `ngdart`, `ngforms` and `ngrouter`.

## Contract overview

`limitless_ui` is a generic AngularDart UI library, but part of its higher-level data UI is built on top of `essential_core`, which was extracted as a reusable and framework-agnostic foundation.

This means the package remains generic, but it is not fully standalone for every component family.

This library has two explicit usage layers:

- Generic UI layer: components such as alerts, buttons, modals, tabs, toast, tooltip, popover, checkbox, radio, toggle, rating, file upload and the base `li-input` can be consumed with `limitless_ui` alone.
- Shared-foundation layer: `li-datatable`, `li-datatable-select`, `li-select`, `li-multi-select`, `li-typeahead` and treeview-related components were designed to reuse generic models and utilities from `essential_core`. This is part of the documented contract of the library, not an accidental implementation detail.

For consumers using the data-oriented components above, `essential_core` should be understood as shared infrastructure, not as an application-specific dependency.

Some form value accessors in this package rely on internal `ngforms` APIs and behavior because AngularDart does not expose all hooks needed by the library through stable public APIs. Because of that, keep `ngdart`, `ngforms` and `ngrouter` tightly pinned, prefer exact or very narrow version constraints in consuming apps, avoid automatic upgrades, and always run focused tests for the value accessors first during framework upgrades.

Demo page: https://insinfo.github.io/limitless_ui/

## Publication status

The package is prepared for publication and currently versioned as `1.0.0-dev.2`, because it still depends on AngularDart pre-release packages:

- `ngdart: ^8.0.0-dev.4`
- `ngforms: ^5.0.0-dev.3`
- `ngrouter: ^4.0.0-dev.3`

For applications consuming `limitless_ui`, treat these versions as compatibility-critical. In particular:

- keep `ngdart`, `ngforms` and `ngrouter` well pinned in the application;
- prefer exact versions or very narrow ranges for these packages in consumers of `limitless_ui`;
- do not enable automated dependency upgrades for these packages without manual validation;
- when testing an upgrade, run the value accessor tests first, because they are usually the first area to break.

Publication metadata is configured in [pubspec.yaml](pubspec.yaml) and CI is defined in [.github/workflows/ci.yml](.github/workflows/ci.yml).

## Installation

### Generic usage

```yaml
dependencies:
  limitless_ui: ^1.0.0-dev.2
```

### When using data-oriented components backed by `essential_core`

If the application will use `li-datatable`, `li-datatable-select`, `li-select`, `li-multi-select`, `li-typeahead` or treeview components, install both packages. In this setup, `essential_core` is the shared data/model foundation reused by the UI layer:

```yaml
dependencies:
  limitless_ui: ^1.0.0-dev.2
  essential_core: ^1.0.0
```

For local development:

```yaml
dependencies:
  limitless_ui:
    path: ../limitless_ui
  essential_core:
    path: ../essential_core
```

## Import

### Generic UI imports

```dart
import 'package:limitless_ui/limitless_ui.dart';
```

### Imports for data-oriented APIs

Use `limitless_ui` for the widgets and `essential_core` for the shared data structures used by the higher-level components:

```dart
import 'package:limitless_ui/limitless_ui.dart';
import 'package:essential_core/essential_core.dart';
```

## Theme and icons

The package follows the Limitless visual language, but some visual affordances are provided by the theme CSS rather than component Dart code.

The demo application loads Limitless CSS plus the Phosphor icon font in [example/web/index.html](example/web/index.html). One practical detail is the dropdown caret: if your theme renders `.dropdown-toggle::after` with a glyph that does not exist in the loaded icon font, the caret will appear broken.

For this repository, the canonical icon mapping is always the Phosphor stylesheet loaded from `https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/icons/phosphor/2.0.3/styles.min.css`.

Do not treat the icon `content` values embedded inside `https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/css/all.min.css` as the source of truth. That theme bundle still contains selectors authored against an older Phosphor codepoint map, so components that depend on pseudo-element icons may need local `content` overrides to stay visually correct with the newer `2.0.3` font file actually loaded by the demo.

`LiWizardComponent` is one of those cases: the wizard step icons are overridden in [lib/src/components/wizard/wizard_component.scss](lib/src/components/wizard/wizard_component.scss) so the `current`, `done` and `error` states resolve against Phosphor `2.0.3` instead of the older codepoints baked into `all.min.css`.

The demo fixes that with a global override in [example/web/style.scss](example/web/style.scss):

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

### Why `sass_builder` is a regular dependency

`limitless_ui` declares `sass_builder` in `dependencies`, not `dev_dependencies`, because this package publishes components whose files under `lib/` depend on Sass compilation during the consumer application's build.

This is required for two reasons:

- Dart `dev_dependencies` do not propagate to package consumers.
- `sass_builder` is auto-applied to dependents, so the builder must be available as a direct runtime dependency of the package that exposes `.scss` files requiring compilation during the downstream build.

In practice, if `sass_builder` existed only in `dev_dependencies` here, it would work for developing `limitless_ui` itself, but not reliably when an application depends on `limitless_ui` and needs the package's `lib/**/*.scss` sources compiled into the `.css` files referenced by AngularDart `styleUrls`.

Practical rule:

- Published library that requires a builder so assets under `lib/` work when consumed: keep that builder in `dependencies`.
- Root application that only compiles its own local Sass files: keep `sass_builder` in `dev_dependencies`.

## Included modules

- Inputs: checkbox, radio, toggle, rating, file upload, currency input, date picker, time picker, date range picker, color picker, select, multi-select, typeahead.
- Data display: datatable, datatable select, tree view, highlight.
- Structure: accordion, collapse, buttons, carousel, modal, tabs, nav, wizard, breadcrumbs, pagination, offcanvas, floating action button.
- Overlay and menus: dropdown, dropdown menu, tooltip, popover, sweet alert, notification toast.
- Navigation helpers: scrollspy service and directives.
- Utilities: HTML directives, form value accessors, pipes, PDF generator and XLSX generator.

## Utility directives and pipes

Beyond visual components, the package also exposes small browser-oriented helpers that are now available from the public barrel in [lib/limitless_ui.dart](lib/limitless_ui.dart):

- `CpfMaskDirective`: applies the `xxx.xxx.xxx-xx` mask while the user types.
- `CnpjMaskDirective`: applies the `xx.xxx.xxx/xxxx-xx` mask while the user types.
- `CpfFormatterPipe`: formats CPF values as `XXX.XXX.XXX-XX` or returns digits only.
- `CpfHiddenPipe`: keeps only the first or last four CPF characters visible.
- `HideStringPipe`: preserves a visible prefix and masks the rest of a string.
- `TextMaskDirective`, `OnlyNumberDirective` and `CustomHrefDirective`: helpers for generic masked inputs, digit-only fields and attribute-driven href synchronization.
- `CustomNumberValueAccessor`, `DateTimeValueAccessor` and `MinMaxDirective`: form helpers for `<input type="number">`, `<input type="datetime-local">` and constrained numeric inputs.

In `ngdart` 8, template pipes are invoked through `$pipe` instead of the legacy `value | pipeName` syntax. That applies both to built-in pipes such as `date` and to custom pipes registered in the component.

Example:

```dart
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';

@Component(
  selector: 'demo-form-helpers',
  template: '''
    <input cpfMask [(ngModel)]="cpf">
    <input type="number" min="1" max="10" [(ngModel)]="quantity">
    <input type="datetime-local" [(ngModel)]="scheduledAt">

    <p>{{ $pipe.date(scheduledAt, 'medium') }}</p>
    <p>{{ $pipe.cpfFormatter(cpf) }}</p>
    <p>{{ $pipe.cpfHidden(cpf, 'asteriskStart') }}</p>
    <p>{{ $pipe.hideString(note, 3, '#') }}</p>
  ''',
  directives: [coreDirectives, formDirectives, CpfMaskDirective],
  pipes: [commonPipes, CpfFormatterPipe, CpfHiddenPipe, HideStringPipe],
)
class DemoFormHelpersComponent {
  String cpf = '';
  String quantity = '1';
  DateTime? scheduledAt;
  String note = 'abcdef';
}
```

## Generic vs `essential_core`-backed components

Use these groups as the practical adoption boundary:

- Generic components: alerts, buttons, accordion, collapse, modal, tabs, nav, tooltip, popover, toast, scrollspy, checkbox, radio, toggle, rating, file upload, date picker, date range picker, currency helpers and the base `li-input`.
- `essential_core`-backed components: `li-datatable`, `li-datatable-select`, `li-select`, `li-multi-select`, `li-typeahead`, `li-treeview-select`, `LiTreeViewComponent` and related data/selection helpers.

The second group reuses `Filters`, `DataFrame`, tree data structures, and related contracts from `essential_core`.

## Public API highlights

The barrel export in [lib/limitless_ui.dart](lib/limitless_ui.dart) exposes these API families:

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
- Dropdown menu:
  `LiDropdownMenuComponent`, `LiDropdownMenuOption`.
- Breadcrumbs:
  `LiBreadcrumbComponent`, `LiBreadcrumbItemDirective`,
  `LiBreadcrumbStartDirective`, `LiBreadcrumbEndDirective`.
- Nav:
  `LiNavDirective`, `LiNavItemDirective`, `LiNavLinkDirective`,
  `LiNavOutletDirective`, `LiNavContentDirective`, `LiNavConfig`.
- Pagination:
  `LiPaginationComponent`, `liPaginationDirectives`,
  `LiPaginationEllipsisDirective`, `LiPaginationFirstDirective`,
  `LiPaginationLastDirective`, `LiPaginationNextDirective`,
  `LiPaginationNumberDirective`, `LiPaginationPagesDirective`,
  `LiPaginationPreviousDirective`.
- Wizard:
  `LiWizardComponent`, `LiWizardStepComponent`, `LiWizardStepChange`,
  `LiWizardStepHeaderContext`, `LiWizardActionsContext`,
  `liWizardDirectives`.
- Offcanvas:
  `LiOffcanvasComponent`, `LiOffcanvasService`, `LiOffcanvasRef`,
  `LiOffcanvasDismissReason`, `LiOffcanvasHeaderDirective`,
  `LiOffcanvasFooterDirective`.
- Popover and tooltip:
  `LiPopoverComponent`, `LiPopoverDirective`, `LiPopoverConfig`,
  `LiTooltipComponent`, `LiTooltipDirective`, `LiTooltipConfig`.
- Scrollspy:
  `LiScrollSpyService`, `LiScrollSpyDirective`,
  `LiScrollSpyFragmentDirective`, `LiScrollSpyItemDirective`,
  `LiScrollSpyMenuDirective`, `LiScrollSpyConfig`.
- Modal:
  `LiModalComponent` with lazy content support.
- Page header:
  `LiPageHeaderComponent`, `LiPageHeaderBreadcrumbItemDirective`,
  `LiPageHeaderBottomDirective`, `LiPageHeaderActionsDirective`,
  `liPageHeaderDirectives`.
- Toast:
  `LiToastComponent`, `LiToastStackComponent`, `LiToastService`.
- Color picker:
  `LiColorPickerComponent`, `LiColorPickerEvent`, plus palette inputs,
  selection-history inputs, and `pickerShow`, `pickerHide`, `pickerChange`,
  `pickerMove`, `pickerDragStart`, `pickerDragStop` streams.
- Floating action button:
  `LiFabComponent`, `LiFabAction`, `LiFabShortcut`,
  `LiFabTriggerDirective`, `LiFabActionDirective`.
- Typeahead:
  `LiTypeaheadComponent`, `LiTypeaheadItem`, `LiTypeaheadSelectItemEvent`, `LiTypeaheadConfig`, `LiTypeaheadHighlightComponent`.
- Selection controls and upload:
  `LiCheckboxComponent`, `LiRadioComponent`, `LiToggleComponent`,
  `LiRatingComponent`, `LiRatingConfig`, `LiFileUploadComponent`,
  `LiFileSelectDirective`, `LiFileDropDirective`, `LiFileType`.
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
- Refined the toast demo presentation, including a more compact rounded toast variant.
- Added CI coverage for toast browser tests and documented the AngularDart `.scss` to `.css` stylesheet convention used in this repository.
- Added `li-typeahead` for autocomplete-style selection with local filtering, keyboard navigation and `ngModel`.
- Expanded `li-typeahead` with async search, rich result markup, a separate highlight component and injectable defaults via `LiTypeaheadConfig`.
- Added `li-checkbox`, `li-radio`, `li-toggle`, `li-rating` and `li-file-upload`, plus low-level file select/drop directives.
- Expanded the demo app with dedicated pages for selection controls, rating, file upload, breadcrumbs, pagination, offcanvas, floating action button, highlight and color picker.
- Added `li-treeview-select` for dropdown selection over hierarchical data.
- Expanded `li-treeview-select` with lazy page loading, remote search term forwarding through `TreeViewLoadRequest.searchTerm`, `multiple`, `labelBuilder`, `canSelectNode` and projected templates for trigger and node rendering.
- Renamed legacy package paths from `br_currency_input` to `currency_input` and aligned select/multi-select internals with the current public API layout.
- Added `li-breadcrumb`, `li-pagination`, `li-offcanvas`, `li-fab` and `li-color-picker` to the public API and demo application.
- Expanded `li-color-picker` with palette support, selection history, toggleable palette-only mode and `LiColorPickerEvent` streams.
- Extended `li-tabsx` with Limitless 4-aligned `underline`, `overline` and `solid` variants, plus richer demo coverage for justified layouts, projected headers, `lazyLoad` and `destroyOnHide`.
- Added `li-wizard` and `li-wizard-step` for guided multi-step flows styled against the native Limitless 4 `.wizard` markup.
- Expanded `li-wizard` with `[headerTemplate]` and `[actionsTemplate]`, plus `LiWizardStepHeaderContext` and `LiWizardActionsContext` so hosts can customize labels and footer actions without breaking the native step icons.
- Refined the example shell with sidebar filtering, navbar route search powered by `li-typeahead`, a shared breadcrumb component based on `li-breadcrumb`, richer tabs examples, a dedicated scrollbar stylesheet and a wizard/form wizard page.
- Updated the demo i18n bootstrap to detect the browser locale and default to Portuguese only when the language starts with `pt`, falling back to English otherwise.
- Added an AngularDart documentation link to the example overview and bundled `site_ngdart` for local and GitHub Pages publication.
- Expanded the package documentation with toast usage, stack placement, AngularDart stylesheet guidance, dependency/contract notes and richer component coverage.
- Expanded browser and integration coverage for breadcrumbs, offcanvas, pagination, typeahead, treeview select, selection controls, rating, file upload flows, directives, form integrations and wizard navigation.
- Stabilized focus-sensitive browser scenarios across input, offcanvas and multi-select interactions.
- Added GitHub Actions Pages deployment plus `scripts/prepare-pages.ps1` to publish a combined artifact with the example app and `site_ngdart`.
- Improved GitHub Pages path rewriting and pretty URL generation for repository-prefixed `site_ngdart` hosting.

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
      Alert content
    </li-alert>
  ''',
  directives: [coreDirectives, LiAlertComponent],
)
class DemoAlertComponent {}
```

### Datatable

`li-datatable` covers the library's most common administrative data flow: field search, pagination, sorting, row selection, export, responsive mobile collapse, and switching between table and grid views without duplicating the data source.

The component revolves around three objects:

- `Filters`: limit, offset, search, and sorting for the current request.
- `DataFrame<T>`: the returned collection plus `totalRecords`.
- `DatatableSettings`: columns and visual behavior for the table or grid.

Most useful features:

- column-targeted search with `searchInFields`;
- events such as `(dataRequest)`, `(searchRequest)`, and `(limitChange)` for server-driven flows;
- columns with `enableSorting`, `sortingBy`, `hideOnMobile`, `textAlign`, `nowrap`, `width`, and custom classes;
- per-cell styling with `cellStyleResolver` and per-row styling with `rowStyleResolver`;
- grid mode with `gridMode`, `gridTemplateColumns`, `gridGap`, and `customCardBuilder`;
- built-in XLSX and PDF export support.

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

For denser visual layouts, the same dataset can be reused in grid mode:

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

Column, row, and grid customization:

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

Best practices:

- keep `Filters`, `DatatableSettings`, and `searchInFields` stable instead of recreating them in getters;
- use `hideOnMobile` on secondary columns to feed the responsive collapse path;
- reserve `customCardBuilder` for grids that genuinely need to diverge from the default layout;
- for heavy content, prefer loading the datatable on demand inside a lazy accordion body or modal with `lazyContent`.

The most complete demo is in [example/lib/src/pages/datatable/datatable_page.dart](example/lib/src/pages/datatable/datatable_page.dart) and [example/lib/src/pages/datatable/datatable_page.html](example/lib/src/pages/datatable/datatable_page.html).

### Input

`li-input` is the base form field for text, number, search, password, textarea, masks, and prefix or suffix addons. It integrates with `[(ngModel)]` and now also exposes field-level DOM-style outputs so the host can react without dropping back to a native `<input>`.

Most relevant inputs and features:

- `label`, `helperText`, `placeholder`, `floatingLabel`, `multiline`, and `rows`;
- `prefixText`, `suffixText`, `prefixIconClass`, and `suffixIconClass`;
- `mask`, `inputMode`, `maxLength`, `readonly`, `disabled`, and numeric attributes such as `min`, `max`, and `step`;
- `inputBlur`, `inputFocus`, `inputClick`, `inputKeydown`, and `inputEnter`.

```html
<li-input
  label="CGM"
  type="number"
  (inputBlur)="loadPersonByCode($event.target.value)"
  (inputEnter)="loadPersonByCode($event.target.value)"
  [(ngModel)]="cgm">
</li-input>
```

### Datatable Select

`li-datatable-select` is the right fit when a simple select is not enough because users need to search, paginate, and sort before choosing an item. It combines a `form-select`-style trigger with an internal `li-modal` that hosts a `li-datatable`.

Main flow:

- the host provides `Filters`, `DataFrame<T>`, and `DatatableSettings`;
- the component emits `(dataRequest)` whenever the internal table needs data;
- clicking a row selects the item, updates the trigger label, and closes the modal;
- the value can be controlled with `[(ngModel)]` or `(currentValueChange)`.

Most relevant inputs and features:

- `labelKey` and `valueKey` to separate the visible label from the persisted value;
- `itemLabelBuilder` and `itemValueBuilder` when the list is typed and the host does not want to rely on `Map` keys;
- `compareWith` when the selected value is an object or when rows may be recreated by new backend responses;
- `searchInFields` for the search selector inside the modal;
- projected `template liDatatableSelectModalContent` for replacing the internal modal body with arbitrary content;
- modal context helpers `ctx.select(item)` and `ctx.selectItem(label, value)`;
- `modalSize`, `title`, `placeholder`, `disabled`, and `fullScreenOnMobile`;
- public methods such as `clear()`, `setSelectedItem(...)`, and `selectedLabel`.

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

For typed rows and object comparison:

```html
<li-datatable-select
  [settings]="personSettings"
  [dataTableFilter]="personFilter"
  [data]="personFrame"
  [searchInFields]="personSearchFields"
  [itemLabelBuilder]="personLabel"
  [itemValueBuilder]="personId"
  [compareWith]="comparePersonById"
  [(ngModel)]="selectedPerson"
  (dataRequest)="loadPeople($event)">
</li-datatable-select>
```

For arbitrary modal content such as an existing search page:

```html
<li-datatable-select
  [itemLabelBuilder]="cgmLabel"
  [itemValueBuilder]="cgmValue"
  [compareWith]="compareCgm"
  [(ngModel)]="selectedPerson">
  <template liDatatableSelectModalContent let-ctx>
    <consultar-cgm-page
      [insideModal]="true"
      [filtroAtivo]="true"
      (onSelect)="ctx.select($event)">
    </consultar-cgm-page>
  </template>
</li-datatable-select>
```

Best practices:

- keep `Filters`, `DatatableSettings`, and `searchInFields` stable;
- handle data loading in the parent, just as you would for a regular datatable;
- use `valueKey` to persist only IDs instead of the full map when the field belongs to a form;
- use `itemLabelBuilder` and `itemValueBuilder` for strongly typed entities;
- use `ctx.selectItem(label, value)` when the modal content already knows the final pair and does not need to emit a full row object;
- use `@ViewChild` only for focused programmatic actions such as `clear()` or `setSelectedItem(...)`.

The reference demo is in [example/lib/src/pages/datatable_select/datatable_select_page.dart](example/lib/src/pages/datatable_select/datatable_select_page.dart) and [example/lib/src/pages/datatable_select/datatable_select_page.html](example/lib/src/pages/datatable_select/datatable_select_page.html).

### Select and Multi-Select

`li-select` and `li-multi-select` cover adjacent but distinct scenarios:

- `li-select`: a single choice with inline search, support for `dataSource` or projected options, and `ngModel` integration;
- `li-multi-select`: multiple selected values, typically rendered as badges in the trigger.

`li-select` accepts `List<Map<String, dynamic>>` or `DataFrame` through `[dataSource]`, and it also supports manual projection with `li-option`. The main keys are `labelKey`, `valueKey`, and `disabledKey`. The component is searchable by default, uses a Popper-based overlay, and already avoids loops by ignoring semantically identical `dataSource` updates.

```html
<li-select
  [dataSource]="users"
  labelKey="name"
  valueKey="id"
  [compareWith]="compareUserById"
  (modelChange)="selectedUserModel = $event"
  placeholder="Selecione"
  [(ngModel)]="selectedUser">
</li-select>
```

When `valueKey` is defined, `[(ngModel)]` continues to store only that reduced value. Use `(modelChange)` when the form should persist an id or code, but the screen also needs the full selected instance:

```html
<li-select
  [dataSource]="classificacoes"
  labelKey="nom_classificacao"
  valueKey="cod_classificacao"
  [(ngModel)]="filtros.codClassificacao"
  (modelChange)="classificacaoSelecionada = $event">
</li-select>
```

`li-multi-select` follows the same idea, but `ngModel` becomes a `List<dynamic>` or a typed object list when combined with `compareWith`:

```html
<li-multi-select
  [dataSource]="channelOptions"
  labelKey="label"
  valueKey="id"
  [compareWith]="compareChannelById"
  (modelChange)="selectedChannelModels = $event"
  [(ngModel)]="selectedChannels">
</li-multi-select>
```

For the multi-select, `(modelChange)` emits the list of selected instances while `[(ngModel)]` may continue to hold only the reduced values:

```html
<li-multi-select
  [dataSource]="people"
  labelKey="name"
  valueKey="id"
  [(ngModel)]="selectedPeopleIds"
  (modelChange)="selectedPeople = $event">
</li-multi-select>
```

You can also project options manually:

```html
<li-multi-select [(ngModel)]="targets">
  <li-multi-option value="portal">Portal</li-multi-option>
  <li-multi-option value="api">API</li-multi-option>
  <li-multi-option value="batch">Batch</li-multi-option>
</li-multi-select>
```

Best practices:

- do not recreate `dataSource` in getters used by the template;
- keep lists stable and update only `ngModel`;
- use `compareWith` whenever object identity is not stable across reloads;
- use `modelChange` when you need the selected model instance without changing the reduced value stored by `ngModel`;
- for very large collections, handle search and pagination in the parent component;
- prefer `li-datatable-select` when the choice requires a table, columns, and structured search.

### Page Header

`li-pg-header` packages the common administrative page shell: title, optional prefix, breadcrumb row, projected actions, and an optional projected bottom row for tabs, filters, or toolbars.

Supported selectors and migration aliases:

- `li-pg-header`
- `li-pg-crumb-item`
- `li-pg-breadcrumb-item`
- `[liPgHeaderActions]`
- `[liPgHeaderBottom]`

Main features:

- `titlePrefix`, `titlePrefixSeparator`, `title`, and `titleClass`;
- breadcrumb items from `[breadcrumbItems]` or projected `li-pg-crumb-item`;
- projected action slot with `[liPgHeaderActions]`;
- projected second row with `[liPgHeaderBottom]`;
- compatibility input `showFavoriteAction` for gradual migrations, while the preferred package pattern is to project the real action content explicitly.

```html
<li-pg-header titlePrefix="Protocolo" title="Incluir Processo">
  <li-pg-crumb-item label="Protocolo"></li-pg-crumb-item>
  <li-pg-crumb-item label="Incluir Processo" [active]="true"></li-pg-crumb-item>

  <div liPgHeaderActions class="collapse d-lg-block ms-lg-auto">
    <acao-favorita-comp></acao-favorita-comp>
  </div>
</li-pg-header>
```

References:

- [lib/src/components/select/custom_select.dart](lib/src/components/select/custom_select.dart)
- [example/lib/src/pages/multi_select/multi_select_page.dart](example/lib/src/pages/multi_select/multi_select_page.dart)
- [example/lib/src/pages/multi_select/multi_select_page.html](example/lib/src/pages/multi_select/multi_select_page.html)

### Typeahead

`li-typeahead` sits between `li-select` and `li-datatable-select`: local or async search with suggestions, configurable highlighting, keyboard navigation, and `[(ngModel)]` integration.

Main features:

- `dataSource` with a stable `List` or `DataFrame`
- `searchCallback` for remote search returning a `Future` or immediate list
- `minLength`, `maxResults`, and `debounceMs`
- `openOnFocus`, `editable`, `selectOnExact`, and `showHint`
- `inputFormatter` and `resultFormatter` for object lists
- `resultMarkupBuilder` for rich result markup
- `LiTypeaheadConfig` for local defaults and `LiTypeaheadHighlightComponent` for reusable highlighting

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

For map-based lists:

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

For local defaults via config:

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

Best practices:

- keep `dataSource` stable in the parent component
- prefer `searchCallback` when the remote API already exposes filtered search
- use `editable=false` when the final value must come only from the list
- prefer `li-datatable-select` when the choice requires a table, pagination, or sorting

The dedicated demo is in [example/lib/src/pages/typeahead/typeahead_page.dart](example/lib/src/pages/typeahead/typeahead_page.dart) and [example/lib/src/pages/typeahead/typeahead_page.html](example/lib/src/pages/typeahead/typeahead_page.html).

### Treeview Select

`li-treeview-select` covers hierarchical selection in a dropdown when a flat select loses too much context. It works with a static tree via `[data]` or incremental loading via `[pageLoader]`.

Main features:

- single or multiple selection with `[(ngModel)]`
- `pageLoader` with `TreeViewLoadRequest(parent, offset, limit, searchTerm)`
- `labelBuilder` to customize the default label
- `canSelectNode` to enforce per-item selection rules
- `template[liTreeviewSelectNode]` and `template[liTreeviewSelectTrigger]` for custom rendering
- `closeOnSelect`, `showClearButton`, `searchable`, and `openOnFocus`

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
      {{ ctx.selectedNodes.length }} item(s)
    </span>
  </template>

  <template liTreeviewSelectNode let-ctx>
    <strong>{{ ctx.node.treeViewNodeLabel }}</strong>
    <small>{{ ctx.node.value }}</small>
  </template>
</li-treeview-select>
```

Best practices:

- use `[data]` when the tree is already loaded in memory
- use `[pageLoader]` for large catalogs or deep hierarchies
- keep remote search on the backend through `request.searchTerm`
- use `canSelectNode` for rules such as leaf-only selection

References:

- [lib/src/components/treeview/treeview_select_component.dart](lib/src/components/treeview/treeview_select_component.dart)
- [example/lib/src/pages/treeview/treeview_page.dart](example/lib/src/pages/treeview/treeview_page.dart)
- [example/lib/src/pages/treeview/treeview_page.html](example/lib/src/pages/treeview/treeview_page.html)

### Tabs

`li-tabsx` organizes content into sections without changing routes. It supports `type="tabs"`, `type="highlight"`, `type="underline"`, `type="overline"`, `type="solid"`, or `type="pills"`, horizontal or side placement, `[justified]`, disabled tabs, `[lazyLoad]`, `[destroyOnHide]`, and projected headers with `template li-tabx-header`.

```html
<li-tabsx type="underline" [justified]="true">
  <li-tabx header="Summary" [active]="true">
    <div class="p-3">Content</div>
  </li-tabx>

  <li-tabx header="Activity"></li-tabx>
  <li-tabx [disabled]="true" header="Disabled"></li-tabx>
</li-tabsx>
```

Use tabs for documentation, segmented forms, and administrative panels. `highlight`, `underline`, `overline`, and `solid` map directly to native Limitless 4 tab styles, while `pills` remains useful for side navigation. Use `[lazyLoad]` when inactive panes are expensive to create and `[destroyOnHide]` when they should leave the DOM after tab changes. When tab content becomes heavy or deeply nested, move it into subcomponents.

The demo shows side pills, Limitless 4 variants, disabled tabs, and custom headers in [example/lib/src/pages/tabs/tabs_page.dart](example/lib/src/pages/tabs/tabs_page.dart) and [example/lib/src/pages/tabs/tabs_page.html](example/lib/src/pages/tabs/tabs_page.html).

### Wizard

`li-wizard` covers guided multi-step flows with native Limitless 4 `.wizard` markup, projected `li-wizard-step` bodies, `[(activeIndex)]`, linear navigation, clickable visited steps, guard callbacks through `[beforeChange]` and `[beforeFinish]`, custom step labels through `[headerTemplate]`, and custom footer actions through `[actionsTemplate]`.

```html
<template #wizardHeader let-ctx>
  <span class="d-block">{{ ctx.step.title }}</span>
  <small class="text-muted">{{ ctx.isDone ? 'Completed' : 'Current flow' }}</small>
</template>

<template #wizardActions let-ctx>
  <div class="d-flex justify-content-between gap-3 flex-wrap">
    <span>Step {{ ctx.activeIndex + 1 }} of {{ ctx.stepCount }}</span>
    <div class="d-flex gap-2">
      <button *ngIf="ctx.hasPrevious" type="button" [class]="ctx.previousButtonClass" (click)="ctx.goPrevious()">
        {{ ctx.previousLabel }}
      </button>
      <button *ngIf="!ctx.isLastStep" type="button" [class]="ctx.nextButtonClass" (click)="ctx.goNext()">
        {{ ctx.nextLabel }}
      </button>
      <button *ngIf="ctx.isLastStep" type="button" [class]="ctx.finishButtonClass" (click)="ctx.finish()">
        {{ ctx.finishLabel }}
      </button>
    </div>
  </div>
</template>

<li-wizard
  [(activeIndex)]="currentStep"
  [beforeChange]="canMoveToStep"
  [beforeFinish]="canFinishWizard"
  [actionsTemplate]="wizardActions"
  (finish)="completeWizard(
    $event,
  )">
  <li-wizard-step title="Account" [headerTemplate]="wizardHeader">
    <div class="p-3">Account details</div>
  </li-wizard-step>

  <li-wizard-step
    title="Profile"
    subtitle="Optional details"
    [headerTemplate]="wizardHeader">
    <div class="p-3">Profile details</div>
  </li-wizard-step>

  <li-wizard-step title="Review">
    <div class="p-3">Review and submit</div>
  </li-wizard-step>
</li-wizard>
```

`LiWizardStepHeaderContext` exposes `step`, `index`, `displayIndex`, `isCurrent`, `isDone`, `hasError`, and `isDisabled`. `LiWizardActionsContext` exposes `goPrevious()`, `goNext()`, `finish()`, `hasPrevious`, `isLastStep`, `activeIndex`, `stepCount`, and the current labels/classes for the footer buttons. The wizard keeps rendering the numeric marker internally, so custom headers do not break the native Limitless current/done/error icon states.

The dedicated wizard/form wizard example is in [example/lib/src/pages/wizard/wizard_page.dart](example/lib/src/pages/wizard/wizard_page.dart) and [example/lib/src/pages/wizard/wizard_page.html](example/lib/src/pages/wizard/wizard_page.html).

### Color Picker

`li-color-picker` integrates with `[(ngModel)]` and can be used as a compact swatch trigger or a richer picker with alpha, palette rows, selection history, and event streams for open, close, change, move, drag start, and drag stop.

```html
<li-color-picker
  [(ngModel)]="brandColor"
  [showPalette]="true"
  [showSelectionPalette]="true"
  [maxSelectionPalette]="6"
  [togglePaletteOnly]="true"
  (pickerChange)="onColorChange(
    $event,
  )">
</li-color-picker>
```

Use `palette` to provide curated swatches, `showSelectionPalette` to keep a short history of recent selections, and `hideAfterPaletteSelect` when the interaction should behave like a fast swatch picker.

### Date Picker

`li-date-picker` covers simple date selection with direct `[(ngModel)]` integration, plus range constraints and locale switching.

Main features:

- `minDate` and `maxDate` to constrain the allowed range;
- `locale` for formats such as `pt_BR` and `en_US`;
- `placeholder`, `value`, and `disabled`;
- straightforward integration into AngularDart forms without an extra wrapper.

```html
<li-date-picker
  [(ngModel)]="selectedDate"
  [minDate]="minDate"
  [maxDate]="maxDate"
  locale="en_US"
  [placeholder]="'Select a date'">
</li-date-picker>
```

The demo covers four useful scenarios: default usage, restricted date ranges, English locale, and a disabled field. References:

- [example/lib/src/pages/date_picker/date_picker_page.dart](example/lib/src/pages/date_picker/date_picker_page.dart)
- [example/lib/src/pages/date_picker/date_picker_page.html](example/lib/src/pages/date_picker/date_picker_page.html)

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

This pattern is useful for expensive content such as datatables, large forms, or projected content that should not exist in the DOM until the dialog opens.

### Toast

`li-toast` covers the inline declarative case. It renders the toast markup, exposes `show()`, `hide()`, and `isOpen`, and supports `header`, `body`, `helperText`, `badgeText`, `iconClass`, `autohide`, `delay`, `dismissible`, `pauseOnHover`, and `rounded`.

```html
<li-toast
  header="Processing completed"
  body="The operation completed successfully."
  helperText="now"
  iconClass="ph-check-circle"
  [autohide]="false">
</li-toast>
```

For global overlay notifications, the package also exposes `LiToastService` plus `li-toast-stack`:

```html
<li-toast-stack [service]="toastService" placement="top-end"></li-toast-stack>
```

```dart
final toastService = LiToastService();

toastService.show(
  header: 'Update available',
  body: 'A new item is waiting for review.',
  badgeText: 'Update',
  iconClass: 'ph-bell-ringing',
  toastClass: 'border-primary',
  headerClass: 'bg-primary text-white border-primary',
  autohide: false,
);
```

`placement` accepts `top-end`, `top-start`, `bottom-end`, `bottom-start`, `top-center`, and `bottom-center`.

Best practices:

- use `li-toast` when the toast is part of the page layout itself;
- use `LiToastService` plus `li-toast-stack` for global messages;
- keep `autohide: false` only for messages that require human action;
- when you need richer layout, project custom markup inside `li-toast`.

The dedicated demo is in [example/lib/src/pages/toast/toast_page.dart](example/lib/src/pages/toast/toast_page.dart) and [example/lib/src/pages/toast/toast_page.html](example/lib/src/pages/toast/toast_page.html).

### Popover

The package exposes two popover layers:

- imperative helpers such as `SimplePopover.showWarning(...)` and `SweetAlertPopover.showPopover(...)`;
- a declarative API with `LiPopoverComponent` and `LiPopoverDirective`.

Use a popover when the content needs to be richer than a tooltip but still does not justify a modal. The declarative component supports `click`, `hover`, manual control via `@ViewChild`, `TemplateRef`, `container="body"`, and positioning hooks.

```html
<button
  class="btn btn-outline-primary"
  [liPopover]="'More context without leaving the screen'"
  popoverTitle="Details"
  triggers="click">
  Open popover
</button>
```

When the content grows too large, move to a modal, drawer, or expandable card. The richest demo is in [example/lib/src/pages/popover/popover_page.dart](example/lib/src/pages/popover/popover_page.dart).

### Dropdown Menu

`li-dropdown-menu` is a compact action menu driven by an option list. It fits overflow buttons, per-card actions, and small toolbar menus without the complexity of the full dropdown module.

Each item is a `LiDropdownMenuOption` with:

- `value`
- `label`
- `iconClass`
- `description`
- `disabled`
- `divider`

The component also supports `triggerLabel`, `triggerIconClass`, `triggerClass`,
`menuClass`, `placement`, `rounded`, `showCaret`, and `closeOnSelect`.

```dart
final options = <LiDropdownMenuOption>[
  const LiDropdownMenuOption(
    value: 'edit',
    label: 'Edit',
    iconClass: 'ph-pencil-simple',
  ),
  const LiDropdownMenuOption(
    value: 'archive',
    label: 'Archive',
    description: 'Remove from the main listing',
  ),
];
```

```html
<li-dropdown-menu
  [options]="options"
  value="edit"
  triggerLabel="Actions"
  placement="dropend"
  (valueChange)="onAction($event)">
</li-dropdown-menu>
```

The menu closes on outside click, `Escape`, or selection depending on `closeOnSelect`. Main reference: [lib/src/components/dropdown_menu/dropdown_menu_component.dart](lib/src/components/dropdown_menu/dropdown_menu_component.dart).

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
dart test test/currency_input_formatter_test.dart test/lite_xlsx_test.dart test/tine_pdf_test.dart
```

Run browser and AngularDart tests in Chrome:

```bash
dart run build_runner test -- -p chrome -j 1 test/alerts/alert_component_test.dart test/alerts/li_alert_component_test.dart test/progress_component_test.dart test/datatable/li_datatable_component_test.dart test/accordion/li_accordion_directive_test.dart test/dropdown/li_dropdown_directive_test.dart test/modal/li_modal_component_test.dart test/nav/li_nav_directive_test.dart test/popover/li_popover_component_test.dart test/scrollspy/li_scrollspy_directive_test.dart test/typeahead/li_typeahead_component_test.dart test/toast/li_toast_component_test.dart test/tooltip/li_tooltip_directive_test.dart test/wizard/li_wizard_component_test.dart
```

When validating dependency upgrades for `ngdart`, `ngforms`, or `ngrouter`, add focused runs for the form value accessors and input bindings before broader test suites. Those accessors depend on internal `ngforms` APIs and behavior due to framework limitations, and they are usually the first compatibility boundary to break.

Recommended first-pass upgrade command:

```bash
dart run build_runner test -- -p chrome -j 1 test/input/li_input_component_test.dart test/multi_select/li_multi_select_focus_test.dart
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
- Specific lesson learned in this repository: a lazy accordion body that projects async content from the host must not be wrapped by an `onPush` accordion item unless that projection path is explicitly handled. The datatable demo only started rendering correctly after removing `ChangeDetectionStrategy.onPush` from [lib/src/components/accordion/accordion_item_component.dart](lib/src/components/accordion/accordion_item_component.dart), because the projected lazy body needed to receive host-side async updates after first render.

## Demo application

The demo app under [example](example) now includes dedicated routes for accordion, breadcrumbs, color picker, datatable, datatable select, dropdown, fab, file upload, inputs, modal, nav, offcanvas, page header, pagination, popover, rating, scrollspy, select, multi-select, tabs, toast, treeview, typeahead, tooltip, wizard, and selection-control examples.

Use the demo app as the reference for real template usage, especially for lazy accordion bodies, lazy modal content, scrollspy menus, and overlay components that depend on browser geometry.

## Release checklist

- `dart analyze`
- VM-safe tests
- Chrome/browser tests
- `dart pub publish --dry-run`
- clean git state before publishing

## Notes

- The demo application is in [example](example).
- The package is not intended for Flutter or server-side Dart.
- `essential_core` is the shared generic foundation reused by the data-oriented component family of this package: `li-datatable`, `li-datatable-select`, `li-select`, `li-multi-select`, `li-typeahead` and treeview-related components.
- Some value accessors are intentionally coupled to internal `ngforms` APIs and behavior due to framework limitations, so framework package upgrades must be deliberate, pinned, and test-driven.
