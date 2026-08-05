# limitless_ui

[![CI](https://github.com/insinfo/limitless_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/insinfo/limitless_ui/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/insinfo/limitless_ui/branch/main/graph/badge.svg)](https://codecov.io/gh/insinfo/limitless_ui)
[![pub package](https://img.shields.io/pub/v/limitless_ui.svg)](https://pub.dev/packages/limitless_ui)

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

The package is prepared for publication and currently versioned as `1.0.0-dev.33`, because it still depends on AngularDart pre-release packages:

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
  limitless_ui: ^1.0.0-dev.33
```

### When using data-oriented components backed by `essential_core`

If the application will use `li-datatable`, `li-datatable-select`, `li-select`, `li-multi-select`, `li-typeahead` or treeview components, install both packages. In this setup, `essential_core` is the shared data/model foundation reused by the UI layer:

```yaml
dependencies:
  limitless_ui: ^1.0.0-dev.33
  essential_core: ^1.2.0
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

### Narrow imports for isolated modules

`li-pdf-viewer` and `li-quill-text-editor` are intentionally exported through separate barrels so host applications can opt into the heavier PDF.js and Quill integrations without depending on the main barrel for those surfaces.

```dart
import 'package:limitless_ui/pdf_viewer.dart';
import 'package:limitless_ui/quill_text_editor.dart';
```

## Theme and icons

The package follows the Limitless visual language, but some visual affordances are provided by the theme CSS rather than component Dart code.

The demo application now also ships extra color themes (`blu`, `pink`, `orange`, and `retro`) on top of the default light/dark switch, plus broader scrollbar theming for the sidebar, content panes, dropdowns, modals, and dense form surfaces. These themes are example-app concerns rather than package APIs, but they are useful references when adapting Limitless-derived tokens for a host application.

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

## Overlay components inside modals

Recent picker/overlay updates in `limitless_ui` are focused on modal-safe behavior:

- `li-tooltip` and `li-popover` now keep body-mounted overlays above modal/backdrop stacks.
- `li-date-picker`, `li-date-range-picker`, `li-time-picker`, and `li-color-picker` support adaptive mobile presentation via `mobilePresentation` and `mobileHeightBreakpoint`. Date, date-range, and time pickers default to fullscreen mobile modals so picker panels keep a stable size while the user selects values.
- The example modal page includes dedicated overlay labs (fields, pickers, and stacked modal-on-modal scenarios) to visually validate z-index and viewport clamping.

For modal demos in the example app, overlay field surfaces were simplified to remove decorative wrapper backgrounds, keeping focus on overlay behavior instead of container chrome.

## Modal `contentTemplate` and OnPush change detection

`LiModalComponent` moves its host element to `document.body` in `ngOnInit()`. This means the modal DOM lives outside the normal AngularDart component tree. When using `[contentTemplate]` with `ngTemplateOutlet`, the embedded view is instantiated inside the modal's view hierarchy, which is now orphaned from the declaring component's change detection path.

### The problem

If the declaring component and the projected content both use `ChangeDetectionStrategy.onPush`, calling `markForCheck()` on the declaring component will not reach the embedded view inside the body-mounted modal. The result is that async state updates (e.g., loading spinners, validation results) appear stuck until the modal is closed and reopened.

### Recommended workaround

Instead of passing a `TemplateRef` via `[contentTemplate]`, project the content directly inside the `<li-modal>` tags as `<ng-content>`. Projected content (`<ng-content>`) is checked as part of the **declaring** component's change detection cycle, regardless of where the host modal DOM is placed.

When the same content needs to render in two modes (e.g., inline panel on desktop, modal on mobile), use separate instances guarded by `*ngIf` instead of sharing a single `TemplateRef`:

```html
<!-- Desktop: inline content -->
<aside class="panel--desktop">
  <my-panel-body *ngIf="!isMobileViewport" [data]="data"></my-panel-body>
</aside>

<!-- Mobile: projected content in modal -->
<li-modal #mobileModal [title-text]="title" [lazyContent]="true">
  <my-panel-body *ngIf="isMobileViewport" [data]="data"></my-panel-body>
</li-modal>
```

This ensures that `markForCheck()` on the parent correctly propagates to the panel body component in both modes.

### When `contentTemplate` is safe

`contentTemplate` works correctly when:

- the projected content does not use `onPush`, or
- state updates are not expected while the modal is open, or
- the content is purely static.

For dynamic content with `onPush` that updates while the modal is open, prefer `<ng-content>` projection.

## Offcanvas DOM, Limitless CSS, and projected scroll areas

`li-offcanvas` is not just a visual wrapper around projected content. It composes three layers:

- the Limitless/Bootstrap base offcanvas rules coming from `all.css`;
- the AngularDart wrapper and lifecycle owned by `LiOffcanvasComponent`;
- the projected content supplied by the consumer application.

Understanding that composition is essential for debugging sizing and scrolling bugs.

### DOM contract

At runtime, `LiOffcanvasComponent` appends its host element to `document.body` in `ngOnInit()`. The effective DOM is therefore body-level, even if the template declared the component deep inside another page.

The relevant structure is:

```html
<li-offcanvas>
  <div class="li-offcanvas-shell">
    <div class="li-offcanvas-backdrop"></div>
    <div class="offcanvas offcanvas-start li-offcanvas-size-sm show">
      <div class="offcanvas-header">...</div>
      <div class="offcanvas-body or custom bodyClass wrapper">
        <projected-content-host></projected-content-host>
      </div>
    </div>
  </div>
</li-offcanvas>
```

The key implication is that parent component SCSS with emulated encapsulation should not be treated as the primary tool for styling the internal panel. Consumers should prefer the offcanvas API itself.

### How `all.css` participates

The host application usually loads the Limitless/Bootstrap bundle where:

- `.offcanvas` is a fixed flex-column panel;
- `.offcanvas.offcanvas-start` and friends position the panel and read width/height from CSS variables;
- `.offcanvas-body` is `flex-grow: 1` and `overflow-y: auto`.

`limitless_ui` builds on top of that contract by adding:

- `.li-offcanvas-shell`;
- `.li-offcanvas-backdrop`;
- `li-offcanvas-size-sm|lg|xl|full` width/height helpers;
- `.li-offcanvas-contents` when `enableBodyWrapper = false`.

In other words, the library does not replace the Limitless offcanvas model. It extends it.

### Wrapper behavior

Three inputs define how projected content is inserted:

- `enableDefaultBodyClass`: when `true`, the internal wrapper gets `offcanvas-body`.
- `enableBodyWrapper`: when `false`, the internal wrapper stays in the DOM but becomes `display: contents` through `.li-offcanvas-contents`.
- `bodyClass`: extra classes applied to the internal wrapper.

This distinction matters when the consumer wants the projected content to own scrolling.

### Internal scroll is a height-chain problem

The most common offcanvas mistake is assuming that adding `overflow-y: auto` to the innermost node is enough. It is not.

If the projected content host does not have a valid height chain, the scroll node expands to the full content height and never becomes scrollable.

When a consumer wants a dedicated internal scroll region inside projected content, the recommended pattern is:

1. Keep the offcanvas body wrapper as a flex shell.
2. Give the projected host an explicit height or flex contract.
3. Inside the projected component, use a flex-column shell plus a dedicated `flex: 1 1 auto` scroll node.

Example:

```html
<li-offcanvas
  position="start"
  size="sm"
  [enableHeader]="false"
  [enableDefaultBodyClass]="false"
  bodyClass="p-0 d-flex flex-column h-100 overflow-hidden">
  <my-scrollable-panel class="h-100"></my-scrollable-panel>
</li-offcanvas>
```

```scss
:host {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
  overflow: hidden;
}

.panel-shell {
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  min-height: 0;
}

.panel-scroll {
  flex: 1 1 auto;
  min-height: 0;
  overflow-y: auto;
}
```

### Practical debugging checklist

When an offcanvas does not scroll correctly, inspect these nodes in DevTools in this exact order:

1. `.offcanvas`
2. internal body wrapper
3. projected content host
4. projected shell
5. intended scroll node

If the intended scroll node has the same height as the full content, the bug is not the overflow declaration itself. The bug is missing vertical constraint higher in the chain.

### Guidance for future examples and fixes

- Use offcanvas API inputs first; do not reach for parent-emulated styles to control the panel.
- Keep examples explicit about where scrolling lives.
- If the goal is an app-like side panel with sticky filters and an internal timeline, document the height chain in the example instead of only showing the final CSS.
- Prefer `enableDefaultBodyClass = false` plus a custom body flex shell when the projected child should own the scroll area.

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

- Inputs: checkbox, radio, toggle, rating, file upload, currency input, password input, token field, date picker, time picker, date range picker, color picker, select, multi-select, typeahead.
- Data display: datatable, datatable select, tree view, highlight, PDF viewer.
- Editors and authoring: Quill rich text editor.
- Tagging workflows: tag filter, tag editor, tag manager.
- Structure: accordion, collapse, buttons, carousel, modal, tabs, nav, wizard, breadcrumbs, pagination, offcanvas, floating action button.
- Overlay and menus: dropdown, dropdown menu, tooltip, popover, sweet alert, notification toast.
- Navigation helpers: scrollspy service and directives.
- Utilities: HTML directives, form value accessors, pipes, PDF generator and XLSX generator.

## Form control sizing

Input-like components follow Bootstrap/Limitless sizing classes through a `size` input. Use `size="sm"` for compact fields, `size="lg"` for large fields, or omit it for the default height.

```html
<li-select size="sm" [dataSource]="statusOptions"></li-select>
<li-date-picker size="lg" [(ngModel)]="dueDate"></li-date-picker>
<li-currency-input size="sm" [(ngModel)]="amount"></li-currency-input>
```

The sizing contract maps to the native theme classes:

- `form-control-sm` / `form-control-lg` on text-like inputs.
- `form-select-sm` / `form-select-lg` on select-like triggers.
- `input-group-sm` / `input-group-lg` when the component renders an addon/trigger group.

Supported components include `li-input`, `li-password-input`, `li-select`, `li-multi-select`, `li-datatable-select`, `li-date-picker`, `li-date-range-picker`, `li-time-picker`, `li-treeview-select`, `li-typeahead`, `li-currency-input`, and `li-tag-filter`.

## User selection events and automation hooks

Interactive selection controls expose two different event layers:

- `currentValueChange`: emits when the component value changes, including changes driven by `ngModel`, `writeValue`, or other programmatic model synchronization.
- `userValueChange`: emits only when the user changes the value through the component UI.

Use `userValueChange` when a screen must trigger side effects only after real user intent, such as loading dependent fields, clearing child filters, auditing a manual choice, or avoiding backend requests during form hydration.

```html
<li-select
  [dataSource]="statusOptions"
  labelKey="label"
  valueKey="id"
  [(ngModel)]="filters.status"
  (currentValueChange)="syncStatusModel($event)"
  (userValueChange)="reloadAfterUserStatusChange($event)">
</li-select>
```

The `userValueChange` output is available on `li-select`, `li-multi-select`, `li-datatable-select`, `li-date-picker`, `li-date-range-picker`, `li-time-picker`, `li-typeahead`, `li-treeview-select`, and `li-rating`.

`li-select` also preserves the written `ngModel` value when its `dataSource` or projected `li-option` items arrive later. For record hydration flows, use `setSelectedItemByValue(...)` or `clearSelectedItem(...)` with `isCallNgModelChange: false` and `isCallCurrentValueChange: false` to synchronize the visual selection without emitting model/current-value events. These programmatic APIs do not emit `userValueChange`.

### Open lifecycle events

Controls that open a dropdown or a modal expose `openChange`, a `Stream<bool>` that emits `true` on open and `false` on close:

`li-select`, `li-multi-select`, `li-treeview-select`, `li-tag-filter`, `li-datatable-select`, `li-date-picker`, `li-date-range-picker`, and `li-time-picker`. `li-color-picker` predates this and exposes the same state through `pickerShow`/`pickerHide`.

Only real transitions are emitted: reopening an already open dropdown stays silent, as does closing an already closed one. Nothing is emitted while the component is being destroyed, so a component held through a `ViewChild` and subscribed to directly does not receive a spurious `false` during teardown.

The main use is loading the option list on demand instead of upfront, so a screen does not pay for a field the user may never open:

```html
<li-select
  [dataSource]="classifications"
  labelKey="label"
  valueKey="id"
  (openChange)="onClassificationsOpenChange($event)"
  [(ngModel)]="filters.classificationId">
</li-select>
```

```dart
bool _classificationsLoaded = false;

Future<void> onClassificationsOpenChange(bool open) async {
  if (!open || _classificationsLoaded) {
    return;
  }
  _classificationsLoaded = true;
  classifications = await _service.listClassifications();
}
```

The "already loaded" guard lives in the host on purpose: the library does not decide caching policy. Drop the guard to refetch on every open.

### Vetoing an open with `beforeOpen`

`li-select` and `li-multi-select` also emit `beforeOpen` right before the dropdown opens, while it is still closed. Calling `preventDefault()` on the event keeps it closed and suppresses the matching `openChange`, which is useful to gate opening on a permission check, a confirmation, or a required field elsewhere in the form:

```html
<li-select
  [dataSource]="cityOptions"
  (beforeOpen)="requireStateFirst($event)"
  [(ngModel)]="address.cityId">
</li-select>
```

```dart
void requireStateFirst(LiBeforeOpenEvent event) {
  if (address.stateId == null) {
    event.preventDefault();
    toastService.warning('Select a state first.');
  }
}
```

The stream is synchronous, following the same shape as `liNav`'s `LiNavChangeEvent`. `preventDefault()` must therefore be called from the handler itself: after an `await` it runs too late, because the dropdown has already opened. To gate opening on asynchronous work, prevent the default, run the work, and call `openDropdown()` when it resolves.

### Redrawing a `li-datatable` after mutating an item in place

`li-datatable` renders from rows it built during the previous draw, and caches them under a signature that only tracks the `DataFrame` identity, its length, and the layout inputs. Mutating an item instance therefore changes nothing the component can observe: the row keeps the value read from `toMap()` at build time and the screen stays stale.

This is the common case for an action column whose button flips a field of the row's own object:

```dart
@ViewChild('orgaoTable')
LiDataTableComponent? orgaoTable;

final orgaos = <Orgao>[...];

late final DataFrame<Orgao> orgaoTableData =
    DataFrame<Orgao>(items: orgaos, totalRecords: orgaos.length);

Future<void> toggleAtivo(Orgao orgao) async {
  orgao.ativo = !orgao.ativo;
  await orgaoService.updateAtivo(orgao.id, orgao.ativo);

  // The list and the DataFrame are the same objects — no Angular binding
  // changed. refresh() is what rebuilds the rows from the current data.
  orgaoTable?.refresh();
}
```

`refresh()` bumps the internal cache revision and schedules the rebuild on the next animation frame. Row selection and responsive row expansion survive it, keyed the same way as virtual-scroll selection (`DatatableSettings.rowKeyResolver`), so toggling a field does not clear checkboxes that a delete/bulk action depends on. Sorting, paging, and the active search filter are untouched.

The same applies to cells built in Dart. A `customRenderHtml` column produces a detached element with its own listeners; `refresh()` rebuilds that element from the mutated instance, and the listener bound to the new element keeps working:

```dart
DatatableCol(
  key: 'habilitar',
  title: 'Habilitar/Desabilitar',
  customRenderHtml: (map, item) {
    final orgao = item as Orgao;
    final div = DivElement();
    div.append(ButtonElement()
      ..text = orgao.ativo ? 'Desabilitar' : 'Habilitar'
      ..onClick.listen((event) {
        event.stopPropagation(); // keeps the datatable rowClick from firing
        toggleAtivo(orgao);
      }));
    return div;
  },
),
```

Pass `refresh(immediate: true)` to rebuild synchronously, so `rows` and `renderedRows` already carry the new values when the call returns — useful when the caller inspects them right away, or when the rebuild must not be deferred past the current turn. Writing the rebuilt rows to the DOM still happens on the next change-detection pass in both cases; call `ChangeDetectorRef.detectChanges()` when the DOM must be up to date within the same turn.

`update()` is kept as an alias for `refresh()`. Reassigning the input (`table.data = items`) also forces the rebuild, since the setter invalidates the same cache — but it is only necessary when the frame itself changed.

A full screen built around this is in the example app under **Dados → Lista de Órgãos** (`#/lista-orgao`), with a selector that switches between `refresh()`, `refresh(immediate: true)`, reassigning `data`, reloading from the service, and doing nothing.

### Loading a `li-datatable-select` list on demand

The `li-datatable-select` modal renders its content lazily, so the inner datatable only exists once the modal opens. That datatable never asks for data on its own — it emits `dataRequest` only when the user paginates, sorts, or searches — so a screen that simply stops preloading the list would open an empty modal.

Set `requestDataOnOpen` to have the component emit `dataRequest` with its current `dataTableFilter` the first time the modal opens:

```html
<li-datatable-select
  [settings]="settings"
  [dataTableFilter]="filter"
  [data]="users"
  [requestDataOnOpen]="true"
  (dataRequest)="loadUsers($event)"
  [(ngModel)]="form.responsibleId">
</li-datatable-select>
```

Only the first open emits, so reopening keeps the data already loaded. Use `openChange` instead to reload on every open.

`li-modal` itself exposes `open` alongside the `close` it already had. Since `lazyContent` only creates the projected content once the modal is open, `open` is the earliest point at which a consumer can load data for that content:

```html
<li-modal #forward title-text="Forward" [lazyContent]="true" (open)="loadHierarchy()">
  <org-chart-dropdown [(ngModel)]="target"></org-chart-dropdown>
</li-modal>
```

### Custom trigger templates

Select-like controls can render a custom trigger template while keeping the component-owned wrapper responsible for click, keyboard focus, disabled state, data hooks, and Popper positioning. This is useful when the trigger should look like a Limitless badge, toolbar button, chip, or compact filter pill instead of a full input.

Supported projected trigger directives:

- `liSelectTrigger` on `li-select`.
- `liMultiSelectTrigger` on `li-multi-select`.
- `liDatatableSelectCustomTrigger` on `li-datatable-select` for replacing the whole trigger. The older `liDatatableSelectTrigger` still customizes only the inner content of the default trigger.
- `liDatePickerTrigger` on `li-date-picker`.
- `liDateRangePickerTrigger` on `li-date-range-picker`.
- `liTimePickerTrigger` on `li-time-picker`.

The trigger context is stable per component instance and exposes the current display state plus actions such as `open()`, `close()`, `toggle()`, and `clear($event)`. Prefer `ctx.clear($event)` for clear buttons inside the custom trigger so the click does not bubble back to the wrapper.

```html
<li-date-range-picker
  [start]="periodStart"
  [end]="periodEnd"
  (startChange)="periodStart = $event"
  (endChange)="periodEnd = $event">
  <template liDateRangePickerTrigger let-ctx>
    <span class="badge bg-primary d-inline-flex align-items-center gap-1">
      <i class="ph ph-calendar-blank"></i>
      {{ ctx.hasValue ? ctx.displayValue : ctx.placeholder }}
    </span>
  </template>
</li-date-range-picker>
```

Selection-oriented controls also render stable browser automation hooks:

- `data-label` identifies the component part, for example `li_select_toggle`, `li_ms_item_*`, `li_dts_apply`, `li_dp_day`, or `li_rate_star_4`.
- `data-value` exposes the current or option value where that value is useful for tests.
- state attributes such as `data-open`, `data-current-value`, and `aria-expanded` are available on controls where open/selected state matters.

These hooks are part of the testability contract for browser automation. Prefer them over styling classes, translated labels, generated ids, or brittle DOM depth selectors.

For a complete Puppeteer guide using `puppeteer: ^3.16.0`, including reusable test helpers and the hook reference table, see [doc/browser_automation_puppeteer.md](doc/browser_automation_puppeteer.md).

Form controls also accept an optional `name` input and reflect it on the
interactive DOM element, such as the inner input, combobox trigger, slider, or
file upload input. The value is passed through as provided by the host
application. Use `ngControl`/`ngModel` for AngularDart form registration and
`name` for browser metadata, accessibility tooling, and stable E2E selectors.

```html
<li-select
  name="status"
  ngControl="status"
  [dataSource]="statusOptions"
  labelKey="label"
  valueKey="id"
  [(ngModel)]="filters.status">
</li-select>
```

```dart
await clickFirstVisible(page, '[data-label="li_select_toggle"]');
await clickFirstVisible(
  page,
  '[data-label^="li_select_item_"][data-value="approved"]',
);
await waitForAttributeMatching(
  page,
  '[data-label="li_select"]',
  'data-value',
  (value) => value == 'approved',
);
```

Dialog overlays expose the same contract for browser automation:

- SweetAlert: wait for `li_sa_root`/`li_sa_popup` with
  `data-open="true"`, then target `li_sa_confirm`,
  `li_sa_cancel`, `li_sa_close`, `li_sa_input`,
  `li_sa_validation`, and `li_sa_input_option`.
- `li-modal`: wait for `[data-label="li_mdl"][data-open="true"]`, then
  target parts such as `li_mdl_dialog`, `li_mdl_content`,
  `li_mdl_header`, `li_mdl_body`, `li_mdl_footer`, `li_mdl_close`,
  and `li_mdl_backdrop`.
- SimpleDialog helpers: wait for `li_sd_root` or
  `li_sd_modal`, then target `li_sd_confirm`,
  `li_sd_cancel`, `li_sd_input`, and
  `li_sd_validation`.

```dart
await clickFirstVisible(page, '[data-label="li_sa_confirm"]');
await waitForSelectorMatching(
  page,
  '[data-label="li_sa_popup"][data-type="question"][data-open="true"]',
);
await page.type(
  '[data-label="li_sa_input"][data-value="text"]',
  'batch-42',
);
```

## Utility directives and pipes

Beyond visual components, the package also exposes small browser-oriented helpers that are now available from the public barrel in [lib/limitless_ui.dart](lib/limitless_ui.dart):

- `LiCpfMaskDirective`: applies the `xxx.xxx.xxx-xx` mask while the user types.
- `LiCnpjMaskDirective`: applies the `xx.xxx.xxx/xxxx-xx` mask while the user types.
- `LiCpfFormatterPipe`: formats CPF values as `XXX.XXX.XXX-XX` or returns digits only.
- `LiCpfHiddenPipe`: keeps only the first or last four CPF characters visible.
- `LiHideStringPipe`: preserves a visible prefix and masks the rest of a string.
- `LiTextMaskDirective`, `LiOnlyNumberDirective` and `LiCustomHrefDirective`: helpers for generic masked inputs, digit-only fields and attribute-driven href synchronization.
- `LiNumberValueAccessor`, `LiDateTimeValueAccessor` and `LiMinMaxDirective`: form helpers for `<input type="number">`, `<input type="datetime-local">` and constrained numeric inputs.

In `ngdart` 8, template pipes are invoked through `$pipe` instead of the legacy `value | pipeName` syntax. That applies both to built-in pipes such as `date` and to custom pipes registered in the component.

Example:

```dart
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';

@Component(
  selector: 'demo-form-helpers',
  template: '''
    <input liCpfMask [(ngModel)]="cpf">
    <input type="number" liMinMax [liMin]="1" [liMax]="10" [(ngModel)]="quantity">
    <input type="datetime-local" [(ngModel)]="scheduledAt">

    <p>{{ $pipe.liDate(scheduledAt, 'medium') }}</p>
    <p>{{ $pipe.liCpfFormatter(cpf) }}</p>
    <p>{{ $pipe.liCpfHidden(cpf, 'asteriskStart') }}</p>
    <p>{{ $pipe.liHideString(note, 3, '#') }}</p>
  ''',
  directives: [coreDirectives, formDirectives, limitlessFormDirectives, LiCpfMaskDirective],
  pipes: [commonPipes, LiCpfFormatterPipe, LiCpfHiddenPipe, LiHideStringPipe],
)
class DemoFormHelpersComponent {
  String cpf = '';
  String quantity = '1';
  DateTime? scheduledAt;
  String note = 'abcdef';
}
```

### Generic text masks

`liTextMask` accepts the same simple string shape used by legacy mask directives, so consumers do not need a `Map` in AngularDart templates for common CEP, phone, and document masks.

```html
<input
  class="form-control"
  liTextMask="xxxxx-xxx"
  liOnlyNumber
  [(ngModel)]="address.zipCode">

<input
  class="form-control"
  liTextMask
  liTextMaskMask="(xx) xxxx-xxxx"
  liOnlyNumber
  [(ngModel)]="person.phone">

<input
  class="form-control"
  [liTextMask]="'xxx-xx'"
  [(ngModel)]="code">
```

For advanced cases the directive still accepts `LiTextMaskConfig` or a Dart-side config object. Template-only options can use scalar inputs: `liTextMaskMask`, `liTextMaskMaxLength`, `liTextMaskEager`, and `liTextMaskEscapeCharacter`.

## Declarative form validation

The form API now supports a declarative validation layer designed to reduce template verbosity without removing control from the host application. The goal is to keep the common case short, preserve backend-driven errors, and reuse the same mental model across `li-input`, `li-select`, `li-multi-select`, `li-checkbox` and adjacent field components.

The public building blocks are:

- `liType`: string preset for common field shapes such as CPF, email or phone.
- `liInputType`: object-based escape hatch for custom reusable field presets.
- `liRules`: declarative validation rules that compose with presets.
- `liMessages`: per-field message overrides keyed by rule code.
- `liValidationMode`: controls when automatic validation becomes visible.
- `invalid`, `dataInvalid` and `errorText`: explicit external overrides, typically used for backend errors.

### Bind rules and messages as component fields

AngularDart template expressions do not support list or map literals. Writing `[liRules]="[LiRule.required()]"` or `[liMessages]="{'required': 'Informe o CPF.'}"` does not compile: the template compiler rejects them with `Parser Error: ListLiteralImpl: Not a subset of supported Dart expressions` and `SetOrMapLiteralImpl: ...`. Closures written inline, such as `LiRule.custom((value) => ...)`, fall under the same rule.

Declare rules and messages as fields on the component and bind them by name, as every example below does. Beyond being the only form that compiles, it keeps Dart code out of the template and gives the lists a stable identity across change detection cycles.

Rule constructors are `const factory`, so fixed lists can be `static const`. The exception is `LiRule.custom(...)`, which takes a callback and therefore cannot be const: use `static final`.

### Why this path

This API follows the same separation of concerns used by modern form systems:

- value binding stays simple in the template;
- validation rules are modeled separately from the HTML input type;
- field state and error presentation are computed by the component instead of being hand-wired in every page;
- presets exist as a design-system convenience layer, not as a replacement for explicit rules.

That puts `limitless_ui` close to the direction used by the current market:

- Angular reactive forms and Signal Forms: validators are composed separately from the field value and errors come from field state.
- React plus React Hook Form: binding is primitive, while validation is registered declaratively per field.
- Vue and Svelte: the ergonomics emphasis is on concise value binding, with validation layered on top by the framework or by libraries.

In practice, `liRules` is the most universal part of the model, `liType` is the design-system convenience layer, and `liInputType` is the escape hatch for advanced reuse.

### Simple presets

```html
<li-input
  name="cpf"
  label="CPF"
  liType="cpf"
  [(ngModel)]="person.cpf">
</li-input>

<li-input
  name="email"
  label="E-mail"
  liType="email"
  [(ngModel)]="person.email">
</li-input>

<li-input
  name="phone"
  label="Telefone"
  liType="phone"
  [(ngModel)]="person.phone">
</li-input>
```

Built-in presets currently include `cpf`, `cnpj`, `cpfOrCnpj`, `email`, `phone`, `textMin3`, `requiredText` and `onlyNumbers`.

### Preset plus additional rules

```html
<li-input
  name="fullName"
  label="Nome completo"
  liType="requiredText"
  [liRules]="fullNameRules"
  [(ngModel)]="person.fullName">
</li-input>
```

```dart
// LiRule.custom takes a callback, so the list cannot be const.
static final List<LiRule> fullNameRules = <LiRule>[
  LiRule.custom(validateFullName, code: 'fullName'),
];

String? validateFullName(dynamic value) {
  final normalized = '${value ?? ''}'.trim();
  return normalized.length >= 6
      ? null
      : 'Informe nome e sobrenome com pelo menos 6 caracteres.';
}
```

### Custom reusable field type

```dart
final LiInputType inventoryCodeType = LiPresetInputType(
  htmlType: 'text',
  inputMode: 'numeric',
  maxLength: 10,
  rules: <LiRule>[
    LiRule.required(),
    LiRule.pattern(r'^[0-9]{10}$'),
  ],
  messages: <String, String>{
    'pattern': 'Use exatamente 10 digitos.',
  },
);
```

```html
<li-input
  label="Codigo"
  [liInputType]="inventoryCodeType"
  [(ngModel)]="item.code">
</li-input>
```

### Overriding messages

```html
<li-input
  label="CPF"
  liType="cpf"
  [liMessages]="cpfMessages"
  [(ngModel)]="person.cpf">
</li-input>
```

```dart
static const Map<String, String> cpfMessages = <String, String>{
  'required': 'Informe o CPF do cidadao.',
  'cpf': 'CPF invalido.',
};
```

### Backend errors still win

Automatic validation is intentionally not the only source of truth. When the backend returns a field error, the host can keep that precedence explicitly:

```html
<li-input
  label="CPF"
  liType="cpf"
  [(ngModel)]="person.cpf"
  [invalid]="backendErrors.containsKey('cpf')"
  [errorText]="backendErrors['cpf'] ?? ''">
</li-input>
```

This preserves the common frontend/backend split used in real applications.

### Validation modes

`liValidationMode` controls when automatic validation is shown. Supported values are:

- `never`
- `dirty`
- `touched`
- `touchedOrDirty`
- `submitted`
- `submittedOrTouched`
- `submittedOrTouchedOrDirty`

Default: `submittedOrTouchedOrDirty`.

### Precedence model

The validation pipeline uses a fixed precedence model so component behavior stays predictable:

- field preset: `liInputType` wins over `liType`;
- field options: explicit component inputs win over preset defaults;
- validation rules: preset rules run first, then `liRules`, then compatibility rules derived from inputs such as `required`, `minLength`, `maxLength`, `pattern` and legacy `validator`;
- error message source: `errorText` wins over automatic messages;
- invalid state source: `invalid` and `dataInvalid` win over automatic invalid state.

### Using the same model in selects and checkboxes

```html
<li-select
  [dataSource]="departments"
  labelKey="label"
  valueKey="id"
  [liRules]="departmentRules"
  [(ngModel)]="person.departmentId">
</li-select>

<li-multi-select
  [dataSource]="skills"
  labelKey="label"
  valueKey="id"
  [liRules]="skillsRules"
  [(ngModel)]="person.skillIds">
</li-multi-select>

<li-checkbox
  label="Aceito os termos"
  [liRules]="acceptTermsRules"
  [(ngModel)]="person.acceptTerms">
</li-checkbox>
```

```dart
static const List<LiRule> departmentRules = <LiRule>[LiRule.required()];

static const List<LiRule> acceptTermsRules = <LiRule>[
  LiRule.requiredTrue('Voce precisa aceitar os termos.'),
];

// LiRule.custom takes a callback, so the list cannot be const.
static final List<LiRule> skillsRules = <LiRule>[
  LiRule.custom(validateAtLeastTwoSkills, code: 'skills'),
];
```

### Pairing field validation with `liForm`

`liForm` remains the container-level API for submit flows, especially when you want to mark everything as touched and focus the first invalid field.

```html
<div liForm #personForm="liForm">
  <li-input liType="cpf" [(ngModel)]="person.cpf"></li-input>
  <li-select [liRules]="departmentRules" [(ngModel)]="person.departmentId"></li-select>

  <button type="button" (click)="save(personForm)">Salvar</button>
</div>
```

```dart
Future<void> save(LiFormDirective form) async {
  final isValid = await form.validateAndFocusFirstInvalid();
  if (!isValid) {
    return;
  }

  // submit
}
```

This is the recommended path for robust forms because it keeps field validation local to each component and submit orchestration local to the form container.

### Native input validation feedback

Native `input`, `select`, and `textarea` controls that use `liRequired` or `liDocumentValidator` receive the same Limitless/Bootstrap visual feedback automatically. The directive applies `is-invalid`, `is-valid`, `aria-invalid`, and creates or reuses a sibling `.invalid-feedback` element.

```html
<div liForm #personForm="liForm">
  <input
    class="form-control"
    liRequired
    liRequiredMessage="Campo requerido!"
    [(ngModel)]="person.name">

  <input
    class="form-control"
    liCpfMask
    liDocumentValidator="cpf"
    liDocumentMessage="CPF invalido!"
    [(ngModel)]="person.cpf">

  <button type="button" (click)="save(personForm)">Salvar</button>
</div>
```

The field can still provide its own feedback element when markup needs a fixed location:

```html
<input
  class="form-control"
  liRequired
  liRequiredMessage="Informe o nome."
  [(ngModel)]="person.name">
<div class="invalid-feedback"></div>
```

Useful options for native validation feedback:

- `liValidationMode`: `submittedOrTouchedOrDirty` by default.
- `liValidationShowValid`: controls whether valid filled fields receive `is-valid`.
- `liValidationFeedback="false"`: disables the automatic visual layer for one field.
- `liValidationFeedbackSelector`: changes how an existing feedback element is found.

When the page mixes native inputs, projected buttons, and composite components, pair `liForm` with `liFormField` so focus order stays explicit where needed and still falls back to DOM order when `[liFormFieldOrder]` is omitted.

```html
<form liForm #personForm="liForm">
  <div liFormField="departmentId" [liFormFieldOrder]="10">
    <li-select
      [dataSource]="departments"
      labelKey="label"
      valueKey="id"
      [liRules]="departmentRules"
      [(ngModel)]="person.departmentId">
    </li-select>
  </div>

  <div liFormField="reviewerIds">
    <li-datatable-select
      [settings]="reviewerSettings"
      [dataTableFilter]="reviewerFilter"
      [data]="reviewerData"
      [searchInFields]="reviewerSearchFields"
      [multiple]="true"
      [(ngModel)]="person.reviewerIds">
    </li-datatable-select>
  </div>
</form>
```

Practical notes:

- use `[liFormFieldOrder]` only when the desired focus order differs from the rendered DOM;
- when a composite field should focus a nested trigger instead of the outer host, mark that element with `data-li-form-focus-target="true"`;
- if no explicit order is provided, `liForm` now falls back to the page order.

### Currency input with declarative validation

`li-currency-input` now follows the same declarative validation contract used by the rest of the form components, so the demo pages and real forms can stay on the same `liRules` plus `liValidationMode` path.

```dart
final List<LiRule> compensationRules = <LiRule>[
  LiRule.custom(
    (value) => value is int && value > 0
        ? null
        : 'Informe um valor monetário maior que zero.',
    code: 'currencyAmount',
  ),
];
```

```html
<li-currency-input
  currencyCode="BRL"
  [locale]="validationLocale"
  [liRules]="compensationRules"
  liValidationMode="submittedOrTouchedOrDirty"
  helperText="Participa do mesmo fluxo declarativo do liForm."
  [(ngModel)]="person.expectedCompensationMinorUnits">
</li-currency-input>
```

## Generic vs `essential_core`-backed components

Use these groups as the practical adoption boundary:

- Generic components: alerts, buttons, accordion, collapse, modal, tabs, nav, tooltip, popover, toast, scrollspy, checkbox, radio, toggle, rating, file upload, date picker, date range picker, currency helpers, `li-token-field`, `li-tag-editor`, the base `li-input`, `li-password-input`, `li-pdf-viewer`, and `li-quill-text-editor`.
- `essential_core`-backed components: `li-datatable`, `li-datatable-select`, `li-select`, `li-multi-select`, `li-typeahead`, `li-treeview-select`, `li-tag-filter`, `li-tag-manager`, `LiTreeViewComponent` and related data/selection helpers.

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
  `LiDropdownButtonItemDirective`, `LiDropdownSubmenuDirective`,
  `LiDropdownSubmenuToggleDirective`, `LiDropdownSubmenuMenuDirective`,
  `LiDropdownConfig`.
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
  `LiModalComponent` with lazy content support, plus `open` and `close`
  outputs.
- Selects:
  `LiSelectComponent`, `LiOptionComponent`, `LiSelectTriggerDirective`,
  `LiMultiSelectComponent`, `LiMultiOptionComponent`,
  `LiMultiSelectTriggerDirective`, `CustomSelectItem`,
  `CustomMultiSelectItem`, plus the `openChange` and `beforeOpen` streams.
- Open lifecycle:
  `LiBeforeOpenEvent`, the cancelable event carried by `beforeOpen`.
- Page header:
  `LiPageHeaderComponent`, `LiPageHeaderBreadcrumbItemDirective`,
  `LiPageHeaderBottomDirective`, `LiPageHeaderActionsDirective`,
  `liPageHeaderDirectives`.
- Toast:
  `LiToastComponent`, `LiToastStackComponent`, `LiToastService`.
- Input fields:
  `LiInputComponent`, `LiPasswordInputComponent`,
  `liPasswordInputDirectives`.
- Color picker:
  `LiColorPickerComponent`, `LiColorPickerEvent`, plus palette inputs,
  selection-history inputs, and `pickerShow`, `pickerHide`, `pickerChange`,
  `pickerMove`, `pickerDragStart`, `pickerDragStop` streams.
- Floating action button:
  `LiFabComponent`, `LiFabAction`, `LiFabShortcut`,
  `LiFabTriggerDirective`, `LiFabActionDirective`.
- Typeahead:
  `LiTypeaheadComponent`, `LiTypeaheadItem`, `LiTypeaheadSelectItemEvent`, `LiTypeaheadConfig`, `LiTypeaheadHighlightComponent`.
- Datatable:
  `LiDataTableComponent`, `LiDatatableHeaderDirective`,
  `LiDatatableHeaderCellDirective`,
  `LiDatatableFooterDirective`, `LiDatatableHeaderContext`,
  `LiDatatableFooterContext`, `DatatableCol`, `DatatableSettings`,
  `DatatableRow`, `DatatableStyle`.
- Datatable select:
  `LiDatatableSelectComponent`, `LiDatatableSelectModalContentDirective`,
  plus the `requestDataOnOpen` input and the `openChange` stream for
  on-demand loading.
- Tagging and tokenization:
  `LiTagFilterComponent`, `LiTagEditorComponent`, `LiTagManagerComponent`,
  `LiTagSelectionChange`, `LiTagSaveRequest`, `LiTagDeleteRequest`,
  `LiTokenFieldComponent`.
- Selection controls and upload:
  `LiCheckboxComponent`, `LiRadioComponent`, `LiToggleComponent`,
  `LiRatingComponent`, `LiRatingConfig`, `LiFileUploadComponent`,
  `LiFileSelectDirective`, `LiFileDropDirective`, `LiFileType`.
- Treeview:
  `LiTreeViewComponent`, `LiTreeviewSelectComponent`,
  `LiTreeViewPageLoader`, `TreeViewLoadRequest`, `TreeViewLoadResult`,
  `LiTreeviewSelectNodeDirective`, `LiTreeviewSelectTriggerDirective`.
- Separate barrels:
  `package:limitless_ui/pdf_viewer.dart` exports `LiPdfViewerComponent`,
  `LiPdfViewerLabels`, `LiPdfViewerToolbarAction`,
  `LiPdfViewerPageText`, `LiPdfViewerPageInfo`, and
  `liPdfViewerDirectives`.
  `package:limitless_ui/quill_text_editor.dart` exports
  `LiQuillTextEditorComponent`, `LiQuillTextEditorLabels`,
  `LiQuillToolbarAction`, `LiQuillToolbarItem`,
  `LiQuillToolbarOption`, and `liQuillTextEditorDirectives`.

## Recent additions in `1.0.0-dev.23`

- Fixed `liDropdown` body-attached overlays on narrow/mobile viewports so long organization switcher menus no longer enter a redraw/reposition loop while Popper and viewport adaptation settle the menu size.
- Documented the overlay lesson learned: for body-mounted `liDropdown` menus, let Popper own wrapper `transform`, and do not write volatile `--popper-available-*` CSS variables from the dropdown writer because they can feed back into layout measurement.
- Documented the recommended opt-out for dense body-mounted organization/account switchers: do not use `adaptToViewport` when app CSS already controls width with `width: max-content`, `max-width`, or viewport-based rules, because the intelligent adaptation can keep recalculating style/classes indefinitely. Use `adaptToViewport="false"` and CSS-owned width/overflow instead.

## Recent additions in `1.0.0-dev.22`

- Expanded `li-pdf-viewer` with isolated `package:limitless_ui/pdf_viewer.dart` imports, localized labels/zoom presets, Dart/template toolbar and side-panel extensibility, document-text/page-info extraction APIs, and stronger browser coverage through dedicated PDF.js/browser bridges.
- Added `li-quill-text-editor` through the isolated `package:limitless_ui/quill_text_editor.dart` barrel, with Quill `2.0.3` integration, configurable toolbar items/actions/templates, optional table support, bilingual labels, and the optional `updateModelOnBlur` performance mode.
- Added `li-password-input` with Dart-controlled masking on top of a `type="text"` input, integrated reveal toggle, declarative validation support, and example coverage for autofill-resistant password flows.
- Added `LiNarratedFullScreenLoading` as an imperative fullscreen loading helper with rotating messages, a `pdfGeneration()` factory, `showOnBody()` overlay support above `li-modal`, and `updateMessage(..., stopRotation: true)` for pinning the final status.
- Expanded declarative `liDropdown` overlays with default viewport adaptation for dynamic/body-mounted menus, post-show relayout for compact navbar triggers, optional `menuMaxWidth`/`menuMaxHeight` caps, and browser coverage for left/right preferred alignment plus long/tall menu clamping.
- Added a dedicated workspace-shell demo route to the example app, simulating a dense operational navbar/sidebar layout with search, notification, organization switching, account submenu, and status-bar patterns without binding the docs to an external product name.

## Recent additions in `1.0.0-dev.17`

- Refactored `li-datatable` into focused controllers for sorting, pagination, search, export, selection, responsive state, virtual scroll, title help, and instrumentation while preserving the public API.
- Added `DatatablePerformanceProfile` with `saliPaged` for small server-paged operational tables, plus `enableGridMode`, `enableResponsiveFeatures`, `fixedTableLayout`, and stable `rowKeyResolver` support.
- Improved dense-table rendering by building row ranges without `sublist()`, using simpler header/cell bindings on plain paths, and caching responsive viewport/container state so template getters do not read DOM dimensions on every change-detection pass.
- Added browser benchmarks for virtual scroll and per-feature datatable cost. The measured expensive paths are `responsiveAutoHideColumns` by priority and `responsiveCollapseByContainer`, because they need real DOM width measurements and can otherwise cause forced reflow/layout thrashing. Action columns, title customization, `table-layout`, and virtual scroll were not the primary regression source in those scenarios.
- Added stable `data-li-datatable-action-cell` and `data-li-datatable-action` markers to `DatatableActionColumn`, expanded debug instrumentation with action-cell/action-element/configured-action-column metrics, and added regression coverage for `saliPaged` action rendering plus desktop container collapse without priority auto-hide.
- Refreshed the example datatable page with a visible performance summary, fixed the frozen-column horizontal-scroll demo spacing for action buttons, and removed component-level fixed-column background overrides so Limitless theme CSS owns those colors.
- Added a `datatable-process-lookup` dense SALI-style profile demo and a `protocol-workflow` demo route with protocol dispatch/attachment datatables inside modals and tabs.
- Added selector-based `liCollapseToggle` and forwarded `enableGridMode`/`enableResponsiveFeatures` through `li-datatable-select` for denser modal table flows.

## Recent additions in `1.0.0-dev.15`

- Expanded `li-datatable` responsive behavior with explicit `responsiveControlColumnKey`, so the details-toggle/control cell can stay on a predictable visible column even when `responsiveAutoHideColumns` is collapsing lower-priority fields.
- Expanded `li-datatable` header composition with `titleTextAlign`, `customRenderTitleString`, `customRenderTitleHtml`, `titleTooltip`, `titlePopover`, and projected `<template li-datatable-header-cell="columnKey" let-ctx>` templates, including inline tooltip support directly on the title text plus optional native browser `title` tooltips through `useNativeTitle`.
- Expanded `DatatableAction` and `DatatableActionColumn` with responsive desktop/mobile layouts (`desktopTextMobileIcon` and `desktopTextAndIconMobileIcon`), semantic `size` support (`btn-sm` / `btn-lg`), default centered action headers via `titleTextAlign`, and export-safe defaults where `DatatableActionColumn` stays out of built-in PDF/XLSX generation unless `exportable: true` is set deliberately.
- Expanded grid mode with projected `<template li-datatable-card>` support alongside `customCardBuilder`, plus refreshed example coverage showing richer header-title customization, custom cards, and safer action alignment in card/grid footers without forcing centered action groups.
- Added virtual-scroll guidance for dense operational tables, including the new `stickyTableHeaderOnVirtualScroll` flow for table mode, and documented the current limitation that non-virtual pages above roughly 100 dense rows can still stall the browser.

## Recent additions in `1.0.0-dev.14`

- Expanded `li-offcanvas` with `enableDefaultBodyClass` and `enableBodyWrapper`, allowing fully custom flex layouts in the panel body without forcing the default `.offcanvas-body` wrapper/class; also updated the internal panel shell to a column flex layout and added the `li-offcanvas-contents` passthrough class for projected content flows.
- Expanded the offcanvas example page with a denser operational “complex scenario” panel (fixed filter header, searchable/filtered timeline list, responsive sizing), plus themed scrollbar coverage for generic `.overflow-auto` containers to keep custom offcanvas bodies visually consistent.
- Fixed `li-dropdown-menu` rounded-corner clipping when vertical scrolling is activated: overflow control was moved from the outer menu container to the inner items container for desktop/inline modes, while mobile modal/sheet sizing behavior remains isolated to the outer menu wrapper.
- Expanded `li-datatable` action rendering with `DatatableActionAppearance.linkIcon` and `iconOnly`, enabling icon-only link-style actions (no button background) while preserving accessible labels; also updated the datatable example favorite action to support this visual mode where state is expressed by icon color only.
- Fixed `li-datatable` responsive auto-hide recovery after viewport/container re-expansion by recalculating with stable column widths instead of stretched runtime measurements, and added browser regression coverage for the shrink-then-expand flow.

## Recent additions in `1.0.0-dev.11`

- Expanded `li-datatable` with `responsiveAutoHideColumns` plus per-column `responsiveAutoHidePriority` and `responsiveAutoHideRequired` flags so narrower layouts can progressively move secondary columns into the responsive details row before horizontal scrolling appears.
- Added public `li-datatable-header` and `li-datatable-footer` template directives together with `LiDatatableHeaderContext` and `LiDatatableFooterContext`, so hosts can replace the built-in toolbar and footer without forking sorting, search, pagination, or export behavior.
- Added sticky/frozen datatable columns through `DatatableCol.fixedPosition`, including `DatatableFixedColumnPosition.left` and `DatatableFixedColumnPosition.right` for cases such as keeping the actions column visible during horizontal scroll.
- Added `requestDataOnItemsPerPageChange` to `li-datatable` and `li-datatable-select` for server-driven flows where changing the page size should reload through `(dataRequest)` instead of only emitting `(limitChange)`.
- Expanded `li-datatable-select` to forward custom datatable header/footer templates to the inner modal table and exposed `modalCompactHeader` plus `modalSmallHeader` to align the modal chrome with denser operational layouts.
- Expanded the dropdown API with `liDropdownSubmenu`, `liDropdownSubmenuToggle`, and `liDropdownSubmenuMenu` for nested account/action menus that keep the parent dropdown open while the submenu is being explored.

## Recent additions in `1.0.0-dev.7`

- Added `li-tag-filter`, `li-tag-editor`, and `li-tag-manager` with configurable `labelKey`, `valueKey`, and `colorKey` mapping, reusable selection/create/edit/delete events, and browser coverage for the new tag workflows.
- Added `li-token-field`, a tokenized text input with `ngModel`, regex-based token extraction, optional keystroke filtering, clipboard actions, and browser coverage for the core parsing flows.
- Added the `work-queue` demo route to show tag tooling and token-field usage inside a more realistic operational flow.
- Expanded dropdown menu overlays so `li-dropdown-menu` and the lower-level `dropdownmenu` directive can render either inline or in a `body`-anchored Popper overlay, which is safer for clipped containers and overflow-hidden layouts.
- Expanded `li-modal` with `compactHeader` and `smallHeader`, improved fullscreen body scrolling, and richer demo coverage for compact, iconified, mini, backdropless, form, and fullscreen dialog variants.
- Expanded the demo shell with extra color themes (`blu`, `pink`, `orange`, `retro`) and broader themed scrollbar coverage across the example surfaces.
- Aligned `li-currency-input` examples with the same declarative validation contract used by `person-registration`, and tightened the extra single/multiple datatable/treeview fields so they also participate in submit validation.

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

### File upload

`li-file-upload` covers drag-and-drop, type/size filters, `ngModel` integration, declarative field validation, and three preview strategies.

Preview-related inputs:

- `previewMode`: accepts `compact`, `thumbnails`, and `limitless`.
- `showPreview`: hides the selected-files list/grid entirely when `false`.
- `enablePreviewModal`: enables enlarged previews for images and PDFs.
- `enablePreviewZoom`: shows zoom controls inside the preview modal for image previews.
- `maxFiles`, `maxSize`, `accept`, `allowedTypes`: constrain the queue before submit.

`compact` renders a lightweight list, `thumbnails` renders cards with inline previews and footer actions, and `limitless` mirrors the native Limitless/Krajee fileinput layout with overlay actions and a metadata footer.

```html
<li-file-upload
  [(ngModel)]="attachments"
  accept="image/*,application/pdf"
  [maxFiles]="4"
  previewMode="limitless"
  [enablePreviewModal]="true"
  [enablePreviewZoom]="true"
  browseLabel="Browse attachments">
</li-file-upload>
```

### Tag tooling

`li-tag-filter`, `li-tag-editor`, and `li-tag-manager` cover the common label-selection and maintenance flow without forcing each screen to rebuild badge rendering, color handling, or CRUD event payloads.

For selection-oriented flows, `li-tag-manager` also accepts `compareWith` when the selected values are objects or when item identity is recreated after reloads.

Use `[wrapSelectedBadges]="true"` on `li-tag-filter` when the selected badges should wrap and increase the input height instead of truncating into a single horizontal row. This is useful for dense filter bars with several selected labels.

```html
<li-tag-filter
  [dataSource]="tagCatalog"
  labelKey="name"
  valueKey="id"
  colorKey="color"
  [wrapSelectedBadges]="true"
  [(ngModel)]="selectedTagIds">
</li-tag-filter>

<li-tag-manager
  [dataSource]="tagCatalog"
  [selectedValues]="selectedTagIds"
  labelKey="name"
  valueKey="id"
  colorKey="color"
  (applySelection)="applyTags($event)"
  (createRequest)="createTag($event)"
  (updateRequest)="updateTag($event)"
  (deleteRequest)="deleteTag($event)">
</li-tag-manager>
```

### Token field

`li-token-field` is aimed at repeated short values such as process codes, e-mails, or routing identifiers, while preserving `[(ngModel)]` and a compact action menu.

Useful customization knobs:

- `showActionMenu` to remove the overflow menu entirely.
- `showCopyAction`, `showPasteAction`, and `showClearAction` to expose only the actions the screen actually needs.
- `showRemoveButton` to keep tokens read-only at the chip level while still allowing programmatic updates.
- `wrapTokens` to let tokens wrap onto additional lines and grow the input height when horizontal space runs out.
- `actionMenuTriggerClass` and `actionMenuTriggerIconClass` to retheme the overflow trigger without forking the component.
- `copyAction`, `pasteAction`, and `clearAction` outputs when the host wants to react to those actions explicitly.

```html
<li-token-field
  [(ngModel)]="processCodes"
  [filterInput]="true"
  patternAllowed="[0-9/]"
  patternToken="\\d+/\\d+"
  [showCopyAction]="false"
  [wrapTokens]="true"
  placeholder="Digite um código/ano e pressione enter.">
</li-token-field>
```

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

`li-datatable` covers the library's most common administrative data flow: field search, pagination, sorting, row selection, export, responsive mobile collapse, progressive responsive auto-hide, custom header/footer templates, and switching between table and grid views without duplicating the data source.

The component revolves around three objects:

- `Filters`: limit, offset, search, and sorting for the current request.
- `DataFrame<T>`: the returned collection plus `totalRecords`.
- `DatatableSettings`: columns and visual behavior for the table or grid.

Most useful features:

- column-targeted search with `searchInFields`;
- events such as `(dataRequest)`, `(searchRequest)`, and `(limitChange)` for server-driven flows;
- columns with `enableSorting`, `sortingBy`, `hideOnMobile`, `responsiveAutoHidePriority`, `responsiveAutoHideRequired`, `textAlign`, `titleTextAlign`, `nowrap`, `width`, custom title renderers, and custom classes;
- performance controls with `performanceProfile`, `DatatablePerformanceProfile.saliPaged`, `enableGridMode`, `enableResponsiveFeatures`, `fixedTableLayout`, and stable selection through `rowKeyResolver`;
- responsive collapse driven by viewport (`responsiveCollapseMaxWidth`) or by container width (`responsiveCollapseByContainer` + `responsiveCollapseContainerMaxWidth`) for desktop shells that shrink horizontally;
- `responsiveControlColumnKey` when the responsive collapse trigger must stay on a specific visible column such as `code`, `name`, or `actions`;
- sticky edge columns with `fixedPosition: DatatableFixedColumnPosition.left` or `DatatableFixedColumnPosition.right` when critical actions or identifiers must remain visible during horizontal scroll;
- optional custom toolbar/footer templates via `headerTemplate`, `footerTemplate`, or projected `<template li-datatable-header let-ctx>` and `<template li-datatable-footer let-ctx>`;
- per-column header-title customization with `customRenderTitleString`, `customRenderTitleHtml`, `titleTooltip`, `titlePopover`, and `<template li-datatable-header-cell="columnKey" let-ctx>` for rich header content without forking the whole table header;
- per-column template projection with `<template li-datatable-cell="columnKey" let-ctx>` for HTML-driven custom cells without replacing existing `customRenderHtml`;
- `LiDatatableHeaderContext` and `LiDatatableFooterContext` so custom templates can still call search, pagination, export, page-size, and view-mode actions;
- `responsiveAutoHideColumns` when lower-priority columns should collapse into the details row before horizontal scrolling appears;
- `requestDataOnItemsPerPageChange` when changing page size should emit through `(dataRequest)` instead of only `(limitChange)`;
- `virtualScroll`, `virtualRowHeight`, `virtualViewportHeight`, and `stickyTableHeaderOnVirtualScroll` for large datasets where the DOM must stay bounded while keeping the table header visible;
- per-cell styling with `cellStyleResolver` and per-row styling with `rowStyleResolver`;
- grid mode with `gridMode`, `gridTemplateColumns`, `gridGap`, projected `<template li-datatable-card let-ctx>`, and `customCardBuilder`;
- built-in XLSX and PDF export support.

Current datatable performance notes:

The latest browser benchmarks are focused on keeping `li-datatable` predictable in AngularDart change detection: plain table paths should stay cheap, and DOM-measuring responsive features should remain explicit opt-ins. Results below came from `dart run build_runner test -- -p chrome -j 1 test/datatable/li_datatable_feature_cost_benchmark_test.dart` on a local Chrome run, using the benchmark's measured instrumentation totals.

| Scenario | Rows / shape | Virtual scroll | Responsive features | Measured total | Main signal | Guidance |
| --- | --- | --- | --- | ---: | --- | --- |
| `baseline-plain` | 12 rows, plain columns | Off | Off | 21.900 ms | Baseline path | Reference for small paged tables. |
| `title-tooltip-popover` | 12 rows, rich header help | Off | Off | 22.600 ms | Header help stayed close to baseline | Safe for normal tables; not the regression source. |
| `custom-title-html` | 12 rows, custom title DOM | Off | Off | 23.400 ms | Custom title rendering stayed close to baseline | Safe when title DOM is stable. |
| `sali-paged-baseline` | 12 rows, `saliPaged` | Off | Disabled by profile | 24.100 ms | No responsive DOM measurement | Recommended for small server-paged operational screens. |
| `collapse-on-mobile` | 12 rows, `hideOnMobile` details | Off | Viewport collapse | 24.700 ms | Details row without priority auto-hide | Good default for mobile collapse. |
| `action-column` | 12 rows, action column | Off | Off | 29.000 ms | `actionElements=44`, close to baseline | Action columns add DOM, but were not the main bottleneck. |
| `sali-paged-action-column` | 12 rows, `saliPaged` + actions | Off | Disabled by profile | 30.600 ms | `actionElements=44`, measured correctly | Good for SALI-style paged tables with action buttons. |
| `collapse-by-container` | 12 rows, desktop container collapse | Off | Container collapse | 55.700 ms | Container width measurement dominates | Useful for modals/split panes; keep it opt-in. |
| `responsive-priority-autohide` | 12 rows, priority auto-hide | Off | Priority auto-hide | 98.900 ms | High measured cost | Treat as the expensive path; enable deliberately. |
| `combined-rich-features` | 12 rows, title help + actions + responsive | Off | Container collapse + priority auto-hide | 129.700 ms | DOM measurement and rich DOM combine | Use only when the UX needs all rich responsive behavior. |

A manual local demo validation also rendered about 3,000 table rows without `virtualScroll` on the optimized plain/SALI-style path without freezing the browser. Treat that as a practical capability of the lean path, not a promise for every table shape: custom cell components, projected templates, many action buttons, grouping, or DOM-measuring responsive features can still make virtualization or server-side paging the better choice.

Operational guidance for dense tables:

- For plain table-heavy screens, first try the lean path: `performanceProfile: DatatablePerformanceProfile.saliPaged`, `enableGridMode: false`, `enableResponsiveFeatures: false`, `virtualScroll: false`, stable row keys, and server-driven filters. This path is the one validated manually with roughly 3,000 rendered rows without browser lockups.
- In table mode, combine `virtualScroll`, `virtualRowHeight`, and an explicit `virtualViewportHeight` so the DOM stays bounded while paging through large result sets.
- When that dense table still needs persistent column labels during scroll, enable `stickyTableHeaderOnVirtualScroll`; the sticky header is intentionally opt-in and only activates for virtualized table mode.
- In grid mode, pair `virtualScroll` with `virtualGridItemHeight` and `virtualGridMinItemWidth` so the viewport can estimate rows of cards without rendering the full dataset.
- For small server-paged tables where every page already contains a bounded number of rows, prefer `performanceProfile: DatatablePerformanceProfile.saliPaged`, keep `virtualScroll` disabled, and set `enableResponsiveFeatures` to `false` unless the screen really needs responsive details rows.
- `responsiveCollapse` can be used as a DataTables Responsive-style details row on desktop too: enable `responsiveCollapseByContainer` and configure `hideOnMobile` columns when a desktop shell or modal becomes narrow. This avoids the priority auto-hide algorithm and is usually cheaper than `responsiveAutoHideColumns`.
- Treat `responsiveAutoHideColumns` plus `responsiveAutoHidePriority` as an opt-in feature for layouts that truly need progressive priority hiding before horizontal scroll. It measures available width and column widths after render, so it is more expensive than plain mobile/container collapse.
- Keep DOM-measuring responsive features off in dense benchmark-sensitive views unless they are required. The component caches responsive viewport state internally, but container collapse and priority auto-hide still depend on real browser layout measurements.
- For `DatatableActionColumn` inside default grid cards, keep the default container or use `justify-content-start` when you want the footer actions aligned from the left. Using `justify-content-center` together with `w-100` will intentionally center the action group across the whole card footer.

Example for dense server-driven tables with sticky header on virtual scroll:

```html
<li-datatable
  [data]="usersFrame"
  [settings]="settings"
  [dataTableFilter]="filters"
  [searchInFields]="searchFields"
  [requestDataOnItemsPerPageChange]="true"
  [virtualScroll]="true"
  [virtualRowHeight]="44"
  [virtualViewportHeight]="'72vh'"
  [stickyTableHeaderOnVirtualScroll]="true"
  (dataRequest)="loadUsers($event)">
</li-datatable>
```

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
      titleTextAlign: 'center',
    ),
    DatatableCol(
      key: 'actions',
      title: 'Actions',
      width: '128px',
      titleTextAlign: 'center',
      fixedPosition: DatatableFixedColumnPosition.right,
    ),
  ],
  responsiveControlColumnKey: 'feature',
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
  [responsiveAutoHideColumns]="true"
  [requestDataOnItemsPerPageChange]="true"
  [searchPlaceholder]="'Type to search'"
  (dataRequest)="loadUsers($event)"
  (limitChange)="loadUsers($event)"
  (searchRequest)="loadUsers($event)">
</li-datatable>
```

For screens that need a custom operational toolbar or footer shell without replacing the built-in datatable behavior, project templates and use the provided context object:

```html
<li-datatable
  [data]="usersFrame"
  [settings]="settings"
  [dataTableFilter]="filters"
  [searchInFields]="searchFields"
  (dataRequest)="loadUsers($event)">
  <template li-datatable-header let-ctx>
    <div class="d-flex gap-2 align-items-center">
      <input
        class="form-control"
        type="search"
        [ngModel]="ctx.dataTableFilter.searchString"
        (ngModelChange)="ctx.dataTableFilter.searchString = $event">
      <button type="button" class="btn btn-primary" (click)="ctx.search()">
        Search
      </button>
    </div>
  </template>

  <template li-datatable-footer let-ctx>
    <div class="small text-muted">
      Page {{ ctx.currentPage }} of {{ ctx.numPages }}
    </div>
  </template>
</li-datatable>
```

For row actions or other rich cells, project a column-scoped template. The `ctx` object exposes `row`, `column`, `itemMap`, `itemInstance`, `rowIndex`, and `columnIndex`:

```html
<li-datatable
  [data]="usersFrame"
  [settings]="settings"
  [dataTableFilter]="filters">
  <template li-datatable-cell="actions" let-ctx>
    <div class="d-inline-flex gap-1">
      <button
        type="button"
        class="btn btn-sm btn-light"
        (click)="openUser(ctx.itemMap)">
        Open
      </button>
      <button
        type="button"
        class="btn btn-sm btn-light"
        (click)="toggleFavorite(ctx.itemMap)">
        Favorite
      </button>
    </div>
  </template>
</li-datatable>
```

Column titles can be customized independently from body cells. Use `titleTextAlign` for header alignment, `customRenderTitleString` for pure-text titles, `customRenderTitleHtml` for DOM-driven titles, `titleTooltip` or `titlePopover` for contextual help, or a projected header-cell template when Angular bindings are needed. When the tooltip should appear directly over the title text, set `displayMode: DatatableTitleTooltipDisplayMode.title`. If you prefer the browser-native tooltip instead of the library overlay, add `useNativeTitle: true`:

```dart
final settings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(
      key: 'protocol',
      title: 'Protocol',
      titleTooltip: DatatableTitleTooltipConfig(
        text: 'This column also acts as the responsive collapse trigger.',
        displayMode: DatatableTitleTooltipDisplayMode.title,
        useNativeTitle: true,
      ),
      customRenderTitleString: (column) => 'Protocol / ID',
    ),
    DatatableCol(
      key: 'status',
      title: 'Status',
      titleTextAlign: 'center',
      textAlign: 'center',
      customRenderTitleHtml: (column) {
        final root = SpanElement()
          ..classes.addAll(<String>['d-inline-flex', 'align-items-center', 'gap-1']);
        root.append(Element.tag('i')..className = 'ph ph-seal-check text-success');
        root.appendText('Status');
        return root;
      },
    ),
    DatatableActionColumn(
      key: 'actions',
      title: 'Actions',
      titleTextAlign: 'center',
      titlePopover: DatatableTitlePopoverConfig(
        title: 'Quick actions',
        body: 'This centered header groups the actions available on each row.',
      ),
      actions: <DatatableAction>[
        DatatableAction(
          label: 'Open',
          iconClass: 'ph ph-folder-open',
          appearance: DatatableActionAppearance.linkIcon,
          responsiveMode: DatatableActionResponsiveMode
              .desktopTextAndIconMobileIcon,
          onTap: (ctx) => openUser(ctx.itemMap),
        ),
        DatatableAction(
          label: 'Archive',
          iconClass: 'ph ph-archive-box',
          appearance: DatatableActionAppearance.linkIcon,
          iconOnly: true,
          size: 'sm',
          onTap: (ctx) => archiveUser(ctx.itemMap),
        ),
      ],
    ),
  ],
);
```

```html
<li-datatable [data]="usersFrame" [settings]="settings" [dataTableFilter]="filters">
  <template li-datatable-header-cell="actions" let-ctx>
    <span class="d-inline-flex align-items-center justify-content-center gap-1 w-100">
      <i class="ph ph-lightning"></i>
      {{ ctx.column.title }}
    </span>
  </template>
