# 86e3anvg2 — CREED-32 · Link table context

> Gerada por `workflows/tarefa-to-spec.md` em 2026-09-24, a partir da tarefa
> [CREED-32](https://app.clickup.com/t/86e3anvg2) e das três subtarefas publicadas:
> [CREED-321](https://app.clickup.com/t/86e3anw3q) (models e enums),
> [CREED-322](https://app.clickup.com/t/86e3anx1v) (repository e service) e
> [CREED-323](https://app.clickup.com/t/86e3anx37) (router e schema) — as três ainda
> sem descrição própria no board, só o título.
>
> **O nome da tarefa usa "Link"; esta spec usa "Vínculo".** A tarefa em si já fala em
> "Vínculos" no resumo e cita a tabela `Vinculo` do `.dbml` como material a consumir. **No código, o nome
> é `Link`** (e setor é `Department`): o time fechou em 2026-09-29 o vocabulário que o
> ADR-0005 deixou aberto, e a P-029, que mantinha os dois em português, foi refutada.
>
> **Revista no mesmo dia, antes das tasks, com uma decisão do time:** o papel sai do
> `User` e passa a morar no `Link`, **dentro desta tarefa**. Fecha a pendência 🔴 do
> [`modelo-de-dados.md`](../../context/modelo-de-dados.md#a-v1-e-a-autenticação) ("a
> tabela `user` que subiu não é a deste modelo") na direção do modelo, e volta ao desenho
> que a CREED-23 já tinha (D4: "`Link.role` manda"). O papel foi parar no `User` só
> porque a guarda precisava de uma cópia no banco para conferir o token, e o `User` era a
> única tabela disponível. A decisão acrescentou a **entrega 2** e o lado `users` da
> entrega 1; as três subtarefas publicadas cobrem só a parte `links` da entrega 1.
>
> **Revista em 2026-09-30, depois da [review](review.md):** o `POST /users` passou a
> exigir `admin`; a guarda passou a decidir a rota pelo papel do vínculo mesmo quando o
> token traz mais de um papel; `participants` chegou à `dev` (PR #28) durante a tarefa,
> e o motivo de `participant_id` seguir sem FK foi reescrito (item 3); o front renomeia
> `vinculo_id` → `link_id` num PR par; e o risco do Keycloak passou a descrever o sintoma
> real (o login responde 200).

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | **Regra de negócio nova, de acesso e de ciclo de vida.** O papel de acesso passa a vir do vínculo: quem não tem vínculo não entra. E o vínculo tem início e fim (`start_at`/`end_at`). São dois sinais do critério P3 ("regra de negócio nova: papel, permissão... ciclo de vida"), e cada um já bastaria. Reforça: uma premissa nova cujo custo cresce com o tempo (P-029, nome em português) |
| Técnico | T3 | **Migration**, e agora **destrutiva** (`user.role` sai), em dois passos. Também há **mudança em contrato já consumido**: `UserCreate` passa a exigir `link_id`, e a sessão do login passa a preencher `link_id`/`organization_id`. Reforçam: **domínio novo** (`app/domains/links/`), a **primeira `ForeignKey` real** do projeto (`user.link_id → links.id`), e duas colunas (`participant_id`, `organization_id`) que apontam para tabelas que **não existem no banco** |

Dispensadas nesta calibragem: nenhuma.

## Problema

Hoje não existe nenhuma tabela que registre "esta pessoa é gestora desta organização,
desde tal data". A autenticação (CREED-23) já supõe essa peça. A P-008 descreve o
cadastro como a cadeia Organização → Participante → **Vínculo** → Usuário, mas só a ponta
final foi implementada: `user` nasceu com `role` e `name` como colunas próprias, porque
`Vinculo` "ainda não tem tabela" (comentário em
[`users/models.py`](../../../creed-backend/app/domains/users/models.py)). O mesmo buraco
aparece em `form_responses.vinculo_id`, criado pela CREED-34 apontando para uma tabela
que ainda não existe.

A consequência é que o papel de acesso não tem organização nem período. O sistema só
sabe dizer "isto é admin ou não", nunca "isto é gestor **desta** organização". E cada
usuário criado com `role` na própria linha aumenta o custo de corrigir o modelo depois.

## Quem usa

| Papel | O que muda |
|---|---|
| **Administrador** | passa a criar o vínculo de uma pessoa com uma organização (papel, tipo, setor) e, ao criar um acesso, passa a dizer **de qual vínculo** ele é (`link_id`), não mais qual papel ele tem. Tudo pela API; nenhuma tela muda |
| **Todo usuário que faz login** (admin, gestor, respondente) | o papel que vale no login e em cada rota protegida passa a ser o do vínculo. Para quem já tem vínculo, nada muda na prática. **Quem não tem vínculo deixa de entrar** (401). Hoje isso só atinge bancos locais, porque não existe ambiente real com dados (ver "Riscos") |
| Quem desenvolve o front | a sessão troca `vinculo_id` por `link_id` (ADR-0005), então o tipo em `src/types/api.ts` acompanha. Fora o nome, o formato é o mesmo, e `link_id`/`organization_id`, que vinham sempre `null`, passam a vir preenchidos |
| Quem desenvolve o back | ganha o alvo de `form_responses.vinculo_id` (CREED-34), e o papel passa a ter uma fonte só |

## Escopo

**Entra — entrega 1 (aditiva, um PR):**

- Domínio novo `app/domains/links/`, na forma do molde `app/domains/users/`:
  - `models.py` com a tabela `links` e os enums `LinkType` e `Roles`;
  - `repository.py`: `insert` e `get_by_id`;
  - `service.py`: criar vínculo e ler um vínculo por id (a leitura é o que `users`
    consome);
  - `schemas.py`: `LinkCreate` e `LinkResponse`;
  - `dependencies.py` e `router.py`:
    `POST /api/v1/organizations/{organization_id}/links`, guardado por
    `require_role("admin")`, registrado em `app/main.py`.
- **`users` passa a apontar para o vínculo:**
  - `user.link_id`: `UUID`, **nulável** nesta entrega, `unique`, com
    `ForeignKey("links.id")`;
  - `UserCreate` passa a exigir `link_id`. O service confere que o vínculo existe
    (404) e que nenhum outro usuário já o usa (409);
  - `POST /users` passa a ser guardado por `require_role("admin")`. Amarrar um login a
    um vínculo decide o papel e a organização de alguém, pelo mesmo motivo do item 7
    (review, exigência 2);
  - `UserResponse` passa a trazer `role`, `link_id` e `organization_id` lidos do
    vínculo, e não mais da coluna. É o formato `User` que o `contrato-api.md` da
    CREED-23 já publicou;
  - `users` compõe com `LinkService`, declarado em `COMPOE_COM_SERVICE_DE` de
    `tests/test_arquitetura.py` com o motivo ao lado.
- **A guarda e o login passam a ler o papel do vínculo:**
  - em `app/shared/authorization.py`, a conferência "claim do token × banco" passa a
    comparar com o papel do vínculo. Usuário sem vínculo → **401**;
  - `authentication/service.py` monta a sessão com `role`, `link_id` e
    `organization_id` vindos do vínculo.
- **`scripts/seed_local.py`** cria o vínculo do `dev@creed.example.com` (papel `admin`) e
  liga o usuário a ele. Continua idempotente: um usuário que já existe sem vínculo ganha o
  vínculo.
- **Uma** revisão Alembic para esta entrega (`links` + `user.link_id`), mais o
  import do model em `alembic/env.py`.
- Testes: `tests/domains/links/` (a forma da tabela, o service, o contrato HTTP com
  401/403/422), e a atualização de `tests/domains/users/`,
  `tests/domains/authentication/` e `tests/shared/test_authorization.py` para o papel
  vindo do vínculo.

**Entra — entrega 2 (destrutiva, outro PR, só depois de a 1 estar na `dev`):**

- Revisão Alembic que **confere** que nenhum usuário está sem vínculo (e falha com
  mensagem clara se houver), torna `user.link_id` **`NOT NULL`** e **remove**
  `user.role` e o tipo `userrole`.
- `UserRole` sai de `users/models.py`, junto com toda referência que sobrar a ele.

**Entra — no `creed-ai-context`:** esta spec · `glossario.md` (entradas "Vínculo",
"Setor" e "Participante", já feitas) · `decisoes/premissas.md` (P-029, registrada e refutada em 2026-09-29) ·
`context/modelo-de-dados.md` (a pendência 🔴 marcada como decidida, já feito) · o
`contrato-api.md` da CREED-23, na seção "Estado real", atualizado quando a entrega 1
entrar.

**Não entra, e por quê:**

- **Criar as tabelas `Organization` ou `Department`.** Nenhuma subtarefa pede
  isso, e `organizacoes/models.py` continua stub. `participants` foi criada pelo PR #28,
  fora desta tarefa. Mesmo assim `participant_id`, `organization_id` e `department_id`
  nascem **sem `ForeignKey`**, o mesmo padrão de `form_responses.form_id` e
  `form_responses.vinculo_id`. Ver "Abordagem técnica", item 3.
- **Conferir que a organização da URL, o participante ou o setor existem.** Organização
  e setor não têm tabela. O participante tem, mas a conferência (404) vai para a
  amarração, junto com a FK (item 3).
- **Listar, editar ou encerrar um vínculo** (`GET`, `PATCH`, `end_at`). O contrato que a
  tarefa publica tem **um** endereço, o `POST`. Consequência: **não há como trocar o papel
  de alguém** nesta entrega. O buraco é o mesmo que o `contrato-api.md` da CREED-23 já
  registrou, e continua aberto.
- **Enviar o papel ao Keycloak automaticamente** (a decisão D4 da CREED-23). Isso nunca
  foi implementado: `external_services/keycloak/client.py` não chama a Admin API para
  papel, e a realm role continua sendo configurada à mão. Esta tarefa troca **de onde o
  banco lê o papel**; ela não passa a gravar nada no Keycloak.
- **`User.name` → `Participant.name`.** O modelo também tira `name` do `user`, mas a
  decisão do time foi sobre o papel. `name` fica onde está. `participants` já existe
  (PR #28), mas mover o nome é outra tarefa.
- **`UserCreate` no formato final** (`{link_id, email, initial_password}`). Esta
  tarefa só acrescenta `link_id`. `keycloak_id` e `name` continuam no payload,
  porque o cadastro no Keycloak ainda é manual (P-012).
- **Front, além do tipo da sessão.** A sessão troca `vinculo_id` por `link_id`
  (ADR-0005), e isso é renomeação, não mudança aditiva. Por isso o `creed-frontend`
  precisa de um PR par que renomeie o campo em `src/types/api.ts` e nas fixtures de
  teste (review, exigência 4). Nenhum código de tela lê o campo, e o front não chama
  `POST /users`.
- **Regra de unicidade entre vínculos** (ex.: impedir dois vínculos iguais para o mesmo
  participante e organização). O `.dbml` não define `UniqueConstraint` em `Vinculo`.

## Repos afetados

| Repo | O que muda |
|---|---|
| `creed-backend` | domínio novo `app/domains/links/` · `app/domains/users/` (model, schemas, service, dependencies) · `app/shared/authorization.py` · `app/domains/authentication/service.py` · `scripts/seed_local.py` · duas revisões Alembic (uma por entrega) · `alembic/env.py` · `app/main.py` · `tests/test_arquitetura.py` · testes de `links`, `users`, `authentication` e `shared` |
| `creed-ai-context` | esta spec · `glossario.md` · `decisoes/premissas.md` (P-029) · `context/modelo-de-dados.md` · `contrato-api.md` da CREED-23 |
| `creed-frontend` | `src/types/api.ts` e três fixtures de teste: `vinculo_id` → `link_id`, num PR par |
| `creed-infrastructure` | nada |

Nome do domínio: **`links`**, em inglês
([ADR-0005](../../decisoes/adrs/0005-idioma-do-codigo.md); a
[P-029](../../decisoes/premissas.md), que o mantinha em português, foi refutada em
2026-09-29; ver "Abordagem técnica", item 1). A tarefa sugere
`app/domains/participantes/`, e esta spec diverge disso de propósito.

**A tabela `links` bate com `Vinculo` no `.dbml`**, coluna por coluna, só com os nomes em inglês. Depois da
entrega 2, `user` também bate em `link_id` e em não ter `role`. Continua divergindo só
em `name`, que fica para a tarefa que o mover para `Participant`.

## Contrato

Tudo `async`, como no molde (`AsyncSession`).

### Contrato HTTP — novo

| Método | Rota | Guarda | Entrada | Saída |
|---|---|---|---|---|
| POST | `/api/v1/organizations/{organization_id}/links` | `admin` | `LinkCreate` | `LinkResponse` · **201** |

`organization_id` vem da **URL**, não do corpo, como a própria tarefa desenhou a rota.

**`LinkCreate`**

```json
{
  "participant_id": "uuid",
  "department_id": "uuid | null",
  "type": "emprego | mentoria | academico | pessoal",
  "role": "admin | gestor | respondente"
}
```

`department_id` é **opcional** (nulo por padrão): o `.dbml` marca a coluna como nulável, e "o
vínculo pode nascer antes de a organização cadastrar os setores dela". `type` e `role`
são obrigatórios e não têm valor padrão.

**`LinkResponse`**

```json
{
  "id": "uuid",
  "participant_id": "uuid",
  "organization_id": "uuid",
  "department_id": null,
  "type": "emprego",
  "role": "gestor",
  "start_at": "2026-09-24T14:00:00Z",
  "end_at": null,
  "created_at": "2026-09-24T14:00:00Z",
  "updated_at": null
}
```

| Código | Quando |
|---|---|
| 401 | sem token, ou token inválido/expirado |
| 403 | token válido, mas sem papel `admin` |
| 422 | corpo fora do formato (`type`/`role` fora do enum, `participant_id` que não é UUID, campo obrigatório ausente) |

**Não existe 404 nesta rota.** Nada confere se `organization_id` ou `participant_id`
existem. Organização não tem tabela; participante tem, mas a conferência vai para a
amarração (item 3).

### Contrato HTTP — alterado

| Rota | Antes | Depois |
|---|---|---|
| `POST /api/v1/users` — guarda | nenhuma | **`admin`**: 401 sem token, 403 sem o papel. **Quebra quem chamava sem token**; hoje só os testes e o Swagger chamam |
| `POST /api/v1/users` — entrada | `{keycloak_id, name, email}` | `{keycloak_id, name, email, link_id}`. **Quebra quem chama sem `link_id`**; hoje só os testes e o Swagger chamam |
| `POST /api/v1/users` — erros | 409 e-mail repetido | + **404** vínculo inexistente · + **409** vínculo já usado por outro usuário |
| `POST /api/v1/users` — saída (`UserResponse`) | `{id, name, email, status, role, created_at}`, com `role` da coluna | + `link_id`, `organization_id`, e `role` lido do vínculo |
| `POST /api/v1/authentication/login` e `/renew` — `user` da sessão | `role` da coluna; `vinculo_id` e `organization_id` sempre `null` | os três lidos do vínculo. O formato só muda **no nome**: `vinculo_id` vira `link_id` (ADR-0005), e o front renomeia no PR par |
| Qualquer rota protegida | 401 se o claim diverge de `user.role` | 401 se o papel do vínculo não está entre os do token, **ou se o usuário não tem vínculo**. E a rota é decidida pelo **papel do vínculo**: token `[admin, gestor]` com vínculo `gestor` leva **403** numa rota `admin` |

### Contrato interno entre camadas

| Camada | Assinatura | Devolve |
|---|---|---|
| `LinkRepository.insert(link)` | a entidade já montada | `Link` gravado, com `id`, `start_at` e `created_at` |
| `LinkRepository.get_by_id(link_id)` | — | `Link` **ou `None`** |
| `LinkService` — criar | `organization_id`, `LinkCreate` | `Link` criado |
| `LinkService` — ler por id | `link_id` | `Link` **ou `None`**. Quem decide se a ausência é 404 ou 401 é quem chama |
| `UserService` — criar | `UserCreate` | `User`, ou `NotFoundError` (vínculo inexistente) / `ConflictError` (e-mail ou vínculo já usados) |
| `UserService` — o que a guarda e o login consomem | e-mail do token | usuário ativo **com o papel e a organização do vínculo**, ou `None` se o usuário não existe, está inativo ou não tem vínculo |

Os nomes dos métodos ficam para as tasks. O que esta tabela fixa é **quem pergunta a
quem**: `authorization.py` e `authentication` continuam falando só com `UserService`, e
só `UserService` fala com `LinkService`.

## Dados

### Entrega 1 — tabela nova `links`

| Coluna | Tipo | Nulo? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, `default=uuid.uuid4` |
| `participant_id` | `UUID` | não | **sem `ForeignKey`** nesta entrega: a tabela `participants` existe (PR #28), e a FK vai para a amarração (item 3) |
| `organization_id` | `UUID` | não | **sem `ForeignKey`**: a tabela `Organization` não existe |
| `department_id` | `UUID` | sim | **sem `ForeignKey`**: a tabela `Department` não existe |
| `type` | `Enum(LinkType)` | não | `emprego` · `mentoria` · `academico` · `pessoal` |
| `role` | `Enum(Roles)` | não | `admin` · `gestor` · `respondente` (P-006) |
| `start_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |
| `end_at` | `DateTime(timezone=True)` | sim | nulo = vínculo em aberto; nenhum endpoint o preenche nesta tarefa |
| `created_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |
| `updated_at` | `DateTime(timezone=True)` | sim | sem `server_default`; fica nulo, porque não há update |

Índices: `participant_id`, `organization_id` e `department_id`, os três que o `.dbml` pede.
**Nenhuma** `UniqueConstraint`.

### Entrega 1 — coluna nova em `user`

| Coluna | Tipo | Nulo? | Observação |
|---|---|---|---|
| `link_id` | `UUID` | **sim**, só nesta entrega | `unique` (o 1:1 de [C2]) e `ForeignKey("links.id")`, declarada por nome, sem importar o model de outro domínio |

`user.role` **continua existindo** e continua `NOT NULL` com o default `respondente`,
mas **nada mais o lê** depois desta entrega. É o passo "adicionar" da regra 6 de
[`conventions/migrations.md`](../../conventions/migrations.md).

### Entrega 2 — `user` perde `role`

- `user.link_id` vira `NOT NULL`.
- `user.role` sai, e o tipo `userrole` também.
- **Antes** das duas mudanças, a revisão conta os usuários sem vínculo. Se houver algum,
  ela para com uma mensagem dizendo o que fazer (rodar o seed de novo, ou apagar o
  usuário de teste local), em vez de deixar o Postgres responder com um erro genérico de
  `NOT NULL`.

Os valores dos enums são os que a **API** usa. No banco, o tipo guarda o **nome** do
membro (`ADMIN`, `EMPREGO`...), como `user` e `form_responses` já fazem.

**Dado existente:** `links` nasce vazia. `user` tem linhas **só em bancos locais**:
não há ambiente real, nem pipeline de deploy
([`creed-infrastructure/ONBOARDING.md`](../../../creed-infrastructure/ONBOARDING.md)).
Nesses bancos, o usuário do seed ganha vínculo pelo próprio seed. Qualquer outro usuário
criado à mão para testes fica sem vínculo e passa a levar 401 até ser recriado.

**O que fica para a tarefa de amarração:** as `ForeignKey` de
`links.participant_id`, `organization_id` e `department_id`, quando essas tabelas ganharem
migration.

## Abordagem técnica

### Escolhido: domínio `links` isolado, `users` compondo com ele pelo service, e a troca do papel em dois PRs

**1. Domínio próprio, `app/domains/links/`, e não `app/domains/participantes/` como
a tarefa sugere.** O
[`modelo-de-dados.md`](../../context/modelo-de-dados.md#mapa-tabela--domínio-do-backend)
mapeia os dois como domínios **separados**: `participantes` para `Participant` e
`vinculos` para `Vinculo` — no código, `links` e `Link`. Nenhuma subtarefa cria `Participant`, e um domínio
`participantes` sem `Participant` só confunde quem procurar depois.

*Descartado:* seguir literalmente `app/domains/participantes/router_vinculos.py`. Contradiz
o mapa que o time desenhou, e obrigaria a mover o arquivo no dia em que `Participant`
ganhar domínio.

**2. Um `router.py` só, sem sufixo.** Nenhum domínio do projeto nomeia arquivo com
sufixo de entidade.

*Descartado:* `router_vinculos.py`, o nome literal da tarefa.

**3. `participant_id`, `organization_id` e `department_id` sem `ForeignKey`.** É o padrão de
`form_responses` e de `questions.form_id`. `organization_id` e `department_id` apontam
para tabelas que não têm migration. `participant_id` aponta para uma que **tem**:
`participants` chegou à `dev` pelo PR #28, com a tarefa já em andamento. Mesmo assim a FK
dele fica para a amarração, junto com as outras duas, porque exige três coisas que esta
tarefa não calibrou:

- uma revisão nova depois do merge `87beb54d929a` (a `b9fa0c109598` nasce de um ponto do
  grafo em que `participants` ainda não existe);
- o seed criar o participante de dev com o id fixo que ele já usa (item 13);
- o `POST` de vínculo conferir se o participante existe (404), com `links` passando a
  compor com `ParticipantService`.

*Descartado:* `ForeignKey` para tabela inexistente, porque a migration falharia. Também
descartado: criar essas tabelas aqui, o que triplicaria o escopo. E também descartado:
a FK de `participant_id` agora, pelo custo acima (review de 2026-09-30, exigência 3,
opção a).

**4. `Roles` nasce em `links/models.py`, e `UserRole` morre na entrega 2.** Entre as
duas entregas os dois enums convivem, com os mesmos três valores. É uma duplicação com
data para acabar, e não uma dívida.

*Descartado:* subir o enum para `app/shared/`. Pela regra dos dois usos, isso só faria
sentido se os dois usos fossem continuar existindo. Com a mudança do papel, o único
dono que sobra é `links`.

**5. A rota fica em `links/router.py`, com
`prefix="/organizations/{organization_id}/links"`.** O prefixo descreve a URL, não o
dono do arquivo.

*Descartado:* colocar a rota em `organizacoes/router.py`, que misturaria a tabela
`Link` num domínio que nem tem `Organization` ainda.

**6. Nenhuma regra de conflito ao criar um vínculo.** O `.dbml` não define unicidade em
`Link`.

*Descartado:* inventar "um vínculo ativo por participante e organização". Seria decisão
de produto que ninguém tomou.

**7. `POST` de vínculo guardado por `require_role("admin")`.** Aplica a P-008 ao ato que
precede o login.

*Descartado:* rota sem guarda. Criar vínculo decide o papel de acesso de alguém.

**8. `users` fala com `links` pelo `LinkService`, e só `users` faz isso.** É o
mecanismo que o projeto já tem para isso: `COMPOE_COM_SERVICE_DE` em
`tests/test_arquitetura.py`, onde hoje está `"authentication": "le o usuario pelo
UserService"`. Entra `"users"`, com o motivo. `authorization.py` e `authentication`
continuam dependendo só de `UserService`, então a seta fica
`authentication → users → links`, sem ciclo, e `links` não importa ninguém.

*Descartado:* `UserRepository` fazendo `JOIN` com `links`. Seria uma consulta a mais
barata, mas `LEITURA_ENTRE_DOMINIOS` é reservado a domínios de leitura
(`dashboards`, `relatorios`), e `users` não é um deles. Também descartado:
`authorization.py` chamar `LinkService` direto. Espalharia a pergunta "qual é o papel
desta pessoa" por dois lugares, e a CREED-23 concentrou a guarda num arquivo só
justamente para isso.

**9. `UserResponse.role` vira `str`, montado a partir do vínculo.** `users/schemas.py`
não pode importar `Roles` de `links/models.py`: `schemas` não está entre os
submódulos de composição. A sessão (`UserSessionResponse.role`) já é `str`, e o contrato
publicado é string. `de_model()` passa a receber o usuário **e** os dados do vínculo.

*Descartado:* uma `relationship()` do SQLAlchemy entre `User` e `Link`. Faria
`users/models.py` conhecer a classe de outro domínio, que é o acoplamento que o teste de
arquitetura existe para barrar.

**10. `user.link_id` é a primeira `ForeignKey` real do projeto.** Dá para ter a
restrição de verdade, porque `links` nasce na mesma revisão. Ela é declarada por nome
(`ForeignKey("links.id")`), sem importar o model de outro domínio, como o
`modelo-de-dados.md` já prevê para `documents`. `ondelete` fica no padrão (recusar):
apagar um vínculo que tem login seria perder o elo do acesso, e não existe rota de apagar
vínculo.

*Descartado:* deixar sem FK, como nas outras três colunas. Aqui o alvo existe, e a coluna
decide quem entra na plataforma.

**11. A troca do papel é feita em dois PRs: aditivo primeiro, destrutivo depois.** É a
regra 6 de `migrations.md` ("adicionar → migrar dados → remover; nunca as três no mesmo
PR"). A entrega 1 cria o caminho novo e passa toda leitura para ele. Entre as duas, o
seed e o `POST /users` são o passo "migrar dados". A entrega 2 só remove o que ninguém
mais lê.

*Descartado:* um PR só, com `link_id NOT NULL` e o `drop` de `role` juntos. Hoje até
funcionaria, porque não há ambiente real, mas é exatamente o que a regra proíbe, e o
banco local de todos quebraria no mesmo `upgrade`, sem um passo intermediário para
rodar o seed.

**12. `link_id` nulável na entrega 1, e usuário sem vínculo recebe 401.** É o ajuste
barato que o próprio modelo cita ("se alguma das três incomodar, o ajuste barato é
`link_id` nullable"), só que temporário. Tratar "sem vínculo" como "sem papel" é o
menor privilégio possível, e a guarda já responde 401 quando não acha o usuário.

*Descartado:* se o usuário não tiver vínculo, cair de volta para `user.role`. Isso
manteria duas fontes de papel vivas ao mesmo tempo, que é o problema que esta decisão
fecha.

**13. O seed cria o vínculo com `participant_id` e `organization_id` fixos no próprio
script**, como constantes com um comentário dizendo que ficam órfãos até a amarração:
`Organization` ainda não tem tabela, e `participants` tem, mas `links.participant_id`
ainda não tem FK para ela. É dado só do ambiente local, e o seed já recusa rodar fora
dele.

*Descartado:* gerar UUIDs aleatórios a cada execução. Isso quebraria a idempotência, e a
amarração não teria um id conhecido para criar a organização e o participante de
desenvolvimento.

## Critérios de aceite

**Entrega 1**

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro, e `alembic heads`
      devolve **um único head**.
- [ ] `\d links` mostra as dez colunas da seção "Dados", sem nenhuma `ForeignKey`,
      com índices em `participant_id`, `organization_id` e `department_id` e sem
      `UniqueConstraint`.
- [ ] `\d user` mostra `link_id` nulável, `unique`, com FK para `links.id`, e
      `role` ainda presente.
- [ ] `POST /api/v1/organizations/{organization_id}/links` devolve **201** com
      `LinkResponse`; **401** sem token; **403** sem papel `admin`; **422** com
      `type`/`role` fora do enum. Omitir `department_id` grava `NULL`.
- [ ] `POST /api/v1/users` sem token → **401**; sem papel `admin` → **403**; sem
      `link_id` → **422**; com vínculo inexistente → **404**; com vínculo já usado →
      **409**; válido → **201** com `role`, `link_id` e `organization_id` iguais aos
      do vínculo.
- [ ] O login devolve na sessão `role`, `link_id` e `organization_id` do vínculo.
- [ ] Uma rota protegida responde **401** para um usuário sem vínculo, e **401** quando
      o claim do token diverge de `Link.role`, **mesmo que o claim bata com
      `user.role`**. Este é o teste que prova que a coluna deixou de ser lida.
- [ ] Com token `[admin, gestor]` e vínculo `gestor`, uma rota `admin` responde **403**;
      com o mesmo token e vínculo `admin`, responde **200**. É o teste que prova que
      quem decide a rota é o vínculo, e não o papel a mais no realm.
- [ ] `grep -rn "\.role" app/` não encontra nenhuma leitura de `user.role` / `User.role`.
- [ ] `python scripts/seed_local.py` rodado duas vezes seguidas deixa o usuário de dev
      com **um** vínculo `admin`, e o login dele funciona.
- [ ] `tests/test_arquitetura.py` passa, com `users` declarado em
      `COMPOE_COM_SERVICE_DE` e o motivo escrito. `links` não importa nenhum
      domínio.
- [ ] Nenhum `commit()` novo fora de `app/core/database.py`, exceto os que o seed já
      tinha.
- [ ] A migration foi **lida linha a linha**, e quem leu consegue dizer o que cada
      comando faz.

**Entrega 2**

- [ ] Com algum usuário sem vínculo, `alembic upgrade head` **para** com uma mensagem
      que diz o que fazer, e não com o erro genérico do Postgres.
- [ ] Com todos os usuários vinculados, `\d user` mostra `link_id NOT NULL` e sem
      `role`; `\dT` não lista mais `userrole`.
- [ ] `UserRole` não existe mais no código; `grep -rn "UserRole" app/ tests/ scripts/`
      volta vazio.
- [ ] O `downgrade()` recria `role` como coluna nulável. Não dá para inventar o valor
      antigo, e isso fica escrito no docstring da revisão.

## Como verificar

```bash
cd creed-backend
docker compose up -d db
alembic heads
alembic upgrade head
python scripts/seed_local.py && python scripts/seed_local.py
ruff check . && mypy app && pytest
docker compose exec db psql -U creed -d creed -c "\d links" -c "\d user"
```

Exercitar o contrato de ponta a ponta com o admin do seed:

```bash
uvicorn app.main:app --reload
# outro terminal — senha do dev@creed.example.com está no realm (docker/keycloak/realm-creed.json):
TOKEN=$(curl -s -X POST localhost:8000/api/v1/authentication/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"dev@creed.example.com","password":"<senha do realm>"}' | jq -r .access_token)

# a sessão já traz link_id e organization_id preenchidos
curl -s localhost:8000/api/v1/authentication/session -H "Authorization: Bearer $TOKEN"

# cria um vínculo
curl -i -X POST localhost:8000/api/v1/organizations/00000000-0000-0000-0000-000000000001/links \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"participant_id":"00000000-0000-0000-0000-000000000002","type":"emprego","role":"gestor"}'
```

A prova de que `user.role` deixou de ser lida (entrega 1). Trocar à mão a coluna do dev
para `respondente`, sem mexer no vínculo: o login continua `admin`. Trocar o
**vínculo** para `respondente`: a próxima requisição protegida dá **401**, porque o
claim `admin` do realm diverge do banco.

```bash
docker compose exec db psql -U creed -d creed \
  -c "UPDATE \"user\" SET role = 'RESPONDENTE' WHERE email = 'dev@creed.example.com'"
curl -s localhost:8000/api/v1/authentication/session -H "Authorization: Bearer $TOKEN"   # role: admin
```

Entrega 2: criar um usuário sem vínculo direto no `psql` e rodar `alembic upgrade head`.
A revisão tem de parar com a mensagem. Apagar esse usuário e rodar de novo: tem de
passar.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-029 | `Vinculo` e `Setor` mantêm o nome em português no código (tabela, coluna, classe). Na prática, isso fecha a pendência de vocabulário do ADR-0005 para esses dois termos. | ❌ **Refutada em 2026-09-29** por decisão de time: no código são `Link` e `Department` (ADR-0005). A troca foi feita antes de a tabela sair da máquina, sem custo de dado |

Está no ledger ([`decisoes/premissas.md`](../../decisoes/premissas.md)).

**A mudança do papel para o vínculo não é premissa:** é decisão do time, tomada em
2026-09-24, e está registrada na pendência 🔴 do `modelo-de-dados.md`. Ela segue o
modelo que o time já tinha desenhado ([C2], D4), então não depende de resposta da
cliente.

## Riscos

- **Múltiplos heads no Alembic.** CREED-31, CREED-33 e CREED-35 estão em andamento e
  migram a partir do mesmo head (`49ef1d2c7b7e`), e esta tarefa agora tem **duas**
  revisões. **Mitigação:** quem mesclar por último roda `alembic merge` no próprio PR, e
  nunca edita `down_revision` à mão. O CI já barra mais de um head.
- **Todo banco local quebra o login entre as duas entregas, até rodar o seed.** Depois
  da entrega 1, um usuário sem vínculo leva 401, e na tela aparece "e-mail ou senha
  inválidos". É o mesmo sintoma enganoso que o README já descreve para o banco vazio.
  **Mitigação:** a descrição do PR da entrega 1 diz "rode `python
  scripts/seed_local.py` depois do `upgrade`", e o README ganha a mesma linha.
- **O Keycloak não recebe o papel.** A realm role continua configurada à mão. Quando
  alguém é `admin` no realm mas tem um vínculo `gestor`, o **login responde 200**, com
  `role: gestor` na sessão, porque o login não compara papel (comportamento que vem da
  CREED-23). O 401 só aparece na **primeira chamada protegida**. O front então renova a
  sessão uma vez, tenta de novo uma vez, limpa a sessão e mostra "Sessão expirada, faça
  login novamente" logo depois do login. Conferido em 2026-09-30, de ponta a ponta no back
  e lendo `apiClient.ts` no front. O comportamento é correto (a guarda recusa a
  divergência), mas vai parecer bug. O sinal de que virou problema: alguém "corrigir" a
  guarda para aceitar a divergência. O conserto certo é a tarefa do espelhamento D4.
- **Papel a mais no realm.** Pelo mesmo motivo, alguém pode ficar com dois papéis no
  realm, por exemplo depois de ser rebaixado só no vínculo. A guarda decide pelo papel do
  vínculo (403 numa rota que o vínculo não cobre), então o papel a mais não abre
  nada. Mas a sessão só funciona enquanto o papel do vínculo estiver entre os do token.
- **Não há como trocar o papel de ninguém.** Sem `PATCH` de vínculo, um papel errado só
  se corrige no `psql`. É o buraco que o `contrato-api.md` da CREED-23 já registrou;
  esta tarefa deixa de ter a desculpa de "não há tabela", mas não o fecha.
- **Entre as entregas 1 e 2, `user.role` existe e ninguém a lê.** Alguém pode voltar a
  lê-la de passagem. **Mitigação:** o critério "`grep` não encontra leitura de
  `user.role`" e o teste da divergência (claim bate com a coluna, mas não com o vínculo →
  401). E a entrega 2 não deve esperar mais do que a sprint.
- **O vínculo aponta para participante, organização ou setor que não existem**, e o do
  seed aponta para ids fixos órfãos. Quando a amarração criar essas `ForeignKey`, o banco
  vai recusar toda linha órfã. **Mitigação:** a mesma da CREED-33/35: nada disso sai do
  ambiente local antes da amarração, e a amarração cria a organização e o participante de
  dev com os ids que o seed já usa.
- **A primeira `ForeignKey` real muda a ordem de tudo.** Um teste que cria `User` sem
  criar `Link` antes, contra banco real, passa a falhar. Os testes de service do
  projeto usam repository fake, então o risco está nos testes contra banco e no seed. O
  sinal é um `IntegrityError` em `fk_user_link_id_links`.
- ~~**Nome em português (P-029) sem confirmação formal do time.**~~ Resolvido em
  2026-09-29: o time decidiu `Link` e `Department`, e a troca foi feita com a tabela
  ainda vazia.
