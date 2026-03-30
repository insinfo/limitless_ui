# limitless_ui

`limitless_ui` is a reusable AngularDart UI package for web applications.
created in top of https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/css/all.min.css 
and https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/icons/phosphor/2.0.3/styles.min.css


check ./example for demo

It groups generic components, directives, pipes, and small UI helpers that can
be shared across multiple frontend projects.

## Scope

The package currently includes:

- data entry components such as `li-currency-input`, custom select, custom
  multi-select, and a date range picker
- data presentation components such as the datatable and tree view
- structural components such as accordions, carousels, dynamic tabs, and
  progress bars
- feedback helpers such as loading overlays, notification toasts, dialogs,
  popovers, tooltips, and toast utilities
- layout/navigation helpers such as dynamic tabs
- shared AngularDart directives and value accessors
- utility pipes and DOM extensions

## Main exports

Import the public barrel:

```dart
import 'package:limitless_ui/limitless_ui.dart';
```

The public API includes exports for:

- `LiAccordionComponent`, `LiAccordionItemComponent`, and
  `LiAccordionHeaderDirective`
- `LiAlertComponent`
- `LiCarouselComponent` and `LiCarouselItemComponent`
- `LiCurrencyInputComponent`
- `LiCurrencyInputFormatter`
- `LiSelectComponent` and `LiOptionComponent`
- `LiMultiSelectComponent` and `LiMultiOptionComponent`
- `LiDataTableComponent`, `DatatableCol`, `DatatableRow`, `DatatableSettings`
- `LiDateRangePickerComponent`
- `LiTabsComponent`, `LiTabxDirective`, and `LiTabxHeaderDirective`
- `SimpleLoading`
- `LiNotificationOutletComponent` and `NotificationToastService`
- `LiProgressComponent` and `LiProgressBarComponent`
- `SimpleDialogComponent`
- `SimplePopover`
- `SimpleToast`
- `SweetAlertPopover` and `SweetAlertSimpleToast`
- `LiTooltipComponent`
- `LiTreeViewComponent` and `TreeViewNode`
- `ClickOutsideDirective`, `DropdownMenuDirective`,
  `SafeHtmlDirective`, `SafeAppendHtmlDirective`, `SafeInnerHtmlDirective`,
  `IndexedNameDirective`, and `limitlessFormDirectives`
- `CustomDatePipe` and `HideStringPipe`

## Local development

Inside this monorepo, add the package as a path dependency:

```yaml
dependencies:
  limitless_ui:
    path: ../packages/limitless_ui
```

When the package is published, this can be replaced with a hosted dependency
from `pub.dev`.

## Testing

## AngularDart template notes

For custom HTML attributes in AngularDart templates, always bind them with the
attribute syntax instead of writing the attribute name directly.

Correct:

```html
<button [attr.data-bs-toggle]="'dropdown'"></button>
<div [attr.aria-expanded]="isOpen.toString()"></div>
```

Incorrect:

```html
<button data-bs-toggle="dropdown"></button>
<div aria-expanded="true"></div>
```

When the value must be static in the template, still prefer the AngularDart
attribute form:

```html
[attr.nome-atributo]="'valor'"
```

This avoids AngularDart template validation issues and keeps attribute binding
behavior explicit.

## AngularDart template syntax rules

### Never use multiple statements in event bindings

The AngularDart template parser does **not** support semicolons (`;`) inside
`(event)="..."` expressions. Writing two statements in the same binding will
fail at compile time with:

> Parser Error: A function body must be provided.

**Bad — compile error:**

```html
<my-component
    (ngModelChange)="ngModelValue = $event; onNgModelChanged()">
</my-component>
```

**Good — delegate to a single method:**

```html
<my-component
    [ngModel]="ngModelValue"
    (ngModelChange)="onNgModelValueChanged($event)">
</my-component>
```

```dart
void onNgModelValueChanged(dynamic value) {
  ngModelValue = value?.toString();
  onNgModelChanged();
}
```

This applies to **all** event bindings, not just `ngModelChange`.

## Performance notes

### Never use `[attr.style]` for CSS layout properties

Using `[attr.style]="someString"` in AngularDart templates causes the entire
style string to pass through the DOM attribute sanitizer on **every** change
detection cycle.  When the string contains complex geometry rules such as
`grid-template-columns: repeat(auto-fit, minmax(280px, 1fr))`, the browser's
layout engine enters a reflow loop (layout thrashing) that can freeze the tab
for 5–20 seconds.

**Bad — causes layout thrashing:**

```html
<div class="grid-layout" [attr.style]="gridLayoutStyle">
```

**Good — binds directly to the style API (`element.style.*`), no sanitizer:**

