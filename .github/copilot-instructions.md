# Copilot Instructions

responda sempre em portugues 

## AngularDart performance rules

- Never return newly created lists, maps, style objects, or view-model objects from getters that are consumed directly by AngularDart templates.
- Treat `*ngFor` inputs as identity-sensitive. If a template uses `*ngFor`, provide a stable collection reference through a `final` field or cached lazy field.
- Avoid patterns equivalent to `[style]="valor"` or any other binding that recreates object-like values on each change-detection pass unless the value is memoized.
- When a template needs localized or mode-specific demo data, cache one stable collection per variant instead of rebuilding it every time a getter runs.

## AngularDart stylesheets

- In this repository, component styles are authored in `.scss` and compiled by `sass_builder`.
- In `@Component(styleUrls: ...)`, always reference the generated `.css` path, not `.scss`.
- Do not create or commit manual duplicate `.css` files next to component `.scss` sources just to satisfy `styleUrls`.
- If a component has `toast_component.scss`, the correct AngularDart annotation is `styleUrls: ['toast_component.css']`.

## Icon mapping source of truth

- In this repository, icon codepoints must follow `https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/icons/phosphor/2.0.3/styles.min.css`.
- Do not assume the `content` values embedded inside `https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/css/all.min.css` are correct for the font actually loaded by the demo.
- When a Limitless selector from `all.min.css` points to an older Phosphor codepoint map, add the narrowest possible override in the component or demo stylesheet so the rendered icon matches Phosphor `2.0.3`.
- Treat the Phosphor `2.0.3` stylesheet as authoritative for pseudo-element icons such as dropdown carets, wizard step states, validation glyphs, and similar `content:`-based UI markers.

## i18n YAML rules

- In `example/lib/messages.i18n.yaml` and `example/lib/messages_en.i18n.yaml`, always wrap text values in double quotes.
- Do this even for apparently simple strings, to avoid YAML parser breaks with `:`, `[]`, `{}`, `#`, HTML snippets, interpolation-like text, or other special characters.
- Prefer `key: "value"` consistently instead of mixing quoted and unquoted text entries.
- When adding multiline examples, keep using YAML block syntax only when really needed; otherwise prefer a single double-quoted string.

## AngularDart change-detection rules

- Do not assume `ChangeDetectorRef.markForCheck()` will fix async rendering issues on pages using the default `ChangeDetectionStrategy.checkAlways`.
- In this repository, treat `markForCheck()` as an `onPush` tool first. If the host page is not `onPush`, `markForCheck()` is not a reliable fix for lazy async UI problems by itself.
- For async content inside lazy accordion bodies, tabs, modals, or other deferred DOM, prefer one of these approaches:
  - move the host component to `ChangeDetectionStrategy.onPush` and use `markForCheck()` deliberately;
  - or force an immediate refresh only in the narrowest possible place when the async update completes;
  - or restructure the flow so the data is ready before the deferred child is created.
- Never claim a bug is fixed just because `markForCheck()` was added to a default-strategy page. Confirm the rendered DOM actually updates without extra user interaction.

## AngularDart emulated encapsulation and host selectors

- In emulated view encapsulation (the default), AngularDart rewrites each simple selector to include a `[_ngcontent-xxx]` attribute. A class applied to the **host element** via `@HostBinding('class.foo')` lives on the `_nghost-xxx` attribute, **not** `_ngcontent-xxx`.
- Therefore, a component SCSS selector like `.foo > .child` will be compiled to `.foo[_ngcontent-xxx] > .child[_ngcontent-xxx]` and **will never match** the host element.
- When you need to select from the host element downward, use `:host > .child` instead of `.foo > .child`. AngularDart compiles `:host` to `[_nghost-xxx]`, which correctly targets the host.
- Real example: the wizard component had `@HostBinding('class.wizard')` on its host, but `.wizard > .steps > ul > li .number::after` in the SCSS never matched. Replacing `.wizard >` with `:host >` fixed the icon rendering.

## Popover-specific lesson learned

- The popover example page froze the browser because `palettePopovers` was implemented as a getter that recreated 11 objects on every change-detection cycle while being consumed by `*ngFor`.
- For demo pages with many rich components, always prefer stable references and incremental updates over recomputing the whole collection in a getter.
