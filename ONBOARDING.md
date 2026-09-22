# Onboarding — creed-ai-context

Você entrou no time. Este arquivo é o **mapa**: o que existe, onde fica, e em que ordem
mexer. Ele não repete regra — regra mora em `conventions/`, `context/` e `decisoes/`, e
cada seção aqui aponta para onde a sua está.

Os outros três repos têm um `ONBOARDING.md` próprio, com o mapa deles. Este aqui é o
único que explica **como o time trabalha**, porque é aqui que o processo mora.

---

## 1. O primeiro dia

Uma máquina nova precisa só de **git**. O resto o script confere e aponta.

```bash
git clone https://github.com/creed-educa-ai/creed-ai-context.git ~/ages/creed-ai-context
bash ~/ages/creed-ai-context/scripts/setup-workspace.sh -f claude
```

Troque `claude` pela sua ferramenta — `codex`, `copilot`, `cursor`, `todas` ou
`nenhuma`. Quem não usa IA roda `-f nenhuma` e tem o workspace montado igual.

O passo a passo completo do setup, com todas as opções e o que cada etapa faz, está no
[`README.md`](README.md). Não duplico aqui. Duas coisas que o script **não** faz e que
você precisa fazer à mão:

| O quê | Como | Por que importa |
|---|---|---|
| Autenticar o MCP do ClickUp | abra o Claude Code no workspace, rode `/mcp`, escolha `clickup` | é OAuth no navegador, não automatizável. Sem isso o `/spec` pede a descrição colada ([ADR-0002](decisoes/adrs/0002-mcp-do-clickup-no-setup.md)) |
| Conferir a identidade git | `git config user.name` em cada repo | os repos são **públicos**. Sem identidade local, o commit herda o seu `git config --global` — se ele for corporativo, é essa conta que fica no histórico para sempre |

Depois de qualquer `git pull` que traga mudança neste repo, **rode o instalador de
adaptadores de novo**. Eles são um retrato do harness no momento em que você rodou:

```bash
bash creed-ai-context/scripts/instalar-adaptadores.sh
```

---

## 2. O que é SDD aqui

**SDD é Spec-Driven Development: a especificação é um artefato obrigatório entre a
tarefa e o código, e é onde a ambiguidade morre antes de virar linha escrita.**

A ideia não é burocracia. É que existem dois momentos em que uma tarefa pode ser mal
entendida — quando alguém lê o card e quando alguém escreve o código — e escrever a
spec junta os dois num só, mais cedo e mais barato.

> **Escrever a spec é entender, não documentar.** Se você não consegue escrever a seção
> "Como verificar", você ainda não entendeu a tarefa.

Três coisas fazem o SDD deste projeto ser diferente do genérico:

### 2.1 A profundidade é proporcional, e é medida antes

Nem toda tarefa merece spec. Cada uma é calibrada em **dois eixos**:

| Eixo | Escala | Pergunta |
|---|---|---|
| **P** — incerteza de produto | P1 · P2 · P3 | quanto disto a cliente ainda não decidiu? |
| **T** — complexidade técnica | T1 · T2 · T3 | quanto disto o molde já não resolve? |

A calibragem decide **quais seções a spec tem** — e **P1 · T1 não gera spec**: vai
direto para tasks, ou para o código. Em sinal observável, P1 · T1 é: toca um repo, fica
dentro do molde, não cria domínio nem feature, não muda contrato de API, não tem
migration, e os critérios de aceite já são verificáveis sem interpretação nova.

Bug pequeno, ajuste de texto, componente dentro do molde: pule. Domínio novo, relatório
novo, mudança que back e front precisam combinar, regra de quem-pode-o-quê: não pule.

Régua completa em [`conventions/profundidade-da-spec.md`](conventions/profundidade-da-spec.md).

### 2.2 Um documento, não dois