</li-datatable>
```

If you prefer a purely Dart-defined API for actions, use `DatatableActionColumn` in `colsDefinitions` (declarative) and optionally `DatatableActionController` (imperative updates), without touching the legacy `customRenderHtml` path:

```dart
final actionController = DatatableActionController(
  actions: <DatatableAction>[
    DatatableAction(
      label: 'Open',
      iconClass: 'ph ph-folder-open',
      appearance: DatatableActionAppearance.linkIcon,
      iconOnly: true,
      onTap: (ctx) => openUser(ctx.itemMap),
    ),
  ],
);

final settings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(key: 'name', title: 'Name'),
    DatatableActionColumn(
      key: 'actions',
      title: 'Actions',
      controller: actionController,
      fixedPosition: DatatableFixedColumnPosition.right,
    ),
  ],
);
```

For icon-only actions with no button background, use `appearance: DatatableActionAppearance.linkIcon` and `iconOnly: true`. This keeps accessibility via `label`/`title` while rendering a link-like icon button.

If the same action should show only text on desktop but collapse to an icon on mobile, use `responsiveMode: DatatableActionResponsiveMode.desktopTextMobileIcon` together with `iconClass`.

If the same action should show icon + text on desktop and collapse to icon-only on mobile, use `responsiveMode: DatatableActionResponsiveMode.desktopTextAndIconMobileIcon`.

For denser action columns, set `size: 'sm'` on `DatatableAction` to emit `btn-sm` while keeping the default Limitless button contract for spacing and icon-only buttons.

When row actions should wrap into multiple lines instead of forcing a wider column, set `wrapActions: true` on `DatatableActionColumn`.

When part of the action set should stay visible and the rest should move into an overflow menu, combine `maxVisibleActions` on `DatatableActionColumn` with `overflowBehavior` on each `DatatableAction`.

- `DatatableActionOverflowBehavior.auto`: uses the normal inline flow and only moves to the overflow menu when the column reaches `maxVisibleActions`.
- `DatatableActionOverflowBehavior.alwaysVisible`: always stays inline, even when the column reached `maxVisibleActions`.
- `DatatableActionOverflowBehavior.overflowMenu`: always renders inside the overflow dropdown.

Example with one fixed visible action and the rest inside the dropdown:

```dart
DatatableActionColumn(
  key: 'actions',
  title: 'Actions',
  maxVisibleActions: 1,
  actions: <DatatableAction>[
    DatatableAction(
      label: 'Open process',
      iconClass: 'ph ph-eye',
      overflowBehavior: DatatableActionOverflowBehavior.alwaysVisible,
      onTap: (ctx) => openUser(ctx.itemMap),
    ),
    DatatableAction(
      label: 'Archive',
      iconClass: 'ph ph-archive-box',
      onTap: (ctx) => archiveUser(ctx.itemMap),
    ),
    DatatableAction(
      label: 'Delete',
      iconClass: 'ph ph-trash',
      overflowBehavior: DatatableActionOverflowBehavior.overflowMenu,
      onTap: (ctx) => deleteUser(ctx.itemMap),
    ),
  ],
)
```

Set `maxVisibleActions: 0` when the whole column should behave like an actions dropdown while still reusing the same declarative `DatatableAction` definitions.

`DatatableActionColumn` is excluded from built-in PDF/XLSX exports by default. If a specific action column really needs to appear in exports, opt in explicitly with `exportable: true` on the column.

If the same actions also appear in default grid/card footers, keep the default `containerClass` or move to `justify-content-start` when you want a left-aligned operational footer. A `containerClass` such as `justify-content-center w-100` is useful only when the design intentionally calls for centered action groups.

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

If you prefer AngularDart templating over building DOM in Dart, project a card template for grid mode:

```html
<li-datatable
  [data]="usersFrame"
  [settings]="advancedSettings"
  [dataTableFilter]="filters"
  [gridMode]="true">
  <template li-datatable-card let-ctx>
    <article class="card h-100 mb-0">
      <div class="card-body">
        <div class="text-muted fs-sm mb-2">{{ ctx.itemMap['owner'] }}</div>
        <h6 class="mb-2">{{ ctx.itemMap['feature'] }}</h6>
        <span class="badge bg-primary">{{ ctx.itemMap['status'] }}</span>
      </div>
    </article>
  </template>
