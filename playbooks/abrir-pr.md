# Playbook: versionar e abrir PR

> **Só executa sob pedido explícito do usuário.** Em qualquer outra situação, a IA
> deixa a mudança no working tree (`../conventions/git-workflow.md`).
>
> O comando `/pr <id-clickup>` é esse pedido — e mesmo ele **não escreve nada em git**
> antes do portão de aprovação (§3).

## Entrada
Working tree com a task pronta + o ID da tarefa no ClickUp.

## Saída
PR contra `dev`, com review pedida aos maintainers de [`../equipe.md`](../equipe.md).

---

## 1. Pré-voo — nada é escrito ainda

Só leitura: `git status`, `git diff`, `git log`, `gh pr list`. Cada linha tem comando
e consequência. **BLOQUEIA** = não segue para §2; **AVISA** = entra nas considerações.

| # | Confere | Como | Falhou → |
|---|---|---|---|
| 1 | Mudança em **um** repo só | `git status --short` nos repos de `../scripts/repos.conf` | BLOQUEIA — task não cruza repo; pergunte qual subir |
| 2 | Não está em `dev`/`main` | `git branch --show-current` | segue para §4.1 (cria a branch) |
| 3 | Nome da branch no padrão 🔒 | regex de `.github/workflows/nome-da-branch.yml` | BLOQUEIA — proponha `git branch -m` |
| 4 | Branch saiu de `dev` | `git merge-base --is-ancestor origin/dev HEAD` | BLOQUEIA — rebase é decisão humana |
| 5 | ID da branch = ID da tarefa | nome da branch × `../tarefas/<ID>-*/` | BLOQUEIA |
| 6 | A tarefa existe no harness | `../tarefas/<ID>-*/spec.md` ou `tasks.md` | AVISA — sem spec, a aderência não é verificável |
| 7 | Critérios de aceite atendidos | `spec.md` e `N_task.md` × diff | BLOQUEIA se algum não estiver |
| 8 | Tasks marcadas em `tasks.md` | leitura | AVISA se sobrou task aberta |
| 9 | Review | `../workflows/revisao.md` inteiro | BLOQUEIA em "Mudanças necessárias"; **tier Sensível sem escalada cumprida também BLOQUEIA** |
| 10 | Estrutura e nomes | `../conventions/estrutura-e-nomes.md` | BLOQUEIA |
| 11 | Nível do código | `../conventions/nivel-de-codigo.md` | AVISA |
| 12 | Suíte verde | `ruff check . && mypy app && pytest` · `npm run check` | BLOQUEIA se vermelha |
| 13 | Suíte rodada **por humano** | pergunte | AVISA — é item do DoD que agente não cumpre |
| 14 | Sem segredo no diff | `.env`, token, chave, dado real | BLOQUEIA |
| 15 | Premissas usadas estão no ledger e marcadas | `../decisoes/premissas.md` | AVISA |
| 16 | Ainda não existe PR desta branch | `gh pr list --head <branch>` | BLOQUEIA — atualize o PR existente |
| 17 | Conta do `gh` tem push no repo | `gh auth status` e `gh api repos/creed-educa-ai/<repo> --jq .permissions.push` | BLOQUEIA — `GH_TOKEN` no ambiente vence a conta do keyring (`../equipe.md` → "Identidade do `gh`") |
| 18 | Time de review existe | `gh api orgs/creed-educa-ai/teams/maintainers` | BLOQUEIA — não caia para handle individual sem avisar |
| 19 | DoD | `../checklists/definition-of-done.md` | BLOQUEIA |

Caso padrão: passou tudo → §2.

## 2. Considerações ao dev — formato fixo

```markdown
## Pré-voo do PR — <ID> <título>

Repo: <repo> · Branch: <atual ou a que será criada> → `dev`
Tier do review: <Trivial | Padrão | Sensível>

### Bloqueios
- <o que impede, e o que fazer>        (ou "nenhum")

### Considerações
- <avisos: nível de código, task aberta, premissa não marcada, suíte não rodada por você>

### Aderência à spec
- <critério de aceite> — atendido em `arquivo:linha`
- <critério> — NÃO atendido        (isto é bloqueio)

### O que vou executar, nesta ordem
1. git checkout -b <branch>              (se aplicável)
2. git add <arquivos, um a um>
3. git commit -m "<tipo>(<escopo>): <resumo>"
4. git push -u origin <branch>
5. gh pr create --base dev --reviewer creed-educa-ai/maintainers

### Descrição do PR
<o corpo montado a partir de ../templates/pr-template.md, inteiro, para você ler antes>

Aprova? Responda **aprovado** para eu executar. Qualquer outra coisa, eu não executo.
```

Havendo bloqueio, o bloco vai **sem** a seção "O que vou executar": não se pede
aprovação para algo que não pode rodar.

## 3. Portão de aprovação

| Resposta do dev | Ação |
|---|---|
| "aprovado" / "pode subir" / equivalente inequívoco | executa §4 |
| pedido de ajuste | ajusta e **refaz o pré-voo do zero** |
| silêncio, dúvida, "acho que sim", qualquer ambiguidade | **não executa** — pergunte de novo |

A aprovação vale para **esta** rodada e para os comandos exibidos. Mudou o diff, mudou
a branch, mudou a descrição: novo pré-voo, nova aprovação.

## 4. Execução

Pare no primeiro erro e reporte — não tente contornar.

1. **Branch** (se estava em `dev`):
   ```bash
   git checkout dev && git pull
   git checkout -b <slug>/<id-clickup>-<contexto>
   ```
   Slugs: `feat` `fix` `refactor` `perf` `test` `docs` `style` `chore` `ci` `build`
   `hotfix` `release`. Contexto em 2–4 palavras, minúsculas, sem acento.

2. **Commit** — Conventional Commits, imperativo, até 72 caracteres. Corpo responde
   **por quê**.
   ```bash
   git add <arquivos específicos>
   git commit
   ```
   Nunca `git add .` — o diff precisa ser o escopo da task, nada mais.

3. **Push**:
   ```bash
   git push -u origin <branch>
   ```
   Recusado pelo hook? O nome está fora do padrão — volte ao pré-voo, não use
   `--no-verify`.

4. **PR** com alvo `dev` (só release/hotfix vai para `main`), corpo de
   `../templates/pr-template.md`, review pedida ao time de `../equipe.md`:
   ```bash
   gh pr create --base dev \
     --title "<tipo>(<escopo>): <resumo>" \
     --body-file <arquivo temporário fora do repo> \
     --reviewer creed-educa-ai/maintainers \
     --assignee @me
   ```

5. **Checks** `qualidade` e `nome-da-branch` 🔒:
   ```bash
   gh pr checks --watch
   ```
   Reporte o resultado e a URL do PR.

## 5. Depois

- 1 aprovação de outra pessoa é obrigatória 🔒 — commit novo depois da aprovação a
  descarta.
- Conversas resolvidas 🔒.
- Merge feito, apague a branch de tarefa.

## A IA nunca

- Escreve em git antes do portão §3 — nem `git add`.
- Reaproveita aprovação de uma rodada anterior.
- Faz `git push --force`, `git rebase` em branch compartilhada, ou `git commit --amend`
  em commit já enviado.
- Usa `--no-verify`.
- Pede review a handle individual: o reviewer é o time `creed-educa-ai/maintainers`
  (`../equipe.md`). Pedir para a própria pessoa derruba o `gh pr create`.
- Mergeia o próprio PR.
