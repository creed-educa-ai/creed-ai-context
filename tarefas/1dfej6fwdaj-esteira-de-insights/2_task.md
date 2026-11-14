# Task 2 — `insights` com status, e o envio grava o pedido

**Repo:** `creed-backend`
**Depende de:** task 1

## Objetivo

Enviar uma resposta passa a gravar, na mesma transação, um insight individual `pending`,
com organização e período. A tabela `insights` ganha as colunas, restrições e índices da
spec, seção "Dados".

## Arquivos que provavelmente mudam

- `app/domains/insights/models.py`: enum `InsightStatus` e as colunas novas
- `app/domains/insights/repository.py`: criar o pedido; ler organização e período da
  resposta por JOIN
- `app/domains/insights/service.py`: `request_individual(form_response)` ou nome
  equivalente
- `app/domains/insights/dependencies.py`
- `app/domains/responses/service.py`: `submit_form_response` chama o `InsightService`
- `app/domains/responses/dependencies.py`: o `InsightService` entra na cadeia
- `alembic/versions/<temporária>.py`
- `tests/domains/insights/test_models.py`, `test_repository.py`, `test_service.py`
- `tests/domains/responses/test_service.py`, `test_router.py`
- `tests/test_arquitetura.py`: `responses` compõe com `insights`; `insights` lê
  `form_responses` e `form` por JOIN

## Molde

- `app/domains/users/`: camadas.
- A skill `migration-back` e o ADR-0009: migration temporária, que não sobe no PR como
  definitiva.

## Critérios de aceite

- [ ] O model tem as colunas da spec: `organization_id` e `form_id` (`not null`),
      `form_response_id` nulável, `status`, `attempts`, `next_attempt_at`,
      `dispatched_at`, `last_error`, `content` (`jsonb` nulável), `model_id`,
      `prompt_version` e `completed_at`.
- [ ] Restrições e índices:
  - `CHECK ((status = 'done') = (content IS NOT NULL))`;
  - `UNIQUE (form_response_id)`;
  - `UNIQUE (organization_id, form_id) WHERE form_response_id IS NULL AND status = 'pending'`;
  - índices `(status, next_attempt_at)` e `(organization_id, form_id, created_at)`.
- [ ] A migration temporária sobe e desce no banco local. Ela confere que a tabela está
      vazia e, se não estiver, falha com uma mensagem que diz por quê.
- [ ] `submit_form_response` grava a resposta `submitted` e o insight `pending`, com
      `organization_id` do formulário, `form_id` e `form_response_id`, na mesma
      transação. Se a gravação do insight falhar, a resposta não fica `submitted`.
- [ ] A resposta HTTP do envio não muda: mesmo schema e mesmo status.
- [ ] A exclusão de membro (M-3) continua apagando os insights, e o teste que já existe
      continua verde.
- [ ] `tests/test_arquitetura.py` fica verde com as declarações novas.
- [ ] O PR traz a seção "Banco" com o que mudou e os ajustes manuais da migration
      (o índice parcial e o `CHECK` não saem do autogenerate).

## Como testar

```bash
pytest tests/domains/insights tests/domains/responses tests/test_arquitetura.py -q
alembic upgrade head && alembic downgrade -1 && alembic upgrade head   # banco local
ruff check . && ruff format --check . && pre-commit run mypy --all-files
```

Casos de borda:

- Enviar a mesma resposta duas vezes continua dando 409, e só existe um insight.
- Um `INSERT` direto de um segundo insight para a mesma resposta é recusado pelo
  `unique`.

## Premissas aplicáveis

- P-042: uma resposta enviada, um insight