</li-datatable>
```

When both APIs are present, `customCardBuilder` keeps priority for backward compatibility and the projected `li-datatable-card` template is used only when no custom card element was produced in Dart.

Mini tutorials:

1. Server-driven pagination and search

```dart
final Filters filters = Filters(limit: 12, offset: 0);
DataFrame<Map<String, dynamic>> tableData =
    DataFrame<Map<String, dynamic>>(items: <Map<String, dynamic>>[], totalRecords: 0);

Future<void> onTableRequest(Filters nextFilters) async {
  filters.fillFromFilters(nextFilters);
  tableData = await service.query(filters);
}
```

```html
<li-datatable
  [dataTableFilter]="filters"
  [data]="tableData"
  [settings]="settings"
  [searchInFields]="searchFields"
  (dataRequest)="onTableRequest($event)"
  (searchRequest)="onTableRequest($event)"
  (limitChange)="onTableRequest($event)">
</li-datatable>
```

2. Responsive collapse on desktop by container width

```dart
final settings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(
      key: 'code',
      title: 'Code',
      responsiveAutoHideRequired: true,
    ),
    DatatableCol(
      key: 'details',
      title: 'Details',
      hideOnMobile: true,
      responsiveAutoHidePriority: 10,
    ),
  ],
  responsiveControlColumnKey: 'code',
);
```

```html
<div style="max-width: 760px;">
  <li-datatable
    [data]="tableData"
    [settings]="settings"
    [dataTableFilter]="filters"
    [responsiveCollapse]="true"
    [responsiveCollapseByContainer]="true"
    [responsiveCollapseContainerMaxWidth]="760"
    [responsiveAutoHideColumns]="true">
  </li-datatable>
