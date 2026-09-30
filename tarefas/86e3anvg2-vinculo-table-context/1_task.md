# Task 1 — Tabela `links` e a coluna `user.link_id` no banco

**Repo:** `creed-backend`
**Depende de:** nenhuma.

## Objetivo

Uma revisão Alembic cria a tabela `links`, num domínio novo `links`, e acrescenta
a coluna `user.link_id` apontando para ela. Nada além da forma do banco: sem
repository, sem service, sem rota.

## Contexto que você não tem como adivinhar

**Vínculo** é o elo entre uma pessoa (participante) e uma organização. Ele guarda o
papel da pessoa ali (`admin`, `gestor`, `respondente`), o tipo do vínculo (emprego,
mentoria, acadêmico, pessoal) e o período (`start_at`/`end_at`). A mesma pessoa em duas
organizações tem dois vínculos, e cada vínculo tem o próprio login.

**O papel vai sair do `user` e passar a morar no vínculo.** É a decisão que abre esta
tarefa (spec, cabeçalho). Esta task só prepara o banco para isso: a coluna
`user.link_id` nasce **nulável**, e **`user.role` não é tocado**. Quem para de ler
`user.role` são as tasks 4 e 5, e quem o remove é a task 6.

**`Participant`, `Organization` e `Department` não existem no banco.** Por isso
`participant_id`, `organization_id` e `department_id` são UUIDs soltos, sem `ForeignKey`. É o
mesmo que `form_responses.form_id` e `form_responses.vinculo_id` já fazem.
**`user.link_id` é diferente**: o alvo nasce nesta mesma revisão, então ela tem
`ForeignKey` de verdade. É a primeira do projeto.

## Arquivos que provavelmente mudam

- `app/domains/links/__init__.py`: o domínio novo
- `app/domains/links/models.py`: a tabela `links` e os enums `LinkType` e `Roles`
- `app/domains/users/models.py`: **só** a coluna `link_id`
- `alembic/env.py`: o import do model novo
- `alembic/versions/<hash>_create_links_and_user_link_id.py`
- `tests/domains/links/__init__.py`
- `tests/domains/links/test_models.py`: trava a forma das duas tabelas

`app/main.py` **não** muda aqui. A rota é a task 3.

## Molde

A **forma** vem de `app/domains/users/models.py`: `Mapped[...]`, `mapped_column`,
`UUID(as_uuid=True)`, `class X(enum.Enum)` usado com `Enum(X)`, e
`server_default=func.now()`. Coluna UUID com índice e sem FK: copie
`app/domains/responses/models.py`.

O docstring e o `downgrade()` da revisão vêm de
`alembic/versions/49ef1d2c7b7e_form_response_table.py`, **inclusive o checklist
preenchido** e o `sa.Enum(name=...).drop(op.get_bind(), checkfirst=True)` para cada
tipo enum criado.

## A tabela `links`

`__tablename__ = "links"`, no plural (`estrutura-e-nomes.md`). Classe `Link`.

| Coluna | Tipo | Nulo? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, `default=uuid.uuid4` |
| `participant_id` | `UUID` | não | `index=True`, **sem `ForeignKey`** |
| `organization_id` | `UUID` | não | `index=True`, **sem `ForeignKey`** |
| `department_id` | `UUID` | **sim** | `index=True`, **sem `ForeignKey`** |
| `type` | `Enum(LinkType)` | não | `EMPREGO = "emprego"` · `MENTORIA = "mentoria"` · `ACADEMICO = "academico"` · `PESSOAL = "pessoal"` |
| `role` | `Enum(Roles)` | não | `ADMIN = "admin"` · `GESTOR = "gestor"` · `RESPONDENTE = "respondente"` |
| `start_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |
| `end_at` | `DateTime(timezone=True)` | sim | — |
| `created_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |
| `updated_at` | `DateTime(timezone=True)` | sim | sem default |

**Nenhuma** `UniqueConstraint`: o `.dbml` não define uma (spec, "Abordagem técnica",
item 6).

`Roles` tem os mesmos três valores de `UserRole`, em `users/models.py`. **Não importe
`UserRole`**, porque um domínio não importa model de outro. A duplicação dura até a
task 6, que apaga `UserRole` (spec, item 4). Deixe um comentário curto em cima de
`Roles` dizendo isso e citando a P-006.

## A coluna nova em `user`

Em `app/domains/users/models.py`, e só ela:

```python
# Aponta para o vínculo que dá o papel deste login (modelo [C2]: 1 login = 1 vínculo).
# Nulável só até a task 6 da CREED-32: aí vira NOT NULL e `role` sai.
link_id: Mapped[uuid.UUID | None] = mapped_column(
    UUID(as_uuid=True),
    ForeignKey("links.id", name="fk_user_link_id_links"),
    unique=True,
    nullable=True,
)
```

