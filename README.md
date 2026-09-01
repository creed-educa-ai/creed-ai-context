# creed-ai-context

Repositório de contexto do **CREED.ai Educa**. Faz três coisas:

1. **Monta o workspace do zero** — clona os repos, confere os pré-requisitos da sua
   máquina, instala as dependências e deixa tudo pronto para desenvolver.
2. **É a fonte única de padrões para IA** — contexto, convenções, workflows e
   playbooks, **independentes de ferramenta**. Claude Code, Codex, Copilot e Cursor
   leem o mesmo conteúdo; cada um ganha um arquivo de entrada de ~20 linhas que aponta
   para cá. Um padrão muda em um lugar e vale para todo mundo.
3. **Faz o time aprender com o que a IA entrega** — a implementação para nas
   bifurcações para você decidir, encerra explicando abordagem e alternativas
   descartadas, e o PR só abre depois que você consegue defender o diff.
   Ver [`context/aprendizado.md`](context/aprendizado.md).

Produtividade controlada **e** aprendizado. Se as duas brigarem, ganha a segunda —
código que o time não entende é dívida, não entrega.

## Começando do zero

Uma máquina nova precisa só de **git**. O resto o script confere e aponta.

```bash
git clone https://github.com/creed-educa-ai/creed-ai-context.git ~/ages/creed-ai-context
bash ~/ages/creed-ai-context/scripts/setup-workspace.sh -f codex
```

```powershell
git clone https://github.com/creed-educa-ai/creed-ai-context.git $HOME\ages\creed-ai-context
powershell -ExecutionPolicy Bypass -File $HOME\ages\creed-ai-context\scripts\setup-workspace.ps1 -Ferramentas codex
```

Troque `codex` pela ferramenta que você usa — `claude`, `copilot`, `cursor`, `todas`
ou `nenhuma`. O workspace nasce ao lado do repo de contexto, então clone-o já dentro
da pasta que vai ser o workspace.

### O que o setup faz, em ordem

| Etapa | O que acontece |
|---|---|
| 1. Pré-requisitos | confere git, python 3.12+, node 20+, npm, docker e gh. Falta de obrigatório **para** o script, com o comando de instalação por sistema |
| 2. Repositórios | clona os três repos de [`scripts/repos.conf`](scripts/repos.conf); os que já existem, atualiza com `pull --ff-only` |
| 3. Identidade | mostra, repo a repo, a identidade que os seus commits levariam; fixa a local se você passar `--identidade` |
| 4. Backend | cria o `.venv`, roda `pip install -e ".[dev]"`, copia `.env.example` → `.env`, instala os hooks de `pre-commit` e `pre-push` |
| 5. Front-end | `npm install` (o husky se instala junto, pelo `prepare`) |
| 6. IA | instala os adaptadores da ferramenta escolhida e grava a preferência |
| 7. ClickUp (MCP) | registra o servidor `clickup` no Claude Code, escopo local. A autenticação é sua, uma vez, no `/mcp` — ver [ADR-0002](decisoes/adrs/0002-mcp-do-clickup-no-setup.md) |

**É seguro rodar de novo.** Repo com alteração local não é tocado; `.venv` e `.env`
existentes são preservados; adaptador é regerado. É o mesmo comando para montar a
máquina no primeiro dia e para atualizar tudo depois de um tempo longe.

### Opções do setup

| Opção (bash · PowerShell) | O que faz |
|---|---|
| `-f, --ferramentas` · `-Ferramentas` | adaptadores de IA a instalar (ou `nenhuma`) |
| `--workspace` · `-Workspace` | onde montar; padrão é a pasta que contém este repo |
| `--sem-clone` · `-SemClone` | pula a etapa de repositórios |
| `--sem-deps` · `-SemDeps` | pula as dependências dos projetos |
| `--sem-adaptadores` · `-SemAdaptadores` | não instala nada de IA |
| `--sem-mcp` · `-SemMcp` | não registra o MCP do ClickUp |
| `--ignorar` · `-Ignorar` | `local` (padrão) · `repo` · `nao` — repassado ao instalador de adaptadores |
| `--identidade` · `-Identidade` | `"Nome <email>"` — fixa `user.name`/`user.email` **locais** nos repos que ainda não têm |
| `--ssh` · `-Ssh` | clona por SSH |
| `-n, --simular` · `-Simular` | mostra o que faria, sem executar |
| `-h, --ajuda` · `Get-Help` | ajuda completa |

