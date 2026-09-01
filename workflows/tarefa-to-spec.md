# Workflow: tarefa → spec

## Entrada
Tarefa do ClickUp. Com o MCP `clickup` autenticado, o **ID** basta; sem ele, ID +
descrição colada (o caminho de sempre).

## Saída
`../tarefas/<ID>-<slug>/spec.md` — a partir de `../templates/spec-template.md`.

## Quando pular

Este workflow **não** é obrigatório. Pule e vá direto para `spec-to-tasks` (ou direto
ao código) quando **todas** valerem:

- toca **um** repo;
- cabe em **um** PR;
- não cria domínio/feature novo, não muda contrato de API, não tem migration;
- os critérios de aceite da tarefa já são verificáveis.

Bug pequeno, ajuste de texto, componente dentro do molde: pule. Domínio novo,
relatório novo, mudança que o front e o back precisam combinar: não pule.

## Princípios

- **Escrever a spec é entender, não documentar.** Se você não consegue escrever a
  seção "Como verificar", ainda não entendeu a tarefa.
- **Sem implementação na spec** além do necessário para dimensionar. Detalhe de
  implementação vive nas tasks.
- **Lacuna vira premissa, não pergunta pendurada.** A cliente não está disponível
  (`../conventions/premissas-e-duvidas.md`).
- **Espelhamento explícito.** Se toca back e front, a spec diz o nome do domínio e da
  feature — os dois iguais.

## Passos

| # | Passo | Modo agente | Modo copiloto |
|---|---|---|---|
| 0 | Conferir o MCP e obter o texto da tarefa | ver abaixo | você cola a descrição |
| 1 | Ler `../CONTEXT.md`, `../catalogo.md`, `../glossario.md` | lê os arquivos | cole `../adaptadores/prompts/00-contexto.md` |
| 2 | Ler o molde do repo afetado (`respondentes`) | abre os arquivos | cole os arquivos-chave |
| 3 | Listar lacunas de produto | — | — |
| 4 | Registrar premissas (`P-NNN`) e seguir | escreve em `../decisoes/premissas.md` | você cola no arquivo |
| 5 | Preencher `spec-template.md` | escreve `../tarefas/<ID>/spec.md` | você salva |
| 6 | Validar contra `../checklists/definition-of-ready.md` | — | — |

### Passo 0 — conferir o MCP antes de contar com ele

O MCP `clickup` é atalho, não dependência. A conferência é uma só, no começo:

1. As ferramentas `mcp__clickup__*` já estão disponíveis na sessão? Então está
   autenticado: busque a tarefa pelo ID e siga para o passo 1.
2. Não estão? Rode **uma vez**, da raiz do workspace (o registro é de escopo local,
   por diretório):

```bash
claude mcp get clickup
```

| Saída | Estado | O que fazer |
|---|---|---|
| `Status: ✔ Connected` | pronto | busque a tarefa pelo ID |
| `Status: ! Needs authentication` | registrado, falta OAuth | avise em uma linha — "abra `/mcp`, escolha `clickup` e autentique" — e siga pelo modo copiloto |
| erro, ou servidor não encontrado | não registrado | avise o comando de registro (abaixo) e siga pelo modo copiloto |

```bash
bash creed-ai-context/scripts/setup-workspace.sh --sem-clone --sem-deps
```

Regras da conferência:

- **Uma vez, sem laço.** O comando só informa o estado; repetir não muda nada.
- **Você não autentica.** `/mcp` é interativo e é o humano que faz — a IA avisa e segue.
- **Nunca bloqueie a spec por isto.** Sem MCP, peça a descrição da tarefa e continue;
  é o fluxo que sempre existiu e continua sendo o caminho oficial.
- **Falhou no meio** — fora do ar, limite de chamadas estourado — pare na primeira
  falha, diga qual foi e peça a descrição. Não preencha a spec com o que a tarefa
  "provavelmente" pede.

## Regra de parada

Se depois do passo 4 restar lacuna que **não dá para transformar em premissa** — porque
qualquer escolha muda o produto de forma cara e irreversível — a tarefa **volta para o
ClickUp como bloqueada** e a pergunta vai para `../pauta/proxima-reuniao.md`. Esse caso é
raro; a maioria das lacunas tem uma escolha barata de reverter.

> Próximo: [`spec-to-tasks.md`](spec-to-tasks.md)
