# Task 6 — Cadastro público ligado ao back

**Repo:** `creed-frontend`
**Subtarefa:** [694 · Integração (E4-E5)](https://app.clickup.com/t/1dfej6fvrvu)
**Branch:** `feat/694-integracao-empresas`, saída da `dev`
**Depende de:** task 2 na `dev`, para o teste no navegador. O código e os testes andam
antes, contra o contrato abaixo, com `stubFetch`.

## Objetivo

A tela `/sign-up` grava a empresa de verdade, e "aguarde confirmação" diz como o acesso
vai chegar.

## Contexto

Hoje o `registerCompany` do `organizationsApi.ts` é mock: espera 1,5 s e põe a empresa
numa lista em memória. A rota real é pública e cria a empresa **pendente**, à espera da
administradora. Quando ela aprova, quem cadastrou recebe no e-mail informado um link para
definir a senha (convite, CREED-23.8). Não há botão de reenviar: quem perdeu o e-mail,
ou deixou o link vencer (72 h), usa **"Esqueci minha senha"** na tela de login, que manda
o mesmo tipo de link. O texto de "aguarde confirmação" hoje diz "tente realizar o login
novamente", o que não funciona: a pessoa ainda não tem senha.

A tabela da administradora (task 7) ainda usa o mock; esta task **não** apaga os tipos
`Company` e `CompanyRegistration`, que o modal e a tabela ainda usam.

## Contrato (visto do front)

`POST /organizations/sign-up`, sem token, corpo `OrganizationSignUp`:
`{ name, document, email, contact_name, phone }`.

| Status | O que a tela faz |
|---|---|
| 201 `OrganizationResponse` | vai para `/awaiting-confirmation` |
| 409 | mensagem no campo "Documento": já existe cadastro com este documento |
| 422 | aviso abaixo do botão (o zod já barra o que o back barraria) |
| 503 / rede | aviso abaixo do botão: tente de novo |

## Arquivos que provavelmente mudam

- `src/types/api.ts`
  - `OrganizationStatus = 'pending' | 'active' | 'inactive'`.
  - `OrganizationDocument { type: string; value: string }`.
  - `OrganizationResponse`: `status: OrganizationStatus`; `email`, `contact_name`,
    `phone: string | null`; `document: OrganizationDocument`.
  - `OrganizationSignUp { name; document; email; contact_name; phone }`.
- `src/features/organizations/organizationsApi.ts`
  - `signUp(body: OrganizationSignUp)` →
    `apiClient.post<OrganizationResponse>('/organizations/sign-up', body)`. Comentário:
    rota pública, prefixo em inglês (não `/organizacoes`).
  - Saem `registerCompany` e `SIGN_UP_DELAY_MS`.
- `src/features/organizations/organizationsSlice.ts`
  - `signUpOrganization` (troca o `registerCompany`): `createAsyncThunk` com
    `rejectValue` = chave de i18n. 409 → `'cadastro:erros.documentoJaCadastrado'`;
    qualquer outro → `'cadastro:erros.envioIndisponivel'`.
  - Sai o `registerCompany.fulfilled` que punha a empresa na lista: quem cadastra não
    tem lista.
- `src/lib/validators.ts`, `signUpSchema`
  - `email`: `z.email(...)`.
  - `documento`: depois de tirar o que não é letra nem número, 11 ou 14 dígitos
    (`cadastro:erros.documentoInvalido`). Mesma regra do back (P-076).
  - Tamanhos máximos do back: 200 (`nomeEmpresa`, `nomeCompleto`), 30 (`telefone`).
  - `nomeCompleto` com no mínimo 2 caracteres, como o `contact_name` do back
    (🟡 Premissa P-082).
- `src/features/organizations/SignUpView.tsx`: monta o `OrganizationSignUp` com os
  nomes do back. No 409, `setError('documento', ...)`. Nos outros erros, um
  `<p role="alert">` abaixo do botão, como o `PasswordResetView`.
- `src/i18n/locales/pt-BR.ts`, `en.ts`, `es.ts`
  - `cadastro.erros`: `documentoInvalido`, `documentoJaCadastrado`,
    `envioIndisponivel`.
  - `aguardeConfirmacao.mensagem`, texto novo. Em pt-BR: "Recebemos o cadastro da sua
    empresa. Quando ele for aprovado, você vai receber no e-mail informado um link para
    definir sua senha. Se o e-mail não chegar, use "Esqueci minha senha" na tela de
    login."
- Testes: `SignUpView.test.tsx`, `organizationsApi.test.ts`,
  `AwaitingConfirmationView.test.tsx`.

## Molde

- `PasswordResetView.tsx` e `requestPasswordReset` em
  `src/features/authentication/`: erro do campo × erro do envio, e a chave de i18n no
  `rejectValue`.
- `src/test/stubFetch.ts`: o teste passa pelo `apiClient` de verdade e confere URL,
  método e corpo.

## Critérios de aceite

- [ ] O envio sai como `POST /api/v1/organizations/sign-up`, com
      `{name, document, email, contact_name, phone}` (o teste lê o corpo do
      `stubFetch`).
- [ ] 201: a tela vai para `/awaiting-confirmation`.
- [ ] 409: a mensagem aparece no campo "Documento", e a tela não sai do lugar.
- [ ] 503: aviso abaixo do botão, e o formulário continua preenchido.
- [ ] Documento `"123"` e e-mail `"abc"` são barrados pelo zod, **sem chamada** ao back.
- [ ] "Aguarde confirmação" cita o e-mail e o "Esqueci minha senha", nos três idiomas.
- [ ] `npm run check` passa.

## Como testar

```bash
cd creed-frontend
npx vitest run src/features/organizations
npm run check
```

No navegador, com o back da task 2 de pé e `npm run dev`: abra
`http://localhost:5173/sign-up`, cadastre, confira a tela de "aguarde" e a empresa na
listagem do admin (`GET /organizacoes`). Cadastre o mesmo CNPJ de novo e veja o erro no
campo. Repita em 375 px de largura.

**O que os testes não provam:** que o back aceita exatamente o que o zod aceita. Se um
documento passar no zod e cair no 422, o aviso aparece, mas no lugar errado.

## Premissas aplicáveis

- P-076 — 11 ou 14 dígitos, mesma regra do back.
- P-077 — o cadastro aceita um e-mail que já tem acesso (quem barra é a aprovação).
