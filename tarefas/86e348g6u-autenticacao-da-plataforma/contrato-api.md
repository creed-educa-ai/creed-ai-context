# CREED-23 — contrato da API de autenticação

> Fecha a seção **Contrato** da [`spec.md`](spec.md), que estava em forma de tabela
> resumida com dois pontos marcados para decidir. Este documento é o que o front
> programa contra **antes de o backend existir**, e o que o backend implementa nas
> entregas 3 e 4.
>
> **Status: proposta.** Nenhuma linha disto existe em código. Quando o backend chegar e
> divergir, **o backend ganha** e o front se ajusta
> ([`conventions/contrato-front-back.md`](../../conventions/contrato-front-back.md)). É
> exatamente para essa conversa durar cinco minutos que este arquivo existe.
>
> Payloads literais, com exemplos nomeados: [`mock/openapi.yaml`](mock/openapi.yaml).
> Como disparar requisição de verdade contra eles: [`mock/README.md`](mock/README.md).

## Mapa

Prefixo `/api/v1`. Identificadores em inglês por
[ADR-0005](../../decisoes/adrs/0005-idioma-do-codigo.md).

| Método | Rota | Auth | Papel | Entrada | Saída |
|---|---|---|---|---|---|
| POST | `/authentication/login` | — | — | `LoginRequest` | `Session` · 200 |
| POST | `/authentication/password` | — | — | `PasswordChangeRequest` | 204 |
| POST | `/authentication/renew` | — | — | `RenewRequest` | `Session` · 200 |
| POST | `/authentication/logout` | — | — | `RenewRequest` | 204 |
| GET | `/authentication/session` | Bearer | qualquer | — | `UserSession` · 200 |
| POST | `/users` | Bearer | `admin` | `UserCreate` | `User` · 201 |
| GET | `/users` | Bearer | `admin` | query | `Page<User>` · 200 |
| PATCH | `/users/{user_id}` | Bearer | `admin` | `UserUpdate` | `User` · 200 |

`GET /users` aceita `organization_id`, `role`, `page` e `page_size` na query.

## Os payloads

```
LoginRequest             { email, password }
PasswordChangeRequest    { email, current_password, new_password }
RenewRequest             { refresh_token }

Session                  { access_token, refresh_token, expires_in, user: UserSession }
UserSession              { id, email, role, vinculo_id, organization_id, organization_name }

UserCreate               { vinculo_id, email, temporary_password }
UserUpdate               { status? }
User                     { id, email, status, role, vinculo_id, organization_id, created_at }
Page<T>                  { items, total, page, page_size }
```

Três observações que evitam bug de transcrição:

- **`role` e `organization_id` do `User` são derivados** — vêm de `Vinculo`, não de
  coluna da tabela `User`. Existem na leitura e **não** existem no `UserCreate`, do mesmo
  jeito que `idade` no molde de `respondentes`.
- **Não há `role` no `UserCreate`.** O papel é do vínculo, e o vínculo já existe quando o
  acesso é criado (P-008). Mandar `role` no POST é sintoma de ter entendido o modelo ao
  contrário.
- **Não há `token_type`.** O front sempre monta `Authorization: Bearer <token>`; um campo
  que só pode ter um valor é campo que alguém vai ramificar por engano.

## Os três fluxos que o front precisa desenhar

### 1. Login normal

```
POST /authentication/login  {email, password}
  200 -> guarda a Session, entra
  401 -> "E-mail ou senha inválidos"
```

O 401 é **o mesmo** para e-mail inexistente, senha errada e acesso desativado. O front não
tem como distinguir, e é de propósito (critério de aceite da spec).

### 2. Primeiro acesso — a tela que a spec não tinha

> 🟡 **Premissa P-011** — a troca de senha do primeiro acesso acontece em tela da
> plataforma, não em página do Keycloak. Confirmar na próxima reunião.

O Keycloak marca a conta com `UPDATE_PASSWORD` (P-007) e, com Direct Access Grant
(decisão D1), **recusa o login por senha enquanto a ação estiver pendente** — responde
`invalid_grant: "Account is not fully set up"`. Sem contrato para isso, o primeiro login de
todo usuário morre numa mensagem de credencial inválida que não é verdade.

```
POST /authentication/login  {email, password}
  409 {code: "password_change_required"} -> tela "defina sua senha"

POST /authentication/password  {email, current_password, new_password}
  204 -> volta e chama o login de novo, com a senha nova
  422 -> a política de senha do realm recusou (detail é string, mostra na tela)
```

O `code` existe porque a ramificação é real. Não é um catálogo de erros — é a única chave
do contrato inteiro, e só nasce onde o front precisa decidir para onde ir.

### 3. Renovação — o que o `apiClient` faz sozinho

```
qualquer rota -> 401
  POST /authentication/renew {refresh_token}
    200 -> repete a requisição original, uma vez
    401 -> limpa creed.session, vai para /login
```

Com **renovação em voo única** (decisão D6): cinco requisições que tomam 401 juntas
disparam **um** refresh, não cinco.

