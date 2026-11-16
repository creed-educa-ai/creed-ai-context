# Tasks — 1dfej6fwdaj · CREED - 80 · Esteira de insights por IA

Spec: [`spec.md`](spec.md)

Decomposição aprovada pelo Luís em 2026-11-14, com três decisões tomadas antes:

1. **O N8N é o da AWS, sem cópia local.** O workflow é montado direto no N8N da EC2, com
   a credencial do Bedrock que já está lá. O serviço `n8n` do compose local fica como
   está, sem uso pela esteira.
2. **Não há integração entre o back local e a AWS.** O back se testa sozinho, com um N8N
   falso, e a ida e a volta reais são testadas depois da publicação (task 12).
3. **As pontas se validam antes da publicação por um kit de contrato** (task 1), que os
   dois lados usam como verdade única.

## Branches

Uma branch e um PR por subtarefa do [épico CREED - 80](https://app.clickup.com/t/1dfej6fwdaj),
com o número da subtarefa como ID, no padrão do board (`feat/691-empresa-pendente`). As
tasks do `creed-backend` vão **empilhadas** (modo AGES III, item 5): cada uma sai da
anterior depois do commit dela, e o PR aponta para a branch de baixo até ela entrar na
`dev`. As tasks de N8N (6, 8 e 15) e o dossiê (7) mexem só em `docker/n8n/`, então saem
da `dev` e correm em paralelo com o back. Os nomes abaixo são proposta: quem pega a
subtarefa pode ajustar o contexto, nunca o número.

| Subtarefa | Task | Repo | Branch | Sai de |
|---|---|---|---|---|
| [801](https://app.clickup.com/t/1dfej6fwdak) | 1 | back | `feat/801-contrato-da-esteira` | `dev` |
| [802](https://app.clickup.com/t/1dfej6fwdam) | 2 | back | `feat/802-envio-grava-pedido` | `feat/801-contrato-da-esteira` |
| [803](https://app.clickup.com/t/1dfej6fwdan) | 3 | back | `feat/803-pedido-e-client-n8n` | `feat/802-envio-grava-pedido` |
| [804](https://app.clickup.com/t/1dfej6fwdaq) | 4 | back | `feat/804-worker-de-insights` | `feat/803-pedido-e-client-n8n` |
| [805](https://app.clickup.com/t/1dfej6fwdar) | 5 | back | `feat/805-volta-do-n8n` | `feat/802-envio-grava-pedido` |
| [806](https://app.clickup.com/t/1dfej6fwdau) | 6 | back (`docker/n8n/`) | `feat/806-workflow-insight-v1` | `dev`, depois da 801 |
| [807](https://app.clickup.com/t/1dfej6fwdav) | 7 | back (`docker/n8n/`) | `docs/807-dossie-teorico` | `dev` |
| [808](https://app.clickup.com/t/1dfej6fwdaw) | 8 | back (`docker/n8n/`) | `feat/808-prompts-e-avaliacao` | `feat/806-workflow-insight-v1` |
| [809](https://app.clickup.com/t/1dfej6fwdax) | 9 | infra | `feat/809-worker-em-producao` | `dev` |
| [8010](https://app.clickup.com/t/1dfej6fwday) | 10 | back | `feat/8010-dashboard-le-insight` | `dev`, depois da 805 e da CREED - 74 |
| [8011](https://app.clickup.com/t/1dfej6fwdaz) | 11 | front | `feat/8011-estados-do-creed-ai` | `dev` |
| [8012](https://app.clickup.com/t/1dfej6fwdb0) | 12 | infra | `docs/8012-roteiro-da-esteira` | `dev` |
| [8013](https://app.clickup.com/t/1dfej6fwdb1) | 13 | back | `feat/8013-insight-da-empresa` | `dev`, depois da 804 e da CREED - 74 |
| [8014](https://app.clickup.com/t/1dfej6fwdb2) | 14 | back | `feat/8014-dashboard-da-empresa` | `feat/8013-insight-da-empresa` |
| [8015](https://app.clickup.com/t/1dfej6fwdb3) | 15 | back (`docker/n8n/`) | `feat/8015-ramo-da-empresa` | `dev`, depois da 808 |
| [8016](https://app.clickup.com/t/1dfej6fwdb4) | 16 | front | `feat/8016-texto-da-empresa` | `dev`, depois da 8011 |

## Progresso

- [x] 1 — Kit do contrato · `creed-backend` (2026-11-14; PR #77, base `dev`)
- [x] 2 — `insights` com status, e o envio grava o pedido · `creed-backend` (2026-11-15; PR #78, empilhado no #77; migration temporária testada e apagada, ajustes na seção Banco do PR)
- [x] 3 — Payload individual e client do N8N · `creed-backend` (2026-11-15; PR #79, empilhado no #78, commit `074c668`; o desempate foi para `prismas.service.highest_and_lowest`)
- [x] 4 — O worker · `creed-backend` (2026-11-15; PR #80, empilhado no #79, commit `aba8b2a` e `5e2d3ea` da revisão da pilha; o teto vale com trava `pg_advisory_xact_lock`, e o `attempt` do pedido passou a ser o `attempts` já somado na reivindicação, como manda o ADR)
- [x] 5 — Volta: callback assinado e leitura de status · `creed-backend` (2026-11-15; PR #81, empilhado no #80, base `feat/804-worker-de-insights`; o `complete` reaproveita `_retry_or_fail`, `get_for_update` e `database_now` da 804, então a branch da 805 sai da 804 e não da 802 como diz a tabela acima; `RUN_POSTGRES_TESTS=1` nos testes de insights: 23 passed, com os 3 novos; sem a trava do `get_for_update`, o do "primeiro `done` vence" falha)
- [ ] 6 — Workflow `insight-v1` no N8N da AWS · N8N (registro em `creed-backend`)
- [ ] 7 — Dossiê v1 · time (registro em `creed-backend`)
- [ ] 8 — Prompts v1 e avaliação · N8N (registro em `creed-backend`)
- [ ] 9 — Produção do back · `creed-infrastructure`
- [x] 10 — Dashboards leem o insight individual · `creed-backend` (2026-11-15; PR #83, empilhado no #82, base `feat/8013-insight-da-empresa`, commit `c3e69a1`; o commit também corrige três erros antigos do hook do mypy em `test_repository.py` e `test_repository_postgres.py` do dashboards, que barravam o commit; pedida pela 14, que depende dela e a encontrou desmarcada, então a branch da 8010 sai da 8013 e não da `dev` como diz a tabela acima, e a 14 sai da 8010; o combinado dos dois campos novos com o Leo foi dado como feito pelo Luís; `/company` e o retrato seguem em `none` até a 14; suíte inteira com `RUN_POSTGRES_TESTS=1`: 1599 passed, 1 skipped)
- [x] 11 — Front: estados do Creed.ai · `creed-frontend` (2026-11-15; creed-frontend#74, base `dev`, commit `c1b462b`; mergear depois da pilha do back, #77 a #84, que traz os campos e a rota que ela lê; decisão do Luís: a repetição da busca mora num hook da tela (`src/hooks/useRepeatWhile.ts`), e não num thunk que repete no slice como dizia a spec, e o mesmo hook serve à confirmação (5 s) e à task 16; o `CreedSummary` continua em `dashboardsApi.ts`, onde já morava, e não em `types/api.ts`; o id da resposta vai da revisão à confirmação pelo `state` da rota; P-095 para o `failed` na confirmação; `npm run check`: lint, prettier e tipos verdes, e 649 passed na segunda rodada da suíte, porque a primeira teve 3 timeouts de 5 s em arquivos que o diff não toca e que passam isolados; conferido no navegador em 375, 768 e 800 px, com as rotas respondidas pela fixture)
- [ ] 12 — Integração na AWS, depois da publicação · `creed-infrastructure` (roteiro executado por uma pessoa)
- [x] 13 — Insight da empresa: gatilho e payload · `creed-backend` (2026-11-15; PR #82, empilhado no #81, base `feat/805-volta-do-n8n`; decisões do Luís: trava por período (`pg_advisory_xact_lock(8013, hashtext(form_id))`) antes de contar, e o piso e a espera como constantes da P-089 no service, sem `INSIGHT_ORG_*` em `config.py`; o `claim_due` passou a pegar o insight da empresa; `RUN_POSTGRES_TESTS=1`: 31 passed nos de insights, e sem a trava o caso de 3 enviadas + 2 simultâneos fica sem pedido)
- [x] 14 — Insight da empresa: leitura e exclusão · `creed-backend` (2026-11-15; PR #84, empilhado no #83, base `feat/8010-dashboard-le-insight`, commit `9045c48`; "mais recente" é o último pedido (`created_at`), em duas consultas no repository (o último pronto, e senão o último de todos); a E-6 apaga só os insights da empresa, por organização, logo depois dos das respostas; sem a chamada nova, 3 testes da E-6 quebram com o insight da empresa ainda apontando para o questionário; suíte inteira com `RUN_POSTGRES_TESTS=1`: 1612 passed, 1 skipped)
- [ ] 15 — Ramo da empresa no N8N · N8N (registro em `creed-backend`)
- [x] 16 — Front: texto da empresa · `creed-frontend` (2026-11-15; creed-frontend#75, empilhado no #74, base `feat/8011-estados-do-creed-ai`, commit `6367ffb`; a visão da empresa usa o `useRepeatWhile` da 11 com o `loadCompanyDashboard`, que já repassava o `signal` e ignorava o cancelado, então o slice e o `ResultText` não mudaram; a fixture da empresa passou a mandar `none` sem texto no recorte por setor ou pessoa, como o back da 8014, e o teste que esperava o texto de Marketing virou o contrário; a administradora é coberta pela tela dela, com `organization_id` na busca repetida; `AdminDashboardView.test.tsx` e a fixture da empresa tinham trechos da 11 e da 16, separados na hora de subir, com a suíte rodada no estado só da 11; `npm run check`: lint, prettier e tipos verdes, 656 passed; sem o hook, os 4 testes de repetição quebram; conferido no navegador em 800 e 375 px)

Marque aqui ao concluir cada task (`workflows/tasks-to-code.md`).

## Dependências

```
Começo, em paralelo:  1 (kit)   ·   7 (dossiê)
Back:                 2 → 3 → 4    ·    2 → 5
N8N:                  1 → 6 → 8 (com o 7)
Produção:             4 + 5 → 9 → 12, parte 1 (com 6 e 8 prontos)
Dashboard:            5 + feat/4-dashboard → 10 → 11
Empresa:              4 + feat/4-dashboard → 13 → 14 → 16
                      8 + 13 → 15 → 12, parte 2
```

| Task | Depende de | Pode correr em paralelo com |
|---|---|---|
| 1 | — | 7 |
| 2 | 1 | 6, 7 |
| 3 | 1, 2 | 5, 6, 7 |
| 4 | 3 | 5, 6, 7, 8 |
| 5 | 1, 2 | 3, 4, 6, 7 |
| 6 | 1 | 2 a 5, 7 |
| 7 | inventário da bibliografia | 1 a 6 |
| 8 | 6, 7 | 4, 5, 9 |
| 9 | 4, 5 | 8, 10 |
| 10 | 5 e a `feat/4-dashboard` na `dev` | 8, 9 |
| 11 | 10 | 12 |
| 12 | parte 1: 6, 8 e 9 publicados; parte 2: 13 a 16 publicados | — |
| 13 | 4 e a `feat/4-dashboard` na `dev` | 10, 11 |
| 14 | 10, 13 | 15 |
| 15 | 8, 13 | 14, 16 |
| 16 | 11, 14 | 15 |

## Por que dezesseis, e nesta ordem

- **O kit vem primeiro (task 1)** porque é ele que deixa o N8N começar sem esperar o
  back. A task 6 só precisa dos exemplos e do vetor de assinatura, não de código
  rodando.
- **O individual funciona sozinho até a task 12.** A empresa (13 a 16) fica no fim,
  como decidido na spec.
- **A migration é uma só, na task 2.** Ela já traz as colunas que o insight da empresa
  usa, e o individual também as preenche. O ADR-0009 consolida uma migration, não duas.
- **A ida virou duas tasks (3 e 4).** Juntas não caberiam num dia. A 3 se testa sem
  banco; a 4 é o loop e o teste de concorrência.
- **O workflow virou três tasks (6, 8 e 15).** A 6 é a mecânica: entrada, chamada ao
  Bedrock, assinatura e volta, com prompt provisório. A 8 é o conteúdo: prompts,
  dossiê no lugar e avaliação. A 15 é o ramo da empresa.
- **O dossiê (7) é trabalho de gente, não de código**, e mesmo assim tem critério de
  aceite. Ele corre em paralelo com as tasks 1 a 6.
- **A task 12 não muda código.** É o roteiro que uma pessoa executa em produção. Fica
  no `creed-infrastructure`, ao lado do README da EC2, e tem duas partes: a do
  individual, logo depois da publicação, e a da empresa, quando 13 a 16 estiverem
  publicadas.

## Como as pontas se validam antes da publicação

O kit da task 1 mora em `creed-backend/docker/n8n/contrato/`:

| Arquivo | Quem usa | Para quê |
|---|---|---|
| `ida.schema.json`, `volta.schema.json` | back (gera) e N8N (lê) | os contratos, gerados dos modelos Pydantic |
| `exemplo-ida-individual.json` | back (task 3) e N8N (task 6) | o back confere que o payload que monta tem essa forma; o N8N roda com ele fixado |
| `exemplo-volta-done.json`, `exemplo-volta-failed.json` | back (task 5) | a rota de volta aceita os dois, assinados |
| `vetor-hmac.json` | back (tasks 1 e 5) e N8N (task 6) | os dois lados precisam chegar à mesma assinatura |
| `saida-n8n.json` | N8N (task 6, grava) e back (testa) | o corpo que o N8N produziu de verdade, validado pelo schema do back |

Um teste do back falha se os schemas commitados divergirem dos modelos Pydantic. Quem
muda o contrato regera os arquivos, e o diff mostra a mudança aos dois lados.

## Onde mora cada coisa, e por quê

`tests/test_arquitetura.py` só deixa um domínio importar outro pelo `service` ou pelo
`dependencies` dele, e a leitura por JOIN precisa estar declarada. O que entra:

| Domínio | Passa a | Por quê | Task |
|---|---|---|---|
| `responses` | compor com o `InsightService` | o envio grava o pedido na mesma transação | 2 |
| `insights` | compor com o `PrismaService` | as notas do payload são as do cálculo | 3 |
| `insights` | ler `form_responses`, `answer`, `questions` e `form` por JOIN | respostas abertas, organização e período | 2, 3 |
| `dashboards` | ler `insights` por JOIN | o texto no `creed_summary` | 10, 14 |
| `insights` | compor com o `DashboardService` | os números agregados do payload da empresa | 13 |
| `users` | usar o `InsightService` também na exclusão de empresa | os insights da empresa saem antes dos questionários | 14 |

`dashboards` **nunca** importa `insights.service`. Se importasse, o ciclo
`insights → dashboards → insights` voltaria.

## O que ficou fora da lista

- N8N local, modo simulado, túnel e qualquer chamada entre o back local e a AWS.
- Mudanças no serviço `n8n` da EC2: compose, variáveis, a credencial do Bedrock e
  `N8N_CONCURRENCY_PRODUCTION_LIMIT`. Quem regula o ritmo é só o `INSIGHT_MAX_IN_FLIGHT`
  do worker.
- Usuário IAM por modelo. Fica a credencial que já existe no N8N.
