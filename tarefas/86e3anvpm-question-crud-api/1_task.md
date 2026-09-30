# Task 1 — Tabela `questions` no banco, com o domínio `questions`

**Repo:** `creed-backend`
**Depende de:** nenhuma. **Não** espera a CREED-33.

## Objetivo

A tabela `questions` existe no banco local, criada por uma revisão Alembic própria,
dentro de um domínio novo `questions`, sem nenhuma chave estrangeira.

## Contexto que você não tem como adivinhar

**Pergunta** aqui é um item de um **formulário**: o enunciado, a posição dele no
formulário, se é obrigatório responder, e o tipo. O tipo é `objective` (múltipla
escolha) ou `descriptive` (resposta livre). As alternativas de uma pergunta de múltipla
escolha **não** entram aqui: são outra tabela, da CREED-37.

**A tabela de formulários está sendo criada ao mesmo tempo, em outra tarefa** (CREED-33,
domínio `forms`). Por isso `form_id` é só uma coluna com um identificador, sem ligação de
banco com a tabela `form`. É o mesmo que já foi feito com `form_responses.form_id`. A
ligação entra numa tarefa de **amarração**, depois.

**`prisma`** é uma das cinco dimensões de análise do produto (plasticidade humana,
empreendedorismo, multiculturalismo, neuroinovação, tomada de decisão). A coluna diz a
qual dimensão a pergunta pertence, para que o painel possa agregar respostas por prisma
no banco. Ela aceita vazio.

**`section`** é a parte do formulário em que a pergunta é desenhada na tela. O front lê
o valor e decide em que bloco colocar a pergunta. **Não é o prisma**: a seção organiza a
tela, e o prisma organiza a análise. Uma pergunta tem as duas coisas. A coluna é
obrigatória (P-028).

> 🟡 **Premissa P-020**: os valores `profile`, `assessment` e `closing` são
> **provisórios**. O time decidiu que a seção existe, mas não quais são as seções.
> Implemente com eles e deixe o comentário da premissa em cima do enum. Trocar a lista
> agora, com a tabela vazia, é barato. Trocar depois de gravar perguntas não é.

## Arquivos que provavelmente mudam

- `app/domains/questions/__init__.py`: a pasta do domínio novo
- `app/domains/questions/models.py`: a tabela `questions` e os enums `QuestionType`,
  `Prisma` e `QuestionSection`
- `alembic/env.py`: **o import do model novo** (ver abaixo)
- `alembic/versions/<hash>_create_questions_table.py`: a revisão, gerada e depois lida
- `tests/domains/questions/__init__.py`
- `tests/domains/questions/test_models.py`: trava a forma da tabela

**`app/main.py` não é tocado aqui.** A rota é a task 3.

## Molde

Copie a **forma** de `app/domains/users/models.py`: `Mapped[...]`, `mapped_column`,
`UUID(as_uuid=True)`, o enum declarado como `class X(enum.Enum)` e usado com `Enum(X)`,
e `server_default=func.now()` no horário de criação. **Os campos, não.**

Para o índice único composto, copie `__table_args__` com `UniqueConstraint` de
`app/domains/responses/models.py`, inclusive o nome explícito da constraint
(`uq_questions_form_id_order_index`).

Copie a forma da revisão de `alembic/versions/0b0ad39d779a_create_user_table.py`,
**inclusive o checklist de revisão do docstring**. Ele existe para ser preenchido, não
para ser copiado em branco.

Herde de `Base`, de `app/core/database.py`. **Não crie outra `Base`.**

## A tabela