Quem não usa IA nenhuma roda `-f nenhuma` e tem o workspace montado do mesmo jeito.

### O que o script pode te avisar

- **Python mais novo que 3.12.** O projeto tem alvo `py312`; versões bem mais novas
  podem não ter wheel para algum pacote. O script avisa e segue.
- **Repo sem identidade git local.** O commit herda o seu `git config --global`, e
  estes repos são **públicos** — se o global for uma conta corporativa, é ela que
  fica registrada no histórico. O script não adivinha qual identidade você quer:
  mostra a que seria usada e, com `--identidade "Nome <email>"`, fixa a local.
  Identidade local já existente nunca é sobrescrita.
- **Branch preferida ausente.** Hoje os três repos têm `dev`, e é nela que você cai.
  Se um repo novo entrar em `repos.conf` sem a `dev` criada, o script clona a branch
  padrão do remoto e avisa — não inventa branch.

## Estrutura do workspace

```
ages/
├── creed-ai-context/       ← este repo
├── creed-backend/
├── creed-frontend/
├── creed-infrastructure/
├── .creed-ia.local         ← sua preferência de ferramenta (não versionado)
├── CLAUDE.md               ← adaptador (gerado, se você usa Claude Code)
└── AGENTS.md               ← adaptador (gerado, se você usa Codex)
```

## Adaptadores de IA — sob demanda, só a sua ferramenta

Com o workspace já montado, o instalador de adaptadores roda sozinho — é o que o setup
chama na etapa 5. Use quando trocar de ferramenta, ou quando alguém mudar o harness.

```bash
bash creed-ai-context/scripts/instalar-adaptadores.sh -f codex --lembrar
```

```powershell
powershell -ExecutionPolicy Bypass -File creed-ai-context\scripts\instalar-adaptadores.ps1 -Ferramentas codex -Lembrar
```

`--lembrar` grava a escolha em `.creed-ia.local` (na raiz do workspace, não versionado);
das próximas vezes basta rodar sem argumento. Dá para usar a variável de ambiente
`CREED_IA_FERRAMENTAS` no lugar do arquivo.

### Opções

| Opção (bash · PowerShell) | O que faz |
|---|---|
| `-f, --ferramentas` · `-Ferramentas` | `claude,codex,copilot,cursor` ou `todas`. Padrão: env → `.creed-ia.local` → `todas` |
| `-r, --repos` · `-Repos` | limita a repos específicos |
| `--workspace` · `-Workspace` | onde escrever; padrão é a pasta que contém este repo |
| `--sem-raiz` · `-SemRaiz` | não escreve na raiz do workspace |
| `--ignorar <modo>` · `-Ignorar <modo>` | `local` (padrão) · `repo` · `nao` |
| `--lembrar` · `-Lembrar` | grava a preferência de ferramentas |
| `--remover` · `-Remover` | apaga os adaptadores gerados e o bloco de ignore |
| `-n, --simular` · `-Simular` | mostra o que faria, sem escrever |
| `-h, --ajuda` · `Get-Help` | ajuda completa com exemplos |

### O que cada ferramenta recebe

| Ferramenta | Arquivos |
|---|---|
| `claude` | `<raiz>/CLAUDE.md` · `<raiz>/.claude/commands/*.md` · `<repo>/CLAUDE.md` |
| `codex` | `<raiz>/AGENTS.md` · `<repo>/AGENTS.md` |
| `copilot` | `<repo>/.github/copilot-instructions.md` |
| `cursor` | `<repo>/.cursor/rules/creed.mdc` |

Adaptador de ferramenta **não selecionada é removido** (desde que carregue a marca
`GERADO por`) — trocar de ferramenta não deixa arquivo velho para trás.

### Por que `.git/info/exclude` e não `.gitignore`

O `.gitignore` é ele próprio versionado: ignorar por ali significa **commitar** uma
regra que menciona ferramentas que o colega não usa — o mesmo problema, uma camada
acima. O `.git/info/exclude` vale só no seu clone e nunca sobe.

O script escreve ali um bloco delimitado e idempotente:

```
# >>> creed-ai-context: adaptadores de IA (gerados, locais) >>>
/CLAUDE.md
/AGENTS.md
/.github/copilot-instructions.md
/.cursor/
# <<< creed-ai-context <<<
```

