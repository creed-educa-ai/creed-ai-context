# Arquitetura

## Visão

```
Cliente (mobile/desktop)
        │  HTTPS
        ▼
┌─────────────────────── AWS / EKS ───────────────────────┐
│  Front (Nginx, estáticos)  ──/api──▶  Back (Uvicorn)    │
│                                          │              │
│                                          ├──▶ PostgreSQL (RDS, fora do cluster)
│                                          │              │
│                                          └──webhook──▶ N8N (pod stateful + PVC)
│                                                  │      │
│                                          ◀──webhook assíncrono
└──────────────────────────────────────────────────────────┘
```

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
