# Task 3 — `forms` e `questions` com login e organização

**Repo:** `creed-backend`
**Depende de:** task 2 (mesmos `service.py` e `router.py` de `questions`).

## Objetivo

Só `admin` e `gestor` cadastram formulário e pergunta, qualquer papel lê, e ninguém
além do `admin` age fora da própria organização (403).

## Contexto que você não tem como adivinhar

**Duas camadas de regra, em dois lugares.**

| Regra | Onde | Resultado |
|---|---|---|
| Qual papel pode chamar a rota | guarda no router: `require_role("admin", "gestor")` para cadastrar, `CurrentUserDep` para ler | 401 / 403 |
| Em qual organização | service, por P-033 | `ForbiddenError` → 403 |

**`ForbiddenError` é nova**, em `app/shared/exceptions.py`, ao lado das outras, com a
docstring "Traduzido para 403 no router".

**O service recebe valores simples, não o `AuthenticatedUser`** (spec, item 7). O
router lê `role` e `organization_id` do usuário autenticado e os passa como argumentos
nomeados. `AuthenticatedUser.organization_id` é `str | None`, porque só vem preenchido
depois de `_check_against_database`, e nas rotas desta task sempre vem. A conversão para
`uuid.UUID` é na borda, no router. `AuthenticatedUser.roles` é uma lista com um papel só
depois da guarda (o do vínculo).

**A regra de organização mora em `FormService`**, porque o formulário é que pertence à
organização. `questions` e, na task 4, `responses` a usam pela composição da task 2:
recebem o `Form` de `FormService.get` e pedem a `FormService` a conferência. Assim
`questions` não repete a regra.

**`FormService.get(form_id)` continua sem regra de acesso**, porque é a pergunta
"existe?" da task 2. A conferência é um método separado.

| Rota | Guarda | Service confere |
|---|---|---|
| `POST /forms` | `admin`, `gestor` | `request.organization_id` é a do usuário, a menos que seja `admin` |
| `GET /forms/{form_id}` | qualquer papel | idem, com `form.organization_id` |
| `POST /questions` | `admin`, `gestor` | organização do formulário da pergunta |
| `GET /forms/{form_id}/questions` | qualquer papel | organização do formulário |

**Os testes de router de `forms` e `questions` passam a atravessar a guarda.** Copie o
`autenticar_como` de `tests/domains/participants/test_router.py` para cada arquivo, que
é o padrão observado: cada `test_router.py` tem o próprio. Aceite também
`organization_id`, porque os testes de 403 precisam dela fixa.

## Arquivos que provavelmente mudam

- `app/shared/exceptions.py`
- `app/domains/forms/service.py` e `router.py`
- `app/domains/questions/service.py` e `router.py`
- `tests/domains/forms/test_service.py` e `test_router.py`
- `tests/domains/questions/test_service.py` e `test_router.py`
- `tests/test_openapi.py`: 401 e 403 nas quatro rotas

## Molde

- Rota com guarda e 401/403 documentados: `app/domains/participants/router.py`
  (`_AUTH_RESPONSES`).
- Teste de router com a guarda de verdade: `tests/domains/participants/test_router.py`.

## Critérios de aceite

- [ ] Sem token: 401 nas quatro rotas.
- [ ] `respondente` em `POST /forms` ou `POST /questions`: 403 (guarda).
- [ ] `gestor` cadastrando formulário ou pergunta em outra organização: 403 (service).
- [ ] `gestor` e `respondente` lendo formulário ou perguntas de outra organização: 403.
- [ ] `admin` cadastra e lê em qualquer organização.
- [ ] Marcador `🟡 Premissa P-033` no método de `FormService` que aplica a regra.
- [ ] O 422 e o 404 da task 2 continuam: o formulário inexistente é conferido antes da
      organização.

## Como testar

```bash
cd creed-backend
pytest tests/domains/forms tests/domains/questions tests/test_openapi.py tests/test_arquitetura.py -q
```

Service: fake de `FormService` com um formulário da organização A. Testar `admin` e
`gestor` de A e de B. Router: sem token (401), `respondente` no `POST` (403), `gestor`
recebendo `ForbiddenError` do fake (403).

## Premissas aplicáveis

- **P-033**: `admin` em qualquer organização; `gestor` e `respondente`, só na do próprio
  vínculo.
