# Construindo uma Aplicação Full Stack Profissional em Dart com AngularDart, `limitless_ui`, `essential_core` e `shelf`

Este guia mostra como desenhar e construir uma aplicação full stack séria em Dart usando:

- `ngdart: 8.0.0-dev.4`
- `ngforms: 5.0.0-dev.3`
- `ngrouter: 4.0.0-dev.3`
- `ngtest: ^5.0.0-dev.3`
- `build_runner: ^2.4.12`
- `build_test: ^2.2.2`
- `build_web_compilers: ^4.0.11`
- `limitless_ui`
- `essential_core: ^1.2.0`
- `shelf` no backend
- opcionalmente `shelf_router`, `shelf_cors_headers`, `eloquent` e `get_it`

A arquitetura recomendada aqui segue a mesma direção prática um monorepo com um pacote `core` compartilhado, um frontend AngularDart e um backend `shelf` modular capaz de escalar com múltiplos isolates.

Este não é um setup de demonstração simples. O objetivo é uma estrutura que consiga suportar módulos CRUD reais, DTOs e filtros reutilizáveis, guards de rota e middleware de autenticação, testes de browser e testes de integração no backend, deploy em produção com múltiplos isolates e manutenção de longo prazo.

Observação importante de terminologia: em servidores Dart, "multithread" normalmente significa **multi-isolate**. Isolates Dart não compartilham memória da mesma forma que threads nativas do sistema operacional. Esse é o modelo mental correto para backend escalável em Dart.

## Validação declarativa de formulários no `limitless_ui`

Para formulários AngularDart com `limitless_ui`, a direção recomendada agora é concentrar as validações simples e repetitivas no próprio componente, em vez de espalhar `invalid`, `errorText`, `class.is-invalid` e helpers manuais por toda a página.

Os blocos principais dessa API são:

- `liType`: preset de alto nível para `li-input`, útil para casos comuns como `cpf`, `email`, `phone` e `requiredText`.
- `liRules`: regras declarativas compostas por `LiRule.required()`, `LiRule.minLength(...)`, `LiRule.cpf()`, `LiRule.custom(...)` e outras.
- `liMessages`: sobrescrita por código de regra, como `required`, `cpf`, `requiredTrue` e `minLength`.
- `liValidationMode`: controla quando o erro aparece, com modos como `dirty`, `touchedOrDirty`, `submitted`, `submittedOrTouched` e `submittedOrTouchedOrDirty`. O padrão do pacote é `submittedOrTouchedOrDirty`.

### Regras e mensagens são campos do componente, não literais no template

Antes dos exemplos, uma restrição do AngularDart que define a forma correta de usar essa API: **expressões de template não aceitam literais de lista nem de mapa**. Escrever `[liRules]="[LiRule.required()]"` ou `[liMessages]="{'required': 'Informe o CPF.'}"` não compila — o compilador de templates rejeita com `Parser Error: ListLiteralImpl: Not a subset of supported Dart expressions` e `SetOrMapLiteralImpl: ...`. Closures dentro do template, como `LiRule.custom((value) => ...)`, caem na mesma regra.

Declare as regras e as mensagens como campos do componente e faça o binding pelo nome. Além de ser o único jeito que compila, isso segue a orientação geral de manter código Dart fora do template e mantém as listas com identidade estável entre ciclos de change detection.

Os construtores de regra são `const factory`, então listas fixas podem ser `static const`. A exceção é `LiRule.custom(...)`, que recebe um callback e por isso não é const: use `static final`.

Exemplo com `li-input`:

```html
<li-input
    label="CPF"
    liType="cpf"
    [liMessages]="cpfMessages"
    liValidationMode="submitted"
    [(ngModel)]="person.cpf">
</li-input>
```

```dart
static const Map<String, String> cpfMessages = <String, String>{
  'required': 'Informe o CPF.',
  'cpf': 'Digite um CPF válido.',
};
```

Exemplo com selects e seleção múltipla:

```html
<li-select
    [dataSource]="departments"
    labelKey="label"
    valueKey="id"
    [liRules]="departmentRules"
    [liMessages]="departmentMessages"
    liValidationMode="submitted"
    [(ngModel)]="person.departmentId">
</li-select>

<li-multi-select
    [dataSource]="channels"
    labelKey="label"
    valueKey="id"
    [liRules]="channelRules"
    liValidationMode="submitted"
    [(ngModel)]="person.channelIds">
</li-multi-select>
```

```dart
static const List<LiRule> departmentRules = <LiRule>[LiRule.required()];

static const Map<String, String> departmentMessages = <String, String>{
  'required': 'Escolha um departamento.',
};

// LiRule.custom recebe um callback, então não é const.
static final List<LiRule> channelRules = <LiRule>[
  LiRule.custom(
    (value) => value is Iterable && value.length >= 2
        ? null
        : 'Selecione ao menos 2 canais.',
  ),
];
```

Exemplo com checkbox e rádio:

```html
<li-checkbox
    label="Aceito os termos"
    [required]="true"
    [liMessages]="termsMessages"
    liValidationMode="submitted"
    [(ngModel)]="acceptedTerms">
</li-checkbox>

<li-radio-group
    [legend]="approvalLegend"
    [value]="approvalMode"
    [liRules]="approvalRules"
    [liMessages]="approvalMessages"
    liValidationMode="submitted">
  ...
</li-radio-group>
```

```dart
static const Map<String, String> termsMessages = <String, String>{
  'requiredTrue': 'Confirme o aceite.',
};

static const List<LiRule> approvalRules = <LiRule>[LiRule.required()];

static const Map<String, String> approvalMessages = <String, String>{
  'required': 'Selecione um modo de aprovação.',
};
```

Essa mesma base também vale para `li-date-picker`, `li-time-picker` e `li-file-upload`, com a vantagem de manter a precedência antiga:

- `invalid`, `dataInvalid` e `errorText` externos continuam tendo prioridade;
- `required`, `minLength`, `maxLength`, `pattern` e `validator` legado ainda funcionam onde já existiam;
- regras declarativas entram para reduzir verbosidade e centralizar mensagens.

Quando o formulário é maior, combine os campos com `liForm`:

```html
<form liForm #ui="liForm">
  <li-input liType="cpf" [(ngModel)]="person.cpf"></li-input>
  <li-select [liRules]="departmentRules" [(ngModel)]="person.departmentId"></li-select>
</form>
```

```dart
final isValid = await ui.validateAndFocusFirstInvalid();
```

Esse fluxo é o ponto de equilíbrio recomendado no projeto:

- regras universais ficam nos componentes;
- regras contextuais continuam na página ou no serviço;
- erros de backend ainda podem sobrescrever a mensagem final do campo.

## Componentes novos do `limitless_ui` em `1.0.0-dev.22`

Além da camada de formulários declarativos, a versão `1.0.0-dev.22` expandiu o pacote com quatro superfícies importantes: um campo de senha com máscara controlada em Dart, um visualizador de PDF genérico com PDF.js, um editor rico isolado baseado em Quill `2.0.3` e um helper fullscreen imperativo para fluxos longos com mensagens narradas.

### `li-password-input`

`li-password-input` mantém o mesmo contrato de `[(ngModel)]`, validação declarativa e eventos de campo usados por `li-input`, mas renderiza sobre `type="text"` com máscara controlada em Dart. O objetivo é reduzir o impacto de autofill agressivo e de alguns password managers, sem perder o toggle integrado de revelar ou ocultar senha.

Quando usar:

- fluxos de assinatura, confirmação ou credencial temporária em que o host quer mais previsibilidade que um `<input type="password">` puro;
- telas que já usam `liRules`, `liMessages` e `liValidationMode` e precisam da mesma ergonomia no campo de senha.

Exemplo:

```html
<li-password-input
  label="Senha de assinatura"
  helperText="Mascara controlada em Dart para reduzir autofill agressivo"
  autocomplete="new-password"
  [(ngModel)]="signaturePassword">
</li-password-input>
```

Inputs mais relevantes:

- `showPasswordLabel`, `hidePasswordLabel` e `maskChar` para a experiência visual;
- `autocomplete`, `dataLpignore`, `data1pIgnore` e `dataBwignore` para integração com navegadores e password managers;
- `liType`, `liRules`, `liMessages`, `liValidationMode`, `invalid` e `errorText` para validação.

### `li-pdf-viewer`

`li-pdf-viewer` é um visualizador genérico de PDF baseado em PDF.js. Ele foi mantido fora do barrel principal para que aplicações possam importar só o slice de PDF quando quiserem uma dependência mais estreita:

```dart
import 'package:limitless_ui/pdf_viewer.dart';
```

O componente aceita `bytes` ou `url`, expõe ações padrão de navegação e arquivo, e também pontos de extensão para toolbar e painel lateral via API Dart ou template projetado.

Exemplo básico:

```html
<script src="assets/js/pdf.js/5.4.149/build/pdf.export.js" type="module"></script>

<div style="height: 72vh;">
  <li-pdf-viewer
    [bytes]="documentBytes"
    title="Release briefing"
    pdfJsBasePath="assets/js/pdf.js/5.4.149">
  </li-pdf-viewer>
</div>
```

Capacidades principais:

- carregamento por `bytes` ou `url`;
- zoom, paginação, fit width, rotação, pan mode, fullscreen, download e print;
- `LiPdfViewerLabels.portuguese` e `LiPdfViewerLabels.english`, além de `defaultLiPdfViewerZoomOptionsPt` e `defaultLiPdfViewerZoomOptions`;
- `customToolbarActions`, `<template liPdfViewerToolbarActions>` e `<template liPdfViewerSidePanel>` para encaixar ações e conteúdo de negócio sem acoplar o componente;
- APIs como `extractPageText(...)`, `extractDocumentText(...)`, `getPageInfo(...)` e `getAllPageInfo(...)` para inspeção e leitura estruturada do documento.

### `li-quill-text-editor`

`li-quill-text-editor` é um editor rico isolado baseado em Quill `2.0.3`, também publicado em barrel separado:

```dart
import 'package:limitless_ui/quill_text_editor.dart';
```

Ele mantém integração com `[(ngModel)]` via `ControlValueAccessor`, permite configurar toolbar por itens, ações Dart e template projetado, e adiciona uma opção de performance para adiar a propagação do modelo até blur quando o host preferir.

Exemplo básico:

```html
<script src="assets/js/quill/2.0.3/quill.js"></script>
<script src="assets/js/quill_table_better/1.2.3/quill_table_better.js"></script>

<li-quill-text-editor
  [(ngModel)]="htmlValue"
  [labels]="editorLabels"
  [updateModelOnBlur]="true"
  minHeight="20rem">
</li-quill-text-editor>
```

Capacidades principais:

- toolbar configurável via `toolbarItems`, `toolbarActions` e `<template liQuillTextEditorToolbarActions>`;
- presets localizados com `LiQuillTextEditorLabels.portuguese` e `LiQuillTextEditorLabels.english`;
- suporte opcional a tabelas com `enableTableSupport`, `enableTableButton` e `tableMenus`;
- APIs `getHtml()`, `getPlainText()`, `getDeltaJson()`, `setDeltaJson(...)`, `format(...)` e `insertTextAtSelection(...)`;
- opção `updateModelOnBlur` para reduzir a frequência de atualização de `ngModel` em telas pesadas.

### Empilhamento e uso correto dos helpers de loading

`LiSimpleLoading.defaultBodyZIndex` (500000, overlay de tela cheia) e
`defaultTargetZIndex` (50000, overlay preso a um elemento) passaram a ser
`static int` mutáveis. Isso existe para adoção sem risco: uma aplicação que já
tem uma escala de empilhamento própria alinha a lib uma vez no `main()`, sem
encostar em nenhuma chamada.

```dart
void main() {
  // Adota a lib com o comportamento idêntico ao que a tela já tinha.
  LiSimpleLoading.defaultTargetZIndex = 500000;
  // Acima de um alerta próprio que fica em 500100.
  LiNarratedFullScreenLoading.defaultZIndex = 500200;
  runApp(...);
}
```

`LiNarratedFullScreenLoading.defaultZIndex` acompanha
`LiSimpleLoading.defaultBodyZIndex + 1` dinamicamente enquanto não for
atribuído, então mover o overlay simples arrasta o narrado junto em qualquer
ordem de inicialização; `resetDefaultZIndex()` volta a derivar. Como valor
padrão de parâmetro precisa ser constante, o `zIndex` de `showOnBody` virou
opcional — passar um valor explícito continua funcionando.

**Um detalhe que parece estilo mas não é:** `show()` chama `hide()` antes de
montar. Isso não é idempotência de API, é liberação de recurso. `show()` aloca
três `StreamSubscription` e um `ResizeObserver` em campos e reatribui `_root`;
um segundo `show()` sem `hide()` sobrescreve esses campos, os listeners antigos
nunca são cancelados e o `_root` anterior fica órfão no DOM — sem nenhuma
referência capaz de removê-lo. O resultado não é um bug visível, é uma cortina
de z-index 500000 presa na tela.

Para quem quer a convenção "um `hide()` para cada `show()`" sem abrir mão dessa
limpeza, existe `LiSimpleLoading.debugAssertSingleShow`:

```dart
LiSimpleLoading.debugAssertSingleShow = true;
```

Ligada, mostrar sobre um overlay já visível dispara `AssertionError` — que só
roda em desenvolvimento, então o custo em release é zero e a contabilidade
continua valendo. Desligada por padrão de propósito: remostrar é legítimo, dois
carregamentos sobrepostos na mesma tabela chamam `show()` os dois, e
`LiDataTableComponent.showLoading()` é exatamente esse caso.

`LiSimpleLoading.isVisible` expõe o estado, útil em teste e em automação. E os
overlays carregam `class="li-simple-loading"` com
`data-li-simple-loading="true"` (o narrado usa
`data-li-narrated-full-screen-loading`), o que dá um seletor estável para
esperar o loading sumir — bem melhor que varrer `querySelectorAll('div')`
comparando z-index computado, que quebra silenciosamente assim que o valor muda.

### Rolagem de um `li-modal`: o diálogo inteiro ou só o corpo

São dois comportamentos distintos e a escolha é uma linha:

- **Sem `dialogScrollable`** (padrão): o diálogo cresce com o conteúdo e quem
  rola é o overlay `.modal`, levando o cabeçalho junto. É o que a maioria das
  telas quer.
- **Com `[dialogScrollable]="true"`**: o tema prende o `.modal-content` em
  `max-height: 100%` e a rolagem passa a ser interna ao `.modal-body`, com o
  cabeçalho fixo no topo.

A armadilha está no segundo caso. O `.modal-body` só ganha altura limitada
sendo **filho flex direto** do `.modal-content` — é de lá que vem o
`flex: 1 1 auto`. Declarar um `<div class="modal-body">` próprio dentro do
conteúdo projetado casa o seletor `.modal-dialog-scrollable .modal-body` e
recebe o `overflow-y: auto`, mas com altura livre: não há o que rolar, e o
`overflow: hidden` do `.modal-content` apenas corta o excesso. O sintoma engana,
porque só aparece quando o conteúdo cresce — uma tabela de cinco linhas cabe, o
mesmo datatable em modo grade não.

Se precisar de rolagem interna, deixe o `#modalBody` do próprio `li-modal` ser o
`.modal-body` (é o padrão, `enableModalBodyClass` já vem `true`) e projete o
conteúdo direto. Use `[enableModalBodyClass]="false"` quando o conteúdo já traz
o próprio espaçamento e o padding do corpo sobraria — mas aí não recrie um
`.modal-body` por dentro.

### `LiNarratedFullScreenLoading`

`LiNarratedFullScreenLoading` é um helper imperativo para fluxos mais longos no navegador, quando a aplicação precisa de uma overlay fullscreen com mensagens rotativas de status. Ele é exportado pelo barrel principal `package:limitless_ui/limitless_ui.dart`, então pode ser usado ao lado de `LiSimpleLoading` e `LiSimpleDialogComponent` sem uma superfície extra de import.

```dart
import 'package:limitless_ui/limitless_ui.dart';

final loading = LiNarratedFullScreenLoading.pdfGeneration(
  title: 'Gerando PDF',
  messages: const <String>[
    'Preparando estrutura do documento...',
    'Renderizando paginas...',
    'Finalizando metadados...',
  ],
);

loading.showOnBody();

// ... execute a tarefa assincrona ...

loading.updateMessage('Enviando arquivo final...', stopRotation: true);

// ... finalize a tarefa ...

loading.hide();
```

Comportamentos mais relevantes:

- `showOnBody()` monta a overlay no `body` do documento e a mantem acima da pilha de `li-modal` por padrao;
- `pdfGeneration()` oferece uma factory pronta para fluxos orientados a geracao de PDF;
- `updateMessage(..., stopRotation: true)` fixa a mensagem atual e interrompe o timer de rotacao automatica;
- `hide()` remove a overlay e libera o timer interno.

A pagina de helpers no example inclui tanto uma demo standalone quanto uma demo acionada de dentro de `li-modal`, para validar visualmente o comportamento da pilha de overlays.

## Eventos de abertura e carregamento sob demanda em `1.0.0-dev.36`

Até a `1.0.0-dev.35` não havia como saber que um select ou um picker tinha aberto. Isso empurrava as telas para um padrão caro: carregar a lista de opções no `ngOnInit`, mesmo quando o usuário talvez nunca abrisse aquele campo. Em telas com vários lookups, isso é a maior parte do payload inicial — e boa parte dele nunca é usada.

A `1.0.0-dev.36` fecha essa lacuna com três APIs complementares.

### `openChange`: saber que abriu

`openChange` é um `Stream<bool>` que emite `true` ao abrir e `false` ao fechar. Está disponível em `li-select`, `li-multi-select`, `li-treeview-select`, `li-tag-filter`, `li-datatable-select`, `li-date-picker`, `li-date-range-picker` e `li-time-picker`. O `li-color-picker` é anterior a essa convenção e expõe o mesmo estado pelos seus `pickerShow`/`pickerHide`.

Só transições reais são emitidas: reabrir um dropdown já aberto não emite de novo, e fechar um já fechado também não — o que importa, porque caminhos como selecionar uma opção ou apertar Escape chamam `closeDropdown()` sem saber o estado atual. Nada é emitido durante a destruição do componente, então quem segura o componente por um `ViewChild` e assina o stream direto não recebe um `false` espúrio no teardown.

O uso principal é adiar a busca da lista:

```html
<li-select
  [dataSource]="classificacoes"
  labelKey="descricao"
  valueKey="id"
  (openChange)="aoAbrirClassificacoes($event)"
  [(ngModel)]="filtros.codClassificacao">
</li-select>
```

```dart
bool _classificacoesCarregadas = false;

Future<void> aoAbrirClassificacoes(bool aberto) async {
  if (!aberto || _classificacoesCarregadas) {
    return;
  }
  _classificacoesCarregadas = true;
  classificacoes = await _service.listarClassificacoes();
}
```

A guarda de "já carregou" fica no host de propósito: a lib não decide política de cache. Se a tela quiser recarregar a cada abertura, basta remover a guarda.

### `beforeOpen`: vetar a abertura

`li-select` e `li-multi-select` também emitem `beforeOpen` imediatamente antes de abrir, com o dropdown ainda fechado. Chamar `preventDefault()` no evento mantém o dropdown fechado e suprime o `openChange` correspondente:

```html
<li-select
  [dataSource]="cidades"
  (beforeOpen)="exigirEstadoAntes($event)"
  [(ngModel)]="endereco.cidadeId">
</li-select>
```

```dart
void exigirEstadoAntes(LiBeforeOpenEvent event) {
  if (endereco.estadoId == null) {
    event.preventDefault();
    _toastService.warning('Selecione o estado primeiro.');
  }
}
```

O evento segue o mesmo formato cancelável que o `liNav` já usava no `LiNavChangeEvent`, e, como ele, o stream é **síncrono**. Isso tem uma consequência prática que vale memorizar: `preventDefault()` precisa ser chamado dentro do próprio handler. Depois de um `await` ele roda tarde demais — o dropdown já abriu, e o veto passa despercebido. Para condicionar a abertura a um trabalho assíncrono, previna o default, faça o trabalho e chame `openDropdown()` quando ele resolver.

### `requestDataOnOpen`: o caso do `li-datatable-select`

O `li-datatable-select` merece atenção separada. O modal interno dele já renderiza o conteúdo de forma lazy, então o datatable só nasce quando o modal abre — mas nasce mudo: ele só emite `dataRequest` em ação do usuário (paginar, ordenar, buscar), nunca ao ser criado. Uma tela que simplesmente parasse de adiantar a lista abriria um modal vazio até o usuário digitar algo.