</div>
```

3. Action cells with TemplateRef and with DatatableActionColumn

```html
<li-datatable [data]="tableData" [settings]="settings" [dataTableFilter]="filters">
  <template li-datatable-cell="actions" let-ctx>
    <div class="d-inline-flex gap-1">
      <button type="button" class="btn btn-sm btn-light" (click)="openItem(ctx.itemMap)">
        Open
      </button>
      <button type="button" class="btn btn-sm btn-light" (click)="toggleFavorite(ctx.itemMap)">
        Favorite
      </button>
    </div>
  </template>
</li-datatable>
```

```dart
final settings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(key: 'name', title: 'Name'),
    DatatableCol(key: 'actions', title: 'Actions', exportable: false),
  ],
);
```

```dart
final actionController = DatatableActionController(
  actions: <DatatableAction>[
    DatatableAction(
      label: 'Open',
      iconClass: 'ph ph-folder-open',
      onTap: (ctx) => openItem(ctx.itemMap),
    ),
  ],
);

final settings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(key: 'name', title: 'Name'),
    DatatableActionColumn(
      key: 'actions',
      title: 'Actions',
      titleTextAlign: 'center',
      controller: actionController,
    ),
  ],
);
```

For TemplateRef-based action columns built with a plain `DatatableCol`, set `exportable: false` explicitly when that column should stay out of PDF/XLSX exports.

4. Custom column titles with alignment, Dart renderers, and TemplateRef

```dart
final settings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(
      key: 'name',
      title: 'Name',
      titleTooltip: DatatableTitleTooltipConfig(
        text: 'Use this header to explain why this column is the responsive trigger.',
        displayMode: DatatableTitleTooltipDisplayMode.title,
        useNativeTitle: true,
      ),
      customRenderTitleString: (column) => 'Name / Display',
    ),
    DatatableCol(
      key: 'status',
      title: 'Status',
      titleTextAlign: 'center',
      textAlign: 'center',
      customRenderTitleHtml: (column) {
        final root = SpanElement()
          ..classes.addAll(<String>['d-inline-flex', 'align-items-center', 'gap-1']);
        root.append(Element.tag('i')..className = 'ph ph-chart-line-up text-primary');
        root.appendText('Status');
        return root;
      },
    ),
    DatatableActionColumn(
      key: 'actions',
      title: 'Actions',
      titleTextAlign: 'center',
      titlePopover: DatatableTitlePopoverConfig(
        title: 'Quick actions',
        body: 'Keep dense row actions discoverable without overloading the title text.',
      ),
      actions: <DatatableAction>[
        DatatableAction(
          label: 'Open',
          iconClass: 'ph ph-folder-open',
          appearance: DatatableActionAppearance.linkIcon,
          responsiveMode: DatatableActionResponsiveMode
              .desktopTextAndIconMobileIcon,
          onTap: (ctx) => openUser(ctx.itemMap),
        ),
      ],
    ),
  ],
);
```

```html
<li-datatable [data]="tableData" [settings]="settings" [dataTableFilter]="filters">
  <template li-datatable-header-cell="actions" let-ctx>
    <span class="d-inline-flex align-items-center justify-content-center gap-1 w-100">
      <i class="ph ph-dots-three-outline"></i>
      {{ ctx.column.title }}
    </span>
  </template>
