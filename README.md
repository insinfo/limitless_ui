# limitless_ui

Reusable AngularDart UI components, directives and small browser helpers for applications built on the Limitless visual language.

This package is browser-only. It depends on `dart:html`, `ngdart`, `ngforms` and `ngrouter`.

## Publication status

The package is prepared for publication and currently versioned as `1.0.0-dev.1`, because it still depends on AngularDart pre-release packages:

- `ngdart: ^8.0.0-dev.4`
- `ngforms: ^5.0.0-dev.3`
- `ngrouter: ^4.0.0-dev.3`

Publication metadata is configured in [pubspec.yaml](/c:/MyDartProjects/limitless_ui/pubspec.yaml) and CI is defined in [ci.yml](/c:/MyDartProjects/limitless_ui/.github/workflows/ci.yml).

## Installation

```yaml
dependencies:
  limitless_ui: ^1.0.0-dev.1
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

## Included modules

- Inputs: currency input, date picker, time picker, date range picker, select, multi-select.
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

## Recent additions in `1.0.0-dev.1`

- Added first-class dropdown, nav, popover and scrollspy modules to the public API.
- Expanded accordion into a fuller directive set for host-driven and template-driven compositions.
- Added collapse as a reusable directive/config pair.
- Added injectable config objects for tooltip, popover, dropdown, nav and scrollspy.
- Added `lazyContent` support to `li-modal` so heavy projected content can be created only while the modal is open.
- Expanded the demo app with pages for dropdown, nav, popover and scrollspy, plus richer modal, tooltip, accordion and datatable examples.
- Added tests for the new surface area, including accordion lazy rendering, modal lazy content and overlay/navigation components.

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

```dart
final settings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(
      key: 'name',
      title: 'Name',
      sortingBy: 'name',
      enableSorting: true,
    ),
    DatatableCol(
      key: 'email',
      title: 'Email',
    ),
  ],
);
```

```html
<li-datatable
  [data]="usersFrame"
  [settings]="settings"
  [dataTableFilter]="filters"
  (dataRequest)="loadUsers($event)">
</li-datatable>
```

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
final cents = BrazilianCurrencyInputFormatter.minorUnitsFromText('1.234,56');
final display = BrazilianCurrencyInputFormatter.formatForDisplay(cents);
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
dart run build_runner test -- -p chrome -j 1 test/alerts/alert_component_test.dart test/alerts/li_alert_component_test.dart test/progress_component_test.dart test/datatable/li_datatable_component_test.dart test/accordion/li_accordion_directive_test.dart test/dropdown/li_dropdown_directive_test.dart test/modal/li_modal_component_test.dart test/nav/li_nav_directive_test.dart test/popover/li_popover_component_test.dart test/scrollspy/li_scrollspy_directive_test.dart test/tooltip/li_tooltip_directive_test.dart
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
