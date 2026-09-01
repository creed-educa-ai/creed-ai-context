# ADR-0002 — MCP do ClickUp registrado pelo setup, autenticação opcional

- **Status:** Proposto
- **Data:** 2026-09-01
- **Decidem:** time CREED

## Contexto

O pipeline começa numa tarefa do ClickUp, mas o harness sempre assumiu **cópia-e-cola**:
`workflows/tarefa-to-spec.md` declara a entrada como "ID + descrição" e o `/spec` recebe
os dois. Quem esquece de colar a descrição inteira produz spec a partir de meia tarefa,
e ninguém percebe — o modelo preenche o resto com o que parece plausível.

A ClickUp publicou um servidor MCP oficial (`https://mcp.clickup.com/mcp`, beta público,
OAuth 2.1, todos os planos). Com ele o `/spec <ID>` busca a tarefa sozinho.

Dois fatos limitam o entusiasmo:

- **Limite de chamadas.** Sem o add-on Everything AI são 50 chamadas/24h no plano Free e
  300/24h no Unlimited+, em janela deslizante e sem reset. Não sabemos ainda qual é o
  plano do workspace da AGES nem se o limite é por pessoa ou por workspace — e somos
  nove.
- **Beta.** O contrato das ferramentas pode mudar sem aviso.

## Decisão

Registrar o MCP `clickup` no Claude Code **durante o `setup-workspace`** (etapa 7,
escopo local, só no workspace do CREED) e deixar a **autenticação por conta de cada
pessoa**, no `/mcp`. O harness passa a citar o MCP como **atalho do passo 0** do
`tarefa-to-spec`, com o fluxo colado como caminho declarado de fallback.

Nenhuma etapa do pipeline passa a depender do MCP. Falha de MCP — sem OAuth, fora do ar,
limite estourado — para na hora, diz o erro e pede a descrição.

**O MCP mora num lugar só: o passo de especificação.** `tarefa-to-spec.md` (e o
`atualizar-spec.md`, que é o mesmo passo rodado de novo) são os únicos workflows que
falam com o ClickUp. Depois deles, a spec é a fonte: `spec-to-tasks` lê a spec,
`tasks-to-code` lê a task. `tasks-to-code` ganhou um portão — sem spec e sem tasks,
para e volta para a especificação, pedindo o ID.

Como a tarefa muda no ClickUp depois da spec escrita, existe `/atualizar-spec <ID>`:
fluxo manual, disparado quando a AGES IV avisa que mexeu na tarefa. Ele compara,
reescreve só o que mudou, aponta o impacto nas tasks e fecha as premissas que a
mudança respondeu.

## Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| Esperar medir o consumo antes de mexer no harness | O custo de esperar é maior que o de tentar: sem o registro no setup ninguém experimenta, e o fallback já é o fluxo atual |
| Deixar cada workflow buscar o que precisa no ClickUp | Multiplica pontos de falha e chamadas; a spec já materializa necessidade e critério — depois dela, ler o ClickUp de novo é ler duas verdades |
| Tornar o MCP obrigatório no `/spec` | Quebraria quem usa Codex, Copilot ou não tem plano com folga de chamadas — e contraria o ADR-0001 |
| Deixar cada pessoa registrar na mão | É o que produz divergência silenciosa; o setup existe justamente para isso não acontecer |
| Registrar também nas outras ferramentas | Codex e Cursor leem MCP, mas cada um com formato próprio. Fica para quando alguém do time usar de fato |
| Automatizar o OAuth no script | Não dá: é fluxo de navegador. Forçar viraria token em arquivo, que o `CONTRIBUTING` proíbe |

## Consequências

**Boas:**
- `/spec <ID>` sem colar descrição, para quem autenticar — e sem tarefa lida pela metade.
- O registro é idempotente e vale só neste workspace: nada vaza para outros projetos.
- Quem não autenticar não perde nada; o caminho colado continua documentado e testado.

**Ruins — e aceitas:**
- Duas maneiras de obter a mesma entrada. Mitigação: o passo 0 do workflow diz qual vale
  em cada modo, e o fallback é explícito.
- ~40 descrições de ferramenta entram no contexto de toda sessão do Claude Code no
  workspace, para ganho em um comando. Se pesar, o próximo passo é `allowed-tools` nos
  comandos que não usam o MCP.
- Dependência de um beta de terceiro dentro do caminho feliz do pipeline.
- O limite de chamadas ainda não foi medido. Primeiro `/spec` real com MCP deve reportar
  quantas chamadas gastou; se estourar com nove pessoas, esta decisão volta à mesa.

## Como reverter

`claude mcp remove clickup -s local` em cada máquina, apagar a etapa 7 dos dois
`setup-workspace` e a linha 0 da tabela de passos do `tarefa-to-spec`. O fluxo colado
não foi removido em nenhum momento, então não há nada a restaurar.
