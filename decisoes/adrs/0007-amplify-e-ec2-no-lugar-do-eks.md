# ADR-0007 — Amplify para o front, uma EC2 para o back: sair do EKS

- **Status:** Proposto
- **Data:** 2026-09-12
- **Decidem:** time CREED

> Vira **Aceito** quando o time confirmar em reunião interna e definir o dono da EC2
> (pendência ao final). O desenho já vale para o que está sendo escrito agora — a
> CREED-23 é a primeira entrega que encosta em infraestrutura real.
>
> ⚠️ Este ADR registra a decisão e **deriva o racional dos documentos do projeto**. Se o
> gatilho real foi outro — custo, restrição da agência, orçamento de crédito AWS —
> acrescente aqui antes de marcar como Aceito. Um ADR que não diz o motivo verdadeiro
> não protege ninguém na próxima discussão.

## Contexto

O desenho de EKS vem do **ADR-001**, herdado. Ele nasceu com três pendências, e a
primeira delas é a que nunca foi respondida:

> *"Confirmar o que a agência já provê de trilhos de EKS antes de construir plataforma
> do zero — cluster compartilhado, ECR, ingress padrão."*

Enquanto ela não é respondida, a segunda pendência — **definir os 1–2 donos de infra** —
também não anda. Hoje o projeto tem um `migration-job.yaml` versionado, notas de EKS, e
**nenhuma pessoa designada** para operar um cluster.

O que trouxe a conversa para agora foi a **CREED-23 entrega 2**: o Keycloak. Ele é um
componente novo, e sob EKS custaria manifest, service, ingress e secret — trabalho que
ninguém no time faz hoje. A entrega resolveu isso empurrando *"Keycloak no EKS"* para
fora do escopo da rodada, o que funcionou como paliativo: o Keycloak existe no
`docker-compose` local e **não existe em lugar nenhum de ambiente real**. Cada componente
novo repetiria a mesma manobra.

Três fatos delimitam a escolha:

1. **Não há dono de infra.** Kubernetes sem alguém que o opere é dívida, não plataforma.
2. **O projeto é de um semestre**, acadêmico, sem SLA e sem tráfego a defender.
3. **O `docker-compose` local já descreve o sistema inteiro** — back, N8N e agora
   Keycloak. Sob EKS ele era uma aproximação do cluster; era preciso manter os dois.

## Decisão

Publicar o front no **AWS Amplify** como build estático, e rodar back, N8N e Keycloak
como três containers numa **EC2 única**, orquestrados pelo mesmo `docker-compose` que
roda na máquina de quem desenvolve. O PostgreSQL continua no **RDS**, fora da instância,
com um schema por componente.

