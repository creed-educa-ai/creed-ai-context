# Task 4 — Reconciliar o modelo de dados com a tabela que foi criada

**Repo:** `creed-ai-context`
**Depende de:** task 1 — só dá para descrever o que existe depois que a migration existe

## Objetivo

O modelo de dados do time volta a descrever a tabela `form` como ela existe de verdade no
banco: **com `name`, sem `participant_id` e sem a relação `Form → Participant`** — e a
decisão que produziu cada uma fica registrada onde quem lê o modelo vai procurar.

## Por que isto é tarefa própria, e não um item da task 1

Três motivos, e o primeiro é regra do projeto:

1. **Ela não vive no mesmo repositório.** A task 1 entrega migration no `creed-backend`; o
   modelo de dados mora no `creed-ai-context`, e o desenho de verdade mora no dbdiagram.io.
   [`workflows/spec-to-tasks.md`](../../workflows/spec-to-tasks.md) diz que **uma task não
   cruza repos**, e o [`checklists/definition-of-ready.md`](../../checklists/definition-of-ready.md)
   cobra o mesmo na subtarefa publicada.
2. **Ela não é verificável no mesmo PR.** O "pronto quando" da task 1 é `alembic upgrade`
   e `pytest`; o desta é um diff de documentação e um diagrama reexportado. Pendurar um no
   outro faz o CI de um repo bloquear o merge do outro, que é exatamente o acoplamento que
   ninguém quer.
3. **O ator é outro.** Quem escreve a migration é dev de backend; quem reexporta o
   dbdiagram é quem tem acesso ao diagrama do time.

**O que a task 1 ganha em troca:** uma frase apontando para cá. É o que impede alguém de
abrir o `.dbml`, ver que não tem `name`, e "corrigir" o código apagando a coluna.

## Contexto que você não tem como adivinhar

O modelo de dados do CREED tem **três camadas de verdade**, e é fácil confundir:

| Onde | O que é |
|---|---|
| dbdiagram.io | o desenho que o time fez em conjunto — a fonte da qual tudo sai |
| `context/modelo-de-dados.dbml` | cópia literal do export do dbdiagram, como ele está hoje |
| `context/modelo-de-dados.proposta.dbml` | a **correção** fechada em 2026-09-04, que ainda não foi colada de volta no dbdiagram |

A regra em vigor é: **não gerar migration a partir do `.dbml`** — o export atual tem dois
pontos que impedem o DDL de subir, e é a `proposta.dbml` que os corrige. Na prática, é a
`proposta.dbml` que as tarefas de tabela estão lendo.

Esta tarefa mexe na **`proposta.dbml`** e no `modelo-de-dados.md` que a explica. Colar de
volta no dbdiagram e reexportar é o passo seguinte, e ele depende do time aceitar a
proposta inteira — não cabe aqui. Ver "O que não entra".

## As duas divergências desta rodada

| O que o modelo diz | O que a migration criou | Decisão |
|---|---|---|
| `Form` não tem coluna de nome | `form.name`, `String(200)`, obrigatória, sem unicidade | P-016 |
| `Form.participant_id uuid` existe | a coluna não foi criada | P-018 |
| `Ref: Form.participant_id > Participant.id` — a **relação** entre formulário e participante | nenhuma relação entre as duas tabelas | P-018 |

> ⚠️ **A `participant_id` custa duas edições no `.dbml`, não uma.** Tirar a coluna de
> dentro do bloco `Table Form` **não** remove a relação: a seta vive numa linha `Ref:`
> separada, no fim do arquivo, e um `.dbml` com `Ref:` apontando para coluna que não existe
> **não carrega no dbdiagram** — o editor recusa o arquivo inteiro. São três mexidas, então:
> a coluna, a linha `Ref:` e a contagem de FKs do cabeçalho.

As duas nasceram de pendências que o próprio `modelo-de-dados.md` registra em aberto — a
**#17** (*"`Form` não tem título nem descrição. Como o gestor identifica um formulário numa
lista?"*) e a **#21** (*"O que `Form.participant_id` significa agora?"*). Esta tarefa não
inventa resposta: ela **anota a resposta que já foi dada** e de onde ela veio.

## Arquivos que provavelmente mudam

- `context/modelo-de-dados.proposta.dbml` — a tabela `Form`, com o comentário de origem
- `context/modelo-de-dados.md` — as pendências #17 e #21, e o registro da divergência

## O que fazer, concretamente

**1. Na `proposta.dbml`**, a tabela `Form` passa a ser:

```
// [C29] name ENTRA (P-016, CREED-33). O modelo não tinha como identificar um formulário
//       numa lista — a pendência #17. Sem unicidade: dois formulários com o mesmo nome
//       na mesma organização são aceitos.
// [C30] participant_id SAI (P-018, CREED-33). A pendência #21 perguntava o que a coluna
//       significa; com o dono sendo a organização ([C1]) e as respostas vindo de N
//       vínculos, a leitura adotada é que ela é resquício do mesmo engano do creator_id.
//       Volta como coluna nulável se a cliente confirmar que formulário nominal existe.
Table Form {
  id uuid [pk, default: `uuid()`]
  name string [not null]
  organization_id uuid [not null]
  status FormStatus [not null, default: 'draft']
  created_at datetime [default: `now()`]

  indexes {
    organization_id
  }
}
```

