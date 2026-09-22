# CREED-33 — rascunho de publicação no ClickUp

```
Épico: 86e3anvgg — CREED-33 Form table context
Spec: spec.md · Tasks: tasks.md
Gerado em: 2026-09-21 · Publicado em: 2026-09-21 (épico + 3 subtarefas, sobrescritos)
Permalinks apontam para creed-backend @ db177b5be91647a7d22831c1064b0b5a6c16add8 (origin/dev)
```

## Mapa de publicação

| # | Subtarefa no board | Repo | Ação | ID |
|---|---|---|---|---|
| — | CREED-33 (épico) | — | ✅ descrição sobrescrita | `86e3anvgg` |
| 1 | CREED-331 - Tabela de formulários no banco | back | ✅ título e descrição sobrescritos | `86e3ap0uf` |
| 2 | CREED-332 - Criar e buscar um formulário: regra e contratos | back | ✅ título e descrição sobrescritos | `86e3ap9jv` |
| 3 | CREED-333 - Endpoints de criação e consulta de formulário | back | ✅ título e descrição sobrescritos | `86e3apa4p` |
| 4 | CREED-334 - Modelo de dados alinhado à tabela de formulários criada | harness | ✅ **criada** em 2026-09-21, segunda rodada | `86e3c55yn` |

**Segunda rodada, 2026-09-21** — a pedido dos AGES IV, a divergência entre o modelo de
dados e a tabela criada ganhou dono próprio. Três escritas a mais: a subtarefa 4 criada, a
CREED-331 com um aviso apontando para ela, e a tabela de entregas do épico passando de três
para quatro linhas. As entregas 2 e 3 **não foram tocadas** — nada nelas mudou, e o
workflow manda não gastar chamada à toa.

### Diferença de conduta em relação à CREED-31

Na CREED-31, a decisão foi **acrescentar** uma seção `[REFINADA 19.09]` ao épico e criar
subtarefas novas ao lado das antigas — porque ninguém tinha aprovado o processo ainda, e
apagar trabalho de outra pessoa sem mandato era o risco maior. O preço foi um épico com
cinco subtarefas, duas descrevendo o mesmo trabalho que três das outras.

Aqui, com o processo aprovado pelos AGES IV em 2026-09-21, é **sobrescrita**:

- a descrição do épico é **substituída**, não acrescida;
- as **três subtarefas existentes são reaproveitadas** — mesmos IDs, mesma numeração
  (`CREED-331/332/333`), título e descrição novos. Quem tiver linkado uma delas continua
  chegando no lugar certo;
- **nenhuma subtarefa é fechada**, e não há duas versões convivendo.

Isso é possível porque a decomposição refinada **casa 1:1** com a que já estava no board
(migration · regra · schemas+router). Foi conferido, não presumido — se não casasse, a
sobrescrita teria virado criação.

> **Correção de 2026-09-21, segunda rodada.** Esta seção dizia "nenhuma subtarefa nova é
> criada". Deixou de ser verdade: a **CREED-334** foi criada depois, para dar dono à
> reconciliação do modelo de dados. Ela não contradiz a sobrescrita — as três originais
> continuam sendo as três originais, reescritas em cima. A quarta é trabalho que **não
> existia** na decomposição antiga, em outro repositório.

> ⚠️ **Sobrescrever apaga o que está lá.** O que se perde, registrado antes de apagar:
> a CREED-331 tinha o passo a passo do Alembic (preservado e ampliado abaixo) e **uma
> imagem anexada** — o recorte da tabela `Form` no dbdiagram. **O anexo não é tocado pela
> sobrescrita da descrição**: ele continua na subtarefa. A CREED-333 tinha o raciocínio
> sobre `status` nascer `draft`, que estava certo e virou a premissa P-017. A CREED-332
> estava vazia.

## Materiais — visão do épico

| Material | Onde está | Vai em | Situação |
|---|---|---|---|
| Recorte do modelo de dados (tabela `Form`) | anexo já existente na CREED-331 | subtarefa 1 | ✅ já anexado — **não precisa subir de novo** |
| Molde do backend (permalinks GitHub) | `origin/dev` @ `db177b5` | subtarefas 1, 2 e 3 | ✅ linkado no corpo, em lista |
| Texto das premissas P-016, P-017 e P-018 | `decisoes/premissas.md` | as três | ✅ colado no corpo |
| Definição de "formulário", "organização" e "rascunho" | este arquivo | épico e subtarefa 1 | ✅ colada no corpo |
| Forma completa da tabela, coluna a coluna | este arquivo | subtarefa 1 | ✅ escrita no corpo |
| Contrato dos dois endpoints, com erros | este arquivo | épico e subtarefa 3 | ✅ escrito no corpo |
| Bloco `Table Form` já corrigido, para colar na proposta | `4_task.md` | subtarefa 4 | ✅ colado no corpo |

**Nenhum `⬜`.** Diferente da CREED-31, esta tarefa não tem pendência de anexo: o recorte
do modelo já está no board desde 2026-09-17, subido por quem criou a subtarefa.

---

## Parte 2 — descrição do épico

<!-- markdown_description em 86e3anvgg = TUDO abaixo, substituindo a descrição atual. -->

### O que é

A plataforma passa a ter onde guardar **um formulário** — o instrumento que ela aplica às
pessoas. Hoje o banco tem **uma tabela só**, a de usuários; o formulário existe apenas no
diagrama do modelo de dados.

Esta rodada entrega a **casca**: o formulário nasce com nome, com a organização dona e em
rascunho. As perguntas que ele contém são outra tarefa. É a fundação sobre a qual três
outras já estão esperando — quem responde um formulário, qual pergunta pertence a ele, e
o painel que agrega por formulário.

### Três palavras, antes de tudo

- **Formulário** — o instrumento que a plataforma aplica: um conjunto de perguntas que
  uma pessoa responde. Esta tarefa cria só a casca dele.
- **Organização** — a instituição parceira à qual as pessoas respondentes pertencem.
  **O dono do formulário é a organização, não uma pessoa.** Quem pode editar e publicar
  sai do papel de cada pessoa naquela organização, não de um campo no formulário.
