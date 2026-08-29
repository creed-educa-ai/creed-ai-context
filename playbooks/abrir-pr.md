# Playbook: versionar e abrir PR

> **Só executa sob pedido explícito do usuário.** Em qualquer outra situação, a IA
> deixa a mudança no working tree (`../conventions/git-workflow.md`).

## Pré-requisitos — confira antes de tocar em git

- [ ] Suíte local **rodada por um humano** e verde
- [ ] `git diff` lido inteiro pelo autor
- [ ] `../checklists/definition-of-done.md` cumprido
- [ ] ID da tarefa no ClickUp em mãos (sem ele o push é recusado 🔒)

## Passos

1. **Branch** a partir de `dev`:
   ```bash
   git checkout dev && git pull
   git checkout -b <slug>/<id-clickup>-<contexto>
   ```
   Slugs: `feat` `fix` `refactor` `perf` `test` `docs` `style` `chore` `ci` `build`
   `hotfix` `release`. Contexto em 2–4 palavras, minúsculas, sem acento.

2. **Commit** — Conventional Commits, imperativo, até 72 caracteres no resumo. Corpo
   responde **por quê**.
   ```bash
   git add <arquivos específicos>
   git commit
   ```
   Nunca `git add .` — o diff precisa ser o escopo da task, nada mais.

3. **Push**:
   ```bash
   git push -u origin <branch>
   ```
   Recusado pelo hook? O nome está fora do padrão. Renomeie:
   ```bash
   git branch -m <slug>/<id>-<contexto>
   ```

4. **PR** com alvo `dev` (só release/hotfix vai para `main`). Descrição a partir de
   `../templates/pr-template.md`.

5. **Confira os checks** `qualidade` e `nome-da-branch` 🔒.

## Depois

- 1 aprovação de outra pessoa é obrigatória 🔒 — commit novo depois da aprovação a
  descarta.
- Conversas resolvidas 🔒.
- Merge feito, apague a branch de tarefa.

## A IA nunca

- Faz `git push --force`, `git rebase` em branch compartilhada, ou `git commit --amend`
  em commit já enviado.
- Mergeia o próprio PR.
- Usa `--no-verify`.
