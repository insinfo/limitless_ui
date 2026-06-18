## 1.0.0-dev.27

- Expanded SweetAlert prompt input customization with `SweetAlertInputConfig` for classes, styles, attributes, row/column sizing, length constraints, and autocomplete, forwarded the configuration through `SweetAlertService`, and added directive inputs for common field customization. Textarea prompts now render with a fuller `form-control` default, 100% width, a usable minimum height, and vertical resizing instead of the tiny native field.
- Added `LiSimpleDialogComponent.showPrompt(...)` with text/textarea input modes, optional validation, input customization through `LiSimpleDialogInputConfig`, and nullable string results for cancel flows. The example app now demonstrates the new SimpleDialog prompt APIs plus configured SweetAlert textareas and directive textarea customization.

## 1.0.0-dev.26

- Removed the default `li-datatable` fixed-column `box-shadow` layer, so sticky left/right cells no longer render the inset accent and edge shadow unless consumers add their own styling.
- Overrode the Limitless responsive datatable `first-child::before` marker inside `li-datatable`, preventing Firefox from showing an unintended glyph in the first data cell while preserving the explicit `dtr-control` expander.

## 1.0.0-dev.25

- Fixed the default `li-datatable` pagination summary in Portuguese by changing the hardcoded unaccented `paginas` text to a localized summary resolver. `li-datatable` now exposes `locale` and renders Portuguese/English summaries (`página(s)`/`page(s)`) through `paginationSummaryText`, with `li-datatable-select` forwarding the same locale to its inner modal datatable.
- Fixed dense right-fixed `DatatableActionColumn` cells so an optional `maxWidth` configuration no longer writes an inline `max-width` on action headers/cells. Action columns still preserve configured `width` and `minWidth`, but the action buttons can use the available sticky-cell space instead of being visually cramped against the right table edge.
- Expanded datatable localization/customization inputs with `emptyStateLabel`, `showAllColumnsLabel`, and `hideAllColumnsLabel`, including locale-aware defaults for the grid empty state and forwarding of `emptyStateLabel` through `li-datatable-select`.
- Fixed responsive `li-datatable` child-row details so long values wrap within the available table width instead of expanding or overflowing the details layout.
- Replaced remaining hardcoded component UI/accessibility labels with configurable inputs across alerts, toast, notification outlet, offcanvas, dropdown menu, pagination, treeview, page header, file upload, and PDF viewer. New inputs include close-button ARIA labels, pagination navigation ARIA labels, treeview select/expand titles, breadcrumb ARIA label, file-preview titles, and PDF viewer zoom labels while preserving the previous defaults.
- Localized the narrated fullscreen PDF loading message from `Gerando paginas...` to `Gerando páginas...`, and added regression coverage for the new datatable locale/empty-state behavior plus focused browser coverage across the affected component templates.

## 1.0.0-dev.24

- Fixed `liDropdown` body-mounted dynamic overlays so the intelligent viewport adaptation (`adaptToViewport="true"`, the default) no longer enters an infinite style/class recalculation loop when the consumer controls the menu surface with CSS such as `width: max-content`, `max-width: min(...)`, or `calc(100vw - ...)`. The adaptation now applies only `max-width`/`max-height`/`overflow-x`/`overflow-y` and preserves the author-provided `width`/`height` inline values, so the loop cannot start regardless of the `adaptToViewport` setting.
- Added a new "Best practices for body-mounted dynamic dropdowns" section to the README covering the contract for `container="body"` + `display="dynamic"` overlays: one owner of width/overflow (CSS or `menuMaxWidth`/`menuMaxHeight`, never both), Popper as the single source of truth for `transform`/`top`/`left`/`right`/`bottom`/`inset`, the prohibition on consuming `--popper-available-*` from app CSS/JS, correct scoping of `transform: none !important` to inline submenus only, stylization through global classes or `dropdownClass`, and a reference template plus anti-pattern list for organization/account switchers.

## 1.0.0-dev.23

- Fixed `liDropdown` body-attached overlays on narrow/mobile viewports so long organization menus no longer enter a relayout loop that keeps recalculating the wrapper style; the menu now stays stable while preserving the full label text through horizontal overflow/clamping behavior, and browser regression coverage now protects that scenario.
- Lesson learned: for Popper-managed `liDropdown` overlays rendered in `document.body`, the Popper controller must remain the only source of truth for wrapper `transform`; avoid a second manual viewport clamp and avoid writing volatile `--popper-available-*` CSS variables from the dropdown writer, because those values can feed back into measurement and cause repeated redraw/reposition cycles.
- Documented that `adaptToViewport` should not be used for body-mounted dynamic organization/account switchers whose menu width is controlled by `width: max-content`, `max-width`, or other app CSS. In that scenario the intelligent viewport adaptation can enter an infinite style/class recalculation loop, so consumers should opt out with `adaptToViewport="false"` and let CSS own the menu width/overflow.

