# Modelo de dados

> **Fonte do time.** Desenhado em conjunto no dbdiagram.io e exportado em 2026-09-03
> (DBML + PDF, mesmo conteúdo). A cópia literal do export vive em
> [`modelo-de-dados.dbml`](modelo-de-dados.dbml) — junto com os protótipos do Figma, é
> um dos dois artefatos que o time produziu coletivamente.
>
> **Status: devolutiva fechada em 2026-09-04.** A análise acabou; a proposta de correção
> está pronta em [`modelo-de-dados.proposta.dbml`](modelo-de-dados.proposta.dbml) e não
> muda mais sem decisão nova. O objetivo declarado é uma **v1 sólida do banco** que
> destrave a autenticação — não o modelo definitivo.
>
> ⚠️ **Ainda não gere migration a partir de `modelo-de-dados.dbml`.** Aquele arquivo é o
> export literal de 2026-09-03, com os dois bloqueios de DDL intactos. O caminho é:
> colar a proposta no dbdiagram → reexportar por cima → aí sim inaugurar. Passo a passo
> em [Quando o modelo for aceito](#quando-o-modelo-for-aceito).

## Os três arquivos

| Arquivo | O que é | Quem edita |
|---|---|---|
| `modelo-de-dados.dbml` | **cópia literal** do dbdiagram de hoje | ninguém edita aqui: edita lá e reexporta por cima |
| `modelo-de-dados.proposta.dbml` | proposta de correção, marcada `[C-NN]` | quem for corrigir — cola no dbdiagram, ajusta, reexporta |
| `modelo-de-dados.md` (este) | o que o modelo diz, o que falta, para onde vai no backend | quem mexer no modelo |

## O que o modelo diz

| Bloco | Tabelas | O que resolve |
|---|---|---|
| Identidade | `User`, `Participant`, `Organization`, `Setor`, `Document` | quem é a pessoa, a que organização pertence, com que documento |
| Ligação | `Vinculo` | a pessoa dentro da organização: tipo de vínculo, papel, período |
| Instrumento | `Form`, `Question` | o que é perguntado |
| Coleta | `FormResponse`, `Answer` | quem respondeu o quê, quando |
| Análise | `Insight`, `InsightPrisma` | a saída da esteira de IA, classificada por prisma |
| Apresentação | `Dashboard` | a visão agregada |

A chave do modelo é o **`Vinculo`**: a resposta não pertence à pessoa, pertence à pessoa
*naquela organização, naquele papel, naquele período* (`FormResponse.vinculo_id`). É o
que permite a mesma pessoa responder por duas organizações sem misturar as análises — e
é também o que várias das pendências abaixo quebram sem querer. Com a decisão
[C2](#decisões-já-tomadas), a mesma pessoa em duas organizações são dois `Vinculo` e
dois logins, mas um só `Participant` — é no participante que as análises se juntam.

## Decisões já tomadas

| Data | Decisão | Consequência |
|---|---|---|
| 2026-09-03 | **Os nomes das tabelas ficam como no diagrama** (`User`, `Form`, `Answer`…), aceitando o desvio de [`../conventions/estrutura-e-nomes.md`](../conventions/estrutura-e-nomes.md) | domínio em português continua valendo para pasta, classe e rota; a **tabela** segue o diagrama. **Atualizado em 2026-09-05:** o [ADR-0005](../decisoes/adrs/0005-idioma-do-codigo.md) acabou com o desvio pelo outro lado — o código passou a ser inglês também, e as tabelas em inglês viraram a regra em vez da exceção. Ficam abertos só `Vinculo` e `Setor`, que são os dois nomes sem tradução decidida (pendência do ADR-0005, com prazo: antes da primeira migration). **Atualizado em 2026-09-29:** fechados também — no código são `Link` e `Department` (tabela `links`, colunas `user.link_id` e `links.department_id`), aplicado pela CREED-32 antes de a tabela subir. O diagrama mantém os nomes em português, e `FormResponse.vinculo_id` segue com o nome antigo no código até ganhar migration própria |
| 2026-09-03 | **`respondentes` não entra na inauguração** | a tabela `respondentes` do `app/domains/respondentes/` é scaffold de exemplo, não modelo do time. `Participant` + `User` ocupam o lugar dela. **Atualizado em 2026-09-21:** a decisão virou remoção — o domínio saiu do `creed-backend` inteiro (models, migration nenhuma, router, testes), e o molde do back passou a ser `app/domains/users/`. Ver a linha de 2026-09-21 abaixo |
| 2026-09-21 | **O domínio `respondentes` sai do backend** | ele era estrutura de scaffold do `chore: commit inicial` (2026-08-13): existia para dar exemplo enquanto nenhum domínio estava escrito. Nunca teve migration nem tabela, então a remoção **não toca dado nenhum** — só saíram 5 endpoints que ninguém do produto usava. O que fica: o papel `UserRole.RESPONDENTE`, que é vocabulário de produto e continua vivo na autenticação, e a feature `src/features/respondentes/` do front, que tem trabalho de tarefa dentro (as telas de demográficos) e é decisão separada. Efeito colateral aberto: `respondentesApi.ts` do front chama `GET /respondentes`, que passou a responder 404 |
| 2026-09-04 | **O 1:1 `User`/`Vinculo` aponta do usuário para o vínculo** — `Vinculo.user_id` sai, `User.vinculo_id` fica `unique, not null` **[C2]** | pessoa com dois vínculos precisa de **dois logins** (`email` é unique) · usuário **não nasce antes do vínculo**: o cadastro é Organização + Participante → Vínculo → User, e o admin da plataforma também precisa de um vínculo · ao trocar de vínculo o ponteiro se move e o vínculo antigo fica sem login — a pessoa continua rastreável por `FormResponse → Vinculo → Participant`. Se alguma das três incomodar, o ajuste barato é `vinculo_id` nullable |
| 2026-09-04 | **O dono do formulário é a organização** — `creator_id` vira `organization_id`, `not null` **[C1]** | formulário não tem dono-pessoa. Quem edita, publica e libera é qualquer vínculo com papel `admin`/`gestor` naquela organização — **autorização, não coluna** |
| 2026-09-04 | **O dono aponta para o documento** — `Participant.document_id` e `Organization.document_id` com FK `unique`; `Document` sem coluna de dono **[C3]** | sem dono polimórfico e sem CHECK, e a organização passa a ter onde guardar CNPJ. Preço: **um documento por dono** (pendência 🟡 22) |
| 2026-09-04 | **Insight tem dois níveis na mesma tabela** — `organization_id` `not null` sempre; `form_response_id` nulável: preenchido = insight individual, nulo = insight de cenário da organização **[C24]** | o modelo anterior (e o diagrama) só permitiam insight individual, porque `form_response_id` era `not null`. `InsightPrisma` serve aos dois sem mudança. São **só** esses dois escopos: nada de recorte por formulário, período ou setor — o que separa duas leituras da mesma organização é o `created_at`, e daí o índice `(organization_id, created_at)`. `organization_id` no individual é denormalizado de propósito: "insights da organização X" vira um `WHERE` indexado em vez de join de três tabelas, e o dashboard sob demanda roda isso o tempo todo |
| 2026-09-04 | **Dashboard e relatório são calculados sob demanda pelo backend** — nenhum resultado é persistido **[C7]** | campos de arquivo saem, `DashboardExport` não entra, `Insight.dashboard_id` sai. Expõe a falta do versionamento de respostas e resultados (pendência 🟠 23). Ver [devolutiva](#devolutiva--dashboard-relatório-e-o-cálculo-sob-demanda) |
| 2026-09-04 | **`User` ganha `status`** (`RecordStatus`, `not null`, default `active`) **[C26]** | desativar um login é caso de uso de autenticação, e a v1 existe para destravar a autenticação. Não se confunde com `Vinculo.end_at`: `status` é **acesso**, `end_at` é **vínculo**. Única mudança feita depois do fechamento da devolutiva |
| 2026-09-04 | **A meta é uma v1 sólida do banco, para destravar a autenticação** — versionamento de resposta e resultado fica para depois | a devolutiva fecha aqui; a proposta não muda mais sem decisão nova. O que foi adiado, com gatilho de retorno, está em [Adiado de propósito](#adiado-de-propósito); o que a auth ainda vai precisar, em [A v1 e a autenticação](#a-v1-e-a-autenticação) |
| 2026-09-13 | **`User.password` sai — a credencial mora no Keycloak [C27]** | guardar hash aqui criaria uma segunda fonte de senha e a pergunta sem resposta boa: qual das duas vale no login? Fecha a pendência "`User.password` é nulável" — não há senha nossa. **Ratificada pelo código**, não por reunião: a migration de inauguração subiu sem a coluna |
| 2026-09-13 | **`User.keycloak_id` entra** (`uuid`, `unique`, `not null`) **[C28]** | é o `sub` do JWT, a única ligação entre o token que chega e a linha da tabela. Sem ele o backend acharia o usuário por e-mail, e e-mail é dado que muda. **Não é FK** — aponta para fora do banco, então a contagem de FKs do cabeçalho não muda |
| 2026-09-22 | **`Question` ganha `section`** (`QuestionSection`, `not null`, sem default) **[C31]** | o front sabe em que parte do formulário desenhar cada pergunta, e a listagem filtra por ela. Independente do prisma. Valores provisórios (P-020): trocar depois de haver pergunta gravada é `ALTER TYPE` + atualização das linhas. Decisão de time, não da cliente |

## Pendências

Nada aqui é opinião de estilo: cada item ou impede o banco de existir, ou deixa entrar
dado que depois não dá para consertar sem migration de correção.

### 🔴 Bloqueiam o DDL — sem isto não há inauguração

**1. Duas FKs apontam para coluna sem `unique`.** `Form.creator_id > Vinculo.organization_id`
e `Form.participant_id > Vinculo.participant_id`. FK só referencia PK ou coluna única;
o Postgres recusa com `there is no unique constraint matching given keys`.
→ **[C1]**: o alvo estava errado, a intenção não. `creator_id` ia parar em
`organization_id` porque **o dono do formulário é a organização** — vira
`organization_id > Organization.id`, `not null`. `participant_id > Participant.id`.

O que o nome `creator_id` sugeria — um dono-pessoa — não existe: vários gestores e
admins da organização editam e liberam o mesmo formulário. **Isso é autorização, não
coluna**: sai de `Vinculo` (papel `admin`/`gestor` naquela organização). Autorização que
vira coluna precisa de `UPDATE` para mudar, e some quando a pessoa troca de papel.

**2. Ciclo obrigatório `User` ↔ `Vinculo`.** `User.vinculo_id` é `not null` e
`Vinculo.user_id` também: a primeira linha de qualquer das duas tabelas é impossível de
inserir. Uma das duas pontas tem que cair.
→ **[C2]**: cai `Vinculo.user_id`; `User.vinculo_id` fica. O `unique` que o diagrama já
trazia nessa coluna diz que **1 usuário = 1 vínculo** era intenção, não descuido — a
correção respeita a intenção em vez de reinterpretá-la. O que isso custa está na
[decisão de 2026-09-04](#decisões-já-tomadas).

### 🟠 Furos de modelagem — o DDL passa, o dado sai errado

| # | O quê | Correção proposta |
|---|---|---|
| 3 | **Organização não consegue ter documento.** `Document.participant_id` é `not null` e `Organization.document_id` não tem FK nenhuma — mas `DocType` traz CNPJ, NIPC e VAT_EU, que são documentos de organização | **[C3]** a seta inverte: quem aponta é o dono. `Participant.document_id` e `Organization.document_id` (as colunas órfãs que o diagrama já trazia) ganham FK `unique`, e `Document` perde a coluna de dono — sem dono polimórfico, sem CHECK. Preço em 🟡 22 |
| 4 | **Setor em três lugares:** enum `Setores`, tabela `Setor` embrulhando o enum, e `Participant.department`. Pessoa troca de setor sem trocar de identidade | **[C4]** setor vive só em `Vinculo.setor_id`; `Setor` vira dado (`name`, opcionalmente por organização) e o enum sai |
| 5 | **`FormResponse` sem `unique (form_id, vinculo_id)`** — o mesmo vínculo responde o mesmo formulário cinco vezes | **[C5]** unique. Se refazer for permitido, então é `attempt`, não duplicata silenciosa |
| 6 | **`status string` solto** em `Participant`, `Organization` e `Form`, num modelo em que todo o resto é enum | **[C6]** `RecordStatus` e `FormStatus` |
| 7 | **`Dashboard` não é um dashboard:** `hash`, `blurhash`, `content_type`, `url`, `s3_url`, `size` são campos de arquivo. Contradiz o princípio nº 1 do projeto — dashboard que é arquivo no S3 foi renderizado fora do front | **[C7]** campos de arquivo saem, `Insight.dashboard_id` sai, `DashboardExport` não entra. Decidido em 2026-09-04: cálculo sob demanda no backend. Devolutiva inteira [abaixo](#devolutiva--dashboard-relatório-e-o-cálculo-sob-demanda) |
| 8 | **Pergunta objetiva sem alternativas.** `QuestionType.objective` existe, mas não há tabela de opções e `Answer.value` é texto livre: agregar objetiva vira `GROUP BY` em coisa digitada | **[C8]** `QuestionOption` + `Answer.option_id` |
| 9 | **Nada liga pergunta a prisma.** Prisma só aparece em `InsightPrisma`, que é saída da IA — toda análise por prisma passa a depender 100% do N8N, sem nada computável no banco | **[C9]** `Question.prisma` |
| 10 | **Timestamps irregulares:** `User`, `Setor`, `Document`, `Question` e `Answer` sem `created_at`; `Vinculo` tem `updated_at` sem `created_at` | **[C10]** uniformizar |
| 23 | **O versionamento de respostas e resultados não existe no modelo.** `Answer` é sobrescrita no lugar, `FormResponse` só tem `status` e `submitted_at`, `Insight` só tem `created_at`. Uma leitura de organização feita sobre 40 respostas e outra sobre 60 são duas linhas idênticas na estrutura | **adiado para depois da v1** (2026-09-04). Motivo, mitigação e gatilho de retorno em [Adiado de propósito](#adiado-de-propósito) |

### 🟡 Consistência e convenção

| # | O quê |
|---|---|
| 11 | **`Question.order` é palavra reservada** em SQL — a coluna viveria entre aspas para sempre. **[C11]** `order_index` |
| 12 | **`Roles {Admin, Gestor, Respondente}` contradiz a premissa [P-003](../decisoes/premissas.md)** (`admin` e `funcionario`, dois níveis). Mas P-003 nasceu da tarefa 17, que nunca saiu do papel — não há menu no front, nem branch, nem commit, e a pasta `tarefas/17-*` sequer está versionada. Entre um artefato feito em time e uma premissa de exercício, quem tem lastro é o modelo. **Não corrigido na proposta** — mas fechar em favor do diagrama hoje custa zero |
| 13 | **Caixa dos enums inconsistente:** `Prisma`, `QuestionType` e `FormResponseStatus` em `snake_case`; `VincType`, `Roles`, `DocType` e `Setores` em PascalCase. **[C13]** tudo em `snake_case` |
| 14 | **`Gender {masc, fem}`** fecha em duas opções o recorte demográfico que é matéria-prima do produto. **[C14]** acrescentar `outro` e `nao_informado` |
| 15 | **`Setores` como enum de 5 valores fixos** — setor é dado da cliente; enum no Postgres só muda por migration. Resolvido junto com [C4] |
| 16 | **Índices só em `Form`, `Question`, `FormResponse` e `Answer`.** Faltam nas FKs de `Vinculo`, `Document`, `Insight` e `Dashboard` — todas entram em JOIN de agregação. **[C16]** |
| 17 | **`Form` não tem título nem descrição.** Como o gestor identifica um formulário numa lista? Não acrescentado na proposta: é campo de produto, não correção |
| 18 | **`prognosticos` e `relatorios` existem como domínio no backend e não têm tabela nenhuma no modelo.** Ou os domínios são scaffold como `respondentes`, ou falta um pedaço do modelo |
| 19 | **`Participant.address` é obrigatório** sem uso definido em nenhuma tela. Dado pessoal que ninguém pediu é dado pessoal que alguém vai ter que justificar. **[C19]** opcional |
| 20 | **Consequência de [C2]:** com `User` e `Vinculo` em 1:1, `Dashboard.user_id` (aponta para o login) e o resto do modelo (que passa por `Vinculo`) chegam na mesma pessoa por caminhos diferentes. Não é erro, mas o código vai ter dois jeitos de perguntar "de quem é isto". Vale padronizar antes de virar `models.py` |
| 21 | **O que `Form.participant_id` significa agora?** Com o dono sendo a organização (#1) e as respostas vindo de N vínculos, uma coluna que aponta para **um** participante ou quer dizer "formulário nominal, feito para esta pessoa", ou é resquício do mesmo engano do `creator_id` — a seta ia parar em `Vinculo.participant_id` querendo dizer "os participantes da organização". A proposta manteve a coluna sem decidir |
| 22 | **Preço de [C3]: um documento por dono.** Com a seta saindo de `Participant`/`Organization`, cada um tem no máximo **um** documento — CPF *e* passaporte na mesma pessoa não cabe. Se a resposta for "sempre um só", vale a pergunta seguinte: a tabela `Document` se justifica, ou viram três colunas em cada dono? Se for "podem ser vários", a direção da seta precisa voltar |

### O que só a cliente decide

Estes não são erro de modelagem — são lacuna de produto, e pelo
[`../conventions/premissas-e-duvidas.md`](../conventions/premissas-e-duvidas.md) viram
premissa ou item de pauta, nunca preenchimento silencioso:

- **Papéis** (#12): `Admin`/`Gestor`/`Respondente` ou `admin`/`funcionario`? Nenhum dos
  dois tem código atrás — é confirmação, não desempate caro.
- **Prisma** (#9): o prisma é atributo da **pergunta** (o instrumento já sabe o que mede)
  ou só do **insight** (quem classifica é a IA)? Muda quem é dono da análise.
- **Objetiva** (#8): a pergunta objetiva aceita mais de uma alternativa? A proposta
  deixa `Answer` sem `unique (form_response_id, question_id)` para não fechar a porta.
- **Formulário nominal** (#21): o formulário é da organização e todo mundo de lá
  responde, ou existe formulário feito para uma pessoa específica? É `Form.participant_id`
  que fica ou some.
- **Documento** (#22): uma pessoa pode ter mais de um documento (CPF *e* passaporte)?
  A resposta decide a direção da seta — e se a tabela `Document` se justifica.
- **Gênero** (#14): que opções o instrumento oferece?

O **dashboard** saiu desta lista: virou decisão de arquitetura do time em 2026-09-04,
não pergunta de produto. Está na devolutiva abaixo.

## Devolutiva — dashboard, relatório e o cálculo sob demanda

### O que a tabela `Dashboard` diz hoje

`hash`, `blurhash`, `content_type`, `url`, `s3_url`, `size`, `is_private`. Isso não é o
esqueleto de um painel: é o esqueleto de **um arquivo guardado num bucket**. `blurhash`
em particular só existe para uma coisa — mostrar um borrão enquanto a **imagem** carrega.
A tabela descreve uma imagem exportada, e o nome dela diz "dashboard".

Não é um deslize de nomenclatura. Uma tabela dessas só faz sentido num desenho em que o
resultado é **calculado uma vez, renderizado, e servido como arquivo pronto**.

### Por que esse desenho não fecha aqui

**1. Contradiz o princípio nº 1.** *Agregação no banco, cálculo no backend, renderização
no front* ([`arquitetura.md`](arquitetura.md)). Um PNG no S3 já foi renderizado — e não
foi pelo front. O princípio não sobrevive à primeira tela.

**2. Congela o resultado.** O número guardado é o número de quando alguém gerou o
arquivo. Chegou resposta nova, a imagem continua lá, certinha e errada. Ninguém percebe:
não há nada na tabela que saiba que envelheceu.

**3. Duplica a fonte da verdade.** O mesmo indicador passa a existir em dois lugares — na
soma das respostas e no arquivo. Quando divergirem, e vão divergir, não há critério de
desempate no banco.

**4. Empurra cálculo para fora do backend.** Alguém tem que gerar essa imagem. Ou é um
job (que precisa saber quando rodar — e não sabe, ver ponto 2), ou é a esteira de IA
devolvendo gráfico pronto. Nos dois casos o cálculo saiu do `service.py`, que é onde
[`arquitetura.md`](arquitetura.md) mandou ele ficar.

### A decisão (2026-09-04)

**Dashboard e relatório são montados pelo backend, sob demanda, a partir das respostas e
dos insights.** Nada de resultado é persistido. O que o banco guarda é matéria-prima:
`Answer`, `FormResponse`, `Insight`, `InsightPrisma`. O indicador é a query.

Consequências no modelo, todas na proposta:

| O quê | Por quê |
|---|---|
| Campos de arquivo saem de `Dashboard` | não há arquivo |
| `DashboardExport` não entra | exportar PDF/imagem, se virar requisito, é **cache** — e cache precisa saber invalidar, o que exige o versionamento que ainda não existe (#23). Enquanto isso, exportação se gera e se entrega |
| `Insight.dashboard_id` sai | o insight nasce de uma resposta, não de um painel. O painel lê insights; o insight não sabe que painel existe. Prender um ao outro recria o congelamento pela porta dos fundos |
| `Dashboard` fica magro — e condicional | só sobrevive se existir "salvar/compartilhar uma visão" como funcionalidade. Se não existir, **dashboard é rota e query, não linha de banco**, e a tabela sai inteira junto com `Dashboard.user_id`/`form_id` |

### O buraco que essa decisão expõe

O cálculo sob demanda se apoia no versionamento de respostas e resultados. **Esse
versionamento não está no modelo, nem em `arquitetura.md`, nem em ADR nenhum** — procurei.
O que existe hoje:

- `Answer` é **sobrescrita no lugar**: editar uma resposta apaga a anterior.
- `FormResponse` tem `status` e `submitted_at`, e nada que diga "esta é a 2ª versão".
- `Insight` tem `created_at` e nada que amarre o insight ao **estado das respostas** que
  o produziu.
- O insight **da organização** ([C24]) é onde isso dói mais: ele resume "todos os
  participantes vinculados", um conjunto que cresce a cada resposta nova. A linha não
  guarda quantas respostas leu, então não há como saber se a leitura de ontem ainda
  vale hoje — nem como reproduzi-la.

Na prática: se alguém edita uma resposta depois de a esteira ter rodado, o insight
continua no banco falando de um estado que não existe mais, e ninguém consegue provar de
onde ele saiu. Um dashboard sob demanda montado em cima disso é reproduzível por acidente,
não por construção.

Isso não se resolve numa coluna, e por isso não está na proposta de DBML. É decisão de
arquitetura — e ficou **adiada de propósito** (abaixo), porque a v1 do banco existe para
destravar a autenticação, não para resolver reprodutibilidade de análise.

**O que segura a v1 enquanto isso:** como nada de resultado é persistido, o dashboard
sempre reflete o banco no instante em que foi aberto. O único dado que envelhece é o
**texto do insight**, que é gerado pela esteira e fica gravado. A mitigação é de
interface, não de schema: **mostrar o `created_at` do insight ao lado do texto**. Quem lê
"leitura de 12/03" ao lado de um painel de hoje entende sozinho que uma coisa é datada e
a outra não. Custa zero no banco e resolve o caso enquanto o volume é pequeno.

## Adiado de propósito

Decidido em 2026-09-04. A v1 do banco existe para **destravar a autenticação**; o que não
serve a isso e não é irreversível fica para depois. Adiar registrado é diferente de
esquecer: cada item abaixo tem motivo, mitigação e **gatilho de retorno**.

| Adiado | Por que dá para adiar | Gatilho de retorno |
|---|---|---|
| **Versionamento de respostas e resultados** (#23) — histórico de `Answer`, `FormResponse` por tentativa, snapshot no `Insight` | nada de resultado é persistido (decisão [C7]), então só o texto do insight envelhece. Mitigação: mostrar o `created_at` do insight na tela. E as três soluções possíveis são **aditivas** — tabela nova ou coluna nulável, nenhuma exige reescrever o que já foi gravado | a primeira vez que alguém precisar responder "de onde saiu este número?" com dado real na frente da cliente. Ou o primeiro caso de resposta editada depois da esteira ter rodado |
| **Export de dashboard/relatório** (`DashboardExport`) | é cache de um cálculo, e cache sem invalidação é o mesmo problema acima | exportar PDF/imagem virar requisito |

O que **não** foi adiado, mesmo custando mais agora: os dois bloqueios de DDL (#1, #2) e
os furos que deixam entrar dado inconsistente (#3 a #10). Esses não são aditivos —
consertar depois é migration de correção com dado gravado em cima.

## A v1 e a autenticação

O próximo passo é autenticação, então vale dizer o que **este** modelo já resolve para ela
e o que ainda não:

**Resolve.** `User.email` único e o papel vindo de `Vinculo.role` —
autorização por papel *dentro de uma organização*, que é o que o produto pede. Com o 1:1
de [C2], o papel de um login é uma consulta direta: `User → Vinculo → role`.

**Não resolve — e aparece na primeira sprint de auth:**

| O quê | Por quê importa agora |
|---|---|
| **`Roles` ainda em conflito com [P-003](../decisoes/premissas.md)** (#12) | a auth vai codificar a lista de papéis. Decidir depois é migration de enum **e** refactor de guarda de rota. É a pendência mais urgente das que sobraram, e a mais barata: nenhum código depende dos dois lados hoje |
| ~~Não há como desativar um login~~ — **resolvido [C26]**: `User.status RecordStatus`, `not null`, default `active` | `status = inactive` desliga o **acesso**; `Vinculo.end_at` encerra o **vínculo**. Separados de propósito: dá para suspender alguém sem encerrar o vínculo, e dá para o vínculo acabar sem apagar a conta. Apagar a linha do `User` nunca foi opção — `Dashboard.user_id` aponta para ela |
| ~~**`User.password` é nulável**~~ — **resolvido [C27]**: a coluna saiu | não há senha nossa. A credencial é do Keycloak (P-012, decisão D1 da CREED-23); daqui sai só o `keycloak_id`, que não abre porta sozinho |
| 🟢 **A tabela `user` que subiu não é a deste modelo** — **decidido em 2026-09-24** | a migration de inauguração (`0b0ad39d779a`, 2026-09-13) criou `user` com **`name` e `role` como coluna** e **sem `vinculo_id`** — porque `Vinculo` ainda não tinha tabela e a guarda precisava de uma cópia do papel no banco para conferir o claim do token. **Decisão do time: vale o modelo.** O papel vai para o vínculo (`Link.role` no código), `user` ganha `link_id` (o `vinculo_id` do diagrama) e perde `role`, executado na [CREED-32](../tarefas/86e3anvg2-vinculo-table-context/spec.md) em dois PRs (aditivo, depois destrutivo). **`name` não entra nessa decisão**: continua no `user` até `Participant` existir |
| **Sem tabela de token** (reset de senha, refresh, verificação de e-mail) | não é problema: essas tabelas são **aditivas**, entram por migration própria quando a auth for desenhada. Só não confundir com esquecimento |

## Mapa tabela → domínio do backend

Proposta, para quando a inauguração acontecer. Domínio é pasta em `app/domains/`;
tabela é o nome do diagrama.

| Domínio | Situação | Tabelas |
|---|---|---|
| `usuarios` | novo | `User` |
| `participantes` | novo — ocupa o lugar do scaffold `respondentes` | `Participant` |
| `documentos` | novo | `Document` — domínio próprio porque, com a seta invertida em [C3], `participantes` **e** `organizacoes` referenciam a mesma tabela, e [`arquitetura.md`](arquitetura.md) proíbe domínio importar `models.py` alheio. A FK se declara por nome (`ForeignKey("documents.id")`), sem import |
| `organizacoes` | existe | `Organization`, `Setor` |
| `vinculos` | novo | `Vinculo` |
| `forms` | novo (CREED-33) | `Form` |
| `questions` | novo (CREED-35) | `Question` — nasceu em domínio próprio porque CREED-33 e CREED-35 correm em paralelo, sem ligação de FK entre as duas tabelas ainda. `QuestionOption` fica para a CREED-37 decidir, junto com a amarração entre os dois domínios |
| `respostas` | novo | `FormResponse`, `Answer` |
| `prismas` | existe | `Insight`, `InsightPrisma` |
| `dashboards` | existe | `Dashboard`, **se** a visão salva existir. Senão: domínio sem tabela, só query — que é o normal para dashboard sob demanda |
| `prognosticos`, `relatorios` | existem | nenhuma — ver pendência #18. `relatorios`, pela decisão de 2026-09-04, tende a ser domínio sem tabela também |

Lembrete do [`../conventions/migrations.md`](../conventions/migrations.md): todo model
novo precisa ser importado em `alembic/env.py`, senão o autogenerate não o enxerga e a
migration sai incompleta.

## Quando o modelo for aceito

1. Corrigir no dbdiagram e reexportar por cima de `modelo-de-dados.dbml`.
2. Trocar o status no topo deste arquivo e apagar as pendências resolvidas.
3. Levar as lacunas de produto para o ledger e a pauta
   ([`../workflows/duvidas-to-pauta.md`](../workflows/duvidas-to-pauta.md)).
4. Acrescentar os termos novos ao [`../glossario.md`](../glossario.md) — vínculo,
   setor, participante, formulário, insight. Nenhum deles está lá hoje.
5. Fechar os papéis (#12) — é o único item que a autenticação não consegue contornar.
6. Só então: `models.py` por domínio → `alembic revision --autogenerate` → leitura
   linha a linha ([`../playbooks/criar-migration.md`](../playbooks/criar-migration.md)).

Versionamento **não** entra nesta lista, por decisão: ver [Adiado de propósito](#adiado-de-propósito).
