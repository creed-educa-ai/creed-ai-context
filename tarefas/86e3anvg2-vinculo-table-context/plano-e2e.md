# Plano de teste ponta a ponta — CREED-32, entrega 1

Spec: [`spec.md`](spec.md) · Tasks: [`tasks.md`](tasks.md)

Os testes automáticos provam a regra e o contrato HTTP com dublês. Este roteiro prova o
que eles não alcançam: Postgres e Keycloak de verdade, o seed, e a guarda lendo o papel
do vínculo com um token emitido pelo realm. Roda **uma vez, à mão, antes do PR da
entrega 1**, e o resultado vai para a seção "Como verificar" do PR.

Comandos em Git Bash, na raiz de `creed-backend/`. Tudo roda no banco **local**.

## 0. Antes de começar

**Rode depois de resolver o bloqueio 1 do pré-voo** (branch atualizada com a `dev` e o
`alembic merge` feito). Resolvido em 2026-09-29: merge `0f34b39` e junção
`bb6c81983ecb`.

**Porta do banco.** O `.env` aponta `POSTGRES_PORT=5433`, e há um PostgreSQL nativo do
Windows na 5432 (README, "Já tem um PostgreSQL instalado?"). Depois do merge da `dev`, o
`docker-compose.yml` publica `${POSTGRES_PORT:-5432}`, então lê a 5433 do `.env` sozinho
e **não precisa mais de override**. Confira no 1.1 que o `docker ps` mostra
`5433->5432`.

**Variáveis de apoio**, usadas em todo o roteiro:

```bash
API=http://localhost:8000/api/v1
PSQL="docker compose exec -T db psql -U creed -d creed -tA -c"
ORG_E2E=11111111-1111-1111-1111-111111111111   # organização só deste roteiro
```

## 1. Subir o ambiente

| # | Passo | Esperado |
|---|---|---|
| 1.1 | `docker compose up -d db keycloak` | os dois `Up`; `docker ps` mostra `db` com `5433->5432` |
| 1.2 | `until curl -sf http://localhost:8080/realms/creed/.well-known/openid-configuration >/dev/null; do sleep 3; done; echo ok` | `ok` (o import do realm leva de 30 s a 1 min) |
| 1.3 | `.venv/Scripts/alembic.exe heads` | **uma** linha |
| 1.4 | `.venv/Scripts/alembic.exe upgrade head` | sem erro |
| 1.5 | noutro terminal: `.venv/Scripts/uvicorn.exe app.main:app --reload` | `Application startup complete` |

## 2. Migration do zero, num banco descartável

Critério da spec: "`alembic upgrade head` sobe do zero, em banco vazio". O banco `creed`
já tem dados, então a prova roda num banco à parte, sem tocar no seu. Variável de
ambiente vence o `.env` no pydantic-settings.

**Não use `downgrade -1`.** A head é uma revisão de junção (`bb6c81983ecb`), com dois
pais, e o Alembic recusa o passo relativo com `Ambiguous walk`. Para descer só a
revisão de vínculos, dê o alvo explícito: primeiro a head da `dev` (`22d4bc18cac6`),
depois `b9fa0c109598@-1` ("um passo abaixo, neste ramo").

> **Atualizado em 2026-09-29, depois do segundo merge da `dev`.** A head da branch passou
> a ser `87beb54d929a`, que junta `bb6c81983ecb` com `d0b345d47e55` (forms e
> participants), e `22d4bc18cac6` ficou **abaixo** de `participants` e `forms`: descer até
> ela desce as duas junto. O caminho que só tira a parte de `links` depende do grafo do
> dia. A prova que não depende dele é o ciclo `downgrade base` + `upgrade head` num banco
> descartável, que passou nesse dia com 18 revisões e nenhuma sobra, e o `alembic check`
> sem diferença entre models e migrations.