```html
<div class="grid-layout"
     [style.grid-template-columns]="settings.gridTemplateColumns"
     [style.gap]="settings.gridGap">
```

Use `[style.<property>]` for any CSS property that may change at runtime.
Reserve `[attr.style]` only for non-layout attributes or static values.

### Use `trackBy` on every `*ngFor`

Without `trackBy`, Angular destroys and recreates every DOM element whenever
the backing list is reassigned — even if the data is identical.  Combined with
heavy directives like `[safeHtml]` / `[safeHtmlNode]`, this causes severe
rendering stalls when switching between list and grid views.

Always provide a `trackBy` function:

```html
<div *ngFor="let row of rows; trackBy: trackByRow">
```

### Prefer `SafeHtmlDirective` over separate inner/append directives

The old pattern of combining `[safeInnerHtml]` + `[safeAppendHtml]` on the
same element caused a double-render race condition: the first directive wrote
HTML, then the second one appended a node, triggering two separate reflows.

The unified `SafeHtmlDirective` (`[safeHtml]` + `[safeHtmlNode]`) resolves
both inputs in a single pass — if a DOM node is provided it wins; otherwise
the HTML string is written.  The old directives are kept for backwards
compatibility but should not be used in new code.

### Prefer `[class.hide]` over `*ngIf` for view mode toggling

`*ngIf` destroys and recreates the entire subtree each time it toggles.  For
sections that switch frequently (e.g. table ↔ grid), prefer hiding via CSS:

```html
<div class="datatable-scroll" [class.hide]="gridMode">
```

This keeps the DOM intact and lets the browser toggle `display: none`
instantly.

Run analyzer checks from the package root:

```bash
dart analyze
```

Run pure Dart unit tests from the package root:

```bash
dart test
```

Run AngularDart browser tests with `build_runner`, since those files depend on
generated `.template.dart` artifacts and will not compile correctly with plain
`dart test`:

```bash
dart run build_runner test -- -p chrome -j 1 test/datatable/li_datatable_component_test.dart
```

When running browser tests from the library package root, keep the root
`build.yaml` scoped to the package sources only. This repository intentionally
includes:

```yaml
targets:
  $default:
    sources:
      include:
        - $package$
        - pubspec.*
        - lib/**
        - test/**
      exclude:
        - example/**
        - build/**
        - .dart_tool/**
```

That prevents `build_runner` from trying to compile the demo app under
`example/` while executing the package test suite.

If you need to build or test the demo app itself, switch into `example/` and
run its own build there:

```bash
cd example
dart pub get
dart run build_runner build --delete-conflicting-outputs
```

If you hit stale resolver or asset graph issues, clear both caches before
rerunning browser tests:

```powershell
Remove-Item -Recurse -Force .dart_tool, build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force example/.dart_tool, example/build -ErrorAction SilentlyContinue
dart pub get
cd example
dart pub get
```

## Quick start

```dart
import 'package:limitless_ui/limitless_ui.dart';

@Component(
  selector: 'demo-page',
  template: '''
    <li-notification-outlet [service]="notifications"></li-notification-outlet>

    <li-currency-input
      [(ngModel)]="amountMinorUnits"
      [required]="true">
    </li-currency-input>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiNotificationOutletComponent,
    LiCurrencyInputComponent,
  ],
)
class DemoPage {
  final notifications = NotificationToastService();

  int? amountMinorUnits;

  void save() {
    notifications.notify('Saved successfully.');
  }
}
```

Toast sounds are opt-in. The library does not ship with a built-in audio asset.

```dart
final notifications = NotificationToastService.withSound(
  audioSrc: 'assets/audio/toast.mp3',
);

// Or provide your own player callback.
final notificationsWithCustomPlayer = NotificationToastService(
  soundController: ToastSoundController(
    customPlayer: () async {
      // trigger your own audio pipeline here
    },
  ),
);
```

## Currency input

`li-currency-input` stores values as minor units (`int?`), which makes it easy
to keep currency calculations consistent in forms and API payloads.

```dart
final text = BrazilianCurrencyInputFormatter.formatForDisplay(123456);
// 1.234,56

final minorUnits =
    BrazilianCurrencyInputFormatter.minorUnitsFromText('R\$ 1.234,56');
// 123456
```

## Select and multi-select

`li-select` and `li-multi-select` support both projected options and external
collections passed through `dataSource`.

