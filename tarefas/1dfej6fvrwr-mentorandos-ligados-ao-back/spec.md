# CREED-699 — M-4 · Tabela de mentorandos e "Adicionar mentorando" ligados ao back

ClickUp: [CREED - 699 - Integração pt2 (M4)](https://app.clickup.com/t/1dfej6fvrwr) ·
épico [CREED - 69 - Painel de controle](https://app.clickup.com/t/1dfej6fvrrn)

## Calibragem

**P2 · T2**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P2 | O resultado e quem usa estão escritos ("a administradora", "papel `respondente` e tipo `mentoria`", quatro itens em "Pronto quando"), e não há regra de negócio nova. Sobram lacunas baratas de reverter: o texto do 409 "nos três idiomas", o que a tela faz com os erros da exclusão (503 e 404 da M-3) e o que o "Editar" mostra do período (P-5). |
| Técnico | T2 | Um repo (`creed-frontend`), mas consome contrato novo para o front: a listagem da M-2 e a exclusão da M-3 ainda não estão transcritas em `src/types/api.ts`. Sem migration, sem agregação, sem infra. Entre T2 e T3, o que decidiu foi a dependência do convite (B-0, PR #51 do back, ainda aberto): o front já tem o `inviteMember` transcrito, e nenhum contrato que alguém consome muda. |

Dispensadas nesta calibragem: Dados (nenhuma coluna nova) · Abordagem técnica (só em T3).

## Problema

O painel da administradora (`/control-panel/admin`) mostra mentorandos inventados: a
tabela lê um mock do `usersApi.ts`, o "Adicionar mentorando" só escreve no console e a
exclusão só some com a linha na tela. O back já lista (M-2) e exclui (M-3) membros, e
o convite (B-0) está para entrar.

## Quem usa

A **administradora** (papel `admin`, vínculo na organização da CREED), no painel dela.
Para ela:

- convidar um mentorando por nome e e-mail, e vê-lo na tabela em seguida;
- ver a lista real de mentorandos, saber quem já respondeu o questionário atual e abrir
  o questionário de cada um;
- excluir um mentorando, sabendo que a exclusão apaga a pessoa e os resultados dela
  para sempre.

**Mentorando** é uma pessoa com vínculo do tipo `mentoria` na organização da CREED.
**Vínculo** é o elo entre a pessoa e a organização: guarda o papel e o tipo. É o
`link_id` que identifica cada linha da tabela.

O gestor (painel da empresa) não muda nesta tarefa.

## Escopo

**Entra:**
- Transcrever para `src/types/api.ts` a resposta da M-2 (`MemberListItem`,
  `MemberPeriod`, `PeriodStatus`) e trocar o tipo provisório `Mentee` por ela.
- `linksApi.ts` ganha a listagem (M-2) e a exclusão (M-3). As rotas são do domínio
  `links` no back, e o front espelha o domínio.
- `usersSlice`: `loadMentees` chama a M-2 com `?type=mentoria` e a organização da sessão;
  `deleteMentee` chama a M-3; nasce um thunk de convite que chama `usersApi.inviteMember`
  e, depois do 201, recarrega a lista.
- `AdminControlPanelView`: o "Adicionar mentorando" usa esse thunk, com papel
  `respondente` e tipo `mentoria`, e a organização vem da sessão (fecha o `TODO` de lá).
- `MenteesTable`:
  - sai a coluna de status, com a ordenação por status e o selo no cartão do celular;
  - "Ver resultados" fica habilitado só com `period.has_answered === true`;
  - "Editar" passa o vínculo e o período da linha ao diálogo (P-082).
- Modal de exclusão com texto novo: a pessoa e os resultados dela são apagados para
  sempre. Erros da exclusão dentro do modal, conforme a P-083.
- 409 do convite com mensagem própria no campo e-mail, nos três idiomas (pt-BR, en, es),
  e os outros erros como mensagem do formulário, conforme a P-084. O `AddMemberForm`
  passa a saber pôr no campo, ou no formulário, o erro que o `onSubmit` devolve. O
  formulário é o mesmo do painel da empresa, e a mudança vale para os dois.
- No harness, na mesma entrega: as linhas "Mentorandos" e "Adicionar mentorando" da
  tabela "Onde a tela diverge do back" (`conventions/contrato-front-back.md`) passam a
  "resolvido", e o `catalogo.md` deixa de dizer que a lista de mentorandos é mock.
- Sai do `usersApi.ts` o mock de mentorandos (`menteeSeed`, `listMentees`,
  `removeMentee`, `resetMenteesMock`). Os testes passam a usar dado de teste próprio, no
  arquivo de teste.

**Não entra:**
- Gravar o período do questionário: o diálogo continua salvando só no console, e quem
  liga o "Salvar" à rota de período é a P-5.
- Ligar "Ver resultados" ao dashboard: ficam as tasks de dashboard. O botão só passa a
  respeitar o `has_answered`.
- O painel da empresa (`MembersSection`, `MembersTable`) e o mock de membros
  (`memberSeed`, `listMembers`, `removeMember`, `setMemberTag`): é a C-2
  ([CREED-6911](https://app.clickup.com/t/1dfej6fvrwv)).
- Paginação no servidor. A M-2 devolve a lista inteira (P-070), e a paginação continua
  na tela, como hoje.
- Qualquer mudança no back. Se faltar algo no contrato, vira pendência para outra tarefa.
- As caixas de seleção da tabela (`selectable`), que continuam desligadas.

## Repos afetados

| Repo | O que muda |
|---|---|
| creed-backend | nada (consome M-2 e M-3, no `dev`, e o convite do PR #51) |
| creed-frontend | `src/types/api.ts`, `features/links/linksApi.ts`, `features/users/usersApi.ts`, `usersSlice.ts`, `MenteesSection.tsx`, `MenteesTable.tsx`, `features/controlPanel/AdminControlPanelView.tsx`, `src/i18n/locales/{pt-BR,en,es}.ts` e os testes de cada um |
| creed-infrastructure | nada |

Nome do domínio/feature: as rotas são do domínio `links` (listar e excluir) e `users`
(convidar). A tela continua na feature `users`, onde a seção de mentorandos já está.

## Contrato

O que a tela consome, visto do front. Prefixo `/api/v1`. A organização é sempre a da
sessão (`state.authentication.user.organization_id`), que para a administradora é a da
CREED.

| Método | Rota | Entrada | Saída | Erros que a tela trata |
|---|---|---|---|---|
| GET | `/organizations/{organization_id}/members?type=mentoria` | — | 200 `MemberListItem[]`, possivelmente `[]` | qualquer erro → estado de erro da seção (`mentees:loadError`, já existe) |
| DELETE | `/organizations/{organization_id}/members/{link_id}` | — | 204, sem corpo | 503, 404, 403 e outros: P-083 |
| POST | `/organizations/{organization_id}/members` | `MemberInvite`: `{ name, email, role: 'respondente', type: 'mentoria' }` | 201 `UserResponse` | 409 e os outros: P-084 |

O POST é do PR #51 do back, **ainda fora do `dev`**. `MemberInvite` e
`usersApi.inviteMember` já estão no front, e não mudam.

Quem traduz o status em mensagem é o **slice**: o thunk devolve, com `rejectWithValue`,
uma chave de i18n. A View só traduz a chave e escolhe onde mostrar (modal, campo ou
formulário), sem olhar `ApiError` (`camadas-do-front.md`).

A mensagem do 409 do convite é própria, e não o `detail` do back. Isso diverge do que
`contrato-front-back.md` sugere para o 409 ("a mensagem do backend vale"), porque o
`detail` vem só em português e a tarefa pede os três idiomas.

`MemberListItem`, transcrito do back (`app/domains/links/schemas.py`):

| Campo | Tipo | Na tela |
|---|---|---|
| `link_id` | `string` (UUID) | chave da linha; vai para o "Editar" e para a exclusão |
| `name` | `string` | coluna Nome, busca e ordenação |
| `email` | `string \| null` | coluna Email e busca. Nulo só em vínculo criado sem convite: mostra vazio |
| `role` | `Role` | não aparece |
| `type` | `LinkType` | não aparece (é sempre `mentoria`) |
| `department` | `DepartmentType \| null` | não aparece |
| `updated_at` | `string \| null` (ISO) | não aparece |
| `period` | `MemberPeriod \| null` | "Ver resultados" e valores iniciais do "Editar" |

`MemberPeriod`: `form_id` (string), `opens_at` e `closes_at` (ISO), `period_status`
(`'past' \| 'open' \| 'scheduled'`), `has_answered` (boolean).

O período de cada pessoa é escolhido pelo back (P-068): o aberto, senão o próximo
agendado, senão o último que passou. `has_answered` é verdadeiro só com resposta
**enviada** naquele período (P-069). A tela não recalcula nada disso.

## Critérios de aceite

- [ ] A tabela de mentorandos lista o que a M-2 devolve para a organização da sessão com
      `?type=mentoria`. Não há mais mock de mentorandos no `usersApi.ts` (`menteeSeed`,
      `listMentees`, `removeMentee`, `resetMenteesMock` saíram), e o tipo `Mentee` saiu
      de `src/types/api.ts`.
- [ ] A tabela e os cartões do celular não têm coluna, selo nem ordenação de status.
- [ ] "Ver resultados" fica desabilitado em quem tem `period` nulo ou
      `period.has_answered` falso, e habilitado em quem tem `has_answered` verdadeiro.
- [ ] "Editar" abre o diálogo com abertura e fechamento do `period` da linha, e vazio
      quando `period` é nulo (P-082).
- [ ] Adicionar um mentorando chama `inviteMember` com a organização da sessão,
      `role: 'respondente'` e `type: 'mentoria'`. Depois do 201, a tabela é recarregada e
      a pessoa aparece nela. O aviso de sucesso só vem depois do 201.
- [ ] Convite com 409 mostra a mensagem própria **no campo e-mail** (P-084), em pt-BR, en
      e es. Os outros erros aparecem como mensagem do formulário. Nos dois casos o
      formulário mantém nome e e-mail, e não sai toast de erro.
- [ ] Excluir chama a M-3 com o `link_id` da linha. Com 204 ou 404, a linha sai da
      tabela. Com 503, a mensagem de "tente de novo" aparece **dentro do modal**, que
      fica aberto, e a linha fica (P-083).
- [ ] O modal de exclusão diz que o mentorando **e os resultados dele** são apagados para
      sempre, nos três idiomas.
- [ ] Os testes de `MenteesTable`, `MenteesSection`, `usersSlice`, `usersApi`,
      `linksApi` e `AdminControlPanelView` usam dado de teste próprio, e não o mock.
- [ ] `npm run check` passa.

## Como verificar

1. Suíte e lint do front:

   ```bash
   cd creed-frontend
   npm run check
   npx vitest run src/features/users src/features/links src/features/controlPanel
   ```

2. Mock fora:

   ```bash
   grep -rnE "menteeSeed|listMentees|removeMentee|resetMenteesMock|\bMentee\b" src
   ```

   Não deve achar nada.

3. Ponta a ponta, listar e excluir: suba o back do `dev` local (Postgres e Keycloak) e o
   front com `npm run dev`, entre como a administradora e abra `/control-panel/admin`.
   - A tabela mostra os vínculos `mentoria` da CREED.
   - Excluir um deles tira a linha, e um novo `GET` não o traz mais.
   - Com o Keycloak parado, excluir mostra o erro de "tente de novo" e a linha fica.
4. Ponta a ponta, convidar: só com o back na branch do PR #51
   (`feat/86e35vhxm-convite-de-membro`) ou depois que ele entrar no `dev`.
   - Adicionar um e-mail novo faz a pessoa aparecer na tabela, e o e-mail chega no
     Mailpit local.
   - Repetir o mesmo e-mail mostra a mensagem do 409.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-082 | "Editar" abre o diálogo preenchido com o período que a linha traz da M-2, e vazio sem período. Gravar continua com a P-5. | baixo |
| P-083 | Exclusão: os erros aparecem dentro do modal, sem toast. 503 → "tente de novo", e o modal e a linha ficam. 403 e outros → mensagem genérica do modal. 404 conta como feito: a linha sai. | baixo |
| P-084 | Convite: 409 → erro no campo e-mail, "Este e-mail já tem acesso à plataforma." (pt-BR, en, es); os outros erros → mensagem do formulário, "Não foi possível enviar o convite. Tente de novo.". O formulário mantém o digitado, e não sai toast de erro. | baixo |

Já registradas em `decisoes/premissas.md`. Valem também, vindas da M-2 e da M-3:
P-064 ("Editar" sempre habilitado), P-068 (qual período), P-069 (respondeu = enviada),
P-070 (sem paginação, ordem por nome) e P-074 (qualquer vínculo pode ser excluído).

## Riscos

- **O convite depende do PR #51 do back**, que está aberto, com mudanças pedidas e em
  conflito com o `dev`. A listagem e a exclusão não dependem dele e podem entrar antes. O
  sinal de risco é o "Pronto quando" do convite não poder ser verificado de ponta a
  ponta. Nesse caso, a entrega do convite fica pronta contra o contrato, com teste de
  unidade, e a verificação manual espera o merge do #51.
- **A exclusão é irreversível**, e a P-074 (excluir outro admin) continua aberta. Na
  tabela de mentorandos só aparecem vínculos `mentoria`, então a administradora não
  consegue excluir outro admin por esta tela.
- **`email` nulo:** a M-2 devolve `null` para vínculo sem login. Hoje a busca por e-mail
  e a célula assumem `string`. Se isso não for tratado, a busca quebra com
  `normalizeForSearch(null)`. O sinal é o teste com uma linha sem e-mail.
- **Divergência com o glossário:** ele diz que o convite está em
  `organizationsApi.inviteMember`, na feature `organizations`, mas no `dev` do front está
  em `usersApi.inviteMember`. Esta spec segue o código.
