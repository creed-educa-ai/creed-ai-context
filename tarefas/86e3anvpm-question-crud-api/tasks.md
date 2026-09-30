# Tasks — CREED-35 Question

Spec: [`spec.md`](spec.md)

## Progresso

- [ ] 1 — [Tabela `questions` no banco, com o domínio `questions`](1_task.md) · `creed-backend`
- [ ] 2 — [Criar e listar perguntas: regra, acesso a dados e contratos](2_task.md) · `creed-backend`
- [ ] 3 — [Endpoints de criação e listagem de perguntas](3_task.md) · `creed-backend`
- [ ] 4 — [Modelo de dados descrevendo a seção da pergunta](4_task.md) · `creed-ai-context`

Marque aqui ao concluir cada task ([`workflows/tasks-to-code.md`](../../workflows/tasks-to-code.md)).

> **Revisto em 2026-09-22**: a pergunta ganhou `section` (enum, obrigatório, filtrável
> na listagem). As tasks 1, 2 e 3 foram ajustadas antes de começar, porque estavam todas
> em `backlog`, e a task 4 nasceu porque a coluna não existe no modelo de dados. Ver a
> spec, "Abordagem técnica", itens 8 a 10.

## Ordem e corte

```
1 (tabela) ──► 2 (regra + contratos) ──► 3 (endpoints)
     └────────► 4 (modelo de dados)  ·  outro repo, em paralelo com 2 e 3

em paralelo, sem esperar:  CREED-33 (form)  ·  outro domínio, outra revisão Alembic
```

**A task 4 é a única que sai do `creed-backend`**, e por isso corre em paralelo: depende
só da 1 (só dá para descrever a coluna depois que a migration existe) e não bloqueia a 2
nem a 3. É meia jornada. Ela mexe nos mesmos arquivos que a task 4 da CREED-33, e o
cuidado está escrito nela.

**As três tasks são sequenciais, sem paralelismo entre elas.** A 2 importa o model que a
1 cria, e a 3 importa os schemas e o service que a 2 cria. Somadas cabem numa sprint: a
1 é meia jornada, a 2 é uma jornada e a 3 é meia jornada.

**Com a CREED-33, esta tarefa corre em paralelo.** As duas não tocam nenhum arquivo em
comum, exceto uma linha em `alembic/env.py` e outra em `app/main.py`. O único ponto de
encontro é o head do Alembic, e a task 1 diz exatamente o que fazer com ele.

O corte segue o das três subtarefas do board (351 migration · 352 repository e service ·
353 schema), com dois ajustes, pelos mesmos motivos da CREED-33:

- **Os schemas vão para a task 2, junto do service.** `service.create(dados:
  QuestionCreate)` importa o schema, então o schema precisa existir antes do service.
- **O router ganha uma task própria, a 3.** Nenhuma das três subtarefas o cita, mas o
  contrato publicado na tarefa tem dois endpoints, e eles precisam de dono.

A task 4 não existia na primeira decomposição, porque a tabela `questions` tinha as
mesmas colunas que `Question` no `.dbml`. A coluna `section` mudou isso.

## Fora do escopo desta rodada

- **Editar e apagar pergunta.** Ver P-019.
- **Conferir que o formulário existe, e a `ForeignKey` de `form_id`.** Ficam para a
  tarefa de amarração.
- **Juntar `questions` com `forms`.** Também fica para a amarração.
- **Alternativas de múltipla escolha.** São a CREED-37.
- **Decidir a lista de seções.** Ela é provisória (P-020), e as tasks implementam com a
  lista provisória.
- **Título, descrição e ordem de exibição das seções.** A seção é um valor de enum. O
  texto na tela e a ordem entre as seções são do front.
- **Consulta por seção entre formulários.** Só dentro de um formulário.
- **Front.** Nada muda no `creed-frontend`. A tela que desenha as seções é outra tarefa.

## Divergências com o que estava publicado no board

| A tarefa dizia | Aqui é | Por quê |
|---|---|---|
| resumo: "cadastrar **e editar**" | só criar e listar | P-019: o contrato publicado só tem `POST` e `GET` |
| schemas `QuestionCreate`, `QuestionUpdate` e `QuestionResponse` | sem `QuestionUpdate` | não existe endpoint que o use (P-019) |
| "Mapeamento SQLAlchemy refletindo o DBML" | reflete, e acrescenta o `prisma` que o contrato da tarefa não cita | a coluna existe no `.dbml`, é opcional, e deixá-la de fora criaria uma divergência nova |
| subtarefa 352: "repository e service" | repository, service **e schemas** | o service importa o schema de entrada |
| nenhuma subtarefa para o router | task 3 | os dois endpoints do contrato precisam de dono |
| nada sobre seção | coluna `section`, filtro `?section=` e task 4 | decisão de time de 2026-09-22, depois da publicação; ver P-020 e P-028 |
