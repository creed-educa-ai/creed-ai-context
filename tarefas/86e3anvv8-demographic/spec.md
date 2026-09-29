# 86e3anvv8 — CREED-40 Demographic

> Épico com uma subtarefa no ClickUp: CREED-401 (criar a tabela). A decomposição sai
> no `/tasks`.

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | 5 premissas novas (P-023 a P-027); a P-023 contraria o `Gender` do modelo de dados e a P-024 tem custo médio; regra nova de quem grava o dado de quem (P-025) |
| Técnico | T3 | migration; tabela que não existe no modelo do time; a resposta de `ParticipantResponse` (CREED-36, PR #28) ganha um campo; padrão novo no código: coluna `ARRAY` |

Dispensadas nesta calibragem: nenhuma.

## Problema

O front já coleta os dados demográficos do respondente em três telas, mas eles só vivem
no rascunho do Redux e se perdem no logout: o backend não tem onde guardá-los. Sem esses
dados gravados, não existe recorte por gênero, faixa etária, etnia, religião ou
nacionalidade — que é matéria-prima das análises do produto ([C14]).

## Quem usa

| Papel | O que faz nesta entrega |
|---|---|
| `admin` | grava e consulta os dados demográficos de um participante (P-025) |
| `respondente` | nada ainda: recebe **403**. Preencher os próprios dados espera o vínculo entre login e pessoa (P-025) |
| `gestor` | nada: recebe **403** |
| Time interno | dashboards e relatórios vão agregar estes dados por recorte, em outra tarefa |

**Dados demográficos** são a autodeclaração da pessoa sobre gênero, faixa etária, origem
étnica, religião e nacionalidade. Todos são **opcionais**: a pessoa pode pular qualquer
um, como já faz no front.

## Escopo

**Entra:**
- Tabela `participant_demographics`, 1:1 com `participants`, com migration própria.
- `PUT /api/v1/participants/{participant_id}/demographics`: grava ou substitui os dados
  demográficos de um participante.
- `ParticipantResponse` passa a trazer `demographics` (nulo enquanto nada foi gravado),
  então o `GET /api/v1/participants/{participant_id}` da CREED-36 também os devolve.
- Validação das opções pelas listas do front (P-023) e da coerência da nacionalidade
  (P-026, P-027).
- Registrar a tabela nova e a mudança de `gender` em `context/modelo-de-dados.md` e na
  proposta `.dbml`.

**Não entra:**
- **Front.** A tela não chama esta rota nesta entrega: o respondente ainda não sabe o id
  do próprio participante (P-025). Transcrever os tipos para `src/types/api.ts` e trocar o
  rascunho do Redux pela API é da integração, depois do vínculo.
- **Nome** (tela 1 do front): já é `participants.name`, da CREED-36.
- **"Perspectiva"** (tela 3 do front, resposta aberta): não é dado demográfico nem está na
  tarefa. Fica para a tarefa dona da tela 3.
- **Setor**: é atributo do vínculo, não da pessoa ([C4]) — CREED-39.
- **Agregação por recorte** (contagem por gênero, por faixa…): é de dashboards/relatórios.
- **Histórico** do que a pessoa respondeu antes: o `PUT` substitui; não há versão
  anterior guardada.
- **Apagar** os demográficos com `DELETE`: um `PUT` com tudo vazio tem o mesmo efeito.
- **Coluna `gender` em `participants`**: não é criada. O gênero mora nos demográficos
  (ver "Abordagem técnica").
- **Fluxo de consentimento LGPD** para dado sensível: ver "Riscos".

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-backend | domínio `participants`: model `ParticipantDemographics`, schemas, repository, service e a rota `PUT`; `ParticipantResponse` ganha `demographics`; migration nova |
| creed-ai-context | `context/modelo-de-dados.md` e `modelo-de-dados.proposta.dbml`: tabela nova e `gender` saindo de `Participant` |
| creed-frontend | nada nesta entrega |
| creed-infrastructure | nada |

Nome do domínio: `participants`, o mesmo da CREED-36. A descrição no ClickUp também põe os
demográficos em `app/domains/participantes/models.py`; o nome em inglês segue o
[ADR-0005](../../decisoes/adrs/0005-idioma-do-codigo.md), como na 36. Ficar no mesmo
domínio evita uma composição entre domínios para um dado que só existe junto do
participante.

## Contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| PUT | `/api/v1/participants/{participant_id}/demographics` | `DemographicsUpdate` | `ParticipantResponse` · 200 |
| GET | `/api/v1/participants/{participant_id}` (CREED-36) | — | `ParticipantResponse` · 200, agora com `demographics` |

`DemographicsUpdate` — todos opcionais; campo ausente conta como "não respondeu":

| Campo | Tipo | Valores (P-023, P-024) |
|---|---|---|
| `gender` | texto ou nulo | `feminino`, `masculino`, `nao_binario`, `prefiro_nao_informar` |
| `age_range` | texto ou nulo | `18_25`, `26_35`, `36_45`, `46_55`, `56_65`, `65_mais`, `prefiro_nao_informar` |
| `ethnicities` | lista, sem repetição | os 9 valores de `ethnicityValues` do front |
| `religions` | lista, sem repetição | os 9 valores de `religionValues` do front |
| `nationality` | texto ou nulo | `brasileira`, `portuguesa`, `outra` |
| `brazil_state` | texto ou nulo | as 27 UFs; só com `brasileira` (P-026) |
| `portugal_region` | texto ou nulo | os 7 valores de `portugalRegionValues`; só com `portuguesa` (P-026) |
| `other_nationality` | texto ou nulo, até 100 caracteres (P-027) | só com `outra` (P-026) |

Nomes de campo em inglês e `snake_case` (ADR-0005, `conventions/contrato-front-back.md`);
os **valores** são os do front, em português, para a integração não precisar de tradução.
A correspondência com o `demographicsSchema.ts` do front (`genero` → `gender`,
`faixaEtaria` → `age_range`, `origemEtnica` → `ethnicities`, `religiao` → `religions`,
`nacionalidade` → `nationality`, `estadoBrasil` → `brazil_state`,
`regiaoPortugal` → `portugal_region`, `nacionalidadeOutra` → `other_nationality`) fica
escrita aqui para quem integrar.

`ParticipantResponse.demographics`: os mesmos oito campos, mais `updated_at`; `null` se o
participante nunca teve demográficos gravados.

| Situação | Status |
|---|---|
| sem token ou token inválido | 401 |
| token de quem não é `admin` | 403 |
| participante não existe | 404 |
| valor fora da lista, item repetido numa lista, texto longo demais | 422 |
| detalhe de nacionalidade sem a nacionalidade correspondente | 422 |

A rota documentada no Swagger no padrão do PR #17, cobrada por `tests/test_openapi.py`.

## Dados

Tabela nova `participant_demographics`:

| Coluna | Tipo | Regra |
|---|---|---|
| `participant_id` | uuid | **PK** e FK → `participants.id`: uma linha por participante |
| `gender` | varchar(30) | nulável |
| `age_range` | varchar(30) | nulável |
| `ethnicities` | varchar(40)[] | not null, default vazio |
| `religions` | varchar(40)[] | not null, default vazio |
| `nationality` | varchar(20) | nulável |
| `brazil_state` | varchar(2) | nulável |
| `portugal_region` | varchar(40) | nulável |
| `other_nationality` | varchar(100) | nulável |
| `created_at` | timestamptz | not null, default `now()` |
| `updated_at` | timestamptz | nulável, atualizado a cada `PUT` que já encontra linha |

- **Dependência:** a FK exige `participants`, que chega com o PR #28 (CREED-36). A
  migration vem depois da head que o #28 deixar na `dev`.
- **Sem enum no banco:** os valores são texto validado na entrada (ver "Abordagem
  técnica"). A migration não cria tipo nenhum.
- **Índice:** a PK já indexa `participant_id`. Nenhuma coluna entra em filtro nesta
  entrega; quando a agregação por recorte chegar, ela decide o índice (ver "Riscos").
- **Dado existente:** nenhum. A tabela nasce vazia, e nenhum participante precisa de
  linha: sem linha é "nunca respondeu".
- **Divergência com o modelo:** o `.dbml` do time põe `gender` em `Participant`, com
  outros valores. Esta tarefa não cria essa coluna e registra a mudança no
  `modelo-de-dados.md`.

## Abordagem técnica

**1. Onde os dados moram.**

- **Escolhida:** tabela própria `participant_demographics`, 1:1, com `participant_id`
  como PK. É o que a subtarefa CREED-401 pede ("criar table Demographic"), deixa o dado
  sensível numa tabela só — mais fácil de restringir e de apagar se um dia for preciso —
  e separa o que o `admin` cadastra (nome, documento) do que a pessoa declara.
- **Descartada, oito colunas em `participants`:** mistura cadastro e autodeclaração, e
  todo `SELECT` de participante passaria a carregar dado sensível sem precisar.
- **Descartada, `gender` em `participants` e o resto na tabela nova:** divide o mesmo
  formulário em dois lugares só para seguir o `.dbml`, que foi desenhado antes de o front
  definir as telas.

**2. Etnia e religião, que aceitam várias opções.**

- **Escolhida:** coluna `ARRAY` de texto na própria tabela. A agregação continua no banco
  (`unnest` + `GROUP BY`, princípio 1), e a lista tem no máximo 9 valores fixos.
- **Descartada, uma tabela de ligação para cada lista:** duas tabelas e dois caminhos de
  escrita para guardar até 9 textos; o ganho (FK para uma tabela de opções) não existe,
  porque as opções não são tabela.
- **Descartada, `JSONB`:** perde o tipo, e agregar vira `jsonb_array_elements`, mais
  obscuro que `unnest` para o nível do time.

Primeiro uso de `ARRAY` no código. É recurso comum do Postgres, e o SQLAlchemy o mapeia
direto; a justificativa fica no docstring do model.

**3. Os valores permitidos.**

- **Escolhida:** texto no banco, validado na fronteira pelo Pydantic com as listas do
  front. As listas ainda são provisórias (P-023, P-024 e o próprio `DEMOGRAPHICS.md` do
  front pedem confirmação à cliente): trocar um valor fica sendo mudança de código, sem
  migration. É o mesmo raciocínio de [C4], que tirou `Setores` de enum.
- **Descartada, enum do Postgres:** acrescentar valor é `ALTER TYPE`, e remover um valor
  não tem comando — a lista provisória ficaria cara de corrigir.

**4. `PUT` substitui tudo.**

- **Escolhida:** o corpo é o formulário inteiro. A primeira chamada cria a linha, as
  seguintes a substituem, e campo ausente vira nulo ou lista vazia. É o comportamento do
  front, onde "Pular" limpa a etapa.
- **Descartada, `PATCH` campo a campo:** o front sempre tem o formulário completo, e
  mesclar exigiria distinguir "não mandei" de "apaguei", sem ganho nesta entrega.

## Critérios de aceite

- [ ] `alembic upgrade head` cria `participant_demographics` como em "Dados", e
      `alembic heads` devolve uma head só.
- [ ] `alembic downgrade -1` apaga a tabela e só ela; `upgrade head` de novo funciona.
- [ ] `alembic check` não acusa diferença entre model e banco nesta tabela.
- [ ] `PUT` com `admin` num participante sem demográficos → 200, e a resposta traz
      `demographics` com o que foi enviado.
- [ ] Segundo `PUT` no mesmo participante substitui tudo: campo omitido volta nulo ou
      vazio, e `demographics.updated_at` é preenchido.
- [ ] `PUT` com corpo vazio (`{}`) → 200, com todos os campos nulos ou vazios.
- [ ] `PUT` com etnia e religião múltiplas → 200, as listas voltam iguais.
- [ ] Valor fora da lista, item repetido numa lista ou `other_nationality` com mais de
      100 caracteres → 422.
- [ ] `brazil_state` sem `nationality = brasileira` (e os equivalentes de Portugal e de
      "outra") → 422.
- [ ] Participante inexistente → 404.
- [ ] Sem token → 401; `gestor` ou `respondente` → 403.
- [ ] `GET /api/v1/participants/{id}` devolve `demographics: null` antes do primeiro
      `PUT` e os dados depois.
- [ ] A rota aparece no Swagger com resumo, descrição, `operation_id`, exemplos e as
      respostas de erro, e o `tests/test_openapi.py` a inclui.
- [ ] `context/modelo-de-dados.md` registra a tabela nova, a saída de `gender` de
      `Participant` e o `Enum Gender` trocado pela lista do front (sem `outro`).

## Como verificar

1. Com a `dev` já contendo o #28: `alembic upgrade head` e `\d participant_demographics`.
   Conferir PK em `participant_id`, FK para `participants` e as colunas `[]`.
2. `alembic downgrade -1`, depois `upgrade head` e `alembic check`.
3. No Swagger local, com token de `admin` e um participante criado pela rota da 36:
   - `GET` do participante → `demographics: null`;
   - `PUT` com gênero, faixa, duas etnias, nacionalidade `brasileira` e `brazil_state`
     `RS` → 200;
   - `GET` de novo → os mesmos dados;
   - `PUT` só com `{"gender": "feminino"}` → as outras chaves voltam vazias;
   - `PUT` com `brazil_state` e `nationality: "portuguesa"` → 422;
   - `PUT` com `gender: "masc"` → 422;
   - `PUT` num UUID inventado → 404.
4. `pytest tests/domains/participants tests/test_arquitetura.py tests/test_openapi.py`.
5. `ruff check . && mypy app && pytest`.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-023 | As opções válidas são as do front, inclusive gênero (`feminino`, `masculino`, `nao_binario`, `prefiro_nao_informar`); o `outro` do `Gender` do modelo sai, e o modelo passa a ter a lista do front (escolha do time em 2026-09-29). Etnia e religião aceitam várias; "prefiro não responder" não exclui as outras. | baixo sem dado; médio depois |
| P-024 | Idade como faixa etária, não data de nascimento. | médio |
| P-025 | Só `admin` grava e lê demográficos; o respondente preencher os próprios espera o vínculo login → pessoa. | baixo |
| P-026 | Detalhe de nacionalidade incoerente com a nacionalidade é recusado (422). | baixo |
| P-027 | "Outra nacionalidade" com até 100 caracteres. | baixo |
| P-022 (existente) | Só `admin` cadastra e consulta participante. | — |

As premissas de custo médio (P-023 e P-024) e a divergência com o modelo em `gender`
vão para a pauta da próxima reunião (`/pauta`): são as que ficam caras depois que houver
dado gravado.

## Riscos

- **O #28 não entrar na `dev`.** Sem `participants`, a FK não tem para onde apontar.
  Sinal: `alembic upgrade` falhando com "relation participants does not exist". Não
  comece a migration antes do merge.
- **Dado pessoal sensível (LGPD, art. 5º, II).** Origem étnica e convicção religiosa são
  dados sensíveis; o tratamento pede consentimento específico. O projeto tem um termo de
  consentimento no front (`TermoModal`), mas nenhum documento diz se ele cobre estes
  dados. Esta entrega restringe o acesso ao `admin` (P-025) e não expõe o dado em
  listagem, mas **não resolve** o consentimento. Sinal: a cliente perguntar quem vê a
  religião de quem. Vai para a pauta.
- **Lista de opções mudar depois de haver dado.** O texto no banco torna a troca barata no
  código, mas as linhas já gravadas com o valor antigo precisam de conversão. Sinal: a
  cliente mudar uma opção depois que o fluxo estiver em uso.
- **Agregação por recorte lenta sem índice.** Quando dashboards contarem por religião ou
  etnia, `unnest` em tabela grande pode pedir índice `GIN`. Hoje não há volume; quem
  escrever a agregação mede.
- **Contrato do participante muda antes de ser consumido.** `ParticipantResponse` ganha
  `demographics`; como nada no front consome a 36 ainda, a mudança é aditiva e segura.
  Sinal: alguém integrar a 36 no front antes desta entrar e tipar a resposta sem o campo.
- **Migration irmã.** Se outra migration entrar na `dev` depois do #28 e antes desta, é
  preciso `alembic merge` antes do PR (`migrations.md`, regra 3), como aconteceu na 36 com
  a 344.
