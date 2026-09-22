# Task 1 — Tabela `form` no banco, com o domínio `forms`

**Repo:** `creed-backend`
**Depende de:** nenhuma

## Objetivo

A tabela `form` existe no banco local, criada por uma revisão Alembic própria, dentro de
um domínio novo `forms` — sem nenhuma chave estrangeira.

## Contexto que você não tem como adivinhar

**Formulário** aqui é o **instrumento** que a plataforma aplica: um conjunto de perguntas
que uma pessoa responde. Esta tarefa cria **só a casca** dele — nome, dono e estado. As
perguntas são outra tabela (`question`, CREED-35), e o registro de "fulano abriu e
respondeu o formulário X" é outra ainda (`form_response`, CREED-34, em review).

**O dono do formulário é a organização, não uma pessoa.** Isso é correção registrada do
modelo de dados (`[C1]`): o diagrama original tinha uma coluna de "criador" apontando
para pessoa, e ela caiu. Quem pode editar e publicar sai do papel da pessoa **naquela
organização**, não de uma coluna nesta tabela.

**O formulário nasce sempre em rascunho (`draft`).** Um formulário publicado sem nenhuma
pergunta não faz sentido, e as perguntas ainda não existem como tabela. Os outros dois
estados (`published`, `closed`) existem no tipo desde já porque o modelo os prevê — mas
nada nesta rodada leva um formulário até eles.

**A coluna de nome não está no modelo de dados do time, e entra mesmo assim.** O diagrama
não tem título nem descrição para o formulário, e essa lacuna está registrada em aberto
lá. Decidimos acrescentar: sem nome, um gestor escolheria um formulário numa lista pelo
identificador aleatório. Como a tabela nasce vazia, tirar a coluna depois custa uma
migration de uma linha. Ver "Decisões já tomadas que valem aqui".

## Arquivos que provavelmente mudam

- `app/domains/forms/__init__.py` — pasta do domínio novo
- `app/domains/forms/models.py` — a tabela `form` e o tipo `FormStatus`
- `alembic/env.py` — **o import do model novo** (ver abaixo, é o erro mais fácil de
  cometer aqui)
- `alembic/versions/<hash>_create_form_table.py` — a revisão, gerada e depois lida
- `tests/domains/forms/__init__.py`
- `tests/domains/forms/test_models.py` — trava a forma da tabela

**`app/main.py` não é tocado.** Não há rota nesta entrega — ela é a task 3.

## Molde

Copie a forma de `app/domains/users/models.py`: como a tabela é declarada
(`Mapped[...]`, `mapped_column`, `UUID(as_uuid=True)`), como o tipo enumerado é declarado
(`class RecordStatus(enum.Enum)` + `Enum(RecordStatus)` na coluna) e como o horário de
criação aparece (`server_default=func.now()`). **Os campos, não** — aqueles são de outro
assunto.

Copie a forma da revisão de `alembic/versions/0b0ad39d779a_create_user_table.py`,
inclusive o **checklist de revisão no docstring do topo**: ele é para preencher, não para
copiar em branco.

Herde de `Base`, de `app/core/database.py`. **Não crie outra `Base`.**

## A tabela

