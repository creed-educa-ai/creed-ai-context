# Task 2 — Keycloak no ambiente local com realm versionado

**Repo:** `creed-backend` · **ClickUp:** [CREED-23.2](https://app.clickup.com/t/86e34yf89)
**Depende de:** nenhuma — corre em paralelo à entrega 1

## Objetivo

Keycloak rodando em desenvolvimento com realm, client e papéis definidos em **arquivo
versionado** — nunca clicados na UI — e o backend configurado para falar com ele.

## Por que no `creed-backend` e não no `creed-infrastructure`

O `docker-compose` do ambiente local mora no backend, junto do Postgres e do N8N. O
`creed-infrastructure` é EKS, e **Keycloak no EKS está fora do escopo desta rodada**
(decisão registrada na spec). Colocar o realm lá seria versionar o arquivo longe de quem
o usa todo dia.

## Arquivos que mudam

- `docker/keycloak/realm-creed.json` — o realm: client, papéis, usuário de teste
- `docker/postgres/init-keycloak-schema.sql` — cria o schema `keycloak` no Postgres
- `docker-compose.yml` — serviço `keycloak` + o mount do script de init
- `app/core/config.py` — as settings `KEYCLOAK_*`
- `.env.example` — placeholders
- `README.md` — como subir e como conferir
- `tests/test_realm_keycloak.py` — o review do realm em forma de CI
- `tests/test_config.py` — as settings novas

## Molde

Não há domínio a copiar aqui: a entrega é infraestrutura local. O molde que vale é o
**serviço `n8n` do próprio `docker-compose`** — componente externo no Postgres
compartilhado, em schema dedicado, como o `README.md` do `creed-infrastructure` descreve
para produção.

## Critérios de aceite

- [ ] `docker compose up` sobe com o realm **já importado**, sem nenhum clique na UI.
- [ ] `curl` no token endpoint devolve token para o usuário de teste vindo do export.
- [ ] `docker compose down -v && docker compose up` reproduz o mesmo realm.
- [ ] Client `creed-backend` é confidencial e tem Direct Access Grant (decisão D1).
- [ ] Papéis do realm são `admin`, `gestor`, `respondente` (premissa P-006).
- [ ] `KEYCLOAK_CLIENT_SECRET` **não tem default**: sem ele a aplicação não sobe.
- [ ] Realm sem *default required action* — senão o Direct Access Grant recusa o
      primeiro login de todo usuário com `invalid_grant`.

## Como testar

```bash
pytest
ruff check . && ruff format --check . && mypy app
docker compose up -d db keycloak
curl -s -X POST http://localhost:8080/realms/creed/protocol/openid-connect/token -d grant_type=password -d client_id=creed-backend -d client_secret=creed-local-secret -d username=dev@creed.local -d password=dev
```

Caso feliz: o token endpoint devolve `access_token`.
Caso de borda: `KEYCLOAK_CLIENT_SECRET` ausente derruba a `Settings` no boot.

## Premissas aplicáveis

- **P-006** — os papéis do realm são `admin`, `gestor`, `respondente`.
- **P-010** — `access_token` de 15 min, `refresh_token` de 8 h. Os dois viram tempo de
  sessão no realm.
- **P-012** — o primeiro acesso ainda não é por e-mail; por isso o realm **não** liga
  ação obrigatória e o usuário de teste nasce com senha definitiva.
