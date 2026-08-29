# ADR-0001 — Harness de IA único e independente de ferramenta

- **Status:** Proposto
- **Data:** 2026-08-29
- **Decidem:** time CREED

## Contexto

Todo mundo do time desenvolve com IA, mas não com a mesma: a maioria usa Claude Code,
outros usam Codex e Copilot. Cada ferramenta lê um arquivo de instrução diferente
(`CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.cursor/rules/`), e sem
combinação prévia cada pessoa acaba instruindo o próprio modelo do seu jeito.

O efeito prático já é visível em projetos parecidos: dois domínios com estruturas
diferentes, dois estilos de teste, dois padrões de nomeação — não porque alguém
discordou, mas porque cada modelo preencheu a lacuna do seu jeito.

Existe referência interna madura (o harness da Theke APIs, corporativo), mas ela
assume duas coisas que aqui não valem: uma única ferramenta (Claude Code) e contato
corporativo com o PO durante o desenvolvimento.

## Decisão

Manter **um** diretório de contexto — `creed-ai-context/` — com todo o conteúdo normativo
em Markdown neutro, e **gerar** a partir dele os arquivos de entrada de cada
ferramenta. Nenhum arquivo de adaptador contém regra própria: cada um é um ponteiro de
até ~30 linhas produzido por `scripts/instalar-adaptadores`.

Além disso, adotar o **ledger de premissas** como mecanismo padrão para lacunas de
produto, já que a cliente só é acessível em reunião marcada.

## Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| Cada pessoa configura sua ferramenta | É o estado atual, e é o que produz divergência de padrão sem ninguém discordar |
| Padronizar em Claude Code para todo o time | Nem todos têm acesso; forçar ferramenta não é decisão que o time pode tomar por licença e preferência |
| Duplicar o conteúdo em cada arquivo de ferramenta | Três cópias divergem na segunda semana |
| Copiar o harness corporativo da Theke | Assume ferramenta única, PO acessível e 21 repositórios; aqui são 3 repos e uma turma |

## Instalação: pessoal, sob demanda e local

Os adaptadores **não são versionados**. Cada pessoa roda o instalador escolhendo suas
ferramentas (`-f codex`, `-f claude,copilot`, …), e o script mantém a regra de ignore
em `.git/info/exclude` — que vale só naquele clone.

Motivo: a divergência de ferramenta é real e legítima. Uma pessoa usa Codex, outra
Claude Code, outra Copilot, outra não usa IA nenhuma. Commitar os quatro adaptadores
imporia a todos os arquivos de ferramentas que a maioria não usa; commitar só os de
uma pessoa elegeria uma ferramenta sem decisão do time. E `.gitignore` não resolve:
ele mesmo é versionado, então a regra de ignore viraria o mesmo problema uma camada
acima.

Custo aceito: cada pessoa precisa **regenerar** depois de um pull que mude o harness.
É barato (o script é idempotente) e automatizável — hook `post-merge` local hoje, passo
dos playbooks de desenvolvimento depois.

## Consequências

**Boas:**
- Um padrão muda em um lugar e vale para todas as ferramentas.
- Colega novo tem um caminho só de leitura, qualquer que seja a IA que use.
- O harness vira artefato revisável por PR, como código.
- Os repos ficam limpos: quem não usa IA nunca vê um arquivo de IA.

**Ruins — e aceitas:**
- Adaptador desatualizado é possível: quem esquecer de regenerar após um pull fica com
  um retrato antigo do harness. Mitigação: hook local, e o aviso obrigatório na
  descrição do PR que mexe em `adaptadores/`.
- Copilot não lê arquivo fora do repositório de forma confiável, então o adaptador
  dele **duplica** o essencial. Essa é a única duplicação tolerada, e ela é gerada.
- Regra de ignore em `.git/info/exclude` não é clonada: quem trocar de máquina ou
  reclonar precisa rodar o instalador de novo antes do primeiro `git status`.

## Como reverter

Apagar `creed-ai-context/` e os arquivos gerados. Custo baixo enquanto o conteúdo estiver
todo em Markdown e nada de build depender dele — condição que este ADR pretende manter.
