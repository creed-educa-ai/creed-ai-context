# Catálogo — repositórios, domínios e features

Origem: `github.com/creed-educa-ai/creed-*`. GitLab da AGES é **espelho de arquivo**
(workflow `espelhar-gitlab.yml`), não caminho de review.

## creed-backend

FastAPI. Organização **por domínio** (ADR-002 §2.1). Cada `app/domains/<nome>/`:

| Arquivo | Responsabilidade | Não faz |
|---|---|---|
| `router.py` | HTTP: recebe, valida, delega | regra de negócio |
| `service.py` | regra de negócio | não conhece HTTP nem ORM |
| `repository.py` | queries e agregações | regra de negócio |
| `schemas.py` | Pydantic, separado por direção | — |
| `models.py` | tabelas SQLAlchemy | — |
| `dependencies.py` | injeção (sessão, service) | — |

| Domínio | Rotas (`/api/v1`) | Situação |
|---|---|---|
| `users` | `POST /users`, `DELETE /users/{id}` | **molde** — domínio-exemplo completo (tabela `user`, CREED-23). Convite de membro e reenvio estão em branches abertas |
| `authentication` | `POST /authentication/login`, `POST /authentication/renew`, `GET /authentication/session` | via Keycloak; sem tabela própria. `password-reset` está em branch aberta |
| `links` | `POST /organizations/{id}/links`, `PATCH /organizations/{id}/members/{link_id}` (troca de setor, CREED-6910) | tabela `links`. As rotas de membros ficam num segundo router (`router_members.py`) e leem o membro por JOIN (adendo ao ADR-0004) |
| `participants` | `POST /participants`, `GET /participants/{id}` | tabela `participants` |
| `organizacoes` | `POST`, `GET` (paginado), `GET /{id}`, `PATCH /{id}` em `/organizacoes`; `POST /organizations/sign-up` (público, sem token); `DELETE /organizations/{id}` (só admin; exclui a empresa e também rejeita uma pendente); `POST /organizations/{id}/approval` (só admin; ativa a pendente e convida quem a cadastrou como gestor) | tabela `organizations`, com status próprio (`OrganizationStatus`: `pending`, `active`, `inactive`; tipo `organization_status`, separado do `recordstatus` de `user` e `participants`) e os dados de contato do cadastro (`email`, `contact_name`, `phone`, anuláveis). Toda leitura devolve também `document: {type, value}`, lido pelo `DocumentService` numa consulta por página. O `PATCH` só aceita `active`/`inactive` e recusa `status` numa pendente (409). Pasta e rota em português. As rotas novas usam o prefixo em inglês `/organizations` (ADR-0005) e ficam num segundo router, `router_organizations.py`. O cadastro público cria o documento pelo `DocumentService`, guardado só com os dígitos (11 = CPF, 14 = CNPJ), e a organização `pending` com o endereço "[A informar]". Documento repetido dá 409. A exclusão (`DELETE /organizations/{id}`) delega ao `OrganizationRemovalService` de `users`, por `users.dependencies`, como `links/router_members.py` faz com a de membro. Ela apaga cada membro como a M-3, os questionários da organização, os setores, a organização, o documento (se nenhum participante usar) e, por último, os logins no Keycloak. A própria organização dá 409, e o Keycloak fora do ar dá 503 sem nada apagado (P-073, P-078, P-079, P-080). A aprovação (`POST /organizations/{id}/approval`) também delega a `users`, ao `OrganizationApprovalService`: troca `pending` por `active` e chama o convite de membro (`MemberService`) com o `contact_name` e o `email` do cadastro, papel `gestor` e vínculo `emprego`, na mesma transação. Empresa que não está pendente e e-mail que já tem acesso dão 409, e o convite que falha dá 503, com a empresa ainda pendente (P-053, P-077, P-079) |
| `department` | `POST /department`, `GET /department/{id}` | tabela `departments`. Pasta e rota no singular |
| `forms` | `POST /forms`, `GET /forms/{id}` | tabela `form` |
| `questions` | `POST /questions`, `GET /forms/{id}/questions`, `POST /questions/{id}/options` | tabelas `questions` e `question_options` |
| `responses` | `POST /form-responses`, `PATCH /form-responses/{id}`, `POST` e `GET /form-responses/{id}/answers` | tabelas `form_responses` e `answer` |
| `demographics`, `documents`, `insights` | — | tabela e schema (documents: só tabela), **sem rota** |
| `dashboards` | — | tabela e schema; router stub |
| `prismas`, `prognosticos`, `relatorios` | — | stub: router sem rota |

