# Task 5 — Gravar e ler respostas individuais

**Repo:** `creed-backend`
**Depende de:** task 1 (`answer.form_response_id`) e task 4 (dono da resposta de
formulário).

## Objetivo

O dono de uma resposta de formulário em andamento grava a resposta de cada pergunta
descritiva e lê o que gravou.

## Contexto que você não tem como adivinhar

**`AnswerService` já existe e não tem rota.** `record()` já recusa as duas formas juntas
(texto e alternativa) e nenhuma das duas. Esta task o liga ao router e acrescenta o que
falta.

**`responses/service.py` não pode importar `QuestionType`.** `test_dominio_nao_importa_dominio`
só libera `service` e `dependencies` de outro domínio, e o enum mora em
`questions/models.py`. Quem responde "essa pergunta aceita texto?" é o `QuestionService`,
com dois métodos novos:

- `get(question_id) -> Question`, que levanta `NotFoundError`;
- um método que diz se a pergunta é descritiva (por exemplo, `is_descriptive(question) ->
  bool`).

**A resposta de formulário é do mesmo domínio**, então o `AnswerService` usa o
`FormResponseRepository` direto, sem service.

**Ordem das conferências no `POST`**, igual à tabela de erros da spec:

1. a resposta de formulário existe → senão 404
2. é do vínculo logado → senão 403
3. está em andamento → senão 409
4. a pergunta existe e é do formulário dessa resposta → senão 422
5. a pergunta é descritiva → senão 422, com a mensagem "respostas a perguntas objetivas
   chegam com as alternativas (CREED-37)" (D2)
6. há texto, e não veio `option_id` → senão 422 (a regra atual, mais `option_id`
   sozinho)
7. a pergunta ainda não tem resposta nesta resposta de formulário → senão 409 (P-032)

**Sem constraint única no banco para o item 7.** O modelo deixou `answer` sem `unique
(form_response_id, question_id)` de propósito, por causa da objetiva de múltipla escolha.
Dois `POST` simultâneos na mesma pergunta passam os dois. Aceito nesta rodada; escreva
isso no docstring do método.

**`GET` só para o dono** (spec, "Não entra": gestor não lê a resposta individual de
outra pessoa). Ordem de gravação: `created_at`.

## Arquivos que provavelmente mudam

- `app/domains/questions/service.py`: `get` e o método de tipo
- `app/domains/responses/models.py`: nada além da task 1
- `app/domains/responses/repository.py`: `AnswerRepository.list_by_form_response` e a
  busca por (resposta de formulário, pergunta)
- `app/domains/responses/service.py`: `AnswerService(answers, form_responses, questions)`,
  com `record` recebendo `form_response_id` e `link_id`, e o método de listar
- `app/domains/responses/schemas.py`: `AnswerResponse` com `form_response_id`;
  `AnswerCreate` sem mudança
- `app/domains/responses/dependencies.py`: montar o `AnswerService` com
  `FormResponseRepository` e o service de `questions`
- `app/domains/responses/router.py`: `POST` e `GET`
  `/form-responses/{form_response_id}/answers`, com `CurrentUserDep`
- `tests/domains/responses/test_service.py`, `test_router.py`
- `tests/domains/questions/test_service.py`: os dois métodos novos
- `tests/test_openapi.py`: as duas rotas novas

## Molde

- Router, service e fake: o mesmo formato da task 4.
- Repository com `list` ordenado no banco: `QuestionRepository.list_by_form`.

## Critérios de aceite

- [ ] Descritiva com texto: 201, com `form_response_id` e `question_id`.
- [ ] Cada um dos sete casos da lista acima devolve o código dela, testado no service.
- [ ] `GET` devolve as respostas gravadas em ordem de gravação; de outro vínculo: 403;
      resposta de formulário inexistente: 404.
- [ ] Sem token: 401 nas duas rotas.
- [ ] Marcador `🟡 Premissa P-032` no método que recusa a segunda resposta.
- [ ] `pytest tests/test_arquitetura.py` passa sem entrada nova além das da task 2.

## Como testar

```bash
cd creed-backend
pytest tests/domains/responses tests/domains/questions tests/test_arquitetura.py tests/test_openapi.py -q
```

Service: fakes de `FormResponseRepository`, `AnswerRepository` e `QuestionService`, e um
teste por caso da ordem de conferências. Router: caminho feliz do `POST` e do `GET` com o
token de `respondente`.

## Premissas aplicáveis

- **P-032**: uma resposta por pergunta descritiva; gravar de novo dá 409.
- **P-031**: o dono é o vínculo do login.
