---
description: Implementa uma task específica (sem commitar)
argument-hint: <id-clickup> <número da task>
model: sonnet
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Implemente a task indicada em **$ARGUMENTS**.

Siga `creed-ai-context/workflows/tasks-to-code.md`, no papel de
`creed-ai-context/roles/implementador.md`.

<critical>PORTÃO DE ENTRADA (antes de tudo): olhe `creed-ai-context/tarefas/<id>-*/`. Sem `N_task.md` e sem `spec.md`, PARE — peça o ID da tarefa no ClickUp, se não veio, e rode o passo de especificação (`/spec <id>`) antes de escrever qualquer linha. Com spec e sem tasks, rode `/tasks <id>`. Este comando NÃO fala com o ClickUp: quem fala é a especificação.</critical>
<critical>Leia ANTES de escrever: o `N_task.md`, a `spec.md`, e o MOLDE (`app/domains/respondentes/` ou `src/features/respondentes/`). Copie a forma do molde, não invente estrutura.</critical>
<critical>Carregue o playbook aplicável de `creed-ai-context/playbooks/` (domínio backend, feature front, migration).</critical>
<critical>PARADA DE DECISÃO: antes de escrever, classifique cada dúvida pela tabela de `workflows/tasks-to-code.md` → "Parada de decisão". Bifurcação TÉCNICA com efeito visível no diff e sem resposta no harness: PARE, apresente 2 opções com trade-off e a sua recomendação, e espere a resposta. Máximo 2 por task. Molde, convenção, estilo ou lacuna de produto NÃO param — seguem (lacuna de produto vira premissa).</critical>
<critical>Escreva no nível de `creed-ai-context/conventions/nivel-de-codigo.md`: um colega entende o arquivo em uma passada. Nada da lista do §3 entra sem justificativa escrita no encerramento.</critical>
<critical>Testes junto com o código: caso feliz + pelo menos um caso de borda; correção de bug tem teste que falha sem a correção (`conventions/testes.md`).</critical>
<critical>NUNCA rode `git add`, `git commit`, `git push`, não crie branch e não abra PR. Deixe no working tree.</critical>
<critical>Se a task tem migration: proponha, e encerre avisando que precisa de leitura humana linha a linha, com os pontos de atenção concretos.</critical>
<critical>Rode a suíte do repo e reporte o resultado real — nunca afirme que passou sem ter rodado.</critical>
<critical>Escopo fechado: nada além da task no diff. Problema ao lado se anota no encerramento, não se conserta.</critical>
<critical>ENCERRE no formato de `creed-ai-context/templates/entrega-didatica.md` — todas as seções, incluindo "O que descartei" e "Para você conseguir defender". Explique decisão, não sintaxe. Encerramento sem as seções didáticas é entrega incompleta.</critical>
<critical>Marque a task em `tasks.md` e aponte o próximo passo humano: rodar a suíte, ler o diff, responder à `creed-ai-context/checklists/defesa-do-codigo.md`.</critical>
