# Task 2 — Criar e listar perguntas: regra, acesso a dados e contratos

**Repo:** `creed-backend`
**Depende de:** task 1, porque importa o model `Question` que ela cria

## Objetivo

O service do domínio `questions` cria uma pergunta, recusando uma posição já ocupada no
mesmo formulário, e lista as perguntas de um formulário em ordem, todas ou só as de uma
seção. Tudo com teste, sem banco.

## Contexto que você não tem como adivinhar

**Duas perguntas não podem ocupar a mesma posição no mesmo formulário.** Se já existe
uma pergunta com `order_index = 2` no formulário X, criar outra com `order_index = 2` no
mesmo formulário é conflito. No formulário Y, a posição 2 continua livre. O banco já
proíbe isso (a constraint única da task 1). O service confere **antes**, para devolver
um erro de domínio claro em vez de uma exceção do Postgres.

**O service não confere se o formulário existe.** A tabela de formulários nasce em
paralelo, em outro domínio (CREED-33), e um domínio não importa outro. Por isso, listar
as perguntas de um `form_id` que ninguém criou devolve lista vazia, e não erro. Isso é
decisão consciente, registrada em [`spec.md`](spec.md) → "Abordagem técnica", item 3.

**Nesta rodada, uma pergunta não é editada nem apagada** (P-019). Não crie
`QuestionUpdate` nem métodos de update ou delete.

**A listagem filtra por seção quando pedem, e só quando pedem.** Sem `section`, vêm
todas as perguntas do formulário. Com `section`, só as daquela seção. Nos dois casos a
ordem é `order_index`. A seção **não** entra na regra da posição: duas perguntas do
mesmo formulário em seções diferentes continuam não podendo ter a mesma posição
([`spec.md`](spec.md) → "Abordagem técnica", item 10).

## Arquivos que provavelmente mudam

- `app/domains/questions/schemas.py`: `QuestionCreate` e `QuestionResponse`
- `app/domains/questions/repository.py`: `QuestionRepository`
- `app/domains/questions/service.py`: `QuestionService`
- `tests/domains/questions/test_service.py`

## Molde

- **Schemas:** `app/domains/users/schemas.py`. Entrada e saída são classes separadas, a
  saída tem `model_config = ConfigDict(from_attributes=True)`, e o `@classmethod
  de_model()` monta a saída a partir do model. É o que permite ao router (task 3) não
  importar `models`.
- **Repository:** `app/domains/users/repository.py`. `flush()` e `refresh()` depois de
  gravar, **nunca `commit()`**. Quando não acha, devolve `None`, e nunca levanta erro.
- **Service:** `app/domains/users/service.py`, em especial `create_user_service`. Ele
  pergunta ao repository se o e-mail já existe e levanta `ConflictError` se existir. É
  exatamente a forma da regra da posição.
- **Teste:** `tests/domains/users/test_service.py`. Um repository dublê em memória
  (`FakeUserRepository`) no lugar do real, sem banco.

## Os contratos

**`QuestionCreate`**

| Campo | Tipo | Obrigatório? | Validação |
|---|---|---|---|
| `form_id` | `uuid.UUID` | sim | — |
| `text` | `str` | sim | `Field(min_length=1)` |
| `order_index` | `int` | sim | `Field(ge=0)` |
| `type` | `QuestionType` | sim | — |
| `section` | `QuestionSection` | **sim** | sem padrão (P-028) |
| `required` | `bool` | não | padrão `True` |
| `prisma` | `Prisma \| None` | não | padrão `None` |

**`QuestionResponse`**: `id`, `form_id`, `text`, `order_index`, `type`, `section`,
`required`, `prisma` e `created_at`, com `de_model()`.

**Entre camadas**

| Camada | Assinatura | Devolve |
|---|---|---|
| `repository.insert(question: Question)` | a entidade já montada | `Question` gravada, com `id` e `created_at` |
| `repository.list_by_form(form_id: UUID, section: QuestionSection \| None = None)` | — | `list[Question]`, com `ORDER BY order_index` **na query**; com `section`, um `WHERE section = ...` a mais **na query** |
| `repository.get_by_form_and_order(form_id: UUID, order_index: int)` | — | `Question` ou `None` |
| `service.create(dados: QuestionCreate)` | — | `Question`, ou `ConflictError` |
| `service.list_for_form(form_id: UUID, section: QuestionSection \| None = None)` | — | `list[Question]`; repassa `section` ao repository, sem filtrar nada |

