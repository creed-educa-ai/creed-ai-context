# ClickUp — CREED-69 · E-1 a E-6

```
Épico: 1dfej6fvrrn — CREED - 69 - Painel de controle (só a parte "Empresa (pov administradora)")
Spec: spec.md · Tasks: tasks.md
Gerado em: 2026-11-10 · Publicado em: 2026-11-10
```

> **Este arquivo é a carga literal.** Cada parágrafo e cada item de lista das Partes 3
> estão numa linha só, de propósito: o `markdown_description` do ClickUp transforma em
> parágrafo solto o item de lista quebrado em duas linhas. Nomes que parecem domínio de
> internet vão em código, porque o ClickUp os transforma em link.
>
> **Links não vão dentro de célula de tabela.** Na primeira publicação da 691, o ClickUp
> guardou o texto do link e jogou fora o endereço. Os permalinks ficam numa lista logo
> abaixo de cada tabela "O que já existe"; em lista, o link chega inteiro (conferido pela
> leitura de volta da 691).

## Mapa de publicação

Publicado em 2026-11-10, com o ok do Luís ("Ok, publica e renomeia"). Cada escrita
respondeu `success: true`; a 691 foi lida de volta duas vezes (antes e depois da
correção dos links), e o épico foi relido no fim para conferir nomes e datas.

| # | Subtarefa no board | Tasks | Repo | Ação | Estado | ID no ClickUp |
|---|---|---|---|---|---|---|
| — | Épico CREED - 69 - Painel de controle | — | — | deixar como está | intocado | `1dfej6fvrrn` |
| 1 | CREED - 691 - Empresa pendente (E1) | 1 | `creed-backend` | preencher a descrição | ✅ publicada (2 escritas: a segunda corrigiu os links) | `1dfej6fvrvn` |
| 2 | CREED - 692 - Cadastro de empresa (E2) | 2 | `creed-backend` | preencher a descrição | ✅ publicada | `1dfej6fvrvp` |
| 3 | CREED - 696 - Excluir empresa (E6) | 3 e 4 | `creed-backend` | preencher a descrição | ✅ publicada | `1dfej6fvrvw` |
| 4 | CREED - 693 - Aceitar ou rejeitar pedido (E3) | 5 | `creed-backend` | preencher a descrição | ✅ publicada | `1dfej6fvrvt` |
| 5 | CREED - 694 - Cadastro e tabela de empresas ligados ao back (E4-E5) | 6 e 7 | `creed-frontend` | preencher a descrição e renomear (era "Integração (E4-E5)") | ✅ publicada e renomeada | `1dfej6fvrvu` |

Na próxima rodada, cada uma já tem a linha de rastreio: a regra do workflow volta a
valer (atualiza o que mudou, deixa o que está igual).

**Desvios do workflow, e por quê:**

- **O épico não é tocado.** A descrição dele é do Leonardo e cobre o painel inteiro:
  empresa, administradora e mentorandos. Esta pasta especifica só a parte "Empresa (pov
  administradora)". Reescrever a descrição apagaria as outras partes.
- **As cinco subtarefas já existem sem rastreio.** A regra do workflow é não tocar em
  subtarefa sem rastreio. Aqui elas foram criadas vazias pelo Leonardo como lugar para
  esta especificação, todas estão atribuídas ao Luís, e o pedido de publicar nelas foi
  explícito. Nenhum texto existente se perde: as descrições estão vazias. Depois desta
  rodada, todas terminam com a linha de rastreio, e a próxima rodada volta à regra.
- **Não se criam subtarefas novas.** O board junta duas entregas em 696 (tasks 3 e 4) e
  em 694 (tasks 6 e 7), e o `tasks.md` já corta uma branch e um PR por subtarefa. O
  rastreio dessas duas cita as duas tasks (`3+4`, `6+7`).
- **Títulos:** ficam como estão, no padrão do board (`CREED - NNN - …`). A exceção
  proposta é a 694: "Integração" é uma atividade, e o checklist pede um resultado.

## Materiais — visão do épico