</li-datatable>
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

### Password Input

`li-password-input` keeps the same `[(ngModel)]` and declarative-validation contract used by the other form fields, but masks the value in Dart while rendering a `type="text"` input. This is useful for Chrome autofill-resistant password flows where the host still wants an integrated reveal toggle and predictable form behavior.

Most relevant inputs and features:

- `showPasswordLabel`, `hidePasswordLabel`, `maskChar`, `autocomplete`, `dataLpignore`, `data1pIgnore`, and `dataBwignore` for browser/password-manager behavior;
- `liType`, `liRules`, `liMessages`, `liValidationMode`, `invalid`, and `errorText` for the same declarative validation model used by `li-input`;
- `inputBlur`, `inputFocus`, `inputClick`, `inputKeydown`, and `inputEnter` outputs for host-side reactions without dropping back to a native input.

```html
<li-password-input
  label="Senha de assinatura"
  helperText="Mascara controlada em Dart para reduzir autofill agressivo"
  autocomplete="new-password"
  [(ngModel)]="signaturePassword">
</li-password-input>
```

### PDF Viewer

`li-pdf-viewer` is intentionally shipped through the separate barrel [lib/pdf_viewer.dart](lib/pdf_viewer.dart). It uses PDF.js for rendering, keeps the component generic around reading and navigation flows, and exposes extensibility points for projected toolbar actions and side panels without coupling the viewer to a specific signature or backend implementation.