| Coluna | Tipo | Nulo? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, `default=uuid.uuid4` |
| `name` | `String(200)` | não | acrescentada ao modelo — ver P-016 |
| `organization_id` | `UUID` | não | **sem `ForeignKey`** nesta rodada |
| `status` | `Enum(FormStatus)` | não | `DRAFT` · `PUBLISHED` · `CLOSED`, `default=FormStatus.DRAFT` |
| `created_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |

Índice: `organization_id`.

`FormStatus` é um `enum.Enum` declarado no próprio `models.py`, com os valores
`draft`, `published` e `closed` — mesma forma que `RecordStatus` e `UserRole` têm no
molde.

**Não** crie: a coluna `participant_id`, nenhuma `ForeignKey`, nenhum `unique`. As
três coisas entram na tarefa de amarração, e o porquê está em [`spec.md`](spec.md) →
"Abordagem técnica".

## O passo que o autogenerate não perdoa

`alembic/env.py` tem um comentário em caixa alta dizendo isto, e ainda assim é o erro
mais comum:

```python
from app.domains.forms import models as forms_models  # noqa: F401
```

Sem essa linha o autogenerate não enxerga o model e **a migration sai vazia** — e vazia
ela aplica sem erro, o que faz a falha aparecer só quando alguém for gravar.

## Antes de gerar a revisão: confira o head

A CREED-34 está **em review** com a revisão `49ef1d2c7b7e`, gerada a partir do mesmo head
de onde esta vai sair (`0b0ad39d779a`). Rode `alembic current` **imediatamente antes** de
gerar:

- head é `0b0ad39d779a` → gere normalmente;
- head é `49ef1d2c7b7e` (a CREED-34 já mesclou) → gere normalmente, e o `down_revision`
  desta nasce apontando para ela;
- `alembic heads` devolveu **duas linhas** → a saída é `alembic merge`. **Nunca** edite
  `down_revision` à mão.

## Critérios de aceite

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] `alembic heads` devolve **um único head**.
- [ ] `\d form` mostra exatamente as cinco colunas da tabela acima, com os mesmos tipos e
      a mesma aceitação de vazio.
- [ ] A tabela **não** tem nenhuma chave estrangeira e **não** tem `participant_id`.
- [ ] Existe índice em `organization_id`.
- [ ] O model está importado em `alembic/env.py`, e a revisão gerada **não** está vazia.
- [ ] `down_revision` aponta para o head que existia quando o arquivo foi gerado —
      conferido com `alembic current` **antes** de gerar.
- [ ] O arquivo gerado foi **lido linha a linha**, e o checklist do docstring está
      preenchido.
- [ ] `pytest tests/test_arquitetura.py` passa.

## Como testar

```bash
cd creed-backend
docker compose up -d db
alembic current
alembic revision --autogenerate -m "create form table"
alembic heads
alembic upgrade head
pytest tests/domains/forms tests/test_arquitetura.py -q
ruff check . && mypy app
```

Conferir a forma no banco:

```bash
docker compose exec db psql -U creed -d creed -c "\d form"
```

**Caso de borda que precisa passar** — derrubar tudo e subir de novo reproduz exatamente
a mesma estrutura:

```bash
docker compose down -v && docker compose up -d db && alembic upgrade head
```

⚠️ `docker compose down -v` apaga o volume inteiro, e com ele o schema do Keycloak do
ambiente local — ao subir de novo é preciso esperar o script de inicialização rodar e
reimportar o realm. Rode sabendo disso, não no meio de outra tarefa que dependa do login
local.

**O teste desta entrega** (`tests/domains/forms/test_models.py`) não precisa de banco: lê
a descrição da tabela direto do código (`Form.__table__`). Ele trava o que é fácil de
alguém desfazer sem perceber — uma chave estrangeira acrescentada antes da amarração, ou
`participant_id` voltando. Confere: as cinco colunas existem com a nulabilidade acima ·
a lista de chaves estrangeiras está vazia · não existe coluna `participant_id` · existe
índice em `organization_id`.

## Premissas aplicáveis

- **P-016** — o formulário tem **nome**: coluna `name`, obrigatória, **sem unicidade**.
  Dois formulários com o mesmo nome na mesma organização são aceitos. Aqui isso aparece
  como a coluna existir e não ter índice único. Se a premissa cair, é uma migration de
  uma linha e nenhum dado se perde.
- **P-017** — o formulário nasce sempre `draft`. Aqui isso aparece só como o `default` da
  coluna; quem aplica a regra é o service, na task 2.
- **P-018** — formulário é da organização, não de uma pessoa: `participant_id` não entra.
  Se cair, acrescentar coluna nulável depois é migration de uma linha, sem backfill.
