# Arquitetura

## Visão

```
Cliente (mobile/desktop)
  │  HTTPS
  ▼
AWS Amplify — estáticos do SPA
  │  /api
  ▼
┌──────────────────────── EC2 (Docker Compose) ──────────────────────┐
│                                                                    │
│ Back (Uvicorn) ─── webhook ──▶ N8N                                 │
│   │  ▲                          │                                  │
│   │  └── webhook assíncrono ────┘                                  │
│   │                                                                │
│   ├── token + Admin API ──▶ Keycloak                               │
│   │                             │                                  │
└───┼─────────────────────────────┼──────────────────────────────────┘
    │                             │ SMTP
    ▼                             ▼
PostgreSQL (RDS,            Provedor de e-mail (fora da AWS)
fora da EC2)                local: Mailpit · real: ADR-0006
schemas: app                      │
         keycloak                 ▼
         n8n                caixa da pessoa
                                  │
                                  │ link do convite
                                  ▼
                            página do realm (Keycloak) — não passa pelo front
```

**Duas peças de compute, não um cluster.** O front é build estático publicado no
**Amplify** — não há Nginx nosso servindo arquivo. Back, N8N e Keycloak são três
containers numa **EC2 única** — os mesmos que sobem na máquina de quem desenvolve, mas
num compose de produção próprio (`creed-infrastructure/ec2/`): sem Postgres, porque o
banco é o RDS, e com o **Caddy** na frente cuidando do HTTPS. Componente novo entra nos
dois composes (ADR-0007, nota de implementação).

**Keycloak e N8N também gravam no RDS**, cada um no seu schema — RDS único, schema por
componente. Nenhum dos dois tem banco próprio, e é por isso que os três schemas estão
listados juntos acima. A EC2 não hospeda banco nenhum.

## As três regras de camada

1. **Agregação no banco.** `SUM`, `COUNT`, `GROUP BY`, janela — no `repository.py`.
2. **Cálculo no backend.** Regra de negócio, derivação, decisão — no `service.py`.
3. **Renderização no front.** O front recebe pronto e desenha.

Se o front está somando array para montar um número de dashboard, a arquitetura
vazou — o número devia ter vindo agregado.

## Fronteiras

- **Domínio não chama domínio pelo repository.** Precisa de dado de outro domínio?
  Passa pelo `service.py` do dono. Import de `models.py` alheio é acoplamento por banco.
- **Front espelha o backend.** Domínio novo no back → feature de mesmo nome no front.
- **Estado mora no RDS, não na máquina.** A exceção é o N8N, que precisa de volume
  próprio (decisão consciente herdada do ADR-001). Back e Keycloak podem ser recriados
  do zero sem perda; o volume do N8N é o único dado que vive no disco da EC2.

## Autenticação e e-mail (ADR-0006)

**Quem manda e-mail é o Keycloak** — nem o backend, nem o N8N. Nenhum código nosso abre
conexão SMTP: o backend chama a Admin API e o Keycloak faz o resto, com template dele.

**Ninguém nasce com senha.** Uma pessoa ganha acesso quando alguém a **convida**: o
`admin`, em qualquer organização e com qualquer papel, ou o `gestor`, só na organização
dele e só como `gestor` ou `respondente` (P-045). O convite é um e-mail com um link; a
pessoa abre o link, define a senha numa página do Keycloak e entra pelo login normal da
plataforma ([CREED-23.8](../tarefas/86e35vhxm-convite-de-primeiro-acesso/spec.md)).

O convite de membro, ponta a ponta:

```
admin ou gestor ──▶ Back: POST /organizations/{organization_id}/members
                      │   {name, email, role, type?}
                      │
                      ├─▶ banco: participante e vínculo        ┐
                      │                                         │ uma transação
                      ├─▶ Keycloak (Admin API): cria o usuário  │
                      │   SEM senha e dá o papel do vínculo     │
                      │                                         │
                      ├─▶ banco: usuário, com o id do Keycloak  ┘
                      │
                      └─▶ Keycloak: PUT .../execute-actions-email ["UPDATE_PASSWORD"]
                                │       link válido por 72 h (P-049)
                                └─▶ SMTP ──▶ caixa da pessoa
                                                 │
                                 clica no link ──┘
                                      │
                                      ▼
                             página do realm: define a senha
                                      │  "voltar para o aplicativo" (P-051)
                                      ▼
                             login normal na plataforma
```