Load the PDF.js bridge in the host page and render the component inside a container with explicit height:

```dart
import 'package:limitless_ui/pdf_viewer.dart';
```

```html
<script src="assets/js/pdf.js/5.4.149/build/pdf.export.js" type="module"></script>

<div style="height: 72vh;">
  <li-pdf-viewer
      [bytes]="documentBytes"
      title="Release briefing"
      pdfJsBasePath="assets/js/pdf.js/5.4.149">
  </li-pdf-viewer>
</div>
```

Most relevant inputs and features:

- `bytes` and `url` cover the common loading paths without locking the component to a single transport strategy;
- `pdfJsBasePath`, `workerSource`, `standardFontDataUrl`, and `cMapUrl` decouple the component from the host application's asset layout;
- `labels`, `LiPdfViewerLabels.portuguese`, `LiPdfViewerLabels.english`, `defaultLiPdfViewerZoomOptions`, and `defaultLiPdfViewerZoomOptionsPt` localize the toolbar and zoom menu;
- `customToolbarActions`, `<template liPdfViewerToolbarActions>`, and `<template liPdfViewerSidePanel>` let hosts attach business actions and body-level side-panel content without forking the viewer;
- `enableDownloadAction`, `enablePrintAction`, `enableRotateAction`, `enableFitWidthAction`, `enablePanModeAction`, `enableFullscreenAction`, and `enableGoToPageAction` allow action-level pruning without local CSS;
- `extractPageText(...)`, `extractDocumentText(...)`, `getPageInfo(...)`, and `getAllPageInfo(...)` expose generic read APIs for inspection and metadata flows;
- `documentLoaded`, `pageChange`, `scaleChange`, `loadError`, and `sidePanelOpenChange` surface viewer state back to the host.

### Quill Text Editor

`li-quill-text-editor` is exported through the separate barrel [lib/quill_text_editor.dart](lib/quill_text_editor.dart). It wraps Quill `2.0.3` as a generic rich-text editor, keeps `ngModel` integration through `ControlValueAccessor`, and exposes toolbar configuration as data plus projected templates so hosts can extend the editor without coupling it to proprietary flows.

Load Quill in the host page before creating the component:

```dart
import 'package:limitless_ui/quill_text_editor.dart';
```

```html
<script src="assets/js/quill/2.0.3/quill.js"></script>
<script src="assets/js/quill_table_better/1.2.3/quill_table_better.js"></script>

<li-quill-text-editor
    [(ngModel)]="htmlValue"
    [labels]="editorLabels"
    [updateModelOnBlur]="true"
    minHeight="20rem">
</li-quill-text-editor>
```

Most relevant inputs and features:

- `toolbarItems`, `toolbarActions`, and `<template liQuillTextEditorToolbarActions>` make the toolbar configurable through data and projected content;
- `labels`, `LiQuillTextEditorLabels.portuguese`, `LiQuillTextEditorLabels.english`, `headerOptions`, and `fontSizeOptions` localize and customize the default toolbar contract;
- `enableTableSupport`, `enableTableButton`, and `tableMenus` turn Quill Table Better support on only when the host wants that feature;
- `updateModelOnBlur` lets the host defer `ngModel` propagation for performance-sensitive screens, while `commitPendingModelUpdate()` can flush pending edits explicitly;
- `getHtml()`, `getPlainText()`, `getDeltaJson()`, `setDeltaJson(...)`, `format(...)`, and `insertTextAtSelection(...)` expose imperative editor APIs without reaching into JS interop directly.

When `enableTableSupport` is used, keep the editor in a container with enough horizontal room for the `quill-table-better` contextual table menu. The plugin positions `.ql-table-menus-container` from the Quill container geometry, and very narrow side-by-side layouts can make the menu clamp to the left edge instead of appearing visually centered above the selected table. Prefer a full-width editor area for table-heavy flows, or move previews/metadata below the editor on constrained pages. The component styles keep the Quill container overflow visible so the table menu can overlap the toolbar when it needs to; host page CSS should not put the editor inside clipping wrappers.

### Narrated Full Screen Loading

`LiNarratedFullScreenLoading` is an imperative helper for long-running browser flows that need a fullscreen overlay plus rotating status messages. It is exported from the main barrel [lib/limitless_ui.dart](lib/limitless_ui.dart), so it can be used alongside `LiSimpleLoading` and `LiSimpleDialogComponent` without an extra import surface.

```dart
import 'package:limitless_ui/limitless_ui.dart';

final loading = LiNarratedFullScreenLoading.pdfGeneration(
  title: 'Generating PDF',
  messages: const <String>[
    'Preparing document structure...',
    'Rendering pages...',
    'Finalizing metadata...',
  ],
);

loading.showOnBody();

// ... run the async task ...

loading.updateMessage('Uploading the final file...', stopRotation: true);

// ... finish the task ...

loading.hide();
```

Most relevant behavior:

