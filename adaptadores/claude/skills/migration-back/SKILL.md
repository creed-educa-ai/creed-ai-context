---
name: migration-back
description: Criar ou alterar migration do Alembic no creed-backend — coluna nova, rename, mudança de tipo, índice, tabela nova, conflito de heads. Use SEMPRE que a task mexer em app/domains/*/models.py ou em alembic/versions/, mesmo que a mudança pareça trivial. É o caminho de maior risco de perda de dado do projeto.
model: opus
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai gerar ou alterar uma migration. Leia ANTES:
`creed-ai-context/playbooks/criar-migration.md` (os passos e a checklist) e
`creed-ai-context/conventions/migrations.md` (as regras).

<critical>A IA PROPÕE, UM HUMANO DECIDE. Nenhuma migration entra sem leitura humana linha a linha. Você não fecha a task dizendo "gerado com sucesso": você entrega o arquivo com os pontos de atenção nomeados.</critical>
<critical>Ordem: altere `models.py` PRIMEIRO, depois `alembic revision --autogenerate -m "descricao"`. Nunca escreva a revisão à mão para "adiantar" — e nunca gere a revisão antes do model, porque o autogenerate compara contra o metadata.</critical>
<critical>ABRA O ARQUIVO GERADO E LEIA INTEIRO. Não é formalidade: o autogenerate transforma rename em `drop_column` + `add_column`, e isso PERDE DADOS. Rename é `op.alter_column(..., new_column_name=...)`, escrito à mão sobre o que ele gerou.</critical>
<critical>Coluna nova `nullable=False` em tabela que já tem linhas não sobe: ou vai com `server_default`, ou vira três passos (adicionar nullable → preencher → tornar obrigatória). Mudança destrutiva SEMPRE se quebra em passos: adicionar → migrar dados → remover.</critical>
<critical>Confira antes de fechar: `down_revision` aponta para o head correto · índice para coluna que entrou em `WHERE`/`JOIN`/`GROUP BY` · tipo bate entre `models.py`, `schemas.py` e a revisão · `downgrade()` coerente mesmo sem uso previsto.</critical>
<critical>Conflito de heads se resolve com `alembic merge -m "merge heads" <head1> <head2>`. NUNCA edite `down_revision` na mão para "resolver" — isso reescreve a história e quebra quem já migrou.</critical>
<critical>`alembic upgrade` só contra o banco LOCAL do usuário (`docker compose up -d db`). Nunca contra dev, staging ou produção — e no EKS a migration roda em Job dedicado antes dos pods subirem, nunca no `lifespan` da aplicação.</critical>
<critical>Valide de verdade: `alembic upgrade head`, depois `alembic heads` (tem que ser um só), depois `pytest` — migration quebrada aparece nos testes de repository, que rodam contra banco real.</critical>
<critical>ENCERRAMENTO OBRIGATÓRIO, sempre: a linha "⚠️ Migration precisa de leitura humana linha a linha antes do commit.", seguida de "Pontos de atenção:" com a lista CONCRETA — quais colunas, qual o risco de cada uma, o que acontece com o dado que já está lá. Lista genérica não vale, e "nenhum ponto de atenção" não é resposta: se não há risco, diga por que não há.</critical>
