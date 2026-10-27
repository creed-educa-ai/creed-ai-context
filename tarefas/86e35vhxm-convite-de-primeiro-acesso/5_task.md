# Task 5 — Primeiro admin por convite

**Repo:** `creed-backend`
**Depende de:** task 2 (`UserService.create_user_service` com convite, e
`admin.send_update_password_email`). Não conflita com a 3 nem com a 4, e pode andar em
paralelo a elas.
**Branch sugerida:** `feat/86e35vhxm-primeiro-admin-por-convite`

## Objetivo

Um comando cria o primeiro admin de qualquer ambiente, inclusive produção, mandando o
convite por e-mail, sem senha conhecida. O mesmo comando cria a organização da própria
CREED, onde ficam esse admin e, depois, os mentorandos.

## Contexto que você não tem como adivinhar

- **Por que existe.** O seed (`scripts/seed_local.py`) só roda com `ENVIRONMENT=local` e
  cria usuário com senha conhecida. Em produção não existe usuário nenhum, e o login real
  (último critério da CREED-283) depende de um (CREED-285, parte E). Este script **roda em
  qualquer ambiente** e nunca define senha.
- **O que ele faz**, de forma idempotente:
  1. garante a organização da CREED, com id fixo, como o seed faz com as dele, e o
     documento dela (`DocType.OTHER`, valor sintético, P-048);
  2. se o e-mail já tem acesso, reenvia o convite (`admin.send_update_password_email`) e
     termina;
  3. senão, cria o participante (nome do argumento), depois o vínculo (`admin`, `emprego`,
     na organização da CREED), e chama `UserService.create_user_service`. Pela D7, isso
     cria no Keycloak, grava e convida.

  O commit é do próprio script, no fim, como no seed. O `test_commit_so_no_get_db` só olha
  `app/`.
- **Argumentos**: `--email` e `--nome`. Nenhum dado de pessoa entra no código.
- **A imagem não tem `scripts/`.** O `Dockerfile` copia só `app`, `alembic` e
  `alembic.ini`, então sem `COPY scripts ./scripts` o comando de produção não acha o
  módulo. O `seed_local.py` também vai na imagem, e continua barrado fora do local pelo
  próprio `ENVIRONMENT`.
  ⚠️ O [creed-backend#45](https://github.com/creed-educa-ai/creed-backend/pull/45) (imagem
  arm64) também mexe no `Dockerfile`: o conflito é de uma linha.
- **Em produção**, depois do release, por quem tem acesso à EC2:
  `docker compose run --rm back python -m scripts.convidar_primeiro_admin --email <e-mail> --nome "<nome>"`.

## Arquivos que provavelmente mudam

- `scripts/convidar_primeiro_admin.py` (novo).
- `Dockerfile`: `COPY scripts ./scripts`.
- `README.md`: seção "Primeiro admin de um ambiente novo".
- `tests/test_convidar_primeiro_admin.py` (novo).

## Molde

- Script com sessão própria, ids fixos e idempotência: `scripts/seed_local.py` (`semear`,
  `_ensure_organization`).
- Testes de script: `tests/test_seed_local.py`.

## Critérios de aceite

- [ ] No local, a primeira execução:
  - [ ] cria a organização da CREED, com o documento;
  - [ ] cria o participante, o vínculo `admin` e o usuário;
  - [ ] faz o convite chegar ao Mailpit.
- [ ] A segunda execução com o mesmo e-mail não cria nada e manda um convite novo.
- [ ] Uma execução com outro e-mail cria outro admin na mesma organização, sem duplicar a
      organização.
- [ ] Se o envio falha, nada fica no banco nem no Keycloak, porque é o mesmo
      `create_user_service`.
- [ ] A imagem construída tem `/app/scripts/convidar_primeiro_admin.py`.

## Como testar

```bash
cd creed-backend
python -m scripts.convidar_primeiro_admin --email admin2@creed.local --nome "Admin Dois"   # convite no Mailpit
python -m scripts.convidar_primeiro_admin --email admin2@creed.local --nome "Admin Dois"   # reenvio
pytest tests/test_convidar_primeiro_admin.py tests/test_seed_local.py -q
docker build -t creed-backend:teste . && docker run --rm creed-backend:teste ls scripts
```

- **Caso feliz:** um convite na primeira execução.
- **Caso de borda:** a segunda execução, que reenvia sem criar nada.

## Premissas aplicáveis

- P-052 — o primeiro admin nasce por convite, e a primeira convidada é a professora.
- P-048 — a organização da CREED, criada uma vez por ambiente, com documento sintético.
