# Browser Automation with Puppeteer

Limitless UI components expose stable `data-label` hooks for browser automation. Use these hooks with `puppeteer: ^3.16.0` instead of CSS classes, translated text, generated ids, or DOM-depth selectors.

The hooks are intended for UI tests that exercise the real browser surface: click the same trigger the user clicks, wait for the same overlay the user sees, and assert component state through stable attributes such as `data-value`, `data-open`, `data-current-value`, and ARIA state.

## Install

Add Puppeteer to the application's test package:

```yaml
dev_dependencies:
  test: ^1.26.3
  puppeteer: ^3.16.0
```

Run:

```bash
dart pub get
```

## Serve the Application Under Test

For this repository's example app, run the server from the `example` package:

```bash
cd example
dart run webdev serve web:8081 --release --auto refresh --hostname 127.0.0.1 -- --delete-conflicting-outputs
```

Use release mode for this E2E gate. The repository harness treats an uncaught JavaScript exception, `console.error`, or the initial `Carregando...` fallback remaining in the DOM as a bootstrap failure.

Then run the Puppeteer tests from the repository root:

```bash
RUN_EXAMPLE_E2E=true UI_EXAMPLE_BASE_URL=http://127.0.0.1:8081 dart test ui_test/e2e/puppeteer_test.dart
```

PowerShell:

```powershell
$env:RUN_EXAMPLE_E2E = 'true'
$env:UI_EXAMPLE_BASE_URL = 'http://127.0.0.1:8081'
dart test ui_test\e2e\puppeteer_test.dart
```

Set `CHROME_EXECUTABLE` or `PUPPETEER_EXECUTABLE_PATH` when the default browser discovery is not enough:

```powershell
$env:CHROME_EXECUTABLE = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
```

## Recommended Test Harness

Use one browser page per test and close the browser in `tearDown`. Disable browser features that make tests noisy, such as password manager prompts, notification prompts, and translation popups.

For the Chrome password save bubble, do not rely only on command-line flags. That bubble is driven by Google Password Manager profile preferences, so create an isolated Chrome `userDataDir` and write the `Default/Preferences` JSON before launching the browser.

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

final baseUrl = Platform.environment['UI_EXAMPLE_BASE_URL'] ??
    'http://127.0.0.1:8081';

String pathJoin(String a, String b) => '$a${Platform.pathSeparator}$b';

Map<String, dynamic> ensureObject(Map<String, dynamic> root, String key) {
  final current = root[key];
  if (current is Map) {
    return current.cast<String, dynamic>();
  }

  final created = <String, dynamic>{};
  root[key] = created;
  return created;
}

Future<Directory> createChromeUserDataDirWithoutPasswordManager() async {
  final userDataDir =
      await Directory.systemTemp.createTemp('limitless-ui-chrome-profile-');
  final defaultProfileDir = Directory(pathJoin(userDataDir.path, 'Default'));
  await defaultProfileDir.create(recursive: true);

  final prefs = <String, dynamic>{};

  prefs['credentials_enable_service'] = false;
  prefs['credentials_enable_autosignin'] = false;

  final profile = ensureObject(prefs, 'profile');
  profile['password_manager_enabled'] = false;
  profile['password_manager_leak_detection'] = false;

  final autofill = ensureObject(prefs, 'autofill');
  autofill['profile_enabled'] = false;
  autofill['credit_card_enabled'] = false;

  final browser = ensureObject(prefs, 'browser');
  browser['check_default_browser'] = false;
  browser['has_seen_welcome_page'] = true;

  final distribution = ensureObject(prefs, 'distribution');
  distribution['skip_first_run_ui'] = true;
  distribution['suppress_first_run_bubble'] = true;
  distribution['suppress_first_run_default_browser_prompt'] = true;

  final preferencesFile = File(pathJoin(defaultProfileDir.path, 'Preferences'));
  await preferencesFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(prefs),
  );

  final localStateFile = File(pathJoin(userDataDir.path, 'Local State'));
  await localStateFile.writeAsString(
    jsonEncode({
      'profile': {'last_used': 'Default'},
    }),
  );

  return userDataDir;
}

