# CREED-23 — contrato da API de autenticação

> Fecha a seção **Contrato** da [`spec.md`](spec.md), que estava em forma de tabela
> resumida com dois pontos marcados para decidir. Este documento é o que o front
> programa contra **antes de o backend existir**, e o que o backend implementa nas
> entregas 3 e 4.
>
> **Status: parcialmente implementado (2026-09-14).** Este documento continua descrevendo
> o **alvo**. O que já existe em código diverge dele em pontos concretos, e pela regra de
> [`conventions/contrato-front-back.md`](../../conventions/contrato-front-back.md)
> **o backend ganha** — o quadro "Estado real" abaixo é a fonte para quem está programando
> hoje. O resto da tabela permanece como o destino acordado, não como dívida.
>
> Payloads literais, com exemplos nomeados: [`mock/openapi.yaml`](mock/openapi.yaml).
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
| POST | `/users` | Bearer | `admin` | `UserCreate` | `User` · 201 |
| GET | `/users` | Bearer | `admin` | query | `Page<User>` · 200 |
| PATCH | `/users/{user_id}` | Bearer | `admin` | `UserUpdate` | `User` · 200 |

`GET /users` aceita `organization_id`, `role`, `page` e `page_size` na query.

## Estado real — 2026-09-14

O domínio `users` está na `dev` do backend; o `authentication` está em PR
([creed-backend#12](https://github.com/creed-educa-ai/creed-backend/pull/12), draft) e o
front que consome está em [creed-frontend#22](https://github.com/creed-educa-ai/creed-frontend/pull/22).
O fluxo de login foi verificado de ponta a ponta contra Keycloak e Postgres locais.

| Alvo acima | O que existe | Nota |
|---|---|---|
| `POST /authentication/login` | **`POST /auth/login`** | prefixo mais curto; front e back já concordam |
| `POST /authentication/renew` | **`POST /auth/renew`** | idem |
| `GET /authentication/session` | **`GET /auth/me`** | mesmo payload (`UserSessionResponse`) |
| `POST /authentication/logout` | **não existe** | sem endpoint, "sair" só limpa a sessão no front e o refresh token segue válido até expirar |
| `POST /users` | existe, **sem guarda de papel** | e o payload é outro — ver abaixo |
| `GET /users` · `PATCH /users/{id}` | **não existem** | |
| — | **`DELETE /users/{user_id}`** (204) | existe e não está no contrato |

**`UserCreate` diverge de verdade.** O alvo é `{vinculo_id, email, initial_password}`;
o implementado é **`{keycloak_id, name, email}`**. A razão é que `Vinculo` ainda não tem
tabela, então o papel virou coluna do `user` e o vínculo não é pedido. Enquanto isso, quem
provisiona cria o usuário no Keycloak primeiro e passa o `sub` — não há senha no payload,
coerente com a P-012.

**`role` e `organization_id` do `User`** continuam existindo na leitura, mas hoje saem
sempre `null` em `UserSessionResponse` (exceto `role`, que vem da coluna).

⚠️ **O 503 do quadro de status ainda não acontece.** Keycloak fora do ar responde **401**,
não 503 — o service traduz indisponibilidade para erro de credencial. É o par que a seção
"Códigos de status" avisa para não confundir, e está confundido no código.


## Os payloads

```
LoginRequest             { email, password }
RenewRequest             { refresh_token }

Session                  { access_token, refresh_token, expires_in, user: UserSession }
UserSession              { id, email, role, vinculo_id, organization_id, organization_name }

UserCreate               { vinculo_id, email, initial_password }
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

## Os dois fluxos que o front precisa desenhar

### 1. Login — e não há um segundo caminho

> 🟡 **Premissa P-012** — o primeiro acesso é por e-mail com link para o realm do
> Keycloak, onde a pessoa define a própria senha. Enquanto o e-mail não existir, o admin
> define uma senha definitiva e passa por fora da plataforma. Confirmar na próxima reunião.

```
POST /authentication/login  {email, password}
  200 -> guarda a Session, entra
  401 -> "E-mail ou senha inválidos"
```

O 401 é **o mesmo** para e-mail inexistente, senha errada e acesso desativado. O front não
tem como distinguir, e é de propósito (critério de aceite da spec).

**Não existe tela de troca de senha nesta plataforma** — nem hoje, nem depois que o envio
de e-mail entrar. Quem define senha é a página do realm do Keycloak, alcançada por link no
e-mail. O front tem tela de login e mais nada.

Isso depende de uma linha do provisionamento, e vale saber por quê: o `POST /users` cria a
credencial com **`temporary: false`**. Se ela fosse temporária, o Keycloak anexaria a ação
obrigatória `UPDATE_PASSWORD`, e o Direct Access Grant (decisão D1) passaria a **recusar o
login** com `invalid_grant: "Account is not fully set up"` — o primeiro login de todo
usuário morreria numa mensagem de credencial inválida que não é verdade.

> ⚠️ **A mesma armadilha vem pelo realm.** `temporary: false` só resolve se o realm não
> tiver *default required actions* ligadas (`VERIFY_EMAIL`, "Update Password" como ação
> padrão). Se tiver, o Keycloak anexa a ação a todo usuário novo e o sintoma é idêntico,
> sem ninguém ter tocado no provisionamento. O realm é arquivo versionado (entrega 2) —
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

## Códigos de status

| Código | Quando | O que o front faz |
|---|---|---|
| 401 | sem token · token inválido/expirado · credencial errada · `status = inactive` · claim divergente do banco | renova **uma vez**; falhou, limpa a sessão e vai para `/login` |
| 403 | autenticado, mas o papel não alcança a rota | "acesso negado" — **não desloga** |
| 404 | `vinculo_id` ou `user_id` que não existe, **ou é de outra organização** | mensagem de não encontrado |
| 409 | e-mail já tem acesso | erro de formulário no cadastro |
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
// Premissas: P-006 (lista de papéis), P-012 (primeiro acesso), P-010 (sessão).
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
  // Senha definitiva, passada à pessoa fora da plataforma (P-012). Este campo
  // some quando o envio de e-mail entrar — aí o Keycloak manda o link do realm.
  initial_password: string;
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
| 2 | **Primeiro acesso não passa pela plataforma** — provisionamento com `temporary: false`, sem ação obrigatória, sem 409 e sem tela de senha | você | é o desenho de destino (P-012): o convite por e-mail leva à página do realm do Keycloak. Como lá também não há tela nossa, tirá-la agora não é dívida — é remover uma tela que o destino não tem. **Substituiu** a decisão anterior (409 + `POST /authentication/password`), que caiu junto com P-007 e P-011 |
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
P-003), **P-008** (sem autocadastro), **P-009** (sem recuperação por e-mail), **P-010**
(sessão de 15 min / 8 h), **[P-012](../../decisoes/premissas.md)** (primeiro acesso por
e-mail com link para o realm; no interim, senha definitiva pelo admin).

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
| P-012 | 🟡 aberta | substitui as duas |

Premissa refutada não é erro do time: é o mecanismo funcionando. O que ele pegou aqui foi
uma decisão tomada e não escrita — e é exatamente para isso que o ledger existe.

**Consequência fora deste documento:** a
[PR #11 do `creed-frontend`](https://github.com/creed-educa-ai/creed-frontend/pull/11)
implementa a tela de troca de senha do primeiro acesso. Neste desenho ela perde a função.
