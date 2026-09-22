# Task 2 — Criar e buscar um formulário: regra, acesso a dados e contratos

**Repo:** `creed-backend`
**Depende de:** task 1 — importa o model `Form` que ela cria

## Objetivo

O servidor sabe criar um formulário em rascunho e buscá-lo por identificador, com as três
camadas separadas e testadas — sem nenhuma rota HTTP ainda.

## Contexto que você não tem como adivinhar

A regra desta entrega é curta, e é toda ela consequência de uma decisão de produto:
**o formulário nasce sempre em rascunho (`draft`), e quem cria não escolhe o estado.**

O motivo: um formulário publicado sem nenhuma pergunta não é respondível, e as perguntas
ainda não existem como tabela. Aceitar `status` no corpo da criação seria oferecer uma
escolha que não existe de verdade.

É o mesmo corte que o domínio de usuários já faz com o papel da pessoa — lá o contrato
diz, com todas as letras, que *"mandar `role` no POST é sintoma de ter entendido o modelo
ao contrário"*. Aqui vale igual para `status`.

**Onde a regra mora:** no service, não no model. O `default` da coluna é a rede para quem
construir um `Form` por outro caminho; em conflito, vale a linha do service. O critério é
do projeto: *se a resposta muda quando o **produto** muda de ideia, é service; se muda
quando o **banco** muda de forma, é repository.*

## Como pretendemos fazer

Três camadas, com responsabilidades separadas — é a divisão que o projeto usa em todo
assunto, e furar ela quebra um teste automático:

- A camada que **fala com o banco** (`repository.py`) só grava e busca. Não decide nada,
  e quando não acha devolve "nada encontrado", sem levantar erro.
- A camada de **regra** (`service.py`) é quem decide: monta o formulário já em `draft` e,
  quando a busca devolve nada, é ela quem levanta o erro de "não encontrado".
- A camada de **contratos** (`schemas.py`) descreve o que entra e o que sai.

Duas armadilhas conhecidas, porque o projeto já tropeçou nelas:

1. **Não escreva `commit()` em lugar nenhum.** Quem fecha a transação é a requisição, no
   fim — `app/core/database.py` cuida disso. O repository usa `flush()` e `refresh()`.
   `commit()` fora de lá é sinal de camada furada, e existe teste automático que reprova.
2. **A camada que fala com o banco devolve `None` quando não acha; ela não levanta erro.**
   Levantar ali é a camada de dados decidindo regra, que é trabalho da camada de regra.

Tudo é escrito em modo assíncrono (`async`), porque é assim que o resto do servidor é.

## Arquivos que provavelmente mudam

- `app/domains/forms/repository.py` — `insert(form)` e `get_by_id(form_id)`
- `app/domains/forms/service.py` — `create(dados)` e `get(form_id)`
- `app/domains/forms/schemas.py` — `FormCreate` (entrada) e `FormRead` (saída)
- `app/domains/forms/dependencies.py` — a cadeia sessão → repository → service
- `tests/domains/forms/test_service.py` — os casos abaixo

**`app/main.py` não é tocado.** Não há rota nesta entrega — ela é a task 3.

## Os métodos que devem nascer

| Onde | Assinatura | Devolve |
|---|---|---|
| `repository.insert(form: Form)` | a entidade já montada | o formulário gravado, com `id` e `created_at` preenchidos |
| `repository.get_by_id(form_id: UUID)` | — | o formulário, **ou `None`** — não levanta erro |
| `service.create(dados: FormCreate)` | os dados já validados | o formulário criado, sempre em `draft` |
| `service.get(form_id: UUID)` | — | o formulário, ou `NotFoundError` |

Os nomes não são livres: **a camada de regra nomeia a intenção**, **a camada de banco
nomeia o acesso**. Um método de regra chamado `get_by_id` é acesso a banco disfarçado —
o nome descreve *como* se busca, que é assunto do banco. E `create_form` repete o assunto
que a classe já carrega: `FormService.create()` não é ambíguo.

## Os contratos

**`FormCreate`** (entrada) leva **dois** campos:

| Campo | Tipo | Regra |
|---|---|---|
| `name` | `str` | obrigatório, entre 2 e 200 caracteres |
| `organization_id` | `UUID` | obrigatório |

**`status` não entra.** Não é esquecimento — está explicado acima.

**`FormRead`** (saída) devolve `id`, `name`, `organization_id`, `status` e `created_at`,
com `ConfigDict(from_attributes=True)` e o `@classmethod de_model()` que monta a saída a
partir do model. O mapeamento model → schema mora aqui, **não no router** — é o que
permite ao router não conhecer a tabela.

> ⚠️ **A saída chama-se `FormRead`, não `FormResponse`.** `FormResponse` é o nome de
> **outra tabela** — a que registra "fulano abriu e respondeu o formulário X" — e já
> existe como classe no repositório, vinda da CREED-34. Duas coisas diferentes com o
> mesmo nome dá confusão no primeiro import. É desvio consciente do sufixo
> `<Entidade>Response` que o molde usa.

## Molde

Copie a forma de `app/domains/users/`, arquivo por arquivo:

- `repository.py` — a sessão assíncrona, a consulta com `select(...)`, e o
  `add` + `flush` + `refresh` do método de criação. Repare que **não há `commit()`**.
- `service.py` — como a regra recebe o repository pelo construtor e levanta erro de
  domínio. Repare também no comentário que explica **por que** `status` mora no service e
  não no model: é exatamente o mesmo caso aqui.
- `schemas.py` — entrada e saída separadas, o `ConfigDict(from_attributes=True)` na saída
  e o `de_model()`.
- `dependencies.py` — `get_repository` → `get_service` → `ServiceDep`.

Erros: use `NotFoundError` de `app/shared/exceptions.py`. **Não crie exceção nova.**

Teste: copie a forma de `tests/domains/users/test_service.py`. **Não existe banco de
teste no projeto** — a regra é testada com um dublê em memória no lugar do repository.
Repare na função auxiliar que monta a entidade à mão com **todos** os campos explícitos:
`default` e `server_default` só são aplicados no `INSERT`, então uma entidade que nunca
passou pela sessão tem `None` neles.

## Critérios de aceite

- [ ] `service.create` devolve um formulário com `status = FormStatus.DRAFT`.
- [ ] `service.create` devolve o `name` e o `organization_id` que recebeu, sem alterar.
- [ ] `service.get` levanta `NotFoundError` quando o identificador não existe.
- [ ] `repository.get_by_id` devolve `None` no mesmo caso — **não** levanta.
- [ ] `FormCreate` **não** tem campo `status`.
- [ ] `FormCreate` recusa `name` com menos de 2 caracteres e `organization_id` que não é
      UUID (validação do Pydantic).
- [ ] `FormRead` devolve os cinco campos: `id`, `name`, `organization_id`, `status`,
      `created_at`.
- [ ] Nenhum `commit()` no diff, fora de `app/core/database.py`.
- [ ] `service.py` não importa `fastapi` nem `sqlalchemy`.
- [ ] `repository.py` não importa `schemas`.
- [ ] `pytest tests/test_arquitetura.py` passa.

## Como testar

```bash
cd creed-backend
pytest tests/domains/forms -q
ruff check . && mypy app && pytest
```

**Caso feliz:** criar um formulário com nome e organização — ele volta em `draft`, com
identificador e horário de criação preenchidos.

**Casos de borda, nomeados:** buscar um identificador que não existe → `NotFoundError` na
camada de regra e `None` na camada de banco · `name` com um caractere só → recusado pelo
Pydantic · `name` com 201 caracteres → recusado pelo Pydantic.

## Premissas aplicáveis

- **P-017** — o formulário nasce sempre `draft`, e `status` não entra no corpo da
  criação. É a regra que esta entrega implementa. Decidimos sem confirmar com a cliente,
  porque publicar um formulário sem perguntas não faz sentido e as perguntas ainda não
  existem. Se cair, muda uma linha no service e um campo no schema de entrada.
- **P-016** — o formulário tem nome, sem unicidade. Aqui isso aparece como o `name` ser
  obrigatório na entrada e **nada** recusar nome repetido.
