# Task 2 — Excluir mentorando pela M-3

**Repo:** `creed-frontend`
**Depende de:** task 1 (`MemberListItem`, `loadMentees(organizationId)`)

## Objetivo

Excluir um mentorando na tabela apaga a pessoa no back. A linha só sai depois da
confirmação do back, e os erros têm tratamento próprio. Com isso, o mock de mentorandos
sai de vez do `usersApi.ts`.

## Contexto

`DELETE /api/v1/organizations/{organization_id}/members/{link_id}` exclui o membro **de
vez**: as respostas, os questionários feitos só para ele, o vínculo, o login (no banco e
no Keycloak) e, se a pessoa não tiver vínculo com outra organização, os dados dela.

| Status | Quando | O que a tela faz (P-083) |
|---|---|---|
| 204 | excluído | tira a linha, fecha o modal e mostra o toast de sucesso que já existe |
| 404 | o vínculo já não existe | **conta como feito**: tira a linha e fecha o modal |
| 503 | o Keycloak não respondeu; nada foi apagado | "Não foi possível excluir agora. Tente de novo." **dentro do modal**, que fica aberto, com a linha na tabela |
| 403, 409 e outros | sem permissão; excluir a si mesmo | a mensagem genérica do modal (`comum:tabela.erroExcluir`), e a linha fica |

Onde o erro aparece segue `ui-e-responsividade.md` → Toasts: com o modal aberto, o erro
fica nele e **não sai toast**. O `ConfirmDeleteDialog` já espera a promessa do
`onConfirm`, mostra `errorMessage` quando ela é rejeitada e continua aberto. Basta passar
a ele a mensagem do erro e rejeitar.

O 404 conta como feito porque `contrato-front-back.md` trata 404 como "não existe", e
não como falha: manter a linha deixaria na tela uma pessoa que não existe mais.

## Arquivos que provavelmente mudam

- `src/features/links/linksApi.ts`: `deleteMember(organizationId: string, linkId: string)`,
  um `DELETE` que devolve `undefined` no 204.
- `src/features/links/linksApi.test.ts`: a rota.
- `src/features/users/usersApi.ts`: saem `removeMentee` e `resetMenteesMock`, o último
  resto do mock de mentorandos. O comentário do topo deixa de citar mentorandos.
- `src/features/users/usersSlice.ts`
  - `deleteMentee({ organizationId, linkId })` chama `linksApi.deleteMember` e devolve o
    `linkId`. No 404, devolve o `linkId` também, como sucesso. Nos outros erros,
    `rejectWithValue` com a chave de i18n: `'mentees:errors.deleteUnavailable'` no 503,
    e `'comum:tabela.erroExcluir'` no resto;
  - `fulfilled` tira a linha por `link_id`. `rejected` não mexe na lista.
- `src/features/users/MenteesSection.tsx`: o `onDelete` despacha o thunk com a
  organização da sessão e faz `unwrap()`. No sucesso, mostra o toast. No erro, guarda a
  chave num `useState` e relança, para o modal ficar aberto.
- `src/features/users/MenteesTable.tsx`: recebe a mensagem de erro por prop e a passa ao
  `ConfirmDeleteDialog` como `errorMessage`.
- `src/i18n/locales/{pt-BR,en,es}.ts`
  - `mentees.confirmDelete.description` diz que **o mentorando e os resultados dele são
    apagados para sempre**. Em pt-BR: "{{name}} e todos os resultados dele serão
    apagados para sempre. Não dá para desfazer.";
  - `mentees.errors.deleteUnavailable`, nos três idiomas.
- Testes: `usersSlice.test.ts`, `MenteesSection.test.tsx` e `MenteesTable.test.tsx`, com
  o `linksApi` simulado e `ApiError` de cada status.

## Molde

- `chaveDeErro` e o `login` em `src/features/authentication/authenticationSlice.ts`, para
  traduzir `ApiError` em chave de i18n com `rejectWithValue`.
- `src/features/authentication/PasswordResetView.test.tsx`, para o teste com
  `new ApiError('...', 503)`.

## Critérios de aceite

- [ ] `linksApi.deleteMember('org', 'link')` faz `DELETE /organizations/org/members/link`.
- [ ] Com 204, a linha sai da tabela, o modal fecha e o toast de sucesso aparece.
- [ ] Com 404, a linha sai da tabela e o modal fecha.
- [ ] Com 503, a mensagem de "tente de novo" aparece **dentro do modal**, que continua
      aberto, a linha fica e não sai toast.
- [ ] Com 403, a mensagem genérica aparece dentro do modal e a linha fica.
- [ ] O slice traduz o status em chave. Nem a seção nem a tabela importam `ApiError`.
- [ ] O modal diz, nos três idiomas, que a pessoa e os resultados dela são apagados para
      sempre.
- [ ] `removeMentee` e `resetMenteesMock` não existem mais em `src`.
- [ ] `npm run check` passa.

## Como testar

```bash
cd creed-frontend
npx vitest run src/features/users src/features/links
grep -rnE "removeMentee|resetMenteesMock|menteeRegistry" src   # não deve achar nada
npm run check
```

Ponta a ponta: back do `dev` local, login como a administradora.
- Excluir um mentorando tira a linha, e recarregar a página confirma que ele saiu.
- Com o Keycloak parado (`docker stop` do container do Keycloak local), excluir mostra
  o "tente de novo" e a linha fica.

## Premissas aplicáveis

- P-083: tratamento dos erros da exclusão.
- P-073: no 503 o back desfez tudo, e repetir a exclusão funciona.
- P-074: qualquer vínculo pode ser excluído. Esta tela só lista `mentoria`, então não
  chega a outro admin.

## Como ficou (diferenças do plano acima)

- **O texto do modal ficou neutro em gênero:** "{{name}} e todos os seus resultados
  serão apagados para sempre. Esta ação não pode ser desfeita."
- **Erro genérico:** a chave é a `comum:tabela.erroExcluir` que o modal já usava. A única
  chave nova é `mentees:errors.deleteUnavailable`.
- **A seção usa `deleteMentee.rejected.match(result)`**, e não `unwrap()` com
  `try/catch`. Assim o tipo da chave de erro chega certo. Depois de guardar a chave, a
  seção lança um `Error` para o modal continuar aberto.
- **O `ConfirmDeleteDialog` passou a aceitar `errorMessage` nulo** (`string | null`), o
  que equivale a não passar. A mudança é de uma linha e não afeta as outras tabelas.