| Material | Onde está | Vai em | Situação |
|---|---|---|---|
| Contrato de cada rota (método, entrada, saída, erros) | spec, seção Contrato | 691, 692, 696, 693, 694 | ✅ colado no corpo |
| Passos da migration temporária | spec, seção Dados | 691 | ✅ colado no corpo |
| Texto das decisões tomadas sem a cliente | `decisoes/premissas.md` | todas | ✅ colado no corpo, sem o ID |
| Definição de organização, vínculo, membro, convite, papéis | `glossario.md` | todas | ✅ colada no corpo |
| Arquivos que servem de forma (`router_members.py`, `MemberRemovalService`, `MemberService`…) | `creed-backend`, `creed-frontend` | todas | ✅ permalinks no corpo |
| Imagem do modal de aceite | anexada na [CREED-595](https://app.clickup.com/t/1dfej6ftzq6) | 694 | ✅ link no corpo |
| O que está de pé no `docker-compose` local (Mailpit, Keycloak) | README do back | 696, 693, 694 | ✅ colado no corpo |

Nada a anexar como arquivo nesta rodada. As telas já existem no front (a integração não
desenha tela nova), e o contrato cabe no corpo de cada subtarefa.

---

## Parte 2 — descrição do épico

**Não vai para o board nesta rodada** (ver "Desvios"). Se um dia o épico for só desta
pasta, a Parte 2 se escreve a partir da spec.

---

## Parte 3 — subtarefas

### 1 · `1dfej6fvrvn` · CREED - 691 - Empresa pendente (E1)

<!-- inicio 1dfej6fvrvn -->
### Em uma frase

A empresa passa a poder ficar **pendente** no banco, com o e-mail, o responsável e o telefone de quem a cadastrou, e a leitura de empresas devolve esses dados e o número do documento.

### O que muda para quem usa

Uma empresa vai poder pedir acesso à plataforma sozinha, pela tela de cadastro, e ficar à espera da aprovação da administradora (a equipe da CREED, dona da plataforma). Esse "à espera" é o status **pendente**. Hoje ele só existe na tela, com dados de mentira: o banco só conhece empresa ativa ou inativa e não guarda o e-mail, o responsável nem o telefone que a tela pede.

Nesta entrega a tela ainda não muda. O que muda é que o banco e a leitura de empresas passam a ter tudo o que a tela de empresas da administradora mostra: o status pendente, os dados de contato e o número do documento (CPF ou CNPJ).

Uma regra nova: a empresa pendente não vira ativa nem inativa por edição comum. Ela só sai desse estado sendo aprovada ou rejeitada pela administradora (subtarefas 693 e 696). Nome e endereço continuam editáveis.

No código, empresa é **organização** (`Organization`, tabela `organizations`): a instituição à qual as pessoas se ligam. A própria CREED também é uma organização, onde ficam a equipe da plataforma e os mentorandos.

### Como pretendemos fazer

- O status da organização ganha um tipo próprio no banco, `organization_status` (`pending`, `active`, `inactive`). Hoje ela usa o tipo `recordstatus`, que é compartilhado com o login (`user`) e com o participante (`participants`). Pôr "pending" ali faria "pendente" valer também para login e pessoa.
- E-mail, responsável e telefone viram três colunas novas em `organizations`, que podem ficar vazias: as organizações criadas pela administradora não têm esses dados.
- O número do documento mora na tabela `documents`. Para não fazer uma consulta por empresa, o service lê os documentos de uma página inteira numa chamada só ao `DocumentService`.
- O `schemas.py` **não importa** o `service.py` do mesmo domínio: o service já importa o schemas, e seria import circular. Por isso o `de_model` recebe o tipo e o número do documento separados.
- O `PATCH` continua recebendo o status como `RecordStatus` (`active`/`inactive`). É isso que impede alguém de mandar `pending` por ali.

**Migration.** Pela regra do projeto, o PR **não** traz arquivo em `alembic/versions/`: quem gera a migration consolidada da sprint é o AGES III. Gere a migration no seu banco local para testar, **escreva à mão** a troca de tipo (o autogenerate não a escreve direito), teste, rode `alembic downgrade` e só então apague o arquivo. A seção "Banco" do PR copia estes passos:

```
1. CREATE TYPE organization_status AS ENUM ('PENDING', 'ACTIVE', 'INACTIVE')
2. ALTER TABLE organizations ALTER COLUMN status TYPE organization_status
   USING status::text::organization_status
3. add_column: email String(320), contact_name String(200), phone String(30),
   todas nullable, sem server_default
4. downgrade: UPDATE organizations SET status = 'INACTIVE' WHERE status = 'PENDING';
   ALTER de volta para recordstatus com o mesmo USING; drop das três colunas;
   DROP TYPE organization_status. Nenhuma linha é apagada na volta.
```

Os rótulos ficam em maiúsculas porque o SQLAlchemy grava o nome do membro, como no `recordstatus` e no `doc_type`. A API continua mostrando `pending`.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/organizacoes/models.py` | `OrganizationStatus(enum.Enum)` com `PENDING`, `ACTIVE`, `INACTIVE`; `status` com `Enum(OrganizationStatus, name="organization_status")`, padrão `ACTIVE`; colunas `email`, `contact_name`, `phone` |
| `app/domains/organizacoes/schemas.py` | `OrganizationDocument` (`type: str`, `value: str`); `OrganizationResponse` com `status: OrganizationStatus`, `email`, `contact_name`, `phone` (`str \| None`) e `document`; `de_model(organization, document_type, document_value)` |
| `app/domains/organizacoes/service.py` | dataclass `OrganizationWithDocument`; `with_documents(organizations)`; `create` grava `ACTIVE`; `update` levanta `ConflictError` quando a pendente recebe `status` e converte o `RecordStatus` em `OrganizationStatus` |
| `app/domains/organizacoes/router.py` | as quatro rotas montam a resposta pelo `with_documents`; o `PATCH` documenta o 409 |
| `app/domains/documents/repository.py` e `service.py` | `list_by_ids(ids) -> list[Document]` |
| `scripts/seed_local.py` | a organização do seed grava `OrganizationStatus.ACTIVE` (hoje grava `RecordStatus.ACTIVE`, perto da linha 307) |
| `tests/test_arquitetura.py` | o motivo de `organizacoes` em `COMPOE_COM_SERVICE_DE` passa a dizer que lê os documentos pelo `DocumentService` |
| `tests/domains/organizacoes/` e `tests/domains/documents/` | `test_models.py` (o teste da coluna hoje confere `RecordStatus`), `test_service.py`, `test_router.py` |

`get`, `organization_exists` e `list_page` do `OrganizationService` **não mudam de assinatura**: o convite de membro (creed-backend#51) chama o `get`.

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| `DocType` e a coluna `type` | `app/domains/documents/models.py`, linhas 20 a 40 | forma de um enum do domínio com nome de tipo próprio no banco |
| `Member` | `app/domains/links/service.py`, linhas 24 a 35 | forma de um dataclass de leitura montado no service |
| `ConflictError` | `app/shared/exceptions.py` | o 409 |

Permalinks (abrem o arquivo na versão da `dev` usada nesta especificação):

- [app/domains/documents/models.py, linhas 20 a 40](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/app/domains/documents/models.py#L20-L40)
- [app/domains/links/service.py, linhas 24 a 35](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/app/domains/links/service.py#L24-L35)

### Contrato

| Método | Rota | Quem | Entrada | Saída |
|---|---|---|---|---|
| GET | `/api/v1/organizacoes` (já existe) | admin | `?pagina=1&tamanho_pagina=50` (até 200) | 200 · `PaginaDe[OrganizationResponse]`, agora com as pendentes |
| GET | `/api/v1/organizacoes/{organization_id}` (já existe) | admin; gestor só a própria | — | 200 · `OrganizationResponse` |
| PATCH | `/api/v1/organizacoes/{organization_id}` (já existe) | admin | `name`, `address`, `status` (`active`/`inactive`) | 200 · `OrganizationResponse` |

**`OrganizationResponse` depois desta entrega**

```json
{ "id": "uuid", "name": "Empresa Teste", "address": "[A informar]",
  "document_id": "uuid", "document": { "type": "cnpj", "value": "12345678000190" },
  "status": "pending", "email": "gestora@empresa.com.br",
  "contact_name": "Gestora Teste", "phone": "51 99999-0000",
  "created_at": "2026-11-10T14:30:00Z", "updated_at": null }
```

**Erros novos**

| Código | Quando | Corpo |
|---|---|---|
| 409 | `PATCH` com `status` numa empresa pendente | `{"detail": "A empresa está pendente: aprove ou rejeite o cadastro"}` |
| 422 | `PATCH` com `{"status": "pending"}` | validação padrão do FastAPI |

### Pronto quando

- [ ] O teste do model confere que `status` usa `OrganizationStatus` com o tipo `organization_status`, e que `user.status` e `participants.status` continuam `RecordStatus`.
- [ ] `GET /organizacoes` e `GET /organizacoes/{id}` devolvem `email`, `contact_name`, `phone` e `document: {type, value}`. Numa organização sem contato, os três primeiros vêm `null`.
- [ ] Listar uma página com 3 organizações faz **uma** chamada a `DocumentService.list_by_ids` (o dublê do teste conta).
- [ ] `PATCH` com `status` numa pendente dá 409, e nada muda. Com só `name`, dá 200 e ela continua pendente.
- [ ] `POST /organizacoes` continua criando organização ativa, com o mesmo corpo de hoje.
- [ ] Com a migration temporária aplicada, `python scripts/seed_local.py` roda sem erro, e as organizações que já existiam mantêm o status.
- [ ] `ruff`, `pre-commit run mypy --all-files` e `pytest` passam.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/organizacoes tests/domains/documents tests/test_arquitetura.py -q
ruff check . && ruff format --check .
pre-commit run mypy --all-files
pytest

# no banco local, com a migration temporária aplicada
docker compose exec db psql -U creed -d creed -c "\dT+ organization_status"
docker compose exec db psql -U creed -d creed -c "\d organizations"
```

O `pre-commit run mypy` é o que o CI usa: o `mypy` do `.venv` local pode passar onde o do hook falha.

### Decisões já tomadas que valem aqui

- **Nome e endereço da empresa pendente continuam editáveis.** O cadastro público não pede endereço, então a empresa nasce com o endereço "[A informar]", e é pelo `PATCH` que a administradora o corrige. Se a regra mudar, é uma conferência a mais no `OrganizationService.update`.

### Atenção

- O `scripts/convidar_primeiro_admin.py` do creed-backend#53 (já na `dev`) também grava `RecordStatus.ACTIVE` na organização da CREED, perto da linha 159. Troque para `OrganizationStatus.ACTIVE` nesta entrega. Diga isso no PR.

### Depende de

Nada. Branch `feat/691-empresa-pendente`, saída da `dev`.

### Materiais para consumir

| Material | Situação |
|---|---|
| Contrato e corpo da resposta | ✅ colados acima |
| Passos da migration | ✅ colados acima |
| Arquivos de referência | ✅ permalinks acima |

### Rastreio

```
Rastreio: 1dfej6fvrrn/1 — creed-ai-context/tarefas/1dfej6fvrrn-ciclo-da-empresa/1_task.md
```
<!-- fim 1dfej6fvrvn -->

---

### 2 · `1dfej6fvrvp` · CREED - 692 - Cadastro de empresa (E2)

<!-- inicio 1dfej6fvrvp -->
### Em uma frase

Uma empresa se cadastra sozinha, sem login, e fica pendente: uma chamada pública cria o documento e a empresa.

### O que muda para quem usa

Quem quer usar a plataforma numa empresa preenche a tela de cadastro (nome da empresa, documento, e-mail da empresa, o próprio nome e telefone) e espera. Hoje o botão "Avançar" dessa tela não grava nada: os dados ficam só na memória do navegador. Depois desta entrega, o cadastro chega ao banco como empresa **pendente** e aparece para a administradora (a equipe da CREED) aprovar ou rejeitar.

Ninguém ganha acesso no cadastro. O acesso só nasce quando a administradora aprova (subtarefa 693): aí quem cadastrou recebe um e-mail para definir a senha.

A tela de cadastro não pede endereço. A empresa nasce com o endereço "[A informar]", como a organização da própria CREED, e a administradora corrige depois.

No código, empresa é **organização** (`Organization`, tabela `organizations`): a instituição à qual as pessoas se ligam. A própria CREED também é uma organização, onde ficam a equipe da plataforma e os mentorandos.

### Como pretendemos fazer

- Rota pública nova, como o login: sem guarda de papel. Ela fica num **segundo router** do domínio `organizacoes`, com o prefixo em inglês `/organizations`. O projeto decidiu que todo nome novo é em inglês, e o prefixo antigo `/organizacoes` não é renomeado porque o front já o usa. As subtarefas 696 e 693 acrescentam rotas neste mesmo arquivo.
- O documento chega como a pessoa digitou ("12.345.678/0001-90"). O back guarda só letras e números e deduz o tipo: 11 dígitos é CPF, 14 é CNPJ. Qualquer outra forma é recusada.
- Documento e empresa são gravados na mesma transação da requisição: um erro na segunda gravação desfaz a primeira.
- Use a tag `organizacoes` na rota nova. Uma tag nova precisaria de descrição no `app/main.py`, e o `tests/test_openapi.py` falha sem ela.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/organizacoes/schemas.py` | `OrganizationSignUp`: `name`, `document`, `email` (`EmailStr`), `contact_name`, `phone`; validador de `document` que limpa e exige `^\d{11}$\|^\d{14}$` |
| `app/domains/documents/repository.py` | `get_by_type_value(type, value)`; `create(document)`, que devolve `None` quando a constraint `uq_documents_type_value` recusa |
| `app/domains/documents/service.py` | `create_brazilian_document(number) -> Document`: 11 dígitos `DocType.CPF`, 14 `DocType.CNPJ`; já existe → `ConflictError("Já existe um cadastro com este documento")` |
| `app/domains/organizacoes/service.py` | `ADDRESS_TO_BE_INFORMED = "[A informar]"`; `sign_up(request) -> Organization` com `status=PENDING` e e-mail em minúsculas |
| `app/domains/organizacoes/router_organizations.py` (novo) | `APIRouter(prefix="/organizations", tags=["organizacoes"])`; `POST /sign-up`, `status_code=201`, `operation_id="sign_up_organization"`, sem guarda |
| `app/main.py` | registra o router novo (`organizations_router`) |
| `tests/test_arquitetura.py` | o motivo de `organizacoes` passa a dizer que cria e lê documentos pelo `DocumentService` |
| `tests/domains/organizacoes/test_router_organizations.py` (novo), `test_service.py`, `tests/domains/documents/test_service.py` | os casos de "Pronto quando" |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| Segundo router de um domínio | `app/domains/links/router_members.py` | forma do arquivo, da docstring e dos `responses=` |
| `OrganizationRepository.create` | `app/domains/organizacoes/repository.py`, linhas 39 a 55 | o `None` da constraint única virando 409 no service |
| `sem_caractere_de_controle` | `app/shared/validators.py` | validação de texto livre, como nos outros schemas |
| `PasswordResetRequest` | `app/domains/authentication/schemas.py`, na `dev` (veio do creed-backend#52) | schema de rota pública com `EmailStr` |

Permalinks (abrem o arquivo na versão usada nesta especificação):

- [app/domains/links/router_members.py](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/app/domains/links/router_members.py)
- [app/domains/organizacoes/repository.py, linhas 39 a 55](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/app/domains/organizacoes/repository.py#L39-L55)
- [app/shared/validators.py](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/app/shared/validators.py)
- [app/domains/authentication/schemas.py, no creed-backend#52](https://github.com/creed-educa-ai/creed-backend/blob/0af70c14110fae42c99afef2d0840dd4039e3437/app/domains/authentication/schemas.py#L37)

### Contrato

| Método | Rota | Quem | Entrada | Saída |
|---|---|---|---|---|
| POST | `/api/v1/organizations/sign-up` | **público**, sem token | `OrganizationSignUp` | 201 · `OrganizationResponse` com `status: "pending"` |

**Corpo da entrada**

```json
{ "name": "Empresa Teste", "document": "12.345.678/0001-90",
  "email": "gestora@empresa.com.br", "contact_name": "Gestora Teste",
  "phone": "51 99999-0000" }
```

`name`: 1 a 200. `contact_name`: 2 a 200 (🟡 Premissa P-082: o `UserBase.name` do convite exige no mínimo 2). `phone`: 1 a 30. Os três sem caractere de controle e sem espaço nas pontas.

**Erros**

| Código | Quando | Corpo |
|---|---|---|
| 409 | documento já cadastrado (mesmo tipo e número) | `{"detail": "Já existe um cadastro com este documento"}` |
| 422 | campo faltando, vazio, longo demais, e-mail mal formado, documento sem 11 nem 14 dígitos | validação padrão do FastAPI, um item por campo |

### Pronto quando

- [ ] Sem token: 201, `status: "pending"`, `address: "[A informar]"`, contato gravado, e-mail em minúsculas.
- [ ] `"12.345.678/0001-90"` grava documento `cnpj` com valor `12345678000190`; `"123.456.789-09"` grava `cpf` com valor `12345678909`.
- [ ] O mesmo CNPJ de novo, com ou sem pontuação: 409, e nenhuma empresa nova.
- [ ] Documento `"123"`: 422, e nada gravado.
- [ ] Cada campo vazio ou ausente dá 422 com o nome do campo no `detail`.
- [ ] Com token de qualquer papel, a rota se comporta igual.
- [ ] `ruff`, `pre-commit run mypy --all-files`, `pytest` e `tests/test_arquitetura.py` passam.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/organizacoes tests/domains/documents tests/test_openapi.py tests/test_arquitetura.py -q
pre-commit run mypy --all-files

API=http://localhost:8000/api/v1
CORPO='{"name":"Empresa Teste","document":"12.345.678/0001-90","email":"Gestora@Empresa.com.br","contact_name":"Gestora Teste","phone":"51 99999-0000"}'
curl -s -X POST "$API/organizations/sign-up" -H "Content-Type: application/json" -d "$CORPO"
# de novo, sem pontuação: 409
curl -s -o /dev/null -w "%{http_code}\n" -X POST "$API/organizations/sign-up" -H "Content-Type: application/json" -d "${CORPO/12.345.678\/0001-90/12345678000190}"
```

### Decisões já tomadas que valem aqui

- **O cadastro não pede endereço.** A empresa nasce com "[A informar]", e a administradora corrige pelo `PATCH`. A tela de cadastro já está desenhada sem esse campo. Se a cliente quiser o endereço no cadastro, é um campo a mais na tela e no schema.
- **Documento: só letras e números, 11 é CPF, 14 é CNPJ.** A tela pede "Documento (CPF/CNPJ)" sem perguntar o tipo. Guardar só os dígitos faz "12.345.678/0001-90" e "12345678000190" serem o mesmo documento. O dígito verificador não é conferido. Mudar é mexer no validador do schema e no `create_brazilian_document`.
- **O cadastro não confere se o e-mail já tem acesso.** Responder diferente numa rota pública revelaria, sem login, quem tem conta. Quem confere é a aprovação (693), que recusa com 409. Mudar é uma consulta a mais no `sign_up`.

### Depende de

Subtarefa **691** (status pendente e colunas de contato). Branch `feat/692-cadastro-de-empresa`, saída da `feat/691-empresa-pendente` depois do commit dela.

### Materiais para consumir

| Material | Situação |
|---|---|
| Contrato | ✅ colado acima |
| Arquivos de referência | ✅ permalinks acima |

### Rastreio

```
Rastreio: 1dfej6fvrrn/2 — creed-ai-context/tarefas/1dfej6fvrrn-ciclo-da-empresa/2_task.md
```
<!-- fim 1dfej6fvrvp -->

---

### 3 · `1dfej6fvrvw` · CREED - 696 - Excluir empresa (E6)

<!-- inicio 1dfej6fvrvw -->
### Em uma frase

A administradora exclui uma empresa de vez, com todos os membros e tudo o que é deles, e a mesma rota serve para rejeitar um cadastro pendente.

### O que muda para quem usa

Na tabela de empresas, a administradora (a equipe da CREED) tem o botão de excluir. Hoje ele só tira a linha da tela. Depois desta entrega, excluir apaga a empresa de verdade: as pessoas dela, as respostas, os questionários, os setores, o documento e o acesso de cada pessoa. Ninguém da empresa consegue mais entrar. Não dá para desfazer.

**Rejeitar um cadastro pendente é a mesma ação.** Uma empresa pendente ainda não tem ninguém, então excluí-la apaga só a empresa e o documento, e ela pode se cadastrar de novo. Por isso esta subtarefa vem antes da aprovação (693): o botão "rejeitar" do modal de aceite chama esta rota.

Ninguém exclui a organização do próprio vínculo. Para a administradora, essa é a organização da CREED, onde estão os mentorandos e a própria equipe.

Termos: um **vínculo** (`Link`) é a ligação de uma pessoa com uma organização, com um papel (`admin`, `gestor` ou `respondente`). Um **membro** é um vínculo visto junto com a pessoa: nome, e-mail do login e setor. O **Keycloak** é o serviço que guarda as senhas e faz o login.

### Como pretendemos fazer

- A exclusão de **um** membro já existe (CREED-698), e foi escrita pensando nesta tarefa. O `MemberRemovalService.delete_member_data` apaga a parte do banco de um membro e devolve o identificador do login no Keycloak. O `remove_logins_from_keycloak` apaga uma lista de logins no Keycloak.
- A exclusão de empresa chama `delete_member_data` para cada vínculo, depois apaga o que é da organização, e só no fim chama o Keycloak **uma vez** com todos os logins.
- A ordem é a das chaves estrangeiras (quem aponta sai antes de quem é apontado), porque o banco recusa apagar uma linha que outra ainda referencia. Cada tabela é apagada pelo service do domínio dono dela.
- O Keycloak não participa da transação do banco. Ele é chamado **antes do commit**: se falhar, a rota responde 503, o banco desfaz tudo, e repetir resolve, porque login que já não existe no Keycloak conta como apagado. Um log diz quais logins já tinham saído.
- O service fica em `users` (como o da exclusão de membro), porque compõe muitos domínios e `users` já depende deles. Em `organizacoes` haveria import circular. A rota fica no `router_organizations.py` e delega a `users.dependencies`, como `app/domains/links/router_members.py` faz com a exclusão de membro.

**Ordem de `remove_organization(organization_id, *, own_organization_id)`:**

```
1. organization_id == own_organization_id -> ConflictError, antes de qualquer consulta
2. organizations.get(..., role="admin")   -> NotFoundError se não existe
3. para cada vínculo: members.delete_member_data -> junta os keycloak_id não nulos
4. questionários da organização: ids -> respostas desses questionários -> insights
   -> dashboards -> respostas com as marcações -> perguntas e alternativas -> questionários
5. setores da organização
6. guarda o document_id e apaga a organização
7. se nenhum participante aponta para o documento: apaga o documento
8. members.remove_logins_from_keycloak(keycloak_ids), por último
```

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/links/service.py` e `repository.py` | `list_organization_link_ids(organization_id)` |
| `app/domains/forms/service.py` e `repository.py` | `list_organization_form_ids(organization_id)`; `delete_organization_forms(form_ids)`, que chama o `delete_by_ids` que já existe |
| `app/domains/responses/service.py` e `repository.py` | `list_ids_for_forms(form_ids)` |
| `app/domains/department/service.py` e `repository.py` | `delete_for_organization(organization_id)` |
| `app/domains/participants/service.py` e `repository.py` | `document_in_use(document_id) -> bool` |
| `app/domains/documents/service.py` e `repository.py` | `delete_document(document_id)` |
| `app/domains/organizacoes/service.py` e `repository.py` | `delete_organization(organization)` |
| `app/domains/users/service.py` | `OrganizationRemovalService`, logo depois do `MemberRemovalService`, com `remove_organization` na ordem acima |
| `app/domains/users/dependencies.py` | `get_organization_removal_service` e `OrganizationRemovalServiceDep`, sobre o `get_member_removal_service` que já existe |
| `app/domains/organizacoes/router_organizations.py` | `@router.delete("/{organization_id}", status_code=204, operation_id="delete_organization")`, só `admin` |
| `tests/test_arquitetura.py` | os motivos de `users` (exclusão de empresa, donos novos: `organizacoes`, `department`, `documents`) e de `organizacoes` (a rota delega a `users.dependencies`) em `COMPOE_COM_SERVICE_DE` |
| `tests/domains/users/test_organization_removal_service.py` (novo), `tests/domains/organizacoes/test_router_organizations.py`, e um teste por método novo em cada domínio | os casos de "Pronto quando" |

Reaproveite sem mudar: `InsightService.delete_for_form_responses`, `DashboardService.delete_for_member_removal(response_ids, None)`, `FormResponseService.delete_with_answers` e `QuestionService.delete_for_forms` (que já apaga as alternativas antes das perguntas).

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| `MemberRemovalService` (`delete_member_data`, `remove_logins_from_keycloak`) | `app/domains/users/service.py`, linhas 242 a 375 | chamado sem mudar; e é a forma do service novo, um nível acima |
| `get_member_removal_service` | `app/domains/users/dependencies.py`, linhas 40 a 66 | forma da injeção |
| Testes da exclusão de membro | `tests/domains/users/test_member_removal_service.py` | dublês que registram a ordem das chamadas numa lista só |
| `delete_member` | `app/domains/links/router_members.py`, linhas 271 a 320 | a mesma tradução de erros e o mesmo import de `users.dependencies` |
| Testes da rota de exclusão de membro | `tests/domains/links/test_router_members.py` | forma dos testes de rota, com o service trocado por dublê |

Permalinks (abrem o arquivo na versão da `dev` usada nesta especificação):

- [app/domains/users/service.py, linhas 242 a 375](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/app/domains/users/service.py#L242-L375)
- [app/domains/users/dependencies.py, linhas 40 a 66](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/app/domains/users/dependencies.py#L40-L66)
- [tests/domains/users/test_member_removal_service.py](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/tests/domains/users/test_member_removal_service.py)
- [app/domains/links/router_members.py, linhas 271 a 320](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/app/domains/links/router_members.py#L271-L320)
- [tests/domains/links/test_router_members.py](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/tests/domains/links/test_router_members.py)

### Contrato

| Método | Rota | Quem | Entrada | Saída |
|---|---|---|---|---|
| DELETE | `/api/v1/organizations/{organization_id}` | só `admin` | — | 204, sem corpo |

**Erros**

| Código | Quando | Corpo |
|---|---|---|
| 401 | sem token | `{"detail": "Não autenticado"}` |
| 403 | papel `gestor` ou `respondente` | `{"detail": "Cargo insuficiente para acessar"}` |
| 404 | organização não existe | `{"detail": "Organização <id> não encontrada"}` |
| 409 | a organização do próprio vínculo | `{"detail": "Não é possível excluir a própria organização"}` |
| 503 | o Keycloak não respondeu; **nada foi apagado** | `{"detail": "Não foi possível remover o acesso agora. Tente de novo."}` |

### Pronto quando

- [ ] A própria organização: 409, **sem nenhuma chamada** aos outros services.
- [ ] Organização inexistente: 404, sem nenhuma exclusão.
- [ ] Empresa com dois membros: `delete_member_data` uma vez por vínculo, e `remove_logins_from_keycloak` **uma vez só**, por último, com os dois logins. Membro sem login fica fora da lista.
- [ ] A ordem registrada pelos dublês é a dos passos 3 a 8.
- [ ] Empresa pendente: apaga organização e documento, e o mesmo documento pode ser cadastrado de novo (201).
- [ ] Documento usado por um participante: a organização sai, o documento fica.
- [ ] Rota: 204 para `admin`; 403 para `gestor` e `respondente`; 401 sem token; 404, 409 e 503 com a mensagem do service.
- [ ] No banco local, excluir uma empresa com membros e respostas dá 204, `GET /organizacoes/{id}` dá 404 e o membro não consegue mais entrar.
- [ ] `ruff`, `pre-commit run mypy --all-files`, `pytest` e `tests/test_arquitetura.py` passam.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/users tests/domains/organizacoes tests/domains/links tests/domains/forms tests/domains/responses tests/domains/sector tests/domains/participants tests/domains/documents tests/test_openapi.py tests/test_arquitetura.py -q
pre-commit run mypy --all-files

docker compose up -d db keycloak mailpit
API=http://localhost:8000/api/v1
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/organizations/$ORG_CREED" -H "Authorization: Bearer $TOKEN_ADMIN"   # 409
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/organizations/$ORG_COM_MEMBROS" -H "Authorization: Bearer $TOKEN_ADMIN"   # 204
curl -s -o /dev/null -w "%{http_code}\n" "$API/organizacoes/$ORG_COM_MEMBROS" -H "Authorization: Bearer $TOKEN_ADMIN"   # 404
```

`TOKEN_ADMIN` é o do usuário de desenvolvimento do seed (README do back, seção "Autenticação local (Keycloak)"). `ORG_CREED` é a organização dele.

A empresa **com membros** sai de um cadastro novo (subtarefa 692). A exclusão não olha o status. Ponha um membro nela com `POST /participants`, `POST /organizations/{id}/links` e `POST /users`. A organização do seed não serve: é a do admin, e dá 409.

**Para o 503:** faça uma chamada autenticada qualquer **antes** de parar o Keycloak (`docker compose stop keycloak`). A API guarda as chaves do Keycloak em cache por uma hora (`KEYCLOAK_JWKS_CACHE_SECONDS`); com o cache vazio, a própria checagem do token falharia, e o 503 não provaria nada. Depois do 503, a empresa continua no `GET`.

**O que os testes não provam:** que a ordem satisfaz as chaves estrangeiras do Postgres (os testes não falam com o banco; a prova é o passo local), e que uma empresa muito grande cabe no tempo de uma requisição.

### Decisões já tomadas que valem aqui

- **Rejeitar apaga a empresa e o documento, sem e-mail de aviso.** A tarefa diz "rejeitar: a empresa é apagada", sem falar em aviso. O documento sai junto porque, se ficasse, um novo cadastro da mesma empresa daria 409. Avisar por e-mail depois é uma chamada a mais.
- **Só a administradora exclui empresa, e nunca a organização do próprio vínculo (409).** O gestor não exclui a própria empresa (403). Excluir a organização da CREED apagaria os mentorandos e a própria administradora. Abrir para o gestor depois é trocar a guarda da rota.
- **O que sai:** cada membro, como na exclusão de membro (respostas, questionários feitos só para a pessoa, login, vínculo e, se a pessoa não tem vínculo com outra organização, o cadastro dela), mais os questionários da organização, os setores, a organização e o documento, se nenhum participante apontar para ele. É irreversível.
- **Keycloak antes do commit, com log.** É o que a exclusão de membro já faz. Se o Keycloak apagar e a resposta se perder, a pessoa fica no banco sem conseguir entrar até alguém repetir a exclusão. O log diz quem.

### Depende de

Subtarefa **691** (status e documento da organização) e **692** (o `router_organizations.py`). A exclusão de membro (CREED-698) já está na `dev`. Branch `feat/696-excluir-empresa`, saída da `feat/692-cadastro-de-empresa` depois do commit dela. Dois commits: primeiro o service, depois a rota.

### Materiais para consumir

| Material | Situação |
|---|---|
| Contrato | ✅ colado acima |
| Arquivos de referência | ✅ permalinks acima |
| O que está de pé no `docker-compose` local | ✅ colado acima (`db`, `keycloak`, `mailpit`) |

### Rastreio

```
Rastreio: 1dfej6fvrrn/3+4 — creed-ai-context/tarefas/1dfej6fvrrn-ciclo-da-empresa/3_task.md e 4_task.md
```
<!-- fim 1dfej6fvrvw -->

---

### 4 · `1dfej6fvrvt` · CREED - 693 - Aceitar ou rejeitar pedido (E3)

<!-- inicio 1dfej6fvrvt -->
### Em uma frase

Aprovar uma empresa pendente torna ela ativa e manda a quem a cadastrou o e-mail de primeiro acesso como gestor, tudo ou nada.

### O que muda para quem usa

A administradora (a equipe da CREED) abre o cadastro pendente, confere os dados e aceita. Hoje aceitar só troca o rótulo na tela. Depois desta entrega, a empresa vira ativa e a pessoa que fez o cadastro recebe, no e-mail informado, um **convite**: um link para definir a própria senha. Com a senha definida, ela entra na plataforma como **gestora** da empresa e pode convidar as pessoas dela.

Se o e-mail não sair (servidor de e-mail ou Keycloak fora do ar), nada acontece: a empresa continua pendente e a administradora tenta de novo. Não existe empresa aprovada sem convite enviado.

Quem perder o e-mail, ou deixar o link vencer (72 horas), usa **"Esqueci minha senha"** na tela de login, que manda o mesmo tipo de link. Não há botão de reenviar convite.

**Rejeitar não é desta subtarefa:** é a exclusão da 696, que já apaga a empresa pendente.

Termos: **gestor** é o papel de quem administra uma empresa na plataforma; **admin** é o papel da equipe da CREED. O **Keycloak** guarda as senhas e é quem manda o e-mail do convite.

### Como pretendemos fazer

- O convite de membro já faz tudo numa chamada (creed-backend#51, já na `dev`): `MemberService.invite_member_service` cria a pessoa, o vínculo e o acesso, e manda o e-mail. Se algo falha, o banco é desfeito no fim da requisição, e o próprio service desfaz o que criou no Keycloak.
- A aprovação troca o status para ativa e chama esse mesmo convite, com o nome e o e-mail do cadastro, papel `gestor` e vínculo `emprego`. As duas coisas estão na mesma transação: se o convite falha, a troca de status também é desfeita.
- Não se aprova pelo `PATCH` de status: ele passaria a fazer duas coisas, e qualquer outro caminho que mudasse o status pularia o convite. Por isso a 691 faz o `PATCH` recusar a pendente.
- O service fica em `users`, ao lado do `MemberService`, porque `users` já depende de `organizacoes`.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/organizacoes/service.py` | `activate_pending(organization_id) -> Organization`: 404 se não existe; `ConflictError` se não está `PENDING`; senão grava `ACTIVE` |
| `app/domains/users/service.py` | `OrganizationApprovalService(organizations, members: MemberService)`, com `approve(organization_id, *, own_organization_id) -> Organization` |
| `app/domains/users/dependencies.py` | `get_organization_approval_service` e `OrganizationApprovalServiceDep` |
| `app/domains/organizacoes/router_organizations.py` | `@router.post("/{organization_id}/approval", operation_id="approve_organization")`, só `admin`; resposta montada pelo `with_documents` da 691 |
| `tests/test_arquitetura.py` | o motivo de `organizacoes` acrescenta a aprovação |
| `tests/domains/users/test_organization_approval_service.py` (novo), `tests/domains/organizacoes/test_service.py`, `test_router_organizations.py` | os casos de "Pronto quando" |

**Passos de `approve`:**

```
1. organizations.activate_pending(organization_id)
2. email ou contact_name nulo -> ConflictError (caso impossível: só organização criada
   pela administradora não tem, e ela nunca está pendente; existe para o mypy e para
   não virar 500)
3. members.invite_member_service(organization.id,
       MemberInvite(name=contact_name, email=email, role=Roles.GESTOR, type=LinkType.EMPREGO),
       role=Roles.ADMIN.value, own_organization_id=own_organization_id)
4. devolve a organização
```

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| `MemberService.invite_member_service` e `MemberInvite` | `app/domains/users/service.py`, do creed-backend#51 (já na `dev`), linhas 379 a 439 no commit do permalink | chamado sem mudar |
| Testes do convite | `tests/domains/users/test_member_service.py`, do creed-backend#51 (já na `dev`) | dublês de participante, vínculo e acesso |
| `delete_member` | `app/domains/links/router_members.py`, linhas 271 a 320 | tradução de erros em status |

Permalinks (os do #51 apontam para o commit do PR, já mergeado na `dev`):

- [app/domains/users/service.py, no creed-backend#51, linhas 379 a 439](https://github.com/creed-educa-ai/creed-backend/blob/998d872708a69877b18388db1cf93a5acc07701d/app/domains/users/service.py#L379-L439)
- [tests/domains/users/test_member_service.py, no creed-backend#51](https://github.com/creed-educa-ai/creed-backend/blob/998d872708a69877b18388db1cf93a5acc07701d/tests/domains/users/test_member_service.py)
- [app/domains/links/router_members.py, linhas 271 a 320](https://github.com/creed-educa-ai/creed-backend/blob/d5c5177db659bcf43a9b201aea3e835c42c9d3f1/app/domains/links/router_members.py#L271-L320)

### Contrato

| Método | Rota | Quem | Entrada | Saída |
|---|---|---|---|---|
| POST | `/api/v1/organizations/{organization_id}/approval` | só `admin` | sem corpo | 200 · `OrganizationResponse` com `status: "active"` |

**Erros**

| Código | Quando | Corpo |
|---|---|---|
| 401 | sem token | `{"detail": "Não autenticado"}` |
| 403 | papel `gestor` ou `respondente` | `{"detail": "Cargo insuficiente para acessar"}` |
| 404 | organização não existe | `{"detail": "Organização <id> não encontrada"}` |
| 409 | a empresa não está pendente | `{"detail": "A empresa <id> não está pendente"}` |
| 409 | o e-mail do cadastro já tem acesso | `{"detail": "Já existe usuário com o e-mail <e-mail>"}`, ou `Já existe acesso com o e-mail <e-mail>` quando só o Keycloak conhece o e-mail |
| 503 | Keycloak ou envio de e-mail fora do ar; a empresa continua pendente | `{"detail": "Não foi possível criar o acesso agora. Tente de novo."}` |

### Pronto quando

- [ ] Pendente: devolve a organização ativa, e o dublê do `MemberService` recebeu o nome do responsável, o e-mail do cadastro, papel `gestor` e vínculo `emprego`.
- [ ] Já ativa ou inativa: 409, sem chamar o convite. Inexistente: 404, sem chamar o convite.
- [ ] Erro do convite (409 ou 503) sobe sem tratamento, e a rota responde com o mesmo código.
- [ ] Rota: 403 para `gestor` e `respondente`, 401 sem token.
- [ ] No local: o convite chega ao Mailpit, o link define a senha, e a pessoa entra no login da plataforma como gestora da empresa.
- [ ] No local, com o Mailpit parado: 503, e a empresa continua `pending`, sem pessoa, vínculo nem usuário novo.
- [ ] `ruff`, `pre-commit run mypy --all-files`, `pytest` e `tests/test_arquitetura.py` passam.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/users tests/domains/organizacoes tests/test_openapi.py tests/test_arquitetura.py -q
pre-commit run mypy --all-files

docker compose up -d db keycloak mailpit
API=http://localhost:8000/api/v1
# ORG = id devolvido por um cadastro (subtarefa 692)
curl -s -X POST "$API/organizations/$ORG/approval" -H "Authorization: Bearer $TOKEN_ADMIN"
curl -s -o /dev/null -w "%{http_code}\n" -X POST "$API/organizations/$ORG/approval" -H "Authorization: Bearer $TOKEN_ADMIN"   # 409
```

O convite aparece em `http://localhost:8025` (Mailpit, a caixa de e-mail falsa do ambiente local). O login da plataforma é `http://localhost:5173/login`.

**E-mail que já tem acesso:** cadastre outra empresa com o e-mail do admin do seed, `dev@creed.example.com`, e aprove. Dá 409, e ela continua pendente.

**O que os testes não provam:** que a troca de status é desfeita quando o convite falha. Os testes de service não têm transação. A prova é o passo com o Mailpit parado.

### Decisões já tomadas que valem aqui

- **O convite vai ao e-mail do cadastro, em nome de quem cadastrou, como gestor.** O modal mostra "e-mail da empresa" e "nome de quem está cadastrando", e o mais provável é que quem cadastrou administre a empresa. Se o e-mail for de uma caixa compartilhada (contato@), o acesso de gestor fica com quem lê essa caixa.
- **O vínculo nasce do tipo emprego.** O cadastro não pergunta o tipo, e numa empresa é o caso mais provável.
- **E-mail que já tem acesso: 409, e a empresa continua pendente.** Uma pessoa tem um acesso só na plataforma, então não administra duas empresas com o mesmo e-mail. A administradora rejeita o cadastro.
- **Só a administradora aprova.**
- **O link vale 72 horas.** Depois disso, o caminho é "Esqueci minha senha".

### Depende de

- Subtarefas **691** e **696** (o `router_organizations.py` com a exclusão, que é a rejeição).
- **creed-backend#51**, já na `dev`: é onde está o `MemberService`.

Branch `feat/693-aprovar-empresa`, saída da `feat/696-excluir-empresa`.

Fora do board: em produção, aprovar dá 503 até o e-mail da EC2 existir (creed-infrastructure#10).

### Materiais para consumir

| Material | Situação |
|---|---|
| Contrato | ✅ colado acima |
| Arquivos de referência | ✅ permalinks acima (os do #51 apontam para o commit do PR, já mergeado na `dev`) |
| O que está de pé no `docker-compose` local | ✅ colado acima (Mailpit em `localhost:8025`) |

### Rastreio

```
Rastreio: 1dfej6fvrrn/5 — creed-ai-context/tarefas/1dfej6fvrrn-ciclo-da-empresa/5_task.md
```
<!-- fim 1dfej6fvrvt -->

---

### 5 · `1dfej6fvrvu` · CREED - 694 - Integração (E4-E5)

Título proposto: `CREED - 694 - Cadastro e tabela de empresas ligados ao back (E4-E5)`.

<!-- inicio 1dfej6fvrvu -->
### Em uma frase

A tela de cadastro e a tabela de empresas da administradora passam a usar o back de verdade, sem nenhum dado de mentira.

### O que muda para quem usa

**Quem cadastra a empresa:** o cadastro passa a gravar de verdade. Se o documento já tem cadastro, o aviso aparece no próprio campo. Na tela de "aguarde confirmação", o texto passa a dizer o que acontece: quando a empresa for aprovada, chega no e-mail informado um link para definir a senha, e, se o e-mail não chegar, o caminho é "Esqueci minha senha" na tela de login. Hoje a tela diz "tente realizar o login novamente", o que não funciona, porque a pessoa ainda não tem senha.

**A administradora** (a equipe da CREED, no painel de controle dela): a tabela de empresas mostra as empresas reais. A pendente tem o botão "Pendente", que abre o modal com os dados do cadastro. Aceitar manda o convite de gestor; rejeitar apaga o cadastro; excluir apaga uma empresa ativa com tudo o que é dela, e a confirmação diz que não dá para desfazer. A organização da própria CREED não aparece na tabela.

"Ver resultados" não muda: o painel de resultados de uma empresa para a administradora ainda não tem rota no back.

No back, empresa é **organização** (`OrganizationResponse`): a instituição à qual as pessoas se ligam. A própria CREED também é uma organização, onde ficam a equipe da plataforma e os mentorandos, e é a organização da sessão da administradora. Por isso ela sai da tabela.

### Como pretendemos fazer

Dois commits na mesma branch.

**Commit 1, o cadastro.** A rota de cadastro é pública e cria a empresa pendente. O formulário passa a barrar antes o que o back recusaria: e-mail mal formado e documento que não tem 11 nem 14 dígitos. Assim, o único erro que o back devolve e que tem lugar certo na tela é o 409 do documento repetido. O resto vira um aviso abaixo do botão.

**Commit 2, a tabela.** Os tipos de mentira da tela (`Company`, `CompanyRegistration`, `CompanyStatus`, com `nomeEmpresa`, `documento`…) saem, e a tela passa a ler o tipo que o back devolve (`OrganizationResponse`). A lista vem inteira: o slice pede páginas de 200 até somar o total, porque a tabela pagina e ordena na própria tela. Rejeitar e excluir usam a mesma rota. As rotas antigas de leitura e edição continuam em `/organizacoes`; as novas (cadastro, aprovação, exclusão) são em `/organizations`.

O 409 da aprovação tem duas causas (outra pessoa já aprovou, ou o e-mail já tem acesso), e o front não tem como separar uma da outra. O aviso diz as duas e recarrega a lista.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `src/types/api.ts` | commit 1: `OrganizationStatus`, `OrganizationDocument`, `OrganizationSignUp`, e os campos novos de `OrganizationResponse`. Commit 2: saem `Company`, `CompanyRegistration`, `CompanyStatus` |
| `src/features/organizations/organizationsApi.ts` | commit 1: `signUp(body)`, sai o mock `registerCompany` e o `SIGN_UP_DELAY_MS`. Commit 2: sai todo o mock de empresas; nascem `approveOrganization(id)` e `deleteOrganization(id)` |
| `src/features/organizations/organizationsSlice.ts` | commit 1: `signUpOrganization` no lugar do `registerCompany`. Commit 2: estado `organizations: OrganizationResponse[]`, `loadOrganizations` (página a página), `approveOrganization`, `deleteOrganization` |
| `src/lib/validators.ts` | `signUpSchema`: e-mail com `z.email`, documento com 11 ou 14 dígitos depois de limpar, tamanhos máximos 200, 200 e 30, e nome completo com no mínimo 2 (P-082) |
| `src/features/organizations/SignUpView.tsx` | corpo com os nomes do back; 409 no campo "Documento"; outros erros num `<p role="alert">` abaixo do botão |
| `src/features/organizations/AwaitingConfirmationView.tsx` | só o texto, via i18n |
| `src/features/organizations/CompaniesSection.tsx` | filtro da organização da sessão (`state.authentication.user?.organization_id`); toasts de aprovar, rejeitar e excluir |
| `src/features/organizations/CompanyTable.tsx` | lê `OrganizationResponse`; "Pendente" (botão), "Ativo" (`StatusPill tone="success"`), "Inativo" (`StatusPill tone="destructive"`, como a `MenteesTable`, `src/features/users/MenteesTable.tsx:62`) |
| `src/components/modals/CompanyApprovalModal.tsx` | mostra `name`, `document.value`, `email`, `contact_name`, `phone`, com "—" no vazio |
| `src/i18n/locales/pt-BR.ts`, `en.ts`, `es.ts` | `cadastro.erros.{documentoInvalido, documentoJaCadastrado, envioIndisponivel}`, `aguardeConfirmacao.mensagem`, `empresas.status.inativo`, `empresas.toasts.naoAprovadaDescricao`, `empresas.toasts.erroExcluir`, `empresas.confirmarExclusao.descricao` |
| testes da feature | `SignUpView.test.tsx`, `AwaitingConfirmationView.test.tsx`, `organizationsApi.test.ts`, `CompaniesSection.test.tsx`, `CompanyTable.test.tsx` e um `organizationsSlice.test.ts` novo |

**Textos novos em pt-BR**

- `aguardeConfirmacao.mensagem`: "Recebemos o cadastro da sua empresa. Quando ele for aprovado, você vai receber no e-mail informado um link para definir sua senha. Se o e-mail não chegar, use "Esqueci minha senha" na tela de login."
- `empresas.toasts.naoAprovadaDescricao`: "Ela pode já ter sido aprovada, ou o e-mail informado já tem acesso à plataforma. Se for o e-mail, rejeite o cadastro."
- `empresas.confirmarExclusao.descricao`: "Excluir {{nome}} apaga a empresa, todos os membros dela, as respostas e os questionários. Não dá para desfazer."

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| `requestPasswordReset` e `chaveDeErroDoReset` | `src/features/authentication/authenticationSlice.ts`, linhas 72 a 95 | thunk que devolve uma chave de i18n a partir do `ApiError.status` |
| `PasswordResetView` | `src/features/authentication/PasswordResetView.tsx` | erro do campo × aviso do envio |
| `stubFetch` e `lastCall` | `src/test/stubFetch.ts` | o teste passa pelo `apiClient` de verdade e confere URL, método e corpo |
| Testes atuais da API | `src/features/organizations/organizationsApi.test.ts` | formato das URLs esperadas (`/api/v1/...`) |
| `StatusPill` | `src/components/table/tablePills.tsx`, linha 13 | sem `tone`, o selo fica com texto branco e sem fundo, invisível no tema claro; o precedente de "Inativo" é `tone="destructive"`, na `MenteesTable` (`src/features/users/MenteesTable.tsx:62`) |
| `apiClient` | `src/lib/apiClient.ts` | o `post` exige corpo: na aprovação, passe `undefined`. O `delete` não tem genérico (204 sem corpo) |

Permalinks (abrem o arquivo na versão da `dev` do front usada nesta especificação):

- [src/features/authentication/authenticationSlice.ts, linhas 72 a 95](https://github.com/creed-educa-ai/creed-frontend/blob/68d8fb894f0afb7e360514b6462e8d026623645d/src/features/authentication/authenticationSlice.ts#L72-L95)
- [src/features/authentication/PasswordResetView.tsx](https://github.com/creed-educa-ai/creed-frontend/blob/68d8fb894f0afb7e360514b6462e8d026623645d/src/features/authentication/PasswordResetView.tsx)
- [src/test/stubFetch.ts](https://github.com/creed-educa-ai/creed-frontend/blob/68d8fb894f0afb7e360514b6462e8d026623645d/src/test/stubFetch.ts)
- [src/features/organizations/organizationsApi.test.ts](https://github.com/creed-educa-ai/creed-frontend/blob/68d8fb894f0afb7e360514b6462e8d026623645d/src/features/organizations/organizationsApi.test.ts)
- [src/components/table/tablePills.tsx, linha 13](https://github.com/creed-educa-ai/creed-frontend/blob/68d8fb894f0afb7e360514b6462e8d026623645d/src/components/table/tablePills.tsx#L13)

### Contrato (visto do front)

| Chamada | Rota | Sucesso | Erros que a tela trata |
|---|---|---|---|
| cadastrar | `POST /organizations/sign-up`, sem token, `{name, document, email, contact_name, phone}` | 201 · `OrganizationResponse` → vai para `/awaiting-confirmation` | 409 no campo "Documento"; 422, 503 e rede no aviso abaixo do botão |
| listar | `GET /organizacoes?pagina=N&tamanho_pagina=200` | `{itens, total, pagina, tamanho_pagina}` | qualquer erro: o estado de erro da seção |
| aprovar | `POST /organizations/{id}/approval`, sem corpo | 200 · `OrganizationResponse` ativa → troca a linha | 409: aviso de "não aprovada" e lista recarregada; 503: "tente de novo" |
| rejeitar e excluir | `DELETE /organizations/{id}` | 204 → tira a linha | 409 (a própria organização) e 503: aviso, e a linha fica |

`OrganizationResponse`: `id`, `name`, `address`, `document_id`, `document: {type, value}`, `status` (`pending`, `active`, `inactive`), `email`, `contact_name`, `phone` (os três podem vir `null`), `created_at`, `updated_at`.

A imagem de referência do modal de aceite está na [CREED-595](https://app.clickup.com/t/1dfej6ftzq6). O modal já existe no front; muda só de onde vêm os dados.

### Pronto quando

- [ ] O cadastro sai como `POST /api/v1/organizations/sign-up` com `{name, document, email, contact_name, phone}` (o teste lê o corpo).
- [ ] Cadastro com 201 vai para `/awaiting-confirmation`; com 409, a mensagem aparece no campo "Documento"; com 503, aviso abaixo do botão e o formulário continua preenchido.
- [ ] Documento `"123"` e e-mail `"abc"` são barrados pelo formulário, **sem chamada** ao back.
- [ ] "Aguarde confirmação" cita o e-mail e o "Esqueci minha senha", nos três idiomas.
- [ ] Nenhum `Company`, `CompanyRegistration`, `CompanyStatus` ou mock de empresa sobra em `src/`.
- [ ] Com `total: 250`, o slice faz duas chamadas (`pagina=1` e `pagina=2`) e guarda as 250.
- [ ] A organização da sessão não aparece na tabela; as outras aparecem como "Pendente", "Ativo" ou "Inativo".
- [ ] Aceitar troca a linha para "Ativo" com toast de sucesso; o 409 mostra o aviso de "não aprovada" e recarrega a lista; o 503 pede para tentar de novo.
- [ ] Rejeitar e excluir chamam `DELETE /organizations/{id}` e tiram a linha; no 503 a linha fica.
- [ ] A confirmação de exclusão diz que não dá para desfazer, nos três idiomas.
- [ ] `npm run check` passa.

### Como verificar

```bash
cd creed-frontend
npx vitest run src/features/organizations src/components/modals
npm run check
npm run dev
```

No navegador, com o back das subtarefas 691, 692, 696 e 693 de pé e o Mailpit (`http://localhost:8025`):

1. `http://localhost:5173/sign-up` com um e-mail novo leva a `/awaiting-confirmation`.
2. Entre como admin, abra `/control-panel/admin`, clique em "Pendente" e aceite.
3. Abra o convite no Mailpit, defina a senha e entre como gestora.
4. **"Esqueci minha senha"**: em `/login`, clique no link, peça com o e-mail da gestora, confira o segundo e-mail no Mailpit e defina uma senha nova.
5. Cadastre outra empresa e rejeite. Exclua a primeira e confira que a gestora não entra mais.
6. Repita a tabela e o modal com a janela em 375 px de largura.

**O que os testes não provam:** o passo 4, que depende de um PR de outra tarefa. E o caso da sessão sem organização (login desligado): aí nada é filtrado e a organização da CREED aparece, mas o back continua recusando excluí-la (409).

### Decisões já tomadas que valem aqui

- **Documento: 11 dígitos é CPF, 14 é CNPJ**, contando só letras e números. É a mesma regra do back; se ela mudar lá, muda no `signUpSchema` também.
- **O cadastro aceita um e-mail que já tem acesso.** Quem recusa é a aprovação, com 409. Responder diferente no cadastro revelaria quem tem conta.
- **Rejeitar é excluir.** A empresa pendente é apagada, sem e-mail de aviso, e pode se cadastrar de novo.
- **A tabela não mostra a organização da sessão** (a da CREED): ela não é empresa cliente, não passa por aprovação e não pode ser excluída. A empresa inativa aparece como "Inativo". Mudar é um filtro e um rótulo nesta tela.
- **Aceitar manda o convite de gestor** ao e-mail do cadastro, em nome de quem cadastrou.

### Depende de

- Para o código e os testes: nada. Eles andam contra o contrato acima, com o `stubFetch`.
- Para o teste no navegador: subtarefas **692** (commit 1) e **691, 696, 693** (commit 2) na `dev` do back.
- Para o passo 4: o creed-backend#52 já está na `dev` (a rota de "esqueci minha senha"; a tela já está na `dev` do front).

Branch `feat/694-integracao-empresas`, saída da `dev` do front.

### Materiais para consumir

| Material | Situação |
|---|---|
| Contrato visto do front | ✅ colado acima |
| Imagem do modal de aceite | ✅ link para a CREED-595 acima |
| Arquivos de referência | ✅ permalinks acima |
| Textos novos em pt-BR | ✅ colados acima |

### Rastreio

```
Rastreio: 1dfej6fvrrn/6+7 — creed-ai-context/tarefas/1dfej6fvrrn-ciclo-da-empresa/6_task.md e 7_task.md
```
<!-- fim 1dfej6fvrvu -->