| # | Passo | Esperado |
|---|---|---|
| 2.1 | `docker compose exec -T db createdb -U creed creed_e2e` | sem saída |
| 2.2 | `POSTGRES_DB=creed_e2e .venv/Scripts/alembic.exe upgrade head` | todas as revisões sobem, inclusive a de merge |
| 2.3a | `POSTGRES_DB=creed_e2e .venv/Scripts/alembic.exe downgrade 22d4bc18cac6 && POSTGRES_DB=creed_e2e .venv/Scripts/alembic.exe downgrade b9fa0c109598@-1` | desfaz só a junção e a `b9fa0c109598`: some `links`, some `user.link_id`, somem os tipos `roles` e `linktype`; `user.role`, `userrole` e as tabelas da `dev` ficam |
| 2.3b | `POSTGRES_DB=creed_e2e .venv/Scripts/alembic.exe upgrade head` | sobe de volta até `bb6c81983ecb` |
| 2.3c | `POSTGRES_DB=creed_e2e .venv/Scripts/alembic.exe downgrade base && POSTGRES_DB=creed_e2e .venv/Scripts/alembic.exe upgrade head` | nenhuma tabela nem tipo enum sobra no meio; as 11 revisões sobem de novo |
| 2.4 | `docker compose exec -T db psql -U creed -d creed_e2e -c '\d links' -c '\d "user"'` | 10 colunas em `links`, 3 índices, sem FK; `user.link_id` nulável com `uq_user_link_id` e `fk_user_link_id_links`; `role` presente |
| 2.5 | `docker compose exec -T db dropdb -U creed creed_e2e` | limpo |

## 3. Usuário sem vínculo não entra (P-008)

O estado de hoje no seu banco é exatamente este: `dev@creed.example.com` existe, com
`link_id` nulo.

| # | Passo | Esperado |
|---|---|---|
| 3.1 | `$PSQL "select link_id is null from \"user\" where email='dev@creed.example.com'"` | `t` |
| 3.2 | `curl -s -o /dev/null -w '%{http_code}\n' -X POST $API/authentication/login -H 'Content-Type: application/json' -d '{"email":"dev@creed.example.com","password":"dev"}'` | **401**. O Keycloak aprova a senha, e o backend recusa porque não há vínculo |

## 4. Seed idempotente

| # | Passo | Esperado |
|---|---|---|
| 4.1 | `.venv/Scripts/python.exe scripts/seed_local.py` | `dev@creed.example.com ganhou o vínculo <uuid> (admin).` |
| 4.2 | `.venv/Scripts/python.exe scripts/seed_local.py` | `... já estava no banco, com o vínculo <mesmo uuid>.` |
| 4.3 | `$PSQL "select count(*), min(role::text) from links"` | `1\|ADMIN` |

## 5. Login, sessão e renovação com o papel do vínculo

```bash
SESSAO=$(curl -s -X POST $API/authentication/login -H 'Content-Type: application/json' \
  -d '{"email":"dev@creed.example.com","password":"dev"}')
TOKEN=$(echo "$SESSAO" | jq -r .access_token)
REFRESH=$(echo "$SESSAO" | jq -r .refresh_token)
LINK_DEV=$($PSQL "select link_id from \"user\" where email='dev@creed.example.com'")
```

| # | Passo | Esperado |
|---|---|---|
| 5.1 | `echo "$SESSAO" \| jq .user` | `role: "admin"`, `link_id` = `$LINK_DEV`, `organization_id: "00000000-0000-0000-0000-000000000001"` |
| 5.2 | `curl -s $API/authentication/session -H "Authorization: Bearer $TOKEN" \| jq` | 200, os mesmos três campos preenchidos |
| 5.3 | `curl -s -X POST $API/authentication/renew -H 'Content-Type: application/json' -d "{\"refresh_token\":\"$REFRESH\"}" \| jq .user` | os mesmos três campos |

## 6. Criar vínculo (só admin)

| # | Passo | Esperado |
|---|---|---|
| 6.1 | `curl -s -o /dev/null -w '%{http_code}\n' -X POST $API/organizations/$ORG_E2E/links -H 'Content-Type: application/json' -d '{"participant_id":"22222222-2222-2222-2222-222222222222","type":"emprego","role":"gestor"}'` | **401** (sem token) |
| 6.2 | o mesmo, com `-H "Authorization: Bearer $TOKEN"` e sem o `-o/-w`, guardando: `LINK_GESTOR=$(... \| jq -r .id)` | **201**; `organization_id` = `$ORG_E2E`, `department_id: null`, `role: "gestor"` |
| 6.3 | o 6.2 com `"type":"inexistente"` | **422** |
| 6.4 | o 6.2 com a URL `$API/organizations/nao-e-uuid/links` | **422** |

