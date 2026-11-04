# Dashboard: como o front se integra

> Análise de 2026-11-03, lendo o `creed-frontend` (branch `feat/3-ajustes-dashboard`).
> Par da [`analise.md`](analise.md), que cobre o back: lá está de onde sai cada
> número; aqui, o que muda no front para ler esses números de verdade, em que
> ordem, e o que a tela ainda não sabe mostrar. Ainda não é spec.

## Em três frases

1. **A arquitetura já está pronta para integrar.** O mock mora no
   `dashboardsApi.ts`, o slice já tem a máquina de quatro estados e as telas só
   leem o slice. Integrar é trocar o corpo de duas funções por `apiClient.get`,
   como a convenção prevê.
2. **Mas a troca não é só isso.** Três coisas que o mock nunca precisou fazer viram
   trabalho: cancelar a requisição velha quando o filtro muda, mostrar os estados
   vazios que o back real vai devolver e dizer qual empresa o `admin` está vendo.
3. **Os testes são o maior custo escondido.** Os testes das duas telas usam o mock
   do `dashboardsApi.ts` como dado. Se o mock sair do arquivo, eles quebram juntos;
   ele precisa virar fixture antes da troca.

## 1. O que muda e o que não muda

| Arquivo | Hoje | Na integração |
|---|---|---|
| `features/dashboards/dashboardsApi.ts` | tipos + mock (~400 linhas) que recorta, compara e calcula | tipos (com os ajustes da seção 3) + duas funções de uma linha. O mock sai para a fixture (seção 5) |
| `features/dashboards/dashboardsSlice.ts` | dois thunks; todo erro vira `erroAoCarregar` | passa o `signal` ao Api, ignora a rejeição por cancelamento e separa 404 (vazio) e 403 (sem acesso) do erro genérico |
| `lib/apiClient.ts` | `get(path)`, sem opções | `get(path, { signal })`: uma mudança compartilhada, de uma linha, que não quebra quem já usa |
| `CompanyDashboardView.tsx`, `UserDashboardView.tsx` | `useEffect` despacha a cada troca de filtro | o `useEffect` devolve `() => promise.abort()`; a tela ganha os estados vazio e sem acesso |
| `components/SummaryCards.tsx` | recebe `titulo` e `descricao` prontos; calcula a taxa de conclusão | título e descrição saem do i18n a partir do prisma (furo B); a taxa vem do back ou fica como está (seção 3, item E) |
| `components/ResultText.tsx` | supõe análise, recomendação e texto por prisma preenchidos | estado "análise ainda não disponível" (seção 4) |
| Os outros componentes (radar, variação, dimensões, alinhamento, mapa, filtros) | leem o tipo do contrato | **não mudam** |
| `features/responses/responsesSlice.ts` | pula a resposta objetiva no envio | apagar o `continue` (pré-requisito, [`analise.md`](analise.md) seção 1) |

O que já está certo e não precisa de nada:

- **Filtragem é do back.** A tela só pede `period`, `department` e `member_id`. Não
  existe `.filter` ou `.reduce` sobre o resultado.
- **A resposta traz o recorte resolvido** (`period`, `department`, `member_id`), e os
  rótulos saem dela, não do filtro pedido. Com o back real, isso evita rótulo errado
  quando o back escolhe o período mais recente.
- **O dado anterior fica na tela enquanto o novo chega** (o esqueleto só aparece na
  primeira carga). Com latência de rede de verdade, isso evita piscar a cada troca.
- **Rotas e destino por papel** (`/dashboard`, `/dashboard/company`,
  `lib/dashboardPath.ts`, P-054) já existem.

## 2. O caminho de uma requisição, depois da integração

