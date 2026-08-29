# Workflow: spec → tasks

## Entrada
`../tarefas/<ID>-<slug>/spec.md` (ou a tarefa do ClickUp direto, quando a spec foi pulada).

## Saída

```
tarefas/<ID>-<slug>/
├── spec.md
├── tasks.md      índice com checklist de progresso
├── 1_task.md
└── 2_task.md
```

Template: `../templates/tasks-template.md`.

## Princípios

- **Cada task é entregável e testável sozinha.** "Criar o model" não é task; "criar o
  domínio prismas com CRUD e testes" é.
- **Ordem natural:** migration → model/repository → service → router → feature do front
  → i18n/polimento.
- **Uma task não cruza repos.** Feature que toca back e front vira duas tasks, com o
  contrato escrito na primeira.
- **Teste faz parte da task**, não é task separada.
- **Aprovação antes de escrever.** Apresente a lista em alto nível e espere o ok
  antes de gerar os arquivos.

## Tamanho

Task que não cabe em um dia de trabalho de uma pessoa está grande demais. Task que é
"renomear variável" está pequena demais — junte na anterior.

## Passos

1. Ler `spec.md` e o molde do repo afetado.
2. Rascunhar a lista de tasks em alto nível (título + repo + entregável).
3. **Apresentar e esperar aprovação.**
4. Escrever `tasks.md` (índice + checklist) e os `N_task.md`.
5. Cada `N_task.md` traz: objetivo, arquivos que provavelmente mudam, critérios de
   aceite, como testar, premissas aplicáveis.

> Próximo: [`tasks-to-code.md`](tasks-to-code.md)
