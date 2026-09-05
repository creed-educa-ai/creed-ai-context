# Camadas do back

O molde `app/domains/respondentes/` — gerado no scaffold dos projetos — já tem a
separação certa. Esta convenção diz **por que** ela existe e **como perceber que
furou** — porque camada furada não dá erro de compilação, só aparece no terceiro
domínio, quando já é caro.

A decisão está em [`../decisoes/adrs/0004-camadas-do-backend.md`](../decisoes/adrs/0004-camadas-do-backend.md),
inclusive o que veio do Netflix Dispatch e o que é adição nossa. O par desta convenção
do outro lado é [`camadas-do-front.md`](camadas-do-front.md).

## As quatro camadas

| Camada | Arquivo | Responsabilidade | Não pode |
|---|---|---|---|
| HTTP | `router.py` | receber, validar via schema, delegar, devolver | regra de negócio, query, importar `models` |
| Regra | `service.py` | decidir, orquestrar, levantar erro de domínio | importar `fastapi` ou `sqlalchemy`, montar query |
| Dado | `repository.py` | consultar e agregar | decidir regra, levantar erro de domínio, conhecer schema |
| Tabela | `models.py` | mapear a tabela | validar entrada |

Apoio, no mesmo pacote: `schemas.py` (Pydantic, separado por direção),
`dependencies.py` (injeção), `utils.py` (função pura) e `constants.py` (constante
nomeada). **Arquivo de domínio nasce quando tem conteúdo** — `utils.py` vazio não entra
no scaffold.

## A pergunta que resolve o empate

> Se a resposta muda quando o **produto** muda de ideia, é service.
> Se muda quando o **banco** muda de forma, é repository.

"Já existe respondente com esse e-mail? Então 409" é produto. "Como eu descubro se
existe" é banco.

## Sinais de que a camada furou

| Sinal | O que está errado |
|---|---|
| `router.py` com `from ...models import` | HTTP conhecendo tabela — o mapeamento model → schema é `@classmethod` em `schemas.py` |
| `router.py` com `if` sobre dado de negócio | regra na borda; ela é do service |
| `service.py` com `select(`, `session.` ou `self.db` | service montando query |
| `service.py` importando `fastapi` | regra sabendo o que é status code — levante exceção de `app/shared/exceptions.py` |
| `service.py` recebendo `Request` | idem, na forma mais direta |
| `repository.py` levantando `NotFoundError` | dado decidindo regra — devolva `None` e deixe o service decidir |
| `repository.py` importando `schemas` | dado conhecendo contrato de saída |
| `.sum()` ou `for` somando lista no service | agregação em Python: é `SUM`/`GROUP BY` no repository (`../context/arquitetura.md` regra 1) |
| endpoint devolvendo lista crua onde a tela mostra total | agregação empurrada para o front |
| `commit()` fora de `core/database.py` | quem fecha a transação é a requisição, não a camada |
| `from app.domains.<outro>` fora do caso permitido | acoplamento entre domínios — ver "Leitura entre domínios" |

A regra prática, igual à do front: **cada arquivo tem um motivo para mudar.** Se trocar
o banco obriga a mexer no service, a camada furou.

## Nome do método diz de qual camada é

`estrutura-e-nomes.md` já manda domínio em português e técnico em inglês.
Aplicado a método, isso vira um sinal de leitura imediata — e é o que o molde já faz:

| Camada | Idioma | Exemplos no molde |
|---|---|---|
| `service.py` | português | `obter`, `listar`, `criar`, `atualizar`, `remover` |
| `repository.py` | inglês | `get_by_id`, `get_by_email`, `list_paginated`, `create`, `delete` |

Método em português é operação de negócio; em inglês, operação técnica. Método de
service em inglês costuma ser regra que vazou para o lugar errado.

## Transação: quem fecha

Ninguém, explicitamente. `get_db()` em `app/core/database.py` dá `commit` ao fim da
requisição e `rollback` em qualquer exceção. **A unidade de trabalho é a requisição
HTTP.**

