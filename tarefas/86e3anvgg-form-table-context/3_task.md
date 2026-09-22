# Task 3 — Endpoints de criação e consulta de formulário

**Repo:** `creed-backend`
**Depende de:** task 2 — importa o service e os schemas que ela cria

## Objetivo

`POST /api/v1/forms` e `GET /api/v1/forms/{form_id}` existem, respondem nos códigos do
contrato e aparecem no Swagger.

## Contexto que você não tem como adivinhar

Esta é a única das três entregas que produz algo que dá para **ver de fora**: uma porta de
API que responde. Ainda assim, **nenhuma tela do aplicativo web a consome** — quem
exercita é dev, pelo Swagger ou por linha de comando.

No servidor deste projeto, a camada de rota (`router.py`) é o que em outros lugares se
chama de *controller*: recebe, deixa o framework validar o formato, chama a camada de
regra e devolve. **Nenhuma decisão de negócio mora aqui**, e ela **não conhece a tabela**
— existe teste automático que reprova um `router.py` que importe `models`.

O que a rota faz de próprio é **traduzir erro de domínio em código HTTP**: a camada de
regra levanta "não encontrado" sem saber o que é um 404; quem sabe é a rota.

⚠️ **Uma coisa que esta entrega deliberadamente não faz, e que quem lê provavelmente
esperaria:** a rota **não confere se a organização existe**, e **não confere se quem
chama tem direito sobre ela**. A tabela de organizações ainda não existe (é outra tarefa,
no backlog), e a de vínculos também não. Na prática: qualquer identificador de
organização é aceito. É risco conhecido e aceito — e tem uma consequência prática no fim
desta tarefa, em "O que não pode acontecer".

## Como pretendemos fazer

Um `APIRouter` com prefixo `/forms`, registrado em `app/main.py` junto dos outros. O
prefixo `/api/v1` **não** se escreve no router: ele vem de `settings.API_V1_PREFIX` no
`include_router`, e escrevê-lo de novo produziria `/api/v1/api/v1/forms`.

Os quatro códigos de resposta:

| Situação | Código | Quem produz |
|---|---|---|
| formulário criado | **201** | o decorador `status_code=status.HTTP_201_CREATED` |
| formulário encontrado | **200** | padrão |
| identificador não existe | **404** | a rota, traduzindo `NotFoundError` |
| corpo fora do formato | **422** | o FastAPI sozinho, sem código nenhum seu |

## Arquivos que provavelmente mudam

- `app/domains/forms/router.py` — os dois endpoints
- `app/main.py` — o import e a entrada na lista de routers
- `tests/domains/forms/test_router.py` — os quatro casos acima

## O contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/forms` | `{"name": "...", "organization_id": "<uuid>"}` | `FormRead` · **201** |
| GET | `/api/v1/forms/{form_id}` | — | `FormRead` · **200** |

**Corpo da saída**

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
| 404 | `form_id` não existe | `{"detail": "..."}`, vindo da mensagem do `NotFoundError` |
| 422 | `name` curto demais, ausente, ou `organization_id` que não é UUID | validação padrão do FastAPI |

**`status` não entra no corpo do POST.** O formulário nasce sempre em rascunho — a
decisão e o motivo estão na entrega 2.

## Molde

Copie a forma de `app/domains/users/router.py`:

- `router = APIRouter(prefix="/forms", tags=["forms"])`;
- o service chega por `ServiceDep`, de `dependencies.py` — **não instancie nada à mão**;
- a saída é montada por `FormRead.de_model(...)`, **não** devolvendo o model direto — é o
  que permite ao router não importar `models`;
- o `try/except` que traduz o erro de domínio em `HTTPException`.

Para registrar em `app/main.py`, copie a forma do que já está lá: um
`from app.domains.forms.router import router as forms_router` junto dos outros imports, e
o nome acrescentado à tupla do laço que chama `include_router`. **Não** escreva
`include_router` com prefixo próprio.

Teste: copie a forma de `tests/domains/authentication/test_router.py`. **Não existe banco
de teste no projeto** — o teste de rota monta um `FastAPI()` só com este router e troca o
service por um dublê, usando `app.dependency_overrides`. O que se prova aqui é **só o
contrato HTTP**: código de status e forma do corpo. Regra de negócio já foi provada na
entrega 2; não a teste de novo aqui.

## Critérios de aceite

- [ ] `POST /api/v1/forms` com corpo válido devolve **201** e um corpo com exatamente as
      cinco chaves de `FormRead`.
- [ ] O formulário criado volta com `"status": "draft"`.
- [ ] `GET /api/v1/forms/{id}` de um formulário que existe devolve **200** com o mesmo
      formato.
- [ ] `GET /api/v1/forms/{id}` de um identificador que não existe devolve **404**.
- [ ] `POST` sem `name`, com `name` vazio, ou com `organization_id` que não é UUID
      devolve **422** — sem nenhum código escrito para isso.
- [ ] Os dois endpoints aparecem em `/api/v1/docs`, sob a etiqueta `forms`.
- [ ] A rota final é `/api/v1/forms`, **não** `/api/v1/api/v1/forms`.
- [ ] `router.py` não importa `models` nem `sqlalchemy`.
- [ ] Nenhum `if` sobre dado de negócio dentro do `router.py`.
- [ ] `pytest tests/test_arquitetura.py` passa.

## Como testar

```bash
cd creed-backend
pytest tests/domains/forms -q
ruff check . && mypy app && pytest
```

De ponta a ponta, com banco:

```bash
docker compose up -d db
alembic upgrade head
uvicorn app.main:app --reload
```

Em outro terminal — **caso feliz**:

```bash
curl -i -X POST localhost:8000/api/v1/forms \
  -H 'Content-Type: application/json' \
  -d '{"name":"Instrumento piloto","organization_id":"00000000-0000-0000-0000-000000000001"}'
```

**Casos de borda, nomeados:**

```bash
# 404 — identificador que não existe
curl -i localhost:8000/api/v1/forms/00000000-0000-0000-0000-000000000000

# 422 — nome vazio
curl -i -X POST localhost:8000/api/v1/forms \
  -H 'Content-Type: application/json' \
  -d '{"name":"","organization_id":"00000000-0000-0000-0000-000000000001"}'
```

## O que não pode acontecer

A rota aceita qualquer `organization_id`, porque não há tabela de organizações para
conferir. Enquanto a tarefa de **amarração** não ligar as duas tabelas, isso tem uma
consequência prática:

- **Nenhum `seed`, `fixture` ou carga inicial pode gravar na tabela `form`.** O que for
  criado à mão em desenvolvimento é descartável e some no `docker compose down -v`.
- **Esta API não vai para ambiente que não seja o local** antes da amarração. Quando a
  ligação com a tabela de organizações for criada, o banco vai recusar qualquer linha
  cujo `organization_id` não exista de verdade — e aí uma linha inventada trava a
  migration para todo mundo.

Quem cuida do deploy precisa saber disso.

## Premissas aplicáveis

- **P-017** — o formulário nasce sempre `draft`; `status` não entra no corpo do POST.
  Aqui isso aparece como o campo simplesmente não existir na entrada. Se a premissa cair,
  o corpo ganha um campo e o service ganha uma linha.
- **P-016** — o formulário tem nome. Aqui isso aparece como `name` ser obrigatório na
  entrada e vir na saída.
