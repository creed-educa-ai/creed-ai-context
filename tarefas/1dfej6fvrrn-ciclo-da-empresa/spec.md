# 1dfej6fvrrn — CREED-69 · E-1 a E-6 · Cadastro, aprovação e exclusão de empresas

> Gerada por `workflows/tarefa-to-spec.md` em 2026-11-10, a partir do épico
> [CREED - 69 - Painel de controle](https://app.clickup.com/t/1dfej6fvrrn), seção
> "Empresa (pov administradora)", e das subtarefas
> [691 · Empresa pendente (E1)](https://app.clickup.com/t/1dfej6fvrvn),
> [692 · Cadastro de empresa (E2)](https://app.clickup.com/t/1dfej6fvrvp),
> [693 · Aceitar ou rejeitar pedido (E3)](https://app.clickup.com/t/1dfej6fvrvt),
> [694 · Integração (E4-E5)](https://app.clickup.com/t/1dfej6fvrvu) e
> [696 · Excluir empresa (E6)](https://app.clickup.com/t/1dfej6fvrvw). Não existe 695.
>
> ⚠️ **As cinco subtarefas estão sem descrição no ClickUp.** O texto das irmãs (M-2,
> M-3) veio do Notion "S4 TASKS", que esta sessão não alcança. Esta spec sai da descrição
> do épico, das tarefas antigas que ele substitui
> ([CREED-591](https://app.clickup.com/t/86e3uzwvk) e
> [CREED-595](https://app.clickup.com/t/1dfej6ftzq6)), do trecho da E-6 citado na M-3
> ("mesmo cuidado da E-6 com o Keycloak, que fica fora da transação do banco") e de duas
> exigências do Luís, dono das subtarefas:
>
> 1. o "Esqueci minha senha" do login funciona de ponta a ponta, com o e-mail mandado
>    pelo back;
> 2. aprovar uma empresa manda o e-mail de primeiro acesso a um usuário ligado ao e-mail
>    informado no cadastro.
>
> Se os textos E-1 a E-6 do Notion aparecerem, a entrada é `/atualizar-spec`, não spec
> nova.
>
> **Estado lido:** `dev` do back em `d5c5177` (M-2, M-3 e C-1 mergeadas); a pilha aberta
> da CREED-23.8 no back, [#51](https://github.com/creed-educa-ai/creed-backend/pull/51)
> (`998d872`, convite de membro) e [#52](https://github.com/creed-educa-ai/creed-backend/pull/52)
> (`0af70c1`, reenvio e "esqueci minha senha"); `dev` do front em `68d8fb8`; `main` do
> harness em `d859177`.

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | **Regra de ciclo de vida nova:** a empresa nasce pendente, vira ativa ao ser aprovada e some ao ser rejeitada ou excluída. **Regra de quem pode nova:** aprovar, rejeitar e excluir empresa. Saem **7 premissas novas** (P-075 a P-081), uma delas de custo médio (P-080, exclusão irreversível). Aplica a P-053, também de custo médio. |
| Técnico | T3 | **Migration:** `organizations.status` troca de tipo (ganha `pending`) e a tabela ganha três colunas. **Contrato já consumido muda:** `OrganizationResponse`, que o front lê no cabeçalho do painel da empresa, ganha campos e um valor novo de status. **Dois repos** e quatro rotas novas, uma delas **pública**. A exclusão fala com o **Keycloak** fora da transação do banco. |

Dispensadas nesta calibragem: nenhuma.

## Problema

O ciclo da empresa existe só na tela, sobre mock. O cadastro público (`/sign-up`) não
grava nada, aprovar não cria acesso para ninguém, rejeitar e excluir só tiram a linha da
memória do navegador. No back, a organização não tem estado "pendente", nem onde guardar
o e-mail, o responsável e o telefone do cadastro, nem rota pública, de aprovação ou de
exclusão.

E o épico cortou o botão de reenviar convite: quem perdeu o e-mail usa "Esqueci minha
senha" na tela de login. O front já chama `POST /authentication/password-reset`, mas
essa rota está só na branch do creed-backend#52, ainda aberta. Na `dev` de hoje, o link
termina em 404.

## Quem usa

| Papel | Vê / faz | Para quê |
|---|---|---|
| **Quem cadastra a empresa** (sem login) | preenche o cadastro público e cai em "aguarde confirmação". Aprovada a empresa, recebe no e-mail informado o convite de gestor, define a senha na página do Keycloak e entra. Perdeu o e-mail ou o link venceu (72 h, P-049): "Esqueci minha senha" | pedir acesso à plataforma |
| **Admin** (a administradora, CREED) | a tabela de empresas do painel dela, **sem a organização da própria CREED** (P-081): nome, e-mail, resultados, status e excluir. Na pendente, o modal com nome, documento, e-mail, responsável e telefone, e os botões aceitar e rejeitar. Na ativa ou inativa, excluir | decidir quem entra e tirar quem sai |
| **Gestor** | nada novo nesta entrega: é quem nasce da aprovação. Não aprova, não rejeita e não exclui empresa, nem a própria (403, P-079) | — |
| **Respondente** | nada (403) | — |

## Escopo

**Entra:**

- **E-1 · Empresa pendente (back).** A organização ganha o status `pending` e guarda
  e-mail, responsável e telefone do cadastro. A leitura (`GET /organizacoes` e
  `GET /organizacoes/{id}`) devolve esses campos e o número do documento. O `PATCH`
  continua mudando nome, endereço e `active`/`inactive`, mas recusa **trocar o status**
  de uma empresa pendente: ela só sai desse estado pela aprovação ou pela rejeição.
  Nome e endereço da pendente continuam editáveis (é como o endereço "[A informar]" é
  corrigido, P-075).
- **E-2 · Cadastro público (back).** `POST /organizations/sign-up`, sem login: cria o
  documento e a organização pendente numa chamada.
- **E-6 · Excluir empresa (back).** `DELETE /organizations/{organization_id}`, só
  `admin`: apaga cada membro como a M-3 faz, depois os questionários, os setores, a
  organização e o documento dela, e por último os logins no Keycloak (P-080, P-073).
  **É também a rejeição:** empresa pendente não tem membro, então excluí-la apaga só a
  organização e o documento (P-078).
- **E-3 · Aprovar (back).** `POST /organizations/{organization_id}/approval`, só `admin`:
  a empresa vira ativa e quem cadastrou recebe o convite de **gestor** no e-mail
  informado, pelo mesmo caminho do convite de membro (creed-backend#51). Tudo ou nada:
  se o convite falha, a empresa continua pendente.
- **E-4/E-5 · Integração (front).** O mock de empresas sai do `organizationsApi.ts`. O
  cadastro, a tabela, o modal de aceite e a exclusão chamam as rotas acima, e a tela
  passa a ler `OrganizationResponse` (o tipo provisório `Company` sai). O texto de
  "aguarde confirmação" diz que o acesso chega por e-mail e aponta o "Esqueci minha
  senha". A confirmação de exclusão avisa que não dá para desfazer.
- **"Esqueci minha senha" de ponta a ponta.** A tela e a chamada já estão na `dev` do
  front ([creed-frontend#52](https://github.com/creed-educa-ai/creed-frontend/pull/52)).
  Falta a rota do back chegar à `dev` com o creed-backend#52. Esta entrega **depende**
  do #52 e **verifica** o fluxo com o gestor recém-aprovado; não reescreve a rota.
- Documentação: `catalogo.md` (rotas de `organizacoes`), `glossario.md` (Organização
  com status pendente), `conventions/contrato-front-back.md` (a linha "Empresas" vira
  resolvida) e o ledger.

**Não entra:**

- **"Ver resultados"** da empresa (abrir o dashboard dela para a administradora): o
  domínio `dashboards` não tem rota de leitura. O botão fica como está.
- **Reenviar convite** pela tabela de empresas: cortado no épico. O caminho é o
  "Esqueci minha senha".
- **E-mail avisando a rejeição** (P-078).
- **Editar e-mail, responsável e telefone** depois do cadastro: o `PATCH` continua
  com nome, endereço e status.
- **Conferir o dígito verificador** do CPF/CNPJ (P-076).
- **Proteger o cadastro público contra abuso** (captcha, limite de requisições). Ver
  Riscos.
- **Tabela de membros, mentorandos, período e troca de setor**: são as outras
  subtarefas do épico (M-2, M-3, M-4, P-5, P-6, C-1, C-2).
- **A rota de "esqueci minha senha" e o reenvio de convite** em si: são da CREED-23.8
  (creed-backend#52).
- **Renomear `/organizacoes`** para inglês: contrato consumido, e o ADR-0005 (item 4)
  não renomeia código existente.
- **Guarda por papel nas rotas do front** (`/control-panel/admin` abre para qualquer
  pessoa logada, P-055): esconder não é autorização, e quem barra é o back.
- **Infra de produção.** O e-mail na EC2 depende do
  [creed-infrastructure#10](https://github.com/creed-educa-ai/creed-infrastructure/pull/10),
  já aberto. Ver Riscos.

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-backend | `organizacoes`: enum `OrganizationStatus`, três colunas, schemas de entrada e saída, `sign_up`, aprovação e exclusão no service, e um **segundo router**, `router_organizations.py`, com as rotas novas em `/organizations`. `documents`: criar, ler por lista de ids e apagar. `users`: dois services de composição, de aprovação e de exclusão de empresa, ao lado do `MemberService` e do `MemberRemovalService`. `links`, `forms`, `responses`, `department` e `participants`: um método de leitura ou de exclusão cada. `tests/test_arquitetura.py`: os motivos de `COMPOE_COM_SERVICE_DE`. Migration **temporária**, que não sobe no PR (ADR-0009) |
| creed-frontend | feature `organizations` (`organizationsApi.ts`, `organizationsSlice.ts`, `SignUpView.tsx`, `AwaitingConfirmationView.tsx`, `CompaniesSection.tsx`, `CompanyTable.tsx`), `components/modals/CompanyApprovalModal.tsx`, `types/api.ts`, `lib/validators.ts` e os três locales |
| creed-infrastructure | nada |
| creed-ai-context | esta pasta, o ledger, `catalogo.md`, `glossario.md` e `conventions/contrato-front-back.md` |

Nome do domínio e da feature: `organizacoes` no back e `organizations` no front. É a
exceção de nome já registrada no `catalogo.md`. As **rotas novas** são em inglês
(`/organizations/...`), como manda o ADR-0005; ver Abordagem técnica, item 5.

## Contrato

Prefixo `/api/v1`. Rota existente é marcada como tal.

| Método | Rota | Quem | Entrada | Saída | Erros |
|---|---|---|---|---|---|
| POST | `/organizations/sign-up` | **público** (sem token) | `OrganizationSignUp` | 201 `OrganizationResponse` com `status: "pending"` | 409 documento já cadastrado · 422 campo inválido, inclusive documento que não tem 11 nem 14 dígitos (P-076) |
| GET | `/organizacoes` *(existe)* | admin | `pagina`, `tamanho_pagina` (até 200) | `PaginaDe[OrganizationResponse]`, **agora com as pendentes** | 401 · 403 |
| GET | `/organizacoes/{organization_id}` *(existe)* | admin; gestor só a própria | — | `OrganizationResponse` | 401 · 403 · 404 |
| PATCH | `/organizacoes/{organization_id}` *(existe)* | admin | `OrganizationUpdate` (sem mudança: nome, endereço, `status` só `active`/`inactive`) | `OrganizationResponse` | **novo:** 409 se o corpo traz `status` e a empresa está pendente · 401 · 403 · 404 · 422 |
| POST | `/organizations/{organization_id}/approval` | admin | — | 200 `OrganizationResponse` com `status: "active"` | 404 · 409 empresa que não está pendente · 409 e-mail que já tem acesso (P-077) · 503 Keycloak ou envio de e-mail fora do ar · 401 · 403 |
| DELETE | `/organizations/{organization_id}` | admin | — | 204 | 404 · 409 a própria organização (P-079) · 503 Keycloak fora do ar, e nada é apagado (P-073) · 401 · 403 |

`OrganizationSignUp` (todos obrigatórios, espaços nas pontas saem, sem caractere de
controle):

| Campo | Regra | Vem da tela |
|---|---|---|
| `name` | 1 a 200 | "Nome da empresa" |
| `document` | 1 a 100; o back guarda só letras e números e deduz o tipo (P-076) | "Documento (CPF/CNPJ)" |
| `email` | `EmailStr`, gravado em minúsculas | "E-mail da empresa" |
| `contact_name` | 1 a 200 | "Seu nome completo" |
| `phone` | 1 a 30, texto livre | "Telefone" |

`OrganizationResponse` ganha, sem perder nenhum campo:

| Campo | Tipo | Nota |
|---|---|---|
| `status` | `"pending" \| "active" \| "inactive"` | era `RecordStatus`; o valor novo é `pending` |
| `email` | `str \| None` | nulo nas organizações criadas pelo `POST /organizacoes` |
| `contact_name` | `str \| None` | idem |
| `phone` | `str \| None` | idem |
| `document` | `{type, value}` | `type` é o `DocType` (`cpf`, `cnpj`, …); `value`, o número guardado |

Aprovar não tem corpo: o convite usa o que a empresa informou. O vínculo nasce com papel
`gestor` e tipo `emprego`, o nome é o `contact_name` e o e-mail é o `email` (P-053,
P-047).

## Dados

| Tabela | Mudança | Dado que já existe |
|---|---|---|
| `organizations` | `status` troca o tipo `recordstatus` por um tipo novo, `organization_status` (`pending`, `active`, `inactive`). O padrão continua `active`, e o `POST /organizacoes` continua criando ativa | cada linha mantém o status que tem, por cast de texto |
| `organizations` | três colunas novas, todas **anuláveis**: `email` (`String(320)`), `contact_name` (`String(200)`) e `phone` (`String(30)`) | ficam nulas; só o cadastro público as preenche |
| `documents` | nenhuma mudança de schema. O cadastro cria uma linha, e a exclusão apaga a da organização | — |

**Migration temporária (ADR-0009).** O PR de tarefa não traz arquivo em
`alembic/versions/`. A seção "Banco" do PR da E-1 registra o ajuste manual que a
consolidação vai precisar, porque o autogenerate **não escreve a troca de tipo de enum**
direito:

1. `CREATE TYPE organization_status AS ENUM ('pending', 'active', 'inactive')`;
2. `ALTER TABLE organizations ALTER COLUMN status TYPE organization_status USING status::text::organization_status`;
3. `add_column` das três colunas, sem `server_default`;
4. **downgrade:** `UPDATE organizations SET status = 'inactive' WHERE status = 'pending'`,
   o `ALTER` de volta para `recordstatus` com o mesmo `USING`, o `drop_column` das três e
   o `DROP TYPE organization_status`. Nenhuma linha é apagada na volta.

O tipo `recordstatus` **não muda**: continua sendo de `user` e `participants`.

**A exclusão (E-6) apaga nesta ordem**, que é a das chaves estrangeiras:

1. cada vínculo da organização, pelo `MemberRemovalService.delete_member_data` (M-3):
   respostas, insights, dashboards, questionários individuais com as perguntas, login,
   vínculo e, sem outro vínculo, participante e perfil demográfico;
2. os questionários da organização que sobraram (`form.organization_id`, os "para
   todos"): antes, as respostas que ainda apontarem para eles, com os insights e os
   dashboards delas; depois, as perguntas e as alternativas;
3. os setores (`departments.organization_id`);
4. a organização;
5. o documento dela, se nenhum participante apontar para ele (P-080);
6. por último, numa chamada só, os logins no Keycloak
   (`MemberRemovalService.remove_logins_from_keycloak`), antes do commit (P-073).

## Abordagem técnica

1. **"Pendente" é um enum próprio da organização** (`OrganizationStatus`, em
   `app/domains/organizacoes/models.py`, tipo `organization_status` no banco). O
   `OrganizationUpdate.status` continua `RecordStatus` (`active`/`inactive`), então o
   `PATCH` não aceita `pending`.
   *Descartada:* acrescentar `pending` ao `RecordStatus`. O tipo `recordstatus` é
   compartilhado com `user` e `participants` (`app/shared/enums.py`), e "pendente"
   passaria a ser valor válido para login e participante, em todo schema que expõe o
   enum. *Descartada também:* uma coluna `approved_at`, com o status deduzido dela. A
   tarefa fala em status, e o front já desenha por status.

2. **O pedido é a própria organização** (decidido no épico). Os dados de contato moram
   em colunas de `organizations`.
   *Descartada:* criar participante e vínculo já no cadastro, deixando para a aprovação
   só o login. Haveria pessoa cadastrada numa empresa que ninguém aprovou, o e-mail e o
   telefone continuariam sem lugar (o participante não tem nenhum dos dois), e a
   rejeição teria de apagar mais coisa.

3. **Aprovar é uma rota de ação** (`POST .../approval`), que reusa o
   `MemberService.invite_member_service` do creed-backend#51. Ele já é tudo ou nada: cria
   participante, vínculo e acesso, manda o e-mail e, se algo falha, o `get_db` desfaz o
   banco e o próprio service desfaz o Keycloak (D7 da 23.8). A aprovação só põe antes a
   troca de status, na mesma transação.
   *Descartada:* aprovar pelo `PATCH status=active` com o convite como efeito colateral.
   O `PATCH` passaria a fazer duas coisas, e qualquer outro caminho que mudasse o status
   pularia o convite. Por isso o `PATCH` passa a recusar a troca de status de uma
   empresa pendente.

4. **Aprovação e exclusão moram em `users`, como a M-3.** O `users` já depende de
   `organizacoes` (`MemberService` usa o `OrganizationService`), de `links`, `forms`,
   `questions`, `responses`, `insights`, `dashboards`, `demographics` e `participants`
   (`MemberRemovalService`). Os dois services novos ficam em
   `app/domains/users/service.py`: `OrganizationApprovalService`, ao lado do
   `MemberService`, e `OrganizationRemovalService`, ao lado do `MemberRemovalService`. A
   M-3 já separou `delete_member_data` e `remove_logins_from_keycloak` **para a E-6**:
   o docstring diz isso. As rotas ficam no domínio dono do caminho (`organizacoes`) e
   delegam a `users.dependencies`, como `links/router_members.py` faz com a M-3.
   *Descartada:* os services em `organizacoes`. Seria `organizacoes → users` e
   `users → organizacoes`: import circular. *Descartada também:* um domínio novo só de
   composição. É um padrão que não existe no código nem no harness.

5. **As rotas novas usam o prefixo em inglês** (`/organizations/...`). O ADR-0005 manda
   inglês em todo identificador novo, e o `conventions/estrutura-e-nomes.md` diz da
   rota `organizacoes`: "Nenhum é permissão para nomear coisa nova em português". As
   rotas aninhadas já são em inglês (`/organizations/{id}/links`, `.../members`). Ficam
   num segundo router do domínio, `app/domains/organizacoes/router_organizations.py`,
   como os segundos routers que já existem (`links/router_members.py`,
   `forms/router_periods.py`).
   **Preço aceito:** o mesmo recurso responde em dois prefixos, com `GET` e `PATCH` em
   `/organizacoes/{id}` e `DELETE` em `/organizations/{id}`. O front já convive com os
   dois prefixos (`linksApi.ts` e `usersApi.ts` chamam `/organizations/{id}/...`), mas o
   `organizationsApi.ts` passa a ser o primeiro arquivo que usa os dois.
   *Descartada:* `DELETE /organizacoes/{id}` e `/organizacoes/{id}/approval`. A primeira
   é nome novo em português, e a segunda mistura os dois idiomas na mesma URL.
   *Descartada também:* renomear `/organizacoes`. Quebra contrato consumido, e o
   ADR-0005 não renomeia código existente.

6. **Rejeitar é excluir** (`DELETE /organizations/{id}`, a mesma rota da E-6). Empresa
   pendente não tem vínculo, então o passo 1 da ordem acima não apaga nada.
   *Descartada:* uma rota própria de rejeição. Seriam duas rotas apagando a mesma linha,
   com dois conjuntos de testes. Por causa disso, **a E-6 vem antes da E-3** na ordem
   de entrega.

7. **O documento do cadastro é criado pelo `DocumentService`** (método novo), chamado
   pelo `OrganizationService.sign_up` na mesma transação. Na leitura, o número do
   documento vem do `DocumentService` numa consulta por página (`list_by_ids`), e não
   numa consulta por organização.
   *Descartada:* JOIN de `organizations` com `documents` no repository. Seria leitura
   fora do próprio domínio, que pede exceção declarada em `LEITURA_ENTRE_DOMINIOS` do
   `tests/test_arquitetura.py`, e a consulta por página já resolve.

8. **No front, a tela passa a ler o contrato do back.** O tipo provisório `Company`
   (`nomeEmpresa`, `documento`…) sai, como decidido em 2026-11-02 no
   `conventions/contrato-front-back.md` ("resolvida na integração — dos dois lados").
   A lista vem inteira: o slice lê `GET /organizacoes` com `tamanho_pagina=200`, página
   a página, até o `total`, porque a tabela pagina e ordena na própria tela.
   *Descartada:* manter `Company` e converter no `organizationsApi.ts`. A tela
   continuaria com um nome de campo por lado e um mapa a manter.

## Mapa das entregas

Ordem de entrega e por onde começar. Back e front são entregas separadas.

| # | Subtarefa | Repo | Depende de | Primeiro arquivo | Terminou quando |
|---|---|---|---|---|---|
| 1 | **E-1** · Empresa pendente | back | — (sai da `dev`) | `app/domains/organizacoes/models.py` | o `GET /organizacoes` devolve `status`, `email`, `contact_name`, `phone` e `document`, e o `PATCH` de `status` numa pendente dá 409 |
| 2 | **E-2** · Cadastro público | back | 1 | `app/domains/organizacoes/router_organizations.py` (novo), com `app/domains/organizacoes/service.py` ao lado | o `curl` sem token do "Como verificar" cria uma empresa pendente, e o documento repetido dá 409 |
| 3 | **E-6** · Excluir (e rejeitar) | back | 1; a M-3 já está na `dev` | `app/domains/users/service.py`, na classe `MemberRemovalService` | excluir uma empresa com membros apaga tudo e os logins somem do realm; com o Keycloak parado, 503 e nada some |
| 4 | **E-3** · Aprovar | back | 1, 3 e o **creed-backend#51 na `dev`** | `app/domains/users/service.py`, na classe `MemberService` | aprovar põe o convite no Mailpit, e o link leva ao login como gestor |
| 5 | **E-4/E-5** · Integração | front | 2, 3, 4 na `dev`; para o "Esqueci minha senha", o **creed-backend#52 na `dev`** | `src/features/organizations/organizationsApi.ts` | o fluxo do "Como verificar", da tela de cadastro até a exclusão, roda no navegador sem mock |

As entregas 1 a 4 são uma pilha de branches no back (modo AGES III, item 5). A 4 só sai
quando o #51 estiver na `dev`. Até lá, dá para escrever a aprovação contra o
`MemberService` da branch dele, mas não para subir.

## Critérios de aceite

**E-1 · Empresa pendente**

- [ ] `organizations.status` aceita `pending`, e `user.status` e `participants.status`
      continuam recusando esse valor.
- [ ] O `GET /organizacoes` e o `GET /organizacoes/{id}` devolvem `email`,
      `contact_name`, `phone` e `document: {type, value}`. Numa organização criada pelo
      `POST /organizacoes`, os três primeiros vêm `null`.
- [ ] A listagem faz **uma** consulta de documentos por página, não uma por
      organização. Um teste do service conta as chamadas ao `DocumentService`.
- [ ] O `PATCH /organizacoes/{id}` com `status` numa empresa pendente responde 409, e
      nada muda. Com só `name` ou `address`, responde 200 e a empresa continua
      pendente. Numa ativa, o `PATCH` continua como antes.
- [ ] O `POST /organizacoes` continua criando organização ativa, sem os campos novos no
      corpo.

**E-2 · Cadastro público**

- [ ] `POST /organizations/sign-up` sem token responde 201, com `status: "pending"` e os
      cinco campos gravados. O e-mail é gravado em minúsculas.
- [ ] `"12.345.678/0001-90"` vira documento `cnpj` de valor `12345678000190`, e
      `"123.456.789-09"` vira `cpf` de valor `12345678909`.
- [ ] O documento `"123"` responde 422, e nada é gravado.
- [ ] Repetir o mesmo CNPJ, com ou sem pontuação, responde 409, e nada é gravado.
- [ ] Campo faltando ou vazio responde 422, com um item por campo.

**E-6 · Excluir (e rejeitar)**

- [ ] Excluir uma **pendente** responde 204 e apaga a organização e o documento. O mesmo
      documento pode ser cadastrado de novo em seguida (201).
- [ ] Excluir uma **ativa com membros** responde 204 e não deixa linha nenhuma que aponte
      para ela: vínculos, logins, respostas, questionários, perguntas, setores. O
      participante com vínculo em **outra** organização continua, com esse outro vínculo.
- [ ] Os logins dos membros somem do realm, e nenhum deles consegue entrar.
- [ ] Com o Keycloak parado, responde 503, e a empresa e os membros continuam no banco.
      O log diz quais logins já saíram do realm (P-073).
- [ ] Excluir a organização do próprio vínculo responde 409. Gestor e respondente
      recebem 403. Organização inexistente dá 404.

**E-3 · Aprovar**

- [ ] Aprovar uma pendente responde 200 com `status: "active"`, e o convite chega ao
      e-mail do cadastro, em nome do responsável, com papel `gestor` e vínculo `emprego`.
- [ ] Pelo link do e-mail, a pessoa define a senha e entra pelo login da plataforma como
      gestor da empresa.
- [ ] Aprovar de novo, ou aprovar uma ativa, responde 409.
- [ ] Se o e-mail já tem acesso, responde 409, e a empresa continua pendente, sem
      participante, vínculo nem usuário novo (P-077).
- [ ] Com o Mailpit parado, responde 503, e a empresa continua pendente, sem nada novo
      no banco nem no realm.
- [ ] Gestor e respondente recebem 403.

**E-4/E-5 · Integração (front)**

- [ ] O `organizationsApi.ts` não tem mais mock de empresas, nem os tipos `Company`,
      `CompanyRegistration` e `CompanyStatus` em `types/api.ts`.
- [ ] O cadastro chama `POST /organizations/sign-up` e, no 201, vai para
      `/awaiting-confirmation`. O 409 de documento aparece no campo "Documento". Os
      outros erros, 422 incluído, aparecem num aviso abaixo do botão: o formulário já
      barra antes o que o back recusaria com 422.
- [ ] O formulário de cadastro recusa e-mail mal formado e documento sem 11 ou 14
      dígitos antes de chamar o back, com as mesmas regras da P-076.
- [ ] "Aguarde confirmação" diz que o acesso chega por e-mail depois da aprovação e que,
      sem o e-mail, o caminho é "Esqueci minha senha" na tela de login. O texto está nos
      três locales.
- [ ] A tabela mostra todas as organizações menos a da sessão (P-081): pendente como
      botão "Pendente", ativa como "Ativo" e inativa como "Inativo".
- [ ] O modal mostra nome, documento (o número), e-mail, responsável e telefone vindos do
      back. Aceitar chama a aprovação e troca a linha pela resposta. Rejeitar chama a
      exclusão e tira a linha.
- [ ] O 409 da aprovação aparece num toast que diz as duas causas possíveis (a empresa
      já não está pendente, ou o e-mail já tem acesso) e recarrega a lista. O 503
      aparece num toast que pede para tentar de novo.
- [ ] A confirmação de exclusão diz que a empresa, os membros e as respostas saem, e que
      não dá para desfazer.
- [ ] `npm run check` passa.

**"Esqueci minha senha" de ponta a ponta**

- [ ] Com o creed-backend#52 na `dev`, o gestor recém-aprovado pede o link em
      `/reset-password`, o e-mail chega ao Mailpit, e o link define uma senha nova.

## Como verificar

Back, a cada entrega:

```bash
cd creed-backend
ruff check . && ruff format --check .
pre-commit run mypy --all-files
pytest tests/domains/organizacoes tests/domains/documents tests/domains/users tests/test_arquitetura.py -q
pytest
```

À mão, com o banco, o Keycloak e o Mailpit de pé (`docker compose up -d db keycloak mailpit`),
a migration temporária aplicada **só no banco local**, a API rodando
(`uvicorn app.main:app --reload`) e o token do admin do seed (README do back, seção
"Autenticação local (Keycloak)"):

```bash
API=http://localhost:8000/api/v1
CORPO='{"name":"Empresa Teste","document":"12.345.678/0001-90","email":"gestora@empresa.test","contact_name":"Gestora Teste","phone":"51 99999-0000"}'

# E-2: cadastro sem token → 201, "status": "pending"
curl -s -X POST "$API/organizations/sign-up" -H "Content-Type: application/json" -d "$CORPO"
ORG=<id da resposta>

# E-2: mesmo documento sem pontuação → 409; documento "123" → 422
curl -s -o /dev/null -w "%{http_code}\n" -X POST "$API/organizations/sign-up" \
  -H "Content-Type: application/json" -d "${CORPO/12.345.678\/0001-90/12345678000190}"
curl -s -o /dev/null -w "%{http_code}\n" -X POST "$API/organizations/sign-up" \
  -H "Content-Type: application/json" -d "${CORPO/12.345.678\/0001-90/123}"

# E-1: a pendente aparece na lista, com os dados de contato e o documento
curl -s "$API/organizacoes?tamanho_pagina=200" -H "Authorization: Bearer $TOKEN_ADMIN"

# E-1: PATCH de status numa pendente → 409
curl -s -o /dev/null -w "%{http_code}\n" -X PATCH "$API/organizacoes/$ORG" \
  -H "Authorization: Bearer $TOKEN_ADMIN" -H "Content-Type: application/json" -d '{"status":"active"}'

# E-3: aprovar → 200 "active"; o convite aparece em http://localhost:8025
curl -s -X POST "$API/organizations/$ORG/approval" -H "Authorization: Bearer $TOKEN_ADMIN"
# aprovar de novo → 409
curl -s -o /dev/null -w "%{http_code}\n" -X POST "$API/organizations/$ORG/approval" \
  -H "Authorization: Bearer $TOKEN_ADMIN"
```

Abra o e-mail no Mailpit, defina a senha pelo link e entre em
`http://localhost:5173/login` como `gestora@empresa.test`. Depois, peça o link de novo em
`http://localhost:5173/reset-password` e confira o segundo e-mail no Mailpit (este passo
precisa do #52 na `dev`).

```bash
# E-6: excluir a própria organização → 409 (ORG_CREED = organization_id da sessão do admin)
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/organizations/$ORG_CREED" \
  -H "Authorization: Bearer $TOKEN_ADMIN"

# E-6: Keycloak parado → 503, e a empresa continua
docker compose stop keycloak
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/organizations/$ORG" \
  -H "Authorization: Bearer $TOKEN_ADMIN"
docker compose start keycloak

# E-6: excluir de verdade → 204; depois, GET → 404 e o login da gestora falha
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE "$API/organizations/$ORG" \
  -H "Authorization: Bearer $TOKEN_ADMIN"
curl -s -o /dev/null -w "%{http_code}\n" "$API/organizacoes/$ORG" -H "Authorization: Bearer $TOKEN_ADMIN"
```

Para o 409 de e-mail com acesso (P-077): cadastre uma segunda empresa com o e-mail de um
usuário que já existe, aprove (409, continua `pending`) e rejeite (`DELETE`, 204).

Front, depois das entregas 1 a 4 na `dev`:

```bash
cd creed-frontend
npm run check
npm run dev
```

No navegador: `/sign-up` → `/awaiting-confirmation`; entre como admin, abra
`/control-panel/admin`, abra a pendente pelo botão "Pendente", aceite, confira o convite
no Mailpit; cadastre outra e rejeite; exclua uma ativa. Repita em 375 px de largura.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-053 *(já aberta)* | Aprovar a empresa convida quem cadastrou, no e-mail informado, como `gestor` | médio |
| P-075 | O cadastro não pede endereço: a organização nasce com o endereço "[A informar]", como a da CREED (P-059), e a administradora corrige pelo `PATCH` | baixo |
| P-076 | Documento: o back guarda só letras e números; 11 dígitos é CPF, 14 é CNPJ, outra forma é 422. Sem dígito verificador. Documento já cadastrado é 409, dito na mensagem | baixo |
| P-077 | O cadastro não confere se o e-mail já tem acesso. A aprovação confere: 409, e a empresa continua pendente | baixo |
| P-078 | Rejeitar apaga a empresa e o documento dela, sem e-mail de aviso, e a mesma empresa pode se cadastrar de novo | baixo |
| P-079 | Aprovar, rejeitar e excluir empresa é só do `admin`, que não exclui a organização do próprio vínculo (409) | baixo |
| P-080 | Excluir a empresa apaga cada membro como a M-3 e, depois, os questionários da organização, os setores, a organização e o documento dela, se nenhum participante apontar para ele | médio |
| P-081 | A tabela de empresas não mostra a organização da sessão (a da CREED); as outras aparecem em qualquer status, inativa como "Inativo" | baixo |

O texto completo, com o motivo de cada uma, está em `decisoes/premissas.md`. Onde cada
uma vale no código:

> 🟡 **Premissa P-075** — `OrganizationService.sign_up`: endereço "[A informar]".
> 🟡 **Premissa P-076** — `OrganizationSignUp` e o `signUpSchema` do front: 11 ou 14
> dígitos; `OrganizationService.sign_up`: 409 do documento.
> 🟡 **Premissa P-077** — `OrganizationApprovalService.approve`: o 409 do e-mail sobe do
> `create_user_service`.
> 🟡 **Premissa P-078** e **P-080** — `OrganizationRemovalService.remove_organization`.
> 🟡 **Premissa P-079** — a guarda das duas rotas e o 409 da própria organização.
> 🟡 **Premissa P-081** — `CompaniesSection.tsx`: o filtro pela sessão e o rótulo
> "Inativo".

Aplicadas sem mudar: P-008 (a empresa pede, a cliente aprova), P-047 (vínculo
`emprego`), P-049 (link de 72 h), P-057 (organização inativa recebe convite), P-072 e
P-073 (o que a M-3 apaga e quando chama o Keycloak).

## Riscos

- **A E-3 e o "Esqueci minha senha" dependem de PRs abertos.** O creed-backend#51
  (convite) e o #52 (reset) estão com mudanças pedidas e conflitos com a `dev`, e há
  uma sessão trabalhando neles agora. O sinal é a entrega 4 pronta sem poder subir.
  Enquanto isso, as entregas 1, 2 e 3 andam.
- **Em produção, aprovar dá 503 até o e-mail da EC2 existir.** O SMTP de produção é o
  creed-infrastructure#10, aberto. Sem ele, o Keycloak não manda o convite, e a
  aprovação desfaz tudo. O sinal é o 503 na primeira aprovação real.
- **A troca de tipo do `status` não sai do autogenerate.** Se a consolidação não
  escrever o `ALTER ... USING` à mão, o `alembic check` pode passar com a coluna ainda
  em `recordstatus`, e o primeiro cadastro dá 500 (`invalid input value for enum`).
  Por isso o passo está escrito em Dados e vai na seção "Banco" do PR.
- **Rota pública sem limite.** Qualquer pessoa pode encher a tabela de pendentes, e a
  administradora rejeita uma a uma. O sinal é a tabela com pendentes que ninguém
  reconhece. Captcha ou limite de requisições ficam para uma tarefa própria.
- **Excluir uma empresa grande numa requisição só.** Cada membro é uma rodada de
  exclusões no banco, e todos os logins vão ao Keycloak antes do commit. Uma empresa com
  muitas pessoas pode estourar o tempo da requisição. Aí o banco desfaz tudo e a resposta
  é 503 (ou o proxy corta antes). Repetir resolve, porque o 404 do realm conta como
  sucesso (P-073), mas, entre a primeira tentativa e a repetição, quem já saiu do realm
  não entra. O sinal é o aviso no log com a lista de logins.
- **E-mail de caixa compartilhada (P-053).** Se o cadastro informar `contato@`, o acesso
  de gestor fica com quem lê essa caixa.
- **O mesmo recurso em dois prefixos** (`/organizacoes/{id}` e `/organizations/{id}`).
  Quem integrar pode chamar o `DELETE` no prefixo errado. O sinal é um 405 ou 404 no
  front. A tabela de Contrato e os comentários do `organizationsApi.ts` dizem qual é qual.