## 7. Cadastro de usuário exige vínculo

| # | Passo | Esperado |
|---|---|---|
| 7.1 | `curl -s -X POST $API/users -H 'Content-Type: application/json' -d "{\"name\":\"Gestor E2E\",\"email\":\"e2e.gestor@creed.example.com\",\"keycloak_id\":\"33333333-3333-3333-3333-333333333333\",\"link_id\":\"$LINK_GESTOR\"}" \| jq` | **201**; `role: "gestor"`, `link_id` = `$LINK_GESTOR`, `organization_id` = `$ORG_E2E` |
| 7.2 | `$PSQL "select role from \"user\" where email='e2e.gestor@creed.example.com'"` | `RESPONDENTE`. É a coluna que ninguém lê, e **diverge** da resposta do 7.1, como deve |
| 7.3 | o 7.1 de novo, com outro `email` e outro `keycloak_id` | **409** (vínculo já usado) |
| 7.4 | o 7.1 com `"link_id":"44444444-4444-4444-4444-444444444444"`, outro `email` e outro `keycloak_id` | **404** |
| 7.5 | o 7.1 sem o campo `link_id` | **422** |

## 8. A prova de que `user.role` deixou de ser lida

O critério da spec que "prova que a coluna deixou de ser lida".

| # | Passo | Esperado |
|---|---|---|
| 8.1 | `$PSQL "update \"user\" set role='RESPONDENTE' where email='dev@creed.example.com'"` e depois `curl -s -o /dev/null -w '%{http_code}\n' $API/authentication/session -H "Authorization: Bearer $TOKEN"` | **200**. A coluna mudou, o acesso não |
| 8.2 | `$PSQL "update \"user\" set role='ADMIN' where email='dev@creed.example.com'"` e depois `$PSQL "update links set role='GESTOR' where id='$LINK_DEV'"`, e o mesmo `curl` | **401**, com a coluna dizendo `ADMIN`, igual ao claim |
| 8.3 | terminal do `uvicorn` | linha `Divergência de cargo entre token (['admin', ...]) e vínculo (gestor)` |
| 8.4 | `$PSQL "update links set role='ADMIN' where id='$LINK_DEV'"` e o mesmo `curl` | **200** de novo |

## 9. Opcional: 403 com um token `respondente`

