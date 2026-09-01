# Workflow: tarefa → spec

## Entrada
Tarefa do ClickUp. Com o MCP `clickup` autenticado, o **ID** basta; sem ele, ID +
descrição colada (o caminho de sempre).

## Saída
`../tarefas/<ID>-<slug>/spec.md` — a partir de `../templates/spec-template.md`, com o
bloco de calibragem no cabeçalho.

## Quando pular

Este workflow **não** é obrigatório. Quem decide é a calibragem do passo 3
(`../conventions/profundidade-da-spec.md`): **P1 · T1 não gera spec** — vá direto para
`spec-to-tasks`, ou ao código.

Em sinal observável, P1 · T1 é: toca um repo, fica dentro do molde, não cria
domínio/feature novo, não muda contrato de API, não tem migration, e os critérios de
aceite da tarefa já são verificáveis sem nenhuma interpretação nova.

Bug pequeno, ajuste de texto, componente dentro do molde: pule. Domínio novo, relatório
novo, mudança que o front e o back precisam combinar, regra de quem-pode-o-quê: não pule.

## Princípios

- **Escrever a spec é entender, não documentar.** Se você não consegue escrever a
  seção "Como verificar", ainda não entendeu a tarefa.
- **A profundidade é decidida antes da primeira linha**, não descoberta no meio da
  escrita. Um documento só carrega PRD e techspec ao mesmo tempo; a calibragem P × T é
  o que impede um dos dois lados de sair raso.
- **Sem implementação na spec** além do necessário para dimensionar. Detalhe de
  implementação vive nas tasks — exceto a seção "Abordagem técnica", que só existe em
  T3 e registra a alternativa descartada.
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
| 3 | **Calibrar** P × T pela `../conventions/profundidade-da-spec.md` | `/calibrar <ID>` | cole `../adaptadores/prompts/08-calibrar.md` |
| 4 | P1 · T1? Pare aqui e vá para `spec-to-tasks` | — | — |
| 5 | Listar lacunas de produto | — | — |
| 6 | Registrar premissas (`P-NNN`) e seguir | escreve em `../decisoes/premissas.md` | você cola no arquivo |
| 7 | Preencher `spec-template.md` **só com as seções que a calibragem exige** | escreve `../tarefas/<ID>-<slug>/spec.md` | você salva |
| 8 | Validar contra `../checklists/definition-of-ready.md` | — | — |

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

### Passo 3 — calibrar

Entrada: o texto da tarefa. Ação: as duas tabelas de sinais da régua. Saída verificável:
o bloco de calibragem, com **o sinal citado** em cada eixo — é por ele que o humano
discorda da nota antes de a spec existir, que é quando discordar ainda é barato.

Sem sinal observável na descrição, o caso padrão é **P3 · T2**, dito por escrito. A régua
nunca chuta para baixo: seção a mais custa parágrafo, seção a menos custa retrabalho.

## Regra de parada

Se depois do passo 6 restar lacuna que **não dá para transformar em premissa** — porque
qualquer escolha muda o produto de forma cara e irreversível — a tarefa **volta para o
ClickUp como bloqueada** e a pergunta vai para `../pauta/proxima-reuniao.md`. Esse caso é
raro; a maioria das lacunas tem uma escolha barata de reverter.

> Próximo: [`spec-to-tasks.md`](spec-to-tasks.md)
