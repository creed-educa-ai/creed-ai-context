# Arquitetura

## Visão

```
Cliente (mobile/desktop)
  │  HTTPS
  ▼
┌──────────────────────────── AWS / EKS ─────────────────────────────┐
│                                                                    │
│ Front (Nginx, estáticos)                                           │
│   │ /api                                                           │
│   ▼                                                                │
│ Back (Uvicorn) ─── webhook ──▶ N8N (pod stateful + PVC)            │
│   │  ▲                          │                                  │
│   │  └── webhook assíncrono ────┘                                  │
│   │                                                                │
│   ├── token + Admin API ──▶ Keycloak                               │
│   │                             │                                  │
└───┼─────────────────────────────┼──────────────────────────────────┘
    │                             │ SMTP
    ▼                             ▼
PostgreSQL (RDS,            Provedor de e-mail (fora da AWS)
fora do cluster)            local: Mailpit · real: ADR-0006
schemas: app                      │
         keycloak                 ▼
         n8n                caixa da pessoa
                                  │
                                  │ link do convite
                                  ▼
                            página do realm (Keycloak) — não passa pelo front
```

**Keycloak e N8N também gravam no RDS**, cada um no seu schema — RDS único, schema por
componente. Nenhum dos dois tem banco próprio, e é por isso que os três schemas estão
listados juntos acima.

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
- **Nada stateful em pod**, exceto N8N (decisão consciente, ADR-001 §2.1).

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

O provedor de SMTP de ambiente real ainda não está escolhido — ver
[`ADR-0006`](../decisoes/adrs/0006-e-mail-transacional.md). Local é Mailpit, e é
suficiente para desenvolver e demonstrar o fluxo inteiro.

## Esteira de IA (N8N)

Consumida por **webhook assíncrono**: o backend dispara e responde; o resultado volta
por webhook. Não há chamada síncrona de LLM no caminho da requisição do usuário — se
o N8N cair, a plataforma continua servindo.

## Deploy

1. `migration-job.yaml` roda (`helm.sh/hook: pre-upgrade`)
2. Job conclui com sucesso
3. Pods da aplicação sobem

Job falhou → deploy para. A aplicação nunca sobe contra schema inconsistente.

## Pendências herdadas (ADR-001)

- Confirmar o que a agência já provê de trilhos de EKS antes de construir plataforma
  do zero (cluster compartilhado, ECR, ingress padrão).
- Definir os 1–2 donos de infra.
- N8N: volume persistente + schema Postgres dedicado no RDS, modo single.
- **E-mail transacional**: existe domínio e acesso a DNS para verificar identidade de
  remetente, e a conta AWS pode ter SES fora do sandbox? Mesma conversa com a agência —
  ver [`ADR-0006`](../decisoes/adrs/0006-e-mail-transacional.md). Não bloqueia nada
  enquanto o local for Mailpit.
