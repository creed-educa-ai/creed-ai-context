# Dashboard: análise do back para a integração

> Análise de 2026-11-03, feita lendo o `creed-backend` (branch `dev`, `cc8dc61`) e
> o contrato do front (`creed-frontend/src/features/dashboards/dashboardsApi.ts`).
> Complementa o [`levantamento.md`](levantamento.md) de 2026-11-02: lá está *o que*
> a tela pede; aqui, *de onde* sai cada campo, o que falta no back e em que ordem
> fazer. Ainda não é spec.

## Em três frases

1. **O esquema do banco basta.** Todo número do dashboard sai de tabelas que já
   existem, sem migration. Fica de fora só o texto do Creed.ai para setor e
   organização.
2. **O dado ainda não existe.** Nenhuma resposta objetiva chega ao banco hoje: a
   cadeia "pergunta com alternativa → resposta → nota" está quebrada em três
   pontos (seção 1). Sem consertar isso, o cálculo roda, mas sempre sobre zero
   linhas.
3. **O contrato tem quatro furos** que o mock esconde: a organização do `admin`,
   textos prontos em português vindos do back, o nome dos prismas em dois enums e
   os textos do Creed.ai (seção 4).

## 1. Pré-requisito: fazer a nota chegar ao banco

A nota de uma pessoa é a média das alternativas (1 a 5) que ela escolheu nas
perguntas objetivas de cada dimensão. Hoje nenhuma dessas alternativas é gravada:

| # | Elo | Situação hoje | Onde | O que falta |
|---|---|---|---|---|
| 1 | O formulário real tem as perguntas objetivas, com `dimensao` e alternativas `1`…`5` (P-040) | **Não existe.** O seed cria só perguntas descritivas, com `prisma=None` e sem `dimensao` | `creed-backend/scripts/seed_local.py` (`_ensure_demo_form`) | Cadastrar o instrumento: as perguntas 16–64 com a dimensão de cada uma (o mapa está nos comentários de `Dimension`, em `app/shared/enums.py`) e as cinco alternativas. As rotas já existem: `POST /questions` e `POST /questions/{id}/options` |
| 2 | `GET /forms/{form_id}/questions` devolve as alternativas (P-039) | **Não devolve.** `QuestionResponse` não tem `options` | `app/domains/questions/schemas.py`, `service.list_for_form` | Incluir `options` na listagem |
| 3 | O front envia a resposta objetiva em `option_id` | **Pula.** Um `continue` nas objetivas, de propósito, até o elo 2 existir | `creed-frontend/src/features/responses/responsesSlice.ts` (`submitResponses`) | Apagar a linha. O corpo com `option_id` já sai pronto de `paraAnswerCreate` |

O back já aceita e confere a resposta objetiva (`590be26`: alternativa da própria
pergunta, sem texto, 422 caso contrário). O problema está só nas duas pontas.

**Consequência para a ordem:** é a primeira tarefa, antes de qualquer cálculo, e
também é o que destrava os testes do cálculo com dado real.

## 2. O que já existe e serve

| Peça | Onde | Serve para |
|---|---|---|
| Uma resposta por vínculo e formulário | `form_responses`, `unique (form_id, vinculo_id)` | "uma pessoa, uma nota por período" já é garantido pelo banco |
| Status da resposta | `form_responses.status` (`IN_PROGRESS` · `SUBMITTED`) e `submitted_at` | contar só as respostas enviadas |
| Resposta objetiva → alternativa | `answer.option_id` → `question_options.id` (FK desde `590be26`) | o número vem de `question_options.value`, **não** de `answer.value` (que é nulo na objetiva) |
| Dimensão da pergunta | `questions.dimensao` (enum `dimension`) | agrupar por dimensão |
| Setor da pessoa | `links.department_id` → `departments.type` (único por organização) | recorte por setor e mapa setores × prismas. **É nulo** para quem não tem setor |
| Nome da pessoa | `links.participant_id` → `participants.name` | lista de funcionários do filtro |
| Os 5 prismas a partir das 7 médias | `calculate_all_prisms` e `dimension_averages` em `app/domains/prismas/utils.py` (com teste) | cálculo por pessoa, em Python |
| Quem pede e de onde | `CurrentUserDep` / `require_role` em `app/shared/authorization.py`: entrega `role`, `link_uuid` e `organization_uuid` já conferidos no banco | guarda das duas rotas e o recorte do `/me` |
| Regra "admin vê qualquer organização, gestor só a sua" | `organizacoes/service.get(role=..., own_organization_id=...)` | o mesmo desenho para `/dashboards/company` |
| Lugar do texto individual | `insights` (`form_response_id`, índice **não** único) e `insight_prismas` | o Creed.ai de uma pessoa, quando o N8N existir |

E o que **não** serve, apesar do nome:

- **A tabela `dashboards`** (`user_id`, `form_id`, `is_private`) não guarda nada que
  a tela use. O dashboard é calculado, não gravado. Além disso, a coluna `form_id`
  aponta para `form_responses`, não para `form`. Proposta: não usar na integração
  e decidir à parte se ela some ou se o `is_private` vira regra (decisão 9).
