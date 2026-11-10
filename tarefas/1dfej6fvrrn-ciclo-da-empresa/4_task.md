# Task 4 — Rota `DELETE /organizations/{organization_id}`

**Repo:** `creed-backend`
**Subtarefa:** [696 · Excluir empresa (E6)](https://app.clickup.com/t/1dfej6fvrvw)
**Branch:** a mesma da task 3 (`feat/696-excluir-empresa`), em outro commit
**Depende de:** task 3 (`OrganizationRemovalServiceDep`) e task 2
(`router_organizations.py`)

## Objetivo

A administradora exclui ou rejeita uma empresa por uma rota só, que responde 204 e não
deixa nada para trás.

## Contexto

A rota traduz o `OrganizationRemovalService` (task 3) em status HTTP. Ela fica no
segundo router de `organizacoes`, que importa o `users.dependencies` como
`links/router_members.py` faz com a exclusão de membro. É a mesma rota para **excluir**
uma empresa ativa ou inativa e para **rejeitar** uma pendente (P-078): o front chama as
duas coisas aqui.

## Contrato

`DELETE /api/v1/organizations/{organization_id}`, só `admin`.

| Status | Quando |
|---|---|
| 204 | excluída; sem corpo |
| 401 | sem token |
| 403 | papel `gestor` ou `respondente` |
| 404 | organização inexistente |
| 409 | a organização do próprio vínculo: `"Não é possível excluir a própria organização"` |
| 503 | o Keycloak não respondeu; **nada foi apagado** e repetir resolve (P-073) |

## Arquivos que provavelmente mudam

- `app/domains/organizacoes/router_organizations.py`
  - `@router.delete("/{organization_id}", status_code=204,
    operation_id="delete_organization")`, guarda `require_role("admin")` num
    `AdminDep`, delegando a `OrganizationRemovalServiceDep` com
    `own_organization_id=user.organization_uuid`.
  - `NotFoundError` → 404, `ConflictError` → 409, `ServiceUnavailableError` → 503.
  - `description`: irreversível; o que sai (membros, respostas, questionários, setores,
    organização, documento, logins); que rejeitar uma pendente é esta rota; que a
    própria organização é recusada.
  - Os erros em `responses=`, com exemplo, no formato do `_DELETE_ERRORS` de
    `links/router_members.py`.
- `tests/domains/organizacoes/test_router_organizations.py`: os casos abaixo, com o
  service trocado por um dublê via `app.dependency_overrides`.
- `tests/test_arquitetura.py`: o motivo de `organizacoes` em `COMPOE_COM_SERVICE_DE`
  acrescenta "a exclusão de empresa (`router_organizations.py`) delega ao
  `OrganizationRemovalService` de `users.dependencies`".
- `creed-ai-context/catalogo.md`: a linha de `organizacoes` ganha o `DELETE`.

## Molde

- `delete_member` em `app/domains/links/router_members.py`: a mesma tradução de erros e
  o mesmo import de `users.dependencies`.
- `tests/domains/links/test_router_members.py`: os testes de rota da M-3.

## Critérios de aceite

- [ ] admin: 204, e o dublê recebeu o id do caminho e o `organization_id` do token.
- [ ] gestor e respondente: 403, sem chamar o service.
- [ ] sem token: 401.
- [ ] `NotFoundError`, `ConflictError` e `ServiceUnavailableError` do service viram 404,
      409 e 503, com a mensagem do service no `detail`.
- [ ] `tests/test_openapi.py` passa com a rota nova (resumo, descrição, `operation_id`,
      erros documentados).
- [ ] No banco local, a sequência de "Como testar" passa.
- [ ] `ruff`, `pre-commit run mypy --all-files`, `pytest` e `tests/test_arquitetura.py`
      passam.

## Como testar

```bash
cd creed-backend
pytest tests/domains/organizacoes tests/test_openapi.py tests/test_arquitetura.py -q
pytest
```

No banco local (`docker compose up -d db keycloak mailpit`, migration temporária da task 1
aplicada, API de pé, token do admin do seed).

A empresa **com membros** sai de um `sign-up` (task 2): a exclusão não olha o status, e a
aprovação só chega na task 5. Ponha um membro nela com `POST /participants`,
`POST /organizations/{id}/links` e `POST /users` (cria o acesso no Keycloak). Para ter
respostas, crie um período e responda com o login desse membro. A organização do seed
não serve: é a do admin, e dá 409.

```bash
API=http://localhost:8000/api/v1

# rejeitar: cadastro novo e DELETE → 204; o mesmo documento cadastra de novo → 201
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/organizations/$ORG_PENDENTE" -H "Authorization: Bearer $TOKEN_ADMIN"

# a própria organização → 409
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/organizations/$ORG_CREED" -H "Authorization: Bearer $TOKEN_ADMIN"

# Keycloak parado → 503, e a empresa continua
docker compose stop keycloak
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/organizations/$ORG_COM_MEMBROS" -H "Authorization: Bearer $TOKEN_ADMIN"
docker compose start keycloak

# de verdade → 204; depois, 404 e o login do membro falha
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/organizations/$ORG_COM_MEMBROS" -H "Authorization: Bearer $TOKEN_ADMIN"
curl -s -o /dev/null -w "%{http_code}\n" "$API/organizacoes/$ORG_COM_MEMBROS" -H "Authorization: Bearer $TOKEN_ADMIN"
```

Atenção: para o 503 acima, pegue o token e faça **uma chamada autenticada qualquer antes
de parar o Keycloak**. A guarda confere o token com as chaves do realm, que a API guarda
em cache por `KEYCLOAK_JWKS_CACHE_SECONDS` (3600 s). Com o cache vazio, a própria guarda
falharia, e o 503 não provaria nada sobre a exclusão.

**O que os testes não provam:** a exclusão de uma empresa grande dentro do tempo da
requisição (spec, Riscos).

## Premissas aplicáveis

- P-078 — rejeitar é esta rota.
- P-079 — só `admin`; a própria organização é 409.
- P-080 — o que sai.
