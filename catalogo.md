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
| `users` | **molde** — domínio-exemplo completo (tabela `user`, CREED-23). Com a CREED-23.8, cria o acesso nos dois lados (banco e Keycloak) e manda o convite; convite de membro num segundo router (`router_members.py`, `POST /organizations/{organization_id}/members`), reenvio e remoção |
| `authentication` | login, renovação, sessão e "esqueci minha senha" via Keycloak; sem tabela própria |
| `organizacoes` | tabela `organizations`; criar, listar, ler e editar organização (`/organizacoes`). O nome do domínio segue em português (ADR-0005, item 4) |
| `participants` | tabela `participants`; criar e ler participante |
| `links` | tabela `links` (o vínculo); criar vínculo em `/organizations/{organization_id}/links` |
| `department` | tabela `departments` (o setor); criar e ler |
| `forms` | tabela `form`; criar e ler formulário |
| `questions` | tabelas `questions` e `question_options`; criar pergunta, listar por formulário, criar alternativa (`router_options.py`) |
| `responses` | tabelas `form_responses` e `answer`; rotas de abrir e finalizar resposta |
| `documents`, `demographics`, `insights` | só tabela, sem rota |
| `prismas`, `prognosticos`, `relatorios` | scaffold: router sem rota, sem tabela |
| `dashboards` | tabela `dashboards`, router sem rota |

Situação conferida em 2026-10-29 contra o OpenAPI do back, com os PRs da CREED-23.8 (#49 a
#53) ainda fora da `dev`. Parte das tabelas existe só em `models.py`, sem migration, até a
consolidação (CREED-57, ADR-0009).

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
| `authentication` | **molde** — login e sessão, ligada ao backend; "esqueci minha senha" (`/reset-password`) só pede o e-mail. Não há tela de definir senha: quem define é a página do Keycloak (CREED-23.8) |
| `organizations` | painel da empresa: lista de membros ainda em memória; o `AddMemberForm` pede nome, e-mail e papel, e o `organizationsApi.inviteMember` chama o convite de membro do backend (creed-frontend#52, ainda fora da `dev`). A página que liga o formulário é da CREED-50 |
| `mentees`, `organizations-admin`, `painel-de-controle`, `superadm` | telas do painel de controle (mentorandos, empresas, questionário, super adm), sem chamada ao backend |
| `responses` | questionário: onboarding, perguntas, revisão e tela de enviado. Espelha o domínio `responses`; ainda com perguntas de exemplo, sem chamada ao backend |
| `respondentes` | dados demográficos (3 etapas). Só no front: o domínio do backend foi removido. A tela `RespondentesView` saiu das rotas, mas o `respondentesApi.ts` ainda chama `/api/v1/respondentes`, que responde 404 |
| `cadastro`, `aguarde-confirmacao` | solicitação de cadastro **da empresa**, que a cliente aprova (não é autocadastro de pessoa, ver P-008). O backend ainda não tem esse fluxo, por isso não há chamada |
| `boas-vindas`, `sobre` | páginas públicas; não espelham domínio e não chamam o backend |
| `dashboards`, `prognosticos`, `relatorios` | só `README.md`, sem código |

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