- **`prismas/router.py`, `service.py` e `repository.py`** são stubs vazios. O
  cálculo pode morar em `dashboards` e usar `prismas/utils.py`, sem criar rota de
  prismas.

## 3. A consulta base e o cálculo

### A consulta (`dashboards/repository.py`)

Uma linha por pessoa e dimensão, com a média já feita no Postgres:

```sql
SELECT fr.id            AS form_response_id,
       fr.vinculo_id    AS link_id,
       l.department_id,
       q.dimensao,
       AVG(CAST(qo.value AS integer)) AS media,
       COUNT(*)                       AS itens
FROM form_responses fr
JOIN links            l  ON l.id  = fr.vinculo_id
JOIN answer           a  ON a.form_response_id = fr.id
JOIN question_options qo ON qo.id = a.option_id
JOIN questions        q  ON q.id  = a.question_id
WHERE fr.form_id        = :form_id
  AND fr.status         = 'SUBMITTED'            -- o enum vai pelo NOME no banco
  AND l.organization_id = :organization_id
  AND q.dimensao IS NOT NULL
  AND qo.value IN ('1','2','3','4','5')          -- P-040; recusa o resto antes do CAST
GROUP BY fr.id, fr.vinculo_id, l.department_id, q.dimensao;
```

- Escrever com o ORM (`select(...)`), não com SQL cru: os enums
  (`FormResponseStatus`, `Dimension`, `DepartmentType`) ficam gravados pelo
  **nome** (`SUBMITTED`, `MARKETING`), e a API usa o **valor** (`Marketing`). O ORM
  converte; uma string solta erra em silêncio.
- **Uma consulta por formulário (período), sem filtro de setor ou pessoa.** Com
  todas as pessoas da organização em memória, o service faz recorte, comparações,
  mapa e alinhamento sem voltar ao banco. Para o tamanho das organizações do
  projeto (dezenas de pessoas × 7 dimensões), isso dá centenas de linhas por
  período.
- Os períodos de comparação são outros formulários: a mesma consulta, uma vez por
  período (hoje no máximo 3).

### O cálculo (`dashboards/service.py`)

Para cada pessoa: as 7 médias → `calculate_all_prisms` → escala 0–100. Depois,
cada campo da tela é uma função pura sobre essa lista:

| Campo do contrato | Cálculo | Depende de |
|---|---|---|
| `periods`, `period` | formulários da organização com status `PUBLISHED` ou `CLOSED`, do mais recente ao mais antigo; sem `period`, o mais recente | decisão 1 |
| `scores`, `dimensions` | média das pessoas do recorte | decisões 2, 3 e 4 |
| `comparisons[]` | o mesmo cálculo para cada par (período × escopo). Escopo nulo = o recorte exibido | — |
| `comparisons[].variation` | `scores` − `comparison.scores`, prisma a prisma | — |
| `comparison_options` | outros períodos; setores da organização (vazio no `/me`); `default_period` = o anterior ao exibido | — |
| `company_summary.destaque` / `oportunidade` | maior e menor prisma do recorte | empate (decisão 7) |
| `company_summary.maisComum` | ? | decisão 6 |
| `company_summary.concluidos` / `convidados` | respostas `SUBMITTED` ÷ vínculos do recorte | decisão 5 |
| `creed_summary.destaque` / `oportunidade` | os mesmos de cima | — |
| `alignment` | por prisma, pessoas em cada faixa e o nível. Nulo no recorte de um funcionário | P-061, P-062 |
| `department_matrix` | para cada `departments` da organização: média do setor − média da organização inteira. Setor sem resposta → `scores: null` | quem não tem setor entra na organização e fica fora do mapa |
| `departments`, `members` | `departments` da organização; vínculos + `participants.name` | decisão 8 |
| `organization_name` | `organizations.name` | — |

Princípio 1 continua valendo: tudo acima é do back; o front só desenha.

## 4. Furos no contrato

O mock aceitou estas formas porque não precisou resolvê-las. Antes de integrar:

| # | Furo | Por quê | Proposta |
|---|---|---|---|
| A | **Qual organização o `admin` vê.** `DashboardFilters` não tem `organization_id` | Pela P-055, `admin` é a CREED (a cliente), não uma empresa: o vínculo dele não diz qual empresa olhar. O `gestor` resolve pelo próprio vínculo | `GET /dashboards/company?organization_id=…`: obrigatório para `admin`, ignorado (ou conferido) para `gestor`, como em `organizacoes` |
| B | **Texto pronto vindo do back.** `DashboardHighlight.titulo` e `.descricao` são frases em português montadas no mock ("O ponto mais forte de Marketing") | Fura o i18n: em inglês e espanhol a tela mostraria português | O back manda só `{ prisma, valor }`; título e descrição saem do i18n do front |
| C | **Dois enums para os prismas.** `prismas/utils.py` devolve `NeuroinnovationPrism` (`SP`, `LA`…), e o contrato usa `Prisma` (`seguranca_psicologica`…) | Duas fontes para a mesma coisa | Um dicionário de tradução em `prismas/utils.py`, ao lado do `PRISM_COMPOSITION`, com teste |
| D | **Identificadores em português no JSON** (`concluidos`, `convidados`, `maisComum`, `analiseTexto`, `recomendacaoTexto`) | O ADR-0005 pede inglês nos identificadores, e o resto do contrato já está em inglês | Renomear no front antes de o back nascer com esses nomes: depois, custa uma migração de contrato |

