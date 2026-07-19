# Relatório da migração dart:html → package:web (branch ngx9)

> Status: migração base versionada e homologação release concluída em
> 2026-07-19. Depois de reproduzir o example preso em `Carregando...` apesar
> do build verde, as correções foram aplicadas e o bundle release aprovou
> 15/15 cenários E2E sem `pageerror`, `console.error` ou fallback persistente.
> A implementação foi versionada em `01ff5e4` e enviada para `origin/ngx9`.
> Em seguida, a homologação arquitetural abriu a etapa de eliminação da
> fachada ampla `web_compat`, concluída em 2026-07-19: a fachada foi excluída,
> todo o código importa `package:web` diretamente e a homologação repetiu
> analyzer limpo, VM 52/52, dart2js 505/505, dart2wasm 505/505 e 15/15 E2E em
> release. Iniciado em 2026-07-18.
> Complementa o plano
> [ngx_migration_plan.md](ngx_migration_plan.md).

> Escopo de entrega confirmado: migração, testes, documentação, `git add`,
> `git commit` e `git push`. Não será executada publicação no pub.dev para
> nenhum dos três repositórios.

Este documento registra, etapa por etapa, a execução da Fase 2 do plano
(limitless_ui 3.0.0-dev.1 sobre `ngx_dart 9.0.0-dev.1` + `package:web`),
com os aprendizados e dificuldades encontrados. A Fase 1 (branch `ngx8`,
2.0.0, rename `ng*` → `ngx_*`) foi concluída antes: rename puro, analyzer
limpo e 550/550 testes passando com `-j 1`.

## Escopo medido antes de começar

- 94 arquivos em `lib/`, 65 em `test/` e 16 no `example/` importavam
  `dart:html` (129 como `import 'dart:html' as html;`, 41 sem prefixo,
  4 com `show`).
- Interop legado: `dart:js_util` em 20 arquivos, `package:js` em 4
  (pdfjs, quill, máscaras e testes).
- APIs mais usadas: ~700 referências a tipos de elemento (`ButtonElement`,
  `DivElement`, `InputElement`...), ~500 usos de `.classes.*`, ~190
  construções de `MouseEvent` em testes, 159 `querySelectorAll`, ~100
  `is html.X`, 68 acessos a `.attributes`, 36 `requestAnimationFrame`.

## Etapas executadas

### 1. Dependências (pubspec)

- `version: 3.0.0-dev.1`; a primeira resolução usou `ngx_*`
  `^9.0.0-dev.1`. Depois das correções de compilador descritas na etapa 8, os
  pacotes passaram a apontar para o Git `master` corrigido; `web: ^1.1.1`;
  `intl` teve de subir para `^0.19.0` (exigência do `ngx_dart` 9).
- O limite anterior `web: ^1.1.0` já permitia resolver `1.1.1`, e o lockfile
  de fato já continha `web 1.1.1` durante as suítes completas. Ainda assim, o
  mínimo declarado foi elevado para `^1.1.1` na raiz, no example, no
  `popper_dart` e no único pacote auxiliar do Angular que ainda declarava
  `^1.1.0` (`goldens`), para que os metadados expressem a versão exigida.
- O changelog `2.0.0-wip` anexado descreve o desenvolvimento ainda não
  publicado do `package:web`, inclusive a remoção de APIs deprecated e SDK
  mínimo 3.12. Ele não é uma versão estável disponível no pub.dev e não foi
  usado nesta migração. O alvo verificável e compatível com o SDK declarado
  pelo projeto continua sendo o estável `web 1.1.1`.
- `popper` → dependência git (`https://github.com/insinfo/popper_dart.git`,
  ref `dart_web`, versão 2.0.0 já migrada para package:web). Trocar por
  `popper: ^2.0.0` quando for publicado; até lá o pacote não pode ser
  publicado no pub.dev (git deps bloqueiam publish — irrelevante por ora).
- O pacote raiz recebeu `publish_to: none`. Além de documentar a decisão, essa
  trava impede publicação acidental da branch que consome dependências Git e
  elimina os avisos `invalid_dependency`; ela só deve ser removida durante
  uma entrega futura solicitada separadamente.

### 2. Camada de compatibilidade (`lib/src/web_compat/web_compat.dart`)

Decisão central da migração: em vez de reescrever ~200 arquivos para o
dialeto do package:web de uma só vez, criamos uma fachada pública transitória
que reexporta tanto o `package:web` canônico quanto os adaptadores locais:

```dart
import 'package:limitless_ui/web_compat.dart' as html;
```

Assim, cada consumidor migrado dos antigos imports DOM possui um único import
e `html.DivElement`, `el.classes`, `el.onClick` etc. continuam válidos com os
nomes servidos parte pelo web, parte pelo shim. O binding de baixo nível do
pdf.js é a única exceção intencional: importa diretamente apenas o tipo Web
IDL canônico `CanvasRenderingContext2D`. O shim fornece:

- typedefs com os nomes do dart:html (`HtmlElement` → `HTMLElement`,
  `DivElement` → `HTMLDivElement`, `CssStyleDeclaration` → `CSS...`, ...);
- fábricas de elemento (`createDivElement()`, `createInputElement(type:)`)
  e de eventos com os defaults do dart:html (`liMouseEvent`/`liEvent`/
  `liKeyboardEvent` com `bubbles: true` — no DOM cru o default é `false`,
  o que quebraria todos os testes que despacham eventos);
