# Task 2 — Vínculo: repository, service e schemas

**Repo:** `creed-backend`
**Depende de:** task 1.

## Objetivo

O domínio `links` sabe criar um vínculo e ler um vínculo pelo id, com os schemas de
entrada e saída prontos e a regra testada sem banco.

## Contexto que você não tem como adivinhar

**`organization_id` não vem no corpo.** Ele vem da URL
(`/organizations/{organization_id}/links`, na task 3). Por isso `LinkCreate` não tem
o campo, e o service recebe `organization_id` como argumento separado.

**Não há regra de conflito.** Diferente de `UserService` (e-mail repetido → 409), criar
um vínculo não confere nada: o `.dbml` não define unicidade em `Vinculo`, e não há
tabela de organização ou de participante para consultar. O service monta a entidade e
delega ao repository. Não invente "um vínculo ativo por pessoa". Seria decisão de
produto (spec, "Abordagem técnica", item 6).

**Ler por id existe por causa da task 4**, e não por causa de uma rota. `users` vai
perguntar ao `LinkService` "esse vínculo existe, e qual é o papel dele?". Por isso a
leitura devolve `Link | None` e **não** levanta `NotFoundError`. Quem decide o que a
ausência significa é quem chama: 404 no cadastro de usuário, 401 no login.

## Arquivos que provavelmente mudam

- `app/domains/links/repository.py`
- `app/domains/links/service.py`
- `app/domains/links/schemas.py`
- `tests/domains/links/test_service.py`

## Molde

`app/domains/users/repository.py`, `service.py` e `schemas.py`, na forma: repository
com `flush()` + `refresh()` e **sem** `commit()`; service sem `fastapi` nem
`sqlalchemy`; schemas separados por direção, com um `@classmethod` no schema de saída
que monta a resposta a partir do model (`de_model()` no molde; em `links`, que já nasce
em inglês pelo ADR-0005, `from_model()`).

O teste de service copia a forma de `tests/domains/users/test_service.py`: um
`FakeLinkRepository` em memória, sem banco.

## O que cada arquivo tem

**`repository.py`**, em `LinkRepository`:

- `insert(link: Link) -> Link`: `add`, `flush`, `refresh`. O `refresh` é o que
  traz `start_at` e `created_at`, que vêm do `server_default`.
- `get_by_id(link_id: uuid.UUID) -> Link | None`

**`schemas.py`**:

- `LinkCreate`: `participant_id: uuid.UUID`, `department_id: uuid.UUID | None = None`,
  `type: LinkType`, `role: Roles`. Nenhum dos dois enums tem default.
- `LinkResponse`: os dez campos da tabela, `model_config =
  ConfigDict(from_attributes=True)`, e `from_model(link)`.

**`service.py`**, em `LinkService`. Os nomes dizem o caso de uso
(`camadas-do-back.md` → "Nome do método diz de qual camada é"):

- criar: recebe `organization_id` e `LinkCreate` e devolve o `Link` gravado;
- ler por id: recebe `link_id` e devolve `Link | None`.

## Critérios de aceite

- [ ] Criar um vínculo grava `organization_id` (do argumento), `participant_id`,
      `department_id`, `type` e `role` (do payload), e devolve a entidade que o repository
      devolveu.
- [ ] Criar sem `department_id` grava `department_id = None`.
- [ ] Ler um id que existe devolve o vínculo; ler um id que não existe devolve `None`,
      sem exceção.
- [ ] `LinkCreate` recusa (`ValidationError` do Pydantic) `type` ou `role` fora do
      enum e `participant_id` que não é UUID. Aceita o corpo sem `department_id`.
- [ ] `LinkResponse.from_model()` monta a saída a partir de um `Link`, com os enums
      serializados como `"emprego"` e `"gestor"`, não com o nome do membro.
- [ ] `service.py` não importa `fastapi` nem `sqlalchemy`, e `repository.py` não importa
      `app.shared.exceptions`. `pytest tests/test_arquitetura.py` passa.
- [ ] Nenhum `commit()`.

## Como testar

```bash
cd creed-backend
pytest tests/domains/links tests/test_arquitetura.py -q
ruff check . && mypy app
```

Caso feliz: criar e ler de volta. Casos de borda: criar sem `department_id`, e ler um id
inexistente. O corpo inválido é teste de schema: `LinkCreate.model_validate(...)`
dentro de `pytest.raises(ValidationError)`.

Lembrete do fake: um `Link` montado à mão não tem `start_at` nem `created_at`, porque
eles vêm do `server_default`. Para testar `from_model()`, preencha os dois à mão, como
`um_user()` faz em `tests/domains/users/test_service.py`.

## Premissas aplicáveis

- **P-006**: os valores de `role`.
- **P-029**, refutada em 2026-09-29: os nomes são em inglês (`Link`, `department_id`),
  pelo ADR-0005.
