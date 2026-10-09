# Infraestrutura

Responsabilidade dos **1–2 donos de infra**. O restante do time interage com o
pipeline, não com a instância.

Desenho vigente: [`ADR-0007`](../decisoes/adrs/0007-amplify-e-ec2-no-lugar-do-eks.md).

| Componente | Onde roda | Observação |
|---|---|---|
| Front-end | **Amplify** | build estático; CDN e TLS gerenciados |
| Entrada (HTTPS) | Container na EC2 (Caddy) | certificado Let's Encrypt; `/auth/admin` fechado para a internet |
| Back-end | Container na EC2 (Uvicorn) | compose de produção em `creed-infrastructure/ec2/` — mesmos containers do local, arquivo próprio (ADR-0007, nota de implementação) |
| Keycloak | Container na EC2 | schema `keycloak` no RDS |
| N8N | Container na EC2 + volume | self-hosted por orçamento (ADR-001 §2.1); **único estado fora do RDS** |
| PostgreSQL | **RDS gerenciado** | fora da instância — nunca banco no disco da EC2 |
| Migrations | **Passo do pipeline** | container descartável, nunca no startup |

## O que a IA pode e não pode fazer aqui

**Pode:** ler manifests e explicar, propor mudança no `docker-compose` e no passo de
migration do pipeline, revisar workflow de CI, escrever Dockerfile.

**Não pode, nem com pedido explícito:** abrir `ssh` na EC2, nem executar `aws`,
`kubectl`, `helm` ou `terraform` contra ambiente real; mexer em secret; alterar ruleset
do GitHub. Mudança de infra é PR revisado por dono de infra — não é ação de agente.

## CI

| Workflow | O que faz |
|---|---|
| `ci.yml` | check `qualidade` — 🔒 obrigatório para mergear |
| `nome-da-branch.yml` | check `nome-da-branch` — 🔒 obrigatório |
| `espelhar-gitlab.yml` | espelha para o GitLab da AGES (arquivo, mão única) |

GitHub é a origem. O GitLab da AGES é **espelho de arquivo** — ninguém revisa nem
abre MR lá.
