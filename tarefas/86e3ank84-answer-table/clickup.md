# CREED-31 — rascunho de publicação no ClickUp

```
Épico: 86e3ank84 — CREED-31 - Answer table context
Spec: spec.md · Tasks: tasks.md
Gerado em: 2026-09-19 · Publicado em: 2026-09-19 (seção no épico + 2 subtarefas)
Permalinks apontam para creed-backend @ db177b5be91647a7d22831c1064b0b5a6c16add8 (origin/dev)
```

## Mapa de publicação

| # | Subtarefa no board | Repo | Ação | ID |
|---|---|---|---|---|
| — | CREED-31 (épico) | — | ✅ publicado — seção `[REFINADA 19.09]` acrescentada ao fim; a descrição anterior foi preservada | `86e3ank84` |
| 1 | CREED-31.1 [REFINADA 19.09] - Tabela de respostas individuais no banco | back | ✅ publicado | `86e3bbau6` |
| 2 | CREED-31.2 [REFINADA 19.09] - Regra de resposta válida: objetiva ou descritiva | back | ✅ publicado | `86e3bbaw0` |

Decisão humana de 2026-09-19: **as duas versões convivem no board**, e o rótulo
`[REFINADA 19.09]` no título das subtarefas e no título da seção do épico é o que
distingue uma da outra.

### ⚠️ Não tocar — reportado, não alterado

As três subtarefas que já existem no épico **não têm linha de rastreio** — foram criadas
à mão, fora deste pipeline. A regra do workflow é não tocar e reportar, e foi o que se
fez: elas continuam no board, intactas.

| Subtarefa existente | ID | Situação |
|---|---|---|
| CREED-311 - Answer model e migration | `86e3anktu` | coberta pela entrega 1, com **outro recorte** (ela manda mockar `form_response_id`; a entrega 1 não cria a coluna) |
| CREED-312 - Answer repository e service | `86e3anpp5` | coberta pela entrega 2, com **regra oposta** (ela manda recusar texto vazio; a entrega 2 recusa a linha sem nenhuma das duas formas) |
| CREED-313 Answer schema | `86e3anwqj` | absorvida pela entrega 2 — schemas não fecham como entrega isolada |

> ⚠️ **O épico fica com cinco subtarefas**, duas delas descrevendo o mesmo trabalho que
> três das outras, com regra incompatível. A seção `[REFINADA 19.09]` no épico existe
> para que quem chega saiba qual das duas versões seguir. **Enquanto as três antigas não
> forem fechadas, duas pessoas podem pegar o mesmo trabalho por caminhos opostos** — é
> risco conhecido e aceito, não descuido.

## Materiais — visão do épico

| Material | Onde está | Vai em | Situação |
|---|---|---|---|
| Recorte do modelo de dados (tabela `Answer`) | `context/modelo-de-dados.proposta.dbml` | subtarefa 1 | ⬜ falta anexar — **AGES IV** |
| Molde do backend (permalinks GitHub) | `origin/dev` @ `db177b5` | subtarefas 1 e 2 | ✅ linkado no corpo |
| Texto das premissas P-014 e P-015 | `decisoes/premissas.md` | ambas | ✅ colado no corpo |
| Definição de "resposta objetiva" e "descritiva" | este arquivo | ambas | ✅ colada no corpo |

Nenhum `⬜` é **bloqueante**: a forma completa da tabela está escrita dentro da subtarefa
1, então dá para começar sem o anexo. O anexo acrescenta profundidade, não destrava.

---

## Parte 2 — seção acrescentada ao épico

<!-- markdown_description em 86e3ank84 = descrição atual + TUDO abaixo, acrescentado ao fim. -->
<!-- A descrição anterior NÃO é apagada. Republicar substitui só desta linha para baixo. -->

## 🔄 [REFINADA 19.09] Versão refinada desta tarefa

> Esta seção foi acrescentada em 19/09 e **não apaga nada do que está acima**. Onde as
> duas se contradisserem, **vale esta** — ela passou pelo processo de especificação do
> projeto e corrige dois pontos que não fechavam.
>
> As subtarefas desta versão são as que têm **`[REFINADA 19.09]` no título**. As outras
> três (CREED-311, CREED-312, CREED-313) continuam no board e descrevem o mesmo trabalho
> de outro jeito — **não pegue as duas versões ao mesmo tempo.**

**O que mudou em relação à descrição acima:**

