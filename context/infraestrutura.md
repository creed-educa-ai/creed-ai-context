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

## Onde ficam os segredos

Decidido em 2026-10-13 ([CREED-282](https://app.clickup.com/t/86e3na5q1)). **Nenhum
segredo vai para o git** — nem em `.env` versionado, nem em arquivo de realm.

| O quê | Onde | Por quê |
|---|---|---|
| Segredos e configuração da produção | **SSM Parameter Store**, região `us-east-2`, em `/creed/prod/<VARIÁVEL>` | gratuito no tier Standard; acesso controlado por usuário da AWS |
| Senha do usuário master do RDS | **Secrets Manager** (RDS → Segurança e conexão → *Visualizar no Secrets Manager*) | a AWS gira a senha a cada 7 dias: cópia em outro lugar vence. Nenhuma aplicação usa o master |
| Valores que os containers leem | `/opt/creed/.env` na EC2 (`chmod 600`) | é o que o compose de produção lê; o Parameter Store é a cópia de segurança e a referência |
| Usuário de admin do console do Keycloak | com cada pessoa | um usuário por pessoa no realm `master`, nunca compartilhado |
| Conta do Gmail do projeto e a **senha de app** do SMTP (`SMTP_USER`, `SMTP_FROM`, `SMTP_PASSWORD`) | com o **dono da conta** (Enzo, CREED-28) e só no `/opt/creed/.env` da EC2 — **exceção**: não vão para o Parameter Store | adendo de 2026-10-27 do [ADR-0006](../decisoes/adrs/0006-e-mail-transacional.md): a conta é uma pessoa, não um recurso da AWS. Passagem para a turma seguinte: abaixo |

Regras do Parameter Store:

- **O nome do parâmetro é o nome da variável** do `.env`: `/creed/prod/POSTGRES_PASSWORD`
  vira `POSTGRES_PASSWORD`. Sem tabela de tradução.
- **Segredo é `SecureString`** (chave `alias/aws/ssm`); configuração que não é segredo
  (host, porta, IP) é `String`.
- **Tier Standard.** O Advanced é cobrado.
- Mudou um valor no `.env` da EC2? Mude no Parameter Store no mesmo momento — os dois
  divergindo é perder o segredo na próxima vez que a instância for recriada.

Parâmetros existentes: `POSTGRES_PASSWORD` e `KEYCLOAK_CLIENT_SECRET` (`SecureString`);
`PUBLIC_HOST`, `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB` e `POSTGRES_USER`
(`String`). Na fase do N8N entram `N8N_ENCRYPTION_KEY` — sem ela as credenciais
salvas nos workflows ficam ilegíveis — e `N8N_CALLBACK_SECRET`.

**Exceção à regra do nome:** `N8N_BEDROCK_ACCESS_KEY_ID` e
`N8N_BEDROCK_SECRET_ACCESS_KEY` (`SecureString`, desde 2026-10-28) **não existem no
`.env`**. São a chave do usuário IAM que o N8N usa para chamar o Bedrock, e o N8N
guarda credencial no próprio banco, criptografada pela `N8N_ENCRYPTION_KEY`. O
Parameter Store é a única cópia fora do N8N.

**Exceção ao Parameter Store: o SMTP do Gmail.** Quem manda o e-mail de convite e de
"esqueci minha senha" é o Keycloak, pelo Gmail do projeto (`smtp.gmail.com:587`). A senha
é uma **senha de app** do Google, que só existe com a verificação em duas etapas ligada e
que o Google revoga quando a senha da conta muda. Revogada, todo convite e todo reset dão
503 até alguém trocar a `SMTP_PASSWORD` no `.env` e rodar o `ec2/realm/aplicar-ajustes.sh`
de novo (`creed-infrastructure/ec2/README.md`, "E-mail (SMTP)").

**Passagem da conta para a turma seguinte.** Na troca de turma, o dono atual:

1. entrega a quem assume a infra a senha da conta e o segundo fator (o telefone ou os
   códigos de recuperação), fora do git e fora de chat público;
2. confere com essa pessoa que ela entra na conta;
3. só então troca a senha da conta, o que revoga a senha de app antiga;
4. a pessoa nova gera outra senha de app, troca a `SMTP_PASSWORD` no `/opt/creed/.env` e
   roda o `aplicar-ajustes.sh`;
5. a linha de cima, nesta tabela, passa a dizer o nome dela.

Sem isso, a conta fica com quem saiu, e a primeira revogação para o envio de vez.

**Instância:** `t4g.medium` (4 GB) desde 2026-10-28. O porquê e os números estão no
`creed-infrastructure/diario-de-campo-ec2.md`, 2026-10-28.

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
