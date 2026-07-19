# Manual ngdart 8: change detection, bindings e componentes de alta performance

Este manual complementa as instruções gerais do projeto para código AngularDart/ngdart 8. Ele foi escrito a partir da leitura de:

- `package:ngx_dart/angular.dart`
- `src/meta/lifecycle_hooks.dart`
- `src/meta/change_detection_constants.dart`
- `src/meta/directives.dart`
- `src/runtime/check_binding.dart`
- `src/core/linker/views/view.dart`
- `src/core/linker/views/component_view.dart`
- `src/core/linker/views/host_view.dart`
- `src/core/linker/view_ref.dart`
- `src/core/zone/ng_zone.dart`

## Regra central: binding deve ser estável

Em modo dev, o ngdart executa uma verificação extra para garantir que uma expressão de template não mudou durante o mesmo ciclo de change detection. O erro:

```text
An expression bound in an AngularDart template returned a different value the second time it was evaluated.
Expression has changed after it was checked.
```

acontece quando o valor de uma expressão muda entre a primeira avaliação e a verificação de estabilidade do mesmo ciclo.

Evite no template qualquer expressão que possa mudar enquanto a view está sendo criada, medida, projetada ou atualizada:

```html
<!-- Evitar -->
<processo-header [canPrintSelectedAnexo]="timelineTab?.canPrintSelectedAnexo == true">
</processo-header>
```

Use campos estáveis atualizados por eventos explícitos:

```dart
bool canPrintSelectedAnexo = false;

void showAnexo(ProcessoAnexo anexo) {
  isShowAnexo = true;
  canPrintSelectedAnexo = true;
  canPrintSelectedDespacho = false;
}
```

```html
<processo-header [canPrintSelectedAnexo]="canPrintSelectedAnexo">
</processo-header>
```

## Não chame métodos no template para cálculo

Métodos chamados por binding são reexecutados a cada ciclo. Isso pesa e pode retornar outro valor sem intenção.

Evite:

```html
<button [disabled]="calcularDisabled(item)">
  {{ labelDinamico(item) }}
</button>
```

Prefira preparar view models ou campos:

```dart
class ProcessoActionVm {
  final String label;
  final bool disabled;
  const ProcessoActionVm({required this.label, required this.disabled});
}
```

```html
<button [disabled]="action.disabled">
  {{ action.label }}
</button>
```

Para listas grandes, não use getters que criam lista:

```dart
// Evitar em binding/*ngFor
List<Item> get itensVisiveis => itens.where((i) => i.visible).toList();
```

Use campo cacheado:

```dart
List<Item> itensVisiveis = const [];

void rebuildItensVisiveis() {
  itensVisiveis = itens.where((i) => i.visible).toList();
}
```

## Lifecycle correto no ngdart 8

A ordem documentada no pacote é:

1. `ngAfterChanges`
2. `ngOnInit`
3. `ngDoCheck`
4. `ngAfterContentInit`
5. `ngAfterContentChecked`
6. `ngAfterViewInit`
7. `ngAfterViewChecked`
8. `ngOnDestroy`

No ngdart 8, use `AfterChanges`, não `OnChanges`.

```dart
class MeuComponente implements AfterChanges, OnDestroy {
  @Input()
  Processo processo = Processo.invalido();

  String? _lastKey;

  @override
  void ngAfterChanges() {
    final key = '${processo.codProcesso}/${processo.anoExercicio}';
    if (key == _lastKey || processo.codProcesso <= 0) return;
    _lastKey = key;
    _recarregar();
  }

  @override
  void ngOnDestroy() {}
}
```

Não existe `AfterViewChange`. Os hooks corretos de view são `AfterViewInit` e `AfterViewChecked`.

## `AfterChanges` é para reagir a `@Input`

Use `ngAfterChanges()` quando o componente depende de `@Input()` e precisa recarregar estado ao receber novo processo, filtro, id ou seleção.

Não use `ngOnInit()` para ler valores que dependem de rota ou de `@Input()` que pode mudar depois.

Em componentes usados por rotas (`OnActivate`), leia `RouterState` em `onActivate()`, não em `ngOnInit()`.

