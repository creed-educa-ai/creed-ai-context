# Task 5 — Guarda e login passam a ler o papel do vínculo

**Repo:** `creed-backend`
**Depende de:** task 4.

## Objetivo

Toda rota protegida e todo login passam a usar o papel do **vínculo**, e não mais
`user.role`. Usuário sem vínculo leva 401. O seed local cria e liga o vínculo do
usuário de dev, para o login local continuar funcionando.

## Contexto que você não tem como adivinhar

**Como a guarda funciona hoje** (`app/shared/authorization.py`). O token do Keycloak
traz a realm role no claim. `require_role` responde 403 se o claim não tem o papel
pedido. Depois disso, `_check_against_database` busca o usuário no banco e confere se o
claim bate com `user.role`. Se não bate, devolve **401 e loga um erro**. Essa divergência
só aparece quando alguém mudou o papel de um lado e esqueceu o outro (spec da CREED-23,
D2 e D4).

**O que muda:** a conferência passa a ser contra o papel do vínculo, usando o método
que a task 4 criou em `UserService`. Nenhum outro arquivo de `shared/` muda de forma.
`authorization.py` continua falando **só** com `UserService`, nunca com
`LinkService` (spec, "Abordagem técnica", item 8).

**A realm role continua configurada à mão.** Nada nesta task grava no Keycloak. Um
usuário `admin` no realm cujo vínculo diga `gestor` passa a levar 401, e isso é o
comportamento correto. **Não afrouxe a guarda para aceitar a divergência.**

**O `GET /authentication/session` monta a sessão a partir do `AuthenticatedUser`**, e
não a partir do banco (`authentication/router.py`). Para ele devolver `link_id` e
`organization_id`, o `AuthenticatedUser` que `_check_against_database` devolve precisa
carregar esses dois campos. Acrescente-os com `None` como padrão, para não quebrar quem
constrói um `AuthenticatedUser` só a partir do token.

**O seed** (`scripts/seed_local.py`) hoje grava o `User` com `role=ADMIN`. Depois desta
task, isso não dá mais acesso a nada: sem vínculo, o login do dev dá 401. O seed passa
a:

1. criar um `Link` com `role=ADMIN`, `type=EMPREGO`, e `participant_id` e
   `organization_id` **fixos**, como constantes no topo do script. Comente que os dois
   ficam órfãos até `Participant` e `Organization` existirem, e que a amarração deve
   criar essas duas linhas com esses ids (spec, "Abordagem técnica", item 13);
2. ligar o usuário ao vínculo (`link_id`);
3. continuar idempotente. Se o usuário já existe e já tem vínculo, não cria outro. Se
   existe sem vínculo (banco de antes desta task), cria o vínculo e liga.

O seed usa os repositories direto, como já faz com `UserRepository`. Ele está fora de
`app/`, e o teste de arquitetura não o cobre.

## Arquivos que provavelmente mudam

- `app/shared/authorization.py`: `_check_against_database` e `AuthenticatedUser`
- `app/domains/authentication/service.py`: `_build_session` passa a montar `role`,
  `link_id` e `organization_id` a partir do método novo de `UserService`
- `app/domains/authentication/router.py`: `/session` devolve `link_id` e
  `organization_id`
- `app/domains/users/service.py`: apagar `get_active_user_by_email`, se ninguém mais o
  chamar
- `scripts/seed_local.py`
- `README.md`: rodar o seed de novo depois do `alembic upgrade head` desta entrega
- `tests/shared/test_authorization.py`: o `_FakeUserService` passa a responder o
  método novo
- `tests/domains/authentication/test_service.py` e `test_router.py`

## Molde

Não há domínio-exemplo para isto: é a própria guarda. O molde é o estado atual de
`authorization.py` e de `tests/shared/test_authorization.py`. Mude o **mínimo**: a
origem do papel, e não a forma da guarda.

## Critérios de aceite

- [ ] Claim `admin`, vínculo `admin` → **200** numa rota `require_role("admin")`.
- [ ] Claim `admin`, vínculo `gestor`, **coluna `user.role = admin`** → **401**, e um log
      de erro. **É o teste que prova que a coluna deixou de ser lida.** Sem ele, a task
      não está pronta.
- [ ] Usuário sem vínculo → **401** em `CurrentUserDep` e em `require_role`.
- [ ] Claim `respondente` numa rota `admin` → **403**, sem consultar o banco. O teste
      atual `test_insufficient_role_does_not_query_the_database` continua passando.
- [ ] O login e o `/renew` devolvem na sessão `role`, `link_id` e `organization_id`
      do vínculo. Usuário sem vínculo no login → **401** com a mensagem de credencial
      inválida que já existe.
- [ ] `GET /authentication/session` devolve `link_id` e `organization_id`
      preenchidos.
- [ ] `grep -rn "\.role\b" app/` não encontra nenhuma leitura de `user.role` ou de
      `User.role`. O que sobra é o `role` do vínculo e do claim.
- [ ] `python scripts/seed_local.py` rodado duas vezes deixa o dev com **um** vínculo
      `admin`, e o login local funciona.
- [ ] `ruff check . && mypy app && pytest` passam.

## Como testar

```bash
cd creed-backend
pytest tests/shared tests/domains/authentication tests/domains/users -q
ruff check . && mypy app && pytest
```

De ponta a ponta, no banco local:

```bash
alembic upgrade head
python scripts/seed_local.py && python scripts/seed_local.py
docker compose exec db psql -U creed -d creed -c "SELECT count(*) FROM links"   # 1
uvicorn app.main:app --reload
TOKEN=$(curl -s -X POST localhost:8000/api/v1/authentication/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"dev@creed.example.com","password":"<senha do realm>"}' | jq -r .access_token)
curl -s localhost:8000/api/v1/authentication/session -H "Authorization: Bearer $TOKEN"
```

A prova manual de que a coluna não é mais lida:

```bash
# a coluna muda, o vínculo não: o login continua admin
docker compose exec db psql -U creed -d creed \
  -c "UPDATE \"user\" SET role = 'RESPONDENTE' WHERE email = 'dev@creed.example.com'"
curl -s localhost:8000/api/v1/authentication/session -H "Authorization: Bearer $TOKEN"

# o vínculo muda: a rota protegida dá 401 (claim admin × vínculo gestor)
docker compose exec db psql -U creed -d creed \
  -c "UPDATE links SET role = 'GESTOR'"
curl -i localhost:8000/api/v1/authentication/session -H "Authorization: Bearer $TOKEN"
```

Depois, desfaça: `UPDATE links SET role = 'ADMIN'`.

⚠️ **Avise o time no PR:** depois deste merge, cada pessoa roda
`python scripts/seed_local.py` depois do `alembic upgrade head`. Sem isso, a tela de
login responde "e-mail ou senha inválidos" com a senha certa.

## Premissas aplicáveis

- **P-008**: login sem vínculo não existe. Aqui isso aparece como o 401 para quem não
  tem vínculo.
- **P-006**: os papéis comparados com o claim.