- extensions: `classes` (view de `classList` com add/addAll/removeAll/
  toggle/toSet), `text` (getter+setter), `style` e `focus/blur/click` em
  `Element` (no package:web só existem em `HTMLElement`), `parent`,
  `nodes` (view VIVA e mutável — ver aprendizado 8), `queryAll` (retorna
  `List<Element>` no lugar de `NodeList`), `innerHtml`/`setInnerHtml`/
  `appendHtml`, `on['evento-custom']`, `toList()`/`isEmpty`/`[]` em
  NodeList/HTMLCollection/TouchList/FileList, `clear()` em HTMLCollection,
  streams que faltam no Window, `liRequestAnimationFrame` (callback Dart),
  `pageXOffset/pageYOffset` (não existem no package:web → `scrollX/Y`);
- wrappers com callback Dart para `MutationObserver`, `ResizeObserver` e
  `IntersectionObserver` (assinaturas do dart:html, incl. options
  posicional no IntersectionObserver);
- stand-ins de `NodeTreeSanitizer` (só `trusted`) e `Url`. Escritas normais de
  HTML continuam passando pelo `DomSanitizationService`; somente o uso
  explícito de `NodeTreeSanitizer.trusted` ignora a sanitização.

Exposto publicamente via `lib/web_compat.dart` (o example é outro pacote e
não pode importar `lib/src/` sem lint).

### 3. Passada mecânica (sed)

Substituições globais em lib/test/example: imports (com `hide` da parte
deprecated dos helpers do web), `html.XxxElement(` → `html.createXxx(`,
`html.MouseEvent(` → `html.liMouseEvent(`, `Element.tag(` →
`document.createElement(`, `.querySelectorAll(` → `.queryAll(`,
`.attributes[...]`/`.remove`/`.containsKey` → `set/get/remove/hasAttribute`,
`x is html.T` → `x.isA<html.T>()` (e `is!` → `!...`),
`.children.addAll(x)` → `x.forEach(el.append)`,
`requestAnimationFrame` → `liRequestAnimationFrame`.

### 4. Correções guiadas pelo analyzer

Do estado pós-sed (1.076 issues) até 0 erros, em passes:

- scripts Python lendo a saída do `dart analyze` para correções em massa
  (envolver `isA` de receptor anulável em `(x?.isA<T>() ?? false)`,
  inserir `!` onde o dart:html não era anulável, adicionar
  `import 'dart:js_interop';` a 40 arquivos, adicionar o bloco de imports
  a 7 arquivos que usavam membros de Element sem importar dart:html);
- correções manuais por arquivo (padrões descritos nos aprendizados);
- 3 subagentes paralelos com um playbook de padrões cuidaram de 43
  arquivos de componentes/diretivas/testes/example; os arquivos com
  interop pesado (pdf_viewer, quill, dropdown, exporter) foram tratados à
  mão.

### 5. package:js / dart:js_util → dart:js_interop

- `pdfjs_bindings.dart` e `quill_interop.dart` reescritos com extension
  types (`@JS()`), `JSPromise<T>.toDart`, `jsify/dartify`, e métodos
  auxiliares Dart-friendly preservando a superfície usada pelos
  componentes (`getPageDart`, `getContentsAsDart`, ...).
- Shims de fullscreen/pointer-capture/print do pdf_viewer convertidos para
  `dart:js_interop_unsafe` (`has`/`getProperty`/`callMethod`) mantendo os
  guards de compatibilidade de navegador.
- `allowInterop(f)` → `f.toJS` (tipando os parâmetros como `JSAny?`/tipos
  interop); `js_util.promiseToFuture` → `promise.toDart`.

### 6. Retomada da validação (2026-07-18)

- O estado não commitado do branch `ngx9` foi auditado e preservado antes de
  novas correções. Dois mocks em `angular/ngx_router/test/regression`
  apareciam como modificados por conversão CRLF/estado do working tree. O
  usuário autorizou incluí-los, mas hashes e diff contra o índice confirmaram
  que não havia mudança de conteúdo; após o `git add`, o status foi limpo e o
  commit do Angular conteve somente os dois arquivos realmente alterados.
- Foram encontrados os dois últimos usos executáveis de `dart:js_util`, ambos
  em helpers de teste que apenas despachavam `KeyboardEvent`. Eles passaram a
  chamar `document.dispatchEvent(event)` diretamente. Como não restou nenhum
  import de `package:js`, a dependência legada `js: ^0.6.7` também foi removida
  do `pubspec.yaml`.
- Dificuldade encontrada ao reiniciar o analyzer: havia um cast encadeado
  sintaticamente inválido em `selection_api_extension.dart`
  (`this as Selection as JSObject`). O cast foi dividido em uma variável
  `Selection` não nula e depois convertido para `JSObject`; a nova análise
  completa foi iniciada após essa correção.
- A revisão semântica do shim encontrou um bug que o analyzer não detecta:
  `_blobParts` aplicava `jsify()` a `List<int>`, produzindo um Array JavaScript,
  mas a API `Blob` exige `BufferSource`, `Blob` ou string. Nos exports XLSX/PDF
  (`datatable_exporter.dart`) isso podia converter os bytes em texto CSV e
  corromper o download. A conversão agora cria um `Uint8List`/`Uint8Array`, e
  foi adicionado um teste de regressão que lê o `arrayBuffer()` do `Blob` e
  compara os cinco bytes, inclusive `128` e `255`. O bug pertence à camada de
  migração do `limitless_ui`; não foi necessária alteração em `angular` nem em
  `popper_dart`.
