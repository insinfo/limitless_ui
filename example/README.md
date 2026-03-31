# limitless_ui example

Aplicacao demo para explorar os componentes do pacote `limitless_ui`.
use  webdev serve --auto refresh --hostname localhost -v -- --delete-conflicting-outputs
## Executar

```bash
cd packages/limitless_ui/example
dart pub get
webdev serve --auto refresh --hostname localhost
```

Abra `http://localhost:8080`.

O `example` mantém os arquivos `lib/messages.i18n.dart` e
`lib/messages_en.i18n.dart` versionados e desabilita o builder automático do
`i18n` em [build.yaml](/c:/MyDartProjects/limitless_ui/example/build.yaml),
então o comando acima deve funcionar sozinho, sem etapa prévia.

Se você reativar a geração automática do `i18n` ou alterar manualmente a
configuração de builders, o `webdev` também aceita repassar flags para o
`build_runner` usando `--`:

```bash
webdev serve --auto refresh --hostname localhost -- --delete-conflicting-outputs
```

Esse `--delete-conflicting-outputs` não é uma opção nativa do `webdev`; ele é
encaminhado para o `build_runner`. Já `dart run webdev ...` só funciona se o
pacote `webdev` estiver listado nas dependências do projeto, o que não é o caso
deste `example`.

## GitHub Pages

O repositório inclui um workflow em
[pages.yml](/c:/MyDartProjects/limitless_ui/.github/workflows/pages.yml) que
gera uma versão estática do `example` com:

```bash
dart run build_runner build --release --delete-conflicting-outputs --output web:build
```

Como a demo usa `routerProvidersHash`, ela funciona bem em subcaminhos do
GitHub Pages sem precisar de fallback de rota no servidor.

## Estilos obrigatórios

A biblioteca **só funciona corretamente** se os estilos abaixo estiverem
incluídos no `index.html` da aplicação host:

```html
<link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/icons/phosphor/2.0.3/styles.min.css"
  rel="stylesheet" type="text/css">
<link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/fonts/inter/inter.min.css"
  rel="stylesheet" type="text/css">
<link href="https://cdn.jsdelivr.net/gh/SXNhcXVl/limitless@4.0/dist/css/all.min.css"
  rel="stylesheet" type="text/css">
```

Sem esses links, ícones (Phosphor), fontes (Inter) e estilos base dos
componentes não serão renderizados.

## Notas de performance para templates AngularDart

Estas regras se aplicam a todos os componentes do `limitless_ui` e a qualquer
template AngularDart neste workspace.

### Nunca use `[attr.style]` para propriedades CSS de layout

`[attr.style]="minhaString"` passa a string inteira pelo sanitizador de
atributos DOM a **cada** ciclo de change detection. Quando combinado com
regras de geometria complexas (ex: `grid-template-columns: repeat(auto-fit,
minmax(280px, 1fr))`), o browser entra em layout thrashing e congela por
5–20 segundos.

```html
<!-- ERRADO — trava o navegador -->
<div class="grid-layout" [attr.style]="gridLayoutStyle">

<!-- CORRETO — injeta direto em element.style.*, sem sanitizador -->
<div class="grid-layout"
     [style.grid-template-columns]="settings.gridTemplateColumns"
     [style.gap]="settings.gridGap">
```

### Sempre use `trackBy` em todo `*ngFor`

Sem `trackBy`, o Angular destrói e recria todos os elementos DOM quando a
referência da lista muda, mesmo que os dados sejam idênticos.

```html
<!-- ERRADO -->
<div *ngFor="let row of rows">

<!-- CORRETO -->
<div *ngFor="let row of rows; trackBy: trackByRow">
```

### Use `SafeHtmlDirective` em vez das diretivas separadas

O par antigo `[safeInnerHtml]` + `[safeAppendHtml]` no mesmo elemento causa
double-render (race condition). Use a diretiva unificada:

```html
<!-- ERRADO — double render -->
<td [safeInnerHtml]="column.value" [safeAppendHtml]="column.htmlElement">

<!-- CORRETO — render único -->
<td [safeHtml]="column.value" [safeHtmlNode]="column.htmlElement">
```

### Prefira `[class.hide]` em vez de `*ngIf` para alternar visões

`*ngIf` destrói e recria a subárvore inteira. Para seções que alternam com
frequência (tabela ↔ grid), use CSS:

```html
<!-- ERRADO — recria todo o DOM -->
<div *ngIf="gridMode == false">

<!-- CORRETO — só alterna display: none -->
<div [class.hide]="gridMode">
```