O projeto entrega **uma** spec, não PRD separado de techspec. Isso é decisão, não
economia: os dois eixos da calibragem existem justamente para impedir que um dos lados
saia raso quando os dois moram no mesmo arquivo. Spec com P3 e T1 é quase toda produto;
com P1 e T3, quase toda técnica. A calibragem é o que evita a spec que fala muito de
arquitetura e nada de para quem aquilo serve.

### 2.3 Lacuna de produto vira premissa, nunca bloqueio

**Não há contato com a cliente no meio do desenvolvimento** — ela é acessível em reunião
marcada. Então a dúvida de produto não pode parar a task, e também não pode ser
resolvida em silêncio pelo palpite de quem está implementando.

O mecanismo é o **ledger de premissas** ([`decisoes/premissas.md`](decisoes/premissas.md)):

```
dúvida de produto → premissa escrita como AFIRMAÇÃO, com ID P-NNN,
                    motivo, custo de reverter e status
                          ↓
                    o código segue, assumindo aquilo
                          ↓
                    workflows/duvidas-to-pauta.md junta as abertas
                          ↓
                    pauta/proxima-reuniao.md → a cliente responde
                          ↓
                    premissa fecha (✅ confirmada ou ❌ refutada) e FICA no ledger
```

Premissa fechada continua no arquivo com o desfecho. É o que evita rediscutir a mesma
coisa na sprint seguinte. Regras em
[`conventions/premissas-e-duvidas.md`](conventions/premissas-e-duvidas.md).

Dúvida **técnica** não vira premissa e não vai para a pauta: ou está num ADR, ou é
decisão do time.

---

## 3. O ciclo de uma tarefa, de ponta a ponta

```
ClickUp ──▶ /calibrar ──▶ /spec ──▶ /tasks ──▶ /implementar ──▶ defesa ──▶ /revisar ──▶ /pr
              P × T         │         │            │             (humano)                │
                            │         │            │                                     ▼
                            └─────────┴────────────┘                              PR contra dev
                          artefatos em tarefas/<ID>-<slug>/                     1 aprovação 🔒
                                       │
                                  premissas ──▶ /pauta ──▶ reunião com a cliente
```

| Estágio | Comando | Workflow | Sai o quê |
|---|---|---|---|
| Medir a tarefa | `/calibrar <ID>` | [`profundidade-da-spec.md`](conventions/profundidade-da-spec.md) | P × T e quais seções a spec precisa ter |
| Tarefa → spec | `/spec <ID>` | [`tarefa-to-spec.md`](workflows/tarefa-to-spec.md) | `tarefas/<ID>-<slug>/spec.md` |
| Spec → tasks | `/tasks <ID>` | [`spec-to-tasks.md`](workflows/spec-to-tasks.md) | `tasks.md` + `N_task.md` |
| Tasks → ClickUp | `/publicar-no-clickup <ID>` | [`tasks-to-clickup.md`](workflows/tasks-to-clickup.md) | `clickup.md` + épico e subtarefas no board, com a lista do que anexar |
| A tarefa mudou | `/atualizar-spec <ID>` | [`atualizar-spec.md`](workflows/atualizar-spec.md) | spec atualizada + impacto nas tasks |
| Task → código | `/implementar <ID> <N>` | [`tasks-to-code.md`](workflows/tasks-to-code.md) | código no working tree, **sem commit** |
| Defesa | — | [`defesa-do-codigo.md`](checklists/defesa-do-codigo.md) | você sabe explicar o diff, ou volta |
| Review | `/revisar` | [`revisao.md`](workflows/revisao.md) | veredito |
| PR | `/pr <ID>` | [`abrir-pr.md`](playbooks/abrir-pr.md) | PR contra o alvo do repo (`dev`; `main` aqui), depois do seu "aprovado" |
| Reunião | `/pauta` | [`duvidas-to-pauta.md`](workflows/duvidas-to-pauta.md) | `pauta/proxima-reuniao.md` |

**Se o seu papel é especificar** (AGES III e IV), os quatro primeiros estágios são uma
jornada só, e ela tem manual próprio:
[`playbooks/jornada-de-discovery.md`](playbooks/jornada-de-discovery.md) — do card cru
até subtarefas que um dev pega e começa hoje.

