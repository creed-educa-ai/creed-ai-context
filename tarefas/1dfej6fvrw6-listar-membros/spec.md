# 1dfej6fvrw6 — CREED-697 · M-2 · Listar os membros de uma organização

> Gerada por `workflows/tarefa-to-spec.md` em 2026-11-09, a partir da subtarefa
> [CREED - 697 - Listar membros de uma org. (M2)](https://app.clickup.com/t/1dfej6fvrw6)
> (autor: Leonardo Rossol; o texto é o mesmo do Notion "S4 TASKS"). Estado lido: `dev`
> do back em `bfe7124`, que já tem a P-6 (PR #59, `feat/683-quest-atual`), e `main` do
> harness em `61e6274`.
>
> **Esta tarefa estende a C-1** ([CREED-6910](../1dfej6fvrwu-trocar-setor-membro/spec.md)).
> A C-1 criou a rota `/organizations/{organization_id}/members` num segundo router de
> `links` (`app/domains/links/router_members.py`), o `MemberResponse`, a leitura do
> membro por JOIN (adendo ao ADR-0004) e a regra de acesso dos membros. A M-2 entra nos
> mesmos arquivos. A branch sai da branch da C-1, não do `dev`.
>
> ⚠️ **O PR #51 (convite de membro, do Luís, aberto) usa o mesmo prefixo** com
> `POST /organizations/{organization_id}/members`, no domínio `users`
> (`app/domains/users/router_members.py`). FastAPI aceita dois routers no mesmo prefixo
> com métodos diferentes. A C-1 registra o dela como `link_members_router` no
> `app/main.py`, para não sobrescrever o `members_router` do #51 quando os dois entrarem.

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | Quem lista segue a P-066 da C-1 (decisão do Enzo, não premissa nova). **Regra de ciclo de vida nova:** qual é "o período" de cada pessoa quando há aberto, agendado e já fechado (P-068). Saem **3 premissas novas** (P-068, P-069, P-070). |
| Técnico | T3 | **Agregação nova:** junta vínculo, participante, login, setor, questionário e resposta, e escolhe um período por membro, sem uma consulta por pessoa. Nenhum repository do back faz isso hoje. Sem migration. |

Dispensadas nesta calibragem: nenhuma.

## Problema

As duas tabelas do painel de controle, a de **mentorandos** (painel da administradora) e
a de **membros da empresa** (painel do gestor), ainda são mock no front. Nenhuma rota
devolve as pessoas de uma organização com o setor e a situação do questionário de cada
uma. Sem isso, o "Ver resultados" não sabe quem já respondeu.

## Quem usa

| Papel | Vê | Para quê |
|---|---|---|
| **Gestor** | os membros da **própria** organização | a tabela de membros da empresa: setor, período e quem já respondeu |
| **Admin** (a administradora) | os membros de **qualquer** organização. No painel dela, a da CREED (P-048), onde estão os mentorandos | a tabela de mentorandos, com `?type=mentoria` |
| **Respondente** | nada (403) | — |

É a mesma regra da troca de setor da C-1 (P-066), que segue a regra geral do projeto
para o admin (P-033): **uma regra só para os membros**, no mesmo
`_check_can_manage_members`. "A administradora, na organização da CREED", no texto da
tarefa, descreve onde ela usa a tela, não um limite. Decisão do Enzo em 2026-11-09.

> ⚠️ **A P-6 diverge.** O `FormService.list_periods`
> (`GET /organizations/{organization_id}/periods`) prende o admin à própria organização
> ("sem a exceção da P-033"). Não é desta tarefa: fica como aviso para quem fez a P-6.

## Escopo

**Entra:**
- `GET /api/v1/organizations/{organization_id}/members`, com o filtro opcional `?type=`
  (um dos tipos de vínculo: `emprego`, `mentoria`, `academico`, `pessoal`).
- Cada membro com os campos do `MemberResponse` da C-1 (id do vínculo, nome, e-mail,
  papel, tipo, setor, última atualização) **e o período dele**: id do questionário,
  abertura, fechamento, situação (`open`, `scheduled` ou `past`) e se já respondeu.
- A escolha de **um** período por membro (P-068) e o "já respondeu" (P-069).
- Número **fixo** de consultas ao banco, qualquer que seja o número de membros.

**Não entra:**
- **Paginação, busca e ordenação configurável** (P-070).
- **Gestor listando outra organização.** Só o admin passa da própria (P-066).
- **Filtro por setor, por papel ou por situação do período.** Só `?type=`.
- **Esconder vínculo encerrado** (`end_at` no passado). Nenhuma rota encerra vínculo
  hoje. Quando existir, o filtro nasce com ela.
- **Todos os períodos de uma pessoa.** Vem um só. A lista inteira já existe em
  `GET /organizations/{organization_id}/periods?link_id=` (P-6).
- **O front** (M-4) e a ligação do "Ver resultados" com o dashboard.

> 🟡 **Premissa P-068**: o período do membro é o aberto; se não houver, o próximo
> agendado; se não houver, o último que fechou. Confirmar na próxima reunião.
>
> 🟡 **Premissa P-069**: "já respondeu" é ter a resposta **enviada** naquele período.
> Confirmar na próxima reunião.
>
> 🟡 **Premissa P-070**: a lista vem inteira, sem paginação, em ordem alfabética de nome.
> Confirmar na próxima reunião.

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-backend | `links`: rota `GET` no `router_members.py`, schemas `MemberPeriod` e `MemberListItem`, `LinkService.list_members`, consultas novas no `LinkRepository`. `forms`: reaproveita `PeriodStatus` e a regra de situação do período. |
| creed-frontend | nada nesta tarefa (a M-4 consome) |
| creed-infrastructure | nada |

Nome do domínio: `links` (rota `/members`, decisão da C-1).

## Contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| GET | `/api/v1/organizations/{organization_id}/members` | `?type=` opcional (`LinkType`) | 200 `MemberListItem[]` |

**`MemberListItem`** é o `MemberResponse` da C-1 mais o campo `period`, do mesmo jeito
que o `PeriodRead` estende o `FormRead` na P-6. O `PATCH` da C-1 continua devolvendo o
`MemberResponse`, sem o período.

```json
[
  {
    "link_id": "d40b7a55-b9cc-4b78-ae5d-ab325fd655e2",
    "name": "Ana Souza",
    "email": "ana@empresa.com.br",
    "role": "respondente",
    "type": "mentoria",
    "department": null,
    "updated_at": null,
    "period": {
      "form_id": "5b1f0a7e-4c2d-4f7a-9d3e-2a6b8c0d1e2f",
      "opens_at": "2026-11-01T00:00:00Z",
      "closes_at": "2026-11-30T23:59:59Z",
      "period_status": "open",
      "has_answered": false
    }
  }
]
```

`period` é `null` quando a pessoa não tem período nenhum, nem para todos nem individual.
`period_status` usa os valores do `PeriodStatus` da P-6 (`open`, `scheduled`, `past`).

> O front (P-064) chama o campo de `hasAnsweredCurrent`. Na API ele é
> `period.has_answered`. A M-4 faz o mapeamento.

**Erros**, nesta ordem de conferência:

| Código | Quando |
|---|---|
| 401 | sem sessão, ou sessão inválida |
| 403 | papel `respondente`, ou `gestor` em organização que não é a do próprio vínculo. Conferido antes de qualquer consulta, como na C-1 |
| 404 | a organização não existe (só o `admin` chega aqui; o gestor recebe 403 antes) |
| 422 | `?type=` fora dos quatro tipos, ou `organization_id` que não é UUID |

Organização que existe mas não tem membros do tipo pedido devolve `[]`. O 404 usa o
`OrganizationService.organization_exists`, que o `LinkService` já recebe.

## Dados

**Sem migration e sem coluna nova.** A rota lê seis tabelas: `links`, `participants`,
`user`, `departments`, `form` e `form_responses`.

- **Período de uma pessoa** = linha de `form` da organização, com `opens_at` e
  `closes_at` preenchidos, e `link_id` nulo (para todos) **ou** igual ao vínculo dela
  (individual, P-6). Formulário sem datas não é período, como no `list_periods`.
- **Já respondeu** = existe `form_responses` com `form_id` do período, `vinculo_id` do
  membro e `status = submitted` (P-069). A coluna ainda se chama `vinculo_id` (nome
  antigo, ver P-029 no ledger).
- **Índices que a leitura usa:** `links.organization_id`, `form.organization_id`,
  `form.link_id` e a unicidade `(form_id, vinculo_id)` de `form_responses`. Todos já
  existem.

## Abordagem técnica

**Escolhida: três consultas fixas, e a escolha do período no service.**

1. Os membros: a mesma leitura por JOIN do `get_member` da C-1 (vínculo + nome + e-mail
   + setor), para a organização inteira, com o filtro de `type` e ordem por nome.
2. Os períodos candidatos: todos os `form` da organização com datas.
3. As respostas enviadas: `form_responses` com `status = submitted` dos vínculos da
   organização.

O service cruza os três em memória e escolhe o período de cada membro com uma **função
pura**, `pick_period(periods, link_id, now)`, que aplica a P-068. A situação usa a
mesma regra de janela do `_period_status` da P-6.

**Descartada: uma consulta só, com `LEFT JOIN LATERAL`** (uma subconsulta por membro
que ordena os períodos e pega o primeiro). É o que a tarefa escreve ("numa consulta
só"), mas tem dois problemas:
- **A regra de produto (P-068) ficaria num `ORDER BY` de SQL**, que a suíte não exercita,
  porque ela não roda contra banco. A regra que mais pode mudar na reunião com a cliente
  seria a única sem teste no CI.
- **`LATERAL` não existe em nenhum lugar do código.** Seria padrão novo para o time
  manter.

O que a tarefa quer impedir é **uma consulta por pessoa** (o "Pronto quando" pede o
teste "com mais de uma pessoa"). Três consultas fixas atendem a isso: o número não cresce
com o número de membros, e o teste prova que continua três com uma ou com dez pessoas.

**Descartada também: chamar `FormService.list_periods` por membro.** É exatamente a
consulta por pessoa que a tarefa proíbe.

**Fronteira entre domínios:** as consultas 2 e 3 leem `form` e `form_responses` por
`select` no repository de `links`. É leitura, coberta pela exceção de
`LEITURA_ENTRE_DOMINIOS` que a C-1 declarou. O docstring do repository e o adendo ao
ADR-0004 passam a citar as duas tabelas. A regra de janela (`_period_status`) é
**reaproveitada** do `forms`, não copiada. Como ela é privada hoje, a implementação a
torna pública (`period_status`) ou a chama pelo `FormService`, conforme o teste de
arquitetura permitir. Isso fica decidido na task.

## Critérios de aceite

- [ ] Admin na organização da CREED com `?type=mentoria`: vêm **só** os vínculos
      `mentoria`.
- [ ] Sem `?type=`, vêm todos os vínculos da organização, inclusive o de quem pede.
- [ ] Período: com um aberto e um agendado, vem o aberto. Só agendados: vem o que abre
      primeiro. Só fechados: vem o último que fechou. Nenhum: `period: null`.
- [ ] Período individual e "para todos" abertos ao mesmo tempo: vem o individual.
- [ ] O período individual de uma pessoa **não** aparece no de outra.
- [ ] `has_answered` é `true` só com a resposta **enviada** daquele período. Resposta em
      andamento, ou enviada em outro período, dá `false`.
- [ ] Gestor em outra organização: 403. Respondente: 403.
- [ ] Admin lista os membros de uma empresa que não é a da CREED: 200 (P-066).
- [ ] Admin em organização inexistente: 404.
- [ ] `?type=vendedor`: 422.
- [ ] Com 1 membro e com 10 membros, o repository é chamado o mesmo número de vezes
      (três).
- [ ] A lista vem em ordem alfabética de nome.

## Como verificar

```bash
cd creed-backend
ruff check . && ruff format --check .
mypy app
pytest tests/domains/links -q
pytest
```

À mão, com o banco e o Keycloak de pé (`docker compose up -d db keycloak mailpit`), a API
rodando (`uvicorn app.main:app --reload`) e os tokens de um admin e de um gestor (README
do back, seção "Autenticação local (Keycloak)"):

```bash
API=http://localhost:8000/api/v1

# admin, mentorandos da CREED → 200, só "type": "mentoria"
curl -s "$API/organizations/$ORG_CREED/members?type=mentoria" \
  -H "Authorization: Bearer $TOKEN_ADMIN"

# gestor, membros da empresa → 200
curl -s "$API/organizations/$ORG_EMPRESA/members" -H "Authorization: Bearer $TOKEN_GESTOR"

# gestor em outra organização → 403
curl -s -o /dev/null -w "%{http_code}\n" "$API/organizations/$ORG_CREED/members" \
  -H "Authorization: Bearer $TOKEN_GESTOR"

# tipo inválido → 422
curl -s -o /dev/null -w "%{http_code}\n" "$API/organizations/$ORG_EMPRESA/members?type=vendedor" \
  -H "Authorization: Bearer $TOKEN_GESTOR"
```

Para conferir o período, crie um período para todos e um individual pelo gerenciador
da P-6 e compare o `period` de cada pessoa com o
`GET $API/organizations/$ORG/periods?link_id=<vínculo>`.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-068 | O período do membro é o aberto; se não houver, o próximo agendado; se não houver, o último que fechou. Entre dois abertos, vale o individual. | baixo |
| P-069 | "Já respondeu" é ter a resposta enviada naquele período. | baixo |
| P-070 | A lista vem inteira, sem paginação, em ordem de nome. | baixo |

## Riscos

- **Admin em qualquer organização é mais amplo que o texto da tarefa.** Se a cliente ou
  o autor da tarefa quiserem o admin preso à CREED, como o `list_periods` da P-6, a volta
  é uma linha em `_check_can_manage_members`, e vale para C-1, M-2 e M-3 de uma vez.
- **Volume da consulta 2.** Ela traz todos os períodos da organização com datas, e não só
  os vigentes. Isso é necessário, porque o "último que fechou" (P-068) pode ser antigo. Na
  CREED, cada mentorando acumula períodos individuais com o tempo. O sinal de problema é a
  rota passar de ~200 ms. A saída é filtrar no banco o último fechado de cada público.
- **"Numa consulta só" lido como intenção, não como letra.** Se o revisor cobrar a letra,
  a alternativa descartada (`LATERAL`) está descrita acima. O que muda é só o repository,
  e a função de escolha continua servindo de oráculo para o teste.
- **PR #51 no mesmo prefixo.** Se o #51 mudar de prefixo ou de tag, o Swagger mostra os
  membros em dois grupos (`users` para o convite e `members` para o resto). Não quebra
  nada, mas confunde. Vale combinar a tag com o Luís.
- **Nome do campo no front.** O mock usa `hasAnsweredCurrent` (P-064), e a API
  `period.has_answered`. Se a M-4 não mapear, o "Ver resultados" fica sempre desabilitado.
