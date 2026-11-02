# Task 3 — Adicionar membro numa chamada

**Repo:** `creed-backend`
**Depende de:** task 2.
**Branch sugerida:** `feat/86e35vhxm-convite-de-membro`

## Objetivo

`POST /api/v1/organizations/{organization_id}/members` cria participante, vínculo e
usuário e manda o convite, numa transação (D8). Vale a regra de quem pode convidar quem
(P-045).

## Contexto que você não tem como adivinhar

- **Contrato:**

  | | |
  |---|---|
  | Quem | `require_role("admin", "gestor")`; o `gestor` só na organização do próprio vínculo |
  | Entrada | `MemberInvite { name, email, role, type = "emprego" }`: `name` de 2 a 200 caracteres, sem caractere de controle; `role` é `admin`, `gestor` ou `respondente`; `type` é `emprego`, `mentoria`, `academico` ou `pessoal` |
  | Saída | `UserResponse` · 201, a mesma do `POST /users` |
  | Erros | 401 · 403 (papel; organização alheia; `gestor` convidando `admin`) · 404 (organização não existe) · 409 (e-mail já tem acesso) · 422 · 503 |

- **A ordem em `MemberService.invite_member_service`:**

  ```
  OrganizationService.get(organization_id, role=..., own_organization_id=...)   → 403 / 404
  gestor convidando admin?                                                       → 403
  ParticipantService.create_member_participant(name)
  LinkService.create_member_link(organization_id, participant_id, role, link_type)
  UserService.create_user_service(UserCreate(name=..., email=..., link_id=...))  → D7 (task 2)
  ```

  - O `OrganizationService.get` já faz a conferência da P-033: dá 403 para organização
    alheia antes de olhar se ela existe.
  - O `gestor` convidando `admin` vira `ForbiddenError`.
  - Falha em qualquer passo derruba a transação inteira. A compensação do Keycloak já
    está no `create_user_service`.
- **Por que métodos novos em `participants` e `links`.** O `tests/test_arquitetura.py`
  (`test_dominio_nao_importa_dominio`) só deixa um domínio importar `service` e
  `dependencies` de outro, nunca `schemas` nem `models`. Por isso o `users` não pode montar
  `ParticipantCreate` nem `LinkCreate`. Os donos expõem métodos que montam o próprio
  schema e chamam o método que já existe:
  - `create_member_participant(name: str) -> Participant`;
  - `create_member_link(organization_id, participant_id, role, link_type) -> Link`.
- **`Roles` e `LinkType` vão para `app/shared/enums.py`**, como o `Prisma` foi em
  `c194e0a`. O `users/schemas.py` precisa dos dois e não pode importar `links/models.py`.
  - `links/models.py` passa a importá-los de `shared`, e os imports que já existem
    (`seed_local.py`, testes) continuam funcionando.
  - O tipo no Postgres não muda, porque o nome vem da classe.
  - Na seção "Banco" do PR: "nenhuma mudança de schema; `Roles` e `LinkType` mudaram de
    arquivo" (ADR-0009, item 3).
- **Uma segunda classe em `users/service.py`**, como o `QuestionOptionService`:
  `MemberService(users, participants, links, organizations)`, com `get_member_service` e
  `MemberServiceDep` em `users/dependencies.py`. Não acrescente nada ao `UserService`: a
  guarda de toda rota protegida monta o `UserService`, e ele passaria a montar participante
  e organização a cada requisição.
- **Router próprio, sem prefixo**: `app/domains/users/router_members.py`, como o
  `questions/router_options.py`, registrado no laço de `app/main.py`.
  - A tag é `users`, que já está em `OPENAPI_TAGS`.
  - A descrição da tag passa a citar o convite.

## Arquivos que provavelmente mudam

- `app/shared/enums.py`: `Roles` e `LinkType`.
- `app/domains/links/models.py`: importa os dois de `shared`.
- `app/domains/links/service.py`: `create_member_link`.
- `app/domains/participants/service.py`: `create_member_participant`.
- `app/domains/users/schemas.py`: `MemberInvite`.
- `app/domains/users/service.py`: `MemberService`.
- `app/domains/users/dependencies.py`: `get_member_service` e `MemberServiceDep`.
- `app/domains/users/router_members.py` (novo).
- `app/main.py`: registro do router e descrição da tag `users`.
- `tests/test_arquitetura.py`: o motivo de `users` em `COMPOE_COM_SERVICE_DE` passa a citar
  participante e organização.
- `tests/domains/users/test_member_service.py` e `test_router_members.py` (novos).
- `tests/domains/links/test_service.py` e `tests/domains/participants/test_service.py`: os
  métodos novos.
- `tests/test_openapi.py`: a rota nova na lista e as respostas documentadas.

## Molde

- Segunda classe de service e segundo router no mesmo domínio:
  `app/domains/questions/service.py` (`QuestionOptionService`), `dependencies.py`
  (`OptionServiceDep`) e `router_options.py`.
- 403 de organização alheia decidido no service: `OrganizationService.get`, em
  `app/domains/organizacoes/service.py`.
- Teste de router que passa pela guarda de verdade: `autenticar_como`, em
  `tests/domains/participants/test_router.py`.
- Enum movido para `shared`: o commit `c194e0a`.

## Critérios de aceite

- [ ] O `admin` convida em qualquer organização, com qualquer papel → 201. Participante,
      vínculo e usuário são criados, e o e-mail chega ao Mailpit.
- [ ] Sem `type` no corpo, o vínculo nasce `emprego`.
- [ ] `type: "mentoria"` cria o vínculo com esse tipo.
- [ ] O `gestor` convidando:
  - [ ] na própria organização, como `gestor` ou `respondente` → 201;
  - [ ] em outra organização → 403;
  - [ ] como `admin` → 403.
- [ ] O `respondente` → 403. Sem token → 401.
- [ ] Organização inexistente, pedida pelo `admin` → 404.
- [ ] E-mail que já tem acesso → 409, e participante e vínculo não ficam no banco.
- [ ] `pytest tests/test_arquitetura.py` passa com o motivo novo.
- [ ] Com a consolidação feita, `alembic check` não acusa diferença depois da mudança dos
      enums.

## Como testar

```bash
cd creed-backend
pytest tests/domains/users tests/domains/links tests/domains/participants tests/test_arquitetura.py tests/test_openapi.py -q
ruff check . && ruff format --check . && mypy app && pytest
pre-commit run mypy --all-files

# de ponta a ponta, com o admin de dev logado e a organização do seed
curl -s -w '\n%{http_code}\n' -X POST \
  http://localhost:8000/api/v1/organizations/00000000-0000-0000-0000-000000000001/members \
  -H "Authorization: Bearer <access_token>" -H 'Content-Type: application/json' \
  -d '{"name":"Pessoa Teste","email":"pessoa@creed.example.com","role":"gestor"}'
```

- **Caso feliz:** 201, e o e-mail chega.
- **Casos de borda:**
  - o mesmo e-mail de novo → 409, sem participante novo no banco;
  - o gestor criado acima convidando com `"role":"admin"` → 403.

## Premissas aplicáveis

- P-045 — quem convida quem.
- P-046 — o convite pede o nome.
- P-047 — `emprego` por padrão.
- P-048 — o mentorando é `type: "mentoria"` na organização da CREED. Quem chama é a
  CREED-594.
- P-053 — a aprovação de empresa (CREED-591) chama esta rota com `role: "gestor"`.
- P-033 — recorte por organização.
