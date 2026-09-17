# ADR-0008 — publicação de épico e subtarefas no ClickUp, com rascunho e aprovação

- **Status:** Proposto
- **Data:** 2026-09-17
- **Decidem:** time CREED
- **Relacionado:** [ADR-0002](0002-mcp-do-clickup-no-setup.md) — que esta decisão emenda

## Contexto

O [ADR-0002](0002-mcp-do-clickup-no-setup.md) registrou o MCP do ClickUp como atalho de
**leitura**, e fechou o ponto de contato em um lugar só: "`tarefa-to-spec.md` (e o
`atualizar-spec.md`, que é o mesmo passo rodado de novo) são os únicos workflows que
falam com o ClickUp". Depois deles, a spec é a fonte. A regra vale, e o motivo dela
também: cada workflow buscando o que precisa multiplica pontos de falha, gasta chamada
e cria duas verdades sobre a mesma tarefa.

Só que o pipeline tem uma volta que o 0002 não cobriu. A decomposição do épico acontece
**no harness** — `spec-to-tasks` produz `tasks.md` e os `N_task.md` —, e quem vai
implementar pega trabalho **no board**. Hoje essa passagem é manual, e três coisas
acontecem com ela:

- **A tradução se perde.** `N_task.md` é nota entre quem já combinou o contexto:
  "molde: `respondentes`", "agregação em SQL, não em Python", "premissas: P-012". Colado
  no ClickUp, isso não nivela ninguém — nem o colega que não usa o repositório de
  contexto, nem a cliente, nem o professor.
- **Ou se perde o oposto.** Quem reescreve para linguagem natural costuma jogar fora o
  recorte técnico — arquivos, métodos, contrato do endpoint, o que reusar — e a
  subtarefa vira desejo.
- **O material fica solto.** Contrato, mock, recorte do modelo de dados e o texto das
  premissas existem, mas em outro repositório. Quem lê a tarefa não sabe que existem,
  e quem publicou não sabe que precisava anexar.

O resultado é a AGES III/IV reescrevendo oito subtarefas à mão a cada épico, com
qualidade que varia por pessoa e por dia.

## Decisão

**Abrir um segundo ponto de contato com o ClickUp, só de escrita, só no fim da
decomposição, e sempre com aprovação humana entre o rascunho e a publicação.**

Concretamente:

1. Nasce o workflow [`workflows/tasks-to-clickup.md`](../../workflows/tasks-to-clickup.md),
   acionado pela skill `publicar-no-clickup`. Entrada: `tarefas/<ID>-<slug>/tasks.md`.
2. Ele roda **em duas etapas**. A primeira é offline e escreve
   `tarefas/<ID>-<slug>/clickup.md` — o rascunho publicável e o mapa de publicação. A
   segunda só acontece depois de um "ok" explícito, e é a única que chama o MCP para
   escrever.
3. A escrita usa duas ferramentas e mais nenhuma: `clickup_update_task` na descrição do
   épico e `clickup_create_task` com `parent` nas subtarefas. **Nada é apagado** — nem
   subtarefa, nem anexo, nem comentário.
4. A idempotência é uma linha `Rastreio: <ID>/<N>` no fim de cada descrição publicada.
   Segunda rodada compara por ela: cria o que falta, atualiza o que mudou, não toca no
   que está igual, e **não encosta** em subtarefa que alguém criou à mão.
5. **Anexar arquivo continua sendo humano.** A automação lista o material que cada
   subtarefa exige, marca o que falta com dono e cobra na mensagem final. Não sobe
   arquivo para o board por conta própria.

A **leitura** continua exatamente como o 0002 deixou: só no passo de especificação.
`spec-to-tasks` e `tasks-to-code` seguem sem falar com o ClickUp.

## Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| Manter tudo manual, como está | É o problema. A tradução varia por pessoa, e o material anexo depende de alguém lembrar |
| Gerar só o `clickup.md` e nunca escrever no board | Metade do ganho: a cópia-e-cola de oito descrições longas é justamente onde a formatação quebra e onde o cansaço corta seção |
| Publicar direto, sem rascunho nem aprovação | O board é compartilhado e a escrita não tem desfazer barato. Além disso gasta chamada antes de alguém ter lido |
| Publicar dentro do próprio `spec-to-tasks` | Junta duas decisões numa só execução: aprovar a decomposição e aprovar o texto público. Quando as duas vêm juntas, a segunda não é lida |
| Deixar a automação anexar os materiais | Upload em board compartilhado é ação de fora; e a versão do material que vale é julgamento de quem publica, não do modelo |
| Sincronizar nos dois sentidos (ClickUp ↔ harness) | Cria as duas verdades que o 0002 evitou. Mudança na tarefa continua entrando por `/atualizar-spec` |

## Consequências

**Boas:**

- A subtarefa passa a ser legível por quem não está imerso no tema **sem** perder
  arquivos, métodos e contrato — os dois públicos no mesmo documento.
- O material necessário vira lista com dono, dentro da própria tarefa. "Falta o mock"
  deixa de ser descoberta do dia da implementação.
- A AGES III/IV para de reescrever oito descrições por épico.
- Rodar de novo é barato e seguro: só o que mudou vai.

**Ruins — e aceitas:**

- Segundo ponto de contato com um beta de terceiro, agora **escrevendo**. Mitigação:
  duas ferramentas só, nenhuma remoção, aprovação humana antes de qualquer chamada.
- Mais consumo do limite de chamadas, na etapa em que ele dói mais (uma por subtarefa).
  Mitigação: o passo de correspondência não reescreve o que está igual.
- O texto público pode divergir do `N_task.md` quando alguém edita direto no ClickUp. A
  divergência é reportada, não resolvida — decidir é humano.
- Uma terceira maneira de uma tarefa mudar de forma (edição no board). Se isso virar
  confusão recorrente, esta decisão volta à mesa.

## Como reverter

Apagar `workflows/tasks-to-clickup.md`, `templates/clickup-epico-e-subtarefas.md`,
`checklists/tarefa-nivelada.md` e
`adaptadores/claude/skills/publicar-no-clickup/`, rodar
`scripts/instalar-adaptadores.sh` e restaurar a frase original do ADR-0002. Os
`clickup.md` já gerados viram documento morto no repositório, e o que foi publicado no
board fica — nada precisa ser desfeito lá.
