# CREED-32 — rascunho de publicação no ClickUp

```
Épico: 86e3anvg2 — CREED-32 Link table context
Spec: spec.md · Tasks: tasks.md
Gerado em: 2026-09-26 · Publicado em: 2026-09-26 (épico atualizado, 321–323 sobrescritas com mandato, 324–326 criadas)
Permalinks apontam para creed-backend @ ffd54ed3084f68fa80733fd59829405ab6c6e47b (origin/dev)
e creed-ai-context @ c5a0322c60d5446306b40e7bf79e4991b357389c (origin/main)
```

## Rodada 2 — 2026-09-29: nomes em inglês (publicada)

O time refutou a P-029: no código, vínculo e setor são `Link` e `Department` (tabela
`links`, `link_id`, `department_id`, rota `/organizations/{organization_id}/links`).
Valores de enum seguem em português. Até esta rodada, o board tinha o texto de 2026-09-26.

Leitura do board em 2026-09-29: as seis subtarefas têm `date_updated` igual ao da
publicação de 26/09 (as três criadas então, igual ao de criação), então ninguém editou
no board. O épico mudou só de status (`in progress`); o texto é o publicado.

| # | Subtarefa no board | Ação | O que muda | ID |
|---|---|---|---|---|
| — | CREED-32 (épico) | atualizar | nomes de código; linha do aplicativo web (o campo da sessão vira `link_id`); decisão sobre os nomes reescrita; "O que mudou" abre com esta atualização; nota de nomes em "Três palavras" | `86e3anvg2` |
| 1 | CREED-321 | atualizar | tabela `links`, `link_id`, `department_id`, `linktype`, nomes de índice e restrição, nome da migration, decisão sobre os nomes | `86e3anw3q` |
| 2 | CREED-322 | atualizar | `LinkRepository`, `LinkService`, `LinkCreate`, `LinkResponse.from_model()`, `department_id` | `86e3anx1v` |
| 3 | CREED-323 | atualizar | rota `/api/v1/organizations/{organization_id}/links`, `create_link`, arquivos em `app/domains/links/` | `86e3anx37` |
| 4 | CREED-324 | atualizar | `link_id` no cadastro de usuário, `get_by_link_id`, `LinkService` | `86e3f2gn0` |
| 5 | CREED-325 | atualizar | `link_id` na sessão e na guarda, SQL do roteiro em `links`; frase sobre o aplicativo web corrigida | `86e3f2gpw` |
| 6 | CREED-326 | atualizar | `link_id` passa a `NOT NULL`, comandos do roteiro | `86e3f2gzd` |

Título de nenhuma muda. Nenhuma criação. Nada sem rastreio.

**Publicada em 2026-09-29**, depois do ok do usuário: 7 × `clickup_update_task` em
`markdown_description`, todas com `success: true`, na ordem da tabela. Três ajustes entraram
durante a publicação, todos de nome ou de clareza, sem mudar produto:

- **323:** "o endereço começa em `/organizations`" — sobra de `/organizacoes` que o filtro
  não pegou (também corrigida no `3_task.md`).
- **324:** item 5 do reuso ganhou a frase "Essa versão do contrato ainda chama o campo de
  `vinculo_id`; o nome que vale é `link_id`", porque o permalink aponta para a `main`.
- **325:** tirada a repetição "que vinha sempre vazio" na frase da sessão.

**Conferência pós-publicação:** releitura do épico e da 323. Tabelas, blocos de código e
listas chegaram formatados; a seção "O que mudou" do épico não tem mais negrito encostado
em código, e o defeito não reapareceu.

**Correção pós-conferência, mesmo dia (pedido do usuário):** 2 × `clickup_update_task`.

- **321:** o `alembic downgrade -1` do "Pronto quando" e do "Como verificar" ganhou a nota
  para branch com revisão de junção (`Ambiguous walk` → descer pela head da `dev` e depois
  por `<revisão desta tarefa>@-1`). A mesma nota foi para o `1_task.md`.
- **325:** o item 1 do reuso trocou "o molde de si mesma" por "esta entrega altera o
  próprio arquivo, mantendo a forma que ele já tem".

Releitura da 321: formatada. Ela passou a mostrar 1 anexo, que não veio desta sessão.

## Mapa de publicação — rodada 1 (publicado em 2026-09-26)

| # | Subtarefa no board | Repo | Ação | ID |
|---|---|---|---|---|
| — | CREED-32 (épico) | — | ✅ descrição atualizada | `86e3anvg2` |
| 1 | CREED-321 - Tabela de vínculos no banco, e o usuário apontando para o vínculo | back | ✅ sobrescrita (título e descrição), com mandato | `86e3anw3q` |
| 2 | CREED-322 - Criar e ler um vínculo: regra e contratos | back | ✅ sobrescrita (título e descrição), com mandato | `86e3anx1v` |
| 3 | CREED-323 - Endpoint de criação de vínculo | back | ✅ sobrescrita (título e descrição), com mandato | `86e3anx37` |
| 4 | CREED-324 - Cadastro de acesso passa a exigir um vínculo | back | ✅ criada, `parent = 86e3anvg2`, status `backlog` | `86e3f2gn0` |
| 5 | CREED-325 - O papel de acesso passa a vir do vínculo, no login e em toda rota protegida | back | ✅ criada, `parent = 86e3anvg2`, status `backlog` | `86e3f2gpw` |
| 6 | CREED-326 - Remover o papel antigo da tabela de usuários | back | ✅ criada, `parent = 86e3anvg2`, status `backlog` | `86e3f2gzd` |

**Mandato:** o usuário autorizou em 2026-09-26 sobrescrever as três subtarefas sem
rastreio (criadas à mão por Pedro Fonseca, sem descrição). Perdeu-se só o título antigo
de cada uma: "Criar models para a tabela de link e seus enums", "Criar repository e
service" e "Criar router e schema".

**Próxima rodada:** as seis descrições terminam com `Rastreio: 86e3anvg2/N`. Rodar o
workflow de novo compara por essa linha e não duplica nada.

**Conferência pós-publicação:** releitura do épico e da CREED-325 no board. As tabelas
e os blocos de código chegaram formatados, e itens de lista chegaram inteiros. Um
defeito já conhecido reapareceu: **negrito encostado em `código` é partido em dois**
(lista "O que mudou" do épico, itens 1 e 2). O texto está inteiro; só a ênfase fica
picotada. Não republicado.

**Correspondência.** Nenhuma subtarefa do board tem a linha `Rastreio:`. As três que já
existem (321, 322, 323) foram criadas à mão, **com título e sem descrição**. Pela regra,
subtarefa sem rastreio não se toca. **Sobrescrevê-las depende de mandato explícito**,
pela mesma conduta da CREED-33 e da CREED-35: mesmos IDs, mesma numeração, título e
descrição novos. O conteúdo que se perde é só o título. Sem mandato, a alternativa é
deixar as três como estão e criar seis subtarefas novas (321 a 326 ficariam repetidas,
então a numeração nova seria outra).

**Numeração:** `CREED-324`, `325` e `326` seguem o padrão épico × 10 + n do board.

