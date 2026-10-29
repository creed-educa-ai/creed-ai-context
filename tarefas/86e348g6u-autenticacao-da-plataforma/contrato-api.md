# CREED-23 — contrato da API de autenticação

> Fecha a seção **Contrato** da [`spec.md`](spec.md), que estava em forma de tabela
> resumida com dois pontos marcados para decidir. Este documento é o que o front
> programa contra **antes de o backend existir**, e o que o backend implementa nas
> entregas 3 e 4.
>
> **Status: parcialmente implementado (revisto em 2026-10-29, com a CREED-23.8).** Este
> documento continua descrevendo o **alvo**. O que já existe em código diverge dele em pontos concretos, e pela regra de
> [`conventions/contrato-front-back.md`](../../conventions/contrato-front-back.md)
> **o backend ganha** — o quadro "Estado real" abaixo é a fonte para quem está programando
> hoje. O resto da tabela permanece como o destino acordado, não como dívida.
>
> Payloads literais, com exemplos nomeados: [`mock/openapi.yaml`](mock/openapi.yaml).
> ⚠️ O mock é de 2026-09 e não acompanhou: ainda tem `vinculo_id` e `initial_password`, e
> não tem as rotas da CREED-23.8. Para o contrato de hoje, vale o OpenAPI do back (`/docs`).
> Como disparar requisição de verdade contra eles: [`mock/README.md`](mock/README.md).

## Mapa

Prefixo `/api/v1`. Identificadores em inglês por
[ADR-0005](../../decisoes/adrs/0005-idioma-do-codigo.md).

| Método | Rota | Auth | Papel | Entrada | Saída |
|---|---|---|---|---|---|
| POST | `/authentication/login` | — | — | `LoginRequest` | `Session` · 200 |
| POST | `/authentication/renew` | — | — | `RenewRequest` | `Session` · 200 |
| POST | `/authentication/logout` | — | — | `RenewRequest` | 204 |
| GET | `/authentication/session` | Bearer | qualquer | — | `UserSession` · 200 |
| POST | `/authentication/password-reset` | — | — | `PasswordResetRequest` | 204 |
| POST | `/users` | Bearer | `admin` | `UserCreate` | `User` · 201 |
| GET | `/users` | Bearer | `admin` | query | `Page<User>` · 200 |
| PATCH | `/users/{user_id}` | Bearer | `admin` | `UserUpdate` | `User` · 200 |
| DELETE | `/users/{user_id}` | Bearer | `admin` | — | 204 |
| POST | `/users/{user_id}/invitation` | Bearer | `admin`; `gestor` só na própria organização | — | 204 |
| POST | `/organizations/{organization_id}/members` | Bearer | `admin`; `gestor` só na própria organização (P-045) | `MemberInvite` | `User` · 201 |

`GET /users` aceita `organization_id`, `role`, `page` e `page_size` na query.

As quatro últimas linhas e o `password-reset` são da
[CREED-23.8](../86e35vhxm-convite-de-primeiro-acesso/spec.md) (convite por e-mail). A
rota de membros mora no domínio `users`, num segundo router, mas o caminho começa por
`/organizations`.

## Estado real — 2026-10-29