O **service** tem o nome do caso de uso (`create`, `list_for_form`), e o
**repository** tem o nome do acesso (`insert`, `list_by_form`, `get_by_...`). Não
chame o método de service de `get_by_form`: isso é repository disfarçado
([`camadas-do-back.md`](../../conventions/camadas-do-back.md)).

A ordenação e o filtro por seção são feitos **pelo banco**, no `ORDER BY` e no `WHERE`
do repository, e não com `sorted()` ou uma list comprehension no service. O princípio
nº 1 do projeto é que agregação, filtro e ordenação ficam no banco. O `WHERE` de seção
só entra na consulta quando `section` não é `None`:

```python
query = select(Question).where(Question.form_id == form_id)
if section is not None:
    query = query.where(Question.section == section)
query = query.order_by(Question.order_index)
```

## Critérios de aceite

- [ ] `service.create` com dados válidos devolve a pergunta criada, com os campos que
      vieram na entrada.
- [ ] `service.create` sem `required` e sem `prisma` cria a pergunta com
      `required = True` e `prisma = None`.
- [ ] `service.create` levanta `ConflictError` quando já existe pergunta com o mesmo
      `(form_id, order_index)`, e **não** chama `insert`.
- [ ] `service.create` aceita o mesmo `order_index` em **outro** `form_id`.
- [ ] `service.list_for_form` devolve só as perguntas daquele `form_id`.
- [ ] `service.list_for_form` de um `form_id` sem perguntas devolve lista vazia, sem
      levantar erro.
- [ ] `service.list_for_form` com `section` devolve só as perguntas daquela seção; sem
      `section`, devolve todas.
- [ ] `service.create` recusa (`ConflictError`) a mesma posição no mesmo formulário
      **mesmo com seções diferentes**.
- [ ] `QuestionCreate` recusa `text` vazio, `order_index` negativo, `section` ausente e
      `type`/`section` fora do enum (erro de validação do Pydantic).
- [ ] `QuestionResponse` devolve `section`.
- [ ] `service.py` não importa `sqlalchemy` nem `fastapi`. `repository.py` não importa
      `schemas` nem `app.shared.exceptions`.
- [ ] Nenhum `commit()` no diff.
- [ ] `pytest tests/test_arquitetura.py` passa.

## Como testar

```bash
cd creed-backend
pytest tests/domains/questions -q
ruff check . && mypy app && pytest
```

O teste do service usa um `FakeQuestionRepository` em memória, na forma do
`FakeUserRepository`. Ele guarda as perguntas numa lista e não decide nada. Casos que
precisam estar nomeados no arquivo:

- **feliz:** criar uma pergunta e encontrá-la em `list_for_form`;
- **borda:** a segunda pergunta na mesma posição do mesmo formulário levanta
  `ConflictError`;
- **borda:** a mesma posição em formulários diferentes passa;
- **borda:** a mesma posição no mesmo formulário, em seções diferentes, levanta
  `ConflictError`;
- **borda:** listar um formulário sem perguntas devolve `[]`;
- **feliz:** com perguntas em duas seções, listar com `section` devolve só as de uma.

A ordenação por `order_index` **não** é provada aqui, porque ela está na query e o dublê
não roda SQL. Ela é conferida à mão na task 3, de ponta a ponta. O filtro por seção tem
o mesmo limite: o dublê filtra em Python, então o teste prova que o service **repassa**
a seção ao repository, e não que o `WHERE` está certo. Escreva as duas coisas num
comentário no teste, para ninguém achar que estão cobertas.

## Premissas aplicáveis

- **P-019**: esta entrega só cria e lista. Aqui isso aparece como a ausência de
  `QuestionUpdate` e de qualquer método de update ou delete. Se a premissa cair, entram
  um schema, um método de service e um de repository, sem migration.
- **P-020**: os valores de seção são provisórios. Aqui isso aparece só nos testes, que
  usam `QuestionSection.PROFILE` etc. **Use o membro do enum, nunca a string solta**,
  para que trocar a lista não exija caçar texto nos testes.
- **P-028**: a seção é obrigatória. Aqui isso aparece como `section` sem valor padrão em
  `QuestionCreate`.