**Títulos:** os três atuais descrevem atividade ("Criar models...", "Criar repository e
service", "Criar router e schema"). Os novos descrevem resultado, como o checklist pede.

### O que muda em cada uma

- **Épico:** a descrição atual (de Pedro Fonseca) é substituída. Ela é curta e está correta no essencial, mas diverge em quatro pontos: o domínio `participantes` vira `links`, o arquivo `router_vinculos.py` vira `router.py`, o papel sai da tabela de usuários (decisão de 2026-09-24), e ela marca como ✅ o `.dbml`, que não está anexado (vira link).
- **321 a 323:** hoje vazias. Recebem a tradução de `1_task.md`, `2_task.md` e `3_task.md`.
- **324 a 326:** novas. Tradução de `4_task.md`, `5_task.md` e `6_task.md`.

## Materiais — visão do épico

| Material | Onde está | Vai em | Situação |
|---|---|---|---|
| Recorte do modelo de dados (tabela Vinculo) | permalink de `context/modelo-de-dados.proposta.dbml` @ c5a0322c | épico e subtarefa 1 | ✅ linkado no corpo |
| Arquivos de exemplo do backend | permalinks @ ffd54ed3 | subtarefas 1 a 6 | ✅ linkados no corpo, em lista |
| Contrato de `User` publicado pela CREED-23 | permalink de `contrato-api.md` @ c5a0322c | subtarefa 4 | ✅ linkado no corpo · ⚠️ o permalink mostra `vinculo_id`; ⬜ trocar pelo permalink da versão com `link_id` quando ela subir — **Luís** |
| Arquivo do realm do Keycloak local | permalink de `docker/keycloak/realm-creed.json` @ ffd54ed3 | subtarefas 3 e 5 | ✅ linkado no corpo |
| Decisão de 2026-09-24 (o papel vai para o vínculo) | `spec.md`, cabeçalho, e `modelo-de-dados.md`, **não commitados** | épico e subtarefas 4, 5 e 6 | ✅ texto colado no corpo |
| Premissas P-006, P-008 e P-029 | `decisoes/premissas.md` (a P-029 **não commitada**) | épico e subtarefas | ✅ texto colado no corpo · P-029 refutada em 2026-09-29: o trecho foi reescrito como decisão do time na rodada 2 |
| Definições de Vínculo, Setor e Participante | `glossario.md`, **não commitado** | épico e subtarefa 1 | ✅ colada no corpo |
| Spec e tasks desta tarefa | `tarefas/86e3anvg2-vinculo-table-context/`, **não commitada** | linha de Rastreio | ⬜ commitar e subir no `creed-ai-context` — **Luís** |

O único ⬜ não é anexo: é a pasta da tarefa (e as edições em `premissas.md`,
`glossario.md`, `modelo-de-dados.md` e `CONTEXT.md`) que ainda não foi para o GitHub.
Quem lê a subtarefa não perde nada, porque o texto está colado. Quem segue o rastreio
não acha o arquivo até ele subir.

---

## Parte 2 — descrição do épico

<!-- markdown_description em 86e3anvg2 = TUDO abaixo, substituindo a descrição atual. -->

### O que é

Hoje a plataforma não registra **a que organização uma pessoa pertence, nem com que papel**. O login sabe dizer "esta pessoa é admin", mas não "esta pessoa é gestora desta organização, desde tal data". Esta entrega cria o **vínculo**, que é essa ligação, e faz o papel de acesso de cada login passar a vir dele.

### Três palavras, antes de tudo

- **Vínculo**: o elo entre uma pessoa e uma organização. Guarda o papel da pessoa ali (administrador, gestor ou respondente), o tipo de vínculo (emprego, mentoria, acadêmico ou pessoal), o setor, quando existir, e o período (início e, se acabou, fim). A mesma pessoa em duas organizações tem dois vínculos, e cada vínculo tem o próprio login.
- **Participante**: a pessoa em si, independente de onde ela está vinculada. É onde as respostas de uma mesma pessoa em duas organizações se encontram. Ainda não existe como tabela.
- **Setor**: uma subdivisão da organização (financeiro, jurídico...). É dado da organização, não uma lista fixa. Também ainda não existe como tabela, e o vínculo pode nascer sem setor.

No código, os nomes são em inglês: vínculo é `Link` (tabela `links`) e setor é `Department` (coluna `department_id`). Os valores continuam em português: `emprego`, `mentoria`, `gestor`, `respondente`.

### Para quem, e o que muda para essa pessoa

| Quem | Hoje | Depois desta entrega |
|---|---|---|
| Administrador da plataforma | cria um acesso dizendo qual papel a pessoa tem | cria o vínculo da pessoa com a organização, com o papel, e cria o acesso dizendo de qual vínculo ele é. Tudo por API, ainda sem tela |
| Toda pessoa que faz login | o papel vale para a plataforma inteira, sem organização | o papel é o do vínculo. Para quem já tem vínculo, nada muda na prática. Quem não tem vínculo deixa de entrar |
| Quem desenvolve o aplicativo web | a sessão traz o identificador do vínculo (`vinculo_id`) e o da organização sempre vazios | os dois passam a vir preenchidos, e o do vínculo muda de nome para `link_id`. O aplicativo web ainda declara o nome antigo, mas não usa o valor, então nada quebra; ajustar o nome lá é uma tarefa do lado web |
| Quem desenvolve o servidor | a tabela de respostas de formulário aponta para um vínculo que não existe | o vínculo existe, e o papel de acesso tem uma fonte só |

Nenhuma tela do aplicativo web muda nesta rodada.

### O que entra nesta rodada

- A tabela de vínculos, criada no banco, num domínio próprio do servidor chamado `links`.
- A tabela de usuários passando a apontar para o vínculo de cada login.
- Um endereço de API para o administrador criar um vínculo numa organização.
- O cadastro de acesso passando a exigir o vínculo, em vez de o papel.
- O login e a conferência de acesso de toda rota protegida passando a ler o papel do vínculo.
- O script que prepara o ambiente local criando o vínculo do usuário de desenvolvimento.
- Por último, e em separado, a remoção do papel antigo da tabela de usuários.

### O que não entra — e por quê

- **As tabelas de participante, de organização e de setor.** Nenhuma delas existe ainda, e criá-las triplicaria esta entrega. O vínculo guarda os identificadores dos três como valores soltos, sem ligação de banco, do mesmo jeito que a tabela de respostas de formulário já faz. A ligação entra numa tarefa futura, de amarração.
- **Conferir que a organização, o participante ou o setor existem.** Mesmo motivo: não há tabela para consultar.
- **Listar, editar ou encerrar um vínculo.** O contrato desta tarefa tem um endereço só, o de criar. Consequência que precisa ficar clara: não há como trocar o papel de alguém pela API nesta rodada.
- **Enviar o papel para o Keycloak** (o serviço que guarda as senhas e emite o login). Isso nunca foi implementado: o papel lá continua configurado à mão. Esta entrega muda de onde o servidor lê o papel, não passa a gravar nada no Keycloak.
- **Tirar o nome da pessoa da tabela de usuários.** O modelo de dados do time põe o nome no participante, mas o participante ainda não existe. O nome fica onde está.
- **Qualquer mudança no aplicativo web.**

> ⚠️ **Depois da entrega 5, o login local de todo mundo para até rodar o script de preparação de novo.** Um usuário sem vínculo passa a ser recusado, e a tela mostra "e-mail ou senha inválidos" mesmo com a senha certa. O script cria o vínculo do usuário de desenvolvimento. O aviso vai na descrição do pull request da entrega 5. Não existe ambiente real com dados, então isso só afeta bancos locais.

### Como vai ser verificado

1. Aplicar as mudanças de estrutura no banco local: aparece a tabela de vínculos, e a de usuários ganha a coluna que aponta para o vínculo.
2. Rodar o script de preparação duas vezes: o usuário de desenvolvimento fica com um único vínculo de administrador.
3. Entrar com esse usuário: a sessão traz o papel, o vínculo e a organização.
4. Criar um vínculo pelo endereço novo: sem login, recusado; com login de quem não é administrador, proibido; com dado fora do formato, erro de formato.
5. Mudar à mão o papel antigo na tabela de usuários: o login não muda. Mudar o papel do vínculo: a próxima requisição protegida é recusada. É isso que prova que o papel antigo deixou de ser lido.
6. Na entrega 6: com um usuário sem vínculo no banco, a remoção do papel antigo para com uma mensagem clara em vez de quebrar.
7. Rodar a bateria de testes do servidor.

### Decisões tomadas

| O que decidimos | Por quê | Custo de mudar depois |
|---|---|---|
| O papel de acesso sai da tabela de usuários e passa a morar no vínculo, nesta tarefa. Decisão do time, 2026-09-24. | É o desenho que o modelo de dados do time sempre teve. O papel foi parar na tabela de usuários só porque, quando o login foi entregue, o vínculo ainda não tinha tabela, e a conferência de acesso precisava de uma cópia do papel no banco. | Médio: desfazer é devolver a coluna e reescrever a conferência de acesso |
| "Vínculo" e "setor" têm nome em inglês no código, como o resto do código novo: `Link` (tabela `links`, coluna `user.link_id`) e `Department` (coluna `department_id`). Os valores, como `emprego` e `gestor`, continuam em português. Decidido pelo time em 2026-09-29, sem a cliente: nome no código não é pergunta para ela. | Eram os dois únicos nomes ainda em aberto, e a primeira versão desta descrição os mantinha em português. O time fechou em inglês antes de a tabela sair da máquina de quem a criou. Fica para trás a coluna `vinculo_id` da tabela de respostas de formulário, já gravada no banco: renomeá-la pede uma mudança de estrutura própria. | Nenhum de dado: a troca foi feita com a tabela ainda vazia |
| Os papéis são administrador, gestor e respondente. Decidido sem a cliente. | É a lista do modelo de dados, feito pelo time. Uma lista anterior (administrador e funcionário) veio de um ensaio e nunca virou código. | Baixo hoje; alto depois que houver guardas de tela e de rota usando a lista |
| Não existe autocadastro: todo login nasce da cadeia organização → participante → vínculo → usuário, criada por um administrador. Decidido sem a cliente. | Uma tela pública de "criar conta" abriria a plataforma para quem não tem vínculo com organização nenhuma. | Baixo |

### O que mudou em relação à descrição anterior desta tarefa

**Atualização de 2026-09-29.** Esta descrição atualiza a publicada em 2026-09-26, e muda uma coisa só: os nomes de código de vínculo e setor passam para o inglês. Domínio e tabela `links`, classe `Link`, colunas `link_id` e `department_id`, e a rota `/api/v1/organizations/{organization_id}/links`. O comportamento é o mesmo.

Em relação à descrição original desta tarefa, continuam valendo quatro pontos:

1. O domínio se chama `links`, e não `participantes`. O modelo de dados do time separa os dois assuntos: `participantes` é da tabela de participante, que esta tarefa não cria.
2. O endereço fica em `router.py`, e não em `router_vinculos.py`. Nenhum domínio do servidor nomeia arquivo com o nome da entidade.
3. **O papel sai da tabela de usuários** (decisão de 2026-09-24). Isso criou as entregas 4, 5 e 6.
4. **O modelo de dados deixa de aparecer como anexado.** Ele não estava. Passa a ser link.

### As entregas

| # | Entrega | Onde | Depende de |
|---|---|---|---|
| 1 | CREED-321 - Tabela de vínculos no banco, e o usuário apontando para o vínculo | servidor | — |
| 2 | CREED-322 - Criar e ler um vínculo: regra e contratos | servidor | 1 |
| 3 | CREED-323 - Endpoint de criação de vínculo | servidor | 2 |
| 4 | CREED-324 - Cadastro de acesso passa a exigir um vínculo | servidor | 2 |
| 5 | CREED-325 - O papel de acesso passa a vir do vínculo, no login e em toda rota protegida | servidor | 4 |
| 6 | CREED-326 - Remover o papel antigo da tabela de usuários | servidor | 5, já na `dev` |

A 3 e a 4 andam em paralelo. A 6 é um pull request separado, aberto só depois de a 5 estar na `dev` e de o time ter rodado o script de preparação. A regra do projeto é nunca acrescentar o caminho novo e remover o velho no mesmo pull request.

**Outras tarefas mexem no banco ao mesmo tempo** (CREED-31, CREED-33 e CREED-35). A entrega 1 e a 6 dizem o que fazer quando duas mudanças de estrutura nascem do mesmo ponto.

### Contrato desta entrega

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/organizations/{organization_id}/links` | `{"participant_id": "uuid", "department_id": "uuid ou nulo, opcional", "type": "emprego, mentoria, academico ou pessoal", "role": "admin, gestor ou respondente"}` | `LinkResponse` · 201 |
| POST | `/api/v1/users` (muda) | acrescenta `"link_id": "uuid"`, obrigatório | `UserResponse`, agora com `role`, `link_id` e `organization_id` vindos do vínculo · 201 |

O modelo de dados do time, na tabela Vinculo: [modelo-de-dados.proposta.dbml](https://github.com/creed-educa-ai/creed-ai-context/blob/c5a0322c60d5446306b40e7bf79e4991b357389c/context/modelo-de-dados.proposta.dbml#L174).

### Materiais desta tarefa

- ✅ Modelo de dados: linkado acima.
- ✅ Decisões e definições: coladas acima.
- ⬜ Spec e decomposição desta tarefa no repositório de contexto — **commitar e subir: Luís**. Não é necessária para trabalhar: tudo está nas subtarefas.

### Rastreio

```
creed-ai-context/tarefas/86e3anvg2-vinculo-table-context/spec.md
```

---

## Parte 3 — subtarefa 1

**Título:** CREED-321 - Tabela de vínculos no banco, e o usuário apontando para o vínculo

### Em uma frase

Cria no banco a tabela de vínculos e acrescenta à tabela de usuários a coluna que diz de qual vínculo é cada login.

### O que muda para quem usa

Nada visível ainda. Esta entrega prepara o banco para as seguintes.

O **vínculo** é o elo entre uma pessoa e uma organização: guarda o papel dela ali (administrador, gestor ou respondente), o tipo de vínculo (emprego, mentoria, acadêmico ou pessoal), o setor, quando existir, e o período. A mesma pessoa em duas organizações tem dois vínculos, e cada vínculo tem o próprio login.

O papel de acesso vai sair da tabela de usuários e passar a morar no vínculo (decisão do time de 2026-09-24). Aqui só nasce a ligação: a coluna nova aceita vazio, e o papel antigo **não é tocado**. Quem para de ler o papel antigo são as entregas 4 e 5, e quem o remove é a 6.

### Como pretendemos fazer

Um assunto novo no servidor, `app/domains/links/`, só com a descrição da tabela por enquanto, mais uma mudança de estrutura do banco (revisão do Alembic) que faz duas coisas: cria `links` e acrescenta `user.link_id`. As duas vão na mesma revisão porque o Alembic lê as descrições de tabela de todos os domínios de uma vez, e a coluna só pode existir depois da tabela a que ela aponta.

As tabelas de participante, organização e setor não existem. Por isso `participant_id`, `organization_id` e `department_id` são identificadores soltos, sem ligação de banco, como `form_responses.vinculo_id` já faz. `user.link_id` é diferente: o alvo nasce nesta mesma revisão, então ela tem ligação de banco de verdade, a primeira do projeto. A ligação é declarada pelo nome da tabela, em texto, sem importar código de outro domínio.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/links/__init__.py` | o domínio novo |
| `app/domains/links/models.py` | `class Link(Base)`, `class LinkType(enum.Enum)`, `class Roles(enum.Enum)` |
| `app/domains/users/models.py` | só a coluna `link_id`, e o comentário de `role` atualizado |
| `alembic/env.py` | a linha de import do model novo |
| `alembic/versions/<hash>_create_links_and_user_link_id.py` | a revisão, gerada e depois lida linha a linha |
| `tests/domains/links/test_models.py` | trava a forma das duas tabelas, sem banco |

### A tabela `links`, coluna a coluna

`__tablename__ = "links"`, no plural. Classe `Link`.

| Coluna | Tipo | Aceita vazio? | Observação |
|---|---|---|---|
| `id` | `UUID` | não | chave primária, `default=uuid.uuid4` |
| `participant_id` | `UUID` | não | `index=True`, sem `ForeignKey` |
| `organization_id` | `UUID` | não | `index=True`, sem `ForeignKey` |
| `department_id` | `UUID` | sim | `index=True`, sem `ForeignKey` |
| `type` | `Enum(LinkType)` | não | `EMPREGO = "emprego"`, `MENTORIA = "mentoria"`, `ACADEMICO = "academico"`, `PESSOAL = "pessoal"` |
| `role` | `Enum(Roles)` | não | `ADMIN = "admin"`, `GESTOR = "gestor"`, `RESPONDENTE = "respondente"` |
| `start_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |
| `end_at` | `DateTime(timezone=True)` | sim | — |
| `created_at` | `DateTime(timezone=True)` | não | `server_default=func.now()` |
| `updated_at` | `DateTime(timezone=True)` | sim | sem default |

Nenhuma restrição de unicidade: o modelo de dados do time não define uma.

`Roles` tem os mesmos três valores de `UserRole`, que está em `app/domains/users/models.py`. **Não importe `UserRole`**: um domínio não importa a descrição de tabela de outro, e o teste de arquitetura reprova. A duplicação dura até a entrega 6, que apaga `UserRole`. Deixe um comentário curto em cima de `Roles` dizendo isso.

### A coluna nova em `user`

```python
# Aponta para o vínculo que dá o papel deste login (1 login = 1 vínculo).
# Nulável só até a CREED-326: aí vira NOT NULL e `role` sai.
link_id: Mapped[uuid.UUID | None] = mapped_column(
    UUID(as_uuid=True),
    ForeignKey("links.id", name="fk_user_link_id_links"),
    unique=True,
    nullable=True,
)
```

Atualize também o comentário que está em cima de `role`. Hoje ele diz "Enquanto `Vinculo` não existe"; passa a dizer que a coluna não é mais lida a partir desta tarefa e sai na CREED-326.

### O que o gerador automático erra, e você corrige

- **Restrições sem nome.** O autogenerate tende a escrever `op.create_foreign_key(None, ...)` e `op.create_unique_constraint(None, ...)`. O `downgrade()` gerado, `op.drop_constraint(None, ...)`, não roda. Dê nome aos dois: `fk_user_link_id_links` e `uq_user_link_id`.
- **Ordem.** No `upgrade()`, primeiro `create_table("links")`, depois a coluna e a ligação em `user`. No `downgrade()`, o inverso: ligação, unicidade, coluna, tabela e, por último, os tipos `linktype` e `roles`.
- **Tipos enumerados.** O Postgres guarda cada enum como um tipo do banco, e apagar a tabela não apaga o tipo. Sem apagar, desfazer e refazer falha com "type already exists". Não apague `userrole` nem `recordstatus`: o `user` continua usando os dois.

Sem esta linha em `alembic/env.py`, a revisão sai sem a tabela, e aplica sem erro:

```python
from app.domains.links import models as links_models  # noqa: F401
```

### Antes de gerar: confira o ponto de partida

Outras tarefas (CREED-31, CREED-33, CREED-35) estão criando mudanças de estrutura ao mesmo tempo, a partir do mesmo ponto (`49ef1d2c7b7e`). Rode `alembic heads` imediatamente antes de gerar. Antes de mesclar, atualize a branch e rode de novo: se aparecerem duas linhas, rode `alembic merge -m "merge heads" <h1> <h2>` **neste** pull request. Nunca edite `down_revision` à mão.

### O que já existe e deve ser reusado

1. A base das tabelas está em [`app/core/database.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/core/database.py). Herde de `Base` — não crie outra.
2. A tabela de exemplo é [`app/domains/users/models.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/users/models.py). Copie a forma: como a tabela, o enum e o horário de criação são declarados. Os campos, não.
3. Coluna de identificador com índice e sem ligação de banco: [`app/domains/responses/models.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/responses/models.py).
4. A revisão de exemplo, com o checklist preenchido no comentário do topo e o `downgrade()` que apaga o tipo enum: [`alembic/versions/49ef1d2c7b7e_form_response_table.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/alembic/versions/49ef1d2c7b7e_form_response_table.py).
5. O lugar do import: [`alembic/env.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/alembic/env.py).
6. O teste que confere as camadas: [`tests/test_arquitetura.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/tests/test_arquitetura.py). Precisa continuar passando.
7. O modelo de dados do time, tabela Vinculo: [`modelo-de-dados.proposta.dbml`](https://github.com/creed-educa-ai/creed-ai-context/blob/c5a0322c60d5446306b40e7bf79e4991b357389c/context/modelo-de-dados.proposta.dbml#L174).

### Pronto quando

- [ ] `alembic upgrade head` sobe do zero, em banco vazio, sem erro.
- [ ] `alembic downgrade -1 && alembic upgrade head` roda sem erro. Se a branch já tiver uma revisão de junção, desça pelo caminho da nota em "Como verificar".
- [ ] `\d links` mostra as dez colunas acima, com os três índices, sem nenhuma `ForeignKey` e sem restrição de unicidade.
- [ ] `\d "user"` mostra `link_id` aceitando vazio, com `uq_user_link_id` e `fk_user_link_id_links`, e `role` ainda presente.
- [ ] Nenhum arquivo de `app/domains/links/` importa de outro domínio, e `users/models.py` não importa de `links`.
- [ ] `alembic heads` devolve uma linha no momento de mesclar.
- [ ] O checklist do comentário do topo da revisão está preenchido.

### Como verificar

```bash
cd creed-backend
docker compose up -d db
alembic heads
alembic revision --autogenerate -m "create links and user.link_id"
alembic upgrade head
alembic downgrade -1 && alembic upgrade head
docker compose exec db psql -U creed -d creed -c "\d links" -c "\d \"user\""
pytest tests/domains/links tests/domains/users tests/test_arquitetura.py -q
ruff check . && mypy app
```

**Se a branch já tiver uma revisão de junção** (criada por `alembic merge`, quando a `dev` ganhou outras mudanças de estrutura enquanto esta tarefa estava aberta), o `alembic downgrade -1` para com `Ambiguous walk`: a junção tem dois pais, e o Alembic não sabe para qual lado descer. Nesse caso, desça pelo identificador. Primeiro até a head que veio da `dev`, o que desfaz só a junção; depois um passo abaixo da revisão desta tarefa, o que desfaz só ela:

```bash
alembic downgrade <head que veio da dev>
alembic downgrade <revisão desta tarefa>@-1
alembic upgrade head
```

Depois do segundo comando, `links` e `user.link_id` somem, e as tabelas das outras tarefas ficam.

O teste `tests/domains/links/test_models.py` não precisa de banco: ele lê `Link.__table__` e `User.__table__` e confere as dez colunas e a nulabilidade, a ausência de ligação de banco em `links`, os três índices, os valores exatos de `LinkType` e `Roles`, e que `user.link_id` aceita vazio, é único e aponta para `links.id`.

Os testes existentes de `tests/domains/users/` continuam passando sem mudança, porque a coluna aceita vazio.

### Decisões já tomadas que valem aqui

- "Vínculo" e "setor" ficam em inglês no código (`links`, `Link`, `link_id`, `department_id`), como o resto do código novo. Decidido pelo time em 2026-09-29. Os valores de tipo e papel (`emprego`, `gestor`…) continuam em português. Fica para trás `form_responses.vinculo_id`, já gravado, que pede migration própria.
- Os papéis são `admin`, `gestor` e `respondente`, a lista do modelo de dados do time.

### Materiais para consumir

- ✅ Modelo de dados: linkado acima (item 7).
- ✅ Arquivos de exemplo: linkados acima.

### Rastreio

```
Rastreio: 86e3anvg2/1 — creed-ai-context/tarefas/86e3anvg2-vinculo-table-context/1_task.md
```

---

## Parte 3 — subtarefa 2

**Título:** CREED-322 - Criar e ler um vínculo: regra e contratos

### Em uma frase

O servidor passa a saber criar um vínculo e ler um vínculo pelo identificador, com os formatos de entrada e saída prontos.

### O que muda para quem usa

Nada visível ainda: o endereço de API é a entrega 3. Esta entrega é o miolo que a 3 e a 4 usam.

Criar um vínculo **não confere nada**. O modelo de dados do time não proíbe dois vínculos iguais, e não há tabela de organização nem de participante para consultar. Não invente uma regra como "um vínculo ativo por pessoa": seria decisão de produto que ninguém tomou.

Ler por identificador existe por causa da entrega 4, não de um endereço: o cadastro de acesso vai perguntar "esse vínculo existe, e qual é o papel dele?". Por isso a leitura devolve o vínculo ou nada, **sem erro**. Quem chama decide o que a ausência significa: no cadastro de acesso, "não encontrado"; no login, "não autorizado".

### Como pretendemos fazer

Três camadas, na forma que o domínio de usuários já usa. O acesso a banco (`repository.py`) só grava e busca. A regra (`service.py`) monta o vínculo e delega, sem conhecer HTTP nem banco. Os contratos (`schemas.py`) separam entrada de saída.

O identificador da organização **não vem no corpo**: vem do endereço (`/organizations/{organization_id}/links`, na entrega 3). Por isso `LinkCreate` não tem o campo, e a criação recebe `organization_id` como argumento separado.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/links/repository.py` | `LinkRepository.insert(link)` e `LinkRepository.get_by_id(link_id)` |
| `app/domains/links/service.py` | `LinkService`: criar (recebe `organization_id` e `LinkCreate`) e ler por id (devolve `Link` ou `None`) |
| `app/domains/links/schemas.py` | `LinkCreate` e `LinkResponse`, com `LinkResponse.from_model(link)` |
| `tests/domains/links/test_service.py` | a regra com um dublê de banco em memória |

Os nomes dos dois métodos do service são seus. A regra do projeto é que o nome do método de regra diga a intenção (criar, ler), e o do acesso a banco diga como o dado é buscado (`insert`, `get_by_id`).

### Os contratos

**`LinkCreate`** (entrada):

```json
{
  "participant_id": "uuid",
  "department_id": "uuid ou null — opcional, nulo por padrão",
  "type": "emprego | mentoria | academico | pessoal",
  "role": "admin | gestor | respondente"
}
```

`type` e `role` são obrigatórios e não têm valor padrão.

**`LinkResponse`** (saída), com `model_config = ConfigDict(from_attributes=True)`:

```json
{
  "id": "uuid",
  "participant_id": "uuid",
  "organization_id": "uuid",
  "department_id": null,
  "type": "emprego",
  "role": "gestor",
  "start_at": "2026-09-24T14:00:00Z",
  "end_at": null,
  "created_at": "2026-09-24T14:00:00Z",
  "updated_at": null
}
```

### O que já existe e deve ser reusado

1. O acesso a banco de exemplo: [`app/domains/users/repository.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/users/repository.py). Copie `add` + `flush` + `refresh` na criação. O `refresh` é o que traz `start_at` e `created_at`, preenchidos pelo banco. Repare que **não há `commit()`**: quem fecha a transação é a requisição.
2. A regra de exemplo: [`app/domains/users/service.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/users/service.py).
3. Os contratos de exemplo, com `de_model()`: [`app/domains/users/schemas.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/users/schemas.py).
4. O teste de exemplo, com dublê no lugar do banco: [`tests/domains/users/test_service.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/tests/domains/users/test_service.py). Não existe banco de teste no projeto.

### Pronto quando

- [ ] Criar um vínculo grava `organization_id` (do argumento) e `participant_id`, `department_id`, `type` e `role` (do corpo), e devolve o que o acesso a banco devolveu.
- [ ] Criar sem `department_id` grava `department_id = None`.
- [ ] Ler um id que existe devolve o vínculo; ler um id que não existe devolve `None`, sem exceção.
- [ ] `LinkCreate` recusa `type` ou `role` fora da lista e `participant_id` que não é UUID, e aceita o corpo sem `department_id`.
- [ ] `LinkResponse.from_model()` devolve os enums como `"emprego"` e `"gestor"`, não como `EMPREGO` e `GESTOR`.
- [ ] `service.py` não importa `fastapi` nem `sqlalchemy`; `repository.py` não importa `app.shared.exceptions`; nenhum `commit()`.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/links tests/test_arquitetura.py -q
ruff check . && mypy app
```

Caso feliz: criar e ler de volta. Casos de borda: criar sem `department_id`, e ler um id inexistente. Corpo inválido é teste de contrato: `LinkCreate.model_validate(...)` dentro de `pytest.raises(ValidationError)`.

Um `Link` montado à mão no teste não tem `start_at` nem `created_at`, porque quem preenche é o banco. Para testar `from_model()`, preencha os dois à mão, como `um_user()` faz no teste de usuários.

### Decisões já tomadas que valem aqui

- Os papéis são `admin`, `gestor` e `respondente`.

### Materiais para consumir

- ✅ Arquivos de exemplo: linkados acima.

### Depende de

CREED-321 — a tabela precisa existir.

### Rastreio

```
Rastreio: 86e3anvg2/2 — creed-ai-context/tarefas/86e3anvg2-vinculo-table-context/2_task.md
```

---

## Parte 3 — subtarefa 3

**Título:** CREED-323 - Endpoint de criação de vínculo

### Em uma frase

O administrador passa a conseguir criar o vínculo de uma pessoa com uma organização, pela API.

### O que muda para quem usa

O administrador da plataforma ganha um endereço de API para dizer "esta pessoa é gestora desta organização, com vínculo de emprego". Ainda não há tela: quem usa é dev, pelo Swagger ou por linha de comando.

Só administrador cria vínculo, porque criar um vínculo decide o papel de acesso de alguém. Decidimos, sem a cliente, que não existe autocadastro: todo login nasce de uma cadeia criada por um administrador.

Qualquer identificador de organização é aceito, desde que tenha o formato certo, porque não há tabela de organizações para conferir. Isso é esperado.

### Como pretendemos fazer

O arquivo fica em `app/domains/links/router.py`, mas o endereço começa em `/organizations`: na URL, o vínculo é parte da organização. Isso não o põe no domínio de organizações, que nem tabela tem ainda. O prefixo descreve o endereço, não o dono do arquivo:

```python
router = APIRouter(prefix="/organizations/{organization_id}/links", tags=["links"])
```

A guarda de acesso já existe: `require_role("admin")`, em `app/shared/authorization.py`. Use no decorator, como `dependencies=[Depends(require_role("admin"))]`.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/links/dependencies.py` | `get_repository` → `get_service` → `ServiceDep` |
| `app/domains/links/router.py` | o `POST`, fino: recebe, delega, devolve `LinkResponse.from_model(...)` |
| `app/main.py` | o import do router e a entrada na tupla de routers |
| `tests/domains/links/test_router.py` | 201, 401, 403 e 422 |

### O contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/organizations/{organization_id}/links` | `LinkCreate`, da CREED-322 | `LinkResponse` · 201 |

**Erros**

| Código | Quando |
|---|---|
| 401 | sem token, ou token inválido ou vencido |
| 403 | token válido, mas sem o papel admin |
| 422 | corpo fora do formato, ou `organization_id` no endereço que não é UUID |

Não existe 404 nesta rota.

### O que já existe e deve ser reusado

1. A guarda de acesso: [`app/shared/authorization.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/shared/authorization.py), função `require_role`.
2. O router de exemplo: [`app/domains/users/router.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/users/router.py). Router fino, sem importar `models`.
3. A injeção de exemplo: [`app/domains/users/dependencies.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/users/dependencies.py).
4. Onde registrar: [`app/main.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/main.py).
5. O teste de rota de exemplo: [`tests/domains/authentication/test_router.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/tests/domains/authentication/test_router.py).
6. O teste da guarda, que mostra como simular o token e o usuário: [`tests/shared/test_authorization.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/tests/shared/test_authorization.py).
7. O realm local do Keycloak, onde estão o usuário e a senha de desenvolvimento: [`docker/keycloak/realm-creed.json`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/docker/keycloak/realm-creed.json).

⚠️ **O teste da guarda muda de forma na CREED-325.** Hoje a guarda confere o papel contra a tabela de usuários; depois da 325, contra o vínculo. Escreva os casos 401 e 403 como `tests/shared/test_authorization.py` está hoje. Se a 325 já tiver mesclado quando você começar, use o dublê novo de lá.

### Pronto quando

- [ ] Com token de admin e corpo válido, 201 com `LinkResponse`, e o `organization_id` da resposta é o do endereço.
- [ ] Sem `Authorization`, 401.
- [ ] Com token de respondente, 403.
- [ ] Com `type` fora da lista, 422. Com `organization_id` no endereço que não é UUID, 422.
- [ ] Sem `department_id` no corpo, 201 com `department_id: null`.
- [ ] A rota aparece em `/api/v1/docs`.
- [ ] `pytest tests/test_arquitetura.py` passa.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/links tests/test_arquitetura.py -q
ruff check . && mypy app
```

De ponta a ponta, com o usuário de desenvolvimento (a senha está no realm, item 7):

```bash
uvicorn app.main:app --reload
TOKEN=$(curl -s -X POST localhost:8000/api/v1/authentication/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"dev@creed.example.com","password":"<senha do realm>"}' | jq -r .access_token)

curl -i -X POST localhost:8000/api/v1/organizations/00000000-0000-0000-0000-000000000001/links \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"participant_id":"00000000-0000-0000-0000-000000000002","type":"emprego","role":"gestor"}'
```

### Decisões já tomadas que valem aqui

- Não existe autocadastro: todo login nasce de uma cadeia organização → participante → vínculo → usuário, criada por um administrador. Aqui isso é o `require_role("admin")`.

### Materiais para consumir

- ✅ Arquivos de exemplo e realm: linkados acima.

### Depende de

CREED-322. Anda em paralelo com a CREED-324.

### Rastreio

```
Rastreio: 86e3anvg2/3 — creed-ai-context/tarefas/86e3anvg2-vinculo-table-context/3_task.md
```

---

## Parte 3 — subtarefa 4

**Título:** CREED-324 - Cadastro de acesso passa a exigir um vínculo

### Em uma frase

Criar um acesso passa a exigir o vínculo da pessoa, e o papel que aparece na resposta passa a ser o do vínculo.

### O que muda para quem usa

Hoje o administrador cria um acesso e o papel fica gravado na própria tabela de usuários. Depois desta entrega, ele diz **de qual vínculo** é o acesso, e o papel, a organização e o vínculo aparecem na resposta, lidos do vínculo.

Se o vínculo informado não existe, o cadastro responde "não encontrado". Se outro acesso já usa esse vínculo, responde "conflito": cada vínculo tem um login só.

O papel continua gravado na coluna antiga da tabela de usuários, mas **ninguém mais lê essa coluna**. Ela sai na CREED-326.

**Por que o papel sai do usuário (decisão do time, 2026-09-24):** é o desenho que o modelo de dados sempre teve. O papel foi parar na tabela de usuários porque, quando o login foi entregue, o vínculo ainda não tinha tabela, e a conferência de acesso precisava de uma cópia do papel no banco.

### Como pretendemos fazer

O domínio de usuários passa a conversar com o de vínculos, **só pela camada de regra** (`LinkService`, injetado). O projeto já tem esse mecanismo, declarado no teste de arquitetura: a lista `COMPOE_COM_SERVICE_DE`, em `tests/test_arquitetura.py`, onde hoje está `"authentication": "le o usuario pelo UserService"`. Acrescente:

```python
"users": "le o papel e a organizacao do vinculo pelo LinkService",
```

Isso libera `users/service.py` e `users/dependencies.py` para importar de `app.domains.links`, e só esses dois. `users/schemas.py` e `users/models.py` continuam sem importar nada de `links`.

Por isso `UserResponse.role` vira `str`: `users/schemas.py` não pode importar o enum `Roles`. O `de_model()` passa a receber o usuário **e** os dados do vínculo (por exemplo, `role: str` e `organization_id: uuid.UUID` como argumentos). A forma exata é sua: a mais simples que passe no `mypy` e no teste de arquitetura. Diga no pull request qual escolheu.

`keycloak_id` e `name` continuam no cadastro. O formato final do contrato (com `initial_password` no lugar de `keycloak_id`) depende de criar o usuário no Keycloak pela API, e isso não entra aqui.

### A regra do cadastro, em ordem

1. E-mail já existe → `ConflictError`. Já existe hoje; não mude.
2. `link_id` não existe (o `LinkService` devolve `None`) → `NotFoundError`.
3. Outro usuário já tem esse `link_id` → `ConflictError`. A unicidade no banco é a última rede; a regra confere antes, como já faz com o e-mail.
4. Cria o `User` com `link_id`. Não passe `role`: o valor padrão da coluna a preenche, e ninguém mais a lê.

### O método que a CREED-325 vai usar

`UserService` ganha **um** método de leitura. Ele recebe o e-mail e devolve o usuário ativo junto com o papel e a organização do vínculo. Devolve `None` se o usuário não existe, está inativo, não tem `link_id`, ou o vínculo não é encontrado. Um `dataclass` pequeno em `users/service.py` é o caminho mais simples. Ele precisa carregar, no mínimo, `id`, `email`, `role` (como `str`), `link_id` e `organization_id`.

`get_active_user_by_email` continua existindo aqui, porque a guarda e o login ainda o chamam. Quem troca os dois é a CREED-325.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/users/schemas.py` | `UserCreate` com `link_id`; `UserResponse` com `role: str`, `link_id` e `organization_id` |
| `app/domains/users/service.py` | a regra do cadastro e o método de leitura novo |
| `app/domains/users/repository.py` | `get_by_link_id(link_id)`, para o conflito |
| `app/domains/users/dependencies.py` | injeta o `LinkService` no `UserService` |
| `app/domains/users/router.py` | traduz `NotFoundError` em 404 no `POST` |
| `tests/test_arquitetura.py` | a entrada `"users"` em `COMPOE_COM_SERVICE_DE` |
| `tests/domains/users/test_service.py` | um `FakeLinkService` e os casos novos |

