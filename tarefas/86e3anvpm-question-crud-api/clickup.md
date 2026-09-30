# CREED-35 — rascunho de publicação no ClickUp

```
Épico: 86e3anvpm — CREED-35 - Question
Spec: spec.md · Tasks: tasks.md
Gerado em: 2026-09-22 · Publicado em: 2026-09-22 (primeira rodada: épico + 3 subtarefas, sobrescritos)
Terceira rodada (seção da pergunta): publicada em 2026-09-22 — épico e 351–353 atualizados, 354 criada
Permalinks apontam para creed-backend @ e7a8c3253c12a288b3d0fbb84134aff0d98adfdb (origin/dev)
e creed-ai-context @ c5a0322c60d5446306b40e7bf79e4991b357389c (origin/main)
```

## Mapa de publicação — terceira rodada (publicada)

| # | Subtarefa no board | Repo | Ação | ID |
|---|---|---|---|---|
| — | CREED-35 (épico) | — | ✅ descrição atualizada | `86e3anvpm` |
| 1 | CREED-351 - Tabela de perguntas no banco, com o domínio `questions` | back | ✅ descrição atualizada (título igual) | `86e3ap1dm` |
| 2 | CREED-352 - Criar e listar perguntas: regra e contratos | back | ✅ descrição atualizada (título igual) | `86e3apg22` |
| 3 | CREED-353 - Endpoints de criação e listagem de perguntas | back | ✅ descrição atualizada (título igual) | `86e3apgm5` |
| 4 | CREED-354 - Modelo de dados descrevendo a seção da pergunta | harness | ✅ **criada**, com `parent = 86e3anvpm` | `86e3d0jvc` |

**Correspondência:** as quatro descrições publicadas terminam com `Rastreio:`. As três
subtarefas têm rastreio `86e3anvpm/1`, `/2` e `/3`, e o texto gerado mudou (entrou a
seção), então a ação é **atualizar**. Não existe subtarefa com `86e3anvpm/4`, então a
ação é **criar**. Nenhuma subtarefa sem rastreio foi encontrada.

**Numeração:** `CREED-354` segue o padrão épico × 10 + n do board. `351`, `352` e `353`
já estão em uso.

### O que muda em cada uma, nesta rodada

- **Épico:** "Três palavras" (entra **Seção**); linha nova em "Para quem" (quem desenvolve o front); entra a seção em "O que entra", no contrato (campo obrigatório e `?section=`) e na verificação; três itens novos em "O que não entra"; P-020 e P-028 em "Decisões que tomamos sem a cliente"; item 5 em "O que mudou"; a entrega 4 na tabela de entregas.
- **CREED-351:** o que é a seção e como ela difere do prisma; a coluna na tabela; o enum com o comentário da premissa; o `downgrade()` que apaga os tipos enum; o banco guardando o nome do membro; critérios e teste novos; segundo caso de borda (`alembic downgrade -1`).
- **CREED-352:** `section` nos contratos; filtro no `WHERE` da consulta; a regra da posição valendo entre seções; critérios e casos de teste novos; o limite do dublê para o filtro.
- **CREED-353:** o parâmetro `?section=` com o código do endpoint; o enum chegando por `schemas.py`, porque o teste de arquitetura reprova router que importa `models`; `curl` de filtro e de 422; critérios novos.
- **CREED-354:** nova. É a tradução do `4_task.md`.

### Histórico: primeira rodada, sobrescrita com mandato

As três subtarefas que já estavam no board não tinham a linha `Rastreio:`. Pela regra de
correspondência, subtarefa sem rastreio não se toca. **O mandato para sobrescrevê-las
veio explícito do usuário em 2026-09-22**, pela mesma conduta que a CREED-33 seguiu:
mesmos IDs e mesma numeração (`351/352/353`), título e descrição novos, nenhuma subtarefa
fechada e nenhuma criada.

O que se perdeu ao sobrescrever, registrado antes de apagar:

- **CREED-351** tinha o passo a passo do Alembic (preservado e ampliado) e uma imagem embutida no corpo (`image.png`, 8 KB, anexo `2dcf6b89-96b0-4e7e-a647-b5a0faf2ee7a`). O anexo continua na subtarefa e a imagem é embutida de novo no corpo novo. O conteúdo dela não foi conferido.
- **CREED-352** dizia que `Question` "existe isolada, sem vínculo com `Form`", sem a coluna `form_id`. Isso contradizia o contrato do épico, e caiu. Também pedia `service.get_by_id(id)`, que não existe no contrato publicado.
- **CREED-353** chamava a saída de `QuestionRead`. Passou a ser `QuestionResponse`.

A **segunda rodada** foi só de formatação: os itens de lista passaram a ter uma linha
só. Ver a nota de formato no fim.

## Materiais — visão do épico

| Material | Onde está | Vai em | Situação |
|---|---|---|---|
| Recorte do modelo de dados (tabela `Question`) | anexo já existente na CREED-351 (`image.png`) | subtarefa 1 | ✅ anexado, **conteúdo a conferir — AGES III/IV**. Ele é anterior à seção, então certamente **não** mostra `section` |
| Molde do backend (permalinks GitHub) | `origin/dev` @ `e7a8c325` | subtarefas 1, 2 e 3 | ✅ linkado no corpo, em lista |
| Arquivos do modelo de dados (permalinks GitHub) | `creed-ai-context` @ `c5a0322c` | subtarefa 4 | ✅ linkado no corpo, em lista |
| Texto das premissas P-019, P-020 e P-028 | `decisoes/premissas.md` | épico e subtarefas | ✅ colado no corpo |
| Definição de "Pergunta", "Prisma" e "Seção" | `glossario.md` | épico e subtarefas 1 e 4 | ✅ colada no corpo |
| Contrato dos dois endpoints, com erros e o filtro | `spec.md` → "Contrato" | épico e subtarefa 3 | ✅ escrito no corpo |
| Blocos do `.dbml` a colar (enum e coluna) | `4_task.md` | subtarefa 4 | ✅ colado no corpo |
| Link do ADR-0005 (idioma do código) | `decisoes/adrs/0005-idioma-do-codigo.md` | subtarefa 1 | ✅ linkado no corpo |

**Nenhum `⬜`.** A ressalva da imagem aumentou: ela é de antes da seção, então mesmo que
seja a tabela `Question`, está desatualizada em uma coluna. A subtarefa 1 diz isso.

---

## Parte 2 — descrição do épico

<!-- markdown_description em 86e3anvpm = TUDO abaixo, substituindo a descrição atual. -->

### O que é

Um formulário (CREED-33, em andamento em paralelo) é hoje uma casca vazia: nasce com
nome, dono e estado, mas não tem uma única pergunta dentro. Esta entrega cria a tabela
de **perguntas**: o enunciado, a posição de cada uma no formulário, se é obrigatória
responder, o tipo — múltipla escolha ou resposta livre — e a **seção** do formulário em
que a pergunta aparece na tela.

### Três palavras, antes de tudo

- **Pergunta** — um item de um formulário: o enunciado, a ordem em que aparece, se é obrigatória, o tipo (múltipla escolha ou resposta livre) e a seção. As alternativas de uma pergunta de múltipla escolha **não** entram aqui — são outra tarefa (CREED-37).
- **Seção** — a parte do formulário em que a pergunta é desenhada na tela. É um valor de uma lista fixa, não algo que o gestor cria. A tela usa a seção para dividir o formulário em blocos.
- **Prisma** — uma das cinco dimensões de análise do produto (plasticidade humana, empreendedorismo, multiculturalismo, neuroinovação, tomada de decisão). Cada pergunta pode, opcionalmente, ser marcada com a dimensão a que pertence, para que o painel agregue respostas por dimensão depois. **Não é a seção**: a seção organiza a tela, o prisma organiza a análise, e uma pergunta tem os dois.

### Para quem, e o que muda para essa pessoa

