# Task 4 — O worker

**Repo:** `creed-backend`
**Depende de:** task 3

## Objetivo

Um processo próprio, `python -m app.workers.insights`, despacha os insights `pending`
para o N8N no ritmo dos settings, com backoff, limite de tentativas e varredura. Dois
workers ao mesmo tempo não perdem nem duplicam nada.

## Arquivos que provavelmente mudam

- `app/core/database.py`: uma unidade de trabalho para quem não é requisição, com o
  mesmo commit e rollback do `get_db`
- `app/core/config.py`: os `INSIGHT_*` do ADR-0010, item 3
- `app/workers/__init__.py` e `app/workers/insights.py`
- `app/domains/insights/repository.py`: reivindicar com `FOR UPDATE SKIP LOCKED`,
  contar os `dispatched`, varrer os esquecidos
- `app/domains/insights/service.py`: um ciclo do worker, o backoff e o limite de
  tentativas
- `docker-compose.yml`: o serviço `insight-worker`, com a mesma imagem do back e outro
  comando
- `tests/test_database.py`
- `tests/workers/test_insights.py`
- `tests/domains/insights/test_service.py`
- `tests/domains/insights/test_repository_postgres.py`
- `tests/test_arquitetura.py`: a mensagem do `test_commit_so_no_get_db` passa a citar a
  unidade de trabalho

## Molde

- ADR-0010, item 3 e a tabela "Como isto encaixa nas regras do back".
- `get_db` em `app/core/database.py`.
- `tests/domains/forms/test_periods_postgres.py`: forma do teste contra Postgres de
  verdade, ligado por `RUN_POSTGRES_TESTS=1`.

## Critérios de aceite

- [ ] Com `N8N_WEBHOOK_URL` vazia, o ciclo não reivindica nada, registra no log que a
      esteira está desligada e não gasta tentativa. É o estado do ambiente local.
- [ ] Nunca há mais `dispatched` que `INSIGHT_MAX_IN_FLIGHT`.
- [ ] Uma falha do client devolve o insight a `pending`, com `next_attempt_at` em 30 s,
      1 min, 2 min e 4 min. Na 5ª tentativa, vira `failed`, com `last_error`.
- [ ] A varredura devolve a `pending` o `dispatched` mais antigo que
      `INSIGHT_DISPATCH_TIMEOUT_SECONDS`.
- [ ] **Teste de concorrência, contra Postgres:** 100 insights `pending`, dois ciclos ao
      mesmo tempo e um client falso. Cada insight é despachado uma vez, nenhum se perde,
      e o teto é respeitado. É o teste de carga que o ADR-0010 pedia, sem N8N.
- [ ] `.commit()` só aparece em `app/core/database.py`, e o
      `test_commit_so_no_get_db` fica verde.
- [ ] O worker é porta de entrada, como o router: abre a unidade de trabalho, chama o
      `InsightService` e mais nada. Backoff, limite e varredura moram no service.
- [ ] Com `SIGTERM`, o worker termina o ciclo em curso e fecha o client e a sessão.
- [ ] `docker compose up insight-worker` sobe e fica parado, com o log "esteira
      desligada", porque o local não tem `N8N_WEBHOOK_URL`.

## Como testar

```bash
pytest tests/workers tests/domains/insights tests/test_database.py tests/test_arquitetura.py -q
RUN_POSTGRES_TESTS=1 pytest tests/domains/insights/test_repository_postgres.py -q
docker compose up -d db && docker compose up insight-worker
ruff check . && ruff format --check . && pre-commit run mypy --all-files
```

## Premissas aplicáveis

- P-042: uma resposta enviada, um insight
