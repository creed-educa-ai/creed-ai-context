# prompts/

Prompts **autocontidos**, para colar em qualquer ferramenta que não leia o repositório:
Copilot Chat, ChatGPT, Gemini, Claude web, Codex sem workspace.

| Prompt | Equivale a |
|---|---|
| `00-contexto.md` | carregar o `CONTEXT.md` — **cole sempre primeiro** |
| `01-spec.md` | `/spec` |
| `02-tasks.md` | `/tasks` |
| `03-implementar.md` | `/implementar` |
| `04-revisar.md` | `/revisar` |
| `05-premissa.md` | `/premissa` |
| `06-pr.md` | `/pr` |
| `07-atualizar-spec.md` | `/atualizar-spec` |

## Como usar

1. Cole `00-contexto.md`.
2. Cole o prompt da etapa.
3. Cole os arquivos que o prompt pedir (o molde, a task, o diff).
4. **Você** aplica o resultado, roda a suíte e abre o PR — modo copiloto não dispensa
   nenhum passo humano.