## Cuidado com `DoCheck`

`DoCheck` roda em toda checagem e substitui o detector padrão para inputs mutáveis. A própria documentação avisa:

- não dispare evento assíncrono em `ngDoCheck`;
- não implemente `DoCheck` junto com `AfterChanges`, porque `ngAfterChanges()` não será chamado.

No SALI, use `DoCheck` só para diretivas muito específicas e com justificativa clara. Para componentes de tela, prefira inputs imutáveis, campos cacheados e `AfterChanges`.

## `ViewChild` e `ViewChildren`

`ViewChild` e `ViewChildren` são preenchidos antes de `ngAfterViewInit()` e podem ser atualizados antes de `ngAfterViewChecked()`.

Não use `@ViewChild` diretamente em binding de template do pai, porque a criação do filho pode mudar o valor no mesmo ciclo.

Evite:

```dart
@ViewChild('timeline')
ProcessoTimelineTabComponent? timeline;

bool get canPrint => timeline?.canPrintSelectedAnexo == true;
```

```html
<processo-header [canPrint]="canPrint"></processo-header>
```

Prefira:

- o componente filho emitir estado por `@Output`;
- ou o pai atualizar campos estáveis nos handlers que selecionam item;
- ou o filho receber toda a responsabilidade da ação.

Para ser notificado quando uma query muda, prefira setter:

```dart
@ViewChildren('item')
set itemElements(List<html.Element> value) {
  _itemElements = value;
}
```

## Atualizações depois da renderização

Quando for necessário executar algo depois de uma alteração observada pelo Angular, prefira `NgZone.runAfterChangesObserved()` em vez de `Timer.run`, `Future` ou `scheduleMicrotask`.

```dart
class MeuComponente {
  final NgZone _zone;

  MeuComponente(this._zone);

  void selecionar() {
    selecionado = true;
    _zone.runAfterChangesObserved(() {
      _scrollParaSelecionado();
    });
  }
}
```

Use `Timer(Duration.zero, ...)` apenas quando já for padrão local ou quando não houver `NgZone` disponível. Cancele timers no `ngOnDestroy()`.

## `OnPush` com cuidado

`ChangeDetectionStrategy.onPush` só verifica o componente quando:

- um `@Input()` muda de identidade;
- um `@Output()` ou evento de template roda no componente ou descendente;
- `ChangeDetectorRef.markForCheck()` é chamado no componente ou descendente.

Use `OnPush` apenas quando:

- inputs são tratados como imutáveis;
- listas são substituídas por nova instância quando mudam;
- callbacks assíncronos chamam `markForCheck()` quando necessário;
- não há filho `checkAlways` dependente de update implícito sob um pai `onPush`.

Não aplique `OnPush` em telas grandes sem antes extrair componentes menores e stores explícitas.

## Componentes autocontidos

Componentes de tela devem possuir a regra visual e o estado local da sua própria área:

- filtros;
- paginação;
- loading;
- estado de colapso;
- lista cacheada;
- labels e opções de UI;
- eventos para o container.

O container da página deve compor:

- rota;
- processo base;
- seleção global;
- modais globais;
- URL;
- ações globais.

Evite página “deus” com árvore, timeline, PDF, URL, filtros, modais e autorização misturados.

## Outputs

Para `@Output`, use `StreamController.broadcast()` quando o evento pode ter múltiplos ouvintes ou seguir padrão dos componentes do projeto.

Sempre feche no `ngOnDestroy()`:

```dart
final _abrirCtrl = StreamController<TramiteProcesso>.broadcast();

@Output()
Stream<TramiteProcesso> get abrir => _abrirCtrl.stream;

@override
void ngOnDestroy() {
  _abrirCtrl.close();
}
```

## Buscas remotas e filtros seletivos

Em telas com paginação remota, lazy loading, timeline, árvore, datatable ou processo com muitos itens, a busca deve ser seletiva e previsível.

Evite expor **Todos os campos** quando o backend não tiver índice full-text específico para isso. Esse tipo de busca normalmente vira uma combinação de múltiplos `OR`, concatenações, `ILIKE`, `unaccent` e casts, reduzindo a seletividade e dificultando uso eficiente de índices.

