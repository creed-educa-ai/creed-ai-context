# ADR-0004 — Camadas do backend: o que veio do Dispatch e o que é nosso

- **Status:** Proposto
- **Data:** 2026-09-01
- **Decidem:** time CREED

## Contexto

O `creed-backend` nasceu com organização **por domínio** (`app/domains/<nome>/`), forma
descrita como "a arquitetura da Netflix". A cadeia real é de três elos, e cada um trouxe
uma coisa diferente:

| Elo | O que é | O que veio dele |
|---|---|---|
| **Netflix Dispatch** | ferramenta de gestão de incidentes da Netflix, em FastAPI, aberta | a ideia central: pacote por domínio, não pasta por tipo de arquivo |
| **`zhanymkanov/fastapi-best-practices`** | repositório que popularizou a forma; diz textualmente que se inspirou no Dispatch "com pequenas modificações" | a lista de arquivos que usamos (`router`, `service`, `schemas`, `models`, `dependencies`) e as que ainda não usamos (`utils`, `constants`, `config`, `exceptions`, `client`) |
| **creed-backend** | o nosso | a forma, mais três adições próprias |

O fato que motiva este ADR: **o `repository.py` não vem da Netflix.** Em
`src/dispatch/incident/` existem `service.py`, `flows.py`, `views.py`, `models.py`,
`enums.py`, `scheduled.py`, `messaging.py` e `metrics.py` — e nenhum `repository.py`.
Lá o `service.py` **é** a camada de acesso a dado: funções de módulo
(`get(db_session, incident_id)`, `create(db_session, incident_in)`) com a query dentro.

Nós enxertamos três coisas na forma do Dispatch, todas pelo mesmo motivo —
testabilidade:

| Assunto | Dispatch | creed-backend |
|---|---|---|
| Acesso a dado | dentro do `service.py` | separado em `repository.py` |
| Forma do service | funções de módulo com `db_session` no argumento | classe com repository injetado no construtor |
| SQLAlchemy | legado (`db_session.query()`), síncrono | 2.0 (`select()`), async com asyncpg |

A consequência é a razão de existir deste documento: **a pergunta que mais aparece no
review — "isso é service ou repository?" — não pode ser respondida lendo o Dispatch,
porque lá a pergunta não existe.** Ela vem da tradição DDD, e nunca foi registrada em
lugar nenhum como decisão nossa. O `context/backend.md` descreve o resultado; ninguém
escreveu por que, nem o que fazer com o que a tabela não cobre.

O que a tabela não cobre, e já está batendo na porta:

- **Utils.** Não existe `utils.py` em domínio nenhum e não há regra de quando algo sobe
  para `app/shared/` — que hoje tem só `exceptions.py`.
- **Serviços externos.** `N8N_WEBHOOK_URL`, `N8N_CALLBACK_SECRET` e
  `N8N_TIMEOUT_SECONDS` estão em `core/config.py` e `httpx` está no `pyproject.toml`
  desde o scaffold. Nenhuma linha usa os dois, e não há lugar definido para o client.
- **Leitura entre domínios.** `context/arquitetura.md` tem duas regras que colidem no
  primeiro dashboard: "agregação no banco" e "domínio não importa model de outro". Um
  dashboard que cruza respondentes, prismas e prognósticos não consegue obedecer as duas.
- **O molde contradiz a convenção.** `context/backend.md` diz que o sinal de camada
  furada é "`router.py` importando `models`", e
  `app/domains/respondentes/router.py` faz exatamente esse import, por causa do helper
  `_to_response()`. Quem copia o molde entra em conflito com a regra sem ter errado.

## Decisão

**1. A separação em quatro camadas fica, e passa a ser decisão registrada, não herança
de scaffold.** `router` → `service` → `repository` → `models`, com o service como classe
recebendo suas dependências no construtor. O critério de corte, escrito para o review:

> Se a resposta muda quando o **produto** muda de ideia, é service.
> Se muda quando o **banco** muda de forma, é repository.

**2. Regra de colocação: local por padrão, sobe no segundo uso, e sobe com nome de
assunto.** Código novo nasce na pasta do domínio que o usa. O segundo domínio que
precisar da mesma coisa move para `app/shared/<assunto>.py` — mesma "regra dos dois usos"
do front (`../../conventions/camadas-do-front.md`). **`app/shared/utils.py` fica proibido:**
o que protege o `shared/` de virar depósito não é a contagem de usos, é a exigência de
nomear o assunto em uma palavra.

**3. Serviço externo é pacote irmão de `domains/`**, com a forma de um domínio menos o
que ele não tem (sem rota, sem tabela, sem regra):

```
app/external_services/n8n/
├── client.py        # httpx, timeout de settings, tradução de erro
├── schemas.py       # payload de ida e de volta, no vocabulário do provedor
└── exceptions.py    # N8NIndisponivel(DomainError)
```

Chamado só pelo `service.py` do domínio dono, injetado por `dependencies.py`. O webhook
de volta é rota do **domínio**, não do `external_services/`.

**4. Leitura entre domínios: permitida no repository de domínio de leitura; escrita,
nunca.** `dashboards` e `relatorios` podem fazer `JOIN` e ler models de outros domínios
para agregar em SQL. Não podem inserir, atualizar nem apagar fora do próprio domínio, e
a permissão é declarada em duas linhas — comentário no topo do repository e entrada na
lista de exceções do teste de arquitetura. Escrita continua passando pelo `service.py`
do dono.

**5. `flows.py` fica adiado.** Orquestração de vários passos continua no `service.py` até
um método passar de três efeitos colaterais externos.

