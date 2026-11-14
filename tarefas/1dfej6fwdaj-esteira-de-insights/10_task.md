# Task 10 — Dashboards leem o insight individual

**Repo:** `creed-backend`
**Depende de:** task 5 e a `feat/4-dashboard` (Leo Rossol) na `dev`

## Objetivo

`/dashboards/me` e `/dashboards/members/{id}` devolvem, no `creed_summary`, o texto do
insight da resposta do período, com `insight_status` e `generated_at`.

## Arquivos que provavelmente mudam

- `app/domains/dashboards/schemas.py`: `CreedSummaryRead` ganha `insight_status` e
  `generated_at`
- `app/domains/dashboards/repository.py`: lê `insights` por JOIN
- `app/domains/dashboards/service.py`: `_creed_summary` passa a receber o insight
- `tests/domains/dashboards/test_service.py`, `test_router.py`, `test_repository.py`
- `tests/test_arquitetura.py`: a leitura de `dashboards` inclui `insights`

## Molde

O próprio `dashboards/` da `feat/4-dashboard`: é a leitura que ele já faz de
`form_responses` e `answer`.

## Critérios de aceite

- [ ] **Antes de começar:** os dois campos novos do `creed_summary` foram combinados com
      o Leo, que mantém o contrato do dashboard.
- [ ] O `creed_summary` segue o status do insight:
  - `done`: `analiseTexto`, `prismas` e `recomendacaoTexto` vêm do `content`,
    `insight_status` é `done` e `generated_at` é o `completed_at`;
  - `pending` ou `dispatched`: `insight_status` é `pending`, e os textos vêm vazios;
  - `failed`: `insight_status` é `failed`, e os textos vêm vazios;
  - sem insight (por exemplo, uma resposta anterior à esteira): `insight_status` é
    `none`.
- [ ] Destaque e oportunidade continuam saindo do cálculo, e não do insight.
- [ ] `/dashboards/company` continua com os textos vazios e `insight_status = none` até
      a task 14.
- [ ] `dashboards` não importa `insights.service`, e `tests/test_arquitetura.py` fica
      verde.
- [ ] O OpenAPI mostra os campos novos com descrição e exemplo.

## Como testar

```bash
pytest tests/domains/dashboards tests/test_openapi.py tests/test_arquitetura.py -q
ruff check . && ruff format --check . && pre-commit run mypy --all-files
```

## Premissas aplicáveis

- P-086: quem lê o insight individual (a administradora lê o do mentorando em
  `/members/{id}`)
- P-088: forma do insight; destaque e oportunidade vêm do cálculo
