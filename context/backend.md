# Backend — FastAPI

Stack: **FastAPI · SQLAlchemy · Alembic · Pydantic · pytest · ruff · mypy**.

## Anatomia de um domínio

`app/domains/<nome>/` — molde vivo em `app/domains/respondentes/`. **Leia o molde antes
de escrever o domínio novo.** A tabela abaixo é lembrete, não substituto.

| Arquivo | Faz | Não faz |
|---|---|---|
| `router.py` | rotas, validação de entrada, delega ao service | regra de negócio, query |
| `service.py` | regra de negócio, orquestração | conhecer `Request`/`Response`, montar query |
| `repository.py` | queries, agregações | decidir regra |
| `schemas.py` | Pydantic, **separado por direção** (`...Create`, `...Read`) | lógica |
| `models.py` | tabelas SQLAlchemy | validação de entrada |
| `dependencies.py` | injeção (sessão, service) | — |

Sinal de que a camada furou: `router.py` importando `models`, ou `service.py`
recebendo `Request`.

## Erros

`app/shared/exceptions.py` é o vocabulário de erro. Levante exceção de domínio no
`service.py`; a tradução para HTTP acontece na fronteira, não espalhada pelo código.
Não retorne `dict` de erro do service.

## Testes

- Regra de negócio → teste de `service.py` com repository fake/mock.
- Query e agregação → teste de `repository.py` contra banco real (docker compose).
- Rota → teste de `router.py` só para contrato: status, shape da resposta, validação.

Não teste as três camadas com o mesmo teste de rota; quando quebrar, você não saberá
onde.

## Comandos

```bash
ruff check . && ruff format --check .
mypy app
pytest
```

Setup local, migrations e regras de Alembic: `README.md` do repo e
`../conventions/migrations.md`.
