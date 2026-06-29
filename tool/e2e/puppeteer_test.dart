import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

import 'puppeteer_setup.dart';

void main() {
  group('selection controls Puppeteer E2E', () {
    late Page page;

    setUp(() async {
      page = await setupExampleBrowser();
    });

    tearDown(() async {
      await page.browser.close();
    });

    test('seleciona valores em select e multi-select', () async {
      await gotoExample(page, 'select');
      await clickFirstVisible(page, '[data-label="custom_select_btn_toggle"]');
      await clickFirstVisible(
        page,
        '[data-label^="custom_select_item_"][data-value="approved"]',
      );
      expect(
        await waitForAttributeMatching(
          page,
          '[data-label="custom_select"]',
          'data-value',
          (value) => value == 'approved',
        ),
        'approved',
      );

      await gotoExample(page, 'multi-select');
      await clickFirstVisible(
        page,
        '[data-label="li_multi_select_btn_toggle"]',
      );
      await clickFirstVisible(
        page,
        '[data-label^="li_multi_select_item_"][data-value="sms"]',
      );
      expect(
        await waitForAttributeMatching(
          page,
          '[data-label="li_multi_select"]',
          'data-value',
          (value) => (value ?? '').split(',').contains('sms'),
        ),
        contains('sms'),
      );
    }, skip: skipExampleE2eReason());

    test('seleciona opcoes projetadas em select e multi-select', () async {
      await gotoExample(page, 'select');
      await clickVisibleAt(page, '[data-label="custom_select_btn_toggle"]', 1);
      await clickFirstVisible(
        page,
        '[data-label^="custom_select_item_"][data-value="backlog"]',
      );
      expect(
        await waitForAttributeAtMatching(
          page,
          '[data-label="custom_select"]',
          1,
          'data-value',
          (value) => value == 'backlog',
        ),
        'backlog',
      );

      await gotoExample(page, 'multi-select');
      await clickVisibleAt(
        page,
        '[data-label="li_multi_select_btn_toggle"]',
        1,
      );
      await clickFirstVisible(
        page,
        '[data-label^="li_multi_select_item_"][data-value="batch"]',
      );
      await waitForAttributeAtMatching(
        page,
        '[data-label="li_multi_select"]',
        1,
        'data-value',
        (value) => (value ?? '').split(',').contains('batch'),
      );
    }, skip: skipExampleE2eReason());

    test('seleciona registros em datatable select, tags e token field',
        () async {
      await gotoExample(page, 'datatable-select');
      await clickFirstVisible(
        page,
        '[data-label="li_datatable_select_btn_toggle"]',
      );
      await clickFirstVisible(page, '[data-label="datatable_row_0"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_datatable_select"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );

      await gotoExample(page, 'work-queue');
      await clickFirstVisible(page, '[data-label="li_token_field_input"]');
      await page.keyboard.type('123/2026');
      await page.keyboard.press(Key.enter);
      await waitForSelectorMatching(
        page,
        '[data-label="li_token_field_token_0"][data-value="123/2026"]',
      );

      await clickFirstVisible(page, '[data-label="li_tag_filter_btn_toggle"]');
      await clickFirstVisible(page, '[data-label="li_tag_filter_option_0"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_tag_filter"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );
    }, skip: skipExampleE2eReason());

    test('seleciona multiplos registros e limpa datatable select', () async {
      await gotoExample(page, 'datatable-select');
      await clickVisibleAt(
        page,
        '[data-label="li_datatable_select_btn_toggle"]',
        2,
      );
      await waitForSelectorCountAtLeast(
        page,
        '[data-label="datatable_col_checkbox"]',
        2,
      );
      await clickVisibleAt(page, '[data-label="datatable_col_checkbox"]', 0);
      await clickVisibleAt(page, '[data-label="datatable_col_checkbox"]', 1);
      await clickFirstVisible(
        page,
        '[data-label="li_datatable_select_modal_apply"]',
      );
      await waitForAttributeAtMatching(
        page,
        '[data-label="li_datatable_select"]',
        3,
        'data-value',
        (value) => value != null && value != '[]' && value.contains(','),
      );

      await clickFirstVisible(page, '[data-label="li_datatable_select_clear"]');
      expect(
        await waitForAttributeAtMatching(
          page,
          '[data-label="li_datatable_select"]',
          3,
          'data-value',
          (value) => value == '[]',
        ),
        '[]',
      );
    }, skip: skipExampleE2eReason());

    test('seleciona datas e horario nos pickers', () async {
      await gotoExample(page, 'date-picker');
      await clickFirstVisible(page, '[data-label="li_date_picker_trigger"]');
      await clickFirstVisible(
        page,
        '[data-label="li_date_picker_day"].available:not(.off)',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_date_picker"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );

      await gotoExample(page, 'date-range');
      await clickFirstVisible(
        page,
        '[data-label="li_date_range_picker_trigger"]',
      );
      final daySelector =
          '[data-label="li_date_range_picker_day"][data-calendar="left"].available:not(.off)';
      await clickVisibleAt(page, daySelector, 0);
      await clickVisibleAt(page, daySelector, 1);
      await clickFirstVisible(
          page, '[data-label="li_date_range_picker_apply"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_date_range_picker"]',
        'data-value',
        (value) => value != null && value.contains('-'),
      );

      await gotoExample(page, 'time-picker');
      await clickFirstVisible(page, '[data-label="li_time_picker_trigger"]');
      await clickFirstVisible(
        page,
        '[data-label="li_time_picker_dial_label"][data-value="10"]',
      );
      await clickFirstVisible(page, '[data-label="li_time_picker_apply"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_time_picker"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );
    }, skip: skipExampleE2eReason());

    test('navega e limpa selecoes nos pickers de data', () async {
      await gotoExample(page, 'date-picker');
      await clickFirstVisible(page, '[data-label="li_date_picker_trigger"]');
      await clickFirstVisible(page, '[data-label="li_date_picker_next"]');
      await clickFirstVisible(
        page,
        '[data-label="li_date_picker_day"].available:not(.off)',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_date_picker"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );
      await clickFirstVisible(
        page,
        '[data-label="li_date_picker_clear_trigger"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_date_picker"]',
        'data-value',
        (value) => value == null || value.isEmpty,
      );

      await gotoExample(page, 'date-range');
      await clickFirstVisible(
        page,
        '[data-label="li_date_range_picker_trigger"]',
      );
      await clickFirstVisible(
        page,
        '[data-label="li_date_range_picker_left_next"]',
      );
      final nextMonthDaySelector =
          '[data-label="li_date_range_picker_day"][data-calendar="left"].available:not(.off)';
      await clickVisibleAt(page, nextMonthDaySelector, 0);
      await clickVisibleAt(page, nextMonthDaySelector, 1);
      await clickFirstVisible(
        page,
        '[data-label="li_date_range_picker_apply"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_date_range_picker"]',
        'data-value',
        (value) => value != null && value.contains('-'),
      );
      await clickFirstVisible(
        page,
        '[data-label="li_date_range_picker_clear_trigger"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_date_range_picker"]',
        'data-value',
        (value) => value == null || value.isEmpty,
      );
    }, skip: skipExampleE2eReason());

    test('seleciona sugestao, arvore e rating', () async {
      await gotoExample(page, 'typeahead');
      await clickFirstVisible(
        page,
        '.demo-page [data-label="li_typeahead_input"]',
      );
      await page.keyboard.type('sa');
      final typeaheadPopupId = await waitForAttributeMatching(
        page,
        '.demo-page [data-label="li_typeahead_input"]',
        'aria-controls',
        (value) => value != null && value.isNotEmpty,
      );
      await clickFirstVisible(
        page,
        '#$typeaheadPopupId [data-label^="li_typeahead_item_"]',
      );
      await waitForAttributeMatching(
        page,
        '.demo-page [data-label="li_typeahead"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );

      await gotoExample(page, 'treeview');
      await clickFirstVisible(
        page,
        '[data-label="li_treeview_select_btn_toggle"]',
      );
      await clickFirstVisible(page, '[data-label="li_treeview_select_label"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_treeview_select"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );

      await gotoExample(page, 'rating');
      await clickFirstVisible(page, '[data-label="li_rating_star_4"]');
      expect(
        await waitForAttributeMatching(
          page,
          '[data-label="li_rating"]',
          'data-value',
          (value) => value == '4',
        ),
        '4',
      );
    }, skip: skipExampleE2eReason());

    test('aciona dropdown menus compacto e mobile por clique real', () async {
      await gotoExample(page, 'dropdown');
      await clickFirstVisible(page, '[aria-label="compact-filters"]');
      expect(
        await waitForAttributeMatching(
          page,
          '[aria-label="compact-filters"]',
          'aria-expanded',
          (value) => value == 'true',
        ),
        'true',
      );
      await clickFirstVisible(
        page,
        '[data-label="li_dropdown_menu_item"][data-value="pending"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="dropdown_compact_menu_state"]',
        'data-value',
        (value) => value != null && value.contains('pending'),
      );

      await clickFirstVisible(page, '[aria-label="compact-columns"]');
      await clickFirstVisible(
        page,
        '[data-label="li_dropdown_menu_item"][data-value="deadline"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="dropdown_compact_menu_state"]',
        'data-value',
        (value) => value != null && value.contains('deadline'),
      );

      await page.setViewport(DeviceViewport(width: 390, height: 760));
      await clickFirstVisible(page, '[aria-label="mobile-modal-menu"]');
      await waitForSelectorMatching(
        page,
        '[data-label="li_dropdown_menu_panel"][role="dialog"][data-open="true"]',
      );
      await clickFirstVisible(
        page,
        '[data-label="li_dropdown_menu_item"][data-value="download"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="dropdown_compact_menu_state"]',
        'data-value',
        (value) => value != null && value.contains('download'),
      );
    }, skip: skipExampleE2eReason());

    test('interage com checkbox, radio, toggle, slider e color picker',
        () async {
      await gotoExample(page, 'selection-controls');
      final checkedBefore = await selectorCount(
        page,
        '[data-label="li_checkbox"][data-value="true"]',
      );
      await clickFirstVisible(
        page,
        '[data-label="li_checkbox"][data-value="false"] [data-label="li_checkbox_input"]',
      );
      await waitForSelectorCountAtLeast(
        page,
        '[data-label="li_checkbox"][data-value="true"]',
        checkedBefore + 1,
      );

      await clickFirstVisible(
        page,
        '[data-label="li_radio"][data-value="customers"] [data-label="li_radio_input"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_radio"][data-value="customers"]',
        'data-current-value',
        (value) => value == 'customers',
      );

      final enabledTogglesBefore = await selectorCount(
        page,
        '[data-label="li_toggle"][data-value="true"]',
      );
      await clickFirstVisible(
        page,
        '[data-label="li_toggle"][data-value="false"] [data-label="li_toggle_input"]',
      );
      await waitForSelectorCountAtLeast(
        page,
        '[data-label="li_toggle"][data-value="true"]',
        enabledTogglesBefore + 1,
      );

      await gotoExample(page, 'slider');
      final initialSliderValue = await attributeValue(
        page,
        '[data-label="li_slider"]',
        'data-value',
      );
      await dragFirstVisibleBy(
        page,
        '[data-label="li_slider_handle_0"]',
        deltaX: 90,
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_slider"]',
        'data-value',
        (value) => value != null && value != initialSliderValue,
      );

      await gotoExample(page, 'color-picker');
      await clickFirstVisible(page, '[data-label="li_color_picker_trigger"]');
      await clickFirstVisible(
          page, '[data-label="li_color_picker_color_area"]');
      await clickFirstVisible(page, '[data-label="li_color_picker_choose"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_color_picker"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );
    }, skip: skipExampleE2eReason());
  });
}
