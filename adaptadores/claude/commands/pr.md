---
description: Pré-voo da feature e, com sua aprovação, abre o PR pedindo review aos maintainers
argument-hint: <id-clickup>
model: sonnet
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Prepare o PR da tarefa **$ARGUMENTS**.

Siga `creed-ai-context/playbooks/abrir-pr.md`, no papel de
`creed-ai-context/roles/revisor.md` durante o pré-voo.

<critical>FASE 1 — PRÉ-VOO, SÓ LEITURA. Rode a tabela §1 do playbook inteira, na ordem. Git de leitura (`status`, `diff`, `log`, `branch`, `merge-base`) e `gh pr list` são livres. NENHUM comando de escrita nesta fase — nem `git add`.</critical>
<critical>Dispare a revisão completa: `creed-ai-context/workflows/revisao.md` (tier, checklist, veredito). "Mudanças necessárias" BLOQUEIA. Tier Sensível sem a escalada cumprida também BLOQUEIA — ver "Tier Sensível: pare e escale".</critical>
<critical>Valide branch: nome contra o regex de `.github/workflows/nome-da-branch.yml`, origem com `git merge-base --is-ancestor origin/dev HEAD`, e ID da branch = ID da tarefa. Estava em `dev`? Não é bloqueio: proponha a branch no passo de execução.</critical>
<critical>Valide aderência: cada critério de aceite de `creed-ai-context/tarefas/<ID>-*/spec.md` e dos `N_task.md` precisa apontar para `arquivo:linha` no diff. Critério não atendido é BLOQUEIO, não ressalva.</critical>
<critical>Reviewer é o TIME, não a pessoa: `--reviewer creed-educa-ai/maintainers` (`creed-ai-context/equipe.md`). Pedir review para o próprio autor derruba o `gh pr create`; pedir para o time que o inclui, não. NUNCA caia para handle individual sem avisar.</critical>
<critical>Confira a identidade do `gh` ANTES de prometer execução: `gh auth status` e `gh api repos/creed-educa-ai/<repo> --jq .permissions.push`. Um `GH_TOKEN` no ambiente vence a conta do keyring — se a conta ativa não tiver push, BLOQUEIE e aponte `creed-ai-context/equipe.md` → "Identidade do `gh`".</critical>
<critical>FASE 2 — apresente o bloco "Pré-voo do PR" do §2 do playbook, com os comandos exatos que você vai rodar e a descrição do PR inteira, montada de `creed-ai-context/templates/pr-template.md`. Havendo bloqueio, não peça aprovação: liste o que fazer e pare.</critical>
<critical>FASE 3 — PORTÃO. Execute só depois de aprovação inequívoca ("aprovado", "pode subir"). Ambiguidade, silêncio ou "acho que sim" = NÃO executa, pergunte de novo. Aprovação vale para esta rodada e para os comandos exibidos; mudou qualquer coisa, refaça o pré-voo.</critical>
<critical>FASE 4 — execute §4 na ordem, parando no primeiro erro. Nunca `git add .`, nunca `--no-verify`, nunca `--force`, nunca `--amend` em commit enviado. Encerre com a URL do PR e o resultado de `gh pr checks`.</critical>