## 1.0.0-dev.22

- Added a generic `li-pdf-viewer` component backed by PDF.js for reusable document preview flows, with bytes/URL loading, zoom/page navigation, fit-width, rotation, pan mode, fullscreen, download, print, configurable labels/zoom menus, localized label presets, Dart/template toolbar and side-panel extensibility, document/page text and page-info extraction APIs, stronger browser-test coverage through dedicated PDF.js/browser bridges, a separate `package:limitless_ui/pdf_viewer.dart` barrel export, and a dedicated example page.
- Added an isolated `li-quill-text-editor` component backed by Quill `2.0.3`, with configurable toolbar items/actions/templates, optional table support, `ngModel` integration, HTML/plain-text/delta APIs, localized label presets, optional deferred model propagation via `updateModelOnBlur`, a separate `package:limitless_ui/quill_text_editor.dart` barrel export, and dedicated example/browser coverage.
- Documented the Quill Table Better contextual table menu layout requirement: table-heavy hosts should render `li-quill-text-editor` in a wide, unclipped editor area because the plugin positions `.ql-table-menus-container` from Quill container geometry and narrow side-by-side shells can force the menu to clamp to the container's left edge.
- Added a dedicated `li-password-input` component with `ngModel`/validation support, Dart-controlled masking over a `type="text"` input, integrated reveal toggle, and an updated inputs demo/API section for Chrome autofill-resistant password flows.
- Expanded declarative `liDropdown` overlays for dense navbar/account flows with post-show body-overlay relayout, default viewport adaptation in dynamic positioning, new `menuMaxWidth`/`menuMaxHeight` caps, and stronger browser regression coverage for `bottom-start`, `bottom-end`, tall menus, and long body-attached content near viewport edges.
- Added richer dropdown example coverage with a dedicated operational workspace-shell demo route plus updated navbar edge-overlay demos documenting preferred `bottom-start` alignment, account-menu submenus, and body-attached organization switcher patterns.
- Expanded the SweetAlert static/service APIs with callback hooks for popup lifecycle (`onOpen`, `onClose`), button actions without `await` (`onConfirmAction`, `onCancelAction`), and dismiss flows (`onDismissAction` for escape, backdrop, and close button), plus updated SweetAlert example snippets and demos.
- Added an imperative `LiTooltip.show(...)` static API with `LiTooltipController`, `dismissAll()`, lifecycle callbacks (`onOpen`, `onClose`), and matching tooltip example-page coverage for static/manual usage.
- Added `LiNarratedFullScreenLoading` for long-running fullscreen helper flows with rotating status messages, a themed animated progress shell, and a `pdfGeneration()` factory; the helpers example now demonstrates it both standalone and from inside `li-modal`, and browser coverage now verifies it stacks above modal layers.
- Breaking change: renamed `SimpleLoading` to `LiSimpleLoading`, added explicit helper `zIndex` control for `LiSimpleLoading` and `LiSimpleDialogComponent`, and aligned both helper overlays to stack safely above `li-modal`, with new browser coverage for helper usage triggered from modal content.

## 1.0.0-dev.21

- Fixed `li-modal` backdrop dismissal so interacting with the modal root scrollbar on short viewports no longer closes the dialog as an outside/backdrop click.
- Added a modal example documenting the short-viewport scrollbar behavior while keeping real backdrop clicks enabled.

## 1.0.0-dev.20

- Added `liDropdownShowCaret` to `liDropdownToggle`/`liDropdownAnchor` so navbar and avatar triggers can opt out of the default `dropdown-toggle` caret (`::after`) without local CSS overrides, plus dropdown demo and README documentation for the no-caret navbar pattern.

## 1.0.0-dev.19

- Fixed `DatatableFormat.boolHighlightedBadge` in the `saliPaged` performance profile so positive boolean cells render the Bootstrap badge element instead of escaping the generated `<span>` as plain text.
- Improved `liDropdown` submenus for dense account/navigation menus with bindable submenu state (`open`/`openChange`), optional `closeOnItemClick`, and keyboard navigation that respects `placement="start"` left-opening submenus.