```
CompanyDashboardView        useEffect([period, view])
  └─ dispatch(loadCompanyDashboard(filtros))  ─┐  cleanup: promise.abort()
dashboardsSlice                                │
  └─ thunk(filtros, { signal })                │
dashboardsApi.getCompanyDashboard(filtros, signal)
  └─ apiClient.get('/dashboards/company?period=…&department=…', { signal })
       → GET /api/v1/dashboards/company  (proxy do Vite → :8000)
  ← CompanyDashboard (JSON)                    │
slice: fulfilled → status 'ready', data        │
       rejected + meta.aborted → ignora  ◀─────┘
       rejected 404 → 'ready' vazio · 403 → sem acesso · resto → erro
```

**Por que cancelar.** Hoje, se a pessoa troca de Marketing para RH rápido, as duas
respostas do mock chegam em ordem, porque são `Promise.resolve`. Com rede, a de
Marketing pode chegar depois da de RH e sobrescrever a tela com o recorte errado. O
`createAsyncThunk` já fornece o `signal`; falta o `apiClient` repassá-lo ao `fetch`
e o slice não tratar o cancelamento como erro (`action.meta.aborted`).

**Montagem da query.** No molde do `organizationsApi.ts`: `URLSearchParams` só com os
filtros definidos. `department` vai pelo **valor** do enum (`Marketing`), que é o que
o back expõe.

## 3. Ajustes de contrato do lado do front

Os furos A–D da [`analise.md`](analise.md) (seção 4), mais dois que só aparecem lendo
as telas:

| # | Ajuste | No front |
|---|---|---|
| A | **A organização do `admin`** | `DashboardFilters` ganha `organization_id`. Proposta de rota: `/dashboard/company/:organizationId`, aberta de uma ação na tabela de empresas do painel do admin (`CompanyTable`). Sem parâmetro, vale a organização do vínculo, que para o `admin` é a da CREED (os mentorandos, P-055) |
| B | **Textos do resumo saem do i18n** | `DashboardHighlight` vira `{ prisma, value }`; `SummaryCards` monta título e descrição com `t()`, nos três idiomas |
| C | **Prismas** | nada: o front já usa os valores do enum `Prisma`; a tradução é do back |
| D | **Nomes em inglês** | renomear `concluidos`, `convidados`, `maisComum`, `analiseTexto`, `recomendacaoTexto`, `destaque`, `oportunidade` no tipo e nos componentes. Mecânico, mas toca vários arquivos e testes; melhor numa task só, antes de o back implementar |
| E | **Taxa de conclusão calculada na tela.** `SummaryCards` faz `concluidos / convidados × 100` | É um indicador derivado (princípio 1). Proposta: o back manda `completion_rate` junto dos dois números. É pequeno, mas evita duas regras de arredondamento |
| F | **Quem aparece em `members`** | Depende da decisão 8 da análise do back. Se só entrarem pessoas com resposta, o filtro de funcionário pode ficar vazio: o menu precisa de uma mensagem para isso |

## 4. Estados que a tela ainda não mostra

O mock sempre devolve uma organização cheia de dados. O back real vai devolver
estes casos, e hoje todos cairiam no alerta vermelho de erro ou quebrariam:

| Caso | O que o back faz (proposta) | O que a tela mostra |
|---|---|---|
| Organização sem nenhum período (nenhum formulário publicado) | 404 | vazio: "ainda não há questionário aplicado" |
| Respondente que ainda não enviou resposta no período | 404 | vazio, com o caminho para o questionário |
| Recorte sem resposta (setor sem ninguém que respondeu) | 200, notas nulas | vazio dentro da seção de prismas. **Muda o tipo:** `scores` e `dimensions` passam a aceitar nulo |
| Texto do Creed.ai ainda não gerado (caminho (c), ou N8N atrasado) | 200, listas vazias | "análise ainda não disponível" no `ResultText`, mantendo as marcações de destaque e oportunidade |
| `gestor` pedindo outra organização | 403 | sem acesso, sem botão de tentar de novo |
| Login desligado no ambiente local (P-054) | 401: as duas rotas exigem sessão | hoje o dashboard abre sem login; com o back, não. Vale registrar como premissa que dashboard exige login |

