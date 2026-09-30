# Review — CREED-33 · Form table context

> Revisão conjunta dos três PRs do épico, feita em 2026-09-28 sobre
> `origin/feat/331-form-table` (PR 23, `@BryanAlmerindo`),
> `origin/feat/332-implement-form-insert-and-search` (PR 24, `matheusbtguerra`) e
> `origin/feat/333-implement-form-insert-and-search-router` (PR 25, `matheusbtguerra`).
>
> Segue [`../../workflows/revisao.md`](../../workflows/revisao.md) e o checklist de
> [`../../checklists/revisao-de-codigo.md`](../../checklists/revisao-de-codigo.md).

## Veredito: Mudanças necessárias
Tier: **Sensível** — tem migration, e migration é sempre Sensível.
Escalada: **parcialmente cumprida** — ver o bloco no fim.

---

## O resumo em uma frase

O domínio `forms` está bem escrito e a suíte passa inteira, mas **nenhuma migration cria
a tabela `form`**. O épico entrega uma API funcionando em cima de uma tabela que não
existe — e o CI verde não acusa isso, porque todos os testes do domínio usam repository
falso e nenhum teste toca o banco.

O segundo problema é do mesmo tamanho: a revisão do Alembic aponta para o pai errado e
**abre um segundo head no `dev`**, o que trava `alembic upgrade head` para todo mundo,
não só para esta tarefa.

Os dois são do PR 23. O que o Matheus escreveu nos PRs 24 e 25 está, no geral, correto.

---

## Uma correção de atribuição, antes de qualquer cobrança

O `unique=True` em `organization_id` e o `keycloak_id` no `FormCreate` **vêm do commit
inicial `e886b02`**, que é a base comum das três branches. Depois dele o Bryan só
acrescentou a coluna `name`, o import no `env.py` e a migration.

Ou seja: não é "o Bryan errou e o Matheus corrigiu". É entulho de scaffold copiado do
molde de `users`, que o Matheus limpou ao reescrever os arquivos. Vale dizer isso em voz
alta para a cobrança cair no lugar certo.

---

## Exigências — @BryanAlmerindo (PR 23)

O PR 23 é o que carrega o risco todo. As quatro exigências abaixo são dele.

### 1. `alembic/versions/d9f1ff5bf65d_form_migration.py` — a migration não cria a tabela

O `upgrade()` inteiro é este:

```python
op.drop_index(op.f("uq_form_responses_form_id_vinculo_id"), table_name="form_responses")
op.create_unique_constraint("uq_form_responses_form_id_vinculo_id", "form_responses", [...])
```

Não tem `create_table("form", ...)` em lugar nenhum. E os PRs 24 e 25 não trazem
migration alguma — confirmei com `git ls-tree`: só as revisões que já existiam.

O que aconteceu, quase certamente: o autogenerate rodou contra um banco que **já tinha**
a tabela `form` de uma tentativa anterior, então não viu nada para criar — e devolveu
só a diferença que sobrou, que era de outra tabela.

**O que fazer:** apagar o conteúdo atual e escrever o `create_table` à mão, com as cinco
colunas da seção "Dados" da spec. Não confie no autogenerate aqui: rode
`docker compose down -v && docker compose up -d db` primeiro, para gerar contra banco
limpo, e confira linha a linha depois.

**Como saber que está certo:** `docker compose down -v && docker compose up -d db &&
alembic upgrade head`, e depois `docker compose exec db psql -U creed -d creed -c "\d form"`
mostrando as cinco colunas.

### 2. Mesmo arquivo, linha 19 — `down_revision` errado, dois heads no `dev`

Está `down_revision = "49ef1d2c7b7e"`. Essa revisão **não é mais o head do `dev`** — ela
já tem duas descendentes (`40c65a5d6177`, da CREED-31, e a merge `fa325a57c783`). O head
único do `dev` hoje é `00e64ebcc7be`.

Confirmei na prática: copiei o arquivo para um worktree do `origin/dev` e rodei
`alembic heads`. Devolveu dois heads. Quando este PR mesclar, **qualquer** `alembic
upgrade head` — deploy ou máquina local de qualquer pessoa — aborta com "Multiple head
revisions are present".

**O que fazer:** sincronizar a branch com o `dev` primeiro (ela está atrás e não tem as
migrations de `documents` nem de `answer`), e só então regerar a revisão. Nascendo sobre
o `dev` atualizado, o `down_revision` sai certo sozinho.

⚠️ **Não edite o `down_revision` à mão** — `conventions/migrations.md`, regra 3. Se ao
sincronizar aparecerem dois heads, a saída é `alembic merge`.

**A armadilha que quase pegou:** mesclando **só as três branches entre si**, `alembic
heads` devolve **um head** e tudo parece bem — porque a branch está atrás do `dev`. O
problema só aparece quando o `dev` entra. Sincronize antes de conferir, ou a conferência
mente.

### 3. Mesmo arquivo — a migration mexe em tabela de outro domínio

