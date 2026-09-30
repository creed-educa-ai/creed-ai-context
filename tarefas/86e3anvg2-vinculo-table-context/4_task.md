# Task 4 — Users: o acesso passa a exigir um vínculo

**Repo:** `creed-backend`
**Depende de:** task 2. Corre em paralelo com a task 3.

## Objetivo

`POST /api/v1/users` passa a exigir `link_id`, recusa vínculo inexistente (404) ou
já em uso (409), e a resposta traz `role`, `link_id` e `organization_id` lidos do
vínculo. `UserService` ganha o método que a task 5 vai usar na guarda e no login.

## Contexto que você não tem como adivinhar

**O papel deixa de ser do usuário.** A partir desta task, `user.role` continua no banco,
mas **ninguém lê**. O papel de um login é o papel do vínculo dele (modelo [C2]: 1 login
= 1 vínculo). Por isso `role` nunca entra no `UserCreate`: o `contrato-api.md` da
CREED-23 já dizia que mandar `role` no POST é "sintoma de ter entendido o modelo ao
contrário".

**`users` conversa com `links` só pelo `LinkService`**, injetado. O projeto já
tem esse mecanismo: `COMPOE_COM_SERVICE_DE` em `tests/test_arquitetura.py`, onde hoje
está `"authentication": "le o usuario pelo UserService"`. Acrescente
`"users": "le o papel e a organizacao do vinculo pelo LinkService"`. Isso libera
`users/service.py` e `users/dependencies.py` para importar de `app.domains.links`, e
**só esses dois arquivos**. `schemas.py` e `models.py` continuam sem importar
`links` (spec, "Abordagem técnica", itens 8 e 9).

**Por isso `UserResponse.role` vira `str`.** `users/schemas.py` não pode importar
`Roles`. O `de_model()` passa a receber o usuário **e** os dados do vínculo: o próprio
`Link`, tipado de forma que não obrigue a importar a classe (por exemplo, `role:
str` e `organization_id: uuid.UUID` como argumentos). Escolha a forma mais simples que
passe no `mypy` e no teste de arquitetura, e diga no PR qual foi.

**`keycloak_id` e `name` continuam no `UserCreate`.** O formato final do contrato
(`{link_id, email, initial_password}`) depende de provisionar o usuário no Keycloak
pela API, e isso não entra aqui (spec, "Não entra").

## Arquivos que provavelmente mudam

- `app/domains/users/schemas.py`: `UserCreate` com `link_id`; `UserResponse` com
  `role: str`, `link_id` e `organization_id`
- `app/domains/users/service.py`: a regra do cadastro e o método de leitura para a
  guarda
- `app/domains/users/repository.py`: `get_by_link_id`, para a regra do 409
- `app/domains/users/dependencies.py`: injeta o `LinkService` no `UserService`
- `app/domains/users/router.py`: 404 no `POST`
- `tests/test_arquitetura.py`: a entrada `"users"` em `COMPOE_COM_SERVICE_DE`
- `tests/domains/users/test_service.py`: um `FakeLinkService` e os casos novos

## Molde

A regra de conflito copia `create_user_service`, que já confere e-mail repetido. A
injeção de um service em outro copia `app/domains/authentication/dependencies.py`, que
recebe o `UserService` do mesmo jeito.

## A regra do cadastro, em ordem

1. E-mail já existe → `ConflictError` (**já existe hoje**, não mude).
2. `link_id` não existe (o `LinkService` devolve `None`) → `NotFoundError`.
3. Outro usuário já tem esse `link_id` → `ConflictError`. O `unique` do banco é a
   última rede, e o service confere antes, como faz com o e-mail.
4. Cria o `User` com `link_id`. **Não passe `role`**: o default do model preenche a
   coluna, que ninguém mais lê.

## O método que a guarda e o login vão usar

`UserService` ganha **um** método de leitura: recebe o e-mail e devolve o usuário ativo
junto com o papel e a organização do vínculo. Devolve `None` se o usuário não existe,
está inativo, não tem `link_id`, ou o vínculo não é encontrado. A forma do retorno
fica à sua escolha (um `dataclass` pequeno em `users/service.py` é o caminho mais
simples), mas ele precisa carregar pelo menos: `id`, `email`, `role` (`str`),
`link_id` e `organization_id`.

`get_active_user_by_email` **continua existindo** nesta task, porque a guarda e o login
ainda o chamam. Quem troca os consumidores é a task 5. Se, depois da 5, ninguém mais
chamar esse método, a 5 o apaga.

## Critérios de aceite

- [ ] `POST /users` sem `link_id` → **422**.
- [ ] Com `link_id` inexistente → **404**.
- [ ] Com `link_id` já usado por outro usuário → **409**.
- [ ] Válido → **201**, com `role`, `link_id` e `organization_id` iguais aos do
      vínculo, **mesmo que `user.role` na linha gravada seja `respondente`**.
- [ ] O método novo devolve `None` para: usuário inexistente, usuário inativo, usuário
      sem `link_id`, e `link_id` que o `LinkService` não encontra.
- [ ] O método novo devolve o papel **do vínculo**. Teste com um usuário cuja coluna
      diz `respondente` e cujo vínculo diz `admin`: o resultado é `admin`.
- [ ] `users/schemas.py` e `users/models.py` não importam `app.domains.links`.
- [ ] `pytest tests/test_arquitetura.py` passa, com a entrada nova e o motivo escrito.

## Como testar

```bash
cd creed-backend
pytest tests/domains/users tests/test_arquitetura.py -q
ruff check . && mypy app
```

`FakeLinkService` é o dublê: um dicionário `id → objeto com role e
organization_id`, e o método de ler por id. Ele entra no `UserService` pelo
construtor, do mesmo jeito que o `FakeUserRepository`.

`um_user()` ganha `link_id` no padrão. Os testes antigos que conferem
`resposta.role is UserRole.ADMIN` (`TestUserResponse`) passam a conferir o papel
vindo do vínculo, como `str`.

## Premissas aplicáveis

- **P-008**: todo login nasce de um vínculo. É o `link_id` obrigatório no
  `UserCreate`.
- **P-013**: o acesso nasce `active`. Não muda aqui.
