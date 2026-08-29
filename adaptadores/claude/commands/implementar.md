---
description: Implementa uma task específica (sem commitar)
argument-hint: <id-clickup> <número da task>
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Implemente a task indicada em **$ARGUMENTS**.

Siga `creed-ai-context/workflows/tasks-to-code.md`, no papel de
`creed-ai-context/roles/implementador.md`.

<critical>Leia ANTES de escrever: o `N_task.md`, a `spec.md`, e o MOLDE (`app/domains/respondentes/` ou `src/features/respondentes/`). Copie a forma do molde, não invente estrutura.</critical>
<critical>Carregue o playbook aplicável de `creed-ai-context/playbooks/` (domínio backend, feature front, migration).</critical>
<critical>NUNCA rode `git add`, `git commit`, `git push`, não crie branch e não abra PR. Deixe no working tree.</critical>
<critical>Se a task tem migration: proponha, e encerre avisando que precisa de leitura humana linha a linha, com os pontos de atenção concretos.</critical>
<critical>Rode a suíte do repo e reporte o resultado real — nunca afirme que passou sem ter rodado.</critical>
<critical>Escopo fechado: nada além da task no diff. Problema ao lado se anota no encerramento, não se conserta.</critical>
<critical>Encerre no formato de "Encerramento" do workflow e marque a task em `tasks.md`.</critical>
