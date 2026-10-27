# CREED-23.8 — revisão de escopo e aderência

> Revisão de 2026-10-24, feita na retomada da [CREED-23.8](https://app.clickup.com/t/86e35vhxm)
> (convite de primeiro acesso por e-mail, com link para o realm do Keycloak), depois da
> publicação na AWS. Entrada para a spec da 23.8, que ainda não existe.
> **Nada de código foi alterado.** As fontes são a `dev`/`main` dos quatro repositórios
> (atualizadas nesta data), o ClickUp e o harness.
>
> Endereços de produção aparecem como `<IP>`, igual ao `creed-infrastructure/ec2/README.md`.
>
> **Atualização de 2026-10-27.** O provedor de e-mail de produção é o **Gmail do projeto
> por SMTP**, não o SES (adendo do
> [ADR-0006](../../decisoes/adrs/0006-e-mail-transacional.md)). Esta revisão fica como
> registro de 24/10. Onde ela fala de SES, sandbox, região ou Parameter Store para o SMTP,
> vale o adendo. A spec da 23.8 já foi refinada com isso.

## Resumo

1. **A 23.8 não é "ligar o e-mail".** O `POST /users` da `dev` **não fala com o Keycloak**:
   recebe o `keycloak_id` de um usuário que alguém já criou no realm. O provisionamento
   com compensação (decisão D4) que a 23.3 prometeu nunca entrou, embora a 23.3 esteja
   "finalizado - sprint" no board. Só o `scripts/seed_local.py` usa a Admin API, e só no
   ambiente local. A 23.8 herda esse débito.
2. **As entidades que faltavam em setembro existem**: `participants` (CREED-36),
   `links` (CREED-32), `organizations` (CREED-38). O fluxo agora pode ser descrito de
   ponta a ponta. Porém `organizations` e mais quatro tabelas **só existem em
   `models.py`**: a migration consolidada do ADR-0009 (CREED-57) não foi feita.
3. **Três frentes novas vão disparar o convite**, e nenhuma está na spec:
   - o `AddMemberForm` da CREED-501, já mergeado: e-mail + papel, adicionado pela empresa;
   - "adicionar mentorando" da CREED-594: só e-mail, **sem empresa**;
   - "aprovar empresa" da CREED-591/595.

   As três batem em regras atuais. Só o `admin` cria acesso (P-008). O nome é obrigatório.
   E o vínculo exige organização, porque 1 login = 1 vínculo ([C2]).
4. **O front contradiz a P-012.** As rotas `/primeiro-acesso` e `/recuperar-senha` levam a
   uma tela de nova senha que não chama API nenhuma (`AlterarSenhaView`, PR #11 do front,
   mergeado em 08/09). O "Esqueci minha senha" do login aponta para ela.
5. **Infra de e-mail: decidida, mas não implementada.** O ADR-0006 escolheu Mailpit no
   local e placeholders no realm. O realm não tem `smtpServer` e o compose não tem
   `mailpit`. No bloco proposto pelo ADR faltam `starttls`/`ssl`, que o SES exige.
6. **Produção**: o Keycloak está na EC2 com `KC_HOSTNAME=https://<IP>/auth`, e o link
   do convite já sai alcançável. Mas é um **IP**, e não existe domínio, o que pesa na
   entrega do e-mail. O realm de produção **não relê o arquivo** (`--import-realm` só
   importa uma vez), então todo ajuste de realm da 23.8 precisa de um caminho próprio para
   chegar lá. O SMTP da AWS não está registrado em nenhum documento nem no Parameter Store
   listado.
7. **Achado de segurança fora do escopo**: `DELETE /api/v1/users/{user_id}` não tem guarda
   (`require_role`), e qualquer chamada sem token apaga usuário. Ele também não apaga no
   Keycloak, e isso impede reconvidar o mesmo e-mail.
8. **Release**: a `main` do back está 203 commits atrás da `dev`, a do front 179 e a do
   infra 8. A CREED-285 decidiu que a produção publica a partir da `main`. Nada da 23.8
   chega lá sem consolidação e release.

---

## 1. Repositórios atualizados

`git -c http.sslBackend=schannel fetch --all --prune` nos cinco repositórios. Depois, cada
checkout foi para a branch de integração com fast-forward. Nenhuma alteração rastreada
foi perdida. Os arquivos não rastreados ficaram onde estavam (`ONBOARDING.md` e
`creed-ai-context/sprints/`).

| Repo | Estava em | Agora | Nota |
|---|---|---|---|
| `creed-ai-context` | `docs/86e3m2x2h-adr-0009-migration-consolidada` | `main` @ `8d978a3` (20/10) | a branch entrou por squash (#32); 2 stashes preservados |
| `creed-backend` | `ci/86e3m2x2h-migration-so-na-consolidacao` (mergeada, #32) | `dev` @ `1d90b2a` (20/10, #41) | — |
| `creed-frontend` | `refactor/86e3anvg2-link-id-na-sessao` (mergeada, #37) | `dev` @ `afd9882` (22/10, #45) | avançou 2 commits |
| `creed-infrastructure` | `docs/0007-amplify-e-ec2-no-lugar-do-eks` (PR #1 aberto) | `dev` @ `353e11c` (20/10, #4) | a branch do #1 continua local |
| `creed-docs` | `main` | `main` | sem novidade |

## 2. O que existe de especificação da 23.8

| Fonte | Estado |
|---|---|
| Descrição da 23.8 no ClickUp (08/09) + comentário de 10/09 (ADR-0006) | única descrição de escopo; sem linha `Rastreio:`, sem spec, sem tasks |
| `spec.md` do épico | 23.8 **fora do escopo**; "Não entra: recuperação de senha por e-mail — não existe serviço de e-mail" |
| `tasks.md` do épico | "Convite de primeiro acesso — adiada de propósito" |
| `contrato-api.md` | P-012; `UserCreate.initial_password` "some quando o envio de e-mail entrar" |
| ADR-0006 | **Proposto**; Mailpit local, provedor real condicionado, placeholders, Keycloak envia |
| `context/arquitetura.md` | fluxo do convite desenhado; provedor "fora da AWS" |
| `creed-docs/docs/arquitetura/index.md` | 🟡 "Convite e e-mail ainda são desenho, não código" — **o único texto exato hoje** |

## 3. Aderência: o que está escrito × o que é verdade hoje

| # | Está escrito | Hoje | Consequência para a 23.8 |
|---|---|---|---|
| 1 | "Hoje o `POST /users` recebe `initial_password`; o provisionamento cria credencial com `temporary: false`" (ClickUp 23.8) | recebe `{name, email, keycloak_id, link_id}`; **o back não chama a Admin API**. `initial_password` nunca existiu em código | a 23.8 **cria** o provisionamento (D4 + compensação) e tira o `keycloak_id` do payload |
| 2 | "`UserCreate` fica `{vinculo_id, email}`" | é `link_id` (ADR-0005, CREED-32); `user.name` continua obrigatório | o `CONTEXT.md` diz "`name` fica até `Participant` existir". O `Participant` existe desde 30/09 (#28): falta decidir de onde vem o nome (§11) |
| 3 | "SMTP versionado junto com o realm" | o ADR-0006 resolveu **como** (`${VAR}`, sem `env.`); o realm não tem `smtpServer` | implementar, com `starttls` e `ssl` (faltam no bloco do ADR) |
| 4 | "Decidir de onde sai o e-mail no local" | **fechado**: Mailpit (ADR-0006, item 1) | o serviço ainda não está no `docker-compose.yml` |
| 5 | Provedor real "condicionado à agência"; diagrama: "provedor de e-mail (fora da AWS)" | SMTP na conta AWS (informação sua, sem registro); produção **sem domínio** (CREED-282: certificado para o IP) | adendo ao ADR-0006; diagrama da `arquitetura.md` |
| 6 | "Keycloak no EKS fica fora" (épico, entrega 8) | **superado**: ADR-0007 + CREED-281/282. Keycloak na EC2, `/auth/*` público pelo Caddy, `/auth/admin*` dá 404, o back usa a rede interna | o link do convite abre por `https://<IP>/auth/...` |
| 7 | "O link herda o hostname do Keycloak" (ADR-0006) | **resolvido** em produção por `KC_HOSTNAME`; no local continua `localhost:8080` | o link é um endereço IP (§13) |
| 8 | "Fecha P-009 pelo mesmo mecanismo" | realm com `resetPasswordAllowed: false`, travado por teste; o "Esqueci minha senha" do front leva à tela-mock | decidir o desenho do reset (§9, B4) |
| 9 | "A plataforma não tem tela de troca de senha, nem hoje nem depois" (P-012) | `AlterarSenhaView` em `/primeiro-acesso` e `/recuperar-senha`; o PR #11 do front entrou em 08/09, o mesmo dia em que a P-012 tirou a função dela | remover ou refazer essas rotas; P-003/P-004 de 07/09 fecham junto |
| 10 | Senha de no mínimo 8 caracteres (P-004 de 07/09), validada no front | quem define a senha passa a ser a página do realm, que **não tem `passwordPolicy`** | a regra vai para o realm |
| 11 | P-013: "nasce ativo, porque o admin passa a senha por fora" | o motivo some com o convite | reescrever o porquê; o "status" da tabela de membros (CREED-503) é outro eixo |
| 12 | "Seed do primeiro admin" (entrega 3) | só existe no local (`ENVIRONMENT=local`, senha `dev`); o de produção é pendência (CREED-285, parte E) | o convite é a saída natural: bootstrap que convida em vez de definir senha |
| 13 | D2/[C28]: achar o usuário pelo `sub`, porque "e-mail é dado que muda" | login e guarda procuram pelo **e-mail** do token; o `keycloak_id` é gravado e nunca lido | com o convite as pessoas passam a usar páginas do realm, inclusive o console de conta, onde dá para trocar o e-mail (§13) |
| 14 | Contrato: 503 quando o Keycloak cai | responde 401 | a 23.8 acrescenta falha de Admin API e de SMTP, que não podem virar 401 |
| 15 | Contrato, "buracos conhecidos": sem rota de troca de papel, sem listar vínculos | continuam | a CREED-503 (tabela de membros) passa a precisar de listagem |
| 16 | Épico no ClickUp e item 3 da pauta: "não existe envio de e-mail"; a pauta ainda descreve a P-007 (refutada) | desatualizados | reescrever ou tirar da pauta |
| 17 | Board: 23.3 "finalizado", 23.6 "to do", 23.7 sem dono | 23.3 sem provisionamento; 23.6 mergeada (front #22, 14/09) | status do board engana quem pegar a 23.8 |

## 4. Questões que fecharam ao longo das sprints

| Questão | Como fechou | Onde |
|---|---|---|
| De onde sai o e-mail no local | Mailpit | ADR-0006, item 1 |
| Segredo do SMTP × realm versionado | placeholders `${VAR}` sem `env.` (testado no Keycloak 26.0) | ADR-0006, item 3 + comentário na 23.8 |
| Quem envia o e-mail | o Keycloak (`execute-actions-email`); nem o back, nem o N8N | ADR-0006, item 4 |
| Onde roda o Keycloak | EC2, compose de produção próprio | ADR-0007 (nota de 09/10), CREED-281 |
| Hostname público do realm | `KC_HOSTNAME=https://<IP>/auth` | `creed-infrastructure/ec2/` (#2) |
| Emissor do token em produção | `KEYCLOAK_PUBLIC_URL` | CREED-283, back #37 |
| Realm sem segredo nem usuário de teste | placeholders + seed local | CREED-281, back #35 |
| Onde ficam os segredos | Parameter Store `/creed/prod/<VAR>`, `us-east-2` | CREED-282, `context/infraestrutura.md` |
| Vínculo e papel | `Link`/`link_id`; papel só no vínculo; `user.role` removido | CREED-32 (#29, #30), ADR-0005 |
| Cadeia de entidades | `participants` (#28), `organizations` (#44), FKs (#31) | `dev` |
| Permissão do service account | `manage-users` + `view-realm` — basta para `execute-actions-email` | realm + `tests/test_realm_keycloak.py` |
| Perfil do Keycloak sem nome obrigatório | `firstName`/`lastName` opcionais (convite só com e-mail não trava no login) | realm + teste |
| Resposta só depois do commit | `SessionDep` com `scope="function"` | CREED-364 |
| Solicitação de cadastro de empresa ≠ autocadastro | escopo da P-008 esclarecido em 29/09 | ledger |
| Migration | PR de tarefa sem migration; AGES III consolida | ADR-0009 (Aceito) |

## 5. O que continua aberto

| Item | Estado | Efeito na 23.8 |
|---|---|---|
| P-006 (papéis) | 🟡 | o `AddMemberForm` já assume `gestor`/`respondente` |
| P-009, P-012, P-013 | 🟡 | a 23.8 fecha a P-009 e a P-012; a P-013 muda de motivo |
| P-003/P-004 de 07/09 (IDs duplicados; tarefa 86e35wea4 em "to do") | 🟡 | somem com a tela de senha; a regra da P-004 vai para o realm |
| ADR-0006 e ADR-0007 | "Proposto" | o ADR-0006 precisa do adendo (região, identidade, sandbox, porta) |
| Aplicar mudança de realm em produção | pendência no `ec2/README.md` | todo ajuste de realm da 23.8 depende disso |
| Primeiro admin de produção | pendente (CREED-285 E, CREED-283) | ver §9, B11 |
| Consolidação de migrations (CREED-57, backlog) | `organizations`, `question_options`, `insights`, `insight_prismas` e `dashboards` só em `models.py`; `links.organization_id` sem FK no banco | o fluxo usuário → vínculo → organização não sobe num banco limpo; release bloqueado (ADR-0009, item 6) |
| Domínio | não existe | remetente e link (§10, passo 2) |

## 6. Git: o que está pendente de merge

Consulta feita como `Kv1ecz` (`env -u GH_TOKEN gh ...`).

### PRs abertos

| Repo | PR | Branch | Autor | Estado | Encosta na 23.8? |
|---|---|---|---|---|---|
| back | #46 | `feat/40-demographics-table` | matheusbtguerra | review pendente | não |
| back | #45 | `feat/285-imagem-do-back` | EnzoVivian | changes requested | **indireto**: é o caminho até a produção (imagem arm64 + `deploy.sh` pelo Session Manager, só a partir da `main`) |
| back | #42 | `feat/55-workflow-n8n-async` | gabriellrmartins | review pendente | não; mexe no `docker-compose.yml` (volume do N8N), e a entrada do `mailpit` vai dar um conflito trivial |
| back | #36 | `feat/339-sector-table` | BryanAlmerindo | changes requested; CI falhou no último push (23/10) | marginal: cria o domínio e a tabela `sector`, mas o ADR-0005 e o código (`links.department_id`) dizem `Department` |
| front | #44 | `feat/502-gerenciar-questionario` | sanx111 | changes requested | não (é da mesma tela da CREED-50) |
| infra | #1 | `docs/0007-amplify-e-ec2-no-lugar-do-eks` | Kv1ecz | review pendente desde 12/09 | não; a nota de implementação do ADR-0007 superou o texto. Fechar ou atualizar |

`creed-ai-context` e `creed-docs`: nenhum PR aberto.

### Branches sem PR com commits fora da `dev`/`main`

- back `feat/55-workflow-n8n-beta` (13/10): N8N, não encosta.
- infra `docs/285-recriar-caddy` (20/10): README do Caddy, não encosta.
- front `chore/1-apresentacao` e `chore/67-apresentacao`: branches de apresentação.
- front `feat/503-componente-de-tabela-de-membros`: criada, **sem commit** além da `dev`.
  Encosta (§7).
- ai-context `docs/86e3anvv8-demographic`: P-023–P-027 colidindo com a `main` (já
  conhecido). As outras ~25 branches de docs entraram por squash e só *parecem* não
  mergeadas. São candidatas a limpeza.

### Release e produção

- `main` atrás da `dev`: back 203, front 179, infra 8 commits. Último merge na `main` em
  agosto.
- O workflow `imagem.yml` não está na `dev` e não tem execução; o pacote do GHCR não é
  visível para a conta. **Não dá para confirmar daqui o que está no ar.** Conferir o
  `BACK_TAG` em `/opt/creed/.env`.

## 7. Trabalho em curso que esbarra na feature

| Frente | Quem | Estado | O que supõe | Onde esbarra |
|---|---|---|---|---|
| [CREED-501](https://app.clickup.com/t/86e3kec5b) — `AddMemberForm` (e-mail + papel `respondente`/`gestor`) | Josias | mergeado em 22/10 (front #45), sem API | a **empresa** adiciona membro só com e-mail | (a) quem convida: `POST /users`, `/participants` e `/links` exigem `admin`; (b) sem nome: `participants.name` e `user.name` são `NOT NULL`; (c) sem tipo de vínculo: `links.type` é `NOT NULL`; (d) um clique vira três escritas (participante → vínculo → usuário) |
| [CREED-503](https://app.clickup.com/t/86e3kec5y) — tabela de membros (status, datas, paginação, excluir) | Maria Eduarda | in progress; branch sem commit | listar membros com status e excluir | não há listagem; "status do convite" não existe; o `DELETE /users` não tem guarda e não apaga no Keycloak |
| [CREED-59](https://app.clickup.com/t/86e3t12p6) — tela de super admin (épico de 17/10, subtarefas de 21 a 23/10) | Luiza, Josias | to do / backlog | — | abaixo |
| ↳ [CREED-594](https://app.clickup.com/t/1dfej6ftzfg) — adicionar mentorando por e-mail, "sem ficar linkado a uma empresa", "segue o fluxo normal de criação de conta" | sem dono | backlog | mentorando sem organização | `links.organization_id` e `user.link_id` são `NOT NULL` ([C2]). O "fluxo normal de criação de conta" **é** a 23.8 |
| ↳ [CREED-591](https://app.clickup.com/t/86e3uzwvk)/[595](https://app.clickup.com/t/1dfej6ftzq6) — empresas pendentes; o modal mostra nome, documento, e-mail da empresa, quem cadastra e telefone | Luiza | backlog | aprovar gera acesso | aprovar = organização + documento + participante + vínculo + usuário + convite. O `/cadastro` do front não tem back |
| [CREED-285](https://app.clickup.com/t/86e3u0t3k) / [CREED-283](https://app.clickup.com/t/86e3purap) | Enzo | in progress | o login real depende do "primeiro admin" | o convite resolve o bootstrap sem senha conhecida |
| [CREED-57](https://app.clickup.com/t/86e3m2x2h) — consolidar migrations | Luís | backlog | — | pré-requisito do banco (§5) |

## 8. O fluxo completo, agora que as entidades existem

```
Entradas (front)                          Back (uma transação)              Keycloak                         Pessoa
CREED-501  empresa: e-mail + papel ──┐
CREED-594  admin: e-mail (mentorando) ┼─▶ participante → vínculo → user ─▶ cria usuário SEM credencial
CREED-591  admin aprova empresa ─────┘    (compensação se falhar)         dá a realm role do vínculo
                                                                         execute-actions-email
                                                                         ["UPDATE_PASSWORD"] ─SMTP─▶ e-mail
                                                                                                        │ link
                                                                         página do realm: define senha ◀┘
                                                                                 │ "voltar à plataforma"
                                                                                 ▼
                                                                         /login do front (Amplify)

Reenviar convite (link vencido) ─▶ back ─▶ execute-actions-email de novo
Esqueci minha senha            ─▶ back (sempre 202) ─▶ execute-actions-email, mesma ação
```

| Passo | Existe? |
|---|---|
| Participante (`POST /participants`) | ✅ só `admin` |
| Vínculo (`POST /organizations/{organization_id}/links`) | ✅ só `admin` |
| Usuário no banco (`POST /users`) | ✅ só `admin`, com `keycloak_id` pronto |
| Usuário no Keycloak sem credencial + realm role | ⬜ só o seed faz, e com senha |
| `execute-actions-email` | ⬜ |
| SMTP no realm — local / produção | ⬜ / ⬜ |
| Página do realm em pt-BR, com política de senha | ⬜ |
| "Voltar à plataforma" depois de definir a senha | ⬜ o client não tem `redirectUris` |
| Reenviar convite · esqueci minha senha | ⬜ · ⬜ (o front tem a tela-mock) |

## 9. Implementação que falta — e que ninguém está fazendo

### Back (`creed-backend`)

| # | O quê | Onde | Nota |
|---|---|---|---|
| B1 | Cliente da Admin API: token do service account (`client_credentials`), criar usuário sem credencial, ler e dar realm role, apagar (compensação), `execute-actions-email` com `lifespan` (e `client_id`/`redirect_uri`, se houver retorno) | `app/external_services/keycloak/` (arquivo novo) | o `seed_local.py` já tem as chamadas certas e serve de molde (id no `Location`, papel em chamada à parte). Separar 409 do realm (e-mail já existe) de "indisponível" |
| B2 | `POST /users` provisiona: realm → INSERT/flush → convite, com compensação; sai o `keycloak_id` do payload | `domains/users/` | muda o contrato; ninguém no front consome ainda |
| B3 | Reenviar convite | rota nova (ex.: `POST /users/{user_id}/invitation`) | a validade padrão do link é 12 h |
| B4 | "Esqueci minha senha" pelo back: `POST /authentication/password-reset {email}`, sempre 202 | `domains/authentication/` | mantém a D1 (o front não conhece o Keycloak); `resetPasswordAllowed` continua `false` e o teste não muda |
| B5 | Falha de Keycloak ou SMTP → 503, não 401 | routers de `users` e `authentication` | corrige junto o 401 de hoje no login |
| B6 | Settings: validade do convite, URL de retorno do front | `app/core/config.py`, `.env.example`, `tests/test_config.py` | — |
| B7 | `DELETE /users/{user_id}` com guarda, apagando ou desativando no Keycloak | `domains/users/` | **hoje sem `require_role`**. A guarda pode sair já, separada da 23.8; a limpeza no Keycloak depende do B1 |
| B8 | Guarda e login pelo `sub` (`keycloak_id`), não pelo e-mail | `shared/authorization.py`, `users/`, `authentication/` | [C28] |
| B9 | Endpoint composto "adicionar membro" (se a Parada 2 escolher A) | ex.: `POST /organizations/{organization_id}/members` | regra de quem convida (§11) |
| B10 | Listagem de membros da organização | users ou links | da CREED-503, mas é ela quem mostra o status do convite |
| B11 | Primeiro admin de produção por convite | script em `scripts/`, rodado com `docker compose run --rm back ...` | substitui senha conhecida; fecha a parte E da CREED-285 |
| B12 | Testes: client com HTTP falso, ordem e compensação no service, 401/403/409/503 no router | `tests/` | o fluxo real só se prova com o Mailpit |

### Realm (`docker/keycloak/realm-creed.json` + `tests/test_realm_keycloak.py`)

- `smtpServer` com placeholders, incluindo `starttls` e `ssl`.
- `internationalizationEnabled: true`, `supportedLocales` e `defaultLocale: "pt-BR"`. Sem
  isso, o e-mail e a página de senha saem em inglês.
- `passwordPolicy: "length(8)"` (P-004).
- `redirectUris` do client `creed-backend` com a URL do front (placeholder), se houver
  "voltar à plataforma".
- E-mail editável só por `admin` no perfil, ou o console de conta desligado (ver B8 e §13).
- Opcional: tema de e-mail com texto de convite. O texto padrão do Keycloak é "o
  administrador pediu que você atualize sua conta".
- Um teste guardando cada item, como os que já existem.

### Compose local

- Serviço `mailpit` com versão fixa (UI na 8025, SMTP na 1025) e as variáveis `SMTP_*`
  no `keycloak`.
- O realm local só reimporta com `docker compose down -v`. Avisar no README.

### Front (`creed-frontend`)

- Tirar `/primeiro-acesso` e a `AlterarSenhaView` (P-012).
- `/recuperar-senha` vira formulário de e-mail ligado ao B4, com mensagem neutra ("se o
  e-mail tiver acesso, enviamos um link").
- Ligar o `AddMemberForm` à API, com retorno de "convite enviado" e os erros 409/503 no
  campo certo.
- Tipos em `src/types/api.ts`; i18n em pt, en e es.
- Com a CREED-503: status do convite e ação de reenviar.
- Com a CREED-23.7: esconder "adicionar membro" de quem não pode. Esconder não é
  autorizar.

### Infra (`creed-infrastructure/ec2`)

- `.env.example`: `SMTP_HOST`, `SMTP_PORT`, `SMTP_FROM`, `SMTP_USER`, `SMTP_PASSWORD`,
  `SMTP_AUTH`, `SMTP_STARTTLS`, `SMTP_SSL`, e as do back (validade do convite, URL do
  front).
- `docker-compose.yml`: passar `SMTP_*` ao `keycloak`. Elas só valem num import do zero,
  mas mantêm o arquivo honesto para recriar o ambiente. Passar as novas do back também.
- **Script versionado que aplica ajustes no realm que já existe** (SMTP, idioma, política
  de senha, redirect). Fecha a pendência "como aplicar mudança depois disso".
- README: como testar o envio.

### Harness, docs e board

- ADR-0006: adendo e status; `arquitetura.md` (o diagrama diz "fora da AWS");
  `infraestrutura.md` (parâmetros SMTP).
- Spec da 23.8 (esta revisão é a entrada); `contrato-api.md` (`UserCreate` sem
  `keycloak_id`, rotas novas, 503); `spec.md` e `tasks.md` do épico.
- Ledger: P-009, P-012, P-013, P-003/P-004 de 07/09, e as premissas novas (§11).
- Pauta, item 3: reescrever ou tirar. A decisão de time já foi tomada. Para a cliente
  sobram o texto do e-mail e a validade do link.
- Glossário: convite, membro, mentorando, super admin. `catalogo.md`: `organizacoes`
  deixou de ser scaffold, e faltam `links`, `participants`, `forms` e `questions`.
- ClickUp: descrição da 23.8 (a tabela "Hoje/Depois" está errada), épico ("esqueci minha
  senha fica de fora", "Keycloak na nuvem fora"), status da 23.3 e da 23.6.
- `creed-docs`: tirar o 🟡 do convite quando ele entrar.

## 10. AWS: o que fazer para o e-mail sair de verdade

> **Superada em 2026-10-27.** O provedor de produção é o **SMTP do Gmail do projeto**, não
> o SES: sem domínio, nenhum remetente passava no DMARC pelo SES. Esta seção fica como
> registro da revisão de 24/10. O que vale está no adendo do
> [`ADR-0006`](../../decisoes/adrs/0006-e-mail-transacional.md) e na
> [task 7](../86e35vhxm-convite-de-primeiro-acesso/7_task.md).

Roteiro para quem tem acesso ao console e à EC2. A IA não abre `ssh` nem roda `aws`
(`context/infraestrutura.md`).

**0. Levantar o que existe e registrar no ADR-0006.** Nada sobre o SMTP da AWS está nos
documentos nem nos parâmetros listados na `infraestrutura.md`.

- Região do SES. O resto está em `us-east-2`, e identidade, credencial e endpoint SMTP só
  valem na região onde foram criados.
- Identidade verificada: domínio (com DKIM) ou endereço de e-mail? Qual?
- A conta está em *sandbox* ou já tem *production access* (SES → Account dashboard)?
- Existe credencial SMTP (usuário IAM de SMTP)? Onde estão o usuário e a senha?
- Cota de envio (por dia e por segundo).

**1. Sair do sandbox.** No sandbox, o SES só entrega para identidades verificadas e para o
simulador (`success@simulator.amazonses.com`), no máximo 200 por dia, 1 por segundo.
Convidar alguém novo é justamente escrever para quem não está verificado. O pedido é em
SES → Account dashboard → *Request production access*, tipo *Transactional*. Descrição
sugerida: convite de primeiro acesso e redefinição de senha; volume baixo (dezenas por
mês); destinatários cadastrados por um administrador; sem lista comprada; bounce e
reclamação tratados pela lista de supressão da conta.

**2. Remetente.**

- **Com domínio:** identidade de domínio com Easy DKIM (3 CNAMEs), MAIL FROM próprio (MX +
  TXT de SPF) e TXT de DMARC (`p=none` para começar). Remetente do tipo
  `nao-responda@<domínio>`.
- **Sem domínio** (a produção hoje): só identidade de endereço. Mandar como `@gmail.com`
  ou `@pucrs.br` pelo SES não passa no alinhamento DMARC; conforme a política do domínio,
  cai em spam ou é recusado, e a própria AWS desaconselha. Serve para a banca, não para
  uso real.
- **Recomendação:** um domínio, ou um subdomínio cedido. Resolve o remetente e tira o IP
  do link.

**3. Credencial SMTP.** SES → *SMTP settings* → *Create SMTP credentials*. Isso cria um
usuário IAM com `ses:SendRawEmail`; a senha SMTP é derivada da chave e só vale na região.
Opcional: restringir a policy ao ARN da identidade. Guardar, pela regra da
`infraestrutura.md` (Parameter Store e `/opt/creed/.env` no mesmo momento):

| Parâmetro | Tipo | Valor |
|---|---|---|
| `/creed/prod/SMTP_HOST` | String | `email-smtp.<região>.amazonaws.com` |
| `/creed/prod/SMTP_PORT` | String | `587` |
| `/creed/prod/SMTP_FROM` | String | o remetente verificado |
| `/creed/prod/SMTP_USER` | SecureString | usuário SMTP |
| `/creed/prod/SMTP_PASSWORD` | SecureString | senha SMTP |

**4. Rede.** Usar a 587 (STARTTLS) ou a 465 (TLS). A 25 é limitada pela AWS em EC2. Conferir
a saída no security group (o padrão libera tudo). Teste de dentro da EC2:

```bash
openssl s_client -starttls smtp -connect email-smtp.<região>.amazonaws.com:587 -crlf
```

O TLS tem que negociar, e um `EHLO teste` tem que voltar `250`.

**5. Aplicar o SMTP no realm de produção.** O `--import-realm` não reimporta um realm que
já existe.

| Caminho | A favor | Contra |
|---|---|---|
| **Script com `kcadm.sh` dentro do container** (recomendado) | versionado, repetível, sem clique | precisa do admin pessoal do realm `master` |
| Console pelo túnel SSH (*Realm settings → Email → Test connection*) | rápido, e tem o botão de teste | é o "clicar na UI" que a 23.2 proíbe, e não deixa rastro |
| Reimportar com `kc.sh import --override true` | — | **apaga e recria o realm, com os usuários.** Não usar |

Forma do script (a senha nunca vai na linha de comando nem fica em arquivo):

```bash
# na EC2, em /opt/creed/creed-infrastructure/ec2
docker compose exec keycloak /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080/auth --realm master --user <seu-admin>   # pede a senha

# o JSON {"smtpServer": {...}} é montado a partir do .env e vai pela entrada padrão
<gera o JSON> | docker compose exec -T keycloak /opt/keycloak/bin/kcadm.sh update realms/creed -f -

docker compose exec keycloak /opt/keycloak/bin/kcadm.sh get realms/creed --fields smtpServer
```

```json
{ "smtpServer": { "host": "email-smtp.<região>.amazonaws.com", "port": "587",
  "from": "<remetente verificado>", "fromDisplayName": "CREED.ai Educa",
  "auth": "true", "starttls": "true", "ssl": "false",
  "user": "<usuário SMTP>", "password": "<senha SMTP>" } }
```

O mesmo script aplica idioma, `passwordPolicy` e `redirectUris`. A senha do SMTP fica
gravada no schema `keycloak` do RDS. Se isso incomodar, o *vault* de arquivo do Keycloak
(`${vault.smtp_password}`) a mantém fora do banco. É opcional.

**6. Testar.**

- Antes da 23.8: um usuário de teste no realm com o e-mail
  `success@simulator.amazonses.com`, e `execute-actions-email` pela Admin API. Ou o *Test
  connection* do console, que manda para o e-mail do admin logado.
- `docker compose logs keycloak | grep -i -E "mail|smtp"`, e no SES, *Sending statistics*.
- Abrir o link de um celular fora da rede: tem que abrir
  `https://<IP>/auth/realms/creed/login-actions/action-token?...` com certificado válido.

**7. Depois.** Acompanhar bounce e reclamação (a lista de supressão da conta já vem ligada)
e a cota diária.

**8. Fora do escopo.** O mesmo SMTP pode servir os convites do editor do N8N, que hoje
mostra o link para copiar.

## 11. Decisões antes da spec

### Bifurcações técnicas (paradas)

**Parada 1 — o que acontece quando o convite não sai** (SMTP ou Keycloak fora):

| | A — tudo ou nada (recomendo) | B — cria e avisa |
|---|---|---|
| Comportamento | o envio falhou → apaga no Keycloak, rollback, 503; o admin tenta de novo | cria; a resposta diz `invitation_sent: false`; o "reenviar" resolve |
| A favor | sem estado "meio criado"; segue a D4 (compensação explícita); nada novo no banco | SMTP fora do ar não trava o cadastro |
| Contra | SMTP fora do ar trava o cadastro | exige status visível, ou ninguém fica sabendo que o e-mail não saiu |
| Precisa de | "reenviar" só para link vencido | "reenviar" e status (CREED-503) |

**Parada 2 — forma da API de "adicionar membro":**

| | A — endpoint composto no back (recomendo) | B — o front orquestra três chamadas |
|---|---|---|
| Forma | `POST /organizations/{organization_id}/members {email, role, name}` cria participante, vínculo, usuário e convite numa transação | `POST /participants` → `POST .../links` → `POST /users` |
| A favor | uma transação, uma compensação; o front manda o que o formulário tem | usa rotas que já existem |
| Contra | contrato novo | falha no meio deixa participante e vínculo órfãos; regra de negócio no front; as três rotas exigem `admin` |

O "esqueci minha senha" pelo back (B4) não é bifurcação: a D1 já decidiu que o front só
fala com o nosso back.

### Lacunas de produto → premissas candidatas

A próxima livre é a **P-045**. A P-041 estava livre na `main` e nas branches remotas, mas
as P-041 a P-044 foram usadas no mesmo dia (2026-10-24) pelo ADR-0010, ainda sem
commit. Nenhuma das candidatas abaixo foi gravada no ledger.

| Lacuna | Interpretação proposta | Por quê | Custo de reverter |
|---|---|---|---|
| Quem convida | `admin` em qualquer organização; `gestor` só na própria e só `gestor`/`respondente` | é o que o `AddMemberForm` já faz e o que a P-033 diz de organização. **Muda a P-008** ("criada por admin") | baixo: guarda |
| Nome de quem é convidado | o convite pede nome (campo novo nos formulários) | `participants.name` e `user.name` são `NOT NULL`; usar o e-mail como nome grava dado errado | baixo: um campo |
| Tipo do vínculo do membro de empresa | `emprego` | o formulário não pergunta, e `links.type` é obrigatório | baixo |
| Mentorando sem empresa (CREED-594) | vínculo `mentoria`, papel `respondente`, numa organização da própria CREED criada uma vez em produção | [C2] e `links.organization_id NOT NULL`; o `LinkType.MENTORIA` já existe | médio: muda dado |
| Validade do link | 72 h | as 12 h padrão vencem de um dia para o outro | baixo: setting |
| Texto e idioma do e-mail | texto padrão do Keycloak em pt-BR, sem tema próprio, nesta entrega | menor escopo | baixo |
| Depois de definir a senha | link "voltar à plataforma" para o `/login` do front | sem ele, a pessoa fica numa página do Keycloak sem saída | baixo |
| Empresa aprovada (CREED-591): quem recebe o convite | o e-mail informado no cadastro, como `gestor` | o modal mostra "e-mail da empresa" e "quem cadastra" | médio. Melhor resolver na spec da 591 |

### Decisões de infra (Enzo/você)

Domínio próprio ou cedido; *production access* do SES; dono do script de realm.

## 12. Recorte sugerido para a 23.8

Calibragem sugerida: **P3 · T3**. Há lacunas de produto, três repositórios, componente
externo novo e débito de segurança. Merece spec própria (`/spec 86e35vhxm`).

| # | Entrega | Repo | Fecha quando |
|---|---|---|---|
| 0 | (pré) Consolidar migrations (CREED-57) | back | `alembic upgrade head` sobe todas as tabelas de `models.py` num banco limpo |
| 1 | E-mail no local: `mailpit`, `smtpServer`, pt-BR, `passwordPolicy`, testes do realm | back | o Mailpit recebe o e-mail de um `execute-actions-email` manual |
| 2 | Provisionamento + convite no `POST /users` (B1, B2, B5, B6) | back | criar usuário cria nos dois lados e o e-mail chega; falha não deixa órfão |
| 3 | Reenviar convite e esqueci minha senha (B3, B4) | back | link vencido tem saída; o reset não revela se o e-mail existe |
| 4 | "Adicionar membro" com a regra de quem convida (B9) | back | depende das Paradas 1 e 2; pode virar subtarefa da CREED-50 |
| 5 | Front: tirar `/primeiro-acesso`, refazer `/recuperar-senha`, ligar o `AddMemberForm` | front | nenhuma tela de senha na plataforma |
| 6 | Produção: SES, Parameter Store, script de realm, primeiro admin por convite (B11) | infra + back | convite real chega a um endereço fora do sandbox |
| 7 | ADR-0006, contrato, premissas, pauta, ClickUp | harness | — |

Fora da 23.8, mas na fila: guarda do `DELETE /users` (B7, **agora**, independente), busca
pelo `sub` (B8), listagem de membros (CREED-503), mentorandos e aprovação de empresas
(CREED-59).

## 13. Riscos

- **Link com IP e remetente sem domínio**: o e-mail cai em spam e tem cara de phishing.
- **Realm de produção diferente do arquivo**: o import é uma vez só. Sem o script, cada
  ajuste vira clique ou esquecimento.
- **Console de conta exposto** (`/auth/realms/creed/account` passa pelo Caddy): a pessoa
  troca o próprio e-mail sem verificação (`verifyEmail: false`) e perde o acesso, porque
  o login procura pelo e-mail.
- **`DELETE /users/{user_id}` aberto**, já na `dev`, e na produção se a `dev` estiver no ar.
- **Sandbox do SES**: o convite só chega a endereço verificado.
- **Release**: nada chega à produção sem consolidação e release.
- **Board otimista**: a 23.3 aparece "finalizada", e o provisionamento é justamente o que
  falta. Quem pegar a 23.8 como "só ligar o e-mail" vai subestimar.

## 14. O que esta revisão não verificou

- Console da AWS e SES, EC2 (`BACK_TAG`, realm de produção), Parameter Store: fora do
  alcance, e proibido pela `infraestrutura.md`.
- Imagens anexadas no ClickUp (telas da CREED-50 e da CREED-59): não abri.
- Nenhum teste rodado, porque não houve mudança de código.
- Os comportamentos do Keycloak 26 citados aqui vêm da documentação e do código do
  Keycloak e do teste registrado no ADR-0006, não de execução nesta revisão. Validar na
  entrega 1, com o Mailpit:
  - o link sai com o `KC_HOSTNAME`;
  - a validade padrão é de 12 h;
  - o link marca o e-mail como verificado;
  - o `kcadm` funciona pela rede interna com o `KC_HOSTNAME_ADMIN` configurado.
