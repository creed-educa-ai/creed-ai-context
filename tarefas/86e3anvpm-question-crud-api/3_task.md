# Task 3 — Endpoints de criação e listagem de perguntas

**Repo:** `creed-backend`
**Depende de:** task 2, porque importa o service e os schemas que ela cria

## Objetivo

`POST /api/v1/questions` e `GET /api/v1/forms/{form_id}/questions` existem, respondem
com os códigos do contrato e aparecem no Swagger.

## Contexto que você não tem como adivinhar

Esta é a única das três entregas que dá para **ver de fora**. Mesmo assim, **nenhuma tela
do front a consome ainda**: quem a usa é o dev, pelo Swagger ou pela linha de comando.

A camada de rota (`router.py`) é o que outros projetos chamam de *controller*: recebe o
pedido, deixa o FastAPI validar o formato, chama o service e devolve a resposta.
**Nenhuma decisão de negócio mora aqui**, e ela **não conhece a tabela**. Existe teste
automático que reprova um `router.py` que importe `models`. O que a rota faz por conta
própria é **traduzir o erro de domínio em código HTTP**: o service levanta
`ConflictError` sem saber o que é 409, e a rota é quem sabe.

⚠️ **Duas coisas que esta entrega não faz de propósito, e que quem lê provavelmente
esperaria:**

- **Não existe 404.** A rota não confere se o formulário existe, porque a tabela de
  formulários nasce em paralelo, em outro domínio. `GET` de um `form_id` que ninguém
  criou devolve **200 com lista vazia**.
- **Ninguém confere quem está chamando.** A tabela de vínculos ainda não existe.

As duas coisas são risco conhecido e aceito, com uma consequência prática em "O que não
pode acontecer", no fim desta task.

## Como pretendemos fazer

Os dois caminhos não têm prefixo em comum (`/questions` e `/forms/{form_id}/questions`).
Por isso o router **não tem prefixo**, e cada rota escreve o caminho inteiro:

```python
router = APIRouter(tags=["questions"])

@router.post("/questions", ...)
@router.get("/forms/{form_id}/questions", ...)
```

Isso é diferente de `users` e de `responses`, que usam `prefix=`. O motivo está em
[`spec.md`](spec.md) → "Abordagem técnica", item 6. O prefixo `/api/v1` **não** se
escreve aqui: ele vem de `settings.API_V1_PREFIX` no `include_router` de `app/main.py`.

| Situação | Código | Quem produz |
|---|---|---|
| pergunta criada | **201** | `status_code=status.HTTP_201_CREATED` no decorador |
| lista devolvida, vazia ou não | **200** | o padrão do FastAPI |
| posição já ocupada no formulário | **409** | a rota, traduzindo `ConflictError` |
| corpo fora do formato, ou `?section=` com valor fora do enum | **422** | o FastAPI, sem nenhum código seu |

**O filtro por seção é um parâmetro de query opcional**, tipado com o enum. É isso que
faz o FastAPI validar o valor e devolver 422 sozinho:

```python
@router.get("/forms/{form_id}/questions", response_model=list[QuestionResponse])
async def list_questions(
    form_id: uuid.UUID,
    service: ServiceDep,
    section: QuestionSection | None = None,
) -> list[QuestionResponse]:
    ...
```

A rota só **repassa** `section` ao service. Não há `if section:` no router: o filtro é
do repository (task 2). O router importa `QuestionSection` de `models.py` só como
tipo do parâmetro, e isso **fura** a regra "router não importa `models`", que o
`tests/test_arquitetura.py` cobra. Para não furar, reexporte o enum em `schemas.py`
(`from app.domains.questions.models import QuestionSection`, que `schemas.py` já pode
importar) e importe de lá no router.

## Arquivos que provavelmente mudam

- `app/domains/questions/dependencies.py`: a cadeia sessão → repository → service, e o
  `ServiceDep`
- `app/domains/questions/router.py`: os dois endpoints
- `app/main.py`: o import e a entrada na tupla de routers
- `tests/domains/questions/test_router.py`

## O contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/questions` | `QuestionCreate` | `QuestionResponse` · **201** |
| GET | `/api/v1/forms/{form_id}/questions` | `?section=profile\|assessment\|closing`, opcional | `list[QuestionResponse]` · **200** |

**Corpo da saída** (um item da lista, ou a resposta do POST)

```json
{
  "id": "uuid",
  "form_id": "uuid",
  "text": "string",
  "order_index": 0,
  "type": "objective",
  "section": "assessment",
  "required": true,
  "prisma": null,
  "created_at": "2026-09-22T14:00:00Z"
}
```

## Molde

- **Router:** `app/domains/users/router.py`. O service chega por `ServiceDep` (não
  instancie nada à mão), a saída é montada com `QuestionResponse.de_model(...)`, e o
  `try/except` traduz `ConflictError` em `HTTPException(409)`. Para a lista, use
  `[QuestionResponse.de_model(q) for q in ...]`.
- **Dependencies:** `app/domains/users/dependencies.py`, com a mesma forma e as mesmas
  três funções.
- **`app/main.py`:** acrescente
  `from app.domains.questions.router import router as questions_router` junto dos outros
  imports, e `questions_router` na tupla do laço que chama `include_router`. **Não**
  escreva um `include_router` separado.