## 1.0.0-dev.18

- Expanded `DatatableAction` and `DatatableActionColumn` with overflow-menu APIs for dense action columns: `DatatableActionOverflowBehavior` (`auto`, `alwaysVisible`, `overflowMenu`), `maxVisibleActions`, customizable overflow trigger/menu styling (`overflowButtonClass`, `overflowButtonIconClass`, `overflowButtonLabel`, `overflowButtonIconOnly`, `overflowMenuClass`, `overflowButtonAriaLabel`, `overflowButtonTitle`), plus a body-anchored Popper overflow menu that escapes clipped datatable containers and regression coverage for mixed inline-plus-dropdown action sets and full-dropdown action columns.
- Expanded the `protocol-workflow` example to demonstrate the new `DatatableActionColumn` overflow API with always-visible primary actions, mixed inline actions, and secondary actions moved into the dropdown menu for dense desktop/mobile operational tables.
- Fixed sticky/frozen datatable columns to render with an opaque theme surface instead of inheriting the Limitless table transparency token, so right/left fixed cells no longer look leaked in light and dark themes while still preserving row hover/striped/active overlays.

## 1.0.0-dev.17

- Refactored `li-datatable` internals into focused controllers for sorting, pagination, search, export, selection, responsive state, virtual scroll, title help, and debug instrumentation while preserving the public component API.
- Added `DatatablePerformanceProfile` with the `saliPaged` profile for small server-paged operational tables, plus `enableGridMode`, `enableResponsiveFeatures`, stable `rowKeyResolver` selection keys, and `fixedTableLayout` as an opt-in instead of forcing `table-layout: fixed`.
- Improved dense-table rendering by building virtual ranges without `sublist()`, avoiding rich header/cell bindings on simple paths, and caching responsive viewport/container state so template getters no longer read DOM dimensions on every change-detection pass.
- Added browser benchmarks for virtual scroll and per-feature datatable cost. The feature benchmark documents that `responsiveAutoHideColumns` by priority and `responsiveCollapseByContainer` are the expensive paths because they must measure real DOM widths, while action columns, title customization, `table-layout`, and virtual scroll are not the primary regression source in the measured scenarios.
- Added stable `data-li-datatable-action-cell` and `data-li-datatable-action` markers for `DatatableActionColumn`, expanded debug instrumentation with explicit action-cell/action-element/configured-action-column metrics, and added regression coverage for `saliPaged` action rendering plus desktop container collapse without responsive priority auto-hide.
- Expanded `DatatableActionColumn` with `maxVisibleActions`, per-action `DatatableActionOverflowBehavior`, automatic overflow dropdown rendering, and optional `wrapActions` for multiline action groups so library consumers can keep specific actions always visible while moving the rest into a menu.
- Refreshed the datatable demo page with an in-page performance summary, benchmark highlights, and guidance for lean SALI-style tables. The fixed-column horizontal-scroll example now gives the action column enough width and spacing for icon buttons.
- Removed datatable component background overrides from fixed/frozen columns so sticky edge columns inherit the active Limitless table/theme CSS instead of forcing local card/body colors.
- Expanded the process lookup example to use the `saliPaged` profile, stable `rowKeyResolver`, disabled grid/responsive work for the dense table path, and debug instrumentation for profiling the operational screen.
- Added a protocol workflow demo route with nested datatables in modals/tabs for dispatches and attachments, and added `liCollapseToggle` for selector-based collapse triggers with browser coverage.
- Forwarded `enableGridMode` and `enableResponsiveFeatures` through `li-datatable-select` so modal picker tables can opt out of grid and responsive measurement work.

## 1.0.0-dev.16

- Expanded overlay stack behavior across `li-tooltip` and `li-popover` so body-mounted overlays render above modal layers, including regression coverage for trigger usage inside `li-modal`.
- Expanded adaptive/mobile overlay presentation for `li-date-picker`, `li-date-range-picker`, `li-time-picker`, and `li-color-picker` with centered modal/sheet flows, viewport-aware clamping, and dedicated browser regression tests.
- Expanded picker APIs with `mobilePresentation`/`mobileHeightBreakpoint` support in real modal demo scenarios (including stacked modal flows) and updated modal examples to validate select/multi-select/tag-filter/tooltip/popover/picker interaction in the same z-index stack.
- Refined picker styling for dark themes and trigger/action consistency, including cleanup of modal demo wrapper classes in overlay demo surfaces and alignment of footer/action spacing behavior in mobile modal picker panels.
- Added `overlay_positioning.dart` shared utilities to normalize container resolution, viewport bounds handling, and adaptive placement decisions used by popup-style components.

