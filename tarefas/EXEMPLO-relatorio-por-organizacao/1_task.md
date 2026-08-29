# Task 1 — Endpoint agregado de adesão

**Repo:** `creed-backend`
**Depende de:** nenhuma

## Objetivo

`GET /api/v1/relatorios/adesao` devolve, por organização, total de respondentes, total
de conclusões e percentual — agregado no banco.

## Arquivos que provavelmente mudam

- `app/domains/relatorios/repository.py`
- `app/domains/relatorios/service.py`
- `app/domains/relatorios/schemas.py`
- `app/domains/relatorios/router.py`
- `tests/domains/relatorios/test_repository.py`
- `tests/domains/relatorios/test_service.py`

## Molde

`app/domains/respondentes/` — mesma divisão de camadas.

## Critérios de aceite

- [ ] Agregação em SQL (`COUNT` + `GROUP BY`), não em Python.
- [ ] Organização sem respondente vem com zeros (LEFT JOIN), não some.
- [ ] `percentual_adesao` calculado no `service.py`; divisão por zero tratada.
- [ ] `AdesaoRead` só para saída — sem schema servindo entrada e saída.

## Como testar

```bash
docker compose up -d db
pytest tests/domains/relatorios -q
```

Casos: organização com respondentes e conclusões · organização com respondentes e zero
conclusões · organização sem respondente algum.

## Premissas aplicáveis

- P-00X — respondente inativo conta no total.
