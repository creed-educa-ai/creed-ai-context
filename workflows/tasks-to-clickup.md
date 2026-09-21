# Workflow: tasks → ClickUp

Leva o que foi especificado no harness para o board: a **descrição do épico** em
linguagem de produto e as **subtarefas** que saíram da decomposição — reescritas para
quem vai ler, não copiadas de `N_task.md`.

## Entrada

`../tarefas/<ID>-<slug>/` com, no mínimo, `tasks.md`. Mais o **ID do épico no ClickUp**
— que é o mesmo `<ID>` da pasta, porque a tarefa já existe lá desde o começo do pipeline.

## Saída

1. `../tarefas/<ID>-<slug>/clickup.md` — o rascunho publicável e o mapa de publicação.
   É ele que o humano lê antes de qualquer chamada de escrita, e é dele que sai a
   idempotência da segunda rodada.
2. **Depois do ok humano:** descrição do épico atualizada e subtarefas criadas ou
   atualizadas no ClickUp, com o ID de cada uma gravado de volta no `clickup.md`.

Template: `../templates/clickup-epico-e-subtarefas.md`.
Conferência: `../checklists/tarefa-nivelada.md`.

## Por que em duas etapas

Rascunho primeiro, publicação depois, sempre — mesmo com o MCP ligado e pressa:

- **O board é compartilhado.** Subtarefa errada no ClickUp incomoda nove pessoas; linha
  errada no `clickup.md` incomoda quem está escrevendo.
- **Chamada de MCP é recurso escasso** (ADR-0002: 50/24h no plano Free) e a escrita
  gasta uma por subtarefa.
- **O humano é o portão** (`../CONTEXT.md` → "Como a IA trabalha aqui"). Aprovar uma
  tabela de 8 linhas é barato; desfazer 8 subtarefas não é.

Escrever no ClickUp é o segundo ponto de contato do harness com a ferramenta, e existe
por decisão registrada:
[`ADR-0008`](../decisoes/adrs/0008-publicacao-de-tasks-no-clickup.md). A **leitura**
continua morando só no passo de especificação.

## Portão de entrada

Antes do passo 1, olhe `../tarefas/<ID>-<slug>/`:

| O que existe lá | O que fazer |
|---|---|
| `tasks.md` (com ou sem os `N_task.md`) | siga para o passo 1 |
| só `spec.md` | rode [`spec-to-tasks.md`](spec-to-tasks.md) e volte |
| nada, ou a pasta não existe | **pare**: peça o ID e rode [`tarefa-to-spec.md`](tarefa-to-spec.md) |

Publicar subtarefa a partir da descrição solta da tarefa é o que este portão evita: sem
decomposição escrita, o que vai para o board é chute com cara de plano.

## Portão do MCP

Mesma conferência do passo 0 de [`tarefa-to-spec.md`](tarefa-to-spec.md) — uma vez, sem
laço, e **você não autentica**. A diferença é o que acontece quando falta:

| Estado do MCP | O que fazer |
|---|---|
| ferramentas `mcp__clickup__*` na sessão | fluxo inteiro, passos 1 a 8 |
| registrado sem OAuth, ou fora do ar | escreva o `clickup.md` (passos 1, 3, 4), diga em uma linha como autenticar e **pare no passo 5**: o arquivo é colável no ClickUp à mão |
| limite de chamadas estourado no meio | pare na primeira falha, diga qual foi a última subtarefa publicada e mande rodar de novo depois — o passo 3 não duplica |

## Os três leitores

Toda subtarefa é escrita para os três **ao mesmo tempo**. É isto que "tarefa nivelada"
quer dizer, e é contra isto que o checklist confere:

| Quem lê | O que precisa achar sem perguntar a ninguém |
|---|---|
| Quem não está no tema — cliente, professor, colega de outra frente | os dois primeiros blocos: o que muda no produto e para quem |
| Dev que **não** usa o harness nem IA | arquivos, métodos, o que reusar, contrato, comando de teste — literais, na própria tarefa |
| Dev que usa o harness | o bloco "Rastreio", no fim, apontando a spec e o `N_task.md` |

**Regra de ouro:** nenhuma frase da subtarefa pode pressupor que a pessoa leu o
`creed-ai-context`. Referência ao harness ou vira texto expandido dentro da tarefa, ou
vira material anexado — nunca vira "veja lá".

## A tradução