| Quem | Hoje | Depois desta entrega |
|---|---|---|
| Administrador da plataforma | não existe pergunta nenhuma | consegue cadastrar as perguntas de um formulário, escolhendo a seção de cada uma, e listar as que já existem, por API — ainda não por tela |
| Gestor de uma organização | idem | idem |
| Quem responde o questionário | nada muda | nada muda nesta rodada. Quando a tela de resposta existir, é para essa pessoa que a seção importa: é ela quem vê o formulário dividido em partes |
| Quem desenvolve o front | não tem como saber em que parte do formulário desenhar uma pergunta | cada pergunta traz a própria seção, e a listagem pode devolver só as perguntas de uma seção |
| Quem desenvolve o back | a tabela de resposta a uma pergunta e a de alternativas apontam para o vazio | passa a existir o alvo dessas setas |

**Nenhuma tela do aplicativo web muda nesta rodada.** Quem exercita a API é dev, pelo
Swagger ou por linha de comando.

### O que entra nesta rodada

- A tabela de perguntas, criada no banco local, num domínio próprio, com a coluna de seção.
- A regra de que duas perguntas do mesmo formulário não podem ocupar a mesma posição — mesmo em seções diferentes.
- A camada que grava e a que lista as perguntas de um formulário, todas ou só as de uma seção.
- Dois endereços de API: um para cadastrar uma pergunta, outro para listar as de um formulário, com filtro opcional por seção.
- O modelo de dados do time passando a descrever a coluna de seção, que ele ainda não tem.

### O que não entra — e por quê

- **Editar e apagar pergunta.** O contrato publicado nesta tarefa só tem os dois endereços acima — nenhuma subtarefa do board cita edição. Fica para uma tarefa futura.
- **Decidir quais são as seções.** O time decidiu que a seção existe, mas não quais são. Esta entrega implementa com uma lista provisória — ver "Decisões que tomamos sem a cliente".
- **Título, descrição e ordem das seções na tela.** A seção é um valor fixo de uma lista. O texto que aparece e a ordem entre as seções são decisão da tela. Se o gestor precisar escrever o título de uma seção, ou criar seções por formulário, isso vira outra estrutura.
- **Consultar perguntas por seção entre formulários.** Sem filtro por organização, essa consulta mostraria perguntas de todas as organizações a qualquer pessoa. A consulta por seção é sempre dentro de um formulário.
- **Conferir que o formulário existe.** A tabela de formulários está sendo criada ao mesmo tempo, em outra tarefa (CREED-33) e em outro domínio do código. Um domínio não pode ler a tabela de outro sem que isso vire uma regra escrita — e essa regra ainda não existe. Cadastrar uma pergunta para um formulário que não existe é aceito nesta rodada; listar as perguntas de um formulário que não existe devolve lista vazia, e não erro. Fica para a tarefa de amarração das tabelas, quando ela vier.
- **A ligação de banco entre pergunta e formulário.** Mesmo motivo.
- **As alternativas de múltipla escolha.** São a CREED-37, tarefa própria.
- **Verificar se quem chama tem direito sobre o formulário.** Depende de saber quem pertence a qual organização, o que ainda não existe.
- **Qualquer mudança no aplicativo web.** Esta rodada é só servidor. A tela que desenha o formulário por seção é outra tarefa, e é ela que consome este contrato.

> ⚠️ **Primeiro aviso: a API aceita qualquer identificador de formulário, sem
> conferir.** Não há como conferir, porque a tabela de formulários está sendo criada em
> paralelo, em outro domínio. Consequência prática: nenhuma carga inicial ou dado de
> exemplo pode ser gravado na tabela de perguntas, e esta API não vai para ambiente que
> não seja o local antes da tarefa de amarração. Quando a ligação entre as duas tabelas
> for criada, o banco vai recusar qualquer pergunta cujo formulário não exista de
> verdade — e uma linha inventada trava a migração para todo mundo.

> ⚠️ **Segundo aviso: a lista de seções é provisória, e vai parecer definitiva.** Ela
> vai estar no código, nos testes e na documentação da API. Trocar a lista enquanto a
> tabela está vazia custa quase nada. Trocar depois de gravar perguntas de verdade exige
> uma alteração de estrutura do banco, a atualização das linhas gravadas e a troca dos
> textos na tela. **A lista precisa ser confirmada pelo time antes da primeira pergunta
> real ser gravada**, e quem fizer a tela das seções precisa saber disso antes de
> começar.

### Como vai ser verificado

1. Subir o banco local e aplicar as mudanças de estrutura — a tabela de perguntas aparece com as colunas previstas, a de seção entre elas, e sem nenhuma ligação com outra tabela.
2. Derrubar o banco inteiro e subir de novo: reproduz exatamente a mesma estrutura.
3. Subir o servidor e cadastrar perguntas em seções diferentes pelo endereço de criação.
4. Cadastrar uma segunda pergunta na mesma posição do mesmo formulário, mesmo em outra seção, e receber conflito, não erro de servidor.
5. Cadastrar uma pergunta sem seção e receber erro de formato.
6. Listar as perguntas de um formulário — em ordem —, listar só as de uma seção, e listar as de um formulário sem nenhuma pergunta, recebendo lista vazia.
7. Pedir uma seção que não existe e receber erro de formato.
8. Rodar a bateria de testes do servidor.
9. Abrir o modelo de dados e conferir que a coluna de seção está descrita, com a lista marcada como provisória.

### Decisões que tomamos sem a cliente

| O que decidimos | Por quê | Custo de mudar depois |
|---|---|---|
| Esta entrega cobre só **cadastrar** e **listar** perguntas. Editar e apagar ficam para uma tarefa futura, apesar de o resumo original desta tarefa falar em "editar". | O contrato publicado na própria tarefa só tinha os dois endereços de criar e listar, e nenhuma das três subtarefas do board citava edição. Ampliar o escopo sem pedido explícito seria inventar entrega. | Baixo — um endpoint de edição é uma rota a mais e um método de regra a mais, sem mudar a tabela |
| As seções são, **provisoriamente**, `profile` (quem responde e o contexto dela), `assessment` (o núcleo do instrumento) e `closing` (fechamento e reflexão). | O time decidiu que a pergunta tem seção, mas deixou explícito que as seções ainda não estão definidas. Nenhum documento do projeto descreve a divisão do formulário. Três valores é o menor número que deixa o filtro e a tela testáveis. **Confirmar com o time; se a divisão do formulário for decisão da cliente, entra na pauta da reunião.** | **Baixo hoje, alto depois.** Com a tabela vazia, é trocar a lista e regerar a alteração de estrutura. Com pergunta gravada, é alteração de estrutura, atualização das linhas e troca dos textos na tela |
| Toda pergunta pertence a uma seção: o campo é obrigatório e não tem valor padrão. | A tela usa a seção para decidir onde desenhar a pergunta. Uma pergunta sem seção obrigaria a tela a ter um "resto" sem nome, e um valor padrão esconderia a escolha de quem cadastra. | Baixo — a tabela nasce vazia; tornar o campo opcional depois é uma alteração de uma linha |

### O que mudou em relação à descrição anterior desta tarefa

Esta descrição **substitui** a que estava aqui. Cinco pontos mudaram de conteúdo, não só
de redação:

1. **Só cadastrar e listar, não editar.** O resumo anterior prometia "cadastrar e editar", mas o contrato publicado só tinha os endereços de criar e listar. Valeu o contrato. Ver "Decisões que tomamos sem a cliente".
2. **Sai o schema `QuestionUpdate`.** Não existe endereço de edição que o use.
3. **Entra o campo opcional `prisma`**, que o modelo de dados tem e o contrato anterior não citava.
4. **Os códigos de erro passam a estar escritos**: 409 para posição repetida, 422 para corpo inválido, e nenhum 404 nesta rodada.
5. **Entra a seção** (decisão de time de 2026-09-22, depois da primeira publicação): um campo obrigatório em cada pergunta e um filtro opcional na listagem. Ela criou a quarta entrega.

### As entregas

| # | Entrega | Onde | Depende de |
|---|---|---|---|
| 1 | CREED-351 - Tabela de perguntas no banco, com o domínio `questions` | back | — |
| 2 | CREED-352 - Criar e listar perguntas: regra e contratos | back | 1 |
| 3 | CREED-353 - Endpoints de criação e listagem de perguntas | back | 2 |
| 4 | CREED-354 - Modelo de dados descrevendo a seção da pergunta | modelo de dados | 1 |

As três primeiras são **sequenciais**: a 2 usa a tabela que a 1 cria, a 3 usa o que a 2
cria.