### O contrato que muda

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/users` | `{"keycloak_id": "uuid", "name": "string", "email": "string", "link_id": "uuid"}` | `UserResponse` · 201 |

```json
{
  "id": "uuid",
  "name": "string",
  "email": "string",
  "status": "active",
  "role": "gestor",
  "link_id": "uuid",
  "organization_id": "uuid",
  "created_at": "2026-09-24T14:00:00Z"
}
```

**Erros**

| Código | Quando |
|---|---|
| 404 | o vínculo informado não existe (novo) |
| 409 | o e-mail já existe, ou o vínculo já é de outro acesso (novo) |
| 422 | corpo fora do formato, inclusive sem `link_id` |

Quem chama este endereço hoje: só os testes e o Swagger. O aplicativo web não usa.

### O que já existe e deve ser reusado

1. A regra de exemplo, com a checagem de duplicidade antes de gravar: [`app/domains/users/service.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/users/service.py), `create_user_service`.
2. Um serviço injetado em outro, do mesmo jeito que aqui: [`app/domains/authentication/dependencies.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/authentication/dependencies.py).
3. Os erros padronizados: [`app/shared/exceptions.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/shared/exceptions.py). Use `NotFoundError` e `ConflictError` — não crie exceção nova.
4. O teste que libera a conversa entre domínios: [`tests/test_arquitetura.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/tests/test_arquitetura.py).
5. O contrato de `User` que a tarefa de autenticação já publicou, e que esta entrega aproxima: [`contrato-api.md`](https://github.com/creed-educa-ai/creed-ai-context/blob/c5a0322c60d5446306b40e7bf79e4991b357389c/tarefas/86e348g6u-autenticacao-da-plataforma/contrato-api.md). Essa versão do contrato ainda chama o campo de `vinculo_id`; o nome que vale é `link_id`.

### Pronto quando

- [ ] `POST /users` sem `link_id` → 422.
- [ ] Com vínculo inexistente → 404.
- [ ] Com vínculo já usado por outro acesso → 409.
- [ ] Válido → 201, com `role`, `link_id` e `organization_id` iguais aos do vínculo, mesmo que a coluna `role` da linha gravada diga `respondente`.
- [ ] O método de leitura novo devolve `None` para usuário inexistente, inativo, sem `link_id`, e com `link_id` que o `LinkService` não encontra.
- [ ] O método de leitura novo devolve o papel do vínculo: com a coluna dizendo `respondente` e o vínculo dizendo `admin`, o resultado é `admin`.
- [ ] `users/schemas.py` e `users/models.py` não importam `app.domains.links`.
- [ ] `pytest tests/test_arquitetura.py` passa, com a entrada nova e o motivo escrito.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/users tests/test_arquitetura.py -q
ruff check . && mypy app
```

O `FakeLinkService` é um dicionário `id → objeto com role e organization_id`, mais o método de ler por id. Ele entra no `UserService` pelo construtor, como o `FakeUserRepository` já entra. `um_user()` ganha `link_id` no padrão. Os testes de `TestUserResponse` que conferem `resposta.role is UserRole.ADMIN` passam a conferir o papel vindo do vínculo, como `str`.

### Decisões já tomadas que valem aqui

- Não existe autocadastro: todo login nasce de um vínculo. É o `link_id` obrigatório.
- O acesso nasce ativo, sem segundo passo de ativação. Não muda aqui.

### Materiais para consumir

- ✅ Arquivos de exemplo e contrato: linkados acima.
- ✅ A decisão de mover o papel: colada acima.

### Depende de

CREED-322. Anda em paralelo com a CREED-323.

### Rastreio

```
Rastreio: 86e3anvg2/4 — creed-ai-context/tarefas/86e3anvg2-vinculo-table-context/4_task.md
```

---

## Parte 3 — subtarefa 5

**Título:** CREED-325 - O papel de acesso passa a vir do vínculo, no login e em toda rota protegida

### Em uma frase

O login e a conferência de acesso de toda rota protegida passam a usar o papel do vínculo, e quem não tem vínculo deixa de entrar.

### O que muda para quem usa

Para quem tem vínculo, nada muda na prática. A sessão devolvida no login passa a trazer o identificador do vínculo e da organização, que antes vinham sempre vazios. O campo do vínculo na sessão se chama `link_id` (antes, `vinculo_id`). O aplicativo web ainda declara o nome antigo, mas não usa o valor, então nada quebra; ajustar o nome lá é tarefa do lado web.

Quem não tem vínculo passa a ser recusado com "não autorizado". Hoje isso só atinge bancos locais: não existe ambiente real com dados.

⚠️ **Avise o time no pull request:** depois deste merge, cada pessoa roda `python scripts/seed_local.py` depois de `alembic upgrade head`. Sem isso, a tela de login responde "e-mail ou senha inválidos" com a senha certa.

### Como a conferência de acesso funciona hoje

O token do Keycloak traz o papel. `require_role` responde 403 se o papel do token não é o pedido. Depois, `_check_against_database`, em `app/shared/authorization.py`, busca o usuário no banco e confere se o papel do token bate com `user.role`. Se não bate, responde **401 e registra um erro no log**. Essa divergência só acontece quando alguém mudou o papel de um lado e esqueceu o outro.

### Como pretendemos fazer

A conferência passa a comparar com o papel do vínculo, usando o método de leitura que a CREED-324 criou em `UserService`. `authorization.py` continua falando **só** com `UserService`, nunca com `LinkService`: a pergunta "qual é o papel desta pessoa" fica num lugar só. Mude o mínimo: a origem do papel, não a forma da guarda.

O papel no Keycloak continua configurado à mão. Nada aqui grava no Keycloak. Um usuário administrador no Keycloak cujo vínculo diga gestor passa a ser recusado, e isso está certo. **Não afrouxe a guarda para aceitar a divergência.**

O `GET /api/v1/authentication/session` monta a sessão a partir do usuário que a guarda devolve (`AuthenticatedUser`), não do banco. Para ele devolver `link_id` e `organization_id`, o `AuthenticatedUser` precisa carregar os dois. Acrescente-os com `None` como padrão, para não quebrar quem monta um `AuthenticatedUser` só a partir do token.

**O script de preparação local** (`scripts/seed_local.py`) hoje grava o usuário de desenvolvimento com `role=ADMIN`. Depois desta entrega, isso não dá acesso a nada. Ele passa a:

1. criar um `Link` com `role=ADMIN`, `type=EMPREGO` e `participant_id` e `organization_id` **fixos**, como constantes no topo do script, com um comentário dizendo que os dois não apontam para nada até as tabelas de participante e organização existirem, e que a tarefa de amarração deve criar essas duas linhas com esses ids;
2. ligar o usuário ao vínculo (`link_id`);
3. continuar podendo rodar várias vezes: se o usuário já tem vínculo, não cria outro; se existe sem vínculo, cria e liga.

O script usa as camadas de acesso a banco direto, como já faz com `UserRepository`.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/shared/authorization.py` | `_check_against_database` usa o papel do vínculo; `AuthenticatedUser` ganha `link_id` e `organization_id` |
| `app/domains/authentication/service.py` | `_build_session` monta `role`, `link_id` e `organization_id` a partir do método novo de `UserService` |
| `app/domains/authentication/router.py` | `/session` devolve `link_id` e `organization_id` |
| `app/domains/users/service.py` | apagar `get_active_user_by_email`, se ninguém mais o chamar |
| `scripts/seed_local.py` | cria e liga o vínculo |
| `README.md` | rodar o script de novo depois do `alembic upgrade head` desta entrega |
| `tests/shared/test_authorization.py` | o `_FakeUserService` responde o método novo |
| `tests/domains/authentication/test_service.py` e `test_router.py` | a sessão com os dados do vínculo |

### O que já existe e deve ser reusado

1. A guarda, que é o ponto de partida: esta entrega altera o próprio arquivo, mantendo a forma que ele já tem. [`app/shared/authorization.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/shared/authorization.py).
2. Os testes da guarda, que continuam valendo: [`tests/shared/test_authorization.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/tests/shared/test_authorization.py).
3. A montagem da sessão: [`app/domains/authentication/service.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/authentication/service.py) e [`app/domains/authentication/router.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/authentication/router.py).
4. O script de preparação: [`scripts/seed_local.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/scripts/seed_local.py).
5. O realm local, com o usuário de desenvolvimento: [`docker/keycloak/realm-creed.json`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/docker/keycloak/realm-creed.json).