Ele ignora **todos** os caminhos de adaptador, não só os seus — assim a escolha de
cada pessoa continua invisível para as outras. Se um dia o time decidir versionar,
`--ignorar repo` move a regra para o `.gitignore`; e `--ignorar nao` deixa os arquivos
aparecerem no `git status`.

### Mantendo em dia

Os adaptadores são um retrato do `creed-ai-context/` no momento em que você rodou o
script. Depois de um `git pull` que traga mudança no harness, rode de novo — é barato
e idempotente.

Para não depender de lembrar, um hook local (também fora do versionamento) resolve:

```bash
printf '#!/bin/sh\nbash "$(git rev-parse --show-toplevel)/../creed-ai-context/scripts/instalar-adaptadores.sh" >/dev/null 2>&1 || true\n' \
  > .git/hooks/post-merge && chmod +x .git/hooks/post-merge
```

Mais adiante isso pode virar um passo dos próprios playbooks de desenvolvimento
("atualizar o projeto e remontar a referência interna"), em vez de um hook.

## Uso por ferramenta

### Claude Code
Abra o workspace em `ages/`. O `CLAUDE.md` carrega sozinho. Slash commands:

| Comando | O que faz |
|---|---|
| `/spec <ID>` | tarefa do ClickUp → `tarefas/<ID>/spec.md` |
| `/tasks <ID>` | spec → lista de tasks incrementais |
| `/atualizar-spec <ID>` | tarefa mudou no ClickUp → spec atualizada + impacto nas tasks |
| `/implementar <ID> <N>` | implementa a task N |
| `/revisar` | review do diff atual contra os checklists |
| `/pr <ID>` | pré-voo da feature e, com sua aprovação, abre o PR |
| `/premissa` | registra uma premissa no ledger |
| `/pauta` | monta a pauta da próxima reunião com a cliente |

**MCP do ClickUp.** O `setup-workspace` registra o servidor `clickup` (escopo local, só
neste workspace). Falta autenticar **uma vez**: abra o Claude Code aqui, rode `/mcp` e
escolha `clickup` — é OAuth no navegador, não dá para automatizar. Autenticado, o
`/spec <ID>` busca a tarefa sozinho; sem autenticar, ele pede a descrição colada, como
sempre fez. Nada mais no pipeline depende disso ([ADR-0002](decisoes/adrs/0002-mcp-do-clickup-no-setup.md)).

### Codex (CLI ou IDE)
Lê o `AGENTS.md` da raiz do repo e sobe na árvore — funciona tanto abrindo `ages/`
quanto um repo isolado. Os "comandos" viram prompts: cole o conteúdo de
`creed-ai-context/adaptadores/prompts/<nome>.md`.

### GitHub Copilot
`.github/copilot-instructions.md` entra em todo chat do repositório automaticamente.
Copilot **não abre arquivos fora do repo** de forma confiável: o adaptador embute o
essencial e aponta o resto. Para workflow completo, cole o prompt de
`adaptadores/prompts/`.

### Qualquer outro chat (ChatGPT, Gemini, Claude web…)
`adaptadores/prompts/` são prompts autocontidos, feitos para copiar e colar.
Comece sempre pelo `adaptadores/prompts/00-contexto.md`.

## Modo agente × modo copiloto

Nem toda ferramenta lê arquivos e roda testes. Todo workflow declara os dois modos:

- **Modo agente** — a ferramenta lê o repo, escreve arquivos e roda comandos
  (Claude Code, Codex CLI, Copilot Agent, Cursor Agent).
- **Modo copiloto** — a ferramenta só sugere texto; **você** aplica, roda e confere
  (Copilot inline, chat avulso).

Os **passos obrigatoriamente humanos** são os mesmos nos dois modos:
rodar a suíte local, ler o diff inteiro e abrir o PR.

## O que este harness deliberadamente NÃO tem

Nem tudo que existe em harness corporativo cabe aqui. Ficaram de fora de propósito:

- **Camadas múltiplas de review automatizado** — o time tem 1 aprovação obrigatória
  no PR; uma camada de review basta.
- **Agentes especializados de QA/DB/sustentação** — não há operação em produção
  com plantão; QA é o CI mais o teste manual do revisor.
- **Ship automatizado de artefatos por PR próprio** — spec e tasks entram no PR da
  própria tarefa.

Se algum desses passar a fazer falta, ele volta — via ADR, não por impulso.

## Evoluindo o harness

Ver [`CONTRIBUTING.md`](CONTRIBUTING.md).
