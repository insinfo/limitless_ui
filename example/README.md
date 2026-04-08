# `limitless_ui` Example

This folder contains the AngularDart showcase application for the `limitless_ui` package. It is the reference demo used to exercise the current components, pages, routing setup, theme integration, and browser build pipeline.

## What is included

- Component demo pages under `example/lib/src/pages`
- Hash-based routing for static hosting via `routerProvidersHash`
- Localized demo content in Portuguese and English
- SCSS-based component styling compiled by `sass_builder`
- A production build flow used by the GitHub Pages workflow

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
dart run build_runner serve web:8081 --delete-conflicting-outputs
```

Then open:

```text
http://localhost:8081
```

Notes:

- This project uses `build_runner` directly for local serving.
- `--delete-conflicting-outputs` is recommended when generated outputs are stale.

You can also run the demo with `webdev` if it is available in your environment:

```bash
webdev serve web:8081 --auto refresh --hostname localhost -- --delete-conflicting-outputs
```

Additional notes for `webdev`:

- `webdev` is an alternative local workflow, not the primary documented one in this repository.
- The trailing `-- --delete-conflicting-outputs` forwards the flag to `build_runner`.
- `webdev` must be installed or otherwise available in your shell for this command to work.

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
