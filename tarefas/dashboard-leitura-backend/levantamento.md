# Dashboard: o que o back precisa entregar

> Levantamento de 2026-11-02, feito a partir do front do dashboard já pronto sobre
> mock. Ainda não é spec: falta o card no ClickUp (renomeie a pasta para
> `<ID>-dashboard-leitura-backend` quando ele existir) e a calibragem P × T.

## Em uma frase

Quase tudo é **cálculo novo sobre tabelas que já existem, sem migration**. A
exceção é o **texto do Creed.ai para setor e organização**, que não tem onde ser
gravado hoje. Antes de começar, seis decisões de produto precisam de resposta.

## Onde está o front

Tudo em `creed-frontend/src/features/dashboards/`. O contrato que a tela espera é
o de `dashboardsApi.ts`: os tipos `UserDashboard` e `CompanyDashboard`, e o mock
logo abaixo deles, que faz o papel do back (recorta, monta as comparações e
calcula as variações). Integrar é trocar o corpo das duas funções de
`dashboardsApi` por `apiClient.get`; slice e telas não mudam.

O resumo das divergências front ↔ back está em
[`conventions/contrato-front-back.md`](../../conventions/contrato-front-back.md),
na linha "Dashboards".

## 1. A rota (o `dashboards/router.py` hoje é stub)

| Rota | Quem chama | Filtros |
|---|---|---|
| `GET /dashboards/me` | quem responde: os próprios resultados | `period` |
| `GET /dashboards/company` | admin ou gestor da organização | `period`, `department` **ou** `member_id` |

- Sem `period`, vale o mais recente. Sem `department` e sem `member_id`, vale a
  organização inteira.
- A resposta **devolve o recorte resolvido** (`period`, `department`,
  `member_id`). A tela monta os rótulos a partir dela, não do filtro que pediu.
- Quem pode chamar `/company` sai de `Link.role`, que já existe.

## 2. A base de tudo: a nota de cada pessoa

Uma consulta no `repository.py`, só com tabelas que já existem:

```
form_responses  (status = submitted, form_id = formulário do período)
  → links       (organization_id; department_id se o filtro pedir; id se for member_id)
  → answer      (form_response_id)
  → questions   (dimensao não nula)
  → question_options.value   ← o número de 1 a 5, gravado como TEXTO (P-040)
GROUP BY form_response_id, dimensao  →  AVG(CAST(value AS integer))
```

Depois, no `service.py`, para cada pessoa:

1. os 5 prismas com `calculate_all_prisms`, que
   [`prismas/utils.py`](../../../creed-backend/app/domains/prismas/utils.py) **já tem**;
2. a conversão de 1–5 para 0–100 (decisão 2, abaixo).

As notas por pessoa alimentam quase todos os cards:

| Dado na tela | O que o back faz | Muda o banco? |
|---|---|---|
| Radar e dimensões do recorte (`scores`, `dimensions`) | média das pessoas (decisão 3) | não |
| Comparações (`comparisons`): outro período, outro escopo (`scope`: um setor ou a empresa toda) ou os dois | o mesmo cálculo para cada referência | não |
| Variação por prisma (`variation`) | exibido − referência | não |
| Período padrão de comparação (`default_period`) | o período anterior ao exibido | não |
| Destaque e Oportunidade (resumo da empresa e marcações do Creed.ai) | maior e menor prisma do recorte | não |
| Alinhamento (`alignment`) | pessoas por faixa de nota e o nível, pela P-061 e pela P-062 | não |
| Mapa setores × prismas (`department_matrix`) | média de cada setor − média da organização, sempre a organização inteira no período pedido | não |
| Taxa de conclusão (`concluidos` / `convidados`) | respostas enviadas ÷ vínculos do recorte (decisão 5) | não |
| Listas de setores e funcionários do filtro | `departments` e `links` + `participants` da organização | não |

> **Princípio 1:** toda diferença, contagem e marcação acima é calculada no back.
> A tela só escolhe o que mostrar.

## 3. Decisões que travam o cálculo

São de produto. Viram premissas no
[`decisoes/premissas.md`](../../decisoes/premissas.md) e vão para a pauta da
cliente.