## 5. Os textos do Creed.ai

Sem mudança em relação ao levantamento, com duas precisões:

- **Texto individual:** além do workflow do N8N (P-041), falta toda a esteira do
  ADR-0010 do lado do back (outbox e worker). Não é um passo do dashboard; o
  dashboard só lê o `insight` quando ele existir.
- **A P-042 e o banco discordam.** A premissa diz `unique (form_response_id)`, mas a
  migration consolidada (`c6625156d816`) criou o índice com `unique=False`. Vale
  corrigir uma das duas. Se o texto por prisma for mantido, a premissa é que
  muda.

Recomendação mantida: **caminho (c)** na primeira versão. `creed_summary` vem com
`analiseTexto`, `recomendacaoTexto` e `prismas` vazios, e o front mostra um estado
de "análise ainda não disponível" no lugar do texto. **Isso o front ainda não tem**:
hoje ele espera os textos preenchidos.

## 6. Decisões

As seis do levantamento continuam abertas. A leitura do código acrescenta três:

| # | Decisão | Proposta | De quem |
|---|---|---|---|
| 1–6 | ver [`levantamento.md`](levantamento.md), seção 3 | — | cliente |
| 7 | Empate em destaque ou oportunidade (dois prismas com a mesma nota) | A ordem fixa dos prismas (`PRISMAS`) desempata | time |
| 8 | Quem aparece na lista de funcionários | Só quem tem resposta enviada no período, já que quem não respondeu não tem resultado para abrir | time, com o front |
| 9 | Para que serve a tabela `dashboards` e o `is_private` | Se for "o funcionário esconde o resultado da empresa", contradiz a refutação da P-063 ("a empresa já vê o resultado individual"). Proposta: não usar agora e levar a dúvida à cliente | cliente |

Sobre a decisão 1, a leitura do código acrescenta um custo: **as perguntas
pertencem ao formulário** (`questions.form_id`). Se cada período for um `Form`,
cada período novo exige recadastrar as perguntas objetivas e as cinco alternativas
de cada uma. Não impede a proposta, mas pede uma ação de "duplicar formulário"
cedo, ou um script.

## 7. Corte proposto

Em ordem, cada passo entregável sozinho:

| # | Entrega | Repo | Tamanho | Destrava |
|---|---|---|---|---|
| 1 | **Nota chega ao banco:** `options` na listagem, o front envia a objetiva, o instrumento cadastrado no seed (seção 1) | back + front | M | tudo |
| 2 | **Decisões 1 a 9** registradas como premissas; as de cliente na pauta | contexto | P | 3 em diante |
| 3 | **Furos A–D** fechados no contrato (`dashboardsApi.ts`, `contrato-front-back.md`) | front + contexto | P | 4 |
| 4 | **Consulta base + cálculo por pessoa** no `dashboards`, com teste em banco real | back | M | 5, 6 |
| 5 | **`GET /dashboards/me`**: período, notas, dimensões, comparações por período, destaque e oportunidade | back + front | M | — |
| 6 | **`GET /dashboards/company`**: recorte, comparações por setor, resumo, alinhamento, mapa, membros | back + front | G | — |
| 7 | **Creed.ai individual**, quando a esteira do ADR-0010 existir | back | — | fora deste corte |

O passo 5 antes do 6 é de propósito: o `/me` tem um recorte só e nenhum setor,
então prova a consulta e o cálculo com metade das regras.

## 8. Riscos para quem implementar

- **Não existe teste com banco real no back.** A `conventions/testes.md` exige banco
  real para agregação, e o CI já sobe um `postgres:16`, mas nenhum teste usa: os de
  repository são dublês. O passo 4 precisa criar o fixture de sessão com banco, e
  ele vale para o projeto todo.
- **`calculate_all_prisms` levanta erro** se faltar uma dimensão. Com pergunta
  objetiva opcional (`required=false`, P-038), uma pessoa pode ficar sem uma
  dimensão inteira. A decisão 4 precisa estar fechada antes do passo 4.
- **Quem não tem setor** (`links.department_id` nulo) entra na média da organização
  e fica fora do mapa. Por isso a soma dos setores pode não bater com a
  organização, e o tooltip do mapa deveria dizer isso.
- **Filtro trocado rápido chega fora de ordem** no front. Na integração, cancelar a
  requisição anterior (o `AbortSignal` do thunk).
- **Ambiente local:** a migration `92112d65a0b3_temporaria_local_navegacao_nao_commitar.py`
  (não versionada) cria uma segunda *head* no Alembic. Quem tiver o arquivo vê
  `alembic upgrade head` falhar por "multiple heads"; ela repete tabelas que a
  consolidação da sprint 3 já cria e pode ser apagada.
