# 86e35vhxm — CREED-23.8 · Convite de primeiro acesso por e-mail (link para o realm do Keycloak)

> Gerada por `workflows/tarefa-to-spec.md` em 2026-10-24, a partir da subtarefa
> [CREED-23.8](https://app.clickup.com/t/86e35vhxm) do épico
> [CREED-23](https://app.clickup.com/t/86e348g6u). Estado lido: `dev` do back em `1d90b2a`,
> do front em `afd9882` e do infra em `353e11c`; `main` do harness em `8d978a3`.
>
> A entrada é a revisão do mesmo dia,
> [`revisao-23.8.md`](../86e348g6u-autenticacao-da-plataforma/revisao-23.8.md). Ela tem o
> levantamento de git e o que mudou desde a spec do épico. Esta spec usa as conclusões e
> não repete o levantamento. O roteiro da AWS da revisão (§10) está superado: veja abaixo.
>
> **Refinada em 2026-10-27** pelo adendo do
> [ADR-0006](../../decisoes/adrs/0006-e-mail-transacional.md), que entrou no
> [creed-ai-context#37](https://github.com/creed-educa-ai/creed-ai-context/pull/37). O
> provedor de produção passou a ser o **Gmail do projeto por SMTP**, no lugar do SES: sem
> domínio, o SES não tinha remetente que passasse no DMARC. O #37 já tinha trocado o SES
> pelo Gmail na calibragem, no escopo, no corte, nos critérios e no "Como verificar". Este
> refino acertou o que ficou para trás:
> - **Não entra:** o domínio próprio e o SES;
> - **Documentos da entrega 8:** o adendo já existe;
> - **Riscos:** o remetente agora passa no DMARC, e o que sobra é o link com IP; entram a
>   senha de app revogada e a conta com uma pessoa só.
>
> ⚠️ **A descrição da 23.8 no ClickUp (08/09) está desatualizada.** A tabela
> "Hoje/Depois" dela diz que o `POST /users` recebe `initial_password`, e ele nunca
> recebeu: recebe o `keycloak_id` de um usuário criado à mão no realm, e o back não fala
> com a Admin API. O provisionamento que a 23.3 prometeu (decisão D4 do épico) entra aqui.
>
> **Duas decisões do Luís, em 2026-10-24, antes da spec** (as paradas da revisão, §11):
> - **D7 — tudo ou nada.** Se o convite não sai (SMTP ou Keycloak fora do ar), nada é
>   criado: o usuário do realm é apagado, o banco volta, e a resposta é 503.
> - **D8 — "adicionar membro" é um endpoint composto no back.** Uma chamada cria
>   participante, vínculo, usuário e convite numa transação; o front não orquestra três
>   chamadas.
>
> D7 e D8 continuam a numeração do épico (D1–D6). Não são premissas: são decisões
> técnicas do responsável técnico e não dependem da cliente. D9 a D12, em "Abordagem
> técnica", saem delas.

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | **Regra de permissão nova**: o `gestor` passa a criar acesso na própria organização (P-045 ajusta a P-008). **Ciclo de vida novo** do acesso: convite, reenvio e redefinição de senha. **Nove premissas novas** (P-045 a P-053), duas de custo médio (P-048 e P-053). |
| Técnico | T3 | **Infra**: realm de produção que não relê o arquivo, SMTP do Gmail, compose e `.env` da EC2, `Dockerfile`. **Padrão que não existe no código**: cliente da Admin API do Keycloak e compensação entre dois sistemas. **Mudança em contrato publicado**: o `POST /users` perde `keycloak_id`, e o login passa a responder 503 (hoje 401). Três repositórios, mais o harness. |

Dispensadas nesta calibragem: nenhuma.

## Problema

Hoje, dar acesso a alguém é trabalho manual. Uma pessoa do time cria o usuário no
console do Keycloak, com uma senha, copia o id dele, chama `POST /users` com esse id e
entrega a senha por fora da plataforma (WhatsApp, papel). Em produção nem isso é viável:
o console só abre por túnel SSH, e o primeiro admin ainda não existe (CREED-285, parte E).

Enquanto isso não muda:

- as telas que dão acesso a alguém não têm o que chamar. São três: membros da empresa
  (CREED-501, já mergeada), mentorandos da professora (CREED-594) e empresas aprovadas
  (CREED-591/595);
- a senha de todo mundo circula fora da plataforma;
- quem esquece a senha depende de um admin. Além disso, o front já mostra um "Esqueci
  minha senha" que leva a uma tela falsa de nova senha, que não chama API nenhuma.

## Quem usa

"Vínculo" é a ligação de uma pessoa com uma organização, com um papel e um período; um
login é sempre de um vínculo (modelo [C2]). "Participante" é a pessoa, independente do
vínculo.

| Papel | O que esta entrega dá |
|---|---|
| `admin` (a professora e o time CREED) | convida em **qualquer** organização, com qualquer papel; reenvia convite; apaga acesso. O primeiro admin de produção nasce por convite (P-052) |
| `gestor` (responsável pela empresa) | convida **só na organização do próprio vínculo**, como `gestor` ou `respondente` (P-045); reenvia o convite de quem é da organização dele |
| `respondente` | não convida. Como todo papel, usa "esqueci minha senha" |
| Pessoa convidada (ainda sem senha) | recebe o e-mail, abre o link, define a senha na página do Keycloak e entra pela tela de login da plataforma. Não vê tela nenhuma da plataforma antes disso |
| Quem não tem acesso | não entra. "Esqueci minha senha" responde a mesma coisa para e-mail com ou sem acesso, para não revelar quem tem cadastro |

> 🟡 **Premissa P-045** — `admin` convida em qualquer organização e com qualquer papel;
> `gestor`, só na própria organização e só como `gestor` ou `respondente`; `respondente`
> não convida. Confirmar na próxima reunião.

## Escopo

**Entra:**

1. **E-mail no ambiente local**: serviço Mailpit no `docker-compose`, e SMTP no realm por
   variável de ambiente (ADR-0006).
2. **Realm**:
   - páginas e e-mail em português (P-050);
   - política de senha de 8 caracteres (a P-004 de 07/09);
   - link de volta para a plataforma (P-051);
   - e-mail que só o `admin` edita no perfil (D12).
3. **Cadastro de acesso nos dois lados**: o `POST /users` cria o usuário no Keycloak sem
   senha, dá a ele o papel do vínculo, grava no banco e manda o convite. É tudo ou nada
   (D7). O `keycloak_id` sai do corpo.
4. **Adicionar membro**: `POST /organizations/{organization_id}/members`, que cria
   participante, vínculo, usuário e convite numa chamada (D8), com a regra de quem
   convida (P-045).
5. **Reenviar convite**: `POST /users/{user_id}/invitation`.
6. **Esqueci minha senha**: `POST /authentication/password-reset`, que manda o mesmo
   e-mail do convite (D10).
7. **503 quando o Keycloak ou o SMTP não respondem**: no cadastro, no convite, no reset,
   no login e na renovação. Hoje o login responde 401.
8. **`DELETE /users/{user_id}` apaga também no Keycloak**, para o mesmo e-mail poder ser
   convidado de novo.
9. **Primeiro admin por convite**: script que roda na EC2 e convida o admin sem senha
   conhecida (P-052), na organização da CREED (P-048).
10. **Front**:
    - saem a rota `/primeiro-acesso` e a tela falsa de nova senha;
    - `/recuperar-senha` vira um formulário de e-mail;
    - o `AddMemberForm` ganha o campo nome (P-046) e a chamada à API de membros.
11. **Produção**:
    - `.env` e compose da EC2 com as variáveis de SMTP;
    - script versionado que aplica os ajustes no realm que já existe (D11);
    - SMTP do Gmail do projeto (adendo de 2026-10-27 do ADR-0006). As credenciais são
      passo humano do Enzo, no `.env` da EC2.
12. **Documentos**: complemento do adendo do ADR-0006 (link com IP e status), contrato
    da CREED-23, arquitetura, infraestrutura, ledger e pauta.

**Não entra:**

- **Status do convite** (pendente ou aceito) e a **tabela de membros**: CREED-503. Com a
  D7 não precisa de coluna nova, porque acesso criado é convite enviado.
- **Listagem de membros**: CREED-503.
- **A página do painel da empresa** que usa o `AddMemberForm`, com o slice e o thunk do
  convite: CREED-50. Esta entrega deixa a chamada pronta, e a página a liga.
- **Tela de mentorandos e aprovação de empresas**: CREED-594, 591 e 595. Elas chamam o
  endpoint desta entrega, e as regras que as afetam estão nas P-048 e P-053.
- **Excluir membro por inteiro** (o que acontece com participante e vínculo quando o
  acesso sai): CREED-503.
- **Texto de convite próprio** (tema de e-mail do Keycloak): ver P-050.
- **Trocar papel e desativar acesso** (`PATCH`): buracos conhecidos do contrato da
  CREED-23.
- **Achar o usuário pelo `sub` em vez do e-mail** na guarda e no login ([C28]): tarefa
  própria. Aqui o risco é fechado pelo perfil do realm (D12).
- **503 na guarda das rotas**: hoje o `JwksUnavailableError` vira 401 em toda rota
  protegida. Também fica de fora o `apiClient` tratar o 503 da renovação sem limpar a
  sessão.
- **Limite de envios** de "esqueci minha senha".
- **Domínio próprio e o SES.** Sem domínio, o SES não tem remetente que passe no DMARC,
  e o provedor de produção é o Gmail do projeto (adendo do ADR-0006). Quando houver
  domínio, a troca é só de valores: as `SMTP_*` no `.env` e o script de ajuste do realm. O
  back não muda, porque quem fala SMTP é o Keycloak. Até lá, o link do convite sai com o
  IP do servidor (ver Riscos).
- **SMTP para os convites do editor do N8N**.
- **Consolidação das migrations** (CREED-57): é pré-requisito, não parte (ver "Dados").

> 🟡 **Premissa P-050** — o e-mail usa o texto padrão do Keycloak em português, sem tema
> próprio; as páginas do realm abrem em português, com inglês e espanhol disponíveis.
> Confirmar na próxima reunião.
>
> 🟡 **Premissa P-053** — na aprovação de uma empresa (CREED-591), o convite vai para o
> e-mail informado no cadastro, em nome de quem cadastrou, como `gestor`. Confirmar na
> próxima reunião.

## Repos afetados

| Repo | O que muda |
|---|---|
| `creed-backend` | `app/external_services/keycloak/admin.py` (novo) · `app/domains/users/` (`service.py`, `schemas.py`, `router.py`, `router_members.py` novo, `dependencies.py`) · `app/domains/authentication/` (`service.py`, `schemas.py`, `router.py`) · um método de composição em `app/domains/participants/service.py` e outro em `app/domains/links/service.py` · `app/shared/exceptions.py` · `app/shared/enums.py` (recebe `Roles` e `LinkType`) · `app/core/config.py` · `app/main.py` · `docker/keycloak/realm-creed.json` · `docker-compose.yml` · `.env.example` · `scripts/convidar_primeiro_admin.py` (novo) · `scripts/seed_local.py` · `Dockerfile` · `README.md` · `tests/` |
| `creed-frontend` | `src/app/routes.tsx` · `src/features/authentication/` (sai a `AlterarSenhaView`, entra a `RecuperarSenhaView`; `authenticationApi.ts`, `authenticationSlice.ts`) · `src/features/organizations/` (`AddMemberForm.tsx`, `addMemberSchema.ts`, `organizationsApi.ts` novo) · `src/lib/validadores.ts` · `src/types/api.ts` · `src/i18n/locales/` (pt-BR, en, es) |
| `creed-infrastructure` | `ec2/.env.example` · `ec2/docker-compose.yml` · `ec2/realm/aplicar-ajustes.sh` (novo) · `ec2/README.md` |
| `creed-ai-context` | ADR-0006 (complemento do adendo: link com IP e status) · `tarefas/86e348g6u-…/contrato-api.md` · `context/arquitetura.md` · `context/infraestrutura.md` · `decisoes/premissas.md` · `pauta/proxima-reuniao.md` · `glossario.md` |

**Nome do domínio e da feature.** No back, o convite é do domínio **`users`**, dono do
acesso, e a rota de membros fica num segundo router, como `questions/router_options.py`.
No front, quem consome é a feature **`organizations`** (painel da empresa). Os nomes não
batem de propósito: a rota `/organizations/{organization_id}/members` é o elo, e o domínio
`organizacoes` do back não é renomeado (ADR-0005, item 4).

## Contrato

Prefixo `/api/v1`. O corpo de erro tem o formato de sempre (`{"detail": "..."}`).

### Novo

| Método | Rota | Quem | Entrada | Saída | Erros |
|---|---|---|---|---|---|
| POST | `/organizations/{organization_id}/members` | `admin`; `gestor` só na própria organização (P-045) | `MemberInvite` | `UserResponse` · 201 | 401 · 403 (papel, organização alheia, `gestor` convidando `admin`) · 404 (organização não existe) · 409 (e-mail já tem acesso, aqui ou no Keycloak) · 422 · 503 |
| POST | `/users/{user_id}/invitation` | `admin`; `gestor` só para quem é da organização dele | — | 204 | 401 · 403 (papel) · 404 (não existe **ou** é de outra organização) · 503 |
| POST | `/authentication/password-reset` | público | `PasswordResetRequest` | 204 | 422 · 503 |

### Alterado

| Método | Rota | O que muda |
|---|---|---|
| POST | `/users` | `UserCreate` perde `keycloak_id`: o back cria o usuário no Keycloak e grava o id que ele devolve. Passa a mandar o convite. Ganha 503 e o 409 de e-mail que já existe no Keycloak |
| DELETE | `/users/{user_id}` | apaga também no Keycloak e ganha 503. A guarda de `admin` veio de um PR separado, o [creed-backend#47](https://github.com/creed-educa-ai/creed-backend/pull/47), mergeado na `dev` em 27/10 (revisão, B7) |
| POST | `/authentication/login` · `/authentication/renew` | Keycloak fora do ar responde **503**, não 401. O front já mostra "serviço indisponível" para todo erro que não seja 401 (`authenticationSlice.ts`) |

### Schemas

```
MemberInvite          { name, email, role, type = "emprego" }
                        role: admin | gestor | respondente                (P-006)
                        type: emprego | mentoria | academico | pessoal    (P-047)
UserCreate            { name, email, link_id }                             ← sai keycloak_id
PasswordResetRequest  { email }
UserResponse          sem mudança: { id, name, email, status, role, link_id, organization_id, created_at }
```

`name` segue a regra que `UserBase` e `ParticipantBase` já aplicam: 2 a 200 caracteres, sem
caractere de controle (`app/shared/validators.py`).

> 🟡 **Premissa P-046** — o convite pede o nome da pessoa; ele vai para o participante e
> para o usuário, e o Keycloak não recebe nome. Confirmar na próxima reunião.
>
> 🟡 **Premissa P-047** — o vínculo do convite é `emprego` quando quem convida não diz
> outro tipo. Confirmar na próxima reunião.

**Por que 403 numa rota e 404 na outra.** `organization_id` de outra organização dá 403,
como no resto da plataforma (P-033). `user_id` de outra organização dá 404, como decidiu o
contrato da CREED-23 (decisão 4): dizer "existe, mas não é seu" vaza cadastro alheio.

**O e-mail.** Convite e redefinição usam a mesma ação do Keycloak (`execute-actions-email`
com `UPDATE_PASSWORD`). O link vale 72 h (P-049). Quando `FRONTEND_URL` estiver preenchida,
há link de volta para o `/login` (P-051).

> 🟡 **Premissa P-049** — o link vale 72 horas. Confirmar na próxima reunião.
>
> 🟡 **Premissa P-051** — depois de definir a senha, a página do Keycloak mostra "conta
> atualizada" com um link para o login da plataforma; não há login automático. Confirmar
> na próxima reunião.

### Contrato interno (entre camadas e domínios)

| Onde | O quê | Nota |
|---|---|---|
| `app/external_services/keycloak/admin.py` (novo) | `create_user(email) -> uuid.UUID` · `assign_realm_role(keycloak_id, role)` · `send_update_password_email(keycloak_id)` · `delete_user(keycloak_id)` · `KeycloakConflictError` | token do service account por `client_credentials`, pedido a cada operação. Indisponível é o `KeycloakUnavailableError` que já existe em `client.py`. Qualquer resposta fora da esperada vira esse erro, com o corpo no log |
| `app/shared/exceptions.py` | `ServiceUnavailableError(DomainError)` | traduzido para 503 no router |
| `UserService` | `create_user_service` (passa a provisionar e convidar) · `resend_invitation_service(user_id, *, role, own_organization_id)` · `send_password_reset_service(email)` · `delete_user_service` (passa a apagar no Keycloak) | — |
| `MemberService` (novo, em `users/service.py`) | `invite_member_service(organization_id, request, *, role, own_organization_id) -> CreatedUser` | compõe `OrganizationService.get`, `ParticipantService`, `LinkService` e `UserService` |
| `ParticipantService` | `create_member_participant(name) -> Participant` | o `users` não pode montar `ParticipantCreate`: `tests/test_arquitetura.py` só deixa um domínio importar `service` e `dependencies` de outro |
| `LinkService` | `create_member_link(organization_id, participant_id, role, link_type) -> Link` | idem, para `LinkCreate` |
| `AuthenticationService` | `request_password_reset(email)` | delega a `UserService.send_password_reset_service` |
| `app/core/config.py` | `KEYCLOAK_INVITE_LIFESPAN_SECONDS: int = 259200` · `FRONTEND_URL: str = ""` | 72 h (P-049); `FRONTEND_URL` vazia desliga o link de volta |

## Dados

**Nenhuma tabela e nenhuma coluna nova: esta entrega não tem migration.** A D7 é o que
permite isso. Com tudo ou nada, acesso criado é convite enviado, e não há estado de convite
para guardar. O status pendente ou aceito que a CREED-503 vai mostrar é dela.

O que muda no dado:

| Onde | Antes | Depois |
|---|---|---|
| `user.keycloak_id` | vem no corpo do `POST /users` | vem do cabeçalho `Location` da Admin API, gravado pelo back |
| Cada convite de membro | — | uma linha em `participants`, uma em `links` e uma em `user`, na mesma transação |
| Keycloak (schema `keycloak`) | usuário criado à mão, com senha | usuário criado pelo back, **sem senha** até a pessoa usar o link, com a realm role do vínculo |
| Produção | nenhuma organização | a organização da CREED e o documento dela, criados uma vez pelo script do primeiro admin (P-048) |
| Seed local | senha `dev` | senha de 8 caracteres ou mais, porque a política nova recusa `dev` na criação pela Admin API |

> 🟡 **Premissa P-048** — mentorando é vínculo `mentoria`, papel `respondente`, com a
> organização da própria CREED. O script do primeiro admin cria essa organização uma vez
> por ambiente, com documento `other` e valor sintético até a cliente informar outro. O
> admin da plataforma tem o vínculo dele nessa mesma organização. Confirmar na próxima
> reunião.
>
> 🟡 **Premissa P-052** — o primeiro acesso de produção é de `admin`, criado pelo script
> com o e-mail informado por quem roda; a primeira convidada é a professora. Nenhum
> usuário de produção nasce com senha conhecida. Confirmar na próxima reunião.

**Pré-requisito: a consolidação das migrations (CREED-57).** Hoje `organizations`,
`question_options`, `insights`, `insight_prismas` e `dashboards` existem só em `models.py`
(ADR-0009). Num banco limpo, o seed local e o fluxo de membros quebram porque falta a
tabela `organizations`. O código desta entrega anda sem a consolidação, porque os testes
não falam com o banco, mas o "Como verificar" e o release dependem dela.

**`Roles` e `LinkType` mudam de arquivo, não de banco.** Saem de
`app/domains/links/models.py` para `app/shared/enums.py`, como o `Prisma` mudou em
`c194e0a`, porque `users/schemas.py` precisa dos dois e não pode importar `models.py` de
outro domínio. O nome do tipo no Postgres vem do nome da classe, que não muda. Conferir
com `alembic check` que não aparece diferença. `links/models.py` passa a importar os dois
de `shared`, e os imports que já existem continuam valendo.

## Abordagem técnica

### D7 — Tudo ou nada (decidido pelo Luís em 2026-10-24)

A ordem no `UserService.create_user_service`:

```
1. banco: e-mail livre, vínculo existe, vínculo sem login             → 409 / 404
2. Keycloak: cria o usuário sem senha (username = e-mail), pega o id  → 409 / 503
3. Keycloak: dá a realm role do vínculo
4. banco: INSERT do user com o keycloak_id (flush, dentro da transação)
5. Keycloak: execute-actions-email ["UPDATE_PASSWORD"]                → 503 se o SMTP falhar
   falhou 3, 4 ou 5 → apaga o usuário no Keycloak e propaga o erro → o get_db faz rollback
```

No convite de membro, participante e vínculo são gravados antes do passo 1, na mesma
transação, e voltam junto.

**Descartado — B, "cria e avisa"** (`invitation_sent: false` na resposta). SMTP fora do ar
não travaria o cadastro, mas o envio que falhou só aparece se houver status de convite
visível, e ele não existe (é da CREED-503). Volta à mesa quando a 503 trouxer esse status.

**Descartado — reaproveitar o usuário órfão do realm** quando o Keycloak responde 409 e o
banco não tem o e-mail. Curaria sozinho o caso raro do commit que falha depois do envio
(ver Riscos). Mas é um caminho a mais, difícil de testar, que poderia ligar uma conta
antiga com papéis antigos. Hoje, 409 é 409.

### D8 — "Adicionar membro" é um endpoint composto (decidido pelo Luís em 2026-10-24)

`MemberService.invite_member_service`, em `users/service.py`, faz numa transação:

```
OrganizationService.get(organization_id, role, own_organization_id)   → 403 / 404   (P-033)
gestor convidando admin?                                              → 403          (P-045)
ParticipantService.create_member_participant(name)
LinkService.create_member_link(organization_id, participant_id, role, type)
UserService.create_user_service(UserCreate(name, email, link_id))     → D7
```

Onde cada peça fica:

- **Router**: `app/domains/users/router_members.py`, sem prefixo, como
  `questions/router_options.py`, registrado em `app/main.py`. A tag é `users`, que já está
  em `OPENAPI_TAGS`; a descrição dela passa a citar o convite.
- **Service**: `MemberService` é uma segunda classe em `users/service.py`, com
  `MemberServiceDep` próprio em `users/dependencies.py`, como o `QuestionOptionService`.
  Assim a guarda de toda rota protegida, que monta o `UserService`, não passa a montar
  participante e organização a cada requisição.
- **Teste de arquitetura**: o motivo de `users` em `COMPOE_COM_SERVICE_DE`
  (`tests/test_arquitetura.py`) passa a citar participante e organização.

**Descartado — o front orquestra três chamadas** (`POST /participants` → `POST .../links`
→ `POST /users`). Falha no meio deixa participante e vínculo órfãos, a regra de quem
convida iria para o front, e as três rotas exigem `admin`.

**Descartado — domínio novo `members`, sem model** (como `authentication`). Seria um
terceiro nome para o mesmo conceito, e o convite ficaria dividido entre dois services.

### D9 — Cliente próprio da Admin API

`app/external_services/keycloak/admin.py`, com `httpx`, usando `build_http_client()` como
ponto de troca nos testes, igual a `client.py` e `token.py`. As chamadas já existem,
testadas, em `scripts/seed_local.py`:

- token por `client_credentials` (`_service_account_token`);
- id do usuário no cabeçalho `Location`, e papel numa chamada à parte (`_criar_no_realm`).

O service account já tem `manage-users` e `view-realm`, que bastam para criar, dar papel,
apagar e mandar o e-mail.

O usuário nasce com `username` e `email` iguais ao e-mail, `enabled: true`,
`requiredActions: []` e **sem** `credentials`. Sem nome, porque o Keycloak guarda
credencial, não cadastro (`test_perfil_nao_exige_nome_para_provisionar`).

O e-mail sai com o `lifespan` de `KEYCLOAK_INVITE_LIFESPAN_SECONDS`. Se `FRONTEND_URL`
estiver preenchida, sai também com `client_id=creed-backend` e
`redirect_uri=<FRONTEND_URL>/login`.

**Descartado — biblioteca `python-keycloak`**: dependência nova para quatro chamadas HTTP
que o projeto já faz com `httpx`.
**Descartado — cachear o token do service account**: estado a mais para testar, e o
volume de convites não justifica.

### D10 — "Esqueci minha senha" passa pelo back

`POST /authentication/password-reset` procura o usuário ativo pelo e-mail e manda o mesmo
e-mail do convite. Para e-mail sem acesso, responde 204 e não manda nada.

Isso mantém a D1, porque o front só fala com o nosso back. Mantém também
`resetPasswordAllowed: false` no realm: o teste
`test_realm_nao_liga_acao_obrigatoria_por_padrao` não muda.

**Descartado — link do front para a página de reset do Keycloak.** O front passaria a
conhecer o endereço do Keycloak, seria preciso ligar `resetPasswordAllowed`, e depois da
troca a pessoa cairia no console de conta do Keycloak.

### D11 — Ajuste de realm em produção por script versionado

O `--import-realm` só importa um realm que ainda não existe. Por isso o que esta entrega
muda no `realm-creed.json` não chega sozinho à produção.

O script `creed-infrastructure/ec2/realm/aplicar-ajustes.sh`:

1. lê os blocos do próprio `realm-creed.json`, no clone que a EC2 já tem;
2. troca os `${VAR}` pelos valores do `/opt/creed/.env`;
3. aplica com `kcadm.sh`, dentro do container do Keycloak.

Quem roda é uma pessoa, com o próprio admin no realm `master`. A senha do SMTP vai pela
entrada padrão, nunca pela linha de comando. O script precisa de `jq` e `envsubst` na EC2.

**Descartado — console pelo túnel SSH**: é o clique que a 23.2 proíbe, e não deixa rastro.
**Descartado — `kc.sh import --override`**: apaga e recria o realm, com os usuários.

### D12 — O e-mail só é editável pelo `admin` no perfil do realm

O link do convite leva a pessoa às páginas do Keycloak, e o console de conta
(`/auth/realms/creed/account`) passa pelo Caddy. Lá, hoje, ela pode trocar o próprio e-mail
sem verificação. Como o login e a guarda procuram o usuário pelo e-mail ([C28] não foi
implementado), ela perderia o acesso. No perfil declarativo do realm, o atributo `email`
passa a `"edit": ["admin"]`.

**Descartado — procurar o usuário pelo `sub` na guarda e no login.** É a correção certa de
[C28], mas mexe em toda rota protegida. Fica como tarefa própria (ver "Não entra").

### Corte em entregas

Cada entrega é um PR, com back e front sempre separados (CONTRIBUTING).

| # | Entrega | Repo | Depende de | Arquivo que se abre primeiro | Pronto quando |
|---|---|---|---|---|---|
| 1 | **E-mail no local**: Mailpit; `smtpServer`, idioma, política, redirect e perfil no realm; settings novas; senha do seed | back | — | `docker/keycloak/realm-creed.json` | o passo 2 do "Como verificar" põe um e-mail em português no Mailpit, e `tests/test_realm_keycloak.py` cobre cada bloco novo |
| 2 | **Cadastro nos dois lados**: `admin.py`, `ServiceUnavailableError`, `POST /users` (D7), `DELETE` limpando o Keycloak, 503 no login e na renovação | back | 1, para o teste real (o código anda com HTTP falso) | `app/external_services/keycloak/admin.py`, com `scripts/seed_local.py` aberto ao lado | criar cria nos dois lados e o convite chega; com o Mailpit parado, 503 e nada sobra |
| 3 | **Membros**: `MemberService`, `router_members.py`, `Roles`/`LinkType` em `shared/enums.py`, métodos de composição em `participants` e `links` | back | 2 | `app/domains/users/service.py` | todos os códigos da tabela "Novo" cobertos por teste de router e de service |
| 4 | **Reenviar e redefinir**: `POST /users/{user_id}/invitation`, `POST /authentication/password-reset` | back | 2 | `app/domains/authentication/service.py` | 204 para e-mail com e sem acesso, e um e-mail só no Mailpit |
| 5 | **Primeiro admin**: `scripts/convidar_primeiro_admin.py` e `COPY scripts` no `Dockerfile` | back | 2 | `scripts/seed_local.py` (molde de script) | rodado duas vezes no local, convida na primeira e reenvia na segunda |
| 6 | **Front**: rotas, `RecuperarSenhaView`, `organizationsApi.inviteMember`, nome no `AddMemberForm` | front | o contrato acima (não espera o back) | `src/app/routes.tsx` | `npm run check` verde; `/primeiro-acesso` não existe; `/recuperar-senha` só pede o e-mail |
| 7 | **Produção**: `.env` e compose da EC2, `aplicar-ajustes.sh`, README; credenciais do Gmail no `.env` (passo humano) | infra + EC2 | 1 (forma do realm) e o release que leva 2–5 à `main` | `ec2/docker-compose.yml` | o `kcadm get` mostra SMTP, idioma e política aplicados, e um convite real chega a um endereço de fora do time |
| 8 | **Documentos** | harness | entra em cada PR | `decisoes/adrs/0006-e-mail-transacional.md` | nenhum documento diz mais que "não existe envio de e-mail" |

A 1 e a 6 podem começar já. A 3, a 4 e a 5 só depois da 2, porque mexem no mesmo
`users/service.py`. A 7 depende de quem tem acesso à EC2 e às credenciais do Gmail do
projeto (Enzo, dono da CREED-28), da consolidação e do release (CREED-57, ADR-0009).

**Documentos da entrega 8**, cada item no PR que o torna verdade:

- ADR-0006: o adendo do provedor já existe (Gmail por SMTP, 2026-10-27) e já cita o
  script de ajuste do realm (D11). Faltam duas coisas:
  - dizer que, sem domínio, o link do convite sai com o IP do servidor;
  - o status, que ainda é "Proposto".
- `contrato-api.md` da CREED-23: `UserCreate`, rotas novas, 503.
- `context/arquitetura.md`: o provedor já está certo desde o #37, e o "fora da AWS" do
  diagrama passou a ser verdade, porque o Gmail fica fora da AWS. Falta o fluxo do convite
  com membros, reenvio e redefinição.
- `context/infraestrutura.md`: na tabela "Onde ficam os segredos", uma linha para a conta
  do Gmail do projeto e a senha de app. Elas ficam com o dono da conta e só no `.env` da
  EC2, como exceção à regra do Parameter Store, e a linha diz como passar a conta para a
  turma seguinte.
- Ledger:
  - a P-009 é refutada, porque o reset passa a existir;
  - a P-012, a P-013 e as P-003/P-004 de 07/09 são atualizadas.
- Pauta, item 3: reescrever com as P-045 a P-053 e com o remetente `@gmail.com`, que a
  cliente vai ver nos convites (limite aceito no adendo do ADR-0006).
- Glossário: convite, membro, mentorando.

## Critérios de aceite

- [ ] `docker compose up` sobe o Mailpit, e o realm importado já aponta o SMTP para ele,
      sem clique na UI.
- [ ] `POST /organizations/{organization_id}/members` como `admin`:
  - [ ] cria participante, vínculo e usuário no banco;
  - [ ] cria o usuário no Keycloak **sem senha** e com a realm role do papel;
  - [ ] o e-mail chega ao Mailpit em português, com link válido por 72 h.
- [ ] O link abre a página do realm, e senha com menos de 8 caracteres é recusada. Depois
      de definir a senha, o link "voltar" leva ao `/login` do front, e o login com a senha
      nova devolve 200.
- [ ] Antes de a pessoa definir a senha, o login com qualquer senha devolve 401, com a
      mesma mensagem de credencial errada.
- [ ] Com o Mailpit parado, o convite responde 503 e não sobra nada: nem usuário no
      Keycloak, nem participante, vínculo ou usuário no banco.
- [ ] `gestor` convidando:
  - [ ] na própria organização, como `gestor` ou `respondente` → 201;
  - [ ] em outra organização → 403;
  - [ ] como `admin` → 403.
- [ ] `respondente` convidando → 403. Sem token → 401.
- [ ] Organização inexistente → 404. E-mail que já tem acesso → 409, sem e-mail enviado.
- [ ] `POST /users` cria nos dois lados sem receber `keycloak_id`.
- [ ] Reenviar convite manda um e-mail novo com link válido. `user_id` de outra organização
      → 404 para o `gestor`.
- [ ] `POST /authentication/password-reset` devolve 204 para e-mail com e sem acesso, e só
      o primeiro recebe e-mail.
- [ ] Login e renovação com o Keycloak fora do ar devolvem 503, não 401.
- [ ] `DELETE /users/{user_id}` apaga também no Keycloak, e o mesmo e-mail pode ser
      convidado de novo.
- [ ] O front não tem mais `/primeiro-acesso` nem `AlterarSenhaView`. `/recuperar-senha`
      pede só o e-mail e mostra a mesma mensagem para qualquer e-mail.
- [ ] O `AddMemberForm` pede nome, e-mail e papel, e `organizationsApi.inviteMember` chama
      a rota nova.
- [ ] O script do primeiro admin, rodado duas vezes, convida na primeira e reenvia na
      segunda.
- [ ] Em produção:
  - [ ] o `aplicar-ajustes.sh` aplica SMTP, idioma, política, redirect e perfil sem
        reimportar o realm;
  - [ ] um convite real chega a um endereço de fora do time.
- [ ] Back: `ruff check . && ruff format --check . && mypy app && pytest` e
      `pre-commit run mypy --all-files` verdes. Front: `npm run check` verde.

## Como verificar

Local, com a consolidação (CREED-57) já na `dev`. O passo 1 **apaga o banco local**.

```bash
# 1. sobe do zero, com o realm novo importado
docker compose down -v
docker compose up -d db keycloak mailpit
alembic upgrade head
python scripts/seed_local.py
uvicorn app.main:app --reload            # em outro terminal

# 2. entrega 1, ainda sem código novo: o realm manda e-mail
#    (o id do usuário de dev está no console, http://localhost:8080/admin, admin/admin)
curl -s -X POST http://localhost:8080/realms/creed/protocol/openid-connect/token \
  -d grant_type=client_credentials -d client_id=creed-backend -d client_secret=creed-local-secret
curl -s -o /dev/null -w '%{http_code}\n' -X PUT \
  "http://localhost:8080/admin/realms/creed/users/<id>/execute-actions-email?lifespan=259200" \
  -H "Authorization: Bearer <access_token do comando anterior>" \
  -H 'Content-Type: application/json' -d '["UPDATE_PASSWORD"]'
# espera 204; em http://localhost:8025 há um e-mail em português com link para localhost:8080

# 3. login do admin de dev (copie o access_token)
curl -s -X POST http://localhost:8000/api/v1/authentication/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"dev@creed.example.com","password":"<senha nova do seed>"}'

# 4. convite de membro: espera 201 e um e-mail no Mailpit
curl -s -w '\n%{http_code}\n' -X POST \
  http://localhost:8000/api/v1/organizations/00000000-0000-0000-0000-000000000001/members \
  -H "Authorization: Bearer <access_token>" -H 'Content-Type: application/json' \
  -d '{"name":"Pessoa Teste","email":"pessoa@creed.local","role":"gestor"}'
```

5. No Mailpit, abra o link:
   - tente uma senha de 5 caracteres e confira que é recusada;
   - defina uma de 8 ou mais;
   - clique em "voltar": a página tem que cair em `http://localhost:5173/login`;
   - entre com a senha nova: espera 200.
6. Repita o passo 4 com o mesmo e-mail: espera 409, sem e-mail novo.
7. Rode `docker compose stop mailpit` e convide `outra@creed.local`: espera 503. Confira
   que não sobrou nada:
   - no console do Keycloak, o usuário não existe;
   - no banco, as contagens não mudam (rode antes e depois):

   ```bash
   docker compose exec db psql -U creed -c "select count(*) from participants" -c "select count(*) from links" -c "select email from \"user\""
   ```

   Depois, `docker compose start mailpit`.
8. Logado como o gestor do passo 5, convide com `"role":"admin"`: espera 403.
9. Reset: `POST /api/v1/authentication/password-reset` com `{"email":"pessoa@creed.local"}`
   e com `{"email":"ninguem@creed.local"}`. Espera 204 nos dois, e um e-mail só no Mailpit.
10. Reenvio: `POST /api/v1/users/<id do usuário>/invitation` como admin. Espera 204 e um
    e-mail novo.
11. Delete: `DELETE /api/v1/users/<id>` como admin. Espera 204, o usuário some do Keycloak,
    e o passo 4 com o mesmo e-mail volta a dar 201.
12. Rode `docker compose stop keycloak`: o login do passo 3 tem que devolver 503.
13. Script: rode duas vezes
    `python -m scripts.convidar_primeiro_admin --email admin2@creed.local --nome "Admin Dois"`.
    Espera um convite e um reenvio no Mailpit.
14. Front (`npm run dev`):
    - `http://localhost:5173/primeiro-acesso` não abre tela de senha;
    - `/recuperar-senha` pede o e-mail e responde com a mesma mensagem para os dois
      e-mails do passo 9.

Produção, por pessoa com acesso à EC2 (o SMTP é o do Gmail: adendo do ADR-0006):

15. As `SMTP_*` do Gmail do projeto no `/opt/creed/.env` (Enzo, que guarda as
    credenciais).
16. ~~TLS até o servidor SMTP de dentro da EC2~~ — feito em 2026-10-27: um envio pelo
    `smtp.gmail.com:587` saiu da EC2 e chegou.
17. Rode `./realm/aplicar-ajustes.sh` e depois
    `docker compose exec keycloak /opt/keycloak/bin/kcadm.sh get realms/creed --fields smtpServer,defaultLocale,passwordPolicy`.
18. *Test connection* na aba Email do realm `creed`, depois do script.
19. Depois do release, rode
    `docker compose run --rm back python -m scripts.convidar_primeiro_admin --email <e-mail da professora> --nome "<nome>"`:
    - o convite chega. Avise a professora antes para olhar também o spam: a conta do
      Gmail é nova, e o primeiro e-mail de teste caiu lá;
    - o link abre `https://<IP>/auth/...`;
    - o login em produção devolve 200, o que fecha o último critério da CREED-283.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-045 | `admin` convida em qualquer organização e com qualquer papel; `gestor`, só na própria e só como `gestor` ou `respondente`; `respondente` não convida. Ajusta a P-008 | baixo |
| P-046 | O convite pede o nome; ele vai para o participante e para o usuário, não para o Keycloak | baixo |
| P-047 | O vínculo do convite é `emprego` quando quem convida não diz outro tipo | baixo |
| P-048 | Mentorando é vínculo `mentoria`, papel `respondente`, com a organização da própria CREED, criada uma vez pelo script do primeiro admin | médio |
| P-049 | Os links de convite e de redefinição valem 72 h | baixo |
| P-050 | O e-mail usa o texto padrão do Keycloak em português; as páginas do realm abrem em português, com inglês e espanhol disponíveis | baixo |
| P-051 | Depois de definir a senha, a pessoa volta ao login da plataforma por um link; não há login automático | baixo |
| P-052 | O primeiro admin de produção nasce por convite, pelo script, e a primeira convidada é a professora; ninguém nasce com senha conhecida | baixo |
| P-053 | Na aprovação de uma empresa (CREED-591), o convite vai para o e-mail informado no cadastro, em nome de quem cadastrou, como `gestor` | médio |

As nove estão abertas em [`decisoes/premissas.md`](../../decisoes/premissas.md). No código,
cada uma ganha o marcador `🟡 Premissa P-0NN` onde é aplicada. A revisão sugeria começar
na P-041, mas as P-041 a P-044 foram usadas no mesmo dia pelo ADR-0010.

Também usadas:

- **P-006**: os três papéis.
- **P-012**: primeiro acesso pela página do Keycloak, que esta entrega torna real.
- **P-013**: o acesso nasce ativo. O motivo muda, a regra não.
- **P-033**: recorte por organização.
- **P-004 de 07/09**: os 8 caracteres, que vão do front para o realm.

A **P-009** ("esqueci minha senha não existe") deixa de valer quando a entrega 4 entrar.

## Riscos

- **Link com IP.** O remetente passa no SPF, DKIM e DMARC desde que o e-mail sai pelo
  servidor do Google (adendo do ADR-0006). O que sobra é o link, que aponta para
  `https://<IP>/auth/...`. Link para IP tem cara de phishing, para os filtros e para as
  pessoas. **Sinal:** o convite chega marcado como suspeito, ou a pessoa tem medo de
  clicar. **Mitigação:** um domínio próprio (decisão de infra); antes de convidar a
  cliente, testar com contas Gmail e Outlook.
- **Senha de app revogada.** O Google revoga as senhas de app quando a senha da conta muda,
  e a senha de app só funciona com a verificação em duas etapas ligada. Pela D7, todo
  convite e todo reset passam a dar 503. **Sinal:**
  `535-5.7.8 Username and Password not accepted` no log do Keycloak. **Mitigação:** só o
  dono da conta (Enzo) mexe nela. Para trocar, gera uma senha de app nova, atualiza o
  `.env` e roda o `aplicar-ajustes.sh` de novo. O README da EC2 diz isso (entrega 7).
- **Conta com uma pessoa só.** As credenciais do Gmail ficam com o Enzo, fora do Parameter
  Store (adendo do ADR-0006). Se ele sair sem passar a conta, a primeira revogação para o
  envio de vez. **Sinal:** ninguém do time sabe entrar na conta do Gmail do projeto.
  **Mitigação:** a passagem da conta entra em `context/infraestrutura.md` (entrega 8) e
  na troca de turma.
- **Conta do Gmail sem reputação.** O primeiro e-mail de teste (2026-10-27) caiu no spam.
  **Sinal:** convite que a pessoa diz não ter recebido. **Mitigação:** avisar quem recebe
  o primeiro convite para olhar o spam. Limite de cerca de 500 destinatários por dia,
  folgado para este uso.
- **SMTP fora do ar trava o cadastro.** É o preço da D7. **Sinal:** 503 em todo convite.
  **Mitigação:** a mensagem pede para tentar de novo, e o reenvio cobre o link vencido.
- **Commit que falha depois do e-mail enviado.** O commit roda depois que a rota termina
  (CREED-364). Se ele falhar, o usuário fica no Keycloak sem linha no banco, com um link
  que funciona e um login que dá 401. É raro, porque o flush já validou as constraints.
  **Sinal:** 409 do Keycloak para e-mail que não está no banco. **Correção:** apagar o
  usuário no console.
- **Realm de produção diferente do arquivo.** **Sinal:** SMTP e idioma certos no local e
  errados em produção. **Mitigação:** a D11, e o README da EC2 manda rodar o script
  depois de cada mudança no realm.
- **`redirect_uri` recusado.** O client `creed-backend` não tem fluxo de navegador. Se o
  Keycloak recusar o redirect, todo convite falha (D7). **Sinal:** `Invalid redirect uri`
  no log. **Mitigação:** validar na entrega 1. Se falhar, `FRONTEND_URL` vazia desliga o
  link de volta, e a P-051 cai para "sem link".
- **Política de senha quebra o seed.** A senha `dev` tem 3 caracteres. **Mitigação:** a
  troca entra na entrega 1.
- **Enumeração no reset durante falha.** O 503 só aparece para e-mail com acesso, e só
  enquanto o SMTP está fora. Aceito.
- **Sem limite de envio.** Alguém pode disparar vários resets para o mesmo e-mail.
  **Sinal:** volume anormal na caixa de enviados do Gmail do projeto. Aceito nesta
  entrega.
- **Consolidação e release.** Sem a CREED-57, o fluxo não sobe num banco limpo; sem
  release, nada chega à produção.
- **Comportamentos do Keycloak 26 ainda não testados aqui.** São três:
  - o link usa o `KC_HOSTNAME`;
  - o link marca o e-mail como verificado;
  - o `kcadm` funciona pela rede interna com o `KC_HOSTNAME_ADMIN` configurado.

  **Sinal:** o passo 2 (local) e os passos 17 e 18 (produção) do "Como verificar".