Prefira sempre:

- um campo de busca explícito por vez;
- opções de campo compatíveis com índices ou colunas bem delimitadas;
- busca por ID usando igualdade, não `LIKE`;
- texto livre disparado por botão de lupa ou Enter;
- `limit` máximo no backend;
- `offset`/cursor controlado pelo componente;
- filtro de período aplicado no servidor;
- `DataFrame.totalRecords` preservado no frontend.

Exemplo de contrato preferido:

```dart
final filtros = SaliFilters(
  limit: 400,
  offset: 0,
  campoBuscaArvoreProcesso: 'setor',
);

void onCampoBuscaChange(String? value) {
  filtros
    ..campoBuscaArvoreProcesso = value ?? 'setor'
    ..offset = 0;
}

void buscar() {
  filtros
    ..searchString = textoBusca.trim().isEmpty ? null : textoBusca.trim()
    ..offset = 0;
  loadItens(forceReload: true);
}
```

Quando uma opção geral for realmente necessária, ela deve ser outro produto técnico: índice de busca textual, tabela materializada, trigram ou serviço de busca. Não implemente busca geral operacional apenas concatenando vários campos em cada consulta de tela.

## Requisições assíncronas e estado obsoleto

Componentes autocontidos podem carregar dados em `ngAfterChanges()`, mas precisam evitar requisições duplicadas ou respostas antigas sobrescrevendo estado novo.

Em páginas com múltiplas ações assíncronas independentes, como carregar resumo, carregar detalhamento, carregar permanência e gerar PDF, não use uma única instância global de `SimpleLoading`. Crie uma instância local dentro de cada método assíncrono, chame `show()` no `try` e `hide()` no `finally`, para uma operação não esconder ou prender o loader de outra.

Classes, componentes, services, repositories, DTOs e métodos públicos devem ter Dartdoc objetivo. Para fluxos privados relevantes (`_filtrosPara...`, `_rebuild...`, `_extrair...`) também documente a intenção quando o nome não deixar a regra completa evidente. Não use `// ignore_for_file: public_member_api_docs` como solução para código novo.

Use uma chave estável do input:

```dart
String? _lastProcessoKey;

@override
void ngAfterChanges() {
  final key = '${processo.codProcesso}/${processo.anoExercicio}';
  if (key == _lastProcessoKey || processo.codProcesso <= 0) return;
  _lastProcessoKey = key;
  filtros.offset = 0;
  scheduleMicrotask(() => loadItens(forceReload: true));
}
```

Para buscas digitadas e filtros rápidos, use um contador de requisição quando houver risco de respostas fora de ordem:

```dart
int _requestSeq = 0;

Future<void> loadItens({bool forceReload = false}) async {
  final requestId = ++_requestSeq;
  final data = await service.all(filtros);
  if (requestId != _requestSeq) return;
  dataFrame = data;
}
```

Não atualize campos observados pelo template em `AfterViewChecked` para corrigir estado visual. Se precisar reagir a medição de DOM, agende a atualização para depois do ciclo e cancele o agendamento em `ngOnDestroy()`.

## Listas, datatables e DataFrame

Para listagens grandes, não mantenha listas paralelas duplicando `DataFrame.items` se não houver transformação real. Use diretamente o `DataFrame<T>` quando a tela é uma listagem comum.

Quando houver transformação de domínio para view model, faça a conversão uma vez por resposta e armazene em campo estável:

```dart
DataFrame<ArvoreProcessoItem> dataFrame = DataFrame.newClear();
List<TramiteProcesso> tramites = const [];

Future<void> load() async {
  dataFrame = await service.getArvoreProcesso(...);
  tramites = dataFrame.items.map(mapper.toTramite).toList();
}
```

Evite no template:

```html
<li *ngFor="let item of dataFrame.items.where(filtro).toList()">
</li>
```

Prepare antes:

```dart
List<TramiteProcesso> itensVisiveis = const [];

void rebuildItensVisiveis() {
  itensVisiveis = tramites.where((item) => item.isVisible).toList();
}
```

Em datatables remotas no SALI:

