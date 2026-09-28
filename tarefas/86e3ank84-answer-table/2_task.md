# Task 2 — Registrar uma resposta: repository, service e schemas

**Repo:** `creed-backend`
**Depende de:** [task 1](1_task.md) — importa o model `Answer` que ela cria

## Objetivo

O domínio `responses` sabe gravar uma resposta válida e recusar uma inválida, e sabe
buscar uma resposta pelo id — tudo por baixo, sem porta HTTP.

## Contexto que você não tem como adivinhar

**Não há endpoint nesta rodada, e isso é de propósito.** A rota nasce junto da submissão
(CREED-34), quando `form_response` existir. Um `POST /api/v1/answers` hoje receberia um
`form_response_id` que não dá para validar contra nada, e gravaria linha órfã. Por isso
**`app/main.py` não é tocado** — não procure onde registrar o router.

A regra de negócio desta task é uma só, e é a razão de ela existir: **uma resposta válida
tem exatamente uma das duas formas preenchida.** `option_id` se a pergunta era objetiva,
`value` se era descritiva. As duas vazias é linha sem significado, e o service recusa.

> ⚠️ A subtarefa publicada no board ([CREED-312](https://app.clickup.com/t/86e3anpp5))
> diz *"texto vazio deve ser recusado"*. **Não siga essa frase**: ela trata `value` como
> o único jeito de responder e recusaria toda resposta objetiva, que tem `value` nulo por
> desenho. O porquê está em [`spec.md`](spec.md) → "Abordagem técnica", item 4.

## Arquivos que provavelmente mudam

- `app/domains/responses/repository.py` — acesso ao dado
- `app/domains/responses/service.py` — a regra
- `app/domains/responses/schemas.py` — Pydantic, separado por direção
- `app/domains/responses/dependencies.py` — cadeia sessão → repository → service
- `tests/domains/responses/test_service.py` — os quatro casos

## Molde

| Copie a forma de | Para |
|---|---|
| `app/domains/respondentes/repository.py` | `AsyncSession`, `select(...)`, `scalar_one_or_none()`, e o `add` + `flush` + `refresh` do `create` |
| `app/domains/respondentes/service.py` | service recebendo o repository no `__init__`, levantando exceção de `app/shared/exceptions.py` |
| `app/domains/respondentes/schemas.py` | schemas separados por direção, e o `model_config = ConfigDict(from_attributes=True)` na saída |
| `app/domains/respondentes/dependencies.py` | `get_repository` → `get_service` → `ServiceDep` |
| `tests/domains/authentication/test_service.py` | a forma do teste: **dublê no lugar do repository**, sem banco |

**Tudo `async`** — o molde é `async`, não é escolha.

## O que deve nascer, nomeado

| Camada | Assinatura | Devolve |
|---|---|---|
| `repository.insert(answer: Answer)` | entidade já montada | `Answer` persistido, com `id` e `created_at` do banco |
| `repository.get_by_id(answer_id: UUID)` | — | `Answer` **ou `None`** |
| `service.record(dados: AnswerCreate)` | payload validado | `Answer` criado, ou `ValidationError` |
| `service.get(answer_id: UUID)` | — | `Answer`, ou `NotFoundError` |

Schemas: `AnswerCreate` (`question_id`, `option_id` opcional, `value` opcional) e
`AnswerResponse` (`id`, `question_id`, `option_id`, `value`, `created_at`).

Duas regras de camada que o teste de arquitetura cobra, e que são o erro mais comum aqui:

- **`repository.get_by_id` devolve `None`** quando não acha. Quem levanta `NotFoundError`
  é o service — repository que levanta erro de domínio é dado decidindo regra.
- **Nenhum `commit()`.** O repository faz `flush()` + `refresh()`. Quem fecha a transação
  é o `get_db`, no fim da requisição. `commit()` fora de `app/core/database.py` é sinal
  declarado de camada furada.

Os nomes seguem [`conventions/camadas-do-back.md`](../../conventions/camadas-do-back.md)
→ "Nome do método diz de qual camada é": o service nomeia o caso de uso (`record`), o
repository nomeia o acesso (`insert`, `get_by_id`).

## Critérios de aceite

- [ ] `service.record` **aceita** resposta com `option_id` preenchido e `value` nulo.
- [ ] `service.record` **aceita** resposta com `value` preenchido e `option_id` nulo.
- [ ] `service.record` **recusa**, com `ValidationError`, a resposta com as duas vazias.
- [ ] `service.record` **recusa** `value` que só tem espaço em branco — string em branco
      não é resposta descritiva.
- [ ] `service.get` levanta `NotFoundError` quando o id não existe.
- [ ] `repository.get_by_id` devolve `None` no mesmo caso — não levanta.
- [ ] Nenhum `commit()` no diff, fora de `app/core/database.py`.
- [ ] `service.py` não importa `fastapi` nem `sqlalchemy`.
- [ ] `repository.py` não importa `schemas`.
- [ ] `pytest tests/test_arquitetura.py` passa.

## Como testar

```bash
cd creed-backend
pytest tests/domains/responses -q
ruff check . && mypy app && pytest
```

**Caso feliz:** gravar uma resposta objetiva (`option_id` preenchido) e uma descritiva
(`value` preenchido) — as duas voltam com `id` e `created_at`.

**Casos de borda, nomeados:** as duas formas vazias → `ValidationError` · `value` só com
espaço em branco → `ValidationError` · `get` de um id que não existe → `NotFoundError` ·
`repository.get_by_id` do mesmo id → `None`.

Os testes usam **dublê no lugar do repository**, como
`tests/domains/authentication/test_service.py`: não há `conftest.py` nem banco de teste
no projeto, e a regra desta task é testável sem tocar em Postgres.

## Premissas aplicáveis

- **P-014** — uma resposta válida tem exatamente uma das duas formas preenchida:
  `option_id` (objetiva) **ou** `value` (descritiva). Linha com as duas vazias é
  recusada; pergunta pulada não gera linha. **É a regra que esta task implementa.**
  Se a cliente refutar, o que muda é a condição em `service.record` — nenhum dado se
  perde na volta. 🟡 Aberta — confirmar na próxima reunião.
- **P-015** — uma pergunta objetiva aceita uma alternativa, mas isso **não** vira índice
  nem validação nesta task: a regra vive no service de submissão, que ainda não existe.
  Aqui ela só explica por que nada impede duas linhas para a mesma pergunta. 🟡 Aberta.