| Coluna | Tipo | Nulo? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, `default=uuid.uuid4` |
| `form_id` | `UUID` | não | `index=True`, **sem `ForeignKey`** |
| `text` | `Text` | não | sem limite de tamanho |
| `order_index` | `Integer` | não | a posição no formulário |
| `type` | `Enum(QuestionType)` | não | `OBJECTIVE = "objective"` · `DESCRIPTIVE = "descriptive"` |
| `section` | `Enum(QuestionSection)` | não | `PROFILE = "profile"` · `ASSESSMENT = "assessment"` · `CLOSING = "closing"`, **provisórios** (P-020). **Sem `default`** (P-028) |
| `required` | `Boolean` | não | `default=True` |
| `prisma` | `Enum(Prisma)` | **sim** | `PLASTICIDADE_HUMANA`, `EMPREENDEDORISMO`, `MULTICULTURALISMO`, `NEUROINOVACAO`, `TOMADA_DECISAO`, com os valores em minúsculas, iguais ao `.dbml` |
| `created_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |

`__tablename__ = "questions"`, no **plural**. As tabelas `user` e `form` estão no
singular, e isso é um desvio, não um padrão a copiar. O porquê está em
[`spec.md`](spec.md) → "Abordagem técnica", item 2.

`text` é `Text`, e não `String(200)` como no molde: o enunciado de uma pergunta não tem
tamanho previsível (item 4 da spec).

O enum `Prisma` mora **neste** `models.py`. O domínio `prismas` existe, mas o
`models.py` de lá está vazio, e importar de outro domínio é proibido (item 5 da spec).

O enum `QuestionSection` também mora aqui, com o comentário da premissa em cima, na
forma do comentário da P-013 em `users/models.py`:

```python
# 🟡 Premissa P-020 — valores provisórios; o time ainda não definiu as seções.
# Confirmar antes de gravar a primeira pergunta real: depois disso, trocar um valor
# é ALTER TYPE + atualização das linhas + troca das chaves de i18n no front.
class QuestionSection(enum.Enum):
    PROFILE = "profile"
    ASSESSMENT = "assessment"
    CLOSING = "closing"
