# Task 14 — Insight da empresa: leitura e exclusão

**Repo:** `creed-backend`
**Depende de:** tasks 10 e 13

## Objetivo

`/dashboards/company` sem recorte mostra o último insight pronto do período, com a
data. Os recortes por setor e por pessoa ficam sem texto. A exclusão de empresa passa a
apagar os insights dela.

## Arquivos que provavelmente mudam

- `app/domains/dashboards/repository.py` e `service.py`: a leitura do insight da
  empresa
- `app/domains/insights/service.py` e `repository.py`: apagar os insights de uma
  organização
- `app/domains/users/service.py`: o `OrganizationRemovalService` chama a exclusão nova
- `tests/domains/dashboards/test_service.py` e `test_router.py`
- `tests/domains/insights/test_service.py`
- `tests/domains/users/test_service.py`: o teste da E-6

## Molde

- A task 10: a mesma leitura, agora para o escopo da empresa.
- A exclusão de membro (M-3): a ordem de apagar os insights antes do que eles apontam.

## Critérios de aceite

- [ ] O dashboard da empresa sem recorte mostra o insight assim:
  - o `done` mais recente de (organização, período), com `generated_at`;
  - um `pending` mais novo não esconde o `done` anterior;
  - sem nenhum `done`, `insight_status` é o do mais recente;
  - sem nenhum insight, `insight_status` é `none`.
- [ ] Com recorte por setor ou por `member_id`, `insight_status` é `none`.
- [ ] A administradora, ao escolher uma empresa, vê o mesmo que a gestora dela.
- [ ] A E-6 apaga os insights da empresa (`form_response_id` nulo) **antes** dos
      questionários. O teste confere que não sobra nenhum insight da organização.
- [ ] `dashboards` continua sem importar `insights.service`.

## Como testar

```bash
pytest tests/domains/dashboards tests/domains/insights tests/domains/users tests/test_arquitetura.py -q
ruff check . && ruff format --check . && pre-commit run mypy --all-files
```

## Premissas aplicáveis

- P-086: a gestora lê só o agregado
- P-089: insight da empresa por período