## 1.0.0-dev.15

- Expanded `li-datatable` responsive rendering with explicit `responsiveControlColumnKey`, allowing the responsive collapse trigger/control cell to stay attached to a predictable visible column instead of depending only on `responsiveAutoHideRequired` ordering.
- Expanded datatable header composition with `titleTextAlign`, `customRenderTitleString`, `customRenderTitleHtml`, `titleTooltip`, `titlePopover`, and projected `<template li-datatable-header-cell="columnKey">` templates, including inline title-level tooltip support and optional native browser `title` tooltips through `useNativeTitle`.
- Expanded grid mode with projected `<template li-datatable-card>` support alongside `customCardBuilder`, refreshed the datatable example page with live demos and mini tutorials for custom column titles and template-driven cards, and kept the default grid/card action guidance aligned with left-start operational footers instead of forced centered action groups.
- Expanded `DatatableAction` with desktop/mobile responsive layouts (`desktopTextMobileIcon` and `desktopTextAndIconMobileIcon`), semantic `size` support for `btn-sm` and `btn-lg`, and default `me-2` icon spacing for text buttons; also made `DatatableActionColumn` center its header by default while staying out of built-in PDF/XLSX exports unless `exportable: true` is enabled explicitly.
- Expanded `li-datatable` virtualization with documented `virtualScroll` guidance for dense operational lists, opt-in `stickyTableHeaderOnVirtualScroll` support for virtualized table mode, and an isolated process-lookup demo route that exercises dense table/grid switching with sequential process numbers and safer page-size experiments.
- Fixed the virtual-scroll edge case where dragging the scrollbar to the bottom could oscillate the rendered window and trigger endless redraws when the viewport was pinned to the end of the dataset; browser regression coverage now protects that bottom-of-list flow.
- Fixed datatable dark-theme regressions around sticky headers, fixed columns, hover surfaces, empty states, and default grid cards by aligning the component styles with the real Limitless theme tokens instead of Bootstrap `--bs-*` fallbacks; also normalized the default grid card radius to `--border-radius`.
- Documented the current non-virtual performance limitation more explicitly: dense pages above roughly 100 rows can still stall the browser, so larger limits should use `virtualScroll` or remain capped/server-driven.

## 1.0.0-dev.14

- Expanded `li-offcanvas` with `enableDefaultBodyClass` and `enableBodyWrapper`, allowing fully custom flex layouts in the panel body without forcing the default `.offcanvas-body` wrapper/class; also updated the internal panel shell to a column flex layout and added the `li-offcanvas-contents` passthrough class for projected content flows.
- Expanded the offcanvas example page with a denser operational “complex scenario” panel (fixed filter header, searchable/filtered timeline list, responsive sizing), plus themed scrollbar coverage for generic `.overflow-auto` containers to keep custom offcanvas bodies visually consistent.
- Fixed `li-dropdown-menu` rounded-corner clipping when vertical scrolling is activated: overflow control was moved from the outer menu container to the inner items container for desktop/inline modes, while mobile modal/sheet sizing behavior remains isolated to the outer menu wrapper.
- Expanded `li-datatable` action rendering with `DatatableActionAppearance.linkIcon` and `iconOnly`, enabling icon-only link-style actions (no button background) while preserving accessible labels; also updated the datatable example favorite action to support this visual mode where state is expressed by icon color only.
- Fixed `li-datatable` responsive auto-hide recovery after viewport/container re-expansion by recalculating with stable column widths instead of stretched runtime measurements, and added browser regression coverage for the shrink-then-expand flow.

## 1.0.0-dev.13

- Added `menuMaxHeight` to `li-dropdown-menu`, allowing long option lists to scroll vertically without forcing consumers to create custom menu classes.
- Added mobile presentations to `li-dropdown-menu` through `mobilePresentation="modal"` and `mobilePresentation="sheet"`, with configurable breakpoint, optional mobile menu title, internal option-list scrolling, and example coverage for both modes.
- Added default viewport adaptation for `li-dropdown-menu` through `adaptToViewport`, so menus near viewport edges flip upward where applicable and cap their height instead of being clipped.

## 1.0.0-dev.12

