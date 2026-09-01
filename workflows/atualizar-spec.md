# Workflow: atualizar a spec (a tarefa mudou no ClickUp)

> **Fluxo manual, sob demanda.** A AGES IV avisa que mexeu na tarefa — critério novo,
> escopo alterado, campo acrescentado — e o dev roda `/atualizar-spec <ID>`. Ninguém
> fica sondando o ClickUp: quem sabe que mudou é gente, não automação.

## Entrada
ID da tarefa + `../tarefas/<ID>-<slug>/spec.md` já existente.

## Saída
A mesma `spec.md` atualizada, o que mudou dito em lista curta na resposta, e o impacto
apontado nas tasks e no ledger de premissas. **Sem tocar em código.**

## Quando NÃO é este workflow

| Situação | Vá para |
|---|---|
| ainda não existe spec | `tarefa-to-spec.md` |
| quem mudou de ideia foi o time, não a tarefa | edite a spec e registre premissa (`../conventions/premissas-e-duvidas.md`) |
| a mudança já está implementada e você só quer conferir | `revisao.md` |

## Passos

| # | Passo | Modo agente | Modo copiloto |
|---|---|---|---|
| 0 | Conferir o MCP — passo 0 de [`tarefa-to-spec.md`](tarefa-to-spec.md) | busca a tarefa pelo ID | você cola o texto novo da tarefa |
| 1 | Ler a spec atual inteira | lê | cole a spec |
| 2 | Comparar seção a seção: Problema · Escopo · Contrato · Dados · Critérios de aceite | — | — |
| 3 | Nada mudou? diga isso e **pare** | — | — |
| 4 | Reescrever **só** as seções que mudaram | edita `spec.md` | você aplica |
| 5 | Cruzar com as tasks (tabela abaixo) | lê `tasks.md` e os `N_task.md` | você confere |
| 6 | Cruzar com o ledger de premissas (tabela abaixo) | edita `../decisoes/premissas.md` | você aplica |
| 7 | Revalidar contra `../checklists/definition-of-ready.md` | — | — |

## Impacto nas tasks

| Situação da task | O que fazer |
|---|---|
| não começou | ajuste o `N_task.md` junto com a spec |
| em andamento | ajuste e **diga em uma linha o que mudou embaixo dos pés** de quem está nela |
| já marcada como feita | **não reescreva**: aponte a divergência e deixe a decisão para o humano — vira task nova ou correção |

Critério de aceite que mudou depois da task feita é o caso mais caro: ele muda o que a
review vai cobrar. Diga isso explicitamente em vez de ajustar o texto e seguir.

## Impacto nas premissas

Mudança na tarefa costuma ser resposta a premissa aberta:

| O que a tarefa passou a dizer | No ledger |
|---|---|
| o mesmo que você tinha suposto | ✅ confirmada — some o marcador do artefato |
| o contrário | ❌ refutada → vira tarefa de correção no ClickUp |
| nada sobre o assunto | 🟡 segue aberta, e continua na pauta |

Ciclo completo em [`../conventions/premissas-e-duvidas.md`](../conventions/premissas-e-duvidas.md).

## Regras

- **Idempotente.** Rodar duas vezes sem mudança no ClickUp não altera arquivo nenhum.
- **Não apague decisão registrada.** Premissa vira confirmada ou refutada; nunca some.
- **Diga o que mudou**, em lista curta — é o que o dev leva para a review e para o PR.
- **Não toca em código.** Código muda por task, em [`tasks-to-code.md`](tasks-to-code.md).
- **Sem MCP autenticado**, o dev cola o texto novo da tarefa. Mesma regra do passo 0:
  a IA avisa o estado em uma linha, pede o texto e segue — não bloqueia e não adivinha.

> Próximo: [`spec-to-tasks.md`](spec-to-tasks.md), se a mudança criou task nova.