- **Teste:** `tests/domains/authentication/test_router.py`. **O projeto não tem banco de
  teste**, então o teste de rota monta um `FastAPI()` só com este router e troca o
  service por um dublê, com `app.dependency_overrides`. Aqui se prova **só o contrato
  HTTP**: o código de status e a forma do corpo. A regra já foi provada na task 2, então
  não a teste de novo.

## Critérios de aceite

- [ ] `POST /api/v1/questions` com corpo válido devolve **201** e um corpo com exatamente
      as nove chaves de `QuestionResponse`.
- [ ] `POST` com uma posição já ocupada no mesmo formulário devolve **409**.
- [ ] `POST` sem `text`, com `text` vazio, sem `section`, com `type` ou `section`
      inválido ou com `form_id` que não é UUID devolve **422**, sem nenhum código escrito
      para isso.
- [ ] `GET /api/v1/forms/{form_id}/questions` devolve **200** com uma lista, e **200** com
      `[]` para um formulário sem perguntas.
- [ ] `GET ...?section=<valor>` devolve só as perguntas daquela seção; com um valor fora
      do enum, devolve **422**.
- [ ] O parâmetro `section` aparece no Swagger como lista fechada dos três valores.
- [ ] `router.py` não importa de `models.py`: `QuestionSection` vem de `schemas.py`.
- [ ] Com banco, a lista volta em ordem de `order_index` mesmo quando as perguntas foram
      criadas fora de ordem.
- [ ] As rotas finais são `/api/v1/questions` e `/api/v1/forms/{form_id}/questions`,
      e **não** `/api/v1/questions/questions` nem `/api/v1/api/v1/...`.
- [ ] Os dois endpoints aparecem em `/api/v1/docs`, sob a etiqueta `questions`.
- [ ] `router.py` não importa `models` nem `sqlalchemy`, e não tem nenhum `if` sobre dado
      de negócio.
- [ ] `pytest tests/test_arquitetura.py` passa.

## Como testar

```bash
cd creed-backend
pytest tests/domains/questions -q
ruff check . && mypy app && pytest
```

De ponta a ponta, com banco:

```bash
docker compose up -d db
alembic upgrade head
uvicorn app.main:app --reload
```

Em outro terminal. **Caso feliz, fora de ordem de propósito**, para provar a ordenação
que o teste da task 2 não cobre:

```bash
F=00000000-0000-0000-0000-000000000001
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"Terceira\",\"order_index\":2,\"type\":\"descriptive\",\"section\":\"assessment\"}"
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"Primeira\",\"order_index\":0,\"type\":\"objective\",\"section\":\"assessment\",\"prisma\":\"tomada_decisao\"}"
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"Segunda\",\"order_index\":1,\"type\":\"descriptive\",\"section\":\"profile\"}"

curl -i localhost:8000/api/v1/forms/$F/questions
# esperado: Primeira, Segunda, Terceira

curl -i "localhost:8000/api/v1/forms/$F/questions?section=assessment"
# esperado: Primeira, Terceira. Filtro e ordem juntos, no banco
```

Esta é a única prova do `WHERE` e do `ORDER BY`: o teste da task 2 usa dublê e não roda
SQL.

**Casos de borda:**

```bash
# 409: posição repetida no mesmo formulário, mesmo em outra seção
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"Repetida\",\"order_index\":0,\"type\":\"objective\",\"section\":\"closing\"}"

# 200 com []: formulário sem pergunta nenhuma
curl -i localhost:8000/api/v1/forms/00000000-0000-0000-0000-000000000999/questions

# 200 com []: seção sem pergunta nenhuma
curl -i "localhost:8000/api/v1/forms/$F/questions?section=closing"

# 422: seção que não existe
curl -i "localhost:8000/api/v1/forms/$F/questions?section=inexistente"

# 422: cadastro sem seção
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"Sem seção\",\"order_index\":5,\"type\":\"objective\"}"

# 422: texto vazio
curl -i -X POST localhost:8000/api/v1/questions -H 'Content-Type: application/json' \
  -d "{\"form_id\":\"$F\",\"text\":\"\",\"order_index\":6,\"type\":\"objective\",\"section\":\"profile\"}"
```

## O que não pode acontecer

A API aceita qualquer `form_id`. Enquanto a tarefa de **amarração** não ligar
`questions` a `form`:

- **Nenhum `seed`, `fixture` ou carga inicial pode gravar em `questions`.** O que for
  criado à mão em desenvolvimento é descartável e some no `docker compose down -v`.
- **Esta API não vai para nenhum ambiente além do local.** Quando a ligação for criada, o
  banco vai recusar toda pergunta cujo `form_id` não exista de verdade, e uma linha
  inventada trava a migration para todo mundo.

Quem cuida do deploy precisa saber disso.

## Premissas aplicáveis

- **P-019**: só criar e listar. Aqui isso aparece como a ausência de `PUT`, `PATCH` e
  `DELETE`. Se a premissa cair, entram uma rota e a tradução de `NotFoundError` para 404.
- **P-020**: os valores de seção são provisórios. Aqui isso aparece no Swagger, que
  mostra a lista fechada, e é por onde o front vai conhecê-los. **Quem integrar o front
  precisa saber que a lista não é definitiva**, antes de criar chaves de tradução para
  ela.
- **P-028**: a seção é obrigatória no cadastro. Aqui isso aparece como o 422 do `POST`
  sem `section`.