O realm só tem o `dev`, que é `admin`. Para ver o 403 ao vivo, crie no console do
Keycloak (http://localhost:8080, `admin`/`admin`) um usuário com a realm role
`respondente` e senha não temporária, pegue o token dele **direto no Keycloak** e chame
o 6.2 com esse token: **403**, antes de qualquer consulta ao banco. Não faça login pela
API: o usuário existe só no realm, sem linha no `user` nem vínculo, e o login da API
devolve 401 antes de chegar à guarda.

```bash
curl -s -X POST http://localhost:8080/realms/creed/protocol/openid-connect/token \
  -d grant_type=password -d client_id=creed-backend \
  --data-urlencode "client_secret=<KEYCLOAK_CLIENT_SECRET do .env>" \
  --data-urlencode "username=<e-mail do usuário>" --data-urlencode "password=<senha>" \
  | jq -r .access_token
``` O usuário some no próximo
`down -v`, e é assim de propósito (README, "O que muda no realm, muda no arquivo"). O
caso já está coberto por `tests/domains/links/test_router.py` e
`tests/shared/test_authorization.py`.

## 10. Limpeza

```bash
$PSQL "delete from \"user\" where email='e2e.gestor@creed.example.com'"
$PSQL "delete from links where organization_id='$ORG_E2E'"
$PSQL "select count(*) from links"   # 1: o do dev
```

O vínculo do dev **fica**: é o estado certo do banco local depois desta entrega.

## Registro

> **As linhas abaixo são das rodadas de 2026-09-29 com os nomes antigos** (`vinculos`,
> `vinculo_id`, `setor_id`, `vinctype`, rota `/organizacoes/{organization_id}/vinculos`),
> e ficam como foram registradas. Depois da renomeação para `Link`/`Department`
> (ADR-0005), o agente repetiu no mesmo dia, com os nomes novos: o bloco 2 inteiro (as 11
> revisões sobem do zero, a descida só da `b9fa0c109598` apaga `links`, `user.link_id` e
> `linktype`, e o `downgrade base` não deixa sobra), o seed duas vezes (bloco 4), login e
> `/session` com `link_id` (bloco 5), `POST .../links` → 201 e a rota antiga → 404
> (bloco 6), `POST /users` com `link_id` → 201 e com `vinculo_id` → 422 (bloco 7). Os
> blocos 3, 8 e 9 não foram repetidos ao vivo; os testes automáticos que os cobrem
> passaram com os nomes novos.

| Bloco | Resultado | Observação |
|---|---|---|
| 1. Ambiente | ✅ 2026-09-29 | rodado pelo agente (Claude). `db` em `5433->5432` sem override; uma head (`bb6c81983ecb`); `upgrade head` a partir de `b9fa0c109598` num banco com dados; API pelo preview do app |
| 2. Migration do zero | ✅ 2026-09-29 | rodado pelo agente (Claude). 2.2: 11 revisões sobem do zero. 2.3a–c: sem erro, `roles`/`vinctype` apagados no downgrade, `base` sem sobras. 2.4 bate com a spec. O `downgrade -1` original falhou com `Ambiguous walk` (ver nota do bloco 2) |
| 3. Sem vínculo → 401 | ✅ 2026-09-29 | agente. 401 "E-mail ou senha inválidos", e o token direto no realm deu 200: a recusa é do backend, não da senha |
| 4. Seed idempotente | ✅ 2026-09-29 | agente. 1ª execução cria `b7861333…` (admin), 2ª reconhece o mesmo; `1\|ADMIN` |
| 5. Sessão com o vínculo | ✅ 2026-09-29 | agente. login, `/session` e `/renew`: `role: "admin"`, `vinculo_id` do seed, `organization_id` `…0001` |
| 6. Criar vínculo | ✅ 2026-09-29 | agente. 401 · 201 (`organization_id` da URL, `setor_id: null`) · 422 · 422 |
| 7. Cadastro de usuário | ✅ 2026-09-29 | agente. 201 com `role: "gestor"` e a coluna gravando `RESPONDENTE` · 409 · 404 · 422 (`loc: body.vinculo_id`) |
| 8. Coluna não lida | ✅ 2026-09-29 | agente. 200 · 401 com log `Divergência de cargo entre token (['admin']) e vínculo (gestor)` · 200. Login com o vínculo em `GESTOR` deu 200 com `role: "gestor"`, como previsto abaixo. Estado restaurado: coluna e vínculo `ADMIN` |
| 9. 403 (opcional) | ✅ 2026-09-29 | agente. Usuário `e2e.respondente@creed.example.com` criado no realm local pela API de admin; token direto do Keycloak → 403 "Cargo insuficiente", sem SQL no log entre a requisição e a resposta |
| 10. Limpeza | ✅ 2026-09-29 | agente. Apagados o `e2e.gestor` e o vínculo da `ORG_E2E` (1 linha cada); sobra 1 vínculo, o do dev, `ADMIN`. O `e2e.respondente` do bloco 9 continua no realm local até o próximo `down -v` |

## Comportamentos que o roteiro expõe e que não são defeito desta entrega

- **O login não confere o claim contra o vínculo.** No 8.2, um `POST /login` feito
  depois do `update` devolve 200 com `role: "gestor"` na sessão, e toda rota protegida
  responde 401. A conferência token × banco sempre morou só na guarda (CREED-23, D2).
  Antes, era contra `user.role`. O front mostraria a tela de gestor e tomaria 401 em
  seguida.
- **`POST /users` não tem guarda.** Qualquer pessoa cria um usuário, desde que tenha o id
  de um vínculo livre. Vem da CREED-23. Hoje o vínculo só nasce pela mão de um `admin`,
  o que reduz o risco, mas não fecha a porta.