A `ForeignKey` é declarada **pelo nome da tabela**, em texto. Não há `import` de
`app.domains.links`, e o teste de arquitetura continua passando.

**Atualize o comentário de `role`** logo acima. Hoje ele diz "Enquanto `Vinculo` não
existe". Passa a dizer que a coluna não é mais lida a partir da CREED-32 e sai na task 6.

## O que o autogenerate erra, e você corrige

1. **Nomes `None`.** O autogenerate tende a emitir
   `op.create_foreign_key(None, ...)` e `op.create_unique_constraint(None, ...)`. O
   `downgrade()` correspondente, `op.drop_constraint(None, ...)`, **não roda**. Dê nome
   aos dois: `fk_user_link_id_links` e `uq_user_link_id`. O unique pode sair
   como `unique=True` na coluna; confira no arquivo gerado o que ele fez, e nomeie.
2. **Ordem.** No `upgrade()`, primeiro `create_table("links")`, depois a coluna e a FK
   em `user`. No `downgrade()`, a ordem inversa: FK, unique, coluna, tabela e, por fim,
   os tipos `linktype` e `roles`.
3. **Tipos enum no `downgrade()`.** Aqui são dois drops. Não apague `userrole` nem
   `recordstatus`, que continuam sendo usados pelo `user`.

## Antes de gerar: o import e o head

```python
from app.domains.links import models as links_models  # noqa: F401
```

Sem essa linha em `alembic/env.py`, a revisão sai sem a tabela.

Rode `alembic heads` **imediatamente antes** de gerar. Hoje o head é `49ef1d2c7b7e`, mas
CREED-31, CREED-33 e CREED-35 podem mesclar antes de você. Antes de mesclar o PR,
atualize a branch e rode `alembic heads` de novo. Se aparecerem duas linhas, rode
`alembic merge -m "merge heads" <h1> <h2>` **neste** PR. Nunca edite `down_revision`
à mão.

## Critérios de aceite

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] `alembic downgrade -1 && alembic upgrade head` roda sem erro. É o que prova que os
      nomes das constraints e os drops dos enums estão certos.
- [ ] `\d links` mostra as dez colunas acima, com os três índices, sem nenhuma
      `ForeignKey` e sem `UniqueConstraint`.
- [ ] `\d "user"` mostra `link_id` nulável, com `uq_user_link_id` e
      `fk_user_link_id_links`, e `role` ainda presente e intacto.
- [ ] Nenhum arquivo de `app/domains/links/` importa de outro domínio, e
      `users/models.py` também não importa de `links`.
- [ ] `alembic heads` devolve uma linha no momento de mesclar.
- [ ] O checklist do docstring da revisão está preenchido, e quem leu o arquivo gerado
      sabe dizer o que cada comando faz.
- [ ] `pytest tests/domains/links tests/domains/users tests/test_arquitetura.py -q`
      passa.

## Como testar

```bash
cd creed-backend
docker compose up -d db
alembic heads
alembic revision --autogenerate -m "create links and user.link_id"
# ler o arquivo gerado, nomear as constraints, conferir a ordem e os drops
alembic upgrade head
alembic downgrade -1 && alembic upgrade head
docker compose exec db psql -U creed -d creed -c "\d links" -c "\d \"user\""
pytest tests/domains/links tests/domains/users tests/test_arquitetura.py -q
ruff check . && mypy app
```

**Com revisão de junção na branch, `downgrade -1` para com `Ambiguous walk`** (a junção
tem dois pais). Desça pelo identificador: `alembic downgrade <head que veio da dev>`,
depois `alembic downgrade <revisão desta tarefa>@-1`, e `alembic upgrade head`. Na CREED-32
isso foi `22d4bc18cac6` e `b9fa0c109598@-1`, provado no bloco 2 do
[`plano-e2e.md`](plano-e2e.md).

`tests/domains/links/test_models.py` não precisa de banco: ele lê
`Link.__table__` e `User.__table__`. Ele confere que:

- as dez colunas de `links` existem, com a nulabilidade da tabela;
- `Link.__table__.foreign_keys` está vazio;
- existe índice em `participant_id`, `organization_id` e `department_id`;
- os valores de `LinkType` e de `Roles` são exatamente os da tabela acima;
- `User.__table__.c.link_id` é nulável, único e tem uma FK para `links.id`.

Os testes de `tests/domains/users/` continuam passando **sem mudança**: a coluna é
nulável, e `um_user()` não precisa dela.

## Premissas aplicáveis

- **P-029**, refutada em 2026-09-29: vínculo e setor **não** ficam em português. No
  código são `Link` e `Department` (ADR-0005), e aqui isso aparece em `links`, `Link`,
  `link_id` e `department_id`.
- **P-006**: os papéis são `admin`, `gestor` e `respondente`. É a lista do enum `Roles`.