```dart
@Component(
  selector: 'demo-selects',
  template: '''
    <li-select
      [dataSource]="statusOptions"
      labelKey="label"
      valueKey="id"
      disabledKey="disabled"
      [(ngModel)]="selectedStatus">
    </li-select>

    <li-multi-select
      class="mt-3"
      [dataSource]="channelOptions"
      labelKey="label"
      valueKey="id"
      [(ngModel)]="selectedChannels">
    </li-multi-select>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiSelectComponent,
    LiMultiSelectComponent,
  ],
)
class DemoSelectsComponent {
  final List<Map<String, dynamic>> statusOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Draft'},
    <String, dynamic>{'id': 'review', 'label': 'In review'},
    <String, dynamic>{'id': 'approved', 'label': 'Approved'},
    <String, dynamic>{'id': 'archived', 'label': 'Archived', 'disabled': true},
  ];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'E-mail'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
  ];

  String selectedStatus = 'review';
  List<dynamic> selectedChannels = <dynamic>['email', 'push'];
}
```

### Important usage notes

- Keep `dataSource` stable. Prefer `final` or `late final` lists created once in
  the parent component.
- Avoid getters that recreate the option list on every change detection pass.
- Use `disabledKey` only when the option source has an explicit boolean field.
- Prefer projected `li-option` or `li-multi-option` when the option list is
  static in the template.

### Troubleshooting

If a select appears to freeze the page, check these points first:

- The parent page must not rebuild equivalent `dataSource` arrays from getters.
- Overlay sizing must be based on viewport and trigger geometry, not on the
  dropdown panel's current rendered height.
- Global keyboard listeners should only handle navigation keys such as `Escape`,
  `Enter`, `ArrowUp`, and `ArrowDown`.

## Accordion

`li-accordion` follows the Limitless/Bootstrap accordion markup and supports
lazy body rendering so expensive DOM trees are only created when the user opens
an item.

```dart
@Component(
  selector: 'demo-accordion',
  template: '''
    <li-accordion [lazy]="true" [destroyOnCollapse]="false">
      <li-accordion-item header="Filtros avançados" description="Conteúdo pesado só aparece ao abrir">
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label">Nome</label>
            <input class="form-control" type="text">
          </div>
          <div class="col-md-6">
            <label class="form-label">CPF</label>
            <input class="form-control" type="text">
          </div>
        </div>
      </li-accordion-item>

      <li-accordion-item [expanded]="true" header="Resumo">
        <template li-accordion-header>
          <span class="d-flex align-items-center gap-2">
            <i class="ph ph-chart-bar"></i>
            <span>Resumo</span>
          </span>
        </template>

        <p class="mb-0">Item aberto por padrão.</p>
      </li-accordion-item>
    </li-accordion>
  ''',
  directives: [
    coreDirectives,
    LiAccordionComponent,
    LiAccordionItemComponent,
    LiAccordionHeaderDirective,
  ],
)
class DemoAccordionComponent {}
```

## Carousel

`li-carousel` follows the Limitless/Bootstrap carousel structure and supports
controls, indicators, autoplay, keyboard navigation, dark mode, optional touch
swipe navigation, and configurable transitions through the `transition` input.

Supported transition values:

- `slide` (default)
- `fade`
- `zoom`
- `vertical`
- `blur`
- `parallax`

```dart
@Component(
  selector: 'demo-carousel',
  template: '''
    <li-carousel
      transition="zoom"
      [showIndicators]="true"
      [showControls]="true"
      [autoPlay]="true"
      [intervalMs]="4000">
      <li-carousel-item indicatorLabel="Slide 1" [active]="true">
        <img src="assets/images/demo/carousel/1.jpg" class="d-block w-100" alt="Primeiro slide">
        <div class="carousel-caption d-none d-md-block">
          <h5>Primeiro slide</h5>
          <p>Conteúdo de exemplo.</p>
        </div>
      </li-carousel-item>

      <li-carousel-item indicatorLabel="Slide 2">
        <img src="assets/images/demo/carousel/2.jpg" class="d-block w-100" alt="Segundo slide">
      </li-carousel-item>

      <li-carousel-item indicatorLabel="Slide 3" [intervalMs]="7000">
        <div class="row g-0">
          <div class="col-4"><img src="assets/images/demo/carousel/5.jpg" class="d-block w-100" alt=""></div>
          <div class="col-4"><img src="assets/images/demo/carousel/6.jpg" class="d-block w-100" alt=""></div>
          <div class="col-4"><img src="assets/images/demo/carousel/7.jpg" class="d-block w-100" alt=""></div>
        </div>
      </li-carousel-item>
    </li-carousel>
  ''',
  directives: [
    coreDirectives,
    LiCarouselComponent,
    LiCarouselItemComponent,
  ],
)
class DemoCarouselComponent {}
```

If you still use `[fade]="true"`, it remains supported and takes precedence
over `transition` for backward compatibility.

## Datatable