### Pronto quando

- [ ] Token admin e vínculo admin → 200 numa rota `require_role("admin")`.
- [ ] Token admin, vínculo gestor e coluna antiga `user.role = admin` → 401, com erro no log. É o teste que prova que a coluna antiga deixou de ser lida. Sem ele, a entrega não está pronta.
- [ ] Usuário sem vínculo → 401, tanto em rota que só exige login quanto em `require_role`.
- [ ] Token respondente numa rota admin → 403 sem consultar o banco. O teste `test_insufficient_role_does_not_query_the_database` continua passando.
- [ ] Login e `/renew` devolvem `role`, `link_id` e `organization_id` do vínculo; usuário sem vínculo no login → 401 com a mensagem de credencial inválida que já existe.
- [ ] `GET /api/v1/authentication/session` devolve `link_id` e `organization_id` preenchidos.
- [ ] `grep -rn "\.role\b" app/` não encontra nenhuma leitura de `user.role` ou `User.role`.
- [ ] `python scripts/seed_local.py` rodado duas vezes deixa o usuário de desenvolvimento com um único vínculo admin, e o login local funciona.
- [ ] `ruff check . && mypy app && pytest` passam.

### Como verificar

```bash
cd creed-backend
alembic upgrade head
python scripts/seed_local.py && python scripts/seed_local.py
docker compose exec db psql -U creed -d creed -c "SELECT count(*) FROM links"
ruff check . && mypy app && pytest
uvicorn app.main:app --reload
TOKEN=$(curl -s -X POST localhost:8000/api/v1/authentication/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"dev@creed.example.com","password":"<senha do realm>"}' | jq -r .access_token)
curl -s localhost:8000/api/v1/authentication/session -H "Authorization: Bearer $TOKEN"
```