**Tudo ou nada.** Se qualquer passo falha (SMTP ou Keycloak fora do ar), o back apaga o
usuário que criou no Keycloak, o banco volta, e a resposta é **503**: acesso criado é
sempre convite enviado. Há duas exceções raras: o commit que falha depois do envio e o
Keycloak que cai antes de a limpeza terminar. Nas duas, o usuário sobra no Keycloak, e a
nova tentativa responde 409 até alguém apagá-lo pelo console.

Os outros caminhos usam o mesmo e-mail do Keycloak:

| Caso | Rota | Quem |
|---|---|---|
| Acesso para um vínculo que já existe | `POST /users` `{name, email, link_id}` | `admin` |
| Reenviar o convite (link vencido ou perdido) | `POST /users/{user_id}/invitation` | `admin`; `gestor` só na própria organização |
| "Esqueci minha senha" | `POST /authentication/password-reset` `{email}` | público: a resposta é 204 para qualquer e-mail, e só quem tem acesso ativo recebe |
| Primeiro admin de um ambiente novo | `python -m scripts.convidar_primeiro_admin --email … --nome …`, rodado na EC2 | quem tem acesso à EC2 (P-052) |
| Tirar o acesso | `DELETE /users/{user_id}`: apaga no banco e no Keycloak, e o e-mail pode ser convidado de novo | `admin` |

O e-mail é sempre gravado e comparado em **minúsculas**, como o Keycloak guarda. O
contrato completo, com os códigos de erro, está no
[`contrato-api.md`](../tarefas/86e348g6u-autenticacao-da-plataforma/contrato-api.md) da
CREED-23.

Duas consequências de desenho que valem lembrar:

- **A plataforma não tem tela de definir senha.** Quem define senha é sempre a página do
  realm. O front tem a tela de login e a de "esqueci minha senha" (`/reset-password`),
  que só pede o e-mail.
- **O link do convite sai do nosso SPA.** Ele abre o Keycloak direto, com o hostname que
  o Keycloak conhece. Hostname errado = link que só funciona na máquina de quem rodou.
  Com o front no Amplify e o Keycloak na EC2, os dois hostnames são **diferentes** —
  o do realm nunca é o do Amplify.

Em produção, o Keycloak envia pelo **SMTP do Gmail do projeto** (`smtp.gmail.com:587`);
o SES fica para quando houver domínio próprio — ver o adendo do
[`ADR-0006`](../decisoes/adrs/0006-e-mail-transacional.md). Sem domínio, o link do
convite sai com o IP do servidor (`https://<IP>/auth/...`). Local é Mailpit
(`http://localhost:8025`), e é suficiente para desenvolver e demonstrar o fluxo inteiro.

O realm de produção não relê o `realm-creed.json` depois da primeira subida: mudança de
SMTP, idioma, política de senha ou perfil chega pelo `ec2/realm/aplicar-ajustes.sh` do
`creed-infrastructure`.

## Esteira de IA (N8N)

Consumida por **webhook assíncrono**: o backend dispara e responde; o resultado volta
por webhook. Não há chamada síncrona de LLM no caminho da requisição do usuário — se
o N8N cair, a plataforma continua servindo.

## Deploy

Sem cluster não há `helm.sh/hook` — mas o princípio inegociável #2 continua de pé:
**migration nunca roda no startup do container**. Na EC2, quem garante isso é o pipeline:

1. Pipeline sobe um container descartável e roda `alembic upgrade head`
2. Esse container termina com código 0
3. **Só então** o container do back é recriado na imagem nova

Migration falhou → o passo 3 não acontece, e a instância continua servindo a versão
anterior. A aplicação nunca sobe contra schema inconsistente.

O front não entra nesse fluxo: o Amplify publica o build por conta própria, no push. SPA
novo contra backend velho é problema de **contrato de API**, não de schema — e é por
isso que o contrato é escrito antes (`tarefas/<ID>/contrato-api.md`).

## Pendências herdadas (ADR-001)

- Confirmar com a agência o que já existe para **EC2 e Amplify**: AMI ou imagem base,
  registry de imagem (ECR?), domínio e certificado, e quem tem acesso ao console.
- Definir os 1–2 donos de infra.
- N8N: volume no disco da EC2 + schema Postgres dedicado no RDS, modo single. É o único
  ponto do desenho que exige backup de disco, não só de RDS.
- **Tamanho da EC2** e o que acontece quando ela morre. Back e Keycloak voltam sem perda
  (estado no RDS); o N8N não volta sem o volume.
- ~~**E-mail transacional**~~ — resolvido em 2026-10-27: Gmail do projeto por SMTP,
  sem domínio e sem SES. Ver o adendo do
  [`ADR-0006`](../decisoes/adrs/0006-e-mail-transacional.md).