- Expanded `li-highlight` with lightweight SQL highlighting support in the core parser, including common SQL aliases, and updated the example highlight page with a dedicated SQL demo snippet for visual verification in the browser.

## 1.0.0-dev.11

- Expanded `li-datatable` with optional responsive auto-hide columns driven by per-column priority and required-visibility flags, so narrow layouts can collapse low-priority columns into the child/details row before horizontal scrolling appears; the example app now exercises that behavior both in the process-lookup datatable demo and in a dedicated responsive inbox/work-queue screen.
- Expanded `li-datatable` with public header/footer template contexts (`LiDatatableHeaderContext` and `LiDatatableFooterContext`), reusable `li-datatable-header`/`li-datatable-footer` directives, and `requestDataOnItemsPerPageChange` for flows where page-size changes should reload data through `(dataRequest)` instead of only `(limitChange)`.
- Expanded `li-datatable` with sticky/frozen columns through `DatatableCol.fixedPosition`, so operational tables can keep columns such as actions fixed on the left or right while the remaining columns scroll horizontally.
- Expanded `li-datatable-select` to forward `li-datatable-header`/`li-datatable-footer` templates into the inner table, added `requestDataOnItemsPerPageChange`, and exposed `modalCompactHeader`/`modalSmallHeader` pass-throughs for denser modal chrome.
- Expanded the dropdown API with reusable `liDropdownSubmenu`, `liDropdownSubmenuToggle`, and `liDropdownSubmenuMenu` directives, added a user-menu demo with nested theme actions, and kept parent dropdown auto-close behavior compatible with submenu toggles.
- Expanded the datatable example with a process-consultation layout that demonstrates custom `TemplateRef` headers, external helper filters, and action-bar controls around `li-datatable`, while relaxing the built-in search toolbar width to `min(100%, 32rem)`.
- Refined `li-file-upload` preview modals so long file names truncate inside the zoom header instead of breaking the action buttons, and kept browser coverage aligned for the richer datatable header/footer customization flows.


## 1.0.0-dev.10

- Expanded `li-datatable` and `li-datatable-select` with optional custom header `TemplateRef` support for the datatable toolbar, exposed `modalCompactHeader`/`modalSmallHeader` pass-throughs on `li-datatable-select`, and removed the hard 24rem search-toolbar cap so search inputs can grow like the reference process toolbar.
- Expanded `li-datatable` with optional custom footer `TemplateRef` support, including a stable footer context for totals and pagination actions, and forwarded the same footer template capability through `li-datatable-select`.
- Expanded `li-modal` with intermediate sizes (`xx-large`, `xxx-large`, and `fluid`), optional `fullScreenShell` for true fullscreen shell styling, optional `closeOnEscape`, projected header/footer slots, custom dimensions/ARIA hooks, stronger stacked-modal handling, and broader browser/demo coverage for the richer dialog flows.
- Breaking change: renamed the `li-modal` fullscreen-shell input from `fullScreenChrome` to `fullScreenShell`; update any template bindings, docs snippets, or wrapper APIs that still reference the old name.
- Added `start`/`end` aliases to `li-date-range-picker` while preserving `inicio`/`fim`, including mirrored `startChange`/`endChange` outputs, updated example usage, and regression coverage for the alias flow.
- Changed `li-dropdown-menu` to close other open instances by default when a new one opens, added the `closeOtherMenusOnOpen` opt-out for submenu-like or coordinated multi-menu layouts, and documented that pattern in both the README and the dropdown example page.
- Expanded the modal and dropdown example pages with more complete API/demo coverage, 
dark-theme-safe presentation based on Limitless theme tokens, and explicit visual documentation for special layout behaviors.
- Refined `li-color-picker` drag/clickout behavior so dragging no longer closes the picker, a single outside click closes it after drag completion, and document text selection is suppressed during interactive dragging.
- Added native `li-slider` with Limitless `noUi-*`/`noui-*` styling compatibility, single-value and range modes, vertical orientation, themed variants, size/handle-style options, tooltip support, configurable `connect` behavior (`auto`, `lower`, `upper`, `range`, `none`), and explicit custom pips via value/label descriptors.
- Added a dedicated slider demo page aligned with the example shell's standard Overview/API tab structure, including examples for `connect`, custom pips, range behavior, themed variants, corrected vertical rendering, and a drag-state tooltip fix so active handles keep their tooltip visible while the user drags.
- Added native `li-timeline` with Limitless-compatible `left`, `right`, and `center` layouts, declarative item fallbacks plus projected icon/time/content slots, example-shell navigation/demo coverage, and browser tests for alignment/class rendering.
- Refined the timeline bridge styles so projected icons stay centered, dark themes keep the expected marker appearance, and date/time blocks follow the Limitless timeline structure without relying on JavaScript widgets.
- Breaking change: normalized several public helper and notification-toast APIs to the `Li` prefix. Rename `SimpleDialogComponent` to `LiSimpleDialogComponent`, `DialogColor` to `LiDialogColor`, `SimplePopover` to `LiSimplePopover`, `SimpleToast` to `LiSimpleToast`, `NotificationToastService` to `LiNotificationToastService`, `NotificationToastColor` to `LiNotificationToastColor`, `ToastSoundController` to `LiToastSoundController`, and `Toast` to `LiNotificationToast`.
- Reworked the notification demo page to document and exercise `li-notification-outlet` with `LiNotificationToastService`, including dedicated browser coverage split between service-level tests and real `ngtest` outlet integration tests.


