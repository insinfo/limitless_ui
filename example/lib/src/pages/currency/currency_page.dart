import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'currency-page',
  templateUrl: 'currency_page.html',
  styleUrls: ['currency_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiCurrencyInputComponent,
  ],
)
class CurrencyPageComponent {
  CurrencyPageComponent(this.i18n);

  static const String apiSnippet = '''
<li-currency-input
  [(ngModel)]="amountMinorUnits"
  currencyCode="USD"
  locale="en_US"
  [required]="true">
</li-currency-input>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  int? amountMinorUnits = 154250;
  int? amountMinorUnitsUsd = 98765;
  int? amountMinorUnitsEur = 73540;

  String get amountMinorUnitsLabel =>
      amountMinorUnits == null ? 'null' : '$amountMinorUnits';

  String get amountMinorUnitsUsdLabel =>
      amountMinorUnitsUsd == null ? 'null' : '$amountMinorUnitsUsd';

  String get amountMinorUnitsEurLabel =>
      amountMinorUnitsEur == null ? 'null' : '$amountMinorUnitsEur';
}
