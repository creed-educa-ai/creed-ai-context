# Workflow: tarefa → spec

## Entrada
Tarefa do ClickUp (ID + descrição, geralmente curta).

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
| 1 | Ler `../CONTEXT.md`, `../catalogo.md`, `../glossario.md` | lê os arquivos | cole `../adaptadores/prompts/00-contexto.md` |
| 2 | Ler o molde do repo afetado (`respondentes`) | abre os arquivos | cole os arquivos-chave |
| 3 | Listar lacunas de produto | — | — |
| 4 | Registrar premissas (`P-NNN`) e seguir | escreve em `../decisoes/premissas.md` | você cola no arquivo |
| 5 | Preencher `spec-template.md` | escreve `../tarefas/<ID>/spec.md` | você salva |
| 6 | Validar contra `../checklists/definition-of-ready.md` | — | — |

## Regra de parada

Se depois do passo 4 restar lacuna que **não dá para transformar em premissa** — porque
qualquer escolha muda o produto de forma cara e irreversível — a tarefa **volta para o
ClickUp como bloqueada** e a pergunta vai para `../pauta/proxima-reuniao.md`. Esse caso é
raro; a maioria das lacunas tem uma escolha barata de reverter.

> Próximo: [`spec-to-tasks.md`](spec-to-tasks.md)