- mantenha `SaliFilters` como estado direto do componente;
- deixe o evento `(dataRequest)` chamar o método de carga;
- atribua a resposta diretamente ao `DataFrame<T>`;
- não clone filtros sem necessidade;
- não exporte/ordene/filtre localmente uma lista gigante se a tabela é remota.

## Dropdowns e componentes de UI

Opções de dropdown devem ser constantes ou campos estáveis. Não crie opções com getter que monta lista nova a cada ciclo.

Prefira:

```dart
static const List<li.LiDropdownMenuOption> campoOptions =
    <li.LiDropdownMenuOption>[
  li.LiDropdownMenuOption(value: 'setor', label: 'Setor'),
  li.LiDropdownMenuOption(value: 'id_despacho', label: 'ID do despacho'),
];
```

Se o componente de UI exige `String`, não faça binding de `String?` sem valor padrão:

```dart
String get campoBuscaValue => filtros.campoBuscaArvoreProcesso ?? 'setor';
```

Ao abrir ou fechar dropdowns, modais e offcanvas, cuidado com eventos síncronos do componente filho. Se o mesmo handler muda estado renderizado no template, agende a abertura/fechamento ou mova a regra para o componente dono do overlay.

## Templates de alta performance

No template:

- use campos simples em bindings;
- use `*ngIf` com booleanos estáveis;
- use `*ngFor` sobre listas estáveis;
- evite criar objetos, listas ou strings complexas;
- evite chamadas de método por item;
- não leia DOM, `matchMedia`, `ResizeObserver` ou `ViewChild` por getter no binding;
- não derive label de dropdown, status de botão ou contagem por getter que percorre lista;
- não altere estado observado em hook `AfterViewChecked` sem agendar para depois;
- não abra/feche modal/offcanvas no mesmo handler que muda vários bindings se o overlay emitir eventos sincronamente.

## Composição SOLID em páginas grandes

Página de rota deve ser container, não dona de toda regra visual. Para telas grandes:

- a página lê rota, carrega o processo base e conecta eventos globais;
- cada aba carrega seus dados locais quando isso reduz acoplamento;
- componentes de aba possuem filtros, paginação, loading, colapsos e listas cacheadas;
- serviços/facades cuidam de URL, autorização, impressão, PDF e seleção quando a regra é compartilhada;
- view models carregam labels, ícones, classes CSS e flags prontas para o template.

Sinal de alerta: se a página possui estado de árvore, timeline, preview, modais, PDF, autorização e filtros ao mesmo tempo, extraia um componente ou serviço. A meta é que cada componente tenha uma razão clara para mudar.

## CSS e encapsulamento

Com `ViewEncapsulation.emulated`, CSS do pai não deve ser usado para controlar estrutura interna do filho.

Quando extrair componente, leve junto:

- layout flex;
- `:host`;
- `height/min-height`;
- scroll container;
- estados visuais internos.

Exemplo para componente projetado em área com altura:

```scss
:host {
  display: block;
  height: 100%;
  min-height: 0;
  min-width: 0;
  overflow: hidden;
}

.content {
  display: flex;
  height: 100%;
  min-height: 0;
}

.scroll {
  flex: 1 1 auto;
  min-height: 0;
  overflow-y: auto;
}
```

## Checklist antes de finalizar componente ngdart

- `dart analyze` sem erros.
- Nenhum getter usado pelo template cria lista, map ou objeto novo.
- Nenhum binding lê `@ViewChild` que pode ser criado no mesmo ciclo.
- Nenhuma busca remota operacional usa **Todos os campos** sem índice full-text próprio.
- Busca textual remota é disparada por ação explícita ou debounce justificado, nunca por request direto a cada tecla.
- Dropdowns expõem valores não nulos quando o componente exige `String`.
- `AfterChanges` usado para reagir a `@Input`.
- `DoCheck` não usado sem necessidade extrema.
- `StreamController`, `Timer`, `StreamSubscription` e observers são limpos em `ngOnDestroy`.
- Componentes filhos carregam seu próprio estado local quando isso reduz responsabilidade da página.
- CSS estrutural do componente está no SCSS do próprio componente, não no pai.