## Códigos de status

| Código | Quando | O que o front faz |
|---|---|---|
| 401 | sem token · token inválido/expirado · credencial errada · `status = inactive` · claim divergente do banco | renova **uma vez**; falhou, limpa a sessão e vai para `/login` |
| 403 | autenticado, mas o papel não alcança a rota | "acesso negado" — **não desloga** |
| 404 | `vinculo_id` ou `user_id` que não existe, **ou é de outra organização** | mensagem de não encontrado |
| 409 | primeiro acesso pendente (`code`) · e-mail já tem acesso | ramifica pelo `code`, ou erro de formulário |
| 422 | payload não bate com o schema **ou** senha recusada pela política do realm | ver abaixo — em desenvolvimento, quase sempre é bug do front |
| 503 | Keycloak fora do ar | "tente novamente" — **nunca** "senha inválida", e **não** limpa a sessão |

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
// Premissas: P-006 (lista de papéis), P-007 (senha temporária), P-010 (sessão).
// Quando o backend chegar e divergir, o backend ganha.

export type Role = 'admin' | 'gestor' | 'respondente';
export type RecordStatus = 'active' | 'inactive';

export interface UserSession {
  id: string;
  email: string;
  role: Role;
  vinculo_id: string;
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

export interface PasswordChangeRequest {
  email: string;
  current_password: string;
  new_password: string;
}

export interface User {
  id: string;
  email: string;
  status: RecordStatus;
  role: Role;
  vinculo_id: string;
  organization_id: string;
  created_at: string;
}

export interface UserCreate {
  vinculo_id: string;
  email: string;
  temporary_password: string;
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
  changePassword: (dados: PasswordChangeRequest) =>
    apiClient.post<undefined>('/authentication/password', dados),
};
```

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
| 2 | **409 + `POST /authentication/password`** para o primeiro acesso | você | resolve o furo de D1 × P-007: sem isso o primeiro login de todo usuário morre. Custa uma tela a mais no front, e nenhum tipo de token novo no sistema |
| 3 | **503 quando o Keycloak está fora** | agente | a spec só mapeava 401/403/409. Sem o 503, indisponibilidade vira "senha inválida" e o usuário troca a senha que estava certa |
| 4 | **404 para `vinculo_id`/`user_id` de outra organização** — mesma resposta de "não existe" | agente | dizer "existe, mas não é sua" vaza cadastro de outra organização. Segue o mapeamento `NotFoundError → 404` do molde |
| 5 | **`logout` idempotente** — refresh já inválido também devolve 204 | agente | o usuário está saindo; travá-lo numa tela que ele quer abandonar é o pior desfecho para um erro que não muda nada |
| 6 | **`GET /users` exige `admin`, e o recorte é sempre a organização do vínculo de quem chama** — `organization_id` de outra organização responde 403 | agente | a spec diz que cadastro de usuário é do `admin`, mas não fixou o papel da listagem. O recorte por vínculo é o mesmo de [C2]; esconder no front não é autorização |

Decisões 3 a 6 foram do agente porque nenhuma é bifurcação de design — são consequências
diretas do molde e do modelo. Se alguma incomodar, o custo de mudar é uma linha no
`openapi.yaml` e uma no router.

## Buracos conhecidos

Coisas que este contrato **não** resolve e que alguém vai esbarrar:

- **Não há endpoint para trocar o papel.** O critério de aceite da spec exige que "mudar
  `Vinculo.role` reflita na realm role", mas `role` mora em `Vinculo`, e não há rota para
  escrever lá. Dois caminhos, nenhum escolhido: `PATCH /vinculos/{id}` (domínio que não
  existe) ou `role` dentro do `UserUpdate` (o domínio `users` escrevendo em `Vinculo`).
  **Precisa de tarefa própria antes da entrega 3 fechar** — o espelhamento de papel (D4) é
  metade do critério de aceite e não tem por onde ser exercitado.
- **Não há como listar vínculos sem acesso.** A tela de cadastro precisa escolher um
  `vinculo_id`, e sem essa rota o admin digita UUID na mão. Telas de gestão estão fora do
  épico, mas é isto que trava a primeira delas.
- **O mock não guarda estado** (ver [`mock/README.md`](mock/README.md)): o token que ele
  devolve não é aceito por ele depois. O fluxo login → usar token → renovar só fecha de
  verdade contra o backend da entrega 4.

## Premissas

Usadas: **P-006** (papéis `admin`/`gestor`/`respondente` — ainda aberta e em conflito com
P-003), **P-007** (senha temporária), **P-008** (sem autocadastro), **P-009** (sem
recuperação por e-mail), **P-010** (sessão de 15 min / 8 h).

Nasceu daqui: **[P-011](../../decisoes/premissas.md)** — a tela de troca de senha do
primeiro acesso é nossa, não do Keycloak. Registrada em 2026-09-08, 🟡 aberta, custo de
reverter **médio**: ela some junto com D1, se o time migrar para Authorization Code.
