# Task 2 — Cadastro público `POST /organizations/sign-up`

**Repo:** `creed-backend`
**Subtarefa:** [692 · Cadastro de empresa (E2)](https://app.clickup.com/t/1dfej6fvrvp)
**Branch:** `feat/692-cadastro-de-empresa`, saída da `feat/691-empresa-pendente`
**Depende de:** task 1 (`OrganizationStatus.PENDING`, colunas de contato, `with_documents`)

## Objetivo

Uma empresa se cadastra sozinha, sem login, e fica pendente: uma chamada cria o
documento e a organização.

## Contexto

É a rota que a tela `/sign-up` do front vai chamar (task 6). Ela é **pública**, como o
login: não tem `require_role`. A tela pede cinco campos e não pede endereço; a
organização nasce com o endereço "[A informar]" (P-075). O documento chega como a pessoa
digitou ("12.345.678/0001-90"). O back guarda só os dígitos e deduz o tipo (P-076).

A rota fica num **segundo router** do domínio, com o prefixo em inglês `/organizations`
(spec, Abordagem técnica, item 5). As tasks 4 e 5 acrescentam rotas neste mesmo arquivo.

## Contrato

`POST /api/v1/organizations/sign-up`, sem token.

| Campo | Regra |
|---|---|
| `name` | 1 a 200, sem caractere de controle |
| `document` | depois de tirar tudo o que não é letra nem número: 11 ou 14 dígitos |
| `email` | `EmailStr`; o service grava em minúsculas |
| `contact_name` | 2 a 200, sem caractere de controle (🟡 Premissa P-082: o `UserBase.name` do convite exige no mínimo 2) |
| `phone` | 1 a 30, sem caractere de controle |

| Status | Quando |
|---|---|
| 201 | `OrganizationResponse`, com `status: "pending"` e `address: "[A informar]"` |
| 409 | documento já cadastrado (mesmo tipo e número): `"Já existe um cadastro com este documento"` |
| 422 | campo faltando, vazio, longo demais, e-mail mal formado ou documento sem 11 nem 14 dígitos. `detail` é a lista do Pydantic, um item por campo |

## Arquivos que provavelmente mudam

- `app/domains/organizacoes/schemas.py`
  - `OrganizationSignUp`: os cinco campos, com `str_strip_whitespace` e o
    `sem_caractere_de_controle` de `app/shared/validators.py`.
  - Validador de `document`: tira o que não é letra nem número e exige
    `^\d{11}$|^\d{14}$`. Devolve o número já limpo.
- `app/domains/documents/repository.py`
  - `get_by_type_value(type, value) -> Document | None`.
  - `create(document) -> Document | None`: `None` quando a constraint
    `uq_documents_type_value` recusa, como o `OrganizationRepository.create`.
- `app/domains/documents/service.py`
  - `create_brazilian_document(number: str) -> Document`: 11 dígitos é `DocType.CPF`, 14
    é `DocType.CNPJ`. Se já existe (consulta ou `None` do `create`), levanta
    `ConflictError("Já existe um cadastro com este documento")`.
- `app/domains/organizacoes/service.py`
  - `ADDRESS_TO_BE_INFORMED = "[A informar]"`, com o marcador da P-075.
  - `sign_up(request: OrganizationSignUp) -> Organization`: cria o documento pelo
    `DocumentService`, depois a organização com `status=PENDING`, o endereço acima e
    `email=request.email.lower()`. As duas gravações estão na mesma transação da
    requisição, então um erro na segunda desfaz a primeira.
- `app/domains/organizacoes/router_organizations.py` (novo)
  - `router = APIRouter(prefix="/organizations", tags=["organizacoes"])`. Use a tag que
    já existe: tag nova precisa de descrição no `app/main.py`
    (`test_every_tag_used_by_a_route_has_a_description`).
  - `POST /sign-up`, `status_code=201`, `operation_id="sign_up_organization"`, sem
    guarda de papel. Resposta montada pelo `with_documents` da task 1. 409 e 422
    documentados em `responses=`, no formato do `router.py` do mesmo domínio.
  - Docstring do topo: por que um segundo router, e por que o prefixo em inglês
    (ADR-0005).
- `app/main.py`: registra o router novo. Nome de import sugerido:
  `organizations_router`.
- Testes: `tests/domains/organizacoes/test_router_organizations.py` (novo),
  `test_service.py`, `tests/domains/documents/test_service.py`. O `tests/test_openapi.py`
  confere sozinho resumo, descrição, `operation_id` e exemplos da rota nova.
- `tests/test_arquitetura.py`: o motivo de `organizacoes` passa a dizer "cria e lê
  documentos pelo DocumentService".
- `creed-ai-context/catalogo.md`: a linha de `organizacoes` ganha a rota.

## Molde

- `app/domains/links/router_members.py`: segundo router de um domínio.
- `OrganizationService.create` e `OrganizationRepository.create`: o `None` da constraint
  única virando 409.
- `PasswordResetRequest` na `dev`, vinda do creed-backend#52
  (`app/domains/authentication/schemas.py`): schema de rota pública com `EmailStr`.

## Critérios de aceite

- [ ] Sem token: 201, `status: "pending"`, `address: "[A informar]"`, contato gravado e
      e-mail em minúsculas.
- [ ] `"12.345.678/0001-90"` grava documento `cnpj` com valor `12345678000190`;
      `"123.456.789-09"` grava `cpf` com valor `12345678909`.
- [ ] O mesmo CNPJ de novo, com ou sem pontuação: 409, e nenhuma organização nova.
- [ ] Documento `"123"`: 422, e nada gravado.
- [ ] Cada campo vazio ou ausente dá 422 com o nome do campo no `detail`.
- [ ] Com token de qualquer papel, a rota se comporta igual (ela não olha o token).
- [ ] `ruff`, `pre-commit run mypy --all-files`, `pytest` e `tests/test_arquitetura.py`
      passam.

## Como testar

```bash
cd creed-backend
pytest tests/domains/organizacoes tests/domains/documents tests/test_openapi.py tests/test_arquitetura.py -q
ruff check . && ruff format --check .
pre-commit run mypy --all-files
```

Com a API e o banco local de pé (migration temporária da task 1 aplicada):

```bash
API=http://localhost:8000/api/v1
CORPO='{"name":"Empresa Teste","document":"12.345.678/0001-90","email":"Gestora@Empresa.com.br","contact_name":"Gestora Teste","phone":"51 99999-0000"}'
curl -s -X POST "$API/organizations/sign-up" -H "Content-Type: application/json" -d "$CORPO"
# de novo, sem pontuação → 409
curl -s -o /dev/null -w "%{http_code}\n" -X POST "$API/organizations/sign-up" \
  -H "Content-Type: application/json" -d "${CORPO/12.345.678\/0001-90/12345678000190}"
```

**O que os testes não provam:** a corrida de dois cadastros com o mesmo documento ao mesmo
tempo. O `None` do `create` cobre isso no código, mas só o Postgres de verdade dispara a
constraint.

## Premissas aplicáveis

- P-075 — sem endereço no cadastro; nasce "[A informar]".
- P-076 — só letras e números; 11 é CPF, 14 é CNPJ; repetido é 409.
- P-077 — o cadastro não confere se o e-mail já tem acesso.
