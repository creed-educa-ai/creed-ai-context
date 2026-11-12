# Tasks — CREED-699 · M-4 · Tabela de mentorandos e "Adicionar mentorando" ligados ao back

Spec: [`spec.md`](spec.md)

Branch: `feat/699-mentorandos-ligados-ao-back`, saindo do `dev` do `creed-frontend`.

## Progresso

- [x] 1 — Tabela de mentorandos lendo a M-2 · `creed-frontend`
- [x] 2 — Excluir mentorando pela M-3 · `creed-frontend`
- [x] 3 — "Adicionar mentorando" com o convite · `creed-frontend`

Marque aqui ao concluir cada task (`workflows/tasks-to-code.md`).

## Por que três, e nesta ordem

- **1 primeiro:** é a maior e é a que tira o tipo provisório `Mentee`, de que as outras
  duas dependem.
- **2 separada da 1:** a exclusão tem tratamento de erro próprio (P-083). Até ela entrar,
  o `removeMentee` do mock segura a tabela, e é a 2 que termina de tirar o mock.
- **3 por último:** é a única que depende de algo fora do `dev` do back, o convite do
  PR #51. Ela fica pronta contra o contrato, com teste de unidade, e a verificação de
  ponta a ponta espera o merge do #51. As tasks 1 e 2 podem virar PR sem ele.

## Onde mora cada coisa

| O quê | Onde | Por quê |
|---|---|---|
| Tipos da resposta da M-2 | `src/types/api.ts`, seção `links` | o schema é `app/domains/links/schemas.py` |
| Chamadas de listar e excluir | `src/features/links/linksApi.ts` | as rotas são do domínio `links` no back (`router_members.py`) |
| Chamada de convidar | `src/features/users/usersApi.ts` (já existe) | a rota do #51 é do domínio `users` |
| Estado da tabela e thunks | `src/features/users/usersSlice.ts` (`mentees`) | a seção de mentorandos já mora na feature `users` |

## Regras do time que mais pesam aqui

- **Erro:** o slice traduz o `ApiError` em chave de i18n (`rejectWithValue`). A View só
  traduz e escolhe o lugar (`camadas-do-front.md`).
- **Onde o erro aparece:** com modal aberto, no modal, sem toast (`ui-e-responsividade.md`
  → Toasts). Em formulário, 409 de e-mail no campo e o resto como mensagem do
  formulário (`formularios.md`, regra 7). Toast só no sucesso, depois do `unwrap()`.
- **404 é "não existe"**, não falha (`contrato-front-back.md` → Erro).
- **Um thunk, uma responsabilidade:** o convite não recarrega a lista. Quem recarrega é
  a tela, depois do `unwrap()`.

## Harness, na mesma entrega

Ao fechar a task 3 (ou a 2, se a 3 esperar o #51), atualizar no `creed-ai-context`:

- `conventions/contrato-front-back.md`, tabela "Onde a tela diverge do back": as linhas
  "Mentorandos" e "Adicionar mentorando" passam a "Resolvido em <data>", com o que
  ficou: `MemberListItem` da M-2, `has_answered` do período, convite com nome e a
  organização da sessão;
- `catalogo.md`, linha da feature `users`: a lista de mentorandos deixa de ser mock.

## Molde

| Para quê | Copiar de |
|---|---|
| Chamada ao back num `<feature>Api.ts` | `linksApi.createLink` em `src/features/links/linksApi.ts` |
| Thunk que traduz `ApiError` em chave de i18n | `chaveDeErro` e o `login` em `src/features/authentication/authenticationSlice.ts` |
| Teste de erro com `ApiError` | `src/features/authentication/PasswordResetView.test.tsx` |
| Modal que espera a promessa e continua aberto se ela falhar | `ConfirmDeleteDialog` em `src/components/table/confirmDeleteDialog.tsx` (já usado pela `MenteesTable`) |