`li-datatable` supports server-driven pagination, sorting, search, exports,
card/grid mode, row selection, and responsive mobile collapse.

Use `DatatableCol.hideOnMobile` to move secondary columns into an expandable
child row on small screens. The component keeps table mode on desktop and
switches to a DataTables-style details row pattern on mobile.

```dart
final settings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(
      key: 'feature',
      title: 'Feature',
      enableSorting: true,
      sortingBy: 'feature',
    ),
    DatatableCol(
      key: 'owner',
      title: 'Owner',
      hideOnMobile: true,
    ),
    DatatableCol(
      key: 'status',
      title: 'Status',
      hideOnMobile: true,
    ),
  ],
);
```

```html
<li-datatable
  [dataTableFilter]="filters"
  [data]="tableData"
  [settings]="settings"
  [searchInFields]="searchFields"
  [responsiveCollapse]="true"
  (dataRequest)="loadPage($event)">
</li-datatable>
```

Performance notes:

- The component uses `ChangeDetectionStrategy.onPush`.
- Table rows and columns expose `trackBy` hooks internally to reduce DOM churn.
- Date formatters are cached instead of being instantiated inside the render loop.
- Prefer stable `DataFrame` and `DatatableSettings` instances from the parent when possible.

## Alerts

`li-alert` follows the Limitless/Bootstrap alert markup and supports contextual
variants, solid mode, dismiss buttons, rounded pills, truncation, and block or
inline icons on either side.

```dart
@Component(
  selector: 'demo-alerts',
  template: '''
    <li-alert
      variant="success"
      [dismissible]="true"
      iconMode="block"
      iconClass="ph-check-circle">
      <span class="fw-semibold">Well done!</span>
      You successfully read <a href="#" class="alert-link">this important</a> alert message.
    </li-alert>

    <li-alert
      class="mt-3"
      variant="indigo"
      [solid]="true"
      [dismissible]="true"
      [roundedPill]="true"
      iconMode="inline"
      iconPosition="end"
      iconClass="ph-gear">
      <span class="fw-semibold">Surprise!</span>
      This is a super-duper nice looking <a href="#" class="alert-link text-reset">alert</a> with custom color.
    </li-alert>
  ''',
  directives: [
    coreDirectives,
    LiAlertComponent,
  ],
)
class DemoAlertsComponent {}
```

## Tooltip

`li-tooltip` follows the Limitless/Bootstrap tooltip markup and renders the
floating element on demand using the local popper overlay, with support for
`top`, `right`, `bottom`, `left`, and `auto` placement plus hover, focus,
click, or manual triggers.

```dart
@Component(
  selector: 'demo-tooltip',
  template: '''
    <li-tooltip text="Tooltip no topo">
      <button type="button" class="btn btn-primary">Hover me</button>
    </li-tooltip>

    <li-tooltip
      placement="right"
      trigger="click"
      tooltipClass="tooltip-info"
      title="<strong>Tooltip</strong> com <em>HTML</em>"
      [html]="true">
      <button type="button" class="btn btn-light ms-2">Click me</button>
    </li-tooltip>
  ''',
  directives: [
    coreDirectives,
    LiTooltipComponent,
  ],
)
class DemoTooltipComponent {}
```

## Progress

`li-progress` and `li-progress-bar` follow the Limitless/Bootstrap progress
markup and support stacked bars, inherited min/max ranges, rounded tracks,
striped or animated bars, and inline labels.

```dart
@Component(
  selector: 'demo-progress',
  template: '''
    <li-progress [rounded]="true" height="0.75rem">
      <li-progress-bar value="25" class="bg-success"></li-progress-bar>
      <li-progress-bar value="35" class="bg-danger"></li-progress-bar>
      <li-progress-bar
        value="20"
        class="bg-info"
        [striped]="true"
        [animated]="true"
        [showValueLabel]="true">
      </li-progress-bar>
    </li-progress>

    <li-progress class="mt-3">
      <li-progress-bar
        value="85"
        class="bg-teal"
        label="85% complete">
      </li-progress-bar>
    </li-progress>
  ''',
  directives: [
    coreDirectives,
    LiProgressComponent,
    LiProgressBarComponent,
  ],
)
class DemoProgressComponent {}
```

## Loading overlay

`SimpleLoading` can be used as a lightweight overlay for any element or for the
whole page.

```dart
final loading = SimpleLoading();

try {
  loading.show(target: hostElement);
  // async work
} finally {
  loading.hide();
}
```

## Notes

- This package is designed for AngularDart web applications.
- It uses `dart:html`, so it is not intended for Flutter or server-side Dart.
- Some components depend on `essential_core` models and the `popper` package.
