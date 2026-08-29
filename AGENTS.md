# Instruções para agentes de IA

Regras deste repositório para qualquer agente (Claude Code, Codex, Copilot, Cursor,
Gemini CLI ou outro). Valem para todo o projeto, sem exceção.

## Idioma

**Fale sempre em português do Brasil.** Vale para as respostas no chat e para
tudo o que for escrito diretamente ao usuário, mesmo quando a pergunta chegar
em inglês.

Os arquivos do repositório, porém, seguem o idioma que cada um já usa — não os
traduza:

| arquivo | idioma |
|---|---|
| mensagens de commit | inglês |
| `README.md` | inglês |
| `CHANGELOG.md` | inglês |
| `doc.md` | inglês |
| dartdocs e comentários em `lib/` | inglês |
| `doc-pt_BR.md` | português |
| app de exemplo em `example/`, dartdocs inclusive | português |

Na dúvida, olhe o que está em volta antes de escrever.

## Commits

**Nunca acrescente trailer de autoria de IA à mensagem de commit.** Nada de:

```
Co-Authored-By: Claude <noreply@anthropic.com>
Generated with Claude Code
Co-Authored-By: <qualquer agente ou bot>
```

O motivo é concreto: um trailer desses coloca um bot na lista de Contributors do
GitHub, e o repositório é mantido por uma pessoa só. A mensagem de commit descreve a
mudança e nada mais.

`.claude/settings.json` já traz `"includeCoAuthoredBy": false`, mas a regra vale
igual para qualquer ferramenta que não leia esse arquivo.

Commits vão direto na `main`; este repositório não usa branch de feature.

## Convenções do projeto

- **CHANGELOG conciso, documentação detalhada.** A entrada do `CHANGELOG.md` resume o
  que mudou; a explicação longa — a causa, o raciocínio, o que foi medido — vai para
  `doc-pt_BR.md` e `doc.md`.
- **Toda funcionalidade nova precisa de demonstração viva** no app de exemplo
  (`example/`), com a entrada correspondente na navegação.
- **Testes.** Os testes de navegador rodam com
  `dart run build_runner test -- -p chrome -j 1 <caminho>`. Os E2E de Puppeteer ficam
  em `ui_test/e2e/` e precisam de `RUN_EXAMPLE_E2E=true` com o `example/web` servido
  em `http://localhost:8081`.
