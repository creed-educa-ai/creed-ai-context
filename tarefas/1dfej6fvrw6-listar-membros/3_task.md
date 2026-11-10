# Task 3 — Rota `GET /organizations/{organization_id}/members`

**Repo:** `creed-backend`
**Depende de:** task 2 (`LinkService.list_members`, `MemberListItem`)

## Objetivo

O gestor (ou o admin) lista os membros de uma organização pela API, com o setor e o
período de cada um, para as tabelas de membros e de mentorandos do painel.

## Contrato

`GET /api/v1/organizations/{organization_id}/members?type=mentoria` → 200 `MemberListItem[]`

| Código | Quando |
|---|---|
| 200 | lista, possivelmente vazia (`[]`) |
| 401 | sem sessão, ou sessão inválida |
| 403 | `respondente`, ou `gestor` em outra organização |
| 404 | organização inexistente (só o admin chega aqui) |
| 422 | `type` fora de `emprego`, `mentoria`, `academico` e `pessoal`, ou `organization_id` que não é UUID |

Formato do item, e `period` `null` quando a pessoa não tem período: ver o "Contrato" da
[spec](spec.md).

## Arquivos que provavelmente mudam

- `app/domains/links/router_members.py`
  - `list_members`: `@router.get("")`, `type: Annotated[LinkType | None, Query(...)] = None`,
    `ManagerDep`. Traduz `ForbiddenError → 403` e `NotFoundError → 404` e monta cada
    item com `MemberListItem.from_member(...)`.
  - O `LinkType` chega ao router pelo `schemas.py` de `links`. O router não importa
    `models` (teste de arquitetura). Se for preciso reexportar o tipo, declare em
    `REEXPORT_DE_TIPO_PERMITIDO`, como `questions` faz.
  - Os `responses=` reaproveitam o `_ERRORS` da C-1, mais um texto próprio de 404.
- `tests/test_openapi.py`: a operação `get` nova na lista de operações esperadas e na
  conferência dos códigos.
- `tests/domains/links/test_router_members.py`: casos do `GET`.

## Molde

- `update_member_department` no mesmo `router_members.py` (C-1)
- `list_periods` em `app/domains/forms/router_periods.py` (P-6), que é um `GET` com
  `Query` opcional

## Critérios de aceite

- [ ] `GET` como gestor da organização: 200, com a lista no formato da spec.
- [ ] `?type=mentoria` chega ao service como `LinkType.MENTORIA`. Sem `type`, chega
      `None`.
- [ ] Sem token: 401. Respondente: 403, sem chamar o service. Service com
      `ForbiddenError`: 403. Service com `NotFoundError`: 404.
- [ ] `?type=vendedor`: 422, sem chamar o service.
- [ ] Organização sem membros: 200 e `[]`.
- [ ] A rota aparece no Swagger sob a tag `members`.
- [ ] `ruff`, `mypy` e `pytest` (a suíte inteira) passam.

## Como testar

```bash
cd creed-backend
pytest tests/domains/links tests/test_arquitetura.py tests/test_openapi.py -q
pytest
ruff check . && ruff format --check . && mypy app
```

Depois, a conferência ponta a ponta num Postgres descartável: o app real com só a
autenticação simulada, como na C-1. Cubra dois membros com períodos diferentes (um
individual aberto e outro "para todos" agendado), uma resposta enviada e uma em
andamento, e `?type=mentoria`. O `curl` com o Keycloak da spec fica para o humano.

## Premissas aplicáveis

- P-066, P-068, P-069 e P-070 (aplicadas no service; a rota só as expõe).

## Como ficou (diferenças do plano acima)

- **O parâmetro se chama `link_type`, com `alias="type"`.** A URL continua
  `?type=mentoria`. Um parâmetro chamado `type` esconderia o builtin do Python dentro da
  função.
- **`LinkType` chega ao router pelo `__all__` do `links/schemas.py`**, com `links` em
  `REEXPORT_DE_TIPO_PERMITIDO`, como `questions` faz com o `QuestionSection`.
- **O 401 e o 403 do `GET` reaproveitam os textos do `PATCH`** (`_ERRORS`). O 404 e o
  422 têm texto próprio (`_LIST_ERRORS`).
