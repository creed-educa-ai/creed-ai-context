# Task 4 — Reenviar convite e esqueci minha senha

**Repo:** `creed-backend`
**Depende de:** task 2 (`admin.py` e `ServiceUnavailableError`). Vem depois da task 3,
porque as duas mexem em `users/service.py`, `users/router.py` e `tests/test_openapi.py`.
**Branch sugerida:** `feat/86e35vhxm-reenvio-e-reset-de-senha`

## Objetivo

Quem perdeu o link do convite recebe outro. Quem esqueceu a senha pede um link pelo
próprio e-mail. Os dois usam o mesmo e-mail do Keycloak, sem tela de senha na plataforma.

## Contexto que você não tem como adivinhar

- **Contrato:**

  | Método | Rota | Quem | Entrada | Saída | Erros |
  |---|---|---|---|---|---|
  | POST | `/api/v1/users/{user_id}/invitation` | `admin`; o `gestor` só para quem é da organização dele | — | 204 | 401 · 403 (papel) · 404 (não existe **ou** é de outra organização) · 503 |
  | POST | `/api/v1/authentication/password-reset` | público | `PasswordResetRequest { email }` | 204 | 422 · 503 |

- **Os dois mandam o mesmo e-mail** (`admin.send_update_password_email`, da task 2), com a
  mesma validade (P-049). O reenvio não confere se a pessoa já definiu senha. Para quem já
  tem, o efeito é uma redefinição, e isso é aceito.
- **Usuário de outra organização dá 404, não 403** (decisão 4 do contrato da CREED-23):
  dizer "existe, mas não é seu" vaza cadastro alheio. Para saber a organização do usuário,
  o service lê o vínculo dele pelo `LinkService.get_link_by_id_service`, como o
  `get_active_user_access_by_email` já faz.
- **O reset nunca diz se o e-mail tem acesso.** Para e-mail sem acesso, ou de acesso
  inativo, responde 204 e não manda nada. É a mesma regra do login, que dá uma mensagem só
  para senha errada e para e-mail inexistente. O 503 só aparece quando o envio falha para
  um e-mail que tem acesso, e isso é aceito na spec (Riscos).
- **O reset passa pelo back** (spec, D10). O front não conhece o endereço do Keycloak (D1
  do épico), e `resetPasswordAllowed` continua `false` no realm. Não ligue o "esqueci a
  senha" do próprio Keycloak.
- **A rota de reset é pública**: sem `require_role`, como o login.

## Arquivos que provavelmente mudam

- `app/domains/users/service.py`: `resend_invitation_service(user_id, *, role, own_organization_id)`
  e `send_password_reset_service(email)`.
- `app/domains/users/router.py`: `POST /users/{user_id}/invitation`.
- `app/domains/authentication/schemas.py`: `PasswordResetRequest`.
- `app/domains/authentication/service.py`: `request_password_reset(email)`, que delega ao
  `UserService`.
- `app/domains/authentication/router.py`: `POST /authentication/password-reset`.
- `tests/domains/users/test_service.py` e `test_router.py`.
- `tests/domains/authentication/test_service.py` e `test_router.py`.
- `tests/test_openapi.py`: as duas rotas na lista e as respostas documentadas.

## Molde

- Rota pública com corpo de entrada: `POST /authentication/login`, em
  `app/domains/authentication/router.py`, sem guarda.
- Rota com resposta 204 sem corpo: `DELETE /users/{user_id}`.
- Organização do usuário lida pelo vínculo: `UserService.get_active_user_access_by_email`.

## Critérios de aceite

- [ ] Reenvio:
  - [ ] como `admin` → 204, e um e-mail novo no Mailpit, com link válido;
  - [ ] como `gestor` da mesma organização → 204; de outra organização → 404;
  - [ ] como `respondente` → 403;
  - [ ] para usuário inexistente → 404.
- [ ] Reset:
  - [ ] e-mail com acesso ativo → 204 e um e-mail;
  - [ ] e-mail sem acesso, ou de acesso inativo → 204 e nenhum e-mail;
  - [ ] com o Mailpit parado e e-mail que tem acesso → 503;
  - [ ] e-mail inválido → 422.
- [ ] `tests/test_openapi.py` cobre as duas rotas novas.

## Como testar

```bash
cd creed-backend
pytest tests/domains/users tests/domains/authentication tests/test_openapi.py -q
ruff check . && ruff format --check . && mypy app && pytest
pre-commit run mypy --all-files

# caso feliz: 204 e um e-mail no Mailpit
curl -s -o /dev/null -w '%{http_code}\n' -X POST http://localhost:8000/api/v1/authentication/password-reset \
  -H 'Content-Type: application/json' -d '{"email":"pessoa@creed.example.com"}'

# caso de borda: 204, sem e-mail
curl -s -o /dev/null -w '%{http_code}\n' -X POST http://localhost:8000/api/v1/authentication/password-reset \
  -H 'Content-Type: application/json' -d '{"email":"ninguem@creed.example.com"}'
```

## Premissas aplicáveis

- P-045 — quem reenvia segue a regra de quem convida.
- P-049 — os dois links valem 72 h.
- P-009 — deixa de valer quando esta task entrar. A atualização do ledger é da task 8.