| # | Decisão | Proposta |
|---|---|---|
| 1 | O que é um **período** | Cada `Form` da organização é um período, com o `name` como rótulo ("2026/1") e a ordem pelo `created_at`. Não muda o banco. O `Form` não tem início e término, mas o dashboard não precisa deles. |
| 2 | A **escala** de 1–5 para 0–100 | `(média − 1) ÷ 4 × 100`, arredondado |
| 3 | A **nota de um grupo** | Média das notas de cada pessoa. A alternativa, média de todas as respostas juntas, só dá diferente quando alguém pula pergunta. |
| 4 | Pessoa com **dimensão faltando** | Hoje o `calculate_all_prisms` recusa. Proposta: a pessoa sai só dos prismas que dependem da dimensão que falta. |
| 5 | Quem conta como **convidado** | Vínculos ativos da organização no período (`links.start_at` / `end_at`) |
| 6 | O que **"Mais comum"** mede | Sem proposta: o mock usa a nota do meio, e o tooltip da tela descreve essa regra provisória |

Também abertas, do card de alinhamento: **P-061** (faixas: baixa até 40, média
de 40 a 70, alta acima de 70) e **P-062** (dividido quando baixa e alta passam de
30% cada; alinhado quando uma faixa só tem 70% ou mais).

Decisões técnicas, do time:

- **`member_id` é o id do vínculo** (`links.id`), não do participante: é a pessoa
  *naquela* organização.
- **Comparações:** devolver todas as combinações de uma vez (hoje 3 períodos ×
  6 setores, contando a organização inteira) ou só a escolhida, numa chamada à
  parte. Todas de uma vez é o que o front espera hoje e é o mais simples para
  organizações pequenas.
- **Setores = os cadastrados na organização** (`departments` com aquele
  `organization_id`), não os cinco do enum. Pode ser nenhum: o front mostra um
  aviso no mapa e esconde o filtro e a comparação por setor. Setor cadastrado
  sem resposta vem com `scores` e `difference` nulos.
- **Pessoa sem setor** (`links.department_id` nulo) entra na média da
  organização, mas em nenhuma linha do mapa: as linhas não somam a empresa.
- **O setor exibido também entra** nas opções de comparação por setor (Marketing contra Marketing de outro período).
- **A empresa toda (`scope: 'organization'`) também é uma referência:** compara um setor ou um funcionário com a média de todos. Só na visão da empresa.

## 4. O que não é simples: os textos do Creed.ai

| Texto | Situação |
|---|---|
| Análise e recomendação de **uma pessoa** (dashboard do usuário; funcionário na visão da empresa) | Já tem onde gravar: um `insight` por `form_response`. Falta o workflow do N8N existir (P-041). |
| **Um texto por prisma**, por pessoa | Cabe sem migration: `insight_prismas` liga texto e prisma, e o índice em `insights.form_response_id` **não** é único no banco. Mas contraria a **P-042** e o ADR-0010, que contam com um insight por resposta. Precisa rever a premissa, não o banco. |
| Marcações de Destaque e Oportunidade nos cards do Creed.ai | Cálculo (seção 2), sem IA |
| Análise de um **setor** ou da **organização** | **Exige mudar o banco ou a arquitetura.** Todo `insight` aponta para um `form_response_id` obrigatório, então não há onde gravar um texto sobre um grupo. |

Caminhos para o texto de grupo:

- **(a) Migration:** o insight passa a poder apontar para organização, setor e
  formulário, em vez de uma resposta.
- **(b) Gerar na hora, sem gravar:** vai contra o webhook assíncrono do ADR-0010
  e deixa a tela lenta e cara.
- **(c) Primeira versão sem ele:** texto só nas visões individuais; nas visões de
  grupo, só as marcações calculadas.

## Recomendação de corte

1. **Primeira entrega, só cálculo:** a rota, a consulta das notas por pessoa e
   tudo da tabela da seção 2. Entrega radar, dimensões, variação, comparações,
   alinhamento, mapa, participação e as marcações de destaque e oportunidade.
2. **Antes de começar:** as decisões 1 a 6 registradas como premissas e levadas
   à cliente.
3. **Creed.ai:** caminho (c) na primeira versão. O texto de grupo vira tarefa
   própria, com a migration (a) e a revisão da P-042.

## Riscos para quem implementar

- **`question_options.value` é texto.** A conversão para número precisa recusar
  alternativa fora de 1 a 5, como o `dimension_averages` já faz em Python.
- **Agregação no banco precisa de teste com banco real** (`conventions/testes.md`):
  mock de query não testa `GROUP BY`.
- **Trocas rápidas de filtro no front podem chegar fora de ordem.** Do lado do
  front, vale cancelar a requisição anterior na integração.
