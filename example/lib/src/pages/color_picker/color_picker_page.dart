import 'package:limitless_ui_example/limitless_ui_example.dart';
import 'package:ngrouter/ngrouter.dart';

@Component(
  selector: 'color-picker-page',
  templateUrl: 'color_picker_page.html',
  styleUrls: ['color_picker_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiColorPickerComponent,
    RouterLink,
  ],
  exports: [DemoRoutePaths],
)
class ColorPickerPageComponent {
  ColorPickerPageComponent(this.i18n);

  final DemoI18nService i18n;

  bool get isPt => i18n.isPortuguese;

  String? basicColor = '#20BF7E';
  String? customButtonsColor = '#20BF7E';
  String? emptyColor;
  String? hideButtonsColor = '#20BF7E';
  String? disabledColor = '#20BF7E';
  String? clickoutColor = '#20BF7E';
  String? initialColor = '#E63E3E';
  String? alphaColor = '#E63E3ECC';
  String? inputColor = '#E63E3E';
  String? clearSelectionColor = '#E63E3E';
  String? fullColor = '#E63E3ECC';
  String? paletteColor = '#27ADCA';
  String? paletteOnlyColor = '#27ADCA';
  String? selectionPaletteColor = '#27ADCA';
  String? paletteHideColor = '#27ADCA';
  String? hexColor = '#F75D1C';
  String? rgbColor = 'rgb(247, 93, 28)';
  String? nameColor = 'orangered';
  String? eventColor = '#45818E';
  String? flatColor = '#45818E';
  String? flatInputColor = '#45818E';
  String? flatPaletteColor = '#45818E';
  String? flatInitialColor = '#45818E';

  bool pickerEnabled = false;

  final List<String> limitlessPalette = const <String>[
    '#000000',
    '#444444',
    '#666666',
    '#999999',
    '#CCCCCC',
    '#EEEEEE',
    '#F3F3F3',
    '#FFFFFF',
    '#FF0000',
    '#FF9900',
    '#FFFF00',
    '#00FF00',
    '#00FFFF',
    '#0000FF',
    '#9900FF',
    '#FF00FF',
    '#F4CCCC',
    '#FCE5CD',
    '#FFF2CC',
    '#D9EAD3',
    '#D0E0E3',
    '#CFE2F3',
    '#D9D2E9',
    '#EAD1DC',
    '#EA9999',
    '#F9CB9C',
    '#FFE599',
    '#B6D7A8',
    '#A2C4C9',
    '#9FC5E8',
    '#B4A7D6',
    '#D5A6BD',
    '#E06666',
    '#F6B26B',
    '#FFD966',
    '#93C47D',
    '#76A5AF',
    '#6FA8DC',
    '#8E7CC3',
    '#C27BA0',
    '#CC0000',
    '#E69138',
    '#F1C232',
    '#6AA84F',
    '#45818E',
    '#3D85C6',
    '#674EA7',
    '#A64D79',
    '#990000',
    '#B45F06',
    '#BF9000',
    '#38761D',
    '#134F5C',
    '#0B5394',
    '#351C75',
    '#741B47',
    '#660000',
    '#783F04',
    '#7F6000',
    '#274E13',
    '#0C343D',
    '#073763',
    '#20124D',
    '#4C1130',
  ];

  final Map<String, String> eventResults = <String, String>{
    'change': '-',
    'hide': '-',
    'dragstart': '-',
    'move': '-',
    'show': '-',
    'dragstop': '-',
  };

  String get title => isPt ? 'Pickers - ' : 'Pickers - ';
  String get subtitle => isPt ? 'Color' : 'Color';
  String get breadcrumb => isPt ? 'Color picker' : 'Color picker';

  String get enableLabel => isPt ? 'Habilitar' : 'Enable';

  String get emptyLabel => isPt ? 'Sem cor selecionada' : 'No color selected';

  String formatValue(String? value) =>
      value == null || value.isEmpty ? emptyLabel : value;

  void onPickerEvent(String key, LiColorPickerEvent event) {
    final value = event.value == null || event.value!.isEmpty
        ? emptyLabel
        : event.value!;
    eventResults[key] = '${event.source}: $value';
  }
}