Future<Page> openPage() async {
  final executablePath = Platform.environment['PUPPETEER_EXECUTABLE_PATH'] ??
      Platform.environment['CHROME_EXECUTABLE'];
  final chromeUserDataDir =
      await createChromeUserDataDirWithoutPasswordManager();

  final browser = await puppeteer.launch(
    headless: true,
    executablePath: executablePath != null && executablePath.isNotEmpty
        ? executablePath
        : null,
    userDataDir: chromeUserDataDir.path,
    noSandboxFlag: true,
    defaultViewport: DeviceViewport(width: 1920, height: 1003),
    args: const [
      '--window-size=1920,1080',
      '--profile-directory=Default',
      '--no-sandbox',
      '--disable-dev-shm-usage',
      '--no-first-run',
      '--no-default-browser-check',
      '--disable-infobars',
      '--disable-search-engine-choice-screen',
      '--disable-notifications',
      '--disable-popup-blocking',
      '--password-store=basic',
      '--use-mock-keychain',
      '--disable-features=Translate,AutofillServerCommunication,PasswordManagerOnboarding',
    ],
  );

  final page = await browser.newPage();
  await page.setViewport(DeviceViewport(width: 1920, height: 1003));
  return page;
}

Future<void> gotoRoute(Page page, String route) async {
  await page.goto('$baseUrl/#/$route', wait: Until.domContentLoaded);
  await waitForSelector(page, '.demo-page, .content');
}
```

`userDataDir` matters because Chrome stores user preferences in the profile directory, usually under `Default/Preferences`. Write those preferences before Chrome starts; changing the file while Chrome is running can be overwritten. The important preference block is:

```json
{
  "credentials_enable_service": false,
  "credentials_enable_autosignin": false,
  "profile": {
    "password_manager_enabled": false,
    "password_manager_leak_detection": false
  },
  "autofill": {
    "profile_enabled": false,
    "credit_card_enabled": false
  }
}
```

Flags such as `--disable-save-password-bubble`, `--disable-popup-blocking`, and `--disable-password-manager-reauthentication` are not reliable fixes for the password-save prompt in modern Chrome. `--disable-popup-blocking` only affects site popups, not Chrome UI. `--password-store=basic` and `--use-mock-keychain` are still useful for avoiding operating-system credential storage prompts in some environments.

If the password prompt still appears, open `chrome://version` in the automated browser and verify that `Profile Path` points to the temporary directory, for example `...\limitless-ui-chrome-profile-xxxxx\Default`. If it points to an existing Chrome profile, the test is not using the expected `userDataDir`. Close other Chrome or Chrome for Testing processes and rerun the test.

For locked-down CI machines, Chrome policy can also disable password manager globally, but use it only in disposable VM/CI profiles because it affects that user profile:

```powershell
reg add HKCU\Software\Policies\Google\Chrome /v PasswordManagerEnabled /t REG_DWORD /d 0 /f
```

## Stable Helpers

Prefer helpers that wait for visible, enabled elements before clicking. This avoids intermittent failures when AngularDart is still rendering, an overlay is animating, or a detached element was found by a raw selector.