**6. As regras de camada viram teste, não lembrança do revisor.**
`creed-backend/tests/test_arquitetura.py` verifica por `grep` que o service não importa
`fastapi` nem `sqlalchemy`, que o router não importa `models`, que o repository não
levanta exceção de domínio, que ninguém dá `commit()` fora do `get_db`, e que
`app/shared/utils.py` não existe. Exceção legítima entra na lista de permitidos do
próprio teste, com o motivo escrito ao lado.

**7. O molde é corrigido em um PR só, antes do primeiro domínio real.** O
`_to_response()` sai do `router.py` e vira `RespondenteResponse.de_model()` em
`schemas.py`; `calcular_idade()` sai do `service.py` e vira `utils.py` do domínio;
`RespondenteListResponse` vira `PaginaDe[RespondenteResponse]` de
`app/shared/paginacao.py`, espelho do `ListaPaginada<T>` do front. É o único momento em
que mudar o molde custa um arquivo em vez de seis.

## Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| Dispatch puro: acesso a dado dentro do `service.py` | É a forma original, e é mais simples. Mas amarra toda regra a uma sessão de banco: o cálculo dos 5 prismas passaria a exigir Postgres para ser testado, sendo que é aritmética sobre dado já carregado. O que o repository separado dá é poder testar a regra com um fake — **propriedade do desenho, ainda não exercida por task nenhuma**: o teste de service que existe hoje também saiu do scaffold |
| Voltar atrás no repository para "seguir a referência" | Seis domínios já têm o arquivo criado. Reverter agora é mexer em tudo para ficar mais parecido com um projeto que não é o nosso |
| Leitura entre domínios via view de banco versionada em migration (A2) | Fronteira mais nítida e é para onde queremos ir. Cara cedo demais: mais uma coisa para o time aprender e versionar, sem nenhum dashboard escrito ainda. Migrar de A1 para A2 depois é trocar o `select()` do repository, sem tocar em service nem router |
| Leitura entre domínios estrita: composição só via service (A3) | Obriga a agregar em Python, que é exatamente o que `../../context/arquitetura.md` regra 1 proíbe. Contradiz decisão de arquitetura já tomada |
| `app/shared/utils.py` global | Em seis meses tem 400 linhas, quatro donos e nenhum teste. É o arquivo onde código vai para não ser encontrado |
| Sistema de plugins para integração externa, como o Dispatch | O Dispatch tem `plugins/` porque integra Slack, Jira, PagerDuty e mais. Nós temos um provedor. Registry com uma opção é o que `../../conventions/nivel-de-codigo.md` §3 barra |
| `flows.py` desde já | Abstração para um caso de uso só. O prognóstico é o único fluxo de vários passos previsto, e ele ainda não existe |
| Criar os sete arquivos vazios em todos os domínios | `utils.py` vazio é ruído no diff e no `grep`. Arquivo de domínio nasce quando tem conteúdo |
| Deixar as regras de camada só na convenção escrita | É o estado atual, e produziu um molde que viola a própria convenção sem ninguém notar |
| Corrigir o molde junto com a primeira feature | Mistura refactor com entrega no mesmo diff e adia a correção para depois da primeira cópia do furo |

## Consequências

**Boas:**

- A pergunta "service ou repository?" tem resposta escrita, e o teste responde antes do
  review.
- `dashboards` e `relatorios` deixam de estar bloqueados por regra contraditória.
- O client do N8N tem endereço antes de existir, então não vai nascer dentro de um
  service.
- Toda regra desta decisão é verificável por `grep`, o que a mantém viva quando o time
  crescer.
- O molde volta a concordar com o que a convenção diz sobre ele.

**Ruins — e aceitas:**

- **Acoplamento por schema.** Com A1, migration em `respondentes` pode quebrar
  `dashboards` sem que o diff mostre. Mitigação: teste de repository contra banco real
  (`../../conventions/testes.md`), que é onde isso aparece vermelho.
- **Um arquivo a mais por domínio** em relação ao Dispatch, e uma pergunta a mais no
  review. É o preço do teste sem banco, e foi cobrado no momento em que a decisão foi
  tomada — este ADR só registra.
- **A lista de exceções do teste de arquitetura vai crescer.** Se passar de umas poucas
  linhas, o sinal não é afrouxar o teste: é que a fronteira está no lugar errado e A2
  entrou na hora.
- **Um PR de infraestrutura sem comportamento novo** (item 7), o que contraria o corte
  por fatia vertical. Aceito uma vez, por ser correção de molde.

## Pendência herdada: a numeração dos ADRs

`models.py`, `service.py`, `repository.py`, `router.py`, `config.py`, `database.py`,
`main.py`, o `README.md` do backend, o `catalogo.md` e três READMEs do front citam
**ADR-001**, **ADR-002** e **ADR-003** com número de seção ("ADR-002 §2.2",
"ADR-001 §4.1"). Em `decisoes/adrs/` existem só `0001-harness-multi-llm` e
`0002-mcp-do-clickup-no-setup` — documentos diferentes, mesmos números. Quem seguir a
referência não acha nada, ou acha o ADR errado.

Este ADR **não** resolve isso: entra como 0004 no espaço de numeração existente e
registra a pendência. As duas saídas são escrever os ADRs 001–003 que o código
pressupõe (stack, organização interna, front) ou renumerar as citações — decisão de
reunião, não de PR.

## Como reverter

Cada item é independente:

- Itens 1 e 2 são regra escrita: reverter é apagar `conventions/camadas-do-back.md` e a
  seção correspondente do `context/backend.md`.
- Item 4 (A1) reverte para A2 trocando o `select()` dos repositories de leitura pela
  leitura de uma view; service e router não mudam.
- Item 6 reverte apagando `tests/test_arquitetura.py`. Nenhum outro teste depende dele.
- Item 7 é um PR: reverter é `git revert`.

Nenhum item cria dependência nova nem passo de build.
