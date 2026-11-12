// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/core/anchored_overlay_placement_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'anchored_overlay_placement_test.template.dart' as ng;

/// Every anchored overlay that sits on a field, each on its own fixed strip
/// whose `top` the test sets — the field can then sit anywhere in the window
/// without resizing it. Only one is opened per test.
@Component(
  selector: 'anchored-overlay-placement-host',
  template: '''
    <div class="strip" [style.top.px]="top"
        style="position: fixed; left: 40px; width: 280px;">
      <li-select #select [dataSource]="options" labelKey="label"
          valueKey="id" [searchable]="false"></li-select>
    </div>
    <div class="strip" [style.top.px]="top"
        style="position: fixed; left: 40px; width: 280px;">
      <li-multi-select #multi [dataSource]="options" labelKey="label"
          valueKey="id"></li-multi-select>
    </div>
    <div class="strip" [style.top.px]="top"
        style="position: fixed; left: 40px; width: 280px;">
      <li-time-picker #time [use24Hour]="true"></li-time-picker>
    </div>
    <div class="strip" [style.top.px]="top"
        style="position: fixed; left: 40px; width: 280px;">
      <li-date-range-picker #range></li-date-range-picker>
    </div>
    <div class="strip" [style.top.px]="top"
        style="position: fixed; left: 40px; width: 280px;">
      <li-color-picker #color></li-color-picker>
    </div>
    <div class="strip" [style.top.px]="top"
        style="position: fixed; left: 40px; width: 280px;">
      <li-typeahead #typeahead [dataSource]="labels" [minLength]="0"
          [openOnFocus]="true" [maxResults]="60" [debounceMs]="0">
      </li-typeahead>
    </div>
    <div class="strip" [style.top.px]="top"
        style="position: fixed; left: 40px; width: 280px;">
      <li-dropdown-menu #menu [options]="menuOptions" triggerLabel="Ações"
          ariaLabel="placement-actions" menuClass=""></li-dropdown-menu>
    </div>
    <div class="strip" [style.top.px]="top"
        style="position: fixed; left: 40px; width: 280px;">
      <div class="dropdown" liDropdownMenuPosition="bottom-start">
        <button type="button" class="btn li-dropdown-trigger">Menu</button>
        <div class="dropdown-menu" id="position-menu">
          <a *ngFor="let label of labels" class="dropdown-item"
              style="display: block; padding: 4px 16px;">{{ label }}</a>
        </div>
      </div>
    </div>
    <div class="strip" [style.top.px]="top"
        style="position: fixed; left: 40px; width: 280px;">
      <div liDropdown container="body" #drop="liDropdown">
        <button type="button" id="ld-toggle" liDropdownToggle>Menu</button>
        <div liDropdownMenu id="ld-menu">
          <button *ngFor="let label of labels" type="button" liDropdownItem
              style="display: block; width: 100%;">{{ label }}</button>
        </div>
      </div>
    </div>
  ''',
  directives: [
    coreDirectives,
    liDropdownDirectives,
    LiSelectComponent,
    LiMultiSelectComponent,
    LiTimePickerComponent,
    LiDateRangePickerComponent,
    LiColorPickerComponent,
    LiTypeaheadComponent,
    LiDropdownMenuComponent,
    LiDropdownMenuPositionDirective,
  ],
)
class AnchoredOverlayPlacementHostComponent {
  @ViewChild('select')
  LiSelectComponent? select;

  @ViewChild('multi')
  LiMultiSelectComponent? multi;

  @ViewChild('time')
  LiTimePickerComponent? time;

  @ViewChild('range')
  LiDateRangePickerComponent? range;

  @ViewChild('color')
  LiColorPickerComponent? color;

  @ViewChild('typeahead')
  LiTypeaheadComponent? typeahead;

  @ViewChild('menu')
  LiDropdownMenuComponent? menu;

  @ViewChild('drop')
  LiDropdownDirective? drop;

  num top = 20;

  final List<Map<String, dynamic>> options = <Map<String, dynamic>>[
    for (var i = 1; i <= 60; i++) <String, dynamic>{'id': i, 'label': 'Opção $i'},
  ];

  final List<String> labels = <String>[
    for (var i = 1; i <= 60; i++) 'Item $i',
  ];

  final List<LiDropdownMenuOption> menuOptions = <LiDropdownMenuOption>[
    for (var i = 1; i <= 60; i++)
      LiDropdownMenuOption(value: '$i', label: 'Ação $i'),
  ];
}

/// One overlay under test: how to open it, and where its field and panel are.
class _Subject {
  const _Subject(this.name, this.open, this.reference, this.panel,
      {this.gap = 0, this.tallStyle});

  final String name;
  final void Function(AnchoredOverlayPlacementHostComponent host) open;
  final html.Element Function(AnchoredOverlayPlacementHostComponent host)
      reference;
  final html.Element Function(AnchoredOverlayPlacementHostComponent host)
      panel;

  /// Distance the component keeps between field and panel.
  final double gap;

  /// CSS that makes the panel taller than the room on either side, for the
  /// components whose content is not a long list.
  final String? tallStyle;
}

