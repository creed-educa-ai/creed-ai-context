# ADR-0010 — Esteira de IA: o envio grava o pedido, um worker dispara

- **Status:** Proposto
- **Data:** 2026-10-24
- **Decidem:** time CREED
- **Relacionado:** [`context/arquitetura.md`](../../context/arquitetura.md) → "Esteira de IA
  (N8N)" · [`playbooks/integrar-servico-externo.md`](../../playbooks/integrar-servico-externo.md)
  · [ADR-0004](0004-camadas-do-backend.md) · [ADR-0007](0007-amplify-e-ec2-no-lugar-do-eks.md)
  · [ADR-0009](0009-migration-consolidada-por-sprint.md) · tarefa do workflow:
  [CREED-55 — Desenvolvimento da esteira do n8n](https://app.clickup.com/t/86e3m2qft)
  · spec ponta a ponta: [`tarefas/1dfej6fwdaj-esteira-de-insights/spec.md`](../../tarefas/1dfej6fwdaj-esteira-de-insights/spec.md)

> **Quando vale.** Este ADR é implementado **na tarefa que ligar o N8N ao back**, e só
> nela. Nada do que existe hoje muda por causa dele: a CREED-52 (`Insight`), o envio de
> resposta, o `deploy.sh` e os dois compose continuam como estão até essa tarefa
> começar. Tudo o que está escrito aqui como mudança ("ganha", "passa a", "entra") é
> trabalho dessa tarefa.
>
> Vira **Aceito** quando o time confirmar em reunião interna. As premissas P-041 a P-044
> (no fim deste documento) não bloqueiam o aceite: o mecanismo não muda com elas, só o
> que a tela mostra e o que o payload leva.
>
> *Emendado em 2026-11-14:* segue **Proposto**. A spec da esteira de insights ligou as
> três pontas (back, N8N com Bedrock e volta) e mudou seis pontos deste texto, sem mexer
> no mecanismo. Na decomposição em tasks, no mesmo dia, entrou um sétimo: o N8N é o da
> AWS, sem cópia local (A7). As mudanças estão no
> [adendo](#adendo--a-esteira-de-ponta-a-ponta-2026-11-14), e cada item afetado tem um
> aviso. O aceite em reunião interna vale para o texto **com o adendo**.

## Contexto

A cada resposta de formulário enviada, o back vai mandar as respostas e o resultado do
cálculo para a esteira do N8N. A esteira chama o Bedrock e devolve o insight para o
respondente. A `arquitetura.md` já diz que a esteira é assíncrona ("o backend dispara e
responde; o resultado volta por webhook"), mas não diz **como o disparo sobrevive a uma
falha**, nem o que acontece quando muitas pessoas enviam ao mesmo tempo.

A preocupação inicial era que o webhook do N8N atendesse uma requisição por vez. **A
documentação do N8N diz o contrário:** no modo `regular`, o que roda na EC2, ele não
limita as execuções simultâneas. `N8N_CONCURRENCY_PRODUCTION_LIMIT` vem com `-1`
(desligado), e quando é ligado, o que passa do limite entra numa fila FIFO interna. O
risco real é o oposto: um pico de envios vira o mesmo número de execuções paralelas
num container com `mem_limit: 768m`, numa instância que também roda o back e o
Keycloak, e o mesmo número de chamadas ao Bedrock, que tem cota por minuto e responde
com *throttling*. **O gargalo é o Bedrock e a EC2, não o webhook.**

Disparar o N8N de dentro da requisição de envio falha de quatro jeitos:

1. **N8N fora do ar ou lento:** o POST espera até `N8N_TIMEOUT_SECONDS` (10 s), e quem
   enviou espera junto.
2. **Disparo depois do commit e o processo morre no meio:** o insight fica pendente para
   sempre, e nada sabe que precisa reenviar.
3. **Disparo antes do commit e o commit falha:** o N8N processa uma resposta que não
   existe, e o callback encontra 404.
4. **`BackgroundTasks` do FastAPI:** a tarefa vive na memória do processo. Todo deploy
   recria o container (`deploy.sh`, passo 3), e o que estava na fila some sem
   retentativa.

Cinco fatos delimitam a escolha:

- **O estado mora no RDS** (`arquitetura.md` → "Fronteiras"). O status do insight
  precisa estar no banco de qualquer jeito, porque a tela pergunta por ele.
- **Não há dono de infra** (ADR-0007, pendências). Fila gerenciada é um componente a
  mais, com credencial e configuração que ninguém opera.
- **O compose de produção é aplicado à mão** (`creed-infrastructure/ec2/README.md`), e
  o local precisa ter os mesmos componentes.
- **`tests/test_arquitetura.py` proíbe `.commit()` fora de `get_db`**, e um processo que
  não atende requisição HTTP não tem `get_db`.
- **O model `Insight` da CREED-52 (em review)** tem `content` `not null`, e não tem
  status. Um insight que ainda não foi gerado não cabe nele.

## Decisão

**O envio grava o pedido de insight na mesma transação da resposta, e um worker
dedicado dispara a esteira no ritmo que o Bedrock aguenta.** É o padrão *transactional
outbox*, com a tabela `insights` fazendo papel de fila. Nenhuma peça nova na AWS.

```
POST /form-responses/{id}/submit
  └─ mesma transação: FormResponse SUBMITTED + Insight(status=pending)
  └─ 200 com o resultado do cálculo                     ← quem enviou está livre

insight-worker (a cada INSIGHT_WORKER_INTERVAL_SECONDS)
  ├─ só segue se os dispatched estiverem abaixo de INSIGHT_MAX_IN_FLIGHT
  ├─ reivindica até INSIGHT_WORKER_BATCH_SIZE pending vencidos (FOR UPDATE SKIP LOCKED)
  ├─ marca dispatched, attempts + 1, dispatched_at, e commita
  ├─ POST ao N8N, um por insight
  │    falhou → pending com next_attempt_at em backoff; passou de INSIGHT_MAX_ATTEMPTS → failed
  └─ varredura: dispatched há mais de INSIGHT_DISPATCH_TIMEOUT_SECONDS → volta a pending

N8N: Webhook (Respond: Immediately) → Bedrock (Retry On Fail) → POST callback
     error workflow → POST callback com status=failed

POST /api/v1/insights/callback      (assinatura conferida; idempotente por insight_id)
GET  /api/v1/form-responses/{id}/insight   → {status, content, created_at}, com polling no front
```

1. **O envio grava, não dispara.** `submit_form_response` cria o `Insight` da resposta
   com `status = pending` e `content` vazio, na mesma transação que marca a resposta
   como `submitted`. Como o `get_db` commita antes de a resposta HTTP sair, ou as duas
   coisas ficam gravadas ou nenhuma fica. Nenhuma chamada ao N8N acontece no caminho
   da requisição.

   > **Emendado em 2026-11-14:** o envio também agenda o insight da empresa quando o
   > período chega a 5 respostas enviadas ([adendo, A2](#a2--o-insight-da-empresa-entra-itens-1-2-e-3)).

2. **O status mora no `Insight`.** A tabela `insights` ganha:

   | Coluna | Tipo | Para quê |
   |---|---|---|
   | `status` | enum `InsightStatus`: `pending`, `dispatched`, `done`, `failed` · `not null`, default `pending` | o estado que o worker e a tela leem |
   | `attempts` | `int` `not null`, default `0` | backoff e limite de tentativas |
   | `next_attempt_at` | `timestamptz` `not null`, default `now()` | quando o pending pode ser despachado |
   | `dispatched_at` | `timestamptz` nulável | a varredura de quem sumiu |
   | `last_error` | `text` nulável | diagnóstico: o motivo da última falha |

   `content` passa a **nulável**, e só pode ficar vazio enquanto o status não for `done`.
   A regra é do service; um `CHECK ((status = 'done') = (content IS NOT NULL))` na
   consolidação protege o dado também. `form_response_id` ganha **`unique`**: uma
   resposta enviada, um insight.

   > 🟡 **Premissa P-042** — cada resposta enviada gera um insight individual, uma vez
   > só; não há gerar de novo. Confirmar na próxima reunião.

   O `unique` não atrapalha o insight de organização ([C24], `form_response_id` nulo):
   no Postgres, `NULL` não colide com `NULL`.

   > **Emendado em 2026-11-14:** `content` vira `jsonb`, e entram `model_id`,
   > `prompt_version` e `completed_at` ([adendo, A1](#a1--content-vira-jsonb-item-2)).
   > Também entram `organization_id` e `form_id`, e `form_response_id` vira nulável
   > ([adendo, A2](#a2--o-insight-da-empresa-entra-itens-1-2-e-3)).

3. **Um worker dedicado, em container próprio.** O serviço `insight-worker` entra nos
   **dois** compose (o local do `creed-backend` e o de produção da EC2), com a mesma
   imagem do back e outro comando: `python -m app.workers.insights`. O loop é o do
   diagrama acima. Os valores iniciais ficam em `settings`, porque só a cota do
   Bedrock vai dizer os certos:

   | Setting | Inicial |
   |---|---|
   | `INSIGHT_WORKER_INTERVAL_SECONDS` | `3` |
   | `INSIGHT_WORKER_BATCH_SIZE` | `5` |
   | `INSIGHT_MAX_IN_FLIGHT` | `5` |
   | `INSIGHT_MAX_ATTEMPTS` | `5` |
   | `INSIGHT_DISPATCH_TIMEOUT_SECONDS` | `600` |

   O backoff dobra a cada tentativa, a partir de 30 s (30 s, 1 min, 2 min, 4 min).
   `SKIP LOCKED` faz dois workers, ou dois ciclos sobrepostos, nunca pegarem a mesma
   linha.

4. **O payload é montado na hora do disparo**, a partir do `form_response_id`, e não
   guardado como cópia no envio. Isso respeita o [C7] (nenhum resultado persistido) e
   não muda nada na prática: a resposta enviada não muda mais (P-032). O payload leva
   **identificadores opacos (UUID), nunca nome nem e-mail** de quem respondeu: as
   respostas vão para o Bedrock, e a pessoa não precisa ir junto.

   > 🟡 **Premissa P-041** — o contrato com o workflow tem, por enquanto, só a
   > correlação: `insight_id` e `form_response_id` na ida; `insight_id`, `status`
   > (`done`/`failed`) e `content` na volta. Confirmar com quem montar o workflow.

   > **Emendado em 2026-11-14:** o contrato é o `insight-v1`, e a P-087 substitui a
   > P-041 ([adendo, A3](#a3--o-contrato-insight-v1-substitui-a-p-041-item-4)).

5. **O N8N recebe e devolve, sem fazer a fila.** O nó Webhook usa `Respond:
   Immediately`, e o POST do worker volta em milissegundos. `N8N_CONCURRENCY_PRODUCTION_LIMIT`
   fica ligado nos dois compose, com valor maior ou igual a `INSIGHT_MAX_IN_FLIGHT`: quem
   regula o ritmo é o back, e o N8N é a válvula de segurança. O nó do Bedrock usa *Retry
   On Fail* para o throttling, e um *error workflow* avisa a falha pelo mesmo callback,
   com `status = failed`.

   > **Emendado em 2026-11-14:** o serviço `n8n` não muda, e a válvula
   > `N8N_CONCURRENCY_PRODUCTION_LIMIT` não é ligada. Quem regula o ritmo é só o
   > `INSIGHT_MAX_IN_FLIGHT` ([adendo, A7](#a7--o-n8n-é-o-da-aws-sem-cópia-local-itens-3-e-5-e-pendências)).

6. **O callback entra pelo domínio `insights`.** A rota `POST /api/v1/insights/callback`
   fica em `insights/router.py`, e a assinatura é conferida por um `Depends` em
   `app/core/security.py`, com `hmac.compare_digest` e o `N8N_CALLBACK_SECRET` (o
   playbook, "O caminho de volta"). As regras de idempotência:

   | Chega | Com o insight em | Faz |
   |---|---|---|
   | `done` | `pending` ou `dispatched` | grava `content`, status `done` (inclusive o callback atrasado de um insight que a varredura já devolveu a `pending`) |
   | `done` ou `failed` | `done` | nada; responde 200 (o primeiro `done` vence) |
   | `failed` | `pending` ou `dispatched` | a mesma regra de falha do disparo: backoff, ou `failed` no limite |
   | qualquer um | inexistente | 404 definido e testado |

   > **Emendado em 2026-11-14:** a ida passa a levar token, e a assinatura da volta passa
   > a incluir um timestamp ([adendo, A4](#a4--a-ida-leva-token-e-a-volta-hmac-com-timestamp-itens-5-e-6)).
   > A tabela acima ganha três linhas ([adendo, A5](#a5--a-tabela-de-idempotência-ganha-três-linhas-item-6)).
   >
   > **Emendado em 2026-11-16:** a volta traz o `attempt`, e o `failed` só vale para a
   > tentativa que ainda espera a volta ([adendo, A8](#a8--a-volta-devolve-o-attempt-item-6-e-a5)).

7. **A tela pergunta, o back responde.** `GET /api/v1/form-responses/{form_response_id}/insight`
   fica em `insights/router.py`, rota aninhada como a de `links`
   (`/organizations/{organization_id}/links`). O front vê três estados: `pending` (que
   inclui o `dispatched`, que é detalhe do worker), `done` e `failed`. Ele faz polling
   com teto, pelo slice da feature, sem SSE nem WebSocket.

   > 🟡 **Premissa P-043** — só o próprio respondente lê o seu insight individual, com
   > a conferência de dono das respostas. Confirmar na próxima reunião.

   > **Emendado em 2026-11-14:** o texto aparece no dashboard, e a rota fica para o
   > polling. A P-086 revê a P-043: a administradora da CREED lê o insight dos
   > mentorandos, e a gestora lê só o agregado da empresa
   > ([adendo, A6](#a6--quem-lê-e-onde-item-7)).

   > 🟡 **Premissa P-044** — esgotadas as tentativas, a tela diz que o insight não ficou
   > disponível, sem "tentar de novo", e o resultado do cálculo continua na tela.
   > Confirmar na próxima reunião.

## Como isto encaixa nas regras do back

| Regra | Como fica |
|---|---|
| Commit só no `get_db` (`test_commit_so_no_get_db`) | `app/core/database.py` ganha uma unidade de trabalho para quem não é requisição, com o mesmo commit/rollback do `get_db`. O worker abre uma por passo (reivindicar, depois registrar o resultado). O commit continua num arquivo só, e a mensagem do teste passa a citá-la |
| Domínio não importa domínio (`test_dominio_nao_importa_dominio`) | `responses` compõe com o `InsightService` para criar o pending no envio. Fica declarado em `COMPOE_COM_SERVICE_DE` |
| Ler respostas para o payload | O repository de `insights` lê `form_responses` e `answer` por JOIN, **só leitura**, declarado em `LEITURA_ENTRE_DOMINIOS` (ADR-0004, item 4). Assim não há ciclo: `responses.service → insights.service`, e `insights` só enxerga os models de `responses` |
| Router fino | O worker é porta de entrada, como o router: abre a unidade de trabalho, chama o `InsightService` e mais nada. A regra (backoff, limite, varredura) fica no `service.py` |
| Serviço externo | `app/external_services/n8n/` com `client.py`, `schemas.py` e `exceptions.py`, como manda o playbook. É o primeiro a usar `N8N_WEBHOOK_URL`, `N8N_CALLBACK_SECRET` e `N8N_TIMEOUT_SECONDS` |
| Pacote novo em `app/` | `app/workers/` é irmão de `domains/` e de `external_services/`. Este ADR é o que o autoriza: "não inventar padrão" |
| Migration (ADR-0009) | O PR muda `models.py`, e a seção "Banco" registra: `content` vira nulável, o enum e as colunas novas, `unique` em `form_response_id`, o `CHECK`, e "linha existente recebe `status = done`". A migration sai na consolidação |

## Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| **Disparar dentro da requisição** (`await` com timeout) | Os quatro modos de falha do Contexto. Quem enviou espera o N8N, e falha entre commit e disparo some |
| **`BackgroundTasks` do FastAPI** | A fila mora na memória do processo e some no deploy. Sem retentativa e sem ninguém saber que faltou |
| **SQS** | O status continua precisando estar no banco, porque a tela lê de lá. A fila vira uma segunda fonte de verdade, e gravar no banco e publicar na fila **não é atômico**, que é exatamente o problema que o outbox resolve. Ainda soma IAM e credencial na EC2, e um emulador no local para manter a paridade |
| **Redis (lista ou stream)** | O mesmo problema da dupla gravação, com um container a mais e persistência a configurar para não perder mensagem no restart. (Service Bus é da Azure; o equivalente na AWS é o SQS, acima) |
| **Envio em lote ao N8N** | Mistura respondentes no mesmo prompt: risco de LGPD e de o LLM trocar o insight de uma pessoa com o de outra. Também atrasa o primeiro do lote. O worker pega em lote, mas **envia um por resposta** |
| **N8N em queue mode** (Redis + workers do N8N) | Escala a execução do N8N, não a durabilidade do disparo. Numa EC2 única, worker a mais não traz CPU nova. Volta à mesa se o N8N saturar a instância |
| **Worker como task asyncio no `lifespan` do back** | Uma peça a menos, mas o processo que atende requisição passa a disparar também, e cai junto. O próprio docstring do `lifespan` argumenta contra misturar responsabilidades que precisam falhar separado |
| **Cron na EC2** | Configuração do host, fora do compose: o local e o real deixam de ter os mesmos componentes |
| **N8N puxando os pendentes** (Schedule Trigger) | Leva a lógica de fila (reivindicar, liberar, retentar) para um workflow sem teste e sem revisão de código, e exige uma rota de "reivindicar" no back |
| **Status numa tabela de job separada** | Deixaria o `content` do `Insight` como `not null`, igual ao modelo do time. Custa uma tabela e um JOIN a mais para a tela saber o status, e o passo 5 do playbook pede a coluna no model do domínio dono. Volta à mesa se a P-042 cair (vários insights por resposta) |

## Consequências

**Boas:**

- **Um pico de envios vira INSERTs**, que são baratos. O worker escoa no ritmo que
  `INSIGHT_MAX_IN_FLIGHT` deixa, e esse ritmo é um número em `settings`, não uma
  mudança de infra.
- **Nada se perde.** Toda falha (N8N fora, Bedrock recusando, processo morrendo, deploy
  no meio) vira estado com reenvio. A varredura recupera o que sumiu dentro do N8N.
- **N8N fora do ar não afeta o envio**, só atrasa o insight. É o que a `arquitetura.md`
  promete e hoje nada garante.
- **Nenhuma peça nova na AWS**, e o local continua com os mesmos componentes da EC2.
- **Testável sem rede:** client fake no service, repository fake, e um ciclo do worker
  testado chamando o service uma vez.

**Ruins — e aceitas:**

- **Entrega "pelo menos uma vez".** Se o POST ao N8N passar e a resposta se perder, o
  worker reenvia e o Bedrock roda duas vezes para a mesma resposta. O callback
  idempotente garante um insight só; o custo é uma chamada de LLM a mais, de vez em
  quando.
- **O insight demora no mínimo um ciclo do worker** (~3 s) mais o tempo da esteira, e o
  front faz polling. Aceito: o insight já era assíncrono para quem responde.
- **Mais um container na EC2**, com `mem_limit` próprio (um processo Python, na casa de
  `192m`), somado a `1g` do Keycloak, `1536m` do N8N e `384m` do back. Cabe na
  `t4g.medium` (4 GB) desde 2026-10-28, quando o N8N passou de `768m` para `1536m`
  depois de travar sem heap (ADR-0007, pendência "Tamanho da instância").
- **O `deploy.sh` vai precisar recriar o worker junto com o back** (`up -d --no-deps back
  insight-worker`), depois da migration, a partir da integração. Sem isso, um worker antigo roda contra o
  schema novo. E como o compose de produção é aplicado à mão, a entrada do serviço na
  EC2 é um passo humano.
- **O worker não tem `/health`.** Se ele cair e não voltar (`restart: unless-stopped`
  cobre o caso comum), o sintoma é insight `pending` envelhecendo. Aceito: sem SLA. O
  sinal fica no log e numa contagem de `pending` com mais de 10 minutos.
- **O Postgres faz papel de fila**, com uma query leve a cada 3 s. Serve ao volume do
  projeto e não serve a milhares de envios por segundo, que ninguém prevê.
- **O model da CREED-52 muda depois dela, não nela.** A CREED-52 segue para o merge
  como está. Na tarefa da integração, `content` deixa de ser `not null` e a tabela ganha
  status e `unique`, e a seção "Banco" daquele PR registra a mudança (ADR-0009).
- **A rota do callback fica alcançável de fora**, porque o Caddy encaminha `/api/*` ao
  back. A assinatura protege. O N8N chama o back pela rede interna do compose, então o
  Caddy pode responder 404 para essa rota, como já faz com `/auth/admin*`.

## Como reverter

O custo é baixo e **zero em dado**: as colunas de status continuam servindo a qualquer
desenho, porque a tela precisa delas.

- **Para SQS ou Redis**, se aparecer volume e dono de infra: o `Insight` com status
  continua, o worker deixa de ler a tabela e passa a consumir a fila. Muda o loop, e
  só ele.
- **Para task no `lifespan`**, se o container a mais pesar: o loop vai para o `lifespan`
  e o serviço sai dos dois compose. O service não muda.
- **Se a P-042 cair** (vários insights por resposta): sai o `unique`, e o status migra
  para uma tabela de job por resposta (a última alternativa da tabela). É a reversão
  mais cara, por isso a P-042 tem custo médio.

## Pendências

- [x] **Levar o contrato da P-041 à CREED-55**, que monta o workflow (atribuída a
      Gustavo Amaro, em andamento, sem descrição no board em 2026-10-24). É lá que o
      payload de ida se define e a P-041 fecha. *Resolvido em 2026-11-14 de outro jeito:*
      a CREED-55 fechou sem PR, e o contrato saiu da spec, como `insight-v1` (adendo, A3;
      P-087). A POC dela entra como estrutura do `docker/n8n/`.
- [ ] **A cota do Bedrock** para o modelo escolhido (requisições e tokens por minuto), que
      é o que acerta `INSIGHT_MAX_IN_FLIGHT`. É do dono de infra: a IA não executa `aws`.
- [x] **Onde nasce o cálculo** cujo resultado vai no payload. Ele ainda não existe, e as
      objetivas dependem da CREED-37. Se o dono do cálculo precisar ler `insights`, o
      ciclo de import volta e esta tabela de encaixe precisa ser revista. *Resolvido em
      2026-11-14:* o cálculo individual é o da CREED-71 (`prismas`), e o agregado é o de
      `dashboards`. `insights` compõe com os dois, e `dashboards` lê `insights` por JOIN,
      sem ciclo (adendo, A3).
- [x] **O tamanho da EC2** com o quinto container (ADR-0007). Resolvido em 2026-10-28
      com a `t4g.medium`.
- [ ] **Teste de carga local** antes do aceite: 50 a 100 envios simultâneos contra um N8N
      com o Bedrock simulado. Precisa mostrar nenhum insight perdido, nenhum duplicado,
      `dispatched` nunca acima de `INSIGHT_MAX_IN_FLIGHT`, e que o webhook com o limite
      de concorrência ligado continua respondendo de imediato. *Trocado em 2026-11-14
      (adendo, A7):* sem N8N local, vira o teste de concorrência do worker contra
      Postgres e um client falso (task 4 da esteira). A parte do webhook sai junto com a
      válvula. A integração real é provada depois da publicação (task 12).
- [ ] **Documentos que este ADR desatualiza, quando for Aceito:** a seção "Esteira de IA"
      da `arquitetura.md` passa a apontar para cá, e o mapa tabela → domínio do
      `modelo-de-dados.md` ainda põe `Insight` em `prismas`, mas o domínio no código é
      `insights`.

## Premissas deste ADR

| ID | Premissa | Reverter | Vai para |
|---|---|---|---|
| [P-041](../premissas.md) | Contrato só de correlação: `insight_id` e `form_response_id` na ida; `insight_id`, `status` e `content` na volta. *Substituída pela P-087 (adendo, A3)* | baixo | quem monta o workflow (é técnica, não vai para a pauta da cliente) |
| [P-042](../premissas.md) | Uma resposta enviada, um insight, uma vez só | médio | pauta da cliente |
| [P-043](../premissas.md) | Só o próprio respondente lê o seu insight individual. *Revista pela P-086 (adendo, A6)* | baixo | pauta da cliente |
| [P-044](../premissas.md) | Esgotadas as tentativas, a tela diz que o insight não ficou disponível, sem "tentar de novo" | baixo | pauta da cliente |

## Adendo — a esteira de ponta a ponta (2026-11-14)

A [spec da esteira de insights](../../tarefas/1dfej6fwdaj-esteira-de-insights/spec.md) liga as três
pontas: o back dispara, o N8N chama o Claude no Bedrock, e o back recebe a volta. Ao
fazer isso, ela muda seis pontos deste ADR. **O mecanismo não muda:** outbox na tabela,
worker em container próprio, `SKIP LOCKED`, backoff, varredura e callback idempotente
continuam como acima. O texto original fica como foi escrito; onde ele diverge, vale este
adendo.

A1, A2 e A7 foram decididos pelo Luís em 2026-11-14. A3 a A6 saíram da spec, escrita a
pedido dele. A8 entrou em 2026-11-16: saiu da revisão do código da volta
(creed-backend#81), feita pelo Enzo, e o Luís aceitou.

### A1 — `content` vira `jsonb` (item 2)

**Antes:** `content` em texto nulável.

**Agora:** `content` em `jsonb` nulável, validado pelo back no callback com o
`InsightContent`: `analise` (parágrafos), `prismas` (um texto por prisma, as cinco chaves
do enum) e `recomendacao` (parágrafos). O `CHECK` e o `unique` do item 2 continuam.
Entram também:

- `model_id` e `prompt_version`, para responder "de onde saiu este texto?";
- `completed_at`, a data que a tela mostra ao lado do texto.

**Por quê:** o front (`ResultText`, `CreedSummary`) desenha análise, recomendação e um
texto por prisma. Com um texto único, a tela teria de recortá-lo.

**Descartado:** vários insights por resposta, ligados por `insight_prismas`. Derruba a
P-042 e é a reversão mais cara deste ADR ("Como reverter").

### A2 — o insight da empresa entra (itens 1, 2 e 3)

**Antes:** só o insight individual; o [C24] ficava para depois.

**Agora:**

- `insights` ganha `organization_id` e `form_id`, os dois `not null`. No insight
  individual, são copiados do formulário e da resposta.
- `form_response_id` vira nulável. Nulo quer dizer insight da empresa, um por período.
- O envio, além de gravar o individual, agenda o da empresa quando o período tem 5 ou
  mais respostas enviadas: grava um `pending` com `next_attempt_at = agora + 30 min`.
- Fica no máximo um `pending` por (organização, período). Quem garante é um índice
  único parcial, com a gravação por `ON CONFLICT DO NOTHING`, para a corrida entre dois
  envios não derrubar nenhum dos dois.
- O worker não muda: o insight da empresa é mais uma linha `pending`.
- A tabela está vazia desde a consolidação `b54ed78ef041`. A migration **confere** isso,
  em vez de preencher `status = done` como dizia a linha "Migration" da tabela de
  encaixe.

| Setting novo | Inicial |
|---|---|
| `INSIGHT_ORG_MIN_RESPONSES` | `5` |
| `INSIGHT_ORG_DEBOUNCE_SECONDS` | `1800` |

**Por quê:** a empresa precisa de texto no dashboard consolidado, e o insight individual
continua anônimo para a gestora (A6). Diverge do [C24], que não recortava o insight da
organização por formulário, porque o dashboard da empresa passou a ser por período
(P-089).

### A3 — o contrato `insight-v1` substitui a P-041 (item 4)

**Ida:** um POST por insight, com:

- `scope`, `insight_id`, `attempt` e `language`;
- as notas de 0 a 100 já calculadas, o destaque e a oportunidade;
- as respostas abertas, no individual, ou os números agregados, na empresa.

O `form_response_id` sai da ida: o N8N só precisa do `insight_id`.

**Volta:** `status`, `content`, `model_id` e `prompt_version`; ou `failed`, com `error` e
`retryable`.

O contrato completo está na spec, seção "Contrato" (P-087).

**Quem monta o payload:** o `PrismaService` (individual) e o `DashboardService`
(empresa), por composição a partir de `insights`. `dashboards` lê a tabela `insights`
por JOIN e **nunca** importa `insights.service`. Assim, o ciclo que a pendência "onde
nasce o cálculo" temia não se forma.

### A4 — a ida leva token e a volta, HMAC com timestamp (itens 5 e 6)

**Antes:** só o callback era assinado, com o `N8N_CALLBACK_SECRET`.

**Agora:**

- A ida manda `Authorization: Bearer {N8N_WEBHOOK_TOKEN}` (setting novo), e o Header Auth
  do nó Webhook confere.
- A volta assina `"{timestamp}.{corpo cru}"` com HMAC-SHA256, no header
  `X-Creed-Signature`. O `X-Creed-Timestamp` precisa estar a menos de 5 min; fora disso,
  ou sem assinatura, a resposta é 401.
- A URL do callback é fixa no workflow e nunca vem do payload.
- Nenhum segredo fica no JSON exportado do workflow.

**Por quê:** sem o timestamp, um callback capturado pode ser reenviado. Sem o token,
qualquer um que alcance a rede interna dispara chamadas pagas ao Bedrock. A POC da
CREED-55 recebia a URL no payload e tinha o segredo escrito no JSON.

### A5 — a tabela de idempotência ganha três linhas (item 6)

| Chega | Com o insight em | Faz |
|---|---|---|
| `done` | `failed` | grava e marca `done`: um texto atrasado vale mais que "indisponível" |
| `failed` com `retryable: false` | `pending` ou `dispatched` | marca `failed` direto: uma recusa do modelo não muda com nova tentativa |
| corpo fora do contrato, inclusive `content` fora do schema | qualquer | 422, sem mudar nada; a varredura devolve o insight a `pending` |

As outras linhas do item 6 continuam. As respostas de sucesso passam a ser 204, sem
corpo.

### A6 — quem lê, e onde (item 7)

**Antes:** o `GET /form-responses/{id}/insight` alimentava a tela de resultado, e só o
respondente lia o insight (P-043).

**Agora:**

- O texto aparece no **dashboard**, pelo `creed_summary` de `/dashboards/me`,
  `/members/{id}` e `/company`, que ganha `insight_status` e `generated_at`.
- O `GET` fica para o polling e devolve `completed_at` no lugar de `created_at`.
- O respondente lê o seu insight, e a administradora da CREED lê o dos mentorandos. A
  gestora não lê o insight individual de ninguém, só o agregado da empresa. É a P-086,
  que revê a P-043.

### A7 — o N8N é o da AWS, sem cópia local (itens 3 e 5, e pendências)

**Antes:** o item 5 ligava `N8N_CONCURRENCY_PRODUCTION_LIMIT` "nos dois compose", e a
pendência de carga pedia um N8N local com o Bedrock simulado.

**Agora:**

- O N8N é a instância self-hosted que já roda na EC2, com a credencial do Bedrock que já
  está nela. Ele não nasce da publicação do back, e o serviço `n8n` dos compose **não
  muda**: nem variável, nem válvula, nem credencial.
- O workflow é montado direto no N8N da AWS. O git guarda o export, os prompts, o
  dossiê e um **kit de contrato** (schemas, exemplos e um vetor de assinatura) que o
  back e o N8N usam como verdade única.
- **Não há integração entre o back local e a AWS.** O `insight-worker` do compose local
  fica parado sem `N8N_WEBHOOK_URL`, e o back se testa com um client falso.
- Quem regula o ritmo é só o `INSIGHT_MAX_IN_FLIGHT` do worker.
- A pendência de carga vira um teste de concorrência do worker contra Postgres. A ida e
  a volta reais são provadas depois da publicação, por um roteiro executado em produção
  com uma organização de teste.

**Por quê:** a esteira já existe e funciona onde está. Uma cópia local seria uma segunda
esteira, que diverge da de produção. E ligar o back local à AWS exigiria abrir o webhook
para fora e manter um túnel por dev para a volta.

**Custo aceito:** o primeiro encontro real entre o back e o N8N acontece em produção. O
kit de contrato diminui esse risco: se os nomes de campo ou a assinatura não baterem, um
teste falha antes. Mas o kit não cobre rede, credenciais nem as variáveis da EC2.

### A8 — a volta devolve o `attempt` (item 6 e A5)

**Antes:** a volta só dizia de qual insight era (A3), e um `failed` valia sobre
`pending` ou `dispatched` (item 6 e A5).

**Agora:**

- A volta, `done` ou `failed`, traz o `attempt` igual ao da ida. O campo é obrigatório.
- Um `failed` só vale com o insight `dispatched` **na mesma tentativa**. Fora disso
  (`pending`, `failed`, ou `dispatched` em outra tentativa), responde 204, não muda
  nada e fica no log.
- O `done` não confere a tentativa: continua valendo sobre `pending`, `dispatched` ou
  `failed`, como no A5.

**Por quê:** o N8N demora mais que o prazo da varredura, ela devolve o pedido à fila, e o
worker manda a tentativa 2. Aí chega o `failed` da 1. Pela tabela antiga, ele devolvia à
fila um pedido em voo: o disparo saía duplicado, e o teto de pedidos em voo era furado.
Com `retryable: false`, encerrava um pedido que ainda podia dar certo. Conferir só o
status não basta, porque a tentativa 2 também está `dispatched`. Sobre `pending`, quem
pôs o pedido lá (a varredura ou a falha do disparo) já contou a falha daquela tentativa.
O worker já fazia a mesma conferência ao registrar a falha do disparo.

**Custo aceito:** se a falha atrasada era uma recusa do modelo, a tentativa seguinte gasta
uma chamada para ouvir a mesma recusa.

### Premissas do adendo

| ID | Premissa | Reverter | Vai para |
|---|---|---|---|
| [P-086](../premissas.md) | Lê o insight individual o respondente, e a administradora lê o dos mentorandos; a gestora, não. Revê a P-043 | baixo | pauta da cliente |
| [P-087](../premissas.md) | Contrato `insight-v1`, ida e volta. Substitui a P-041 | baixo | quem monta o workflow (é técnica) |
| [P-088](../premissas.md) | O insight tem análise, um texto por prisma e recomendação; destaque e oportunidade vêm do cálculo | baixo | pauta da cliente |
| [P-089](../premissas.md) | Insight da empresa por período, com 5 ou mais respostas, regerado no máximo a cada 30 min | médio | pauta da cliente |
| [P-090](../premissas.md) | Nenhum texto livre de respondente no insight da empresa | baixo | pauta da cliente |
| [P-091](../premissas.md) | O payload individual não leva dado pessoal, e o questionário não avisa que as respostas abertas passam por IA | médio | pauta da cliente |

As P-092 a P-094 tratam do texto e do conhecimento do modelo (idioma, dossiê, tom) e
moram só na spec.

### Consequências do adendo

**Boas:**

- O texto chega ao dashboard, que já sabia desenhá-lo.
- Cada insight diz de que modelo e de que versão do prompt saiu.
- A empresa recebe texto sem expor nenhuma pessoa.

**Ruins — e aceitas:**

- O worker depende de `prismas` e `dashboards` para montar o payload. Uma mudança no
  cálculo muda o que o N8N recebe; é de propósito, para ser o mesmo número da tela.
- O insight da empresa fica até ~30 min atrás do período e não é regerado quando alguém
  é excluído.
- Índice único parcial e `ON CONFLICT` no envio: SQL que o time ainda não usa.
- O custo por insight deixa de ser desconhecido: entre ~US$ 0,09 e ~US$ 0,40, pela
  estimativa da spec (item 2.4).
- A exclusão de empresa (E-6) passa a apagar também os insights da empresa.

### Como reverter o adendo

- **A1:** `jsonb` → `text` é migration com conversão, e o front volta a receber um texto
  só.
- **A2:** apagar as linhas com `form_response_id` nulo, voltar a coluna a `not null` e
  tirar o gatilho do envio. `organization_id` e `form_id` podem ficar, como cópia
  inofensiva.
- **A3 a A5:** schemas do provedor, nós do N8N e o `Depends` de `core/security.py`. Não
  tocam em dado.
- **A6:** guarda de rota e um campo do `creed_summary`.
- **A8:** tirar o campo dos modelos de volta e a conferência do `complete`, e regerar o
  kit. O workflow do N8N deixa de mandar o campo. Não toca em dado.
- **A7:** ligar a válvula é uma variável no serviço `n8n`. Um N8N local é o serviço que
  o compose do back já tem, mais o workflow importado do export. Nenhum dos dois toca
  em dado.
