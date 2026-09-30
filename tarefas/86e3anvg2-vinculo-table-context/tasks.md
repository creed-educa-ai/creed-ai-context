# Tasks — CREED-32 Link table context (Vínculo)

Spec: [`spec.md`](spec.md)

## Progresso

**Entrega 1: só acrescenta (um PR, ou um por task, mas todos antes da entrega 2)**

- [x] 1 — [Tabela `links` e a coluna `user.link_id` no banco](1_task.md) · `creed-backend`
- [x] 2 — [Vínculo: repository, service e schemas](2_task.md) · `creed-backend`
- [x] 3 — [Vínculo: endpoint de criação](3_task.md) · `creed-backend`
- [x] 4 — [Users: o acesso passa a exigir um vínculo](4_task.md) · `creed-backend`
- [x] 5 — [Guarda e login passam a ler o papel do vínculo](5_task.md) · `creed-backend`

**Entrega 2: remove (PR separado, só depois da entrega 1 inteira estar na `dev`)**

- [x] 6 — [Remover `user.role`](6_task.md) · `creed-backend` · branch `refactor/86e3anvg2-remover-user-role`, empilhada na das tasks 1–5; o PR só abre depois de 1–5 na `dev`

Marque aqui ao concluir cada task ([`workflows/tasks-to-code.md`](../../workflows/tasks-to-code.md)).

## Ordem e corte

```
1 (tabela + coluna) ──► 2 (regra + contratos de vinculos) ──┬──► 3 (POST de vínculo)
                                                             └──► 4 (users exige vínculo) ──► 5 (guarda + login + seed)
                                                                                                   │
                                          entrega 2, outro PR, depois de 1–5 na dev ──► 6 (remove user.role)
```

**A 3 e a 4 correm em paralelo.** As duas dependem só da 2 e não tocam nenhum arquivo em
comum. A 5 depende da 4, porque consome o método de `UserService` que a 4 cria.

**A 6 não entra no mesmo PR que nenhuma das outras.** A regra 6 de
[`conventions/migrations.md`](../../conventions/migrations.md) proíbe acrescentar, migrar
e remover no mesmo PR. Entre a 5 e a 6, cada pessoa do time roda o seed de novo no
próprio banco local. A 6 só abre quando isso já aconteceu.

**Tamanho:** a 1, a 2, a 3 e a 4 levam meia jornada cada. A 5 leva perto de uma jornada:
é a guarda de autenticação, e o teste de divergência é o que mais importa na tarefa
inteira. A 6 é curta. Somadas, cabem numa sprint.

**Com CREED-31, CREED-33 e CREED-35 em andamento, o head do Alembic é disputado.** A
task 1 e a task 6 dizem o que fazer. Resumo: quem mescla por último roda
`alembic merge` no próprio PR, e ninguém edita `down_revision` à mão.

## Fora do escopo desta rodada

- **Criar `Participant`, `Organization` e `Department`**, e as `ForeignKey` de
  `links.participant_id`, `organization_id` e `department_id`. Ficam para a amarração.
- **Listar, editar ou encerrar um vínculo.** Consequência: não há como trocar o papel de
  alguém pela API.
- **Enviar o papel ao Keycloak** (a D4 da CREED-23). A realm role continua configurada à
  mão.
- **Tirar `name` do `user`.** Espera `Participant` existir.
- **`UserCreate` no formato final** (`initial_password` no lugar de `keycloak_id`).
- **Front.** Nada muda no `creed-frontend`.

## Divergências com o que estava publicado no board

| A tarefa dizia | Aqui é | Por quê |
|---|---|---|
| `app/domains/participantes/router_vinculos.py` e `participantes/models.py` | domínio `app/domains/links/`, com `router.py` e `models.py` | o mapa de `modelo-de-dados.md` separa `participantes` (`Participant`) de `vinculos` (`Vinculo`, no código `links`/`Link`), e nenhuma subtarefa cria `Participant`. Spec, "Abordagem técnica", itens 1 e 2 |
| CREED-321: "models para a tabela de link e seus enums" | task 1, que também acrescenta `user.link_id` | o autogenerate gera uma revisão a partir dos dois `models.py`, e a coluna só pode existir depois da tabela que ela referencia |
| CREED-322: "repository e service" | task 2: repository, service **e schemas** | o service importa o schema de entrada. É o mesmo ajuste que a CREED-33 e a CREED-35 fizeram |
| CREED-323: "router e schema" | task 3: só o router | o schema já saiu na 2 |
| nada sobre o papel do usuário | tasks 4, 5 e 6 | decisão de time de 2026-09-24: o papel sai do `User` e vai para o `Link`, dentro desta tarefa. Spec, nota do cabeçalho |