final _subjects = <_Subject>[
  _Subject(
    'li-select',
    (host) => host.select!.openDropdown(),
    (host) => host.select!.dropdownButtonElement!,
    (host) => host.select!.dropdownContainerEle!,
  ),
  _Subject(
    'li-multi-select',
    (host) => host.multi!.openDropdown(),
    (host) => host.multi!.dropdownButtonElement!,
    (host) => host.multi!.dropdownContainerEle!,
  ),
  _Subject(
    'li-time-picker',
    (host) => host.time!.open(),
    (host) => host.time!.triggerElement!,
    (host) => host.time!.panelElement!,
    tallStyle:
        '[data-label="li_tp_panel"] .time-picker-panel-shell { min-height: 75vh; }',
  ),
  _Subject(
    'li-date-range-picker',
    (host) => host.range!.open(),
    (host) => host.range!.triggerElement!,
    (host) => host.range!.panelElement!,
    tallStyle: '[data-label="li_drp_panel"] .drp-calendar { min-height: 75vh; }',
  ),
  _Subject(
    'li-color-picker',
    (host) => host.color!.toggleOpen(),
    (host) => host.color!.triggerElement!,
    (host) => host.color!.panelElement!,
    tallStyle:
        '[data-label="li_cp_panel"] .sp-palette-container { min-height: 75vh; }',
  ),
  _Subject(
    'li-typeahead',
    (host) => host.typeahead!.handleFocus(),
    (host) => host.typeahead!.inputElement!,
    (host) => host.typeahead!.popupElement!,
    gap: 4,
  ),
  _Subject(
    'li-dropdown-menu',
    (host) => host.menu!.openDropdown(),
    (host) => host.menu!.triggerButtonElement!,
    (host) => host.menu!.menuElement!,
    gap: 4,
    // Without Bootstrap the items are inline buttons and the menu is short.
    tallStyle: '.li-dropdown-menu__items > * { display: block; width: 100%; '
        'padding: 4px 16px; }',
  ),
  _Subject(
    'liDropdownMenuPosition',
    (host) => (html.document.querySelector('.li-dropdown-trigger')!)
        .dispatchEvent(html.MouseEvent('click', canBubble: true)),
    (host) => html.document.querySelector('.li-dropdown-trigger')!,
    (host) => html.document.getElementById('position-menu')!,
    gap: 4,
  ),
  _Subject(
    'liDropdown container="body"',
    (host) => host.drop!.open(),
    (host) => html.document.getElementById('ld-toggle')!,
    // In the body, popper places (and the layout caps) the wrapper the
    // directive moves the menu into, so that is what the person sees.
    (host) => html.document.getElementById('ld-menu')!.parent!,
    gap: 2,
  ),
];

void main() {
  tearDown(() async {
    html.document.getElementById('anchored-overlay-tall')?.remove();
    await disposeAnyRunningTest();
  });

  final testBed = NgTestBed<AnchoredOverlayPlacementHostComponent>(
    ng.AnchoredOverlayPlacementHostComponentNgFactory,
  );

  double viewportHeight() =>
      (html.document.documentElement?.clientHeight ?? 0).toDouble();

  for (final subject in _subjects) {
    group(subject.name, () {
      test(
          'with no room on either side opens on the roomier side, glued to '
          'the field, inside the viewport and scrolling', () async {
        final tallStyle = subject.tallStyle;
        if (tallStyle != null) {
          html.document.head!.append(html.StyleElement()
            ..id = 'anchored-overlay-tall'
            ..text = tallStyle);
        }

        final fixture = await testBed.create();
        await fixture.update((host) => host.top = viewportHeight() * 0.55);
        await _frames();
        await fixture.update(subject.open);
        await _frames();

        final host = fixture.assertOnlyInstance;
        final reference = subject.reference(host).getBoundingClientRect();
        final panel = subject.panel(host);
        final rect = panel.getBoundingClientRect();
        final describe = 'panel ${_describe(rect)}, '
            'field ${_describe(reference)}';

        expect(rect.height, greaterThan(40), reason: describe);
        expect(panel.getAttribute('data-popper-placement'), startsWith('top'),
            reason: describe);
        expect(rect.bottom, closeTo(reference.top - subject.gap, 1.5),
            reason: describe);
        expect(rect.top, greaterThanOrEqualTo(7.5), reason: describe);
      });

      test('reopened near the top, opens below and glued', () async {
        final fixture = await testBed.create();
        await fixture.update((host) => host.top = 20);
        await _frames();
        await fixture.update(subject.open);
        await _frames();

        final host = fixture.assertOnlyInstance;
        final reference = subject.reference(host).getBoundingClientRect();
        final rect = subject.panel(host).getBoundingClientRect();
        final describe = 'panel ${_describe(rect)}, '
            'field ${_describe(reference)}';

        expect(rect.top, closeTo(reference.bottom + subject.gap, 1.5),
            reason: describe);
        expect(rect.bottom, lessThanOrEqualTo(viewportHeight() - 7.5),
            reason: describe);
      });
    });
  }
}

String _describe(html.Rectangle<num> rect) =>
    'top ${rect.top.toStringAsFixed(1)} bottom ${rect.bottom.toStringAsFixed(1)} '
    'height ${rect.height.toStringAsFixed(1)}';

/// Enough frames for change detection, the delayed popper updates some
/// components schedule (20ms) and a ResizeObserver round trip.
Future<void> _frames([int count = 4]) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  for (var i = 0; i < count; i++) {
    final completer = Completer<void>();
    html.window.requestAnimationFrame((_) => completer.complete());
    await completer.future;
  }
}
