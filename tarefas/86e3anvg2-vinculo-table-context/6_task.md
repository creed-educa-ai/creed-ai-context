# Task 6 — Remover `user.role`

**Repo:** `creed-backend`
**Depende de:** task 5, **mesclada na `dev`**, e o time avisado para rodar o seed.
**PR separado das tasks 1 a 5.**

## Objetivo

`user.role` e o tipo `userrole` somem do banco e do código, e `user.link_id` passa a
ser obrigatório. É o passo "remover" da regra 6 de
[`conventions/migrations.md`](../../conventions/migrations.md), que as tasks 1 a 5
prepararam.

## Contexto que você não tem como adivinhar

**Por que esta task existe separada.** Acrescentar o caminho novo, migrar os dados e
remover o caminho velho no mesmo PR é o que a regra 6 proíbe. Entre a task 5 e esta, cada
pessoa roda o seed, e o usuário de dev ganha vínculo. Esse é o passo "migrar dados".
Remover antes disso quebraria o `upgrade` no banco de todo mundo ao mesmo tempo.

**Não há ambiente real.** `creed-infrastructure/ONBOARDING.md` confirma que não há
pipeline de deploy nem banco fora do local. Então "dado existente" aqui é o banco local
de cada pessoa. Mesmo assim, a revisão **confere antes de alterar**: se algum usuário
ainda estiver sem vínculo, ela para com uma mensagem que diz o que fazer, em vez de
deixar o Postgres falhar com um erro genérico de `NOT NULL`.

**O `downgrade()` não recupera o papel antigo.** Ele recria `role` como coluna
**nulável**, porque não há de onde tirar o valor que existia. Diga isso no docstring da
revisão. É aceitável: rollback se faz avançando com uma migration nova (regra 5), e o
`downgrade()` só precisa ser coerente.

## Arquivos que provavelmente mudam

- `alembic/versions/<hash>_drop_user_role.py`
- `app/domains/users/models.py`: sai `role`, sai `UserRole`, e `link_id` deixa de
  aceitar nulo
- tudo que ainda importar `UserRole`: `tests/domains/users/test_service.py`,
  `tests/shared/test_authorization.py`, `tests/domains/authentication/test_service.py` e
  `scripts/seed_local.py` (confira com `grep`)
- `app/domains/links/models.py`: tirar do comentário de `Roles` a menção à
  duplicação, que acabou

## Molde

A forma da revisão e do checklist no docstring vem de
`alembic/versions/49ef1d2c7b7e_form_response_table.py`. Não há revisão destrutiva no
projeto para copiar. Esta é a primeira, e o checklist dela tem de responder "sim" à
pergunta "mudança destrutiva foi dividida em passos?", citando o PR da entrega 1.

## A revisão

`upgrade()`, nesta ordem:

1. Conferir: `SELECT count(*) FROM "user" WHERE link_id IS NULL`. Se for maior que
   zero, `raise RuntimeError(...)` com a mensagem: quantos usuários, e o que fazer
   (rodar `python scripts/seed_local.py`, ou apagar os usuários de teste criados à mão).
2. `alter_column("user", "link_id", nullable=False)`.
3. `drop_column("user", "role")`.
4. `sa.Enum(name="userrole").drop(op.get_bind(), checkfirst=True)`.

`downgrade()`: recria o tipo `userrole`, recria `role` nulável, e devolve `link_id`
para nulável.

**Leia o que o autogenerate fizer com o enum.** Ele costuma gerar o `drop_column` e
esquecer o `DROP TYPE`.

## Critérios de aceite

- [ ] Com um usuário sem vínculo no banco, `alembic upgrade head` para com a mensagem
      desta task, e não com o erro do Postgres. O banco fica como estava.
- [ ] Com todos os usuários vinculados, `alembic upgrade head` passa, `\d "user"` mostra
      `link_id` `not null` e sem `role`, e `\dT` não lista `userrole`.
- [ ] `alembic downgrade -1 && alembic upgrade head` roda sem erro.
- [ ] `grep -rn "UserRole" app/ tests/ scripts/` volta vazio.
- [ ] `alembic heads` devolve uma linha no momento de mesclar.
- [ ] O docstring diz que o `downgrade()` não recupera os papéis, e o checklist está
      preenchido.
- [ ] `ruff check . && mypy app && pytest` passam.

## Como testar

```bash
cd creed-backend
python scripts/seed_local.py
alembic heads
alembic revision --autogenerate -m "drop user role"
# ler, acrescentar a conferência do passo 1 e o DROP TYPE, conferir o downgrade
alembic upgrade head
alembic downgrade -1 && alembic upgrade head
ruff check . && mypy app && pytest
```

O caso de borda, provado à mão:

```bash
alembic downgrade -1
docker compose exec db psql -U creed -d creed -c \
  "INSERT INTO \"user\" (id, keycloak_id, name, email, status) VALUES (gen_random_uuid(), gen_random_uuid(), 'Sem vinculo', 'sem@vinculo.test', 'ACTIVE')"
alembic upgrade head            # tem de parar com a mensagem
docker compose exec db psql -U creed -d creed -c "DELETE FROM \"user\" WHERE email = 'sem@vinculo.test'"
alembic upgrade head            # passa
```

## Premissas aplicáveis

- Nenhuma nova. É a execução da decisão de time de 2026-09-24 (spec, cabeçalho) e do
  [C2] do modelo de dados.
