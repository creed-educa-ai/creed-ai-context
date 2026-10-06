# Migrations — Alembic

> Ver ADR-002 §2.4 e [ADR-0009](../decisoes/adrs/0009-migration-consolidada-por-sprint.md).
> Este é o assunto com maior chance de perda de dado no projeto.
> A IA **propõe**; um humano **lê linha a linha** antes de qualquer commit.

> O modelo de dados que as migrations materializam vive em
> [`../context/modelo-de-dados.md`](../context/modelo-de-dados.md) — leia o status dele
> antes de gerar qualquer revisão.

## Duas migrations, dois donos

| | Migration **temporária** | Migration **consolidada** |
|---|---|---|
| Quem gera | quem desenvolve a tarefa | um AGES III, uma ou mais vezes por sprint |
| Para quê | testar a tarefa no banco local | levar o schema acumulado da `dev` para o repositório |
| Vai para o repositório? | **nunca**: sai com `downgrade` antes do PR | sim, na branch `chore/<id>-consolidar-migrations` |
| O que leva para frente | a seção **"Banco"** do PR | ela mesma |

PR de tarefa muda `models.py` e **não traz arquivo em `alembic/versions/`**. O CI
recusa o PR que trouxer.

## As sete regras

1. **Autogenerate nunca vai para o repositório sem leitura linha a linha.**
   Renomear coluna vira `drop` + `create` e **perde dados**. Vale também para a
   temporária: é lendo ela que você descobre o que escrever na seção "Banco".
2. **Migration passa por code review, com prioridade.** O PR de consolidação é sempre
   Sensível.
3. **Conflito de heads**: use `alembic merge`. Nunca edite `down_revision` à revelia.
   Com a consolidação ele vira exceção, não rotina.
4. **No deploy: passo dedicado do pipeline**, nunca no startup do container.
5. **Rollback**: corrija avançando com nova migration, não com `downgrade`. O
   `downgrade` da temporária é a única exceção: ela nunca saiu da sua máquina.
6. **Mudança destrutiva em passos**: adicionar → migrar dados → remover. Os passos
   caem em **consolidações diferentes**, e a seção "Banco" diz em qual passo o PR está.
7. **PR de tarefa sobe sem migration, e o banco local volta ao head da `dev`.**
   `alembic current` precisa mostrar o mesmo que `alembic heads` antes de você abrir
   o PR.

## A seção "Banco" do PR

É o único canal entre quem entendeu a mudança e quem vai escrevê-la. Um PR que muda
`models.py` diz:

- **o que mudou**: tabela, coluna, tipo, índice, constraint;
- **o que o autogenerate não sabe**, ou seja, todo ajuste que você fez à mão na
  temporária: rename (`op.alter_column(..., new_column_name=...)`), backfill,
  `server_default` em tabela com linhas, passo de mudança destrutiva;
- **"nenhum ajuste manual"**, quando é o caso. Seção vazia não vale.

## Fluxo da tarefa

```bash
alembic heads                                     # anote: é o head da dev
alembic revision --autogenerate -m "descricao"   # temporária, SEMPRE revisar
alembic upgrade head                              # testar a tarefa
# ... antes do PR:
alembic downgrade <head-da-dev>                   # PRIMEIRO desce
rm alembic/versions/<arquivo-temporario>.py       # DEPOIS apaga
alembic current                                   # tem que bater com alembic heads
```

## Fluxo da consolidação (AGES III)

Passo a passo em [`../playbooks/criar-migration.md`](../playbooks/criar-migration.md).
Em resumo: branch saída da `dev`, autogenerate, ajustes das seções "Banco", leitura
linha a linha, `alembic check` limpo. **Release `dev` → `main` só depois dela.**

## O que revisar no arquivo gerado

- [ ] Algum `drop_column` / `drop_table` que deveria ser rename?
- [ ] `nullable=False` em coluna nova de tabela com dados? Precisa de default ou de
      três passos.
- [ ] `down_revision` aponta para o head correto?
- [ ] Índice de coluna que entrou em `WHERE`/`JOIN` de agregação?
- [ ] Tipo bate com o `models.py` (e o `models.py` bate com o `schemas.py`)?
- [ ] O `downgrade()` está coerente — mesmo sabendo que não vamos usá-lo?

## Para a IA

PR de tarefa: gere a migration temporária para testar, mas **o arquivo não entra no
diff que você entrega**. Encerre dizendo o que escrever na seção "Banco" e lembrando
o `downgrade` antes de apagar.

Ao gerar ou alterar migration que **vai** para o repositório (consolidação), **sempre**
encerre a resposta com:

```
⚠️ Migration precisa de leitura humana linha a linha antes do commit.
Pontos de atenção: <lista>
```

Nunca rode `alembic upgrade` contra banco que não seja o local do usuário.
