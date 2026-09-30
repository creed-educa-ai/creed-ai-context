# Task 6 — O envio exige as descritivas obrigatórias

**Repo:** `creed-backend`
**Depende de:** task 5 (as respostas gravadas e o `QuestionService` composto).

## Objetivo

Enviar uma resposta de formulário com pergunta descritiva obrigatória sem resposta dá
422, dizendo quais faltam.

## Contexto que você não tem como adivinhar

**Só as descritivas contam (spec, item 9).** Uma objetiva obrigatória não pode ser
respondida até a CREED-37 (D2). Se ela contasse, nenhum formulário com objetiva
obrigatória seria enviado. Quando a CREED-37 chegar, ela passa a contar; escreva isso no
docstring.

**Quem sabe quais perguntas são obrigatórias é `questions`.** Um método novo em
`QuestionService`, por exemplo `list_required_descriptive(form_id) -> list[Question]`,
com o filtro feito no repository de `questions` (no banco, não em memória:
`list_by_form` já mostra como).

**A conferência entra depois das que o `PATCH` já faz:** existe (404) → dono (403) → em
andamento (409) → obrigatórias (422).

## Arquivos que provavelmente mudam

- `app/domains/questions/repository.py` e `service.py`
- `app/domains/responses/service.py`: `FormResponseService` passa a receber o
  `QuestionService` e o `AnswerRepository`
- `app/domains/responses/dependencies.py`
- `app/domains/responses/router.py`: 422 no `PATCH`, traduzido e documentado
- `tests/domains/responses/test_service.py`, `tests/domains/questions/test_service.py`
- `tests/test_openapi.py`: o `PATCH` já exige 422; conferir que continua

## Molde

`FormResponseService.submit_form_response`, o método que esta task estende.

## Critérios de aceite

- [ ] Descritiva obrigatória sem resposta: 422, com a mensagem citando as perguntas
      (id ou posição).
- [ ] Descritiva opcional sem resposta: não impede o envio.
- [ ] Objetiva obrigatória sem resposta: não impede o envio.
- [ ] Todas as descritivas obrigatórias respondidas: 200 e `submitted`.
- [ ] Formulário sem pergunta nenhuma: 200. Nada a exigir.

## Como testar

```bash
cd creed-backend
pytest tests/domains/responses tests/domains/questions -q
```

Os cinco critérios acima como testes de service, com fakes.

## Premissas aplicáveis

- Nenhuma nova. D2 explica por que a objetiva não conta.
