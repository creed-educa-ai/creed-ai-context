# 86e3gurw3 — CREED-47 · Integração das tabelas e domínios da sprint 2 (backend)

> Gerada por `workflows/tarefa-to-spec.md` em 2026-09-30, a partir da tarefa
> [CREED-47](https://app.clickup.com/t/86e3gurw3), criada no mesmo dia a pedido do Luís
> (AGES III, responsável técnico). Estado lido: `origin/dev` em `b5216cd` (PRs #29 e #30
> já dentro), com o Alembic numa head só (`28e9a13197f4`) e nenhuma branch remota fora
> da `dev`.
>
> **Esta é a "tarefa de amarração"** que as specs da CREED-32, 33 e 35 deixaram marcada
> e que não existia no board. O que cada uma delas empurrou para cá está nas seções
> abaixo, com a origem citada.
>
> **Três decisões do Luís, em 2026-09-30, antes da spec:**
> - **D1: organização e setor ficam fora.** As FKs de `links.organization_id` e
>   `form.organization_id` entram com a [CREED-38](https://app.clickup.com/t/86e3anvtn), e
>   a de `links.department_id` com a [CREED-39](https://app.clickup.com/t/86e3anvup),
>   junto com as tabelas. Esta tarefa liga só o que já existe.
> - **D2: por enquanto, só respostas descritivas.** Enquanto a
>   [CREED-37](https://app.clickup.com/t/86e3anvr9) (alternativas) não existir, a resposta
>   a uma pergunta objetiva é recusada, para não gravar `option_id` que não aponta para
>   nada.
> - **D3: tarefa nova no board**, em vez de reaproveitar a CREED-27.

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | **Regra de negócio nova, de permissão:** quem cadastra, lê e responde formulário, e em qual organização (P-031, P-033). Também há **ciclo de vida**: quando uma resposta pode ser aberta e enviada (P-030). Reforçam: **quatro premissas novas** (P-030 a P-033). |
| Técnico | T3 | **Migration** com cinco FKs e uma coluna `NOT NULL` nova. **Mudança em contrato já publicado**: `POST /form-responses` perde `vinculo_id` do corpo, e `GET /forms/{form_id}/questions` troca 200 com lista vazia por 404. Reforça: **padrão que ainda não existe no código**, o 403 decidido no service (`ForbiddenError`). |

Dispensadas nesta calibragem: nenhuma.

## Problema

Na sprint 2, cada equipe entregou sua tabela e seu domínio sem depender das outras. Foi
de propósito: evitou conflito de migration e de arquivo. O custo é que o backend
de hoje tem as peças, mas não o fluxo:

- **O banco não liga quase nada.** Só existem duas FKs, `user.link_id → links` e
  `participants.document_id → documents`. Vínculo, pergunta, resposta de formulário e
  resposta aceitam ids de coisas que não existem.
- **A resposta individual não sabe a qual resposta de formulário pertence.** A tabela
  `answer` não tem a coluna `form_response_id` que o modelo prevê.
- **Nenhuma rota grava resposta.** O `AnswerService` existe, mas nenhum router o chama.
- **Formulário, pergunta e resposta de formulário não exigem login.** As specs da
  CREED-33 e da CREED-35 deixaram isso para esta tarefa, com a condição de a API não
  sair do ambiente local antes.
- **O seed aponta para um participante (`…0002`) e uma organização (`…0001`) que não
  existem.**

Sem isso, não há o que mostrar à cliente de ponta a ponta: não dá para abrir um
formulário, responder e ver a resposta gravada.

## Quem usa

| Papel | O que enxerga e faz depois desta tarefa |
|---|---|
| `admin` | Tudo o que já fazia (cadastrar participante, vínculo e usuário). Passa a cadastrar e ler formulário e pergunta **de qualquer organização** (P-033). Pode responder formulário da própria organização (P-031). |
| `gestor` | Cadastra e lê formulário e pergunta **só da própria organização** (P-033). Pode responder formulário da própria organização (P-031). |
| `respondente` | Lê formulário e perguntas da própria organização; abre a própria resposta, grava as respostas descritivas, lê o que gravou e envia (P-031). |
| Time (dev) | Um seed local que monta a cadeia inteira, para testar e para a apresentação. |
| Equipes da CREED-37, 38 e 39 | Recebem as ligações restantes descritas aqui, com o que cada uma precisa criar para a FK dela não travar. |

A cliente não usa nenhuma tela nova: o front não consome estas rotas (a CREED-21, que
desenha o questionário, está em "to do"). O que ela vê é a demonstração pela API.

## Escopo

**Entra:**
- FKs em `links.participant_id`, `questions.form_id`, `form_responses.form_id`,
  `form_responses.vinculo_id` (para `links`) e `answer.question_id`.
- Coluna nova `answer.form_response_id`, `NOT NULL`, com FK e índice.
- Os services passam a conferir o que recebem: vínculo confere participante, pergunta
  confere formulário, resposta de formulário confere formulário, e resposta confere
  resposta de formulário e pergunta.
- Guarda de papel e de organização em `forms`, `questions` e `form-responses` (P-033,
  P-031).
- O vínculo da resposta de formulário passa a vir do login: `vinculo_id` sai do corpo
  do `POST /form-responses`.
- Rotas novas: gravar resposta (`POST /form-responses/{id}/answers`) e ler as respostas
  gravadas (`GET /form-responses/{id}/answers`).
- O envio (`PATCH /form-responses/{id}`) passa a exigir as perguntas **descritivas**
  obrigatórias respondidas.
- Seed local: cria o participante `…0002` e, na última entrega, a cadeia de
  demonstração (formulário e perguntas descritivas).
- `ForbiddenError` em `app/shared/exceptions.py`, traduzido para 403 no router.
- Três entradas em `COMPOE_COM_SERVICE_DE` (`tests/test_arquitetura.py`): `links`,
  `questions` e `responses`.

**Não entra:**
- **FKs de `organization_id` e `department_id`** (D1). Vão com a CREED-38 e a CREED-39.
- **Resposta a pergunta objetiva e FK de `answer.option_id`** (D2). Vão com a CREED-37.
- **Renomear `form_responses.vinculo_id` para `link_id`.** É mudança destrutiva: a
  regra 6 de `conventions/migrations.md` pede PR próprio, e a cliente não vê
  diferença. O nome antigo continua no banco e na saída da API.
- **Transição de status do formulário** (`draft` → `published` → `closed`). Continua
  com a tarefa que precisar dela (P-017); até lá, vale a P-030.
- **Editar ou apagar resposta** (P-032), formulário ou pergunta.
- **Juntar os domínios `questions` e `forms`.** Ver "Abordagem técnica", item 6.
- **Gestor lendo a resposta individual de outra pessoa.** Quem lê as respostas é só o
  dono. Leitura agregada é dashboard e relatório, que têm tarefa própria.
- **Usuário `gestor` ou `respondente` no realm local.** A P-031 deixa o `admin` de dev
  responder, e o 403 do gestor é provado nos testes de service.
- **Front.** Nenhuma tela muda.
- **Corrigir o 404 do `POST /users`** para vínculo inexistente no corpo (ver item 11).
  A divergência fica anotada.

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-backend | domínios `links`, `forms`, `questions` e `responses`; `app/shared/exceptions.py`; uma revisão do Alembic; `scripts/seed_local.py`; `tests/test_arquitetura.py` |
| creed-frontend | nada |
| creed-infrastructure | nada |

Nomes dos domínios, que não mudam: `links`, `forms`, `questions`, `responses`.

## Contrato

### Contrato HTTP alterado

Todas as rotas abaixo passam a documentar 401 e, quando se aplica, 403 e os erros
novos. O `test_openapi.py` não varre as rotas sozinho: ele confere uma lista fixa, rota
a rota (hoje já estão lá `POST /form-responses` e `PATCH /form-responses/{id}`). As
rotas desta tarefa entram nessa lista.

| Método | Rota | Guarda | O que muda | Erros novos |
|---|---|---|---|---|
| POST | `/api/v1/organizations/{organization_id}/links` | `admin` (já tinha) | confere o participante | **422** participante inexistente |
| POST | `/api/v1/forms` | **`admin`, `gestor`** | o gestor só cadastra na própria organização | 401, 403 |
| GET | `/api/v1/forms/{form_id}` | **qualquer papel** | fora da própria organização, 403 (o admin lê qualquer uma) | 401, 403 |
| POST | `/api/v1/questions` | **`admin`, `gestor`** | confere o formulário e a organização dele | 401, 403, **422** formulário inexistente |
| GET | `/api/v1/forms/{form_id}/questions` | **qualquer papel** | confere o formulário e a organização dele | 401, 403, **404** formulário inexistente (hoje: 200 com `[]`) |
| POST | `/api/v1/form-responses` | **qualquer papel** | corpo só com `form_id`; o vínculo vem do login; confere o formulário e a organização dele | 401, 403, **422** formulário inexistente |
| PATCH | `/api/v1/form-responses/{form_response_id}` | **qualquer papel, só o dono** | confere as obrigatórias descritivas | 401, 403, **422** obrigatória sem resposta |

Corpo novo do `POST /api/v1/form-responses`:

```json
{ "form_id": "7d94e9bb-25ca-4df9-9c08-d90251dd8d68" }
```

`vinculo_id` enviado no corpo é ignorado, porque o Pydantic descarta campo que não
está no schema. A **saída** continua com `vinculo_id` (ver "Não entra").

### Contrato HTTP novo

| Método | Rota | Guarda | Entrada | Saída |
|---|---|---|---|---|
| POST | `/api/v1/form-responses/{form_response_id}/answers` | qualquer papel, só o dono | `AnswerCreate{question_id, option_id?, value?}` (schema atual, sem mudança) | 201 `AnswerResponse` |
| GET | `/api/v1/form-responses/{form_response_id}/answers` | qualquer papel, só o dono | — | 200 `AnswerResponse[]`, na ordem de gravação |

`AnswerResponse` ganha `form_response_id`.

Erros do `POST .../answers`, na ordem em que o service confere:

| Código | Quando |
|---|---|
| 404 | a resposta de formulário não existe |
| 403 | a resposta de formulário é de outro vínculo |
| 409 | a resposta de formulário já foi enviada |
| 422 | a pergunta não existe, ou é de outro formulário |
| 422 | a pergunta é objetiva (D2): "respostas a perguntas objetivas chegam com as alternativas (CREED-37)" |
| 422 | o texto está vazio, ou veio `option_id` numa descritiva. O `AnswerService.record` de hoje já recusa as duas formas juntas e nenhuma das duas; falta recusar `option_id` sozinho numa descritiva |
| 409 | a pergunta já tem resposta nesta resposta de formulário (P-032) |

### Contrato interno entre camadas

| Quem chama | Quem responde | Para quê |
|---|---|---|
| `LinkService` | `ParticipantService.get_participant` (já existe) | participante existe? |
| `QuestionService` | `FormService.get` (já existe) | formulário existe, e de que organização é? |
| `FormResponseService` | `FormService.get` | idem |
| `AnswerService` | `FormResponseRepository` (mesmo domínio) e `QuestionService` (método novo, `get`) | a resposta de formulário e a pergunta existem, e a pergunta é daquele formulário? |

O router entrega ao service **valores simples** tirados do `AuthenticatedUser`:
`role`, `organization_id` e `link_id`, convertidos para `uuid.UUID`. Ver item 7.

## Dados

### Revisão nova, depois de `28e9a13197f4`

| Tabela | Coluna | Muda | Constraint |
|---|---|---|---|
| `links` | `participant_id` | ganha FK | `fk_links_participant_id_participants` → `participants.id` |
| `questions` | `form_id` | ganha FK | `fk_questions_form_id_form` → `form.id` |
| `form_responses` | `form_id` | ganha FK | `fk_form_responses_form_id_form` → `form.id` |
| `form_responses` | `vinculo_id` | ganha FK | `fk_form_responses_vinculo_id_links` → `links.id` |
| `answer` | `question_id` | ganha FK | `fk_answer_question_id_questions` → `questions.id` |
| `answer` | `form_response_id` | **coluna nova**, `UUID NOT NULL`, com índice | `fk_answer_form_response_id_form_responses` → `form_responses.id` |

Os nomes seguem o padrão de `fk_user_link_id_links`. `ON DELETE` fica no padrão do
Postgres (item 3). Nenhum índice novo além do de `answer.form_response_id`: as outras
cinco colunas já são indexadas.

### O dado que já existe

Esta API nunca saiu do ambiente local, e o CI não tem passo de deploy (`ci.yml` só roda
qualidade e heads). O dado que pode existir está no banco local de cada pessoa do time:

| Onde | O que pode haver | O que acontece |
|---|---|---|
| `links` | o vínculo do seed, apontando para o participante `…0002`, que não existe | o seed novo cria o participante. Rodar o seed **antes** do `upgrade` resolve |
| `links`, `questions`, `form_responses` | linhas de teste manual com ids inventados | a revisão para com mensagem que diz o que apagar |
| `answer` | nada, porque nenhuma rota nem seed escreve nela | se houver alguma linha, a revisão para: não há como saber a qual resposta de formulário ela pertence |

A conferência roda no Postgres (`DO $$ ... RAISE EXCEPTION`), como na `28e9a13197f4`.
Assim ela também entra no `alembic upgrade --sql`. Com órfão, nada é alterado.

### `downgrade()`

Remove as cinco FKs, o índice e a coluna `answer.form_response_id`. Não há dado a
reconstruir: a coluna nasce numa tabela vazia.

## Abordagem técnica

### Escolhido: FKs onde o destino existe, conferência pelo service do dono, e a regra de organização no service

**1. Uma revisão só para as cinco FKs e a coluna.** Uma única conferência de órfãos
e um único ciclo de `downgrade`/`upgrade` para testar.
*Descartado:* uma revisão por tabela. Seriam cinco arquivos na mesma cadeia sem ganho:
nenhuma delas faz sentido sozinha, e cada uma repetiria a conferência.

**2. FK declarada pelo nome da tabela** (`ForeignKey("form.id", name=...)`), sem
importar o model do outro domínio. É como `participants.document_id` e `user.link_id`
já fazem, e o `app/models.py` garante que a tabela alvo esteja no `metadata`.

**3. `ON DELETE` no padrão (`NO ACTION`).** Nenhuma rota apaga formulário, pergunta,
vínculo ou participante hoje. Se um dia apagar, o banco recusa enquanto houver quem
aponte, e isso é o comportamento certo para dado de pesquisa.
*Descartado:* `CASCADE`. Apagar um formulário levaria perguntas, respostas de
formulário e respostas junto, sem aviso.

**4. Órfão faz a revisão parar com uma mensagem; ela não corrige nada.**
*Descartado:* a revisão inserir o participante `…0002`. A migration roda em todo
ambiente, e dado de desenvolvimento não entra por ela; isso é trabalho do seed, que já
recusa rodar fora de `ENVIRONMENT=local`.
*Descartado:* a revisão apagar órfãos. Apagaria dado sem ninguém ver o quê.

**5. Cada domínio confere a existência pelo service do dono.** `links` passa a compor
com `ParticipantService`, `questions` com `FormService`, e `responses` com `FormService`
e `QuestionService`. Cada um entra em `COMPOE_COM_SERVICE_DE`, com o motivo. É o padrão
que `participants → DocumentService` e `users → LinkService` já seguem.
*Descartado:* `LEITURA_ENTRE_DOMINIOS` (JOIN no repository). A exceção existe para
domínio de **leitura**, e aqui cada caso é escrita com regra.
*Descartado:* confiar só na FK e traduzir o `IntegrityError`. O erro chegaria no
`flush()`, com a mensagem do driver, e o `GET /forms/{form_id}/questions` precisaria
consultar o formulário de qualquer jeito para devolver 404.

**6. `questions` continua separado de `forms`.** A spec da CREED-35 deixou para cá a
decisão entre juntar os dois domínios ou manter separados com composição. Juntar
significa mover oito arquivos e os testes, sem efeito que alguém veja, na véspera da
entrega.
*Descartado:* juntar agora. Consequência para a CREED-37: `QuestionOption` entra em
`questions`, que é o dono da pergunta.

**7. Quem age, e em qual organização, chega ao service como valores simples.** O
router lê `role`, `organization_id` e `link_id` do `AuthenticatedUser` e os passa ao
service. A regra "o gestor só na própria organização" (P-033) e "só o dono mexe na
resposta" moram no service, que levanta `ForbiddenError`, uma classe nova em
`app/shared/exceptions.py`. O router traduz para 403, como já faz com as outras.
*Descartado:* passar o `AuthenticatedUser` inteiro ao service. Ele mora em
`app/shared/authorization.py`, que importa FastAPI; o service passaria a depender da
guarda HTTP.
*Descartado:* conferir a organização no router. Seria regra de negócio no router,
contra o ADR-0004.

**8. O vínculo da resposta de formulário vem do login.** `AuthenticatedUser.link_id`
já existe desde a CREED-32.
*Descartado:* manter `vinculo_id` no corpo e conferir se é igual ao do login. É um
campo redundante que só serve para errar. A mudança de contrato é barata agora porque
nenhuma tela o consome.

**9. Objetiva é recusada (D2), e o envio ignora obrigatória objetiva.** Sem
alternativas, uma pergunta objetiva obrigatória tornaria impossível enviar o
formulário. Até a CREED-37, a conferência do envio considera só as perguntas
descritivas obrigatórias.
*Descartado:* aceitar `option_id` sem conferir. Cada linha dessas travaria a FK da
CREED-37.

**10. Organização e setor esperam a CREED-38 e a CREED-39 (D1).** Até lá,
`organization_id` continua sem FK em `links` e `form`, e o `admin` consegue gravar
qualquer UUID ali. **O que a CREED-38 precisa fazer para a FK dela não travar:** criar
a organização `00000000-0000-0000-0000-000000000001`, que o seed já usa, e conferir os
`organization_id` gravados antes de ligar. O mesmo vale para a CREED-39 com
`department_id` (o seed grava nulo).
*Descartado:* esta tarefa criar uma tabela `organizations` mínima. Sobreporia a
CREED-38, que tem responsável, e o processo da sprint existe justamente para evitar
isso.

**11. Referência inexistente: 422 se veio no corpo, 404 se veio no caminho.** É o que
`participants` já faz com `document_id` (422) e o que o `GET` de formulário faz (404).
O `POST /users` responde 404 para `link_id` inexistente no corpo. A divergência fica
anotada e não é corrigida aqui, porque mudaria um contrato publicado sem pedido.

**12. Seed em dois tempos.** Na entrega 1, o seed cria o participante `…0002` antes do
vínculo, inclusive no caminho em que o usuário de dev já existe. Na entrega 5, ele cria
o formulário e as perguntas de demonstração com ids fixos, no mesmo esquema idempotente
que o seed já usa. As perguntas são todas descritivas (D2), com texto sintético que se
identifica como demonstração: o conteúdo do instrumento é da cliente.

### Corte em entregas

**Um PR só**, decidido pelo Luís em 2026-09-30 ao decompor: o merge precisa sair no mesmo
dia. As cinco entregas viram sete tasks, com um commit cada
([`tasks.md`](tasks.md)), e cada commit passa na suíte sozinho. A regra 6 de
`conventions/migrations.md` não impede: nada sai do banco. A tabela abaixo continua
valendo como ordem dos commits.

| # | Entrega | Depende de | Arquivo que se abre primeiro | Pronto quando |
|---|---|---|---|---|
| 1 | **Banco**: as cinco FKs, `answer.form_response_id`, participante `…0002` no seed | — | `app/domains/responses/models.py` | `upgrade`, `downgrade -1` e `upgrade` limpos num banco local com o seed antigo, depois de rodar o seed novo; `\d answer` mostra a FK |
| 2 | **Conferências**: `links`, `questions` e `form-responses` conferem o que recebem | — | `app/domains/links/service.py` | participante e formulário inexistentes dão 422, e `GET` de perguntas de formulário inexistente dá 404; `test_arquitetura.py` verde com as três entradas |
| 3 | **Guardas**: `ForbiddenError`, papel e organização em `forms`, `questions` e `form-responses`, com `vinculo_id` fora do corpo | 2 | `app/shared/exceptions.py`, depois `app/domains/forms/router.py` | 401 sem token nas sete rotas da tabela; 403 do gestor em outra organização coberto por teste de service |
| 4 | **Respostas**: `POST` e `GET .../answers`, e o envio conferindo as obrigatórias | 1, 3 | `app/domains/responses/service.py` | fluxo completo com o usuário de dev, do "Como verificar" |
| 5 | **Seed de demonstração** | 1–4 | `scripts/seed_local.py` | seed rodado duas vezes sem erro, e `GET /forms/{id}/questions` do formulário de demonstração devolve as perguntas |

A 1 e a 2 não tocam arquivo em comum e podem andar juntas. A 3 muda assinatura de
método de service que a 2 também muda, por isso vem depois.

## Critérios de aceite

- [ ] `alembic heads` mostra uma head só, e ela é a revisão nova.
- [ ] Com um vínculo apontando para um participante inexistente, o `upgrade` para com a
      mensagem da revisão e não altera nada.
- [ ] Depois do seed novo, `upgrade head`, `downgrade -1` e `upgrade head` rodam sem
      erro.
- [ ] `\d links`, `\d questions`, `\d form_responses` e `\d answer` mostram as seis
      constraints com os nomes da tabela de "Dados".
- [ ] `POST .../links` com participante inexistente → 422.
- [ ] `POST /questions` com formulário inexistente → 422;
      `GET /forms/{id}/questions` com formulário inexistente → 404.
- [ ] `POST /form-responses` com formulário inexistente → 422; sem `vinculo_id` no
      corpo → 201, e o `vinculo_id` da saída é o do login.
- [ ] As sete rotas da tabela "Contrato HTTP alterado" e as duas novas respondem 401
      sem token.
- [ ] Gestor cadastrando formulário ou pergunta em outra organização → 403, coberto
      por teste de service (`ForbiddenError`).
- [ ] Resposta a pergunta descritiva → 201, com `form_response_id` na saída; objetiva
      → 422; a mesma pergunta de novo → 409; depois do envio → 409.
- [ ] Envio com pergunta descritiva obrigatória sem resposta → 422; com todas
      respondidas → 200 e `status: submitted`.
- [ ] Mexer na resposta de formulário de outro vínculo (`POST` ou `GET .../answers`,
      `PATCH`) → 403, coberto por teste de service.
- [ ] `COMPOE_COM_SERVICE_DE` tem `links`, `questions` e `responses`, cada um com o
      motivo, e `tests/test_arquitetura.py` passa.
- [ ] `tests/test_openapi.py` confere os códigos documentados das rotas alteradas e das
      duas novas.
- [ ] O seed roda duas vezes seguidas sem erro, antes e depois da revisão nova.
- [ ] Nenhum comentário do código continua dizendo "FK para Form — tabela ainda não
      criada" ou equivalente nas colunas que ganharam FK.
- [ ] `ruff check .`, `ruff format --check .`, `pre-commit run mypy --all-files` e
      `pytest` passam.

## Como verificar

1. Numa `dev` atualizada, com o banco local no estado de hoje e o seed antigo já
   rodado: `alembic upgrade head` **tem de parar**, com a mensagem sobre o participante
   `…0002`.
2. `python scripts/seed_local.py` e depois `alembic upgrade head`: passa.
3. `alembic downgrade -1 && alembic upgrade head`: passa.
4. `psql`: `\d answer` mostra `form_response_id NOT NULL` e as duas FKs; `\d links`
   mostra `fk_links_participant_id_participants`.
5. Suba o backend e abra `/api/v1/docs`. Faça login com `dev@creed.example.com` e
   **Authorize** com o token.
6. Sem token, chame `GET /api/v1/forms/{id}`: 401.
7. Com a entrega 5, pegue o formulário de demonstração: `GET /forms/{id}/questions`
   devolve as perguntas. Antes dela, crie formulário e perguntas pelo Swagger, na
   organização `…0001`.
8. `POST /form-responses` com `{"form_id": ...}`: 201, e o `vinculo_id` é o do seed.
9. `POST /form-responses/{id}/answers` com uma pergunta descritiva e texto: 201. De
   novo na mesma pergunta: 409. Com uma pergunta objetiva: 422.
10. `PATCH /form-responses/{id}` antes de responder todas as obrigatórias: 422. Depois
    de responder: 200. `POST .../answers` depois disso: 409.
11. `GET /form-responses/{id}/answers`: devolve o que foi gravado.
12. `pytest`, `ruff check .`, `ruff format --check .`, `pre-commit run mypy --all-files`.

**O que estes passos não provam:** o 403 de gestor e o de "não é o dono" não se
reproduzem no Swagger com o realm local, que só tem o usuário `admin`. Eles ficam com
os testes de service. Provar à mão exige criar um usuário `gestor` no Keycloak local, e
isso está fora do escopo.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-030 | Responder não depende do status do formulário enquanto não houver transição: `draft` pode ser respondido | baixo |
| P-031 | Qualquer vínculo responde formulário da própria organização, com o próprio vínculo; o papel não limita | baixo |
| P-032 | Uma resposta por pergunta descritiva por resposta de formulário; gravar de novo dá 409; não há edição | baixo |
| P-033 | `admin` age em qualquer organização; `gestor` e `respondente`, só na do próprio vínculo | baixo |

As quatro estão abertas em [`decisoes/premissas.md`](../../decisoes/premissas.md). No
código, cada uma ganha o marcador `🟡 Premissa P-0NN` no service que a aplica.

D1, D2 e D3 **não** são premissas: são decisões de escopo do responsável técnico e não
dependem da cliente.

## Riscos

- **Banco local com órfão de teste manual.** A revisão para, e a pessoa não sabe o que
  apagar. **Mitigação:** a mensagem do `RAISE` diz a tabela e o comando. **Sinal:**
  alguém no canal com "a migration não sobe".
- **`organization_id` órfão se acumula até a CREED-38.** O `admin` grava qualquer UUID
  em `form` e `links`, e a FK da CREED-38 vai recusar cada um. **Mitigação:** o item 10
  diz o que a CREED-38 faz; deixar isso escrito na tarefa dela no board. **Sinal:** o
  `upgrade` da CREED-38 falhando com `violates foreign key constraint`.
- **Contrato de `POST /form-responses` muda sem erro visível.** Quem ainda mandar
  `vinculo_id` não recebe 422: o campo é ignorado, e vale o vínculo do login.
  **Mitigação:** a descrição da rota no Swagger diz de onde vem o vínculo. **Sinal:**
  resposta de formulário gravada com vínculo diferente do que o cliente mandou.
- **A P-031 mistura respostas de `admin` e `gestor` com as de `respondente`.** Numa
  análise futura, a resposta de teste do admin de dev vira dado. **Mitigação:** tudo
  isso é local; o dashboard, quando existir, filtra por papel do vínculo. **Sinal:**
  contagem de respostas maior que o número de respondentes.
- **O formulário de demonstração parece o instrumento real.** Texto de pergunta
  inventado, mostrado à cliente, pode ser lido como proposta de conteúdo.
  **Mitigação:** o texto se identifica como demonstração (item 12). **Sinal:** a
  cliente comentando o conteúdo das perguntas em vez do fluxo.
- **A apresentação fora do ambiente local não tem seed.** O seed recusa
  `ENVIRONMENT` diferente de `local`. **Mitigação:** apresentar a partir do ambiente
  local, ou montar a cadeia pelo Swagger. **Sinal:** o seed saindo com
  `Este seed é só do ambiente local`.
- **Cinco PRs em sequência na reta da entrega.** Se a 3 atrasar, a 4 não entra.
  **Mitigação:** a 1 e a 2 andam em paralelo, e cada PR é defensável sozinho.
  **Sinal:** a entrega 3 aberta há mais de um dia.
