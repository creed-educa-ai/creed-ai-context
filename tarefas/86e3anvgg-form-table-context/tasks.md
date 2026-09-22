# Tasks — CREED-33 Form table context

Spec: [`spec.md`](spec.md)

## Progresso

- [ ] 1 — [Tabela `form` no banco, com o domínio `forms`](1_task.md) · `creed-backend`
- [ ] 2 — [Criar e buscar um formulário: regra, acesso a dados e contratos](2_task.md) · `creed-backend`
- [ ] 3 — [Endpoints de criação e consulta de formulário](3_task.md) · `creed-backend`
- [ ] 4 — [Reconciliar o modelo de dados com a tabela que foi criada](4_task.md) · `creed-ai-context`

Marque aqui ao concluir cada task ([`workflows/tasks-to-code.md`](../../workflows/tasks-to-code.md)).

## Ordem e corte

```
1 (tabela) ──► 2 (regra + contratos) ──► 3 (endpoints)
     └────────► 4 (reconciliar o modelo)  ·  outro repo, em paralelo com 2 e 3
```

**As três primeiras são sequenciais, sem paralelismo.** A 2 importa o model que a 1 cria;
a 3 importa os schemas e o service que a 2 cria. Não há contrato intermediário contra o
qual programar em paralelo — as três vivem no mesmo repo e na mesma pasta. Somadas cabem
numa sprint: a 1 é meia jornada, a 2 é uma, a 3 é meia.

**A 4 é a única que sai do `creed-backend`**, e por isso corre em paralelo: ela depende só
da 1 (é preciso a migration existir para descrever o que existe) e não bloqueia nem é
bloqueada pela 2 e pela 3. É meia jornada, e o ator é outro — quem mexe no modelo de
dados, não quem escreve migration.

O recorte do board **é mantido em três**, e desta vez ele está certo: diferente da
CREED-31, aqui existe router, então "schemas" tem para onde ir e a terceira entrega tem
resultado observável — uma porta de API que responde 201, 200, 404 e 422.

**Um ajuste no corte:** os schemas saem da entrega 3 e vão para a **2**. Motivo mecânico,
não estético — `service.create(dados: FormCreate)` importa o schema, então o schema
precisa existir antes do service. É a mesma cadeia do molde
(`UserService.create_user_service(request: UserCreate)`). A entrega 3 fica com router,
injeção de dependência e o registro em `app/main.py`.

## Fora do escopo desta rodada

- **As chaves estrangeiras.** `organization_id` aponta para uma tabela que não existe
  (CREED-38, backlog). Vão na tarefa de **amarração**, que ainda não existe no board e
  precisa de dono e data.
- **A coluna `participant_id`.** Pendência #21 do modelo de dados, em aberto — ver
  premissa P-018 na [`spec.md`](spec.md). O **modelo** passa a registrar essa ausência na
  entrega 4; a **coluna** só volta se a cliente confirmar que formulário nominal existe.
- **Colar a proposta no dbdiagram e reexportar.** A entrega 4 corrige o `.dbml` da
  proposta, não o diagrama do time — reexportar depende de aceitar a proposta inteira, que
  é decisão de time e não cabe nesta tarefa.
- **Transição de estado** (`draft` → `published` → `closed`) e **listagem**
  (`GET /api/v1/forms`). A primeira não faz sentido sem perguntas (CREED-35); a segunda
  não faz sentido sem filtro por organização, que depende de autorização.
- **Editar e apagar formulário.** Ninguém pediu.
- **Front.** Nada muda no `creed-frontend`.
- **Corrigir o domínio `respostas` da CREED-34** para inglês. É desvio real do ADR-0005,
  já em review, e **não é trabalho desta tarefa** — escopo fechado.

## Divergências com o que estava publicado no board

Estas tasks **não** seguem o que as três subtarefas diziam antes de 2026-09-21. Cada
divergência está justificada na [`spec.md`](spec.md) → "Contrato" e "Abordagem técnica":

| A subtarefa dizia | Aqui é | Por quê |
|---|---|---|
| CREED-33 (épico): a casca tem "nome e status" | a tabela ganha `name` | o modelo de dados **não tinha** coluna de nome (pendência #17); ela entra agora, como premissa P-016 |
| CREED-33 (épico): `POST` recebe `{organization_id, status}` | `POST` recebe `{name, organization_id}` | o formulário nasce sempre `draft` (P-017) — aceitar `status` é oferecer escolha que não existe, o mesmo corte que `UserCreate` faz com `role` |
| CREED-33 (épico): a saída é `FormResponse` | a saída é `FormRead` | `FormResponse` é o nome de **outra tabela**, a da CREED-34, e já existe como classe no repo |
| 331: criar em `form/models.py` | `app/domains/forms/models.py` | domínio é pasta em `app/domains/`, nome em inglês e no plural (ADR-0005 + `estrutura-e-nomes.md`) |
| 331: não menciona `alembic/env.py` | o import entra na entrega 1 | sem ele o autogenerate não enxerga o model e a migration sai vazia |
| 333: `service.get_by_id(id)` | `service.get(form_id)` | `get_by_id` em service é "repository disfarçado" — o nome descreve como se busca, que é assunto do banco |
| 333: `service.create_form()` | `service.create()` | `FormService.create()` não é ambíguo; o assunto já está na classe |
| 333: schemas junto do router | schemas junto do service | o service importa `FormCreate` — o schema precisa nascer antes |
| 333: `FormRead` devolve `id`, `status`, `created_at` | devolve também `name` e `organization_id` | sem os dois, quem chama não consegue distinguir um formulário do outro nem saber de quem ele é |

**O conteúdo do épico e das três subtarefas foi sobrescrito no board em 2026-09-21** —
ver [`clickup.md`](clickup.md). Não há versão antiga convivendo.
