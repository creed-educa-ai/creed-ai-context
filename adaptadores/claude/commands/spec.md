---
description: Transforma uma tarefa do ClickUp em spec (tarefas/<ID>/spec.md)
argument-hint: <id-clickup> [descrição da tarefa]
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai transformar a tarefa **$ARGUMENTS** em uma spec.

Siga `creed-ai-context/workflows/tarefa-to-spec.md`, no papel de
`creed-ai-context/roles/analista.md`.

<critical>Leia ANTES de escrever: `creed-ai-context/CONTEXT.md`, `creed-ai-context/catalogo.md`, `creed-ai-context/glossario.md` e o molde do repo afetado (`respondentes`).</critical>
<critical>Avalie a seção "Quando pular" do workflow. Se a tarefa for pequena, diga isso e vá direto para `/tasks` em vez de gerar spec por burocracia.</critical>
<critical>Lacuna de produto NÃO vira pergunta pendurada: vira premissa em `creed-ai-context/decisoes/premissas.md`, com marcador no artefato, e a spec continua. A cliente só é acessível em reunião marcada.</critical>
<critical>Use `creed-ai-context/templates/spec-template.md`. Apague seção sem conteúdo em vez de escrever "N/A".</critical>
<critical>Valide contra `creed-ai-context/checklists/definition-of-ready.md` antes de encerrar.</critical>

Saída: `creed-ai-context/tarefas/<id>-<slug>/spec.md`
