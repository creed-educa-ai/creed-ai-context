---
description: Calibra a profundidade da spec de uma tarefa (eixos produto × técnico)
argument-hint: <id-clickup> [descrição — só se o MCP do ClickUp não estiver ligado]
model: haiku
allowed-tools: Read, Grep, Glob, mcp__clickup__clickup_get_task, mcp__clickup__clickup_search
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai calibrar a tarefa **$ARGUMENTS**: decidir a **profundidade** da spec. Você não
escreve a spec.

Régua: `creed-ai-context/conventions/profundidade-da-spec.md`.
Formato da saída: o bloco "Calibragem" de `creed-ai-context/templates/spec-template.md`.

Passos:

1. Obtenha o texto da tarefa. Ferramentas `mcp__clickup__*` na sessão: busque pelo ID.
   Não estão: peça a descrição colada e siga — nunca invente o conteúdo da tarefa.
2. Leia `creed-ai-context/catalogo.md` para saber o que é molde e o que é domínio/feature
   que ainda não existe.
3. Classifique o eixo P e o eixo T pelas tabelas da régua.
4. Imprima o bloco de calibragem preenchido, com a lista de seções exigidas e dispensadas.

<critical>Você NÃO cria nem edita arquivo. A saída é o bloco impresso na conversa; quem grava é o `/spec`.</critical>
<critical>Cada nível cita o SINAL OBSERVADO na tarefa que o decidiu — a frase da descrição, o repo, a migration. Sinal citado é o que permite ao humano discordar da nota. "Parece complexa" não é sinal.</critical>
<critical>Um sinal do nível maior basta; os eixos não são média. Empate ou dúvida: fica o MAIOR e diga qual sinal decidiu.</critical>
<critical>Nenhum sinal observável na descrição: **P3 · T2**, e escreva "sem sinal observável na tarefa". Não invente sinal para justificar nota mais baixa.</critical>
<critical>Resultado **P1 · T1**: diga que a spec é desnecessária e mande para `/tasks`. Não gere spec por burocracia.</critical>

Saída: bloco de calibragem impresso. Próximo passo: `/spec <ID>`.
