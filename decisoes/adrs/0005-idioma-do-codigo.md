# ADR-0005 — Idioma do código: inglês por padrão, português só onde a cliente fala

- **Status:** Proposto
- **Data:** 2026-09-05
- **Decidem:** time CREED

> Vira **Aceito** quando o time confirmar em reunião interna **e** fechar a lista de
> vocabulário de produto (pendência ao final). Até lá, vale para código novo, que é o
> que a CREED-23 precisa nomear agora.

## Contexto

[`conventions/estrutura-e-nomes.md`](../../conventions/estrutura-e-nomes.md) manda
**domínio em português, técnico em inglês**, com a justificativa de que o domínio é o
vocabulário da cliente. A regra é defensável — e já não descreve o código. Ela está
furada em três lugares, sempre no mesmo sentido:

**1. As tabelas já são inglês.** A decisão de 2026-09-03 registrada em
[`context/modelo-de-dados.md`](../../context/modelo-de-dados.md) fixou os nomes do
diagrama — `User`, `Organization`, `Participant`, `Document`, `Form`, `Question`,
`FormResponse`, `Answer`, `Insight`, `Dashboard` — e a própria linha diz, com todas as
letras, que aceita "o desvio de `estrutura-e-nomes.md`". Só `Vinculo` e `Setor` ficaram
em português, e não por critério: por serem palavras sem tradução óbvia.

**2. A convenção transformou o furo em regra de camada.**
[`conventions/camadas-do-back.md`](../../conventions/camadas-do-back.md) usa o idioma
como sinal: service em português (`criar`, `listar`), repository em inglês
(`get_by_id`, `list_paginated`). É um sinal elegante, e ele só funciona enquanto o
domínio for português. O preço é o que o molde faz hoje: `RespondenteService.criar()`
chamando `RespondenteRepository.get_by_id()`, e `PaginaDe[RespondenteResponse]` com
campos `itens`, `total`, `pagina`, `tamanho_pagina`. Dois idiomas dentro de um arquivo.

**3. A autenticação não tem o que traduzir.** `authentication`, `session`, `token`,
`refresh`, `claim`, `role` não são vocabulário da cliente — são vocabulário de OAuth.
`/api/v1/autenticacao/renovar` inventa português para um conceito que só existe em
inglês, e obriga quem lê a Admin API do Keycloak a fazer a tradução de volta a cada
linha.

**O que força a decisão agora:** o épico
[CREED-23](../../tarefas/86e348g6u-autenticacao-da-plataforma/spec.md) cria dois
domínios novos e, mais caro que isso, a **estrutura comum de proteção de rota que todo
domínio futuro importa**. Nomear `exige_papel()` em português e mudar de ideia depois é
refactor em todo o código escrito no meio.

## Decisão

**1. Inglês é o padrão em todo identificador.** Pasta, classe, método, variável, rota,
schema Pydantic, chave de i18n, nome de arquivo de teste. Não há mais distinção entre
"nome técnico" e "nome de domínio".

**2. Português sobrevive num lugar só: o termo que a cliente usa e que aparece na
conversa com ela.** O critério não é "é domínio" — é **exposição**. A pergunta a fazer:

> Esta palavra é dita numa reunião com a professora?
> **Sim** → fica como ela fala. **Não** → inglês.

Rota, método, service, repository, schema, dependência, teste: ninguém mostra isso para
a cliente. É inglês, sempre.

**3. A lista de termos expostos é decisão do time**, e está aberta — ver pendência
abaixo. Ela é curta e não bloqueia o resto: `authentication`, `users`, `session`,
`role`, `token` não dependem dela.

**4. Vale daqui para frente.** Código existente **não** é renomeado por esta decisão. O
preço disso está em Consequências, e é real.

**5. A interface continua em português.** Código em inglês não é tela em inglês: a chave
de i18n é inglês (`auth.login.submit`), o valor em `pt-BR` é o que a cliente lê. Quem
confundir as duas coisas entrega uma tela que ninguém do público-alvo entende.

**6. O idioma deixa de ser sinal de camada.** A tabela de
`camadas-do-back.md` (service português × repository inglês) sai. A distinção volta a
ser a do [ADR-0004](0004-camadas-do-backend.md), que nunca dependeu de idioma:

> Se a resposta muda quando o **produto** muda de ideia, é service.
> Se muda quando o **banco** muda de forma, é repository.

## Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| **Manter português no domínio** (estado atual) | Já não descreve o código: as tabelas estão em inglês desde 2026-09-03, e o molde mistura idioma dentro do mesmo arquivo. Uma convenção que o código não cumpre não é convenção, é folclore |
| **Renomear o código existente junto**, num PR de refactor | Considerado e **recusado pelo time nesta rodada**: gastar um PR que toca tudo antes de o inglês estar confirmado com todos é apostar. O custo de não fazer está em Consequências, e o gatilho para refazer a conta está lá também |
| **Inglês total, inclusive o vocabulário da cliente** | `prism` não é o que a professora chama de prisma. O glossário deixaria de ser dicionário e viraria tradutor, e toda reunião passaria a exigir tradução nos dois sentidos — que é exatamente o custo que a regra original queria evitar |
| **Português total**, inclusive o técnico | Coerente, e resolve a mistura pelo outro lado. Mas obriga a inventar português para `token`, `refresh`, `claim`, `payload`, e a renomear as tabelas do diagrama — que é um dos dois artefatos que o time produziu coletivamente |
| **Adiar até a lista de vocabulário estar fechada** | A lista trava três palavras (`Vinculo`, `Setor`, `Prisma`). O que a CREED-23 precisa nomear esta semana — `authentication`, `users`, `session`, `role` — não depende dela em nada |