`N_task.md` é nota técnica entre quem já combinou o contexto. A subtarefa do ClickUp é
documento público. Traduzir é **acrescentar o porquê e o para quem** sem perder o
recorte técnico — não é resumir, e não é enfeitar.

O que traduz e o que **não** traduz:

| Bloco da task | Tratamento |
|---|---|
| Objetivo, critérios de aceite | vira prosa de produto: o que muda para quem usa |
| Molde, convenção, premissa | vira frase explicada, com o motivo — sem o jargão |
| Arquivos, métodos, rotas, comandos, nomes de classe | **copia literal.** Caminho não vira prosa |
| Contrato de endpoint | tabela, com entrada, saída e os códigos de erro |
| O que reusar | nome + caminho do que já existe, nunca "aproveite o que tem" |
| Calibragem (P×T), numeração de task, vocabulário do harness | não vai para o board |

Exemplos do corte — a coluna da direita é o que vai para o ClickUp:

| `N_task.md` diz | A subtarefa diz |
|---|---|
| "Agregação em SQL (`COUNT` + `GROUP BY`), não em Python." | "A contagem por organização é feita pelo banco, não pelo código que monta a resposta — é o que segura o tempo de tela quando o número de respondentes crescer. Na prática: `COUNT` + `GROUP BY` na consulta do `repository.py`, e nenhum laço somando em Python." |
| "Organização sem respondente vem com zeros (LEFT JOIN), não some." | "Uma organização que ainda não tem ninguém respondendo precisa aparecer no relatório zerada. Sumir da lista é pior que aparecer com zero, porque quem lê não sabe se é falha do sistema. Tecnicamente: `LEFT JOIN` em vez de `JOIN`." |
| "Molde: `app/domains/users/`." | "Já existe um domínio pronto com exatamente esta divisão de camadas — `app/domains/users/` no `creed-backend`. Copie a forma dele (mesmos arquivos, mesma injeção de dependência); **os campos, não** — aqueles são de exemplo." |
| "Premissas aplicáveis: P-012." | "Decidimos, sem confirmar com a cliente, que respondente inativo continua contando no total. Se estiver errado, muda só a cláusula `WHERE` da consulta." |
| "P2 · T3, spec calibrada." | nada — calibragem é vocabulário interno |

## Os materiais para anexar

A tarefa fica nivelada quando o material que ela cita **está junto dela**. Esta é a parte
que a automação não faz sozinha: ela **lista e cobra**; quem publica — AGES III/IV —
anexa.

Gatilho → material, conferido por subtarefa:

| Se a subtarefa fala de | Anexe / linke |
|---|---|
| endpoint, request, response | o documento de contrato da tarefa (ex.: `contrato-api.md`) |
| tela, fluxo, navegação | protótipo no Figma (link) ou o PDF do mock |
| coluna, tabela, migration | o recorte do dbdiagram e/ou `context/modelo-de-dados.dbml` |
| "copie a forma de X" | **permalink do arquivo no GitHub**, não o nome da pasta |
| premissa `P-NNN` | o texto da premissa colado na tarefa — o ID sozinho não é material |
| decisão de arquitetura | link do ADR |
| termo do domínio (prisma, prognóstico, respondente) | a definição colada, de `../glossario.md` |
| serviço externo (Keycloak, N8N) | link da doc + o que já está de pé no `docker-compose` local |

Duas regras sem exceção:

- **Anexo pendente nunca vira anexo imaginário.** Enquanto o material não está lá, a
  linha fica `⬜ falta anexar — <quem>`. A tarefa nunca diz "veja o anexo" para arquivo
  que ninguém subiu.
- **A automação não anexa por conta própria.** Ela lista; subir arquivo para o board é
  ação humana, arquivo por arquivo, a pedido explícito.

### Quando o pedido explícito vier

Use `clickup_request_attachment_upload` — **não** `clickup_attach_task_file`. O segundo
exige o arquivo em base64 dentro da própria chamada; o primeiro devolve um tíquete e a
URL, e o arquivo sobe por HTTP sem passar pelo contexto.

| Passo | O quê |
|---|---|
| 1 | Um tíquete por par arquivo × subtarefa. Quatro subtarefas recebendo o mesmo arquivo são quatro tíquetes |
| 2 | `POST` multipart para a URL devolvida, com o tíquete no cabeçalho `X-Upload-Ticket` e o arquivo no campo `attachment` |
| 3 | Deu certo quando a resposta traz `"id"`. Qualquer outra coisa: **pare na primeira falha** e diga qual arquivo era |
| 4 | **Anexou? Corrija a descrição.** A linha `⬜ falta anexar` vira `✅ anexado`, com o nome que o arquivo ganhou no board — senão a tarefa passa a mentir ao contrário |