- A suíte do repositório `popper_dart` passou 28/28 testes com dart2js, mas
  falhou inicialmente em sete asserções com dart2wasm. Os testes usavam o
  matcher `same()` (baseado em `identical()`) para comparar elementos JS; o
  SDK alerta que identidade de representações JS pode variar entre
  compiladores e orienta usar `==`. As sete asserções em
  `popper_dart/test/popper_test.dart` foram corrigidas para igualdade JS. Após
  a correção, `dart analyze`, 28/28 testes dart2js e 28/28 testes dart2wasm
  passaram. Não havia bug funcional no posicionamento do `popper`; era uma
  incompatibilidade real da própria suíte com Wasm. A mudança foi commitada e
  enviada ao branch `dart_web` como `cd89e88`
  (`Fix DOM identity checks in Wasm tests`).
- O `popper_dart` também passou a declarar explicitamente `web: ^1.1.1`.
  Analyzer, 28/28 testes dart2js e 28/28 testes dart2wasm voltaram a passar;
  a alteração foi commitada e enviada ao branch `dart_web` como `1daf2d9`
  (`Require web 1.1.1`).

### 7. Revisão arquitetural da camada `web_compat`

A documentação oficial foi confrontada com a implementação atual:

- o alvo recomendado é usar diretamente os nomes Web IDL de `package:web`,
  aplicar `dart fix` para renames, converter valores JS/Dart explicitamente e
  usar `isA<T>()` nos testes de tipo;
- o próprio `package:web` fornece uma *helper layer* para reduzir o custo da
  migração, inclusive streams e wrappers de listas. O guia também aceita
  wrappers locais para coleções e a cópia pontual de APIs não nativas quando o
  código depende da semântica antiga;
- portanto, ter adaptadores pequenos e testados não é uma anomalia. O que não
  deve virar estado final é manter todo o dialeto de `dart:html` escondido por
  aliases/fábricas e por dois imports fundidos sob o mesmo prefixo: isso torna
  conversões implícitas difíceis de revisar e já permitiu bugs silenciosos nas
  views vivas e nos bytes de `Blob`.

Decisão: manter por enquanto somente a fachada necessária para não reescrever
686 referências de aliases e 108 fábricas em uma única mudança de alto
risco, mas tratá-la como infraestrutura transitória. Ela foi convertida em um
único import público que reexporta `package:web`; os helpers com semântica
própria permanecerão cobertos por testes e aliases/fábricas serão reduzidos
gradualmente em mudanças posteriores. Referências oficiais:
<https://dart.dev/interop/js-interop/package-web> e
<https://github.com/dart-lang/web/tree/main/web/lib/src/helpers>.

### 8. Bugs do compilador corrigidos no `ngx_compiler`

O primeiro smoke de `li_input_component_test.dart` compilou, mas os 14 testes
falharam em runtime com `No provider found for JSObject`. O componente injetava
o antigo alias `HtmlElement`, definido como `typedef` de `web.HTMLElement`. O
gerador preservava o símbolo do alias no token de DI, por isso ele não casava
com o provider interno de `HTMLElement`/`Element` do nó e emitia
`injectorGet(JSObject)`.

A correção foi feita em `angular/ngx_compiler`: aliases cujo tipo subjacente é
exatamente `package:web` `HTMLElement` ou `Element` agora são canonizados para
os tokens DOM internos. Foram adicionadas regressões para os dois tipos. O
teste focado passou 7/7, a suíte do `ngx_compiler` passou 116/116 e o analyzer
ficou limpo. A correção foi commitada e enviada ao `master` do repositório
`angular` no commit `12d91771` (`Fix typedef DOM tokens in generated DI`).

Isso não significa que a injeção de dependência do Angular estivesse quebrada
de forma geral. `Element`, `HTMLElement` e `JSObject` canônicos já eram
tratados pelo framework. A falha ocorria somente quando o token DOM chegava ao
gerador por um `typedef`; nesse caso, o alias não era reduzido ao tipo DOM
canônico e o gerador consultava o injetor pelo token incorreto. Além da
correção no compilador, os 13 tokens de construtor/injeção do `limitless_ui`
que ainda usavam `HtmlElement`, distribuídos em 11 arquivos, foram trocados
para `HTMLElement`. Os aliases restantes são tipos locais transitórios, não
tokens de DI. Assim, o pacote usa a forma canônica recomendada sem esconder o
bug e a regressão do compilador impede que outros consumidores o reencontrem.

Durante uma reconstrução limpa, outro bug real do `ngx_compiler` apareceu no
controle assíncrono do contexto de compilação: `Completer<T>.sync()` combinado
com `completeError(error)` podia mascarar o erro original com
`Null is not a subtype of FutureOr<String>`. O contexto agora usa um completer
assíncrono e preserva também a stack trace com `completeError(error, stack)`.
Foi adicionada regressão; a suíte do compilador passou 117/117 e o analyzer
ficou limpo. A correção foi commitada e enviada como `72dc21e9`
(`Preserve compiler context errors`).

