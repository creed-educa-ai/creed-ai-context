# 86e3anvgg — CREED-33 · Form table context

> Gerada por `workflows/tarefa-to-spec.md` em 2026-09-21, a partir do épico
> [CREED-33](https://app.clickup.com/t/86e3anvgg) e das três subtarefas publicadas
> ([331](https://app.clickup.com/t/86e3ap0uf) · [332](https://app.clickup.com/t/86e3ap9jv) ·
> [333](https://app.clickup.com/t/86e3apa4p)).
>
> Segunda tarefa a passar pelo processo pilotado na
> [CREED-31](../86e3ank84-answer-table/spec.md). Diferença de conduta, decidida pelos
> AGES IV em 2026-09-21: aqui o conteúdo do épico e das subtarefas é **sobrescrito**, não
> acrescentado ao lado. Não há rótulo `[REFINADA]` e não há duas versões convivendo no
> board.

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | **O que conta como pronto depende de decisão que a cliente não deu.** O épico promete a "casca" com **nome e status**, e a tabela `Form` do modelo de dados **não tem coluna de nome** — é a pendência #17, registrada em aberto (*"`Form` não tem título nem descrição. Como o gestor identifica um formulário numa lista? Não acrescentado na proposta: é campo de produto, não correção"*). Soma-se a pendência #21, também aberta (*"O que `Form.participant_id` significa agora?"*), e **três premissas novas** (P-016, P-017, P-018). |
| Técnico | T3 | **Migration** — a subtarefa 331 é uma revisão Alembic, e um sinal de T3 basta. Reforçam: **domínio novo** (`app/domains/` não tem `forms`), **contrato de API novo** (`POST` e `GET /api/v1/forms`), e **risco de head divergente** — a CREED-34 está em review com a revisão `49ef1d2c7b7e` gerada a partir do mesmo head. |

Dispensadas nesta calibragem: nenhuma.

## Problema

Não existe onde guardar um formulário. O banco da plataforma tem **uma tabela só**
(`user`, criada pela revisão `0b0ad39d779a`); o resto do modelo desenhado pelo time
existe apenas no diagrama. Sem a tabela `form`, nada do instrumento tem onde se
pendurar: a pergunta aponta para um formulário, a resposta de alguém aponta para um
formulário, e o painel agrega por formulário.

O caso mais concreto já está em cima da mesa: a **CREED-34 está em review** com a tabela
`form_response`, e a coluna `form_id` dela aponta para uma tabela que ainda não existe.
Esta tarefa é o alvo daquela seta.

Há um segundo problema, este dentro da própria tarefa: **o épico e as subtarefas
descrevem entregas diferentes.**

- O épico promete a casca com "**nome** e status" — e o modelo de dados não tem coluna de
  nome, por decisão registrada.
- O épico chama a saída de `FormResponse` — que é o **nome de outra tabela**, a da
  CREED-34.
- A subtarefa 331 manda criar em `form/models.py`; a 333 manda `app/domains/forms/`. As
  duas são do mesmo épico e discordam da pasta.
- A subtarefa 333 pede `service.get_by_id()`, que a convenção de camadas chama de
  "repository disfarçado".

Esta spec existe, em boa parte, para que esses quatro conflitos morram em um lugar só.

## Quem usa

**Nesta rodada, quase ninguém — e isso é a informação, não uma lacuna.** Nenhuma tela do
`creed-frontend` muda. O que nasce é uma porta de API que ninguém no produto ainda abre:
quem exercita é dev, pelo Swagger ou por `curl`.

| Papel | O que essa pessoa faz | O que esta entrega sustenta |
|---|---|---|
| **Administrador** — quem administra a plataforma | cria e mantém os instrumentos | passa a conseguir criar a casca de um formulário e consultá-la por identificador |
| **Gestor** — quem administra uma organização parceira | monta os instrumentos da organização dele | idem, dentro da organização dele — **a verificação de que a organização é a dele não existe nesta rodada**; ver "Riscos" |
| **Respondente** — pessoa que responde aos instrumentos | responde o que o gestor montou | nada muda: um formulário `draft` e sem perguntas não é respondível |
| **Quem desenvolve** | — | ganha o alvo de `form_response.form_id` (CREED-34), de `question.form_id` (CREED-35) e de `dashboard.form_id` |

Definições que quem lê precisa ter na mão (de [`glossario.md`](../../glossario.md) e do
modelo de dados):

- **Formulário** — o instrumento que a plataforma aplica: um conjunto de perguntas que
  uma pessoa responde. Esta tarefa cria **só a casca** dele; as perguntas são a CREED-35.
- **Organização** — instituição parceira à qual as pessoas respondentes pertencem. **O
  dono do formulário é a organização, não uma pessoa** — correção `[C1]` do modelo de
  dados.
- **Rascunho (`draft`)** — o formulário existe mas não está no ar. É o único estado em
  que um formulário nasce.

## Escopo

**Entra:**

- Domínio `forms` em `app/domains/forms/`, seguindo a forma do molde `app/domains/users/`.
- `models.py` com a tabela `form`: `id`, `name`, `organization_id`, `status`, `created_at`.
- Migration Alembic isolada, que cria **só** esta tabela, mais o import do model em
  `alembic/env.py`.
- `repository.py` com o acesso ao dado (`insert`, `get_by_id`).
- `service.py` com a regra de criação e busca.
- `schemas.py` com `FormCreate` (entrada) e `FormRead` (saída).
- `dependencies.py` montando a cadeia sessão → repository → service.
- `router.py` com `POST /api/v1/forms` e `GET /api/v1/forms/{form_id}`, registrado em
  `app/main.py`.
- Testes em `tests/domains/forms/`: forma da tabela, regra e contrato HTTP.
- **No `creed-ai-context`:** o modelo de dados passa a descrever a tabela `form` como ela
  existe — com `name`, sem `participant_id` — e as pendências #17 e #21 ganham desfecho
  escrito. É a entrega 4, e é a única que sai do `creed-backend`.

**Não entra — e por quê:**

- **As chaves estrangeiras.** `organization_id` aponta para `organization`, que não
  existe (CREED-38, no backlog). Decisão de time de 2026-09-19: migrations isoladas
  agora, uma tarefa de **amarração** depois. É o mesmo caminho que a CREED-34 já seguiu
  em review.
- **A coluna `participant_id`.** Pendência #21 do modelo de dados, em aberto: ninguém
  sabe hoje o que ela significa. Ver premissa P-018 e "Abordagem técnica".
- **A verificação de que a organização existe, e de que quem chama pertence a ela.**
  A primeira depende de `organization` existir; a segunda depende de `vinculo`. Nenhuma
  das duas tem tabela. ⚠️ Consequência declarada em "Riscos".
- **Transição de estado** (`draft` → `published` → `closed`). Publicar um formulário sem
  pergunta nenhuma não faz sentido, e `question` é a CREED-35. O endpoint que muda o
  estado nasce com a tarefa que precisar dele. Ver P-017.
- **Listagem de formulários** (`GET /api/v1/forms`). Uma listagem sem filtro por
  organização devolveria o formulário de todas as organizações para qualquer um. O
  filtro depende de autorização, que depende de `vinculo`.
- **Editar e apagar formulário.** Ninguém pediu, e o épico não promete.
- **As perguntas e as alternativas.** CREED-35 e CREED-37.
- **Front.** Nada muda no `creed-frontend` nesta entrega.

## Repos afetados

| Repo | O que muda |
|---|---|
| `creed-backend` | domínio novo `app/domains/forms/` · uma revisão Alembic · import em `alembic/env.py` · registro em `app/main.py` · testes em `tests/domains/forms/` |
| `creed-ai-context` | `context/modelo-de-dados.proposta.dbml` e `context/modelo-de-dados.md` — a reconciliação da entrega 4 |
| `creed-frontend` | nada |
| `creed-infrastructure` | nada |

A entrega 4 é o motivo de o `creed-ai-context` aparecer aqui. Ela é **subtarefa separada**,
não um item da entrega 1, porque
[`spec-to-tasks.md`](../../workflows/spec-to-tasks.md) proíbe task que cruza repos — e
porque o "pronto quando" de uma é `alembic upgrade`, o da outra é um diff de documentação.

Nome do domínio: **`forms`** — inglês, `snake_case`, plural.

Inglês por padrão em identificador é o [ADR-0005](../../decisoes/adrs/0005-idioma-do-codigo.md);
plural em `snake_case` é [`conventions/estrutura-e-nomes.md`](../../conventions/estrutura-e-nomes.md).
Por isso **não** é `form` no singular (como diz a subtarefa 331) nem `formularios` (como
diz o mapa tabela → domínio do `modelo-de-dados.md`, escrito antes do ADR-0005).

> ⚠️ A CREED-34, em review, criou `app/domains/respostas/` — **português**. É desvio do
> ADR-0005 que já está em código e **esta tarefa não corrige**; corrigir de passagem é
> escopo que ninguém pediu ([`context/trabalho-com-ia.md`](../../context/trabalho-com-ia.md),
> regra 4). Fica em "Riscos".

## Contrato

Tudo `async`, porque o molde é `async` (`AsyncSession`).

### Contrato HTTP

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/forms` | `{"name": "...", "organization_id": "<uuid>"}` | `FormRead` · **201** |
| GET | `/api/v1/forms/{form_id}` | — | `FormRead` · **200** |

**Corpo da saída (`FormRead`)**

```json
{
  "id": "uuid",
  "name": "string",
  "organization_id": "uuid",
  "status": "draft",
  "created_at": "2026-09-21T14:00:00Z"
}
```

**Erros**

| Código | Quando | Corpo |
|---|---|---|
| 404 | `form_id` não existe | `{"detail": "..."}` — do `NotFoundError` |
| 422 | corpo fora do formato (`name` curto demais, `organization_id` que não é UUID) | validação padrão do FastAPI |

Duas diferenças em relação ao contrato publicado no épico, as duas deliberadas:

1. **`status` não entra no corpo do POST.** O épico manda `{organization_id, status}`. O
   formulário nasce sempre `draft` (P-017), então aceitar o campo é oferecer uma escolha
   que não existe. É o mesmo corte que `UserCreate` já faz com `role` —
   `contrato-api.md` da CREED-23 é explícito: *"mandar `role` no POST é sintoma de ter
   entendido o modelo ao contrário"*.
2. **A saída chama-se `FormRead`, não `FormResponse`.** `FormResponse` é o nome de
   **outra tabela** — a da CREED-34, que registra "fulano abriu e respondeu o formulário
   X" — e já existe como classe em `app/domains/respostas/models.py`. Duas coisas
   diferentes com o mesmo nome no mesmo repositório é confusão garantida no primeiro
   import. O desvio do sufixo `<Entidade>Response` do molde é consciente, e a subtarefa
   333 já tinha chegado nele sozinha.

### Contrato interno entre camadas

| Camada | Assinatura | Devolve |
|---|---|---|
| `repository.insert(form: Form)` | recebe a entidade já montada | `Form` persistido, com `id` e `created_at` preenchidos |
| `repository.get_by_id(form_id: UUID)` | — | `Form` **ou `None`** — o repository não levanta erro |
| `service.create(dados: FormCreate)` | o payload já validado | `Form` criado, em `draft` |
| `service.get(form_id: UUID)` | — | `Form`, ou `NotFoundError` |

Os nomes seguem [`conventions/camadas-do-back.md`](../../conventions/camadas-do-back.md)
→ "Nome do método diz de qual camada é": **o service nomeia o caso de uso**, **o
repository nomeia o acesso**.

> ⚠️ **Divergência com a subtarefa 333**, que pede `service.create_form()` e
> `service.get_by_id()`. `get_by_id` em service é "repository disfarçado" — o nome
> descreve **como** se busca, que é assunto do banco. E `create_form` repete o assunto
> que a classe já carrega: `FormService.create()` não é ambíguo.

## Dados

Tabela `form`. A migration desta rodada cria **exatamente** isto:

| Coluna | Tipo | Nulo? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, `default=uuid.uuid4` |
| `name` | `String(200)` | não | **acrescentada ao modelo** — ver P-016 |
| `organization_id` | `UUID` | não | **sem `ForeignKey`** nesta rodada |
| `status` | `Enum(FormStatus)` | não | `draft` · `published` · `closed`, `default=DRAFT` |
| `created_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |

Índice criado agora: `organization_id`. É a coluna do `WHERE` de "os formulários da minha
organização", que é a primeira consulta que vai existir.

**Nenhuma restrição de unicidade.** Dois formulários com o mesmo nome na mesma
organização são aceitos — ver P-016.

**O que fica para a tarefa de amarração**, declarado para que ninguém descubra no meio:

- `ForeignKey` em `organization_id → organization.id`;
- a coluna `participant_id` + índice + `ForeignKey → participant.id`, **se** a pendência
  #21 decidir que formulário nominal existe.

**Dado existente:** nenhum. A tabela nasce vazia. Diferente da `answer` da CREED-31, ela
**não** precisa continuar vazia: a FK que falta (`organization_id`) já é `NOT NULL`, então
a amarração é um `ALTER TABLE ADD CONSTRAINT` — e o que ele exige é que todo
`organization_id` gravado exista de verdade na tabela `organization` quando ela nascer.
Linha criada com identificador inventado **vai travar a amarração**. Ver "Riscos".

## Abordagem técnica

### Escolhido: domínio `forms`, tabela com `name`, sem FK, sem `participant_id`, com router

**1. Domínio `forms`, e `Form` sozinho nele por enquanto.** O mapa tabela → domínio
prevê `Form`, `Question` e `QuestionOption` juntos — são o instrumento, um assunto só. A
CREED-35 e a CREED-37 entram nesta mesma pasta.

*Descartado:* um domínio por tabela (`forms`, `questions`, `question_options`).
`tests/test_arquitetura.py` proíbe um domínio importar o outro por dentro, e a pergunta
precisa do formulário — a CREED-35 nasceria já pedindo exceção na lista de permitidos.

**2. A tabela ganha `name`, que o modelo não tem.** É a pendência #17 do modelo,
resolvida por premissa (P-016) em vez de ficar aberta. O épico pede, e é o que permite
distinguir dois formulários numa lista — sem ele o gestor escolhe por UUID.

*Descartado:* seguir o `.dbml` ao pé da letra e não criar a coluna. Seria fiel ao modelo
fechado em 2026-09-04, mas nenhuma outra tarefa do board acrescenta o campo depois, e a
descrição do épico teria de perder a palavra "nome". A tabela nasce vazia, então a coluna
é barata de tirar e cara de esquecer.
⚠️ **Consequência:** `context/modelo-de-dados.proposta.dbml` passa a divergir do código.
Isso **tem dono**: é a entrega 4. Reexportar o dbdiagram continua fora — depende de o time
aceitar a proposta inteira.

**3. `organization_id` fica, `participant_id` não entra.** A regra é a mesma que a
CREED-31 aplicou: **coluna que dá sentido à linha fica; coluna que é pura ligação, e cujo
destino não existe, espera.** `organization_id` é o dono do formulário — sem ele a linha
não significa nada, nem isolada. `participant_id` é nulável, e o próprio modelo diz que
não se sabe o que ela quer dizer (#21).

*Descartado:* criar `participant_id` agora, nulável, para "não faltar". Coluna de
significado desconhecido é pior do que coluna ausente: alguém grava nela, e a decisão de
produto passa a ter dado atrás. Acrescentar coluna nulável depois é uma migration de uma
linha, sem backfill.

**4. A tabela nasce sem nenhuma `ForeignKey`.** Consequência direta da decisão de time de
2026-09-19 (migrations isoladas, amarração depois), e é o que a CREED-34 já fez em review
— `form_response.form_id` é `UUID NOT NULL` sem FK.

*Descartado:* criar já com a FK para `organization`. Seria o desenho correto **se** a
tabela-alvo existisse; como não existe, exigiria ordenar as dez tarefas de tabela numa
fila única, que é exatamente o que a decisão de migrations isoladas evitou.

**5. Os endpoints entram nesta rodada.** Decisão dos AGES IV em 2026-09-21, ciente do
preço: `POST /api/v1/forms` aceita qualquer `organization_id` sem conferir. O que sustenta
a escolha: o épico existe para entregar a API, não há outra tarefa no board que receberia
a rota, e a CREED-34 já publicou as rotas dela sobre colunas igualmente não validadas —
recusar aqui seria incoerência na direção oposta.

*Descartado:* espelhar a CREED-31 e entregar só fundação. Lá a rota tinha outro dono (a
submissão, CREED-34); aqui `POST /forms` ficaria sem casa por tempo indeterminado.

**6. `status` não entra no corpo do POST, e o service é quem aplica `draft`.** O default
do model é a rede para quem construir um `Form` por fora; em conflito, vale a linha do
service. É exatamente o que `UserService.create_user_service` faz com `status` —
[ADR-0004](../../decisoes/adrs/0004-camadas-do-backend.md): *"se muda quando o produto
muda de ideia, é service"*.

**7. Tudo `async`, e o repository faz `flush()`/`refresh()` — nunca `commit()`.** Não é
escolha: é o que o molde faz e o que `tests/test_arquitetura.py` cobra.

## Critérios de aceite

- [ ] `docker compose up -d db && alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] `alembic heads` devolve **um único head** — se devolver dois, a saída é `alembic merge`, nunca editar `down_revision` à mão.
- [ ] A tabela `form` tem exatamente as cinco colunas da seção "Dados", com os mesmos tipos e a mesma nulabilidade.
- [ ] A tabela `form` **não** tem nenhuma `ForeignKey` e **não** tem a coluna `participant_id`.
- [ ] Existe índice em `organization_id`.
- [ ] O model novo está importado em `alembic/env.py`.
- [ ] `service.create` devolve um formulário com `status = draft`, mesmo que o corpo tente mandar outro valor.
- [ ] `service.get` levanta `NotFoundError` quando o id não existe; `repository.get_by_id` devolve `None` no mesmo caso.
- [ ] `POST /api/v1/forms` devolve **201** com o corpo de `FormRead`.
- [ ] `GET /api/v1/forms/{id}` devolve **200** quando existe e **404** quando não existe.
- [ ] `POST` com `name` vazio ou `organization_id` que não é UUID devolve **422**.
- [ ] Nenhum `commit()` no diff, fora de `app/core/database.py`.
- [ ] A migration gerada foi **lida linha a linha**, e quem leu consegue dizer o que cada comando faz.
- [ ] `pytest tests/test_arquitetura.py` passa — nenhuma camada furada no domínio novo.

## Como verificar

```bash
cd creed-backend
docker compose up -d db
alembic current
alembic heads
alembic upgrade head
ruff check . && mypy app && pytest
```

Conferir a forma da tabela no banco:

```bash
docker compose exec db psql -U creed -d creed -c "\d form"
```

Exercitar o contrato de ponta a ponta:

```bash
uvicorn app.main:app --reload
# outro terminal:
curl -X POST localhost:8000/api/v1/forms \
  -H 'Content-Type: application/json' \
  -d '{"name":"Instrumento piloto","organization_id":"00000000-0000-0000-0000-000000000001"}'
```

Caso de borda que precisa passar — derrubar tudo e subir de novo reproduz exatamente o
mesmo banco:

```bash
docker compose down -v && docker compose up -d db && alembic upgrade head
```

⚠️ `docker compose down -v` apaga o volume inteiro, e com ele o schema `keycloak` do
ambiente local — quem subir de novo precisa esperar o `init-keycloak-schema.sql` rodar e
reimportar o realm. É o preço de conferir que a migration sobe do zero; rode com isso em
mente, não no meio de outra tarefa que dependa do login local.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-016 | O formulário tem **nome**: coluna `name`, obrigatória, sem unicidade. Dois formulários com o mesmo nome na mesma organização são aceitos. | baixo — a tabela nasce vazia; tirar a coluna ou acrescentar o índice único é uma migration de uma linha |
| P-017 | O formulário **nasce sempre `draft`**, e `status` não entra no corpo da criação. A transição para `published`/`closed` nasce com a tarefa que precisar dela. | baixo — é uma linha no service e um campo no schema de entrada |
| P-018 | **Formulário é da organização, não de uma pessoa.** A coluna `participant_id` não entra nesta rodada. | baixo — acrescentar coluna nulável depois é migration de uma linha, sem backfill |

**As três foram fechadas como ✅ confirmadas em 2026-09-21, por decisão dos AGES IV** — não
da cliente. Estão na seção "Fechadas" do ledger
([`decisoes/premissas.md`](../../decisoes/premissas.md)), com o desfecho e quem decidiu.
**Não vão para a pauta**, com uma exceção nomeada logo abaixo.

Adotar a interpretação mais provável **sem** torná-la cara de reverter é o critério 2 de
[`conventions/premissas-e-duvidas.md`](../../conventions/premissas-e-duvidas.md) — e o
custo de reverter continua baixo nas três, mesmo fechadas.

⚠️ **A exceção: P-018 fecha a premissa, não a pergunta.** A pendência **#21** do
[`modelo-de-dados.md`](../../context/modelo-de-dados.md) — *"existe formulário feito sob
medida para uma pessoa específica?"* — está na lista de **lacunas de produto** daquele
arquivo, ao lado de papéis e prisma, e **continua valendo para a cliente**. O que ficou
decidido é que a coluna não nasce agora; o que o produto é continua pergunta dela. Se a
resposta for "existe", a volta é coluna nulável mais a relação: migration de uma linha,
sem backfill.

P-016 fecha também a pendência **#17** (*"`Form` não tem título nem descrição"*), e essa
sim deixa de ser pergunta: todo formulário tem nome.

## Riscos

- **`POST /api/v1/forms` aceita organização inventada.** Não há tabela `organization`
  para conferir, e a rota entra nesta rodada por decisão consciente. Sinal de que deu
  errado: a tabela `form` com linhas cujo `organization_id` não corresponde a nenhuma
  organização quando a CREED-38 nascer — **e aí a amarração trava**, porque
  `ADD CONSTRAINT` recusa linha órfã. Mitigação: **nada de seed, fixture ou carga inicial
  gravando em `form`**; o que for criado à mão em desenvolvimento é descartável e sai no
  `docker compose down -v`.
- **Conflito de heads no Alembic, com nome e sobrenome.** A CREED-34 está **em review**
  com a revisão `49ef1d2c7b7e`, gerada a partir de `0b0ad39d779a` — o mesmo head de onde
  esta tarefa vai gerar. Se as duas mesclarem, `alembic heads` devolve duas linhas.
  Mitigação: rodar `alembic current` **imediatamente antes** de gerar; se a CREED-34 já
  tiver mesclado, a revisão desta tarefa nasce sobre `49ef1d2c7b7e`. Se as duas já
  estiverem no `dev`, a saída é `alembic merge` — nunca editar `down_revision` à mão
  ([`conventions/migrations.md`](../../conventions/migrations.md), regra 3).
- **Quem pode criar formulário não é verificado.** Qualquer chamada autenticada — ou
  nenhuma, já que a rota não exige token — cria formulário para qualquer organização.
  Autorização por organização depende de `vinculo`, que não tem tabela. Sinal: a rota
  chegando a ambiente que não seja o local. Mitigação: esta API **não vai para produção
  antes da amarração**, e isso precisa estar dito para quem cuida do deploy (CREED-28).
- **`forms` em inglês × `respostas` em português.** A CREED-34 criou o domínio dela em
  português, contra o ADR-0005. Esta tarefa segue o ADR e **não corrige a vizinha**.
  Sinal: o `app/domains/` com os dois idiomas convivendo — que é o estado que o próprio
  ADR-0005 já declarou aceitar por prazo indeterminado. Mitigação: nenhuma aqui; o
  assunto é da revisão da CREED-34.
- **O `.dbml` passa a divergir do código** em duas linhas: a coluna `name` que entra
  (P-016) e a `participant_id` que não entra (P-018). Sinal: alguém abrir o modelo, não
  achar `name`, e "corrigir" o código apagando a coluna. **Mitigação: a entrega 4**, que
  reconcilia o modelo — e uma frase na entrega 1 apontando para ela, para que a divergência
  seja encontrada explicada em vez de descoberta crua.
- **A reconciliação do modelo tem um teto que esta tarefa não alcança.** A entrega 4
  corrige a `proposta.dbml`; o diagrama do time no dbdiagram continua desatualizado, porque
  colá-la de volta exige aceitar a proposta **inteira** — decisão de time, listada em
  [`modelo-de-dados.md`](../../context/modelo-de-dados.md) → "Quando o modelo for aceito".
  Sinal de que isso está custando: uma terceira tarefa de tabela redescobrindo a mesma
  divergência.
- **Outras duas divergências já existem e não são desta tarefa.** A CREED-31 decidiu não
  criar `Answer.form_response_id`, que o modelo traz como `not null`; e a migration da
  CREED-34, em review, cria `form_response` **sem nenhum índice** — o modelo pede três,
  incluindo o `unique (form_id, vinculo_id)` da correção `[C5]`, que existe para impedir o
  mesmo vínculo responder o mesmo formulário mais de uma vez. A entrega 4 **confere e
  reporta**; corrigir é da revisão daquelas tarefas.
- **O molde mudou no meio do caminho.** `app/domains/respondentes/` foi removido
  (CREED-41, em progresso) e o molde passou a ser `app/domains/users/`. Quem tiver aberto
  a CREED-31 vai encontrar permalinks para o molde antigo. Sinal: um `FormService.criar()`
  em português, copiado do resíduo. Mitigação: **todos os permalinks desta tarefa apontam
  para `users`**.
