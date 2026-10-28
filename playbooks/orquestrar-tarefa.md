# Playbook: orquestrar a implementação de uma tarefa

> Uso: abrir uma sessão nova do Claude Code na raiz do workspace (`creed/`), em opus,
> preencher os `{…}` do bloco "Prompt" e colar inteiro. A sessão principal vira a
> orquestradora: decide ordem, paralelismo e quem executa. Cada task continua passando
> pelo caminho oficial, [`../workflows/tasks-to-code.md`](../workflows/tasks-to-code.md)
> no papel de [`../roles/implementador.md`](../roles/implementador.md), uma por vez em
> cada repo e em paralelo entre repos.
>
> **Quando usar:** tarefa com duas ou mais tasks para implementar na mesma sessão. Uma
> task só continua sendo `/implementar <ID> <N>`.
>
> Nada aqui depende de automação nova: só o workflow, os papéis, os checklists e as
> skills que já existem no harness, e as ferramentas padrão do Claude Code (Agent,
> AskUserQuestion, Bash; Workflow só no modo ultracode, com as guardas da seção própria).

---

## Prompt

```
Você vai conduzir a implementação da tarefa {ID ClickUp} ({título curto}), em
`creed-ai-context/tarefas/{ID}-{slug}/`.
Seu papel é ORQUESTRAR: planejar a ordem, delegar ou executar cada task pelo caminho oficial,
conferir evidências e me reportar. O caminho oficial é `creed-ai-context/workflows/tasks-to-code.md`,
no papel de `creed-ai-context/roles/implementador.md`: portão de entrada, leitura de task + spec +
molde, playbook aplicável, parada de decisão, código + teste, suíte, auto-review contra
`creed-ai-context/checklists/revisao-de-codigo.md`, entrega didática. Não invente procedimento: onde o
workflow já diz como fazer, siga o workflow.

### Escopo desta sessão
- Tasks a executar: {todas | 1, 2, 6 | "até a 5"}.
- Tasks que são ação manual minha (não implemente; pare e me peça): {7, a parte de produção | nenhuma}.
- Pontos de parada obrigatórios (não avance sem meu OK): {PR da task 1 mergeado na dev antes da 2 |
  nenhum além dos gates manuais}.
- Branch: a "Branch sugerida" de cada `N_task.md`, criada a partir de `origin/dev` (`origin/main` no
  `creed-ai-context`), no formato de `creed-ai-context/conventions/git-workflow.md`. Task sem branch
  sugerida → me pergunte o nome (ele precisa do ID do ClickUp). Repo com working tree sujo ou em outra
  branch de trabalho → pare e me pergunte; não troque de branch por conta própria.

### Regras que não mudam
1. NÃO versiona: nada de `git add`, `commit`, `push`, `tag`, `stash` nem PR, nem você nem subagente.
   Branch, só as que eu aprovar no plano. Versionar é o `/pr {ID}`, depois da minha defesa do código
   e com a minha aprovação (`creed-ai-context/playbooks/abrir-pr.md`).
2. Uma task por vez por repo. Paralelismo só entre repos diferentes (um working tree por repo).
3. Task sem suíte verde real não é concluída e não é marcada. Evidência é o comando rodado e a contagem
   lida da saída, não a frase "testes passaram":
   - `creed-backend`: a linha final do `pytest` (`N passed, M failed, K skipped`) e
     `pre-commit run --files <arquivos tocados>` — o mypy do hook não é o da `.venv`;
   - `creed-frontend`: `npm run check` (é o que o CI roda), com o resumo `Tests` do Vitest;
   - `creed-infrastructure` e `creed-ai-context`: o "Como testar" da própria task.
4. Bifurcação técnica com efeito no diff e sem resposta no harness → parada de decisão
   (`tasks-to-code.md` → "Parada de decisão": no máximo 2 por task, com recomendação). Me traga o
   bloco "⏸ DECISÃO SUA" e não escolha. Lacuna de PRODUTO não para: vira premissa
   (`creed-ai-context/conventions/premissas-e-duvidas.md`) e a task segue. Divergência entre a
   task/spec e o contrato que já existe no código (`schemas.py`, `src/types/api.ts`, o
   `contrato-api.md` da tarefa) → pare aquela task e me traga a divergência.
5. "Arquivos que provavelmente mudam" é guia, não cerca: outro arquivo no mesmo repo pode, mas vem
   no relato com o motivo. Arquivo em outro repo → pare: a task estava errada.
6. Padrões vêm do molde (`creed-backend/app/domains/users/`, `creed-frontend/src/features/authentication/`)
   e das skills de `.claude/skills/`. Dependência nova, só perguntando. Nível do time
   (`creed-ai-context/conventions/nivel-de-codigo.md`). `models.py` mudou → migration TEMPORÁRIA
   (ADR-0009, `creed-ai-context/playbooks/criar-migration.md`, fluxo A): sobe só no banco local, não
   entra no diff, e a task encerra com a seção "Banco" do PR. Nunca `alembic upgrade` fora do banco
   local; nunca `kubectl`, `helm` ou `aws` contra ambiente real.
7. Só você escreve no `tasks.md` da tarefa, depois de conferir a evidência da task. Subagente relata;
   você marca. O mesmo vale para o ledger de premissas (`creed-ai-context/decisoes/premissas.md`):
   o builder devolve o texto da premissa, você registra uma por vez, na numeração do ledger.

### Modelo e esforço
- Você, orquestrador, roda no modelo e no esforço desta sessão. Não suba o esforço por conta própria.
- Subagente HERDA o esforço da sessão (a ferramenta Agent não tem parâmetro de esforço; só de
  modelo). Então o nível desta sessão é o nível de todo mundo. Não existe "orquestrador em xhigh e
  builders em high" fora do modo ultracode (ver a seção própria).
- Builders (escrevem código ou fazem análise de código, inclusive a passada pesada do tier Sensível):
  modelo `opus`, no máximo **3 ao mesmo tempo**. Demais tarefas (ler material extenso, buscar no
  harness, logs, banco local, conferir contrato): `sonnet`. Nunca `haiku` para código.
- Passou de 3 builders prontos para disparar → fila; serialize pelo grafo, não abra o 4º.

### Fase 1 — Plano (antes de tocar em código)
1. Leia `tasks.md` (o "Progresso" e a seção de ordem, se houver: "Ordem e corte" ou equivalente) e,
   de cada `N_task.md` no escopo, só o cabeçalho e as listas: título, **Repo**, **Depende de**,
   **Branch sugerida**, "Arquivos que provavelmente mudam", "Molde". Não leia a spec agora: quem
   implementa lê inteira na hora (passo 1 do `tasks-to-code.md`). Faltou `tasks.md` ou algum
   `N_task.md` do escopo → pare: é o portão de entrada do `tasks-to-code.md`.
2. Monte o grafo de dependências a partir do "Depende de" de cada task e da seção de ordem do
   `tasks.md`. Se os dois divergirem, me mostre em vez de escolher. Dependência fora do board (PR
   de outra tarefa) → confira se já está na `origin/dev`; se não estiver, é parada.
3. Separe as tasks em etapas: cada etapa é o conjunto de tasks cujas dependências já fecharam,
   agrupadas por repo. Dentro de uma etapa, tasks de repos diferentes podem rodar em paralelo (até
   3 builders); tasks do mesmo repo ficam em ordem. Encerram a etapa: gate manual, PR que precisa
   estar na `dev`, passo em produção, e **duas tasks seguidas no mesmo repo com branches
   diferentes** — sem commit da IA, a segunda não tem de onde partir: a primeira passa pela minha
   defesa e pelo `/pr`, e a segunda sai da `dev` depois do merge ou empilhada na branch da primeira.
   Marque no plano qual dos dois você propõe.
4. Para cada repo afetado: `git -C <repo> status --short` (tem que estar vazio), a branch atual e o
   sha de `origin/dev`. Proponha os comandos de branch; não os execute ainda.
5. Me apresente o plano assim e espere aprovação (AskUserQuestion: aprovar / ajustar / cancelar):

   Tarefa {ID} · N tasks no escopo · M etapas · sessão: {modelo} {esforço}
   Repos: {repo} ({branch}, de origin/dev {sha}, limpo) · …
   Etapa 1 (paralelo entre repos): 1 [back]  6 [front]
   ── parada: defesa + /pr da 1, merge na dev (a 2 sai de outra branch) ──
   Etapa 2: 2 [back] ‖ 7 [infra]
   Etapa 3: …
   Gates manuais: … · Tier Sensível previsto: … (migration, autenticação, contrato de API,
   agregação de indicador, infra)

### Fase 2 — Execução, etapa por etapa
Aprovado o plano: crie as branches aprovadas e execute uma etapa de cada vez.

**Quem implementa cada task (modo padrão):**
- Etapa com uma task, ou cadeia num repo só: você mesmo, seguindo `tasks-to-code.md` direto. Não
  chame `/implementar`: o frontmatter dele fixa `sonnet`, e aqui a escrita de código é `opus`.
- Etapa com tasks em repos diferentes: um builder por repo (ferramenta Agent, tipo general-purpose,
  modelo `opus`), até 3 em paralelo. Cada builder recebe este contrato, nada além dele:
  ```
  Assuma o papel de creed-ai-context/roles/implementador.md e implemente a task {N} da tarefa {ID}
  (creed-ai-context/tarefas/{ID}-{slug}/{N}_task.md) seguindo creed-ai-context/workflows/tasks-to-code.md
  INTEIRO, inclusive o portão de entrada, o passo 1 (task, spec.md e o molde inteiros), o passo 3
  (playbook aplicável) e o passo 7 (auto-review contra creed-ai-context/checklists/revisao-de-codigo.md,
  com tier). Repo: {caminho absoluto}, já na branch {branch}. NÃO faça git add/commit/push/stash/branch.
  NÃO edite tasks.md nem creed-ai-context/decisoes/premissas.md. Arquivo fora dos "Arquivos que
  provavelmente mudam" pode, se for do mesmo repo: liste com o motivo. Outro repo: PARE. Subagentes
  seus só para o auxiliar (ler material, buscar, logs, banco local), em sonnet. Você não pode perguntar
  ao usuário: em bifurcação técnica, PARE e devolva o bloco "⏸ DECISÃO SUA" do tasks-to-code.md (no
  máximo 2, com recomendação); lacuna de produto vira premissa, e você segue. Ao terminar, devolva SÓ:
  status (concluída / parada: motivo); arquivos criados e alterados, com o motivo de cada um fora da
  lista da task; comandos de teste rodados e a contagem (passou/falhou/skipped) copiada da saída;
  tier do auto-review e veredito (exigências e como foram resolvidas); premissas adotadas, com o texto
  para o ledger; nomes que a próxima task consome (rotas, schemas, tipos, slices, settings, chaves de
  i18n); pendências; e a entrega didática completa, no formato de
  creed-ai-context/templates/entrega-didatica.md. Sem diff.
  ```
  Em sequência no mesmo repo depois de um builder: passe ao próximo os "nomes que a próxima task
  consome" do relato anterior — subagentes não dividem contexto.
- Task de ação manual: descreva exatamente o que eu preciso fazer e espere.

**Ao receber o relato de cada task (seu ou de builder), confira antes de marcar:**
- `git -C <repo> status --short`: os arquivos tocados são os relatados, e quem saiu da lista da
  task tem motivo. Migration temporária em `alembic/versions/` é esperada: ela não entra no diff,
  e a entrega lembra o `alembic downgrade` antes de apagar.
- Evidência de teste: rode você mesmo a suíte do repo (regra 3) e leia a contagem. Não marque por
  relato.
- Veredito do auto-review sem exigência aberta. Tier Sensível → a passada pesada é um revisor novo
  (Agent, `opus`) com o prompt de `creed-ai-context/workflows/revisao.md` → "Tier Sensível: pare e
  escale"; me proponha e só dispare com o meu OK. A segunda leitura humana fica pendente no relato.
- Premissas do relato: registre no ledger e marque o artefato
  (`creed-ai-context/conventions/premissas-e-duvidas.md`).
- Então marque a task no `tasks.md` e me mande UMA linha:
  `{N} ✓ · {repo} · {n} arquivos · suíte {p}/{f}/{s} · review {tier} {veredito}`, seguida da
  entrega didática da task, sem resumir — é com ela que eu faço a defesa.
- Suíte vermelha, review com exigência aberta, builder parado ou arquivo em outro repo → não marca;
  me traz com o que precisa de decisão.

**Fim de etapa:** resumo das tasks fechadas, o que a próxima etapa precisa (ex.: "defesa e /pr da 1,
merge na dev"; "credenciais no .env da EC2"), e espere meu OK para seguir.

### Modo ultracode — guardas (só se um system-reminder confirmar que o ultracode está ligado)
Ultracode troca o executor, não o procedimento. O que muda:
- **Você nunca executa.** Nenhuma task na sessão principal: toda task vai para um builder,
  inclusive as cadeias em sequência de um repo só. Você planeja, dispara, confere e registra.
- **Fan-out pela ferramenta Workflow, um script por etapa aprovada**, nunca pela tarefa inteira.
  Cada `agent()` de builder leva `{ model: 'opus', effort: 'high', agentType: 'general-purpose' }` —
  o esforço do ultracode fica só em você, o orquestrador; builder roda no `high`, que é o padrão.
  Auxiliares em `{ model: 'sonnet' }`. Sem `isolation: 'worktree'` (o código fica no checkout do
  repo, como no modo padrão).
- **Um builder por repo por vez, ≤ 3 ao mesmo tempo.** Modele a etapa como `pipeline()` sobre os
  repos; dentro de um repo as tasks são estágios em sequência; mais de 3 repos → corte a lista em
  blocos de 3, um `parallel()` por bloco. Nada de loop "até secar", judge panel ou sweep adversarial
  sobre código: isso é para review e pesquisa, não para implementar.
- **Builder devolve dado estruturado** (`schema`): `{ status: 'concluida' | 'parada', motivo,
  decisoes: [], arquivos: [], teste: { comando, passou, falhou, skipped }, review: { tier, veredito,
  abertos: [] }, premissas: [], nomes: [], pendencias: [], entrega }`, com `entrega` sendo a entrega
  didática completa. Agente do Workflow não fala com você no meio: `parada` com bloco "⏸ DECISÃO SUA"
  → o script termina a etapa, você me pergunta, e retoma com `resumeFromRunId` depois de responder
  no `args` (os builders que já concluíram não rodam de novo).
- **O que o Workflow não pode fazer segue igual:** git de escrita, `tasks.md`, ledger de premissas,
  arquivo em outro repo, decidir bifurcação técnica. A conferência pós-builder (git status, suíte,
  review) é sua, fora do Workflow, antes de marcar.
- **Antes de disparar**, me mostre o esboço do script da etapa (repos, ordem, modelo/esforço de
  cada agente) e espere o OK: um Workflow dispara muitos agentes e cada um paga o fixo da sessão.
- Passada pesada do Sensível, defesa e PR continuam fora: `workflows/revisao.md`,
  `checklists/defesa-do-codigo.md` e `/pr`, no modo padrão.

### Fase 3 — Encerramento
Fechadas as tasks do escopo: resumo por repo (tasks, arquivos, suíte, reviews, premissas,
pendências) e as próximas ações do caminho oficial, sem executá-las sem meu OK:
- defesa do código, task por task (`creed-ai-context/checklists/defesa-do-codigo.md`) — é minha;
- tier Sensível: passada pesada e segunda leitura humana que faltarem (`workflows/revisao.md`);
- migration temporária: `alembic downgrade` antes de apagar o arquivo;
- `/pr {ID}` por branch — pré-voo e PR contra a `dev` (`main` no harness);
- premissas novas → `/pauta`.
Se alguma task ficou parada, listar o motivo e a pergunta pendente.

### Se der errado
- Suíte vermelha que você não resolve em duas tentativas → pare a task e me mostre o erro.
- Builder devolveu relato sem evidência de teste ou sem entrega didática → peça; sem elas a task
  não fecha.
- Dois builders tocando o mesmo repo → nunca; se o plano levaria a isso, serialize.
- Mais de 3 builders em voo → pare de disparar; a fila espera.
- Sessão ficando pesada (muito código lido) → termine a task em curso, me dê o resumo e proponha
  continuar numa sessão nova com este mesmo prompt e "Tasks a executar" ajustado ao que falta.
```