`respondentes` foi removido em 2026-09-21: era scaffold do commit inicial e nunca teve
tabela.

Transversal: `app/core/` (config, database) · `app/shared/` (exceptions) ·
`alembic/` (migrations) · `tests/`.

## creed-frontend

React + TS + Vite. Organização **por feature**, espelhando os domínios:

```
src/features/<feature>/
├── <Feature>View.tsx
├── <feature>Slice.ts
├── <feature>Api.ts
└── <feature>Slice.test.ts
```

Cada domínio do back com rota tem uma feature de mesmo nome com o `<feature>Api.ts`
transcrito do router. Duas exceções de nome, porque o back está fora da própria
convenção: `organizations` (back: `organizacoes`) e `departments` (back: `department`).
A rota é transcrita como o back a expõe.

| Feature | Domínio do back | Situação |
|---|---|---|
| `authentication` | `authentication` | **molde** — login, sessão e "esqueci a senha", ligada ao backend |
| `responses` | `responses` (+ `forms`, `questions`) | questionário: onboarding, perguntas, revisão e enviado. Ligado ao backend; as objetivas ainda são de demonstração (P-039) |
| `forms`, `questions` | `forms`, `questions` | só `Api.ts` (consumido pelo questionário) e, em `forms`, o período do questionário do painel da empresa |
| `users` | `users` | membros (painel da empresa) e mentorandos (painel do super adm). Listas em **mock no `usersApi.ts`**; convite já transcrito |
| `organizations` | `organizacoes` | empresas do super adm, cadastro público e "aguarde confirmação". Ligado ao backend: lista, aprovação e exclusão (que também rejeita) das empresas, e o cadastro público. Usa os dois prefixos do domínio (`/organizacoes` e `/organizations`) |
| `participants`, `links`, `departments` | idem | só `Api.ts`, ainda sem tela |
| `demographics` | `demographics` | as 3 etapas de dados demográficos; campos com os nomes do `DemographicCreate`. Sem `Api.ts`: o back não tem rota |
| `dashboards` | `dashboards` | dashboards individual e da empresa. Dados em **mock no `dashboardsApi.ts`** |
| `controlPanel` | — | páginas de composição (painel da empresa e do super adm): juntam seções de outras features |
| `welcome`, `about` | — | páginas públicas; não espelham domínio e não chamam o backend |
| `prognosticos`, `relatorios` | idem | só `README.md`: o back é stub |

**Mock no `<feature>Api.ts`**: onde o back ainda não tem a rota, o dado fictício mora na
camada de integração, com a forma que a tela usa. Integrar é trocar o corpo da função
por `apiClient`; slice e View não mudam. Onde a forma da tela diverge do back, a lista
está em [`conventions/contrato-front-back.md`](conventions/contrato-front-back.md).

Transversal: `src/app/` (store, routes, hooks) · `src/components/ui/` ·
`src/hooks/` · `src/lib/` · `src/i18n/` · `src/types/` · `src/test/`.

## creed-infrastructure

Compose de produção da EC2 (`ec2/`: Caddy na frente, Keycloak atrás) e notas de
deploy. Componentes: front (**Amplify**, build estático) · back, N8N e Keycloak (três
containers numa **EC2 única** — os mesmos do ambiente local, num compose de produção
próprio) · PostgreSQL **no RDS**, fora da instância, um schema por componente.

`migration-job.yaml` continua versionado como referência de um desenho **aposentado**
([ADR-0007](decisoes/adrs/0007-amplify-e-ec2-no-lugar-do-eks.md)) — nada o consome.
Migration hoje é passo do pipeline.

## Comandos de qualidade

| Repo | Comando | Cobre |
|---|---|---|
| backend | `ruff check . && ruff format --check .` | lint + formatação |
| backend | `mypy app` | tipos |
| backend | `pytest` | testes |
| frontend | `npm run check` | lint + format + typecheck + testes, na ordem do CI |

Check de CI obrigatório: `qualidade`. Check de nome de branch: `nome-da-branch`.