> ⚠️ Os containers são os mesmos, mas o compose de produção virou arquivo próprio. Ver
> [Nota de implementação](#nota-de-implementação--dois-composes-2026-10-09).

O princípio inegociável de que **migration nunca roda no startup do container**
continua valendo; muda só o mecanismo: um **passo dedicado no pipeline** (container
descartável rodando `alembic upgrade head`) no lugar do Job com `helm.sh/hook`.

## Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| **Continuar no EKS** | A pendência #1 do ADR-001 segue sem resposta e não há dono de infra. Cada componente novo — o Keycloak é o primeiro — exige manifest, service, ingress e secret que ninguém no time escreve hoje |
| **ECS / Fargate** | Continua sendo orquestrador: task definition, service, ALB. Paga o custo de aprender orquestração sem o ganho que o EKS ao menos daria, e o compose local deixa de ser o mesmo artefato do ambiente real |
| **Front também na EC2, atrás de Nginx** | Mantém um Nginx nosso para manter e um deploy manual de estático. O Amplify faz build, CDN, TLS e preview por PR sem ninguém operar nada |
| **App Runner / Elastic Beanstalk para o back** | Pensados para um serviço web por vez. N8N quer volume e o Keycloak quer configuração própria; seriam três serviços gerenciados separados no lugar de um compose que já existe |

## Consequências

**Boas:**

- **Local e ambiente real viram a mesma topologia.** O `docker-compose` deixa de ser
  aproximação e passa a ser o artefato de deploy. Um componente novo entra nos dois
  lugares no mesmo commit.
  > ⚠️ **Não se confirmou na implementação:** a produção ganhou compose próprio. Ver
  > [Nota de implementação](#nota-de-implementação--dois-composes-2026-10-09).
- **O Keycloak deixa de estar fora do escopo por falta de plataforma.** O que subiu na
  entrega 2 é o que sobe na instância.
- **Amplify entrega build, CDN, TLS e preview por PR** sem ninguém manter — e o front
  passa a ter deploy próprio, independente do backend.
- **Falha de migration ficou menos grave.** No EKS, deploy parava. Na EC2, o container
  do back simplesmente não é recriado e a instância **continua servindo a versão
  anterior**.

**Ruins — e aceitas:**

- **Ponto único de falha.** Back, N8N e Keycloak caem juntos com a instância. Aceito:
  projeto acadêmico, sem SLA, e a alternativa custa um cluster que ninguém opera.
- **Escala só vertical.** Instância maior é o único caminho. Aceito: não há tráfego
  previsto que justifique horizontal.
- **O disco da EC2 passa a guardar estado.** O volume do N8N é o único dado fora do
  RDS — vira item de backup, e o RDS deixa de ser "o lugar onde tudo está".
- **Dois hostnames.** Front no Amplify, back e Keycloak na EC2. CORS deixa de ser
  detalhe, e o link do convite de primeiro acesso (ADR-0006) aponta para o hostname do
  realm, nunca para o do Amplify.
- **`migration-job.yaml` e o `creed-infrastructure` perdem a função atual.** O manifesto
  fica versionado como referência, mas nada o consome.

## Como reverter

O custo é alto em pessoa-hora e **zero em dado** — o RDS não muda de lugar em nenhum
dos dois desenhos.

Voltar ao EKS significa: escrever manifest, service e secret para os três containers
(hoje o compose descreve os três num arquivo só), configurar ingress, retomar o
`migration-job.yaml` — que continua versionado exatamente por isso — e devolver o front
a um pod Nginx. O que **não** se recupera de graça é o tempo: a decisão só faz sentido
reverter se aparecer dono de infra e uma necessidade de escala que hoje não existe.

## Nota de implementação — dois composes (2026-10-09)

Ao montar a EC2 ([CREED-281](https://app.clickup.com/t/86e3na5jg)), a produção ganhou
um compose próprio, em `creed-infrastructure/ec2/`, separado do `docker-compose.yml`
local do `creed-backend`. Os **componentes são os mesmos** — back, Keycloak, N8N, nas
mesmas imagens e versões —; o que os cerca, não:

| | Local (`creed-backend/docker-compose.yml`) | Produção (`creed-infrastructure/ec2/`) |
|---|---|---|
| Banco | Postgres em container | RDS, fora da instância |
| Keycloak | `start-dev`, admin `admin`/`admin` | `start`, segredos vindos do `.env` da instância |
| Entrada | cada serviço publica a própria porta | só o Caddy (80/443, HTTPS); o resto fechado ou preso a `127.0.0.1` |
| Segredos | valores de desenvolvimento no próprio arquivo | `.env` só na instância, fora do git |

O `realm-creed.json` continua **um arquivo só**, lido pelos dois composes: o que muda
entre ambientes (segredo do client, `sslRequired`) chega por variável de ambiente.

**Descartado:** compose base + arquivo de sobreposição de produção
(`docker-compose.yml` + `docker-compose.prod.yml`). Ficaria mais perto do "mesmo
artefato", mas, com diferença em quase todo serviço, a sobreposição esconderia a
produção em vez de mostrá-la — e obrigaria o arquivo de produção a morar no
`creed-backend`, junto do código.

**Consequência:** a vantagem "um componente novo entra nos dois lugares no mesmo
commit" **deixa de valer**. Componente novo, ou versão nova de imagem, entra nos dois
arquivos — em dois repositórios, portanto em dois PRs.

## Pendências

- [ ] **Quem é o dono da EC2** — a pendência #2 do ADR-001 não morreu, só encolheu.
- [ ] **Onde roda o passo de migration** no pipeline, e com qual credencial de RDS.
- [ ] **Backup do volume do N8N** — o único dado que não está no RDS.
- [ ] **Domínio e TLS** nas duas pontas: Amplify e EC2. É o que fecha o CORS e o
      hostname do realm do Keycloak (ver [`ADR-0006`](0006-e-mail-transacional.md)).
- [ ] **Tamanho da instância.** Três containers mais o overhead do Keycloak (JVM).
