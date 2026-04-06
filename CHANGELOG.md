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