Os números `[C29]` e `[C30]` são os próximos livres — **confira** antes de usar, porque
outra tarefa pode ter gasto um deles.

**2. Retire o `Ref: Form.participant_id > Participant.id`** da lista de referências no fim
do arquivo, e **acerte a contagem do cabeçalho** (ele diz "14 tabelas · 9 enums · 21 FKs").

**3. No `modelo-de-dados.md`**, as pendências #17 e #21 deixam de ser perguntas abertas e
passam a ter desfecho, com o ID da premissa e o da tarefa. Mantenha a linha original
visível — o padrão do arquivo é registrar o desfecho ao lado, não apagar a pergunta.

**4. Enquanto estiver lá, confira e reporte** — **não corrija** — duas divergências que
vêm de outras tarefas e cuja decisão é delas, não desta:

- **`Answer.form_response_id`**: a CREED-31 decidiu não criar essa coluna na primeira
  rodada. O modelo a traz como `not null`.
- **`FormResponse` sem nenhum índice**: a migration da CREED-34 (`49ef1d2c7b7e`, em
  review) cria só a chave primária. O modelo pede índice em `form_id`, em `vinculo_id`
  **e um `unique (form_id, vinculo_id)`** — este último é a correção `[C5]`, que existe
  para impedir o mesmo vínculo responder o mesmo formulário cinco vezes. ⚠️ **Isso é
  regra de integridade caindo em silêncio, e a PR ainda está aberta** — levar para a
  revisão da CREED-34 vale mais do que anotar aqui.

## O que não entra

- **Colar a proposta no dbdiagram e reexportar por cima de `modelo-de-dados.dbml`.** É o
  passo 1 da lista "Quando o modelo for aceito" do `modelo-de-dados.md`, e ele depende do
  time aceitar a proposta **inteira** — não só estas duas linhas. Fazer só o pedaço do
  `Form` deixaria o diagrama num estado misto, que é pior que o atual.
- **Corrigir as divergências de `Answer` e `FormResponse`.** São de outras tarefas. Aqui
  só se confere e se reporta.
- **A divergência da tabela `user`.** Já está documentada no `modelo-de-dados.md` → "A v1
  e a autenticação", e continua sem decisão. Não é desta tarefa abri-la.

## Critérios de aceite

- [ ] `proposta.dbml` → `Table Form` tem `name string [not null]` e **não** tem
      `participant_id`.
- [ ] O comentário acima da tabela diz **qual premissa** produziu cada mudança e **qual
      tarefa**.
- [ ] O `Ref:` de `Form.participant_id` saiu, e a contagem de FKs do cabeçalho bate com o
      número de linhas `Ref:` do arquivo.
- [ ] As pendências #17 e #21 do `modelo-de-dados.md` têm desfecho escrito, com o ID da
      premissa — e a pergunta original continua legível.
- [ ] As duas divergências de `Answer` e `FormResponse` estão **reportadas por escrito**
      (no PR ou na tarefa), com o aviso sobre o `unique` da `FormResponse`.
- [ ] Nenhuma migration foi gerada a partir deste arquivo.

## Como testar

Não há teste automático: a saída é documentação. A conferência é por leitura.

```bash
cd creed-ai-context
grep -n -A 12 '^Table Form' context/modelo-de-dados.proposta.dbml
grep -c '^Ref:' context/modelo-de-dados.proposta.dbml   # tem que bater com o cabeçalho
grep -n 'participant_id' context/modelo-de-dados.proposta.dbml
```

**Caso de borda:** a terceira linha não pode devolver nenhuma ocorrência ligada a `Form` —
`Vinculo.participant_id` e `Ref: Vinculo.participant_id > Participant.id` **continuam** e
são de outra tabela.

## Premissas aplicáveis

- **P-016** — o formulário tem nome, sem unicidade. É a premissa que esta tarefa
  materializa no modelo.
- **P-018** — formulário é da organização, não de uma pessoa. Idem.

As duas foram **✅ confirmadas em 2026-09-21, por decisão dos AGES IV** (não da cliente).
Estão na seção "Fechadas" do ledger. **Não vão mais para a pauta** — e é por isso que esta
tarefa deixou de ser opcional: com a premissa fechada, o modelo é a única coisa que ainda
contradiz o banco.

⚠️ **Uma ressalva que precisa aparecer no diff desta tarefa:** P-018 fechou a **premissa**
(não criamos a coluna), **não a pendência #21** (*"existe formulário feito sob medida para
uma pessoa específica?"*). Aquela é lacuna de **produto**, está na lista que vai para a
cliente, e continua aberta. Ao escrever o comentário `[C30]` e ao mexer na pendência #21
do `modelo-de-dados.md`, **não escreva que a #21 foi respondida** — escreva que a decisão
de não criar a coluna foi tomada, e que a pergunta de produto segue de pé.