## 1.0.0-dev.9

- Fixed `li-datatable` sorting compatibility with `essential_core` `1.2.0` by updating single-column sorting to write `orderBy`/`orderDir` directly, clearing legacy `orderFields` when multi-column sorting is disabled, and adding regression coverage for the split sorting API, including repeated-click `asc`/`desc` toggling in multi-column mode.

## 1.0.0-dev.8

- Fixed `li-datatable` search-field propagation when host components replace `dataTableFilter`, preserving the selected `searchInFields` entry across modal/filter reinitialization flows and adding regression coverage for the selected-field state.

## 1.0.0-dev.7

- Added generic tag tooling with `li-tag-filter`, `li-tag-editor`, and `li-tag-manager`, including configurable `labelKey`/`valueKey`/`colorKey` mapping, reusable selection/create/edit/delete events, `compareWith` support for selection stability, and browser coverage for the new tag workflows.
- Added `li-token-field`, a generic tokenized text input with `ngModel`, regex-based token extraction, optional keystroke filtering, clipboard actions, granular action visibility toggles, explicit copy/paste/clear outputs, and browser coverage for core parsing flows.
- Added the `work-queue` demo route to showcase `li-tag-filter`, `li-tag-manager`, and `li-token-field` together inside a more realistic operational workflow.
- Expanded dropdown menu overlays so both `li-dropdown-menu` and the lower-level `dropdownmenu` directive can render inline or in a `body`-anchored Popper overlay, with better outside-click/Escape handling and browser coverage for the new placement flow.
- Expanded `li-modal` with `compactHeader` and `smallHeader`, improved fullscreen body scrolling, and richer example coverage for iconified, mini, backdropless, form, and fullscreen dialog variants.
- Expanded the demo shell with extra color themes (`blu`, `pink`, `orange`, `retro`) and broader themed scrollbar coverage across sidebar, content, dropdown, modal, and form surfaces.
- Aligned the standalone `li-currency-input` demos and docs with the same declarative validation contract used by `liForm`, including `liRules`, `liValidationMode`, and native helper/error feedback.
- Tightened the extra `person-registration` fields so `primaryReviewerId` and `workflowNodeIds` now participate in submit validation with business-aware rules, plus browser coverage for the additional required states.

## 1.0.0-dev.6

