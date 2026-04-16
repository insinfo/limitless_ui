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
  currencyCode="BRL"
  [locale]="validationLocale"
  [liRules]="currencyRules"
  liValidationMode="submittedOrTouchedOrDirty"
  helperText="Participa do mesmo fluxo declarativo do liForm.">
</li-currency-input>''';

  static final List<LiRule> _currencyRulesPt = <LiRule>[
    LiRule.custom(
      (value) {
        if (value is int && value > 0) {
          return null;
        }
        return 'Informe um valor monetário maior que zero.';
      },
      code: 'currencyAmount',
    ),
  ];

  static final List<LiRule> _currencyRulesEn = <LiRule>[
    LiRule.custom(
      (value) {
        if (value is int && value > 0) {
          return null;
        }
        return 'Provide a monetary amount greater than zero.';
      },
      code: 'currencyAmount',
    ),
  ];

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  bool get isPt => i18n.isPortuguese;

  String get validationLocale => isPt ? 'pt_BR' : 'en_US';

  List<LiRule> get currencyRules => isPt ? _currencyRulesPt : _currencyRulesEn;

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
