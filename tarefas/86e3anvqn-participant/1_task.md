# Task 1 — Domínio `participants` com cadastro e consulta, sem documento

**Repo:** `creed-backend`
**Depende de:** nenhuma

## Objetivo

Um `admin` cadastra um participante só com `name` e o consulta pelo id, pelas rotas
`POST /api/v1/participants` e `GET /api/v1/participants/{participant_id}`, com as camadas
do molde e testes de service e de router.

## Arquivos que provavelmente mudam

- `app/shared/enums.py` (novo): `RecordStatus` sai de `users/models.py`
- `app/domains/users/models.py`, `schemas.py`, `service.py`: importam `RecordStatus` de `app/shared/enums.py`
- `app/domains/participants/__init__.py`, `models.py`, `repository.py`, `service.py`,
  `schemas.py`, `router.py`, `dependencies.py` (novos)
- `app/main.py`: registra o router
- `tests/domains/participants/test_service.py`, `test_router.py` (novos)
- `tests/test_openapi.py`: as duas rotas novas em `expected_operations`

## Molde

`app/domains/users/` (as seis camadas) e `tests/domains/responses/test_router.py` (router
testado com `dependency_overrides` e service falso).

## Critérios de aceite

- [ ] `RecordStatus` mora em `app/shared/enums.py`, e a suíte de `users` passa sem
      mudança de comportamento. O nome do tipo no banco continua `recordstatus`.
- [ ] Model `Participant` (`participants`): `id` (uuid4 no Python), `name` varchar(200)
      not null, `status` `RecordStatus` not null default `ACTIVE`, `created_at` com
      `server_default=now()`, `updated_at` nulável com `onupdate`. **Sem** `document_id`
      (task 2) e sem migration (task 3).
- [ ] `ParticipantCreate`: `name` obrigatório, 1 a 200 caracteres, sem espaços nas pontas.
- [ ] `ParticipantResponse`: `id`, `name`, `status`, `created_at`, `updated_at`, montado
      por `de_model()`, sem o router importar `models`.
- [ ] `POST /api/v1/participants` com `admin` → 201, `status: "active"`.
- [ ] `GET /api/v1/participants/{participant_id}` com `admin` → 200; id inexistente → 404.
- [ ] As duas rotas: sem token → 401; `gestor` ou `respondente` → 403 (P-022).
- [ ] `name` vazio, só espaços ou com mais de 200 caracteres → 422.
- [ ] Swagger no padrão do PR #17 (`summary`, `description`, `operation_id`, exemplos,
      respostas de erro), cobrado por `tests/test_openapi.py`.
- [ ] `tests/test_arquitetura.py` passa sem nova exceção.

## Como testar

```bash
pytest tests/domains/participants tests/domains/users tests/test_arquitetura.py tests/test_openapi.py -q
ruff check . && ruff format --check . && mypy app && pytest
```

Caso feliz: cadastro e consulta com token de `admin`. Bordas: nome só com espaços,
201 caracteres, id inexistente, sem token, papel `respondente`.

Sem tabela no banco (task 3), a rota não roda de ponta a ponta no Swagger local: esta
task é verificada pela suíte.

## Premissas aplicáveis

- P-022 — só `admin` cadastra e consulta participante nesta entrega.
- P-008 — todo cadastro da cadeia Organização → Participante → Vínculo → Usuário é do `admin`.
