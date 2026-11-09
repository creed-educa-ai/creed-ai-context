# Task 2 — Listar os membros com o período (service e repository de `links`)

**Repo:** `creed-backend`
**Depende de:** task 1 (`pick_period`, `period_status`) e a C-1 commitada (`Member`,
`MemberResponse`, `get_member`, `_check_can_manage_members`)

## Objetivo

`LinkService.list_members(...)` devolve os membros de uma organização, com o período
de cada um e se já respondeu, usando **três consultas fixas**, qualquer que seja o
número de membros.

## Contexto

Um **membro** é um vínculo (`Link`) visto com a pessoa: nome (`participants`), e-mail do
login (`user`) e setor (`departments`). A C-1 já lê um membro assim (`get_member`). Aqui
são todos os membros da organização, mais o período (task 1) e o "já respondeu": existe
`form_responses` **enviada** (`status = submitted`, P-069) daquele vínculo naquele
período. A coluna do vínculo em `form_responses` ainda se chama `vinculo_id`.

## Arquivos que provavelmente mudam

- `app/domains/links/repository.py`
  - `list_members(organization_id, link_type) -> list[tuple[Link, str, str | None, DepartmentType | None]]`:
    a mesma consulta do `get_member`, filtrando só pela organização, mais
    `Link.type == link_type` quando vier, e `order_by(Participant.name, Link.id)` (P-070).
    Para não repetir os JOINs, extraia o `select(...)` comum para um método privado
    `_member_query()`, usado pelos dois.
  - `list_periods(organization_id) -> list[Form]`: todos os `form` da organização com
    `opens_at` e `closes_at` preenchidos.
  - `list_submitted(organization_id) -> set[tuple[uuid.UUID, uuid.UUID]]`: os pares
    `(form_id, vinculo_id)` de `form_responses` enviadas, de formulários da organização.
  - O docstring do topo passa a citar `form` e `form_responses` na leitura entre domínios.
- `app/domains/links/schemas.py`
  - `MemberPeriod`: `form_id`, `opens_at`, `closes_at`, `period_status: PeriodStatus`,
    `has_answered: bool`.
  - `MemberListItem(MemberResponse)`: acrescenta `period: MemberPeriod | None`.
  - `PeriodStatus` vem de `app.domains.forms.schemas`.
- `tests/test_arquitetura.py`: entrada `("links", "forms")` em
  `SCHEMA_DE_SAIDA_DE_OUTRO_DOMINIO`, com o motivo (o período do membro usa o
  `PeriodStatus` de `forms`).
- `app/domains/links/service.py`
  - `MemberWithPeriod`, um dataclass ao lado do `Member`: `member: Member`,
    `period` (o `Form` escolhido, ou `None`), `period_status`, `has_answered`.
  - `list_members(organization_id, link_type, *, role, own_organization_id) -> list[MemberWithPeriod]`:
    1. `_check_can_manage_members` (403, P-066), antes de qualquer consulta;
    2. `organizations.organization_exists`; se não existir, `NotFoundError` (só o admin
       chega aqui);
    3. as três consultas do repository;
    4. para cada membro: `pick_period(periods, link.id, now)`, `period_status(...)` e
       `(period.id, link.id) in submitted`.
  - Importa `pick_period` e `period_status` de `app.domains.forms.service`, que é
    composição permitida.
- `tests/domains/links/test_service_members.py`: casos novos. Pode criar
  `test_service_list_members.py` se o arquivo ficar grande.
- `creed-ai-context/decisoes/adrs/0004-camadas-do-backend.md`: o adendo da C-1 passa a
  citar `form` e `form_responses`.

## Molde

- `LinkRepository.get_member` e `LinkService.update_member_department` (C-1)
- `FormService.list_periods` (montagem com `period_status` e `now` uma vez só)
- `PeriodRead(FormRead)` em `app/domains/forms/schemas.py`

## Critérios de aceite

- [ ] `link_type=MENTORIA`: só vínculos `mentoria`. Sem filtro: todos, inclusive o de
      quem pede.
- [ ] Ordem por nome, com desempate pelo id do vínculo.
- [ ] O período de cada membro é o de `pick_period`, e o individual de um não vaza para
      outro.
- [ ] `has_answered` é `true` só com o par (período, vínculo) enviado. Enviada em outro
      período dá `false`.
- [ ] Membro sem período: `period` `None` e `has_answered` `false`.
- [ ] Gestor em outra organização e respondente: `ForbiddenError`, **sem nenhuma
      consulta**.
- [ ] Admin em organização inexistente: `NotFoundError`. Admin em outra empresa: lista.
- [ ] **Com 1 e com 10 membros, o repository recebe exatamente 3 chamadas** (o dublê
      conta).
- [ ] `ruff`, `mypy`, `pytest` e `tests/test_arquitetura.py` passam.

## Como testar

```bash
cd creed-backend
pytest tests/domains/links tests/test_arquitetura.py -q
ruff check . && ruff format --check . && mypy app
```

**O que os testes não provam:** que as três consultas estão certas no Postgres (JOINs,
filtro de `type`, ordem, filtro de `submitted`). Conferir num Postgres descartável, como
na C-1, ou pelo `curl` da spec depois da task 3.

## Premissas aplicáveis

- P-066: gestor só na própria organização, admin em qualquer uma.
- P-068: o período via `pick_period`.
- P-069: só a resposta enviada conta.
- P-070: sem paginação, ordem por nome.