Por solicitação, o `pubspec.yaml` raiz e o do example passaram a consumir
`ngx_dart`, `ngx_forms`, `ngx_router`, `ngx_test` e o override de
`ngx_compiler` pelo Git, branch `master`. A primeira resolução encontrou um
conflito de origem porque o compilador Git ainda declara `ngx_dart` hospedado;
um override raiz de `ngx_dart` unificou todas as referências no mesmo Git. O
`dart pub get` e `dart pub upgrade` inicialmente resolveram os cinco pacotes
em `12a50e32`, revisão do `master` que contém `12d91771` e `72dc21e9`. Depois
das correções reveladas pelo E2E, a resolução final passou a `fc8c8c3a`, que
também contém `f789d199d`, `99d11f69`, `f40dbf30` e a correção de forms.
Nenhum pacote foi publicado no pub.dev.

Por fim, o único `pubspec.yaml` do repositório Angular ainda em `web: ^1.1.0`
era `goldens/pubspec.yaml`; todos os pacotes principais `ngx_*` já exigiam
`^1.1.1`. O auxiliar foi atualizado, o analyzer do compilador permaneceu
limpo e a alteração foi enviada ao `master` como `12a50e32`
(`Require web 1.1.1 in goldens`).

### 9. Consolidação da fachada e correções semânticas

- Todos os consumidores antes ligados à antiga biblioteca DOM em `lib/`,
  `test/` e `example/` foram consolidados no único import
  `package:limitless_ui/web_compat.dart`. A fachada pública reexporta
  `package:web/web.dart` com a lista de conflitos ocultada e também exporta os
  adaptadores internos. O binding isolado do pdf.js usa diretamente
  `package:web` somente para `CanvasRenderingContext2D`, sem misturar os dois
  imports sob o mesmo prefixo.
- A primeira passada mecânica removeu corretamente os blocos de dois imports,
  mas deixou 30 arquivos sem importar a nova fachada. O `dart analyze`
  revelou cerca de 80 referências DOM não resolvidas. Os imports foram
  restaurados a partir dos antigos usos de `dart:html`, diferenciando os casos
  com e sem prefixo, e os arquivos foram novamente formatados. Isso reforçou
  que a consolidação de imports precisa ser validada imediatamente pelo
  analyzer, mesmo quando a substituição parece puramente textual.
- A implementação inicial de `innerHtml`/`setInnerHtml`/`appendHtml` tratava
  toda escrita como confiável e, assim, eliminava silenciosamente a
  sanitização padrão existente em `dart:html`. As escritas normais agora usam
  o `DomSanitizationService` do `ngx_dart`; apenas a passagem explícita de
  `NodeTreeSanitizer.trusted` mantém o bypass intencional. O teste de regressão
  verifica que `<script>` e `onerror` são removidos por padrão e que um
  atributo `onclick` só é preservado no caminho explicitamente confiável.
- `FileUploadInputElement` é apenas um alias de `HTMLInputElement` no novo
  modelo. Portanto, um teste `isA<FileUploadInputElement>()` aceitava também
  `<input type="text">`. A diretiva `LiAutoClickFileInputDirective` passou a
  validar primeiro `HTMLInputElement` e depois `input.type == 'file'`; o teste
  correspondente confirma a rejeição do input de texto e a aceitação do input
  de arquivo.
- Entradas Angular declaradas como `Object?` não podem ser convertidas
  diretamente para `JSAny`: um objeto Dart comum pode lançar `TypeError` em
  dart2wasm antes mesmo do `isA<T>()`. Os helpers `liElementOrNull` e
  `liFileOrNull` agora confinam esse cast, capturam a incompatibilidade de
  representação e retornam `null` para valores Dart/não DOM. Os testes cobrem
  elementos e arquivos reais, objetos, mapas, blobs e `null`; tooltip,
  popover, scrollspy e validações de anexos usam o caminho seguro.
- Os usos remanescentes da extensão compatível e deprecated `Touch.client`
  foram substituídos pelos campos Web IDL canônicos `Touch.clientX` e
  `Touch.clientY`, com conversão numérica explícita onde a API interna exige
  `double`.

