# Task 2 — Criar acesso cria nos dois lados e convida

**Repo:** `creed-backend`
**Depende de:**
- task 1 (settings e Mailpit);
- [creed-backend#47](https://github.com/creed-educa-ai/creed-backend/pull/47), a guarda de
  `admin` no `DELETE /users`, porque esta task também mexe no `DELETE`.

**Branch sugerida:** `feat/86e35vhxm-acesso-nos-dois-lados`

## Objetivo

O `POST /users` deixa de receber o `keycloak_id`. Ele cria o usuário no Keycloak sem
senha, dá o papel do vínculo, grava no banco e manda o e-mail de convite. Se qualquer passo
falhar, não faz nada (D7).

O `DELETE /users` passa a apagar também no Keycloak. Login e renovação respondem 503
quando o Keycloak não responde.

## Contexto que você não tem como adivinhar

- **Hoje o back não fala com a Admin API.** O `POST /users` recebe o `keycloak_id` de um
  usuário criado à mão. As chamadas certas já existem, testadas, em `scripts/seed_local.py`:
  - `_service_account_token`: token por `client_credentials`;
  - `_criar_no_realm`: o id vem no cabeçalho `Location`, e o papel é uma chamada à parte
    (`GET /roles/{papel}` e depois `POST /users/{id}/role-mappings/realm`).

  O service account já tem `manage-users` e `view-realm`, que bastam.
- **A ordem é a da D7, e ela importa:**

  ```
  1. banco: e-mail livre, vínculo existe, vínculo sem login            → 409 / 404
  2. Keycloak: cria sem senha (username = e-mail) e pega o id          → 409 / 503
  3. Keycloak: dá a realm role do vínculo
  4. banco: INSERT do user com o keycloak_id (flush)
  5. Keycloak: execute-actions-email ["UPDATE_PASSWORD"]               → 503
     falhou 3, 4 ou 5 → apaga no Keycloak e propaga → o get_db faz rollback
  ```

  O commit acontece quando a rota termina (`SessionDep` com `scope="function"`,
  CREED-364). Não chame `commit()`: o `test_commit_so_no_get_db` reprova.
- **O usuário nasce no Keycloak sem nome e sem credencial:**
  `{"username": email, "email": email, "enabled": true, "requiredActions": []}`.
  Não vão `credentials`, `firstName` nem `lastName`: o perfil do realm não exige nome
  (`test_perfil_nao_exige_nome_para_provisionar`).
- **O e-mail** vai com `lifespan=settings.KEYCLOAK_INVITE_LIFESPAN_SECONDS`.
  - Se `settings.FRONTEND_URL` não for vazia, vão também `client_id=creed-backend` e
    `redirect_uri={FRONTEND_URL}/login`.
  - Se a task 1 anotou que o Keycloak recusa o redirect, mande sem os dois.
- **Erros do Keycloak:**

  | O que o Keycloak responde | Exceção em `admin.py` | No service | Status |
  |---|---|---|---|
  | 409 na criação | `KeycloakConflictError` (nova) | `ConflictError("Já existe acesso com o e-mail X")` | 409 |
  | qualquer outra resposta fora da esperada, ou erro de rede | `KeycloakUnavailableError` (já existe em `client.py`), com o corpo no log | `ServiceUnavailableError` (nova, em `app/shared/exceptions.py`) | 503 |
  | 404 no `DELETE` | — (é sucesso: o usuário já não existe) | — | — |
- **O service não conhece HTTP.** As exceções de `admin.py` viram exceções de domínio no
  service, e o router traduz para status, como o `AuthenticationService` já faz com o
  `client.py`.
- **Se a compensação falhar** (o Keycloak cai entre o passo 2 e a compensação), logue o
  `keycloak_id` com `logger.error`, para a limpeza manual, e propague o erro original.
- **No `DELETE`**: flush do delete no banco, depois apagar no Keycloak. Se o Keycloak
  falhar, vale 503 e rollback: o usuário continua nos dois lados.
- **Armadilha do `DELETE`, fora do escopo.** A FK `dashboards.user_id` não tem `ondelete`
  (achado do #47). Quando `dashboards` ganhar migration, apagar um usuário que tem
  dashboard vai falhar no flush, com 500. Como o flush vem antes do Keycloak, nada se perde
  no realm. O 500 em si é de outra tarefa.

## Arquivos que provavelmente mudam

- `app/external_services/keycloak/admin.py` (novo):
  - `create_user(email) -> uuid.UUID`;
  - `assign_realm_role(keycloak_id, role)`;
  - `send_update_password_email(keycloak_id)`;
  - `delete_user(keycloak_id)`;
  - `KeycloakConflictError`;
  - `build_http_client()`, como ponto de troca nos testes.
- `app/shared/exceptions.py`: `ServiceUnavailableError(DomainError)`, "traduzido para 503
  no router".
- `app/domains/users/schemas.py`: `UserCreate` sem `keycloak_id`, inclusive no exemplo do
  `json_schema_extra`.
- `app/domains/users/service.py`: `create_user_service` na ordem acima, e o
  `delete_user_service` apagando no Keycloak.
- `app/domains/users/router.py`: 503 no `POST` e no `DELETE`, documentado em `responses`,
  e as descrições sem "já provisionado no Keycloak".
- `app/domains/authentication/service.py`: `KeycloakUnavailableError` no login e na
  renovação vira `ServiceUnavailableError`.
- `app/domains/authentication/router.py`: 503 no login e na renovação, documentado.
- `tests/external_services/keycloak/test_admin.py` (novo).
- `tests/domains/users/test_service.py` e `test_router.py`.
- `tests/domains/authentication/test_service.py` e `test_router.py`.
- `tests/test_openapi.py`: 503 documentado nas quatro rotas.

## Molde

- Cliente externo, `build_http_client()` e tradução de resposta em exceção:
  `app/external_services/keycloak/client.py`.
- Teste com transporte falso (`httpx.MockTransport` em `_responder_com`):
  `tests/external_services/keycloak/test_client.py`.
- As chamadas da Admin API: `scripts/seed_local.py` (`_service_account_token`,
  `_criar_no_realm`, `_admin_url`).
- Exceção externa virando exceção de domínio no service: `AuthenticationService.login`.

## Critérios de aceite

- [ ] `POST /users` com `{name, email, link_id}`:
  - [ ] cria no banco e no Keycloak, sem senha e com a realm role do vínculo;
  - [ ] o e-mail chega ao Mailpit;
  - [ ] o `keycloak_id` gravado é o que veio no cabeçalho `Location`.
- [ ] Mandar `keycloak_id` no corpo não muda nada: o campo é ignorado.
- [ ] E-mail que já está no banco → 409, e o Keycloak não é chamado. E-mail que só está
      no Keycloak → 409, e nada fica no banco.
- [ ] Falha no papel, no INSERT ou no envio:
  - [ ] o usuário é apagado no Keycloak e nada fica no banco;
  - [ ] a resposta é 503 (ou o erro original do INSERT);
  - [ ] há um teste de service para cada um dos três pontos.
- [ ] `DELETE /users/{user_id}` apaga no Keycloak. Com o Keycloak fora, a resposta é 503 e
      o usuário continua no banco.
- [ ] Login e renovação com o Keycloak fora → 503 (hoje 401). Credencial errada continua
      401.
- [ ] `admin.py` testado com transporte falso:
  - [ ] a forma das requisições: URL, cabeçalho, corpo, `lifespan`, e `redirect_uri` só
        quando há `FRONTEND_URL`;
  - [ ] o id lido do `Location`;
  - [ ] 409 → `KeycloakConflictError`;
  - [ ] 5xx e erro de rede → `KeycloakUnavailableError`;
  - [ ] 404 no `delete_user` é sucesso.
- [ ] `tests/test_openapi.py` exige o 503 documentado em `POST /users`,
      `DELETE /users/{user_id}`, no login e na renovação.

## Como testar

```bash
cd creed-backend
pytest tests/external_services/keycloak tests/domains/users tests/domains/authentication tests/test_openapi.py tests/test_arquitetura.py -q
ruff check . && ruff format --check . && mypy app && pytest
pre-commit run mypy --all-files
```

De ponta a ponta, com o ambiente da task 1 de pé e o admin de dev logado. O `<link_id>`
é de um vínculo sem login, criado pelo Swagger com `POST /participants` e
`POST /organizations/{organization_id}/links`.

```bash
# caso feliz: 201 e um e-mail no Mailpit
curl -s -w '\n%{http_code}\n' -X POST http://localhost:8000/api/v1/users \
  -H "Authorization: Bearer <access_token>" -H 'Content-Type: application/json' \
  -d '{"name":"Pessoa Teste","email":"pessoa@creed.local","link_id":"<link_id>"}'

# caso de borda: com o Mailpit parado, repita com outro e-mail e outro vínculo.
# Espera 503, e nada no Keycloak nem no banco.
docker compose stop mailpit
docker compose start mailpit

# caso de borda: com o Keycloak parado, o login responde 503
docker compose stop keycloak
```

## Premissas aplicáveis

- P-013 — o acesso nasce `active`. O motivo muda (não há mais senha passada por fora), mas
  a regra não.
- P-049 e P-051 — validade e link de volta, lidos das settings da task 1.
- P-046 — o Keycloak não recebe nome.