---

## Exemplo preenchido — CREED-23.8 (convite de primeiro acesso)

Só o bloco "Escopo desta sessão" muda; o resto do prompt vai igual.

```
Você vai conduzir a implementação da tarefa 86e35vhxm (Convite de primeiro acesso por e-mail),
em `creed-ai-context/tarefas/86e35vhxm-convite-de-primeiro-acesso/`.
…
### Escopo desta sessão
- Tasks a executar: 1 a 7; da 7, só o script e o compose. Fora: 8 (documentos, fecha atrás de 2 a 7,
  em sessão própria).
- Tasks que são ação manual minha: 7, a parte de produção (credenciais do Gmail no `/opt/creed/.env`
  com o Enzo; aplicar na EC2 depois do release).
- Pontos de parada obrigatórios: "Um PR por task" (tasks.md) — entre duas tasks do back, defesa e
  /pr da anterior; a 2 parte da dev que já tem o creed-backend#47.
- Branch: a "Branch sugerida" de cada N_task.md, de origin/dev.
- Observações do tasks.md que valem aqui: a 5 "pode andar em paralelo" à 3 e à 4, mas é o mesmo
  repo — aqui serializa; a 6 começa já, contra o contrato da spec.
```

Plano esperado para esse escopo (o que a sessão deve devolver na Fase 1):

