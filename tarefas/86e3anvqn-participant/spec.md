# 86e3anvqn — CREED-36 Participant

> Épico com três subtarefas no ClickUp: CREED-361 (tabela), CREED-362 (repository e
> service), CREED-363 (schema e router). A decomposição sai no `/tasks`.

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | regra de negócio nova: quem pode cadastrar e consultar pessoa (P-022). Também: o contrato pede `document_id`, mas nenhuma API cria documento (P-021), e a descrição fala em "pessoas físicas ou jurídicas", o que diverge do modelo |
| Técnico | T3 | migration (tabela `participants`); FK para `documents`, que ainda não está na `dev`; enum `recordstatus` compartilhado com `user`; primeira rota a usar `require_role` |

Dispensadas nesta calibragem: nenhuma.

## Problema

A plataforma não tem onde registrar **a pessoa**. Hoje só existe o **login** (`user`). Pelo
modelo do time, a mesma pessoa em duas organizações tem dois logins e **um só
participante** ([C2]), e é no participante que as análises se juntam. Sem essa tabela, a
cadeia de cadastro Organização → Participante → Vínculo → Usuário (P-008) não tem o
segundo elo, e nada que dependa da pessoa (demográficos, vínculo, respostas) pode começar.

## Quem usa

| Papel | O que faz nesta entrega |
|---|---|
| `admin` | cadastra um participante e consulta um participante pelo identificador |
| `gestor`, `respondente` | nada: recebem **403** nas duas rotas (P-022) |
| Time interno | usa o participante como base para CREED-40 (demográficos) e para o vínculo |

**Participante** é a pessoa física que responde às avaliações ou acessa a plataforma,
independente de a que organização pertença. Uma pessoa, um participante, mesmo com vários
logins.

## Escopo

**Entra:**
- Tabela `participants` com migration própria.
- Domínio `participants` no backend: model, repository, service, schemas, router e
  dependencies, na forma do molde `app/domains/users/`.
- `POST /api/v1/participants`: cadastra com `name` e `document_id` opcional.
- `GET /api/v1/participants/{participant_id}`: consulta um participante.
- As duas rotas protegidas por `require_role("admin")`.
- Serviço mínimo no domínio `documents` para o `participants` perguntar se um documento
  existe, sem importar o model de outro domínio.
- Mover o enum `RecordStatus` de `users` para `app/shared/`, porque `User` e `Participant`
  usam o mesmo tipo do banco.

**Não entra:**
- **Gênero e demais dados demográficos**: são da CREED-40. O modelo põe `gender` em
  `Participant`, mas as opções do modelo (`masc`, `fem`, `outro`, `nao_informado`) e as do
  front (`feminino`, `masculino`, `nao_binario`, `prefiro_nao_informar`) divergem, e
  resolver isso é da tarefa dona dos demográficos.
- **`address`**: o modelo o deixou opcional ([C19]) porque nenhuma tela usa. Entra quando
  alguma tela pedir.
- **Pessoa jurídica.** A descrição fala em "pessoas físicas ou jurídicas", mas no modelo
  a pessoa jurídica é `Organization`, com documento próprio ([C3]). Participante é só
  pessoa física.
- **Criar, editar ou listar documento.** Só se consulta se o documento existe (P-021).
- **Listar, editar, desativar ou apagar participante.** `status` nasce `active` e nenhuma
  rota o muda.
- **Vínculo com organização** (`Vinculo`): outra tarefa.
- **Proteger as rotas já existentes** (`/users` também não tem guarda). Fica como está.
- Front: nenhuma tela consome estas rotas nesta entrega.

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-backend | domínio novo `participants`; `documents` ganha `repository.py` e `service.py` mínimos; `RecordStatus` vai para `app/shared/`; migration nova; import em `alembic/env.py`; uma entrada em `COMPOE_COM_SERVICE_DE` no `tests/test_arquitetura.py` |
| creed-frontend | nada nesta entrega |
| creed-infrastructure | nada |

Nome do domínio: `participants`. A descrição no ClickUp diz `participantes`, mas o
[ADR-0005](../../decisoes/adrs/0005-idioma-do-codigo.md) manda código em inglês, e a
própria descrição já usa `/api/v1/participants` e a tabela `Participant`. O mapa tabela →
domínio de `context/modelo-de-dados.md` ainda está em português, anterior ao ADR.

## Contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/participants` | `ParticipantCreate` `{name, document_id?}` | `ParticipantResponse` · 201 |
| GET | `/api/v1/participants/{participant_id}` | — | `ParticipantResponse` · 200 |

`ParticipantCreate`:
- `name`: texto, obrigatório, 1 a 200 caracteres, com espaços das pontas removidos.
- `document_id`: UUID, opcional.

`ParticipantResponse`: `id`, `name`, `document_id` (pode ser nulo), `status`
(`"active"`), `created_at`, `updated_at` (pode ser nulo).

| Situação | Status |
|---|---|
| sem token ou token inválido | 401 |
| token de quem não é `admin` | 403 |
| `name` vazio ou longo demais, `document_id` malformado | 422 |
| `document_id` de documento que não existe | 422 |
| `document_id` já ligado a outro participante | 409 |
| `GET` de um id que não existe | 404 |

As duas rotas documentadas no Swagger no padrão do PR #17: `summary`, `description`,
`operation_id`, exemplos e respostas de erro. O `tests/test_openapi.py` passa a cobrar isso
delas.

## Dados

Tabela nova `participants`. Vem do bloco `Participant` de
`context/modelo-de-dados.proposta.dbml`, **sem** `gender` e `address` (ver "Não entra"):

| Coluna | Tipo | Regra |
|---|---|---|
| `id` | uuid | PK, gerado no Python (`uuid4`), igual a `users` e `documents` |
| `name` | varchar(200) | not null |
| `document_id` | uuid | nullable, **unique**, FK → `documents.id` |
| `status` | `recordstatus` | not null, default `ACTIVE`: o **mesmo tipo** do `user` |
| `created_at` | timestamptz | not null, default `now()` |
| `updated_at` | timestamptz | nullable, atualizado a cada alteração |

- **Dependência:** a FK exige a tabela `documents`, que chega com o PR #13 (CREED-27.3).
  A migration desta tarefa vem depois do head que o #13 deixar na `dev`.
- **O tipo `recordstatus` já existe** no banco (criado pela migration do `user`). A
  migration de `participants` **não** o cria e o `downgrade` **não** o apaga. Quem apaga é
  o `downgrade` do `user`.
- Índice: o `unique` em `document_id` já cria um. Nenhuma outra coluna entra em filtro
  nesta entrega.
- Dado existente: nenhum. A tabela nasce vazia.

## Abordagem técnica

**1. Como o `participants` sabe se o documento existe.**

- **Escolhida:** `documents` ganha `repository.py` com `get_by_id` e `service.py` com
  `document_exists(document_id) -> bool`. O `ParticipantService` recebe um
  `DocumentService` e pergunta antes de inserir. É a regra de `context/arquitetura.md`:
  dado de outro domínio vem pelo `service.py` do dono. A composição precisa ser
  **declarada** em `tests/test_arquitetura.py`, no dicionário `COMPOE_COM_SERVICE_DE`:
  `"participants": "consulta documento pelo DocumentService"`, no mesmo formato da entrada
  que já existe para `authentication`. Sem essa linha, o `test_dominio_nao_importa_dominio`
  reprova.
- **Descartada, importar `app.domains.documents.models`:** a regra proíbe, e o
  `tests/test_arquitetura.py` existe para pegar isso.
- **Descartada, confiar só na FK do banco e traduzir o `IntegrityError`:** a violação de
  FK e a de `unique` chegam como a mesma exceção. Separar as duas exige ler o nome da
  constraint na mensagem do driver, o que é esperto demais para o nível do time e quebra
  se o nome mudar.

O "já ligado a outro participante" (409) é pergunta ao **próprio** repository:
`get_by_document_id`.

**2. O enum de status compartilhado.**

- **Escolhida:** mover `RecordStatus` de `app/domains/users/models.py` para
  `app/shared/enums.py`, com `users` importando de lá. Na migration, a coluna usa
  `postgresql.ENUM(name="recordstatus", create_type=False)`. O modelo já trata o
  `RecordStatus` como um enum só para `User`, `Participant` e `Organization` ([C6]).
- **Descartada, um segundo `RecordStatus` dentro de `participants`:** seriam duas classes
  Python para o mesmo tipo do banco. A primeira que mudar sozinha desalinha a outra.