Conferido contra o OpenAPI do back com as tasks 1 a 5 da CREED-23.8
([creed-backend#49](https://github.com/creed-educa-ai/creed-backend/pull/49) a
[#53](https://github.com/creed-educa-ai/creed-backend/pull/53), empilhados e ainda não
mergeados na `dev`). O que está marcado "23.8" só vale na `dev` depois do merge deles.

| Alvo acima | O que existe | Nota |
|---|---|---|
| `POST /authentication/login` · `renew` | existem | 503 com o Keycloak fora do ar, não mais 401 (23.8). O schema do `renew` se chama `RefreshRequest`, com o mesmo `{refresh_token}` |
| `GET /authentication/session` | existe | |
| `POST /authentication/logout` | **não existe** | sem endpoint, "sair" só limpa a sessão no front e o refresh token segue válido até expirar |
| `POST /authentication/password-reset` | existe (23.8) | 204 · 422 · 503 |
| `POST /users` | existe, com guarda de `admin` | `UserCreate` sem `keycloak_id` (23.8) — ver abaixo |
| `GET /users` · `PATCH /users/{user_id}` | **não existem** | |
| `DELETE /users/{user_id}` | existe, com guarda de `admin` | apaga também no Keycloak e ganha 503 (23.8) |
| `POST /users/{user_id}/invitation` | existe (23.8) | 204 · 401 · 403 · 404 · 422 · 503 |
| `POST /organizations/{organization_id}/members` | existe (23.8) | 201 · 401 · 403 · 404 · 409 · 422 · 503 |

**`UserCreate` é `{name, email, link_id}`.** Até a 23.8 era `{name, email, keycloak_id,
link_id}`: quem cadastrava criava o usuário à mão no console do Keycloak e passava o id.
Agora o back cria o usuário no Keycloak, **sem senha**, dá a ele o papel do vínculo, grava
no banco e manda o e-mail de convite. O `initial_password` deste alvo nunca existiu em
código: com o convite, ninguém nasce com senha conhecida (P-012).

**O e-mail é gravado e comparado em minúsculas**, como o Keycloak guarda. `Pessoa@X.com`
volta como `pessoa@x.com` no 201, e o 409 de e-mail repetido não distingue maiúsculas. O
reset também procura sem distinguir. Usuário antigo gravado com maiúscula continua sem
entrar: o login acha o usuário pelo e-mail do token, e a busca pelo `sub` ([C28]) é tarefa
própria.

**O que pode sobrar no Keycloak.** Criar acesso é tudo ou nada **no banco**: se o
Keycloak ou o SMTP falham, o back apaga o usuário que criou lá, desfaz a transação e
responde 503. Duas falhas escapam disso: o Keycloak cair antes de a limpeza terminar, e o
commit falhar depois de o e-mail sair (resposta 500). Nas duas, o usuário sobra no
Keycloak, sem linha no banco, e a nova tentativa com o mesmo e-mail responde **409** até
alguém apagá-lo pelo console. No `DELETE`, o banco sai primeiro: um 503 deixa o usuário no
banco, e repetir a remoção resolve.


## Os payloads

> **`link_id` é o `vinculo_id` do diagrama.** No código, vínculo é `Link` desde
> 2026-09-29 ([ADR-0005](../../decisoes/adrs/0005-idioma-do-codigo.md), pendência de
> vocabulário). O front ainda tipa `vinculo_id` em `src/types/api.ts` e precisa acompanhar.

```
LoginRequest             { email, password }
RenewRequest             { refresh_token }

Session                  { access_token, refresh_token, expires_in, user: UserSession }
UserSession              { id, email, role, link_id, organization_id, organization_name }

UserCreate               { name, email, link_id }
MemberInvite             { name, email, role, type = "emprego" }
PasswordResetRequest     { email }
UserUpdate               { status? }
User                     { id, name, email, status, role, link_id, organization_id, created_at }
Page<T>                  { items, total, page, page_size }
```

`name` tem de 2 a 200 caracteres, sem caractere de controle. No `MemberInvite`, `role` é
`admin`, `gestor` ou `respondente` (P-006), e `type` é `emprego`, `mentoria`, `academico`
ou `pessoal` (P-047). O `name` vai para o participante e para o usuário; o Keycloak não
recebe nome (P-046).

Três observações que evitam bug de transcrição:

- **`role` e `organization_id` do `User` são derivados** — vêm do vínculo (`Link`), não de
  coluna da tabela `User`. Existem na leitura e **não** existem no `UserCreate`, do mesmo
  jeito que `idade` no molde de `respondentes`.
- **Não há `role` no `UserCreate`.** O papel é do vínculo, e o vínculo já existe quando o
  acesso é criado (P-008). Mandar `role` no POST é sintoma de ter entendido o modelo ao
  contrário. O `MemberInvite` tem `role` porque **cria** o vínculo, na mesma chamada.
- **Não há `token_type`.** O front sempre monta `Authorization: Bearer <token>`; um campo
  que só pode ter um valor é campo que alguém vai ramificar por engano.

## Os fluxos que o front precisa desenhar

### 1. Login — e não há um segundo caminho

> 🟡 **Premissa P-012** — o primeiro acesso é por e-mail com link para o realm do
> Keycloak, onde a pessoa define a própria senha. Confirmar na próxima reunião. *O interim
> (senha definitiva passada por fora) acabou com a CREED-23.8.*

```
POST /authentication/login  {email, password}
  200 -> guarda a Session, entra
  401 -> "E-mail ou senha inválidos"
  503 -> "serviço indisponível, tente de novo" — a senha pode estar certa
```

O 401 é **o mesmo** para e-mail inexistente, senha errada, acesso desativado e pessoa que
ainda não abriu o convite. O front não tem como distinguir, e é de propósito (critério de
aceite da spec).

**Não existe tela de definir senha nesta plataforma.** Quem define senha é a página do
realm do Keycloak, alcançada pelo link do e-mail de convite ou de "esqueci minha senha". O
front tem a tela de login e a de pedir o link (`/reset-password`), que só manda o e-mail.

Isso depende de o usuário nascer **sem ação obrigatória**, e vale saber por quê. O back
cria o usuário sem credencial e com `requiredActions: []`; o `UPDATE_PASSWORD` vai só
dentro do link do e-mail (`execute-actions-email`). Se ele fosse ação obrigatória do
usuário, o Direct Access Grant (decisão D1) passaria a **recusar o login** com
`invalid_grant: "Account is not fully set up"` — e o login de quem já definiu a senha
morreria numa mensagem de credencial inválida que não é verdade.

> ⚠️ **A mesma armadilha vem pelo realm.** Isso só resolve se o realm não tiver *default
> required actions* ligadas (`VERIFY_EMAIL`, "Update Password" como ação padrão). Se
> tiver, o Keycloak anexa a ação a todo usuário novo e o sintoma é idêntico, sem ninguém
> ter tocado no provisionamento. O realm é arquivo versionado (entrega 2) —
> isto é item de review, não bug a descobrir.

### 2. Renovação — o que o `apiClient` faz sozinho

```
qualquer rota -> 401
  POST /authentication/renew {refresh_token}
    200 -> repete a requisição original, uma vez
    401 -> limpa creed.session, vai para /login
```

Com **renovação em voo única** (decisão D6): cinco requisições que tomam 401 juntas
disparam **um** refresh, não cinco.

### 3. Convite e "esqueci minha senha" (CREED-23.8)

```
POST /organizations/{organization_id}/members  {name, email, role, type?}
  201 -> acesso criado e convite enviado (os dois, ou nenhum)
  409 -> e-mail já tem acesso: erro no campo e-mail
  503 -> nada foi criado no banco: "tente de novo"

POST /authentication/password-reset  {email}
  204 -> sempre a mesma mensagem: "se este e-mail tiver acesso, enviamos um link"
  422 -> e-mail inválido, no campo
  503 -> "tente de novo"
```

O reset responde **204 para qualquer e-mail válido**, com ou sem acesso, e só quem tem
acesso ativo recebe o e-mail: a resposta não revela quem tem cadastro. ⚠️ O **tempo** de
resposta revela (mediana de 278 ms com acesso e 6 ms sem, medida no local). O risco foi
aceito em 2026-10-29 e está nos Riscos da spec da 23.8.

O reenvio (`POST /users/{user_id}/invitation`) manda um link novo, e para quem já tem
senha o link serve para trocá-la. O e-mail sai sempre para o endereço guardado no
Keycloak, nunca para um digitado.

## Códigos de status

| Código | Quando | O que o front faz |
|---|---|---|
| 401 | sem token · token inválido/expirado · credencial errada · `status = inactive` · claim divergente do banco | renova **uma vez**; falhou, limpa a sessão e vai para `/login` |
| 403 | autenticado, mas o papel não alcança a rota · no convite de membro: `organization_id` de outra organização, ou `gestor` convidando `admin` | "acesso negado" — **não desloga** |
| 404 | `link_id` ou `user_id` que não existe, **ou é de outra organização** · organização que não existe, no convite de membro | mensagem de não encontrado |
| 409 | e-mail já tem acesso, aqui ou no Keycloak, sem distinguir maiúsculas · vínculo já tem acesso | erro de formulário no cadastro |
| 422 | payload não bate com o schema | ver abaixo — em desenvolvimento, quase sempre é bug do front |
| 503 | Keycloak ou SMTP fora do ar: login, renovação, cadastro, convite, reenvio, reset e remoção | "tente novamente" — **nunca** "senha inválida", e **não** limpa a sessão |

A política de senha do realm (8 caracteres, P-004 de 07/09) não passa por aqui: quem a
aplica é a página do Keycloak, quando a pessoa define a senha.

Nas rotas protegidas, a guarda ainda responde **401**, não 503, quando não consegue ler as
chaves do Keycloak (`JwksUnavailableError`). Fica fora da 23.8 ("Não entra" da spec).

A distinção 401 × 403 é o que impede o bug clássico: um 403 tratado como 401 desloga o
usuário toda vez que ele clica onde não pode.

O 503 é o segundo par que se confunde: sem ele, autenticação indisponível vira "sua senha
está errada", o usuário troca a senha que estava certa, e o suporte persegue um fantasma.

## O corpo de erro tem duas formas

Isso não é escolha deste contrato — é o que o FastAPI produz, e o molde de `respondentes`
já produz hoje:

```jsonc
// HTTPException(status, "mensagem")  -> detail é STRING
{ "detail": "E-mail ou senha inválidos" }

// validação de payload do próprio FastAPI -> detail é LISTA
{ "detail": [ { "type": "missing", "loc": ["body","password"], "msg": "Field required" } ] }
```

**Consequência para o front, e é um bug esperando:** o `apiClient.ts` de hoje faz
`response.text()` e joga o resultado cru em `ApiError.message`. Uma tela que mostre
`error.message` vai exibir `{"detail":"E-mail ou senha inválidos"}`, com chaves e aspas.
A entrega 5 reescreve o `apiClient` de qualquer forma — é lá que ele passa a fazer
`JSON.parse` e extrair `detail`, tratando lista e string.

## Para o front: pronto para colar

### `src/types/api.ts`

```ts
// --- CREED-23 · autenticação --------------------------------------------
// Contrato PROPOSTO, backend ainda não existe. Fonte:
// creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/contrato-api.md
// Premissas: P-006 (lista de papéis), P-012 (primeiro acesso), P-010 (sessão).
// Quando o backend chegar e divergir, o backend ganha.

export type Role = 'admin' | 'gestor' | 'respondente';
export type RecordStatus = 'active' | 'inactive';

export interface UserSession {
  id: string;
  email: string;
  role: Role;
  link_id: string;
  organization_id: string;
  organization_name: string;
}

export interface Session {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  user: UserSession;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface User {
  id: string;
  name: string;
  email: string;
  status: RecordStatus;
  role: Role;
  link_id: string;
  organization_id: string;
  created_at: string;
}

// Sem senha: o back cria o usuário no Keycloak e o convite leva a pessoa à
// página do realm (P-012, CREED-23.8).
export interface UserCreate {
  name: string;
  email: string;
  link_id: string;
}

export type LinkType = 'emprego' | 'mentoria' | 'academico' | 'pessoal';

export interface MemberInvite {
  name: string;
  email: string;
  role: Role;
  type?: LinkType; // sem type, o back usa 'emprego' (P-047)
}

export interface PasswordResetRequest {
  email: string;
}

export interface UserUpdate {
  status?: RecordStatus;
}

// Envelope de paginação do backend (app/shared/pagination.py).
// Substitui ListaPaginada<T> — ver "O que este contrato decidiu" abaixo.
export interface Page<T> {
  items: T[];
  total: number;
  page: number;
  page_size: number;
}
```

### `src/features/authentication/authenticationApi.ts`

Funções puras sobre o `apiClient`, como manda
[`conventions/contrato-front-back.md`](../../conventions/contrato-front-back.md): sem
Redux, sem React, sem `try/catch` — quem trata erro é o slice.

```ts
export const authenticationApi = {
  login: (dados: LoginRequest) => apiClient.post<Session>('/authentication/login', dados),
  renew: (refresh_token: string) =>
    apiClient.post<Session>('/authentication/renew', { refresh_token }),
  logout: (refresh_token: string) =>
    apiClient.post<undefined>('/authentication/logout', { refresh_token }),
  session: () => apiClient.get<UserSession>('/authentication/session'),
  requestPasswordReset: (dados: PasswordResetRequest) =>
    apiClient.post<undefined>('/authentication/password-reset', dados),
};
```

O convite de membro mora em `src/features/organizations/organizationsApi.ts`
(`inviteMember`), porque quem o usa é o painel da organização.

### `src/features/users/usersApi.ts`

```ts
export const usersApi = {
  listar: (params: { role?: Role; page?: number; page_size?: number }) =>
    apiClient.get<Page<User>>(`/users?${new URLSearchParams(params as never)}`),
  criar: (dados: UserCreate) => apiClient.post<User>('/users', dados),
  atualizar: (id: string, dados: UserUpdate) => apiClient.patch<User>(`/users/${id}`, dados),
};
```

## O que este contrato decidiu — e por quê

A spec deixou dois pontos marcados para decisão e não previu quatro casos. Está tudo aqui
para não ser descoberto no review.

| # | Decisão | Quem decidiu | Efeito |
|---|---|---|---|
| 1 | **`Page[T]` em inglês** — `app/shared/paginacao.py` vira `pagination.py`, campos `items/total/page/page_size`, query `page`/`page_size` | você | 1 arquivo + 2 imports no back, 1 interface + 2 referências no front, **hoje**. Depois da entrega 4, `users` é o molde e todo domínio novo copia o envelope — o mesmo rename passa a custar N domínios × 2 repos. Fecha o ⚠️ da spec |
| 2 | **Primeiro acesso não passa pela plataforma** — provisionamento com `temporary: false`, sem ação obrigatória, sem 409 e sem tela de senha | você | é o desenho de destino (P-012): o convite por e-mail leva à página do realm do Keycloak. Como lá também não há tela nossa, tirá-la agora não é dívida — é remover uma tela que o destino não tem. **Substituiu** a decisão anterior (409 + `POST /authentication/password`), que caiu junto com P-007 e P-011. *Desde a CREED-23.8 o usuário nasce sem credencial nenhuma, e o `temporary: false` deixou de existir* |
| 3 | **503 quando o Keycloak está fora** | agente | a spec só mapeava 401/403/409. Sem o 503, indisponibilidade vira "senha inválida" e o usuário troca a senha que estava certa |
| 4 | **404 para `link_id`/`user_id` de outra organização** — mesma resposta de "não existe" | agente | dizer "existe, mas não é sua" vaza cadastro de outra organização. Segue o mapeamento `NotFoundError → 404` do molde |
| 5 | **`logout` idempotente** — refresh já inválido também devolve 204 | agente | o usuário está saindo; travá-lo numa tela que ele quer abandonar é o pior desfecho para um erro que não muda nada |
| 6 | **`GET /users` exige `admin`, e o recorte é sempre a organização do vínculo de quem chama** — `organization_id` de outra organização responde 403 | agente | a spec diz que cadastro de usuário é do `admin`, mas não fixou o papel da listagem. O recorte por vínculo é o mesmo de [C2]; esconder no front não é autorização |

Decisões 3 a 6 foram do agente porque nenhuma é bifurcação de design — são consequências
diretas do molde e do modelo. Se alguma incomodar, o custo de mudar é uma linha no
`openapi.yaml` e uma no router.

## Buracos conhecidos

Coisas que este contrato **não** resolve e que alguém vai esbarrar:

- **Não há endpoint para trocar o papel.** O critério de aceite da spec exige que "mudar
  `Vinculo.role` reflita na realm role", mas `role` mora no vínculo (`Link`), e não há rota para
  escrever lá. Dois caminhos, nenhum escolhido: uma rota de escrita no domínio `links` (que a
  CREED-32 criou só com o `POST`) ou `role` dentro do `UserUpdate` (o domínio `users`
  escrevendo em `Link`).
  **Precisa de tarefa própria antes da entrega 3 fechar** — o espelhamento de papel (D4) é
  metade do critério de aceite e não tem por onde ser exercitado.
- **Não há como listar vínculos sem acesso.** A tela de cadastro precisa escolher um
  `link_id`, e sem essa rota o admin digita UUID na mão. Telas de gestão estão fora do
  épico, mas é isto que trava a primeira delas.
- **O mock não guarda estado** (ver [`mock/README.md`](mock/README.md)): o token que ele
  devolve não é aceito por ele depois. O fluxo login → usar token → renovar só fecha de
  verdade contra o backend da entrega 4.

## Premissas

Usadas: **P-006** (papéis `admin`/`gestor`/`respondente` — ainda aberta e em conflito com
P-003), **P-008** (sem autocadastro, ajustada pela P-045), **P-010** (sessão de 15 min /
8 h), **[P-012](../../decisoes/premissas.md)** (primeiro acesso por e-mail com link para o
realm; o interim da senha definitiva acabou com a CREED-23.8).

Da CREED-23.8: **P-045** (quem convida quem), **P-046** (o nome vai para participante e
usuário), **P-047** (`type` padrão `emprego`), **P-049** (link de 72 h), **P-057**
(organização inativa recebe convite) e **P-058** (o reenvio não olha papel nem status).

A **P-009** (sem recuperação por e-mail) foi **refutada** em 2026-10-29: o
`POST /authentication/password-reset` existe.

### O que caiu, e por quê — leia antes de comparar com a spec

A spec e a descrição do épico no ClickUp ainda descrevem **senha temporária com troca
obrigatória no primeiro login** (P-007), e uma versão anterior deste documento propôs um
409 `password_change_required` mais um `POST /authentication/password` (P-011). **As duas
caíram em 2026-09-08**, por uma decisão de time que já existia e não estava registrada: o
convite é por e-mail com link para o realm do Keycloak, e é lá que a senha é definida.

| Premissa | Status | Onde ler o desfecho |
|---|---|---|
| P-007 | ❌ refutada | [`premissas.md`](../../decisoes/premissas.md) → Fechadas |
| P-011 | ❌ refutada | idem — refutada no mesmo dia em que nasceu |
| P-012 | 🟡 aberta | substitui as duas; o interim acabou com a CREED-23.8 |

Premissa refutada não é erro do time: é o mecanismo funcionando. O que ele pegou aqui foi
uma decisão tomada e não escrita — e é exatamente para isso que o ledger existe.

**Consequência fora deste documento:** a
[PR #11 do `creed-frontend`](https://github.com/creed-educa-ai/creed-frontend/pull/11)
implementa a tela de troca de senha do primeiro acesso. Neste desenho ela perde a função.
*Saiu em 2026-10-29, no
[creed-frontend#52](https://github.com/creed-educa-ai/creed-frontend/pull/52) (CREED-23.8):
a rota `/first-access` deixou de existir, e `/reset-password` só pede o e-mail.*