- `showOnBody()` mounts the overlay at the document body and keeps it above `li-modal` stacks by default;
- `pdfGeneration()` provides a ready-made factory for PDF-oriented messaging flows;
- `updateMessage(..., stopRotation: true)` pins the latest message and stops the automatic rotation timer;
- `hide()` removes the overlay and releases the internal timer.

The example helper page includes both a standalone narrated-loading demo and a second demo triggered from inside `li-modal`, so modal stacking can be verified visually.

### Datatable Select

`li-datatable-select` is the right fit when a simple select is not enough because users need to search, paginate, and sort before choosing an item. It combines a `form-select`-style trigger with an internal `li-modal` that hosts a `li-datatable`.

Main flow:

- the host provides `Filters`, `DataFrame<T>`, and `DatatableSettings`;
- the component emits `(dataRequest)` whenever the internal table needs data;
- clicking a row selects the item, updates the trigger label, and closes the modal;
- the value can be controlled with `[(ngModel)]` or `(currentValueChange)`.

Most relevant inputs and features:

- `labelKey` and `valueKey` to separate the visible label from the persisted value;
- `multiple` to switch the value model to `List<dynamic>` and reuse datatable checkbox selection inside the modal;
- `itemLabelBuilder` and `itemValueBuilder` when the list is typed and the host does not want to rely on `Map` keys;
- `compareWith` when the selected value is an object or when rows may be recreated by new backend responses;
- `searchInFields` for the search selector inside the modal;
- projected `template li-datatable-header` and `template li-datatable-footer` when the inner modal table needs a custom toolbar or pagination shell;
- `modalCompactHeader` and `modalSmallHeader` for denser modal chrome without replacing the modal itself;
- `requestDataOnItemsPerPageChange` when page-size changes should reload through the inner datatable `(dataRequest)` flow;
- `showClearButton`, `clearButtonLabel`, `triggerIconMode`, and `triggerIconClass` for trigger and multi-selection UX tuning;
- projected `template liDatatableSelectModalContent` for replacing the internal modal body with arbitrary content;
- modal context helpers `ctx.select(item)`, `ctx.selectItem(label, value)`, `ctx.clear()`, `ctx.apply()`, and `ctx.close()`;
- `mobileResponsiveCollapse` and `mobileResponsiveCollapseMaxWidth` to enable the inner table's mobile details-row layout when columns are marked with `hideOnMobile`;
- `responsiveCollapseByContainer` and `responsiveCollapseContainerMaxWidth` when the modal/table container width, not only the viewport, should trigger collapsed details rows;
- `modalSize`, `title`, `placeholder`, `disabled`, and `fullScreenOnMobile`;
- public methods such as `clear()`, `setSelectedItem(...)`, and `selectedLabel`.

In multiple mode, the component keeps the modal open while the user marks rows, mirrors the current page selection through the datatable checkboxes, and commits the pending selection when the modal is confirmed or closed.

```html
<li-datatable-select
  [settings]="personSettings"
  [dataTableFilter]="personFilter"
  [data]="personFrame"
  [searchInFields]="personSearchFields"
  [mobileResponsiveCollapse]="true"
  [modalCompactHeader]="true"
  [modalSmallHeader]="true"
  [requestDataOnItemsPerPageChange]="true"
  labelKey="name"
  valueKey="id"
  [multiple]="true"
  triggerIconMode="addon"
  triggerIconClass="ph ph-users-three"
  clearButtonLabel="Limpar modal"
  [(ngModel)]="selectedPeopleIds"
  (dataRequest)="loadPeople($event)">
</li-datatable-select>
```

When the built-in modal toolbar is not enough, the same datatable template directives can be projected through `li-datatable-select` and will be forwarded to the inner table:

```html
<li-datatable-select
  [settings]="personSettings"
  [dataTableFilter]="personFilter"
  [data]="personFrame"
  [searchInFields]="personSearchFields"
  [modalCompactHeader]="true"
  [modalSmallHeader]="true"
  [mobileResponsiveCollapse]="true"
  (dataRequest)="loadPeople($event)">
  <template li-datatable-header let-ctx>
    <div class="d-flex align-items-center justify-content-between gap-2">
      <span class="fw-semibold">{{ ctx.totalRecords }} records</span>
      <button type="button" class="btn btn-light btn-sm" (click)="ctx.search()">
        Refresh
      </button>
    </div>
  </template>
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
- mark secondary columns with `hideOnMobile` before enabling `mobileResponsiveCollapse`;
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

When the bound model is `null`, `li-select` keeps the selection empty and
renders the configured `placeholder`. Use `placeholder="Selecione"` to show an
empty-state label, `[placeholder]="''"` for a visually blank trigger, or
`[autoSelectFirstOption]="true"` only when the first enabled option should be
selected intentionally.

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

- [lib/src/components/select/li_select.dart](lib/src/components/select/li_select.dart)
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
- `selectDescendantsOnParentSelect` in multiple mode to select/deselect a loaded parent branch in one user action
- `mobilePresentation`, `mobileBreakpoint`, and `mobileHeightBreakpoint` to switch the dropdown to a fullscreen modal or sheet on small screens
- `showPanelActions` to toggle the footer action bar with confirm, clear, and expand-or-collapse-all actions
- `expandTogglePlacement` to move the expand/collapse-all toggle between the footer, the search row, or hide it
- `expandAllButtonLabel`, `collapseAllButtonLabel`, and `confirmButtonLabel` to localize the action labels

```html
<li-treeview-select
  [pageLoader]="loadTreeChunk"
  [pageSize]="20"
  [multiple]="true"
  [closeOnSelect]="false"
  [selectDescendantsOnParentSelect]="true"
  mobilePresentation="modal"
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
- expand/load lazy branches before selecting a parent when `selectDescendantsOnParentSelect` must include those descendants
- keep the default `mobilePresentation="modal"` for touch-heavy forms; use `"dropdown"` only when an anchored overlay is explicitly required
- keep remote search on the backend through `request.searchTerm`
- use `canSelectNode` for rules such as leaf-only selection
- use `showPanelActions="false"` plus `expandTogglePlacement="search"` when the footer would be redundant and the user still needs a fast expand/collapse control

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

### Date Range Picker

`li-date-range-picker` is the paired-range companion to `li-date-picker`. It supports the original Portuguese API with `inicio`/`fim` and now also accepts the English aliases `start`/`end`, with matching `startChange` and `endChange` outputs.

```html
<li-date-range-picker
  [start]="rangeStart"
  [end]="rangeEnd"
  [minDate]="minDate"
  [maxDate]="maxDate"
  (startChange)="onRangeStartChange($event)"
  (endChange)="onRangeEndChange($event)">
</li-date-range-picker>
```

Use `inicio`/`fim` when you need backward compatibility with existing code, or `start`/`end` when the host API is already standardized in English. Both forms map to the same internal state and can be used interchangeably at the component boundary.

The picker also supports predefined ranges through `presets`, following the same interaction model popularized by date-range-picker libraries: a shortcut applies a known start/end range, and the optional custom-range action reveals the calendars for manual selection.

```dart
final reportRanges = <LiDateRangePreset>[
  LiDateRangePreset(
    label: 'Today',
    value: 'today',
    start: DateTime(2026, 6, 29),
    end: DateTime(2026, 6, 29),
  ),
  LiDateRangePreset(
    label: 'Last 7 Days',
    value: 'last_7_days',
    start: DateTime(2026, 6, 23),
    end: DateTime(2026, 6, 29),
  ),
];
```

```html
<li-date-range-picker
  [presets]="reportRanges"
  [start]="rangeStart"
  [end]="rangeEnd"
  (startChange)="rangeStart = $event"
  (endChange)="rangeEnd = $event">
</li-date-range-picker>
```

Use `[presetAutoApply]="false"` when the user should confirm a preset with the Apply button, `[alwaysShowCalendars]="true"` when shortcuts and calendars should stay visible together, `[showCalendarsForCustomRange]="true"` when a non-preset current value should open directly with calendars visible, and `[showCustomRangePreset]="false"` when the list should contain only fixed shortcuts.

On mobile widths, date, date range, and time pickers use `mobilePresentation="modal"` by default and render as fullscreen modals with internal scrolling. Set `mobilePresentation="dropdown"` only when an anchored overlay is explicitly preferred.

References:

- [example/lib/src/pages/date_range/date_range_page.dart](example/lib/src/pages/date_range/date_range_page.dart)
- [example/lib/src/pages/date_range/date_range_page.html](example/lib/src/pages/date_range/date_range_page.html)

### Modal with lazy content

```html
<li-modal
  title-text="Heavy report"
  size="fluid"
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

For width control, `size` now supports the intermediate steps `xx-large`, `xxx-large`, and `fluid` between `xtra-large` and `modal-full`. Use `fluid` when you want a near-full-width dialog without switching to the fullscreen shell.

Additional sizing and chrome inputs include `compactHeader` and `smallHeader` when the default Limitless header density is too tall for short dialogs or fullscreen administrative forms.

If you want `size="modal-full"` to behave like a true full-screen shell with straight edges, opt in with `fullScreenShell="true"`. Without that input, `modal-full` keeps the viewport-sized body but preserves the regular rounded modal look.

When you need a flush body with no Bootstrap `modal-body` padding, set `[enableModalBodyClass]="false"`. In that mode the body wrapper is intentionally raw by default. If custom fullscreen content still needs a no-padding flex/min-height wrapper, opt in with `[enableModalBodyLayout]="true"` and add any extra classes through `bodyClass`.

For locked flows, combine `closeOnEscape="false"`, `closeOnBackdropClick="false"`, and `enableCloseBtn="false"` so the user can leave only through your explicit action buttons.

```html
<li-modal
  title-text="Quick review"
  size="modal-sm"
  [smallHeader]="true"
  [lazyContent]="true">
  <div class="p-3">Compact modal content</div>
</li-modal>
```

```html
<li-modal
  title-text="Fullscreen table"
  [fullScreenOnMobile]="true"
  [enableModalBodyClass]="false">
  <li-datatable
    [data]="frame"
    [settings]="settings"
    [dataTableFilter]="filters">
  </li-datatable>
</li-modal>
```

```html
<li-modal
  title-text="Custom flex body"
  [enableModalBodyClass]="false"
  [enableModalBodyLayout]="true"
  bodyClass="p-0">
  <my-flex-panel></my-flex-panel>
</li-modal>
```

Use `compactHeader` when you want a subtler reduction without changing the overall rhythm as aggressively as `smallHeader`. The fullscreen demo route also now shows `size="modal-full"` combined with `smallHeader` for long-form administrative flows.

Use `fullScreenShell` only in flows that really need the app-shell feel; for many screens, keeping the regular rounded modal look on `modal-full` is visually safer.

### Toast

`li-toast` covers the inline declarative case. It renders the toast markup, exposes `show()`, `hide()`, and `isOpen`, and supports `header`, `body`, `helperText`, `badgeText`, `iconClass`, `autohide`, `delay`, `dismissible`, `pauseOnHover`, and `rounded`.

When `toastClass` or `headerClass` uses light text such as `text-white`, the component now adapts the header chrome automatically so the badge, helper text, and close button remain legible without extra host CSS.

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
`menuClass`, `placement`, `rounded`, `showCaret`, `closeOnSelect`,
`closeOtherMenusOnOpen`, `menuMaxHeight`, `mobilePresentation`,
`mobileBreakpoint`, `mobileMenuTitle`, `adaptToViewport`, and `container`.

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
  container="body"
  placement="dropend"
  menuMaxHeight="18rem"
  mobilePresentation="sheet"
  mobileMenuTitle="Actions"
  [adaptToViewport]="true"
  (valueChange)="onAction($event)">
</li-dropdown-menu>
```

Use `container="body"` when the trigger lives inside clipped panels, tables, cards, or any `overflow: hidden`/`auto` ancestor and you want the menu to escape that stacking context. Use `container="inline"` when normal DOM flow is preferred. The same inline-versus-body overlay choice is also available on the lower-level `dropdownmenu` directive through `dropdownmenuContainer`.

Use `menuMaxHeight` for longer option lists so the menu scrolls vertically instead of growing past the viewport.

Set `mobilePresentation="modal"` or `mobilePresentation="sheet"` when small screens should use a touch-friendly fixed presentation instead of an anchored dropdown. The mobile mode is selected with `mobileBreakpoint`, which defaults to `575.98px`; `mobileMenuTitle` adds an optional header/title to the mobile surface. Modal and sheet presentations cap themselves to the visual viewport and scroll their option list internally.

`adaptToViewport` is enabled by default. For `container="body"`, Popper uses fallback placements and the component applies an available-height cap when needed, so the option list can scroll instead of being clipped. For `container="inline"`, the component automatically flips a default downward menu to `dropup` when there is not enough space below the trigger and there is more room above it, and applies the same available-height cap with vertical scrolling when needed.

The menu closes on outside click, `Escape`, or selection depending on `closeOnSelect`. Main reference: [lib/src/components/dropdown_menu/dropdown_menu_component.dart](lib/src/components/dropdown_menu/dropdown_menu_component.dart).

By default, opening one `li-dropdown-menu` closes other open instances first, which is usually the right behavior for headers and action toolbars. Set `closeOtherMenusOnOpen="false"` only for special cases such as submenu-like compositions or coordinated multi-panel controls.

### Declarative Dropdown Structure

Use the lower-level `liDropdown` directives when the menu contains custom markup, account blocks, dividers, explanatory text, or nested submenus. This API intentionally follows the Bootstrap/Limitless dropdown DOM contract: the dropdown host owns one toggle/anchor and one menu.