A prova manual de que a coluna antiga não é mais lida:

```bash
# a coluna muda, o vínculo não: a sessão continua admin
docker compose exec db psql -U creed -d creed \
  -c "UPDATE \"user\" SET role = 'RESPONDENTE' WHERE email = 'dev@creed.example.com'"
curl -s localhost:8000/api/v1/authentication/session -H "Authorization: Bearer $TOKEN"

# o vínculo muda: 401, porque o token diz admin e o vínculo diz gestor
docker compose exec db psql -U creed -d creed -c "UPDATE links SET role = 'GESTOR'"
curl -i localhost:8000/api/v1/authentication/session -H "Authorization: Bearer $TOKEN"

# desfazer
docker compose exec db psql -U creed -d creed -c "UPDATE links SET role = 'ADMIN'"
```

### Decisões já tomadas que valem aqui

- Não existe login sem vínculo. Aqui isso é o 401 para quem não tem vínculo.
- Os papéis comparados com o token são `admin`, `gestor` e `respondente`.

### Materiais para consumir

- ✅ Arquivos de exemplo e realm: linkados acima.

### Depende de

CREED-324 — usa o método de leitura que ela cria.

### Rastreio

```
Rastreio: 86e3anvg2/5 — creed-ai-context/tarefas/86e3anvg2-vinculo-table-context/5_task.md
```

