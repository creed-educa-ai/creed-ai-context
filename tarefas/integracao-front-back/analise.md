# Front: o que falta para integrar com o back

> Análise de 2026-11-03, lendo o `creed-frontend` (`feat/3-ajustes-dashboard`) e o
> `creed-backend` (`dev`, `cc8dc61`, mais as branches ainda abertas). O dashboard
> tem análise própria e mais funda em
> [`../dashboard-leitura-backend/`](../dashboard-leitura-backend/) (`analise.md`
> para o back, `analise-front.md` para o front). Ainda não é spec.

## Em três frases

1. **Hoje só três fluxos falam com o back de verdade:** login, pedido de nova senha
   e o questionário. Todo o resto (painéis, dashboards, cadastro de empresa,
   demográficos) roda sobre mock no `<feature>Api.ts` ou ainda não envia nada.
2. **O front está mais adiantado que o back.** Dos 10 `Api.ts`, a maioria das
   funções já está escrita e testada contra o contrato, esperando uma tela ou uma
   rota. O que trava é quase sempre **uma rota que não existe** ou que está numa
   branch fora da `dev`.
3. **O fluxo que destrava o produto é o questionário.** Ele já está integrado, mas
   num formulário fixo de demonstração e sem as perguntas objetivas. Sem ele, não
   existe nota, e sem nota os dashboards não têm o que mostrar.

## 1. Tela por tela

Legenda: ✅ integrado · 🟡 integrado em parte · 🔶 mock no `Api.ts` · ⬜ não envia nada

| Rota | Tela | Hoje | O que o back tem | O que falta |
|---|---|---|---|---|
| `/` · `/about` | boas-vindas, informações | — páginas públicas, sem dado | — | nada |
| `/login` | login | ✅ `POST /authentication/login` | ✅ `dev` | nada. A sessão vem da resposta do login e fica no `localStorage` |
| `/reset-password` | pedir nova senha | ✅ chama `POST /authentication/password-reset` | ⏳ branch `feat/86e35vhxm-reenvio-e-reset-de-senha` | o merge da branch. Até lá, a tela recebe 404 |
| `/sign-up` · `/awaiting-confirmation` | cadastro de empresa | 🔶 `registerCompany` no mock | ❌ nenhuma rota (CREED-591/595) | rota de cadastro público e de aprovação no back; o tipo `Company` tem campos que `OrganizationResponse` não tem |
| `/demographics/step-1…3` | dados demográficos | ⬜ guarda no slice e segue para o questionário | 🟡 tabela e schema (`DemographicCreate`), **sem rota** | `POST` de demográficos no back; o nome (tela 1) vai para `Participant`, e a perspectiva (tela 3) **não tem lugar** no banco |
| `/questionnaire/*` | questionário | 🟡 lê formulário e perguntas, grava respostas e envia | ✅ `forms`, `questions`, `form-responses` | ver seção 2: formulário fixo, objetivas de demonstração, alternativas fora da listagem |
| `/dashboard` · `/dashboard/company` | dashboards | 🔶 tudo em mock | ❌ router stub | ver [`../dashboard-leitura-backend/`](../dashboard-leitura-backend/) |
| `/control-panel` | painel da empresa | 🔶 lista de membros e remoção em mock · ⬜ convidar membro e configurar questionário só fazem `console.log` | ⏳ convite na branch `feat/86e35vhxm-convite-de-membro` · ❌ listar e remover membros · ❌ período do formulário | seção 3 |
| `/control-panel/admin` | painel do super adm | 🔶 empresas e mentorandos em mock · ⬜ adicionar mentorando, "ver resultados" e "editar questionário" só fazem `console.log` | ❌ nenhuma das listas | seção 3 |

### Funções prontas que nenhuma tela usa ainda

Estão escritas, têm teste com `stubFetch` e batem com rotas que existem na `dev`.
Esperam a tela que vai chamá-las:

| `Api.ts` | Funções | Quem deve chamar |
|---|---|---|
| `departmentsApi` | `createDepartment`, `getDepartment` | cadastro de setores no painel da empresa (não existe tela) |
| `linksApi` | `createLink` | convite de membro, se não vier tudo numa chamada só (a branch de convite faz numa chamada) |
| `participantsApi` | `createParticipant`, `getParticipant` | demográficos (o nome da tela 1) |
| `formsApi` | `createForm` | configurar questionário, no painel da empresa |
| `questionsApi` | `createQuestion`, `createOption` | cadastro do instrumento (hoje, só por script) |
| `organizationsApi` | `listOrganizations`, `getOrganization`, `createOrganization`, `updateOrganization` | painel do admin. Hoje a tela usa a lista mockada de `Company` no lugar |
| `usersApi` | `createUser`, `deleteUser`, `inviteMember`, `resendInvitation` | painéis (as duas últimas dependem das branches de convite) |
| `authenticationApi` | `getCurrentUser` | ninguém. A sessão restaurada do `localStorage` não é conferida no back ao recarregar a página |