Keep this structure tight:

```html
<div liDropdown placement="bottom-end" container="body">
  <button type="button"
          liDropdownToggle
          liDropdownShowCaret="false"
          class="navbar-nav-link rounded-pill">
    Account
  </button>

  <div liDropdownMenu class="dropdown-menu-end">
    <button type="button" liDropdownItem>Profile</button>
    <div class="dropdown-divider"></div>
    <button type="button" liDropdownItem>Logout</button>
  </div>
</div>
```

The menu element should be the element with `liDropdownMenu`. Put placement classes such as `dropdown-menu-end` on that same element. Avoid wrapping `liDropdownMenu` inside extra positioned containers unless the wrapper is part of the dropdown host itself; extra wrappers are the most common reason a menu appears offset, clipped, or aligned to the wrong node.

Do not mix `liDropdownToggle` with Bootstrap's `data-bs-toggle="dropdown"` for the same menu. Let `liDropdown` own the open state, `.show` classes, keyboard handling, outside click behavior, and Popper positioning.

`liDropdownToggle` and `liDropdownAnchor` expose `liDropdownShowCaret` (default: `true`). Set `liDropdownShowCaret="false"` when you need navbar/avatar triggers without the theme caret pseudo-element (`.dropdown-toggle::after`).

`display` defaults to `static` inside a `.navbar` and `dynamic` elsewhere. Static navbar dropdowns rely on the Limitless/Bootstrap CSS flow and usually work well for simple header menus. Use `display="dynamic"` when the menu must be positioned by Popper, especially for custom app bars, right-aligned account menus, or cases where the trigger is not inside a normal Bootstrap navbar flow.

Use `container="body"` when the dropdown is declared inside a scrollable or clipped area such as a table, sidebar, card, modal body, `overflow: hidden`, or `overflow: auto` container. In this mode the menu is temporarily moved under `document.body` while open, so it escapes clipping and stacking-context bugs. The tradeoff is that component-scoped styles from the original parent may no longer reach the menu; use global classes, `dropdownClass`, or classes directly on `liDropdownMenu` for menu styling that must survive body mounting.

`liDropdown` also supports `adaptToViewport` (default: `true`) for Popper-driven menus. In `display="dynamic"` mode the directive waits for the menu to become visible, recalculates after the real menu size is known, preserves the preferred placement whenever possible, and clamps the floating panel to the viewport when long or tall content would otherwise overflow.

Do not use `adaptToViewport` for body-mounted dynamic organization/account switchers when the application already controls the menu surface with CSS such as `width: max-content`, `max-width: min(...)`, `calc(100vw - ...)`, horizontal overflow, or custom wrapping rules. That combination can make AngularDart, Popper, and the browser alternate between the unclamped and clamped measurements, causing an infinite class/style recalculation loop. Prefer `adaptToViewport="false"` and keep the width/overflow contract in CSS for that dropdown.

For body-mounted dynamic dropdowns, treat Popper as the owner of the wrapper position. Do not add consumer-side scripts or local component code that rewrites the body wrapper `transform` after Popper has positioned it, and avoid CSS or JavaScript that depends on the internal `--popper-available-*` variables for these menus. In long organization/account switchers this can create a measurement feedback loop where available height/width changes on every frame and the dropdown appears to redraw indefinitely.

Use `menuMaxWidth` and `menuMaxHeight` when dense account menus or body-mounted navbar switchers need a predictable surface cap without relying only on external CSS. This is especially useful for avatar menus, organization switchers, and long explanatory blocks that can grow much wider or taller than the trigger.

#### Best practices for body-mounted dynamic dropdowns

For navbar account/organization switchers and any other `liDropdown` rendered with `container="body"` + `display="dynamic"`, follow the rules below. They are the contract that prevents the infinite style/class recalculation loop documented in the `1.0.0-dev.23` notes.

1. **Pick one owner of the menu width/overflow.** Either the application controls it via CSS (`width: max-content`, `max-width: min(...)`, `calc(100vw - ...)`, horizontal overflow rules), or the directive controls it via `menuMaxWidth`/`menuMaxHeight`. **Do not combine both.** When the CSS path is used, set `adaptToViewport="false"` on the `liDropdown` host.
2. **Popper owns position; CSS owns size.** Never write inline `transform`, `top`, `left`, `right`, `bottom`, or `inset` on `.dropdown-menu`, on the `liDropdownMenu` host, or on the body wrapper created by `dropdownClass`. Do not add app-level scripts that mutate the wrapper `style` after open. The directive uses Popper as the single source of truth for those properties on body-mounted dynamic menus.
3. **Do not depend on `--popper-available-*` CSS variables for body-mounted menus.** Reading those values in app CSS, observing them in JavaScript, or writing them back through host CSS can feed back into measurement and trigger repeated reposition/redraw cycles.
4. **Scope inline-only overrides to inline submenus.** Patterns like `position: static; inset: auto; transform: none !important;` are safe for inline submenus that are *not* positioned by Popper (for example a responsive mobile collapse of a user menu submenu). Never apply those rules to selectors that match a body-mounted dynamic `.dropdown-menu` or to the wrapper created via `dropdownClass`.
5. **Stylize through stable hooks.** The dropdown panel can lose the original component-scoped selectors when it is moved to `document.body`. Use a global class on `liDropdownMenu` or `dropdownClass="..."` on the host to target the body wrapper. Both selectors must live in a stylesheet that is not view-encapsulated to the original host.
6. **Never put `width`/`max-width` on the body wrapper for trigger alignment.** The wrapper is positioned by Popper and is the floating element. Constrain the visual size of the menu via the `.dropdown-menu` selector (or `dropdownClass`'s descendant rules), not by resizing the wrapper itself. A `max-width: calc(100vw - .5rem)` on the wrapper is acceptable only as a defensive cap to prevent horizontal bleed.
7. **Keep the menu content stable across change-detection.** Bind to fields, not getters that allocate new lists/objects on every pass (see the AngularDart performance rules). A menu whose `*ngFor` source identity changes on every cycle forces Popper to remeasure on every frame and can amplify any positioning instability into a visible flicker loop.

##### Reference template (organization/account switcher)

```html
<li class="nav-item dropdown"
    liDropdown
    placement="bottom-end"
    display="dynamic"
    container="body"
    dropdownClass="org-switcher-dropdown-wrapper"
    adaptToViewport="false">
  <button type="button"
      class="navbar-nav-link rounded-pill p-0 border-0 bg-transparent"
      [liDropdownShowCaret]="false"
      liDropdownToggle>
    <!-- avatar / badge content -->
  </button>

  <div class="dropdown-menu dropdown-menu-end org-switcher-dropdown" liDropdownMenu>
    <button *ngFor="let org of organizations"
        type="button"
        class="org-switcher-dropdown__item"
        liDropdownItem
        (click)="selectOrganization(org)">
      {{ org.fullName }} - {{ org.id }}
    </button>
  </div>
</li>
```

```scss
// Wrapper created by `liDropdown` under `document.body` when `container="body"`.
// Defensive cap so the floating wrapper never bleeds horizontally.
.org-switcher-dropdown-wrapper {
  max-width: calc(100vw - 0.5rem);
}

// CSS owns the panel surface size. Because of this, the host has
// `adaptToViewport="false"` and does NOT pass `menuMaxWidth`/`menuMaxHeight`.
.org-switcher-dropdown {
  width: max-content;
  min-width: 18rem;
  max-width: min(34rem, calc(100vw - 1rem));
}
```

##### Common anti-patterns to avoid

- Setting `transform: none !important` on `.dropdown-menu` globally to "fix" alignment of a body-mounted dropdown. This breaks Popper positioning and the directive cannot recover from it.
- Listening to `(openChange)` and calling code that mutates the menu DOM, classes, or inline style on every emission. The directive already toggles `.show`, attributes, and Popper geometry — extra mutations on the same frame create a feedback loop.
- Wrapping `liDropdownMenu` in an extra positioned container inside the host. The menu element itself must be the one with `liDropdownMenu`.
- Mixing `liDropdownToggle` with Bootstrap's `data-bs-toggle="dropdown"` for the same menu.
- Using `menuMaxWidth` together with `width: max-content` and a CSS `max-width: min(...)` on the same panel. Pick one path.

Placement strings may contain fallbacks separated by spaces, for example `bottom-start bottom-end top-start top-end`. The first placement remains the preferred alignment and the later values are only used when the preferred one would not fit the viewport. Prefer `bottom-start` when the menu should begin below the trigger left edge, and `bottom-end` when the menu should stay right-aligned to avatar/account triggers.

Use inline rendering only when the menu should stay in the local DOM flow:

```html
<div liDropdown container="inline" display="static">
  <button type="button" liDropdownToggle>Local menu</button>
  <div liDropdownMenu>...</div>
</div>
```

For account menus like SALI/Portal, prefer this pattern: `liDropdown` on the `li.nav-item` or a compact wrapper, `liDropdownToggle` on the clickable avatar/name button, and `liDropdownMenu` directly inside that same host. Put submenus inside the menu, not as sibling dropdowns.

### Dropdown Submenus

When you need richer account menus or nested action trees, keep using the declarative dropdown API and add the submenu directives on top of it.

```html
<div liDropdown placement="bottom-end" container="body" display="dynamic">
  <button liDropdownToggle>Account</button>
  <div class="dropdown-menu-end" liDropdownMenu>
    <button liDropdownItem>Profile</button>

    <div liDropdownSubmenu #themeSubmenu="liDropdownSubmenu" placement="start">
      <button liDropdownItem liDropdownSubmenuToggle [class.active]="themeSubmenu.isOpen">
        Theme
      </button>

      <div liDropdownSubmenuMenu>
        <button liDropdownItem>Light</button>
        <button liDropdownItem>Dark</button>
      </div>
    </div>
  </div>
</div>
```

`liDropdownSubmenuToggle` opens the nested menu without collapsing the parent dropdown, while nested `liDropdownItem` elements remain part of the same keyboard navigation model only when that submenu is open.

`placement="start"` opens the submenu to the left, which is usually what right-aligned account menus need near the viewport edge. Keyboard navigation follows the visual direction: for `placement="start"`, `ArrowLeft` opens the submenu and `ArrowRight` returns to the parent toggle. For the default end placement, the directions are reversed.

Submenus expose `open`, `openChange`, `openOnHover`, `closeOnItemClick`, and the exported instance `#submenu="liDropdownSubmenu"`. Use these instead of maintaining parallel `.show` flags in application code.

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
dart test test/currency_input_formatter_test.dart test/lite_xlsx_test.dart test/tine_pdf_test.dart test/treeview/treeview_settings_test.dart
```

Run browser and AngularDart tests in Chrome:

```bash
dart run build_runner test -- -p chrome -j 1 test/alerts/alert_component_test.dart test/alerts/li_alert_component_test.dart test/progress_component_test.dart test/datatable/li_datatable_component_test.dart test/accordion/li_accordion_directive_test.dart test/dropdown/li_dropdown_directive_test.dart test/modal/li_modal_component_test.dart test/nav/li_nav_directive_test.dart test/popover/li_popover_component_test.dart test/scrollspy/li_scrollspy_directive_test.dart test/typeahead/li_typeahead_component_test.dart test/toast/li_toast_component_test.dart test/tooltip/li_tooltip_directive_test.dart test/wizard/li_wizard_component_test.dart
```

Run the real example-app Puppeteer E2E suite from the repository root after serving `example/web`:

```bash
cd example
dart run webdev serve web:8081 --auto refresh --hostname 0.0.0.0 -- --delete-conflicting-outputs
```

In another shell:

```bash
RUN_EXAMPLE_E2E=true UI_EXAMPLE_BASE_URL=http://127.0.0.1:8081 CHROME_EXECUTABLE=/path/to/chrome dart test ui_test/e2e/puppeteer_test.dart
```

On Windows PowerShell, set the environment variables before running the same test file:

```powershell
$env:RUN_EXAMPLE_E2E = 'true'
$env:UI_EXAMPLE_BASE_URL = 'http://127.0.0.1:8081'
$env:CHROME_EXECUTABLE = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
dart test ui_test\e2e\puppeteer_test.dart
```

Without `RUN_EXAMPLE_E2E=true`, the Puppeteer tests are intentionally skipped so normal local `dart test` runs do not need a running web server.

Generate local coverage for the VM-only suite:

```bash
dart test --coverage=coverage/vm_raw test/currency_input_formatter_test.dart test/lite_xlsx_test.dart test/tine_pdf_test.dart test/treeview/treeview_settings_test.dart
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage/vm_raw --out=coverage/vm.lcov.info --report-on=lib --packages=.dart_tool/package_config.json
```

Codecov is enabled in CI through `CODECOV_TOKEN` and publishes only the VM LCOV report. The browser and AngularDart suite still runs in CI as a functional safety net, but it does not contribute coverage to Codecov in this repository.

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

The demo app under [example](example) now includes dedicated routes for accordion, breadcrumbs, color picker, currency input, datatable, datatable select, dropdown, fab, file upload, inputs, modal, nav, offcanvas, page header, pagination, PDF viewer, person registration, popover, quill text editor, rating, scrollspy, select, multi-select, tabs, toast, treeview, typeahead, tooltip, wizard, work queue, and selection-control examples.

Use the demo app as the reference for real template usage, especially for lazy accordion bodies, lazy modal content, scrollspy menus, overlay components that depend on browser geometry, the PDF.js and Quill integration pages, and the `person-registration` route that demonstrates an end-to-end form with declarative frontend rules plus fake backend validation.

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