---

## Parte 3 — subtarefa 6

**Título:** CREED-326 - Remover o papel antigo da tabela de usuários

### Em uma frase

A coluna de papel sai da tabela de usuários, e todo acesso passa a ser obrigado a ter um vínculo.

### O que muda para quem usa

Nada muda no comportamento: desde a CREED-325, ninguém lê essa coluna. Esta entrega só remove o que sobrou, para que ninguém volte a lê-la por engano.

**Esta entrega é um pull request separado**, aberto só depois de as CREED-321 a 325 estarem na `dev` e de o time ter rodado `python scripts/seed_local.py`. A regra do projeto para mudança que apaga coisa no banco é em três passos (acrescentar o caminho novo, migrar os dados, remover o velho), nunca os três no mesmo pull request. As entregas anteriores acrescentaram; o script de preparação migrou; esta remove.

### Como pretendemos fazer

Uma revisão do Alembic que, **antes de alterar qualquer coisa**, conta os usuários sem vínculo. Se houver algum, ela para com uma mensagem dizendo quantos são e o que fazer, em vez de deixar o Postgres falhar com um erro genérico de campo obrigatório. Não há ambiente real com dados, então "dado existente" aqui é o banco local de cada pessoa.

O `downgrade()` não recupera o papel antigo: ele recria a coluna aceitando vazio, porque não há de onde tirar os valores. Escreva isso no comentário do topo da revisão. É aceitável: no projeto, voltar atrás se faz com uma revisão nova, e o `downgrade()` só precisa ser coerente.

