# Jornada de discovery e especificação — manual do AGES III/IV

Do card cru no ClickUp até subtarefas que um dev pega e começa hoje.

Este é o manual de **quem especifica**. Os workflows em
[`../workflows/`](../workflows/) descrevem cada salto isoladamente; aqui está a jornada
inteira, com o julgamento que mora entre um salto e outro — o que investigar, quando
parar, o que decidir sozinho e o que registrar.

Quem só quer o mapa do repositório: [`../ONBOARDING.md`](../ONBOARDING.md).

---

## O que você produz

Quatro artefatos, nesta ordem. Cada um é entrada do seguinte.

| # | Artefato | Onde fica | Para quem |
|---|---|---|---|
| 1 | Calibragem **P × T** | cabeçalho da spec | você — decide o tamanho do resto |
| 2 | `spec.md` | `../tarefas/<ID>-<slug>/` | o time, e você daqui a três semanas |
| 3 | `tasks.md` + `N_task.md` | idem | quem vai implementar |
| 4 | **Épico e subtarefas no ClickUp** | o board | **o dev que nunca abriu este repositório** |

O quarto é o que importa no fim. Os três primeiros existem para ele sair certo.

## A régua que atravessa tudo

> **O produto final se mede por quem não usa o `creed-ai-context`.**

Quem desenvolve com este repositório aberto, e com IA lendo a spec, alcança informação
que a tarefa não precisou escrever. Quem não usa, não alcança — e é a mesma tarefa, o
mesmo sprint, o mesmo prazo.

Isso tem uma consequência prática em cada etapa: **tudo que for necessário para começar
precisa terminar dentro da subtarefa**, em texto ou em anexo. Este repositório acrescenta
profundidade; ele não pode ser a única fonte de nada.

Portão formal: [`../checklists/definition-of-ready.md`](../checklists/definition-of-ready.md).

## O mapa

```
card no ClickUp
      │
      ▼
 [1] calibrar  P × T ──────────────► P1·T1? pule a spec, vá para [3]
      │
      ▼
 [2] discovery + spec.md ──────────► lacuna de produto → premissa no ledger
      │
      ▼
 [3] tasks.md + N_task.md ─────────► aprovação da lista antes de escrever
      │
      ▼
 [4] publicar no board ────────────► traduzir, sem perder o recorte técnico
      │
      ▼
 [5] DoR ──────────────────────────► reprovou? a tabela diz para onde volta
```

Com IA no modo agente, as etapas 1 a 4 têm comando. Sem IA, são as mesmas etapas
escritas à mão — a coluna "sem IA" de cada seção diz o que muda.

---

## Etapa 1 — calibrar

**Entrada:** a descrição da tarefa no ClickUp. **Saída:** `P<n> · T<n>` com o sinal
observado em cada eixo.

A calibragem decide **quais seções a spec tem**, e por isso vem antes da primeira linha
dela. Régua completa em
[`../conventions/profundidade-da-spec.md`](../conventions/profundidade-da-spec.md);
o que você precisa saber para rodar:

| Eixo | Pergunta |
|---|---|
| **P** — produto | quanto disto a cliente ainda não decidiu? |
| **T** — técnico | quanto disto o molde já não resolve? |

Três regras que evitam a discussão mais comum:

- **Um sinal do nível maior basta.** Não é média. Uma migration sozinha faz T3.
- **Empate fica no maior.** Seção a mais custa parágrafo; seção a menos custa retrabalho.
- **Sem sinal observável na descrição → `P3 · T2`**, dito por escrito. Não invente sinal
  para poder calibrar baixo.

**`P1 · T1` não gera spec.** Vá direto para a etapa 3. Em sinal observável: toca um repo,
fica dentro do molde, não cria domínio nem feature, não muda contrato, não tem migration,
e os critérios de aceite da tarefa já são verificáveis sem interpretação nova.

| Com IA | Sem IA |
|---|---|
| `/calibrar <ID>` | leia as duas tabelas de sinais da régua e escreva o bloco à mão |

> **O erro que mais aparece:** calibrar baixo para escrever menos. A calibragem não é
> estimativa de esforço — é medida de incerteza. Tarefa pequena e ambígua é `P3`, e a
> spec dela é curta mesmo assim: são poucas seções, fundas.

---

## Etapa 2 — discovery, e só então a spec

**Entrada:** a tarefa + a calibragem. **Saída:** `spec.md`, e premissas no ledger.

Discovery aqui não é entrevistar ninguém: **a cliente é acessível só em reunião marcada**.
É procurar a resposta onde ela já existe antes de decidir que não existe.

### A ordem de consulta

Vá nesta ordem e pare no primeiro lugar que responde:

