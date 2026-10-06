# Playbook: criar migration

> **Playbook de maior risco do projeto.** A IA propõe; **um humano lê linha a linha**
> antes do commit. Regras em `../conventions/migrations.md`; o porquê do fluxo em
> [ADR-0009](../decisoes/adrs/0009-migration-consolidada-por-sprint.md).

São dois fluxos. **Na tarefa** a migration é temporária e não sobe. **Na consolidação**
um AGES III gera a que sobe.

## A. Na tarefa — migration temporária

1. Partir da `dev` atualizada e anotar o head dela:
   ```bash
   alembic heads
   ```
   Se a `dev` tem model sem tabela (alguém mergeou depois da última consolidação), a
   sua temporária vai trazer essas mudanças também. Isso é esperado, e elas saem
   junto no passo 7.
2. Alterar `models.py`.
3. Gerar:
   ```bash
   alembic revision --autogenerate -m "descricao"
   ```
4. **Abrir o arquivo gerado e ler inteiro.** O autogenerate transforma rename em
   `drop_column` + `add_column`, e isso **perde dados**. Todo ajuste que você fizer à
   mão aqui é exatamente o que vai para a seção "Banco" do PR.
5. Conferir a checklist abaixo, aplicar e testar:
   ```bash
   alembic upgrade head
   pytest
   ```
6. Escrever a seção **"Banco"** do PR (`../templates/pr-template.md`): o que mudou
   no schema e cada ajuste manual do passo 4, ou "nenhum ajuste manual".
7. **Antes de abrir o PR, limpar.** Primeiro desce, depois apaga, porque sem o
   arquivo o Alembic não acha a revisão para desfazer:
   ```bash
   alembic downgrade <head-da-dev-do-passo-1>
   rm alembic/versions/<arquivo-temporario>.py
   alembic current        # tem que mostrar o mesmo head do passo 1
   git status             # nada em alembic/versions/
   ```
   Esqueceu e o CI recusou? Repita o passo 7 e empurre de novo.

## B. Na consolidação — AGES III

1. Tarefa no ClickUp e branch saída da `dev` atualizada, com o contexto
   **`consolidar-migrations`**. É o nome que o CI reconhece:
   ```bash
   git switch -c chore/<id-clickup>-consolidar-migrations
   ```
2. Banco local no head da `dev`: `alembic current` igual a `alembic heads`. Tem
   temporária aplicada? Faça o passo A.7 antes.
3. Levantar o que entrou desde a última consolidação, que é o último commit da `dev`
   em `alembic/versions/`:
   ```bash
   BASE=$(git log -1 --format=%h origin/dev -- alembic/versions/)
   git log --oneline "$BASE"..origin/dev -- 'app/domains/*/models.py'
   ```
   Para cada PR mergeado, leia a seção **"Banco"** e o **diff de `models.py`**. Não
   leia só o texto: seção incompleta vira `drop` + `add` em silêncio.
4. Gerar:
   ```bash
   alembic revision --autogenerate -m "consolida migrations da sprint N"
   ```
5. Aplicar sobre o gerado os ajustes que as seções "Banco" pediram: rename como
   `op.alter_column(..., new_column_name=...)`, backfill, `server_default`. Passo de
   mudança destrutiva que ainda depende de dado migrado fica para a próxima
   consolidação.
6. Ler inteiro e conferir a checklist abaixo.
7. Validar, de preferência num banco local **com dados**, que é o que pega
   `nullable=False` sem default:
   ```bash
   alembic upgrade head
   alembic check          # "No new upgrade operations detected."
   alembic heads          # um só
   pytest
   ```
8. Abrir o PR como **Sensível** (`../checklists/revisao-de-codigo.md`). O CI aplica
   tudo num Postgres limpo e roda `alembic check` de novo.
9. Depois do merge, avisar o time: quem tem temporária aplicada faz A.7 e depois
   `alembic upgrade head`. **Release `dev` → `main` só depois deste merge.**

## Checklist do arquivo gerado

- [ ] Nenhum `drop_column` / `drop_table` que deveria ser rename
      (`op.alter_column(..., new_column_name=...)`)
- [ ] Coluna nova `nullable=False` em tabela com dados? → precisa de `server_default`
      ou de três passos
- [ ] `down_revision` aponta para o head correto
- [ ] Índice criado para coluna que entrou em `WHERE`/`JOIN`/`GROUP BY`
- [ ] Tipo bate com `models.py`, que bate com `schemas.py`
- [ ] `downgrade()` coerente (mesmo sem uso previsto)
- [ ] Mudança destrutiva quebrada em passos: adicionar → migrar dados → remover
- [ ] Na consolidação: cada ajuste pedido numa seção "Banco" está no arquivo

## Conflito de heads

Com a consolidação, só acontece se duas consolidações correrem em paralelo, ou se
alguém subir migration fora dela. Se acontecer:

```bash
alembic merge -m "merge heads" <head1> <head2>
```

Nunca edite `down_revision` na mão para "resolver".

## Encerramento obrigatório

Na tarefa (fluxo A), a resposta de IA termina com o texto proposto para a seção
"Banco" e o lembrete do passo A.7.

Na consolidação (fluxo B), toda resposta de IA que gera ou altera migration termina com:

```
⚠️ Migration precisa de leitura humana linha a linha antes do commit.
Pontos de atenção: <lista concreta, não genérica>
```

E nunca rode `alembic upgrade` contra banco que não seja o local do usuário.
