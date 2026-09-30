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
| `creed-infrastructure/` | Notas de deploy e o Job de migration aposentado | EC2 · Docker Compose · Amplify |

Detalhe por repo em [`catalogo.md`](catalogo.md). Termos do domínio em [`glossario.md`](glossario.md).
Quem é quem — e quem revisa PR — em [`equipe.md`](equipe.md).

## Arquitetura em uma frase

Cliente (mobile/desktop) → front estático no **Amplify** → back, N8N e Keycloak como
três containers numa **EC2 única** (mesmo `docker-compose` do ambiente local) →
PostgreSQL no **RDS**, um schema por componente. A esteira de IA (N8N) é consumida por
webhook assíncrono. Ver [`context/arquitetura.md`](context/arquitetura.md) e
[`ADR-0007`](decisoes/adrs/0007-amplify-e-ec2-no-lugar-do-eks.md).

## Modelo de dados

Desenhado pelo time no dbdiagram.io. A fonte literal é
[`context/modelo-de-dados.dbml`](context/modelo-de-dados.dbml); a leitura — o que cada
bloco resolve, as pendências e o mapa tabela → domínio — está em
[`context/modelo-de-dados.md`](context/modelo-de-dados.md).

⚠️ **O banco foi inaugurado em 2026-09-13 — e não pelo `.dbml`.** A primeira revisão
do Alembic (`0b0ad39d779a`) criou **só** a tabela `user` da CREED-23; o resto do modelo
continua existindo apenas no diagrama.

**Continua valendo não gerar migration a partir do `.dbml`**: dois pontos do export
atual impedem o DDL de subir. A devolutiva fechou em 2026-09-04 e a correção está em
[`context/modelo-de-dados.proposta.dbml`](context/modelo-de-dados.proposta.dbml):
o caminho é colar no dbdiagram, reexportar por cima e só então migrar o resto.

⚠️ **E a `user` que subiu diverge do modelo do time** — ela tem `name` e `role` como
coluna e não tem o `vinculo_id` do diagrama. A divergência está descrita em
[`context/modelo-de-dados.md`](context/modelo-de-dados.md) → "A v1 e a autenticação".
**Decidido em 2026-09-24:** o papel vai para o vínculo (`Link.role`) e `user` ganha
`link_id`, na [CREED-32](tarefas/86e3anvg2-vinculo-table-context/spec.md). `name` fica
até `Participant` existir. No código, vínculo e setor são `Link` e `Department`
(ADR-0005, decidido em 2026-09-29); o `.dbml` segue com os nomes do diagrama.

## Princípios inegociáveis

1. **Agregação no banco, cálculo no backend, renderização no front.**
   Se o front estiver agregando, a arquitetura vazou.
2. **Migrations nunca rodam no startup do container** — passo dedicado antes do deploy.
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

- **Ler antes de escrever.** O domínio-exemplo (`app/domains/users/`) e a
  feature-exemplo (`src/features/authentication/`) são o molde. Copie a forma deles.
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
                     ↑        │               ↑                  ↓
                  premissas   └▶ subtarefas   │     pauta da reunião com a cliente
                                  no ClickUp  (passo humano)
```

| Estágio | Workflow | Saída |
|---|---|---|
| Tarefa → spec | [`workflows/tarefa-to-spec.md`](workflows/tarefa-to-spec.md) | `tarefas/<ID>/spec.md`, calibrada por [`conventions/profundidade-da-spec.md`](conventions/profundidade-da-spec.md) |
| Spec → tasks | [`workflows/spec-to-tasks.md`](workflows/spec-to-tasks.md) | `tarefas/<ID>/tasks.md` + `N_task.md` |
| Tasks → ClickUp | [`workflows/tasks-to-clickup.md`](workflows/tasks-to-clickup.md) | `tarefas/<ID>/clickup.md` + épico e subtarefas publicados, nivelados por [`checklists/tarefa-nivelada.md`](checklists/tarefa-nivelada.md) |
| Tarefa mudou → spec | [`workflows/atualizar-spec.md`](workflows/atualizar-spec.md) | `spec.md` atualizada + impacto nas tasks e nas premissas |
| Tasks → código | [`workflows/tasks-to-code.md`](workflows/tasks-to-code.md) | código no repo, testes verdes, entrega didática |
| Defesa (humano) | [`checklists/defesa-do-codigo.md`](checklists/defesa-do-codigo.md) | você sabe explicar o diff — ou volta ao estágio anterior |
| Review | [`workflows/revisao.md`](workflows/revisao.md) | veredito + `review.md` quando aplicável |
| Dúvidas → reunião | [`workflows/duvidas-to-pauta.md`](workflows/duvidas-to-pauta.md) | `pauta/proxima-reuniao.md` |

**Quem especifica — AGES III e IV — roda os quatro primeiros estágios como uma jornada
só**, e o manual dela é [`playbooks/jornada-de-discovery.md`](playbooks/jornada-de-discovery.md):
o que investigar antes de inventar, como calibrar, onde cortar as tasks e como publicar
no board. A régua do produto final é uma: **mede-se por quem não usa este repositório**
([`checklists/definition-of-ready.md`](checklists/definition-of-ready.md)).

O pipeline é **proporcional**, e a proporção é medida: cada tarefa é calibrada em dois
eixos — incerteza de **produto** (P1–P3) e complexidade **técnica** (T1–T3) —, e a
calibragem decide quais seções a spec tem. Como o projeto entrega **um documento**, não
PRD + techspec, é o que impede um dos dois lados de sair raso. P1 · T1 não gera spec: vai
direto a tasks. Régua em [`conventions/profundidade-da-spec.md`](conventions/profundidade-da-spec.md).

## Prioridade em conflitos

1. ADRs do projeto (`decisoes/adrs/`)
2. Princípios inegociáveis (acima)
3. `CONTRIBUTING.md` dos repos (git flow, commits, PR) — é o que o GitHub cobra 🔒
4. `conventions/` e `context/` deste harness
5. Código existente do domínio/feature-exemplo
6. Heurística geral do modelo

Se você precisa romper essa ordem, primeiro atualize a documentação da ordem.