| Camada | Faz |
|---|---|
| `repository.py` | `flush()` quando precisa do id gerado; **nunca** `commit()` |
| `service.py` | nada — não abre nem fecha transação |
| `router.py` | nada |

Efeito que precisa estar escrito: `RespondenteService.atualizar()` muda os atributos do
objeto e **não chama o repository** — a persistência acontece no commit do `get_db`. É
idiomático em SQLAlchemy e surpreende quem lê pela primeira vez, então o método leva um
comentário de **por quê** (`nivel-de-codigo.md` §5).

## Cálculo puro sai do service

Função sem repository, sem sessão e sem I/O mora em `utils.py` do domínio, não no
`service.py`. O service usa; quem mais precisar, também. `calcular_idade()` é o caso do
molde.

O teste de três perguntas, para saber se é mesmo util:

- Precisa de sessão de banco? Não é util — é **repository**.
- Precisa decidir alguma coisa do negócio? Não é util — é **service**.
- Precisa de `settings` ou de rede? Não é util — é **core** ou **serviço externo**.

## Onde mora o compartilhado

| O quê | Onde | Quando criar |
|---|---|---|
| Função pura de um domínio só | `app/domains/<x>/utils.py` | **padrão** — é aqui que tudo nasce |
| Constante nomeada de um domínio só | `app/domains/<x>/constants.py` | no primeiro número solto com significado |
| Vocabulário de erro | `app/shared/exceptions.py` | já existe — use, não crie exceção nova de domínio sem necessidade |
| Paginação | `app/shared/paginacao.py` | `PaginaDe[T]`, espelho do `ListaPaginada<T>` do front |
| Qualquer outro compartilhado | `app/shared/<assunto>.py` | no **segundo** domínio que precisar |
| Config, sessão, segurança de webhook | `app/core/` | é fundação, não util — e não conhece domínio nenhum |

**Regra dos dois usos**, a mesma do front: o primeiro uso mora no domínio, o segundo
sobe para `shared/`. Subir cedo demais cria util que ninguém acha; subir tarde demais
cria duas versões da mesma função.

**`app/shared/utils.py` é proibido.** Arquivo utilitário global sem assunto é onde
código vai para não ser encontrado: em seis meses tem 400 linhas, quatro donos e nenhum
teste. Se você não consegue nomear o **assunto** do arquivo em uma palavra, a função
ainda não subiu de andar — ela fica no domínio.

A seta aponta sempre para baixo: `domains/` → `shared/` → `core/`, e
`domains/` → `external_services/`. `core/` não sabe que domínio existe.

## Serviços externos

Serviço externo é pacote **irmão** de `domains/`, com a forma de um domínio menos o que
ele não tem — sem rota, sem tabela, sem regra:

```
app/external_services/n8n/
├── client.py        # class N8NClient: httpx, timeout de settings, tradução de erro
├── schemas.py       # payload de ida e de volta, no vocabulário do provedor
└── exceptions.py    # N8NIndisponivel(DomainError)
```

| Regra | Por quê |
|---|---|
| O client não sabe o que é um prognóstico | traduzir CREED ↔ provedor é trabalho do `service.py` do domínio dono |
| Só o `service.py` chama, injetado por `dependencies.py` | router nunca chama client; nada de instanciar client em nível de módulo |
| Timeout obrigatório, vindo de `settings` | chamada sem timeout é o pod pendurado esperando serviço que já morreu |
| Erro de biblioteca morre no client | o que sai do client é `N8NIndisponivel`, não `httpx.HTTPError` |
| Cair não derruba a requisição do usuário | a esteira é assíncrona por decisão de arquitetura: falha ao disparar é **estado do domínio** (com reenvio possível), não 500 na cara de quem clicou |
| Teste não toca a rede | client fake, do mesmo jeito que o repository fake |

