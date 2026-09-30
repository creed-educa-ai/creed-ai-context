# Task 4 — `form-responses`: o vínculo vem do login, e só o dono mexe

**Repo:** `creed-backend`
**Depende de:** task 3 (`ForbiddenError` e a conferência de organização em
`FormService`).

## Objetivo

Abrir uma resposta de formulário usa o vínculo de quem está logado, só para formulário
da própria organização, e só o dono pode enviá-la.

## Contexto que você não tem como adivinhar

**`vinculo_id` sai de `FormResponseCreate`.** O corpo fica só com `form_id`. O vínculo
vem de `AuthenticatedUser.link_id`, que a guarda preenche desde a CREED-32. A **saída**
(`FormResponseResponse`) continua com `vinculo_id`: renomear é outro PR (spec, "Não
entra"). Quem mandar `vinculo_id` no corpo não recebe erro, porque o Pydantic descarta o
campo; diga isso na `description` da rota.

**Qualquer papel abre resposta** (P-031), então a guarda é `CurrentUserDep`, não
`require_role`. A organização é conferida pelo `FormService` da task 3: formulário de
outra organização dá 403, **inclusive para o `admin`**. O admin cadastra em qualquer
organização (P-033), mas responde com o próprio vínculo, e o vínculo tem uma organização
só.

**Ordem das conferências no `POST`:** formulário existe (422) → mesma organização (403)
→ já existe resposta desse vínculo para esse formulário (409, como hoje).

**Ordem no `PATCH`:** existe (404) → é do vínculo logado (403) → ainda em andamento
(409, como hoje).

## Arquivos que provavelmente mudam

- `app/domains/responses/schemas.py`: `FormResponseCreate` só com `form_id`, e o exemplo
  atualizado
- `app/domains/responses/service.py`: `create_form_response(form_id, *, link_id,
  organization_id)` e `submit_form_response(form_response_id, *, link_id)`
- `app/domains/responses/router.py`: `CurrentUserDep`, conversão para `uuid.UUID`, 401
  e 403 documentados, descrição de onde vem o vínculo
- `tests/domains/responses/test_service.py` e `test_router.py`: o `test_router` passa a
  atravessar a guarda, como na task 3
- `tests/test_openapi.py`: 401 e 403 em `POST /form-responses` e
  `PATCH /form-responses/{form_response_id}`

## Molde

- A mesma forma da task 3.
- O `link_id` do login: `AuthenticatedUser` em `app/shared/authorization.py`.

## Critérios de aceite

- [ ] `POST /form-responses` com `{"form_id": ...}`: 201, com o `vinculo_id` do login.
- [ ] `vinculo_id` enviado no corpo: ignorado, e vale o do login.
- [ ] Formulário de outra organização: 403, também para `admin`.
- [ ] `PATCH` na resposta de outro vínculo: 403. Na própria: 200, como hoje.
- [ ] Sem token: 401 nas duas rotas.
- [ ] Marcador `🟡 Premissa P-031` no `create_form_response`, e `🟡 Premissa P-030`
      onde o status do formulário **não** é conferido.

## Como testar

```bash
cd creed-backend
pytest tests/domains/responses tests/test_openapi.py tests/test_arquitetura.py -q
```

Service: fake de `FormService` com formulários de duas organizações. Router: token de
`respondente` abrindo e enviando a própria resposta, e tentando enviar a de outro
vínculo.

## Premissas aplicáveis

- **P-030**: responder não depende do status do formulário.
- **P-031**: qualquer vínculo responde formulário da própria organização, com o próprio
  vínculo.
