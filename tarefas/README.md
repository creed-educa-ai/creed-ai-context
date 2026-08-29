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

`EXEMPLO-relatorio-por-organizacao/` é um esqueleto preenchido para servir de referência
na primeira vez. Não é tarefa real — não implemente.
