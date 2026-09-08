# 86e348g6u — CREED-23 [Autenticação] Estruturar autenticação da plataforma

> Épico. A descrição no ClickUp estava vazia; este documento é o discovery que a
> preenche. Decomposição em entregas na última seção — é dela que saem as subtarefas.

## Calibragem

**P3 · T3**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | regra de negócio nova (quem pode o quê, por papel) + 5 premissas novas + a lista de papéis está em conflito aberto no modelo de dados (pendência #12 × [P-003](../../decisoes/premissas.md)) |
| Técnico | T3 | migration (o banco nem foi inaugurado) · padrão que não existe no código nem neste harness (Keycloak, JWT, guarda de rota, sessão no front) · componente novo de infra · três repos |

Dispensadas nesta calibragem: nenhuma.

## Problema

Hoje **qualquer pessoa com a URL vê qualquer tela e chama qualquer endpoint**. Não há
login, não há sessão, e o papel do usuário no front é valor fixo em código
([P-004](../../decisoes/premissas.md)). Enquanto isso continuar:

- nenhuma tela pode mostrar dado real de respondente — a plataforma inteira fica presa
  em dado sintético;
- `Form` não tem dono-pessoa por decisão [C1] do modelo: quem edita e publica é
  "qualquer vínculo com papel admin/gestor naquela organização". Essa frase **é
  autorização** — sem autenticação ela não tem onde existir;
- toda tarefa de produto que dependa de "quem está vendo" fica bloqueada ou nasce com
  outra premissa de papel fixo.

A v1 do banco foi fechada em 2026-09-04 declaradamente **para destravar a autenticação**
([`modelo-de-dados.md`](../../context/modelo-de-dados.md) → "A v1 e a autenticação").
Este épico é o que ela destrava.

## Quem usa

Todo mundo — é o portão da plataforma. Por papel (ver premissa P-006 sobre a lista):

| Papel | O que a autenticação dá a ele |
|---|---|
| `respondente` | entra e vê **os formulários dos vínculos dele**; não vê tela de gestão nem dado de outra pessoa |
| `gestor` | entra e vê a **organização do vínculo dele**: formulários, respostas, dashboards daquela organização |
| `admin` | tudo do gestor **na organização dele**, mais cadastro de usuário e mudança de papel |

O recorte é sempre `Vinculo` — organização + papel + período. Um login é um vínculo
(decisão [C2]): a mesma pessoa em duas organizações tem **dois logins**, e nunca vê as
duas de uma vez. Isso não é limitação da auth, é o modelo de dados fechado em 2026-09-04.

**Quem não usa:** não existe visitante. Não há tela pública além da própria tela de
login (P-008).

## Escopo

**Entra:**

- Keycloak como guardião de **credencial** (senha, hash, política de senha, revogação de
  sessão). Realm, client e roles versionados como arquivo, não clicados na UI.
- Domínio `users` no backend: `User` ligado ao `Vinculo`, provisionamento no Keycloak,
  ativar/desativar acesso (`User.status`), troca de papel.
- Domínio `authentication` no backend: login, renovação, logout e "quem sou eu".
- **Estrutura comum de proteção de rota** no backend — a dependência que qualquer domínio
  futuro usa em uma linha para exigir autenticação e nível de acesso.
- Espelhamento dos papéis: backend é a fonte, o realm do Keycloak é a cópia.
- Front: módulo de sessão, `apiClient` autenticado (injeção de token + renovação
  automática), guarda de rota, e leitura de papel compartilhada entre telas.
- Tela de login e tela de "acesso negado".
- Seed do primeiro admin (sem ele ninguém entra — ver Riscos).

**Não entra:**

- **Telas** de gestão de usuário (listar, criar, editar usuário pela interface). O épico
  entrega o backend de `users`; a tela é tarefa própria, depois.
- Recuperação de senha por e-mail — não existe serviço de e-mail na arquitetura (P-009).
- Autocadastro / tela de "criar conta" (P-008).
- MFA, login social, SSO institucional da PUCRS.
- Auditoria de acesso (quem entrou quando). Log de aplicação sim, tabela não.
- Troca de vínculo dentro da sessão ("mudar de organização sem deslogar") — com [C2] são
  dois logins distintos.
- Permissão por objeto ("este gestor só vê estes 3 formulários"). O recorte desta entrega
  é **papel + organização do vínculo**, não item a item.

## Repos afetados

| Repo | O que muda |
|---|---|
| `creed-backend` | domínios novos `users` e `authentication` · `app/external_services/keycloak/` · `app/shared/authorization.py` · settings novas · migration da v1 do banco |
| `creed-frontend` | feature nova `authentication` · `src/lib/session.ts` · `src/lib/apiClient.ts` (autenticado) · `src/app/routes.tsx` (rotas protegidas) · `src/app/store.ts` · i18n |
| `creed-infrastructure` | Keycloak no EKS + schema dedicado no RDS + realm versionado · `docker-compose` local · ADR do componente novo |

Nome do domínio/feature (iguais nos dois lados): **`authentication`** e **`users`**.

## Contrato

Prefixo `/api/v1`. **Inglês em todo identificador**, pelo
[ADR-0005](../../decisoes/adrs/0005-idioma-do-codigo.md): nada aqui é vocabulário que a
cliente use em reunião — `session`, `token`, `role` e `refresh` são vocabulário de OAuth,
e traduzir isso obrigaria a destraduzir a cada linha da documentação do Keycloak.

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/authentication/login` | `LoginRequest{email, password}` | `SessionResponse` |
| POST | `/authentication/renew` | `RenewRequest{refresh_token}` | `SessionResponse` |
| POST | `/authentication/logout` | `RenewRequest{refresh_token}` | 204 |
| GET | `/authentication/session` | — (Bearer) | `UserSessionResponse` |
| POST | `/users` | `UserCreate{vinculo_id, email, temporary_password}` | `UserResponse` (201) |
| GET | `/users` | query `organization_id`, `role`, paginação | `PaginaDe[UserResponse]` ⚠️ |
| PATCH | `/users/{id}` | `UserUpdate{status?}` | `UserResponse` |

```
SessionResponse      { access_token, refresh_token, expires_in, user: UserSessionResponse }
UserSessionResponse  { id, email, role, vinculo_id, organization_id, organization_name }
UserResponse         { id, email, status, role, vinculo_id, organization_id, created_at }
```

> ⚠️ **`PaginaDe[T]` é o envelope de paginação que já existe** em
> `app/shared/paginacao.py`, com campos `itens`, `pagina`, `tamanho_pagina`. O ADR-0005
> não renomeia código existente, então o `GET /users` devolve um schema em inglês dentro
> de um envelope em português. É **um arquivo e dois imports** para arrumar
> (`app/shared/pagination.py`, `Page[T]`) — a exceção mais barata ao ADR, registrada nas
> Consequências dele. **Decidir antes da entrega 4**, não no review.
>
> 🟡 `vinculo_id` fica em português porque `Vinculo` é nome de tabela e está na lista de
> vocabulário ainda aberta (pendência do ADR-0005). Se o time fechar por `Engagement`,
> este campo vira `engagement_id` — e é por isso que a lista tem prazo: antes da
> entrega 1.

**Códigos de status — o contrato que o front vai programar contra:**

| Código | Quando | O que o front faz |
|---|---|---|
| 401 | sem token · token inválido/expirado · `User.status = inactive` | tenta renovar **uma vez**; falhou, limpa a sessão e vai para `/login` |
| 403 | autenticado, mas o papel não alcança a rota | mostra "acesso negado", **não** desloga |
| 409 | e-mail já existe no `User` ou no realm | erro de formulário no cadastro |

A distinção 401 × 403 é o que impede o bug clássico: um 403 tratado como 401 desloga o
usuário toda vez que ele clica onde não pode.

## Dados

Nada aqui é tabela nova de autenticação — o modelo já previu quase tudo. **Duas
correções** no [`modelo-de-dados.proposta.dbml`](../../context/modelo-de-dados.proposta.dbml),
que este épico fecha:

| # | Coluna | Hoje na proposta | Fica | Por quê |
|---|---|---|---|---|
| 1 | `User.password` | `string` nulável | **sai** | a credencial mora no Keycloak. Guardar hash aqui cria duas fontes de senha e a pergunta "qual vale?". Resolve a pendência aberta em [`modelo-de-dados.md`](../../context/modelo-de-dados.md) → *"`User.password` é nulável — login precisa saber o que fazer com senha nula"*: a resposta é SSO |
| 2 | `User.keycloak_id` | não existe | **entra** — `uuid, unique, not null` | é o `sub` do JWT. Sem ele, achar o usuário a partir do token vira busca por e-mail, e e-mail é dado que muda |

Sem coluna nova além dessas duas. `Vinculo.role`, `User.status` e `User.email unique` já
carregam o resto.

O bloco `Table User` já corrigido, no formato `[CNN]` do arquivo e pronto para colar no
dbdiagram, está em [`correcoes-dbml-auth.md`](correcoes-dbml-auth.md) — junto com o que
**não** muda no resto do modelo.

**Índices que a auth exercita a cada requisição** (todos já previstos em [C16], mas vale
o lembrete de que agora eles têm consumidor): `User.keycloak_id`, `User.email`,
`Vinculo.participant_id`, `Vinculo.organization_id`.

**Migration:** este épico **depende** da inauguração do banco, que ainda não aconteceu
(`alembic/versions/` vazio). O caminho continua o de
[`modelo-de-dados.md`](../../context/modelo-de-dados.md) → "Quando o modelo for aceito":
corrigir no dbdiagram → reexportar → `models.py` por domínio → `alembic revision
--autogenerate` → **leitura linha a linha**. As duas correções acima entram nessa mesma
passada, não em migration separada.

**Dado existente:** nenhum. O banco não tem uma linha. É a única janela em que essas duas
correções custam zero.

## Abordagem técnica

Seis decisões. As duas primeiras foram bifurcações levadas ao dev; as outras quatro
seguem delas.

### D1 — O backend intermedeia o login (Direct Access Grant)

O front tem **tela de login própria** (a do Figma) e posta e-mail/senha em
`POST /api/v1/authentication/login`. O backend chama o token endpoint do Keycloak com
`grant_type=password` como *confidential client* e devolve os tokens. **O front nunca
sabe que o Keycloak existe.**

*Descartado: Authorization Code + PKCE com redirect do navegador.* É o padrão da
indústria e abre MFA e login social sem refazer nada — mas joga fora a tela do Figma (o
login passaria a ser página do Keycloak, tematizada), coloca uma biblioteca OIDC e um
ciclo de redirect no front, e exige o time aprender OIDC agora, em cima de uma stack que
ainda não tem uma migration sequer.

*Preço aceito, dito por escrito:* ROPC é desencorajado no OAuth 2.1 e pelo próprio
Keycloak, a senha trafega pelo nosso backend, e MFA/social ficam de fora. **A mitigação é
o próprio D1:** como o front só conhece `/api/v1/authentication/*`, migrar para
Authorization Code depois é mexer na tela de login e no router — não em cada tela.

### D2 — Autorização: o claim abre a porta, o banco confirma o dado

Duas camadas, de propósito:

| Camada | O que faz | Custo |
|---|---|---|
| `require_role("admin", "gestor")` | lê `realm_access.roles` do JWT já validado e responde 403 na hora | zero query |
| `current_user` | carrega `User → Vinculo` do banco quando a requisição **precisa do dado** do usuário, e confere que `Vinculo.role` bate com o claim | uma query indexada |

Divergência entre claim e banco = **401 + log de erro**, nunca "escolhe um dos dois". A
divergência só existe se o espelhamento (D4) falhou, e falhar em silêncio é o modo de
falha que ninguém descobre.

> **Decisão marcada como reimplementável.** A conferência claim × banco é o que dá
> confiança enquanto o espelhamento é novo. Se ela provar ser ruído — nenhuma divergência
> em N sprints — vira log sem bloqueio. Se provar o contrário — divergência recorrente —
> o claim sai do caminho e toda guarda passa a ler o banco. As duas reversões mexem em
> **um arquivo**, `app/shared/authorization.py`, e é por isso que a guarda nasce lá e não
> espalhada por domínio.

*Descartado: só o claim.* Papel alterado só valeria no próximo token — janela de acesso
indevido, e o espelhamento vira caminho crítico invisível.
*Descartado: só o banco.* Correto e mais simples, mas paga uma query em toda rota
protegida, inclusive nas que nem tocam no usuário.

### D3 — O backend valida o token do Keycloak; não emite token próprio

RS256, chave pública lida do JWKS do realm e **cacheada em memória** (TTL de settings).
Validação: assinatura, `iss`, `aud`, `exp` e `User.status == active`.

*Descartado: o backend emitir JWT próprio depois de conferir a senha no Keycloak.* Dois
emissores, dois relógios de expiração e duas revogações — e o logout do Keycloak deixaria
de significar coisa alguma.

### D4 — Papel: o banco é a fonte, o realm é a cópia

`Vinculo.role` manda. Toda vez que o backend cria um usuário ou muda o papel de um
vínculo, ele chama a Admin API do Keycloak e ajusta a realm role. Ordem, no
provisionamento:

```
1. cria no Keycloak  -> devolve o sub
2. INSERT User (keycloak_id = sub)  dentro da transação
3. INSERT falhou? -> apaga o usuário do Keycloak (compensação) e propaga o erro
```

*Descartado: banco primeiro, Keycloak depois.* Seria mais limpo (rollback de transação é
grátis, usuário órfão no realm não é) — mas exige cravar o `sub` antes de o Keycloak
existir, escrevendo o id na Admin API. Fica dependendo de comportamento de versão do
Keycloak; a compensação explícita acima é mais feia e mais previsível.
*Descartado: espelhar em job assíncrono.* Papel que demora a valer é bug de segurança que
o suporte não consegue reproduzir.

### D5 — Onde cada peça mora no backend

Sem inventar estrutura: tudo abaixo já tem endereço definido no
[ADR-0004](../../decisoes/adrs/0004-camadas-do-backend.md).

```
app/external_services/keycloak/     ADR-0004 item 3 — serviço externo é pacote irmão
├── client.py                       httpx, token endpoint + Admin API, timeout de settings
├── token.py                        JWKS, cache da chave, validação da assinatura
├── schemas.py                      payload no vocabulário do Keycloak
└── exceptions.py                   KeycloakIndisponivel(DomainError)

app/domains/authentication/         login/renew/logout/sessionn — router, service,
                                    schemas, dependencies. Sem models e sem repository:
                                    lê usuário pelo service de `users`
                                    (arquitetura.md: domínio não chama repository alheio)

app/domains/users/                  User — a forma completa do molde `respondentes`,
                                    no idioma novo (ADR-0005)

app/shared/authorization.py         require_role() e current_user()
```

`app/shared/authorization.py` nasce compartilhado — não é violação da regra "local por
padrão, sobe no segundo uso" do ADR-0004 item 2: ele tem **seis** domínios como usuário
no dia 1, e passa no teste que a regra de fato aplica (nomeia o assunto em uma palavra,
não é `utils.py`).

**`users` é o primeiro domínio em inglês**, e por isso vira o molde de fato para todo
domínio seguinte — o `respondentes` continua servindo para a **forma** (quais arquivos,
qual camada faz o quê) e não mais para o **idioma**. Vale registrar isso no
[`catalogo.md`](../../catalogo.md) na entrega 3, antes que alguém copie o errado.

### D6 — Sessão no front: um módulo, e só ele toca o armazenamento

`access_token` e `refresh_token` em `localStorage`, sob **uma chave só** (`creed.session`),
lidos e escritos exclusivamente por `src/lib/session.ts`. Nenhum componente, slice ou view
toca `localStorage`.

*Descartado: refresh token em cookie httpOnly.* É mais seguro contra XSS (script não lê
cookie httpOnly) e o front e o back são mesma origem atrás do Nginx, então dava para
fazer. Custa configuração de cookie no backend e no proxy, uma regra de CSRF a mais para
o time carregar, e o front deixa de saber se está autenticado sem uma chamada extra.

*Preço aceito:* XSS lê `localStorage`. **A mitigação é a encapsulação**, não a esperança:
trocar por cookie httpOnly depois é reescrever `session.ts` e um handler no backend — as
telas não mudam uma linha. Somado a `expires_in` curto (P-010), é o risco que o time
consegue explicar.

O `apiClient` ganha três comportamentos, nessa ordem:

1. injeta `Authorization: Bearer` quando há sessão;
2. em 401, renova **uma vez** e repete a requisição original;
3. renovação falhou → limpa a sessão e manda para `/login`.

Com **renovação em voo única**: cinco requisições que tomam 401 juntas disparam um
refresh, não cinco. Sem isso, o primeiro carregamento de um dashboard invalida o próprio
refresh token no meio da tela.

## Critérios de aceite

- [ ] Requisição sem `Authorization` a uma rota protegida responde **401**; com token de
      papel insuficiente responde **403** — e são códigos diferentes de verdade.
- [ ] `POST /authentication/login` com credencial correta devolve `access_token`,
      `refresh_token` e o `user` com `role`, `vinculo_id` e `organization_id`.
- [ ] `POST /authentication/login` com senha errada devolve 401 **sem dizer se o e-mail
      existe** (mesma mensagem para e-mail inexistente e senha errada).
- [ ] Usuário com `User.status = inactive` não entra, mesmo com a senha certa no Keycloak.
- [ ] Token expirado é recusado com 401; `POST /authentication/renew` devolve sessão nova.
- [ ] Criar usuário cria a linha em `User` **e** o usuário no realm com a role do
      `Vinculo`; se o `INSERT` falhar, o usuário não fica órfão no Keycloak.
- [ ] Mudar `Vinculo.role` reflete na realm role, e a próxima requisição já usa o papel novo.
- [ ] Claim divergente do banco resulta em 401 e log — não em "passou porque o token dizia".
- [ ] Proteger uma rota nova custa **uma linha** (`Depends(require_role("admin"))`), sem
      copiar código de outro domínio.
- [ ] No front, rota protegida sem sessão redireciona para `/login` e volta para a rota
      pretendida depois do login.
- [ ] Recarregar a página com sessão válida **não** desloga.
- [ ] Um 403 não desloga o usuário.
- [ ] Elemento restrito a `admin` não aparece para `respondente` — e a rota também recusa
      no backend (esconder no front não é autorização).
- [ ] `npm run check` verde no front; `ruff` + `mypy app` + `pytest` verdes no backend.

## Como verificar

1. `docker compose up` — Postgres e Keycloak sobem; o realm é importado do arquivo
   versionado, não clicado na UI.
2. Rodar a migration da v1 pelo caminho de `playbooks/criar-migration.md` e o seed do
   primeiro admin.
3. `GET /api/v1/users` sem header → **401**.
4. `POST /api/v1/authentication/login` com o admin do seed → copiar o `access_token`.
5. Colar o token em <https://jwt.io> e conferir `sub`, `exp` e `realm_access.roles`.
6. Repetir o passo 3 com o header → **200**.
7. Criar um usuário `respondente`, logar com ele, chamar uma rota de admin → **403**
   (não 401).
8. Trocar o papel desse vínculo para `gestor`; repetir a chamada com token novo → **200**.
9. Alterar a role **direto no Keycloak** para simular dessincronia; a próxima requisição
   que carrega o usuário responde **401** e registra log.
10. `User.status = inactive` no banco → login recusado.
11. No front (`npm run dev`): abrir `/respondentes` deslogado → cai em `/login`; logar →
    volta para `/respondentes`; **F5** → continua logado.
12. Apagar `creed.session` do `localStorage` pelo DevTools e clicar em qualquer coisa →
    cai em `/login` sem tela quebrada.

## Premissas

| ID | Premissa | Custo de reverter |
|---|---|---|
| P-006 | Os papéis são **`admin`, `gestor`, `respondente`** — a lista do diagrama, não a de [P-003](../../decisoes/premissas.md). | baixo hoje, **alto depois** |
| P-007 | O acesso nasce com **senha temporária definida por quem cadastra**, e o Keycloak exige a troca no primeiro login (`UPDATE_PASSWORD`). Não há convite por e-mail. | baixo |
| P-008 | **Não existe autocadastro.** Todo login nasce da cadeia Organização → Participante → Vínculo → Usuário, por alguém com papel `admin`. | baixo |
| P-009 | **"Esqueci minha senha" não existe nesta entrega.** Quem perde a senha pede a um `admin`, que emite outra temporária. | médio |
| P-010 | Sessão: `access_token` de **15 minutos**, `refresh_token` de **8 horas**, sem renovação deslizante além disso. | baixo |

**Por que P-006 é a mais urgente do ledger.** O modelo de dados já dizia
([pendência #12](../../context/modelo-de-dados.md)) que este é *"o único item que a
autenticação não consegue contornar"*. Escolhi o diagrama porque ele foi feito em time e
tem lastro; P-003 nasceu de um ensaio da esteira (tarefa `EXEMPLO`) que nunca virou
código. **Hoje nenhum dos dois lados tem uma linha atrás** — decidir custa zero. Depois
desta entrega, mudar a lista é migration de enum **mais** refactor de toda guarda de rota
**mais** realm do Keycloak. P-003 fica aberta no ledger apontando para cá, e as duas vão
juntas para a pauta.

## Riscos

- **O banco ainda não existe.** `alembic/versions/` está vazio; `User`, `Vinculo`,
  `Organization` e `Participant` são desenho. *Sinal de que deu errado:* alguém começar o
  domínio `authentication` antes da migration e escrever contra model imaginado. Por isso a
  entrega 1 é a inauguração, e ela já é a subtarefa que existe no ClickUp.
- **Ovo e galinha do primeiro admin.** Por [C2] o admin da plataforma também precisa de
  vínculo: Organização → Participante → Vínculo → User. Sem seed, ninguém entra e ninguém
  pode cadastrar. *Sinal:* ambiente novo em que o time cria usuário na mão pelo psql — é o
  seed faltando. *Mitigação:* o seed é entregável da entrega 3, não improviso de cada dev.
- **Espelhamento dessincroniza.** Duas escritas (banco e realm) sem transação distribuída.
  *Sinal:* o 401 por divergência de D2 aparecendo em log. É o detector, não o bug.
- **Keycloak é componente novo na arquitetura**, e o diagrama de
  [`arquitetura.md`](../../context/arquitetura.md) não o tem. Precisa de pod, schema
  dedicado no RDS (como o N8N) e realm versionado. *Sinal:* dev e produção com realms
  diferentes porque alguém clicou na UI. *Mitigação:* realm como arquivo, importado no
  boot — nunca configuração manual.
- **ROPC é caminho de saída conhecido.** Se MFA ou login institucional entrar no escopo,
  D1 muda. *Sinal:* a cliente pedir "entrar com a conta da PUCRS". *Mitigação:* já está no
  desenho — o front só fala com o nosso backend.
- **Esconder no front não é autorizar.** *Sinal:* uma rota protegida só pelo
  `ProtectedRoute` e não pelo `require_role`. *Mitigação:* está nos critérios de aceite, e
  é o item que a revisão precisa procurar de propósito.

## Decomposição em entregas

Seção específica de épico. Cada linha é candidata a subtarefa no ClickUp e, depois, a
`spec` + `tasks` próprias. Ordem é dependência real, não preferência.

| # | Entrega | Repo | Fecha quando |
|---|---|---|---|
| 1 | **Inaugurar o banco** — proposta DBML (com as duas correções de "Dados") → models por domínio → primeira migration, lida linha a linha | back | `alembic upgrade head` sobe do zero no banco local e o teste de arquitetura passa |
| 2 | **Keycloak no ambiente local** — `docker-compose`, realm/client/roles como arquivo versionado, settings novas | infra + back | `docker compose up` sobe o realm importado, sem clique na UI |
| 3 | **Domínio `users`** — `User`, provisionamento no Keycloak com compensação, espelhamento de papel, ativar/desativar, seed do primeiro admin | back | criar usuário cria nos dois lados; falha no banco não deixa órfão |
| 4 | **Domínio `authentication` + guarda comum** — login/renew/logout/session, validação de JWT por JWKS, `app/shared/authorization.py` | back | 401 × 403 corretos, e proteger rota nova custa uma linha |
| 5 | **Sessão no front** — `lib/session.ts`, `apiClient` autenticado com renovação em voo única, slice de autenticação | front | recarregar não desloga; 401 renova uma vez; 403 não desloga |
| 6 | **Tela de login + rota protegida** — `LoginView`, `ProtectedRoute`, redirect de volta, i18n, "acesso negado" | front | os passos 11 e 12 de "Como verificar" passam |
| 7 | **Nível de acesso por tela** — leitura de papel compartilhada, itens de menu e ações por papel, e a substituição da [P-004](../../decisoes/premissas.md) (papel fixo no front) pelo papel real | front | nenhuma tela lê papel de valor fixo |
| 8 | **Keycloak no EKS** — manifest, schema dedicado no RDS, ADR do componente novo, atualização do diagrama em `arquitetura.md` | infra + harness | PR revisado por dono de infra |

**1 e 2 são independentes entre si** — o Keycloak local não precisa do schema, e o schema
não precisa do Keycloak. A 3 precisa das duas; a 4 precisa da 3. **5 e 6 podem começar em
paralelo à 4 assim que o Contrato acima estiver acordado** — que é exatamente para isso
que a seção existe. A 7 fecha atrás da 6.

A **8 não entra neste momento**: o time está priorizando entregável que a cliente vê, e
deploy na nuvem não é isso. Fica registrada aqui como trabalho conhecido, sem tarefa no
board — o desenvolvimento inteiro roda em ambiente local sem ela.
