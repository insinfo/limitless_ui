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

## AngularDart browser test rules

- Para testes browser deste repositório, sempre execute `dart run build_runner test -- -p chrome -j 1` a partir da raiz do pacote, ou a variante focada com caminho de arquivo quando precisar limitar o escopo.
- Não trate o resumo do runner genérico como validação suficiente para testes AngularDart browser. O resultado correto deve vir do fluxo com `build_runner test` e Chrome.
- Ao relatar o resultado, informe o total real retornado por esse comando browser, mesmo quando houver testes ignorados/skipped no output.

## AngularDart emulated encapsulation and host selectors

- In emulated view encapsulation (the default), AngularDart rewrites each simple selector to include a `[_ngcontent-xxx]` attribute. A class applied to the **host element** via `@HostBinding('class.foo')` lives on the `_nghost-xxx` attribute, **not** `_ngcontent-xxx`.
- Therefore, a component SCSS selector like `.foo > .child` will be compiled to `.foo[_ngcontent-xxx] > .child[_ngcontent-xxx]` and **will never match** the host element.
- When you need to select from the host element downward, use `:host > .child` instead of `.foo > .child`. AngularDart compiles `:host` to `[_nghost-xxx]`, which correctly targets the host.
- Real example: the wizard component had `@HostBinding('class.wizard')` on its host, but `.wizard > .steps > ul > li .number::after` in the SCSS never matched. Replacing `.wizard >` with `:host >` fixed the icon rendering.

## Offcanvas DOM and internal scroll contract

- `LiOffcanvasComponent` appends its host element to `document.body` in `ngOnInit()`. Treat the rendered panel as body-level DOM, not as a visual child of the component that declared `<li-offcanvas>`.
- Because of that, parent component styles using emulated encapsulation are not a reliable way to style the internal `.offcanvas` panel. Prefer the component contract: `panelClass`, `bodyClass`, `headerClass`, `size`, `position`, `enableDefaultBodyClass`, and `enableBodyWrapper`.
- The effective DOM shape is: `.li-offcanvas-shell` -> optional `.li-offcanvas-backdrop` -> `.offcanvas ...` -> optional header -> body wrapper -> projected content.
- `enableDefaultBodyClass = true` adds Bootstrap-compatible `offcanvas-body` to the wrapper. `enableDefaultBodyClass = false` removes that class but keeps the wrapper. `enableBodyWrapper = false` turns the wrapper into `display: contents` through `.li-offcanvas-contents`.
- The library relies on Limitless/Bootstrap base CSS where `.offcanvas` is a fixed flex column panel and `.offcanvas-body` is `flex-grow: 1` with `overflow-y: auto`.
- When consumers want the projected child component to own the scroll area, the safest pattern is usually:
  - keep `enableBodyWrapper = true`;
  - set `enableDefaultBodyClass = false`;
  - pass a `bodyClass` such as `d-flex flex-column h-100 overflow-hidden`;
  - ensure the projected component host itself has explicit height or a valid flex contract.
- Never assume `overflow-y: auto` on the innermost child is enough. If the projected host has no usable height, the scroll node will expand to content height and no scrolling will happen.
- For library docs, examples, and fixes, describe offcanvas bugs by checking the real DOM height chain: panel -> body wrapper -> projected host -> projected shell -> scroll node.
- If a demo needs to show a complex scrollable offcanvas, prefer a projected component or projected markup that explicitly defines `height: 100%`, `min-height: 0`, a flex-column shell, and a dedicated `flex: 1 1 auto` scroll node.

## Popover-specific lesson learned

- The popover example page froze the browser because `palettePopovers` was implemented as a getter that recreated 11 objects on every change-detection cycle while being consumed by `*ngFor`.
- For demo pages with many rich components, always prefer stable references and incremental updates over recomputing the whole collection in a getter.

## Dropdown body-overlay lesson learned

- `liDropdown` menus with `container="body"`, `display="dynamic"`, `placement="bottom-end"`, and long content such as organization switchers are sensitive to layout feedback loops on mobile/narrow viewports.
- For Popper-managed body overlays, let Popper be the only source of truth for the wrapper `transform`. Do not add a second manual viewport clamp that rewrites the same transform after Popper positions the overlay.
- Do not write volatile `--popper-available-width` or `--popper-available-height` CSS variables from the custom dropdown layout writer unless there is a real consumer. Those values can alternate as the menu is measured and cause repeated style mutations/redraws.
- When fixing dropdown redraw issues, compare similar dropdowns in the real app: a normal account dropdown inside navbar flow may be fine while the organization switcher fails because it uses body mounting, dynamic Popper positioning, `menuMaxWidth`, and horizontally long content.
- Protect fixes with browser tests that observe the body wrapper `style` after opening; the wrapper should stabilize after settling, not keep mutating every frame.

## Limitless theme token rules for datatable and shared surfaces

- Neste repositório, não use variáveis Bootstrap `--bs-*` em SCSS de componentes customizados do pacote quando estiver estilizando superfícies, bordas, hover ou texto secundário. O tema real do example expõe tokens como `--body-bg`, `--card-bg`, `--body-color`, `--body-color-rgb` e `--border-color-translucent`.
- Antes de concluir qualquer ajuste visual em `li-datatable`, `grid.scss` ou superfícies similares, confirme que light e dark mode continuam corretos. Fallbacks para `#fff`, `#f8f9fa` ou `--bs-body-bg` em headers sticky, colunas fixas e painéis costumam quebrar imediatamente o dark theme.
- Para headers sticky e colunas fixas do datatable, prefira fundos derivados de `--card-bg`/`--body-bg`, separadores com `--border-color-translucent` e texto secundário com `rgba(var(--body-color-rgb), alpha)`.
- Quando precisar de hover em superfícies customizadas do datatable e não houver token direto, derive com `color-mix` a partir de `--card-bg`/`--body-bg` e `--body-color` em vez de usar cores claras hardcoded.
- Lição aprendida: o sticky header do datatable que usava `--bs-tertiary-bg`, `--bs-body-bg` e `--bs-table-hover-bg` ficou branco no dark theme. Trate esse caso como regressão conhecida a evitar.
