# Task 1 — Empresa pendente: status, dados de contato e documento na leitura

**Repo:** `creed-backend`
**Subtarefa:** [691 · Empresa pendente (E1)](https://app.clickup.com/t/1dfej6fvrvn)
**Branch:** `feat/691-empresa-pendente`, saída da `dev`
**Depende de:** nenhuma

## Objetivo

A organização passa a ter o status `pending` e a guardar e-mail, responsável e telefone,
e toda leitura de organização devolve esses campos e o número do documento.

## Contexto

Uma **organização** é a empresa cliente (ou a própria CREED, P-048). Hoje o status é o
`RecordStatus` (`active`/`inactive`), um tipo do banco compartilhado com `user` e
`participants`. "Pendente" é a empresa que se cadastrou sozinha e ainda não foi aprovada
pela administradora. O valor novo não pode vazar para login e participante, por isso a
organização ganha um enum só dela (spec, Abordagem técnica, item 1).

O documento (CPF, CNPJ…) mora na tabela `documents`, e a organização só guarda o
`document_id`. A tela da administradora mostra o **número**, então a resposta passa a
trazê-lo, lido do `DocumentService` numa consulta só por chamada, qualquer que seja o
número de organizações.

## Arquivos que provavelmente mudam

- `app/domains/organizacoes/models.py`
  - `OrganizationStatus(enum.Enum)`: `PENDING = "pending"`, `ACTIVE = "active"`,
    `INACTIVE = "inactive"`.
  - `status`: `Enum(OrganizationStatus, name="organization_status")`, padrão
    `OrganizationStatus.ACTIVE`.
  - `email` (`String(320)`), `contact_name` (`String(200)`) e `phone` (`String(30)`),
    todos `nullable=True`.
- `app/domains/organizacoes/schemas.py`
  - `OrganizationDocument`: `type: str` (o valor do `DocType`: `cpf`, `cnpj`…) e
    `value: str`.
  - `OrganizationResponse`: `status: OrganizationStatus`; `email`, `contact_name`,
    `phone: str | None`; `document: OrganizationDocument`. Atualize o exemplo.
  - `de_model(organization, document_type, document_value)`: passa a receber o
    documento. **Não importe o `service.py` aqui**: o service já importa o
    `schemas.py`, e seria import circular.
  - `OrganizationUpdate.status` continua `RecordStatus`. É isso que impede o `PATCH` de
    mandar `pending`.
- `app/domains/organizacoes/service.py`
  - `OrganizationWithDocument` (dataclass, como o `Member` de `links`):
    `organization`, `document_type: str`, `document_value: str`.
  - `with_documents(organizations) -> list[OrganizationWithDocument]`: uma chamada a
    `DocumentService.list_by_ids`, na ordem recebida.
  - `create`: grava `OrganizationStatus.ACTIVE`.
  - `update`: se a organização está `PENDING` e o corpo traz `status`, levanta
    `ConflictError("A empresa está pendente: aprove ou rejeite o cadastro")`. Nome e
    endereço continuam editáveis (P-075). O `RecordStatus` recebido vira
    `OrganizationStatus(valor.value)` antes do `setattr`.
  - `get`, `organization_exists` e `list_page` **não mudam de assinatura**. O
    `MemberService` do #51 chama o `get`.
- `app/domains/organizacoes/router.py`: as quatro rotas montam a resposta passando pelo
  `with_documents`. O `PATCH` documenta o 409 novo.
- `app/domains/documents/repository.py` e `service.py`: `list_by_ids(ids) -> list[Document]`.
- `scripts/seed_local.py` (linha ~307): a organização do seed grava
  `OrganizationStatus.ACTIVE`, não `RecordStatus.ACTIVE`.
- Testes: `tests/domains/organizacoes/test_models.py` (o teste da coluna hoje confere
  `RecordStatus`), `test_service.py`, `test_router.py`, e
  `tests/domains/documents/test_service.py`.
- `tests/test_arquitetura.py`: o motivo de `organizacoes` em `COMPOE_COM_SERVICE_DE`
  passa a dizer "lê os documentos pelo DocumentService".
- `creed-ai-context/catalogo.md`: a linha de `organizacoes` cita o status `pending` e os
  campos novos.

**Migration temporária (ADR-0009):** gere no banco local, **escreva à mão** a troca de
tipo (o autogenerate não a escreve direito), teste, faça `alembic downgrade` e só então
apague o arquivo. A seção "Banco" do PR copia os quatro passos da spec (Dados):
`CREATE TYPE`, `ALTER ... USING status::text::organization_status`, as três colunas sem
`server_default`, e o downgrade que troca `pending` por `inactive` antes de voltar o tipo.

⚠️ **Divergência conhecida:** `scripts/convidar_primeiro_admin.py`, do creed-backend#53
(aberto), também grava `RecordStatus.ACTIVE` na organização da CREED (linha ~159). Quem
mergear por último troca para `OrganizationStatus.ACTIVE`. Diga isso no PR.

## Molde

- `DocType` e a coluna `type` em `app/domains/documents/models.py`: enum do domínio com
  nome de tipo no banco.
- `Member` em `app/domains/links/service.py`: dataclass de leitura montado no service.

## Critérios de aceite

- [ ] O teste do model confere que `status` usa `OrganizationStatus` com o tipo
      `organization_status`, e que `user.status` e `participants.status` continuam
      `RecordStatus`.
- [ ] `GET /organizacoes` e `GET /organizacoes/{id}` devolvem `email`, `contact_name`,
      `phone` e `document: {type, value}`. Numa organização sem contato, os três vêm
      `null`.
- [ ] Listar uma página com 3 organizações faz **uma** chamada a
      `DocumentService.list_by_ids` (o dublê conta).
- [ ] `PATCH` com `status` numa pendente: 409, e nada muda. Com só `name`: 200, e ela
      continua pendente. `PATCH` com `{"status": "pending"}`: 422.
- [ ] `POST /organizacoes` continua criando organização ativa, com o mesmo corpo.
- [ ] Com a migration temporária aplicada, `python scripts/seed_local.py` roda sem erro.
- [ ] `ruff`, `pre-commit run mypy --all-files` e `pytest` passam.

## Como testar

```bash
cd creed-backend
pytest tests/domains/organizacoes tests/domains/documents tests/test_arquitetura.py -q
ruff check . && ruff format --check .
pre-commit run mypy --all-files
pytest
```

No banco local, com a migration temporária aplicada:

```bash
docker compose exec db psql -U creed -d creed -c "\dT+ organization_status"
docker compose exec db psql -U creed -d creed -c "\d organizations"
curl -s "http://localhost:8000/api/v1/organizacoes" -H "Authorization: Bearer $TOKEN_ADMIN"
```

**O que os testes não provam:** que a migration troca o tipo sem perder o status das
linhas que já existem. Confira no banco local: antes e depois do `upgrade`, o mesmo
`status` em cada organização.

## Premissas aplicáveis

- P-075 — nome e endereço de uma pendente continuam editáveis pelo `PATCH`.
- Nenhuma outra: o resto desta task é técnico.