- **Descartada, um tipo novo `participant_status`:** contradiz o [C6] e faz a
  `Organization` precisar de um terceiro.

## Critérios de aceite

- [ ] `alembic upgrade head` cria `participants` com as colunas e regras de "Dados", e
      `alembic heads` devolve uma head só.
- [ ] `alembic downgrade -1` apaga `participants` e **mantém** o tipo `recordstatus`;
      `upgrade head` de novo funciona.
- [ ] `alembic check` não acusa diferença entre model e banco.
- [ ] `POST /api/v1/participants` com `admin` e só `name` responde 201, com
      `status: "active"` e `document_id: null`.
- [ ] Com `document_id` de um documento existente, responde 201 e devolve o mesmo id.
- [ ] Com `document_id` inexistente, responde 422.
- [ ] Com `document_id` já usado por outro participante, responde 409.
- [ ] `GET /api/v1/participants/{id}` com `admin` devolve o participante (200); com id
      inexistente, 404.
- [ ] Nas duas rotas: sem token, 401; com `gestor` ou `respondente`, 403.
- [ ] `participants` não importa `models.py` de outro domínio. A única composição,
      `DocumentService`, está declarada em `COMPOE_COM_SERVICE_DE`, e o
      `tests/test_arquitetura.py` passa.
- [ ] `users` continua funcionando com `RecordStatus` vindo de `app/shared/`: a suíte de
      `users` passa sem alteração de comportamento.
- [ ] As duas rotas aparecem no Swagger com resumo, descrição, `operation_id` e exemplos,
      e o `tests/test_openapi.py` as inclui.

## Como verificar

1. Com a `dev` já contendo o #13: `alembic upgrade head`, depois
   `psql -c '\d participants'`. Conferir colunas, `unique` em `document_id` e FK para
   `documents`.
2. `alembic downgrade -1` e `psql -c '\dT recordstatus'`: o tipo continua lá. Depois
   `alembic upgrade head` e `alembic check`.
3. `pytest tests/domains/participants tests/domains/users tests/test_arquitetura.py tests/test_openapi.py`.
4. No Swagger local (`/api/v1/docs`), com token de `admin`: criar sem documento, criar
   com documento existente, repetir o mesmo documento (409), usar um UUID qualquer como
   documento (422), consultar pelo id devolvido (200) e por um id inventado (404).
5. Repetir uma chamada com token de `respondente`: 403.
6. `ruff check . && mypy app && pytest`.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-021 | O participante pode ser cadastrado sem documento. Se o `document_id` vier, o documento precisa existir e não estar ligado a outro participante. Não há rota para criar documento nesta entrega. | baixo |
| P-022 | Só `admin` cadastra e consulta participante nesta entrega. | baixo |
| P-008 (existente) | Todo cadastro da cadeia Organização → Participante → Vínculo → Usuário é feito por `admin`. | — |

## Riscos

- **O #13 não entrar na `dev`.** Sem `documents`, a FK não tem para onde apontar e a
  migration não sobe. Sinal: `alembic upgrade` falha com "relation documents does not
  exist". Não comece a migration antes do merge.
- **`require_role` nunca foi usado numa rota de verdade.** Esta é a primeira. Sinal: um
  teste de 403 que passa sem token ou um 401 que vira 500. Os critérios cobrem os dois
  casos, com teste de router.
- **Autogenerate tentando criar `recordstatus` de novo.** Por padrão, ele gera
  `sa.Enum(..., name="recordstatus")`, que tenta `CREATE TYPE` e quebra com "type already
  exists". A migration precisa ser ajustada à mão (regra 1 de `migrations.md`).
- **Conflito com o PR #18 (CREED-23.9)**, que mexe no `downgrade` da migration do `user`
  para apagar `recordstatus`. Com `participants` usando o tipo, o `downgrade` completo só
  funciona na ordem certa (`participants` antes de `user`), que é a ordem natural do
  Alembic. Sinal: `downgrade base` falhando com "cannot drop type recordstatus because
  other objects depend on it".
- **A CREED-40 escolher colocar os demográficos em tabela própria** em vez de colunas em
  `participants`. Não quebra esta entrega: só significa que `gender` nunca entra aqui.
