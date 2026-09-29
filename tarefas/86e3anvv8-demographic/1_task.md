# Task 1 — Gravar e consultar os demográficos de um participante

**Repo:** `creed-backend`
**Depende de:** o domínio `participants` da CREED-36 (branch `feat/36-participant`, PR #28)

## Objetivo

Um `admin` grava ou substitui os dados demográficos de um participante por
`PUT /api/v1/participants/{participant_id}/demographics`, com as opções validadas, e o
`GET` do participante passa a devolver esses dados.

## Arquivos que provavelmente mudam

- `app/domains/participants/models.py`: model `ParticipantDemographics` (tabela
  `participant_demographics`, `participant_id` como PK e FK) e o relacionamento
  `Participant.demographics`
- `app/domains/participants/schemas.py`: `DemographicsUpdate` (entrada), `DemographicsResponse`
  (saída) e o campo `demographics` em `ParticipantResponse`
- `app/domains/participants/repository.py`: `get_demographics(participant_id)` e
  `save_demographics(demographics)`
- `app/domains/participants/service.py`: `update_demographics(participant_id, request)`
- `app/domains/participants/router.py`: rota `update_participant_demographics`
- `tests/domains/participants/test_service.py`, `test_router.py`
- `tests/test_openapi.py`: a rota nova

## Molde

O próprio domínio `participants` da CREED-36: mesma forma de repository, service, schema
com `de_model()`, guarda `require_role("admin")` por rota e testes de router com a guarda
de verdade. Nomes em inglês (ADR-0005), valores em português (P-023).

## Critérios de aceite

- [ ] Model `ParticipantDemographics` com as colunas da spec ("Dados"): `ethnicities` e
      `religions` como `ARRAY(String(40))`, not null, default lista vazia; os demais
      nuláveis; `created_at` com `server_default=now()` e `updated_at` com `onupdate`.
- [ ] `Participant.demographics` carrega junto com o participante (sessão assíncrona não
      faz lazy load). Participante sem linha de demográficos → `demographics` nulo.
- [ ] `DemographicsUpdate`, todos os campos opcionais:
  - [ ] `gender`: `feminino`, `masculino`, `nao_binario`, `prefiro_nao_informar` (P-023);
  - [ ] `age_range`: `18_25`, `26_35`, `36_45`, `46_55`, `56_65`, `65_mais`,
        `prefiro_nao_informar` (P-024);
  - [ ] `ethnicities` e `religions`: listas com os valores do front, **sem repetição**;
  - [ ] `nationality`: `brasileira`, `portuguesa`, `outra`;
  - [ ] `brazil_state` (27 UFs) só com `brasileira`, `portugal_region` (7 regiões) só com
        `portuguesa`, `other_nationality` só com `outra`, senão 422 (P-026);
  - [ ] `other_nationality` com no máximo 100 caracteres, sem espaços nas pontas (P-027).
- [ ] `PUT` com `admin` → 200 e `ParticipantResponse` com `demographics` preenchido.
- [ ] Segundo `PUT` substitui tudo: campo omitido volta nulo ou vazio.
- [ ] `PUT` com `{}` → 200, tudo nulo ou vazio.
- [ ] Participante inexistente → 404. Sem token → 401. `gestor`/`respondente` → 403 (P-025).
- [ ] `GET /api/v1/participants/{id}` traz `demographics` (nulo antes do primeiro `PUT`).
- [ ] Swagger no padrão do PR #17, cobrado por `tests/test_openapi.py`: resumo,
      descrição, `operation_id`, exemplos e respostas 401, 403, 404 e 422.
- [ ] `tests/test_arquitetura.py` passa sem exceção nova.

## Como testar

```bash
pytest tests/domains/participants tests/test_arquitetura.py tests/test_openapi.py -q
ruff check . && ruff format --check . && mypy app && pytest
```

Caso feliz: `PUT` completo com duas etnias e `brasileira` + `RS`; `GET` devolve igual.
Bordas: `{}`; lista com item repetido; `gender: "masc"`; `brazil_state` com
`portuguesa`; `other_nationality` com 101 caracteres; participante inexistente; papel
`respondente`.

Sem a tabela no banco (task 2), a rota não roda de ponta a ponta no Swagger local: esta
task é verificada pela suíte.

## Premissas aplicáveis

- P-023 — as opções válidas são as do front, inclusive gênero (sem o `outro` do modelo);
  etnia e religião aceitam várias, e "prefiro não responder" não exclui as outras.
- P-024 — idade como faixa etária, não data de nascimento.
- P-025 — só `admin` grava e lê demográficos; o respondente preencher os próprios espera
  o vínculo entre login e pessoa.
- P-026 — detalhe de nacionalidade incoerente com a nacionalidade é recusado (422).
- P-027 — "outra nacionalidade" com até 100 caracteres.
