# Task 2 — Participante com documento

**Repo:** `creed-backend`
**Depende de:** task 1 e o PR #13 (domínio `documents`) na `dev`

## Objetivo

O cadastro de participante aceita `document_id` opcional: recusa documento que não
existe (422) e documento já ligado a outro participante (409), consultando o domínio
`documents` pelo service dele.

## Arquivos que provavelmente mudam

- `app/domains/documents/repository.py` (novo): `get_by_id`
- `app/domains/documents/service.py` (novo): `document_exists(document_id) -> bool`
- `app/domains/participants/models.py`: coluna `document_id` (uuid, nulável, unique, FK → `documents.id`)
- `app/domains/participants/schemas.py`: `document_id` em `ParticipantCreate` e `ParticipantResponse`
- `app/domains/participants/repository.py`: `get_by_document_id`
- `app/domains/participants/service.py`: as duas verificações, antes de inserir
- `app/domains/participants/dependencies.py`: compõe o `DocumentService`
- `tests/test_arquitetura.py`: `"participants": "consulta documento pelo DocumentService"` em `COMPOE_COM_SERVICE_DE`
- `tests/domains/participants/test_service.py`, `test_router.py`
- `tests/domains/documents/test_service.py` (novo)

## Molde

A composição `authentication` → `UserService` (já declarada em `COMPOE_COM_SERVICE_DE`).
Repository e service de `documents` no formato de `app/domains/users/`.

## Critérios de aceite

- [ ] Sem `document_id`: 201, `document_id: null` (P-021).
- [ ] `document_id` de documento existente: 201, e a resposta devolve o mesmo id.
- [ ] `document_id` inexistente: 422.
- [ ] `document_id` já usado por outro participante: 409.
- [ ] `document_id` malformado: 422.
- [ ] `participants` não importa `models.py` de `documents`; a composição está em
      `COMPOE_COM_SERVICE_DE`, e `tests/test_arquitetura.py` passa.
- [ ] Os novos códigos de erro aparecem no Swagger da rota `POST`.

## Como testar

```bash
pytest tests/domains/participants tests/domains/documents tests/test_arquitetura.py tests/test_openapi.py -q
```

Service de `participants` testado com `DocumentService` e repository falsos: documento
existe, não existe, já está em uso.

## Premissas aplicáveis

- P-021 — participante pode nascer sem documento; se vier, o documento precisa existir e
  estar livre. Não há rota para criar documento.

## Antes de começar

Conferir o que o #13 mudou em `documents` depois da review do Luís (nome da tabela,
colunas, enum). Se mudou, ajustar esta task antes de codar.
