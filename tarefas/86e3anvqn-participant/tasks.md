# Tasks — 86e3anvqn CREED-36 Participant

Spec: [`spec.md`](spec.md)

## Progresso

- [x] 1 — [Domínio `participants` com cadastro e consulta, sem documento](1_task.md) · `creed-backend`
- [x] 2 — [Participante com documento](2_task.md) · `creed-backend`
- [x] 3 — [Migration da tabela `participants`](3_task.md) · `creed-backend`

Marque aqui ao concluir cada task (`workflows/tasks-to-code.md`).

## Ordem e corte

```
1 (domínio, sem documento) ──► 2 (documento) ──► 3 (migration) ──► PR
                                   ▲                  ▲
                                   └──── PR #13 (documents) na dev
```

- **A task 1 não depende do PR #13** e pode ser feita já.
- **As tasks 2 e 3 esperam o #13 entrar na `dev`**: a 2 usa o domínio `documents`, a 3
  aponta a FK para `documents.id` e parte da head que o #13 deixar.
- **Um PR só, depois da task 3.** A task 1 cria um model sem tabela no banco: sozinha na
  `dev`, o `alembic check` acusaria diferença e a rota daria 500. As três tasks vão na
  mesma branch, `feat/36-participant`.

## Por que a migration é a última

O workflow sugere migration primeiro. Aqui ela depende da FK para `documents`, que ainda
não está na `dev`, e a spec manda não começar a migration antes do #13 (Riscos).

Descartado: duas migrations (tabela agora, `document_id` depois). Seriam duas revisões em
vez de uma, disputando a head com o #13 e com os PRs #20 e #21.

## Relação com as subtarefas do ClickUp

O board divide por camada: CREED-361 (tabela), CREED-362 (repository e service) e
CREED-363 (schema e router). Aqui a divisão é por entregável testável
(`workflows/spec-to-tasks.md`: "criar o model" não é task). Se as subtarefas forem
realinhadas, é pelo `workflows/tasks-to-clickup.md`.
