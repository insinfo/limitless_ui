import 'dart:math' as math;

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
      await clickFirstVisible(page, '[data-label="li_select_toggle"]');
      await clickFirstVisible(
        page,
        '[data-label^="li_select_item_"][data-value="approved"]',
      );
      expect(
        await waitForAttributeMatching(
          page,
          '[data-label="li_select"]',
          'data-value',
          (value) => value == 'approved',
        ),
        'approved',
      );

      await gotoExample(page, 'multi-select');
      await clickFirstVisible(
        page,
        '[data-label="li_ms_toggle"]',
      );
      await clickFirstVisible(
        page,
        '[data-label^="li_ms_item_"][data-value="sms"]',
      );
      expect(
        await waitForAttributeMatching(
          page,
          '[data-label="li_ms"]',
          'data-value',
          (value) => (value ?? '').split(',').contains('sms'),
        ),
        contains('sms'),
      );
    }, skip: skipExampleE2eReason());

    test('seleciona opcoes projetadas em select e multi-select', () async {
      await gotoExample(page, 'select');
      await clickVisibleAt(page, '[data-label="li_select_toggle"]', 1);
      await clickFirstVisible(
        page,
        '[data-label^="li_select_item_"][data-value="backlog"]',
      );
      expect(
        await waitForAttributeAtMatching(
          page,
          '[data-label="li_select"]',
          1,
          'data-value',
          (value) => value == 'backlog',
        ),
        'backlog',
      );

      await gotoExample(page, 'multi-select');
      await clickVisibleAt(
        page,
        '[data-label="li_ms_toggle"]',
        1,
      );
      await clickFirstVisible(
        page,
        '[data-label^="li_ms_item_"][data-value="batch"]',
      );
      await waitForAttributeAtMatching(
        page,
        '[data-label="li_ms"]',
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
        '[data-label="li_dts_toggle"]',
      );
      await clickFirstVisible(page, '[data-label="li_dt_row_0"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_dts"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );

      await gotoExample(page, 'work-queue');
      await clickFirstVisible(page, '[data-label="li_token_input"]');
      await page.keyboard.type('123/2026');
      await page.keyboard.press(Key.enter);
      await waitForSelectorMatching(
        page,
        '[data-label="li_token_item_0"][data-value="123/2026"]',
      );

      await clickFirstVisible(page, '[data-label="li_tf_toggle"]');
      await clickFirstVisible(page, '[data-label="li_tf_option_0"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_tf"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );
    }, skip: skipExampleE2eReason());

    test('seleciona multiplos registros e limpa datatable select', () async {
      await gotoExample(page, 'datatable-select');
      await clickVisibleAt(
        page,
        '[data-label="li_dts_toggle"]',
        2,
      );
      await waitForSelectorCountAtLeast(
        page,
        '[data-label="li_dt_check"]',
        2,
      );
      await clickVisibleAt(page, '[data-label="li_dt_check"]', 0);
      await clickVisibleAt(page, '[data-label="li_dt_check"]', 1);
      await clickFirstVisible(
        page,
        '[data-label="li_dts_apply"]',
      );
      await waitForAttributeAtMatching(
        page,
        '[data-label="li_dts"]',
        3,
        'data-value',
        (value) => value != null && value != '[]' && value.contains(','),
      );

      await clickFirstVisible(page, '[data-label="li_dts_clear"]');
      expect(
        await waitForAttributeAtMatching(
          page,
          '[data-label="li_dts"]',
          3,
          'data-value',
          (value) => value == '[]',
        ),
        '[]',
      );
    }, skip: skipExampleE2eReason());

    test('seleciona datas e horario nos pickers', () async {
      await gotoExample(page, 'date-picker');
      await clickFirstVisible(page, '[data-label="li_dp_trigger"]');
      await clickFirstVisible(
        page,
        '[data-label="li_dp_day"].available:not(.off)',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_dp"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );

      await gotoExample(page, 'date-range');
      await clickFirstVisible(
        page,
        '[data-label="li_drp_trigger"]',
      );
      final daySelector =
          '[data-label="li_drp_day"][data-calendar="left"].available:not(.off)';
      await clickVisibleAt(page, daySelector, 0);
      await clickVisibleAt(page, daySelector, 1);
      await clickFirstVisible(page, '[data-label="li_drp_apply"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_drp"]',
        'data-value',
        (value) => value != null && value.contains('-'),
      );
      final presetRangeBefore = await attributeValueAt(
        page,
        '[data-label="li_drp"]',
        1,
        'data-value',
      );
      await clickVisibleAt(
        page,
        '[data-label="li_drp_trigger"]',
        1,
      );
      await clickFirstVisible(
        page,
        '[data-label="li_drp_preset"][data-value="last_7_days"]',
      );
      await waitForAttributeAtMatching(
        page,
        '[data-label="li_drp"]',
        1,
        'data-value',
        (value) =>
            value != null && value.contains('-') && value != presetRangeBefore,
      );
      await clickVisibleAt(
        page,
        '[data-label="li_drp_trigger"]',
        1,
      );
      await clickFirstVisible(
        page,
        '[data-label="li_drp_custom_range"]',
      );
      await waitForSelectorCountAtLeast(
        page,
        '[data-label="li_drp_panel"].is-open .drp-calendar',
        2,
      );
      final customRangeMetrics = await page.evaluate(
        r'''() => {
          const panel = document.querySelector('[data-label="li_drp_panel"].is-open');
          const custom = document.querySelector('[data-label="li_drp_custom_range"]');
          const thisMonth = document.querySelector('[data-label="li_drp_preset"][data-value="this_month"]');
          const calendar = document.querySelector('[data-label="li_drp_panel"].is-open .drp-calendar');
          const panelRect = panel.getBoundingClientRect();
          const calendarRect = calendar.getBoundingClientRect();
          return {
            customActive: custom.classList.contains('active'),
            thisMonthActive: thisMonth.classList.contains('active'),
            panelRight: panelRect.right,
            viewportWidth: window.innerWidth,
            overflowX: window.getComputedStyle(panel).overflowX,
            calendarWidth: calendarRect.width
          };
        }''',
      ) as Map;
      expect(customRangeMetrics['customActive'], isTrue);
      expect(customRangeMetrics['thisMonthActive'], isFalse);
      expect(
        (customRangeMetrics['panelRight'] as num) <=
            (customRangeMetrics['viewportWidth'] as num) + 1,
        isTrue,
      );
      expect(customRangeMetrics['overflowX'], isNot('visible'));
      expect((customRangeMetrics['calendarWidth'] as num) >= 280, isTrue);

      await gotoExample(page, 'time-picker');
      await clickFirstVisible(page, '[data-label="li_tp_trigger"]');
      await clickFirstVisible(
        page,
        '[data-label="li_tp_dial_label"][data-value="10"]',
      );
      await clickFirstVisible(page, '[data-label="li_tp_apply"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_tp"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );
    }, skip: skipExampleE2eReason());

    test('mantem posicao desktop do date picker ao reabrir pelo mesmo trigger',
        () async {
      await page.setViewport(DeviceViewport(width: 1000, height: 650));
      await gotoExample(page, 'date-picker');

      Future<Map<dynamic, dynamic>> openDatePickerAt(num fraction) async {
        final point = await page.evaluate(
          r'''(fraction) => {
            const triggers = [...document.querySelectorAll('[data-label="li_dp_trigger"]')]
              .filter((item) => {
                const rect = item.getBoundingClientRect();
                const style = window.getComputedStyle(item);
                return rect.width > 0 &&
                  rect.height > 0 &&
                  style.display !== 'none' &&
                  style.visibility !== 'hidden' &&
                  style.pointerEvents !== 'none';
              });
            const trigger = triggers[1] || triggers[0];
            trigger.scrollIntoView({
              block: 'center',
              inline: 'nearest',
              behavior: 'instant'
            });
            const rect = trigger.getBoundingClientRect();
            return {
              x: rect.left + rect.width * fraction,
              y: rect.top + rect.height / 2
            };
          }''',
          args: [fraction],
        ) as Map;

        await aguarde(100);
        await page.mouse.move(
          math.Point<num>(point['x'] as num, point['y'] as num),
        );
        await page.mouse.down();
        await page.mouse.up();
        await waitForSelectorMatching(
          page,
          '[data-label="li_dp_panel"].is-open',
        );
        await aguarde(250);

        return await page.evaluate(
          r'''() => {
            const panel = document.querySelector('[data-label="li_dp_panel"].is-open');
            const rect = panel.getBoundingClientRect();
            return {
              left: rect.left,
              top: rect.top,
              width: rect.width,
              height: rect.height,
              placement: panel.getAttribute('data-popper-placement'),
              inlineMaxHeight: panel.style.maxHeight,
              inlineOverflowY: panel.style.overflowY
            };
          }''',
        ) as Map;
      }

      final firstOpen = await openDatePickerAt(0.15);
      await page.keyboard.press(Key.escape);
      await aguarde(200);

      final secondOpen = await openDatePickerAt(0.85);
      expect(
        ((secondOpen['left'] as num) - (firstOpen['left'] as num)).abs(),
        lessThanOrEqualTo(2),
      );
      expect(
        ((secondOpen['top'] as num) - (firstOpen['top'] as num)).abs(),
        lessThanOrEqualTo(2),
      );
      expect(secondOpen['placement'], firstOpen['placement']);
    }, skip: skipExampleE2eReason());

    test('mantem date range mobile fullscreen estavel ao selecionar datas',
        () async {
      await page.setViewport(DeviceViewport(width: 375, height: 667));
      await gotoExample(page, 'date-range');
      await clickFirstVisible(
        page,
        '[data-label="li_drp_trigger"]',
      );
      await waitForSelectorMatching(
        page,
        '[data-label="li_drp_panel"].date-range-open--mobile-modal.is-open',
      );

      final beforeMetrics = await page.evaluate(
        r'''() => {
          const panel = document.querySelector('[data-label="li_drp_panel"].is-open');
          const content = panel.querySelector('.date-range-panel-content');
          const rect = panel.getBoundingClientRect();
          const style = window.getComputedStyle(panel);
          const contentStyle = window.getComputedStyle(content);
          return {
            top: rect.top,
            left: rect.left,
            width: rect.width,
            height: rect.height,
            viewportWidth: window.innerWidth,
            viewportHeight: window.innerHeight,
            transform: style.transform,
            overflow: style.overflow,
            contentOverflowY: contentStyle.overflowY
          };
        }''',
      ) as Map;

      await clickFirstVisible(
        page,
        '[data-label="li_drp_day"][data-calendar="left"].available:not(.off)',
      );

      final afterMetrics = await page.evaluate(
        r'''() => {
          const panel = document.querySelector('[data-label="li_drp_panel"].is-open');
          const content = panel.querySelector('.date-range-panel-content');
          const rect = panel.getBoundingClientRect();
          const style = window.getComputedStyle(panel);
          const contentStyle = window.getComputedStyle(content);
          return {
            top: rect.top,
            left: rect.left,
            width: rect.width,
            height: rect.height,
            viewportWidth: window.innerWidth,
            viewportHeight: window.innerHeight,
            transform: style.transform,
            overflow: style.overflow,
            contentOverflowY: contentStyle.overflowY
          };
        }''',
      ) as Map;

      expect((beforeMetrics['top'] as num).abs() <= 1, isTrue);
      expect((beforeMetrics['left'] as num).abs() <= 1, isTrue);
      expect(
        (beforeMetrics['width'] as num) >=
            (beforeMetrics['viewportWidth'] as num) - 1,
        isTrue,
      );
      expect(
        (beforeMetrics['height'] as num) >=
            (beforeMetrics['viewportHeight'] as num) - 1,
        isTrue,
      );
      expect(beforeMetrics['transform'],
          anyOf('none', 'matrix(1, 0, 0, 1, 0, 0)'));
      expect(beforeMetrics['overflow'], 'hidden');
      expect(beforeMetrics['contentOverflowY'], 'auto');
      expect(
        ((afterMetrics['top'] as num) - (beforeMetrics['top'] as num)).abs() <=
            1,
        isTrue,
      );
      expect(
        ((afterMetrics['left'] as num) - (beforeMetrics['left'] as num))
                .abs() <=
            1,
        isTrue,
      );
      expect(
        ((afterMetrics['width'] as num) - (beforeMetrics['width'] as num))
                .abs() <=
            1,
        isTrue,
      );
      expect(
        ((afterMetrics['height'] as num) - (beforeMetrics['height'] as num))
                .abs() <=
            1,
        isTrue,
      );
    }, skip: skipExampleE2eReason());

    test('mostra presets mobile sem area vazia antes do calendario', () async {
      await page.setViewport(DeviceViewport(width: 375, height: 667));
      await gotoExample(page, 'date-range');
      await clickVisibleAt(
        page,
        '[data-label="li_drp_trigger"]',
        1,
      );
      await waitForSelectorMatching(
        page,
        '[data-label="li_drp_panel"].date-range-open--mobile-modal.is-open',
      );

      final presetsOnlyMetrics = await page.evaluate(
        r'''() => {
          const panel = document.querySelector('[data-label="li_drp_panel"].is-open');
          const content = panel.querySelector('.date-range-panel-content');
          const presets = panel.querySelector('.date-range-presets');
          const rect = panel.getBoundingClientRect();
          const contentRect = content.getBoundingClientRect();
          const presetsRect = presets.getBoundingClientRect();
          return {
            calendarCount: panel.querySelectorAll('.drp-calendar').length,
            panelHeight: rect.height,
            contentHeight: contentRect.height,
            presetsHeight: presetsRect.height,
            viewportHeight: window.innerHeight,
            presetsBorderBottom: window.getComputedStyle(presets).borderBottomWidth
          };
        }''',
      ) as Map;

      expect(presetsOnlyMetrics['calendarCount'], 0);
      expect(
        (presetsOnlyMetrics['panelHeight'] as num) <
            (presetsOnlyMetrics['viewportHeight'] as num) * 0.75,
        isTrue,
      );
      expect(
        ((presetsOnlyMetrics['contentHeight'] as num) -
                    (presetsOnlyMetrics['presetsHeight'] as num))
                .abs() <=
            2,
        isTrue,
      );
      expect(presetsOnlyMetrics['presetsBorderBottom'], '0px');

      await clickFirstVisible(
        page,
        '[data-label="li_drp_custom_range"]',
      );
      await waitForSelectorCountAtLeast(
        page,
        '[data-label="li_drp_panel"].is-open .drp-calendar',
        2,
      );

      final calendarMetrics = await page.evaluate(
        r'''() => {
          const panel = document.querySelector('[data-label="li_drp_panel"].is-open');
          const rect = panel.getBoundingClientRect();
          return {
            top: rect.top,
            left: rect.left,
            width: rect.width,
            height: rect.height,
            viewportWidth: window.innerWidth,
            viewportHeight: window.innerHeight
          };
        }''',
      ) as Map;

      expect((calendarMetrics['top'] as num).abs() <= 1, isTrue);
      expect((calendarMetrics['left'] as num).abs() <= 1, isTrue);
      expect(
        (calendarMetrics['width'] as num) >=
            (calendarMetrics['viewportWidth'] as num) - 1,
        isTrue,
      );
      expect(
        (calendarMetrics['height'] as num) >=
            (calendarMetrics['viewportHeight'] as num) - 1,
        isTrue,
      );
    }, skip: skipExampleE2eReason());

    test('mantem date e time picker mobile fullscreen', () async {
      await page.setViewport(DeviceViewport(width: 375, height: 667));

      await gotoExample(page, 'date-picker');
      await clickFirstVisible(page, '[data-label="li_dp_trigger"]');
      await waitForSelectorMatching(
        page,
        '[data-label="li_dp_panel"].date-picker-open--mobile-modal.is-open',
      );
      final dateMetrics = await page.evaluate(
        r'''() => {
          const panel = document.querySelector('[data-label="li_dp_panel"].is-open');
          const calendar = panel.querySelector('.single-calendar');
          const rect = panel.getBoundingClientRect();
          return {
            top: rect.top,
            left: rect.left,
            width: rect.width,
            height: rect.height,
            viewportWidth: window.innerWidth,
            viewportHeight: window.innerHeight,
            overflowX: window.getComputedStyle(panel).overflowX,
            overflowY: window.getComputedStyle(panel).overflowY,
            calendarClientHeight: calendar.clientHeight,
            calendarScrollHeight: calendar.scrollHeight,
            calendarTableHeight: window.getComputedStyle(
              calendar.querySelector('.calendar-table')
            ).height
          };
        }''',
      ) as Map;
      expect((dateMetrics['top'] as num).abs() <= 1, isTrue);
      expect((dateMetrics['left'] as num).abs() <= 1, isTrue);
      expect(
        (dateMetrics['width'] as num) >=
            (dateMetrics['viewportWidth'] as num) - 1,
        isTrue,
      );
      expect(
        (dateMetrics['height'] as num) >=
            (dateMetrics['viewportHeight'] as num) - 1,
        isTrue,
      );
      expect(dateMetrics['overflowX'], 'hidden');
      expect(dateMetrics['overflowY'], 'auto');
      expect(
        (dateMetrics['calendarScrollHeight'] as num) <=
            (dateMetrics['calendarClientHeight'] as num) + 1,
        isTrue,
      );

      await gotoExample(page, 'time-picker');
      await clickFirstVisible(page, '[data-label="li_tp_trigger"]');
      await waitForSelectorMatching(
        page,
        '[data-label="li_tp_panel"].time-picker-panel--mobile-modal.is-open',
      );
      final timeBeforeMetrics = await page.evaluate(
        r'''() => {
          const panel = document.querySelector('[data-label="li_tp_panel"].is-open');
          const shell = panel.querySelector('.time-picker-panel-shell');
          const footer = panel.querySelector('.time-picker-footer');
          const rect = panel.getBoundingClientRect();
          return {
            top: rect.top,
            left: rect.left,
            width: rect.width,
            height: rect.height,
            viewportWidth: window.innerWidth,
            viewportHeight: window.innerHeight,
            overflow: window.getComputedStyle(panel).overflow,
            shellOverflowY: window.getComputedStyle(shell).overflowY,
            footerBorderTopStyle: window.getComputedStyle(footer).borderTopStyle,
            footerBorderTopWidth: window.getComputedStyle(footer).borderTopWidth
          };
        }''',
      ) as Map;
      await clickFirstVisible(
        page,
        '[data-label="li_tp_dial_label"][data-value="10"]',
      );
      final timeAfterMetrics = await page.evaluate(
        r'''() => {
          const panel = document.querySelector('[data-label="li_tp_panel"].is-open');
          const rect = panel.getBoundingClientRect();
          return {
            top: rect.top,
            left: rect.left,
            width: rect.width,
            height: rect.height
          };
        }''',
      ) as Map;

      expect((timeBeforeMetrics['top'] as num).abs() <= 1, isTrue);
      expect((timeBeforeMetrics['left'] as num).abs() <= 1, isTrue);
      expect(
        (timeBeforeMetrics['width'] as num) >=
            (timeBeforeMetrics['viewportWidth'] as num) - 1,
        isTrue,
      );
      expect(
        (timeBeforeMetrics['height'] as num) >=
            (timeBeforeMetrics['viewportHeight'] as num) - 1,
        isTrue,
      );
      expect(timeBeforeMetrics['overflow'], 'hidden');
      expect(timeBeforeMetrics['shellOverflowY'], 'auto');
      expect(timeBeforeMetrics['footerBorderTopStyle'], 'solid');
      expect(timeBeforeMetrics['footerBorderTopWidth'], isNot('0px'));
      expect(
        ((timeAfterMetrics['top'] as num) - (timeBeforeMetrics['top'] as num))
                .abs() <=
            1,
        isTrue,
      );
      expect(
        ((timeAfterMetrics['left'] as num) - (timeBeforeMetrics['left'] as num))
                .abs() <=
            1,
        isTrue,
      );
      expect(
        ((timeAfterMetrics['width'] as num) -
                    (timeBeforeMetrics['width'] as num))
                .abs() <=
            1,
        isTrue,
      );
      expect(
        ((timeAfterMetrics['height'] as num) -
                    (timeBeforeMetrics['height'] as num))
                .abs() <=
            1,
        isTrue,
      );
    }, skip: skipExampleE2eReason());

    test('navega e limpa selecoes nos pickers de data', () async {
      await gotoExample(page, 'date-picker');
      await clickFirstVisible(page, '[data-label="li_dp_trigger"]');
      await clickFirstVisible(page, '[data-label="li_dp_next"]');
      await clickFirstVisible(
        page,
        '[data-label="li_dp_day"].available:not(.off)',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_dp"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );
      await clickFirstVisible(
        page,
        '[data-label="li_dp_clear_trigger"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_dp"]',
        'data-value',
        (value) => value == null || value.isEmpty,
      );
      final customTriggerBefore = await attributeValue(
        page,
        '[data-label="li_dp_badge"]',
        'data-value',
      );
      await clickFirstVisible(
        page,
        '[data-label="li_dp_badge"]',
      );
      await clickFirstVisible(
        page,
        '[data-label="li_dp_day"].available:not(.off)',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_dp_badge"]',
        'data-value',
        (value) =>
            value != null && value.isNotEmpty && value != customTriggerBefore,
      );

      await gotoExample(page, 'date-range');
      await clickFirstVisible(
        page,
        '[data-label="li_drp_trigger"]',
      );
      await clickFirstVisible(
        page,
        '[data-label="li_drp_left_next"]',
      );
      final nextMonthDaySelector =
          '[data-label="li_drp_day"][data-calendar="left"].available:not(.off)';
      await clickVisibleAt(page, nextMonthDaySelector, 0);
      await clickVisibleAt(page, nextMonthDaySelector, 1);
      await clickFirstVisible(
        page,
        '[data-label="li_drp_apply"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_drp"]',
        'data-value',
        (value) => value != null && value.contains('-'),
      );
      await clickFirstVisible(
        page,
        '[data-label="li_drp_clear_trigger"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_drp"]',
        'data-value',
        (value) => value == null || value.isEmpty,
      );
    }, skip: skipExampleE2eReason());

    test('seleciona sugestao, arvore e rating', () async {
      await gotoExample(page, 'typeahead');
      await clickFirstVisible(
        page,
        '.demo-page [data-label="li_ta_input"]',
      );
      await page.keyboard.type('sa');
      final typeaheadPopupId = await waitForAttributeMatching(
        page,
        '.demo-page [data-label="li_ta_input"]',
        'aria-controls',
        (value) => value != null && value.isNotEmpty,
      );
      await clickFirstVisible(
        page,
        '#$typeaheadPopupId [data-label^="li_ta_item_"]',
      );
      await waitForAttributeMatching(
        page,
        '.demo-page [data-label="li_ta"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );

      await gotoExample(page, 'treeview');
      await clickFirstVisible(
        page,
        '[data-label="li_ts_toggle"]',
      );
      await clickFirstVisible(page, '[data-label="li_ts_label"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_ts"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );

      await gotoExample(page, 'rating');
      await clickFirstVisible(page, '[data-label="li_rate_star_4"]');
      expect(
        await waitForAttributeMatching(
          page,
          '[data-label="li_rate"]',
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
        '[data-label="li_dm_item"][data-value="pending"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_dd_compact_state"]',
        'data-value',
        (value) => value != null && value.contains('pending'),
      );

      await clickFirstVisible(page, '[aria-label="compact-columns"]');
      await clickFirstVisible(
        page,
        '[data-label="li_dm_item"][data-value="deadline"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_dd_compact_state"]',
        'data-value',
        (value) => value != null && value.contains('deadline'),
      );

      await page.setViewport(DeviceViewport(width: 390, height: 760));
      await clickFirstVisible(page, '[aria-label="mobile-modal-menu"]');
      await waitForSelectorMatching(
        page,
        '[data-label="li_dm_panel"][role="dialog"][data-open="true"]',
      );
      await clickFirstVisible(
        page,
        '[data-label="li_dm_item"][data-value="download"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_dd_compact_state"]',
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
      await clickFirstVisible(page, '[data-label="li_cp_trigger"]');
      await clickFirstVisible(page, '[data-label="li_cp_area"]');
      await clickFirstVisible(page, '[data-label="li_cp_choose"]');
      await waitForAttributeMatching(
        page,
        '[data-label="li_cp"]',
        'data-value',
        (value) => value != null && value.isNotEmpty,
      );
    }, skip: skipExampleE2eReason());

    test('interage com SweetAlert por hooks de automacao', () async {
      await gotoExample(page, 'sweet-alert');

      await clickFirstVisible(page, '[data-label="li_sa_demo_confirm"]');
      await waitForSelectorMatching(
        page,
        '[data-label="li_sa_root"][data-open="true"]',
      );
      await waitForSelectorMatching(
        page,
        '[data-label="li_sa_popup"][data-type="question"][data-open="true"]',
      );
      await waitForSelectorMatching(
        page,
        '[data-label="li_sa_icon"][data-value="question"]',
      );
      await clickFirstVisible(page, '[data-label="li_sa_cancel"]');
      await waitForSelectorGone(page, '[data-label="li_sa_root"]');

      await clickFirstVisible(page, '[data-label="li_sa_demo_prompt"]');
      await waitForSelectorMatching(
        page,
        '[data-label="li_sa_input"][data-value="text"]',
      );
      await clickFirstVisible(page, '[data-label="li_sa_confirm"]');
      await waitForSelectorMatching(
        page,
        '[data-label="li_sa_validation"]',
      );
      await page.type(
        '[data-label="li_sa_input"][data-value="text"]',
        'batch-42',
      );
      await clickFirstVisible(page, '[data-label="li_sa_confirm"]');
      await waitForSelectorGone(page, '[data-label="li_sa_root"]');

      await clickFirstVisible(
        page,
        '[data-label="li_tab_link"][data-value="2"]',
      );
      await waitForAttributeMatching(
        page,
        '[data-label="li_tab_nav"]',
        'data-value',
        (value) => value == '2',
      );
      await waitForSelectorMatching(
        page,
        '[data-label="li_tab_panel"][data-value="2"][data-open="true"]',
      );
      await clickFirstVisible(page, '[data-label="li_sa_demo_select"]');
      await waitForSelectorMatching(
        page,
        '[data-label="li_sa_input_option"][data-value="prod"]',
      );
      await clickFirstVisible(page, '[data-label="li_sa_cancel"]');
      await waitForSelectorGone(page, '[data-label="li_sa_root"]');
    }, skip: skipExampleE2eReason());
  });
}