## Consequências

**Boas:**

- Rota, método e schema param de precisar de tradução inventada:
  `/api/v1/authentication/renew` em vez de `/api/v1/autenticacao/renovar`.
- O desvio registrado em 2026-09-03 deixa de ser desvio. As tabelas em inglês viram a
  regra, e a linha do `modelo-de-dados.md` que pedia desculpa por elas fica obsoleta.
- Nenhum identificador novo mistura idioma. `criar()` chamando `get_by_id()` deixa de
  ser o padrão do projeto e passa a ser resíduo datado.
- Uma decisão a menos por arquivo novo: não se pergunta mais "isto é domínio ou
  técnico?".
- O vocabulário do Keycloak, do OAuth e do FastAPI atravessa o código sem tradução.

**Ruins — e aceitas:**

- **O molde fica no idioma antigo.** `app/domains/respondentes/` e
  `src/features/respondentes/` continuam em português e continuam sendo o que todo mundo
  copia. É literalmente o defeito que o [ADR-0004](0004-camadas-do-backend.md) item 7
  registrou — *"o molde contradiz a convenção"* — agora assumido de propósito e por prazo
  indeterminado. *Mitigação:* o primeiro domínio em inglês da CREED-23 (`users`, entrega
  3) vira o molde de fato, e o [`catalogo.md`](../../catalogo.md) precisa dizer qual é
  qual antes que alguém copie o errado.
- **`app/shared/paginacao.py` bate primeiro, e bate na CREED-23.** `PaginaDe[T]` é
  compartilhado; o `GET /users` vai importá-lo e devolver um schema em inglês dentro de
  um envelope com campos `itens`, `pagina`, `tamanho_pagina`. É **um arquivo e dois
  imports** — de longe a exceção mais barata ao item 4, se o time quiser abri-la. Fica
  registrado aqui para ser decidido de propósito, não descoberto no review.
- **Dois idiomas convivendo sem data de fim** não é transição, é estado. *Gatilho para
  reabrir:* a v1 do banco já decidiu que `respondentes` **não entra na inauguração**
  (2026-09-03). Quando aquele domínio deixar de ser molde, renomear vira apagar — e a
  conta muda de sinal.
- **A lista de vocabulário fica aberta com duas palavras dentro da primeira migration.**
  Ver pendência.
- **Um ADR a mais para ler** antes de nomear um arquivo. Pequeno, mas real.

## Pendência: a lista de vocabulário de produto

Precisa de decisão do time **antes da entrega 1 da CREED-23** (a inauguração do banco).
Motivo de prazo: `Vinculo` e `Setor` são **nome de tabela**, e
[`conventions/migrations.md`](../../conventions/migrations.md) trata rename como
drop+create. Depois da primeira migration, mudar de ideia custa dado.

| Termo | Aparece em conversa com a cliente? | Se ficar | Se for inglês |
|---|---|---|---|
| `Vinculo` | provavelmente sim — é o conceito central do modelo | `Vinculo`, `vinculo_id` | **decidido em 2026-09-29: `Link`, `link_id`** |
| `Setor` | provavelmente sim | `Setor`, `setor_id` | **decidido em 2026-09-29: `Department`, `department_id`** |
| `Prisma` | **sim** — são os cinco prismas do método dela | `Prisma`, `InsightPrisma` | `Prism` |
| `Prognostico` | sim | `Prognostico` | `Forecast` |
| `Respondente` | sim | `Respondente` | `Respondent` |

Não é pergunta para a cliente — ela não decide nome de tabela. É o time olhando o
[`glossario.md`](../../glossario.md) e marcando quais palavras ela de fato usa.

**2026-09-29 — `Vinculo` e `Setor` fechados: inglês, `Link` e `Department`.** O time
decidiu que só o vocabulário de código muda; **valores** de enum (`emprego`, `gestor`,
`respondente`…) ficam em português por enquanto. A CREED-32 aplicou isso antes de a
primeira tabela subir (`links`, `user.link_id`, `links.department_id`). Isso refuta a
P-029, que propunha manter os dois em português. O `.dbml` do time continua com os nomes
do diagrama, e `form_responses.vinculo_id` continua com o nome antigo até ganhar
migration própria. Seguem abertos `Prisma`, `Prognostico` e `Respondente`.

## Pendência herdada: a numeração dos ADRs

Continua valendo o que o [ADR-0004](0004-camadas-do-backend.md) registrou: o código cita
ADR-001, ADR-002 e ADR-003 com número de seção, e esses documentos não existem em
`decisoes/adrs/`. Este entra como **0005** no mesmo espaço de numeração e não resolve a
pendência.

## Como reverter

- **Antes da CREED-23 entrar:** custo **zero**. Nenhum código foi renomeado; reverter é
  apagar este ADR e restaurar a seção "Idioma" de `estrutura-e-nomes.md`, mais a tabela
  de idioma-por-camada em `camadas-do-back.md`.
- **Depois da CREED-23:** custo de renomear dois domínios (`authentication`, `users`), a
  guarda comum (`app/shared/authorization.py`), a feature `authentication` do front e as
  chaves de i18n correspondentes. Nenhuma migration envolvida — nenhum nome de tabela
  depende deste ADR, e é de propósito: a pendência de vocabulário é o que toca tabela, e
  ela está separada justamente para poder ser decidida sem desfazer esta.
