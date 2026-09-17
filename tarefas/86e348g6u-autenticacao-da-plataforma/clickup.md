# CREED-23 — rascunho de publicação no ClickUp

```
Épico: 86e348g6u — CREED-23 [Autenticação] Estruturar autenticação da plataforma
Spec: spec.md · Tasks: tasks.md · Contrato: contrato-api.md
Gerado em: 2026-09-17 · Publicado em: 2026-09-17 (épico + 7 subtarefas)
Anexos: 2026-09-17 — 8 arquivos subidos; 5 descrições corrigidas de ⬜ para ✅
```

## Mapa de publicação

| # | Subtarefa no board | Repo | Ação | ID |
|---|---|---|---|---|
| — | CREED-23 (épico) | — | ✅ publicado — substituída por versão de produto; a anterior tinha P-007 (refutada) e `temporary_password` | `86e348g6u` |
| 1 | CREED-23.1 - Review do banco e criação de entidades e estruturas base para feature | back | ✅ publicado — descrição preenchida | `86e34y3k3` |
| 2 | CREED-23.2 - Subir Keycloak no ambiente local com realm versionado | back | ✅ publicado — descrição preenchida | `86e34yf89` |
| 3 | CREED-23.3 - Criar domínio users com provisionamento no Keycloak e seed do primeiro admin | back | ✅ publicado — descrição preenchida | `86e34yf97` |
| 4 | CREED-23.4 - Criar domínio authentication e a guarda de rota compartilhada | back | ✅ publicado — descrição preenchida | `86e34yfae` |
| 5 | CREED-23.5 - Gerir a sessão autenticada no front (armazenamento + apiClient) | front | ✅ publicado — descrição preenchida | `86e34yfba` |
| 6 | Tela de login e proteção de rota no front | front | ✅ publicado + renomeado para `CREED-23.6 - …` | `86e34yfct` |
| 7 | Nível de acesso por tela no front | front | ✅ publicado + renomeado para `CREED-23.7 - …` | `86e34yfdm` |

### Não tocar — reportado, não alterado

| Subtarefa | ID | Por quê |
|---|---|---|
| CREED-23.8 - Convite de primeiro acesso por e-mail | `86e35vhxm` | Não é uma das 7 entregas de `tasks.md`; está lá como "fora do escopo desta rodada" |
| Renumerar as premissas duplicadas P-003 e P-004 do ledger | `86e35wea4` | Tarefa de processo, não sai da decomposição |

### Exceção aplicada nesta rodada

Nenhuma das 7 subtarefas tem a linha `Rastreio:` — elas foram criadas à mão antes de este
fluxo existir. A regra padrão manda **não tocar** em subtarefa sem rastreio. A correspondência
aqui foi feita **por título**, e a exceção é explícita: o pedido foi reescrever as tarefas do
CREED-23. Todas as sete recebem a linha de rastreio nesta passada, e a partir da próxima o
fluxo volta à regra normal.

### Estado real das entregas — levantado em 2026-09-17

Cinco entregas estão `finalizado - sprint` e a 6 está em branch. A descrição de uma entrega
concluída continua valendo: é contra ela que se confere o que foi entregue. Onde o código
divergiu do acordado, a divergência está escrita na própria subtarefa, e a fonte é o quadro
"Estado real — 2026-09-14" de `contrato-api.md`.