O `requestDataOnOpen` resolve isso fazendo o componente emitir `dataRequest` com o `dataTableFilter` atual na primeira abertura:

```html
<li-datatable-select
  [settings]="settings"
  [dataTableFilter]="filtro"
  [data]="usuarios"
  [requestDataOnOpen]="true"
  (dataRequest)="carregarUsuarios($event)"
  [(ngModel)]="form.numcgmResponsavel">
</li-datatable-select>
```

Como o evento carrega o `Filters` correto, o handler que já existia para paginação e busca serve sem mudança. Só a primeira abertura emite; reabrir mantém os dados já carregados. Para recarregar a cada abertura, use `openChange`.

### `li-modal`: o `open` como primitiva

Por baixo dos dois casos acima está o `li-modal`, que agora expõe `open` além do `close` que já tinha. Como o `lazyContent` só cria o conteúdo projetado quando o modal abre, o `open` é o primeiro momento em que dá para carregar dados para esse conteúdo:

```html
<li-modal #modalEncaminhar
    title-text="Encaminhar"
    size="xtra-large"
    [lazyContent]="true"
    (open)="carregarHierarquia()">
  <dropdown-organograma [(ngModel)]="destino"></dropdown-organograma>
</li-modal>
```

Vale um cuidado ao adotar `lazyContent` num modal que já existe: o conteúdo é destruído ao fechar e recriado a cada abertura. Um `@ViewChild` que aponte para dentro do modal fica nulo enquanto ele está fechado, e qualquer busca feita no `ngOnInit` do conteúdo passa a rodar a cada abertura.

## O loop de layout do datatable em `1.0.0-dev.41`

A tela **Protocolo > Acompanhamento Especial** do SALI travava com zoom em 110%: a tabela piscava sem parar, cerca de 30 redesenhos por segundo, e a página ficava inutilizável. Em 100% e em 125% não acontecia nada.

### O ciclo

O `li-datatable` com `[responsiveAutoHideColumns]="true"` mede o espaço disponível a cada desenho e esconde a coluna de menor prioridade quando as colunas não cabem. O desenho seguinte mede de novo, e é aí que o ciclo se fecha:

1. As colunas passam do espaço disponível por poucos pixels. O auto-hide esconde uma.
2. Sem essa coluna a tabela encurta. A página encurta junto e a **barra de rolagem vertical some**.
3. Sem a barra, o container ganha os ~16px que ela ocupava. Agora todas as colunas cabem.
4. O auto-hide devolve a coluna escondida. A tabela cresce, a barra volta, e o passo 1 recomeça.

Não é preciso evento nenhum para manter isso vivo: cada desenho do datatable agenda duas passagens de medição (`postRenderSync` e `responsiveAutoHideSync`), e cada medição diferente da anterior agenda outro desenho. A corrente se alimenta sozinha, frame a frame.

O ciclo só existe numa faixa estreita — quando a sobra das colunas é **menor que a largura da barra de rolagem**. Com muita sobra as colunas ficam escondidas nos dois estados; com folga, cabem nos dois. Foi por isso que só o zoom de 110% mostrou o problema: ele colocou a tela exatamente nessa faixa. Na página de exemplo, a faixa vai de 632px a 640px de container; fora dela o layout converge sozinho.

### A correção

Três camadas, da causa para a rede de segurança.

**1. Histerese no auto-hide.** O limiar deixou de ser simétrico: a coluna some assim que estoura o espaço, mas só volta quando sobram `DatatableResponsiveController.autoHideRestoreMargin` (24px). Como a barra de rolagem devolve ~16px, esse ganho sozinho não desfaz mais a decisão — e o ciclo não fecha.

```dart
// datatable_responsive_controller.dart
final fitWidth = _autoHiddenColumnKeys.isEmpty
    ? availableWidth
    : _restoreThreshold(availableWidth); // availableWidth - 24
```

A margem nunca passa de metade do container, senão num container muito estreito ela comeria o orçamento inteiro e esconderia tudo.

**2. Largura medida estável.** `getBoundingClientRect().width` oscila nas últimas casas decimais com zoom fracionário (110%, 125%), e a comparação era `!=` entre doubles — cada frame parecia um layout novo e forçava um redesenho. A largura passou a ser arredondada, e diferenças abaixo de meio pixel devolvem o valor anterior em vez de um novo, para a referência não escorregar meio pixel por frame até cruzar o limiar.

**3. Guarda de reflow.** Depois de 8 redesenhos responsivos seguidos — contados dentro de uma janela de 1s, porque um frame parado no meio de um loop não é convergência — o datatable para de medir e mantém o último layout. Só um evento de verdade religa: `resize` da janela, `data` ou `settings` novos, troca de modo grid, uma coluna ligada/desligada à mão, ou o próprio container mudando de largura. É a rede de segurança: nenhum arranjo de CSS trava mais a tela, mesmo que apareça um ciclo que a histerese não cubra.

O guarda emite `responsiveReflow.suspended`, `responsiveReflow.containerChanged` e `responsiveReflow.resumed` no stream de instrumentação (`[debugInstrumentation]="true"`), então dá para ver quando ele age.

### O container passou a ser observado

O `resize` da janela não cobre um container que muda de tamanho sozinho — uma sidebar recolhendo, um card mudando, a barra de rolagem da página aparecendo. Antes o datatable só remedia depois de um desenho, então um container que encolheu ficava com as colunas erradas até algo mais provocar um redesenho. E enquanto o guarda segurava a corrente nada era desenhado, logo nada era medido: a tabela podia ficar parada no layout errado.

Agora um `ResizeObserver` acompanha o container. Duas armadilhas apareceram no caminho, e as duas estão cobertas por teste:

**O alvo não pode ser o host.** `li-datatable` é um custom element sem `display` próprio — nem o SCSS do componente nem o `all.css` do tema declaram um —, então ele computa `inline`, e um `ResizeObserver` não reporta nada para uma caixa inline não substituída. Ele ficaria mudo. Quem é observado é o container de rolagem, que é bloco e é exatamente o elemento que a medição lê. Como o `*ngIf` troca os viewports de tabela e grid, o alvo é reconferido depois de cada desenho.

**A zona.** O `dart:html` monta o `ResizeObserver` com `convertDartClosureToJS` e **sem** `_wrapZone`, ao contrário de todos os streams de evento que ele expõe. O callback chega na zona raiz, fora do Angular, onde `markForCheck` não marca nada. Pior: `requestAnimationFrame` captura a `Zone.current` no momento em que é chamado, então um frame agendado de dentro do callback herdaria a zona errada também. A zona é capturada na criação do observer, onde ainda é a do Angular, e o trabalho é devolvido para dentro dela com `runGuarded`.

```dart
final angularZone = Zone.current;
_containerResizeObserver = ResizeObserver(
  (List<dynamic> entries, ResizeObserver observer) {
    angularZone.runGuarded(_scheduleContainerResizeSync);
  },
);
```

Mudanças só de altura são descartadas — linhas expandindo, conteúdo chegando, nada disso muda quais colunas cabem — e as entregas do observer são juntadas em uma medição por frame.

### Como as colunas passaram a ser medidas

Duas descobertas de campo mudaram a medição de largura do auto-hide.

**Medir a tabela renderizada não funciona.** Uma coluna escondida não está no layout — medi-la ali dá zero, e zero entra no cálculo como "não ocupa espaço", devolvendo a coluna cedo demais e trazendo rolagem horizontal. Já uma coluna visível, com vizinhas escondidas, estica para preencher o vão — medi-la ali infla o total, e o auto-hide passa a esconder colunas que cabiam (era o que comia uma coluna a cada troca de aba). Não existe momento em que a tabela renderizada mostre todas as colunas no tamanho mínimo delas.

A solução é a mesma do DataTables Responsive (`_resizeAuto`): clonar a tabela, devolver todas as colunas ao fluxo, e medir o clone dentro de um contêiner de 1×1px com `overflow: hidden` e `width: auto` — sem espaço para esticar, cada coluna encolhe até o mínimo que o conteúdo permite, e todas são lidas na mesma passada, no mesmo estado. Dois detalhes deram trabalho:

- Esconder uma coluna aplica **três** classes (`hide`, `datatable-mobile-hidden`, `dtr-hidden`). Remover só a primeira deixava as outras segurando o `display: none`, e a coluna media zero do mesmo jeito.
- O clone precisa perder as classes do modo colapsado (`collapsed`, `dtr-inline`): ele representa o estado com tudo visível, que por definição não é o colapsado — e mantê-las trazia junto o `nowrap` do tema, quase dobrando o total medido.

**O tema proíbe quebrar linha no celular.** O `all.css` traz, nos breakpoints dele (576/768/992px), `white-space: nowrap` para toda célula de `.datatable-scroll` — é o padrão Limitless de "no celular a tabela rola na horizontal". O modo responsivo faz o oposto: quebra, esconde por prioridade e nunca rola. Com o `nowrap` do tema valendo, cada coluna media o texto inteiro numa linha, o auto-hide concluía que quase nada cabia e desabava para uma ou duas colunas com espaço sobrando ao lado — 5 colunas em 810px viravam 2 em 710px, exatamente ao cruzar o breakpoint de 768.

Agora o container de rolagem carrega `datatable-scroll--responsive` sempre que auto-hide ou collapse estão ligados, e o stylesheet do componente restaura o `white-space: normal` ali. O `nowrap` por coluna (`DatatableCol.nowrap`) é estilo inline e não é afetado; o layout fixo com reticências continua valendo; e quem usa o datatable no padrão do tema, com rolagem horizontal, não muda nada. Medido na página de exemplo, o salto 5→2 virou 5→4→3, sem barra de rolagem horizontal em nenhuma das doze larguras varridas.

Uma nota sobre um sintoma que **não** é bug: trocar de aba (ou de página) pode deslocar as colunas alguns pixels mesmo com o mesmo cabeçalho. É o `table-layout: auto` — a distribuição de largura depende do conteúdo de todas as linhas visíveis, e conjuntos de linhas diferentes assentam diferente. Medido na mesma aba, só trocando de página: `assunto` foi de 148.1px para 142.3px.

### Os dois mecanismos responsivos, e qual mede o quê

Vale saber que são dois, porque eles respondem a perguntas diferentes:

| | pergunta | mede |
|---|---|---|
| `responsiveAutoHideColumns` | "as colunas cabem?" | o container |
| `responsiveCollapse` | "estou no mobile?" | a janela (`window.innerWidth`) |

