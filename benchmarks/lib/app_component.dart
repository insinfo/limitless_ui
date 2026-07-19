// Benchmark host: renders a large li-datatable without virtualization plus a
// li-dropdown-menu and a li-select. All timing is done from the outside by the
// Puppeteer driver (tool/bench_exemplo2.dart in the package root), so this
// component must stay identical between the ngx8 and ngx9 variants and must
// not import dart:html or package:web.
import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';

@Component(
  selector: 'bench-app',
  template: '''
    <h4>limitless_ui benchmark</h4>
    <div class="mb-3">
      <button id="btn-render" type="button" class="btn btn-primary"
          (click)="renderRows()">Render {{rowTarget}} rows</button>
      <button id="btn-clear" type="button" class="btn btn-light"
          (click)="clearRows()">Clear</button>
      <span id="row-state">{{data.items.length}}</span>
    </div>
    <div id="dd" class="mb-3">
      <li-dropdown-menu
          ariaLabel="bench menu"
          triggerLabel="Menu"
          [options]="menuOptions">
      </li-dropdown-menu>
    </div>
    <div id="sel" class="mb-3" style="max-width: 320px;">
      <li-select
          [dataSource]="selectOptions"
          labelKey="label"
          valueKey="id"
          placeholder="Selecione uma cidade">
      </li-select>
    </div>
    <li-datatable
        [dataTableFilter]="filter"
        [data]="data"
        [settings]="settings">
    </li-datatable>
  ''',
  directives: [
    coreDirectives,
    LiDataTableComponent,
    LiDropdownMenuComponent,
    LiSelectComponent,
  ],
)
class AppComponent {
  static const int rowTarget = 2500;
  static const int selectOptionCount = 300;
  static const int menuOptionCount = 60;

  Filters filter = Filters(limit: rowTarget + 100, offset: 0);

  DataFrame<Map<String, dynamic>> data =
      DataFrame<Map<String, dynamic>>(items: <Map<String, dynamic>>[], totalRecords: 0);

  final DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'id', title: 'ID', sortingBy: 'id', enableSorting: true),
      DatatableCol(key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
      DatatableCol(key: 'email', title: 'E-mail'),
      DatatableCol(key: 'cidade', title: 'Cidade'),
      DatatableCol(key: 'status', title: 'Status'),
      DatatableCol(key: 'saldo', title: 'Saldo'),
    ],
  );

  final List<Map<String, dynamic>> selectOptions = List<Map<String, dynamic>>.generate(
    selectOptionCount,
    (i) => <String, dynamic>{'id': i, 'label': 'Cidade $i - Municipio de exemplo'},
  );

  final List<LiDropdownMenuOption> menuOptions = List<LiDropdownMenuOption>.generate(
    menuOptionCount,
    (i) => LiDropdownMenuOption(value: 'v$i', label: 'Item de menu $i'),
  );

  void renderRows() {
    final items = List<Map<String, dynamic>>.generate(
      rowTarget,
      (i) => <String, dynamic>{
        'id': i + 1,
        'nome': 'Pessoa ${i + 1} da Silva',
        'email': 'pessoa${i + 1}@exemplo.gov.br',
        'cidade': 'Cidade ${i % 92}',
        'status': i.isEven ? 'Ativo' : 'Inativo',
        'saldo': ((i * 37) % 10000) / 100,
      },
    );
    data = DataFrame<Map<String, dynamic>>(items: items, totalRecords: rowTarget);
  }

  void clearRows() {
    data = DataFrame<Map<String, dynamic>>(items: <Map<String, dynamic>>[], totalRecords: 0);
  }
}
