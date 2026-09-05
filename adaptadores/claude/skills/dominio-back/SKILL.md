---
name: dominio-back
description: Implementar um domínio do creed-backend de ponta a ponta — nova pasta em app/domains/, model, migration, schemas, repository, service, router e testes. Use quando a task pede um domínio novo, um recurso completo (CRUD + regra) ou um endpoint que ainda não existe. Orquestra as skills camadas-back, migration-back e integracao-externa.
model: sonnet
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai implementar um domínio do `creed-backend` de ponta a ponta.

Leia ANTES de escrever: `creed-ai-context/playbooks/criar-dominio-backend.md` (a
sequência e a tabela de erros) e `creed-ai-context/conventions/camadas-do-back.md` (as
camadas e os sinais de que furou). O molde é `app/domains/respondentes/` — abra os
arquivos.

<critical>PASSO 0, ANTES DE QUALQUER CÓDIGO: os campos existem na spec? Se não, PARE. Campo de domínio é decisão de produto: vira premissa em `creed-ai-context/decisoes/premissas.md` + tarefa no ClickUp. `respondentes` é exemplo gerado no scaffold — copie dele a FORMA (camadas, injeção, separação de schema por direção), NUNCA os campos: `regiao`, `pais` e `genero` não foram acordados com ninguém. Campo inventado vira migration, e migration vira dado.</critical>
<critical>Ordem obrigatória: `models.py` → migration → `schemas.py` → `repository.py` → `service.py` → `utils.py`/`constants.py` (só se tiverem conteúdo) → `dependencies.py` → `router.py` → registrar em `app/main.py` → testes. Não pule para o passo 3 antes da migration existir.</critical>
<critical>O CORTE: se a resposta muda quando o PRODUTO muda de ideia, é `service.py`; se muda quando o BANCO muda de forma, é `repository.py`. Service é classe, recebe o repository no construtor, não importa `fastapi` nem `sqlalchemy`. Repository recebe a sessão, devolve model/tupla/escalar, devolve `None` em vez de levantar erro, e só dá `flush()` — NUNCA `commit()`.</critical>
<critical>REUSE ANTES DE CRIAR. Já existem: `app/shared/exceptions.py` (`NotFoundError`, `ConflictError`, `ValidationError`), `app/shared/paginacao.py` (`PaginaDe[T]` — não escreva um `<Entidade>ListResponse` próprio), `app/core/database.py` (`get_db`, `Base`), `app/core/config.py` (`settings`). Util novo nasce em `utils.py` do domínio e sobe para `app/shared/<assunto>.py` no segundo uso; `app/shared/utils.py` é PROIBIDO.</critical>
<critical>`router.py` NÃO importa `models` e NÃO tem `if` de regra. O mapeamento model → schema é `@classmethod de_model()` em `schemas.py`. Se você está escrevendo um `_to_response()` no router, parou no lugar errado — é o furo que o molde ainda tem e que o PR de correção resolve.</critical>
<critical>Agregação (`SUM`, `COUNT`, `GROUP BY`, janela) é SQL no repository, nunca laço em Python no service e nunca lista crua devolvida para o front somar.</critical>
<critical>Domínio não importa domínio: precisa de dado de outro? Passe pelo `service.py` do dono. A ÚNICA exceção é `dashboards`/`relatorios`, que podem LER tabela alheia por `JOIN` (ADR-0004, item 4) — escrita fora do próprio domínio, nunca. Se usar a exceção, declare: comentário no topo do repository dizendo quais tabelas lê e por quê, mais a entrada na lista de exceções de `tests/test_arquitetura.py`.</critical>
<critical>Corte por fatia vertical: model + migration + o primeiro caso de uso inteiro por task, nunca por camada horizontal. Migration é a skill `migration-back`; serviço de fora é a skill `integracao-externa`.</critical>
<critical>Testes por camada: regra no service com repository fake, query e agregação no repository contra banco real, rota só para contrato. Encerre com `ruff check . && ruff format --check .`, `mypy app`, `pytest` e `pytest tests/test_arquitetura.py` verdes, e diga de onde vieram os campos (spec ou premissa), o que ficou no service e o que ficou no repository, e o que os testes NÃO provam.</critical>
