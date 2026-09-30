# Task 1 — Banco: as cinco FKs e `answer.form_response_id`

**Repo:** `creed-backend`
**Depende de:** nenhuma.

## Objetivo

O banco passa a recusar vínculo, pergunta, resposta de formulário e resposta que apontem
para algo que não existe, e cada resposta fica presa à sua resposta de formulário.

## Contexto que você não tem como adivinhar

**Os bancos locais do time têm o vínculo do seed apontando para o participante `…0002`,
que não existe.** Por isso a revisão confere os órfãos antes de alterar, e o seed passa a
criar esse participante. A ordem para quem já tem banco: rodar o seed, depois o
`upgrade`. A `participants` já existe na head atual, então o seed novo roda antes da
revisão.

**O seed tem um caminho de saída antecipada** (o usuário de dev já existe → `return`). O
participante precisa ser criado **antes** desse `return`, senão quem já tem o usuário
nunca ganha o participante.

**A conferência vai no Postgres, não no Python.** É o que a `28e9a13197f4` faz
(`DO $$ ... RAISE EXCEPTION ... $$`): funciona também no `alembic upgrade --sql`, e o
`upgrade` inteiro roda numa transação só, então nada fica pela metade. Dentro do `RAISE`,
nada de aspas simples nem `%`.

**`answer` precisa estar vazia.** A coluna nova é `NOT NULL` e não há de onde tirar o
valor. Se houver linha, a revisão para e manda apagar.

**A revisão não insere nem apaga dado** (spec, "Abordagem técnica", item 4).

## Arquivos que provavelmente mudam

- `app/domains/links/models.py`: `participant_id` com
  `ForeignKey("participants.id", name="fk_links_participant_id_participants")`; docstring
  e comentário da coluna passam a dizer que só organização e setor seguem sem FK (D1)
- `app/domains/questions/models.py`: `form_id` com FK para `form.id`; a docstring deixa
  de dizer "sem chave estrangeira"
- `app/domains/responses/models.py`: FKs em `FormResponse.form_id` (`form.id`) e
  `FormResponse.vinculo_id` (`links.id`); em `Answer`, `form_response_id` novo (`NOT NULL`,
  `index=True`, FK para `form_responses.id`) e FK em `question_id` (`questions.id`); saem
  os comentários "tabela ainda não criada"
- `alembic/versions/<rev>_liga_as_tabelas_da_sprint_2.py`: gerada por
  `alembic revision --autogenerate`, lida linha a linha, com a conferência e o checklist
  de revisão na docstring
- `scripts/seed_local.py`: cria o `Participant` `…0002` (nome `NAME`, sem documento) se
  não existir, antes do vínculo e antes do `return` antecipado; o comentário das
  constantes passa a dizer que só a organização segue órfã
- `tests/domains/links/test_models.py`: `test_has_no_foreign_key` vira "a única FK é a de
  `participant_id`"
- `tests/domains/responses/test_models.py`: colunas de `answer` com `form_response_id`;
  FKs esperadas em `answer` e `form_responses`
- `tests/domains/questions/test_models.py`: FK de `form_id`

## Molde

- FK por nome de tabela, com `name=` explícito: `user.link_id` em
  `app/domains/users/models.py`.
- Conferência no Postgres e checklist na docstring:
  `alembic/versions/28e9a13197f4_drop_user_role.py`.

## A conferência

Uma checagem por tabela, cada uma com a própria mensagem, que diz **o que apagar**:

| Tabela | Órfão é |
|---|---|
| `links` | `participant_id` sem linha em `participants`. A mensagem diz para rodar `python scripts/seed_local.py` antes, porque é o caso do vínculo do seed |
| `questions` | `form_id` sem linha em `form` |
| `form_responses` | `form_id` sem linha em `form`, ou `vinculo_id` sem linha em `links` |
| `answer` | qualquer linha |

## Critérios de aceite

- [ ] `alembic heads` mostra uma head só, e ela é a revisão nova, com
      `down_revision = "28e9a13197f4"`.
- [ ] Os nomes das seis FKs são os da tabela "Dados" da spec.
- [ ] Banco com o seed antigo: `upgrade head` para com a mensagem de `links` e não
      altera nada.
- [ ] `python scripts/seed_local.py` e depois `upgrade head`: passa.
      `downgrade -1` e `upgrade head`: passa.
- [ ] Seed rodado duas vezes seguidas: sem erro, e só um participante `…0002`.
- [ ] `\d answer` mostra `form_response_id` `not null`, o índice e as duas FKs.
- [ ] `alembic upgrade 28e9a13197f4:head --sql` gera o SQL sem conectar a banco.
- [ ] Testes de model atualizados, e `pytest` passa.

## Como testar

```bash
cd creed-backend
pytest tests/domains/links tests/domains/questions tests/domains/responses tests/test_models.py -q
alembic heads
# banco local com o seed antigo já rodado:
alembic upgrade head            # tem de parar, com a mensagem de links
python scripts/seed_local.py
alembic upgrade head && alembic downgrade -1 && alembic upgrade head
```

Para ver a conferência de `questions`, insira à mão uma pergunta com `form_id` aleatório
e rode o `upgrade`: ele tem de parar com a mensagem de `questions`.

## Premissas aplicáveis

- Nenhuma. D1: organização e setor seguem sem FK.
