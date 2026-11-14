# Task 5 — Volta: callback assinado e leitura de status

**Repo:** `creed-backend`
**Depende de:** tasks 1 e 2

## Objetivo

O N8N devolve o insight por `POST /api/v1/insights/callback`, assinado. O back confere a
assinatura, aplica a tabela de idempotência e grava. O dono lê o status em
`GET /api/v1/form-responses/{form_response_id}/insight`.

## Arquivos que provavelmente mudam

- `app/core/security.py`: o `Depends` que lê o corpo cru, confere o timestamp e compara
  a assinatura com `hmac.compare_digest`
- `app/domains/insights/router.py` (novo)
- `app/domains/insights/service.py`: `complete` e a tabela de idempotência; a leitura
  de status com a guarda
- `app/domains/insights/repository.py`
- `app/domains/insights/schemas.py`: `InsightStatusRead`
- `app/domains/insights/dependencies.py`
- `app/main.py`: inclui o router
- `tests/core/test_security.py`
- `tests/domains/insights/test_router.py`, `test_service.py`
- `tests/test_openapi.py`

## Molde

- `app/domains/users/router.py`: router fino, erros do domínio traduzidos em status.
- `app/domains/links/router.py`: rota aninhada (`/organizations/{organization_id}/links`),
  que é a forma do `GET /form-responses/{id}/insight`.
- `playbooks/integrar-servico-externo.md`, "O caminho de volta".

## Critérios de aceite

- [ ] O callback não usa a autenticação do Keycloak: quem chama é o N8N, e quem protege
      é a assinatura.
- [ ] Os exemplos `done` e `failed` do kit, assinados com o segredo do `vetor-hmac.json`,
      recebem 204. O `done` grava `content`, `model_id`, `prompt_version` e
      `completed_at`.
- [ ] Assinatura ausente, assinatura errada ou timestamp a mais de 5 min dão 401, e
      nada muda no banco.
- [ ] A tabela de idempotência da spec ("Contrato", volta) tem um teste por linha:
  - `done` sobre `pending`, `dispatched` e `failed` grava;
  - `done` ou `failed` sobre `done` não muda nada;
  - `failed` com `retryable: true` faz backoff, ou vira `failed` no limite;
  - `failed` com `retryable: false` vira `failed` direto;
  - `failed` sobre `failed` não muda nada.
- [ ] Corpo fora do contrato, inclusive `content` fora do `InsightContent`, dá 422, e o
      insight continua `dispatched`.
- [ ] `insight_id` desconhecido dá 404.
- [ ] A leitura de status (`GET`):
  - para o dono da resposta, devolve `status`, `content` e `completed_at`, com o
    `dispatched` aparecendo como `pending`;
  - a administradora da CREED lê o de um mentorando (P-048);
  - outro vínculo recebe 403, inclusive a gestora da mesma organização;
  - resposta inexistente dá 404.
- [ ] O OpenAPI descreve as duas rotas, com os códigos de erro, e
      `tests/test_openapi.py` fica verde.

## Como testar

```bash
pytest tests/core tests/domains/insights tests/test_openapi.py tests/test_arquitetura.py -q
ruff check . && ruff format --check . && pre-commit run mypy --all-files
```

O teste do callback monta a assinatura com a função da task 1 e o segredo do vetor,
nunca com o segredo de `settings` de outro ambiente.

## Premissas aplicáveis

- P-086: quem lê o insight individual
- P-087: contrato `insight-v1`
- P-044: esgotadas as tentativas, a tela diz que o insight não ficou disponível
