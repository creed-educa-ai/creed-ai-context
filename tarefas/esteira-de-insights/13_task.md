# Task 13 — Insight da empresa: gatilho e payload

**Repo:** `creed-backend`
**Depende de:** task 4 e a `feat/4-dashboard` na `dev`

## Objetivo

O envio de uma resposta agenda o insight da empresa quando o período chega ao piso, sem
duplicar, e o worker monta para ele o payload agregado.

## Arquivos que provavelmente mudam

- `app/domains/insights/service.py`: agenda o pedido e monta o payload da empresa
- `app/domains/insights/repository.py`: conta as respostas enviadas de (organização,
  período) e grava com `INSERT … ON CONFLICT DO NOTHING`
- `app/domains/dashboards/service.py`: um método que devolve os números agregados do
  período, se o que existe não servir
- `app/external_services/n8n/schemas.py`: o modelo da ida com `scope = "organization"`
- `app/core/config.py`: `INSIGHT_ORG_MIN_RESPONSES` e `INSIGHT_ORG_DEBOUNCE_SECONDS`
- `docker/n8n/contrato/exemplo-ida-empresa.json` e o `ida.schema.json` regerado
- `tests/domains/insights/test_service.py` e `test_repository_postgres.py`
- `tests/external_services/n8n/test_contrato.py`
- `tests/test_arquitetura.py`: `insights` compõe com `dashboards`

## Molde

- A task 2: a gravação do pedido no envio.
- A task 3: a montagem do payload.

## Critérios de aceite

- [ ] O gatilho segue o piso e a espera:
  - com 4 respostas enviadas no período, nada é agendado;
  - na 5ª, nasce um `pending` com `next_attempt_at` 30 min à frente;
  - 10 envios dentro da janela não criam outro.
- [ ] Com um insight da empresa `dispatched`, um envio novo agenda o próximo `pending`.
- [ ] **Contra Postgres:** dois envios simultâneos criam um `pending` só, e nenhum dos
      dois envios falha.
- [ ] O payload da empresa:
  - valida contra o kit;
  - tem os mesmos números do dashboard da empresa no período;
  - em `departments`, traz só os setores com 5 ou mais respostas;
  - não traz nenhum texto livre de respondente (P-090).
- [ ] O kit tem o `exemplo-ida-empresa.json`, e o teste de divergência dos schemas
      continua verde.
- [ ] Um questionário individual de mentorando (formulário com `link_id`) nunca agenda
      insight da empresa.
- [ ] O `dashboards` continua sem importar `insights.service`.

## Como testar

```bash
pytest tests/domains/insights tests/external_services/n8n tests/test_arquitetura.py -q
RUN_POSTGRES_TESTS=1 pytest tests/domains/insights/test_repository_postgres.py -q
ruff check . && ruff format --check . && pre-commit run mypy --all-files
```

## Premissas aplicáveis

- P-089: insight da empresa por período, com piso de 5 e espera de 30 min
- P-090: nenhum texto livre no insight da empresa
