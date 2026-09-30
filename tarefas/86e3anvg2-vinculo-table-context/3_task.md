# Task 3 — Vínculo: endpoint de criação

**Repo:** `creed-backend`
**Depende de:** task 2. Corre em paralelo com a task 4.

## Objetivo

`POST /api/v1/organizations/{organization_id}/links` cria um vínculo e devolve 201,
e só quem tem papel `admin` consegue chamar.

## Contexto que você não tem como adivinhar

**O arquivo é `links/router.py`, mas a URL começa em `/organizations`.** O vínculo é
sub-recurso da organização na URL, como a tarefa desenhou a rota. Isso não faz dele
parte do domínio `organizacoes`, que nem tem tabela ainda. O prefixo do `APIRouter`
descreve o endereço, não o dono do arquivo (spec, "Abordagem técnica", item 5):

```python
router = APIRouter(prefix="/organizations/{organization_id}/links", tags=["links"])
```

**Não existe 404 nesta rota.** Qualquer `organization_id` que seja um UUID válido é
aceito, porque não há tabela `Organization` para consultar. Isso é esperado. Não
tente conferir.

**Só `admin` cria vínculo.** Criar um vínculo decide o papel de acesso de alguém, e a
P-008 reserva o cadastro dessa cadeia ao `admin`. A guarda já existe:
`require_role("admin")`, em `app/shared/authorization.py`. Use-a como
`dependencies=[Depends(require_role("admin"))]` no decorator, do jeito que
`tests/shared/test_authorization.py` monta a rota `/admin`.

## Arquivos que provavelmente mudam

- `app/domains/links/dependencies.py`
- `app/domains/links/router.py`
- `app/main.py`: o import e a entrada na tupla de routers
- `tests/domains/links/test_router.py`

## Molde

`app/domains/users/dependencies.py` (a cadeia `get_repository` → `get_service` →
`ServiceDep`) e `app/domains/users/router.py` (router fino, `de_model()` na saída,
nenhum import de `models`).

Para o teste HTTP, a forma de `tests/domains/authentication/test_router.py`:
`TestClient` com `dependency_overrides` no service. Para a guarda, siga
`tests/shared/test_authorization.py`: um `validate_token` falso via `monkeypatch`, e o
`get_service` de `users` sobrescrito.

⚠️ **O teste da guarda muda de forma na task 5.** Hoje `require_role` confere o papel
contra `user.role`. Depois da task 5, confere contra o vínculo. Escreva os casos
401/403 do jeito que `test_authorization.py` está hoje, e deixe para a task 5 ajustar o
dublê de `UserService`. Se a task 5 já tiver mesclado quando você começar, use o dublê
novo.

## Critérios de aceite

- [ ] Com token `admin` e corpo válido, a rota devolve **201** com `LinkResponse`, e
      `organization_id` na resposta é o da URL.
- [ ] Sem `Authorization`, **401**.
- [ ] Com token de papel `respondente`, **403**.
- [ ] Com `type` fora do enum, **422**. Com `organization_id` na URL que não é UUID,
      **422**.
- [ ] Sem `department_id` no corpo, **201** com `department_id: null`.
- [ ] A rota aparece em `/api/v1/docs`.
- [ ] `router.py` não importa `models` nem `sqlalchemy`, e
      `pytest tests/test_arquitetura.py` passa.

## Como testar

```bash
cd creed-backend
pytest tests/domains/links tests/test_arquitetura.py -q
ruff check . && mypy app
```

De ponta a ponta, com o admin do seed. Enquanto a task 5 não mescla, o login ainda lê
`user.role`, e o seed já deixa o dev como `admin`:

```bash
uvicorn app.main:app --reload
TOKEN=$(curl -s -X POST localhost:8000/api/v1/authentication/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"dev@creed.example.com","password":"<senha do realm>"}' | jq -r .access_token)

curl -i -X POST localhost:8000/api/v1/organizations/00000000-0000-0000-0000-000000000001/links \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"participant_id":"00000000-0000-0000-0000-000000000002","type":"emprego","role":"gestor"}'
```

## Premissas aplicáveis

- **P-008**: só `admin` cria a cadeia que leva a um login. Aqui é o
  `require_role("admin")`.