Não existe outra revisão que apague coisa no projeto para copiar. Esta é a primeira, e o checklist dela responde "sim" a "mudança destrutiva foi dividida em passos?", citando o pull request da CREED-321.

### A revisão

`upgrade()`, nesta ordem:

1. `SELECT count(*) FROM "user" WHERE link_id IS NULL`. Se for maior que zero, `raise RuntimeError(...)` com quantos são e o que fazer: rodar `python scripts/seed_local.py`, ou apagar os usuários de teste criados à mão.
2. `op.alter_column("user", "link_id", nullable=False)`.
3. `op.drop_column("user", "role")`.
4. `sa.Enum(name="userrole").drop(op.get_bind(), checkfirst=True)`.

`downgrade()`: recria o tipo `userrole`, recria `role` aceitando vazio, e devolve `link_id` para aceitar vazio.

O gerador automático costuma escrever o `drop_column` e esquecer de apagar o tipo. Leia o arquivo gerado.

### Onde isso encosta no código

| Arquivo | O que nasce ou muda ali |
|---|---|
| `alembic/versions/<hash>_drop_user_role.py` | a revisão |
| `app/domains/users/models.py` | sai `role`, sai `UserRole`, e `link_id` passa a `nullable=False` |
| `app/domains/links/models.py` | tira do comentário de `Roles` a menção à duplicação |
| `tests/domains/users/test_service.py`, `tests/shared/test_authorization.py`, `tests/domains/authentication/test_service.py`, `scripts/seed_local.py` | tudo que ainda importar `UserRole` (confira com `grep`) |