1. **A rota `POST /api/v1/answers` não entra nesta rodada.** Ela precisa apontar para o
   registro de "quem respondeu qual formulário", que ainda não existe como tabela.
   Publicada agora, aceitaria identificador inventado e gravaria registro órfão.
2. **A regra de resposta válida estava invertida** na decomposição anterior. "Recusar
   texto vazio" recusaria **toda resposta objetiva**, que por desenho não tem texto — ela
   responde marcando uma alternativa.

### O que é

A plataforma passa a ter onde guardar **a resposta que uma pessoa dá a uma pergunta**.
Hoje as telas de questionário existem, mas o que a pessoa marca ou escreve não tem para
onde ir: o banco tem uma tabela só, a de usuários.

Esta rodada entrega a fundação — a tabela e a regra do que é uma resposta válida. Ela
**não** entrega a rota que recebe a resposta pela internet: essa nasce junto da submissão
do formulário, quando existir a tabela que registra "fulano abriu e respondeu o
formulário X".

### Para quem, e o que muda para essa pessoa

| Quem | Hoje | Depois desta entrega |
|---|---|---|
| Quem responde o questionário | marca as alternativas e nada é guardado | continua sem mudança visível — a tela ainda não envia; o que muda é que agora existe destino para o dado |
| Quem gere uma organização | não tem número nenhum para ler | continua sem mudança visível; passa a existir a estrutura que torna a contagem por alternativa possível |
| Quem desenvolve | não tem onde plugar a submissão | tem a tabela, a camada de gravação e a regra de validade prontas para a submissão usar |

**Esta é uma entrega de fundação: ninguém de fora do time percebe diferença.** Dizer isso
é a informação, não uma lacuna.

### O que entra nesta rodada

- A tabela que guarda cada resposta individual, criada no banco local.
- A regra que decide se uma resposta é válida, com teste.
- A camada que grava e a que busca por identificador.

### O que não entra — e por quê

- **A rota HTTP que recebe a resposta** — ela precisa apontar para o registro de "quem
  respondeu qual formulário", que ainda não existe. Uma rota publicada agora aceitaria
  identificador inventado e gravaria linha órfã, que depois ninguém consegue rastrear.
- **As ligações com as outras tabelas** (a pergunta, a alternativa, o formulário
  respondido) — essas tabelas ainda não existem. As ligações entram numa tarefa de
  amarração, depois, quando todas estiverem de pé.
- **A conferência de que a alternativa escolhida pertence mesmo àquela pergunta** —
  depende da tabela de alternativas existir.
- **Qualquer mudança no aplicativo web.** Esta rodada é só servidor.

> ⚠️ Enquanto a tarefa de amarração não acontecer, **esta tabela precisa continuar
> vazia**. Ligar as tabelas depois custa uma operação só enquanto não há nenhuma linha
> gravada; com dado dentro, vira um procedimento de três etapas. Nenhum dado de teste ou
> carga inicial deve ser gravado aqui até lá.

### Como vai ser verificado

1. Subir o banco local e aplicar as mudanças de estrutura — a tabela aparece com as cinco
   colunas previstas e sem nenhuma ligação com outra tabela.
2. Derrubar o banco inteiro e subir de novo: reproduz exatamente a mesma estrutura.
3. Rodar a bateria de testes do servidor — os casos de resposta objetiva, resposta
   descritiva e resposta vazia passam.

### Decisões que tomamos sem a cliente

| O que decidimos | Por quê | Custo de mudar depois |
|---|---|---|
| Uma resposta válida tem **uma** das duas formas preenchida: ou a alternativa marcada, ou o texto escrito. Nunca as duas, nunca nenhuma. Pergunta pulada não gera registro. | O modelo de dados já separa as duas formas, mas não diz o que fazer quando nenhuma vem. Sem ligação com outras tabelas nesta rodada, é a única regra que impede resposta vazia entrar no banco. | **Baixo** — é uma condição em um arquivo, e nenhum dado se perde na volta |
| Uma pergunta objetiva aceita **uma** alternativa. Mas não travamos isso na estrutura do banco. | Se depois a cliente quiser permitir marcar várias, travar agora exigiria desfazer a trava. Deixando a regra fora da estrutura, abrir para múltipla escolha não custa nada. | **Baixo** — nenhuma alteração de estrutura é necessária para mudar de ideia |

### As entregas

São as duas subtarefas marcadas com `[REFINADA 19.09]` no título:

| # | Entrega | Onde | Depende de |
|---|---|---|---|
| 1 | CREED-31.1 [REFINADA 19.09] - Tabela de respostas individuais no banco | back | — |
| 2 | CREED-31.2 [REFINADA 19.09] - Regra de resposta válida: objetiva ou descritiva | back | 1 |