Três portões que não se pulam:

1. **`tasks-to-code` não fala com o ClickUp.** Quem **lê** o board é a especificação;
   quem **escreve** nele é `tasks-to-clickup`, e só depois do seu ok (ADR-0008). Sem
   `tarefas/<ID>-<slug>/`, os dois param e mandam você especificar antes.
2. **A defesa é humana.** Nenhuma saída de IA entra em PR sem alguém do time ter lido o
   diff inteiro e rodado a suíte. Quem não sabe explicar o diff não abre o PR.
3. **`/pr` não escreve em git antes da sua aprovação** — nem `git add`. Ele faz 19
   verificações em modo leitura e mostra os comandos exatos que vai rodar.

---

## 4. Desenvolvimento integrado: por que o workspace é uma pasta só

```
ages/                        ← ABRA A FERRAMENTA DE IA AQUI, não dentro de um repo
├── creed-ai-context/        ← processo, padrões, specs e tasks
├── creed-backend/           ← código
├── creed-frontend/          ← código
├── creed-infrastructure/    ← código
├── .creed-ia.local          ← sua preferência de ferramenta (não versionado)
├── CLAUDE.md                ← adaptador gerado (se você usa Claude Code)
└── AGENTS.md                ← adaptador gerado (se você usa Codex)
```

Isso não é organização estética. Três coisas dependem de os quatro repos estarem lado a
lado:

**O portão de contrato.** Antes de escrever uma tela que consome a API, a ferramenta
abre `creed-backend/app/domains/<dominio>/router.py` para ver se o endpoint existe
mesmo. Se você abriu só o `creed-frontend/`, ela não alcança o backend — e o front
nasce contra campo inventado, com a divergência aparecendo semanas depois.

**O espelhamento.** Domínio do backend e feature do front têm **o mesmo nome, sempre**.
`prognosticos` no back é `prognosticos` no front. Nome novo se escolhe pensando nos dois
lados antes de criar qualquer arquivo
([`conventions/estrutura-e-nomes.md`](conventions/estrutura-e-nomes.md)).

**Os artefatos ficam separados do código.** `spec.md` e `N_task.md` vivem aqui, no
`creed-ai-context`; o código vive nos outros. Consequência prática que pega todo mundo
uma vez: **uma tarefa que toca back e front vira duas tasks e dois PRs**, com o contrato
escrito na primeira. Task não cruza repo — e o pré-voo do `/pr` bloqueia se o working
tree estiver sujo em mais de um.

**Modo agente × modo copiloto.** Nem toda ferramenta lê arquivo e roda comando. Todo
workflow declara os dois: no **modo agente** a ferramenta lê o repo, escreve e roda
(Claude Code, Codex CLI, Cursor Agent); no **modo copiloto** ela só sugere texto e
**você** aplica (Copilot inline, chat avulso). Os passos humanos são os mesmos nos dois:
rodar a suíte, ler o diff inteiro, abrir o PR.

---

## 5. Onde vai o quê, neste repo

Você vai escrever algo. A tabela decide onde:

| Você está escrevendo | Vai em |
|---|---|
| Sequência entrada → saída de um estágio do pipeline | `workflows/` |
| Passo a passo de uma tarefa técnica recorrente | `playbooks/` |
| Regra normativa ("sempre assim", "nunca assim") | `conventions/` |
| O que conferir antes de dar por pronto | `checklists/` |
| Formato de um artefato gerado | `templates/` |
| Decisão de arquitetura, com alternativas descartadas | `decisoes/adrs/` |
| Interpretação de produto adotada sem a cliente | `decisoes/premissas.md` |
| Descrição de como o sistema é (não do que fazer) | `context/` |
| O gatilho para a ferramenta chamar um workflow | `adaptadores/` |
| Spec e tasks de uma tarefa | `tarefas/<ID>-<slug>/` |

E o mapa do resto:

