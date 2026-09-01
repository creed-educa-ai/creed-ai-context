---
description: Transforma uma tarefa do ClickUp em spec (tarefas/<ID>/spec.md)
argument-hint: <id-clickup> [descrição — só se o MCP do ClickUp não estiver ligado]
model: sonnet
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai transformar a tarefa **$ARGUMENTS** em uma spec.

Siga `creed-ai-context/workflows/tarefa-to-spec.md`, no papel de
`creed-ai-context/roles/analista.md`.

<critical>Leia ANTES de escrever: `creed-ai-context/CONTEXT.md`, `creed-ai-context/catalogo.md`, `creed-ai-context/glossario.md` e o molde do repo afetado (`respondentes`).</critical>
<critical>Comece pelo passo 0 do workflow: confira o MCP `clickup`. Se as ferramentas `mcp__clickup__*` não estiverem na sessão, rode `claude mcp get clickup` UMA vez, da raiz do workspace, e classifique pela tabela do passo 0 — registrado sem OAuth: diga em uma linha para abrir `/mcp` e autenticar; não registrado: diga o comando do setup. Nos dois casos, peça a descrição colada e siga. Nunca invente o conteúdo da tarefa, nunca bloqueie a spec por causa do MCP e nunca tente autenticar sozinho.</critical>
<critical>Passo 3 do workflow: calibre P × T por `creed-ai-context/conventions/profundidade-da-spec.md` ANTES de escrever. A calibragem decide QUAIS seções existem — escreva só elas, e grave o bloco no cabeçalho da spec, com o sinal observado em cada eixo. Se a sessão já trouxe uma calibragem do `/calibrar`, use aquela em vez de refazer.</critical>
<critical>Resultado **P1 · T1**: a spec é desnecessária. Diga isso e vá direto para `/tasks` em vez de gerar spec por burocracia.</critical>
<critical>Lacuna de produto NÃO vira pergunta pendurada: vira premissa em `creed-ai-context/decisoes/premissas.md`, com marcador no artefato, e a spec continua. A cliente só é acessível em reunião marcada.</critical>
<critical>Use `creed-ai-context/templates/spec-template.md`. Seção que a calibragem dispensou é APAGADA, não preenchida com "N/A".</critical>
<critical>Valide contra `creed-ai-context/checklists/definition-of-ready.md` antes de encerrar.</critical>

Saída: `creed-ai-context/tarefas/<id>-<slug>/spec.md`
