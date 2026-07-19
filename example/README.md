# `limitless_ui` Example

This folder contains the AngularDart showcase application for the `limitless_ui` package. It is the reference demo used to exercise the current components, pages, routing setup, theme integration, and browser build pipeline.

## What is included

- Component demo pages under `example/lib/src/pages`
- Dedicated demos for inputs, select, multi-select, datatable-select, PDF viewer, Quill text editor, and page-header migration scenarios
- Hash-based routing for static hosting via `routerProvidersHash`
- Localized demo content in Portuguese and English
- SCSS-based component styling compiled by `sass_builder`
- A production build flow used by the GitHub Pages workflow
- Stable `data-label` and `data-value` hooks on interactive demos so browser automation can select real UI controls without depending on translated text or CSS classes

## Requirements

- Dart SDK `^3.6.0`
- Chrome or another supported browser for local testing

## Install dependencies

From the repository root:

```bash
dart pub get
cd example
dart pub get
```

## Run locally

From `example/`:

```bash
dart run webdev serve web:8081 --auto refresh --hostname 0.0.0.0 -- --delete-conflicting-outputs
```

Then open:

```text
http://localhost:8081
```

Notes:

- This project uses `webdev` for local serving because it is the documented Dart web development server.
- The trailing `-- --delete-conflicting-outputs` forwards cleanup to `build_runner` when generated outputs are stale.

If you prefer using a globally activated `webdev`, this equivalent command also works:

```bash
webdev serve web:8081 --auto refresh --hostname 0.0.0.0 -- --delete-conflicting-outputs
```

`build_runner` is still used for builds and tests, but it is not the command documented here for running the example server.

## Selection APIs shown by the example

The select-like picker demos use the same API split expected in consuming apps:

- `currentValueChange` follows the component model and may fire during programmatic synchronization.
- `userValueChange` is reserved for a real user selection made through the UI.
- stable `data-label`, `data-value`, and state attributes are rendered by selection controls for browser automation.

Use `userValueChange` for side effects that should not run during form hydration:

```html
<li-select
  [dataSource]="statusOptions"
  labelKey="label"
  valueKey="id"
  [(ngModel)]="selectedStatus"
  (currentValueChange)="syncStatus($event)"
  (userValueChange)="reloadDependentFields($event)">
</li-select>
```

The example E2E tests exercise those hooks through real Puppeteer clicks, keyboard input, and mouse dragging across select, multi-select, datatable-select, date/time pickers, typeahead, treeview, rating, tag/token controls, checkbox/radio/toggle, slider, color picker, and dropdown menu demos.

## Build for production

From `example/`:

```bash
dart run build_runner build --release --delete-conflicting-outputs --output web:build
```

This generates a static build in `example/build/`.

## GitHub Pages

The repository includes a Pages workflow at [`.github/workflows/pages.yml`](/c:/MyDartProjects/limitless_ui/.github/workflows/pages.yml). The workflow:

1. Installs dependencies for the root package and the example app
2. Builds the example with `build_runner`
3. Prepares a deployable `dist/` artifact
4. Publishes the result to GitHub Pages

Because the app uses hash-based routing, it works correctly when served from a repository subpath on GitHub Pages.

## Required host assets

The demo depends on the following external stylesheets declared in [`example/web/index.html`](/c:/MyDartProjects/limitless_ui/example/web/index.html):

```html
<link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/icons/phosphor/2.0.3/styles.min.css"
  rel="stylesheet" type="text/css">
<link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/fonts/inter/inter.min.css"
  rel="stylesheet" type="text/css">
<link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/css/all.min.css"
  rel="stylesheet" type="text/css">
```

Without them, icons, typography, and part of the base visual styling will not render as expected.

For the PDF viewer and Quill demo pages, the host page also loads component-specific assets from the local `example/web/assets` tree:

```html
<!-- Quill editor -->
<link href="assets/js/quill/2.0.3/quill.snow.css" rel="stylesheet" type="text/css">
<script src="assets/js/quill/2.0.3/quill.js"></script>
<link rel="stylesheet" href="assets/js/quill_table_better/1.2.3/quill_table_better.css">
<script src="assets/js/quill_table_better/1.2.3/quill_table_better.js"></script>
<script src="assets/js/quill_table_better/1.2.3/register_table_better.js"></script>

<!-- PDF viewer -->
<script src="assets/js/pdf.js/5.4.149/build/pdf.export.js" type="module"></script>
```

These assets are required only for the routes that exercise `li-quill-text-editor` and `li-pdf-viewer`, but the example app loads them globally because those demos are part of the same host shell.

## Project structure

- [`example/lib/src/app`](/c:/MyDartProjects/limitless_ui/example/lib/src/app): shell application and navigation
- [`example/lib/src/pages`](/c:/MyDartProjects/limitless_ui/example/lib/src/pages): component showcase pages
- [`example/lib/src/routes`](/c:/MyDartProjects/limitless_ui/example/lib/src/routes): route definitions
- [`example/lib/src/shared`](/c:/MyDartProjects/limitless_ui/example/lib/src/shared): shared layout, DI, and helpers
- [`example/lib/src/theme`](/c:/MyDartProjects/limitless_ui/example/lib/src/theme): demo theme setup
- [`example/web`](/c:/MyDartProjects/limitless_ui/example/web): entrypoint and host page

## Localization

The example app ships with Portuguese and English localized content. If you update localized source files, make sure the generated message artifacts stay consistent with the current repository setup.

## Styling notes

- Component styles are authored in `.scss`
- AngularDart components reference generated `.css` files in `styleUrls`
- The build relies on `sass_builder` during development and production builds

## Testing and validation

Useful commands while working on the example:

```bash
dart analyze
dart run build_runner test -- -p chrome -j 1
```

Run them from the repository root unless you intentionally want to target only the example app.

To run the real Puppeteer E2E suite, keep the example server running on port `8081`:

```bash
cd example
dart run webdev serve web:8081 --release --auto refresh --hostname 0.0.0.0 -- --delete-conflicting-outputs
```

Then run from the repository root:

```bash
RUN_EXAMPLE_E2E=true UI_EXAMPLE_BASE_URL=http://127.0.0.1:8081 CHROME_EXECUTABLE=/path/to/chrome dart test ui_test/e2e/puppeteer_test.dart
```

On Windows PowerShell:

```powershell
$env:RUN_EXAMPLE_E2E = 'true'
$env:UI_EXAMPLE_BASE_URL = 'http://127.0.0.1:8081'
$env:CHROME_EXECUTABLE = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
dart test ui_test\e2e\puppeteer_test.dart
```

If `RUN_EXAMPLE_E2E` is not set to `true`, `ui_test/e2e/puppeteer_test.dart` is skipped by design.
The E2E server uses release mode so the bootstrap smoke test exercises the minified bundle and rejects browser exceptions, `console.error`, and a stuck `Carregando...` fallback.
