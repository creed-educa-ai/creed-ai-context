# Review — CREED-32 · Link table context (entrega 1)

> Revisão de `feat/86e3anvg2-tabela-vinculos` (creed-backend) contra **`origin/dev`**
> (`122b972`), feita em 2026-09-30. São 9 commits (`7323ecc`..`e5715da`) e 36 arquivos:
> tasks 1–5. A task 6 não está na branch.
>
> Segue [`../../workflows/revisao.md`](../../workflows/revisao.md) e o checklist de
> [`../../checklists/revisao-de-codigo.md`](../../checklists/revisao-de-codigo.md).
>
> A `dev` **local** está em `25a74d4`, atrás da `origin/dev`. `git diff dev...HEAD` mostra
> 107 arquivos, a maioria de PRs já mesclados. O diff real é contra `origin/dev`.

## Veredito: Mudanças necessárias
Tier: **Sensível**, por três motivos: migration (`b9fa0c109598` e dois merges), autenticação (a guarda e o login passam a ler o papel do vínculo) e contrato de API (`UserCreate` exige `link_id`; a sessão troca `vinculo_id` por `link_id`).
Escalada: **exigida**, ver o bloco no fim. **A passada pesada já foi feita** (ver
"Passada pesada", no fim). Ela manteve as três exigências e acrescentou uma quarta. A
segunda leitura humana foi **dispensada** pelo responsável técnico (ver o bloco no fim).

## Estado das exigências — 2026-09-30, depois das correções

As correções foram aplicadas sobre `e5715da`, na própria branch, sem migration nova.
A numeração é a mesma da spec (nota de 2026-09-30 no cabeçalho).

**Commits (2026-09-30):**
- back, em `feat/86e3anvg2-tabela-vinculos`: `087d25b` (exigência 1), `f3ca662` (2) e
  `39ece72` (3);
- front, na branch nova `refactor/86e3anvg2-link-id-na-sessao`, que sai de `5bac8fd`:
  `b90b864` (4).

Nada foi enviado ao GitHub (sem push). Onde a tabela abaixo diz "sem commit", leia o
commit listado aqui.

| # | Exigência | Onde apareceu | Estado |
|---|---|---|---|
| 1 | A guarda decide a rota pelo token, não pelo vínculo | passada pesada | ✅ resolvida, sem commit. `app/shared/authorization.py:123-132` confere o papel da rota de novo, sobre o usuário já verificado no banco (403). Testes: `test_token_with_two_roles_is_judged_by_the_link_role` (403) e o par com vínculo `admin` (200) |
| 2 | `POST /users` sem guarda | primeira passada | ✅ resolvida, sem commit. `app/domains/users/router.py:35` com `require_role("admin")` e 401/403 documentados no OpenAPI. Testes: `test_without_token_returns_401` e `test_respondente_role_returns_403` |
| 3 | `participant_id` sem FK, justificado com um fato falso | primeira passada | ✅ resolvida pela **opção (a)**, sem commit. A FK fica para a amarração. O motivo real foi escrito em `links/models.py`, `seed_local.py`, `test_models.py` e no item 3 da spec |
| 4 | `vinculo_id` → `link_id` no front | primeira passada | ✅ resolvida no `creed-frontend`, **sem commit e sem branch**. As mudanças estão no working tree da `dev`, que foi atualizada antes com fast-forward até `origin/dev` (`5bac8fd`). Foram renomeados `src/types/api.ts:47` e as três fixtures (`ProtectedRoute.test.tsx`, `authenticationSlice.test.ts`, `apiClient.test.ts`). Nenhum código de tela lê o campo. `npm run check` passou (lint, prettier, typecheck e 161/161 testes) |

**Como as correções foram verificadas:**

- Os testes novos foram escritos antes da correção e vistos **vermelhos**: 200 onde devia
  ser 403, e 201 onde devia ser 401 e 403. Depois da correção, ficaram verdes.
