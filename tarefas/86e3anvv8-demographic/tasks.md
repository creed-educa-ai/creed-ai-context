# Tasks — 86e3anvv8 CREED-40 Demographic

Spec: [`spec.md`](spec.md)

## Progresso

- [x] 1 — [Gravar e consultar os demográficos de um participante](1_task.md) · `creed-backend`
- [ ] 2 — [Migration da tabela `participant_demographics`](2_task.md) · `creed-backend`
- [ ] 3 — [Modelo de dados atualizado](3_task.md) · `creed-ai-context`

Marque aqui ao concluir cada task (`workflows/tasks-to-code.md`).

## Ordem e corte

```
feat/36-participant (PR #28)
        │
        ▼
1 (PUT + validação + GET com demográficos) ──► 2 (migration) ──► PR no backend
                                                    ▲
                                  PR #28 (participants) na dev

3 (modelo de dados) ── vai no PR de docs da 40 (docs/86e3anvv8-demographic)
```

- **A task 1 não espera o PR #28 entrar:** a branch `feat/40-demographic` nasce da
  `feat/36-participant`, que já tem o model `Participant`. Quando o #28 entrar, a branch
  é rebaseada na `dev`.
- **A task 2 espera o #28 na `dev`:** a FK aponta para `participants`, e a migration
  parte da head que o #28 deixar.
- **Um PR só no backend, depois da task 2.** A task 1 cria um model sem tabela: sozinha
  na `dev`, o `alembic check` acusaria diferença e a rota daria 500.
- **A task 3 não toca código** e vai no mesmo PR do `creed-ai-context` que carrega a spec
  e as premissas P-023 a P-027.

## Por que validação e rota na mesma task

A coerência da nacionalidade (P-026) é um validador no schema. Separada, viraria uma task
pequena demais, e a outra ficaria sem comportamento completo para testar.

## Relação com as subtarefas do ClickUp

O board tem só a CREED-401 ("Criar table Demographic"). Ela corresponde à task 2; as
tasks 1 e 3 viram subtarefas novas na publicação (`workflows/tasks-to-clickup.md`).
