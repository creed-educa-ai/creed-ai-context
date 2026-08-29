# Migrations — Alembic

> Ver ADR-002 §2.4. Este é o assunto com maior chance de perda de dado no projeto.
> A IA **propõe**; um humano **lê linha a linha** antes de qualquer commit.

## As sete regras

1. **Autogenerate nunca vai para o repositório sem leitura linha a linha.**
   Renomear coluna vira `drop` + `create` e **perde dados**.
2. **Migration passa por code review, com prioridade.**
3. **Conflito de heads**: use `alembic merge`. Nunca edite `down_revision` à revelia.
4. **No deploy: Job dedicado**, nunca no startup do container.
5. **Rollback**: corrija avançando com nova migration, não com `downgrade`.
6. **Mudança destrutiva em passos**: adicionar → migrar dados → remover. Nunca as três
   no mesmo PR.
7. **`alembic heads` antes de abrir PR.** Mais de um head = PR errado.

## Fluxo

```bash
alembic revision --autogenerate -m "descricao"   # SEMPRE revisar o resultado
alembic heads                                     # conferir antes de abrir PR
alembic upgrade head
```

## O que revisar no arquivo gerado

- [ ] Algum `drop_column` / `drop_table` que deveria ser rename?
- [ ] `nullable=False` em coluna nova de tabela com dados? Precisa de default ou de
      três passos.
- [ ] `down_revision` aponta para o head correto?
- [ ] Índice de coluna que entrou em `WHERE`/`JOIN` de agregação?
- [ ] Tipo bate com o `models.py` (e o `models.py` bate com o `schemas.py`)?
- [ ] O `downgrade()` está coerente — mesmo sabendo que não vamos usá-lo?

## Para a IA

Ao gerar ou alterar migration, **sempre** encerre a resposta com:

```
⚠️ Migration precisa de leitura humana linha a linha antes do commit.
Pontos de atenção: <lista>
```

Nunca rode `alembic upgrade` contra banco que não seja o local do usuário.