- Suíte inteira: `pytest` com 309 passed e 1 skipped; `ruff check` e `format` limpos;
  `pre-commit run mypy --all-files` passou; `alembic check` sem diferença, confirmando que
  só comentário mudou em `models.py`.
- Um merge simulado com a branch empilhada da task 6 (`abc8456`), feito com
  `git stash create` + `git merge-tree`, saiu **sem conflito**.

**O que as correções não provam:**

- O token com dois papéis foi simulado; não saiu de um Keycloak de verdade.
- A execução de ponta a ponta da passada pesada (29/29) rodou **antes** das correções e
  não foi repetida depois.

**Para fechar o veredito:** as quatro exigências estão resolvidas e commitadas. Os dois
PRs podem entrar em qualquer ordem, porque nenhuma tela lê o campo renomeado.
Depois do merge, falta ainda a seção "Estado real" do `contrato-api.md` da CREED-23, que
diz que o `POST /users` não tem guarda.

## O resumo em uma frase

O núcleo da tarefa está certo e provado. A guarda e o login leem o papel do vínculo, o
teste de divergência usa o `UserService` de verdade, e a migration sobe do zero num head
único e desce limpa. Duas coisas seguram a entrega. Uma é antiga, mas esta branch a piorou:
o `POST /users` não tem guarda e agora amarra um login a um papel e a uma organização. A
outra: o motivo de `links.participant_id` não ter FK deixou de valer quando `participants`
entrou na `dev` (#28).

---

### Exigências

- **`app/domains/users/router.py:21`: Segurança.** O `POST /users` continua sem guarda.
  O `contrato-api.md` da CREED-23 registra isso como estado ("existe, **sem guarda de
  papel**"), não como decisão. Antes desta branch, o pior que a rota fazia era criar um
  `respondente`. Agora ela amarra qualquer `email`/`keycloak_id` a qualquer `link_id` livre,
  ou seja, decide o papel e a organização de um login. É exatamente o motivo que a spec
  (item 7) usou para guardar o `POST` de vínculo. A comparação com o claim na guarda impede
  escalar para `admin` sem ter a realm role. O que ela não impede é alguém sem token ligar
  um vínculo a um e-mail qualquer. O dono legítimo passa a levar 409, e isso só se desfaz no
  `psql`. Também não impede que um gestor do realm, ainda sem linha em `user`, se cadastre
  no vínculo de gestor de **outra** organização. Nos dois casos é preciso conhecer o
  `link_id`, um UUID que só o admin recebe, então o risco é moderado. A correção custa uma
  linha.
  → Acrescentar `dependencies=[Depends(require_role("admin"))]` no `@router.post`, como a
  CREED-23 prometeu ("proteger uma rota nova custa uma linha"). Em
  `tests/domains/users/test_router.py`, levar para lá o `_authorize_as` que
  `tests/domains/links/test_router.py` já tem, com um teste de 401 e um de 403. Se a decisão
  for deixar isso fora do PR, ela precisa ficar escrita em "Riscos" da spec, com uma tarefa
  aberta. Silêncio não serve.

- **`app/domains/links/models.py:7` e `:51`: Dados.** O model diz que `Participant` "ainda
  não tem tabela", mas desde o #28 (mesclado nesta branch em `d007dcb`) `participants`
  existe. A justificativa de `participant_id` sem FK (spec, "Abordagem técnica", item 3)
  deixou de valer para essa coluna. O mesmo texto aparece em
  `tests/domains/links/test_models.py:41` e em `scripts/seed_local.py:38`.
  → Decidir e registrar:
  - **(a) manter sem FK neste PR (recomendado):** reescrever os quatro trechos e o item 3
    da spec com o motivo real. A FK entra na amarração, junto com `Organization` e
    `Department`, porque o participante fixo do seed teria de existir antes.
  - **(b) pôr a FK agora:** exige revisão nova depois de `87beb54d929a`, o seed criando o
    participante de dev, e `links` compondo com `ParticipantService` para responder 404.
    É escopo que a calibragem da spec não previu.

  O que não pode ficar é o comentário afirmando um fato que o banco contradiz.

- **`creed-frontend/src/types/api.ts:47`: Contratos.** Em `UserSessionResponse`,
  `vinculo_id` virou `link_id`. É renomeação, não mudança aditiva. Na `origin/dev` do front,
  o campo só aparece no tipo e em três fixtures de teste, e nenhum código de tela o lê. Por
  isso nada quebra na tela, mas depois do merge o tipo mente.
  → Abrir o PR par no front renomeando `api.ts:47` e as fixtures
  (`ProtectedRoute.test.tsx:16`, `authenticationSlice.test.ts:11`, `apiClient.test.ts:10`),
  e citá-lo na descrição do PR do back. A própria spec ("Quem usa") e o `contrato-api.md`
  dizem que o front "precisa acompanhar".

### Sugestões

- `app/domains/users/repository.py:32`: dois `POST /users` simultâneos com o mesmo
  `link_id` passam juntos pelo `get_by_link_id`, e o segundo bate em `uq_user_link_id`:
  `IntegrityError` e **500** no lugar de 409. O mesmo já acontecia com o e-mail. `participants`
  e `questions` já tratam essa corrida (`IntegrityError` → conflito). Se a guarda entrar,
  sai barato tratar os dois casos juntos. Se não entrar, isso continua sendo o padrão do molde.
- `app/domains/users/service.py:66`: `end_at` não é conferido, então um vínculo encerrado
  continua dando acesso. Hoje isso é inalcançável, porque nenhuma rota preenche `end_at`,
  mas a tarefa que criar o encerramento precisa lembrar disso. Vale uma linha em "Riscos"
  ou um comentário ao lado do `if`.
- `app/domains/authentication/schemas.py:51`, `:68` e `:92`: o exemplo ainda mostra
  `"link_id": None`, e a descrição diz "quando disponível". Depois desta branch, uma sessão
  válida sempre traz `link_id` e `organization_id`. Vale trocar o exemplo por um UUID; o tipo
  pode continuar nulável por causa do front.
- `tests/domains/users/test_service.py:142`: `created.user.role is not UserRole.ADMIN` passa
  por acaso. O repository falso não aplica o `default`, então `role` fica `None`. Se o service
  passasse a mandar `role=UserRole.GESTOR`, o teste continuaria verde.
  `assert created.user.role is None` diz exatamente "o service não passou papel".
- `app/domains/users/router.py:79`: o `DELETE /users/{user_id}` também não tem guarda. Isso
  é anterior a esta branch, mas se a guarda entrar no `POST`, a mesma linha serve aqui.
- Antes do `/pr`, atualizar a `dev` local (`git -c http.sslBackend=schannel fetch` e depois
  `git branch -f dev origin/dev`). Sem isso, o diff padrão do `/revisar` e do `/pr` sai com
  107 arquivos.

### Verificado

- **Escopo:** só as tasks 1–5. `UserRole` e `user.role` continuam existindo, e não há
  nenhum `drop`, então a regra 6 de `conventions/migrations.md` foi respeitada.
- **Suíte:** `pytest` com 305 passed e 1 skipped (o skip é antigo: `authentication` não tem
  `models.py`). `ruff check` e `ruff format --check` limpos. `pre-commit run mypy --all-files`
  passou, rodado pelo hook e não só pelo `.venv`.
- **Migration**, num banco descartável (`creed_review_32`, já apagado):
  - `upgrade head` do zero chega a um head único, `87beb54d929a`;
  - `\d links`: dez colunas, três índices, nenhuma FK, nenhuma unique;
  - `\d user`: `link_id` nulável, com `uq_user_link_id` e `fk_user_link_id_links`, e `role`
    ainda presente;
  - `downgrade b9fa0c109598@-1` remove a tabela, a coluna, as duas constraints e os tipos
    `roles`/`linktype`, e mantém `userrole`;
  - depois de reaplicar, `alembic check` não acusa diferença.

  No teu banco local, `alembic check` também não acusa diferença: model e migration batem.
- **Leitura linha a linha** de `b9fa0c109598` e dos dois merges (`bb6c81983ecb` e
  `87beb54d929a`). Os merges estão vazios e só unem o grafo, e ninguém editou
  `down_revision` à mão.
- **Guarda:** `_check_against_database` compara o claim com `access.role`, que vem do
  vínculo. O `None` cobre quatro casos (usuário inexistente, inativo, sem vínculo, ou vínculo
  não achado), e todos dão 401. `grep "\.role" app/` não acha nenhuma leitura de `user.role`.
- **O teste que importa:** `test_column_says_admin_but_link_says_gestor_returns_401` usa o
  `UserService` real e troca só o banco. Ele falha se alguém voltar a ler a coluna, e está
  no nível certo.
- **Login e `/authentication/session`** preenchem `link_id` e `organization_id` a partir do
  vínculo, e os dois têm teste.
- **Camadas:** `users` só fala com `links` pelo `LinkService`, e isso está declarado em
  `COMPOE_COM_SERVICE_DE` com o motivo. `links` não importa nenhum domínio. A FK é declarada
  por nome, e `UserResponse` não importa `Roles`. O router não tem regra e o repository não
  toma decisão.
- **Seed:** idempotente nos três caminhos (usuário novo, usuário existente sem vínculo,
  usuário existente com vínculo). Isso foi conferido **lendo o código, sem executar**.
- **Nenhuma credencial ou dado real no diff.** Os UUIDs são de exemplo, e os ids fixos são
  do seed local.

### Não verificado

- **O seed não foi executado,** porque o Keycloak não estava de pé (só o container `db`).
  O critério "rodar duas vezes deixa **um** vínculo `admin` e o login funciona" não está
  provado.
- **Login de ponta a ponta** (uvicorn + Keycloak + curl): o "Como verificar" da spec não foi
  rodado. "Trocar `user.role` no `psql` e o login continuar `admin`" só está provado pelo
  teste com dublês.
- **Nenhum teste toca o banco real** no caminho da FK: `IntegrityError` em
  `fk_user_link_id_links` e a corrida em `uq_user_link_id`.
- **Migration com linhas pré-existentes em `user`:** o banco descartável estava vazio.
  Com linhas, `link_id` fica `NULL`, que é o que a spec espera, mas isso não foi executado.
- **Frontend:** só foi feito o `grep` de `vinculo_id`. Nem build nem testes do front rodaram.
- **Swagger renderizado:** não foi aberto. Só `tests/test_openapi.py` passou.
- **Harness:** a spec, o ADR-0005, o glossário, as premissas e o `contrato-api.md`, todos
  sem commit, estão fora do diff revisado.

### Escalada exigida — tier Sensível
Motivo do tier: migration + autenticação + contrato de API
- [x] Passada com modelo pesado — feita em 2026-09-30 (Opus 5.5). Ver "Passada pesada"
  abaixo. Rodou na mesma conversa da primeira passada, e não numa sessão nova.
- [x] Segunda leitura humana — **dispensada** em 2026-09-30 por Luís (@Kv1ecz, AGES III,
  responsável técnico e autor do PR). Motivo: ele é quem sobe os últimos PRs antes da
  entrega, e a CREED-32 precisa entrar antes da integração entre as tabelas e as features.
  O que compensa a falta dela é a passada pesada e a execução de ponta a ponta (29/29).
  A dispensa **não fecha as exigências**: o veredito continua "Mudanças necessárias" até as
  quatro serem resolvidas ou recusadas por escrito.
A primeira passada rodou em modelo médio (`/revisar`, `model: sonnet`).

Frase para a sessão com modelo pesado:

```
Revise a branch feat/86e3anvg2-tabela-vinculos do creed-backend contra origin/dev
seguindo creed-ai-context/workflows/revisao.md, no papel de
creed-ai-context/roles/revisor.md. Tier Sensível, motivo: migration, autenticação e
contrato de API. Já houve uma passada em modelo médio
(creed-ai-context/tarefas/86e3anvg2-vinculo-table-context/review.md) — comece pelo
que ela deixou em "Não verificado".
```

---

## Passada pesada — 2026-09-30

> Opus 5.5, na mesma conversa da primeira passada. Para reduzir a ancoragem, ela partiu do
> "Não verificado" e tentou **refutar** as três exigências, não só confirmá-las.
>
> A execução ponta a ponta rodou numa **cópia limpa de `e5715da`** (`git archive`,
> confirmada por `app.__file__`), e não no working tree. Durante a revisão, alguém começou
> a task 6 no working tree: `alembic/versions/28e9a13197f4_drop_user_role.py` e quatro
> arquivos modificados, tudo sem commit. Essa parte ficou fora da revisão.

### Veredito: Mudanças necessárias (mantido)

As três exigências da primeira passada resistiram à tentativa de refutação. A passada
pesada acrescenta uma quarta, na guarda.

### Exigência nova

- **`app/shared/authorization.py:113` e `:123` (`require_role`): Segurança.** Quem
  autoriza a rota é o **token**, não o vínculo. `_check_against_database` (`:95`) só
  confere se o papel do vínculo está **entre** os papéis do token. O teste abaixo foi feito
  com token e serviço falsos:

  | token | vínculo | rota `admin` |
  |---|---|---|
  | `[admin]` | `gestor` | 401 ✔ |
  | `[admin, gestor]` | `gestor` | **200** ✘ |
  | `[admin, respondente]` | `respondente` | **200** ✘ |

  A spec promete que "o papel que vale no login e em cada rota protegida passa a ser o do
  vínculo". O teste de divergência da task 5 só cobre token com um papel. O caso real é
  justamente o desvio que a spec lista em "Riscos": a realm role é configurada à mão. Quem
  foi rebaixado no vínculo (hoje, só pelo `psql`) mas ficou com os dois papéis no realm
  continua admin. A lógica já vinha da CREED-23, que fazia o mesmo com `user.role`, mas a
  promessa que ela quebra é a da task 5. O token real do realm local traz só `['admin']`,
  então para chegar a isso alguém precisa atribuir dois papéis à mão. O risco é moderado.
  → Depois de `_check_against_database`, conferir os papéis da rota contra o usuário já
  verificado no banco:

  ```python
  user = await _check_against_database(identity, users)
  if not any(user.has_role(role) for role in roles):
      raise HTTPException(status.HTTP_403_FORBIDDEN, "Cargo insuficiente para acessar")
  return user
  ```

  O 403 barato, sem consulta, continua valendo, e
  `test_insufficient_role_does_not_query_the_database` segue verde. Falta um teste com
  token `["admin", "gestor"]`, vínculo `gestor`, rota admin → 403.

  A alternativa, mais estrita, é tratar como divergência (401) qualquer papel de
  plataforma no token além do papel do vínculo. É decisão tua. A correção acima é a menor.

### As três exigências da primeira passada, reconfirmadas

- **`POST /users` sem guarda:** confirmado de ponta a ponta. Sem token nenhum, a chamada
  criou um usuário amarrado a um vínculo `gestor` (201). O `DELETE /users` sem token
  respondeu 204.
- **`participant_id` sem FK com comentário falso:** `participants` existe. A revisão
  `9b1560fe0917` ("cria tabela participants") roda no `upgrade head` desta branch.
- **`vinculo_id` no front:** a `origin/dev` do front continua com `vinculo_id` em
  `api.ts:47`.

### Sugestões novas ou reforçadas

- **Corrida em `uq_user_link_id`: agora com evidência.** Em cinco rodadas de dois
  `POST /users` simultâneos, deu `[201, 409]` uma vez e `[201, 500]` quatro vezes. A
  integridade se mantém: nunca ficaram dois usuários no mesmo vínculo. Como a rota está sem
  guarda, qualquer um consegue provocar esses 500.
- **`end_at` confirmado:** um vínculo com `end_at` no passado continua dando acesso (200).
- **Spec, "Riscos", o item do Keycloak.** A spec diz que um vínculo `gestor` para um admin
  do realm "vira 401 no login". Na prática, **o login responde 200** com `role: gestor`,
  e o 401 só vem na primeira chamada protegida. O front então renova uma vez, tenta de novo
  uma vez, limpa a sessão e mostra "Sessão expirada, faça login novamente" logo depois do
  login. Não há loop infinito, confirmado lendo `apiClient.ts:95`. Isso já vinha da
  CREED-23, porque o login nunca comparou papel. Vale corrigir o texto do risco com o
  sintoma real.
- **`links/router.py`: o OpenAPI do `POST` de vínculo só documenta 201 e 422.**
  `participants/router.py:25` documenta 401 e 403. Vale seguir o padrão observado.

### Verificado nesta passada

Ponta a ponta, com o app real rodando em processo (sem servidor), o Keycloak local de pé e
um banco descartável (`creed_heavy_32`, já apagado). **29/29 checks passaram.**

- **Migration com linhas antigas.** O banco foi montado no head da `dev` com dois usuários
  "de antes" e depois levado até o head da branch. Os dois ficaram com `link_id NULL`, e o
  `role` antigo foi preservado.
- **Downgrade com dados:** `links` some, as sete linhas de `user` ficam, e o re-upgrade
  devolve `link_id NULL`.
- **Seed rodado duas vezes:** a primeira execução ligou o usuário já existente a um
  vínculo; a segunda disse "já estava". Ficou **um** vínculo, `ADMIN`.
- **Antes do seed,** o login com a senha certa dá 401 "E-mail ou senha inválidos", que é o
  sintoma que o README avisa.
- **Depois do seed,** o login dá 200 com `role`, `link_id` e `organization_id` vindos do
  vínculo, e `/authentication/session` devolve o mesmo.
- **`POST` de vínculo:** 201 com `department_id` nulo; 401 sem token; 422 com papel fora
  do enum.
- **`POST /users`:** 404 para vínculo inexistente, 409 para vínculo já usado, 422 sem
  `link_id`.
- **A prova da coluna, contra o banco real.** Com `user.role` trocado para `RESPONDENTE`,
  a sessão continua `admin`. Com o **vínculo** trocado para `GESTOR`, a sessão e a rota
  admin dão 401.
- **FK real:** o banco recusa `link_id` inexistente e recusa apagar um vínculo que tem
  login (`fk_user_link_id_links`).
- **Estado do repositório:** a `origin/dev` não se mexeu (`122b972`) e não há PR aberto no
  backend, então o merge `87beb54d929a` continua sendo o head certo.
- **`contrato-api.md` da CREED-23 (harness):** a mudança é só renomeação e bate com o
  código. A seção "Estado real" ainda descreve a `dev` de antes, como a spec prevê que
  fique até o merge.

### Ainda não verificado

- **Token com dois papéis vindo do Keycloak de verdade:** a prova usou um token falso, e o
  realm não foi alterado, de propósito.
- **Front:** nem build nem testes rodaram. O comportamento no caso de divergência foi
  conferido lendo o código, sem executar.
- **Swagger:** a tela não foi aberta; só o JSON do OpenAPI foi inspecionado.
- **O trabalho da task 6 no working tree** (e o banco `creed_task6`, que não é desta
  revisão).
- **Custo por requisição protegida** (duas consultas: usuário e vínculo): não foi medido.
