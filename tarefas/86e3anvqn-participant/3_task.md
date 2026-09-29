# Task 3 — Migration da tabela `participants`

**Repo:** `creed-backend`
**Depende de:** task 2 e o PR #13 na `dev`

## Objetivo

Uma migration nova cria `participants` como o model das tasks 1 e 2 descreve, reusando
o tipo `recordstatus` do `user`, com upgrade, downgrade e `alembic check` verificados num
Postgres descartável.

## Arquivos que provavelmente mudam

- `alembic/versions/<nova>_cria_tabela_participants.py` (novo)
- `alembic/env.py`: import de `app.domains.participants.models`

## Molde

`alembic/versions/0b0ad39d779a_create_user_table.py` e `conventions/migrations.md`.

## Critérios de aceite

- [ ] `down_revision` é a head da `dev` depois do #13; `alembic heads` devolve uma só.
- [ ] `status` usa `postgresql.ENUM(name="recordstatus", create_type=False)`: a migration
      não cria o tipo, e o `downgrade` não o apaga. Quem apaga é o `downgrade` do `user`
      (PR #18).
- [ ] `document_id`: unique e FK para `documents.id`.
- [ ] `alembic upgrade head` cria a tabela; `\d participants` mostra colunas, unique e FK.
- [ ] `alembic downgrade -1` apaga `participants` e mantém `recordstatus`
      (`\dT recordstatus`); `upgrade head` de novo funciona.
- [ ] `alembic check`: `No new upgrade operations detected.`
- [ ] `alembic downgrade base` funciona (`participants` sai antes de `user`).

## Como testar

Com Postgres descartável — não o banco do docker-compose, porque `downgrade` apaga dados:

```bash
alembic upgrade head
psql -c '\d participants'
alembic downgrade -1 && psql -c '\dT recordstatus'
alembic upgrade head && alembic check
alembic downgrade base && alembic upgrade head
```

Nenhum teste automatizado cobre isto: a suíte não roda migration contra banco.

Autogenerate gera `sa.Enum(..., name="recordstatus")`, que tenta `CREATE TYPE` e quebra
com "type already exists". A migration precisa ser ajustada à mão e revisada linha a linha
(`conventions/migrations.md`, regra 1). Review: tier Sensível.

## Premissas aplicáveis

- nenhuma nova (P-021 e P-022 já cobertas nas tasks 1 e 2)