```
Etapa 1 (paralelo entre repos): 1 [back]  6 [front, contra o contrato da spec]
── parada: defesa + /pr da 1, merge na dev (a 2 lê as settings e o Mailpit da 1) ──
Etapa 2: 2 [back] ‖ 7 script e compose [infra]
── parada: defesa + /pr da 2 ──
Etapa 3 (só back, uma por vez, defesa + /pr entre elas): 3 → 4 → 5
── gates manuais: 7 em produção (credenciais + release) · 8 em sessão própria ──
Tier Sensível previsto: 2 a 6 (autenticação e contrato de API), 7 (infra)
```

---

## Por que o playbook é assim (para quem for ajustar)

- **Ele não cria procedimento novo.** Cada task continua passando pelo `tasks-to-code.md` inteiro —
  inclusive a leitura integral da spec e do molde e a parada de decisão. O playbook só decide ordem,
  paralelismo e quem executa.
- **Paralelismo é só entre repos**, pela razão física (um working tree por repo) e porque o diff de
  cada repo continua revisável sozinho. Por isso o princípio do `tasks-to-code.md` é "uma task por
  vez **por repo**" (27/10/2026) — os `tasks.md` já planejavam "outro repo, em paralelo".
- **Branch por task vira parada.** Quando a spec corta "um PR por task", duas tasks seguidas no mesmo
  repo não têm de onde partir sem o commit da primeira, e commit é humano.
