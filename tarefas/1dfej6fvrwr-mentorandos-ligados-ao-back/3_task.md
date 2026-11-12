# Task 3 — "Adicionar mentorando" com o convite

**Repo:** `creed-frontend`
**Depende de:** task 1 (`loadMentees(organizationId)`). A verificação de ponta a ponta
depende do **PR #51 do back** (`feat/86e35vhxm-convite-de-membro`), que ainda não está no
`dev`. Dá para programar e testar a unidade contra o contrato abaixo, que o front já tem
transcrito.

## Objetivo

O "Adicionar mentorando" do painel da administradora manda o convite por e-mail. A
pessoa aparece na tabela em seguida, e o e-mail repetido tem mensagem própria.

## Contexto

`POST /api/v1/organizations/{organization_id}/members` cria numa chamada a pessoa, o
vínculo e o acesso, e manda o convite por e-mail. Entrada: `MemberInvite`
(`{ name, email, role, type }`), já em `src/types/api.ts`. A chamada já existe:
`usersApi.inviteMember(organizationId, invite)`.

| Status | Quando | O que a tela faz (P-084) |
|---|---|---|
| 201 | convite enviado | toast de sucesso (já existe: `painelControle:toasts.conviteEnviado`), limpa o formulário e recarrega a tabela |
| 409 | o e-mail já tem acesso | **erro no campo e-mail**: "Este e-mail já tem acesso à plataforma." |
| 403, 404, 422, 503 | sem permissão, organização inexistente, dado inválido, provedor ou e-mail fora do ar | **mensagem do formulário**, abaixo dos campos: "Não foi possível enviar o convite. Tente de novo." |

Nos erros, o formulário mantém o que foi digitado e **não sai toast**. O lugar de cada
erro segue `formularios.md`, regra 7: 409 de e-mail duplicado no campo, erro que não é
de campo como mensagem do formulário.

Hoje o `AddMemberForm` engole qualquer erro do `onSubmit` (o `catch` vazio do `submit`).
Ele precisa passar a pôr o erro no lugar certo, e o formulário é o mesmo do painel da
empresa. A forma proposta:

- o `onSubmit` rejeita com `{ field: 'email' | 'root'; message: string }`, sendo
  `message` a chave de i18n;
- o `catch` do `submit` faz `setError(field, { message })`;
- o formulário mostra o erro de `root` abaixo dos campos.

Quem rejeita com outra coisa continua como hoje: nada aparece e os campos ficam. Por
isso o painel da empresa não muda nesta task.

Recarregar a tabela **não é do thunk do convite** (`camadas-do-front.md`: um thunk, uma
responsabilidade). O painel recarrega depois do `unwrap()`.

## Arquivos que provavelmente mudam

- `src/features/users/usersSlice.ts`: thunk `inviteMentee({ organizationId, name, email })`.
  - Chama `usersApi.inviteMember(organizationId, { name, email, role: 'respondente',
    type: 'mentoria' })`.
  - No erro, `rejectWithValue` com `{ field: 'email', message:
    'mentees:errors.inviteConflict' }` no 409, e `{ field: 'root', message:
    'mentees:errors.inviteFailed' }` no resto.
  - Não recarrega a lista.
- `src/features/users/AddMemberForm.tsx`: o `catch` do `submit` põe no campo (`email`)
  ou no formulário (`root`) o erro que o `onSubmit` rejeitar nesse formato, e o
  formulário mostra o erro de `root`. Qualquer outra rejeição continua como hoje.
- `src/features/controlPanel/AdminControlPanelView.tsx`: o `handleAdicionar` vira
  `async`.
  - Lê a organização da sessão e despacha `inviteMentee(...).unwrap()`.
  - No sucesso, despacha `loadMentees(organizationId)` e mostra o toast de sucesso.
  - No erro, relança o que o thunk rejeitou, para o formulário mostrar.
  - Sai o `TODO` de integração.
- `src/i18n/locales/{pt-BR,en,es}.ts`: `mentees.errors.inviteConflict` e
  `mentees.errors.inviteFailed`, nos três idiomas.
- Testes:
  - `usersSlice.test.ts`: o thunk chama com `respondente` e `mentoria`; 409 e erro
    genérico.
  - `AddMemberForm.test.tsx`: erro de `email` no campo, de `root` abaixo dos campos, e
    rejeição em outro formato sem mensagem.
  - `AdminControlPanelView.test.tsx`: toast e recarga só depois da resposta; 409 no campo
    e sem toast.
  - Todos com o `usersApi` simulado e `ApiError`.

## Molde

- `chaveDeErro` em `src/features/authentication/authenticationSlice.ts`.
- `AddMemberForm.test.tsx`, para o formulário que mantém os campos quando o `onSubmit`
  rejeita.

## Critérios de aceite

- [ ] Adicionar chama `usersApi.inviteMember` com a organização da sessão,
      `role: 'respondente'` e `type: 'mentoria'`.
- [ ] Depois do 201: toast de sucesso, formulário limpo e nova chamada à listagem.
- [ ] Com 409: a mensagem própria **no campo e-mail**, nos três idiomas. Nome e e-mail
      continuam, e não sai toast.
- [ ] Com 503 (e os outros erros): a mensagem genérica **abaixo dos campos**. Os campos
      continuam, e não sai toast.
- [ ] O toast de sucesso não aparece antes da resposta do back.
- [ ] O thunk do convite não recarrega a lista: quem recarrega é o painel.
- [ ] O painel da empresa (`CompanyControlPanelView`) continua funcionando como antes.
- [ ] `npm run check` passa.

## Como testar

```bash
cd creed-frontend
npx vitest run src/features/users src/features/controlPanel
npm run check
```

Ponta a ponta, **só com o back na branch do PR #51** ou depois do merge dele:
- Adicionar um e-mail novo faz a pessoa aparecer na tabela, e o convite chega no Mailpit
  local.
- Repetir o mesmo e-mail mostra a mensagem do 409.

## Premissas aplicáveis

- P-084: mensagens do convite.
- P-046 e P-047: o convite pede o nome e, sem `type`, o back grava `emprego`. Por isso
  o `type: 'mentoria'` é obrigatório aqui.

## Como ficou (diferenças do plano acima)

- **As chaves de erro moram em `organizations:errors`** (`emailTaken`, `inviteFailed`), ao
  lado dos erros de validação do mesmo formulário, e não em `mentees`. O painel da
  empresa vai usar as mesmas quando ligar o convite dele (C-2). As constantes ficam em
  `addMemberSchema.ts` (`INVITE_EMAIL_TAKEN`, `INVITE_FAILED`, tipo `InviteError`).
- **A rejeição é a própria chave, e não `{ field, message }`.** O painel faz
  `await dispatch(inviteMentee(...)).unwrap()` sem `try/catch`. Quando o thunk rejeita, o
  `unwrap` lança a chave, e o `AddMemberForm` a compara com as duas constantes: e-mail
  vai para o campo, o resto vai para o formulário. É o mesmo padrão do `SignUpView`
  (`DOCUMENTO_JA_CADASTRADO`), do PR #62. Qualquer outra rejeição continua como antes:
  os campos ficam e nada aparece.
- **O thunk aceita `organizationId` nulo** e rejeita com `inviteFailed` sem chamar o
  back, para o painel não precisar de um caminho próprio para a sessão sem organização.