- Changed the default `liValidationMode` across declarative form components to `submittedOrTouchedOrDirty`, so fields surface errors after submit, after blur, or while typing once they become dirty.
- Added declarative form validation across `li-input`, `li-select`, `li-multi-select`, `li-checkbox`, `li-radio-group`, `li-date-picker`, `li-time-picker`, and `li-file-upload`, with `liRules`, `liMessages`, `liValidationMode`, preset support through `liType` on `li-input`, and `liForm`-aware submit-time validation flows.
- Reduced verbose manual validation in the registration demo, documented the new validation model in `README.md`, `doc-pt_BR.md`, and the affected example component pages, and added browser coverage for the new submitted-mode declarative validation flow.
- Expanded `li-treeview-select` with in-panel actions for expand-all, clear selection, and confirm/close flows, plus regression coverage for the new overlay action bar behavior.
- Refined `li-treeview-select` actions with configurable footer visibility, a toggleable expand/collapse-all control that can also render beside the search field, and compact `btn-sm` action styling.
- Expanded `li-input` with high-level `validator` and `maskFormatter` callbacks so custom validation/masking can be configured directly on the component without replacing the existing declarative `mask` API.
- Added `multiple` selection mode to `li-datatable-select`, reusing datatable checkbox selection with modal confirm/clear actions and regression coverage for the new selection workflow.
- Expanded composite form controls with configurable clear-button visibility and trigger icon presentation modes (`default`, `overlay`, `addon`, `hidden`) across date/time pickers, selects, datatable select, and treeview select, plus updated registration demo usage for the new overlay trigger style.
- Added `liForm`, an exportable form/container directive with agnostic APIs to mark AngularDart controls as touched, validate rendered UI, and focus the first invalid field without page-level DOM hacks.
- Expanded `liForm` with `liFormField`, explicit priority hooks, preferred focus-target markers, and DOM-order fallback when `liFormFieldOrder` is omitted, then applied that flow across the example app form demos.
- Added a dedicated `person-registration` example route that combines declarative validation, fake backend responses, `li-datatable-select`, `li-treeview-select`, `li-currency-input`, and `li-file-upload` in one realistic end-to-end form flow.
- Refined the `li-datatable-select` and `li-treeview-select` demos/docs with clearer `ngModel` summaries, typed-row modal coverage, trigger icon examples, search/footer action bars, and compact multi-selection UX updates.
- Expanded `li-file-upload` with `previewMode` (`compact`, `thumbnails`, `limitless`), Limitless-style preview cards, image/PDF preview modals with zoom/rotate/fullscreen/borderless controls, updated example flows, and stronger invalid/valid dropzone visual states, plus browser coverage for the richer preview workflow.
- Refined solid `li-toast` chrome so headers, badges, helper text, and close buttons stay legible on light-text toasts.
- Added `li-pg-header` with projected breadcrumb/action/bottom slots, exported it from the public barrel, added a dedicated example route, and covered the new API with browser tests.
- Expanded form-oriented APIs with `li-input` event outputs (`inputBlur`, `inputFocus`, `inputClick`, `inputKeydown`, `inputEnter`) plus `compareWith` and `modelChange` support in `li-select` and `li-multi-select`, with regression coverage for the new behavior.
- Expanded `li-datatable-select` with `itemLabelBuilder`, `itemValueBuilder`, `compareWith`, and modal context helpers for arbitrary projected content such as embedded search components, and added browser tests for typed rows and custom modal selection flows.
- Standardized and enriched the example app documentation pages, including broader `li-highlight` adoption, Overview/API tab structure updates, new migration snippets, and README/example README updates covering the new component and form APIs.

## 1.0.0-dev.5

- Expanded `li-datatable` with grouped and multi-column sorting demos, customizable grid container class/style hooks, responsive pagination sizing, safer grouped-row selection behavior, and new regression coverage for grouping and grid rendering.
- Expanded the datatable example and documentation with richer AngularDart integration snippets, backend/frontend usage guidance, and updated localized README/docs instructions for `build_runner serve` and optional `webdev` usage.
- Expanded `li-accordion` with `bodyPadding`, `buttonClass`, and `buttonSemibold` so host apps can match dense Limitless-style accordion body density and header typography without forking the component.
- Added a "Visualiza Processo" accordion demo to the example app, including underline tabs, flush accordion sections, neutral active tab text, and muted non-bold accordion headers.
- Fixed `li-tabsx` nested tab/header projection so inner tabs no longer leak into outer tab headers, ensured active panes also receive the `show` class, and added configurable tab content padding and active-text body coloring.
- Added browser regression tests covering accordion body padding/button styling, datatable grouped selection/grid container behavior, and tab content padding.

## 1.0.0-dev.4

- Updated the `essential_core` dependency constraint to `^1.1.0`.

## 1.0.0-dev.3

- Fixed Popper-based overlay positioning so `li-select`, `li-multi-select`, `li-date-picker`, `li-date-range-picker`, `li-time-picker`, `li-color-picker`, and `li-treeview-select` open directly below their triggers instead of overlapping them vertically.
- Added the shared `overlay_positioning.dart` helper to normalize overlay vertical placement across components that render floating panels with Popper.
- Restored `li-select` and `li-multi-select` dropdown panels to rely on the global Limitless `dropdown-menu` styling, preserving dark theme compatibility and avoiding regressions caused by local hardcoded panel styles.
- Updated the `liSweetAlert` directive to default modal-like flows to centered positioning while keeping toast notifications aligned to `top-end`.
- Fixed custom `li-fab` trigger templates so projected icons no longer inherit the global absolute icon positioning from `.fab-menu-btn i`, preventing icons from overlapping text labels.
- Updated the SweetAlert demo documentation snippet to reflect the corrected directive defaults.
- Added browser regression tests covering overlay alignment for `select`, `multi-select`, `date picker`, `date range picker`, `time picker`, and `color picker`.
- Added regression tests to protect dark theme styling delegation for `select` and `multi-select`.
- Added regression tests for SweetAlert directive positioning defaults and FAB custom trigger template rendering.

