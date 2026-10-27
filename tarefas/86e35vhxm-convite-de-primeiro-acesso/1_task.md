# Task 1 — O Keycloak local manda e-mail

**Repo:** `creed-backend`
**Depende de:** nenhuma.
**Branch sugerida:** `feat/86e35vhxm-email-no-ambiente-local`, com base na `dev`.

## Objetivo

Com `docker compose up`, o Keycloak local passa a mandar e-mail para um Mailpit, em
português, com política de senha e link de volta para a plataforma. Tudo vem do arquivo de
realm, sem clique na UI. Nenhuma rota do back muda nesta task.

## Contexto que você não tem como adivinhar

- **Quem manda o e-mail é o Keycloak, nunca o back** (ADR-0006, item 4). O back só vai
  pedir o envio pela Admin API, na task 2. Aqui só se preparam o realm e o ambiente.
- **Segredo não entra no arquivo.** O `realm-creed.json` é público e é o mesmo que a
  produção importa (ADR-0007). Todo valor de SMTP entra como placeholder `${VARIAVEL}`,
  **sem o prefixo `env.`**. Com `${env.X}` a substituição falha em silêncio, e o erro só
  aparece na hora do envio (testado no ADR-0006). Os valores locais ficam no
  `docker-compose.yml`, como já acontece com `${CREED_BACKEND_CLIENT_SECRET}`.
- **O SES exige TLS.** O bloco `smtpServer` do ADR-0006 não tem `starttls` nem `ssl`; os
  dois entram aqui, também como placeholder. No local os dois são `false`; em produção
  (task 7), `starttls` é `true`.
- **A política de senha quebra o seed.** Com `length(8)`, a Admin API recusa criar o
  usuário de dev com a senha `dev`. A senha do seed muda nesta task (sugestão:
  `dev-creed`), e o README muda junto.
- **O realm só é importado quando nasce.** Para ver as mudanças no local, rode
  `docker compose down -v`, que apaga também o banco local, e suba de novo. Em produção
  isso não serve: é a task 7.
- **O e-mail passa a ser editável só pelo `admin`** (spec, D12). Fica no perfil
  declarativo do realm (`components` → `UserProfileProvider` → `kc.user.profile.config`).
  - O atributo `email` passa de `"edit":["admin","user"]` para `"edit":["admin"]`.
  - Esse perfil é uma string JSON dentro do JSON: edite com cuidado e deixe o teste
    conferir.
  - Motivo: o console de conta do Keycloak passa pelo Caddy, e quem troca o próprio
    e-mail ali perde o acesso, porque o login procura pelo e-mail.

## Arquivos que provavelmente mudam

- `docker-compose.yml`:
  - serviço `mailpit`: imagem `axllent/mailpit` com versão fixa; porta `8025` (tela) e
    `1025` (SMTP);
  - no `keycloak`: `SMTP_HOST=mailpit`, `SMTP_PORT=1025`,
    `SMTP_FROM=nao-responda@creed.local`, `SMTP_AUTH=false`, `SMTP_STARTTLS=false`,
    `SMTP_SSL=false`, `SMTP_USER=`, `SMTP_PASSWORD=`,
    `CREED_FRONTEND_URL=http://localhost:5173`.
- `docker/keycloak/realm-creed.json`:
  - `"internationalizationEnabled": true`, `"supportedLocales": ["pt-BR", "en", "es"]`,
    `"defaultLocale": "pt-BR"`;
  - `"passwordPolicy": "length(8)"`;
  - `"smtpServer"` com `host`, `port`, `from`, `auth`, `starttls`, `ssl`, `user` e
    `password` por placeholder, e `"fromDisplayName": "CREED.ai Educa"`;
  - no client `creed-backend`: `"redirectUris": ["${CREED_FRONTEND_URL}/*"]`;
  - no perfil: `email` com `"edit": ["admin"]`.
- `app/core/config.py`, cada setting com o comentário do porquê, como as vizinhas:
  - `KEYCLOAK_INVITE_LIFESPAN_SECONDS: int = 259200` (72 h, P-049);
  - `FRONTEND_URL: str = ""` (vazia desliga o link de volta, P-051).
- `.env.example`: as duas variáveis, com `FRONTEND_URL=http://localhost:5173`.
- `scripts/seed_local.py`: `PASSWORD` com 8 caracteres ou mais.
- `README.md`: o Mailpit (`http://localhost:8025`), a senha nova do seed (na tabela e no
  `curl`) e o aviso de que mudar o realm pede `down -v`.