Pela `conventions/contrato-front-back.md`, quem traduz o status é o slice: 404 vira
estado de produto (vazio), não falha. Os textos novos entram nos três idiomas.

## 5. Testes: o mock vira fixture

Hoje `CompanyDashboardView.test.tsx` e `UserDashboardView.test.tsx` renderizam a tela
e esperam o dado do mock do `dashboardsApi.ts` ("Acme Inc.", "Walter White", as notas
de 2026/1). Quando as funções passarem a chamar a rede, esses testes ficam sem dado.

Proposta, numa task própria **antes** da troca:

1. Mover o mock (os construtores `buildResult`, `buildCompanySummary` e os dados)
   para `features/dashboards/dashboardsFixtures.ts`, sem mudar uma linha da lógica.
2. Nos testes das telas, `vi.spyOn(dashboardsApi, 'getCompanyDashboard')` devolvendo
   a fixture. O `UserDashboardView.test.tsx` já faz isso no caso de erro, então o
   padrão existe.
3. Enquanto o back não serve, as funções do Api chamam a fixture. Assim a troca
   final mexe em duas linhas.

A partir daí, cada camada testa o que é dela (`conventions/testes.md`):

| Camada | Teste novo |
|---|---|
| `dashboardsApi` | `stubFetch` (de `src/test/stubFetch.ts`): monta a URL com só os filtros definidos e repassa o `signal`. No molde de `formsApi.test.ts` |
| `dashboardsSlice` | rejeição por cancelamento não vira erro; 404 vira vazio; 403 vira sem acesso |
| Telas | os estados da seção 4, com a fixture |
| Fixture | continua sendo o dado sintético das telas (nunca dado real, `conventions/testes.md`) |

**A fixture não substitui o teste de contrato.** Se o back mudar um campo, o teste
das telas continua verde. Quem segura isso é conferir o OpenAPI do back
(`/docs`) contra os tipos do `dashboardsApi.ts` na review de cada passo.

## 6. Ordem, casada com a do back

| # (back) | Front | Tamanho |
|---|---|---|
| 1 | apagar o `continue` das objetivas no `responsesSlice.ts`, assim que a listagem trouxer `options` | P |
| — | **mock → fixture** (seção 5). Não depende do back e pode começar já | P |
| 3 | **ajustes de contrato A–F** no tipo, nos componentes e no i18n, ainda sobre a fixture | M |
| — | **`signal` no `apiClient` e cancelamento no slice e nas telas** | P |
| — | **estados da seção 4**, sobre a fixture | M |
| 5 | **`getUserDashboard` real.** O `getCompanyDashboard` continua na fixture: as duas funções são independentes | P |
| 6 | **`getCompanyDashboard` real**, com a rota do `admin` (item A) | P–M |

Quase todo o trabalho do front vem **antes** do back e não depende dele. A troca
final, nos passos 5 e 6, fica pequena de propósito: quando a rota do back sair, o
front já está esperando por ela.

## 7. Riscos

- **O tipo é a única ponte.** O front não gera tipos do OpenAPI; o
  `dashboardsApi.ts` é escrito à mão. Divergência de nome ou de nulidade só aparece
  em tempo de execução. Na review dos passos 5 e 6, conferir campo a campo.
- **Payload grande no `/company`.** Todas as comparações vêm de uma vez (3 períodos ×
  6 escopos, cada uma com prismas e dimensões). Para organizações do tamanho do
  projeto é pouco, mas se crescer, a alternativa é buscar a comparação escolhida
  numa chamada à parte, e isso muda o `OverviewSection`.
- **Rótulos que dependem de `members`.** `viewName` procura o nome do funcionário na
  lista `members` da resposta. Se o back não incluir a pessoa exibida na lista
  (decisão 8), o rótulo cai no nome da organização sem aviso.
- **`organization_name` no cabeçalho** vem da resposta: em erro ou 403, o cabeçalho
  fica vazio. Já é assim hoje, mas com o back real esses casos passam a acontecer.
