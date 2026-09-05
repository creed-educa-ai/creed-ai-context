# tarefas/

Artefatos do pipeline SDD, uma pasta por tarefa do ClickUp:

```
tarefas/<id-clickup>-<slug>/
├── spec.md      (workflows/tarefa-to-spec.md — pode não existir; ver "Quando pular")
├── tasks.md     índice com checklist
├── 1_task.md
└── 2_task.md
```

## Convenções

- **Pasta** = `<id-clickup>-<slug>`, mesmo slug do nome da branch.
  Ex.: `42-relatorio-por-organizacao` ↔ `feat/42-relatorio-por-organizacao`.
- **Os artefatos entram no PR da própria tarefa** — não há PR separado de documentação.
- Tarefa concluída, a pasta **fica**. É o histórico de por que o código é como é.
- Nada de dado real de respondente, credencial ou anexo pesado aqui.

## Exemplo

Pasta com prefixo `EXEMPLO-` é referência, **não tarefa a implementar**. Há duas:

| Pasta | O que mostra |
|---|---|
| `EXEMPLO-relatorio-por-organizacao/` | esqueleto sintético, preenchido à mão para mostrar a forma |
| `EXEMPLO-menu-de-navegacao/` | saída real da esteira (`/calibrar` → `/spec` → `/tasks`) sobre a tarefa CREED-17, gerada como ensaio. Nada foi implementado |

Premissa que nasceu de pasta `EXEMPLO-` vai para o ledger com `EXEMPLO` na coluna Tarefa
e **não** entra na pauta da cliente ([`../decisoes/premissas.md`](../decisoes/premissas.md)).
