# Task 2 — Trocar o setor de um vínculo (service e repository de `links`)

**Repo:** `creed-backend`
**Depende de:** task 1 (`DepartmentService.get_or_create`)

## Objetivo

`LinkService.update_member_department(...)` troca, escolhe ou tira o setor de um vínculo,
com a regra de acesso completa, e devolve o membro já com nome, e-mail e setor. Sem HTTP:
a rota é a task 3.

## Contexto

Um **membro** é um vínculo (`Link`, o elo entre uma pessoa e uma organização, com papel e
tipo) visto junto com a pessoa: o nome vem de `participants.name`, o e-mail do login
(`user.email`, ligado por `user.link_id`) e o setor de `departments.type`. Vínculo criado
pela rota de vínculos, sem convite, não tem login, e aí o e-mail é `null`.

## Arquivos que provavelmente mudam

- `app/domains/links/schemas.py`
  - `MemberDepartmentUpdate`: `department: DepartmentType | None`, **obrigatório** (sem
    default, então corpo vazio dá 422). Com `extra="forbid"`, para recusar papel, tipo e
    outros campos.
  - `MemberResponse`: `link_id`, `name`, `email: str | None`, `role`, `type`,
    `department: DepartmentType | None`, `updated_at: datetime | None`. Com um
    `from_row(...)` que monta a partir do que o repository devolve. A M-2 vai estender
    este schema com o período, então não ponha nada da C-1 que a M-2 não queira.
- `app/domains/links/repository.py`
  - `get_member(organization_id, link_id)`: **uma** consulta com `Link` + `Participant`
    (inner join) + `User` (outer join por `User.link_id`) + `Department` (outer join),
    filtrando pelos dois ids. Devolve a linha ou `None`.
  - `set_department(link, department_id)`: grava `department_id` e
    `updated_at = func.now()`, depois `flush()` e `refresh()`.
- `app/domains/links/service.py`
  - `update_member_department(organization_id, link_id, department, *, role, own_organization_id) -> MemberRow`,
    nesta ordem:
    1. `role` é `respondente`, ou é `gestor` e `organization_id != own_organization_id`:
       `ForbiddenError`. **Antes** de qualquer busca (P-066).
    2. O vínculo não existe ou é de outra organização: `NotFoundError`, a mesma mensagem
       nos dois casos.
    3. `department` é `None`: `department_id = None`. Senão: `self.departments.get_or_create(organization_id, department)`.
    4. Grava e devolve o membro relido por `get_member`.
  - Para o `admin` em organização inexistente: o vínculo não vai ser achado nessa
    organização, então o passo 2 já dá 404. Não precisa chamar `organization_exists`.
- `tests/domains/links/test_service.py`: casos novos, com dublês.

`ForbiddenError` e `NotFoundError` já existem em `app/shared/exceptions.py`.

## Molde

- `OrganizationService.get` em `app/domains/organizacoes/service.py` (403 antes de 404,
  `role` e `own_organization_id` recebidos de quem pede)
- `LinkService.create_link_service` em `app/domains/links/service.py` (composição com
  `DepartmentService`)
- `tests/domains/links/test_service.py` (`FakeLinkRepository`, `make_link`)

## Critérios de aceite

- [ ] Gestor da empresa escolhe um setor que ela não tinha: `get_or_create` é chamado e o
      vínculo passa a apontar para o setor devolvido.
- [ ] Dois vínculos da mesma empresa no mesmo setor ficam com o mesmo `department_id`.
- [ ] `department=None` tira o setor.
- [ ] `updated_at` é gravado na troca.
- [ ] `gestor` de outra organização: `ForbiddenError`, **sem** chamar o repository.
- [ ] `respondente`, mesmo na própria organização: `ForbiddenError`.
- [ ] `admin` em qualquer organização: troca.
- [ ] Vínculo inexistente e vínculo de outra organização: `NotFoundError`, sem chamar
      `get_or_create`.
- [ ] `MemberDepartmentUpdate` recusa `{}`, `{"department": "Vendas"}` e campo a mais.
- [ ] `ruff`, `mypy`, `pytest` e `tests/test_arquitetura.py` passam (o service não importa
      `sqlalchemy`; o `func.now()` fica no repository).

## Como testar

```bash
cd creed-backend
pytest tests/domains/links/test_service.py -q
pytest tests/test_arquitetura.py -q
ruff check . && ruff format --check . && mypy app
```

Feliz: gestor troca para um setor novo. Bordas: `null`, gestor de fora (o dublê do
repository conta chamadas e prova que não foi chamado), vínculo de outra organização.

**O que os testes não provam:** que a consulta de `get_member` está certa no Postgres (os
joins e o outer join do login). A suíte não roda contra banco. Conferir com o `curl` do
"Como verificar" da spec depois da task 3.

## Premissas aplicáveis

- P-066: o `gestor` troca só na própria organização e o `admin` em qualquer uma. O alvo
  pode ser qualquer vínculo da organização, inclusive o próprio.

## Como ficou (diferenças do plano acima)

- **Leitura por JOIN em `links`.** O ADR-0004 só permitia JOIN entre domínios em domínio
  de leitura. Decisão do Enzo, registrada em adendo ao ADR-0004: `links` entra em
  `LEITURA_ENTRE_DOMINIOS`.
- **`DepartmentType` foi para `app/shared/enums.py`.** O `schemas.py` de `links`
  precisa dele, e o teste de arquitetura não deixa `links` importar o `models.py` de
  outro domínio. É a regra que o `shared/enums.py` já tinha para enum de dois domínios.
- **`updated_at` por `onupdate=func.now()` no model `Link`**, como `organizacoes`,
  `participants` e `demographics` fazem. Não gera migration: é valor do ORM no UPDATE.
- **`set_department` virou `save(link)`.** O service troca o `department_id` e o
  repository só grava, como em `OrganizationRepository.save`.
- **O membro é o dataclass `Member` em `links/service.py`**, como o `UserAccess`. O
  repository devolve uma tupla.