```
creed-ai-context/
├── CONTEXT.md              ← entry point de TODA ferramenta de IA. Comece por ele.
├── catalogo.md             ← o que é cada repo, domínio e feature
├── glossario.md            ← vocabulário do domínio (respondente, prisma, prognóstico)
├── equipe.md               ← quem é quem, e quem revisa PR
├── context/                ← como o sistema é
│   ├── arquitetura.md          as três regras de camada, fronteiras, deploy
│   ├── backend.md · frontend.md · infraestrutura.md
│   ├── trabalho-com-ia.md      as seis regras que valem para qualquer modelo
│   └── aprendizado.md          por que a IA para e explica em vez de só entregar
├── conventions/            ← regra
├── workflows/              ← o pipeline
├── playbooks/              ← passo a passo por tarefa técnica
├── checklists/             ← DoR, DoD, review, defesa do código, PR
├── templates/              ← formato de spec, tasks, ADR, premissa, PR, pauta
├── decisoes/               ← ADRs + ledger de premissas
├── adaptadores/            ← ponteiros por ferramenta (NADA normativo aqui)
├── scripts/                ← setup-workspace, instalar-adaptadores, repos.conf
├── tarefas/                ← specs e tasks, uma pasta por tarefa
└── pauta/                  ← a próxima reunião com a cliente
```

**A regra de ouro dos `adaptadores/`:** se você está prestes a escrever um padrão lá
dentro, ele pertence a `context/` ou `conventions/`. O adaptador é ponteiro fino; regra
repetida dentro dele vira uma segunda versão da regra, e a do adaptador envelhece
primeiro.

---

## 6. Armadilhas deste repo

| Armadilha | O que acontece |
|---|---|
| Editar `CLAUDE.md`, `AGENTS.md` ou `.claude/commands/` no workspace | são **gerados**. O próximo `instalar-adaptadores` sobrescreve. Edite a fonte em `adaptadores/` |
| Esquecer de regenerar depois do `git pull` | você fica com um retrato antigo do harness e não percebe |
| Escrever regra nova dentro de uma skill ou comando | a regra passa a morar em quatro arquivos de ferramenta diferentes — é o problema que este repo existe para resolver |
| Tratar `respondentes` como contrato | ele veio do **scaffold**. É molde de **forma** (camadas, paginação, máquina de status), nunca fonte de campos acordados — inclusive os testes dele, que são exemplo e não cobertura conquistada |
| Criar automação com modelo pesado "por garantia" | [`conventions/skills-e-comandos.md`](conventions/skills-e-comandos.md) §1: modelo leve por padrão, e a exceção se justifica por escrito |
| Commitar por conta própria | a IA deixa no working tree. `git add`/`commit`/`push`/PR é pedido humano explícito |

---

## 7. Prioridade quando duas fontes discordam

1. ADRs (`decisoes/adrs/`)
2. Princípios inegociáveis do [`CONTEXT.md`](CONTEXT.md)
3. `CONTRIBUTING.md` dos repos — é o que o GitHub cobra 🔒
4. `conventions/` e `context/` deste harness
5. Código existente do molde
6. Heurística geral do modelo

Precisa romper essa ordem? Atualize a documentação da ordem primeiro.

---

## 8. Seu primeiro PR aqui

Este repo não tem CI. O que protege é o review — e o `main` exige PR, mesmo sem
aprovação obrigatória.

```
main ← recebe merge de branch de tarefa (este repo não tem dev)
```

Nome da branch: `<slug>/<id>-<contexto-em-2-a-4-palavras>`. Sem tarefa no ClickUp — o
caso normal para mudança de harness — a convenção deste repo é usar **o número do PR**
como id, como em `feat/8-camadas-do-backend`. Você descobre o próximo com
`gh pr list --state all --limit 1`.

O resto (commit, pré-voo, portão de aprovação) está em
[`playbooks/abrir-pr.md`](playbooks/abrir-pr.md) e em
[`CONTRIBUTING.md`](CONTRIBUTING.md).