| # | Status no board | Código |
|---|---|---|
| 1, 2, 3, 4 | finalizado - sprint | na `dev` do `creed-backend` (PR #12 mergeado) |
| 5 | finalizado - sprint | na `dev` do `creed-frontend` (PR #20 mergeado) |
| 6 | to do | **em branch** `feat/86e34yfct-tela-login-e-protecao-rota` — `LoginView.tsx` e `ProtectedRoute.tsx` já existem |
| 7 | to do | não começou |

## Materiais — visão do épico

| Material | Onde está | Vai em | Situação |
|---|---|---|---|
| `creed-23-openapi.yaml` | anexo do épico CREED-23 | 3, 4, 5, 6 | ✅ anexado no épico |
| `creed-23-payloads.json` | anexo do épico CREED-23 | 5, 6 | ✅ anexado no épico |
| Contrato completo (`contrato-api.md`) | `tarefas/86e348g6u-.../contrato-api.md` | 3, 4, 5, 6 | ✅ anexado como `creed-23-contrato-api.md` |
| Correções do DBML (`correcoes-dbml-auth.md`) | `tarefas/86e348g6u-.../correcoes-dbml-auth.md` | 1 | ✅ anexado como `creed-23-correcoes-dbml-auth.md` |
| Modelo de dados proposto (`context/modelo-de-dados.proposta.dbml`) | fora da pasta da tarefa | 1 | ✅ anexado |
| Mock: README e docker-compose | `tarefas/86e348g6u-.../mock/` | 5 | ✅ anexados |
| Diagrama do modelo de dados (link dbdiagram.io) | fora do repositório | 1 | ⬜ falta o link — **AGES III** |
| Protótipo da tela de login (Figma) | fora do repositório | 6 | ⬜ falta o link — **AGES III** |
| Desenho do menu e do que cada papel vê | não existe ainda | 7 | ⬜ **falta produzir** — AGES III/IV |
| Textos das premissas P-006, P-008, P-009, P-010, P-012, P-013 | `decisoes/premissas.md` | 1, 2, 3, 4, 6, 7 | ✅ colados no corpo de cada subtarefa |
| Definição de "vínculo", "organização", "respondente" | `glossario.md` + modelo de dados | épico, 3, 4, 7 | ✅ colada no corpo |

---

# Parte 2 — descrição do épico (`86e348g6u`)

## O que é

Hoje **qualquer pessoa com o endereço da plataforma vê qualquer tela e consegue chamar
qualquer parte do sistema**. Não existe login, não existe sessão, e o nível de acesso que
a interface usa para decidir o que mostrar é um valor fixo escrito no código.

Este épico coloca o portão: uma tela de login, uma sessão que sobrevive a recarregar a
página, e a regra de **quem pode ver e fazer o quê** aplicada dos dois lados — na interface
e no servidor. Ele também entrega a peça reaproveitável: depois dele, proteger uma tela nova
ou um serviço novo deixa de ser trabalho de autenticação e passa a ser uma linha.

Enquanto isso não existe, nenhuma tela pode mostrar dado real de uma pessoa respondente — a
plataforma inteira fica presa em dado de mentira.

## Para quem, e o que muda para essa pessoa

Três níveis de acesso. "Vínculo" é a ligação de uma pessoa com uma organização, com um papel
e um período — é sempre ele que define o recorte do que a pessoa enxerga.

| Quem | Hoje | Depois desta entrega |
|---|---|---|
| Pessoa que responde aos instrumentos | vê qualquer tela, inclusive as de gestão | entra com e-mail e senha e vê **os formulários do vínculo dela** — nada de gestão, nada de outra pessoa |
| Gestor de uma organização | idem | vê **a organização do vínculo dele**: formulários, respostas e painéis daquela organização, e de nenhuma outra |
| Administrador | idem | tudo o que o gestor vê na organização dele, mais cadastrar acesso para outras pessoas e mudar o papel delas |
| Quem não tem vínculo | vê tudo | não entra. Não existe visitante e não existe "criar conta" |

Uma consequência que vale saber de antemão: **um login é um vínculo**. A mesma pessoa em duas
organizações tem dois acessos separados e nunca vê as duas ao mesmo tempo. Isso não é limitação
da autenticação — é como o modelo de dados foi fechado pelo time em 04/09/2026.

## O que entra nesta rodada

- Tela de login, tela de "acesso negado", e a sessão que não cai quando a pessoa recarrega.
- Cadastro de acesso pelo servidor: criar, ativar e desativar o acesso de uma pessoa, e
  mudar o papel dela.
- A senha guardada por um serviço dedicado a isso (Keycloak), nunca no nosso banco.
- A peça compartilhada que qualquer tela ou serviço futuro usa para exigir login e nível
  de acesso.
- O primeiro administrador criado automaticamente — sem ele ninguém entra e ninguém pode
  cadastrar.

## O que não entra — e por quê

- **Telas de gestão de usuário** (listar, criar e editar acesso pela interface) — o épico
  entrega o servidor; a tela é tarefa própria, depois.
- **"Esqueci minha senha"** — não existe envio de e-mail na plataforma. Quem perde a senha
  pede a um administrador.
- **Criar a própria conta** — todo acesso nasce de alguém com papel de administrador.
- **Segundo fator, login com Google, login da PUCRS** — nada disso agora.
- **Registro de quem entrou e quando** — há log técnico, não há tabela de auditoria.
- **Trocar de organização sem sair** — são dois acessos distintos, por decisão do modelo.
- **Permissão item a item** ("este gestor só vê estes três formulários") — o recorte desta
  entrega é papel + organização, não objeto por objeto.
- **Subir o Keycloak na nuvem** — tudo roda em ambiente local nesta rodada. O time está
  priorizando o que a cliente vê, e deploy não é isso. Fica registrado como trabalho
  conhecido, sem tarefa no board.

## Como decidimos fazer — uma linha cada

Seis decisões técnicas que moldaram as sete entregas. Elas estão aqui porque explicam por que
as subtarefas têm a forma que têm; o detalhe de cada uma está na subtarefa correspondente.

| # | A decisão | O que ela nos dá |
|---|---|---|
| D1 | A tela de login é nossa; ela manda e-mail e senha para o **nosso** servidor, que conversa com o Keycloak por baixo (*Direct Access Grant*) | a interface nunca sabe que o Keycloak existe — trocar essa peça depois mexe em uma tela e um arquivo, não em todas as telas |
| D2 | O crachá (*token*) abre a porta; o banco confirma o dado quando ele é preciso | recusa acesso sem consultar o banco na maioria das rotas, e ainda pega o caso em que crachá e banco discordam |
| D3 | O servidor **confere** o crachá emitido pelo Keycloak, não emite crachá próprio | um emissor só, uma expiração só — e "sair" significa a mesma coisa nos dois lados |
| D4 | O papel mora no nosso banco; o Keycloak recebe uma cópia | uma fonte da verdade. Se gravar no nosso banco falhar, o usuário criado lá é apagado na volta |
| D5 | Nada de estrutura nova: cada peça já tem endereço definido nas decisões de arquitetura do projeto | ninguém precisa inventar onde as coisas moram |
| D6 | No site, **um único arquivo** guarda e lê a sessão; nenhuma tela toca no armazenamento do navegador | trocar a forma de guardar depois é reescrever um arquivo, sem encostar nas telas |

## Decisões que tomamos sem a cliente

Registradas por escrito para poderem ser derrubadas na próxima reunião. Nenhuma foi
confirmada com ela.

| O que decidimos | Por quê | Custo de mudar depois |
|---|---|---|
| Os papéis são **administrador, gestor e respondente** | é a lista do diagrama de dados, feito em time. A outra lista que circulava (`admin`/`funcionário`) nasceu de um ensaio que nunca virou código | **baixo hoje, alto depois.** É a decisão mais urgente do épico: hoje nenhum dos dois lados tem uma linha atrás. Depois, mudar é migração de banco + refazer toda a guarda de acesso + reconfigurar o Keycloak |
| **Não existe autocadastro.** Todo acesso nasce da cadeia organização → participante → vínculo → usuário, criada por um administrador | é consequência direta do modelo: usuário não nasce antes do vínculo. Tela pública de "criar conta" abriria a plataforma para quem não tem vínculo nenhum | baixo |
| **"Esqueci minha senha" fica de fora.** Quem perde a senha pede a um administrador | não existe serviço de e-mail na arquitetura | médio |
| A sessão dura **15 minutos**, renovável por até **8 horas** (um turno de trabalho) | prazo curto limita o estrago de um crachá vazado, e 8h cobre um dia sem relogar | baixo — é configuração, não código |
| O **primeiro acesso não passa pela plataforma**: o convite será um e-mail com link para a página do Keycloak, onde a pessoa define a própria senha. Enquanto o e-mail não existir, o administrador define uma senha definitiva e passa por fora | o Keycloak já resolve o fluxo inteiro, então a plataforma nunca precisa de tela de troca de senha — nem hoje, nem depois | baixo. **Substituiu** a decisão anterior, de senha temporária com troca obrigatória no primeiro login, derrubada em 08/09/2026 |
| O acesso **nasce ativo**: quem é cadastrado já consegue entrar, sem segundo passo de ativação | é o que a decisão acima pressupõe — o administrador cria e passa a senha em seguida | baixo |

> ⚠️ **A descrição anterior deste épico ainda descrevia senha temporária com troca obrigatória
> no primeiro login.** Aquela decisão foi derrubada em 08/09/2026 e está substituída acima.

## As entregas

| # | Entrega | Onde | Depende de |
|---|---|---|---|
| 1 | Inaugurar o banco — modelo, entidades e a primeira migração | servidor | — |
| 2 | Keycloak no ambiente local, com a configuração em arquivo versionado | servidor | — |
| 3 | Cadastro de acesso: criar usuário nos dois lados + primeiro administrador | servidor | 1 e 2 |
| 4 | Login, renovação, saída e a guarda de acesso compartilhada | servidor | 3 |
| 5 | Sessão no site: onde o crachá mora e como ele viaja | site | contrato acordado |
| 6 | Tela de login e proteção das rotas | site | 5 |
| 7 | O que cada papel enxerga em cada tela | site | 6 |

**1 e 2 correm em paralelo** — o Keycloak local não precisa do nosso banco, e o banco não
precisa dele. **3 precisa das duas; 4 precisa da 3.** **5 e 6 não esperam a 4 terminar**:
programam contra o contrato acordado, que é exatamente para isso que ele existe. **7 fecha
atrás da 6.**

## Materiais desta tarefa

- ✅ `creed-23-openapi.yaml` — os formatos de requisição e resposta, literais
- ✅ `creed-23-payloads.json` — exemplos nomeados de cada chamada
- ⬜ Contrato completo em texto (`contrato-api.md`) — **anexar: AGES IV**
- ⬜ Link do diagrama do modelo de dados no dbdiagram.io — **anexar: AGES III**

## Rastreio

```
creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/spec.md
```

---

# Parte 3 — subtarefas

---

## 1 · `86e34y3k3` — CREED-23.1 - Review do banco e criação de entidades e estruturas base para feature

### Em uma frase

Criar, pela primeira vez, as tabelas da plataforma no banco de dados — já com as duas
correções que a autenticação exige.

### O que muda para quem usa

Ninguém usa esta entrega diretamente: ela é o chão sobre o qual as outras seis ficam de pé.
Hoje o banco tem **uma tabela só**, criada solta; organização, participante, vínculo e
usuário existem apenas no diagrama que o time desenhou.

O que muda é que, a partir daqui, toda tela pode mostrar dado real em vez de dado de mentira.
E muda uma coisa que só acontece uma vez: enquanto o banco não tem nenhuma linha gravada,
corrigir o desenho custa zero. Depois da primeira pessoa cadastrada, a mesma correção passa a
exigir migração de dado.

### Como pretendemos fazer

O diagrama do time é a fonte, mas o arquivo exportado dele **não sobe como está** — dois
pontos do export impedem o banco de ser criado. O caminho é: corrigir no dbdiagram.io →
reexportar por cima → escrever as tabelas em código, uma pasta por assunto → gerar a migração
automaticamente → **ler a migração gerada linha a linha** antes de rodar.

Duas correções entram nessa mesma passada, e não em uma migração separada:

1. **A coluna de senha sai da tabela de usuário.** A senha passa a morar só no Keycloak.
   Guardar o hash aqui também criaria duas fontes de senha e a pergunta "qual das duas vale?".
2. **Entra uma coluna com o identificador do usuário no Keycloak** (`keycloak_id`, único e
   obrigatório). É por ele que o servidor acha a pessoa a partir do crachá. Sem ele, a busca
   seria por e-mail — e e-mail é dado que muda.

Duas regras do projeto que valem aqui, e que não são negociáveis: **migração nunca roda
sozinha quando o container sobe** (é passo dedicado, antes do deploy) e **migração gerada
automaticamente é sempre revisada linha a linha**.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/<assunto>/models.py` | as tabelas, uma pasta por assunto — `organizacoes`, `users`, e as demais do diagrama |
| `alembic/versions/<hash>_*.py` | a migração de inauguração, gerada e depois lida linha a linha |
| `tests/test_arquitetura.py` | o teste que garante que nenhum assunto importa outro por dentro |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| `Base` e `get_db` | `app/core/database.py` | a base das tabelas e a sessão de banco — não crie outra |
| Tabelas de exemplo completas | `app/domains/respondentes/models.py` | copie a **forma**: como a tabela é declarada, como a chave e o índice aparecem |
| Tabela `user` já criada | migração `0b0ad39d779a` | **atenção:** ela subiu antes do diagrama e diverge dele — tem `name` e `role` como coluna e não tem o vínculo. Resolver essa divergência faz parte desta entrega |

### Pronto quando

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] A tabela de usuário **não** tem coluna de senha.
- [ ] A tabela de usuário **tem** `keycloak_id`, único e obrigatório.
- [ ] Existem índices em `keycloak_id` e `email` do usuário, e no vínculo por participante e
      por organização — são as buscas que a autenticação faz em toda requisição.
- [ ] A migração gerada foi lida linha a linha, e quem leu consegue dizer o que cada comando faz.
- [ ] `pytest tests/test_arquitetura.py` passa.

### Como verificar

```bash
docker compose up -d db
alembic upgrade head
pytest tests/test_arquitetura.py -q
```

Caso de borda que precisa passar: derrubar tudo (`docker compose down -v`) e subir de novo
reproduz exatamente o mesmo banco.

### Decisões já tomadas que valem aqui

- **Os papéis são administrador, gestor e respondente.** Se essa lista mudar depois desta
  entrega, muda o tipo da coluna de papel — ou seja, migração. É a decisão mais urgente do
  épico por causa desta tarefa.
- **A lista de palavras que ficam em português ainda está aberta** (`Vinculo`, `Setor`,
  `Prisma`, `Prognostico`, `Respondente`). Dois desses viram nome de tabela aqui, e renomear
  depois da primeira migração é apagar e recriar. **Fechar antes de começar.**

### Materiais para consumir

| Material | Situação |
|---|---|
| `creed-23-correcoes-dbml-auth.md` — o bloco de tabela já corrigido, pronto para colar no dbdiagram | ✅ anexado |
| `creed-23-modelo-de-dados.proposta.dbml` — o modelo inteiro, na versão que sobe | ✅ anexado |
| Link do diagrama no dbdiagram.io | ⬜ falta anexar — **AGES III** |
| Definições: *vínculo* = ligação de uma pessoa com uma organização, com papel e período · *organização* = instituição à qual as pessoas respondentes pertencem | ✅ acima |

### Rastreio

```
Rastreio: 86e348g6u/1 — creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/spec.md
```

---

## 2 · `86e34yf89` — CREED-23.2 - Subir Keycloak no ambiente local com realm versionado

### Em uma frase

Deixar o serviço que guarda as senhas rodando na máquina de quem desenvolve, com toda a
configuração dele escrita em arquivo — nunca clicada na tela de administração.

### O que muda para quem usa

Para quem usa a plataforma, nada muda ainda. Para o time, muda o que decide se as próximas
entregas funcionam: **a configuração de quem-pode-o-quê passa a ser arquivo versionado**.

O problema que isso evita é conhecido e caro: alguém configura clicando na tela, funciona na
máquina dele, e ninguém mais consegue reproduzir. Depois, o ambiente do time e o ambiente de
verdade ficam diferentes e ninguém sabe em quê. Com a configuração em arquivo, subir o
ambiente do zero devolve sempre a mesma coisa.

### Como pretendemos fazer

O Keycloak entra como mais um serviço no `docker-compose` que o time já usa — o mesmo arquivo
onde o banco e a esteira de IA já estão. Ele usa o mesmo Postgres, num espaço separado
(*schema* próprio), exatamente como a esteira de IA já faz hoje. Esse é o desenho a copiar.

A configuração — o *realm*, o cliente da aplicação, os três papéis e um usuário de teste —
vai num arquivo JSON versionado, importado automaticamente quando o container sobe.

**Por que no repositório do servidor e não no de infraestrutura:** o `docker-compose` do
ambiente local mora ali, junto do banco. O repositório de infraestrutura trata do ambiente de
nuvem, e subir o Keycloak na nuvem está fora do escopo desta rodada. Versionar o arquivo longe
de quem o usa todo dia é como perdê-lo.

**Uma armadilha específica, que já custou tempo de gente e precisa ser item de revisão:** se o
*realm* tiver qualquer "ação obrigatória padrão" ligada — verificar e-mail, trocar senha — o
Keycloak anexa essa ação a todo usuário novo, e o login pela nossa tela passa a ser **recusado
com "credencial inválida"**, que não é verdade. O sintoma não aponta para a causa. O arquivo do
realm precisa nascer sem nenhuma dessas ações.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `docker/keycloak/realm-creed.json` | o realm: cliente da aplicação, os três papéis, o usuário de teste |
| `docker/postgres/init-keycloak-schema.sql` | cria o espaço separado do Keycloak dentro do Postgres |
| `docker-compose.yml` | o serviço `keycloak` e o ponto de montagem do script acima |
| `app/core/config.py` | as configurações `KEYCLOAK_*` |
| `.env.example` | os campos em branco, para quem clona o projeto saber o que preencher |
| `README.md` | como subir e como conferir |
| `tests/test_realm_keycloak.py` | transforma a revisão do arquivo do realm em teste automático |
| `tests/test_config.py` | as configurações novas |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| O serviço `n8n` | `docker-compose.yml` do `creed-backend` | é o **exemplo a copiar**: serviço externo usando o Postgres compartilhado, em espaço dedicado. Copie a forma dele |
| As configurações da aplicação | `app/core/config.py` | acrescente ali; não crie um segundo lugar de configuração |

### Pronto quando

- [ ] `docker compose up` sobe com o realm **já importado** — zero cliques na tela de administração.
- [ ] Uma chamada ao endereço de token devolve um crachá para o usuário de teste que veio do arquivo.
- [ ] `docker compose down -v && docker compose up` reproduz exatamente o mesmo realm.
- [ ] O cliente `creed-backend` é confidencial e tem *Direct Access Grant* ligado — é o que a
      decisão D1 do épico exige.
- [ ] Os papéis do realm são exatamente `admin`, `gestor` e `respondente`.
- [ ] A aplicação **não sobe** se `KEYCLOAK_CLIENT_SECRET` não estiver definida. Sem valor
      padrão: segredo com valor padrão é segredo que vaza para produção.
- [ ] O realm não tem nenhuma *default required action* — a armadilha descrita acima.

### Como verificar

```bash
pytest
ruff check . && ruff format --check . && mypy app
docker compose up -d db keycloak
curl -s -X POST http://localhost:8080/realms/creed/protocol/openid-connect/token \
  -d grant_type=password -d client_id=creed-backend -d client_secret=creed-local-secret \
  -d username=dev@creed.local -d password=dev
```

Caso feliz: a resposta traz um `access_token`.
Caso de borda: sem a variável de segredo, a aplicação falha ao iniciar — e é para falhar.

### Decisões já tomadas que valem aqui

- **Os papéis são `admin`, `gestor` e `respondente`** — é essa lista que vai para o arquivo
  do realm.
- **A sessão dura 15 minutos, renovável por até 8 horas.** Os dois viram configuração de
  tempo dentro do realm.
- **O primeiro acesso não passa pela plataforma**, e é por isso que o realm não liga nenhuma
  ação obrigatória e o usuário de teste nasce com senha definitiva.

### Materiais para consumir

| Material | Situação |
|---|---|
| Documentação do Keycloak sobre importação de realm no boot | ⬜ falta o link — **AGES IV** |
| O `docker-compose.yml` atual, com o serviço `n8n` que serve de exemplo | ✅ está no próprio repositório, ao lado do arquivo que você vai editar |

### Rastreio

```
Rastreio: 86e348g6u/2 — creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/2_task.md
```

---

## 3 · `86e34yf97` — CREED-23.3 - Criar domínio users com provisionamento no Keycloak e seed do primeiro admin

### Em uma frase

Fazer o servidor saber criar, ativar e desativar o acesso de uma pessoa — gravando nos dois
lugares que precisam concordar: o nosso banco e o Keycloak.

### O que muda para quem usa

É aqui que **alguém passa a poder dar acesso a outra pessoa**. Um administrador escolhe um
vínculo que já existe (organização + papel + período), informa o e-mail, e a pessoa passa a
ter como entrar.

Três consequências que quem lê precisa saber:

- **Ninguém cria a própria conta.** O acesso sempre nasce de um administrador, em cima de um
  vínculo que já existe. Não existe tela pública de cadastro.
- **A senha não é definida pela plataforma.** No desenho de destino, a pessoa recebe um
  e-mail com link para a página do Keycloak e define a senha lá. Enquanto o envio de e-mail
  não existir, o administrador define uma senha definitiva e passa por fora — por isso o
  acesso já nasce pronto para usar, sem troca obrigatória no primeiro login.
- **Desativar o acesso é imediato.** A pessoa continua existindo no sistema, com todo o
  histórico; ela só para de conseguir entrar.

### Como pretendemos fazer

Dois lugares guardam informação sobre a mesma pessoa, e isso exige uma regra clara de quem
manda: **o papel mora no nosso banco; o Keycloak recebe uma cópia.** Toda vez que um acesso é
criado ou o papel de um vínculo muda, o servidor chama o Keycloak e ajusta lá.

A ordem da criação importa, e é esta:

```
1. cria no Keycloak       -> ele devolve o identificador (o `sub`)
2. grava no nosso banco   -> com esse identificador em `keycloak_id`
3. a gravação falhou?     -> apaga o usuário do Keycloak e propaga o erro
```

O passo 3 é feio de propósito. O caminho inverso — gravar no banco primeiro — seria mais
limpo, porque desfazer no banco é grátis e apagar no Keycloak não é; mas exigiria cravar o
identificador antes de o usuário existir lá, o que depende de detalhe de versão do Keycloak.
A compensação explícita é mais feia e mais previsível.

**O primeiro administrador é entregável desta tarefa, não improviso de cada pessoa.** Como
todo acesso precisa de um vínculo, e todo vínculo precisa de organização e participante, um
ambiente novo nasce sem ninguém que possa cadastrar ninguém. Se o time começar a criar usuário
na mão pelo banco, é sinal de que este item ficou faltando.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/users/models.py` | a tabela de usuário, já com `keycloak_id` |
| `app/domains/users/schemas.py` | os formatos de entrada e de saída, separados por direção |
| `app/domains/users/repository.py` | as consultas — buscar por `keycloak_id`, por e-mail, listar por organização |
| `app/domains/users/service.py` | a regra: a ordem de criação, a compensação, o espelhamento do papel |
| `app/domains/users/router.py` | as rotas HTTP |
| `app/external_services/keycloak/client.py` | as chamadas ao Keycloak (criar usuário, ajustar papel, apagar) |
| `app/external_services/keycloak/exceptions.py` | o erro de "Keycloak fora do ar", separado dos demais |
| `scripts/seed_admin.py` (ou equivalente) | o primeiro administrador |
| `tests/domains/users/` | regra com o Keycloak simulado; consultas contra banco real |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| `NotFoundError`, `ConflictError`, `ValidationError` | `app/shared/exceptions.py` | os erros padronizados — não crie exceção própria para "não encontrado" |
| Envelope de lista paginada | `app/shared/paginacao.py` | a resposta de listagem — não escreva outro envelope |
| Um assunto completo, de ponta a ponta | `app/domains/respondentes/` | copie a **forma**: quais arquivos existem, o que cada camada faz, como a dependência é injetada. **Não copie os campos** — aqueles são de exemplo e não foram acordados com ninguém |

Onde fica cada coisa, e este é o corte que a revisão vai procurar: **se a resposta muda quando
o produto muda de ideia, é `service.py`; se muda quando o banco muda de forma, é
`repository.py`.** O `service.py` não conhece HTTP nem banco; o `repository.py` não tem regra
de negócio e nunca confirma transação sozinho.

### Contrato

| Método | Rota | Quem pode | Entrada | Saída |
|---|---|---|---|---|
| POST | `/api/v1/users` | administrador | `UserCreate` | `User` · 201 |
| GET | `/api/v1/users` | administrador | `organization_id`, `role`, `page`, `page_size` | `Page<User>` · 200 |
| PATCH | `/api/v1/users/{user_id}` | administrador | `UserUpdate` | `User` · 200 |

```
UserCreate  { vinculo_id, email, initial_password }
UserUpdate  { status? }
User        { id, email, status, role, vinculo_id, organization_id, created_at }
Page<T>     { items, total, page, page_size }
```

Três observações que evitam erro de transcrição:

- **`role` e `organization_id` são derivados** — vêm do vínculo, não de coluna da tabela de
  usuário. Aparecem na leitura e **não** aparecem na criação.
- **Não existe `role` na criação.** O papel é do vínculo, e o vínculo já existe quando o
  acesso é criado. Mandar `role` no POST é sinal de ter entendido o modelo ao contrário.
- **A listagem é sempre recortada pela organização de quem chama.** Pedir a organização de
  outra pessoa responde 403.

**Erros**

| Código | Quando |
|---|---|
| 403 | quem chama não é administrador, ou pediu dado de outra organização |
| 404 | o vínculo ou o usuário não existe — **ou é de outra organização** (dizer "existe, mas não é sua" vaza cadastro alheio) |
| 409 | o e-mail já tem acesso |
| 422 | o corpo não bate com o formato, ou a senha foi recusada pela política do realm |
| 503 | o Keycloak está fora do ar — **nunca** "senha inválida" |

### Pronto quando

- [ ] Criar um acesso cria a linha no nosso banco **e** o usuário no realm, com o papel do vínculo.
- [ ] Se a gravação no banco falhar, o usuário **não** fica órfão no Keycloak.
- [ ] Mudar o papel de um vínculo reflete no Keycloak, e a requisição seguinte já usa o papel novo.
- [ ] A senha é criada como **definitiva** (`temporary: false`) — senão o Keycloak exige troca
      no primeiro login e o login da nossa tela é recusado com "credencial inválida", que é mentira.
- [ ] Existe um primeiro administrador criável por comando, com a cadeia inteira
      (organização → participante → vínculo → usuário).
- [ ] O acesso nasce ativo.
- [ ] `ruff check . && mypy app && pytest` verdes.

### Como verificar

```bash
docker compose up -d db keycloak
alembic upgrade head
python -m scripts.seed_admin
pytest tests/domains/users -q
```

Casos que precisam existir no teste: criação feliz · falha na gravação do banco, conferindo
que o Keycloak ficou limpo · e-mail repetido · Keycloak fora do ar.

### Decisões já tomadas que valem aqui

- **Não existe autocadastro** — todo acesso nasce de um administrador, sobre um vínculo existente.
- **O primeiro acesso não passa pela plataforma.** No destino, é e-mail com link para a página
  do Keycloak; no interim, senha definitiva pelo administrador. É daqui que sai o
  `temporary: false`.
- **O acesso nasce ativo** — sem segundo passo de ativação.
- **Os papéis são administrador, gestor e respondente.**

### O que esta tarefa não resolve, e alguém vai esbarrar

**Não existe rota para trocar o papel.** O critério "mudar o papel reflete no Keycloak" é
metade desta entrega, mas o papel mora no vínculo e não há rota que escreva lá. Dois caminhos
possíveis, nenhum escolhido: uma rota para vínculo (assunto que ainda não existe) ou o papel
dentro da atualização de usuário. **Precisa de tarefa própria antes de esta fechar** — sem
isso o espelhamento não tem por onde ser exercitado.

### Materiais para consumir

| Material | Situação |
|---|---|
| `creed-23-openapi.yaml` — os formatos literais | ✅ anexado no épico CREED-23 |
| `creed-23-contrato-api.md` — o contrato completo, em texto | ✅ anexado |
| Link do arquivo de exemplo `app/domains/respondentes/service.py` no GitHub | ⬜ falta o permalink — **AGES IV** |

### Rastreio

```
Rastreio: 86e348g6u/3 — creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/contrato-api.md
```

---

## 4 · `86e34yfae` — CREED-23.4 - Criar domínio authentication e a guarda de rota compartilhada

### Em uma frase

Entregar as portas de entrada e saída — entrar, renovar a sessão, sair, saber quem está
logado — e a peça que qualquer serviço futuro usa, em uma linha, para exigir login e nível
de acesso.

### O que muda para quem usa

É a entrega que fecha o portão. A partir daqui, chamar qualquer parte protegida do sistema
sem estar logado deixa de funcionar.

A parte que mais aparece no dia a dia de quem usa é a diferença entre dois tipos de recusa,
e ela precisa estar certa:

- **"Você não está logado"** — a pessoa é mandada para a tela de login.
- **"Você está logado, mas isto não é para o seu papel"** — a pessoa vê "acesso negado" e
  **continua logada**.

Confundir os dois produz o bug clássico: a pessoa clica onde não pode e é deslogada. Ela não
entende, tenta de novo, é deslogada de novo.

Outra decisão que aparece para quem usa: **errar a senha e digitar um e-mail que não existe
dão exatamente a mesma resposta**. É de propósito — resposta diferente diria a um estranho
quais e-mails têm cadastro.

E uma terceira, que costuma ser esquecida: **se o Keycloak estiver fora do ar, a mensagem é
"tente novamente", nunca "senha inválida"**. Sem essa distinção, a pessoa troca a senha que
estava certa e o suporte persegue um fantasma.

### Como pretendemos fazer

Três decisões sustentam esta entrega:

**O servidor confere o crachá; não emite crachá próprio.** A assinatura é verificada com a
chave pública do Keycloak, buscada uma vez e guardada em memória. Emitir crachá próprio
criaria dois emissores, duas expirações e faria "sair" no Keycloak deixar de significar algo.

**O crachá abre a porta; o banco confirma o dado.** Duas camadas, de propósito:

| Camada | O que faz | Custo |
|---|---|---|
| `require_role("admin", "gestor")` | lê o papel de dentro do crachá já verificado e responde 403 na hora | nenhuma consulta ao banco |
| `current_user` | carrega o usuário e o vínculo do banco **quando a requisição precisa do dado da pessoa**, e confere que o papel bate com o do crachá | uma consulta indexada |

Se o crachá e o banco discordarem, a resposta é **recusar e registrar log** — nunca "escolhe
um dos dois". A divergência só existe se a cópia do papel no Keycloak falhou, e falhar em
silêncio é o modo de falha que ninguém descobre.

> Esta conferência está marcada como **reversível de propósito**. Se ela nunca pegar nada, vira
> log sem bloqueio. Se pegar com frequência, o crachá sai do caminho e toda guarda passa a ler
> o banco. As duas reversões mexem em **um arquivo só** — e é por isso que a guarda nasce
> centralizada, e não copiada em cada assunto.

**A guarda nasce compartilhada, não local.** A regra normal do projeto é "nasce local, sobe
para compartilhado no segundo uso". A exceção aqui é justificada: são seis assuntos usando no
primeiro dia.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/authentication/router.py` | as quatro rotas |
| `app/domains/authentication/service.py` | a regra: chamar o Keycloak, traduzir erro, montar a sessão |
| `app/domains/authentication/schemas.py` | os formatos de entrada e saída |
| `app/domains/authentication/dependencies.py` | a injeção |
| `app/external_services/keycloak/token.py` | busca e guarda a chave pública; verifica assinatura, emissor, público-alvo e validade |
| `app/shared/authorization.py` | `require_role()` e `current_user()` — as duas peças que todo assunto futuro vai usar |
| `tests/domains/authentication/` | crachá válido, expirado, adulterado, papel insuficiente, divergência |

Este assunto **não tem tabela nem consultas próprias**: ele lê o usuário chamando o serviço de
cadastro. Assunto não fala com o banco de outro assunto.

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| O cliente do Keycloak | `app/external_services/keycloak/client.py` | a conversa com o Keycloak já está encapsulada ali — não abra conexão nova |
| Erros padronizados | `app/shared/exceptions.py` | o mapeamento de erro para código HTTP |
| Serviço de cadastro de usuário | `app/domains/users/service.py` | é por aqui que se lê o usuário — nunca pelo repositório do outro assunto |

### Contrato

| Método | Rota | Precisa de crachá | Entrada | Saída |
|---|---|---|---|---|
| POST | `/api/v1/authentication/login` | não | `LoginRequest{email, password}` | `Session` · 200 |
| POST | `/api/v1/authentication/renew` | não | `RenewRequest{refresh_token}` | `Session` · 200 |
| POST | `/api/v1/authentication/logout` | não | `RenewRequest{refresh_token}` | 204 |
| GET | `/api/v1/authentication/session` | sim | — | `UserSession` · 200 |

```
Session      { access_token, refresh_token, expires_in, user: UserSession }
UserSession  { id, email, role, vinculo_id, organization_id, organization_name }
```

Não existe campo `token_type`: o cabeçalho é sempre `Authorization: Bearer <token>`. Um campo
que só pode ter um valor é campo que alguém vai ramificar por engano.

**Erros**

| Código | Quando |
|---|---|
| 401 | sem crachá · crachá inválido ou expirado · senha errada · e-mail inexistente · acesso desativado · papel do crachá diferente do banco |
| 403 | logado, mas o papel não alcança a rota |
| 503 | Keycloak fora do ar |

**O corpo do erro tem duas formas**, e isso não é escolha deste contrato — é o que o
framework produz:

```jsonc
// erro que nós levantamos -> "detail" é texto
{ "detail": "E-mail ou senha inválidos" }

// erro de validação do corpo -> "detail" é lista
{ "detail": [ { "type": "missing", "loc": ["body","password"], "msg": "Field required" } ] }
```

Quem consome precisa tratar as duas. Isso está anotado aqui porque a entrega do site tropeça
nele se ninguém avisar.

### Pronto quando

- [ ] Requisição sem crachá a uma rota protegida responde **401**; com papel insuficiente
      responde **403** — e são códigos diferentes de verdade.
- [ ] Login com credencial correta devolve os dois crachás e os dados da pessoa, com papel,
      vínculo e organização.
- [ ] Login com senha errada e login com e-mail inexistente devolvem **a mesma** resposta.
- [ ] Acesso desativado não entra, mesmo com a senha certa no Keycloak.
- [ ] Crachá expirado é recusado; a renovação devolve sessão nova.
- [ ] Papel do crachá diferente do banco resulta em 401 **e log** — não em "passou porque o
      crachá dizia".
- [ ] Keycloak fora do ar responde **503**, não 401.
- [ ] Sair funciona mesmo com um crachá já inválido (devolve 204 do mesmo jeito) — a pessoa
      está saindo; travá-la numa tela que ela quer abandonar é o pior desfecho possível.
- [ ] **Proteger uma rota nova custa uma linha** (`Depends(require_role("admin"))`), sem
      copiar código de outro assunto.

### Como verificar

```bash
docker compose up -d db keycloak
alembic upgrade head && python -m scripts.seed_admin
pytest tests/domains/authentication tests/shared -q
```

Manualmente, o roteiro que prova o comportamento:

1. Chamar uma rota protegida sem cabeçalho → **401**.
2. Fazer login com o administrador semeado → copiar o crachá.
3. Colar o crachá em <https://jwt.io> e conferir identificador, validade e papéis.
4. Repetir o passo 1 com o cabeçalho → **200**.
5. Criar um acesso de respondente, logar com ele, chamar uma rota de administrador → **403**,
   não 401.
6. Alterar o papel direto no Keycloak, para simular a cópia dessincronizada → a requisição
   seguinte responde **401** e registra log.
7. Derrubar o Keycloak e tentar login → **503**.

### Estado em 2026-09-14 — divergências conhecidas

Esta entrega está marcada como concluída, e o código está na `dev`. Três pontos divergem do
contrato acima, e estão registrados para não serem descobertos por acidente:

- As rotas na `dev` ainda são `/auth/login`, `/auth/renew` e `/auth/me`. A renomeação para
  `/authentication/{login,renew,session}` está em revisão e **precisa entrar antes** do lado
  do site, senão o login cai em "não encontrado" na janela entre os dois.
- **`POST /authentication/logout` não existe.** Sair só limpa a sessão no navegador, e o
  crachá de renovação segue válido até expirar.
- **O 503 não acontece:** Keycloak fora do ar responde 401 hoje. É exatamente o par que esta
  descrição avisa para não confundir, e está confundido no código.

### Decisões já tomadas que valem aqui

- **A sessão dura 15 minutos, renovável por até 8 horas**, sem renovação deslizante além disso.
- **Os papéis são administrador, gestor e respondente.**

### Materiais para consumir

| Material | Situação |
|---|---|
| `creed-23-openapi.yaml` — os formatos literais | ✅ anexado no épico CREED-23 |
| `creed-23-contrato-api.md` — o contrato completo, em texto | ✅ anexado |

### Rastreio

```
Rastreio: 86e348g6u/4 — creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/contrato-api.md
```

---

## 5 · `86e34yfba` — CREED-23.5 - Gerir a sessão autenticada no front (armazenamento + apiClient)

### Em uma frase

Fazer o site guardar a sessão em um lugar só e anexar o crachá automaticamente em toda
chamada ao servidor, renovando sozinho quando ele expira.

### O que muda para quem usa

Três coisas que a pessoa sente diretamente:

- **Recarregar a página não desloga.** Hoje, qualquer F5 perderia a sessão.
- **A sessão não cai no meio do trabalho.** O crachá vale 15 minutos; quando expira, o site
  renova sozinho e refaz a chamada. A pessoa não percebe.
- **Quando a sessão realmente acaba** (depois de 8 horas), o site limpa tudo e leva para a
  tela de login, sem tela quebrada e sem mensagem de erro técnico.

Nenhuma tela precisa saber que qualquer uma dessas coisas está acontecendo.

### Como pretendemos fazer

**Um arquivo, e só ele, toca o armazenamento do navegador.** Os dois crachás ficam sob uma
única chave (`creed.session`), lidos e escritos exclusivamente por `src/lib/session.ts`.
Nenhum componente, nenhuma tela e nenhum pedaço de estado global lê o armazenamento direto.

Isso tem um preço, e ele foi aceito por escrito: um script malicioso injetado na página
consegue ler o armazenamento. A alternativa mais segura seria guardar em cookie que o
JavaScript não enxerga — mas custa configuração de cookie no servidor e no proxy, uma regra
a mais de proteção contra requisição forjada, e o site deixaria de saber se está logado sem
uma chamada extra. **A mitigação é o encapsulamento, não a esperança:** trocar depois é
reescrever um arquivo e um trecho do servidor — as telas não mudam uma linha.

O cliente de chamadas ao servidor ganha três comportamentos, nesta ordem:

1. anexa o crachá quando há sessão;
2. se o servidor recusar por crachá expirado, **renova uma vez** e repete a chamada original;
3. se a renovação falhar, limpa a sessão e manda para a tela de login.

Com **uma renovação só, mesmo com várias chamadas em voo**: cinco chamadas que expiram juntas
disparam **um** pedido de renovação, não cinco. Sem isso, o primeiro carregamento de um painel
invalida o próprio crachá de renovação no meio da tela.

Um detalhe que é bug esperando para acontecer: o cliente de chamadas de hoje pega o corpo do
erro como texto cru. Uma tela que mostre essa mensagem vai exibir `{"detail":"E-mail ou senha
inválidos"}` com chaves e aspas. **Esta entrega é o lugar de arrumar**: interpretar o corpo e
extrair a mensagem, tratando as duas formas que o servidor produz (texto e lista).

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `src/lib/session.ts` | ler, gravar e limpar a sessão — o único lugar que toca o armazenamento |
| `src/lib/apiClient.ts` | anexar o crachá, renovar uma vez, limpar e redirecionar; interpretar o corpo do erro |
| `src/types/api.ts` | os formatos vindos do servidor, transcritos |
| `src/features/authentication/authenticationApi.ts` | as quatro chamadas, como funções puras |
| `src/features/authentication/authenticationSlice.ts` | o estado da sessão e o status das chamadas |
| `src/app/store.ts` | registrar o estado novo |
| `src/lib/apiClient.test.ts` | renovação única com chamadas simultâneas · renovação que falha |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| O cliente de chamadas | `src/lib/apiClient.ts` | é ele que ganha os comportamentos — não crie um segundo |
| Um assunto completo de exemplo | `src/features/respondentes/` | copie a **forma**: chamadas puras em `<assunto>Api.ts`, estado em `<assunto>Slice.ts`, tela separada |
| O registro de estado global | `src/app/store.ts` | acrescente ali |

As chamadas em `authenticationApi.ts` são funções puras sobre o cliente: **sem estado global,
sem React e sem `try/catch`**. Quem trata erro é a camada de estado.

### Contrato que esta entrega consome

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/authentication/login` | `{ email, password }` | `Session` |
| POST | `/api/v1/authentication/renew` | `{ refresh_token }` | `Session` |
| POST | `/api/v1/authentication/logout` | `{ refresh_token }` | 204 |
| GET | `/api/v1/authentication/session` | — (com crachá) | `UserSession` |

```ts
type Role = 'admin' | 'gestor' | 'respondente';

interface UserSession {
  id: string; email: string; role: Role;
  vinculo_id: string; organization_id: string; organization_name: string;
}

interface Session {
  access_token: string; refresh_token: string; expires_in: number; user: UserSession;
}
```

**Como reagir a cada código**

| Código | O que o site faz |
|---|---|
| 401 | renova **uma vez**; se falhar, limpa a sessão e vai para `/login` |
| 403 | mostra "acesso negado" — **não desloga** |
| 503 | "tente novamente" — **não** limpa a sessão e **nunca** diz "senha inválida" |

### Pronto quando

- [ ] Recarregar a página com sessão válida **não** desloga.
- [ ] Uma chamada recusada por crachá expirado é renovada e refeita, uma vez, sem a pessoa perceber.
- [ ] Cinco chamadas simultâneas que expiram juntas disparam **um** pedido de renovação.
- [ ] Renovação que falha limpa a sessão e leva para a tela de login, sem tela quebrada.
- [ ] Um 403 **não** desloga.
- [ ] Nenhum componente, tela ou estado global lê o armazenamento do navegador direto — só
      `session.ts`.
- [ ] A mensagem de erro que chega às telas é texto legível, não JSON cru.
- [ ] `npm run check` verde.

### Como verificar

```bash
npm run check
npm test -- src/lib/apiClient.test.ts
npm run dev
```

No navegador: apagar `creed.session` pelas ferramentas de desenvolvedor e clicar em qualquer
coisa → cai na tela de login, sem tela quebrada.

### Materiais para consumir

| Material | Situação |
|---|---|
| `creed-23-openapi.yaml` e `creed-23-payloads.json` | ✅ anexados no épico CREED-23 |
| `creed-23-mock-README.md` — como disparar chamadas de verdade contra os exemplos | ✅ anexado |
| `creed-23-mock-docker-compose.yml` — sobe o mock local que o README explica | ✅ anexado |
| `creed-23-contrato-api.md` — o contrato completo, em texto | ✅ anexado |

> ⚠️ Os exemplos anexados **não guardam estado**: o crachá que eles devolvem não é aceito por
> eles depois. O ciclo entrar → usar → renovar só fecha de verdade contra o servidor da
> entrega 4.

### Rastreio

```
Rastreio: 86e348g6u/5 — creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/contrato-api.md
```

---

## 6 · `86e34yfct` — CREED-23.6 - Tela de login e proteção de rota no front

### Em uma frase

Entregar a tela onde a pessoa entra, e fazer com que nenhuma outra tela abra sem que ela
tenha entrado.

### O que muda para quem usa

É a primeira coisa que qualquer pessoa vê na plataforma. O que precisa acontecer:

- Abrir qualquer endereço do sistema sem estar logada **leva para a tela de login**.
- Depois de entrar, a pessoa volta **para a tela que ela tentou abrir**, não para uma tela
  genérica. Quem clicou num link de painel quer o painel.
- Errar a senha mostra **"E-mail ou senha inválidos"** — a mesma mensagem para senha errada,
  e-mail inexistente e acesso desativado. É de propósito, e é a única mensagem possível: o
  servidor não diz mais que isso.
- Não há link de "criar conta" nem de "esqueci minha senha". Nenhum dos dois existe nesta
  plataforma, e link para tela que não existe é pior que link ausente.
- Quando a pessoa chega a um lugar em que está logada mas não pode entrar, ela vê **"acesso
  negado"** e continua logada.

### Como pretendemos fazer

A tela segue o protótipo do time. Ela conversa **só com o nosso servidor** — não sabe, em
nenhum ponto, que existe um Keycloak por trás. Essa é a decisão que permite trocar a forma de
autenticar depois mexendo nesta tela e no roteador, e não em cada tela do sistema.

A proteção das rotas é um componente que envolve as rotas protegidas: se não há sessão,
redireciona para o login guardando o endereço pretendido; se há, deixa passar.

**Uma armadilha de ordem**, que precisa ser combinada antes de começar: o servidor está
renomeando as rotas de autenticação. O lado do site **só pode entrar depois** do lado do
servidor. Invertida a ordem, o login cai em "não encontrado" na janela entre os dois.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `src/features/authentication/LoginView.tsx` | a tela: campos, validação, envio, mensagem de erro |
| `src/app/ProtectedRoute.tsx` | a proteção: sem sessão, redireciona guardando o endereço pretendido |
| `src/app/routes.tsx` | quais rotas ficam dentro da proteção |
| `src/features/authentication/AccessDeniedView.tsx` | a tela de acesso negado |
| `src/i18n/locales/pt-BR.ts` e `en.ts` | os textos — nenhum texto fixo dentro do componente |
| `src/features/authentication/LoginView.test.tsx` | sucesso · credencial inválida · volta para o endereço pretendido |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| A sessão e o cliente de chamadas autenticado | `src/lib/session.ts`, `src/lib/apiClient.ts` | entregues na tarefa anterior — **não** leia o armazenamento do navegador aqui |
| O estado da autenticação | `src/features/authentication/authenticationSlice.ts` | é dele que a tela lê se há sessão |
| As chamadas ao servidor | `src/features/authentication/authenticationApi.ts` | já existem — a tela não monta chamada própria |
| Componentes de formulário e de campo | os compartilhados do projeto | a biblioteca de interface é fechada: não entre com componente de fora |

### Contrato que esta entrega consome

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/authentication/login` | `{ email, password }` | `Session` · 200 |

| Código | O que a tela mostra |
|---|---|
| 200 | guarda a sessão e vai para o endereço pretendido |
| 401 | "E-mail ou senha inválidos" — e **só** isso |
| 503 | "Serviço indisponível, tente novamente" — **nunca** "senha inválida" |

### Pronto quando

- [ ] Abrir uma rota protegida deslogado cai em `/login`.
- [ ] Depois de entrar, a pessoa volta para **a rota que tentou abrir**.
- [ ] Recarregar a página com sessão válida continua logado.
- [ ] Senha errada mostra a mensagem única, sem revelar se o e-mail existe.
- [ ] Não há link de criar conta nem de recuperar senha.
- [ ] Um 403 leva à tela de acesso negado e **não** desloga.
- [ ] Todo texto passa pelos arquivos de tradução — nenhum texto fixo no componente.
- [ ] A tela funciona em telas pequenas — responsividade é obrigatória no projeto, não item
      de polimento.
- [ ] `npm run check` verde.

### Como verificar

```bash
npm run check
npm test -- src/features/authentication
npm run dev
```

No navegador, o roteiro que prova o comportamento:

1. Deslogado, abrir `/respondentes` → cai em `/login`.
2. Entrar → volta para `/respondentes`.
3. **F5** → continua logado.
4. Apagar `creed.session` pelas ferramentas de desenvolvedor e clicar em qualquer coisa →
   cai em `/login` sem tela quebrada.

### Estado em 2026-09-17 — atenção antes de começar

Esta tarefa está `to do` no board, mas **já existe código em andamento** na branch
`feat/86e34yfct-tela-login-e-protecao-rota` do site: `LoginView.tsx` e `ProtectedRoute.tsx`
estão escritos. Quem pegar esta tarefa começa dali, não do zero — e confere o que falta contra
a lista de "Pronto quando" acima.

Há também uma tela de troca de senha em `src/features/autenticacao/AlterarSenhaView.tsx`, com
rotas apontando para ela (`/primeiro-acesso`, `/recuperar-senha`). **Essa tela perdeu a função**
com a decisão de que o primeiro acesso não passa pela plataforma. O que fazer com ela é decisão
de quem revisa esta entrega — não a apague sem combinar.

### Decisões já tomadas que valem aqui

- **O primeiro acesso não passa pela plataforma.** Não existe tela de troca de senha, nem hoje
  nem depois: quem define a senha é a página do Keycloak, alcançada por link no e-mail.
- **Não existe autocadastro** — por isso não há link de criar conta.
- **"Esqueci minha senha" não existe nesta entrega** — quem perde a senha pede a um administrador.

### Materiais para consumir

| Material | Situação |
|---|---|
| Protótipo da tela de login (Figma) | ⬜ falta o link — **AGES III** |
| Protótipo da tela de acesso negado | ⬜ falta o link — **AGES III** |
| `creed-23-payloads.json` — exemplos de resposta do login | ✅ anexado no épico CREED-23 |
| `creed-23-contrato-api.md` — o contrato completo, em texto | ✅ anexado |

### Rastreio

```
Rastreio: 86e348g6u/6 — creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/spec.md
```

---

## 7 · `86e34yfdm` — CREED-23.7 - Nível de acesso por tela no front

### Em uma frase

Fazer cada tela mostrar o que o papel da pessoa permite — e trocar o papel fixo escrito no
código pelo papel real, vindo da sessão.

### O que muda para quem usa

É o que faz a plataforma parecer diferente para cada pessoa.

- Quem responde aos instrumentos **não vê os itens de menu de gestão**. Eles não aparecem
  desabilitados: não aparecem.
- Um gestor vê a organização do vínculo dele, e ações que são de administrador não aparecem
  para ele.
- Um administrador vê o conjunto completo dentro da organização dele.

Hoje nada disso acontece: o papel que a interface usa para decidir é um valor fixo escrito no
código, porque não havia login quando o menu foi feito. **Esta entrega é o que apaga esse
valor fixo** — é o último pedaço do épico, e o que fecha a promessa dele.

### Como pretendemos fazer

Uma leitura de papel compartilhada, vinda da sessão, usada por todas as telas. Nenhuma tela
guarda papel próprio e nenhuma tela lê o crachá direto.

**Uma regra que precisa ficar explícita, porque é o erro que a revisão vai procurar de
propósito: esconder no site não é autorizar.** Todo item escondido aqui precisa ter a recusa
correspondente no servidor. Quem esconde um botão sem proteger a rota entregou uma porta
trancada com a chave pendurada ao lado.

O critério é simples e vale como item de revisão: para cada elemento que some por papel, existe
uma rota protegida no servidor que recusa a mesma coisa.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `src/features/authentication/useRole.ts` (ou equivalente) | a leitura de papel compartilhada, a partir da sessão |
| o componente de menu | itens filtrados por papel |
| as telas que hoje leem papel de valor fixo | passam a ler o papel real |
| `src/i18n/locales/pt-BR.ts` e `en.ts` | textos de "acesso negado" e rótulos por papel |
| os testes de cada tela tocada | um caso por papel: o que aparece e o que não aparece |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| O papel da pessoa logada | `src/features/authentication/authenticationSlice.ts` | é a fonte — não guarde papel em outro lugar |
| A proteção de rota | `src/app/ProtectedRoute.tsx` | já existe; esta tarefa acrescenta o recorte por papel, não um segundo mecanismo |
| O tipo dos papéis | `src/types/api.ts` (`Role`) | use o tipo existente |

### Pronto quando

- [ ] **Nenhuma tela lê papel de valor fixo** — este é o critério que fecha o épico.
- [ ] Um elemento restrito a administrador não aparece para quem é respondente.
- [ ] Para cada elemento escondido por papel, existe a recusa correspondente no servidor.
- [ ] Quem chega a uma rota que o papel dele não alcança vê "acesso negado" e **continua logado**.
- [ ] Há teste por papel nas telas tocadas — pelo menos administrador e respondente.
- [ ] `npm run check` verde.

### Como verificar

```bash
npm run check
npm test
npm run dev
```

No navegador, com dois acessos de papéis diferentes criados pelo cadastro do servidor: entrar
com cada um e conferir o menu e as ações. Depois, pegar um endereço que só o administrador
alcança e abri-lo logado como respondente → "acesso negado", **sem deslogar**.

### Decisões já tomadas que valem aqui

- **Os papéis são administrador, gestor e respondente.**
- **O recorte é sempre papel + organização do vínculo** — não existe permissão item a item
  nesta entrega.
- A decisão anterior de que o papel vinha de um valor fixo no código **é exatamente o que esta
  tarefa remove**. Ela existia porque não havia login; agora há.

### Materiais para consumir

| Material | Situação |
|---|---|
| Desenho de qual item de menu e qual ação cada papel enxerga | ⬜ **falta produzir** — AGES III/IV. Sem isso, quem implementar vai adivinhar, e adivinhar aqui é decisão de produto |
| Protótipo das telas com os três papéis | ⬜ falta o link — **AGES III** |

> ⚠️ Esta é a única das sete entregas em que **falta material de produto**, não só anexo. A
> lista de "o que cada papel vê em cada tela" não existe escrita em lugar nenhum. Sem ela, a
> tarefa não está pronta para começar.

### Rastreio

```
Rastreio: 86e348g6u/7 — creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/spec.md
```
