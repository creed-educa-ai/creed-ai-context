# Task 1 — Tabela `answer` no banco, com o domínio `responses`

**Repo:** `creed-backend`
**Depende de:** nenhuma

## Objetivo

A tabela `answer` existe no banco local, criada por uma revisão Alembic própria, dentro
de um domínio novo `responses` — sem nenhuma chave estrangeira.

## Contexto que você não tem como adivinhar

**Resposta** aqui é a marcação de **uma** pergunta: uma linha por pergunta respondida, não
uma linha por formulário. Quem guarda "fulano respondeu o formulário X" é outra tabela
(`form_response`), que ainda não existe — é a CREED-34.

Uma pergunta pode ser **objetiva** (a pessoa marca uma alternativa) ou **descritiva** (a
pessoa escreve). Por isso há duas colunas de resposta e **as duas são nuláveis**:
`option_id` é preenchida na objetiva, `value` na descritiva. Nunca as duas, nunca
nenhuma — mas quem cobra isso é o service, na task 2, não o banco.

O motivo de a objetiva **não** ser texto livre: contar quantas pessoas escolheram cada
alternativa sobre texto digitado viraria contagem de coisa que cada pessoa escreve de um
jeito.

## Arquivos que provavelmente mudam

- `app/domains/responses/__init__.py` — pasta do domínio novo
- `app/domains/responses/models.py` — a tabela `answer`
- `alembic/versions/<hash>_create_answer_table.py` — a revisão, gerada e depois lida
- `tests/domains/responses/__init__.py`
- `tests/domains/responses/test_models.py` — trava a forma da tabela

## Molde

| Copie a forma de | Para |
|---|---|
| `app/domains/respondentes/models.py` | como a tabela é declarada: `Mapped[...]`, `mapped_column`, `UUID(as_uuid=True)`, `server_default=func.now()` |
| `alembic/versions/0b0ad39d779a_create_user_table.py` | a forma da revisão — inclusive o **checklist de revisão no docstring**, que é para preencher, não para copiar em branco |

Herde de `Base`, de `app/core/database.py`. **Não crie outra `Base`.**

## A tabela

| Coluna | Tipo | Nulo? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, `default=uuid.uuid4` |
| `question_id` | `UUID` | não | **sem `ForeignKey`** nesta rodada |
| `option_id` | `UUID` | sim | resposta **objetiva** |
| `value` | `String` | sim | resposta **descritiva** |
| `created_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |

Índice: `question_id`.

**Não** crie: a coluna `form_response_id`, nenhuma `ForeignKey`, nenhum `unique`.
As três coisas entram na tarefa de amarração, e o porquê está em
[`spec.md`](spec.md) → "Abordagem técnica".

## Critérios de aceite

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] `alembic heads` devolve **um único head**. Se devolver dois, a saída é
      `alembic merge` — **nunca** editar `down_revision` à mão.
- [ ] `\d answer` mostra exatamente as cinco colunas acima, com os mesmos tipos e a mesma
      nulabilidade.
- [ ] A tabela **não** tem nenhuma `ForeignKey` e **não** tem `form_response_id`.
- [ ] Existe índice em `question_id`.
- [ ] `down_revision` aponta para o head que existia quando você gerou a revisão —
      confirmado com `alembic current` **antes** de gerar.
- [ ] A revisão gerada foi **lida linha a linha**, e você consegue dizer o que cada
      comando faz. O checklist no docstring da revisão está preenchido.
- [ ] `pytest tests/test_arquitetura.py` passa — o domínio novo não fura camada.

## Como testar

```bash
cd creed-backend
docker compose up -d db
alembic current
alembic revision --autogenerate -m "create answer table"
alembic heads
alembic upgrade head
pytest tests/domains/responses tests/test_arquitetura.py -q
ruff check . && mypy app
```

Conferir a forma no banco:

```bash
docker compose exec db psql -U creed -d creed -c "\d answer"
```

**Caso de borda que precisa passar** — derrubar tudo e subir de novo reproduz exatamente
o mesmo banco:

```bash
docker compose down -v && docker compose up -d db && alembic upgrade head
```

⚠️ `docker compose down -v` apaga o volume inteiro, e com ele o schema `keycloak` do
ambiente local — quem subir de novo espera o `init-keycloak-schema.sql` rodar e reimporta
o realm. Rode com isso em mente, não no meio de outra tarefa que dependa do login local.

### O teste que acompanha esta task

`tests/domains/responses/test_models.py` não precisa de banco: lê o metadata do
SQLAlchemy (`Answer.__table__`). Ele trava o que é fácil de regredir sem ninguém notar —
alguém "ajudando" e acrescentando a `ForeignKey` antes da amarração, ou apertando
`option_id`/`value` para `NOT NULL`:

- as cinco colunas existem, com a nulabilidade da tabela acima;
- `Answer.__table__.foreign_keys` está **vazio**;
- existe índice em `question_id`.

## Premissas aplicáveis

- **P-014** — uma resposta válida tem exatamente uma das duas formas preenchida:
  `option_id` (objetiva) **ou** `value` (descritiva). Aqui isso aparece só como
  **as duas colunas serem nuláveis**; quem recusa a linha vazia é o service, na task 2.
  🟡 Aberta — confirmar na próxima reunião com a cliente.
- **P-015** — uma pergunta objetiva aceita uma alternativa, mas a tabela **não** ganha
  `unique (form_response_id, question_id)`: sem o índice, abrir para múltipla seleção
  depois não custa migration nenhuma. 🟡 Aberta.

## Antes de abrir o PR

⚠️ Migration precisa de leitura humana linha a linha antes do commit.
Pontos de atenção: `down_revision` apontando para o head certo · nenhuma `ForeignKey`
tendo entrado pelo autogenerate · `downgrade()` derrubando só o que esta revisão criou ·
`alembic heads` com um head só.
