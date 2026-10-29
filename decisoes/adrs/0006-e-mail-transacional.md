# ADR-0006 — E-mail transacional: Mailpit no local, provedor real condicionado

- **Status:** Proposto
- **Data:** 2026-09-10
- **Decidem:** time CREED

> Vira **Aceito** quando o time confirmar em reunião interna. A parte local vale desde
> já — é o que a CREED-23.8 precisa para ser desenvolvida e demonstrada. A parte de
> ambiente real depende de uma resposta da agência que ainda não temos (pendência ao
> final).
>
> *Revisto em 2026-10-29:* segue **Proposto**. A pendência da agência foi resolvida sem
> ela (adendo de 2026-10-27), e a CREED-23.8 implementou o ADR
> ([nota de implementação](#nota-de-implementação--creed-238-2026-10-29)), mas a
> confirmação em reunião interna ainda não aconteceu.

## Contexto

A premissa **P-012** decidiu que o primeiro acesso é por **e-mail com link para o realm
do Keycloak**, onde a pessoa define a própria senha. A consequência boa dessa decisão é
que a plataforma **nunca precisa de tela de troca de senha** — quem manda o e-mail e quem
serve a página são os dois o Keycloak, por `execute-actions-email`. A
[CREED-23.8](https://app.clickup.com/t/86e35vhxm) implementa isso e já tem o escopo
escrito, incluindo a linha "SMTP configurado no realm do Keycloak, versionado junto com o
realm".

O que nenhum documento responde é **de onde sai esse SMTP** — e essa lacuna não é
detalhe de configuração, é o que trava quem pegar a 23.8 no primeiro dia. Três fatos
tornam a pergunta difícil:

**1. Keycloak envia, mas não é servidor de e-mail.** Ele é cliente SMTP. Sem um SMTP
configurado no realm, `execute-actions-email` falha e o convite não existe.
[`premissas.md`](../premissas.md) já registra isso na justificativa da **P-009**
("esqueci minha senha"): *"sem serviço de e-mail, o fluxo de reset não tem por onde sair.
Acrescentar depois é configurar SMTP no realm, não escrever código"*. A frase está certa
sobre o esforço e incompleta sobre o pré-requisito.

**2. A conta AWS e o DNS provavelmente não são nossos.**
[`context/arquitetura.md`](../../context/arquitetura.md) registra como pendência herdada
do ADR-001: *"confirmar o que a agência já provê de trilhos de EKS — cluster
compartilhado, ECR, ingress padrão"*. Isso decide o assunto deste ADR, porque as duas
únicas formas de verificar uma identidade no Amazon SES exigem exatamente uma dessas duas
coisas: **controlar o DNS** de um domínio (3 CNAMEs de DKIM) ou **ter acesso à caixa** do
endereço remetente. Além disso, toda conta SES nasce em *sandbox*, onde o **destinatário
também** precisa ser verificado — o que mata o caso de uso, já que convidar alguém
significa escrever para quem ainda não é nada no sistema. Sair do sandbox é um pedido de
*production access* revisado pela AWS.

**3. O segredo do SMTP colide com a regra da entrega 23.2.** O realm é **arquivo
versionado** (`creed-backend/docker/keycloak/realm-creed.json`), e a regra escrita é que
nada nele se configura clicando na UI. Mas o bloco `smtpServer` carrega a senha do
provedor. Ou a senha entra no repositório — contrariando "segredo nunca no repositório" —
ou o realm deixa de ser inteiramente descrito pelo arquivo, contrariando a regra da 23.2.
Os dois princípios são do projeto e colidem aqui.

### O que foi verificado antes de decidir

O item 3 tem saída, e ela foi **testada**, não suposta — em `quay.io/keycloak/keycloak:26.0`,
a mesma imagem do `docker-compose`:

| Verificação | Resultado |
|---|---|
| Realm com `"host": "${SMTP_HOST}"` e `"user": "${SMTP_USER}"` importa e substitui pelo valor da variável de ambiente | ✅ leitura de volta pela Admin API devolveu os valores reais |
| Sintaxe `${env.SMTP_FROM}` | ❌ **não** substitui — volta literal na configuração do realm |
| `"password": "${SMTP_PASSWORD}"` com Mailpit **exigindo autenticação** | ✅ o convite chegou, o que só é possível com a senha substituída |
| `execute-actions-email` com `["UPDATE_PASSWORD"]` contra Mailpit | ✅ 204, mensagem entregue com `from`, `fromDisplayName` e link de action-token |

A armadilha do `${env.}` merece registro próprio: é a sintaxe que a intuição sugere, a
substituição falha **em silêncio** (o realm importa normalmente) e o sintoma aparece só
no envio, como erro de SMTP que não aponta para a causa.

## Decisão

**1. Ambiente local usa Mailpit, e isso é suficiente para a 23.8 inteira.** Um serviço
`mailpit` no `docker-compose` do `creed-backend`, ao lado de `db`, `keycloak` e `n8n`.
Mailpit não entrega em lugar nenhum: aceita qualquer remetente e qualquer destinatário e
mostra tudo numa UI. O fluxo completo — `execute-actions-email` → e-mail → link → página
do realm → senha definida — é demonstrável sem provedor nenhum. O único trecho falso é o
transporte.

**2. O provedor de ambiente real não é escolhido agora.** Fica condicionado à resposta da
agência sobre domínio, DNS e conta AWS — a mesma pergunta que a `arquitetura.md` já lista
como pendência do ADR-001. Os dois caminhos ficam registrados:

| Se a agência ceder domínio/DNS | Se não ceder |
|---|---|
| **Amazon SES** — coerente com o resto da stack (ADR-001), identidade por domínio com DKIM, e é preciso pedir saída do sandbox | Provedor que envia a partir de **domínio de teste próprio dele**, sem exigir DNS nosso. Pior para produção, suficiente para banca |

**Escolher agora seria escolher no escuro.** A decisão que este ADR toma é que o
desenvolvimento **não espera** por ela.

**3. O segredo sai do arquivo por placeholder, e o realm continua versionado.** O bloco
`smtpServer` referencia variáveis de ambiente com a sintaxe `${VARIAVEL}` — **sem o
prefixo `env.`**:

```json
"smtpServer": {
  "host": "${SMTP_HOST}",
  "port": "${SMTP_PORT}",
  "from": "${SMTP_FROM}",
  "fromDisplayName": "CREED.ai Educa",
  "auth": "${SMTP_AUTH}",
  "user": "${SMTP_USER}",
  "password": "${SMTP_PASSWORD}"
}
```

Local, os valores vêm do `docker-compose` e **nenhum deles é segredo** (`host: mailpit`,
sem autenticação). Em ambiente real vêm de Secret. O arquivo de realm descreve a
**forma** da configuração e continua sendo a única fonte de verdade sobre ela; o que sai
do repositório são só os valores. A regra da 23.2 sobrevive.

**4. Quem manda e-mail é o Keycloak — nem o backend, nem o N8N.** Nenhum código nosso
abre conexão SMTP. O backend chama a Admin API do Keycloak e o Keycloak faz o resto. Isso
já era consequência da P-012; aqui vira regra de arquitetura, para que a próxima
necessidade de e-mail (se aparecer) seja discutida em vez de resolvida por atalho.

**5. Este ADR não altera código.** A 23.8 continua fora do escopo da rodada atual. O que
muda é que ela deixa de ter uma decisão de infra não tomada no caminho.

## Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| **Escolher o SES agora e seguir** | Depende de domínio verificado e de saída do sandbox, as duas coisas fora do nosso controle enquanto a pergunta da agência estiver aberta. Quem pegasse a 23.8 gastaria dias em sandbox para descobrir que precisa verificar o e-mail da cliente um a um para ela receber o convite |
| **Gmail/Google Workspace com senha de app** | Funciona e é tentador. Amarra o produto à conta pessoal de um aluno, tem limite diário baixo e some quando a pessoa sai do time. Serve para um teste manual, não para ser a decisão registrada |
| **Mandar o e-mail pelo N8N**, que já está na stack | O N8N tem nó de SMTP e já existe — parece economia. Mas `arquitetura.md` diz que a esteira de IA é assíncrona justamente porque *"se o N8N cair, a plataforma continua servindo"*. Pôr o convite de acesso nele transforma um componente que pode cair num componente do caminho de autenticação. Troca a natureza do desenho para economizar um container |
| **Backend envia o e-mail direto** (SMTP no FastAPI) | Duplica o que o Keycloak já faz inteiro e reintroduz o que a P-012 eliminou: template nosso, link nosso, e a pergunta "onde fica a tela de definir senha?" de volta. Também obrigaria o backend a guardar credencial de SMTP, que hoje ele não precisa conhecer |
| **MailHog em vez de Mailpit** | O escopo da 23.8 cita "MailHog/Mailpit". MailHog está sem manutenção há anos; Mailpit é o sucessor ativo, com a mesma proposta e API melhor. Entre dois equivalentes, o mantido |
| **Não ter e-mail: manter a senha definitiva para sempre** | É o estado atual e funciona. Mas deixa a P-009 ("esqueci minha senha") sem saída para sempre, e mantém a senha de todo mundo circulando por fora da plataforma — WhatsApp, papel, o que for |
| **Escrever a senha do SMTP no realm versionado** | Segredo em repositório. Não precisa de mais argumento, e o teste mostrou que existe alternativa que não custa nada |
| **Configurar o SMTP clicando na UI do Keycloak** | É exatamente o que a entrega 23.2 existe para impedir: realm clicado é dev e produção divergindo sem ninguém perceber |

## Consequências

**Boas:**

- A 23.8 deixa de ter decisão de infra pendente no caminho. Pode ser desenvolvida,
  testada e **demonstrada** inteira sem provedor nenhum.
- A **P-009** fecha pelo mesmo mecanismo, sem código adicional: "esqueci minha senha" é o
  mesmo `execute-actions-email` com outra action.
- Nenhum segredo entra no repositório, e o realm continua sendo arquivo versionado — os
  dois princípios que pareciam colidir passam a caber juntos.
- A armadilha do `${env.}` fica registrada antes de alguém perder uma tarde com ela.
- A pergunta sobre provedor real vira **item de pauta com dono**, em vez de descoberta no
  meio de uma task.

**Ruins — e aceitas:**

- **O realm deixa de ser autossuficiente.** Ler o arquivo não diz mais qual é o host de
  SMTP: diz que existe um `${SMTP_HOST}`. Mitigação: as variáveis entram no
  `.env.example` do backend, que é onde o time já procura.
- **Um container a mais** no `docker-compose` local. Aceito: sem ele ninguém consegue
  testar a 23.8, e é a alternativa mais barata que existe.
- **Ambiente real continua indefinido.** É dívida assumida e explícita, não esquecimento —
  com a diferença de que agora ela tem um lugar e um gatilho (a resposta da agência).
- **O que for validado com Mailpit não prova entregabilidade.** SPF, DKIM, DMARC e
  reputação só aparecem contra provedor real. Nada disso muda o código; muda o DNS.
- **O link do convite herda o hostname do Keycloak.** Com `http://localhost:8080`, ele só
  abre na máquina de quem rodou. Para demo em outra máquina, `KC_HOSTNAME` precisa
  apontar para algo alcançável — vale para qualquer provedor, inclusive Mailpit.

## Pendência: a pergunta que a agência precisa responder

Item de pauta, não de PR:

> Existe domínio e acesso a DNS que possamos usar para e-mail transacional, e a conta AWS
> onde a EC2 roda pode ter SES habilitado com saída do sandbox?

**Sim** → SES, e este ADR ganha um adendo com região e identidade.
**Não** → provedor com domínio de teste, e o adendo registra o limite que isso impõe.

Enquanto a resposta não vem, nada trava: o item 1 cobre desenvolvimento e demonstração.

## Adendo — provedor de produção: Gmail do projeto por SMTP (2026-10-27)

A resposta acima não chegou, e o projeto não tem domínio. O provedor real ficou sendo o
**Gmail do projeto**, com o Keycloak enviando pelo **servidor SMTP do próprio Google**. O
SES está **descartado enquanto não houver domínio próprio**.

**Por que não o SES:** sem domínio, a única identidade possível no SES é um endereço
avulso, e todo endereço à mão era de provedor que não deixa a AWS falar por ele:

| Remetente | DMARC do domínio (consultado em 2026-10-27) | Pelo SES |
|---|---|---|
| `@edu.pucrs.br` | `p=reject` | **recusado** pelos provedores de quem recebe |
| `@gmail.com` | `p=none` | entregue, mas **falhando** no DMARC — spam provável |

Some-se o *sandbox*, que só entrega a endereços verificados um a um, e o pedido de saída,
que a AWS tende a negar para remetente de provedor gratuito. Pelo SMTP do Google, o
e-mail sai do servidor autorizado para `@gmail.com`: SPF, DKIM e DMARC passam, e não há
sandbox.

**Configuração:**

| Campo | Valor |
|---|---|
| `host` / `port` | `smtp.gmail.com` / `587` |
| `starttls` / `ssl` | `true` / `false` |
| `auth` | `true` |
| `user` | o Gmail do projeto |
| `password` | **senha de app** do Google (exige verificação em duas etapas na conta), nunca a senha da conta |
| `from` | **o mesmo Gmail**: o Google reescreve qualquer outro remetente |
| `fromDisplayName` | `CREED.ai Educa` |

**Verificado em 2026-10-27:** envio de dentro da EC2 pela porta 587 (Python `smtplib`;
o `curl-minimal` do Amazon Linux 2023 não fala SMTP) e *Test connection* do Keycloak de
produção, no realm `creed`. Essa configuração foi feita **pelo console**, como teste: a
fonte continua sendo o `realm-creed.json` com placeholders, aplicado em produção pelo
script da CREED-23.8 (task 7), que sobrescreve o que o console gravou.

**Onde estão as credenciais:** a conta e a senha de app ficam com o dono da conta,
Enzo (CREED-28), que preenche as `SMTP_*` no `/opt/creed/.env` da EC2. Não estão no
Parameter Store.

**Limites aceitos:**
- **Spam no começo.** Conta nova não tem reputação: o primeiro e-mail de teste caiu no
  spam. Avisar quem recebe o primeiro convite.
- **Cerca de 500 destinatários por dia**, o limite de uma conta Gmail comum. Sobra para
  convites e redefinição de senha.
- **Remetente `@gmail.com`**, menos oficial para a cliente.
- **Link do convite com o IP do servidor.** Sem domínio, o `KC_HOSTNAME` de produção é
  `https://<IP>/auth`, e o link do e-mail sai como
  `https://<IP>/auth/realms/creed/login-actions/...`. O remetente passa no DMARC, mas link
  para IP tem cara de phishing, para os filtros e para as pessoas. Antes de convidar a
  cliente, testar com contas Gmail e Outlook. Com domínio, o link muda pelo `PUBLIC_HOST`
  do `.env` da EC2, sem código. *(Acrescentado em 2026-10-29, CREED-23.8.)*

**Como trocar:** com domínio próprio, o SES volta à mesa. A troca é só de valores
(`SMTP_*` no `.env` e o script de ajustes do realm): nada no código do back muda, porque
quem fala SMTP é o Keycloak (item 4).

## Nota de implementação — CREED-23.8 (2026-10-29)

A [CREED-23.8](https://app.clickup.com/t/86e35vhxm) pôs o ADR em código, nas tasks 1 a 7
(creed-backend#49 a #53, creed-frontend#52, creed-infrastructure#10). O que ficou
diferente do texto acima:

- **As `SMTP_*` locais moram no `docker-compose.yml`**, no serviço `keycloak`, e não no
  `.env.example` do back, como dizia a primeira consequência ruim: quem lê é o Keycloak, e
  nenhum valor local é segredo. Em produção, vêm do `/opt/creed/.env` da EC2.
- **O bloco `smtpServer` ganhou `starttls` e `ssl`**, também por placeholder: a porta 587
  do Gmail só aceita login depois do STARTTLS.
- **O realm de produção recebe os ajustes por script** (`ec2/realm/aplicar-ajustes.sh`),
  porque o `--import-realm` não relê um realm que já existe. O script lê o mesmo
  `realm-creed.json` e troca os `${VAR}` com `jq`.
- **O item 4 continua de pé.** O back chama `execute-actions-email` na Admin API, para o
  convite, o reenvio e o "esqueci minha senha", e nunca abre conexão SMTP.
- **O envio é parte da requisição.** Pela D7 da spec da 23.8, se o e-mail não sai, o
  acesso não é criado e a resposta é 503.
- **A P-009 ("esqueci minha senha" não existe) foi refutada**, como a segunda
  consequência boa previa, mas não "sem código adicional": o pedido passa por uma rota do
  back (D10 da spec da 23.8), para o front só falar com o nosso back e o realm continuar
  com `resetPasswordAllowed: false`.

## Como reverter

Cada item é independente e nenhum cria dependência de código:

- Item 1 reverte apagando o serviço `mailpit` do `docker-compose.yml`.
- Item 3 reverte trocando os `${...}` por valores literais no realm. É uma edição de JSON;
  nada lê essas variáveis além do próprio Keycloak.
- Item 4 é regra escrita: reverter é apagar esta seção.
- Item 2 não tem o que reverter — é uma decisão de **não** decidir ainda.

Nenhum passo de build muda, e o backend não ganha dependência nova.
