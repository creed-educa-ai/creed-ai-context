# Task 6 — Front sem tela de senha, com reset por e-mail e convite de membro

**Repo:** `creed-frontend`
**Depende de:** só do contrato abaixo. Começa já; o que não dá para provar sem o back está
em "Como testar".
**Branch sugerida:** `feat/86e35vhxm-front-sem-tela-de-senha`

## Objetivo

A plataforma deixa de ter tela de definir senha:

- `/primeiro-acesso` some;
- "Esqueci minha senha" pede só o e-mail e manda o pedido ao back;
- o formulário de adicionar membro passa a pedir o nome e ganha a chamada pronta para a
  página do painel usar.

## Contexto que você não tem como adivinhar

- **Quem define senha é a página do Keycloak**, aberta pelo link do e-mail (P-012). A
  `AlterarSenhaView` (PR #11, de 08/09) nunca chamou API, e perdeu a função no mesmo dia
  em que entrou. Ela sai, junto com o teste e o `alterarSenhaSchema` de
  `src/lib/validadores.ts`. Esse schema carrega a P-004 de 07/09; a regra dos 8
  caracteres agora mora no realm.
- **Contrato que esta task consome**, com prefixo `/api/v1`:

  | Método | Rota | Entrada | Saída | Erros que a tela trata |
  |---|---|---|---|---|
  | POST | `/authentication/password-reset` | `{ email }` | 204 | 422 (no campo), 503 ("tente de novo") |
  | POST | `/organizations/{organization_id}/members` | `{ name, email, role, type? }` | `UserResponse` · 201 | 403, 404, 409 (no campo e-mail), 422, 503 |

  `UserResponse = { id, name, email, status, role, link_id, organization_id, created_at }`.
- **O reset nunca revela se o e-mail tem acesso.** Depois de qualquer 204, a tela mostra a
  mesma mensagem: "Se este e-mail tiver acesso, enviamos um link para definir uma nova
  senha."
- **Camadas** (`conventions/camadas-do-front.md`): a View não chama HTTP. O reset é um
  thunk no `authenticationSlice.ts`, como o `login`, com status próprio, e o erro chega à
  tela como chave de i18n.
- **Nenhuma página usa o `AddMemberForm` ainda.** A página do painel da empresa é da
  CREED-50: é ela que liga o `onSubmit` à chamada e cria o slice e o thunk do convite.
  Aqui entram só a função de API, os tipos e o campo nome.
- **O i18n é tipado pelo pt-BR** (`en: typeof ptBR`). Chave que sai, sai dos três idiomas
  (`pt-BR.ts`, `en.ts`, `es.ts`) no mesmo commit, senão o `typecheck` quebra.
  - Saem as chaves `autenticacao.primeiroAcesso.*`.
  - Saem também os erros que só o `alterarSenhaSchema` usa. Confira com `grep` antes:
    `senhaCurta`, `confirmacaoObrigatoria`.

## Arquivos que provavelmente mudam

- `src/app/routes.tsx`: sai `/primeiro-acesso`, e `/recuperar-senha` passa a abrir a
  `RecuperarSenhaView`.
- `src/features/authentication/AlterarSenhaView.tsx` e `.test.tsx`: removidos.
- `src/features/authentication/RecuperarSenhaView.tsx` e `.test.tsx` (novos).
- `src/features/authentication/authenticationApi.ts`: `requestPasswordReset(email)`.
- `src/features/authentication/authenticationSlice.ts` e `.test.ts`: o thunk
  `requestPasswordReset`.
- `src/lib/validadores.ts`: sai o `alterarSenhaSchema`, entra o `recuperarSenhaSchema`.
- `src/features/organizations/organizationsApi.ts` (novo):
  `inviteMember(organizationId, body)`.
- `src/features/organizations/addMemberSchema.ts` e `AddMemberForm.tsx`, com os testes: o
  campo `name`.
- `src/types/api.ts`: `PasswordResetRequest`, `MemberInvite` e `UserResponse`.
- `src/i18n/locales/pt-BR.ts`, `en.ts` e `es.ts`.

## Molde

- Tela de autenticação com `AuthLayout`, formulário e erro vindo do slice:
  `src/features/authentication/LoginView.tsx`.
- Thunk e chave de erro: `login` e `chaveDeErro`, em `authenticationSlice.ts`.
- Funções puras sobre o `apiClient`: `authenticationApi.ts`.
- Campo novo no formulário de membro: o próprio `AddMemberForm.tsx` (mesmo `Field` e
  `FieldError`).

## Critérios de aceite

- [ ] `/primeiro-acesso` não abre tela de senha nenhuma, e não sobra import, teste nem
      chave de i18n da `AlterarSenhaView`.
- [ ] "Esqueci minha senha", no login, leva a `/recuperar-senha`:
  - [ ] a tela pede só o e-mail, e e-mail inválido mostra erro no campo;
  - [ ] o envio chama `POST /authentication/password-reset`;
  - [ ] qualquer 204 mostra a mesma mensagem, e 503 mostra "tente de novo".
- [ ] O `AddMemberForm` pede nome (2 a 200 caracteres), e-mail e papel, e o `onSubmit`
      recebe os três.
- [ ] `organizationsApi.inviteMember('<org>', {...})` faz
      `POST /organizations/<org>/members` com o corpo do contrato (teste com o `apiClient`
      falso).
- [ ] Os textos existem em pt-BR, en e es.
- [ ] `npm run check` verde.

## Como testar

```bash
cd creed-frontend
npm run check
npm run dev    # http://localhost:5173/recuperar-senha e http://localhost:5173/primeiro-acesso
```

Sem o back das tasks 3 e 4, a tela de reset dá erro de rede e mostra "tente de novo". Quem
prova a tela é o teste com o `apiClient` falso. Com o back de pé, o e-mail do reset chega
ao Mailpit.

- **Caso feliz:** o e-mail válido mostra a mensagem neutra.
- **Caso de borda:** o e-mail inválido mostra erro no campo, sem chamar a API.

## Premissas aplicáveis

- P-012 — a plataforma não tem tela de senha; quem define senha é a página do Keycloak.
- P-046 — o convite pede o nome.
- P-045 — o formulário oferece `respondente` e `gestor`, como o `MEMBER_ROLES` já faz.
- P-004 de 07/09 — sai do front; a regra vai para o realm (task 1).
