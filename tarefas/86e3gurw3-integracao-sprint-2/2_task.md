# Task 2 — Conferências: `links`, `questions` e `form-responses` confirmam o que recebem

**Repo:** `creed-backend`
**Depende de:** nenhuma. Não toca arquivo da task 1.

## Objetivo

Criar vínculo, pergunta ou resposta de formulário apontando para participante ou
formulário inexistente dá erro claro da API, antes de chegar ao banco. E listar as
perguntas de um formulário inexistente passa a dar 404.

## Contexto que você não tem como adivinhar

**A pergunta "existe?" vai ao service do domínio dono**, nunca ao model nem ao
repository dele. É o que `participants → DocumentService` e `users → LinkService` já
fazem. `test_dominio_nao_importa_dominio` só libera o import em `service.py` e
`dependencies.py`, e só para domínio listado em `COMPOE_COM_SERVICE_DE`.

**422 quando o id veio no corpo, 404 quando veio no caminho** (spec, item 11). Os
services dos donos levantam `NotFoundError`: `ParticipantService.get_participant` e
`FormService.get`. Quem chama traduz para `ValidationError` quando o id veio no corpo.

| Rota | Referência | Erro |
|---|---|---|
| `POST /organizations/{organization_id}/links` | `participant_id` no corpo | 422 |
| `POST /questions` | `form_id` no corpo | 422 |
| `GET /forms/{form_id}/questions` | `form_id` no caminho | **404** (hoje: 200 com `[]`) |
| `POST /form-responses` | `form_id` no corpo | 422 |

`vinculo_id` ainda vem no corpo nesta task, e **não** é conferido aqui: a task 4 o tira
do corpo.

**O `GET` de perguntas muda um contrato publicado** (a spec da CREED-35 prometia o 404
"com a amarração"). Atualize a `description` da rota, que hoje diz o contrário.

## Arquivos que provavelmente mudam

- `app/domains/links/service.py` e `dependencies.py`: `LinkService(repository,
  participants)`
- `app/domains/links/router.py`: 422 traduzido e documentado
- `app/domains/questions/service.py` e `dependencies.py`: `QuestionService(repository,
  forms)`
- `app/domains/questions/router.py`: 422 no `POST`, 404 no `GET`, descrições
- `app/domains/responses/service.py` e `dependencies.py`: `FormResponseService(repository,
  forms)`
- `app/domains/responses/router.py`: 422 no `POST`
- `tests/test_arquitetura.py`: `links`, `questions` e `responses` em
  `COMPOE_COM_SERVICE_DE`, cada um com o motivo
- `tests/domains/{links,questions,responses}/test_service.py` e `test_router.py`
- `tests/test_openapi.py`: códigos novos das rotas acima

## Molde

- Composição e fake do service alheio: `app/domains/users/service.py`,
  `app/domains/users/dependencies.py` e `FakeLinkService` em
  `tests/domains/users/test_service.py`.
- Tradução de "documento inexistente" em 422: `ParticipantService.create_participant`.

## Critérios de aceite

- [ ] Participante inexistente em `POST .../links`: 422, e o repository de links não é
      chamado.
- [ ] Formulário inexistente em `POST /questions` e em `POST /form-responses`: 422.
- [ ] Formulário inexistente em `GET /forms/{form_id}/questions`: 404. Formulário
      existente e sem perguntas: 200 com `[]`.
- [ ] Os casos felizes continuam como estavam.
- [ ] `COMPOE_COM_SERVICE_DE` tem as três entradas novas com motivo, e
      `pytest tests/test_arquitetura.py` passa.
- [ ] `tests/domains/links/test_service.py` monta `LinkService` com o fake de
      participantes.

## Como testar

```bash
cd creed-backend
pytest tests/domains/links tests/domains/questions tests/domains/responses tests/test_arquitetura.py tests/test_openapi.py -q
```

Caso feliz e caso inexistente para cada uma das quatro rotas, no service (com fake do
service dono) e no router.

## Premissas aplicáveis

- Nenhuma. É leitura do que as specs da CREED-32, 33 e 35 deixaram para a integração.
