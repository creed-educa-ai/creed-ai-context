---
description: Relê a tarefa no ClickUp e atualiza a spec já existente
argument-hint: <id-clickup>
model: sonnet
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Atualize a spec da tarefa **$ARGUMENTS** com o que mudou no ClickUp.

Siga `creed-ai-context/workflows/atualizar-spec.md`, no papel de
`creed-ai-context/roles/analista.md`.

<critical>Passo 0 primeiro: confira o MCP `clickup` como manda `creed-ai-context/workflows/tarefa-to-spec.md`. Sem ele autenticado, diga o estado em uma linha e peça o texto novo da tarefa colado — nunca adivinhe o que mudou.</critical>
<critical>Se `creed-ai-context/tarefas/<id>-*/spec.md` não existir, este NÃO é o comando: diga isso e ofereça `/spec <id>`.</critical>
<critical>Compare seção a seção e reescreva SÓ o que mudou. Nada mudou = diga isso e pare, sem tocar em arquivo.</critical>
<critical>Task já marcada como feita e afetada pela mudança: NÃO reescreva o `N_task.md`. Aponte a divergência e deixe a decisão para o humano — vira task nova ou correção.</critical>
<critical>Premissa aberta que a tarefa respondeu vira ✅ confirmada ou ❌ refutada em `creed-ai-context/decisoes/premissas.md`. Refutada vira tarefa de correção no ClickUp. Não apague premissa.</critical>
<critical>NÃO toque em código. Este comando mexe em spec, tasks e ledger — mais nada.</critical>
<critical>Encerre com a lista do que mudou (seção → antes → depois) e o impacto em cada task.</critical>

Saída: `creed-ai-context/tarefas/<id>-<slug>/spec.md` atualizada + resumo do que mudou.