A **quarta corre em paralelo** com a 2 e a 3. Ela é a única que não toca o servidor: o
modelo de dados vive em outro repositório, e a regra do projeto é que uma tarefa não
cruza repositórios. Depende só da 1 — só dá para descrever a coluna depois que ela existe.

**Nenhuma delas espera a CREED-33.** As duas tarefas correm em paralelo, sem tocar nos
mesmos arquivos do servidor — a ligação entre as duas tabelas é trabalho de uma tarefa
futura, de amarração. A quarta entrega, sim, mexe nos mesmos arquivos de modelo de dados
que a quarta entrega da CREED-33, e diz como as duas convivem.

### Contrato desta entrega

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/questions` | `{"form_id": "uuid", "text": "string", "order_index": 0, "type": "objective ou descriptive", "section": "profile, assessment ou closing", "required": true, "prisma": "opcional, um dos cinco valores, ou nulo"}` | `QuestionResponse` · 201 |
| GET | `/api/v1/forms/{form_id}/questions` | `?section=profile, assessment ou closing` — opcional | lista de `QuestionResponse` · 200 |

Sem `section`, a listagem devolve todas as perguntas do formulário; com `section`, só as
daquela seção. Nos dois casos, em ordem de posição.

Erros: **409** quando já existe pergunta na mesma posição do mesmo formulário · **422**
quando o corpo está fora do formato, quando falta `section` no cadastro, ou quando o
`?section=` pede uma seção que não existe. **Não existe 404** nesta rodada — ver o
primeiro aviso acima.

### Materiais desta tarefa

- ✅ Imagem da tabela de perguntas, anexada na subtarefa 1. **AGES III/IV: falta conferir** se é a tabela atual; ela é anterior à seção
- ✅ Definições dos termos, coladas acima e nas subtarefas 1 e 4
- ✅ Endereços dos arquivos de referência, linkados em cada subtarefa
- ✅ Texto das decisões tomadas sem a cliente, colado acima e em cada subtarefa

### Rastreio

```
Rastreio: 86e3anvpm — creed-ai-context/tarefas/86e3anvpm-question-crud-api/spec.md
```

---

## Parte 3 — subtarefa 1

<!-- Título: CREED-351 - Tabela de perguntas no banco, com o domínio `questions` -->
<!-- markdown_description em 86e3ap1dm. -->

### Em uma frase

Criar, no banco, a tabela que guarda uma pergunta de um formulário: enunciado, posição,
tipo, seção, obrigatoriedade e a dimensão de análise a que ela pertence.

### O que muda para quem usa

Ninguém usa esta entrega diretamente — ela é o chão sobre o qual as outras ficam de pé.

Três palavras decidem a forma da tabela:

- **Pergunta** é um item de um formulário: o enunciado, a posição, se é obrigatória, o tipo — múltipla escolha ou resposta livre — e a seção. As alternativas de uma pergunta de múltipla escolha não entram aqui; são outra tarefa.
- **Seção** é a parte do formulário em que a pergunta é desenhada na tela. A tela lê o valor e decide em que bloco colocar a pergunta. A coluna é obrigatória.
- **Prisma** é uma das cinco dimensões de análise do produto (plasticidade humana, empreendedorismo, multiculturalismo, neuroinovação, tomada de decisão). A coluna é opcional. **Não é a seção**: a seção organiza a tela, o prisma organiza a análise, e uma pergunta tem os dois.

> ⚠️ **A lista de seções é provisória.** O time decidiu que a seção existe, mas não
> quais são as seções. Esta entrega usa `profile`, `assessment` e `closing` para que a
> tabela, o contrato e os testes tenham com o que trabalhar. Trocar a lista agora, com a
> tabela vazia, é barato. Trocar depois de gravar perguntas de verdade não é.

### Como pretendemos fazer

Criar uma pasta nova para o assunto "perguntas" no servidor, declarar a tabela ali,
gerar a alteração de estrutura do banco automaticamente e **ler essa alteração linha a
linha** antes de aplicar.

**Domínio próprio, não dentro do domínio de formulários.** A tabela de formulários está
sendo criada ao mesmo tempo, em outra tarefa. Se as duas tabelas ficassem no mesmo
lugar, os dois times criariam os mesmos arquivos ao mesmo tempo e teriam de juntar à
mão duas branches na hora de mesclar. Separados, os dois times só se encontram em três
pontos: uma linha em `alembic/env.py`, uma linha em `app/main.py` (na terceira entrega)
e o ponto de partida das alterações de estrutura do banco, explicado abaixo em "Antes de
gerar". As duas linhas são acréscimo, e quem mesclar por último só junta as duas.

Duas coisas que esta entrega deliberadamente **não** faz:

1. **Nenhuma ligação com a tabela de formulários.** Ela está sendo criada ao mesmo tempo, em outra tarefa, e pode nem existir ainda quando esta migração rodar. A ligação de banco (chave estrangeira) entra numa tarefa de amarração, depois, quando as duas tabelas já estiverem de pé.
2. **Nenhuma rota.** Não procure onde registrar endpoint — isso é a terceira entrega.

### Onde isso encosta no código

Repo: `creed-backend`.

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/questions/__init__.py` | a pasta do assunto novo |
| `app/domains/questions/models.py` | a tabela `questions` e os tipos enumerados `QuestionType`, `Prisma` e `QuestionSection` |
| `alembic/env.py` | o import do model novo — ver o aviso abaixo |
| `alembic/versions/<hash>_create_questions_table.py` | a alteração de estrutura, gerada e depois lida linha a linha |
| `tests/domains/questions/__init__.py` | — |
| `tests/domains/questions/test_models.py` | o teste que trava a forma da tabela |