Três detalhes que custam tempo:

- **No Windows, converta o caminho com `cygpath -m` antes do `curl`.** O `curl` do
  Git Bash é build Windows e não lê caminho `/c/...`; o erro é
  `curl: (26) Failed to open/read local data from file/application`, que não diz nada
  sobre o formato do caminho.
- **Nomeie com prefixo da tarefa** (`creed-23-contrato-api.md`). No board o anexo perde
  a pasta de origem, e dois `README.md` soltos não se distinguem.
- **O tíquete expira.** Pedir todos de uma vez e subir depois funciona, mas se demorar,
  peça de novo em vez de insistir no tíquete velho.

## Passos

| # | Passo | Entrada | Saída verificável |
|---|---|---|---|
| 0 | Portão de entrada e portão do MCP (acima) | a pasta `../tarefas/<ID>-<slug>/` | segue, ou para dizendo o quê |
| 1 | Ler `spec.md`, `tasks.md` e todo `N_task.md` que existir | a pasta | lista numerada: entrega, repo, depende de |
| 2 | Ler o que já está no ClickUp — `clickup_get_task` com `include: ["description","subtasks"]` | `<ID>` | descrição atual do épico + subtarefas existentes |
| 3 | Montar o **mapa de publicação** pela tabela de correspondência (abaixo) | passos 1 × 2 | tabela com uma ação por linha: criar / atualizar / deixar |
| 4 | Escrever `clickup.md` pelo template, com épico, subtarefas e materiais | passos 1 e 3 | arquivo em `../tarefas/<ID>-<slug>/clickup.md` |
| 5 | **Apresentar o mapa e a lista de materiais. Esperar aprovação.** | passo 4 | um "ok" explícito, ou correção |
| 6 | Publicar: `clickup_update_task` no épico; `clickup_create_task` com `parent: <ID>` por subtarefa nova; `clickup_update_task` nas que mudaram | `clickup.md` | IDs devolvidos, gravados na coluna "ID" do `clickup.md` |
| 7 | Conferir contra `../checklists/tarefa-nivelada.md` | as subtarefas publicadas | veredito, item a item |
| 8 | Encerrar: link de cada subtarefa + **a tabela do que falta anexar, com dono** | passos 6 e 7 | mensagem final ao humano |

Use `markdown_description` — não `description` — nas duas ferramentas de escrita: a
tarefa tem tabela e bloco de código, e em texto puro elas viram sopa.

## Correspondência — o que impede duplicar

Toda subtarefa publicada termina com a linha de rastreio, e é ela a chave:

```
Rastreio: <ID>/<N> — creed-ai-context/tarefas/<ID>-<slug>/<N>_task.md
```

| Situação no passo 3 | Ação |
|---|---|
| Entrega `N` do `tasks.md` **sem** subtarefa com `Rastreio: <ID>/N` | **criar** |
| Tem subtarefa com o rastreio, e o texto gerado difere do publicado | **atualizar** (`clickup_update_task`) |
| Tem subtarefa com o rastreio, texto idêntico | **deixar como está** — não gasta chamada |
| Subtarefa no ClickUp **sem** rastreio, ou com rastreio que sumiu do `tasks.md` | **não toque.** Reporte a linha ao humano e siga — pode ser tarefa criada à mão |

Rodar o workflow duas vezes na mesma pasta não cria subtarefa repetida, não duplica
seção na descrição do épico e não reescreve o que não mudou. Se a segunda rodada muda
alguma coisa que não deveria, o defeito é aqui.

## Regra de parada

Se, ao traduzir uma entrega, o bloco "O que muda para quem usa" só puder ser escrito
inventando comportamento de produto que não está na spec nem em premissa: **pare**.
Registre a premissa (`../conventions/premissas-e-duvidas.md`), marque o artefato e
continue. Subtarefa publicada com produto inventado é pior que subtarefa faltando — ela
parece acordada.

> Vem de: [`spec-to-tasks.md`](spec-to-tasks.md) · Próximo: [`tasks-to-code.md`](tasks-to-code.md)