O auto-hide sempre mediu o container, e agora é avisado por `ResizeObserver`. O collapse — o modo que faz sumir as colunas marcadas com `hideOnMobile` — decide por `window.innerWidth` contra `responsiveCollapseMaxWidth`.

A diferença aparece quando o datatable tem menos espaço do que a janela sugere: dentro de um modal estreito, numa coluna de grid, ou com a sidebar da aplicação aberta. Numa tela de 1920px com o container em 1350px, o `innerWidth` continua 1920 e o collapse não ativa, mesmo com a tabela apertada. As colunas que o auto-hide esconde continuam virando detalhe da linha normalmente — nada de informação se perde —, mas o `hideOnMobile` não é honrado.

Quem decide é a aplicação, com `responsiveCollapseByContainer`:

```html
<li-datatable
    [responsiveCollapse]="true"
    [responsiveCollapseByContainer]="true"
    [responsiveCollapseContainerMaxWidth]="991"
    [responsiveAutoHideColumns]="true">
</li-datatable>
```

Com ele ligado, o collapse passa a olhar o mesmo espaço que o auto-hide olha. O flag é opt-in de propósito: as duas leituras são legítimas — uma tela que ocupa a página inteira quer mesmo o breakpoint da janela — e trocar o padrão mudaria o layout de quem já usa a biblioteca.

### Do lado da aplicação: `scrollbar-gutter`

Vale matar a causa na origem. `scrollbar-gutter: stable` no `html` reserva o espaço da barra de rolagem para sempre, então ela aparecer ou sumir deixa de mexer na largura de tudo que está na página:

```css
html {
    scrollbar-gutter: stable;
}
```

Isso não substitui a histerese — o container muda de tamanho por outros motivos, e a biblioteca não manda no CSS de quem a usa —, mas elimina o gatilho concreto que travou a tela do SALI. É uma linha, e hoje tem suporte amplo.

### Onde ver funcionando

A página **Loop de layout** do app de exemplo (`example/lib/src/pages/datatable_layout_loop/`) replica a tela do SALI — abas, card, paginação, os mesmos inputs de responsividade — e fecha o mesmo ciclo com um controle de largura e um interruptor que simula a barra de rolagem. Os contadores mostram redesenhos por segundo, mudanças de auto-hide e quais colunas estão escondidas.

Medido nela, com o navegador em `deviceScaleFactor` 1.1 e o container em 636px: **90 redesenhos em 3s antes da correção, 0 depois**. `ui_test/e2e/datatable_layout_loop_test.dart` verifica isso no navegador de verdade.

## Datatable responsivo, colunas fixadas e menus em `1.0.0-dev.40`

O `li-datatable` já recolhia colunas em telas estreitas, mas três detalhes do modo responsivo só apareciam no uso real em celular — e um deles vinha do jeito como o tema Limitless declara suas variáveis.

### Onde fica o controle de expandir

Quando colunas são recolhidas, o datatable precisa colocar o controle de expandir (o triângulo) em alguma célula visível da linha. A regra antiga preferia a primeira coluna marcada com `responsiveAutoHideRequired` — e o `DatatableActionColumn` marca isso como `true` por padrão, justamente para que as ações nunca sumam no auto-hide.

O efeito colateral era ruim: em toda tabela montada com a coluna de ações declarativa, o controle caía **na célula de ações**. Como cada botão de ação chama `stopPropagation()` no clique, a única parte da célula que ainda abria a linha era a tirinha de padding onde o triângulo é desenhado — poucos pixels, encostados nos botões. No celular era quase impossível acertar sem disparar uma ação por engano.

A regra agora é a mesma do `inline` do DataTables: **primeira coluna visível**, pulando as que se declaram inelegíveis pelo novo `DatatableCol.responsiveControlEligible`:

```dart
/// Se a coluna pode hospedar o controle de expandir.
///
/// Colunas cheias de conteúdo interativo — a de ações acima de tudo — saem
/// dessa disputa para o controle nunca dividir área de toque com um botão.
bool responsiveControlEligible = true;
```

O `DatatableActionColumn` passa `false`. Com isso o controle cai numa célula de dados (tipicamente o número do processo), e a largura inteira dela vira área de toque. Quem quiser escolher a dedo continua com o `DatatableSettings.responsiveControlColumnKey`, que tem prioridade sobre tudo.

### `responsiveControlMode`: uma coluna só para o controle

Dividir a célula com o conteúdo resolve o caso comum, mas não todos: se a primeira coluna também tiver um link ou um badge clicável, a disputa volta. Para isso existe o `DatatableResponsiveControlMode.column`, equivalente ao `responsive.details.type: 'column'` do DataTables:

```dart
DatatableSettings(
  colsDefinitions: colunas,
  responsiveControlMode: DatatableResponsiveControlMode.column,
);
```

O datatable passa a renderizar uma coluna dedicada, **antes do checkbox de seleção**, com uma área de toque de 2.75rem (3rem no mobile) centrada na célula. A coluna só existe enquanto há algo recolhido, então no desktop a tabela mantém a largura inteira; o `colspan` da linha de detalhes e os espaçadores do virtual scroll já contam com ela.

A célula mantém o `role` nativo de `cell` — como o DataTables faz — e é alcançável por teclado (`tabindex="0"`, Enter/Espaço), com `aria-expanded` e um nome acessível vindo de dois inputs novos:

```html
<li-datatable
  [settings]="settings"
  [data]="dados"
  expandRowDetailsLabel="Mostrar os demais dados da linha"
  collapseRowDetailsLabel="Ocultar os demais dados da linha">
</li-datatable>
```

### `responsiveDetailsTrigger`: quem abre o detalhe

Por padrão só o controle abre a linha de detalhes, o que deixa o clique no resto da linha livre para o `onRowClick` da tela — abrir o registro, por exemplo. Quando a tela não usa o clique na linha para nada, dá para transformar a linha inteira em área de toque:

```dart
DatatableSettings(
  colsDefinitions: colunas,
  responsiveDetailsTrigger: DatatableResponsiveDetailsTrigger.row,
);
```

Os dois modos convivem com o `onRowClick`: em `row`, uma linha **sem** colunas recolhidas continua emitindo `onRowClick` normalmente, então o comportamento no desktop não muda — só a linha recolhida troca o clique pela expansão. O cursor de ponteiro aparece mesmo com `disableRowClick` ligado, porque expandir continua disponível.

Os dois modos são independentes: dá para usar a coluna dedicada com `control` (o controle é o único jeito de abrir, e o clique na linha fica para a tela) ou com `row` (a coluna dedicada é só um alvo mais visível, e a linha toda também abre).

### O fundo cinza atrás da coluna fixada

Uma célula fixada (`fixedPosition`) precisa de fundo opaco para tapar as colunas que passam por baixo dela na rolagem horizontal. Esse fundo era chutado assim:

```css
background-color: var(--card-bg, var(--body-bg, #fff));
```

O chute funciona dentro de um card e falha em todo o resto. O tema Limitless declara `--card-bg` **dentro da própria regra `.card`**, não no `:root`:

```css
.card {
    --card-bg: var(--white);
    /* ... */
}
```

Ou seja: a variável só existe no escopo de um `.card`. Uma tabela dentro de um `li-modal` não tem `.card` como ancestral, a cadeia cai no `--body-bg` — que é `#f1f4f9` no tema claro — e a coluna fixada pinta o cinza da página por cima do branco do modal. O mesmo vale para o `--modal-bg`, que é escopado em `.modal`, e para qualquer outra superfície que o tema resolva por variável escopada.

Por isso a correção não troca uma variável por outra: o datatable sobe do container de rolagem até o primeiro ancestral que **realmente pinta** um fundo e publica a cor em `--li-datatable-sticky-bg`, usada pelas colunas fixadas e pelo header sticky. Ler a cor pintada é o que faz isso seguir o tema em vez de adivinhar: dá `--card-bg` dentro de um card, `--modal-bg` dentro de um modal, a cor de um `.bg-light` onde ele for usado, e os valores de modo escuro de todos eles — sem o datatable precisar saber em que superfície foi solto.

Para forçar uma cor específica, basta definir a variável:

```css
.minha-tela li-datatable {
    --li-datatable-sticky-bg: var(--card-bg);
}
```

### Menus que não cabem na tela

O menu de visibilidade de colunas, o de exportação e o de ações da linha são portados para o `body` quando abrem, e nada limitava a altura deles: numa tela baixa o menu passava da borda e as entradas de fora ficavam inalcançáveis — o caso relatado foi o botão "Exibir tudo" da lista de colunas parando acima do topo da janela.

Os três agora são ajustados ao espaço disponível ao lado do gatilho e rolam por dentro. O menu de ações da linha também ganhou fallback de posicionamento (estava preso em `bottom-end`, sem virar para cima) e empilhamento ciente de modal, então não abre mais atrás do modal que contém a tabela.

### Abrir um overlay agora fecha os outros

O caso relatado foi a lista de colunas e o menu de ações de uma linha ficando na tela ao mesmo tempo, mas o problema valia para **todos** os overlays da lib.

Todos detectavam clique-fora na fase de *bubble*. Um gatilho que chama `stopPropagation()` no próprio clique fica, portanto, invisível para qualquer overlay já aberto — e os dois menus do datatable fazem isso, o de ações porque o clique não pode virar clique de linha. Resultado: nada fechava nada.

A detecção passou a ser feita por um helper único, `listenOutsideClick`, que assina na fase de **captura**. A captura percorre documento → alvo antes do bubble, então o clique é visto independentemente do que o alvo faça com a propagação depois:

```dart
StreamSubscription<html.MouseEvent> listenOutsideClick(
  void Function(html.MouseEvent event) onClick,
) {
  return const html.EventStreamProvider<html.MouseEvent>('click')
      .forTarget(html.document, useCapture: true)
      .listen(onClick);
}
```

Alcança `li-select`, `li-multi-select` (pelo `liClickOutside`), `li-treeview-select`, `li-tag-filter`, `li-typeahead`, `li-dropdown-menu`, `liDropdown` e seus submenus, `li-date-picker`, `li-date-range-picker`, `li-time-picker`, `li-color-picker`, `li-popover`, `li-tooltip`, `li-simple-popover`, o popover do sweet alert e os menus do próprio datatable.

Clicar no próprio gatilho ou painel continua igual: todo handler já começava perguntando "o clique foi dentro de mim?", então rodar antes do alvo não muda o resultado — alternar pelo gatilho continua alternando, em vez de fechar e reabrir.