```dart
Future<void> waitForSelector(
  Page page,
  String selector, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    final found = await page.evaluate(
      '(css) => document.querySelector(css) != null',
      args: [selector],
    );
    if (found == true) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw TimeoutException('Selector not found: $selector');
}

Future<void> clickFirstVisible(Page page, String selector) async {
  final handles = await page.$$(selector);
  try {
    for (final handle in handles) {
      final visible = await handle.evaluate<bool>(
        r'''(item) => {
          if (item.disabled || item.getAttribute('aria-disabled') === 'true') {
            return false;
          }
          const rect = item.getBoundingClientRect();
          const style = window.getComputedStyle(item);
          return rect.width > 0 &&
            rect.height > 0 &&
            style.display !== 'none' &&
            style.visibility !== 'hidden' &&
            style.pointerEvents !== 'none';
        }''',
      );

      if (visible == true) {
        await handle.evaluate(
          r'''(item) => item.scrollIntoView({
            block: 'center',
            inline: 'nearest',
            behavior: 'instant'
          })''',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await handle.click(delay: const Duration(milliseconds: 25));
        return;
      }
    }
  } finally {
    for (final handle in handles) {
      await handle.dispose();
    }
  }

  throw TimeoutException('Visible selector not found: $selector');
}

Future<String?> waitForAttribute(
  Page page,
  String selector,
  String attribute,
  bool Function(String? value) matches,
) async {
  final stopwatch = Stopwatch()..start();
  String? lastValue;
  while (stopwatch.elapsed < const Duration(seconds: 10)) {
    final value = await page.evaluate(
      '(css, attribute) => document.querySelector(css)?.getAttribute(attribute)',
      args: [selector, attribute],
    );
    lastValue = value?.toString();
    if (matches(lastValue)) {
      return lastValue;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw TimeoutException(
    'Attribute did not match: $selector@$attribute, last value: $lastValue',
  );
}
```

## Example Flows

Select an option from `li-select`:

```dart
test('selects a status', () async {
  final page = await openPage();
  try {
    await gotoRoute(page, 'select');

    await clickFirstVisible(page, '[data-label="li_select_toggle"]');
    await clickFirstVisible(
      page,
      '[data-label^="li_select_item_"][data-value="approved"]',
    );

    expect(
      await waitForAttribute(
        page,
        '[data-label="li_select"]',
        'data-value',
        (value) => value == 'approved',
      ),
      'approved',
    );
  } finally {
    await page.browser.close();
  }
});
```

Select and apply a date range:

```dart
await clickFirstVisible(page, '[data-label="li_drp_trigger"]');
await clickFirstVisible(
  page,
  '[data-label="li_drp_day"][data-calendar="left"].available:not(.off)',
);
await clickFirstVisible(page, '[data-label="li_drp_apply"]');
await waitForAttribute(
  page,
  '[data-label="li_drp"]',
  'data-value',
  (value) => value != null && value.contains('-'),
);
```

Confirm a SweetAlert prompt:

```dart
await clickFirstVisible(page, '[data-label="li_sa_demo_prompt"]');
await waitForSelector(page, '[data-label="li_sa_root"][data-open="true"]');
await page.type('[data-label="li_sa_input"][data-value="text"]', 'batch-42');
await clickFirstVisible(page, '[data-label="li_sa_confirm"]');
```

Open a modal and close it:

```dart
await waitForSelector(page, '[data-label="li_mdl"][data-open="true"]');
await clickFirstVisible(page, '[data-label="li_mdl_close"]');
```

## Hook Reference

The table groups hooks by component and stable hook family. A trailing `_` means the component appends a runtime index, for example `li_select_item_0`, `li_dt_row_3`, or `li_rate_star_4`.