O que ela faz hoje é corrigir uma divergência da CREED-34: o `form_responses` tem a
unicidade declarada como `UniqueConstraint` no model e criada como índice único
(`op.create_index(..., unique=True)`) na migration `49ef1d2c7b7e`.

Dois problemas. A CREED-33 não deveria alterar `form_responses`. E a CREED-34 **ainda
está em review** — se a revisão dela corrigir a mesma coisa, este `drop_index` passa a
apontar para um objeto que já não existe, e o `upgrade` quebra com `UndefinedObject`.

**O que fazer:** tirar esses dois comandos da migration. A divergência é real e vale
reportar na review da CREED-34 — mas como achado, não como código aqui.

### 4. A forma da tabela: falta índice, e o enum tem um valor só

Duas coisas na declaração do model, que é o que a subtarefa 331 entrega:

- **`organization_id` sem índice.** O PR 24 tirou o `unique=True` errado (certo) mas não
  pôs `index=True` no lugar. Fica sem índice nenhum. A spec pede índice, e é a coluna do
  `WHERE` de "os formulários da minha organização" — a primeira consulta que vai existir.
  Compare com `app/domains/responses/models.py`, onde `form_id` e `vinculo_id` têm os
  dois.
- **`FormStatus` só tem `DRAFT`.** A spec pede `draft · published · closed`. Isso não é
  preciosismo de documentação: o tipo `formstatus` nasce no Postgres com um rótulo só, e
  acrescentar rótulo depois exige `ALTER TYPE ... ADD VALUE`, que o Postgres não deixa
  usar na mesma transação em que foi criado — ou seja, não sai num passo normal de
  Alembic. Com a tabela vazia, declarar os três agora é de graça. Depois, não é.
  O `FormResponseStatus` do vizinho já nasceu com os dois estados dele.

**O que fazer:** `index=True` em `organization_id` e os três valores no enum, no model e
na migration.

### 5. Falta `tests/domains/forms/test_models.py`

A subtarefa 331 previa teste de forma da tabela, e o molde para isso já existe em **três**
domínios vizinhos: `tests/domains/vinculos/test_models.py`,
`tests/domains/documents/test_models.py` e `tests/domains/responses/test_models.py`. Ele
lê `Form.__table__` direto, sem banco, e prova nulabilidade, índice, ausência de FK e os
valores do enum.

Não é pedido burocrático: **esse teste teria falhado nos três achados acima.** Hoje a
suíte passa com o `unique=True` dentro, sem índice e com o enum incompleto — rodei os 129
testes para confirmar.

**O que fazer:** copiar o de `vinculos` e adaptar.

---

## Exigências — @matheusbtguerra (PRs 24 e 25)

O código está bom. As duas exigências são pequenas.

### 6. Resolver o conflito de `models.py` a favor da sua versão

Os PRs 24 e 25 saíram do **primeiro commit** do PR 23, não do head dele, e os dois lados
editaram `models.py`. Fiz a mesclagem: conflita, e são exatamente **dois hunks** — a linha
de import do SQLAlchemy e o bloco do `organization_id`. Os dois resolvem a seu favor.

**Por que isso é exigência e não detalhe:** um `git checkout --ours` distraído devolve o
`unique=True` e o épico volta a aceitar um formulário por organização. E nenhum teste
acusa.

**O que fazer:** reempilhar o 24 sobre o head do 23 e o 25 sobre o 24, em vez dos três
apontarem para o `dev` direto. Aí a ordem de merge deixa de ser decisão de quem mescla.
Se preferir mesclar à mão, resolva e confira que o `models.py` final tem
`organization_id` sem `unique`, **com** `index=True`, e o `created_at` (esse entra por
auto-merge, sem conflito).

### 7. `repository.create` deveria chamar `insert`

`app/domains/forms/repository.py:23`. O contrato interno da spec fixa
`repository.insert(form)`, e `create` é o verbo que a spec reserva para o caso de uso do
service. Não quebra nada em execução, mas apaga justo a distinção que o projeto usa para
separar camada — a mesma regra que fez a spec recusar `service.get_by_id`. O próximo
domínio copiado de `forms` herda o borrão.

---

## Sugestões — não travam o merge

- `tests/domains/forms/test_router.py` monta um `FastAPI()` cru, sem o prefixo `/api/v1`,
  e o `expected_operations` do `tests/test_openapi.py` não ganhou `/api/v1/forms`. Ou
  seja: **nada prova que o registro em `app/main.py` funciona**. Uma linha no
  `expected_operations` resolve — e é o padrão que os outros domínios já seguem. (@matheusbtguerra)
- `_FakeService.create` ignora o payload e devolve sempre `FAKE_FORM`, então o teste de
  201 não prova que o corpo da requisição chega ao service. (@matheusbtguerra)
- Ao sincronizar com o `dev` vai aparecer um conflito pequeno no `alembic/env.py`, só de
  ordem de import — o isort do ruff cobra a ordem. Trivial, mas não se assuste. (@BryanAlmerindo)

---

## Sem dono nestes três PRs

