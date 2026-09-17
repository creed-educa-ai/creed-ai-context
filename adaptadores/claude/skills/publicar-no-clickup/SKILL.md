---
name: publicar-no-clickup
description: Levar uma tarefa já especificada no harness para o ClickUp — descrição do épico em linguagem de produto e as subtarefas da decomposição reescritas para qualquer pessoa ler. Use quando pedirem para publicar, subir, transportar, criar ou atualizar tarefas e subtarefas no ClickUp a partir de uma spec ou de tasks.md, ou quando a AGES III/IV vai abrir as tarefas de um épico para o time pegar.
model: sonnet
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, mcp__clickup__clickup_get_task, mcp__clickup__clickup_update_task, mcp__clickup__clickup_create_task, mcp__clickup__clickup_get_list
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai transportar para o ClickUp o que já está especificado em
`creed-ai-context/tarefas/<ID>-<slug>/`.

Siga `creed-ai-context/workflows/tasks-to-clickup.md`, no papel de
`creed-ai-context/roles/analista.md`. A decisão que autoriza esta escrita é
`creed-ai-context/decisoes/adrs/0008-publicacao-de-tasks-no-clickup.md`.

<critical>PORTÃO, ANTES DE QUALQUER COISA: existe `creed-ai-context/tarefas/<ID>-*/tasks.md`? Só `spec.md` → rode `/tasks` e volte. Nada → PARE e peça o ID para rodar `/spec`. Nunca publique subtarefa inventada a partir da descrição solta da tarefa.</critical>

<critical>DUAS ETAPAS, SEMPRE. Primeiro escreva `creed-ai-context/tarefas/<ID>-<slug>/clickup.md` pelo template `creed-ai-context/templates/clickup-epico-e-subtarefas.md`. Depois APRESENTE o mapa de publicação e a lista de materiais e ESPERE um "ok" explícito. Nenhuma chamada de escrita no ClickUp antes disso — o board é compartilhado e não tem desfazer barato.</critical>

<critical>TRADUZA, NÃO COPIE. Cada subtarefa abre com o que muda para quem usa, em português corrente, sem caminho de arquivo e sem jargão do harness ("molde", "spec", "task N", "P-012", "P2 · T3" não vão para o board). Mas o recorte técnico NÃO se traduz: arquivos e métodos propostos, o que já existe e deve ser reusado (com caminho), contrato de entrada e saída com os códigos de erro, e o comando de teste vão LITERAIS. A tabela de exemplos do workflow, seção "A tradução", é a régua.</critical>

<critical>NENHUMA FRASE PODE PRESSUPOR QUE A PESSOA LEU O `creed-ai-context`. "Veja o molde", "siga a convenção", "premissa P-012" sozinhos reprovam a tarefa: ou vira texto expandido ali mesmo, ou vira material anexado. O bloco "Rastreio" no fim é o único ponteiro para o harness, e é opcional para quem lê.</critical>

<critical>MATERIAIS: monte a lista por subtarefa pela tabela de gatilhos do workflow (contrato, mock, modelo de dados, permalink do molde, texto da premissa, glossário, doc de serviço externo). Marque ✅ anexado ou ⬜ falta anexar COM DONO, e cobre isso na mensagem final, subtarefa por subtarefa. Você NÃO anexa arquivo por conta própria — só se a pessoa pedir, arquivo por arquivo. E nunca escreva "veja o anexo" para material que está ⬜.</critical>

<critical>IDEMPOTÊNCIA: toda descrição publicada termina com `Rastreio: <ID>/<N>`. No passo 3, compare por essa linha — cria o que falta, atualiza o que mudou, DEIXA o que está igual (não gasta chamada) e NÃO TOCA em subtarefa sem rastreio: reporte e siga. Escreva sempre em `markdown_description`, nunca em `description`.</critical>

<critical>Sem MCP `clickup` na sessão: escreva o `clickup.md`, diga em uma linha como autenticar (`/mcp`) e PARE — o arquivo é colável à mão. Falha no meio da publicação: pare na primeira, diga qual foi a última subtarefa que entrou e grave os IDs já obtidos no `clickup.md`. Nunca tente autenticar sozinho, nunca siga publicando por cima do erro.</critical>

<critical>Lacuna de produto na hora de escrever "o que muda para quem usa": PARE e registre premissa em `creed-ai-context/decisoes/premissas.md`. Subtarefa publicada com produto inventado parece acordada — é pior que subtarefa faltando.</critical>

<critical>Encerre conferindo `creed-ai-context/checklists/tarefa-nivelada.md` item a item, e entregue: link de cada subtarefa publicada, a tabela do que falta anexar com dono, e o que você reportou sem tocar.</critical>
