# Infraestrutura

Responsabilidade dos **1–2 donos de infra**. O restante do time interage com o
pipeline, não com o cluster.

| Componente | Onde roda | Observação |
|---|---|---|
| Front-end | Pod (Nginx) | estáticos |
| Back-end | Pod (Uvicorn) | — |
| PostgreSQL | **RDS gerenciado** | nunca banco stateful em pod |
| N8N | Pod stateful + PVC | self-hosted por orçamento (ADR-001 §2.1) |
| Migrations | **Job dedicado** | `migration-job.yaml`, nunca no startup |

## O que a IA pode e não pode fazer aqui

**Pode:** ler manifests e explicar, propor mudança em `migration-job.yaml`, revisar
workflow de CI, escrever Dockerfile.

**Não pode, nem com pedido explícito:** executar `kubectl`, `helm`, `aws` ou
`terraform` contra ambiente real; mexer em secret; alterar ruleset do GitHub. Mudança
de infra é PR revisado por dono de infra — não é ação de agente.

## CI

| Workflow | O que faz |
|---|---|
| `ci.yml` | check `qualidade` — 🔒 obrigatório para mergear |
| `nome-da-branch.yml` | check `nome-da-branch` — 🔒 obrigatório |
| `espelhar-gitlab.yml` | espelha para o GitLab da AGES (arquivo, mão única) |

GitHub é a origem. O GitLab da AGES é **espelho de arquivo** — ninguém revisa nem
abre MR lá.