O ajuste de altura vale para todos os overlays da lib:

O ajuste de altura vale para todos os overlays da lib: o `constrainOverlayHeightToViewport` se auto-cancelava uma passada de layout depois de aplicar — media a altura **já limitada**, concluía que o painel cabia e removia o limite, deixando-o transbordar de novo. Isso afetava `li-color-picker`, `li-date-picker`, `li-date-range-picker` e `li-time-picker` sempre que o painel não tinha altura fixa em CSS. A altura natural agora vem do `scrollHeight` do elemento quando ele é maior, então a decisão é estável entre passadas.

### Onde ver funcionando

Na página `Dados > Datatable` do app de exemplo, no acordeão "Ações via DatatableActionColumn (Dart)", há um switch para o `responsiveControlMode` e outro para o `responsiveDetailsTrigger` — dá para estreitar a janela e alternar os dois ao vivo. O acordeão "Colunas fixadas dentro de um modal" mostra a coluna fixada sobre o fundo do modal.

## 1. O que você está construindo

O sistema alvo tem três pacotes:

```text
my_app/
  backend/
  frontend/
  core/
```

Cada pacote tem um propósito claro:

- `core`: contratos compartilhados, DTOs, helpers de serialização, filtros genéricos, objetos de resposta tabular, exceções compartilhadas e modelos reutilizáveis de baixo nível.
- `frontend`: aplicação web AngularDart usando `limitless_ui` e `essential_core`.
- `backend`: API REST com `shelf`, registro de rotas, middleware, acesso a banco, autenticação e bootstrap para produção.

Essa separação resolve um problema comum em projetos full stack: frontend e backend se desalinharem quando contratos de request e response são duplicados manualmente. Com um `core` compartilhado, os mesmos tipos podem ser reutilizados nas duas camadas.

## 2. Por que esse stack é forte

Esse stack é uma boa escolha quando você quer:

- uma única linguagem no sistema inteiro;
- contratos de request e response fortemente tipados;
- separação limpa entre transporte, lógica de domínio e persistência;
- um frontend baseado em componentes com widgets reais de negócio;
- um backend explícito e fácil de depurar, sem esconder demais o comportamento atrás de magia de framework.

O que cada peça entrega:

- `ngdart`: arquitetura de componentes no estilo Angular para Dart no navegador.
- `ngforms`: formulários e value accessors no AngularDart.
- `ngrouter`: definições de rota, navegação e guards.
- `limitless_ui`: UI reutilizável de aplicação como datatables, selects, typeahead, modais, tabs, toasts, wizards, paginação e mais.
- `essential_core`: modelos genéricos reutilizáveis como `Filters`, `DataFrame<T>` e contratos compartilhados de baixo nível.
- `shelf`: uma camada HTTP pequena e explícita.
- `shelf_router`: mapeamento organizado de rotas.
- `eloquent`: camada de queries SQL quando você quer um query builder ao estilo Laravel em Dart.
- `get_it`: injeção de dependência pragmática e registro de serviços.

O resultado é um stack que continua compreensível mesmo quando a aplicação cresce.

## 3. Estrutura de monorepo recomendada

Comece com este layout:

```text
my_app/
  backend/
    bin/
    lib/
    test/
    pubspec.yaml
  frontend/
    web/
    lib/
    test/
    build.yaml
    dart_test.yaml
    pubspec.yaml
  core/
    lib/
    test/
    pubspec.yaml
```

À medida que a aplicação crescer, evolua para:

```text
my_app/
  backend/
    bin/server.dart
    lib/src/
      shared/
        app_config.dart
        bootstrap.dart
        routes.dart
        middleware/
        di/
        extensions/
      modules/
        projects/
          projects_routes.dart
          controllers/
          repositories/
          services/
        users/
          users_routes.dart
          controllers/
          repositories/
          services/
    test/
  frontend/
    web/
      main.dart
      index.html
      style.scss
    lib/src/
      app/
      routes/
      shared/
        di/
        services/
        guards/
        components/
        pipes/
        directives/
      modules/
        dashboard/
        projects/
        users/
    test/
  core/
    lib/
      src/
        dto/
        models/
        filters/
        exceptions/
        utils/
      core.dart
    test/
```

Esse layout mapeia bem fronteiras de responsabilidade e escala com pouca fricção.

## 4. Setup dos pacotes passo a passo

Crie os três pacotes e conecte-os corretamente.

Ordem recomendada:

1. Crie primeiro `core`.
2. Adicione DTOs e filtros compartilhados.
3. Crie `backend` e faça-o depender de `core`.
4. Crie `frontend` e faça-o depender de `core`, `limitless_ui` e `essential_core`.
5. Implemente um slice vertical completo antes de expandir para mais módulos.

O primeiro slice vertical vale mais do que scaffoldar dez módulos vazios. Um slice como `projects` ou `users` força você a validar o formato dos DTOs compartilhados, o design das rotas do backend, a API do repositório, o design dos services do frontend, a integração do roteamento AngularDart, a composição de página com `limitless_ui` e a estratégia de testes.

## 5. Desenhando o pacote compartilhado `core`

O pacote `core` compartilhado é uma das decisões estruturais mais importantes dessa arquitetura.

Ele deve conter:

- DTOs que trafegam por HTTP;
- modelos de domínio leves e seguros para frontend e backend;
- contratos de serialização;
- erros tipados de API;
- filtros reutilizáveis;
- wrappers de resposta paginada ou tabular;
- utilitários que não dependam exclusivamente de navegador ou servidor.

Ele não deve conter:

- `dart:html`;
- `dart:io`;
- código direto de banco de dados;
- componentes AngularDart;
- objetos `Request` ou `Response` do `shelf`;
- configuração exclusiva do backend ou helpers exclusivos do browser.

Exemplo de `core/pubspec.yaml`:

```yaml
name: my_app_core
description: Contratos compartilhados entre frontend e backend.
version: 1.0.0

environment:
  sdk: ^3.6.0

dependencies:
  essential_core: ^1.2.0

dev_dependencies:
  test: ^1.25.9
```

Exemplo de DTO:

```dart
class ProjectDto {
  final int? id;
  final String name;
  final String status;
  final DateTime? createdAt;

  ProjectDto({
    this.id,
    required this.name,
    required this.status,
    this.createdAt,
  });

  factory ProjectDto.fromMap(Map<String, dynamic> map) {
    return ProjectDto(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      status: map['status'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };
}
```

Exemplo de erro tipado:

```dart
class ApiProblem {
  final int status;
  final String title;
  final String detail;

  ApiProblem({
    required this.status,
    required this.title,
    required this.detail,
  });

  factory ApiProblem.fromMap(Map<String, dynamic> map) {
    return ApiProblem(
      status: map['status'] as int? ?? 500,
      title: map['title'] as String? ?? 'Erro inesperado',
      detail: map['detail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'title': title,
        'detail': detail,
      };
}
```

Exemplo de barrel export:

```dart
library my_app_core;

export 'src/dto/project_dto.dart';
export 'src/exceptions/api_problem.dart';
```

## 6. Setup do pacote frontend

Exemplo de `frontend/pubspec.yaml`:

```yaml
name: my_app_frontend
publish_to: none

environment:
  sdk: ^3.6.0

dependencies:
  ngdart: 8.0.0-dev.4
  ngforms: 5.0.0-dev.3
  ngrouter: 4.0.0-dev.3
  limitless_ui: ^1.0.0-dev.10
  essential_core: ^1.2.0
  my_app_core:
    path: ../core

dev_dependencies:
  build_runner: ^2.4.12
  build_test: ^2.2.2
  build_web_compilers: ^4.0.11
  ngtest: ^5.0.0-dev.3
  test: ^1.25.9
  sass_builder: ^2.2.1
```

Se você estiver desenvolvendo com um checkout local do `limitless_ui`:

```yaml
dependencies:
  limitless_ui:
    path: ../limitless_ui
```

Por que essas dependências ficam assim:

- pacotes de runtime AngularDart ficam em `dependencies`;
- ferramentas de build e teste do browser ficam em `dev_dependencies`;
- `sass_builder` permanece como dependência de desenvolvimento da aplicação raiz porque o app compila o próprio Sass.

## 7. Entry point do frontend e app raiz

Entry point mínimo:

```dart
import 'package:ngdart/angular.dart';
import 'package:my_app_frontend/src/app/app_component.template.dart' as ng;

void main() {
  runApp(ng.AppComponentNgFactory);
}
```

Se você precisar de locale global, DI ou configuração de app, faça isso aqui antes do `runApp`.

Exemplo com inicialização de locale:

```dart
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ngdart/angular.dart';
import 'package:my_app_frontend/src/app/app_component.template.dart' as ng;
import 'package:my_app_frontend/src/shared/di/di.dart';

Future<void> main() async {
  await initializeDateFormatting('pt_BR');
  Intl.defaultLocale = 'pt_BR';
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
```

Componente raiz:

```dart
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:my_app_frontend/src/routes/app_routes.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  styleUrls: ['app_component.css'],
  directives: [coreDirectives, RouterOutlet],
  exports: [AppRoutes],
)
class AppComponent {}
```

Template:

```html
<router-outlet [routes]="AppRoutes.all"></router-outlet>
```

Isso é propositalmente pequeno. Mantenha o componente raiz fino e mova a UI real para páginas de rota ou componentes de shell.

## 8. Roteamento AngularDart para aplicações reais

Para aplicações AngularDart não triviais, use objetos `RouteDefinition` explícitos e factories geradas.

Exemplo de registro de rotas:

```dart
import 'package:ngrouter/ngrouter.dart';
import 'package:my_app_frontend/src/pages/dashboard/dashboard_page.template.dart'
    as dashboard_template;
import 'package:my_app_frontend/src/pages/projects/projects_page.template.dart'
    as projects_template;
import 'package:my_app_frontend/src/pages/not_found/not_found_page.template.dart'
    as not_found_template;

class AppRoutes {
  static final dashboard = RouteDefinition(
    routePath: RoutePath(path: 'dashboard'),
    component: dashboard_template.DashboardPageNgFactory,
    useAsDefault: true,
  );

  static final projects = RouteDefinition(
    routePath: RoutePath(path: 'projects'),
    component: projects_template.ProjectsPageNgFactory,
  );

  static final notFound = RouteDefinition(
    routePath: RoutePath(path: 'not-found'),
    component: not_found_template.NotFoundPageNgFactory,
  );

  static final all = <RouteDefinition>[
    dashboard,
    projects,
    notFound,
    RouteDefinition.redirect(path: '.+', redirectTo: 'not-found'),
  ];
}
```