```

`section` **não** ganha índice. O filtro por seção (task 2) sempre vem junto de
`form_id`, que já tem índice (item 9 da spec).

⚠️ **Enum no Postgres vira um tipo do banco, e o `downgrade()` tem de apagá-lo.** O
autogenerate cria os tipos `questiontype`, `questionsection` e `prisma` junto da tabela,
mas `op.drop_table` não os apaga. Sem isso, `alembic downgrade` seguido de
`alembic upgrade` falha com "type already exists". O molde é a migration da CREED-34,
`alembic/versions/49ef1d2c7b7e_form_response_table.py`, que faz, depois do
`drop_table`:

```python
sa.Enum(name="formresponsestatus").drop(op.get_bind(), checkfirst=True)
```

Aqui são três linhas assim, uma por tipo. **Não** copie o `downgrade()` da
`0b0ad39d779a_create_user_table.py`: ele só apaga a tabela e deixa para trás os tipos
`recordstatus` e `userrole`. É defeito conhecido daquela migration, fora do escopo
desta task.

**O banco guarda o nome do membro, não o valor.** Com `Enum(QuestionSection)`, o
SQLAlchemy cria o tipo com `PROFILE`, `ASSESSMENT` e `CLOSING`, e a API devolve
`profile`, `assessment` e `closing`, porque o Pydantic serializa o valor. É o
comportamento padrão, e é o que `users` e `responses` já fazem: a CREED-34 gerou
`sa.Enum("IN_PROGRESS", "SUBMITTED", ...)`. **Siga o padrão.** Não use `values_callable`
só nesta tabela, porque seria o único enum do banco gravado de outro jeito. Quem
consultar direto no `psql` vai ver maiúsculas, e isso está certo.

**Não** crie: nenhuma `ForeignKey`, e nenhum import de `app.domains.forms`.

## O passo que o autogenerate não perdoa

```python
from app.domains.questions import models as questions_models  # noqa: F401
```

Sem essa linha em `alembic/env.py`, o autogenerate não enxerga o model e **a migration
sai vazia**. Uma migration vazia aplica sem erro, então a falha só aparece quando alguém
tentar gravar.

## Antes de gerar a revisão: confira o head

A CREED-33 está gerando a revisão dela **ao mesmo tempo**, a partir do mesmo head
(`49ef1d2c7b7e`, da CREED-34). As duas vão sair com o mesmo `down_revision`. Isso é
esperado e tem uma saída só:

1. Rode `alembic current` e `alembic heads` **imediatamente antes** de gerar.
2. Gere a revisão normalmente.
3. **Antes de mesclar o PR**, atualize a branch com a `dev` e rode `alembic heads` de
   novo:
   - uma linha → pode mesclar;
   - duas linhas (a CREED-33 mesclou antes) → rode
     `alembic merge -m "merge form and questions heads" <head1> <head2>` e inclua a
     revisão de merge **neste** PR.

**Nunca** edite `down_revision` à mão para "encaixar" uma revisão depois da outra
([`conventions/migrations.md`](../../conventions/migrations.md), regra 3). Quem mescla
por último é quem faz o merge dos heads.

## Critérios de aceite

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] `alembic heads` devolve **um único head** no momento de mesclar.
- [ ] `\d questions` mostra exatamente as nove colunas da tabela acima, com os mesmos
      tipos e a mesma nulabilidade.
- [ ] `section` é `NOT NULL`, **sem** default, e o enum tem só os três valores
      provisórios, com o comentário `🟡 Premissa P-020` em cima.
- [ ] O `downgrade()` apaga a tabela **e os três tipos enum**, e `alembic downgrade -1`
      seguido de `alembic upgrade head` roda sem erro.
- [ ] A tabela **não** tem nenhuma chave estrangeira.
- [ ] Existe índice em `form_id` e a constraint única `uq_questions_form_id_order_index`
      em `(form_id, order_index)`.
- [ ] O model está importado em `alembic/env.py`, e a revisão gerada **não** está vazia.
- [ ] Nenhum arquivo do domínio importa de `app.domains.forms`.
- [ ] O arquivo gerado foi **lido linha a linha**, e o checklist do docstring está
      preenchido.
- [ ] `pytest tests/test_arquitetura.py` passa.

## Como testar

```bash
cd creed-backend
docker compose up -d db
alembic current
alembic heads
alembic revision --autogenerate -m "create questions table"
alembic upgrade head
pytest tests/domains/questions tests/test_arquitetura.py -q
ruff check . && mypy app
```

Conferir a forma no banco:

```bash
docker compose exec db psql -U creed -d creed -c "\d questions"
```

**Caso de borda que precisa passar:** derrubar tudo e subir de novo reproduz exatamente
a mesma estrutura.

```bash
docker compose down -v && docker compose up -d db && alembic upgrade head
```

⚠️ `docker compose down -v` apaga o volume inteiro, e com ele o schema do Keycloak do
ambiente local. Ao subir de novo, é preciso esperar o script de inicialização rodar e
reimportar o realm. Não rode isso no meio de outra tarefa que dependa do login local.

**Segundo caso de borda:** desfazer só esta revisão e refazê-la. É o que prova que o
`downgrade()` apaga os tipos enum. Não mexe no Keycloak:

```bash
alembic downgrade -1 && alembic upgrade head
```

Se o `alembic heads` tiver acabado de ganhar uma revisão de merge (a CREED-33 mesclou
antes), o `-1` desfaz o merge, e não esta revisão. Nesse caso, use
`alembic downgrade <revisão anterior a esta>`.

**O teste desta entrega** (`tests/domains/questions/test_models.py`) não precisa de
banco: ele lê a descrição da tabela direto do código (`Question.__table__`). Ele trava o
que é fácil desfazer sem perceber. Confere que:

- as nove colunas existem, com a nulabilidade da tabela acima;
- `section` não aceita vazio e não tem default;
- os valores de `QuestionSection` são exatamente os três provisórios, para que trocar a
  lista seja uma decisão visível no diff do teste e não um acidente;
- a lista de chaves estrangeiras está vazia;
- existe índice em `form_id`;
- existe a constraint única em `(form_id, order_index)`.

## Premissas aplicáveis

- **P-020**: os valores de `QuestionSection` são provisórios (`profile`, `assessment`,
  `closing`). Aqui isso aparece como o enum e o comentário em cima dele. Se a lista
  mudar antes de haver pergunta gravada, basta editar o enum e regerar esta revisão.
  Depois disso, é migration nova com `ALTER TYPE`.
- **P-028**: a seção é obrigatória. Aqui isso aparece como `nullable=False` sem
  default. Se cair, é uma migration de uma linha.
- A P-019 (só criar e listar) não muda nada na tabela.
