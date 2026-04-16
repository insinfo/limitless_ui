## 1.0.0-dev.7

- Added generic tag tooling with `li-tag-filter`, `li-tag-editor`, and `li-tag-manager`, including configurable `labelKey`/`valueKey`/`colorKey` mapping, reusable selection/create/edit/delete events, and browser coverage for the new tag workflows.
- Added `li-token-field`, a generic tokenized text input with `ngModel`, regex-based token extraction, optional keystroke filtering, clipboard actions, and browser coverage for core parsing flows.
- Added the `work-queue` demo route to showcase `li-tag-filter`, `li-tag-manager`, and `li-token-field` together inside a more realistic operational workflow.
- Expanded dropdown menu overlays so both `li-dropdown-menu` and the lower-level `dropdownmenu` directive can render inline or in a `body`-anchored Popper overlay, with better outside-click/Escape handling and browser coverage for the new placement flow.
- Expanded `li-modal` with `compactHeader` and `smallHeader`, improved fullscreen body scrolling, and richer example coverage for iconified, mini, backdropless, form, and fullscreen dialog variants.
- Expanded the demo shell with extra color themes (`blu`, `pink`, `orange`, `sali`) and broader themed scrollbar coverage across sidebar, content, dropdown, modal, and form surfaces.
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
- Expanded `li-accordion` with `bodyPadding`, `buttonClass`, and `buttonSemibold` so host apps can match Limitless/SALI accordion body density and header typography without forking the component.
- Added a SALI-inspired "Visualiza Processo" accordion demo to the example app, including underline tabs, flush accordion sections, neutral active tab text, and muted non-bold accordion headers.
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