## 2. O questionário: o fluxo que destrava o resto

Já grava de verdade, mas com três atalhos de demonstração que precisam sair:

| Atalho | Onde | Por que existe | O que substitui |
|---|---|---|---|
| **Formulário fixo** `DEMO_FORM_ID` | `responsesSlice.ts`, usado por `FormView` e `AnswersReviewRoute` | o back não tem rota para "qual formulário esta pessoa deve responder" | rota nova no back, por exemplo `GET /forms?status=published` para a organização do vínculo. **Não existe e precisa de decisão:** com mais de um formulário aberto, qual vale? |
| **Objetivas de demonstração** (`demoQuestions.ts`) misturadas às perguntas do back | `responsesSlice.ts`, `loadQuestionnaire` | a listagem do back não traz alternativas, então o front não tinha como desenhar uma objetiva real | `options` em `GET /forms/{id}/questions` (P-039) e o instrumento cadastrado no banco |
| **Objetivas puladas no envio** (`continue`) | `responsesSlice.ts`, `submitResponses` | as objetivas da tela são as de demonstração, com ids que o back não conhece | apagar a linha quando os dois de cima existirem |

Os três saem juntos, numa task só de front, logo depois de o back entregar a
listagem com `options`. Detalhe do lado do back na
[`analise.md`](../dashboard-leitura-backend/analise.md) do dashboard, seção 1.

## 3. Os painéis

### Painel da empresa (`/control-panel`)

| Ação | Hoje | Falta |
|---|---|---|
| Ver membros | 🔶 `listMembers` (mock, junto com o nome da organização) | rota de listagem no back: `GET /organizations/{id}/links` não existe (só o `POST`). O nome da organização pode vir de `GET /organizacoes/{id}`, que já existe |
| Remover membro | 🔶 `removeMember` (mock) | decisão: remover é encerrar o vínculo (`links.end_at`) ou apagar o login (`DELETE /users/{id}`, que já existe)? |
| Convidar membro | ⬜ `console.log` | merge de `feat/86e35vhxm-convite-de-membro`; depois, um thunk no `usersSlice` chamando `inviteMember` |
| Configurar questionário (período, horário) | ⬜ `console.log` | `Form` não tem início nem término, só `status`. **Decisão de modelo**, ligada à decisão 1 do dashboard ("o que é um período") |

### Painel do super adm (`/control-panel/admin`)

| Ação | Hoje | Falta |
|---|---|---|
| Empresas: listar, aprovar, recusar, remover | 🔶 `listCompanies` e companhia (mock) | o fluxo de cadastro e aprovação no back (CREED-591/595). A listagem simples já existe (`GET /organizacoes`) e poderia entrar antes, sem a aprovação |
| Mentorandos: listar, remover | 🔶 `listMentees` (mock) | rota de listagem: são vínculos `mentoria` na organização da CREED |
| Adicionar mentorando | ⬜ `console.log` | o mesmo convite do painel da empresa, com `type: 'mentoria'`. Falta o **id da organização CREED** no front (não há como descobrir hoje) e o nome da pessoa no formulário (P-046) |
| "Ver resultados" (empresa ou mentorando) | ⬜ `console.log` | a rota do dashboard com `organization_id` e `member_id` (furo A da análise do dashboard) |

## 4. O que atravessa todas as telas

| Tema | Situação | Proposta |
|---|---|---|
| **Cancelar requisição** | `apiClient.get` não aceita `signal` | uma opção a mais no `apiClient`, sem quebrar quem já usa. Vale para toda lista com filtro, não só o dashboard |
| **Autorização por rota** | `ProtectedRoute` só confere se há sessão. O papel só esconde itens do menu (P-055): qualquer pessoa logada abre `/control-panel/admin` pela URL | guarda por papel nas rotas dos painéis e do dashboard da empresa. O back recusa de qualquer jeito, mas a tela deveria mostrar "sem acesso" em vez de quebrar |
| **Sessão restaurada sem conferência** | ao recarregar, a sessão sai do `localStorage`, e `getCurrentUser` não é chamado. Papel ou vínculo que mudaram no back só aparecem no próximo login | chamar `GET /authentication/session` ao iniciar o app |
| **`organization_name` da sessão** | o back devolve sempre nulo | preencher no back (o `AuthenticatedUser` já tem a organização). Hoje cada tela busca o nome por conta própria, e no mock ele vem junto da lista de membros |
| **Login desligado** (`VITE_LOGIN_ENABLED=false`) | as telas abrem sem sessão, e o mock responde | com o back real, toda rota protegida devolve 401. A chave passa a servir só para demonstração sobre mock; vale registrar como premissa |
| **Tipos escritos à mão** | `src/types/api.ts` acompanha os `schemas.py` manualmente | conferir contra o OpenAPI (`/docs`) na review de cada integração. Gerar os tipos do OpenAPI seria dependência nova (ADR) |
| **Mocks usados como dado de teste** | os testes das telas de dashboards, empresas, membros e mentorandos dependem do mock de dentro do `Api.ts` | antes de cada troca, mover o mock para uma fixture da feature e usar `vi.spyOn` nos testes (detalhe em `analise-front.md`, seção 5) |

