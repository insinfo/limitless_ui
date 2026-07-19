# Plano de migração do limitless_ui para a família ngx_*

> Status: Fase 2 concluída em 2026-07-19. Commit principal `3575fe7`
> enviado para `origin/ngx9`; nenhuma publicação foi realizada. Plano criado
> em 2026-07-18.

> **Limite desta execução:** migrar, testar, documentar, fazer `git add`,
> `git commit` e `git push`. **Não executar `dart pub publish` e não publicar
> nenhuma versão no pub.dev**, nem de `limitless_ui`, nem de `popper`, nem dos
> pacotes `ngx_*`. Qualquer publicação futura exige uma solicitação separada e
> explícita.

## Contexto

O AngularDart original (`ngdart`, `ngforms`, `ngrouter`, `ngtest`) foi
abandonado pelo upstream e continuado no fork
[insinfo/angular](https://github.com/insinfo/angular), que republicou o
código no pub.dev sob a família **`ngx_*`**:

- Linha estável (branch `angular9`): `ngx_dart 8.0.1`, `ngx_forms 5.0.1`,
  `ngx_router 4.0.1`, `ngx_test 5.0.1` — código idêntico ao
  `ngdart 8.0.0-dev.4` usado pela linha congelada 1.x, só renomeado. Usa
  `dart:html`.
- Linha de desenvolvimento (branch `master`): `9.0.0-dev.*` — migração para
  `package:web` + `dart:js_interop`, com suporte a WebAssembly (dart2wasm).
- Guia de migração: <https://insinfo.github.io/angular/migration>

A linha congelada `main`/1.x depende de `ngdart: ^8.0.0-dev.4` e é consumida
pelo SALI e outros apps como `limitless_ui: 1.0.0-dev.*`. **Essa linha não foi
tocada** — permanece publicada e funcional para os apps atuais.

## Linhas e branches

| Branch | Framework | Versão do limitless_ui | Consumidores |
|--------|-----------|------------------------|--------------|
| `main` (congelada) | ngdart 8.0.0-dev.4 (`dart:html`) | `1.0.0-dev.*` — **congelada**, só correção crítica | SALI e apps atuais, sem mudanças |
| `ngx8` (existente) | `ngx_dart: ^8.0.1` (`dart:html`) | `2.0.0` | apps migrados para ngx_* |
| `ngx9` (atual) | `ngx_dart: ^9.0.0-dev.1` (`package:web`) | `3.0.0-dev.*` (e `3.0.0` quando o ngx_dart 9 estabilizar) | linha package:web / Wasm |

Por que os majors: trocar `ngdart` → `ngx_dart` é breaking para o consumidor
(os tipos re-exportados mudam de pacote e o app migra os próprios imports
junto), então `2.0.0`. A linha `package:web` muda a superfície DOM
(`dart:html` → `package:web`), então `3.x` — publicada como `-dev` enquanto
depender de pré-release do framework (estável não deve depender de dev).

Semver garante o isolamento: `^1.0.0-dev.x` resolve `< 2.0.0`, logo os apps
atuais nunca recebem 2.x/3.x sem opt-in explícito.

## Fase 1 — branch `ngx8` → limitless_ui 2.0.0 (concluída)

1. Criar o branch a partir do `main`: `git checkout -b ngx8`.
2. `pubspec.yaml`:
   - `version: 2.0.0`
   - `ngdart: ^8.0.0-dev.4` → `ngx_dart: ^8.0.1`
   - `ngforms: ^5.0.0-dev.3` → `ngx_forms: ^5.0.1`
   - `ngrouter: ^4.0.0-dev.3` → `ngx_router: ^4.0.1`
   - `ngtest` (dev_dependencies) → `ngx_test: ^5.0.1`
3. Find & replace global (case-sensitive) nos fontes, testes e exemplos:
   - `package:ngdart/` → `package:ngx_dart/`
   - `package:ngforms/ngforms.dart` → `package:ngx_forms/ngx_forms.dart`
   - `package:ngrouter/ngrouter.dart` → `package:ngx_router/ngx_router.dart`
   - `package:ngtest/angular_test.dart` → `package:ngx_test/angular_test.dart`
   - Atenção a `build.yaml`/`build.debug.yaml` se referenciarem builders por
     nome de pacote (`ngdart`/`ngcompiler` → `ngx_dart`/`ngx_compiler`).
4. Dependências que NÃO mudam nesta fase: `essential_core` (agnóstico de
   framework por contrato), `popper` (1.3.0 tem zero dependências),
   `sass_builder`, `js`.
5. `dart pub get` + `dart run build_runner build --delete-conflicting-outputs`.
6. Rodar a suíte completa (`dart run build_runner test -- -p chrome`).
7. CHANGELOG: seção `## 2.0.0` explicando a troca de família e linkando o
   guia de migração do framework.
8. README: badge/instruções da linha 2.x + tabela de linhas (1.x = ngdart,
   2.x = ngx 8, 3.x = ngx 9).
9. Etapa futura, **fora desta execução**: avaliar uma publicação de `2.0.0`
   somente após solicitação explícita. Não executar `dart pub publish` durante
   esta migração.
10. Migrar um app piloto (ex.: um módulo do SALI) para validar de ponta a
    ponta antes de migrar o restante.

## Fase 2 — branch `ngx9` → limitless_ui 3.0.0-dev.*

Pré-requisito: `ngx_dart 9.0.0-dev.1` publicado (acompanhar o branch
`master` do fork). O `ngx_dart 9.0.0-dev.1` foi publicado em 18/07/2026.

1. Criar `ngx9` a partir do `ngx8` (não do `main`): herda a fase 1.
2. `pubspec.yaml`: `version: 3.0.0-dev.1`, `web: ^1.1.1`,
   `ngx_dart: ^9.0.0-dev.1` (e demais `ngx_*` nas versões 9.x-dev
   correspondentes). Enquanto as correções de compilador ainda não estiverem
   publicadas, consumir os pacotes `ngx_*` diretamente do branch `master`
   corrigido do Git e manter `publish_to: none` como trava contra publicação
   acidental desta configuração transitória.
3. Migrar o código do `dart:html` para `package:web` + `dart:js_interop`
   seguindo o checklist do guia
   (<https://dart.dev/interop/js-interop/package-web>): renames via
   `dart fix`, casts `Element`→`HTMLElement`, listas do DOM, `isA<>()`,
   `.toJS` em callbacks, conditional imports `dart.library.js_interop`,
   nulabilidade estrita (`style.setProperty` etc.).
   - O estado final deve preferir nomes e operações nativos de `package:web`.
     Uma fachada local pode ser usada durante a migração e para adaptações
     sem equivalente direto (streams, callbacks, coleções vivas), mas aliases
     de nomes do `dart:html` e fábricas antigas são transitórios, não uma nova
     API pública a estabilizar. Toda adaptação semântica deve ter teste.
   - Evitar o truque de dois imports com o mesmo prefixo. Se a fachada ainda
     for necessária, ela deve reexportar `package:web` e concentrar os poucos
     helpers próprios em um único import explícito.
4. Substituir `js: ^0.6.7` (descontinuado) por `dart:js_interop`; avaliar
   se o `popper` precisa de uma versão js_interop para compatibilidade com
   dart2wasm (hoje ele usa apenas SDK libs).
5. Testes em Chrome com dart2js **e** dart2wasm (o `_tests` do framework já
   roda os dois; replicar aqui).
6. Entrega desta execução: adicionar as alterações, criar commit e fazer push
   do branch `ngx9`. A publicação de `3.0.0-dev.1` e a promoção futura para
   `3.0.0` ficam explicitamente fora do escopo; não executar comandos de
   publicação no pub.dev.

## Política de manutenção entre linhas

- Bugfix que vale para mais de uma linha: corrigir primeiro no branch mais
  antigo afetado e portar para os mais novos (cherry-pick), com bump de
  versão em cada linha publicada (`1.0.0-dev.37`, `2.0.1`, `3.0.0-dev.2`...).
- `main` (1.x) recebe apenas correções críticas — o objetivo é os apps
  migrarem para 2.x.
- CI: replicar o workflow por branch como no fork do framework (um `dart.yml`
  por branch, apontando para o próprio branch).

## Referências

- Fork do framework: <https://github.com/insinfo/angular>
- Guia de migração ngdart → ngx: <https://insinfo.github.io/angular/migration>
- Guia oficial dart:html → package:web:
  <https://dart.dev/interop/js-interop/package-web>
