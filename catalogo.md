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
| `respondentes` | **molde** — domínio-exemplo completo |
| `organizacoes` | — |
| `prismas` | — |
| `prognosticos` | — |
| `relatorios` | — |
| `dashboards` | — |

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
| `respondentes` | **molde** — feature-exemplo |
| `dashboards`, `prognosticos`, `relatorios` | — |

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