### Materiais desta tarefa

- ⬜ Recorte do modelo de dados com a tabela de respostas — **anexar: AGES IV**
- ✅ Definições dos termos, coladas em cada subtarefa
- ✅ Endereços dos arquivos de referência, linkados em cada subtarefa

### Rastreio

```
Rastreio: 86e3ank84 — creed-ai-context/tarefas/86e3ank84-answer-table/spec.md
```

---

## Parte 3 — subtarefa 1

<!-- Título: CREED-31.1 [REFINADA 19.09] - Tabela de respostas individuais no banco -->
<!-- markdown_description, parent = 86e3ank84 -->

### Em uma frase

Criar, no banco, a tabela que guarda cada resposta que uma pessoa dá a uma pergunta.

### O que muda para quem usa

Ninguém usa esta entrega diretamente — ela é o chão sobre o qual a próxima fica de pé.
Hoje o banco da plataforma tem **uma tabela só**, a de usuários. As telas de questionário
já foram construídas, mas o que a pessoa marca não tem para onde ir.

Vale entender o que "resposta" quer dizer aqui, porque o nome engana: é a marcação de
**uma pergunta**, não o questionário inteiro. Uma pessoa que responde dez perguntas gera
dez linhas nesta tabela. Quem guarda "fulano respondeu o formulário X" é outra tabela,
que ainda não existe.

E as perguntas são de dois tipos, o que explica o formato da tabela:

- **Pergunta objetiva** — a pessoa marca uma alternativa pronta (por exemplo "Sim",
  "Não", "Às vezes"). A resposta guarda **qual alternativa** foi marcada.
- **Pergunta descritiva** — a pessoa escreve com as próprias palavras. A resposta guarda
  **o texto**.

Por isso existem duas colunas de resposta, e as duas aceitam ficar vazias: cada tipo de
pergunta preenche uma delas. A objetiva não guarda texto de propósito — contar quantas
pessoas escolheram cada alternativa sobre texto digitado viraria contagem de coisa que
cada um escreve de um jeito.

### Como pretendemos fazer

Criar uma pasta nova para o assunto "respostas" no servidor, declarar a tabela ali, gerar
a alteração de estrutura do banco automaticamente e **ler essa alteração linha a linha**
antes de aplicar — gerar é automático, aprovar não é.

Duas coisas que esta entrega deliberadamente **não** faz, e que a pessoa provavelmente
esperaria fazer:

1. **Nenhuma ligação com outras tabelas.** A pergunta, a alternativa e o formulário
   respondido ainda não existem como tabela, e uma ligação só pode ser criada depois do
   alvo. Elas entram numa tarefa de amarração, depois.
2. **A coluna que aponta para o formulário respondido não entra nem como coluna.** Ela
   seria um campo obrigatório apontando para o nada: aceitaria qualquer valor e não
   conferiria coisa alguma. Na amarração dá o mesmo trabalho criar do zero ou alterar a
   existente — então fica para lá.

A coluna da pergunta **fica**, mesmo sem ligação, porque é ela que dá sentido à linha:
sem saber de que pergunta é, a resposta não significa nada nem isolada.

### Onde isso encosta no código

