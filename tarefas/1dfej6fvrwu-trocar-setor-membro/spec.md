# 1dfej6fvrwu — CREED-6910 · C-1 · Trocar o setor de um membro

> Gerada por `workflows/tarefa-to-spec.md` em 2026-11-09, a partir da subtarefa
> [CREED - 6910 - Trocar setor de um membro (C1)](https://app.clickup.com/t/1dfej6fvrwu)
> (autor: Leonardo Rossol; o texto é o mesmo do Notion "S4 TASKS"). Estado lido: `dev` do
> back em `e37c0a1`.
>
> **Decisão do Enzo, em 2026-11-08, antes da spec:** a rota segue o endereço da tarefa,
> `/organizations/{organization_id}/members/...`, e o código fica num **segundo router
> dentro do domínio `links`** (`app/domains/links/router_members.py`). Não é um domínio
> `members` novo. O membro é um vínculo e não tem tabela própria, e um domínio
> corresponde a uma tabela. Já existe precedente de domínio com dois routers:
> `questions/router.py` + `questions/router_options.py`. A M-2 (listar) e a M-3 (excluir)
> entram no mesmo arquivo.

## Calibragem

**P2 · T2**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P2 | O resultado e quem usa estão dados ("o gestor escolhe ou troca o setor…", "Quem pode: o gestor, na própria organização"), e o "Pronto quando" está escrito. A permissão aplica a P-033, que já existe, e não é regra nova. Ficaram duas lacunas baratas de reverter: o `admin` e o alvo da troca (P-066), e o setor que fica vazio (P-067). |
| Técnico | T2 | Contrato de API novo (`PATCH .../members/{link_id}`) num repo só. **Sem migration**: `departments` (com unicidade organização + tipo) e a chave `links.department_id → departments.id` já estão no `dev`. O segundo router dentro do domínio já tem precedente (`questions/router_options.py`). |

Dispensadas nesta calibragem: Dados, Abordagem técnica.

## Problema

O setor de um membro alimenta o filtro por setor e o mapa setores × prismas do dashboard
da empresa, mas hoje **nenhuma rota muda o setor de um vínculo**. O setor só entra no
cadastro (`POST /organizations/{organization_id}/links`) e só com o id de um setor que já
existe. Não há tela nem rota para cadastrar setor por empresa.

## Quem usa

- **Gestor da empresa**: escolhe, troca ou tira o setor de qualquer membro da própria
  organização. É quem conhece a estrutura da empresa.
- **Admin da plataforma**: pode fazer o mesmo em qualquer organização (P-066).
- **Respondente**: não usa. Recebe 403, inclusive para o próprio setor.

> 🟡 **Premissa P-066**: o `admin` também troca setor, em qualquer organização, e o alvo
> pode ser qualquer vínculo da organização (o próprio, o de outro gestor, de qualquer
> tipo). Confirmar na próxima reunião.

O front que chama esta rota (o seletor de setor na tabela de membros da empresa) **não
está nesta tarefa**.

## Escopo

**Entra:**
- `PATCH /api/v1/organizations/{organization_id}/members/{link_id}` em
  `app/domains/links/router_members.py`, registrado no `app/main.py`.
- Escolher um setor que a empresa ainda não tem **cria o setor da empresa na hora** e liga
  o membro a ele. Se a empresa já tem aquele setor, reaproveita o cadastro, sem duplicar.
- `department: null` tira o setor do membro.
- Gravar `links.updated_at` na troca.
- O schema de saída `MemberResponse`, que a M-2 reaproveita (ver Contrato).

**Não entra:**
- **Front.** O seletor de setor na tabela de membros é outra tarefa.
- **Apagar setor que ficou vazio** (P-067).
- **Cadastrar, renomear ou listar setores** por rota própria. A tarefa diz que não há
  tela de cadastro de setor, e o `POST /department` que existe não muda.
- **Setor fora dos cinco tipos fixos**, ou nome livre de setor.
- **Trocar papel, tipo ou período** do vínculo. Esta rota só mexe no setor. O corpo não
  aceita outros campos.
- **O período do membro** (abertura, fechamento, se já respondeu) na resposta. Esses
  campos entram com a M-2.

> 🟡 **Premissa P-067**: o setor que fica sem membro continua cadastrado na empresa.
> Confirmar na próxima reunião.

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-backend | `links`: router novo `router_members.py`, schemas `MemberDepartmentUpdate` e `MemberResponse`, método no `LinkService` e no `LinkRepository`. `department`: buscar ou criar o setor da empresa por tipo. `app/main.py`: registrar o router. |
| creed-frontend | nada nesta tarefa |
| creed-infrastructure | nada |

Nome do domínio: `links` (rota `/members`, decisão no cabeçalho).

## Contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| PATCH | `/api/v1/organizations/{organization_id}/members/{link_id}` | `{ "department": DepartmentType \| null }` | 200 `MemberResponse` |

**Entrada.** `department` é **obrigatório** no corpo: ou um dos cinco valores, ou `null`.
Corpo vazio é 422, e não um "não muda nada" silencioso. Os valores são os do enum
`DepartmentType` que já está no `dev` (`app/domains/department/models.py`), escritos
exatamente assim:

| Valor na API | Setor |
|---|---|
| `Marketing` | Marketing |
| `Financeiro` | Financeiro |
| `Administrativo` | Administrativo |
| `RecursosHumanos` | Recursos Humanos |
| `TecnologiaInformacao` | Tecnologia da Informação |

> ⚠️ A tarefa escreve `"Marketing" | ...`. O valor na API é o do enum, **sem espaço**
> (`RecursosHumanos`, não `Recursos Humanos`). O rótulo bonito é trabalho do i18n do front.

**Saída: `MemberResponse`.** Um membro é um vínculo visto com a pessoa:

| Campo | Tipo | De onde vem |
|---|---|---|
| `link_id` | uuid | `links.id` |
| `name` | string | `participants.name` |
| `email` | string \| null | `user.email`. É `null` quando o vínculo não tem login (vínculo criado só pelo `POST .../links`, sem convite) |
| `role` | `admin` \| `gestor` \| `respondente` | `links.role` |
| `type` | `emprego` \| `mentoria` \| `academico` \| `pessoal` | `links.type` |
| `department` | `DepartmentType` \| null | `departments.type` do setor ligado |
| `updated_at` | datetime \| null | `links.updated_at` |

A M-2 lista com este mesmo schema e acrescenta os campos do período. Por isso ele nasce
aqui, sem eles, para os dois endpoints devolverem o membro da mesma forma.

**Erros**, nesta ordem de conferência:

| Código | Quando |
|---|---|
| 401 | sem sessão, ou sessão inválida |
| 403 | papel `respondente`, ou `gestor` pedindo em organização que não é a do próprio vínculo. A conferência vem **antes** da busca, como em `OrganizationService.get`, para a resposta não revelar quais organizações e vínculos existem |
| 404 | a organização não existe (só o `admin` chega aqui), ou o vínculo não existe, ou existe mas é de outra organização. A resposta é a mesma nos três casos |
| 422 | `department` ausente ou fora dos cinco valores (validação do Pydantic) |

## Critérios de aceite

- [ ] Escolher um setor que a empresa ainda não tinha cria **uma** linha em `departments`
      para aquela organização e aquele tipo, e o vínculo passa a apontar para ela.
- [ ] Dois membros da mesma empresa no mesmo setor apontam para o **mesmo**
      `department_id`, sem duplicar a linha.
- [ ] O mesmo setor em **duas empresas** gera dois setores, um por organização.
- [ ] `{"department": null}` tira o setor: `department_id` fica nulo e a resposta traz
      `"department": null`.
- [ ] A resposta é 200 com `MemberResponse`, e `updated_at` vem preenchido.
- [ ] `gestor` em outra organização recebe 403. `respondente` recebe 403 mesmo na própria
      organização.
- [ ] `admin` troca o setor de um membro de qualquer organização (P-066).
- [ ] Vínculo de outra organização no endereço gera 404, e não troca nada.
- [ ] `{"department": "Vendas"}` e `{}` geram 422.
- [ ] Quando a M-2 existir, ela devolve o setor novo. Isso se verifica na M-2: aqui o
      critério é a M-2 reaproveitar o `MemberResponse`.

## Como verificar

```bash
cd creed-backend
ruff check . && ruff format --check .
mypy app
pytest tests/domains/links tests/domains/department -q
pytest   # a suíte inteira, antes do PR
```

À mão, com o banco e o Keycloak de pé (`docker compose up -d db keycloak mailpit`), a
API rodando (`uvicorn app.main:app --reload`) e o token de um gestor (README do back,
seção "Autenticação local (Keycloak)"):

```bash
API=http://localhost:8000/api/v1

# troca para um setor novo da empresa → 200, "department": "Marketing"
curl -s -X PATCH "$API/organizations/$ORG/members/$LINK" \
  -H "Authorization: Bearer $TOKEN_GESTOR" -H "Content-Type: application/json" \
  -d '{"department": "Marketing"}'

# tira o setor → 200, "department": null
curl -s -X PATCH "$API/organizations/$ORG/members/$LINK" -H "Authorization: Bearer $TOKEN_GESTOR" \
  -H "Content-Type: application/json" -d '{"department": null}'

# setor inválido → 422
curl -s -o /dev/null -w "%{http_code}\n" -X PATCH "$API/organizations/$ORG/members/$LINK" \
  -H "Authorization: Bearer $TOKEN_GESTOR" -H "Content-Type: application/json" \
  -d '{"department": "Vendas"}'

# organização de outra empresa → 403
curl -s -o /dev/null -w "%{http_code}\n" -X PATCH "$API/organizations/$OUTRA_ORG/members/$LINK" \
  -H "Authorization: Bearer $TOKEN_GESTOR" -H "Content-Type: application/json" \
  -d '{"department": "Marketing"}'
```

E no banco, depois de pôr dois membros no mesmo setor:

```sql
SELECT organization_id, type, count(*) FROM departments GROUP BY 1, 2 HAVING count(*) > 1;
-- nenhuma linha
```

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-066 | O `gestor` troca o setor só na própria organização e o `admin` em qualquer uma. O alvo pode ser qualquer vínculo da organização: o próprio, o de outro gestor, de qualquer tipo. | baixo |
| P-067 | O setor que fica sem membro continua cadastrado na empresa, e nada apaga setor nesta entrega. | baixo |

## Riscos

- **Duas trocas simultâneas criando o mesmo setor.** Se dois pedidos escolhem, ao mesmo
  tempo, um setor que a empresa ainda não tem, os dois tentam inserir e o segundo bate na
  unicidade `uq_departments_organization_type`. O sinal é um 500 com `IntegrityError` no
  log. O "buscar ou criar" precisa tolerar a corrida (inserir sem erro em conflito e ler de
  novo). A task que implementar isso nomeia o jeito e o teste.
- **O glossário diverge do código.** O `glossario.md` diz que o setor é "dado da
  organização, não enum fixo". O código e esta tarefa usam cinco tipos fixos, com uma
  linha por organização. As duas coisas são verdade ao mesmo tempo, mas quem ler só o
  glossário espera nome livre. Ajustar o verbete fica fora desta spec.
- **O `MemberResponse` nasce antes da M-2.** Se a M-2 precisar de outra forma de membro,
  a C-1 muda junto. O sinal é a M-2 criar um schema próprio em vez de estender este. Como
  o front ainda não consome nenhum dos dois, o custo é baixo agora e sobe quando a M-4
  ligar a tabela.
- **Vínculo sem login.** `email` pode ser `null`. Se alguém assumir que todo membro tem
  e-mail, a tela da M-4 quebra justo nos vínculos criados sem convite.