- **Rascunho** — o formulário existe, mas não está no ar. É o único estado em que um
  formulário nasce nesta rodada.

### Para quem, e o que muda para essa pessoa

| Quem | Hoje | Depois desta entrega |
|---|---|---|
| Administrador da plataforma | não existe formulário nenhum | consegue criar a casca de um formulário e consultá-la, por API — ainda não por tela |
| Gestor de uma organização | idem | idem. A conferência de que a organização é a dele ainda não existe — ver o aviso abaixo |
| Quem responde o questionário | nada muda | nada muda: formulário em rascunho e sem perguntas não é respondível |
| Quem desenvolve | as tabelas de resposta e de pergunta apontam para o vazio | passa a existir o alvo dessas setas |

**Nenhuma tela do aplicativo web muda nesta rodada.** Quem exercita a API é dev, pelo
Swagger ou por linha de comando.

### O que entra nesta rodada

- A tabela de formulários, criada no banco local.
- A regra de que um formulário nasce em rascunho, com teste.
- A camada que grava e a que busca por identificador.
- Dois endereços de API: um para criar um formulário, outro para consultá-lo pelo
  identificador.
- O modelo de dados do time acertado para descrever a tabela como ela ficou.

### O que não entra — e por quê

- **As ligações com as outras tabelas.** A tabela de organizações ainda não existe, e uma
  ligação só pode ser criada depois do alvo. Elas entram numa tarefa de amarração,
  depois, quando todas estiverem de pé.
- **A coluna que aponta para uma pessoa específica.** O modelo de dados registra, em
  aberto, que ninguém sabe hoje o que essa coluna significa — se é "formulário feito sob
  medida para esta pessoa" ou resquício de um desenho que já foi corrigido. Criar coluna
  de significado desconhecido é pior que não criar: alguém grava nela e a decisão de
  produto passa a ter dado atrás.
- **Publicar ou encerrar um formulário.** Publicar um formulário sem nenhuma pergunta não
  faz sentido, e as perguntas são outra tarefa. O endereço que muda o estado nasce junto
  da tarefa que precisar dele.
- **Listar os formulários.** Uma listagem sem filtro por organização devolveria o
  formulário de todas as organizações para qualquer pessoa. O filtro depende de saber
  quem pertence a qual organização, o que ainda não existe.
- **Editar e apagar formulário.** Ninguém pediu nesta rodada.
- **As perguntas e as alternativas.** São tarefas próprias no board.
- **Qualquer mudança no aplicativo web.** Esta rodada é só servidor.
- **Colar a correção no dbdiagram e reexportar o diagrama do time.** A quarta entrega
  acerta o arquivo da proposta de correção; refazer o diagrama depende de o time aceitar a
  proposta inteira, que é decisão de outra conversa.

<!-- Os dois avisos são citações SEPARADAS de propósito: lista numerada dentro de `>`
     perde a numeração no ClickUp. Ver a nota de formato no fim deste arquivo. -->

> ⚠️ **Primeiro aviso, que precisa estar dito e não descoberto: o endereço de criação
> aceita qualquer organização, sem conferir.** Não há tabela de organizações para conferir
> contra. Também não há verificação de quem está chamando. Por isso: **nada de carga
> inicial ou dado de exemplo gravado nesta tabela**, e **esta API não vai para ambiente que
> não seja o local** antes da amarração. Quando a ligação for criada, o banco recusa
> qualquer linha cuja organização não exista de verdade — e uma linha inventada trava a
> migration para todo mundo.

> ⚠️ **Segundo aviso: duas tarefas estão gerando alteração de estrutura de banco ao mesmo
> tempo.** A CREED-34 está em review com a dela. Se as duas mesclarem sem cuidado, o banco
> fica com dois caminhos de evolução e ninguém consegue subir. A primeira subtarefa diz
> exatamente o que conferir antes de gerar.

### Como vai ser verificado

1. Subir o banco local e aplicar as mudanças de estrutura — a tabela aparece com as cinco
   colunas previstas e sem nenhuma ligação com outra tabela.
2. Derrubar o banco inteiro e subir de novo: reproduz exatamente a mesma estrutura.
3. Subir o servidor e criar um formulário pelo endereço de criação — ele volta em
   rascunho, com identificador e horário de criação.
4. Consultar esse formulário pelo identificador; consultar um identificador que não
   existe e receber "não encontrado".
5. Rodar a bateria de testes do servidor.
6. Abrir o modelo de dados e conferir que a tabela descrita ali é a mesma que está no
   banco.

### Decisões que tomamos sem a cliente

| O que decidimos | Por quê | Custo de mudar depois |
|---|---|---|
| O formulário tem **nome** — um campo próprio, obrigatório. Dois formulários com o mesmo nome na mesma organização são aceitos. | O modelo de dados do time não tem esse campo, e registra a falta como pergunta em aberto: "como o gestor identifica um formulário numa lista?". A descrição original desta tarefa pede nome, e nenhuma outra tarefa do board acrescenta o campo depois. Sem ele, escolhe-se formulário por código aleatório. | Baixo — a tabela nasce vazia, então tirar o campo ou proibir nome repetido custa uma alteração de estrutura só |
| O formulário **nasce sempre em rascunho**, e quem cria não escolhe o estado. | Um formulário publicado sem nenhuma pergunta não é respondível, e as perguntas ainda não existem. Oferecer a escolha do estado seria oferecer uma opção que não existe de verdade. | Baixo — é uma linha na regra e um campo a mais na entrada |
| O formulário é **da organização**, não de uma pessoa. A coluna que apontaria para uma pessoa não entra. | O modelo registra em aberto o que essa coluna significa. Com o dono sendo a organização e as respostas vindo de várias pessoas, a leitura mais provável é que ela seja resquício de um desenho já corrigido. | Baixo — acrescentar a coluna depois não exige mexer em nenhum dado |

As duas primeiras e a terceira **afastam o banco do diagrama**. Isso não fica solto: a
quarta entrega existe para registrar cada uma delas no modelo, com o motivo — ver abaixo.

### O que mudou em relação à descrição anterior desta tarefa

Esta descrição **substitui** a que estava aqui. Três pontos mudaram de conteúdo, não de
redação:

1. **A saída deixa de se chamar `FormResponse`.** Esse é o nome de **outra tabela** — a
   que registra "fulano abriu e respondeu o formulário X" — e ela já existe no
   repositório. Duas coisas diferentes com o mesmo nome dá confusão no primeiro uso. A
   saída passa a se chamar `FormRead`.
2. **O corpo da criação deixa de aceitar `status`.** O formulário nasce sempre em
   rascunho; ver as decisões acima.
3. **O nome do formulário passa a existir de verdade**, como coluna. A descrição anterior
   já o prometia, mas o modelo de dados não o tinha.

### As entregas

| # | Entrega | Onde | Depende de |
|---|---|---|---|
| 1 | CREED-331 - Tabela de formulários no banco | back | — |
| 2 | CREED-332 - Criar e buscar um formulário: regra e contratos | back | 1 |
| 3 | CREED-333 - Endpoints de criação e consulta de formulário | back | 2 |
| 4 | CREED-334 - Modelo de dados alinhado à tabela de formulários criada | modelo de dados | 1 |

As três primeiras são **sequenciais**: a 2 usa a tabela que a 1 cria, a 3 usa o que a 2
cria.

A **quarta corre em paralelo** com a 2 e a 3. Ela é a única que não toca o servidor: o
modelo de dados vive em outro repositório, e a regra do projeto é que uma tarefa não cruza
repositórios. Ela depende só da 1 — só dá para descrever o que existe depois que a tabela
existe.

### Contrato desta entrega

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/forms` | `{"name": "...", "organization_id": "<uuid>"}` | `FormRead` · 201 |
| GET | `/api/v1/forms/{form_id}` | — | `FormRead` · 200 |

Erros: **404** quando o identificador não existe · **422** quando o corpo está fora do
formato.

### Materiais desta tarefa

- ✅ Recorte do modelo de dados com a tabela de formulários — anexado na subtarefa 1
- ✅ Definições dos termos, coladas acima e em cada subtarefa
- ✅ Endereços dos arquivos de referência, linkados em cada subtarefa
- ✅ Texto das decisões tomadas sem a cliente, colado acima e em cada subtarefa

### Rastreio

```
Rastreio: 86e3anvgg — creed-ai-context/tarefas/86e3anvgg-form-table-context/spec.md
```

---

## Parte 3 — subtarefa 1

<!-- Título: CREED-331 - Tabela de formulários no banco -->
<!-- markdown_description em 86e3ap0uf, substituindo a descrição atual. -->

### Em uma frase

Criar, no banco, a tabela que guarda um formulário — nome, organização dona e estado.

### O que muda para quem usa

Ninguém usa esta entrega diretamente — ela é o chão sobre o qual as outras duas ficam de
pé. Hoje o banco da plataforma tem **uma tabela só**, a de usuários.

Vale entender três palavras, porque elas decidem a forma da tabela:

- **Formulário** é o instrumento que a plataforma aplica: um conjunto de perguntas que uma
  pessoa responde. Esta entrega cria **só a casca** dele. As perguntas são outra tarefa, e
  o registro de "fulano abriu e respondeu o formulário X" é outra ainda, já em revisão.
- **O dono do formulário é a organização, não uma pessoa.** Isso é correção registrada do
  modelo de dados: o desenho original tinha uma coluna de "criador" apontando para pessoa,
  e ela caiu. Quem pode editar e publicar sai do papel de cada pessoa **naquela
  organização**, não de uma coluna nesta tabela.
- **Rascunho** é o estado em que um formulário nasce, e o único que existe nesta rodada.
  Um formulário publicado sem nenhuma pergunta não seria respondível.

### Como pretendemos fazer

Criar uma pasta nova para o assunto "formulários" no servidor, declarar a tabela ali,
gerar a alteração de estrutura do banco automaticamente e **ler essa alteração linha a
linha** antes de aplicar — gerar é automático, aprovar não é.

Três coisas que esta entrega deliberadamente **não** faz, e que a pessoa provavelmente
esperaria fazer:

1. **Nenhuma ligação com outras tabelas.** A tabela de organizações ainda não existe, e
   uma ligação só pode ser criada depois do alvo. Ela entra numa tarefa de amarração,
   depois.
2. **A coluna que apontaria para uma pessoa específica não entra nem como coluna.** O
   modelo de dados registra, em aberto, que ninguém sabe hoje o que ela significa. Coluna
   de significado desconhecido é pior que coluna ausente: alguém grava nela, e a decisão
   de produto passa a ter dado atrás.
3. **Nenhuma rota.** Não procure onde registrar endpoint — isso é a terceira entrega.

A coluna da organização **fica**, mesmo sem ligação, porque é ela que dá sentido à linha:
um formulário que não pertence a ninguém não significa nada.

### Onde isso encosta no código

Repo: `creed-backend`.

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/forms/__init__.py` | a pasta do assunto novo |
| `app/domains/forms/models.py` | a tabela `form` e o tipo `FormStatus` |
| `alembic/env.py` | o import do model novo — ver o aviso abaixo |
| `alembic/versions/<hash>_create_form_table.py` | a alteração de estrutura, gerada e depois lida linha a linha |
| `tests/domains/forms/__init__.py` | — |
| `tests/domains/forms/test_models.py` | o teste que trava a forma da tabela |

