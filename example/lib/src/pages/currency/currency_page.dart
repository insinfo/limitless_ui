import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'currency-page',
  templateUrl: 'currency_page.html',
  styleUrls: ['currency_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiCurrencyInputComponent,
  ],
)
class CurrencyPageComponent {
  CurrencyPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  int? amountMinorUnits = 154250;

  String get amountMinorUnitsLabel =>
      amountMinorUnits == null ? 'null' : '$amountMinorUnits';
}