Repo: `creed-backend`.

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/responses/__init__.py` | a pasta do assunto novo |
| `app/domains/responses/models.py` | a tabela `answer` |
| `alembic/versions/<hash>_create_answer_table.py` | a alteração de estrutura, gerada e depois lida linha a linha |
| `tests/domains/responses/__init__.py` | — |
| `tests/domains/responses/test_models.py` | o teste que trava a forma da tabela |

O nome da pasta é `responses`, em inglês e no plural, porque
**todo identificador no código deste projeto é em inglês** — pasta, classe, método,
variável, rota — e pasta de domínio é `snake_case` no plural. Não use `respostas` nem
`response`. A decisão e o motivo dela estão em
[decisão sobre o idioma do código](https://github.com/creed-educa-ai/creed-ai-context/blob/f3bb75d61ca2eaea902b68ca420af1cdd0fb6a25/decisoes/adrs/0005-idioma-do-codigo.md)
(abre no GitHub).

**`app/main.py` não é tocado.** Não há rota nesta entrega — não procure onde registrar.

### A tabela, coluna a coluna

| Coluna | Tipo | Aceita vazio? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, gerada pela aplicação |
| `question_id` | `UUID` | não | **sem ligação** com a tabela de perguntas nesta rodada |
| `option_id` | `UUID` | **sim** | preenchida na pergunta **objetiva**; **sem ligação** |
| `value` | `String` | **sim** | preenchida na pergunta **descritiva** |
| `created_at` | `DateTime` com fuso | não | preenchida pelo banco |

Índice: `question_id`.

**Não crie:** a coluna `form_response_id`, nenhuma chave estrangeira, nenhuma restrição
de unicidade.

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| `Base` e `get_db` | [`app/core/database.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/core/database.py) | a base das tabelas e a sessão de banco — **não crie outra** |
| Tabela de exemplo completa | [`app/domains/respondentes/models.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/respondentes/models.py) | copie a **forma**: como a tabela é declarada, como a chave e o horário de criação aparecem. **Os campos, não** — aqueles são de outro assunto |
| Alteração de estrutura de exemplo | [`alembic/versions/0b0ad39d779a_create_user_table.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/alembic/versions/0b0ad39d779a_create_user_table.py) | a forma do arquivo — inclusive o **checklist de revisão no comentário do topo**, que é para preencher, não para copiar em branco |
| Teste que confere as camadas | [`tests/test_arquitetura.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/tests/test_arquitetura.py) | ele roda sobre o assunto novo automaticamente; precisa continuar passando |

### Pronto quando

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] `alembic heads` devolve **um único head**. Se devolver dois, a saída é
      `alembic merge` — **nunca** editar `down_revision` à mão.
- [ ] `\d answer` mostra exatamente as cinco colunas da tabela acima, com os mesmos tipos
      e a mesma aceitação de vazio.
- [ ] A tabela **não** tem nenhuma chave estrangeira e **não** tem `form_response_id`.
- [ ] Existe índice em `question_id`.
- [ ] `down_revision` aponta para o head que existia quando o arquivo foi gerado —
      conferido com `alembic current` **antes** de gerar.
- [ ] O arquivo gerado foi **lido linha a linha**, e quem leu consegue dizer o que cada
      comando faz. O checklist no comentário do topo está preenchido.
- [ ] `pytest tests/test_arquitetura.py` passa.

### Como verificar

```bash
cd creed-backend
docker compose up -d db
alembic current
alembic revision --autogenerate -m "create answer table"
alembic heads
alembic upgrade head
pytest tests/domains/responses tests/test_arquitetura.py -q
ruff check . && mypy app
```

Conferir a forma no banco:

```bash
docker compose exec db psql -U creed -d creed -c "\d answer"
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

**O teste desta entrega** (`tests/domains/responses/test_models.py`) não precisa de banco:
lê a descrição da tabela direto do código. Ele trava o que é fácil de alguém desfazer sem
perceber — uma chave estrangeira acrescentada antes da amarração, ou uma das duas colunas
de resposta virando obrigatória. Confere: as cinco colunas existem com a aceitação de
vazio da tabela acima · a lista de chaves estrangeiras está vazia · existe índice em
`question_id`.

### Decisões já tomadas que valem aqui

- **Uma resposta válida tem uma das duas formas preenchida: a alternativa marcada ou o
  texto escrito.** Aqui isso aparece só como **as duas colunas aceitarem vazio**. Quem
  recusa a linha sem nenhuma das duas é a entrega 2. Decidimos sem confirmar com a
  cliente; se estiver errado, muda uma condição em um arquivo e nenhum dado se perde.
- **Uma pergunta objetiva aceita uma alternativa, mas não travamos isso no banco.** Sem a
  trava, permitir marcar várias depois não exige nenhuma alteração de estrutura. Também
  decidido sem a cliente.

### Materiais para consumir

| Material | Situação |
|---|---|
| A forma completa da tabela | ✅ escrita acima, coluna a coluna |
| Definições de "pergunta objetiva" e "pergunta descritiva" | ✅ coladas acima |
| Arquivos de referência do servidor | ✅ linkados acima (abrem no GitHub) |
| Recorte do modelo de dados com a tabela de respostas | ⬜ falta anexar — **AGES IV**. Não bloqueia: a forma da tabela está escrita acima |

### Antes de abrir o PR

⚠️ Alteração de estrutura de banco precisa de leitura humana linha a linha antes do
commit. Pontos de atenção: `down_revision` apontando para o head certo · nenhuma chave
estrangeira tendo entrado sozinha na geração automática · o `downgrade()` derrubando só o
que este arquivo criou · `alembic heads` com um head só.

### Rastreio

```
Rastreio: 86e3ank84/1 — creed-ai-context/tarefas/86e3ank84-answer-table/1_task.md
```

---

## Parte 3 — subtarefa 2

<!-- Título: CREED-31.2 [REFINADA 19.09] - Regra de resposta válida: objetiva ou descritiva -->
<!-- markdown_description, parent = 86e3ank84 -->

### Em uma frase

Ensinar o servidor a gravar uma resposta válida, recusar uma inválida e buscar uma
resposta pelo identificador.

### O que muda para quem usa

Ninguém de fora do time percebe diferença — não há tela nem rota nesta entrega. O que
muda é que a regra mais importante do assunto "resposta" passa a existir e a ter teste.

A regra é uma só: **uma resposta válida tem exatamente uma das duas formas preenchida.**
A alternativa marcada, se a pergunta era objetiva. O texto escrito, se era descritiva.
Nunca as duas ao mesmo tempo, e nunca nenhuma — linha sem nenhuma das duas é registro sem
significado, e o servidor recusa.

Pergunta que a pessoa **pulou** simplesmente não gera registro. Não existe "resposta em
branco" guardada.

### Como pretendemos fazer

Três camadas, com responsabilidades separadas — é a divisão que o projeto usa em todo
assunto, e furar ela quebra um teste automático:

- A camada que **fala com o banco** só grava e busca. Não decide nada, e quando não acha
  devolve "nada encontrado", sem levantar erro.
- A camada de **regra** é quem decide: recebe os dados, confere se uma das duas formas
  veio preenchida e recusa se não veio. Quando a busca devolve nada, é ela quem levanta o
  erro de "não encontrado".
- A camada de **contratos de entrada e saída** descreve o que entra e o que sai.

**Não há rota nesta entrega, e isso é de propósito.** A rota que recebe a resposta pela
internet precisa apontar para o registro de "quem respondeu qual formulário", que ainda
não existe como tabela. Publicada agora, ela aceitaria identificador inventado e gravaria
registro órfão. `app/main.py` não é tocado.

Duas armadilhas conhecidas, porque o projeto já tropeçou nelas:

1. **Não escreva `commit()` em lugar nenhum.** Quem fecha a transação é a requisição, no
   fim — o arquivo `app/core/database.py` cuida disso. `commit()` fora de lá é sinal de
   camada furada, e existe teste automático que reprova.
2. **A camada que fala com o banco devolve "nada" quando não acha; ela não levanta erro.**
   Levantar erro ali é a camada de dados decidindo regra, que é trabalho da camada de
   regra.

Tudo é escrito em modo assíncrono (`async`), porque é assim que o resto do servidor é.

### Onde isso encosta no código

Repo: `creed-backend`.

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/responses/repository.py` | `insert(answer)` e `get_by_id(answer_id)` — o acesso ao banco |
| `app/domains/responses/service.py` | `record(dados)` e `get(answer_id)` — a regra |
| `app/domains/responses/schemas.py` | `AnswerCreate` (entrada) e `AnswerResponse` (saída) |
| `app/domains/responses/dependencies.py` | a montagem da cadeia sessão → banco → regra |
| `tests/domains/responses/test_service.py` | os quatro casos abaixo |

### Os métodos que devem nascer

| Onde | Assinatura | Devolve |
|---|---|---|
| `repository.insert(answer: Answer)` | a entidade já montada | a resposta gravada, com identificador e horário preenchidos pelo banco |
| `repository.get_by_id(answer_id: UUID)` | — | a resposta, **ou `None`** — não levanta erro |
| `service.record(dados: AnswerCreate)` | os dados já validados | a resposta criada, ou `ValidationError` |
| `service.get(answer_id: UUID)` | — | a resposta, ou `NotFoundError` |

Os nomes não são livres: **a camada de regra nomeia a intenção** (`record` — registrar uma
resposta) e **a camada de banco nomeia o acesso** (`insert`, `get_by_id`). Um método de
regra chamado `get_by_id` é acesso a banco disfarçado.

Conteúdo dos contratos: `AnswerCreate` leva `question_id`, mais `option_id` e `value`,
os dois opcionais. `AnswerResponse` devolve `id`, `question_id`, `option_id`, `value` e
`created_at`.

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| Acesso a banco de exemplo | [`app/domains/respondentes/repository.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/respondentes/repository.py) | copie a forma: a sessão assíncrona, a consulta, e o `add` + `flush` + `refresh` do método de criação — repare que **não há `commit()`** |
| Camada de regra de exemplo | [`app/domains/respondentes/service.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/respondentes/service.py) | como a regra recebe o acesso a banco e levanta erro de domínio |
| Contratos de exemplo | [`app/domains/respondentes/schemas.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/respondentes/schemas.py) | entrada e saída separadas, e o `ConfigDict(from_attributes=True)` na saída |
| Montagem da cadeia de exemplo | [`app/domains/respondentes/dependencies.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/respondentes/dependencies.py) | `get_repository` → `get_service` → `ServiceDep` |
| `NotFoundError` e `ValidationError` | [`app/shared/exceptions.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/shared/exceptions.py) | os erros padronizados — **não crie exceção nova** |
| Teste de exemplo, com dublê no lugar do banco | [`tests/domains/authentication/test_service.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/tests/domains/authentication/test_service.py) | a forma do teste. **Não existe banco de teste no projeto** — a regra é testada com dublê |

### Pronto quando

- [ ] `service.record` **aceita** resposta com `option_id` preenchido e `value` vazio.
- [ ] `service.record` **aceita** resposta com `value` preenchido e `option_id` vazio.
- [ ] `service.record` **recusa**, com `ValidationError`, a resposta com as duas vazias.
- [ ] `service.record` **recusa** `value` que só tem espaço em branco — texto em branco
      não é resposta descritiva.
- [ ] `service.get` levanta `NotFoundError` quando o identificador não existe.
- [ ] `repository.get_by_id` devolve `None` no mesmo caso — **não** levanta.
- [ ] Nenhum `commit()` no diff, fora de `app/core/database.py`.
- [ ] `service.py` não importa `fastapi` nem `sqlalchemy`.
- [ ] `repository.py` não importa `schemas`.
- [ ] `pytest tests/test_arquitetura.py` passa.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/responses -q
ruff check . && mypy app && pytest
```

**Caso feliz:** gravar uma resposta objetiva (`option_id` preenchido) e uma descritiva
(`value` preenchido) — as duas voltam com identificador e horário de criação.

**Casos de borda, nomeados:** as duas formas vazias → `ValidationError` · `value` só com
espaço em branco → `ValidationError` · buscar um identificador que não existe →
`NotFoundError` na camada de regra e `None` na camada de banco.

### Decisões já tomadas que valem aqui

- **Uma resposta válida tem exatamente uma das duas formas preenchida; linha com as duas
  vazias é recusada; pergunta pulada não gera registro.** É a regra que esta entrega
  implementa. Decidimos sem confirmar com a cliente, porque o modelo de dados separa as
  duas formas mas não diz o que fazer quando nenhuma vem. Se ela cair, muda a condição
  dentro de `service.record` — nenhum dado se perde.
- **Uma pergunta objetiva aceita uma alternativa, mas isso não vira trava aqui.** Nesta
  entrega a decisão só explica por que nada impede dois registros para a mesma pergunta.
  A regra nasce junto da submissão do formulário, depois.

### Materiais para consumir

| Material | Situação |
|---|---|
| Assinaturas dos métodos e conteúdo dos contratos | ✅ escritos acima |
| Arquivos de referência do servidor | ✅ linkados acima (abrem no GitHub) |
| Texto das decisões tomadas sem a cliente | ✅ colado acima |

### Depende de

**Entrega 1 — "Tabela de respostas individuais no banco".** Esta entrega importa a tabela
que a 1 cria; não dá para começar antes de ela estar mesclada.

### Rastreio

```
Rastreio: 86e3ank84/2 — creed-ai-context/tarefas/86e3ank84-answer-table/2_task.md
```

---

## Nota de publicação — links em tabela não sobrevivem no ClickUp

Descoberto em 2026-09-19, na conferência pós-publicação: **o ClickUp remove links
markdown dentro de célula de tabela.** Uma linha escrita como

```
| Tabela de exemplo | [`models.py`](https://github.com/...) | copie a forma |
```

chega ao board como `models.py` em texto puro — o endereço some. Link em **prosa** ou em
**lista** sobrevive normalmente. Negrito dentro de célula também é descartado.

Consequência para este workflow: a seção **"O que já existe e deve ser reusado"** não
pode ser tabela, porque é exatamente a seção em que o checklist exige permalink. Aqui ela
virou **lista numerada**, com o link no nome do arquivo. As duas subtarefas foram
republicadas com essa correção.

Vale para qualquer tarefa futura: tabela para dado tabular sem link; lista para tudo que
precisa de endereço que abre.