O nome da pasta é `forms`, em inglês e no plural, porque **todo identificador no código
deste projeto é em inglês** — pasta, classe, método, variável, rota — e pasta de domínio é
`snake_case` no plural. Não use `form` no singular nem `formularios`. A decisão e o motivo
estão na
[decisão sobre o idioma do código](https://github.com/creed-educa-ai/creed-ai-context/blob/f3bb75d61ca2eaea902b68ca420af1cdd0fb6a25/decisoes/adrs/0005-idioma-do-codigo.md)
(abre no GitHub).

**`app/main.py` não é tocado.** Não há rota nesta entrega.

### A tabela, coluna a coluna

| Coluna | Tipo | Aceita vazio? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, gerada pela aplicação |
| `name` | `String(200)` | não | o nome do formulário |
| `organization_id` | `UUID` | não | **sem ligação** com a tabela de organizações nesta rodada |
| `status` | `Enum(FormStatus)` | não | `draft` · `published` · `closed`, nascendo em `draft` |
| `created_at` | `DateTime` com fuso | não | preenchida pelo banco |

Índice: `organization_id`. É a coluna do "me dá os formulários da minha organização", que
é a primeira consulta que vai existir.

`FormStatus` é um tipo enumerado declarado no próprio arquivo da tabela, com os três
valores acima — mesma forma que os dois tipos enumerados do molde.

**Não crie:** a coluna `participant_id`, nenhuma chave estrangeira, nenhuma restrição de
unicidade. Nem mesmo nome único por organização.

### ⚠️ A tabela acima não bate com o modelo de dados — e é de propósito

<!-- Acrescentado na segunda rodada (2026-09-21), junto da criação da CREED-334. -->

Se você abrir o diagrama do time ou o arquivo do modelo de dados, vai encontrar uma tabela
`Form` **diferente da de cima**, em dois pontos: **o modelo não tem o campo de nome**, e
**o modelo tem uma coluna apontando para uma pessoa** (`participant_id`).

**Não "corrija" a tabela para casar com o modelo.** As duas diferenças são decisões
tomadas de propósito, explicadas em "Decisões já tomadas que valem aqui". Elas respondem a
duas perguntas que o próprio modelo registrava em aberto.

**Quem reconcilia o modelo é a CREED-334**, subtarefa irmã desta. Pode correr em paralelo;
não depende de você e você não depende dela. É tarefa separada porque mexe em **outro
repositório** — o modelo de dados não vive no servidor —, e a regra do projeto é que uma
tarefa não cruza repositórios.

Na prática: **a tabela desta tarefa é a de cima**, coluna a coluna. O modelo é que vai ser
acertado.

### O passo que o autogenerate não perdoa

O arquivo `alembic/env.py` tem um comentário em caixa alta dizendo isto, e ainda assim é
o erro mais comum do projeto:

```python
from app.domains.forms import models as forms_models  # noqa: F401
```

Sem essa linha, a geração automática **não enxerga a tabela nova e a alteração sai
vazia** — e vazia ela aplica sem dar erro, o que faz a falha aparecer só quando alguém
for gravar.

### Antes de gerar: confira o head

Outra tarefa (CREED-34) está **em revisão** com uma alteração de estrutura gerada a partir
do mesmo ponto de onde esta vai sair. Se as duas mesclarem sem cuidado, o banco fica com
dois caminhos de evolução e ninguém consegue subir.

Rode `alembic current` **imediatamente antes** de gerar:

- se o ponto atual é `0b0ad39d779a` → gere normalmente;
- se é `49ef1d2c7b7e` (a CREED-34 já mesclou) → gere normalmente; a sua nasce em cima
  dela;
- se `alembic heads` devolver **duas linhas** → a saída é `alembic merge`. **Nunca** edite
  `down_revision` à mão.

### O que já existe e deve ser reusado

1. A base das tabelas e a sessão de banco estão em
   [`app/core/database.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/core/database.py).
   Herde de `Base` — **não crie outra**.
2. A tabela de exemplo completa é
   [`app/domains/users/models.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/users/models.py).
   Copie a **forma**: como a tabela é declarada, como o tipo enumerado é declarado e usado
   na coluna, como a chave e o horário de criação aparecem. **Os campos, não** — aqueles
   são de outro assunto.
3. A alteração de estrutura de exemplo é
   [`alembic/versions/0b0ad39d779a_create_user_table.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/alembic/versions/0b0ad39d779a_create_user_table.py).
   Copie a forma do arquivo — inclusive o **checklist de revisão no comentário do topo**,
   que é para preencher, não para copiar em branco.
4. O lugar onde o import do model precisa entrar é
   [`alembic/env.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/alembic/env.py).
5. O teste que confere as camadas é
   [`tests/test_arquitetura.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/tests/test_arquitetura.py).
   Ele roda sobre o assunto novo automaticamente; precisa continuar passando.

### Pronto quando

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] `alembic heads` devolve **um único head**.
- [ ] `\d form` mostra exatamente as cinco colunas da tabela acima, com os mesmos tipos e
      a mesma aceitação de vazio.
- [ ] A tabela **não** tem nenhuma chave estrangeira e **não** tem `participant_id`.
- [ ] Existe índice em `organization_id`.
- [ ] O model está importado em `alembic/env.py`, e o arquivo gerado **não** está vazio.
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
alembic revision --autogenerate -m "create form table"
alembic heads
alembic upgrade head
pytest tests/domains/forms tests/test_arquitetura.py -q
ruff check . && mypy app
```

Conferir a forma no banco:

```bash
docker compose exec db psql -U creed -d creed -c "\d form"
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

**O teste desta entrega** (`tests/domains/forms/test_models.py`) não precisa de banco: lê
a descrição da tabela direto do código. Ele trava o que é fácil de alguém desfazer sem
perceber — uma chave estrangeira acrescentada antes da amarração, ou a coluna de pessoa
voltando. Confere: as cinco colunas existem com a aceitação de vazio da tabela acima · a
lista de chaves estrangeiras está vazia · não existe coluna `participant_id` · existe
índice em `organization_id`.

### Decisões já tomadas que valem aqui

- **O formulário tem nome**, coluna própria e obrigatória, **sem** nome único por
  organização. O modelo de dados do time não tem esse campo e registra a falta como
  pergunta em aberto. Decidimos acrescentar sem confirmar com a cliente; se estiver
  errado, a tabela nasce vazia e tirar a coluna custa uma alteração de estrutura só.
- **O formulário nasce em rascunho.** Aqui isso aparece só como o valor padrão da coluna;
  quem aplica a regra de verdade é a segunda entrega.
- **O formulário é da organização, não de uma pessoa**, então a coluna que apontaria para
  uma pessoa não entra. Também decidido sem a cliente; acrescentá-la depois não exige
  mexer em nenhum dado.

### Materiais para consumir

| Material | Situação |
|---|---|
| A forma completa da tabela | ✅ escrita acima, coluna a coluna |
| Recorte do modelo de dados com a tabela de formulários | ✅ anexado nesta subtarefa |
| Definições de "formulário", "organização" e "rascunho" | ✅ coladas acima |
| Arquivos de referência do servidor | ✅ linkados acima (abrem no GitHub) |
| Aviso de que o modelo diverge, e quem reconcilia | ✅ escrito acima — a subtarefa irmã é a CREED-334 |

### Antes de abrir o PR

⚠️ Alteração de estrutura de banco precisa de leitura humana linha a linha antes do
commit. Pontos de atenção: `down_revision` apontando para o head certo · nenhuma chave
estrangeira tendo entrado sozinha na geração automática · o `downgrade()` derrubando só o
que este arquivo criou · `alembic heads` com um head só · o arquivo gerado **não** estar
vazio, que é o sintoma de ter esquecido o import em `alembic/env.py`.

### Rastreio

```
Rastreio: 86e3anvgg/1 — creed-ai-context/tarefas/86e3anvgg-form-table-context/1_task.md
```

---

## Parte 3 — subtarefa 2

<!-- Título: CREED-332 - Criar e buscar um formulário: regra e contratos -->
<!-- markdown_description em 86e3ap9jv, substituindo a descrição atual (vazia). -->

### Em uma frase

Ensinar o servidor a criar um formulário em rascunho e a buscá-lo pelo identificador.

### O que muda para quem usa

Ninguém de fora do time percebe diferença — não há tela nem endereço de API nesta entrega.
O que muda é que a regra do assunto "formulário" passa a existir e a ter teste.

A regra é curta: **o formulário nasce sempre em rascunho, e quem cria não escolhe o
estado.** Um formulário publicado sem nenhuma pergunta não seria respondível, e as
perguntas ainda não existem como tabela. Oferecer a escolha do estado na criação seria
oferecer uma opção que não existe de verdade.

É o mesmo corte que o cadastro de usuário já faz com o papel da pessoa: o contrato daquele
domínio diz, com todas as letras, que mandar o papel no corpo da criação é sintoma de ter
entendido o modelo ao contrário. Aqui vale igual para o estado do formulário.

### Como pretendemos fazer

Três camadas, com responsabilidades separadas — é a divisão que o projeto usa em todo
assunto, e furar ela quebra um teste automático:

- A camada que **fala com o banco** só grava e busca. Não decide nada, e quando não acha
  devolve "nada encontrado", sem levantar erro.
- A camada de **regra** é quem decide: monta o formulário já em rascunho e, quando a busca
  devolve nada, é ela quem levanta o erro de "não encontrado".
- A camada de **contratos de entrada e saída** descreve o que entra e o que sai.

O estado em rascunho é aplicado pela camada de **regra**, não pela tabela. O valor padrão
da coluna é a rede para quem montar um formulário por outro caminho; em conflito, vale a
linha da regra. O critério do projeto: *se a resposta muda quando o produto muda de ideia,
é regra; se muda quando o banco muda de forma, é acesso a dados.*

Duas armadilhas conhecidas, porque o projeto já tropeçou nelas:

1. **Não escreva `commit()` em lugar nenhum.** Quem fecha a transação é a requisição, no
   fim — o arquivo `app/core/database.py` cuida disso. A camada de banco usa `flush()` e
   `refresh()`. `commit()` fora de lá é sinal de camada furada, e existe teste automático
   que reprova.
2. **A camada que fala com o banco devolve "nada" quando não acha; ela não levanta erro.**
   Levantar ali é a camada de dados decidindo regra, que é trabalho da camada de regra.

Tudo é escrito em modo assíncrono (`async`), porque é assim que o resto do servidor é.

### Onde isso encosta no código

Repo: `creed-backend`.

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/forms/repository.py` | `insert(form)` e `get_by_id(form_id)` — o acesso ao banco |
| `app/domains/forms/service.py` | `create(dados)` e `get(form_id)` — a regra |
| `app/domains/forms/schemas.py` | `FormCreate` (entrada) e `FormRead` (saída) |
| `app/domains/forms/dependencies.py` | a montagem da cadeia sessão → banco → regra |
| `tests/domains/forms/test_service.py` | os casos abaixo |

**`app/main.py` não é tocado.** Não há rota nesta entrega — ela é a terceira.

### Os métodos que devem nascer

| Onde | Assinatura | Devolve |
|---|---|---|
| `repository.insert(form: Form)` | a entidade já montada | o formulário gravado, com identificador e horário preenchidos pelo banco |
| `repository.get_by_id(form_id: UUID)` | — | o formulário, **ou `None`** — não levanta erro |
| `service.create(dados: FormCreate)` | os dados já validados | o formulário criado, sempre em rascunho |
| `service.get(form_id: UUID)` | — | o formulário, ou `NotFoundError` |

Os nomes não são livres: **a camada de regra nomeia a intenção** e **a camada de banco
nomeia o acesso**. Um método de regra chamado `get_by_id` é acesso a banco disfarçado —
o nome descreve *como* se busca, que é assunto do banco. E `create_form` repete o assunto
que a classe já carrega: `FormService.create()` não é ambíguo.

### Os contratos

`FormCreate` — o que entra — leva **dois** campos:

| Campo | Tipo | Regra |
|---|---|---|
| `name` | `str` | obrigatório, entre 2 e 200 caracteres |
| `organization_id` | `UUID` | obrigatório |

**`status` não entra.** Não é esquecimento — está explicado acima.

`FormRead` — o que sai — devolve `id`, `name`, `organization_id`, `status` e `created_at`.
A montagem da saída a partir da tabela mora **neste arquivo**, num método de classe, e
**não na camada de rota** — é o que permite à rota não conhecer a tabela.

⚠️ **A saída chama-se `FormRead`, não `FormResponse`.** `FormResponse` é o nome de **outra
tabela** — a que registra "fulano abriu e respondeu o formulário X" — e já existe como
classe no repositório. Duas coisas diferentes com o mesmo nome dá confusão no primeiro
uso. É desvio consciente do sufixo que o molde usa, e a descrição anterior desta tarefa já
tinha chegado nele sozinha.

### O que já existe e deve ser reusado

1. O acesso a banco de exemplo é
   [`app/domains/users/repository.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/users/repository.py).
   Copie a forma: a sessão assíncrona, a consulta, e o `add` + `flush` + `refresh` do
   método de criação — repare que **não há `commit()`**.
2. A camada de regra de exemplo é
   [`app/domains/users/service.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/users/service.py).
   Repare no comentário que explica **por que** o estado mora na regra e não na tabela: é
   exatamente o mesmo caso aqui.
3. Os contratos de exemplo estão em
   [`app/domains/users/schemas.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/users/schemas.py):
   entrada e saída separadas, o `ConfigDict(from_attributes=True)` na saída e o método de
   classe que monta a saída a partir da tabela.
4. A montagem da cadeia de exemplo está em
   [`app/domains/users/dependencies.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/users/dependencies.py):
   `get_repository` → `get_service` → `ServiceDep`.
5. Os erros padronizados estão em
   [`app/shared/exceptions.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/shared/exceptions.py).
   Use `NotFoundError` — **não crie exceção nova**.
6. O teste de exemplo, com dublê no lugar do banco, é
   [`tests/domains/users/test_service.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/tests/domains/users/test_service.py).
   **Não existe banco de teste no projeto** — a regra é testada com dublê. Repare na
   função auxiliar que monta a entidade à mão com **todos** os campos explícitos: valores
   padrão só são aplicados na gravação, então uma entidade que nunca passou pela sessão
   tem `None` neles.

### Pronto quando

- [ ] `service.create` devolve um formulário em **rascunho**.
- [ ] `service.create` devolve o nome e a organização que recebeu, sem alterar.
- [ ] `service.get` levanta `NotFoundError` quando o identificador não existe.
- [ ] `repository.get_by_id` devolve `None` no mesmo caso — **não** levanta.
- [ ] `FormCreate` **não** tem campo `status`.
- [ ] `FormCreate` recusa `name` com menos de 2 caracteres e `organization_id` que não é
      UUID.
- [ ] `FormRead` devolve os cinco campos: `id`, `name`, `organization_id`, `status`,
      `created_at`.
- [ ] Nenhum `commit()` no diff, fora de `app/core/database.py`.
- [ ] `service.py` não importa `fastapi` nem `sqlalchemy`.
- [ ] `repository.py` não importa `schemas`.
- [ ] `pytest tests/test_arquitetura.py` passa.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/forms -q
ruff check . && mypy app && pytest
```

**Caso feliz:** criar um formulário com nome e organização — ele volta em rascunho, com
identificador e horário de criação preenchidos.

**Casos de borda, nomeados:** buscar um identificador que não existe → `NotFoundError` na
camada de regra e `None` na camada de banco · nome com um caractere só → recusado ·
nome com 201 caracteres → recusado.

### Decisões já tomadas que valem aqui

- **O formulário nasce sempre em rascunho, e o estado não entra no corpo da criação.** É a
  regra que esta entrega implementa. Decidimos sem confirmar com a cliente, porque
  publicar um formulário sem perguntas não faz sentido e as perguntas ainda não existem.
  Se cair, muda uma linha na camada de regra e um campo na entrada.
- **O formulário tem nome, sem exigir nome diferente dentro da mesma organização.** Aqui
  isso aparece como o nome ser obrigatório na entrada e **nada** recusar nome repetido.

### Materiais para consumir

| Material | Situação |
|---|---|
| Assinaturas dos métodos e conteúdo dos contratos | ✅ escritos acima |
| Arquivos de referência do servidor | ✅ linkados acima (abrem no GitHub) |
| Texto das decisões tomadas sem a cliente | ✅ colado acima |

### Depende de

**Entrega 1 — "Tabela de formulários no banco".** Esta entrega importa a tabela que a 1
cria; não dá para começar antes de ela estar mesclada.

### Rastreio

```
Rastreio: 86e3anvgg/2 — creed-ai-context/tarefas/86e3anvgg-form-table-context/2_task.md
```

---

## Parte 3 — subtarefa 3

<!-- Título: CREED-333 - Endpoints de criação e consulta de formulário -->
<!-- markdown_description em 86e3apa4p, substituindo a descrição atual. -->

### Em uma frase

Abrir os dois endereços de API que criam um formulário e o consultam pelo identificador.

### O que muda para quem usa

Esta é a única das três entregas que produz algo que dá para **ver de fora**: uma porta de
API que responde. Ainda assim, **nenhuma tela do aplicativo web a consome** — quem
exercita é dev, pelo Swagger ou por linha de comando.

No servidor deste projeto, a camada de rota é o que em outros lugares se chama de
*controller*: recebe, deixa o framework conferir o formato, chama a camada de regra e
devolve. **Nenhuma decisão de negócio mora aqui**, e ela **não conhece a tabela** — existe
teste automático que reprova uma rota que conheça.

O que a rota faz de próprio é **traduzir erro de negócio em código HTTP**: a camada de
regra levanta "não encontrado" sem saber o que é um 404; quem sabe é a rota.

⚠️ **Duas coisas que esta entrega deliberadamente não faz, e que quem lê provavelmente
esperaria:** a rota **não confere se a organização existe**, e **não confere se quem chama
tem direito sobre ela**. A tabela de organizações ainda não existe, e a que diz quem
pertence a qual organização também não. Na prática: qualquer identificador de organização
é aceito. É risco conhecido e aceito — e tem consequência prática, no fim desta tarefa.

### Como pretendemos fazer

Um roteador com prefixo `/forms`, registrado em `app/main.py` junto dos outros. O prefixo
`/api/v1` **não** se escreve no roteador: ele vem da configuração, no momento do registro.
Escrevê-lo de novo produz `/api/v1/api/v1/forms`.

Os quatro códigos de resposta:

| Situação | Código | Quem produz |
|---|---|---|
| formulário criado | **201** | declarado no decorador da rota |
| formulário encontrado | **200** | padrão |
| identificador não existe | **404** | a rota, traduzindo o erro de negócio |
| corpo fora do formato | **422** | o FastAPI sozinho, sem nenhum código seu |

### Onde isso encosta no código

Repo: `creed-backend`.

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/forms/router.py` | os dois endpoints |
| `app/main.py` | o import e a entrada na lista de roteadores |
| `tests/domains/forms/test_router.py` | os quatro casos acima |

### O contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/forms` | `{"name": "...", "organization_id": "<uuid>"}` | `FormRead` · 201 |
| GET | `/api/v1/forms/{form_id}` | — | `FormRead` · 200 |

**Corpo da saída**

```json
{
  "id": "uuid",
  "name": "string",
  "organization_id": "uuid",
  "status": "draft",
  "created_at": "2026-09-21T14:00:00Z"
}
```

**Erros**

| Código | Quando | Corpo |
|---|---|---|
| 404 | o identificador não existe | `{"detail": "..."}`, com a mensagem do erro de negócio |
| 422 | nome curto demais ou ausente, organização que não é UUID | validação padrão do FastAPI |

**`status` não entra no corpo da criação.** O formulário nasce sempre em rascunho — a
decisão e o motivo estão na segunda entrega.

### O que já existe e deve ser reusado

1. A rota de exemplo é
   [`app/domains/users/router.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/domains/users/router.py).
   Copie a forma: o `APIRouter` com prefixo e etiqueta, a regra chegando por `ServiceDep`
   (**não instancie nada à mão**), a saída montada pelo método de classe do contrato
   (**não** devolvendo a tabela direto), e o `try/except` que traduz o erro de negócio em
   `HTTPException`.
2. O lugar onde registrar é
   [`app/main.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/app/main.py).
   Copie a forma do que já está lá: um import junto dos outros e o nome acrescentado à
   tupla do laço que registra. **Não** registre com prefixo próprio.
3. O teste de rota de exemplo é
   [`tests/domains/authentication/test_router.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/tests/domains/authentication/test_router.py).
   **Não existe banco de teste no projeto** — o teste monta uma aplicação só com este
   roteador e troca a camada de regra por um dublê. O que se prova aqui é **só o contrato
   HTTP**: código de status e forma do corpo. A regra já foi provada na entrega 2; não a
   teste de novo.
4. O teste que confere as camadas é
   [`tests/test_arquitetura.py`](https://github.com/creed-educa-ai/creed-backend/blob/db177b5be91647a7d22831c1064b0b5a6c16add8/tests/test_arquitetura.py).
   Precisa continuar passando.

### Pronto quando

- [ ] `POST /api/v1/forms` com corpo válido devolve **201** e um corpo com exatamente as
      cinco chaves da saída.
- [ ] O formulário criado volta com `"status": "draft"`.
- [ ] `GET /api/v1/forms/{id}` de um formulário que existe devolve **200** com o mesmo
      formato.
- [ ] `GET /api/v1/forms/{id}` de um identificador que não existe devolve **404**.
- [ ] `POST` sem nome, com nome vazio, ou com organização que não é UUID devolve **422** —
      sem nenhum código escrito para isso.
- [ ] Os dois endpoints aparecem em `/api/v1/docs`, sob a etiqueta `forms`.
- [ ] A rota final é `/api/v1/forms`, **não** `/api/v1/api/v1/forms`.
- [ ] `router.py` não importa `models` nem `sqlalchemy`.
- [ ] Nenhum `if` sobre dado de negócio dentro de `router.py`.
- [ ] `pytest tests/test_arquitetura.py` passa.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/forms -q
ruff check . && mypy app && pytest
```

De ponta a ponta, com banco:

```bash
docker compose up -d db
alembic upgrade head
uvicorn app.main:app --reload
```

Em outro terminal — **caso feliz**:

```bash
curl -i -X POST localhost:8000/api/v1/forms \
  -H 'Content-Type: application/json' \
  -d '{"name":"Instrumento piloto","organization_id":"00000000-0000-0000-0000-000000000001"}'
```

**Casos de borda, nomeados** — identificador que não existe, e nome vazio:

```bash
curl -i localhost:8000/api/v1/forms/00000000-0000-0000-0000-000000000000

curl -i -X POST localhost:8000/api/v1/forms \
  -H 'Content-Type: application/json' \
  -d '{"name":"","organization_id":"00000000-0000-0000-0000-000000000001"}'
```

### O que não pode acontecer

A rota aceita qualquer organização, porque não há tabela de organizações para conferir.
Enquanto a tarefa de amarração não ligar as duas, isso tem duas consequências práticas:

- **Nenhuma carga inicial ou dado de exemplo pode ser gravado na tabela de formulários.**
  O que for criado à mão em desenvolvimento é descartável e some ao derrubar o banco.
- **Esta API não vai para ambiente que não seja o local** antes da amarração. Quando a
  ligação for criada, o banco recusa qualquer linha cuja organização não exista de verdade
  — e uma linha inventada trava a alteração de estrutura para todo mundo.

Quem cuida do deploy precisa saber disso.

### Decisões já tomadas que valem aqui

- **O formulário nasce sempre em rascunho; o estado não entra no corpo da criação.** Aqui
  isso aparece como o campo simplesmente não existir na entrada. Decidido sem a cliente;
  se cair, o corpo ganha um campo e a camada de regra ganha uma linha.
- **O formulário tem nome.** Aqui isso aparece como o nome ser obrigatório na entrada e
  vir na saída.

### Materiais para consumir

| Material | Situação |
|---|---|
| Contrato dos dois endpoints, com erros | ✅ escrito acima |
| Arquivos de referência do servidor | ✅ linkados acima (abrem no GitHub) |
| Texto das decisões tomadas sem a cliente | ✅ colado acima |

### Depende de

**Entrega 2 — "Criar e buscar um formulário: regra e contratos".** Esta entrega importa a
camada de regra e os contratos que a 2 cria; não dá para começar antes de ela estar
mesclada.

### Rastreio

```
Rastreio: 86e3anvgg/3 — creed-ai-context/tarefas/86e3anvgg-form-table-context/3_task.md
```

---

---

## Parte 3 — subtarefa 4

<!-- Título: CREED-334 - Modelo de dados alinhado à tabela de formulários criada -->
<!-- markdown_description, parent = 86e3anvgg. CRIADA na segunda rodada (2026-09-21). -->
<!-- Corpo técnico completo em 4_task.md; aqui está a versão publicada, em linguagem de board. -->

### Em uma frase

Fazer o modelo de dados do time voltar a descrever a tabela de formulários como ela existe
de verdade no banco.

### O que muda para quem usa

Ninguém de fora do time percebe diferença — não há código de produto aqui. O que muda é
para **quem abre o modelo de dados para desenhar a próxima tabela**, que são as tarefas de
pergunta, de alternativa e de organização, todas no board.

Ao criar a tabela de formulários, o time tomou duas decisões que **afastam o banco do
diagrama**: o formulário **ganhou um campo de nome**, que o diagrama não tinha, e **não
ganhou** a coluna que apontava para uma pessoa específica, que o diagrama tem.

**O problema não é a divergência — é ela ficar sem registro.** Quem abrir o diagrama daqui
a duas semanas vê uma tabela que não bate com o banco, sem nada explicando por quê. O
desfecho mais provável é alguém "consertar" o código para casar com o desenho, apagando o
campo de nome.

### Por que isto é subtarefa, e não item da primeira

1. **É outro repositório.** A primeira entrega mexe no servidor; esta, na documentação do
   modelo — e o desenho de verdade vive no dbdiagram.io. A regra do projeto é que uma
   tarefa não cruza repositórios.
2. **Não dá para verificar no mesmo lugar.** O "pronto" da primeira é a migration subir e
   os testes passarem; o desta é um texto revisado. Amarrar uma na outra faz o CI de um
   repositório travar o merge do outro.
3. **O ator é outro.** Quem escreve a migration é dev de backend; quem mexe no modelo de
   dados é quem cuida do diagrama do time.

### As três divergências desta rodada

| O que o modelo diz | O que a migration criou | Decisão |
|---|---|---|
| a tabela de formulários não tem campo de nome | `form.name`, texto até 200, obrigatório, sem unicidade | P-016 |
| a tabela tem uma coluna apontando para uma pessoa (`participant_id`) | a coluna não foi criada | P-018 |
| existe a relação `Form → Participant`, pela linha `Ref:` | nenhuma relação entre as duas tabelas | P-018 |

> ⚠️ **A coluna de pessoa custa três mexidas no arquivo, não uma.** Tirar a coluna do bloco
> `Table Form` **não** remove a relação: a seta vive numa linha `Ref:` separada, no fim do
> arquivo. E um `.dbml` com `Ref:` apontando para coluna que não existe **não carrega no
> dbdiagram** — o editor recusa o arquivo inteiro. São três: a coluna, a linha `Ref:` e a
> contagem de FKs do cabeçalho.

### O que fazer

Corpo publicado na íntegra na subtarefa — os cinco passos (tabela `Form` reescrita na
proposta com os comentários `[C29]`/`[C30]`, linha `Ref:` removida, contagem do cabeçalho
acertada, pendências #17 e #21 com desfecho, e a conferência das divergências vizinhas).
O detalhamento técnico está em [`4_task.md`](4_task.md).

A conferência final que vale mais que os `grep`: **colar o arquivo no dbdiagram**. Se
carregar, as três mexidas estão coerentes entre si; se recusar, sobrou `Ref:` órfã.

### A conferência que esta subtarefa pede, e não corrige

Duas divergências de **outras** tarefas, para reportar por escrito:

- `Answer.form_response_id` — a CREED-31 decidiu não criar a coluna; o modelo a traz como
  `not null`.
- `form_response` **sem nenhum índice** — a migration `49ef1d2c7b7e` da CREED-34, em
  review, cria só a chave primária. O modelo pede três índices, incluindo o
  `unique (form_id, vinculo_id)` da correção `[C5]`, que existe para impedir o mesmo
  vínculo responder o mesmo formulário mais de uma vez. ⚠️ **Regra de integridade caindo em
  silêncio, com a PR ainda aberta.**

### Decisões já tomadas que valem aqui

P-016 e P-018 foram **fechadas em 2026-09-21 pelos AGES IV** — decisão de time, não da
cliente. Estão na seção "Fechadas" do ledger.

⚠️ A ressalva que a subtarefa publicada carrega por escrito: **P-018 fechou a premissa, não
a pergunta.** A pendência #21 (*"existe formulário feito sob medida para uma pessoa
específica?"*) é lacuna de **produto**, está na lista que vai para a cliente e continua
aberta. Ao escrever o desfecho dela no `modelo-de-dados.md`, a instrução é explícita: **não
escrever que foi respondida** — escrever que a decisão de não criar a coluna foi tomada.

### Rastreio

```
Rastreio: 86e3anvgg/4 — creed-ai-context/tarefas/86e3anvgg-form-table-context/4_task.md
```

## Nota de formato — o que não sobrevive no ClickUp

Descoberto na publicação da CREED-31, em 2026-09-19, e aplicado aqui desde o rascunho:
**o ClickUp remove link markdown dentro de célula de tabela**, e descarta negrito dentro
de célula. Link em **prosa** ou em **lista** sobrevive normalmente.

Por isso a seção "O que já existe e deve ser reusado" é **lista numerada** nas três
subtarefas — é exatamente a seção em que o checklist do projeto exige permalink que abre.
Tabela, aqui, só para dado tabular sem link.

### Achado novo, na conferência pós-publicação de 2026-09-21

**Lista numerada dentro de citação (`>`) perde a numeração.** O bloco "Dois avisos que
precisam estar ditos" foi escrito como `> 1.` / `> 2.` e chegou ao board como duas linhas
soltas dentro da citação: o texto está inteiro, a ordem se perde. Para quem lê no board,
"o primeiro aviso" deixa de ter âncora.

Regra que sai daí: **numeração e citação não se combinam.** Ou a lista é numerada fora da
citação, ou o aviso vira parágrafo com o número escrito por extenso no texto.

Dois detalhes menores, cosméticos, registrados para ninguém achar que é erro:

- **Negrito encostado em `código` é partido em dois.** `**A saída deixa de se chamar
  `FormResponse`.**` vira dois trechos em negrito com a crase no meio. Não some nada.
- **O ClickUp adivinha a linguagem do bloco de código.** O bloco de rastreio, sem
  linguagem declarada, chegou marcado como `verilog`. Inofensivo — mas se incomodar, basta
  declarar a linguagem.