### O que já existe e deve ser reusado

1. A forma da revisão e do checklist no comentário do topo: [`alembic/versions/49ef1d2c7b7e_form_response_table.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/alembic/versions/49ef1d2c7b7e_form_response_table.py).
2. A tabela que muda: [`app/domains/users/models.py`](https://github.com/creed-educa-ai/creed-backend/blob/ffd54ed3084f68fa80733fd59829405ab6c6e47b/app/domains/users/models.py).

### Pronto quando

- [ ] Com um usuário sem vínculo no banco, `alembic upgrade head` para com a mensagem desta entrega, e o banco fica como estava.
- [ ] Com todos vinculados, `alembic upgrade head` passa; `\d "user"` mostra `link_id` obrigatório e sem `role`; `\dT` não lista `userrole`.
- [ ] `alembic downgrade -1 && alembic upgrade head` roda sem erro.
- [ ] `grep -rn "UserRole" app/ tests/ scripts/` volta vazio.
- [ ] `alembic heads` devolve uma linha no momento de mesclar.
- [ ] O comentário do topo diz que o `downgrade()` não recupera os papéis, e o checklist está preenchido.
- [ ] `ruff check . && mypy app && pytest` passam.

### Como verificar

```bash
cd creed-backend
python scripts/seed_local.py
alembic heads
alembic revision --autogenerate -m "drop user role"
alembic upgrade head
alembic downgrade -1 && alembic upgrade head
ruff check . && mypy app && pytest
```

O caso de borda, à mão:

```bash
alembic downgrade -1
docker compose exec db psql -U creed -d creed -c \
  "INSERT INTO \"user\" (id, keycloak_id, name, email, status) VALUES (gen_random_uuid(), gen_random_uuid(), 'Sem vinculo', 'sem@vinculo.test', 'ACTIVE')"
alembic upgrade head
docker compose exec db psql -U creed -d creed -c "DELETE FROM \"user\" WHERE email = 'sem@vinculo.test'"
alembic upgrade head
```

O primeiro `upgrade` tem de parar com a mensagem; o segundo tem de passar.

### Decisões já tomadas que valem aqui

- O papel de acesso mora no vínculo (decisão do time, 2026-09-24). Esta entrega é o último passo dela.

### Materiais para consumir

- ✅ Arquivos de exemplo: linkados acima.

### Depende de

CREED-325, **já na `dev`**, e o time avisado para rodar o script de preparação.

### Rastreio

```
Rastreio: 86e3anvg2/6 — creed-ai-context/tarefas/86e3anvg2-vinculo-table-context/6_task.md
```