| Component | Hook or family | Purpose |
| --- | --- | --- |
| `li-accordion` | `li_accordion`, `li_accordion_item`, `li_accordion_header`, `li_accordion_button`, `li_accordion_toggle`, `li_accordion_panel`, `li_accordion_body` | Locate the accordion root, items, clickable headers/toggles, collapsible panels, and mounted body content. |
| `li-breadcrumb` | `li_breadcrumb`, `li_breadcrumb_shell`, `li_breadcrumb_main`, `li_breadcrumb_list`, `li_breadcrumb_item`, `li_breadcrumb_helper`, `li_breadcrumb_start`, `li_breadcrumb_end` | Locate breadcrumb navigation, projected start/end slots, helper text, and individual breadcrumb entries. |
| `li-checkbox` | `li_checkbox`, `li_checkbox_input`, `li_checkbox_label`, `li_checkbox_group` | Read checkbox value state through `data-value`, click the native input, and group related checkbox options. |
| `li-radio` | `li_radio`, `li_radio_input`, `li_radio_label`, `li_radio_group` | Select radio options and assert the selected value on the option/group. |
| `li-toggle` | `li_toggle`, `li_toggle_input`, `li_toggle_label` | Toggle boolean state and assert `data-value`. |
| `li-select` | `li_select`, `li_select_toggle`, `li_select_search`, `li_select_opts`, `li_select_item_` | Open the select, type into the search box, choose options by `data-value`, and assert the selected value on the root. |
| `li-multi-select` | `li_ms`, `li_ms_toggle`, `li_ms_search`, `li_ms_opts`, `li_ms_item_`, `li_ms_check_` | Open the multi-select, filter options, click option rows or checkboxes, and assert comma-separated selected values. |
| `li-datatable-select` | `li_dts`, `li_dts_toggle`, `li_dts_apply`, `li_dts_clear`, `li_dts_modal_clear` | Open the modal selector, apply multi-selection, clear the trigger value, and read selected values on the root. |
| `li-datatable` | `li_dt`, `li_dt_head`, `li_dt_table`, `li_dt_scroll`, `li_dt_foot`, `li_dt_empty` | Locate the datatable root, table shell, scroll container, footer, and empty state. |
| `li-datatable` | `li_dt_search`, `li_dt_search_field`, `li_dt_search_opt`, `li_dt_search_btn` | Drive global search and select the active searchable field. |
| `li-datatable` | `li_dt_hcol_`, `li_dt_col_`, `li_dt_row_`, `li_dt_hcheck`, `li_dt_check`, `li_dt_check_all` | Target header cells, body cells, rows, and row-selection checkboxes by index/value. |
| `li-datatable` | `li_dt_child_row`, `li_dt_child_cell`, `li_dt_child_item` | Assert or inspect responsive detail rows and hidden-column content. |
| `li-datatable` | `li_dt_cols_btn`, `li_dt_cols_panel`, `li_dt_cols`, `li_dt_cols_all`, `li_dt_col_vis_item`, `li_dt_col_vis_check` | Open and interact with the column-visibility menu. |
| `li-datatable` | `li_dt_export`, `li_dt_export_btn`, `li_dt_export_panel`, `li_dt_export_item` | Open export actions and choose export formats. |
| `li-datatable` | `li_dt_page`, `li_dt_page_size`, `li_dt_page_size_opt`, `li_dt_page_summary` | Navigate pagination, change page size, and assert the visible page summary. |
| `li-datatable` | `li_dt_view_btn`, `li_dt_grid`, `li_dt_grid_layout`, `li_dt_grid_scroll`, `li_dt_grid_item`, `li_dt_card_default`, `li_dt_card_custom`, `li_dt_card_tpl` | Switch and inspect grid/card rendering modes. |
| `li-datatable` | `li_dt_hpop`, `li_dt_htip` | Target header popovers/tooltips used by rich column headers. |
| `li-date-picker` | `li_dp`, `li_dp_trigger`, `li_dp_input`, `li_dp_clear_trigger`, `li_dp_panel` | Open the picker, read the input/root value, clear from the trigger, and wait for the open panel. |
| `li-date-picker` | `li_dp_prev`, `li_dp_next`, `li_dp_view_switch`, `li_dp_day`, `li_dp_month`, `li_dp_year`, `li_dp_clear`, `li_dp_cancel` | Navigate calendar views, select a date/month/year, clear, or cancel. |
| `li-date-range-picker` | `li_drp`, `li_drp_trigger`, `li_drp_input`, `li_drp_clear_trigger`, `li_drp_panel` | Open the range picker, read the selected range, clear from the trigger, and wait for the open panel. |
| `li-date-range-picker` | `li_drp_left_prev`, `li_drp_left_next`, `li_drp_left_view_switch`, `li_drp_right_prev`, `li_drp_right_next`, `li_drp_right_view_switch` | Navigate the left and right calendars independently. |
| `li-date-range-picker` | `li_drp_day`, `li_drp_month`, `li_drp_year`, `li_drp_preset`, `li_drp_range`, `li_drp_apply`, `li_drp_clear`, `li_drp_cancel` | Select range cells, month/year views, preset shortcuts, manual range mode, and footer actions. |
| `li-time-picker` | `li_tp`, `li_tp_trigger`, `li_tp_input`, `li_tp_clear_trigger`, `li_tp_panel` | Open the time picker, read the selected time, clear from the trigger, and wait for the panel. |
| `li-time-picker` | `li_tp_hour_input`, `li_tp_minute_input`, `li_tp_am`, `li_tp_pm`, `li_tp_dial_label`, `li_tp_clear`, `li_tp_cancel`, `li_tp_apply` | Type or click time parts, switch meridiem, use dial labels, and apply/cancel. |
| `li-typeahead` | `li_ta`, `li_ta_input`, `li_ta_popup`, `li_ta_item_` | Type search text, wait for suggestions, select a suggestion, and assert the selected root value. |
| `li-treeview` | `li_treeview`, `li_treeview_input_search`, `li_treeview_btn_select_all`, `li_treeview_btn_expand_all`, `li_treeview_tree` | Search, select all, expand/collapse all, and inspect the standalone tree. |
| `li-treeview` | `li_treeview_node_item`, `li_treeview_node`, `li_treeview_node_expander`, `li_treeview_node_checkbox`, `li_treeview_node_label`, `li_treeview_node_children` | Interact with individual standalone tree nodes and child containers. |
| `li-treeview-select` | `li_ts`, `li_ts_toggle`, `li_ts_clear`, `li_ts_panel`, `li_ts_search`, `li_ts_all` | Open the dropdown tree selector, clear values, search nodes, and toggle all. |
| `li-treeview-select` | `li_ts_node`, `li_ts_expander`, `li_ts_checkbox`, `li_ts_label`, `li_ts_more_children`, `li_ts_more`, `li_ts_clear_action`, `li_ts_confirm_action` | Expand nodes, select labels/checkboxes, load more lazy nodes, clear, and confirm selection. |
| `li-rating` | `li_rate`, `li_rate_star_` | Click a star by index and assert the rating value on the root. |
| `li-slider` | `li_slider`, `li_slider_surface`, `li_slider_connect`, `li_slider_handle_`, `li_slider_pip_marker`, `li_slider_pip_value` | Drag handles, inspect connect bars, and assert rendered pip markers/values. |
| `li-color-picker` | `li_cp`, `li_cp_trigger`, `li_cp_panel`, `li_cp_backdrop`, `li_cp_area`, `li_cp_dragger` | Open the color picker, wait for the panel/backdrop, and drag inside the color area. |
| `li-color-picker` | `li_cp_hue`, `li_cp_hue_slider`, `li_cp_alpha`, `li_cp_alpha_handle`, `li_cp_input` | Adjust hue/alpha and type color input values. |
| `li-color-picker` | `li_cp_palette`, `li_cp_palette_btn`, `li_cp_swatch`, `li_cp_sel_swatch`, `li_cp_preview`, `li_cp_current`, `li_cp_initial`, `li_cp_clear`, `li_cp_cancel`, `li_cp_choose` | Pick palette colors, compare current/initial colors, clear, cancel, or choose. |
| `li-token-field` | `li_token`, `li_token_set`, `li_token_tokens`, `li_token_item_`, `li_token_remove_`, `li_token_input`, `li_token_menu` | Add tokens, assert token items by `data-value`, remove tokens, and inspect the action menu. |
| `li-tag-filter` | `li_tf`, `li_tf_toggle`, `li_tf_selected_badge`, `li_tf_inline_remove`, `li_tf_clear`, `li_tf_panel` | Open the tag filter, inspect selected badges, remove inline items, and clear the selection. |
| `li-tag-filter` | `li_tf_reload`, `li_tf_input_search`, `li_tf_options`, `li_tf_option_`, `li_tf_empty`, `li_tf_footer_clear` | Reload options, search/filter, select options, assert empty state, and clear from the footer. |
| Dropdown menu | `li_dm`, `li_dm_btn_toggle`, `li_dm_panel`, `li_dm_item`, `li_dm_mobile_backdrop`, `li_dm_mobile_close` | Open dropdown menus, wait for desktop/mobile panels, click items by `data-value`, and close mobile presentation. |
| `li-modal` | `li_mdl`, `li_mdl_dialog`, `li_mdl_content`, `li_mdl_header`, `li_mdl_title`, `li_mdl_body`, `li_mdl_footer` | Wait for the modal, inspect structure, and scope assertions inside the active dialog. |
| `li-modal` | `li_mdl_close`, `li_mdl_backdrop`, `li_mdl_error` | Close through the header button/backdrop and assert modal-level validation or error messages. |
| SimpleDialog | `li_sd_root`, `li_sd_modal`, `li_sd_dialog`, `li_sd_content`, `li_sd_header`, `li_sd_title`, `li_sd_body`, `li_sd_footer`, `li_sd_backdrop` | Wait for alert/confirm/prompt dialogs and scope selectors inside the active dialog. |
| SimpleDialog | `li_sd_confirm`, `li_sd_cancel`, `li_sd_input`, `li_sd_input_label`, `li_sd_validation`, `li_sd_detail_toggle`, `li_sd_detail` | Confirm/cancel, type prompt input, assert validation, and expand optional detail content. |
| SweetAlert | `li_sa_root`, `li_sa_popup`, `li_sa_title`, `li_sa_body`, `li_sa_footer`, `li_sa_actions`, `li_sa_icon`, `li_sa_image` | Wait for SweetAlert overlays, inspect type/title/body/footer/actions/icon/image. |
| SweetAlert | `li_sa_confirm`, `li_sa_cancel`, `li_sa_close`, `li_sa_loader`, `li_sa_progress`, `li_sa_progress_bar`, `li_sa_validation` | Click dialog actions, wait for loaders/progress, and assert validation messages. |
| SweetAlert | `li_sa_input`, `li_sa_input_option`, `li_sa_input_radio_label`, `li_sa_input_radio`, `li_sa_input_checkbox` | Type prompt values and choose select/radio/checkbox input options. |
| SweetAlert popover | `li_sa_popover`, `li_sa_popover_arrow`, `li_sa_popover_header`, `li_sa_popover_body` | Inspect popover-mode SweetAlert content and arrow placement. |
| `li-toast` | `li_toast`, `li_toast_header`, `li_toast_icon`, `li_toast_title`, `li_toast_badge`, `li_toast_helper`, `li_toast_body`, `li_toast_close` | Assert toast content and close visible toasts. |
| Toast stack | `li_toast_stack`, `li_toast_stack_item` | Inspect the rendered stack and individual toast entries. |
| Notification toast | `li_ntf`, `li_ntf_item`, `li_ntf_body` | Inspect notification container, notification items, and body content. |
| Pagination | `li_pagination`, `li_pagination_list`, `li_pagination_item_first`, `li_pagination_first`, `li_pagination_item_previous`, `li_pagination_previous`, `li_pagination_item_next`, `li_pagination_next`, `li_pagination_item_last`, `li_pagination_last` | Navigate first/previous/next/last page controls. |
| Pagination | `li_pagination_item_page`, `li_pagination_page`, `li_pagination_item_ellipsis`, `li_pagination_ellipsis` | Click page numbers and inspect ellipsis entries. |
| Popover | `li_popover_trigger`, `li_popover_panel`, `li_popover_arrow`, `li_popover_header`, `li_popover_body` | Open popovers and assert rendered panel/header/body/arrow. |
| Tooltip | `li_tooltip_trigger`, `li_tooltip_panel`, `li_tooltip_arrow`, `li_tooltip_body` | Open tooltips and assert panel/body/arrow placement. |
| Dynamic tabs | `li_tab`, `li_tab_nav`, `li_tab_nav_item`, `li_tab_link`, `li_tab_content`, `li_tab_panel` | Select tabs by `data-value` and assert the open panel through `data-open`. |

## Selector Guidelines

- Prefer `[data-label="..."]` for a component part.
- Combine with `[data-value="..."]` when selecting a business value.
- Use prefix selectors for indexed hooks: `[data-label^="li_select_item_"]`.
- Wait for `[data-open="true"]` on overlays before clicking inside them.
- Use `name` on form controls when you need browser metadata, accessibility tooling, or a stable form-level selector.
- Keep CSS classes for styling assertions only. Component classes may change for design reasons; `data-label` hooks are the automation contract.
