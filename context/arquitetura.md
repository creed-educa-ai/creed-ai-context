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
containers numa **EC2 única**, orquestrados pelo mesmo `docker-compose` que roda na
máquina de quem desenvolve. Local e ambiente real passam a ter a mesma topologia: o que
sobe na sua máquina é o que sobe na instância.

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

O convite de primeiro acesso, ponta a ponta:

```
admin cadastra ──▶ Back: POST /users
                     │
                     └─▶ Keycloak: cria usuário SEM credencial
                              │
                              └─▶ PUT .../execute-actions-email ["UPDATE_PASSWORD"]
                                       │
                                       └─▶ SMTP ──▶ caixa da pessoa
                                                        │
                                        clica no link ──┘
                                             │
                                             ▼
                                    página do realm: define a senha
                                             │
                                             ▼
                                    login normal na plataforma
```

Duas consequências de desenho que valem lembrar:

- **A plataforma não tem tela de troca de senha** — nem hoje, nem depois. Quem define
  senha é sempre a página do realm. O front tem tela de login e mais nada.
- **O link do convite sai do nosso SPA.** Ele abre o Keycloak direto, com o hostname que
  o Keycloak conhece. Hostname errado = link que só funciona na máquina de quem rodou.
  Com o front no Amplify e o Keycloak na EC2, os dois hostnames são **diferentes** —
  o do realm nunca é o do Amplify.

O provedor de SMTP de ambiente real ainda não está escolhido — ver
[`ADR-0006`](../decisoes/adrs/0006-e-mail-transacional.md). Local é Mailpit, e é
suficiente para desenvolver e demonstrar o fluxo inteiro.

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
- **E-mail transacional**: existe domínio e acesso a DNS para verificar identidade de
  remetente, e a conta AWS pode ter SES fora do sandbox? Mesma conversa com a agência —
  ver [`ADR-0006`](../decisoes/adrs/0006-e-mail-transacional.md). Não bloqueia nada
  enquanto o local for Mailpit.