A fachada também foi auditada como arquitetura, não apenas como código que
compila. Ela é consumida por 94 arquivos de `lib`, 17 do example e 71 de
testes; 21 dos 37 aliases e 16 das 22 fábricas ainda têm uso de produção.
Portanto, removê-la agora quebraria streams, coleções vivas, callbacks com
Zone, sanitização e outras semânticas sem substituição mecânica. Isso é uma
ponte de migração legítima conforme o
[guia oficial](https://dart.dev/interop/js-interop/package-web), que admite
adaptadores pequenos quando `package:web` não oferece o comportamento
necessário. Não é o destino final praticado: código novo deve importar
`package:web` diretamente, usar nomes Web IDL canônicos e reduzir a fachada.

A auditoria também registrou riscos para a redução futura: o bypass explícito
`NodeTreeSanitizer.trusted` é superfície de segurança; helpers que forçam
`Element` para `HTMLElement` não servem genericamente para SVG/MathML;
`IntersectionObserver` ainda confina opções dinâmicas na fronteira JS; e
`ResizeObserver`/`IntersectionObserver` precisam de teste de Zone se seus
callbacks passarem a atualizar UI Angular. Símbolos públicos sem uso interno
devem ser depreciados antes de remoção em uma versão maior.

### 10. Correções reveladas pelas suítes completas

A primeira suíte completa após a migração terminou com 550 aprovações e cinco
falhas. Cada falha expôs uma diferença semântica que testes focados não tinham
coberto:

- `requestAnimationFrame` e `MutationObserver` do DOM não preservam
  automaticamente a `Zone` Dart de criação. Os wrappers agora vinculam os
  callbacks à `Zone.current`, restaurando change detection e temporização de
  carousel/datatable; ambos ganharam regressões.
- O color picker deixou de invocar dinamicamente `.isA`, que não existe como
  membro JavaScript em runtime; os fluxos mouse/touch agora usam tipos e
  guards estáticos.
- A view de `classList` passou a implementar `SetBase<String>`, preservando o
  contrato vivo de `Set`/`Iterable` usado pelo Quill e por componentes.
- O datatable deixou de usar `whereType<TableCellElement>()`, pois extension
  types não participam de testes de tipo Dart em runtime; agora filtra com
  `isA` e faz o cast somente após o guard.
- O validador min/max recuperou o comportamento legado para entrada vazia
  (`double.tryParse(value) ?? 0`) e ganhou regressão.
- Comparações de identidade de wrappers DOM foram trocadas de
  `identical`/`same` para a igualdade JS `==`, necessária para manter o mesmo
  resultado entre dart2js e dart2wasm.
- O bridge do Quill passou a usar uma interface marcadora Dart para expor a
  instância real tipada, em vez de `is quill.Quill` sobre um extension type.
- As fábricas de eventos foram alinhadas aos defaults legados relevantes,
  inclusive `composed: false`, `view: window` para mouse/teclado e
  `KeyboardEvent.location: 1`.

Depois dessas correções, uma execução focada dos subsistemas alterados passou
107/107. As duas suítes completas e limpas passaram 559/559 em cada backend.

### 11. Reabertura da homologação com o example em release

O comando usado pelo usuário, `webdev serve web:8080 --auto=refresh
--release -- --delete-conflicting-outputs`, concluiu a geração e informou
sucesso. No navegador, porém, o example permaneceu indefinidamente na tela
`Carregando...` e o console registrou exceções minificadas como
`NoSuchMethodError: method not found: 'gaOv'`. Isso comprovou uma lacuna no
gate anterior: analyzer, build e testes de componentes não asseguravam que o
bootstrap completo do bundle release executava sem despacho DOM dinâmico.

A investigação com source maps isolou três frentes:

- no próprio example, `DemoI18nService` lia `navigator.languages` por
  `dynamic`. Em `package:web`, esse valor é `JSArray<JSString>`; o getter
  dinâmico virou um nome minificado inexistente. O acesso passou a ser
  estático, com conversão explícita para Dart antes de escolher e normalizar
  o locale;
- no `ngx_compiler`, a criação de uma raiz local destacada emitia
  `unsafeCast(document.createElement(...))` sem conservar o tipo
  `Element`. Uma chamada posterior a `append` era então gerada como despacho
  dinâmico e falhava somente no JavaScript release. O gerador passou a
  preservar o tipo do elemento, ganhou regressão e a correção foi commitada e
  enviada ao `angular/master` como
  `f789d199d8ee1c95574f9dece2f03350853bc572`
  (`fix(compiler): preserve package:web element types`);
- depois dessas duas correções, a execução revelou outro bug real do
  compilador: `$event` era propagado como `dynamic`, inclusive quando o evento
  DOM possuía tipo Web IDL conhecido ou quando um `@Output` expunha
  `Stream<T>`. Em release, expressões como `$event.preventDefault()` e
  `$event.target` dependiam de nomes dinâmicos minificados. O commit
  `f40dbf30` (`fix(compiler): preserve web event payload types`) agora
  transporta tipos de eventos nativos e payloads `Stream<T>` pela metadata,
  IR e handler gerado, com fallback seguro para streams raw/`void`. O analyzer
  do compilador ficou limpo, a integração sequencial passou 76 testes com 4
  skips e o build completo dos goldens release terminou com 100 outputs/173
  ações;
- a propagação correta tornou visível um problema separado do `ngx_forms`:
  accessors geravam `$event.target.value` ou `checked`, mas `Event.target` é
  apenas `EventTarget?`. O commit final `fc8c8c3a` passa a ler
  `HTMLInputElement`/`HTMLSelectElement` injetados. Forms ficou com analyzer
  limpo e 116/116 testes em cada backend, Dart2JS e Dart2Wasm; o teste de
  `HostListener('$event.target')` passou 12/12;
- durante a validação dos testes do compilador, 51 falhas aparentes eram casos
  que declaravam erros esperados e passaram a receber corretamente a exceção
  propagada por `72dc21e9`. `99d11f69` ajustou o harness para capturar apenas
  esses erros declarados e continuar propagando falhas inesperadas; não é uma
  correção de runtime.

Em paralelo, os pontos executáveis já identificados no `limitless_ui` foram
movidos para handlers Dart tipados, usando `Event`, `MouseEvent`,
`KeyboardEvent` e `HTMLInputElement` canônicos conforme o caso, em vez de
acessar diretamente `$event.target` ou chamar métodos por `dynamic` no
template. Essas mudanças foram validadas e entregues em `01ff5e4`.

O diretório `ui_test` deixou de aceitar apenas a presença genérica de
conteúdo. O harness Puppeteer agora captura `Page.onError`, mensagens
`console.error`, verifica conteúdo real do app e exige que o fallback
`my-app > .loadContainer` desapareça. Foi acrescentado um smoke de bootstrap,
totalizando 15 cenários E2E. A primeira execução release com essas guardas
aprovou 9/15 e reprovou 6/15, expondo tanto os handlers dinâmicos quanto uma
asserção frágil do date picker que comparava coordenadas absolutas entre
aberturas; a asserção passou a medir o painel relativamente ao gatilho. Esse
resultado foi mantido como diagnóstico intermediário, não como validação
final.

Depois das correções do Angular, dos handlers tipados e da estabilização da
asserção relativa do date picker (fontes prontas e dois frames de layout), o
build release final compilou 26.013.840 bytes de entrada para 4.131.767
caracteres JavaScript. A execução completa do `ui_test/e2e` aprovou 15/15 em
76,9 segundos. Como o harness falha no primeiro erro, esse resultado também
confirma ausência de `Page.onError`, `console.error` e da tela
`Carregando...` persistente durante bootstrap e interações.

O workflow de CI foi preparado para também atender o branch `ngx9`, iniciar
o example em modo release, esperar tanto o processo vivo quanto o bundle
`main.dart.js` disponível e só então executar o E2E. A etapa de publicação foi
removida: a CI apenas confirma `publish_to: none` e registra que publicação é
intencionalmente bloqueada.

Os três repositórios em escopo — `limitless_ui`, `angular` e `popper_dart` —
declaram `web: ^1.1.1` nos pacotes aplicáveis. Esta rodada de runtime não
confirmou novo bug funcional no `popper_dart`; os erros observados foram
localizados no app, no `ngx_compiler` e no `ngx_forms`. A conclusão
arquitetural sobre `web_compat` permanece: adaptadores pequenos, tipados e
testados são uma
ponte aceitável para semânticas legadas, mas uma fachada que perpetue todo o
dialeto de `dart:html` não representa o estado final praticado na migração.
Novos pontos devem usar `package:web` canônico, e a ponte deve diminuir
progressivamente.

### 12. Eliminação da fachada ampla antes do release 3.x

Por solicitação explícita, a conclusão anterior de “manter e reduzir no longo
prazo” foi endurecida: a fachada não deve sobreviver como API da linha 3.x. A
auditoria encontrou 95 importadores em `lib`, 17 no example e 71 nos testes;
`ui_test` já era independente. Ela também confirmou que `lib/web_compat.dart`
não é reexportado pelos barrels principais. Como essa API nasceu apenas nesta
prerelease, está bloqueada por `publish_to: none` e nunca chegou a um release
estável, esta é a janela correta para removê-la sem perpetuar dívida pública.

O desenho final não cria outro arquivo que combine e reexporte todo
`package:web`. Os consumidores passam a importar a API canônica diretamente.
Somente comportamentos adicionais comprovados ficam em módulos internos e
temáticos: guards de representação seguros em dart2wasm, conversão de valores
Dart para partes de Blob/File, sinks HTML com sanitização ou bypass *trusted*
explicitamente nomeado e callbacks DOM que preservam a Zone. As fábricas de
eventos que reproduzem bubbling legado não têm uso em produção e passam para
suporte exclusivamente de teste.

O primeiro lote concluiu os 17 arquivos do example: aliases viraram tipos
`HTML*`, fábricas viraram construtores, `classes`/`text`/`append`/`parent`
viraram `classList`/`textContent`/`appendChild`/`parentElement`, e o stream de
resize usa `EventStreamProviders`. O analyzer do example ficou limpo.

Os lotes seguintes migraram os 95 arquivos de `lib` e os 71 testes para
imports diretos de `package:web`. Os comportamentos que exigiam adaptação
ficaram nos módulos estreitos `lib/src/web_support/` (`js_type_guards.dart`,
`blob_parts.dart`, `html_sinks.dart`, `zone_dom_callbacks.dart`,
`dom_tokens.dart`), cada um com testes próprios em `test/web_support/`. As
fábricas de eventos com defaults de bubbling legado saíram da API pública e
viraram suporte exclusivo de teste em `test/support/web_event_factories.dart`.
Com zero consumidores, `lib/web_compat.dart`,
`lib/src/web_compat/web_compat.dart` e `test/web_compat/web_compat_test.dart`
foram excluídos.

A homologação final da Fase 3, em 2026-07-19, confirmou: `dart analyze` da
raiz e do example sem problemas; conjunto VM da CI 52/52; suíte completa
Chrome/dart2js 505/505 em 82 arquivos, sem falhas; suíte completa
Chrome/dart2wasm 505/505, sem `SEVERE` nem `InvalidType`; e `ui_test/e2e`
15/15 contra o bundle release servido com HTTP 200, sem `pageerror`,
`console.error` ou fallback `Carregando...` persistente.

## Aprendizados e dificuldades

1. **`is`/`as` com extension types não checam nada.** `x is html.Element`
   compila e retorna true para QUALQUER objeto JS (checagem apagada em
   runtime) — quebra silenciosa, o analyzer não acusa erro (só um lint
   info em alguns casos). É obrigatório converter para
   `.isA<T>()`. Este é o risco nº 1 da migração: ~100 sites aqui.
2. **`isA` não promove o tipo.** Depois de `if (x.isA<InputElement>())` o
   `x` continua com o tipo estático antigo; é preciso inserir um cast
   (`final input = x as html.InputElement;`). Cast entre extension types é
   apagado — depois de um guard `isA` bem-sucedido nunca lança. Esse
   padrão (perda de promotion) gerou a maior parte dos ~200 erros
   "getter X isn't defined".
3. **Os helpers do package:web ajudam, mas são um campo minado de
   deprecated.** `EventStreamProviders`/`ElementEventGetters` (onClick
   etc.) e `KeyCode` são utilizáveis e não-deprecated; já os renames
   (`HtmlElement`...), `NodeGlue` (`text`/`append`), `EventGlue`
   (`MouseEvent.client`), `TouchListConvert` e os `createXElement` são
   deprecated — usamos `hide` no import e reimplementamos no shim para
   manter `dart analyze` limpo. O `WindowEventGetters` é incompleto (sem
   `onResize`/`onScroll`/`onClick`...), foi preciso completar no shim.
4. **Extensions valem sob prefixo, mas import faltando = "método não
   existe".** 40 arquivos usavam `.isA` sem importar `dart:js_interop`; e
   arquivos que nunca importavam dart:html (usavam membros via tipos
   inferidos de fixtures) precisaram ganhar o bloco de imports só para as
   extensions entrarem em escopo.
5. **Eventos sintéticos: defaults diferentes.** dart:html construía
   `MouseEvent('click')` com `canBubble: true`; no DOM (e no package:web)
   `bubbles` default é `false`. Sem os wrappers `li*Event`, todos os
   testes de click/keyboard falhariam de formas difíceis de diagnosticar.
   Para `keyCode` em `KeyboardEvent` sintético foi preciso injetar a
   propriedade legada no init dict via `js_interop_unsafe` (o Chrome a
   honra, mas o `KeyboardEventInit` do package:web não a expõe).
6. **Nulabilidade mudou nas duas direções.** `window.innerWidth`,
   `InputElement.value`, `KeyboardEvent.key` agora são não-anuláveis
   (dezenas de `?? ''`/`!`/`?.` mortos para remover — warnings
   `dead_null_aware_expression`/`invalid_null_aware_operator`); na outra
   direção `event.target` é `EventTarget?` e exige cast para
   Element/Node (`contains(target as html.Node?)`).
7. **Coleções DOM não são List.** `children`/`childNodes`/`touches`/
   `files` viram HTMLCollection/NodeList/TouchList/FileList sem API de
   Iterable. `.toList()` no shim resolve leitura; mutação
   (`children.addAll`, `children.clear`) precisa reescrita para
   `append`/`remove`.
8. **Cuidado com views materializadas de coisas que eram vivas.** A
   primeira versão do `nodes` no shim retornava `List<Node>` materializada
   — `nodes.clear()` compilava e virava no-op silencioso (bug apontado na
   revisão de um dos subagentes). A versão final é uma `ListBase` viva que
   delega mutações ao DOM. Moral: qualquer API dart:html que era *live*
   precisa continuar live ou os call sites precisam mudar.
9. **Números: `int` vs `double`.** `scrollTop/scrollLeft` viraram
   `double` (eram `int` no dart:html) — `.round()` nos sites que guardam
   int; `getBoundingClientRect()` retorna `DOMRect`, não
   `math.Rectangle` — onde a API interna pedia Rectangle, construímos
   `math.Rectangle(r.left, r.top, r.width, r.height)`.
10. **`innerHTML` é `JSAny` (TrustedHTML union)** no web 1.1 — atribuição
    exige `.toJS`; o shim encapsula (`innerHtml`, `setInnerHtml` e
    `appendHtml`). Preservar apenas o stand-in `NodeTreeSanitizer.trusted` não
    basta: o caminho sem esse marcador deve continuar sanitizando por padrão,
    ou a migração introduz uma regressão de segurança silenciosa.
11. **Interop novo é mais estrito e mais simples.** Extension types +
    `JSPromise<T>.toDart` eliminaram `promiseToFuture`/`getProperty` do
    caminho comum; `getData()` do pdf.js tipado como
    `JSPromise<JSUint8Array>` devolve `Uint8List` direto com `.toDart`.
    Truques do package:js exigem atenção: chamadas com aridade variável
    (ex.: `insertText(index, text, source)` pulando `formats`) precisam de
    um segundo binding `@JS('insertText')` com outra assinatura.
12. **sed em massa tem armadilhas previsíveis**: atribuições multi-linha
    (`.attributes['x'] =` com valor na linha seguinte) geram código
    inválido; `??=` sobre `attributes[...]` não tem equivalente direto
    (vira `if (!hasAttribute) setAttribute`); e line endings CRLF/LF
    poluem o `git status` (219 arquivos com mudança real vs 456 tocados).
    O analyzer pega quase tudo — exceto o item 1, que é silencioso.
13. **Paralelizar com subagentes funciona** para a cauda longa de erros
    contextuais (perda de promotion etc.) desde que recebam um playbook de
    padrões e listas de arquivos disjuntas; a revisão deles inclusive
    achou o bug do item 8.
14. **Callbacks DOM precisam preservar a Zone quando o framework depende
    dela.** Fazer apenas `.toJS` compila, mas perde o contexto que aciona a
    detecção de mudanças. O wrapper deve capturar a Zone na criação e vincular
    o callback antes da conversão para JS.
15. **Identidade Dart não é identidade JS entre backends.** Wrappers de um
    mesmo objeto JavaScript podem não ser `identical` no dart2wasm. Para DOM e
    extension types, `==` expressa a comparação JavaScript desejada.
16. **O cache do build_runner não tolera fontes mudando durante a geração.**
    Uma compilação iniciada enquanto arquivos ainda eram alterados reteve
    `InvalidType` no asset graph. Congelar os fontes e executar
    `build_runner clean` eliminou o estado. O erro secundário que mascarava a
    causa, porém, era do compilador e foi corrigido em `72dc21e9`.
17. **Geradores não podem apagar o tipo de eventos.** Um `$event` dinâmico
    pode parecer funcional em debug e falhar apenas depois da minificação. O
    tipo Web IDL ou o payload `Stream<T>` precisa atravessar metadata, IR,
    parâmetro do handler e conversão `.toJS` de forma coerente.
18. **Accessors não devem depender de `Event.target` para obter valor.** No
    modelo Web IDL ele é `EventTarget?`; quando a diretiva já injeta o
    `HTMLInputElement` ou `HTMLSelectElement`, ler esse elemento tipado evita
    casts frágeis e preserva Dart2JS/Dart2Wasm.
19. **Build verde não é smoke de runtime.** O bundle original compilava e era
    servido com sucesso, mas parava no bootstrap. O gate precisa abrir o
    JavaScript release real, observar erros do navegador e provar que o
    conteúdo substituiu o fallback inicial.

## Validação final concluída

Os resultados da migração base e da homologação release final são:

- `dart analyze` da raiz: sem problemas após a trava `publish_to: none`.
- `dart analyze` do example: sem problemas.
- Build completo do example com `--delete-conflicting-outputs` e
  `--fail-on-severe`: 5.578 outputs/13.616 ações, sem `SEVERE`.
- Smoke Chrome após consumir o Angular corrigido: 17/17 testes passando
  (3/3 da fachada e 14/14 de `li_input_component_test.dart`), confirmando a
  correção do token DOM em DI. A regressão adicional de `liFileOrNull` passou
  4/4 diretamente em Chrome/dart2wasm.
- Execução focada final (fachada, carousel, color picker, datatable, Quill e
  diretivas utilitárias): 107/107, com geração de 6.352 outputs/14.143 ações,
  sem `SEVERE` nem `InvalidType`.
- Suíte completa Chrome/dart2js: 82 arquivos, 559/559, 0 falhas, 0 warnings de
  build, 0 `SEVERE` e 0 `InvalidType`.
- Suíte completa Chrome/dart2wasm: 82 arquivos, 559/559, 0 falhas e 0 erros de
  geração, compilação ou runtime Wasm.
- A resolução final local aponta Angular para `fc8c8c3a` e Popper para
  `1daf2d95`. Os analyzers foram repetidos depois do upgrade.
- Não há imports executáveis de `dart:html`, `dart:js_util` ou `package:js`.
  README, `doc.md`, `doc-pt_BR.md`, o example e os guias HTML também não
  contêm referências legadas; as únicas menções históricas intencionais
  ficam neste relatório, no plano e em comentários da fachada transitória.
- Build release do example concluído e bundle `main.dart.js` servido com HTTP
  200; `ui_test/e2e` passou 15/15 sem `pageerror`, `console.error` ou tela
  `Carregando...` persistente.
- Formatação dos 28 arquivos Dart alterados: nenhuma mudança necessária;
  `dart analyze` da raiz, do example e de `ui_test/e2e`: sem problemas.
- Teste afetado do datatable: 76/76 no Chrome, com 6.352 outputs/14.143 ações
  e sem `SEVERE`; conjunto VM da CI: 52/52.

## Entrega Git

- `angular/master`: `12d91771` (tokens DOM por typedef), `72dc21e9`
  (preservação dos erros do contexto do compilador), `12a50e32`
  (`web: ^1.1.1` no pacote auxiliar goldens) e
  `f789d199d8ee1c95574f9dece2f03350853bc572` (preservação do tipo de
  elementos em raízes destacadas), `99d11f69` (harness de erros esperados),
  `f40dbf30` (tipos de eventos DOM/`@Output`) e `fc8c8c3a` (accessors de
  forms tipados), todos enviados ao remoto.
- `popper_dart/dart_web`: `cd89e88` (comparações DOM compatíveis com Wasm) e
  `1daf2d95` (`web: ^1.1.1`), ambos enviados ao remoto.
- `limitless_ui/ngx9`: commit principal `3575fe7`
  (`Migrate limitless_ui to package:web`) e correções da homologação release
  em `01ff5e4` (`fix(web): make release example runtime-safe`), ambos enviados
  para `origin/ngx9`. A Fase 3 (remoção da fachada `web_compat` e criação dos
  módulos `web_support`) é entregue no commit que acompanha este fechamento
  documental, também enviado para `origin/ngx9`.
- Nenhum `dart pub publish`, upload ou publicação no pub.dev foi executado.
  A branch permanece protegida por `publish_to: none`. O único fluxo
  autorizado nesta execução é migrar, testar, documentar, adicionar,
  commitar e fazer push; publicar exige outra solicitação explícita.
