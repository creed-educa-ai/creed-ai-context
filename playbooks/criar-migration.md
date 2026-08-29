# Playbook: criar migration

> **Playbook de maior risco do projeto.** A IA propõe; **um humano lê linha a linha**
> antes do commit. Regras em `../conventions/migrations.md`.

## Passos

1. Alterar `models.py` primeiro.
2. Gerar:
   ```bash
   alembic revision --autogenerate -m "descricao"
   ```
3. **Abrir o arquivo gerado e ler inteiro.** Não é formalidade — o autogenerate
   transforma rename em `drop_column` + `add_column`, e isso **perde dados**.
4. Conferir a checklist abaixo.
5. Aplicar local e conferir head único:
   ```bash
   alembic upgrade head
   alembic heads
   ```
6. Rodar `pytest` — migration quebrada aparece nos testes de repository.

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

## Conflito de heads

```bash
alembic merge -m "merge heads" <head1> <head2>
```

Nunca edite `down_revision` na mão para "resolver".

## Encerramento obrigatório

Toda resposta de IA que gera ou altera migration termina com:

```
⚠️ Migration precisa de leitura humana linha a linha antes do commit.
Pontos de atenção: <lista concreta, não genérica>
```

E nunca rode `alembic upgrade` contra banco que não seja o local do usuário.