## 5. O que falta no back, em uma lista

O que o front já espera e o back ainda não entrega, por onde está:

| Rota ou mudança | Para | Onde está |
|---|---|---|
| `POST /authentication/password-reset`, `POST /users/{id}/invitation` | nova senha, reenviar convite | ⏳ `feat/86e35vhxm-reenvio-e-reset-de-senha` (4 commits à frente da `dev`) |
| convite de membro numa chamada | painéis | ⏳ `feat/86e35vhxm-convite-de-membro` (3 commits) |
| `options` em `GET /forms/{id}/questions` | questionário, dashboards | ❌ falta (P-039) |
| "qual formulário eu respondo" | questionário | ❌ falta, com decisão |
| listar vínculos ou membros de uma organização | painel da empresa, mentorandos | ❌ falta |
| `POST` de demográficos | demográficos | ❌ falta (tabela existe) |
| cadastro e aprovação de empresa | sign-up, painel do admin | ❌ falta (CREED-591/595) |
| período no formulário | configurar questionário, dashboards | ❌ falta, com decisão de modelo |
| `GET /dashboards/me` e `/dashboards/company` | dashboards | ❌ router stub |
| `organization_name` na sessão | cabeçalhos | 🟡 campo existe, sempre nulo |

## 6. Ordem sugerida

Pelo que destrava mais com menos, e cada passo ponta a ponta (back + front):

| # | Entrega | Back | Front | Destrava |
|---|---|---|---|---|
| 1 | **Branches de convite e senha na `dev`** | merge, já pronto | thunk de convite no painel da empresa; a tela de nova senha passa a funcionar | entrada de pessoas reais |
| 2 | **Questionário real** | `options` na listagem, "qual formulário eu respondo", instrumento cadastrado | tirar os três atalhos da seção 2 | toda nota do produto |
| 3 | **Transversais** | `organization_name` na sessão | `signal` no `apiClient`, guarda por papel, `getCurrentUser` no início | painéis e dashboards sem retrabalho |
| 4 | **Painel da empresa** | listar membros; decisão sobre remover | trocar `listMembers` e `removeMember`; nome da organização pela rota | gestão de pessoas |
| 5 | **Demográficos** | `POST` de demográficos; lugar para a perspectiva | `demographicsApi.ts` e o envio no fim da etapa 3 | perfil das pessoas |
| 6 | **Dashboards** | [`../dashboard-leitura-backend/analise.md`](../dashboard-leitura-backend/analise.md) | [`analise-front.md`](../dashboard-leitura-backend/analise-front.md) | o produto em si |
| 7 | **Painel do admin** | cadastro e aprovação de empresa; listar mentorandos | trocar os mocks de `Company` e `Mentee` | a operação da CREED |

O passo 2 vem antes dos dashboards porque é ele que produz o dado. O passo 7 fica
por último porque depende do maior pedaço de back que não existe (CREED-591/595),
mas a listagem simples de empresas (`GET /organizacoes`) pode entrar antes, se o
painel precisar.

## 7. Decisões que aparecem aqui

São novas em relação às do dashboard e viram premissas antes da spec:

| Decisão | Por que trava | De quem |
|---|---|---|
| Qual formulário a pessoa responde quando há mais de um publicado | sem isso, a rota "meu formulário" não tem regra | cliente |
| O que é "remover membro": encerrar o vínculo ou apagar o login | muda a rota e o que acontece com as respostas antigas da pessoa | time, depois cliente |
| Onde mora a "perspectiva" (tela 3 dos demográficos) | não tem coluna em lugar nenhum | time |
| Como o front sabe o id da organização CREED | adicionar mentorando precisa dele | time: configuração do ambiente ou a própria sessão do admin |
| `VITE_LOGIN_ENABLED=false` continua existindo | com o back real, deixa de funcionar fora do mock | time |
