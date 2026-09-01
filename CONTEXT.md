# CREED.ai Educa — contexto de IA

> **Este é o entry point.** Qualquer ferramenta de IA usada no projeto — Claude Code,
> Codex, Copilot, Cursor, chat avulso — começa por aqui. Os arquivos em
> `adaptadores/` são só ponteiros para este; **nada normativo mora neles**.

## O produto

Plataforma de **Plasticidade Humana e Inteligência Neuroinovadora**.
Cliente: Profa. Dra. Naira Maria Lobraico Libermann · Turma 3JK5JK · 2026/2 (AGES/PUCRS).

Três repositórios, um workspace:

| Repo | O que é | Stack |
|---|---|---|
| `creed-backend/` | API, domínios, migrations | FastAPI · SQLAlchemy · Alembic · Pydantic |
| `creed-frontend/` | SPA por feature | React · TS · Vite · Tailwind · Redux Toolkit · Vitest |
| `creed-infrastructure/` | Job de migration, notas de EKS | Kubernetes · Helm hooks |

Detalhe por repo em [`catalogo.md`](catalogo.md). Termos do domínio em [`glossario.md`](glossario.md).
Quem é quem — e quem revisa PR — em [`equipe.md`](equipe.md).

## Arquitetura em uma frase

Cliente (mobile/desktop) → **tudo o mais dentro da AWS/EKS**: front (Nginx), backend
(Uvicorn), PostgreSQL no RDS, N8N self-hosted como esteira de IA consumida por webhook
assíncrono. Ver [`context/arquitetura.md`](context/arquitetura.md).

## Princípios inegociáveis

1. **Agregação no banco, cálculo no backend, renderização no front.**
   Se o front estiver agregando, a arquitetura vazou.
2. **Migrations nunca rodam no startup do container** — Job dedicado.
3. **Autogenerate de migration sempre revisado linha a linha.**
4. **CI é obrigatório** — pre-commit acelera, CI garante.
5. **Estrutura por domínio (back) e por feature (front), espelhadas.**
6. **Sem contato com a cliente no meio do desenvolvimento**: dúvida vira
   **premissa registrada**, não bloqueio. Ver
   [`conventions/premissas-e-duvidas.md`](conventions/premissas-e-duvidas.md).
7. **Código entregue por IA precisa ser defensável por quem entrega.** Quem não sabe
   explicar o diff não abre o PR — a IA implementa, o julgamento continua humano.
   Ver [`context/aprendizado.md`](context/aprendizado.md).

## Como a IA trabalha aqui

Regras que valem para **qualquer** modelo ou ferramenta:
[`context/trabalho-com-ia.md`](context/trabalho-com-ia.md). Resumo:

- **Ler antes de escrever.** O domínio-exemplo (`app/domains/respondentes/`) e a
  feature-exemplo (`src/features/respondentes/`) são o molde. Copie a forma deles.
- **Não inventar padrão.** Se não está documentado aqui nem existe no código, pergunte
  ou registre premissa — não improvise.
- **Não commitar por conta própria.** Implementar e revisar é da IA; `git commit`/`push`/
  PR é decisão humana explícita (ver [`playbooks/abrir-pr.md`](playbooks/abrir-pr.md)).
- **O humano é o portão.** Nenhuma saída de IA entra em PR sem alguém do time ter lido
  e rodado os testes localmente ([`checklists/definition-of-done.md`](checklists/definition-of-done.md)).
- **Entender é parte da entrega.** Toda implementação encerra explicando abordagem e
  alternativas descartadas ([`templates/entrega-didatica.md`](templates/entrega-didatica.md)),
  e para nas bifurcações de design para o humano decidir. Código no nível do time,
  não código esperto ([`conventions/nivel-de-codigo.md`](conventions/nivel-de-codigo.md)).
- **Automação nova é leve e determinística.** Comando, skill ou workflow novo declara
  o modelo mais barato que dá conta e descreve passos com entrada, ação e saída
  verificável. Ver [`conventions/skills-e-comandos.md`](conventions/skills-e-comandos.md).

## Pipeline SDD

```
tarefa (ClickUp) → spec → tasks → código → defesa → review → PR
                     ↑                        ↑                  ↓
                  premissas           (passo humano)   pauta da reunião com a cliente
```

| Estágio | Workflow | Saída |
|---|---|---|
| Tarefa → spec | [`workflows/tarefa-to-spec.md`](workflows/tarefa-to-spec.md) | `tarefas/<ID>/spec.md` |
| Spec → tasks | [`workflows/spec-to-tasks.md`](workflows/spec-to-tasks.md) | `tarefas/<ID>/tasks.md` + `N_task.md` |
| Tasks → código | [`workflows/tasks-to-code.md`](workflows/tasks-to-code.md) | código no repo, testes verdes, entrega didática |
| Defesa (humano) | [`checklists/defesa-do-codigo.md`](checklists/defesa-do-codigo.md) | você sabe explicar o diff — ou volta ao estágio anterior |
| Review | [`workflows/revisao.md`](workflows/revisao.md) | veredito + `review.md` quando aplicável |
| Dúvidas → reunião | [`workflows/duvidas-to-pauta.md`](workflows/duvidas-to-pauta.md) | `pauta/proxima-reuniao.md` |

O pipeline é **proporcional**: tarefa pequena pula spec e vai direto a tasks. Critério
em [`workflows/tarefa-to-spec.md`](workflows/tarefa-to-spec.md) → "Quando pular".

## Prioridade em conflitos

1. ADRs do projeto (`decisoes/adrs/`)
2. Princípios inegociáveis (acima)
3. `CONTRIBUTING.md` dos repos (git flow, commits, PR) — é o que o GitHub cobra 🔒
4. `conventions/` e `context/` deste harness
5. Código existente do domínio/feature-exemplo
6. Heurística geral do modelo

Se você precisa romper essa ordem, primeiro atualize a documentação da ordem.
