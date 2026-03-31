## 1.0.0-dev.2

- Added the new toast module with `LiToastComponent`, `LiToastStackComponent` and `LiToastService`.
- Added a dedicated toast demo page to the example application and routed it from the demo navigation.
- Expanded the package documentation with toast usage, stack placement, AngularDart stylesheet guidance and richer component coverage.
- Added browser test coverage for toast behavior and included it in CI.
- Refined the toast demo presentation, including a more compact rounded toast variant.
- Added `li-typeahead` with local filtering, keyboard navigation, `ngModel` support and a dedicated demo page.
- Expanded `li-typeahead` with async search callbacks, rich result markup, reusable text highlighting and `LiTypeaheadConfig` defaults.
- Added `li-treeview-select` for dropdown selection over hierarchical data.
- Expanded `li-treeview-select` with lazy page loading, remote search term forwarding through `TreeViewLoadRequest.searchTerm`, multiple selection and projected templates for trigger and node rendering.
- Added `labelBuilder` and `canSelectNode` hooks so host applications can customize labels and selection rules without forking the component.

## 1.0.0-dev.1

- Prepared the package for the first public pre-release on pub.dev.
- Added publication metadata (`homepage`, `repository`, `issue_tracker`).
- Relaxed AngularDart dependency constraints to caret ranges.
- Stabilized test execution by separating VM-safe tests from browser tests.
- Added coverage for `BrazilianCurrencyInputFormatter`.
- Added GitHub Actions CI with Dart `3.6.2`, Chrome browser tests, analyzer, and `pub publish --dry-run`.

## 1.0.0

- Initial release of reusable AngularDart UI components and directives.
