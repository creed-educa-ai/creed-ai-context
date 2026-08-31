# Git — o que a IA precisa saber

> A fonte é o `CONTRIBUTING.md` dos repos (é o que o GitHub cobra 🔒). Este arquivo
> só destaca o que muda o comportamento de um agente.

## Fluxo

```
main ← só recebe merge de dev
 ↑
dev  ← alvo padrão de todo PR
 ↑
sua branch de tarefa
```

## Nome da branch — 🔒 check obrigatório

```
<slug>/<id-clickup>-<contexto-em-2-a-4-palavras>
```

`feat/1-criar-usuarios` · `fix/86ab12-corrigir-login-expirado`

Slugs: `feat` `fix` `refactor` `perf` `test` `docs` `style` `chore` `ci` `build`
`hotfix` `release`.

Sem ID do ClickUp o push é recusado pelo hook e o PR não mergeia. **A IA que sugerir
nome de branch precisa do ID** — se não tiver, pergunte; este é um dos poucos casos em
que perguntar ao usuário resolve na hora.

## Commit

```
<tipo>(<escopo opcional>): <resumo no imperativo>

<corpo: por que a mudança existe>
```

Imperativo, minúscula, sem ponto final, até 72 caracteres, descreve efeito e não
arquivo. Corpo responde **por quê** — o diff já mostra o quê.

## Regra para agentes

**Não rode `git add`, `git commit`, `git push`, `git tag`, `git stash`, não crie branch
e não abra PR por conta própria.** Deixe a mudança no working tree. Leitura
(`git status`, `git diff`, `git log`) é livre.

Motivo: com 1 aprovação obrigatória por PR, o revisor é a única revisão do time. Um
commit que o autor não leu transfere para o revisor um trabalho que era do autor.

Quando o usuário **pedir explicitamente** para versionar, siga `../playbooks/abrir-pr.md`.
O comando `/pr <id-clickup>` é esse pedido — e ele ainda assim faz todo o pré-voo em
modo leitura e só escreve depois de uma aprovação inequívoca do dev.

## Merge

🔒 1 aprovação de outra pessoa · 🔒 CI `qualidade` verde · 🔒 conversas resolvidas.
Aprovação é descartada se chegarem commits novos. Depois do merge, apague a branch
de tarefa.