Por que esse padrão é melhor:

- a responsabilidade das rotas fica explícita;
- factories geradas em build permanecem visíveis e depuráveis;
- aplicações grandes conseguem segmentar mapas de rota por módulo;
- o padrão funciona bem com guards e shells de rota aninhados.

## 9. Injeção de dependência no frontend

À medida que a aplicação cresce, não instancie services manualmente dentro dos componentes. Use DI do AngularDart ou um injector de aplicação.

Responsabilidades típicas da DI no frontend:

- cliente da API;
- service de autenticação;
- services por feature;
- route hooks;
- config de aplicação.

Exemplo de injector:

```dart
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:my_app_frontend/src/shared/guards/auth_guard.dart';
import 'package:my_app_frontend/src/shared/services/api_client.dart';
import 'package:my_app_frontend/src/modules/projects/services/project_service.dart';

@GenerateInjector([
  ClassProvider(ApiClient),
  ClassProvider(ProjectService),
  ClassProvider(RouterHook, useClass: AuthGuard),
])
final InjectorFactory injector = self.injector$Injector;
```

## 10. Estilização e Sass no AngularDart

Componentes AngularDart devem apontar para arquivos `.css` gerados em `styleUrls`, mesmo quando a fonte real é `.scss`.

Exemplo:

```dart
@Component(
  selector: 'projects-page',
  templateUrl: 'projects_page.html',
  styleUrls: ['projects_page.css'],
)
class ProjectsPage {}
```

Arquivo real no disco:

```text
projects_page.scss
```

O AngularDart consome CSS em tempo de compilação do componente. `sass_builder` gera o CSS a partir do SCSS. Usar `.scss` diretamente em `styleUrls` é o padrão errado para esse toolchain.

Exemplo de `frontend/build.yaml`:

```yaml
targets:
  $default:
    builders:
      ngdart:
        generate_for:
          exclude:
            - "web/assets/**"
            - "web/scrollbar.css"
```

## 11. Construindo UI séria com `limitless_ui`

`limitless_ui` fica mais valioso quando você o trata como um toolkit de aplicação, e não como uma coleção solta de widgets.

Padrões comuns:

- `li-datatable` para páginas de listagem;
- `li-select`, `li-multi-select` e `li-typeahead` para formulários;
- `li-color-picker` para configurações de cor, branding e aparência;
- `li-modal` ou `li-offcanvas` para fluxos de edição;
- `li-toast` e `LiToastService` para feedback;
- `li-pagination` e `Filters` para dados paginados;
- `openChange`, `beforeOpen` e `requestDataOnOpen` para carregar listas de lookup só quando o campo é aberto, em vez de no `ngOnInit` da tela.

Ao documentar ou apresentar essa camada de UI, prefira o nome real do componente, `li-color-picker`. Ele pode ser inspirado por interações clássicas de color picker, mas a API pública e o comportamento pertencem ao `limitless_ui`.

Exemplo de componente de página:

```dart
import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:my_app_core/my_app_core.dart';
import 'package:my_app_frontend/src/modules/projects/services/project_service.dart';

@Component(
  selector: 'projects-page',
  templateUrl: 'projects_page.html',
  styleUrls: ['projects_page.css'],
  directives: [coreDirectives, LiDatatableComponent],
)
class ProjectsPage implements OnInit {
  final ProjectService _service;

  ProjectsPage(this._service);

  final Filters filters = Filters(limit: 10, offset: 0);

  late final DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'name', title: 'Name', sortingBy: 'name', enableSorting: true),
      DatatableCol(key: 'status', title: 'Status', sortingBy: 'status', enableSorting: true),
    ],
  );

  DataFrame<ProjectDto> frame = DataFrame<ProjectDto>(
    data: const [],
    totalRecords: 0,
  );

  bool loading = false;
  String? errorMessage;

  @override
  Future<void> ngOnInit() async {
    await load();
  }

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    try {
      frame = await _service.list(filters);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
    }
  }
}
```

## 12. Design do cliente de API no frontend

Não deixe componentes chamarem `http.get` diretamente. Centralize as regras de transporte.

Seu cliente de API normalmente deve cuidar de:

- construção da URL base;
- headers de autenticação;
- decodificação de JSON;
- conversão de erros em tipos consistentes;
- requests multipart quando necessário.

Exemplo de cliente base:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app_core/my_app_core.dart';

class ApiClient {
  final String baseUrl;

  ApiClient(this.baseUrl);

  Uri uri(String path, {Map<String, dynamic>? queryParameters}) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (k, v) => MapEntry(k, v?.toString()),
      ),
    );
  }

  Future<Map<String, String>> authHeaders() async {
    return {'Content-Type': 'application/json'};
  }

  Never _throwForError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        throw ApiProblem.fromMap(decoded);
      }
    } catch (_) {}

    throw ApiProblem(
      status: response.statusCode,
      title: 'Erro HTTP',
      detail: response.body,
    );
  }

  Future<dynamic> getJson(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await http.get(
      uri(path, queryParameters: queryParameters),
      headers: await authHeaders(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    _throwForError(response);
  }
}
```

Service por feature:

```dart
import 'package:essential_core/essential_core.dart';
import 'package:my_app_core/my_app_core.dart';
import 'package:my_app_frontend/src/shared/services/api_client.dart';

class ProjectService {
  final ApiClient _api;

  ProjectService(this._api);

  Future<DataFrame<ProjectDto>> list(Filters filters) async {
    final json = await _api.getJson(
      '/api/projects',
      queryParameters: filters.getParams(),
    );
    return DataFrame<ProjectDto>.fromMapWithFactory(
      json,
      (map) => ProjectDto.fromMap(map),
    );
  }
}
```

## 13. Setup do pacote backend

Exemplo de `backend/pubspec.yaml`:

```yaml
name: my_app_backend
publish_to: none

environment:
  sdk: ^3.6.0

dependencies:
  shelf: ^1.4.1
  shelf_router: ^1.1.4
  shelf_cors_headers: ^0.1.5
  eloquent: ^3.4.3
  get_it: ^8.0.3
  essential_core: ^1.2.0
  my_app_core:
    path: ../core

dev_dependencies:
  test: ^1.25.9
```

`shelf` não impõe uma estrutura pesada, então você precisa definir a estrutura correta por conta própria. Quando isso é feito direito, vira vantagem.

## 14. Inicialização do backend e bootstrap multi-isolate

Essa estrutura de backend mostra a direção correta para um servidor Dart pronto para produção:

- parse de argumentos de linha de comando;
- configuração da aplicação uma vez por isolate;
- spawn de múltiplos isolates quando desejado;
- uso de `shared: true` para todos escutarem na mesma porta;
- estado compartilhado mantido fora da memória do processo.

Exemplo de `bin/server.dart`:

```dart
import 'package:args/args.dart';
import 'package:my_app_backend/src/shared/bootstrap.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('address', abbr: 'a', defaultsTo: '0.0.0.0')
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('isolates', abbr: 'j', defaultsTo: '1');

  final parsed = parser.parse(args);

  await configureServer(
    parsed['address'] as String,
    int.parse(parsed['port'] as String),
    int.parse(parsed['isolates'] as String),
  );
}
```

## 15. Design do pipeline de middleware

Uma aplicação `shelf` profissional deve empurrar comportamento transversal para middleware, em vez de duplicá-lo em controllers.

Preocupações típicas de middleware:

- log de request;
- CORS;
- mapeamento de exceção para response;
- autenticação;
- injeção de conexão com banco.

Exemplo de middleware de exceção:

```dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:my_app_core/my_app_core.dart';