| # | Onde | Responde |
|---|---|---|
| 1 | **O código** — `creed-backend/app/domains/`, `creed-frontend/src/features/` | o que já existe de verdade, que às vezes diverge do que está escrito |
| 2 | [`../context/modelo-de-dados.md`](../context/modelo-de-dados.md) | que entidade é essa, o que ela já carrega, que pendência está aberta nela |
| 3 | [`../glossario.md`](../glossario.md) | o termo já tem definição acordada |
| 4 | [`../decisoes/premissas.md`](../decisoes/premissas.md) | alguém já decidiu isto sem a cliente — **inclusive o que foi refutado depois** |
| 5 | [`../decisoes/adrs/`](../decisoes/adrs/) | a decisão de arquitetura que restringe o caminho |
| 6 | [`../catalogo.md`](../catalogo.md) · [`../context/arquitetura.md`](../context/arquitetura.md) | onde a coisa mora, quem fala com quem |

O passo 1 vem antes dos outros de propósito. Documento envelhece; código não mente sobre
o que está rodando. Quando os dois discordam, **isso é um achado** — vai para a spec como
divergência declarada, não é corrigido em silêncio.

### Quando não há resposta: premissa, não pergunta pendurada

Lacuna de **produto** vira **afirmação escrita** no ledger — nunca uma pergunta esperando
resposta, nunca uma escolha silenciosa.

Escolha a interpretação pelos quatro critérios, nesta ordem
([`../conventions/premissas-e-duvidas.md`](../conventions/premissas-e-duvidas.md)):

1. o que **já existe** no produto
2. o mais **barato de reverter**
3. o **menor escopo**
4. o que **não trava** outra pessoa

Depois disso, escreva no ledger com ID, motivo e custo de reverter — e siga.

**Dúvida técnica não vira premissa.** Se está no harness, num ADR ou no código, é
leitura, não decisão de produto. Se não está em lugar nenhum e muda o diff, é decisão do
time — pergunte ao time, não à cliente.

### A spec

Preencha [`../templates/spec-template.md`](../templates/spec-template.md) **só com as
seções que a calibragem exige**. Seção dispensada é apagada, não preenchida com "N/A".

| Com IA | Sem IA |
|---|---|
| `/spec <ID>` | [`../workflows/tarefa-to-spec.md`](../workflows/tarefa-to-spec.md), passo a passo, com o template aberto ao lado |

> **O teste da spec pronta:** você consegue escrever a seção **"Como verificar"** com
> passos concretos que outra pessoa executa? Se não, você ainda não entendeu a tarefa — e
> o que falta não é resposta da cliente, é leitura.

---

## Etapa 3 — quebrar em tasks

**Entrada:** `spec.md`. **Saída:** `tasks.md` (índice) + um `N_task.md` por entrega.

O corte, em quatro regras:

- **Cada task é entregável e testável sozinha.** "Criar o model" não é task; "domínio
  `prismas` com CRUD e testes" é.
- **Task não cruza repositório.** Back e front viram duas tasks, com **o contrato escrito
  na primeira** — é o que deixa as duas correrem em paralelo.
- **Teste faz parte da task.** Nunca existe uma task "escrever os testes".
- **Ordem natural:** migration → model/repository → service → router → feature do front →
  i18n e polimento.

**Tamanho.** Não cabe em um dia de trabalho de uma pessoa: grande demais. É "renomear
variável": pequena demais, junte na anterior.

**Apresente a lista em alto nível e espere aprovação** antes de escrever os arquivos.
Discordar de uma lista de sete linhas é barato; discordar de sete documentos não é.

| Com IA | Sem IA |
|---|---|
| `/tasks <ID>` | [`../workflows/spec-to-tasks.md`](../workflows/spec-to-tasks.md) + [`../templates/tasks-template.md`](../templates/tasks-template.md) |

---

## Etapa 4 — materializar no board

**Entrada:** `tasks.md`. **Saída:** descrição do épico em linguagem de produto, e uma
subtarefa por entrega — legível por quem não tem este repositório.

Esta é a etapa que a régua deste manual cobra. `N_task.md` é nota técnica entre quem já
combinou o contexto; a subtarefa é documento público.

### O que traduz e o que não traduz

| Bloco | Tratamento |
|---|---|
| Objetivo, critérios de aceite | vira prosa de produto: o que muda para quem usa |
| Molde, convenção, premissa | vira frase explicada, com o motivo — **sem o jargão** |
| Arquivos, métodos, rotas, comandos, nomes de classe | **copia literal.** Caminho não vira prosa |
| Contrato de endpoint | tabela, com entrada, saída e os códigos de erro |
| O que reusar | nome **e caminho** do que já existe |
| Calibragem, numeração de task, vocabulário do harness | não vai para o board |

Traduzir é **acrescentar o porquê e o para quem sem perder o recorte técnico**. Os dois
erros são simétricos e igualmente caros: colar `N_task.md` cru não nivela ninguém;
reescrever "bonito" joga fora arquivo, método e contrato, e a tarefa vira desejo.

### Os três leitores

A mesma subtarefa é lida por três pessoas ao mesmo tempo:

| Quem | Acha onde |
|---|---|
| Quem não está no tema — cliente, professor, colega de outra frente | os dois primeiros blocos |
| **Dev que não usa este repositório nem IA** | arquivos, reuso, contrato, comando de teste — literais, na tarefa |
| Dev que usa | o bloco "Rastreio", no fim |

O segundo é a régua. O terceiro é cortesia.

### Os materiais

