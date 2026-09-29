# Task 2 — Migration da tabela `participant_demographics`

**Repo:** `creed-backend`
**Depende de:** task 1 e o PR #28 (CREED-36, tabela `participants`) na `dev`

## Objetivo

Uma migration nova cria `participant_demographics` como o model da task 1 descreve, com
upgrade, downgrade e `alembic check` verificados num Postgres descartável.

## Arquivos que provavelmente mudam

- `alembic/versions/<nova>_cria_tabela_participant_demographics.py` (novo)

O `alembic/env.py` já importa `app.domains.participants.models` (CREED-36), então o
model novo entra no autogenerate sem mudança lá.

## Molde

`alembic/versions/9b1560fe0917_cria_tabela_participants.py` (CREED-36) e
`conventions/migrations.md`.

## Critérios de aceite

- [ ] `down_revision` é a head da `dev` depois do #28; `alembic heads` devolve uma só.
- [ ] `participant_id` é PK e FK para `participants.id`.
- [ ] `ethnicities` e `religions` são `varchar(40)[]`, not null, com default de lista
      vazia no banco (`server_default`), para linhas criadas por fora da aplicação.
- [ ] Nenhum tipo enum é criado: os valores são texto (spec, "Abordagem técnica" 3).
- [ ] `alembic upgrade head` cria a tabela; `\d participant_demographics` mostra PK, FK e
      as colunas `[]`.
- [ ] `alembic downgrade -1` apaga só `participant_demographics`; `upgrade head` de novo
      funciona.
- [ ] `alembic check`: sem diferença nesta tabela.
- [ ] `alembic downgrade base` funciona (`participant_demographics` sai antes de
      `participants`).

## Como testar

Com Postgres descartável — não o banco do docker-compose, porque `downgrade` apaga dados:

```bash
alembic upgrade head
psql -c '\d participant_demographics'
alembic downgrade -1 && alembic upgrade head && alembic check
alembic downgrade base && alembic upgrade head
```

Nenhum teste automatizado cobre isto: a suíte não roda migration contra banco.

Autogenerate pode trazer de carona operações de outras tabelas (foi o caso na CREED-36,
com `form_responses`). Ler linha a linha e tirar o que não é desta tarefa
(`conventions/migrations.md`, regra 1). Review: tier Sensível.

## Premissas aplicáveis

- nenhuma nova (P-023 a P-027 já cobertas na task 1)
