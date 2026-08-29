# Workflow: tasks → código

## Entrada
`tarefas/<ID>-<slug>/N_task.md` + spec para contexto.

## Saída
Código no working tree, testes verdes, task marcada em `tasks.md`. **Sem commit.**

## Princípios

- **Uma task por vez.** Não implemente duas em paralelo — o diff fica irrevisável.
- **Ler antes de escrever:** task → spec → molde (`respondentes`) → `context/` do repo.
- **Copiar a forma do molde**, não inventar estrutura.
- **Teste junto**, não depois.
- **Escopo fechado**: nada fora da task entra no diff.

## Passos

| # | Passo | Modo agente | Modo copiloto |
|---|---|---|---|
| 1 | Ler task, spec e molde | lê | cole os arquivos |
| 2 | Conferir dependências (tasks anteriores marcadas?) | lê `tasks.md` | você confere |
| 3 | Carregar o playbook aplicável | `../playbooks/` | cole o playbook |
| 4 | Implementar | escreve arquivos | você aplica as sugestões |
| 5 | Rodar a suíte | roda | **você roda** |
| 6 | Auto-review contra `../checklists/revisao-de-codigo.md` | gera veredito | você lê o diff |
| 7 | Marcar a task em `tasks.md` | edita | você edita |

## Playbooks

| Task envolve | Playbook |
|---|---|
| domínio novo no backend | `../playbooks/criar-dominio-backend.md` |
| feature nova no front | `../playbooks/criar-feature-frontend.md` |
| mudança de schema | `../playbooks/criar-migration.md` |
| versionar e abrir PR | `../playbooks/abrir-pr.md` |

## Encerramento

Terminada a task, a resposta encerra com:

```
Task N — <título>
Arquivos tocados: <lista>
Suíte: <comando> → <resultado, ou "não executada">
Premissas usadas: P-NNN (ou nenhuma)
Fora do escopo, observado mas não mexido: <lista ou "nada">
Próximo passo humano: rodar a suíte, ler o diff, seguir para a task N+1
```

Não faça commit. Versionar é `../playbooks/abrir-pr.md`, sob pedido explícito.