## 1.0.0-dev.2

- Added `li-checkbox`, `li-radio`, `li-toggle`, `li-rating` and `li-file-upload`.
- Added `li-breadcrumb`, `li-pagination`, `li-offcanvas`, `li-fab` and `li-color-picker`.
- Added low-level upload helpers with `LiFileSelectDirective`, `LiFileDropDirective` and `LiFileType`.
- Added richer color picker APIs with palette support, selection history and `LiColorPickerEvent` streams.
- Added `li-typeahead` with local filtering, keyboard navigation, `ngModel` support and a dedicated demo page.
- Expanded `li-typeahead` with async search callbacks, rich result markup, reusable text highlighting and `LiTypeaheadConfig` defaults.
- Added `li-treeview-select` for dropdown selection over hierarchical data.
- Expanded `li-treeview-select` with lazy page loading, remote search term forwarding through `TreeViewLoadRequest.searchTerm`, multiple selection and projected templates for trigger and node rendering.
- Added `labelBuilder` and `canSelectNode` hooks so host applications can customize labels and selection rules without forking the component.
- Renamed legacy package paths from `br_currency_input` to `currency_input` and aligned select/multi-select internals with the current public API layout.
- Added the new toast module with `LiToastComponent`, `LiToastStackComponent` and `LiToastService`.
- Added a dedicated toast demo page to the example application and routed it from the demo navigation.
- Refined the toast demo presentation, including a more compact rounded toast variant.
- Added `li-wizard` and `li-wizard-step` for guided multi-step flows styled against the native Limitless 4 `.wizard` markup.
- Expanded `li-wizard` with `[headerTemplate]`, `[actionsTemplate]`, `LiWizardStepHeaderContext` and `LiWizardActionsContext` so host apps can customize step labels and footer actions while preserving the native state icons.
- Expanded the example app with dedicated pages for selection controls, rating, file upload, breadcrumbs, pagination, offcanvas, floating action button, highlight and color picker.
- Refined the example shell with sidebar filtering, navbar route search powered by `li-typeahead`, standardized page breadcrumbs based on `li-breadcrumb`, richer tabs examples, a dedicated wizard/form wizard page and a dedicated scrollbar stylesheet.
- Extended `li-tabsx` and its demo coverage with Limitless 4 `underline`, `overline` and `solid` variants plus richer examples for projected headers, `lazyLoad` and `destroyOnHide`.
- Updated the demo i18n service to detect the browser locale automatically, defaulting to Portuguese only when the browser language starts with `pt` and falling back to English otherwise.
- Added an AngularDart documentation link to the example overview and bundled `site_ngdart` for local and GitHub Pages publication.
- Expanded the package documentation with toast usage, stack placement, AngularDart stylesheet guidance, dependency/contract notes and richer component coverage.
- Added browser test coverage for toast behavior and included it in CI.
- Expanded browser and integration coverage for breadcrumbs, offcanvas, pagination, typeahead, treeview select, selection controls, rating, file upload flows, directives, form integrations and wizard navigation.
- Stabilized focus-sensitive browser scenarios across input, offcanvas and multi-select interactions.
- Added GitHub Actions Pages deployment plus `scripts/prepare-pages.ps1` to publish a combined artifact with the example app and `site_ngdart`.
- Improved GitHub Pages path rewriting and pretty URL generation for repository-prefixed `site_ngdart` hosting.

## 1.0.0-dev.1

- Prepared the package for the first public pre-release on pub.dev.
- Added publication metadata (`homepage`, `repository`, `issue_tracker`).
- Relaxed AngularDart dependency constraints to caret ranges.
- Stabilized test execution by separating VM-safe tests from browser tests.
- Added coverage for `BrazilianCurrencyInputFormatter`.
- Added GitHub Actions CI with Dart `3.6.2`, Chrome browser tests, analyzer, and `pub publish --dry-run`.

## 1.0.0

- Initial release of reusable AngularDart UI components and directives.
