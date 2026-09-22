# 86e3ank84 — CREED-31 · Answer table context

> Gerada por `workflows/tarefa-to-spec.md` em 2026-09-19, a partir do épico
> [CREED-31](https://app.clickup.com/t/86e3ank84) e das três subtarefas publicadas
> ([311](https://app.clickup.com/t/86e3anktu) · [312](https://app.clickup.com/t/86e3anpp5) ·
> [313](https://app.clickup.com/t/86e3anwqj)).

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | **"O que conta como pronto" não está decidido**: o épico promete `POST /api/v1/answers` com `{form_response_id, question_id, option_id, value}` e a subtarefa 313 diz, textualmente, *"sem router nesta rodada"*. Some-se a **regra de negócio nova e contraditória** — a subtarefa 312 manda *"texto vazio deve ser recusado"*, mas no modelo a resposta **objetiva** tem `value` nulo e responde em `option_id` — e a **pendência de produto ainda aberta** no próprio modelo de dados: *"Sem unique (form_response_id, question_id) de propósito: se objetiva aceitar mais de uma alternativa, a resposta são várias linhas"*. Duas premissas novas. |
| Técnico | T3 | **Migration** — a subtarefa 311 é uma revisão Alembic, e um sinal de T3 basta. Reforçam: o **domínio não existe** (`app/domains/` tem `authentication`, `dashboards`, `organizacoes`, `prismas`, `prognosticos`, `relatorios`, `respondentes`, `users`); e **padrão que não existe no código nem no harness** — tabela nascendo com chave estrangeira comentada. |

Dispensadas nesta calibragem: nenhuma.

## Problema

Não existe onde gravar a resposta que uma pessoa dá a uma pergunta. O banco da
plataforma tem **uma tabela só** (`user`, criada pela revisão `0b0ad39d779a`); o resto
do modelo desenhado pelo time existe apenas no diagrama. As telas de questionário do
front foram construídas sem destino para o dado.

Há um segundo problema, este dentro da própria tarefa: **o épico e as subtarefas
descrevem entregas diferentes.** O épico promete um endpoint HTTP com quatro campos; as
subtarefas entregam uma tabela sem chave estrangeira, um service com um campo só, e
declaram que não haverá router. Quem pegar a subtarefa entrega algo que o contrato do
épico não consegue usar. Esta spec existe, em boa parte, para fazer esse conflito morrer
em um lugar só.

## Quem usa

**Nesta rodada, ninguém — e isso é a informação, não uma lacuna.** É entrega de
fundação: nenhuma tela muda, ninguém de fora do time percebe diferença.

Quando a submissão existir (CREED-34), a cadeia fica assim:

| Papel | O que essa pessoa faz | O que esta entrega sustenta |
|---|---|---|
| **Respondente** — pessoa que responde aos instrumentos da plataforma | marca uma alternativa, ou escreve um texto, pergunta a pergunta | cada marcação vira **uma linha** nesta tabela |
| **Gestor** — quem administra uma organização parceira | lê os resultados agregados da organização dele | a agregação por alternativa só é possível porque a resposta objetiva grava `option_id`, e não texto digitado |
| **Administrador** — quem administra a plataforma | idem, sobre qualquer organização | idem |

O motivo de a resposta objetiva **não** ser texto livre está no modelo de dados
(correção `[C8]`): agregar objetiva sobre texto digitado viraria contagem de coisa que
cada pessoa escreve de um jeito.

## Escopo

**Entra:**

- Domínio `responses` em `app/domains/responses/`, seguindo a forma do molde.
- `models.py` com a tabela `answer`: `id`, `question_id`, `option_id`, `value`, `created_at`.
- Migration Alembic isolada, que cria **só** esta tabela.
- `repository.py` com o acesso ao dado (`insert`, `get_by_id`).
- `service.py` com a regra de qual resposta é válida.
- `schemas.py` com `AnswerCreate` e `AnswerResponse`.
- `dependencies.py` montando a cadeia sessão → repository → service.
- Testes de service em `tests/domains/responses/test_service.py`.

**Não entra — e por quê:**

- **Nenhum endpoint HTTP.** Um `POST /api/v1/answers` que recebe `form_response_id` sem
  que a tabela `form_response` exista aceitaria qualquer UUID inventado e gravaria lixo
  que ninguém consegue rastrear depois. A rota nasce junto da submissão, em CREED-34.
  ⚠️ **Isto contradiz o contrato publicado no épico** — ver "Riscos".
- **As chaves estrangeiras.** `form_response_id`, `question_id` e `option_id` apontam
  para tabelas que ainda não existem. Decisão de time de 2026-09-19: migrations
  isoladas agora, uma tarefa de **amarração** depois. Ver "Abordagem técnica".
- **A coluna `form_response_id`.** Sai desta rodada junto com a FK dela — ver
  "Abordagem técnica" para o porquê de ela ser tratada diferente de `question_id`.
- **O índice `unique (form_response_id, question_id)`.** Não existe no modelo, e de
  propósito — ver premissa P-015.
- **Qualquer validação cruzada** do tipo "a alternativa escolhida pertence mesmo a esta
  pergunta". Depende de `question_option` existir.
- **Front.** Nada muda no `creed-frontend` nesta entrega.

## Repos afetados

| Repo | O que muda |
|---|---|
| `creed-backend` | domínio novo `app/domains/responses/` · uma revisão Alembic · testes em `tests/domains/responses/` |
| `creed-frontend` | nada |
| `creed-infrastructure` | nada |

Nome do domínio (e da futura feature, quando houver): **`responses`**.

Inglês por padrão em identificador é o [ADR-0005](../../decisoes/adrs/0005-idioma-do-codigo.md);
`snake_case` plural é [`conventions/estrutura-e-nomes.md`](../../conventions/estrutura-e-nomes.md).
Por isso **não** é `respostas` (como diz o épico) nem `response` no singular.

## Contrato

**Esta rodada não publica nenhum endpoint HTTP.** A seção existe para registrar o
contrato interno que nasce agora, e o contrato HTTP que **não** nasce — é o ponto em que
épico e subtarefa discordam hoje.

### O que nasce: contrato interno entre camadas

Tudo `async`, porque o molde é `async` (`AsyncSession`).

| Camada | Assinatura | Devolve |
|---|---|---|
| `repository.insert(answer: Answer)` | recebe a entidade já montada | `Answer` persistido, com `id` e `created_at` preenchidos pelo banco |
| `repository.get_by_id(answer_id: UUID)` | — | `Answer` **ou `None`** — o repository não levanta erro |
| `service.record(dados: AnswerCreate)` | o payload já validado | `Answer` criado, ou `ValidationError` |
| `service.get(answer_id: UUID)` | — | `Answer`, ou `NotFoundError` |

Os nomes seguem [`conventions/camadas-do-back.md`](../../conventions/camadas-do-back.md)
→ "Nome do método diz de qual camada é": **o service nomeia o caso de uso** (`record` —
registrar uma resposta), **o repository nomeia o acesso** (`insert`, `get_by_id`).

> ⚠️ **Divergência com a subtarefa 312**, que pede `service.create_text(value)` e
> `service.get_by_id(id)`. Os dois nomes furam a convenção: `get_by_id` em service é
> "repository disfarçado", e `create_text` amarra o nome do caso de uso a **uma** das
> duas formas de resposta — a objetiva não é texto.

### O que NÃO nasce: contrato HTTP

Registrado aqui para quando a rota existir (CREED-34), e para que as duas tarefas parem
de discordar:

| Método | Rota | Entrada | Saída | Erros |
|---|---|---|---|---|
| POST | `/api/v1/answers` | `{form_response_id, question_id, option_id?, value?}` | `AnswerResponse` · **201** | **422** entrada inválida (FastAPI) · **422** nem `option_id` nem `value` (`ValidationError`) · **404** `form_response_id` ou `question_id` inexistente |

## Dados

Tabela `answer`. A migration desta rodada cria **exatamente** isto:

| Coluna | Tipo | Nulo? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, `default=uuid.uuid4` |
| `question_id` | `UUID` | não | **sem `ForeignKey`** nesta rodada |
| `option_id` | `UUID` | sim | preenchido na resposta **objetiva**; **sem `ForeignKey`** |
| `value` | `String` | sim | preenchido na resposta **descritiva** |
| `created_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |

Índice criado agora: `question_id`.

**O que fica para a tarefa de amarração**, declarado para que ninguém descubra no meio:

- coluna `form_response_id` + índice + `ForeignKey → form_response.id`, `NOT NULL`;
- `ForeignKey` em `question_id → question.id`;
- `ForeignKey` em `option_id → question_option.id`.

**Dado existente:** nenhum. A tabela nasce vazia e **precisa continuar vazia** até a
amarração — é o que torna a amarração barata. Acrescentar uma FK `NOT NULL` a uma tabela
com linhas exige os três passos de
[`conventions/migrations.md`](../../conventions/migrations.md) (regra 6); numa tabela
vazia é uma migration só.

> 🟡 **Premissa P-015** — a tabela não ganha `unique (form_response_id, question_id)`.
> Confirmar na reunião.

## Abordagem técnica

### Escolhido: um domínio `responses`, tabela sem FK, `form_response_id` adiada

**1. `Answer` e `FormResponse` no mesmo domínio `responses`.** São um assunto só — "a
resposta de alguém a um formulário" —, e é o que os dois épicos já dizem ao apontar para
a mesma pasta (`app/domains/respostas/`, em CREED-31 e em CREED-34).

*Descartado:* domínio `answers` separado de `form_responses`. Partiria em dois um assunto
que o modelo trata junto, e `tests/test_arquitetura.py` proíbe um domínio importar o
outro por dentro — a submissão precisaria de uma exceção declarada na lista de permitidos
logo na primeira tarefa que a usasse.
⚠️ **A subtarefa de CREED-34 diz `app/domains/form_responses/`.** As duas tarefas
precisam fechar na mesma pasta; ver "Riscos".

**2. A tabela nasce sem nenhuma `ForeignKey`.** Consequência direta da decisão de time de
2026-09-19 (migrations isoladas, amarração depois).

*Descartado:* criar já com as FKs. Seria o desenho correto e o mais barato **se** as
tabelas-alvo existissem — mas `form_response`, `question` e `question_option` não
existem, e uma FK só pode ser criada depois do alvo. Exigiria ordenar as dez tarefas numa
fila única, que é exatamente o que a decisão de migrations isoladas evitou.

**3. `form_response_id` não entra como coluna nesta rodada.** Aqui eu me afastei do que a
subtarefa 311 sugere (*"pode colocar de forma mockada esses id no models"*).
`question_id` fica porque **identifica a resposta**: sem ela a linha não significa nada,
nem mesmo isolada. `form_response_id` é pura ligação: uma coluna `UUID NOT NULL` sem FK e
sem destino aceita qualquer coisa e não valida nada — e na amarração vira uma coluna a
alterar em vez de uma coluna a criar, o que dá o mesmo trabalho.

*Descartado:* criar `form_response_id` agora, nulável, e apertar depois. Salva uma linha
de migration e cria uma janela em que dá para gravar resposta órfã.

**4. `service.record` recusa a linha em que `option_id` e `value` estão os dois vazios.**
É a regra que sobra quando não há FK para validar. Ver premissa P-014.

*Descartado:* a regra da subtarefa 312, *"texto vazio deve ser recusado"*. Ela trata
`value` como o único jeito de responder e **recusaria toda resposta objetiva**, que por
desenho tem `value` nulo (`[C8]`).

**5. Tudo `async`, e o repository faz `flush()`/`refresh()` — nunca `commit()`.** Não é
escolha: é o que o molde faz (`app/domains/respondentes/repository.py`) e o que
`conventions/camadas-do-back.md` cobra — *"`commit()` fora de `core/database.py`"* é
sinal declarado de camada furada. Quem fecha a transação é o `get_db`, no fim da
requisição.

## Critérios de aceite

- [ ] `docker compose up -d db && alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] `alembic heads` devolve **um único head** — se devolver dois, a saída é `alembic merge`, nunca editar `down_revision` à mão.
- [ ] A tabela `answer` tem exatamente as cinco colunas da seção "Dados", com os mesmos tipos e a mesma nulabilidade.
- [ ] A tabela `answer` **não** tem nenhuma `ForeignKey` e **não** tem a coluna `form_response_id`.
- [ ] Existe índice em `question_id`.
- [ ] `service.record` **aceita** uma resposta com `option_id` preenchido e `value` nulo (caso objetivo).
- [ ] `service.record` **aceita** uma resposta com `value` preenchido e `option_id` nulo (caso descritivo).
- [ ] `service.record` **recusa**, com `ValidationError`, a resposta com os dois vazios — e recusa `value` que só tem espaço em branco.
- [ ] `service.get` levanta `NotFoundError` quando o id não existe; `repository.get_by_id` devolve `None` no mesmo caso.
- [ ] Nenhum `commit()` no diff, fora de `app/core/database.py`.
- [ ] A migration gerada foi **lida linha a linha**, e quem leu consegue dizer o que cada comando faz.
- [ ] `pytest tests/test_arquitetura.py` passa — nenhuma camada furada no domínio novo.

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
docker compose exec db psql -U creed -d creed -c "\d answer"
```

Caso de borda que precisa passar — derrubar tudo e subir de novo reproduz exatamente o
mesmo banco:

```bash
docker compose down -v && docker compose up -d db && alembic upgrade head
```

⚠️ `docker compose down -v` apaga o volume inteiro, e com ele o schema `keycloak` do
ambiente local — quem subir de novo precisa esperar o `init-keycloak-schema.sql` rodar e
reimportar o realm. É o preço de conferir que a migration sobe do zero; rode com isso em
mente, não no meio de outra tarefa que dependa do login local.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-014 | Uma resposta válida tem **exatamente uma** das duas formas preenchida: `option_id` (objetiva) **ou** `value` (descritiva). Linha com as duas vazias é recusada pelo service. Pergunta pulada **não gera linha** em `answer`. | baixo — é uma condição no service, e nenhum dado se perde na volta |
| P-015 | Uma pergunta objetiva aceita **uma alternativa**. A tabela **não** ganha `unique (form_response_id, question_id)`: a regra vive no service de submissão, que ainda não existe. | baixo — sem o índice, abrir para múltipla seleção depois não custa migration nenhuma |

As duas estão no ledger ([`decisoes/premissas.md`](../../decisoes/premissas.md)) e vão
para a pauta da próxima reunião.

O motivo de P-015 não virar índice: o modelo de dados registra a pendência em aberto
(*"se objetiva aceitar mais de uma alternativa, a resposta são várias linhas"*). Adotar a
interpretação mais provável **sem** materializá-la em índice é a escolha mais barata de
reverter — critério 2 de
[`conventions/premissas-e-duvidas.md`](../../conventions/premissas-e-duvidas.md).

## Riscos

- **O contrato publicado no épico não vai ser entregue.** O épico anuncia
  `POST /api/v1/answers`; esta spec não entrega rota nenhuma. Sinal de que deu errado:
  alguém do front programar contra esse endpoint. **Mitigação: a descrição do épico
  precisa ser corrigida no board antes de a tarefa ser pega** — não é alteração que esta
  spec faz sozinha.
- **Conflito de heads no Alembic.** Dez tarefas de tabela gerando revisão a partir do
  mesmo head produzem heads divergentes. Sinal: `alembic heads` devolvendo duas linhas.
  Mitigação: `alembic merge`, e combinar a ordem de merge antes da primeira PR.
- **A amarração encarece se a tabela receber linhas.** FK `NOT NULL` em tabela com dados
  exige três passos. Sinal: qualquer seed ou fixture gravando em `answer` fora de teste.
  Mitigação: a tabela fica vazia até a amarração, e a amarração precisa de dono e data no
  board.
- **`responses` × `form_responses`.** CREED-34 está em progresso, com branch no remoto, e
  a subtarefa dela aponta para `app/domains/form_responses/`. Se as duas tarefas não
  fecharem na mesma pasta, nasce um domínio duplicado para o mesmo assunto. Sinal: as
  duas pastas existindo no mesmo diff. Mitigação: combinar com quem está em CREED-34
  **antes** de abrir a branch desta.
- **`modelo-de-dados.proposta.dbml` não está anexado na tarefa.** O épico o lista com ✅,
  mas não há anexo — quem não usa este repositório não tem como abrir o modelo.
  Mitigação: anexar na publicação, como foi feito na CREED-23.
