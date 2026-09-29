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

| Domínio | Situação |
|---|---|
| `users` | **molde** — domínio-exemplo completo (tabela `user`, CREED-23) |
| `authentication` | login, renovação e sessão via Keycloak; sem tabela própria |
| `responses` | tabelas `form_responses` e `answer`; rotas de abrir e finalizar resposta |
| `organizacoes`, `prismas`, `prognosticos`, `relatorios`, `dashboards` | scaffold: pasta criada, nenhuma rota |

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

| Feature | Situação |
|---|---|
| `authentication` | **molde** — login e sessão, ligada ao backend |
| `responses` | questionário: onboarding, perguntas, revisão e tela de enviado. Espelha o domínio `responses`; ainda com perguntas de exemplo, sem chamada ao backend |
| `respondentes` | dados demográficos (3 etapas). Só no front: o domínio do backend foi removido. A tela `RespondentesView` saiu das rotas, mas o `respondentesApi.ts` ainda chama `/api/v1/respondentes`, que responde 404 |
| `cadastro`, `aguarde-confirmacao` | solicitação de cadastro **da empresa**, que a cliente aprova (não é autocadastro de pessoa, ver P-008). O backend ainda não tem esse fluxo, por isso não há chamada |
| `boas-vindas`, `sobre` | páginas públicas; não espelham domínio e não chamam o backend |
| `dashboards`, `prognosticos`, `relatorios` | só `README.md`, sem código |

Transversal: `src/app/` (store, routes, hooks) · `src/components/ui/` ·
`src/hooks/` · `src/lib/` · `src/i18n/` · `src/types/` · `src/test/`.

## creed-infrastructure

Notas de deploy. Componentes: front (**Amplify**, build estático) · back, N8N e
Keycloak (três containers numa **EC2 única**, pelo mesmo `docker-compose` do ambiente
local) · PostgreSQL **no RDS**, fora da instância, um schema por componente.

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