A tarefa fica pronta quando o material que ela cita **está junto dela**. Isso não é
automático e não é opcional — é trabalho seu.

| Se a subtarefa fala de | Anexe / linke |
|---|---|
| endpoint, request, response | o documento de contrato da tarefa |
| tela, fluxo, navegação | o protótipo no Figma, ou o PDF |
| coluna, tabela, migration | o recorte do modelo de dados |
| "copie a forma de X" | **permalink do arquivo no GitHub**, não o nome da pasta |
| premissa | o **texto** da premissa — o ID sozinho não é material |
| termo do domínio | a definição colada |
| serviço externo | link da doc + o que já está de pé no ambiente local |

**Anexo pendente nunca vira anexo imaginário.** Enquanto não subiu, a linha fica
`⬜ falta anexar — <quem>`. E depois de anexar, **volte e marque ✅** — tarefa pedindo
material que já está lá é a mesma falha ao contrário.

| Com IA | Sem IA |
|---|---|
| `/publicar-no-clickup <ID>` — escreve um rascunho, mostra o mapa, e só publica depois do seu ok | [`../workflows/tasks-to-clickup.md`](../workflows/tasks-to-clickup.md) + [`../templates/clickup-epico-e-subtarefas.md`](../templates/clickup-epico-e-subtarefas.md), colando no board |

Conferência de publicação — mecânica, idempotência, o que não tocar:
[`../checklists/tarefa-nivelada.md`](../checklists/tarefa-nivelada.md).

---

## Etapa 5 — o portão

Rode [`../checklists/definition-of-ready.md`](../checklists/definition-of-ready.md) em
cada subtarefa. Se tiver pressa, rode só o teste de três perguntas com alguém que não
participou da especificação:

1. O que muda para quem usa o sistema?
2. Por onde eu começo — que arquivo eu abro primeiro?
3. Como eu sei que terminei?

Precisou abrir outra coisa para responder: reprovou, e o checklist diz para onde volta.

---

## Quanto isso custa

Medido na CREED-23 (`P3 · T3`, épico de autenticação, sete entregas, três repositórios):

| Etapa | Ordem de grandeza |
|---|---|
| Calibragem | minutos |
| Discovery + spec | a maior parte do trabalho — é onde a ambiguidade morre |
| Tasks | rápido, **se** a spec estiver pronta. Se estiver demorando, a spec é que não fechou |
| Publicar no board | rápido com IA; é o que mais cansa à mão, e é onde a qualidade costuma cair no fim |
| DoR | minutos por subtarefa |

A conta que importa: **a etapa 2 é cara e as outras são baratas quando ela foi bem
feita.** Toda tentativa de economizar tempo na etapa 2 reaparece multiplicada na 4 e na 5.

---

## O que deu errado de verdade

Armadilhas observadas, não hipotéticas.

| Armadilha | Como aparece | O que fazer |
|---|---|---|
| **Épico vira depósito técnico** | toda decisão de arquitetura no épico, e as subtarefas com descrição vazia | o épico é produto; o detalhe desce para a subtarefa que precisa dele |
| **Premissa refutada continua valendo no board** | a tarefa descreve um fluxo que o time abandonou semanas atrás | ao publicar, confira o ledger — premissa fechada tem desfecho escrito |
| **Anexo que ninguém subiu** | "veja o contrato em anexo", sem anexo | `⬜ falta anexar` com dono, e cobrar |
| **ID de premissa como contexto** | `P-012` solto na tarefa | cole o texto; o ID é rastro, não explicação |
| **"Veja o molde"** | quem não conhece o repositório não sabe o que é molde | permalink do arquivo, e diga o que copiar dele |
| **Board diz `to do`, código já existe** | alguém começou e não moveu o card | levante o estado real antes de publicar, e escreva na tarefa |
| **Material de produto que não existe** | "cada papel vê um menu diferente" sem lista de quem vê o quê | isto é decisão de produto faltando: vira premissa ou vira pendência com dono — **nunca** o dev adivinhando |

---

## Referência rápida

| Preciso de | Vá para |
|---|---|
| A régua P × T | [`../conventions/profundidade-da-spec.md`](../conventions/profundidade-da-spec.md) |
| O papel de quem especifica | [`../roles/analista.md`](../roles/analista.md) |
| Como escrever premissa | [`../conventions/premissas-e-duvidas.md`](../conventions/premissas-e-duvidas.md) |
| Formato da spec | [`../templates/spec-template.md`](../templates/spec-template.md) |
| Formato das tasks | [`../templates/tasks-template.md`](../templates/tasks-template.md) |
| Formato do que vai para o board | [`../templates/clickup-epico-e-subtarefas.md`](../templates/clickup-epico-e-subtarefas.md) |
| O portão final | [`../checklists/definition-of-ready.md`](../checklists/definition-of-ready.md) |
| Juntar as premissas abertas para a reunião | [`../workflows/duvidas-to-pauta.md`](../workflows/duvidas-to-pauta.md) |
| Um exemplo real, inteiro | `../tarefas/86e348g6u-autenticacao-da-plataforma/` |
