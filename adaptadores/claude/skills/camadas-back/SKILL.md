---
name: camadas-back
description: Alterar regra de negócio ou query num domínio que já existe no creed-backend — mexer em service.py, repository.py, schemas.py ou router.py sem criar domínio novo. Use quando a task corrige comportamento, acrescenta um endpoint a domínio existente, muda uma agregação, ou quando a dúvida é "isso é service ou repository?".
model: sonnet
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai mexer nas camadas de um domínio que já existe. A régua é
`creed-ai-context/conventions/camadas-do-back.md`; o molde é
`app/domains/respondentes/`. Para criar domínio novo, a skill é `dominio-back`.

<critical>O CORTE, antes de escrever a primeira linha: se a resposta muda quando o PRODUTO muda de ideia, é `service.py`. Se muda quando o BANCO muda de forma, é `repository.py`. "Já existe respondente com esse e-mail? Então 409" é produto; "como eu descubro se existe" é banco.</critical>
<critical>`service.py`: classe, recebe as dependências no construtor, NÃO importa `fastapi` nem `sqlalchemy`, não monta query, não recebe `Request`. Levanta exceção de `app/shared/exceptions.py` — nunca devolve `dict` de erro e nunca conhece status code.</critical>
<critical>`repository.py`: recebe a sessão no construtor, devolve model, tupla ou escalar. NÃO levanta exceção de domínio (devolve `None` e deixa o service decidir), NÃO importa `schemas`, e só dá `flush()` — `commit()` é do `get_db`, porque a unidade de trabalho é a requisição.</critical>
<critical>`router.py` é fino: recebe, valida via schema, delega, devolve. Sem `if` de regra e SEM importar `models` — o mapeamento model → schema é `@classmethod de_model()` em `schemas.py`.</critical>
<critical>Agregação é SQL no repository. `.sum()`, `for` somando lista ou `len()` de lista carregada dentro do service é agregação no lugar errado; endpoint devolvendo lista crua onde a tela mostra um total empurra a agregação para o front, que a arquitetura proíbe.</critical>
<critical>Cálculo puro (sem `self`, sem repository, sem sessão, sem I/O) não fica no service: mora em `utils.py` do domínio e sobe para `app/shared/<assunto>.py` no segundo uso. `app/shared/utils.py` é PROIBIDO — se você não nomeia o assunto do arquivo em uma palavra, a função ainda não subiu de andar.</critical>
<critical>Domínio não importa domínio. A ÚNICA exceção é `dashboards`/`relatorios` lendo tabela alheia por `JOIN` (ADR-0004, item 4); escrita fora do próprio domínio passa pelo `service.py` do dono, sempre. Usou a exceção? Declare no topo do repository e na lista de exceções de `tests/test_arquitetura.py`.</critical>
<critical>Mudou o `models.py`? Então é migration, e a skill é `migration-back` — não altere coluna sem gerar a revisão. Passou a chamar serviço de fora? A skill é `integracao-externa`.</critical>
<critical>Teste no nível certo: mudou regra → teste de service com repository fake; mudou query ou agregação → teste de repository contra banco real (mock de query não testa `GROUP BY`); mudou contrato → teste de rota só para status, shape e validação. Corrigiu bug? Escreva o teste que falha SEM a correção, veja vermelho, então corrija.</critical>
<critical>Encerre com `ruff check . && ruff format --check .`, `mypy app`, `pytest` e `pytest tests/test_arquitetura.py` verdes. Vermelho no teste de arquitetura não é estilo: é camada furada.</critical>
