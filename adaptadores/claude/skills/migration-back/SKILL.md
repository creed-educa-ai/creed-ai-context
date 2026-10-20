---
name: migration-back
description: Criar ou alterar migration do Alembic no creed-backend — a temporária de uma tarefa (testa local e não sobe), a consolidada do AGES III, coluna nova, rename, mudança de tipo, índice, tabela nova, conflito de heads. Use SEMPRE que a task mexer em app/domains/*/models.py ou em alembic/versions/, mesmo que a mudança pareça trivial. É o caminho de maior risco de perda de dado do projeto.
model: opus
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai gerar ou alterar uma migration. Leia ANTES:
`creed-ai-context/playbooks/criar-migration.md` (os dois fluxos e a checklist),
`creed-ai-context/conventions/migrations.md` (as regras) e
`creed-ai-context/decisoes/adrs/0009-migration-consolidada-por-sprint.md` (por que PR de
tarefa sobe sem migration).

<critical>PRIMEIRO, SAIBA EM QUAL FLUXO VOCÊ ESTÁ. Branch de tarefa → fluxo A: a migration é TEMPORÁRIA, serve para testar no banco local e NÃO entra no diff que você entrega. Branch `chore/<id>-consolidar-migrations` → fluxo B: a consolidada do AGES III, que vai para o repositório. Na dúvida, pergunte. Arquivo em `alembic/versions/` num PR de tarefa é recusado pelo CI.</critical>
<critical>A IA PROPÕE, UM HUMANO DECIDE. Nenhuma migration entra sem leitura humana linha a linha. Você não fecha a task dizendo "gerado com sucesso": você entrega o arquivo com os pontos de atenção nomeados.</critical>
<critical>Ordem: altere `models.py` PRIMEIRO, depois `alembic revision --autogenerate -m "descricao"`. Nunca escreva a revisão à mão para "adiantar" — e nunca gere a revisão antes do model, porque o autogenerate compara contra o metadata.</critical>
<critical>ABRA O ARQUIVO GERADO E LEIA INTEIRO, também a temporária. O autogenerate transforma rename em `drop_column` + `add_column`, e isso PERDE DADOS. Rename é `op.alter_column(..., new_column_name=...)`, escrito à mão sobre o que ele gerou. No fluxo A, cada ajuste manual desses vira uma linha da seção "Banco" do PR, porque é o único jeito de o AGES III saber dele na consolidação.</critical>
<critical>Coluna nova `nullable=False` em tabela que já tem linhas não sobe: ou vai com `server_default`, ou vira três passos (adicionar nullable → preencher → tornar obrigatória). Mudança destrutiva SEMPRE se quebra em passos: adicionar → migrar dados → remover, e cada passo cai numa consolidação diferente.</critical>
<critical>Confira antes de fechar: `down_revision` aponta para o head correto · índice para coluna que entrou em `WHERE`/`JOIN`/`GROUP BY` · tipo bate entre `models.py`, `schemas.py` e a revisão · `downgrade()` coerente mesmo sem uso previsto.</critical>
<critical>LIMPEZA DO FLUXO A, NESTA ORDEM: `alembic downgrade <head-da-dev>` PRIMEIRO, depois apagar o arquivo. Apagar antes deixa o banco local numa revisão que o Alembic não encontra mais. Feche conferindo que `alembic current` bate com `alembic heads` e que `git status` não mostra nada em `alembic/versions/`. Se o humano pedir para manter a temporária enquanto testa, diga que a limpeza fica pendente antes do PR.</critical>
<critical>Conflito de heads se resolve com `alembic merge -m "merge heads" <head1> <head2>`. NUNCA edite `down_revision` na mão para "resolver" — isso reescreve a história e quebra quem já migrou.</critical>
<critical>`alembic upgrade` só contra o banco LOCAL do usuário (`docker compose up -d db`). Nunca contra dev, staging ou produção — em ambiente real a migration roda num passo dedicado do pipeline, num container descartável, antes de o container do back ser recriado; nunca no `lifespan` da aplicação.</critical>
<critical>Valide de verdade: `alembic upgrade head`, depois `pytest`. No fluxo B, também `alembic check` (tem que dizer que não há operação pendente) e `alembic heads` (tem que ser um só). Os testes do back NÃO falam com o banco, então pytest verde não prova a migration: diga isso no encerramento.</critical>
<critical>ENCERRAMENTO OBRIGATÓRIO. Fluxo A: o texto proposto para a seção "Banco" do PR (o que mudou e cada ajuste manual, ou "nenhum ajuste manual") e o lembrete da limpeza. Fluxo B: a linha "⚠️ Migration precisa de leitura humana linha a linha antes do commit.", seguida de "Pontos de atenção:" com a lista CONCRETA — quais colunas, qual o risco de cada uma, o que acontece com o dado que já está lá, e qual seção "Banco" pediu cada ajuste. Lista genérica não vale, e "nenhum ponto de atenção" não é resposta: se não há risco, diga por que não há.</critical>
