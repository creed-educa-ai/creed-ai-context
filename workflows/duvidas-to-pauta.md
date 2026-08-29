# Workflow: dúvidas → pauta da reunião

> O contraponto de `premissas-e-duvidas`. Registrar premissa só funciona se elas
> **voltarem** para a cliente. Este workflow é o retorno.

## Quando rodar
Antes de cada reunião com a cliente. Leva uns 10 minutos.

## Entrada
`../decisoes/premissas.md` (ledger) + dúvidas bloqueantes das specs em `tarefas/`.

## Saída
`../pauta/proxima-reuniao.md` — a partir de `../templates/pauta-cliente-template.md`.

## Passos

1. **Coletar** todas as premissas com status aberta.
2. **Agrupar por assunto** — cinco perguntas sobre relatório viram um bloco, não cinco
   itens soltos.
3. **Ordenar por custo de reverter**, decrescente. O tempo da reunião acaba antes da
   lista; o que já está feito e é caro de desfazer vai primeiro.
4. **Reescrever para a cliente.** Ela não lê `P-007` nem sabe o que é `service.py`.
   Cada item vira três frases:
   - o que o time entendeu e já fez — "hoje o relatório considera só respondentes
     ativos";
   - a pergunta fechada — "está certo, ou inativos entram também?";
   - o custo da troca — "mudar agora: 1 dia; depois do próximo entregável: 3 dias".
5. **Cortar** o que não precisa dela — dúvida técnica não vai para a pauta.
6. **Limitar a 5–7 itens.** O resto fica no ledger para a próxima.

## Depois da reunião

1. Registrar o desfecho de cada premissa no ledger: confirmada, refutada ou segue
   aberta.
2. Premissa **refutada** vira tarefa no ClickUp, com o custo estimado.
3. Premissa **confirmada** vira regra: some o marcador dos artefatos e, quando for
   termo de domínio, atualize o `../glossario.md`.
4. Arquive a pauta como `../pauta/YYYY-MM-DD.md`.

Premissa fechada **fica no ledger** com o desfecho. É o que evita rediscutir a mesma
coisa na sprint seguinte.