**A entrega 4 do épico não foi feita.** O
[`context/modelo-de-dados.proposta.dbml`](../../context/modelo-de-dados.proposta.dbml)
linha 228 ainda mostra `Form` **sem** `name` e **com** `participant_id` — exatamente a
divergência que a spec criou uma subtarefa separada para fechar, junto com o desfecho
escrito das pendências #17 e #21.

O risco que a própria spec previu está de pé: alguém abre o modelo, não acha `name`, e
"corrige" o código apagando a coluna.

Isso não é do Bryan nem do Matheus — é a quarta subtarefa, e **precisa de alguém**. Não
bloqueia o merge dos três PRs, mas não deveria fechar o épico sem ela.

---

## O que foi verificado

- Diff completo dos três PRs, arquivo por arquivo, mais o contexto ao redor
  (`app/core/database.py`, `app/shared/exceptions.py`, molde de `users`, `responses`).
- `ruff check .` e `mypy app` no PR 25: limpos.
- `pytest` no PR 25 (51 testes do escopo) e na mesclagem dos três (**129 testes, a suíte
  inteira**): tudo passa. Inclusive `tests/test_arquitetura.py` — **nenhuma camada furada
  no domínio novo**, o que é mérito real.
- Grafo do Alembic no `dev` reconstruído revisão por revisão, e `alembic heads` rodado com
  a revisão nova dentro — é daí que vem a confirmação dos dois heads.
- Mesclagem real das três branches num worktree, com conflito resolvido, e depois o `dev`
  por cima — é daí que vem o mapa de quais achados a mesclagem resolve e quais sobrevivem.
- Camadas: `router` sem regra e sem import de `models`; `service` sem query e sem
  framework; `repository` sem `shared.exceptions`; nenhum `commit()` fora do `get_db`.
  Tudo certo.
- Contrato HTTP contra a spec: `POST` 201, `GET` 200/404, `422` nas bordas, `status` fora
  do corpo de entrada, `FormRead` no lugar de `FormResponse`. Tudo conforme, e a escolha
  do nome `FormRead` está bem justificada.

## O que NÃO foi verificado

Seja honesto ao ler esta lista — é ela que diz o tamanho da falsa segurança.

- **Nada rodou contra Postgres de verdade.** Não subi `docker compose up -d db`, não rodei
  `alembic upgrade head`, não olhei `\d form`. A conclusão de que a tabela não é criada vem
  de ler a migration, não de ver o banco falhar. É leitura confiável, mas não é execução.
- **Não conferi o `downgrade`** da migration nova contra banco real.
- **O comportamento com concorrência** não foi olhado: dois POSTs simultâneos para a mesma
  organização, o que o `flush()` sem `commit()` faz sob carga.
- **A divergência do `form_responses`** (índice único × `UniqueConstraint`) foi identificada
  mas **não investigada a fundo** — qual das duas formas é a certa é assunto da review da
  CREED-34, não desta.
- **Não avaliei a autorização.** A spec já declara como risco aceito que `POST /forms`
  aceita qualquer `organization_id` sem conferir e sem exigir token. Não questionei a
  decisão; só registro que ela continua valendo e que a API **não pode ir para ambiente
  que não seja o local** antes da amarração.
- **Não conferi o `creed-frontend`** — a spec diz que nada muda lá, e eu tomei isso como
  verdade sem olhar.
- **Não revisei a CREED-34 nem a CREED-35**, que fazem fronteira com esta.

---

## Escalada exigida — tier Sensível
Motivo do tier: **migration**.

- [x] Checklist aplicado — esta passada.
- [x] Passada com modelo pesado — esta passada rodou em **Opus 5**, em sessão aberta por
      gente, não pelo comando `/revisar`. Está cumprida.
- [ ] **Segunda leitura humana** — falta. Pelo `equipe.md`, quem mescla em `dev` é
      `@gabriellrmartins` ou `@Kv1ecz`; a leitura precisa ser de alguém que **não** seja o
      Bryan nem o Matheus.

A parte que mais pede o olho humano é a migration reescrita do item 1 — leia o
`create_table` linha a linha contra a seção "Dados" da spec, e rode
`docker compose down -v && docker compose up -d db && alembic upgrade head` antes de
aprovar. Esta revisão **não** fez isso.

---

## Ordem sugerida para sair disso

1. **Bryan** sincroniza `feat/331-form-table` com o `dev` e reescreve a migration
   (itens 1, 2, 3), ajusta a forma da tabela (item 4) e acrescenta o `test_models.py`
   (item 5).
2. **Matheus** reempilha o 332 sobre o head do 331 e o 333 sobre o 332 (item 6), e renomeia
   `create` → `insert` (item 7).
3. Merge na ordem 23 → 24 → 25, cada um com `alembic heads` conferido **depois** de
   sincronizar com o `dev`.
4. A entrega 4 (reconciliação do `.dbml`) ganha dono e fecha o épico.

Nota de cadastro: `matheusbtguerra` **não aparece** no
[`equipe.md`](../../equipe.md), que foi levantado em 2026-08-31. Vale acrescentar a linha.
