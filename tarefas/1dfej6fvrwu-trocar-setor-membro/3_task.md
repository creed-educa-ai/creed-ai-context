# Task 3 — Rota `PATCH /organizations/{organization_id}/members/{link_id}`

**Repo:** `creed-backend`
**Depende de:** task 2 (`LinkService.update_member_department`, `MemberDepartmentUpdate`,
`MemberResponse`)

## Objetivo

O gestor (ou o admin) troca o setor de um membro pela API:
`PATCH /api/v1/organizations/{organization_id}/members/{link_id}` com
`{"department": "Marketing" | ... | null}`, que responde 200 com o membro atualizado.

## Contrato

| Código | Quando |
|---|---|
| 200 | `MemberResponse` com o setor novo |
| 401 | sem sessão, ou sessão inválida |
| 403 | `respondente`, ou `gestor` em outra organização |
| 404 | vínculo inexistente ou de outra organização (e organização inexistente, para o `admin`) |
| 422 | `department` ausente, fora dos cinco valores, ou campo a mais no corpo |

Valores aceitos em `department`: `Marketing`, `Financeiro`, `Administrativo`,
`RecursosHumanos`, `TecnologiaInformacao` ou `null`. Sem espaço: é o valor do enum, não o
rótulo da tela.

## Arquivos que provavelmente mudam

- `app/domains/links/router_members.py` (novo)
  - `router = APIRouter(prefix="/organizations/{organization_id}/members", tags=["members"])`
  - `update_member_department`: `@router.patch("/{link_id}")`, recebendo o usuário por
    `Annotated[AuthenticatedUser, Depends(require_role("admin", "gestor"))]`, a mesma
    forma do `EditorDep` em `app/domains/forms/router.py:25`. Passa `user.role` e
    `user.organization_uuid` ao service e traduz `ForbiddenError → 403` e
    `NotFoundError → 404`. Documenta cada código em `responses=`, como o `router.py` do
    mesmo domínio.
  - Importa só de `schemas`, `dependencies` e `app.shared`, nunca de `models`.
- `app/main.py`: importar `router as members_router` de `app.domains.links.router_members`
  e pôr na tupla do `for _router in (...)`, ao lado de `links_router`.
- `tests/domains/links/test_router_members.py` (novo): um teste por linha da tabela de
  contrato.
- `tests/test_openapi.py`: o caso da operação nova, se o arquivo confere cada rota (ver
  o caso de `.../links` "post").
- `tests/test_arquitetura.py`: `test_router_nao_conhece_models_nem_orm` só lê
  `router.py`. Passar a ler **todo `router*.py`** do domínio, senão `router_members.py`
  (e o `questions/router_options.py` que já existe) escapam da regra.

## Molde

- `app/domains/links/router.py` (sub-recurso de organização, `responses=` com exemplo,
  tradução de exceção)
- `app/domains/questions/router_options.py` e o registro dele em `app/main.py` (segundo
  router no mesmo domínio)
- `tests/domains/links/test_router.py` (`_install_validate_token`, `_authorize_as`,
  service falso)

## Critérios de aceite

- [ ] `PATCH` com `{"department": "Marketing"}` como gestor da organização: 200 e
      `"department": "Marketing"`.
- [ ] `{"department": null}`: 200 e `"department": null`.
- [ ] Sem token: 401. `respondente`: 403. `gestor` de outra organização: 403.
- [ ] Vínculo de outra organização: 404.
- [ ] `{}`, `{"department": "Vendas"}` e `{"department": "Marketing", "role": "admin"}`: 422.
- [ ] A rota aparece em `/api/v1/docs` sob a tag `members`.
- [ ] `tests/test_arquitetura.py` cobre `router_members.py`. Para provar, importe
      `models` nele de propósito: o teste tem que falhar.
- [ ] `ruff`, `mypy` e `pytest` (suíte inteira) passam.

## Como testar

```bash
cd creed-backend
pytest tests/domains/links tests/test_arquitetura.py tests/test_openapi.py -q
pytest
ruff check . && ruff format --check . && mypy app
```

Depois, o roteiro manual com `curl` do "Como verificar" da [spec](spec.md), com banco e
Keycloak locais. É o único lugar em que a consulta da task 2 e o savepoint da task 1
rodam contra Postgres de verdade.

## Premissas aplicáveis

- P-066: `require_role("admin", "gestor")` na rota. O recorte por organização é do
  service (task 2), não da rota.
