# 86e3anvpm — CREED-35 · Question

> Gerada por `workflows/tarefa-to-spec.md` em 2026-09-22, a partir da tarefa
> [CREED-35](https://app.clickup.com/t/86e3anvpm) e das três subtarefas publicadas
> ([351](https://app.clickup.com/t/86e3ap1dm) · [352](https://app.clickup.com/t/86e3apg22) ·
> [353](https://app.clickup.com/t/86e3apgm5), todas ainda sem descrição no board).
>
> **Revista no mesmo dia, antes das tasks**, com duas decisões do time: (1) a CREED-33 e
> a CREED-35 são entregues **em paralelo**, e a integração entre tabelas e domínios fica
> para a tarefa de amarração — a mesma linha da decisão de 2026-09-19 ("migrations
> isoladas agora, amarração depois"); (2) por isso, `Question` nasce num domínio próprio,
> `questions`, e não dentro de `forms`. A primeira versão desta spec punha a CREED-33
> como pré-requisito; isso caiu.
>
> **Revista de novo em 2026-09-22, depois da publicação**, por decisão do time: a pergunta
> ganha uma **seção** (`section`), um enum que o front usa para decidir em que parte do
> formulário a pergunta é desenhada, e a listagem passa a poder filtrar por ela. Nas
> quatro escolhas que isso abriu, o time respondeu: a seção é independente do prisma; o
> filtro vale dentro de um formulário, não entre formulários; a posição continua única
> no formulário inteiro; e os valores do enum **ainda não estão definidos**, o que virou
> a P-020. A mudança recalibrou a tarefa de P2 para P3 e criou a task 4.

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | **Três premissas novas, e uma delas com custo alto depois.** A P-019: a tarefa promete "cadastrar e editar", mas o contrato só lista `POST` e `GET`. A P-020: o time decidiu que a pergunta tem seção, mas **os valores do enum não estão definidos**; a lista é provisória, e trocar valor de enum quando já houver pergunta gravada é migration mais atualização de dado. A P-028: toda pergunta tem seção. Recalibrado de P2 em 2026-09-22. |
| Técnico | T3 | **Migration** (tabela `questions` nova), e um sinal já basta. Reforçam: **domínio novo** (`app/domains/questions/`), **contrato de API novo**, uma revisão Alembic gerada **ao mesmo tempo** que a da CREED-33 a partir do mesmo head, e agora uma coluna que o modelo de dados não tem. |

Dispensadas nesta calibragem: nenhuma.

## Problema

Um formulário não tem onde guardar as perguntas. O banco tem `user` e `form_responses`,
e a CREED-33 está criando `form` em paralelo, mas nenhuma tabela diz "esta é a
pergunta 3 do formulário X, é obrigatória e é descritiva". Sem isso, o formulário é uma
casca que ninguém consegue preencher, e a alternativa de múltipla escolha (CREED-37) e
a resposta a uma pergunta (CREED-31) não têm para onde apontar.

Três coisas estavam em aberto, e esta spec resolve as três:

1. **O que "editar" quer dizer aqui.** Ver Calibragem. Virou a P-019.
2. **Onde a pergunta mora.** A spec da CREED-33 tinha decidido que `Form`, `Question` e
   `QuestionOption` ficariam juntos em `app/domains/forms/`. Essa decisão supunha
   entregas em sequência. Com as duas em paralelo, dois PRs criariam os mesmos arquivos
   ao mesmo tempo. O time escolheu o domínio isolado `questions`, que é também o que a
   tarefa pedia. Ver "Abordagem técnica", item 1.
3. **Como o front sabe em que parte do formulário desenhar cada pergunta.** A tabela
   guarda a posição, mas não o agrupamento. Sem um campo para isso, o front teria de
   deduzir a seção pela posição ou pelo tipo, e a regra ficaria escondida na tela. O
   time decidiu que a pergunta carrega a própria seção. Ver "Abordagem técnica", itens
   8 a 10.

## Quem usa

| Papel | O que muda |
|---|---|
| **Administrador** / **Gestor**: quem monta os instrumentos | passa a conseguir cadastrar as perguntas de um formulário e listar as que já existem, pela API (Swagger ou `curl`). Nenhuma tela do front muda. |
| **Administrador** / **Gestor**, na mesma ação | escolhe a seção de cada pergunta ao cadastrá-la |
| **Respondente** | nada muda nesta rodada: não existe tela de resposta nem formulário publicado. Quando a tela existir, é para essa pessoa que a seção importa: é ela quem vê o formulário dividido em partes |
| Quem desenvolve o front | ganha, em cada pergunta, o campo que diz em que seção ela é desenhada, e uma consulta que devolve só as perguntas de uma seção |
| Quem desenvolve o back | ganha o alvo de `answer.question_id` (CREED-31) e de `question_option.question_id` (CREED-37) |

Como na CREED-33, **nada confere que o formulário existe, nem que quem chama pertence à
organização dona dele**. Ver "Riscos".

## Escopo

**Entra:**

- Domínio novo `app/domains/questions/`, na forma do molde `app/domains/users/`.
- `models.py` com a tabela `questions` e os enums `QuestionType`, `Prisma` e
  `QuestionSection`.
- Uma migration Alembic isolada que cria **só** esta tabela, e o import do model em
  `alembic/env.py`.
- `repository.py`: `insert`, `list_by_form` (com filtro opcional por seção),
  `get_by_form_and_order`.
- `service.py`: regra de criação (a posição já está ocupada?) e de listagem.
- `schemas.py`: `QuestionCreate` (entrada) e `QuestionResponse` (saída).
- `dependencies.py` e `router.py`: `POST /api/v1/questions` e
  `GET /api/v1/forms/{form_id}/questions`, com o filtro `?section=`, registrados em
  `app/main.py`.
- Testes em `tests/domains/questions/`: a forma da tabela, a regra do service e o
  contrato HTTP.
- **No `creed-ai-context`:** o modelo de dados passa a descrever a coluna `section` e o
  enum `QuestionSection`, que o `.dbml` não tem. É a task 4, e é a única que sai do
  `creed-backend`.

**Não entra, e por quê:**

- **Editar e apagar pergunta** (`QuestionUpdate`). É a P-019: o contrato publicado na
  tarefa não tem endereço para isso. O schema de update nasce junto do endpoint que o
  usa. Criar agora seria código sem uso.
- **Conferir que o formulário existe.** A tabela `form` está nascendo em paralelo, em
  outro domínio, e um domínio não importa outro (`tests/test_arquitetura.py`). Fica
  para a amarração.
- **`ForeignKey` em `form_id`.** Mesmo motivo. Fica para a amarração, como
  `form_responses.form_id` e `form.organization_id` já ficaram.
- **Alternativas de múltipla escolha** (`QuestionOption`). São a CREED-37.
- **Mover `Question` para `app/domains/forms/`.** Se o time quiser juntar os domínios,
  isso é trabalho da amarração, não desta tarefa.
- **Verificar se quem chama pertence à organização do formulário.** Depende de
  `Vinculo`, que não tem tabela.
- **Título, descrição e ordem de exibição das seções.** A seção é um valor de enum, não
  uma entidade. O texto que aparece na tela é tradução do front (chave de i18n por
  valor), e a ordem em que as seções aparecem também é decisão do front. Se o gestor
  precisar escrever o título de uma seção ou criar seções por formulário, isso vira
  tabela própria. Ver "Abordagem técnica", item 8.
- **Consultar perguntas por seção entre formulários** (`GET /api/v1/questions?section=`).
  Sem filtro por organização, essa rota mostraria perguntas de todas as organizações a
  qualquer pessoa. É o mesmo motivo que tirou a listagem geral da CREED-33.
- **Front.** Nada muda no `creed-frontend` nesta entrega. A tela que desenha o
  formulário por seção é outra tarefa, e é ela que consome este contrato.

## Repos afetados

| Repo | O que muda |
|---|---|
| `creed-backend` | domínio novo `app/domains/questions/` · uma revisão Alembic · import em `alembic/env.py` · registro em `app/main.py` · testes em `tests/domains/questions/` |
| `creed-ai-context` | esta spec · `glossario.md` (as entradas "Formulário", "Pergunta" e "Seção") · `decisoes/premissas.md` (P-019, P-020 e P-028) · uma nota na spec da CREED-33 dizendo que a decisão dela sobre o domínio mudou · **task 4**: `context/modelo-de-dados.proposta.dbml` e `context/modelo-de-dados.md` passam a descrever `section` |
| `creed-frontend` | nada |
| `creed-infrastructure` | nada |

Nome do domínio: **`questions`**, em inglês e no plural
([ADR-0005](../../decisoes/adrs/0005-idioma-do-codigo.md) e
[`estrutura-e-nomes.md`](../../conventions/estrutura-e-nomes.md)). Não há feature de
front espelhando, porque esta entrega não toca o front.

**A tabela passa a divergir do modelo de dados em um ponto: a coluna `section`.** O
resto bate com `Question` no `.dbml`, e `text` como `Text` é só a tradução de `string`
sem tamanho. A divergência tem dono, a task 4, pelo mesmo motivo que a CREED-33 criou a
entrega 4 dela: quem abrir o modelo e não achar a coluna tende a "corrigir" o código
apagando-a.

## Contrato

Tudo `async`, como no molde (`AsyncSession`).

### Contrato HTTP

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/questions` | `QuestionCreate` | `QuestionResponse` · **201** |
| GET | `/api/v1/forms/{form_id}/questions` | `?section=<valor>`, **opcional** | `list[QuestionResponse]` · **200** |

Sem `section`, o `GET` devolve todas as perguntas do formulário. Com `section`, devolve
só as daquela seção. Nos dois casos a lista vem em ordem de `order_index`.

**`QuestionCreate`**

```json
{
  "form_id": "uuid",
  "text": "string",
  "order_index": 0,
  "type": "objective | descriptive",
  "section": "profile | assessment | closing",
  "required": true,
  "prisma": "plasticidade_humana | empreendedorismo | multiculturalismo | neuroinovacao | tomada_decisao | null"
}
```

`required` e `prisma` são opcionais na entrada: `required` vale `true` por padrão e
`prisma` vale `null`. É exatamente o que as colunas do `.dbml` dizem
(`context/modelo-de-dados.proposta.dbml`, tabela `Question`). O tipo `objective` é a
pergunta de múltipla escolha, e `descriptive` é a de resposta livre. A tarefa usa esses
nomes em português ("múltipla escolha ou descritiva").

`section` é **obrigatório** e não tem valor padrão (P-028).

> 🟡 **Premissa P-020**: os valores `profile`, `assessment` e `closing` são
> **provisórios**. O time decidiu que a seção existe, mas não quais são as seções. Esta
> lista existe para que o contrato, a tabela e os testes tenham com o que trabalhar.
> Confirmar com o time antes da primeira pergunta real ser gravada.

**`QuestionResponse`**

```json
{
  "id": "uuid",
  "form_id": "uuid",
  "text": "string",
  "order_index": 0,
  "type": "objective",
  "section": "assessment",
  "required": true,
  "prisma": null,
  "created_at": "2026-09-22T14:00:00Z"
}
```

**Erros**

| Código | Quando | Endpoint |
|---|---|---|
| 409 | já existe pergunta com o mesmo `(form_id, order_index)` | POST |
| 422 | corpo fora do formato (`text` vazio, `order_index` negativo, `section` ausente, `type`/`section`/`prisma` fora do enum, `form_id` que não é UUID) | POST |
| 422 | `?section=` com valor que não está no enum | GET |

**Não existe 404.** Como nada confere se o formulário existe, `GET` de um `form_id` que
ninguém criou devolve **200 com lista vazia**, igual a um formulário real sem nenhuma
pergunta. Isso é consequência declarada da entrega em paralelo, não um descuido. O 404
entra com a amarração.

### Contrato interno entre camadas

| Camada | Assinatura | Devolve |
|---|---|---|
| `repository.insert(question: Question)` | a entidade já montada | `Question` gravada, com `id` e `created_at` preenchidos |
| `repository.list_by_form(form_id: UUID, section: QuestionSection \| None = None)` | — | `list[Question]` em ordem de `order_index`; com `section`, só as daquela seção. O filtro é `WHERE` na consulta |
| `repository.get_by_form_and_order(form_id: UUID, order_index: int)` | — | `Question` **ou `None`**. O repository não levanta erro. |
| `service.create(dados: QuestionCreate)` | o payload já validado | `Question` criada, ou `ConflictError` |
| `service.list_for_form(form_id: UUID, section: QuestionSection \| None = None)` | — | `list[Question]` |

O service nomeia o caso de uso e o repository nomeia o acesso
([`camadas-do-back.md`](../../conventions/camadas-do-back.md) → "Nome do método diz de
qual camada é").

## Dados

A tabela é `questions`. A migration desta rodada cria **exatamente** isto:

| Coluna | Tipo | Nulo? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, `default=uuid.uuid4` |
| `form_id` | `UUID` | não | **sem `ForeignKey`** nesta rodada |
| `text` | `Text` | não | sem limite de tamanho |
| `order_index` | `Integer` | não | a posição da pergunta no formulário |
| `type` | `Enum(QuestionType)` | não | `objective` · `descriptive` |
| `section` | `Enum(QuestionSection)` | não | `profile` · `assessment` · `closing`, **provisórios** (P-020). Obrigatória e sem default (P-028). **Não está no `.dbml`**: é a task 4 |
| `required` | `Boolean` | não | `default=True` |
| `prisma` | `Enum(Prisma)` | **sim** | os 5 valores do `.dbml` |
| `created_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |

Índices: `form_id`, e `UniqueConstraint(form_id, order_index)`. O `.dbml` pede os dois.
`section` **não** ganha índice. O filtro sempre vem junto de `form_id`, e o índice de
`form_id` já reduz a busca às perguntas de um formulário, que são dezenas.

Os valores dos enums nesta tabela são os que a **API** usa. No banco, o tipo guarda o
**nome** do membro (`PROFILE`, `OBJECTIVE`, `TOMADA_DECISAO`), que é o comportamento
padrão do SQLAlchemy e o que `user` e `form_responses` já fazem. Não há conversão a
escrever. Só importa para quem consultar direto no `psql`, e para a task 4, que precisa
descrever isso no modelo sem fingir que o banco guarda minúsculas.

**Dado existente:** nenhum. A tabela nasce vazia.

**O que fica para a tarefa de amarração:** a `ForeignKey` de `questions.form_id` para
`form.id`. Quando ela for criada, o banco vai recusar toda pergunta cujo `form_id` não
exista na tabela `form`. Ver "Riscos".

## Abordagem técnica

### Escolhido: domínio `questions` isolado, tabela `questions`, sem FK, um router com dois caminhos

**1. Domínio próprio, `app/domains/questions/`.** A CREED-33 e a CREED-35 andam em
paralelo. No mesmo domínio, os dois PRs criariam os mesmos oito arquivos
(`models.py`, `router.py`, `service.py`...) ao mesmo tempo. Separados, os dois PRs não
tocam nenhum arquivo em comum, exceto `alembic/env.py` e `app/main.py`, onde cada um
acrescenta uma linha.

*Descartado:* `Question` dentro de `app/domains/forms/`, como decidia a spec da
CREED-33 (item 1 da "Abordagem técnica"). Esse desenho continua sendo o melhor para o
estado final, porque são um assunto só. Mas ele supunha que as entregas viriam em
sequência. Em paralelo, quem mesclasse por último teria de juntar à mão oito arquivos
nascidos em duas branches. O motivo daquela decisão também perde força agora: o
problema era a pergunta precisar importar `Form` para conferir que o formulário existe,
e nesta rodada ela não confere. Se o time quiser juntar os domínios, isso é trabalho da
amarração.

**2. A tabela se chama `questions`, no plural.** Segue
[`estrutura-e-nomes.md`](../../conventions/estrutura-e-nomes.md) ("Tabela:
`snake_case`, plural") e `form_responses`, que já está no plural. As tabelas `user` e
`form` são singulares. A ordem de prioridade do `CONTEXT.md` põe a convenção escrita
(nível 4) acima do código que já existe (nível 5), então aquelas duas são desvio e não
padrão a copiar.

*Descartado:* `question`, no singular, para ficar igual a `form`. Seria repetir uma
inconsistência já apontada, contra a única regra escrita sobre o assunto.

**3. `form_id` nasce sem `ForeignKey`, e o service não confere se o formulário
existe.** É o padrão que a CREED-34 abriu (`form_responses.form_id`) e que a CREED-33
repetiu (`form.organization_id`). Aqui ele é ainda mais necessário: a tabela `form` pode
não existir quando esta migration rodar.

*Descartado:* conferir que o formulário existe chamando o domínio `forms`. Seria
importar de outro domínio, o que `tests/test_arquitetura.py` reprova, e de um domínio
que talvez nem esteja mesclado ainda.

**4. `text` é `Text`, sem limite de tamanho.** O `.dbml` diz só `string`, e o campo é o
enunciado de uma pergunta. Um limite arbitrário cortaria texto legítimo, e no Postgres
`TEXT` não custa mais do que `VARCHAR(n)`.

*Descartado:* copiar o `String(200)` do molde. Serve para um nome, mas é curto para o
enunciado de uma pergunta.

**5. O enum `Prisma` nasce em `app/domains/questions/models.py`.** Este é o primeiro
lugar do código que precisa dele. O domínio `prismas` existe como pasta, mas o
`models.py` de lá está vazio. A regra dos dois usos
([`camadas-do-back.md`](../../conventions/camadas-do-back.md) → "Onde mora o
compartilhado") diz que o primeiro uso fica no domínio, e só o segundo sobe para
`app/shared/`.

*Descartado:* criar o enum já em `app/shared/`, o que adiantaria uma subida que a regra
guarda para o segundo uso. Também descartado: criá-lo em `prismas/models.py`, o que
faria `questions` importar de outro domínio.

**6. Um router só, sem prefixo, com os dois caminhos escritos por inteiro.** O contrato
pede `/questions` e `/forms/{form_id}/questions`, que não têm prefixo em comum. Então
`router = APIRouter(tags=["questions"])` recebe `@router.post("/questions")` e
`@router.get("/forms/{form_id}/questions")`. `app/main.py` continua recebendo **um**
router deste domínio, como recebe dos outros.

*Descartado:* `prefix="/questions"` com a listagem virando
`GET /api/v1/questions?form_id=...`. Seria mais simples, mas muda o contrato publicado
na tarefa. Também descartado: dois routers no mesmo domínio, o que seria um padrão novo
sem ganho.

**7. A regra "uma pergunta por posição" é conferida no service, antes do insert.** É o
mesmo jeito que `UserService.create_user_service` confere e-mail repetido: pergunta ao
repository e, se já existe, levanta `ConflictError`. A `UniqueConstraint` continua no
banco como última proteção.

*Descartado:* deixar o Postgres levantar `IntegrityError` e traduzir o erro no router.
Funcionaria, mas o molde não trata erro assim em lugar nenhum. Seria o primeiro
`except IntegrityError` do projeto.

> ⚠️ A conferência no service tem uma janela: dois `POST` simultâneos com a mesma
> posição podem passar os dois pela conferência. Nesse caso a `UniqueConstraint` barra o
> segundo, que sai como **500** em vez de 409. Aceitamos isso nesta rodada: quem monta
> um formulário é uma pessoa só, e a tela ainda nem existe.

### Acrescentado em 2026-09-22: a seção

**8. A seção é um enum, numa coluna da própria `questions`.** É o que o time pediu, e
segue a forma que `type` e `prisma` já têm: `class QuestionSection(enum.Enum)` no
`models.py` do domínio e `Enum(QuestionSection)` na coluna. O texto de cada seção na
tela vem da tradução do front, uma chave de i18n por valor. Com isso, o valor gravado é
inglês e estável, e o que a pessoa lê é português.

*Descartado:* uma tabela `form_section` (id, form_id, título, ordem), com
`questions.section_id` apontando para ela. É o desenho certo **se** cada formulário
tiver seções próprias, ou se o gestor tiver de escrever o título de cada seção. Mas
seria uma entidade nova, com cadastro próprio e mais uma ligação sem alvo nesta rodada,
e o time pediu um enum. Se o produto evoluir para "seções por formulário", a migração é
aditiva: nasce a tabela, e `section` vira chave para ela.

**9. O filtro é um parâmetro opcional da rota que já existe.** Fica
`GET /api/v1/forms/{form_id}/questions?section=assessment`. Sem o parâmetro, a rota
devolve tudo, como antes. O filtro é `WHERE section = :section` na consulta do
repository, não um `if` sobre a lista no service, pelo princípio nº 1 do projeto: filtro
e agregação ficam no banco. O FastAPI valida o valor contra o enum e devolve 422 sozinho
para um valor desconhecido.

*Descartado:* `GET /api/v1/questions?section=`, que atravessa formulários. Sem filtro por
organização, a rota exporia perguntas de todas as organizações a qualquer pessoa, o
mesmo motivo que tirou a listagem geral da CREED-33. Também descartado:
`GET /api/v1/forms/{form_id}/sections/{section}/questions`, uma rota a mais para o
mesmo resultado, e uma rota que faria a seção parecer um recurso com identidade própria,
o que ela não é.

**10. A posição continua única no formulário inteiro, e não dentro da seção.** A regra
de conflito e a `UniqueConstraint(form_id, order_index)` não mudam. A seção agrupa, e a
posição global ordena as perguntas dentro de cada grupo. O front desenha uma seção com
as perguntas dela, na ordem de `order_index`.

*Descartado:* `UniqueConstraint(form_id, section, order_index)`, com cada seção
recomeçando do zero. É mais natural para quem digita as posições, mas muda a regra de
conflito já escrita nas tasks 2 e 3, e abre um caso sem resposta: duas perguntas na
posição 0 em seções diferentes, listadas sem filtro, aparecem em que ordem?

> ⚠️ **Consequência a conhecer:** mudar uma pergunta de seção não mexe na posição dela.
> A ordem entre as seções na tela é decisão do front, e não sai de `order_index`. Se o
> gestor numerar as perguntas de uma seção "depois" das de outra, isso é convenção de
> uso, não regra do sistema.

## Critérios de aceite

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro, **tenha a CREED-33
      mesclado ou não**.
- [ ] `alembic heads` devolve **um único head**.
- [ ] `\d questions` mostra exatamente as nove colunas da seção "Dados", com os mesmos
      tipos e a mesma nulabilidade.
- [ ] `section` é `NOT NULL`, sem default, e aceita só os valores de `QuestionSection`.
- [ ] A tabela **não** tem nenhuma `ForeignKey`.
- [ ] Existe índice em `form_id` e `UniqueConstraint` em `(form_id, order_index)`.
- [ ] O model está importado em `alembic/env.py`, e a revisão gerada **não** está vazia.
- [ ] `service.create` levanta `ConflictError` quando `(form_id, order_index)` já existe.
- [ ] `service.create` cria a pergunta com `required = True` e `prisma = None` quando
      esses campos não vêm na entrada.
- [ ] `service.list_for_form` com `section` devolve só as perguntas daquela seção, e sem
      `section` devolve todas.
- [ ] `POST /api/v1/questions` devolve **201** com o corpo de `QuestionResponse`, **409**
      para posição repetida no mesmo formulário e **422** para corpo inválido, inclusive
      sem `section`.
- [ ] `GET /api/v1/forms/{form_id}/questions` devolve **200**, com a lista em ordem de
      `order_index`, e lista vazia quando o formulário não tem nenhuma pergunta.
- [ ] `GET /api/v1/forms/{form_id}/questions?section=<valor>` devolve só as perguntas
      daquela seção, ainda em ordem de `order_index`; com um valor fora do enum, devolve
      **422**.
- [ ] O modelo de dados (`context/modelo-de-dados.proposta.dbml` e
      `context/modelo-de-dados.md`) descreve a coluna `section` e o enum, com a
      premissa P-020 citada (task 4).
- [ ] Nenhum arquivo de `app/domains/questions/` importa de `app.domains.forms`.
- [ ] Nenhum `commit()` no diff fora de `app/core/database.py`.
- [ ] A migration gerada foi **lida linha a linha**, e quem leu consegue dizer o que cada
      comando faz.
- [ ] `pytest tests/test_arquitetura.py` passa.

## Como verificar

```bash
cd creed-backend
docker compose up -d db
alembic current
alembic heads
alembic upgrade head
ruff check . && mypy app && pytest
```

Conferir a forma da tabela no banco:

```bash
docker compose exec db psql -U creed -d creed -c "\d questions"
```

Exercitar o contrato de ponta a ponta. Qualquer UUID serve de `form_id`, porque nada
confere a existência dele nesta rodada:

```bash
uvicorn app.main:app --reload
# outro terminal:
curl -i -X POST localhost:8000/api/v1/questions \
  -H 'Content-Type: application/json' \
  -d '{"form_id":"00000000-0000-0000-0000-000000000001","text":"Você se sente confiante para tomar decisões sozinho?","order_index":0,"type":"objective","section":"assessment"}'

curl -i -X POST localhost:8000/api/v1/questions \
  -H 'Content-Type: application/json' \
  -d '{"form_id":"00000000-0000-0000-0000-000000000001","text":"Qual é a sua área de atuação?","order_index":1,"type":"descriptive","section":"profile"}'

curl -i localhost:8000/api/v1/forms/00000000-0000-0000-0000-000000000001/questions
curl -i "localhost:8000/api/v1/forms/00000000-0000-0000-0000-000000000001/questions?section=profile"
```

A primeira listagem traz as duas perguntas; a segunda, só a de `profile`.

Casos de borda que precisam passar. Repetir a posição no mesmo formulário devolve
**409**, e não 500. Uma seção que não existe devolve **422**:

```bash
curl -i -X POST localhost:8000/api/v1/questions \
  -H 'Content-Type: application/json' \
  -d '{"form_id":"00000000-0000-0000-0000-000000000001","text":"outra pergunta","order_index":0,"type":"descriptive","section":"closing"}'

curl -i "localhost:8000/api/v1/forms/00000000-0000-0000-0000-000000000001/questions?section=inexistente"
```

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-019 | Esta entrega cobre só criar e listar perguntas. Editar e apagar ficam para uma tarefa futura, apesar de o resumo da tarefa falar em "editar". | baixo: um endpoint de edição é uma rota a mais e um método de service, sem migration |
| P-020 | As seções são, **provisoriamente**, `profile` (quem responde e o contexto dela), `assessment` (o núcleo do instrumento) e `closing` (fechamento e reflexão). O time decidiu que a seção existe, mas não quais são as seções. | **baixo hoje, alto depois**: com a tabela vazia, trocar a lista é editar o enum e regerar a migration. Com pergunta gravada, é `ALTER TYPE`, atualização das linhas e troca das chaves de tradução no front |
| P-028 | Toda pergunta pertence a uma seção: `section` é obrigatória e não tem valor padrão. | baixo: a tabela nasce vazia; tornar a coluna opcional depois é uma migration de uma linha, sem mexer em dado |

As três estão no ledger ([`decisoes/premissas.md`](../../decisoes/premissas.md)).

**A P-020 precisa de resposta antes da primeira pergunta real ser gravada**, não antes da
implementação. Implementar com a lista provisória custa zero. Gravar perguntas de
verdade com ela é o que torna a troca cara.

## Riscos

- **Dois heads no Alembic, e desta vez é certo, não provável.** A CREED-33 e esta
  tarefa geram cada uma a sua revisão a partir do mesmo head (`49ef1d2c7b7e`, a da
  CREED-34), ao mesmo tempo. Quando as duas estiverem na `dev`, `alembic heads` vai
  devolver duas linhas. **Mitigação:** quem mesclar **por último** roda `alembic merge`
  no próprio PR, antes de mesclar. **Nunca** se edita `down_revision` à mão
  ([`conventions/migrations.md`](../../conventions/migrations.md), regra 3). O sinal de
  que ninguém fez isso: `alembic upgrade head` falhando na `dev` com "Multiple head
  revisions".
- **Pergunta apontando para formulário que não existe.** A API aceita qualquer
  `form_id`. Quando a amarração criar a `ForeignKey`, o banco vai recusar toda linha
  órfã, e a migration trava para todo mundo. **Mitigação:** a mesma da CREED-33.
  Nenhum `seed`, `fixture` ou carga inicial grava em `questions`, e esta API não vai
  para nenhum ambiente além do local antes da amarração.
- **`GET` não distingue formulário inexistente de formulário vazio.** Os dois devolvem
  200 com lista vazia. Quem integrar o front antes da amarração pode confundir "digitei o
  identificador errado" com "o formulário ainda não tem perguntas". **Mitigação:** está
  escrito no contrato. O 404 entra com a amarração.
- **A amarração cresceu.** Além das FKs, ela agora herda uma decisão: juntar `questions`
  com `forms`, ou manter os dois separados e liberar a leitura entre eles em
  `tests/test_arquitetura.py`. O sinal de que ficou esquecido: a CREED-37
  (`QuestionOption`) começar sem ninguém ter decidido em qual dos dois domínios ela
  entra.
- **O enum `Prisma` nasce sem dono.** Quando o domínio `prismas` ganhar tabela própria,
  alguém precisa decidir se o enum sobe para `app/shared/`. O sinal de que virou dívida:
  um segundo `class Prisma(enum.Enum)` em outro domínio.
- **Ninguém confere quem pode cadastrar pergunta.** O motivo é o mesmo da CREED-33: falta
  `Vinculo`. A mitigação também é a mesma: a API fica só no ambiente local até a
  amarração.
- **A lista de seções é provisória e vai parecer definitiva.** Com `profile`,
  `assessment` e `closing` no código, nos testes e no Swagger, quem chegar depois tende
  a tratá-los como decididos, e o front vai criar uma chave de tradução para cada um. O
  sinal de que virou dívida: a primeira pergunta real gravada com a P-020 ainda
  🟡 aberta. **Mitigação:** o comentário `🟡 Premissa P-020` em cima do enum no
  `models.py`, como `users/models.py` faz com a P-013, e a premissa na pauta do time.
- **O front pode começar a desenhar seções antes de a lista fechar.** A tela que consome
  a seção é outra tarefa, e pode andar em paralelo. Se ela nascer com chaves de i18n
  para os valores provisórios, trocar a lista passa a mexer em dois repositórios.
  **Mitigação:** quem pegar a tarefa do front lê a P-020 antes, e isso precisa estar na
  descrição daquela tarefa.