Middleware exceptionMiddleware() {
  return (innerHandler) {
    return (request) async {
      try {
        return await innerHandler(request);
      } on ApiProblem catch (e) {
        return Response(
          e.status,
          body: jsonEncode(e.toMap()),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        final problem = ApiProblem(
          status: 500,
          title: 'Erro interno do servidor',
          detail: e.toString(),
        );
        return Response.internalServerError(
          body: jsonEncode(problem.toMap()),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}
```

## 16. Modularização de rotas

Não coloque a API inteira em um único arquivo de rotas.

Layout recomendado:

```text
backend/lib/src/
  shared/
    routes.dart
  modules/
    projects/
      projects_routes.dart
      controllers/project_controller.dart
      repositories/project_repository.dart
```

Registro de rotas no topo:

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:my_app_backend/src/modules/projects/projects_routes.dart';

void registerRoutes(Router app) {
  app.get('/', (Request request) => Response.ok('my_app'));
  app.mount('/api/projects', projectsRoutes());
}
```

## 17. Injeção de dependências no backend

Usar `get_it` aqui é uma escolha pragmática e eficiente para um backend Dart modular.

Exemplo:

```dart
import 'package:eloquent/eloquent.dart';
import 'package:get_it/get_it.dart';
import 'package:my_app_backend/src/db/database_service.dart';
import 'package:my_app_backend/src/modules/projects/repositories/project_repository.dart';

final ioc = GetIt.instance;

void setupDependencies() {
  if (!ioc.isRegistered<DatabaseService>()) {
    ioc.registerSingleton(DatabaseService());
  }

  if (!ioc.isRegistered<ProjectRepository>()) {
    ioc.registerFactory<ProjectRepository>(
      () => ProjectRepository(ioc<Connection>()),
    );
  }
}
```

Regra importante em ambiente multi-isolate: cada isolate tem seu próprio estado de registro, conexões e services.

## 18. Acesso a banco com `eloquent`

`eloquent` é útil quando você quer aplicações de negócio baseadas em SQL, um query builder em vez de SQL montado à mão, fronteiras explícitas de repositório e pooling de conexão em um único lugar.

Exemplo de repositório:

```dart
import 'package:eloquent/eloquent.dart';
import 'package:my_app_core/my_app_core.dart';

class ProjectRepository {
  final Connection connection;

  ProjectRepository(this.connection);

  Future<List<ProjectDto>> findAll() async {
    final rows = await connection.table('projects').get();
    return rows
        .map((row) => ProjectDto.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }
}
```

## 19. Fluxo de request ponta a ponta

Uma forma saudável de raciocinar sobre o sistema é seguir um request completo:

1. O usuário abre `/projects` no app AngularDart.
2. O router do AngularDart ativa `ProjectsPage`.
3. `ProjectsPage` chama `ProjectService.list(filters)`.
4. `ProjectService` usa o cliente de API compartilhado.
5. O cliente envia `GET /api/projects`.
6. O pipeline `shelf` recebe a request.
7. Os middlewares são executados.
8. O router despacha para a rota da feature.
9. O controller invoca o repositório.
10. O repositório consulta o banco.
11. A response JSON volta para o browser.
12. O AngularDart faz o bind do resultado em `li-datatable`.

## 20. Estratégia de testes

Você precisa de camadas de teste diferentes para riscos diferentes.

### `core`

Teste DTOs, filtros, utilitários e erros compartilhados.

### Frontend

Teste componentes AngularDart com `ngtest`, comportamento de browser com `build_runner test` e interações de rota e formulário.

Exemplo de `frontend/dart_test.yaml`:

```yaml
platforms:
  - chrome
timeout: 2x
```

Comandos úteis de teste frontend:

```bash
dart run build_runner test -- -p chrome -j 1
```

Se você estiver trabalhando em uma biblioteca de componentes como o `limitless_ui`, mantenha separados os testes Dart puros em VM e os testes AngularDart de browser. Uma divisão prática é:

```bash
dart test test/currency_input_formatter_test.dart test/lite_xlsx_test.dart test/tine_pdf_test.dart test/treeview/treeview_settings_test.dart
dart run build_runner test -- -p chrome -j 1
```

No Windows, defina `CHROME_EXECUTABLE` com o caminho local do Chrome quando a descoberta automática do navegador falhar.

### Backend

Teste middleware, repositórios, integração rota/controller e comportamento request-to-response com um handler real de teste.

## 21. Fluxo de build e desenvolvimento

Um fluxo diário produtivo:

1. Rode o backend em um terminal.
2. Rode o build/watch ou serve do AngularDart em outro.
3. Mantenha DTOs compartilhados em `core`.
4. Adicione primeiro o contrato do backend.
5. Implemente depois o service do frontend.
6. Faça o bind da UI em seguida.
7. Adicione testes logo depois do primeiro fluxo funcional.

Comando típico do backend:

```bash
dart run bin/server.dart --address 0.0.0.0 --port 8080 --isolates 4
```

Comando típico do frontend:

```bash
dart run webdev serve web:8081 --auto refresh --hostname 0.0.0.0 -- --delete-conflicting-outputs
```

O trecho final `-- --delete-conflicting-outputs` é repassado ao `build_runner` quando os outputs gerados estiverem antigos.

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 22. Orientações para deploy em produção

Em produção:

- compile o app AngularDart para assets estáticos;
- sirva esses assets atrás de Nginx ou outro reverse proxy;
- rode a API `shelf` como processo separado;
- termine TLS no proxy;
- escale o backend com múltiplos isolates.

Não confie em estado mutável compartilhado em memória em ambiente multi-isolate.

## 23. Erros comuns a evitar

- Colocar DTOs compartilhados dentro do frontend em vez de `core`.
- Fazer chamadas HTTP brutas diretamente de componentes AngularDart.
- Construir o backend como um único arquivo plano de rotas.
- Misturar SQL, validação e formatação HTTP no mesmo método de controller.
- Tratar isolates Dart como threads com memória compartilhada.
- Referenciar `.scss` diretamente em `styleUrls` do AngularDart.
- Recriar manualmente UI que `limitless_ui` já oferece.

## 24. Blueprint mínimo para começar

Se você quiser a estrutura mínima viável que ainda escale depois, comece aqui:

```text
my_app/
  core/
    lib/
      src/dto/
      src/exceptions/
      core.dart
  backend/
    bin/server.dart
    lib/src/shared/bootstrap.dart
    lib/src/shared/routes.dart
    lib/src/shared/middleware/
    lib/src/modules/projects/
  frontend/
    web/main.dart
    web/index.html
    lib/src/app/
    lib/src/routes/
    lib/src/modules/projects/
    lib/src/shared/services/
```

## 25. Recomendação final

Se você está construindo hoje um sistema full stack sério em Dart com AngularDart, a arquitetura mais defensável é:

- `core` para contratos compartilhados;
- AngularDart + `limitless_ui` no frontend;
- `shelf` + `shelf_router` + middleware no backend;
- `eloquent` para persistência relacional estruturada quando fizer sentido;
- múltiplos isolates em produção em vez de um único isolate gigante.

Essa arquitetura é muito mais sustentável do que uma aplicação achatada em um pacote único.

## 26. Exemplo completo de CRUD de `projects` com estrutura real de arquivos

A forma mais rápida de validar o stack inteiro é implementar um módulo completo de `projects`.

Estrutura recomendada:

```text
my_app/
  core/
    lib/src/dto/project_dto.dart
    lib/core.dart
  backend/
    lib/src/modules/projects/
      projects_routes.dart
      controllers/project_controller.dart
      repositories/project_repository.dart
    test/projects/
      projects_routes_test.dart
  frontend/
    lib/src/modules/projects/
      pages/projects_page.dart
      pages/projects_page.html
      pages/projects_page.scss
      components/project_form_component.dart
      components/project_form_component.html
      components/project_form_component.scss
      services/project_service.dart
```

### DTO compartilhado

`core/lib/src/dto/project_dto.dart`

```dart
class ProjectDto {
  final int? id;
  final String name;
  final String status;
  final DateTime? createdAt;

  ProjectDto({
    this.id,
    required this.name,
    required this.status,
    this.createdAt,
  });

  factory ProjectDto.fromMap(Map<String, dynamic> map) {
    return ProjectDto(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      status: map['status'] as String? ?? 'draft',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };
}
```

### Tabela no banco

Exemplo de tabela PostgreSQL:

```sql
create table projects (
  id bigserial primary key,
  name varchar(180) not null,
  status varchar(40) not null default 'draft',
  created_at timestamp not null default now()
);
```

### Repositório

`backend/lib/src/modules/projects/repositories/project_repository.dart`

```dart
import 'package:eloquent/eloquent.dart';
import 'package:my_app_core/my_app_core.dart';

class ProjectRepository {
  final Connection connection;

  ProjectRepository(this.connection);

  Future<DataFrame<ProjectDto>> findAll({Filters? filters}) async {
    final query = connection.table('projects');
    final totalRecords = await query.count();

    final rows = await query
        .orderBy('id', 'desc')
        .offset(filters?.offset ?? 0)
        .limit(filters?.limit ?? 10)
        .get();

    final items = rows
        .map((row) => ProjectDto.fromMap({
              'id': row['id'],
              'name': row['name'],
              'status': row['status'],
              'createdAt': row['created_at']?.toString(),
            }))
        .toList();

    return DataFrame<ProjectDto>(
      data: items,
      totalRecords: totalRecords,
    );
  }

  Future<ProjectDto?> findById(int id) async {
    final row = await connection.table('projects').where('id', id).first();
    if (row == null) return null;
    return ProjectDto.fromMap({
      'id': row['id'],
      'name': row['name'],
      'status': row['status'],
      'createdAt': row['created_at']?.toString(),
    });
  }

  Future<ProjectDto> insert(ProjectDto dto) async {
    final id = await connection.table('projects').insertGetId({
      'name': dto.name,
      'status': dto.status,
    });
    return (await findById(id as int))!;
  }

  Future<ProjectDto?> update(int id, ProjectDto dto) async {
    final affected = await connection.table('projects').where('id', id).update({
      'name': dto.name,
      'status': dto.status,
    });
    if (affected == 0) return null;
    return findById(id);
  }

  Future<bool> delete(int id) async {
    final affected = await connection.table('projects').where('id', id).delete();
    return affected > 0;
  }
}
```

### Controller

`backend/lib/src/modules/projects/controllers/project_controller.dart`

```dart
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:shelf/shelf.dart';
import 'package:my_app_core/my_app_core.dart';
import 'package:my_app_backend/src/modules/projects/repositories/project_repository.dart';

class ProjectController {
  final _repo = GetIt.instance<ProjectRepository>();

  Future<Response> list(Request request) async {
    final items = await _repo.findAll();
    return Response.ok(
      jsonEncode(items.toMap()),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> getById(Request request, String id) async {
    final item = await _repo.findById(int.parse(id));
    if (item == null) {
      throw ApiProblem(status: 404, title: 'Not found', detail: 'Project not found');
    }
    return Response.ok(
      jsonEncode(item.toMap()),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> create(Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final dto = ProjectDto.fromMap(body);
    if (dto.name.trim().isEmpty) {
      throw ApiProblem(status: 400, title: 'Validation error', detail: 'Name is required');
    }
    final created = await _repo.insert(dto);
    return Response(
      201,
      body: jsonEncode(created.toMap()),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> update(Request request, String id) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final dto = ProjectDto.fromMap(body);
    final updated = await _repo.update(int.parse(id), dto);
    if (updated == null) {
      throw ApiProblem(status: 404, title: 'Not found', detail: 'Project not found');
    }
    return Response.ok(
      jsonEncode(updated.toMap()),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> delete(Request request, String id) async {
    final ok = await _repo.delete(int.parse(id));
    if (!ok) {
      throw ApiProblem(status: 404, title: 'Not found', detail: 'Project not found');
    }
    return Response.ok(
      jsonEncode({'deleted': true}),
      headers: {'content-type': 'application/json'},
    );
  }
}
```

### Rotas

`backend/lib/src/modules/projects/projects_routes.dart`

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:my_app_backend/src/modules/projects/controllers/project_controller.dart';

Handler projectsRoutes() {
  final router = Router();
  final controller = ProjectController();

  router.get('/', controller.list);
  router.get('/<id|[0-9]+>', controller.getById);
  router.post('/', controller.create);
  router.put('/<id|[0-9]+>', controller.update);
  router.delete('/<id|[0-9]+>', controller.delete);

  return router;
}
```

### Service do frontend

`frontend/lib/src/modules/projects/services/project_service.dart`

```dart
import 'package:essential_core/essential_core.dart';
import 'package:my_app_core/my_app_core.dart';
import 'package:my_app_frontend/src/shared/services/api_client.dart';

class ProjectService {
  final ApiClient _api;

  ProjectService(this._api);

  Future<DataFrame<ProjectDto>> list(Filters filters) async {
    final json = await _api.getJson(
      '/api/projects',
      queryParameters: filters.getParams(),
    );
    return DataFrame<ProjectDto>.fromMapWithFactory(
      json,
      (map) => ProjectDto.fromMap(map),
    );
  }

  Future<ProjectDto> create(ProjectDto dto) async {
    final json = await _api.postJson('/api/projects', dto.toMap());
    return ProjectDto.fromMap(json as Map<String, dynamic>);
  }
}
```

### Página do frontend

`frontend/lib/src/modules/projects/pages/projects_page.dart`

```dart
import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:my_app_core/my_app_core.dart';
import 'package:my_app_frontend/src/modules/projects/services/project_service.dart';

@Component(
  selector: 'projects-page',
  templateUrl: 'projects_page.html',
  styleUrls: ['projects_page.css'],
  directives: [coreDirectives, LiDatatableComponent],
)
class ProjectsPage implements OnInit {
  final ProjectService _service;

  ProjectsPage(this._service);

  final filters = Filters(limit: 10, offset: 0);
  late final DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'name', title: 'Name', enableSorting: true, sortingBy: 'name'),
      DatatableCol(key: 'status', title: 'Status', enableSorting: true, sortingBy: 'status'),
    ],
  );

  DataFrame<ProjectDto> frame = DataFrame<ProjectDto>(data: const [], totalRecords: 0);
  bool loading = false;

  @override
  Future<void> ngOnInit() async {
    await refresh();
  }

  Future<void> refresh() async {
    loading = true;
    try {
      frame = await _service.list(filters);
    } finally {
      loading = false;
    }
  }
}
```

### Template do frontend

`frontend/lib/src/modules/projects/pages/projects_page.html`

```html
<section class="page-header mb-3">
  <h2>Projects</h2>
</section>

<li-datatable
  [data]="frame"
  [settings]="settings"
  [dataTableFilter]="filters">
</li-datatable>
```

### Teste de rota no backend

`backend/test/projects/projects_routes_test.dart`

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';
import 'package:my_app_backend/src/modules/projects/projects_routes.dart';

void main() {
  test('monta rotas de projects', () async {
    final app = Router()..mount('/api/projects', projectsRoutes());
    final response = await app(Request('GET', Uri.parse('http://localhost/api/projects/')));
    expect(response.statusCode, isNot(404));
  });
}
```

Esse exemplo é simples de propósito, mas já é um slice vertical real: tabela, repositório, controller, rotas, service, página de UI e teste.

Observação importante: para listagens, retorne `DataFrame` já no repositório. Isso mantém paginação, `totalRecords` e compatibilidade com `li-datatable` e com `DataFrame.fromMapWithFactory(...)` no frontend.

## 27. Tutorial de autenticação JWT ponta a ponta

O setup mais limpo de JWT para esse stack é:

- frontend guarda o access token em um auth service;
- o cliente da API anexa `Authorization: Bearer <token>`;
- o backend valida o JWT em middleware;
- rotas privadas ficam montadas atrás de middleware de auth;
- route guards no AngularDart redirecionam usuários não autenticados para longe das páginas protegidas.

Em sistemas maiores, você pode adotar um ecossistema mais amplo de OIDC/auth. Para este guia, a baseline mais reaproveitável é validação direta de bearer token no `shelf`.

### Fluxo JWT

1. Usuário envia o formulário de login.
2. O frontend manda credenciais para `/api/auth/login`.
3. O backend valida as credenciais.
4. O backend assina um JWT e o retorna.
5. O frontend armazena o token.
6. O cliente da API inclui o token nas próximas requests.
7. O backend valida assinatura, expiração, issuer e audience quando necessário.
8. O middleware grava os claims no contexto da request.
9. Controllers e middleware de permissão leem os claims.

### Endpoint de login no backend

Exemplo `backend/lib/src/modules/auth/controllers/auth_controller.dart`

```dart
import 'dart:convert';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

class AuthController {
  final String jwtSecret;

  AuthController(this.jwtSecret);

  Future<Response> login(Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final username = body['username'] as String? ?? '';
    final password = body['password'] as String? ?? '';

    if (username != 'admin' || password != '123456') {
      return Response.forbidden(
        jsonEncode({'title': 'Invalid credentials', 'detail': 'Username or password is invalid'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final claimSet = JwtClaim(
      issuer: 'my_app_backend',
      subject: username,
      maxAge: const Duration(hours: 8),
      otherClaims: <String, dynamic>{
        'roles': ['admin'],
      },
    );

    final token = issueJwtHS256(claimSet, jwtSecret);

    return Response.ok(
      jsonEncode({
        'accessToken': token,
        'tokenType': 'Bearer',
        'expiresIn': 28800,
      }),
      headers: {'content-type': 'application/json'},
    );
  }
}
```

### Middleware JWT no backend

`backend/lib/src/shared/middleware/auth_middleware.dart`

```dart
import 'dart:convert';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

Middleware authMiddleware(String jwtSecret) {
  return (innerHandler) {
    return (request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({'title': 'Unauthorized', 'detail': 'Missing bearer token'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final token = authHeader.substring('Bearer '.length).trim();

      try {
        final claimSet = verifyJwtHS256Signature(token, jwtSecret);
        claimSet.validate(issuer: 'my_app_backend');

        final next = request.change(context: {
          ...request.context,
          'jwt_claims': claimSet,
          'username': claimSet.subject,
        });

        return innerHandler(next);
      } catch (_) {
        return Response(
          401,
          body: jsonEncode({'title': 'Unauthorized', 'detail': 'Invalid or expired token'}),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}
```

### Montando rotas privadas

```dart
final privateApi = Pipeline()
    .addMiddleware(authMiddleware(jwtSecret))
    .addHandler(projectsRoutes());

app.mount('/api/projects', privateApi);
```

### Auth service no frontend

`frontend/lib/src/shared/services/auth_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  String? _accessToken;

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  Future<void> login(String baseUrl, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = json['accessToken'] as String?;
  }

  void logout() {
    _accessToken = null;
  }
}
```

### Cliente da API com bearer token

```dart
class ApiClient {
  final String baseUrl;
  final AuthService authService;

  ApiClient(this.baseUrl, this.authService);

  Future<Map<String, String>> authHeaders() async {
    final headers = <String, String>{'content-type': 'application/json'};
    final token = authService.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
```

### Route guard no AngularDart

```dart
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:my_app_frontend/src/shared/services/auth_service.dart';

class AuthGuard extends RouterHook {
  final AuthService _authService;
  final Router _router;

  AuthGuard(this._authService, this._router);

  @override
  Future<NavigationResult> navigationPath(
    String path,
    NavigationParams? navigationParams,
  ) async {
    if (_authService.isAuthenticated) {
      return NavigationResult.allow;
    }

    _router.navigate('/login');
    return NavigationResult.block;
  }
}
```

### Notas operacionais sobre JWT

- Mantenha access tokens com vida curta.
- Se precisar de sessão longa, adicione refresh tokens.
- Nunca confie em checagem de role no frontend como autorização real.
- Valide permissão no backend mesmo que o frontend esconda botões.
- Se você migrar para OIDC depois, mantenha a mesma estrutura: auth service, rotas protegidas, middleware bearer token e claims no contexto da request.

## 28. Guia de deploy com Nginx + systemd + isolates

Este modelo de deploy segue um arranjo prático de produção. Os arquivos exatos variam por projeto, mas o modelo geral é reaproveitável:

- frontend compilado em arquivos estáticos;
- backend `shelf` rodando como serviço Linux;
- proxy reverso em Nginx;
- backend escalado com múltiplos isolates.

### Topologia de produção

```text
Browser
  -> Nginx :443
    -> /            arquivos estáticos AngularDart
    -> /api/        backend shelf em localhost:8080
```

### Comando do backend

```bash
dart run bin/server.dart --address 127.0.0.1 --port 8080 --isolates 4
```

### Exemplo de serviço systemd

`/etc/systemd/system/my_app_backend.service`

```ini
[Unit]
Description=My App Dart Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/dart/my_app/backend
Environment=APP_ENV=production
Environment=DB_HOST=127.0.0.1
Environment=DB_PORT=5432
Environment=DB_NAME=my_app
Environment=DB_USER=my_app
Environment=DB_PASS=change_me
Environment=JWT_SECRET=change_me
ExecStart=/usr/bin/dart run bin/server.dart --address 127.0.0.1 --port 8080 --isolates 4
Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

Comandos:

```bash
sudo systemctl daemon-reload
sudo systemctl enable my_app_backend
sudo systemctl start my_app_backend
sudo systemctl status my_app_backend
```

### Exemplo de site Nginx

`/etc/nginx/sites-available/my_app.conf`

```nginx
server {
    listen 80;
    server_name myapp.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name myapp.example.com;

    ssl_certificate /etc/letsencrypt/live/myapp.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/myapp.example.com/privkey.pem;

    root /var/www/dart/my_app/frontend_build;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Comandos:

```bash
sudo ln -s /etc/nginx/sites-available/my_app.conf /etc/nginx/sites-enabled/my_app.conf
sudo nginx -t
sudo systemctl reload nginx
```

### Build do frontend para deploy

Uma abordagem comum:

```bash
dart run build_runner build --release
```

Depois copie os artefatos gerados para um diretório como:

```text
/var/www/dart/my_app/frontend_build
```

### Checklist de endurecimento para produção

- Rode o backend em `127.0.0.1`, não em `0.0.0.0`, quando o Nginx for o entrypoint público.
- Mantenha a terminação TLS no Nginx.
- Guarde segredos em variáveis de ambiente ou secret store adequado.
- Habilite rotação de logs.
- Use `Restart=always` no `systemd`.
- Ajuste `LimitNOFILE` para produção.
- Monitore memória por isolate.
- Dimensione o pool de banco conforme a quantidade de isolates.

### Orientação de sizing para isolates

Uma baseline prática:

- Comece com `--isolates` próximo ao número de cores da máquina.
- Faça benchmark antes de aumentar.
- Lembre que cada isolate pode criar suas próprias conexões com banco.
- Se você rodar 4 isolates com pool de 10, o banco pode enxergar até 40 conexões abertas.

### Sequência de deploy

1. Publicar o código do backend no servidor.
2. Rodar migrations no banco.
3. Gerar build do frontend.
4. Copiar o build para o root servido pelo Nginx.
5. Atualizar o serviço `systemd`, se necessário.
6. Reiniciar o serviço do backend.
7. Recarregar o Nginx.
8. Verificar `/`, `/api/health`, login e uma página protegida.

### Checklist de verificação em produção

- `curl -I https://myapp.example.com/`
- `curl -I https://myapp.example.com/api/health`
- login funcionando
- rota protegida rejeitando acesso anônimo
- página com datatable carregando dados reais
- logs sem repetição de `500` após startup