O nome da pasta é `questions`, em inglês e no plural, porque **todo identificador no
código deste projeto é em inglês** — pasta, classe, método, variável, rota — e pasta de
domínio é `snake_case` no plural. A decisão e o motivo estão na
[decisão sobre o idioma do código](https://github.com/creed-educa-ai/creed-ai-context/blob/c5a0322c60d5446306b40e7bf79e4991b357389c/decisoes/adrs/0005-idioma-do-codigo.md)
(abre no GitHub).

**`app/main.py` não é tocado.** Não há rota nesta entrega.

### A tabela, coluna a coluna

| Coluna | Tipo | Aceita vazio? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, gerada pela aplicação |
| `form_id` | `UUID` | não | sem ligação com a tabela de formulários nesta rodada |
| `text` | texto sem limite de tamanho | não | o enunciado da pergunta |
| `order_index` | número inteiro | não | a posição da pergunta no formulário |
| `type` | tipo enumerado `QuestionType` | não | `objective` (múltipla escolha) ou `descriptive` (resposta livre) |
| `section` | tipo enumerado `QuestionSection` | não | `profile`, `assessment` ou `closing`, provisórios. Sem valor padrão |
| `required` | verdadeiro/falso | não | nasce `true` quando não informado |
| `prisma` | tipo enumerado `Prisma` | sim | as cinco dimensões; pode ficar vazio |
| `created_at` | data e hora com fuso | não | preenchida pelo banco |

Índice: `form_id`. Restrição de unicidade: `(form_id, order_index)` — duas perguntas do
mesmo formulário não podem ocupar a mesma posição, **mesmo em seções diferentes**;
formulários diferentes podem repetir posição entre si.

`section` **não** ganha índice: o filtro por seção sempre vem junto de `form_id`, que já
tem índice.

O nome da tabela é `questions`, no plural — segue a convenção escrita do projeto para
nome de tabela.

**Não crie:** nenhuma chave estrangeira, e nenhum import do domínio de formulários.

### O tipo da seção, com o aviso em cima

O tipo mora no mesmo `models.py`, com um comentário que avisa que a lista é provisória —
do mesmo jeito que `app/domains/users/models.py` avisa sobre a decisão do status de
nascimento de um usuário:

```python
# 🟡 Premissa P-020 — valores provisórios; o time ainda não definiu as seções.
# Confirmar antes de gravar a primeira pergunta real: depois disso, trocar um valor
# é ALTER TYPE + atualização das linhas + troca das chaves de i18n no front.
class QuestionSection(enum.Enum):
    PROFILE = "profile"
    ASSESSMENT = "assessment"
    CLOSING = "closing"
```

`P-020` é o identificador desta decisão no registro de decisões que o time tomou sem a
cliente (`decisoes/premissas.md`, no repositório `creed-ai-context`). Ele fica no
comentário para quem precisar achar o motivo da lista.

**O banco guarda o nome, não o valor.** Com esse tipo, o banco grava `PROFILE`, e a API
devolve `profile`. É o comportamento padrão da biblioteca, e é o que as tabelas de
usuários e de respostas já fazem. **Siga o padrão** e não configure o contrário só aqui.
Quem consultar o banco direto vai ver maiúsculas, e isso está certo.

### O passo que o autogenerate não perdoa

```python
from app.domains.questions import models as questions_models  # noqa: F401
```

Sem essa linha em `alembic/env.py`, a geração automática **não enxerga a tabela nova e a
alteração sai vazia** — e vazia ela aplica sem dar erro, o que faz a falha aparecer só
quando alguém for gravar.

### Desfazer precisa apagar os tipos

No Postgres, cada tipo enumerado vira um tipo do banco: `questiontype`,
`questionsection` e `prisma`. Apagar a tabela **não** apaga os tipos, e a geração
automática não escreve isso sozinha. Sem as três linhas abaixo no `downgrade()`, desfazer
e refazer a alteração falha com "type already exists". Depois do `op.drop_table(...)`:

```python
sa.Enum(name="questiontype").drop(op.get_bind(), checkfirst=True)
sa.Enum(name="questionsection").drop(op.get_bind(), checkfirst=True)
sa.Enum(name="prisma").drop(op.get_bind(), checkfirst=True)
```

A alteração de estrutura da tabela de respostas já faz isso e serve de exemplo — link
abaixo. **Não** copie o `downgrade()` da alteração que criou a tabela de usuários: ele
esquece os tipos, e é defeito conhecido daquela alteração.

### Antes de gerar: confira o head

A tarefa de formulários (CREED-33) está gerando a alteração de estrutura dela **ao mesmo
tempo**, a partir do mesmo ponto de partida. As duas vão sair, no primeiro momento, com o
mesmo "ponto anterior". Isso é esperado, e a saída é sempre a mesma:

1. Rode `alembic current` e `alembic heads` imediatamente antes de gerar.
2. Gere a alteração normalmente.
3. Antes de mesclar o PR, atualize a branch com a `dev` e rode `alembic heads` de novo. Se devolver **duas linhas**, a saída é `alembic merge` — incluído neste mesmo PR. **Nunca** edite o "ponto anterior" à mão para encaixar uma revisão depois da outra.

### O que já existe e deve ser reusado

1. A base das tabelas e a sessão de banco estão em [`app/core/database.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/app/core/database.py). Herde da classe base de lá — **não crie outra**.
2. A tabela de exemplo completa é [`app/domains/users/models.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/app/domains/users/models.py). Copie a **forma**: como a tabela é declarada, como um tipo enumerado é declarado e usado numa coluna, como a chave e o horário de criação aparecem, e o comentário que avisa, em cima de uma coluna, que a decisão por trás dela é provisória. **Os campos, não.**
3. A restrição de unicidade composta (duas colunas juntas) tem exemplo em [`app/domains/responses/models.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/app/domains/responses/models.py). Copie a forma, inclusive o nome explícito dado à restrição.
4. A alteração de estrutura que apaga o tipo enumerado ao ser desfeita é [`alembic/versions/49ef1d2c7b7e_form_response_table.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/alembic/versions/49ef1d2c7b7e_form_response_table.py). Copie o `downgrade()` dela.
5. O checklist de revisão no comentário do topo está em [`alembic/versions/0b0ad39d779a_create_user_table.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/alembic/versions/0b0ad39d779a_create_user_table.py). Copie o checklist — que é para preencher, não para copiar em branco — mas **não** o `downgrade()`.
6. O lugar onde o import do model precisa entrar é [`alembic/env.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/alembic/env.py).
7. O teste que confere as camadas é [`tests/test_arquitetura.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/tests/test_arquitetura.py). Ele roda sobre o assunto novo automaticamente; precisa continuar passando.

### Pronto quando

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] `alembic heads` devolve **um único head** no momento de mesclar.
- [ ] `\d questions` mostra exatamente as nove colunas da tabela acima, com os mesmos tipos e a mesma aceitação de vazio.
- [ ] `section` não aceita vazio, **não** tem valor padrão, e o tipo tem só os três valores provisórios, com o comentário de aviso em cima.
- [ ] O `downgrade()` apaga a tabela **e os três tipos enumerados**, e `alembic downgrade -1` seguido de `alembic upgrade head` roda sem erro.
- [ ] A tabela **não** tem nenhuma chave estrangeira.
- [ ] Existe índice em `form_id` e a restrição única em `(form_id, order_index)`.
- [ ] O model está importado em `alembic/env.py`, e o arquivo gerado **não** está vazio.
- [ ] Nenhum arquivo do domínio importa do domínio de formulários.
- [ ] O arquivo gerado foi **lido linha a linha**, e o checklist no comentário do topo está preenchido.
- [ ] `pytest tests/test_arquitetura.py` passa.

### Como verificar

```bash
cd creed-backend
docker compose up -d db
alembic current
alembic heads
alembic revision --autogenerate -m "create questions table"
alembic upgrade head
pytest tests/domains/questions tests/test_arquitetura.py -q
ruff check . && mypy app
```

Conferir a forma no banco:

```bash
docker compose exec db psql -U creed -d creed -c "\d questions"
```

**Caso de borda que precisa passar** — derrubar tudo e subir de novo reproduz
exatamente a mesma estrutura:

```bash
docker compose down -v && docker compose up -d db && alembic upgrade head
```

⚠️ `docker compose down -v` apaga o volume inteiro, e com ele o schema do Keycloak do
ambiente local. Ao subir de novo, é preciso esperar o script de inicialização rodar e
reimportar o realm. Não rode isso no meio de outra tarefa que dependa do login local.

**Segundo caso de borda** — desfazer só esta alteração e refazê-la. É o que prova que os
tipos enumerados são apagados. Não mexe no Keycloak:

```bash
alembic downgrade -1 && alembic upgrade head
```

Se a CREED-33 tiver mesclado antes e esta branch ganhou uma revisão de merge, o `-1`
desfaz o merge, não esta alteração. Nesse caso, desça até a revisão anterior a esta, pelo
identificador.

**O teste desta entrega** não precisa de banco: lê a descrição da tabela direto do
código. Confere: as nove colunas existem com a aceitação de vazio da tabela acima ·
`section` não aceita vazio e não tem padrão · o tipo da seção tem exatamente os três
valores provisórios, para que trocar a lista seja uma decisão visível no teste e não um
acidente · a lista de chaves estrangeiras está vazia · existe índice em `form_id` ·
existe a restrição única em `(form_id, order_index)`.

### Decisões já tomadas que valem aqui

- **A lista de seções é provisória** (`profile`, `assessment`, `closing`). O time decidiu que a seção existe, não quais são. Aqui isso aparece como o tipo e o comentário em cima dele. Se a lista mudar antes de haver pergunta gravada, basta editar o tipo e regerar esta alteração. Depois disso, é alteração nova, com atualização das linhas.
- **Toda pergunta tem seção.** Aqui isso aparece como a coluna não aceitar vazio e não ter padrão. Se a decisão cair, é uma alteração de uma linha.

### Materiais para consumir

| Material | Situação |
|---|---|
| A forma completa da tabela | ✅ escrita acima, coluna a coluna |
| Imagem da tabela no modelo de dados | ✅ anexada nesta subtarefa (`image.png`, exibida abaixo). AGES III/IV: falta conferir se é a tabela atual. Ela é de antes da seção, então não mostra essa coluna |
| Definições de "pergunta", "seção" e "prisma" | ✅ coladas acima |
| Arquivos de referência do servidor | ✅ linkados acima (abrem no GitHub) |

A imagem que já estava anexada nesta tarefa:

![](https://t90171447403.p.clickup-attachments.com/t90171447403/2dcf6b89-96b0-4e7e-a647-b5a0faf2ee7a/image.png)

### Rastreio

```
Rastreio: 86e3anvpm/1 — creed-ai-context/tarefas/86e3anvpm-question-crud-api/1_task.md
```

---

## Parte 3 — subtarefa 2

<!-- Título: CREED-352 - Criar e listar perguntas: regra e contratos -->
<!-- markdown_description em 86e3apg22. -->

### Em uma frase

Ensinar o servidor a cadastrar uma pergunta, recusando uma posição já ocupada no mesmo
formulário, e a listar as perguntas de um formulário em ordem — todas, ou só as de uma
seção.

### O que muda para quem usa

Ninguém de fora do time percebe diferença — não há tela nem endereço de API nesta
entrega. O que muda é que a regra do assunto "pergunta" passa a existir e a ter teste.

A regra central: **duas perguntas do mesmo formulário não podem ocupar a mesma
posição.** Se já existe uma pergunta na posição 2 do formulário X, cadastrar outra na
posição 2 do mesmo formulário é conflito — **mesmo que ela esteja em outra seção**. No
formulário Y, a posição 2 continua livre. A seção agrupa as perguntas na tela; a posição
ordena as perguntas dentro de cada grupo.

**A listagem filtra por seção quando pedem, e só quando pedem.** Sem seção, vêm todas
as perguntas do formulário; com seção, só as daquela seção. Nos dois casos, em ordem de
posição.

**Esta entrega não confere se o formulário existe.** A tabela de formulários está sendo
criada ao mesmo tempo, em outro domínio do código, e um domínio não pode importar de
outro sem que isso vire regra escrita — essa regra ainda não existe. Por isso, listar as
perguntas de um formulário que ninguém criou devolve lista vazia, e não erro.

### Como pretendemos fazer

Três camadas, com responsabilidades separadas — é a divisão que o projeto usa em todo
assunto, e furar ela quebra um teste automático:

- A camada que **fala com o banco** só grava e busca. Não decide nada.
- A camada de **regra** é quem decide: confere se a posição já está ocupada antes de gravar, e levanta um erro de conflito se estiver.
- A camada de **contratos de entrada e saída** descreve o que entra e o que sai.

A checagem de posição repetida acontece na camada de regra **antes** de gravar — não se
espera o banco recusar e traduzir o erro dele. É o mesmo jeito que o cadastro de usuário
já confere e-mail repetido antes de gravar. A restrição de unicidade continua na tabela
como última proteção, para o caso raro de duas gravações simultâneas na mesma posição.

**A ordenação e o filtro por seção são feitos pela consulta ao banco**, não por código
que reordena ou filtra a lista depois de buscar — é o princípio do projeto de que filtro,
ordenação e soma ficam no banco. A condição de seção só entra na consulta quando a seção
foi pedida:

```python
query = select(Question).where(Question.form_id == form_id)
if section is not None:
    query = query.where(Question.section == section)
query = query.order_by(Question.order_index)
```

A camada de regra só **repassa** a seção para a camada de banco; ela não filtra nada.

**Nesta rodada, uma pergunta não é editada nem apagada.** Não crie schema nem método
para isso.

Tudo é escrito em modo assíncrono (`async`), porque é assim que o resto do servidor é.

### Onde isso encosta no código

Repo: `creed-backend`.

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/questions/schemas.py` | `QuestionCreate` (entrada) e `QuestionResponse` (saída) |
| `app/domains/questions/repository.py` | `insert(question)`, `list_by_form(form_id, section=None)` e `get_by_form_and_order(form_id, order_index)` — o acesso ao banco |
| `app/domains/questions/service.py` | `create(dados)` e `list_for_form(form_id, section=None)` — a regra |
| `tests/domains/questions/test_service.py` | os casos abaixo |

**`app/main.py` e `dependencies.py` não são tocados.** A montagem da cadeia e a rota são
da terceira entrega.

### Os métodos que devem nascer

| Onde | Assinatura | Devolve |
|---|---|---|
| `repository.insert(question: Question)` | a entidade já montada | a pergunta gravada, com identificador e horário preenchidos pelo banco |
| `repository.list_by_form(form_id: UUID, section: QuestionSection \| None = None)` | — | as perguntas daquele formulário, em ordem de posição; com seção, só as daquela seção. Filtro e ordem são da consulta |
| `repository.get_by_form_and_order(form_id: UUID, order_index: int)` | — | a pergunta naquela posição, **ou nada** — não levanta erro |
| `service.create(dados: QuestionCreate)` | os dados já validados | a pergunta criada, ou erro de conflito se a posição já está ocupada |
| `service.list_for_form(form_id: UUID, section: QuestionSection \| None = None)` | — | as perguntas daquele formulário, vazia se não houver nenhuma |

Os nomes não são livres: a camada de regra nomeia a intenção (`create`,
`list_for_form`), e a camada de banco nomeia o acesso (`insert`, `list_by_form`,
`get_by_...`).

### Os contratos

`QuestionCreate` — o que entra:

| Campo | Tipo | Regra |
|---|---|---|
| `form_id` | identificador (UUID) | obrigatório |
| `text` | texto | obrigatório, não pode ser vazio |
| `order_index` | número inteiro | obrigatório, não pode ser negativo |
| `type` | `objective` ou `descriptive` | obrigatório |
| `section` | `profile`, `assessment` ou `closing` | obrigatório, sem valor padrão |
| `required` | verdadeiro/falso | opcional, nasce `true` |
| `prisma` | uma das cinco dimensões, ou vazio | opcional, nasce vazio |

`QuestionResponse` — o que sai — devolve `id`, `form_id`, `text`, `order_index`,
`type`, `section`, `required`, `prisma` e `created_at`. A montagem da saída a partir da
tabela mora neste mesmo arquivo, num método de classe, e **não na camada de rota** — é o
que permite à rota não conhecer a tabela.

Este arquivo também **reexporta** o tipo da seção
(`from app.domains.questions.models import QuestionSection`). A terceira entrega precisa
dele na rota, e a rota não pode importar de `models.py`.

### O que já existe e deve ser reusado

1. Os contratos de exemplo estão em [`app/domains/users/schemas.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/app/domains/users/schemas.py): entrada e saída separadas, e o método de classe que monta a saída a partir da tabela.
2. O acesso a banco de exemplo é [`app/domains/users/repository.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/app/domains/users/repository.py). Copie a forma: a sessão assíncrona, a consulta, e `add` + `flush` + `refresh` no método de criação — repare que **não há `commit()`**.
3. A camada de regra de exemplo, com a checagem de duplicidade antes de gravar, é [`app/domains/users/service.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/app/domains/users/service.py), em especial `create_user_service`. É exatamente a forma da checagem de posição repetida aqui.
4. Os erros padronizados estão em [`app/shared/exceptions.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/app/shared/exceptions.py). Use o erro de conflito de lá — **não crie exceção nova**.
5. O teste de exemplo, com dublê no lugar do banco, é [`tests/domains/users/test_service.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/tests/domains/users/test_service.py). **Não existe banco de teste no projeto** — a regra é testada com um dublê em memória no lugar do banco de verdade.

### Pronto quando

- [ ] Cadastrar uma pergunta com dados válidos devolve a pergunta criada, com a seção que veio na entrada.
- [ ] Cadastrar sem `required` e sem `prisma` cria a pergunta com `required = true` e `prisma` vazio.
- [ ] Cadastrar uma segunda pergunta na mesma posição do mesmo formulário devolve erro de conflito — **mesmo em outra seção** — e **não** grava a segunda.
- [ ] A mesma posição em **outro** formulário é aceita normalmente.
- [ ] Listar as perguntas de um formulário devolve só as daquele formulário, em ordem de posição.
- [ ] Listar com uma seção devolve só as perguntas daquela seção; sem seção, devolve todas.
- [ ] Listar as perguntas de um formulário sem nenhuma pergunta devolve lista vazia, sem erro.
- [ ] Texto vazio, posição negativa, seção ausente, ou tipo e seção fora da lista são recusados na validação de entrada.
- [ ] A saída traz a seção.
- [ ] Nenhum `commit()` no diff.
- [ ] `pytest tests/test_arquitetura.py` passa.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/questions -q
ruff check . && mypy app && pytest
```

**Casos felizes:** cadastrar uma pergunta válida e encontrá-la ao listar as perguntas do
formulário · com perguntas em duas seções, listar com uma seção devolve só as dela.
**Casos de borda, nomeados:** a segunda pergunta na mesma posição do mesmo formulário é
recusada, mesmo em outra seção · a mesma posição em formulário diferente passa · listar
um formulário sem pergunta nenhuma devolve lista vazia.

Nos testes, use os membros do tipo (`QuestionSection.PROFILE`), **nunca o texto solto**
(`"profile"`): a lista é provisória, e trocá-la não pode exigir caçar texto nos testes.

⚠️ **O teste desta entrega não prova a ordenação nem o filtro.** Os dois estão na
consulta ao banco, e o dublê do teste não roda consulta nenhuma — ele filtra em memória.
O que o teste prova é que a camada de regra **repassa** a seção para a camada de banco.
Quem prova a consulta é a terceira entrega, de ponta a ponta, com banco. Deixe um
comentário no teste dizendo isso, para ninguém achar que está coberto.

### Decisões já tomadas que valem aqui

- **Esta entrega cobre só cadastrar e listar.** Aqui isso aparece como a ausência de qualquer método de editar ou apagar pergunta. Decidido sem confirmar com a cliente, porque o contrato publicado na tarefa só tinha esses dois endereços. Se cair, entram um schema e um método de regra e de banco a mais, sem mudar a tabela.
- **A lista de seções é provisória** (`profile`, `assessment`, `closing`). Aqui isso aparece só nos testes — por isso a regra de usar o membro do tipo, e não o texto.
- **Toda pergunta tem seção.** Aqui isso aparece como `section` sem valor padrão na entrada.

### Materiais para consumir

| Material | Situação |
|---|---|
| Assinaturas dos métodos e conteúdo dos contratos | ✅ escritos acima |
| Arquivos de referência do servidor | ✅ linkados acima (abrem no GitHub) |
| Texto das decisões tomadas sem a cliente | ✅ colado acima |

### Depende de

**Entrega 1 — "Tabela de perguntas no banco, com o domínio `questions`".** Esta entrega
importa a tabela que a 1 cria; não dá para começar antes de ela estar mesclada.

### Rastreio

```
Rastreio: 86e3anvpm/2 — creed-ai-context/tarefas/86e3anvpm-question-crud-api/2_task.md
```

---

## Parte 3 — subtarefa 3

<!-- Título: CREED-353 - Endpoints de criação e listagem de perguntas -->
<!-- markdown_description em 86e3apgm5. -->

### Em uma frase

Abrir os dois endereços de API que cadastram uma pergunta e listam as de um formulário,
com filtro opcional por seção.

### O que muda para quem usa

Esta é a única entrega do servidor que produz algo que dá para **ver de fora**: uma
porta de API que responde. Ainda assim, **nenhuma tela do aplicativo web a consome** —
quem exercita é dev, pelo Swagger ou por linha de comando. A tela que desenha o
formulário por seção é outra tarefa, e é ela que vai consumir este endereço.

No servidor deste projeto, a camada de rota é o que em outros lugares se chama de
*controller*: recebe, deixa o framework conferir o formato, chama a camada de regra e
devolve. **Nenhuma decisão de negócio mora aqui**, e ela **não conhece a tabela**.

O que a rota faz de próprio é **traduzir erro de negócio em código HTTP**: a camada de
regra levanta "posição já ocupada" sem saber o que é um 409; quem sabe é a rota.

⚠️ **Uma coisa que esta entrega deliberadamente não faz, e que quem lê provavelmente
esperaria:** a rota **não confere se o formulário existe**. A tabela de formulários está
sendo criada ao mesmo tempo, em outro domínio do código, e um domínio não pode importar
de outro. Na prática: listar as perguntas de um identificador de formulário que ninguém
criou devolve **200 com lista vazia**, e não "não encontrado" — igual a um formulário
real sem nenhuma pergunta ainda. É risco conhecido e aceito, com consequência prática no
fim desta tarefa.

⚠️ **A lista de seções que o Swagger vai mostrar é provisória.** Quem integrar a tela
precisa saber disso antes de criar os textos de cada seção.

### Como pretendemos fazer

Os dois endereços não têm um prefixo em comum: um é `/questions`, o outro é
`/forms/{form_id}/questions`. Por isso o roteador desta entrega **não tem prefixo
próprio**: cada rota escreve o caminho inteiro. O prefixo `/api/v1` **não** se escreve
aqui de qualquer forma: ele vem da configuração central, no momento do registro.

**O filtro por seção é um parâmetro opcional da listagem**, tipado com o tipo da seção.
É isso que faz o framework conferir o valor e devolver 422 sozinho para uma seção que
não existe:

```python
router = APIRouter(tags=["questions"])

@router.post("/questions", ...)

@router.get("/forms/{form_id}/questions", response_model=list[QuestionResponse])
async def list_questions(
    form_id: uuid.UUID,
    service: ServiceDep,
    section: QuestionSection | None = None,
) -> list[QuestionResponse]:
    ...
```

A rota só **repassa** a seção para a camada de regra — não há `if` sobre ela aqui.

**O tipo da seção vem de `schemas.py`, não de `models.py`.** Existe teste automático que
reprova uma rota que importe de `models.py`. A segunda entrega reexporta o tipo no
`schemas.py`, e é de lá que a rota importa.

Isso é diferente dos domínios de usuários e de respostas, que usam `prefix=`. Com um
roteador só, `app/main.py` continua recebendo **um** roteador deste domínio, como recebe
dos outros.

Os códigos de resposta:

| Situação | Código | Quem produz |
|---|---|---|
| pergunta criada | **201** | declarado no decorador da rota |
| lista devolvida, vazia ou não | **200** | padrão |
| posição já ocupada no formulário | **409** | a rota, traduzindo o erro de negócio |
| corpo fora do formato, ou seção que não existe no filtro | **422** | o FastAPI sozinho, sem nenhum código seu |

### Onde isso encosta no código

Repo: `creed-backend`.

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/questions/dependencies.py` | a montagem da cadeia sessão → banco → regra, que a rota recebe pronta |
| `app/domains/questions/router.py` | os dois endpoints |
| `app/main.py` | o import e a entrada na lista de roteadores |
| `tests/domains/questions/test_router.py` | os casos abaixo |

### O contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/questions` | `QuestionCreate` | `QuestionResponse` · 201 |
| GET | `/api/v1/forms/{form_id}/questions` | `?section=profile, assessment ou closing` — opcional | lista de `QuestionResponse` · 200 |

**Corpo da saída** (um item da lista, ou a resposta do POST)

```json
{
  "id": "uuid",
  "form_id": "uuid",
  "text": "string",
  "order_index": 0,
  "type": "objective",
  "section": "assessment",
  "required": true,
  "prisma": null,
  "created_at": "2026-09-22T14:00:00Z"
}
```

**Erros**

| Código | Quando | Corpo |
|---|---|---|
| 409 | já existe pergunta na mesma posição do mesmo formulário | `{"detail": "..."}` |
| 422 | corpo fora do formato, cadastro sem seção, ou filtro com seção que não existe | validação padrão do FastAPI |

### O que já existe e deve ser reusado

1. A rota de exemplo é [`app/domains/users/router.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/app/domains/users/router.py). Copie a forma: a regra chegando pela injeção de dependência (**não instancie nada à mão**), a saída montada pelo método de classe do contrato, e o `try/except` que traduz o erro de negócio em resposta HTTP.
2. A montagem da cadeia de exemplo está em [`app/domains/users/dependencies.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/app/domains/users/dependencies.py): `get_repository` → `get_service` → `ServiceDep`. Mesma forma, mesmas três peças.
3. O lugar onde registrar é [`app/main.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/app/main.py). Copie a forma do que já está lá: um import junto dos outros e o nome acrescentado à lista de roteadores registrados.
4. O teste de rota de exemplo é [`tests/domains/authentication/test_router.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/tests/domains/authentication/test_router.py). **Não existe banco de teste no projeto** — o teste monta uma aplicação só com este roteador e troca a camada de regra por um dublê.
5. O teste que confere as camadas é [`tests/test_arquitetura.py`](https://github.com/creed-educa-ai/creed-backend/blob/e7a8c3253c12a288b3d0fbb84134aff0d98adfdb/tests/test_arquitetura.py). Ele reprova rota que importe de `models.py` — é por isso que o tipo da seção vem de `schemas.py`. Precisa continuar passando.

### Pronto quando

- [ ] `POST /api/v1/questions` com corpo válido devolve **201** com o corpo completo da pergunta criada — as nove chaves, com a seção.
- [ ] `POST` com posição já ocupada no mesmo formulário devolve **409**, mesmo em outra seção.
- [ ] `POST` com texto vazio, sem seção, com tipo ou seção inválidos, ou com identificador de formulário que não é UUID devolve **422**, sem nenhum código escrito para isso.
- [ ] `GET /api/v1/forms/{form_id}/questions` devolve **200** com a lista, em ordem de posição, e **200** com lista vazia para um formulário sem pergunta nenhuma.
- [ ] `GET ...?section=<valor>` devolve só as perguntas daquela seção, ainda em ordem de posição; com uma seção que não existe, devolve **422**.
- [ ] As rotas finais são exatamente `/api/v1/questions` e `/api/v1/forms/{form_id}/questions`.
- [ ] Os dois endpoints aparecem no Swagger, sob a etiqueta "questions", e o filtro `section` aparece como lista fechada dos três valores.
- [ ] `router.py` não importa de `models.py` nem nada de acesso a banco direto.
- [ ] `pytest tests/test_arquitetura.py` passa.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/questions -q
ruff check . && mypy app && pytest
```

De ponta a ponta, com banco:

```bash
docker compose up -d db
alembic upgrade head
uvicorn app.main:app --reload
```

Em outro terminal — **caso feliz, cadastrando fora de ordem e em duas seções de
propósito**, para provar a ordenação e o filtro que o teste da segunda entrega não cobre:

```bash
F=00000000-0000-0000-0000-000000000001
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"Terceira\",\"order_index\":2,\"type\":\"descriptive\",\"section\":\"assessment\"}"
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"Primeira\",\"order_index\":0,\"type\":\"objective\",\"section\":\"assessment\"}"
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"Segunda\",\"order_index\":1,\"type\":\"descriptive\",\"section\":\"profile\"}"

curl -i localhost:8000/api/v1/forms/$F/questions
# esperado: Primeira, Segunda, Terceira

curl -i "localhost:8000/api/v1/forms/$F/questions?section=assessment"
# esperado: Primeira, Terceira
```

**Casos de borda:**

```bash
# 409 — posição repetida no mesmo formulário, mesmo em outra seção
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"Repetida\",\"order_index\":0,\"type\":\"objective\",\"section\":\"closing\"}"

# 200 com lista vazia — seção sem pergunta nenhuma
curl -i "localhost:8000/api/v1/forms/$F/questions?section=closing"

# 200 com lista vazia — formulário sem pergunta nenhuma
curl -i localhost:8000/api/v1/forms/00000000-0000-0000-0000-000000000999/questions

# 422 — seção que não existe
curl -i "localhost:8000/api/v1/forms/$F/questions?section=inexistente"

# 422 — cadastro sem seção
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"Sem seção\",\"order_index\":5,\"type\":\"objective\"}"
```

### O que não pode acontecer

A API aceita qualquer identificador de formulário. Enquanto a tarefa de amarração não
ligar as duas tabelas:

- **Nenhuma carga inicial ou dado de exemplo pode ser gravado na tabela de perguntas.** O que for criado à mão em desenvolvimento é descartável e some ao derrubar o banco.
- **Esta API não vai para ambiente que não seja o local.** Quando a ligação for criada, o banco vai recusar toda pergunta cujo formulário não exista de verdade — e uma linha inventada trava a migração para todo mundo.

Quem cuida do deploy precisa saber disso.

### Decisões já tomadas que valem aqui

- **Esta entrega cobre só criar e listar.** Aqui isso aparece como a ausência de qualquer rota de editar ou apagar. Decidido sem confirmar com a cliente; se cair, entra uma rota a mais.
- **A lista de seções é provisória** (`profile`, `assessment`, `closing`). Aqui isso aparece no Swagger, que mostra a lista fechada — e é por onde a tela vai conhecê-la.
- **Toda pergunta tem seção.** Aqui isso aparece como o 422 do cadastro sem seção.

### Materiais para consumir

| Material | Situação |
|---|---|
| Contrato dos dois endpoints, com erros e o filtro | ✅ escrito acima |
| Arquivos de referência do servidor | ✅ linkados acima (abrem no GitHub) |
| Texto das decisões tomadas sem a cliente | ✅ colado acima |

### Depende de

**Entrega 2 — "Criar e listar perguntas: regra e contratos".** Esta entrega importa a
camada de regra, os contratos e o tipo da seção reexportado que a 2 cria; não dá para
começar antes de ela estar mesclada.

### Rastreio

```
Rastreio: 86e3anvpm/3 — creed-ai-context/tarefas/86e3anvpm-question-crud-api/3_task.md
```

---

## Parte 3 — subtarefa 4

<!-- Título: CREED-354 - Modelo de dados descrevendo a seção da pergunta -->
<!-- markdown_description, parent = 86e3anvpm. CRIADA na terceira rodada. -->

### Em uma frase

Fazer o modelo de dados do time descrever a coluna de seção que a tabela de perguntas
passou a ter, deixando escrito que a lista de seções é provisória.

### O que muda para quem usa

Ninguém de fora do time percebe diferença — não há código de produto aqui. O que muda é
para **quem abre o modelo de dados** para entender ou desenhar uma tabela.

A tabela de perguntas ganhou uma coluna que o modelo não tem: a **seção**, a parte do
formulário em que a pergunta é desenhada na tela. **O problema não é a divergência — é
ela ficar sem registro.** Quem abrir o modelo, procurar a coluna e não achar tende a
concluir que ela está sobrando, e "corrigir" o código apagando-a.

Há um cuidado a mais: a lista de seções é **provisória**. O time decidiu que a seção
existe, mas não quais são as seções. O modelo tem de registrar a lista **e** o fato de
ela ser provisória. Registrar só a lista transformaria uma decisão em aberto em decisão
tomada.

**A seção não é o prisma.** A pergunta já tem prisma, a dimensão de análise. A seção é o
agrupamento na tela. O comentário no modelo precisa dizer isso, senão a primeira leitura
vai achar que é duplicação.

### Por que isto é subtarefa, e não item da primeira

1. **É outro repositório.** A primeira entrega mexe no servidor; esta, na documentação do modelo. A regra do projeto é que uma tarefa não cruza repositórios.
2. **Não dá para verificar no mesmo lugar.** O "pronto" da primeira é a alteração de estrutura subir e os testes passarem; o desta é um texto revisado.
3. **Só dá para descrever o que existe.** Por isso depende da primeira entrega, e só dela.

### Onde isso encosta

Repo: `creed-ai-context`. O modelo de dados tem três camadas, e esta tarefa mexe só na
do meio:

| Onde | O que é |
|---|---|
| dbdiagram.io | o desenho que o time fez em conjunto |
| `context/modelo-de-dados.dbml` | cópia literal do export do dbdiagram. Não mexa |
| `context/modelo-de-dados.proposta.dbml` | a correção que as tarefas de tabela estão lendo. É aqui |

Os dois arquivos que mudam:

1. [`context/modelo-de-dados.proposta.dbml`](https://github.com/creed-educa-ai/creed-ai-context/blob/c5a0322c60d5446306b40e7bf79e4991b357389c/context/modelo-de-dados.proposta.dbml) — o tipo novo, a coluna na tabela `Question` e a contagem do cabeçalho.
2. [`context/modelo-de-dados.md`](https://github.com/creed-educa-ai/creed-ai-context/blob/c5a0322c60d5446306b40e7bf79e4991b357389c/context/modelo-de-dados.md) — uma linha em "Decisões já tomadas" e a linha de `Question` no "Mapa tabela → domínio do backend".

### O que fazer, concretamente

Nos trechos abaixo, `P-020` (a lista de seções é provisória) e `P-028` (toda pergunta
tem seção) são os identificadores dessas duas decisões no registro de decisões que o
time tomou sem a cliente, `decisoes/premissas.md`, neste mesmo repositório. `[C31]` é o
número da correção no modelo, na mesma numeração das anteriores (`[C1]`, `[C9]`…). Os
dois vão literais para o modelo: é por eles que quem lê acha o motivo.

**1. Na `proposta.dbml`, o tipo novo**, junto dos outros tipos no topo do arquivo:

```
// [C31] Seção do formulário: onde a pergunta é desenhada na tela (CREED-35).
//       NÃO é o prisma: o prisma é a dimensão de análise ([C9]); a seção é o
//       agrupamento visual. Uma pergunta tem os dois.
//       Valores PROVISÓRIOS (P-020): o time decidiu que a seção existe, não quais são.
Enum QuestionSection {
  profile
  assessment
  closing
}
```

**2. Na tabela `Question`**, a coluna, logo depois de `type`:

```
  section QuestionSection [not null]  // [C31] obrigatória, sem default (P-028)
```

Nenhum índice novo.

**3. Acerte o cabeçalho.** Ele diz "14 tabelas · 9 enums · 21 FKs", e passa a ter **10
enums**. As ligações não mudam: a seção não aponta para tabela nenhuma.

**4. No `modelo-de-dados.md` → "Decisões já tomadas"**, uma linha nova, no formato das
outras: data 2026-09-22; decisão "`Question` ganha `section` (`QuestionSection`, `not null`, sem default) [C31]"; consequência "o front sabe em que parte do formulário desenhar cada pergunta, e a listagem filtra por ela. Independente do prisma. Valores provisórios (P-020): trocar depois de haver pergunta gravada é `ALTER TYPE` + atualização das linhas. Decisão de time, não da cliente".

**5. No mesmo arquivo → "Mapa tabela → domínio do backend"**, a linha que põe `Form`,
`Question` e `QuestionOption` juntos num domínio só deixou de ser verdade: a pergunta
nasceu num domínio próprio, porque as duas tarefas correm em paralelo. Troque essa linha
por duas: `forms` (novo, CREED-33) com `Form`; e `questions` (novo, CREED-35) com
`Question` — e anote que `QuestionOption` fica para a CREED-37 decidir, junto com a
amarração. Mexa só nessa linha: os outros nomes do mapa são anteriores à decisão do
idioma, e renomeá-los é outra conversa.

**6. Confira e reporte, sem corrigir:** o modelo descreve os valores dos tipos em
minúsculas (`objective`, `plasticidade_humana`), mas o banco guarda o **nome** em
maiúsculas (`OBJECTIVE`, `PLASTICIDADE_HUMANA`). É o comportamento padrão da biblioteca,
e as tabelas de usuários e de respostas já estão assim. A API devolve minúsculas. Não é
defeito desta tarefa, mas quem ler o modelo e depois consultar o banco vai estranhar —
vale uma linha no PR.

### Cuidado com a CREED-33

A quarta entrega da CREED-33 mexe nos **mesmos dois arquivos**: reescreve a tabela
`Form` com as correções `[C29]` e `[C30]` e acerta a contagem de ligações do cabeçalho.
As duas podem estar abertas ao mesmo tempo.

- **Os números de correção:** `[C29]` e `[C30]` são dela, e `[C31]` é desta. Antes de usar, confira com `grep -o '\[C[0-9]*\]'` que ninguém gastou o 31.
- **O cabeçalho:** as duas mudam a mesma linha, uma nas ligações e a outra nos tipos. Quem mesclar por último junta as duas mudanças e reconta, em vez de aceitar uma das versões.
- **O mapa tabela → domínio:** se a CREED-33 também tiver tocado na linha do formulário, junte as duas.

### O que não entra

- **Colar no dbdiagram e reexportar o diagrama do time.** Depende de o time aceitar a proposta de correção inteira — decisão de outra conversa.
- **Decidir a lista de seções.** Esta tarefa descreve a decisão em aberto; não a fecha.
- **Corrigir a diferença entre nome e valor dos tipos** (item 6). Só se reporta.

### Pronto quando

- [ ] `proposta.dbml` tem `Enum QuestionSection` com os três valores e o comentário `[C31]`, que diz que não é o prisma e que os valores são provisórios.
- [ ] `Table Question` tem `section QuestionSection [not null]`, sem default e sem índice novo.
- [ ] O cabeçalho conta 10 enums, e a contagem bate com o número de blocos `Enum` do arquivo.
- [ ] `modelo-de-dados.md` → "Decisões já tomadas" tem a linha de 2026-09-22 com `[C31]`, a lista provisória e "decisão de time, não da cliente".
- [ ] O mapa tabela → domínio mostra `Form` em `forms` e `Question` em `questions`.
- [ ] A diferença entre nome e valor dos tipos está **reportada por escrito** (no PR ou nesta tarefa).
- [ ] `modelo-de-dados.dbml` (o export literal) **não** foi tocado.

### Como verificar

Não há teste automático: a saída é documentação. A conferência é por leitura.

```bash
cd creed-ai-context
grep -n -B 5 -A 5 '^Enum QuestionSection' context/modelo-de-dados.proposta.dbml
grep -n -A 12 '^Table Question ' context/modelo-de-dados.proposta.dbml
grep -c '^Enum ' context/modelo-de-dados.proposta.dbml
grep -n 'QuestionSection' context/modelo-de-dados.dbml
```

O terceiro comando tem que bater com a contagem de tipos do cabeçalho. O quarto não
pode devolver nada.

**Caso de borda:** o segundo comando tem um espaço depois de `Question` de propósito.
Sem ele, também pega a tabela `QuestionOption`.

### Decisões já tomadas que valem aqui

- **A lista de seções é provisória** (`profile`, `assessment`, `closing`). O time decidiu que a seção existe, não quais são. É o que o comentário `[C31]` registra; se a lista mudar, a linha do modelo muda junto.
- **Toda pergunta tem seção.** É o `[not null]` sem default.

As duas decisões estão **em aberto**, e o modelo precisa soar assim — não como decisão
final.

### Materiais para consumir

| Material | Situação |
|---|---|
| Blocos a colar no modelo (tipo e coluna) | ✅ escritos acima |
| Os dois arquivos do modelo | ✅ linkados acima (abrem no GitHub) |
| Definições de "seção" e "prisma" | ✅ coladas acima |
| Texto das decisões tomadas sem a cliente | ✅ colado acima |

### Depende de

**Entrega 1 — "Tabela de perguntas no banco, com o domínio `questions`".** Só dá para
descrever a coluna depois que ela existe. Não depende da 2 nem da 3.

### Rastreio

```
Rastreio: 86e3anvpm/4 — creed-ai-context/tarefas/86e3anvpm-question-crud-api/4_task.md
```

---

## Nota de formato — conferência pós-publicação de 2026-09-22

As regras já registradas na CREED-33 foram aplicadas desde o rascunho: nada de link dentro
de célula de tabela, nada de lista numerada dentro de citação. A releitura das tarefas
publicadas confirmou três comportamentos já conhecidos e mostrou um novo.

**Novo: um item de lista escrito em mais de uma linha é cortado na quebra.** Dentro de um
item de lista (`-`, `1.`, `- [ ]`), a linha de continuação indentada chega ao board como
**parágrafo solto**, separado do marcador. Nada se perde, mas a lista fica picotada. O
"Pronto quando" é onde isso mais atrapalha, porque o checkbox fica só com a primeira
linha.

Regra que sai daí: **dentro de item de lista, uma linha só**, por mais longa que seja. O
parágrafo corrido pode continuar quebrado, porque ali o ClickUp junta as linhas.

Conhecidos, e confirmados de novo:

- **Negrito dentro de célula de tabela some.** O texto fica, a ênfase não.
- **Negrito encostado em `código` é partido em dois**, por exemplo em "Sai o schema `QuestionUpdate`".
- **O ClickUp adivinha a linguagem do bloco de rastreio.** O do épico chegou como `yaml`, e o das subtarefas como `verilog`. Não afeta nada.

**Segunda rodada, 2026-09-22:** republicado a pedido do usuário, com cada item de lista
numa linha só. O conteúdo não mudou, e isso foi conferido antes de enviar: as mesmas
palavras na mesma ordem, e os blocos de código idênticos. A releitura da CREED-351 no
board confirmou os itens chegando inteiros.