- **Esforço: subagente herda o da sessão.** A ferramenta Agent só escolhe modelo. Por isso o playbook
  controla custo pelo modelo (opus só nos builders) e pela concorrência (3), não pelo esforço.
- **Opus nos builders é parametrização proposital** ([`../conventions/skills-e-comandos.md`](../conventions/skills-e-comandos.md)
  §1 → "Exceção"). A tabela põe código dentro do molde em modelo médio; aqui sobem a orquestração,
  os builders e a passada pesada do Sensível. Leitura, busca, logs e banco local ficam em `sonnet`.
  Decisão do Luís (27/10/2026): o playbook é de uso pontual, numa sessão que já roda em opus. O
  `/implementar` do dia a dia segue em `sonnet`, e a exceção não vale como precedente.
- **Ultracode é orquestrador, nunca executor.** Lá o esforço alto fica só na sessão principal; a
  ferramenta Workflow é a única que aceita `effort` por agente, então é ela que mantém os builders em
  `high`. As guardas (um script por etapa, ≤ 3 builders, sem worktree, schema de retorno, esboço
  antes de disparar) existem porque um Workflow dispara muitos agentes de uma vez e não para para
  perguntar.
- **Subagente não pergunta ao usuário**: por isso o contrato manda ele PARAR e devolver o bloco da
  parada de decisão, e a sessão principal é quem traz para você. É limitação da ferramenta, não
  desenho.
- **A entrega didática atravessa o orquestrador inteira.** É com ela que o dev faz a defesa
  (princípio 7 do `CONTEXT.md`); resumida, ela perde o "O que descartei" e o "Não provam".
- **O orquestrador roda a suíte de novo antes de marcar.** Os repos não gravam relatório de teste em
  arquivo; a saída do comando é a única evidência que não depende do relato.
- **Premissa e `tasks.md` têm um escritor só.** Dois builders registrando premissa ao mesmo tempo
  pegariam o mesmo número no ledger.
- **Quando a sessão ficar pesada**, o remédio é o mais simples: encerrar com resumo e continuar com o
  mesmo playbook numa sessão nova. O `tasks.md` marcado é o estado.
- **Ainda não rodou numa tarefa real do CREED.** O `skills-e-comandos.md` §4 pede isso; a primeira
  rodada cita o resultado aqui.
- O que fica de fora de propósito: contabilidade de tokens, scripts de validação, sessões em segundo
  plano, contratos em arquivo.
