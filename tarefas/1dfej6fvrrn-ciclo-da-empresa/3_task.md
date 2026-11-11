# Task 3 — Exclusão de empresa no banco (`OrganizationRemovalService`)

**Repo:** `creed-backend`
**Subtarefa:** [696 · Excluir empresa (E6)](https://app.clickup.com/t/1dfej6fvrvw)
**Branch:** `feat/696-excluir-empresa`, saída da `feat/692-cadastro-de-empresa`
**Depende de:** task 1 (status e `document_id` da organização). A M-3 (exclusão de
membro) já está na `dev`.

## Objetivo

`OrganizationRemovalService.remove_organization(...)` apaga uma empresa inteira, com
todos os membros e tudo o que pende dela, e só no fim tira os logins do Keycloak.

## Contexto

Um **membro** é um vínculo (`Link`) de uma pessoa com a organização. A M-3 já sabe
apagar um membro com tudo o que é dele, e deixou isso pronto **para esta task**: o
`MemberRemovalService.delete_member_data` apaga a parte do banco de um membro e devolve o
`keycloak_id` do login, e o `remove_logins_from_keycloak` apaga uma lista de logins no
realm, antes do commit (P-073). Os docstrings dos dois citam a E-6.

O que sobra depois dos membros é da organização: os questionários "para todos"
(`form.link_id` nulo), com perguntas, alternativas e alguma resposta que ainda aponte
para eles; os setores (`departments`); a própria organização; e o documento dela.

A ordem é a das chaves estrangeiras, de quem aponta para quem é apontado, porque o banco
recusa apagar uma linha que outra ainda referencia. Cada tabela é apagada pelo service
do dono (ADR-0004, item 4).

Empresa **pendente** não tem membro nem questionário: para ela, isto apaga só a
organização e o documento. É a **rejeição** (P-078).

## Arquivos que provavelmente mudam

Métodos novos nos donos. Todos sem regra de acesso: quem chama já conferiu.

| Arquivo | Método novo | Faz |
|---|---|---|
| `app/domains/links/service.py` e `repository.py` | `list_organization_link_ids(organization_id) -> list[uuid.UUID]` | ids dos vínculos da organização |
| `app/domains/forms/service.py` e `repository.py` | `list_organization_form_ids(organization_id)` e `delete_organization_forms(form_ids)` | o segundo chama o `delete_by_ids` que já existe |
| `app/domains/responses/service.py` e `repository.py` | `list_ids_for_forms(form_ids)` | ids das respostas desses questionários |
| `app/domains/department/service.py` e `repository.py` | `delete_for_organization(organization_id)` | apaga os setores |
| `app/domains/participants/service.py` e `repository.py` | `document_in_use(document_id) -> bool` | algum participante aponta para o documento? |
| `app/domains/documents/service.py` e `repository.py` | `delete_document(document_id)` | apaga o documento |
| `app/domains/organizacoes/service.py` e `repository.py` | `delete_organization(organization)` | apaga a organização |

Reaproveite sem mudar: `InsightService.delete_for_form_responses`,
`DashboardService.delete_for_member_removal(response_ids, None)`,
`FormResponseService.delete_with_answers` e `QuestionService.delete_for_forms` (que já
apaga as alternativas antes das perguntas).

- `app/domains/users/service.py`, logo depois do `MemberRemovalService`:
  - `OrganizationRemovalService.__init__(members: MemberRemovalService, organizations,
    links, forms, questions, responses, insights, dashboards, departments, participants,
    documents)`.
  - `remove_organization(organization_id, *, own_organization_id) -> None`:
    1. `organization_id == own_organization_id` →
       `ConflictError("Não é possível excluir a própria organização")`, **antes de
       qualquer consulta** (P-079);
    2. `organizations.get(organization_id, role=Roles.ADMIN.value,
       own_organization_id=own_organization_id)`: 404 se não existe;
    3. para cada id de `list_organization_link_ids`: `members.delete_member_data(...)`,
       juntando os `keycloak_id` que não forem `None`;
    4. `list_organization_form_ids` → `list_ids_for_forms` → insights → dashboards →
       `delete_with_answers` → `delete_for_forms` → `delete_organization_forms`;
    5. `departments.delete_for_organization`;
    6. guarda o `document_id` e chama `organizations.delete_organization`;
    7. se `not participants.document_in_use(document_id)`: `documents.delete_document`;
    8. `members.remove_logins_from_keycloak(keycloak_ids)`, por último.
  - Docstring: a ordem e por quê, os marcadores 🟡 das P-078, P-079 e P-080, e a janela
    do Keycloak herdada da P-073.
- `app/domains/users/dependencies.py`: `get_organization_removal_service` e
  `OrganizationRemovalServiceDep`. Recebe o `MemberRemovalService` pelo
  `get_member_removal_service` que já existe, mais os `ServiceDep` de `organizacoes`,
  `department` e `documents`.
- `tests/domains/users/test_organization_removal_service.py` (novo), e um teste por
  método novo nos `test_service.py` de cada dono.
- `tests/test_arquitetura.py`: o motivo de `users` em `COMPOE_COM_SERVICE_DE` cita a
  exclusão de empresa (E-6) e os donos novos (`organizacoes`, `department`, `documents`).

## Molde

- `MemberRemovalService.delete_member_data` em `app/domains/users/service.py`: a mesma
  forma, um nível acima.
- `tests/domains/users/test_member_removal_service.py`: os dublês que registram a ordem
  das chamadas numa lista só, e os testes de "etapa do banco" e "etapa do realm" que já
  citam a E-6.

## Critérios de aceite

- [ ] A própria organização: `ConflictError`, **sem nenhuma chamada** a nenhum dublê.
- [ ] Organização inexistente: `NotFoundError`, sem nenhuma exclusão.
- [ ] Empresa com dois membros: `delete_member_data` chamado uma vez por vínculo, e
      `remove_logins_from_keycloak` **uma vez só**, por último, com os dois logins.
- [ ] Membro sem login (`delete_member_data` devolve `None`): fica fora da lista do
      Keycloak.
- [ ] A ordem registrada pelos dublês é a dos passos 3 a 8 acima.
- [ ] Empresa pendente (sem vínculo nem questionário): apaga organização e documento, e
      chama o Keycloak com lista vazia.
- [ ] Documento usado por um participante: a organização sai, o documento fica.
- [ ] `ServiceUnavailableError` do Keycloak sobe sem ser tratado (o `get_db` desfaz o
      banco, P-073).
- [ ] `ruff`, `pre-commit run mypy --all-files`, `pytest` e `tests/test_arquitetura.py`
      passam.

## Como testar

```bash
cd creed-backend
pytest tests/domains/users tests/domains/links tests/domains/forms tests/domains/responses tests/domains/sector tests/domains/participants tests/domains/documents tests/domains/organizacoes tests/test_arquitetura.py -q
ruff check . && ruff format --check .
pre-commit run mypy --all-files
```

**O que os testes não provam:** que a ordem satisfaz as chaves estrangeiras do Postgres.
Os testes não falam com o banco (ADR-0009). A prova é o `DELETE` de uma empresa com
membros e respostas no banco local, depois da task 4.

## Premissas aplicáveis

- P-078 — rejeitar é isto, para uma pendente; o documento sai junto.
- P-079 — a própria organização é recusada (409).
- P-080 — o que sai, e o documento só se nenhum participante apontar para ele.
- P-072 e P-073 — herdadas da M-3, pelo `delete_member_data` e pelo
  `remove_logins_from_keycloak`.