- `tests/test_realm_keycloak.py`: um teste por bloco novo.
- `tests/test_config.py`: os padrões das duas settings.

## Molde

- Placeholder no realm e teste de "o segredo vem do ambiente":
  `test_segredo_e_ssl_chegam_pelo_ambiente`, em `tests/test_realm_keycloak.py`.
- Serviço com versão fixa e o comentário do porquê: o `n8n` do `docker-compose.yml`.
- Setting com comentário: `KEYCLOAK_PUBLIC_URL`, em `app/core/config.py`.

## Critérios de aceite

- [ ] `docker compose down -v && docker compose up -d` sobe `db`, `keycloak`, `n8n` e
      `mailpit`. O realm importado tem o SMTP apontando para `mailpit:1025`, sem clique.
- [ ] O `execute-actions-email` manual de "Como testar" responde 204. O e-mail aparece em
      `http://localhost:8025`, em português, com link para
      `http://localhost:8080/realms/creed/login-actions/...`.
- [ ] O link abre a página de definir senha em português, e senha com menos de 8
      caracteres é recusada.
- [ ] O seed roda no ambiente novo, e o `dev@creed.example.com` entra com a senha nova.
- [ ] `tests/test_realm_keycloak.py` cobre:
  - a senha do SMTP é placeholder, nunca literal;
  - `starttls` e `ssl` existem;
  - `defaultLocale` é `pt-BR`;
  - `passwordPolicy` tem `length(8)`;
  - o redirect do client é placeholder;
  - o `email` não é editável pelo usuário.
- [ ] Os testes que já existem continuam verdes, inclusive `resetPasswordAllowed: false`
      e `verifyEmail: false`.
- [ ] `tests/test_config.py` cobre os padrões de `KEYCLOAK_INVITE_LIFESPAN_SECONDS`
      (`259200`) e de `FRONTEND_URL` (vazia).
- [ ] **Validado e anotado no PR**: com `client_id=creed-backend` e
      `redirect_uri=http://localhost:5173/login` no envio manual, o Keycloak aceita o
      redirect, e a página final mostra o link de volta? Se ele recusar
      (`Invalid redirect uri`), o PR diz isso, e a task 2 manda o e-mail sem redirect
      (spec, Riscos).

## Como testar

```bash
cd creed-backend
docker compose down -v && docker compose up -d
alembic upgrade head
python scripts/seed_local.py

# token do service account do back
curl -s -X POST http://localhost:8080/realms/creed/protocol/openid-connect/token \
  -d grant_type=client_credentials -d client_id=creed-backend -d client_secret=creed-local-secret

# id do usuário de dev no realm
curl -s "http://localhost:8080/admin/realms/creed/users?email=dev@creed.example.com&exact=true" \
  -H "Authorization: Bearer <access_token>"

# o envio: espera 204 e um e-mail em http://localhost:8025
curl -s -o /dev/null -w '%{http_code}\n' -X PUT \
  "http://localhost:8080/admin/realms/creed/users/<id>/execute-actions-email?lifespan=259200&client_id=creed-backend&redirect_uri=http://localhost:5173/login" \
  -H "Authorization: Bearer <access_token>" -H 'Content-Type: application/json' \
  -d '["UPDATE_PASSWORD"]'

pytest tests/test_realm_keycloak.py tests/test_config.py tests/test_seed_local.py -q
ruff check . && ruff format --check . && mypy app && pytest
pre-commit run mypy --all-files
```

Sem a consolidação das migrations (CREED-57), o seed para no banco, porque falta a tabela
`organizations`. Mas ele para **depois** de criar o usuário de dev no Keycloak, então o
teste do e-mail funciona assim mesmo.

- **Caso feliz:** o e-mail chega em português, e a senha nova funciona no login.
- **Caso de borda:** a senha `1234567`, de 7 caracteres, é recusada na página do realm.

## Premissas aplicáveis

- P-049 — o link vale 72 horas (setting desta task).
- P-050 — texto padrão do Keycloak em português, páginas em pt-BR, com en e es.
- P-051 — link de volta para o login; `FRONTEND_URL` vazia desliga.
- P-004 de 07/09 — senha de no mínimo 8 caracteres, que agora mora no realm.
