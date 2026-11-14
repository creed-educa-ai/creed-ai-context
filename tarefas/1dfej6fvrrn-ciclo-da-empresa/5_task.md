# Task 5 — Aprovar `POST /organizations/{organization_id}/approval`

**Repo:** `creed-backend`
**Subtarefa:** [693 · Aceitar ou rejeitar pedido (E3)](https://app.clickup.com/t/1dfej6fvrvt)
**Branch:** `feat/693-aprovar-empresa`, saída da `feat/696-excluir-empresa`
**Depende de:** task 1 (status `pending` e dados de contato), task 4 (o
`router_organizations.py` com a exclusão, que é a rejeição) e o
**[creed-backend#51](https://github.com/creed-educa-ai/creed-backend/pull/51)**, já na
`dev` (o `MemberService`).

## Objetivo

Aprovar uma empresa pendente torna ela ativa e manda a quem a cadastrou o e-mail de
primeiro acesso como gestor, tudo ou nada.

## Contexto

O **convite** é o e-mail que dá acesso a uma pessoa: um link para ela definir a própria
senha na página do Keycloak (CREED-23.8). Quem convida informa nome, e-mail e papel. O
#51 faz isso numa chamada só, no `MemberService.invite_member_service`: cria
participante, vínculo e acesso e manda o e-mail. Se algo falha, o `get_db` desfaz o
banco e o service desfaz o Keycloak.

A aprovação troca o status para `active` e chama esse mesmo convite, com o nome e o
e-mail que a empresa informou no cadastro, papel `gestor` e vínculo `emprego` (P-053,
P-047). Como tudo acontece na mesma transação, se o convite falha, a troca de status é
desfeita junto, e a empresa continua pendente.

**Rejeitar não é desta task:** é o `DELETE` da task 4.

## Contrato

`POST /api/v1/organizations/{organization_id}/approval`, só `admin`, sem corpo.

| Status | Quando |
|---|---|
| 200 | `OrganizationResponse` com `status: "active"` |
| 401 | sem token |
| 403 | papel `gestor` ou `respondente` |
| 404 | organização inexistente |
| 409 | a empresa não está pendente: `"A empresa ... não está pendente"` |
| 409 | o e-mail do cadastro já tem acesso: a mensagem vem do `create_user_service` (P-077) |
| 503 | o Keycloak ou o envio de e-mail não respondeu; a empresa continua pendente |

## Arquivos que provavelmente mudam

- `app/domains/organizacoes/service.py`
  - `activate_pending(organization_id) -> Organization`: 404 se não existe;
    `ConflictError` se o status não é `PENDING`; senão grava `ACTIVE`.
- `app/domains/users/service.py`, logo depois do `MemberService`:
  - `OrganizationApprovalService.__init__(organizations: OrganizationService,
    members: MemberService)`.
  - `approve(organization_id, *, own_organization_id) -> Organization`:
    1. `organizations.activate_pending(organization_id)`;
    2. se `email` ou `contact_name` vier nulo, `ConflictError` (só uma organização criada
       pelo `POST /organizacoes` não tem, e ela nunca está pendente; a conferência existe
       para o `mypy` e para o caso impossível não virar 500);
    3. `members.invite_member_service(organization.id, MemberInvite(name=contact_name,
       email=email, role=Roles.GESTOR, type=LinkType.EMPREGO), role=Roles.ADMIN.value,
       own_organization_id=own_organization_id)`;
    4. devolve a organização.
  - Docstring: por que a ordem (status antes do convite, mesma transação), e os
    marcadores 🟡 das P-053, P-077 e P-079.
- `app/domains/users/dependencies.py`: `get_organization_approval_service` e
  `OrganizationApprovalServiceDep`, sobre o `MemberService` que o #51 já monta.
- `app/domains/organizacoes/router_organizations.py`
  - `@router.post("/{organization_id}/approval", operation_id="approve_organization")`,
    `require_role("admin")`, delega ao `OrganizationApprovalServiceDep` e monta a
    resposta pelo `with_documents` (task 1). `NotFoundError` → 404, `ConflictError` →
    409, `ServiceUnavailableError` → 503.
- Testes: `tests/domains/users/test_organization_approval_service.py` (novo),
  `tests/domains/organizacoes/test_service.py` e `test_router_organizations.py`.
- `tests/test_arquitetura.py`: o motivo de `organizacoes` acrescenta a aprovação.
- `creed-ai-context/catalogo.md` (a rota) e `glossario.md` (o termo **Convite** cita a
  aprovação de empresa como uma das portas).

## Molde

- `MemberService.invite_member_service` (#51), que esta task chama sem mudar.
- `tests/domains/users/test_member_service.py` (#51): os dublês de participante,
  vínculo e acesso.
- `delete_member` em `app/domains/links/router_members.py`: tradução de erros.

## Critérios de aceite

- [ ] Pendente: devolve a organização ativa, e o dublê do `MemberService` recebeu
      `name` = `contact_name`, `email` do cadastro, `role` `gestor` e `type` `emprego`.
- [ ] Já ativa ou inativa: `ConflictError`, sem chamar o convite.
- [ ] Inexistente: `NotFoundError`, sem chamar o convite.
- [ ] `ConflictError` ou `ServiceUnavailableError` do convite sobem sem tratamento (o
      `get_db` desfaz a troca de status).
- [ ] Rota: 200, 403 (gestor e respondente), 401, e os três erros do service viram 404,
      409 e 503.
- [ ] No local, com o Mailpit: o convite chega a `http://localhost:8025`, o link define a
      senha, e a pessoa entra em `http://localhost:5173/login` como gestor da empresa.
- [ ] No local, com o Mailpit parado: 503, e a empresa continua `pending`, sem
      participante, vínculo nem usuário novo.
- [ ] `ruff`, `pre-commit run mypy --all-files`, `pytest` e `tests/test_arquitetura.py`
      passam.

## Como testar

```bash
cd creed-backend
pytest tests/domains/users tests/domains/organizacoes tests/test_openapi.py tests/test_arquitetura.py -q
pytest
```

```bash
API=http://localhost:8000/api/v1
# depois de um sign-up (task 2), com ORG = id devolvido
curl -s -X POST "$API/organizations/$ORG/approval" -H "Authorization: Bearer $TOKEN_ADMIN"
curl -s -o /dev/null -w "%{http_code}\n" -X POST "$API/organizations/$ORG/approval" -H "Authorization: Bearer $TOKEN_ADMIN"   # 409

# e-mail que já tem acesso: cadastre outra empresa com o e-mail do admin do seed
# (dev@creed.example.com) e aprove → 409; ela continua pendente
```

**O que os testes não provam:** que o rollback do `get_db` desfaz mesmo a troca de status
quando o convite falha. Os testes de service não têm transação. A prova é o passo do
Mailpit parado, no banco local.

## Premissas aplicáveis

- P-053 — o convite vai ao e-mail do cadastro, em nome de quem cadastrou, como `gestor`.
- P-047 — vínculo `emprego`.
- P-077 — e-mail com acesso: 409, e a empresa continua pendente.
- P-079 — só `admin`.
- P-049 — o link vale 72 h; depois disso, o caminho é "Esqueci minha senha".