**O caminho de volta não mora aqui.** O webhook que o provedor chama é rota do domínio
dono (`prognosticos/router.py`) — quem entra pela porta HTTP entra pelo domínio, sempre.
A verificação do `N8N_CALLBACK_SECRET` é dependency e mora em `app/core/security.py`,
porque vale para qualquer webhook futuro.

**`flows.py` está adiado** (ADR-0004, item 5). Orquestração de vários passos fica no
`service.py` até um método passar de três efeitos colaterais externos.

## Leitura entre domínios

`../context/arquitetura.md` tem duas regras que colidem no primeiro dashboard:
"agregação no banco" e "domínio não importa model de outro". O ADR-0004 (item 4) decidiu
assim:

| Operação | Domínio de leitura (`dashboards`, `relatorios`) | Demais domínios |
|---|---|---|
| `SELECT` / `JOIN` em tabela de outro domínio | **permitido** | não |
| `INSERT` / `UPDATE` / `DELETE` fora do próprio domínio | **nunca** | nunca |
| Escrita em outro domínio | pelo `service.py` do dono | pelo `service.py` do dono |

A permissão é declarada, não tácita: comentário no topo do `repository.py` dizendo quais
tabelas alheias ele lê e por quê, mais a entrada na lista de exceções de
`tests/test_arquitetura.py`.

O custo aceito é acoplamento por schema — migration em `respondentes` pode quebrar
`dashboards` sem o diff mostrar. É por isso que query de domínio de leitura **precisa**
de teste de repository contra banco real (`testes.md`), não de mock.

## A checagem que não depende de review

As regras acima são verificáveis por `grep`, então moram em
`creed-backend/tests/test_arquitetura.py` e quebram o CI — em vez de o revisor precisar
lembrar:

```bash
grep -rn "fastapi\|sqlalchemy\|select(\|self\.db" app/domains/*/service.py     # vazio
grep -rn "\.models import\|sqlalchemy"            app/domains/*/router.py      # vazio
grep -rn "shared.exceptions\|HTTPException"       app/domains/*/repository.py  # vazio
grep -rn "commit()" app --include=*.py                     # só app/core/database.py
test ! -f app/shared/utils.py
```

Exceção legítima entra na **lista de permitidos do próprio teste**, com o motivo escrito
ao lado — que é o oposto de descobrir a exceção seis meses depois lendo o diff. Se a
lista passar de umas poucas linhas, o sinal não é afrouxar o teste: é que a fronteira
está no lugar errado.

## Dívida conhecida do molde

O `respondentes` é exemplo de scaffold, não código nascido de tarefa, e mostra a idade
em três pontos — todos endereçados no PR de correção do molde (ADR-0004, item 7):

- `router.py` importa `models` e importa `calcular_idade` direto do módulo do service,
  por causa do helper `_to_response()`. É exatamente o sinal de camada furada que a
  tabela acima lista, no arquivo que o time copia.
- `RespondenteListResponse` repete `itens`/`total`/`pagina`/`tamanho_pagina`, que todo
  domínio que lista vai copiar. Vira `PaginaDe[RespondenteResponse]`.
- `calcular_idade()` está no `service.py`, e é função pura — vai para `utils.py`.

Até o PR entrar, **o molde é canônico na estrutura** (camadas, nomes, injeção, separação
de schema por direção) e dívida nesses três pontos. Não refatore de passagem: escopo
fechado (`../context/trabalho-com-ia.md`, regra 4).

**O molde inclui os testes dele.** `tests/test_respondentes_service.py` também saiu do
scaffold: mostra a **forma** do teste de regra sem banco, e não é cobertura conquistada
por nenhuma task. Vale como exemplo de como escrever o seu; não vale como prova de que a
separação de camadas já está pagando — isso só aparece no primeiro domínio nascido de
tarefa real.

E a dívida que não é do molde: `respondentes` é **forma**, não contrato. `regiao`,
`pais` e `genero` são exemplo plausível, não campo acordado com a cliente. Campo novo é
decisão de produto e vira premissa no ledger (`contrato-front-back.md`).
