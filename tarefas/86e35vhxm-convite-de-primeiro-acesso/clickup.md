# CREED-23.8 — rascunho de publicação no ClickUp

```
Épico: 86e35vhxm — CREED-23.8 - Convite de primeiro acesso por e-mail (link para o realm do Keycloak)
Spec: spec.md · Tasks: tasks.md
Gerado em: 2026-10-24 · Refeito em: 2026-10-27 (Gmail no lugar do SES, ADR-0006) · Publicado em: ainda não
```

A 23.8 é subtarefa da CREED-23 no board. Aqui ela faz o papel de épico: a descrição dela
é trocada pela Parte 2, e as oito entregas viram subtarefas **dela** (`parent: 86e35vhxm`),
com o prefixo `CREED-23.8.N`.

## Mapa de publicação

| # | Título da subtarefa | Repo | Ação | ID no ClickUp |
|---|---|---|---|---|
| — | CREED-23.8 - Convite de primeiro acesso por e-mail (link para o realm do Keycloak) | — | **atualizar** a descrição (a de 08/09 está desatualizada); título, status e responsável ficam | `86e35vhxm` |
| 1 | CREED-23.8.1 - Keycloak local envia e-mail de convite em português | `creed-backend` | criar | — |
| 2 | CREED-23.8.2 - Criar acesso cria o usuário nos dois lados e manda o convite | `creed-backend` | criar | — |
| 3 | CREED-23.8.3 - Adicionar membro à organização numa chamada só | `creed-backend` | criar | — |
| 4 | CREED-23.8.4 - Reenviar convite e redefinir senha por e-mail | `creed-backend` | criar | — |
| 5 | CREED-23.8.5 - Primeiro admin de cada ambiente nasce por convite | `creed-backend` | criar | — |
| 6 | CREED-23.8.6 - Site sem tela de senha, com recuperação por e-mail e convite de membro | `creed-frontend` | criar | — |
| 7 | CREED-23.8.7 - Produção envia e-mail pelo Gmail do projeto | `creed-infrastructure` | criar | — |
| 8 | CREED-23.8.8 - Documentação do projeto descreve o convite | `creed-ai-context` | criar | — |

Lido em 2026-10-24: a 23.8 não tem subtarefas e não muda desde 2026-09-10. O comentário de
10/09 (ADR-0006) não é tocado. Ninguém é designado nas subtarefas: o status é o padrão da
lista.

⚠️ **Subtarefa de subtarefa.** Se o board recusar `parent: 86e35vhxm` porque a 23.8 já é
subtarefa, a publicação para na primeira criação e volta com a alternativa: criar as oito
como subtarefas da CREED-23, com o mesmo prefixo.

## Materiais — visão do épico

| Material | Onde está | Vai em | Situação |
|---|---|---|---|
| Documento da tarefa (spec da 23.8, com o contrato) | `tarefas/86e35vhxm-convite-de-primeiro-acesso/spec.md` | épico, 1 a 6 | ⬜ falta anexar — **Luís (AGES III)**. Enquanto isso, o link da `main` abre |
| Decisão de arquitetura do e-mail (ADR-0006), com o adendo do Gmail | `decisoes/adrs/0006-e-mail-transacional.md` | épico, 1, 2, 7, 8 | ✅ link permanente (`main` de 27/10) |
| Os arquivos que já fazem algo parecido | `creed-backend`, `creed-frontend`, `creed-infrastructure` | 1 a 7 | ✅ links permanentes (`dev` de 24/10) |
| Texto das decisões tomadas sem a cliente | `decisoes/premissas.md` | todas | ✅ colado no corpo |
| Definições de organização, participante, vínculo e mentorando | `glossario.md` e spec | épico, 2, 3, 5 | ✅ colado no corpo |
| Documentação externa (Keycloak, Mailpit, Google) | sites dos projetos | 1, 2, 7 | ✅ links |
| Protótipo da tela de recuperar senha (Figma), se existir | — | 6 | ⬜ falta o link — **Leonardo (front)** |
| Credenciais do Gmail do projeto e acesso à EC2 | — | 7 | ⬜ dependência de pessoa — **Enzo (CREED-28)** |

A revisão de 24/10 saiu dos materiais: o roteiro da AWS dela (§10) foi superado pelo adendo
do ADR-0006.

---

# Parte 2 — descrição do épico (`86e35vhxm`)

## O que é

Hoje, para alguém entrar na plataforma, uma pessoa do time cria o acesso à mão, escolhe
uma senha e entrega essa senha por fora, por WhatsApp ou papel. Esta tarefa troca isso por
um **convite por e-mail**. Quem é cadastrado recebe um link, define a própria senha numa
página segura e entra pela tela de login. O mesmo caminho serve para quem esqueceu a senha.

É também esta tarefa que destrava as telas que dão acesso a alguém: adicionar membro no
painel da empresa, adicionar mentorando e aprovar empresa.

## Para quem, e o que muda para essa pessoa

| Quem | Hoje | Depois desta entrega |
|---|---|---|
| Administrador (a professora e o time CREED) | cria o acesso no console técnico e passa a senha por fora | convida por e-mail, em qualquer organização, e reenvia o convite quando o link vence |
| Responsável pela empresa (gestor) | não consegue dar acesso a ninguém | convida funcionários e outros gestores da própria empresa |
| Pessoa convidada | recebe uma senha de alguém | recebe um e-mail, define a própria senha e entra |
| Quem esqueceu a senha | depende de um administrador | pede um link pelo próprio e-mail, na tela de login |

Termos usados nas subtarefas:

- **Organização**: a instituição parceira; no painel, a empresa.
- **Participante**: a pessoa, independente da organização.
- **Vínculo**: a ligação de uma pessoa com uma organização, com um papel (`admin`,
  `gestor` ou `respondente`) e um tipo (`emprego`, `mentoria`, `academico` ou `pessoal`).
  Todo login da plataforma é de um vínculo.
- **Mentorando**: pessoa acompanhada pela professora, sem estar ligada a uma empresa.
- **Keycloak**: o serviço que guarda as senhas e faz o login. A plataforma nunca guarda
  senha, e quem manda o e-mail é o Keycloak, não o nosso servidor.

## O que entra nesta rodada

- E-mail de convite em português, com link que vale 72 horas.
- Cadastro de acesso que cria a conta nos dois lugares (banco da plataforma e Keycloak) e
  manda o convite. Se algo falhar, não cria nada.
- "Adicionar membro" numa chamada só, com a regra de quem pode convidar quem.
- Reenviar convite e "esqueci minha senha".
- Primeiro administrador de cada ambiente criado por convite, sem senha conhecida.
- Site sem tela de senha própria.
- Produção enviando e-mail pelo Gmail do projeto.

## O que não entra — e por quê

- **Status do convite (pendente ou aceito) e a tabela de membros**: são da CREED-503.
- **A página do painel da empresa**: é da CREED-50. Esta tarefa deixa pronta a chamada
  que ela usa.
- **As telas de mentorandos e de aprovação de empresa**: são da CREED-594, 591 e 595.
  Elas usam o que esta tarefa entrega.
- **Texto de convite personalizado**: nesta rodada basta o texto padrão do Keycloak, em
  português.
- **Domínio próprio e, com ele, o serviço de e-mail da AWS**: é decisão de
  infraestrutura. Sem domínio, os e-mails saem de um Gmail do projeto, e o link sai com o
  número de IP do servidor. Quando houver domínio, a troca é só de configuração.

## Como vai ser verificado

1. No ambiente local, convidar uma pessoa e ver o e-mail chegar, em português, na caixa
   de testes (Mailpit).
2. Abrir o link e definir uma senha (com menos de 8 caracteres ela é recusada), depois
   entrar pela tela de login.
3. Com o envio de e-mail parado, tentar convidar. A plataforma diz que não conseguiu agora
   e não deixa nada criado pela metade.
4. Em produção, o primeiro administrador recebe o convite num endereço real e entra. A
   conta de e-mail é nova, então vale olhar também o spam.

## Como decidimos fazer — uma linha cada

| A decisão | O que ela nos dá |
|---|---|
| Se o convite não sai, nada é criado (tudo ou nada) | sem cadastro pela metade; quem cadastra tenta de novo |
| "Adicionar membro" é uma chamada só, resolvida no servidor | uma transação, e o site não junta três cadastros |
| O servidor fala com o Keycloak por um cliente próprio, sem biblioteca nova | quatro chamadas que o projeto já sabe fazer |
| "Esqueci minha senha" passa pelo nosso servidor | o site continua sem conhecer o endereço do Keycloak |
| Mudanças de configuração do Keycloak de produção entram por script versionado | nada configurado clicando, e nada some ao recriar |
| Só o administrador muda o e-mail de uma conta no Keycloak | a pessoa não perde o acesso trocando o próprio e-mail |

## Decisões que tomamos sem a cliente

| O que decidimos | Por quê | Custo de mudar depois |
|---|---|---|
| O administrador convida em qualquer organização e com qualquer papel; o gestor só na própria empresa, e só como gestor ou respondente; o respondente não convida | é o que o formulário de adicionar membro já desenha | baixo |
| O convite pede o nome da pessoa | o cadastro exige nome, e usar o e-mail no lugar gravaria dado errado | baixo |
| Membro de empresa entra com vínculo de emprego, a menos que se diga outro tipo | o formulário não pergunta | baixo |
| Mentorando fica numa organização da própria CREED, com vínculo de mentoria e papel de respondente | todo acesso precisa de uma organização | médio |
| O link do convite e o de nova senha valem 72 horas | as 12 horas do padrão vencem de um dia para o outro | baixo |
| O e-mail usa o texto padrão do Keycloak, em português | menor escopo; um texto próprio pode vir depois | baixo |
| Depois de definir a senha, um link leva de volta ao login da plataforma; não há login automático | sem o link, a pessoa fica numa página sem saída | baixo |
| O primeiro administrador de produção nasce por convite, e a primeira convidada é a professora | ninguém nasce com senha conhecida | baixo |
| Na aprovação de empresa, o convite vai para o e-mail do cadastro, em nome de quem cadastrou, como gestor | quem cadastrou é quem administra a empresa | médio |
| Os e-mails saem de um Gmail do projeto (`@gmail.com`), assinados como "CREED.ai Educa", até haver domínio próprio | sem domínio, é o único remetente que não cai no filtro de fraude dos provedores | baixo: muda só configuração |

## As entregas

| # | Entrega | Onde | Depende de |
|---|---|---|---|
| 1 | CREED-23.8.1 - Keycloak local envia e-mail de convite em português | servidor | — |
| 2 | CREED-23.8.2 - Criar acesso cria o usuário nos dois lados e manda o convite | servidor | 1 (a guarda da remoção de usuário, creed-backend#47, já entrou em 27/10) |
| 3 | CREED-23.8.3 - Adicionar membro à organização numa chamada só | servidor | 2 |
| 4 | CREED-23.8.4 - Reenviar convite e redefinir senha por e-mail | servidor | 2, depois da 3 |
| 5 | CREED-23.8.5 - Primeiro admin de cada ambiente nasce por convite | servidor | 2 |
| 6 | CREED-23.8.6 - Site sem tela de senha, com recuperação por e-mail e convite de membro | site | só o contrato: pode começar já |
| 7 | CREED-23.8.7 - Produção envia e-mail pelo Gmail do projeto | infraestrutura | 1, e a publicação do servidor para rodar |
| 8 | CREED-23.8.8 - Documentação do projeto descreve o convite | documentação | 2 a 7 |

Fora do board, mas no caminho:

- a consolidação das migrations (CREED-57), sem a qual o fluxo não sobe num banco limpo;
- o acesso à EC2 e as credenciais do Gmail do projeto, que ficam com o Enzo.

## Materiais desta tarefa

- ⬜ Documento da tarefa, com o contrato completo — **anexar: Luís (AGES III)**. Enquanto
  isso, abre no repositório:
  [spec.md](https://github.com/creed-educa-ai/creed-ai-context/blob/main/tarefas/86e35vhxm-convite-de-primeiro-acesso/spec.md).
- ✅ [Decisão de arquitetura do e-mail, com o adendo do Gmail](https://github.com/creed-educa-ai/creed-ai-context/blob/0e47cebec332f1addcddd3dfaefbfbc8479a7632/decisoes/adrs/0006-e-mail-transacional.md).
- ✅ [PR da discovery (creed-ai-context#36)](https://github.com/creed-educa-ai/creed-ai-context/pull/36).

## Rastreio

```
creed-ai-context/tarefas/86e35vhxm-convite-de-primeiro-acesso/spec.md
```

---

# Parte 3 — subtarefas

## 1 — CREED-23.8.1 - Keycloak local envia e-mail de convite em português

### Em uma frase

No ambiente de desenvolvimento, o Keycloak passa a mandar e-mail em português para uma
caixa de testes, com regra de senha mínima e link de volta para o site.

### O que muda para quem usa

Ninguém de fora vê esta entrega: ela prepara o terreno. Ao subir o ambiente local, quem
desenvolve passa a ter uma caixa de e-mail de testes, o Mailpit
(<http://localhost:8025>), onde chegam os e-mails que o Keycloak manda. Sem isso, ninguém
consegue testar o convite.

Ela também acerta três coisas que a pessoa convidada vai ver:

- a página de definir senha em português;
- a recusa de senha com menos de 8 caracteres;
- um link de volta para o login da plataforma depois de definir a senha.

O Keycloak é o serviço que guarda as senhas e faz o login. A plataforma nunca guarda
senha, e quem manda o e-mail é o Keycloak, não o nosso servidor.

### Como pretendemos fazer

Tudo entra no arquivo de configuração do Keycloak que já fica no repositório
(`docker/keycloak/realm-creed.json`), nunca clicado na tela de administração. Configurar
clicando deixa desenvolvimento e produção diferentes sem ninguém perceber.

Esse arquivo é público e é o mesmo que a produção importa, então nenhum segredo entra
nele. Os dados do servidor de e-mail entram como variáveis `${VARIAVEL}`, **sem o prefixo
`env.`**: com o prefixo, a troca falha em silêncio, e o erro só aparece na hora do envio.
Os valores locais ficam no `docker-compose.yml`. Em produção, o servidor de e-mail é o do
Gmail do projeto, que exige conexão criptografada (TLS). Por isso `starttls` e `ssl`
também entram como variáveis.

O e-mail de uma conta passa a ser editável só por administrador, no perfil do Keycloak.
Hoje a pessoa consegue trocar o próprio e-mail na página de conta dele, e com isso perderia
o acesso, porque o login procura a pessoa pelo e-mail.

A política de senha nova recusa a senha `dev` do usuário de testes. A senha do script que
monta o ambiente local muda junto (sugestão: `dev-creed`).

### Onde isso encosta no código (`creed-backend`)

| Arquivo | O que nasce ou muda ali |
|---|---|
| `docker-compose.yml` | serviço `mailpit` com versão fixa, portas `8025` (tela) e `1025` (SMTP). No `keycloak`: `SMTP_HOST=mailpit`, `SMTP_PORT=1025`, `SMTP_FROM=nao-responda@creed.local`, `SMTP_AUTH=false`, `SMTP_STARTTLS=false`, `SMTP_SSL=false`, `SMTP_USER=`, `SMTP_PASSWORD=` e `CREED_FRONTEND_URL=http://localhost:5173` |
| `docker/keycloak/realm-creed.json` | `"internationalizationEnabled": true`, `"supportedLocales": ["pt-BR", "en", "es"]`, `"defaultLocale": "pt-BR"`; `"passwordPolicy": "length(8)"`; `"smtpServer"` com `host`, `port`, `from`, `auth`, `starttls`, `ssl`, `user` e `password` por variável, e `"fromDisplayName": "CREED.ai Educa"`; `"redirectUris": ["${CREED_FRONTEND_URL}/*"]` no client `creed-backend`; o atributo `email` do perfil com `"edit": ["admin"]` |
| `app/core/config.py` | `KEYCLOAK_INVITE_LIFESPAN_SECONDS: int = 259200` (72 h) e `FRONTEND_URL: str = ""` (vazia desliga o link de volta) |
| `.env.example` | as duas variáveis, com `FRONTEND_URL=http://localhost:5173` |
| `scripts/seed_local.py` | `PASSWORD` com 8 caracteres ou mais |
| `README.md` | o Mailpit, a senha nova do usuário de testes e o aviso de `docker compose down -v` (que apaga também o banco local) |
| `tests/test_realm_keycloak.py` | um teste por bloco novo |
| `tests/test_config.py` | os padrões das duas settings |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| teste que garante que o segredo vem do ambiente | `test_segredo_e_ssl_chegam_pelo_ambiente` em [tests/test_realm_keycloak.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/tests/test_realm_keycloak.py) | forma dos testes novos |
| serviço com versão fixa e o comentário do porquê | o `n8n` em [docker-compose.yml](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/docker-compose.yml) | forma do `mailpit` |
| setting com comentário do porquê | `KEYCLOAK_PUBLIC_URL` em [app/core/config.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/app/core/config.py) | forma das settings novas |
| a configuração atual do Keycloak | [docker/keycloak/realm-creed.json](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/docker/keycloak/realm-creed.json) | onde os blocos novos entram |

### Pronto quando

- [ ] `docker compose down -v && docker compose up -d` sobe o Mailpit e o Keycloak já com
      o e-mail configurado, sem clique.
- [ ] O envio manual de "Como verificar" responde 204, e o e-mail aparece em
      <http://localhost:8025>, em português.
- [ ] A página do link recusa senha de 7 caracteres e aceita de 8.
- [ ] O usuário de testes entra com a senha nova.
- [ ] Os testes do arquivo de configuração cobrem:
  - [ ] a senha do e-mail é variável, nunca escrita no arquivo;
  - [ ] `starttls` e `ssl` estão presentes;
  - [ ] o idioma padrão é português;
  - [ ] a senha mínima é de 8 caracteres;
  - [ ] o link de volta é variável;
  - [ ] o e-mail não é editável pela própria pessoa.
- [ ] Os testes que já existiam continuam verdes.
- [ ] O PR diz se o Keycloak aceitou o link de volta (`redirect_uri`) no envio manual. Se
      recusou, a CREED-23.8.2 manda o e-mail sem ele.

### Como verificar

```bash
cd creed-backend
docker compose down -v && docker compose up -d
alembic upgrade head
python scripts/seed_local.py

# token do servidor e id do usuário de testes no Keycloak
curl -s -X POST http://localhost:8080/realms/creed/protocol/openid-connect/token \
  -d grant_type=client_credentials -d client_id=creed-backend -d client_secret=creed-local-secret
curl -s "http://localhost:8080/admin/realms/creed/users?email=dev@creed.example.com&exact=true" \
  -H "Authorization: Bearer <access_token>"

# o envio: espera 204 e um e-mail em http://localhost:8025
curl -s -o /dev/null -w '%{http_code}\n' -X PUT \
  "http://localhost:8080/admin/realms/creed/users/<id>/execute-actions-email?lifespan=259200&client_id=creed-backend&redirect_uri=http://localhost:5173/login" \
  -H "Authorization: Bearer <access_token>" -H 'Content-Type: application/json' \
  -d '["UPDATE_PASSWORD"]'

pytest tests/test_realm_keycloak.py tests/test_config.py tests/test_seed_local.py -q
ruff check . && ruff format --check . && mypy app && pytest
pre-commit run mypy --all-files
```

Sem a consolidação das migrations (CREED-57), o script de dados para no banco. Mas ele para
depois de criar o usuário de testes no Keycloak, então o teste do e-mail funciona assim
mesmo.

- **Caso feliz:** o e-mail chega em português, e a senha nova funciona no login.
- **Caso de borda:** a senha `1234567`, de 7 caracteres, é recusada na página do link.

### Decisões já tomadas que valem aqui

- **O link vale 72 horas.** As 12 horas do padrão do Keycloak vencem de um dia para o
  outro. Se mudar, muda só a setting.
- **O e-mail usa o texto padrão do Keycloak, em português.** As páginas abrem em
  português, com inglês e espanhol disponíveis. Um texto próprio de convite pode vir
  depois, sem mudar o servidor.
- **Depois de definir a senha, um link leva ao login da plataforma.** Com `FRONTEND_URL`
  vazia, o link some.
- **A senha tem no mínimo 8 caracteres, sem regra extra de complexidade.** A regra sai do
  site e passa a valer no Keycloak.

### Materiais para consumir

| Material | Situação |
|---|---|
| Decisão de arquitetura do e-mail: Mailpit no local, Keycloak envia, segredo por variável | ✅ [ADR-0006](https://github.com/creed-educa-ai/creed-ai-context/blob/0e47cebec332f1addcddd3dfaefbfbc8479a7632/decisoes/adrs/0006-e-mail-transacional.md) |
| Keycloak: importação de configuração e e-mail | ✅ <https://www.keycloak.org/server/importExport> · <https://www.keycloak.org/docs/latest/server_admin/#_email> |
| Mailpit | ✅ <https://mailpit.axllent.org/> |
| Documento da tarefa | ⬜ falta anexar — **Luís (AGES III)** |

### Depende de

Nenhuma.

### Rastreio

```
Rastreio: 86e35vhxm/1 — creed-ai-context/tarefas/86e35vhxm-convite-de-primeiro-acesso/1_task.md
```

---

## 2 — CREED-23.8.2 - Criar acesso cria o usuário nos dois lados e manda o convite

### Em uma frase

Cadastrar o acesso de alguém passa a criar a conta no Keycloak e no banco da plataforma e
a mandar o e-mail de convite. É tudo ou nada.

### O que muda para quem usa

Hoje, para dar acesso, alguém cria a pessoa à mão no Keycloak, copia um identificador de
lá e só então cadastra na plataforma, entregando a senha por fora. Depois desta entrega, o
cadastro faz tudo:

1. cria a pessoa no Keycloak **sem senha**, com o papel certo;
2. grava a pessoa na plataforma;
3. manda o e-mail. A pessoa define a própria senha pelo link.

Se qualquer passo falhar (o envio de e-mail fora do ar, por exemplo), nada fica criado pela
metade. A plataforma responde que não conseguiu agora, e quem cadastrou tenta de novo.

Duas mudanças vêm junto:

- Remover um acesso passa a remover nos dois lados, para o mesmo e-mail poder ser
  convidado de novo.
- Tentar entrar com o Keycloak fora do ar passa a dizer "não foi possível agora", e não
  "senha inválida".

### Como pretendemos fazer

A ordem importa. É a decisão do time de tudo ou nada:

```
1. banco: e-mail livre, vínculo existe e ainda não tem login        → 409 / 404
2. Keycloak: cria sem senha (username = e-mail) e pega o id          → 409 / 503
3. Keycloak: dá o papel do vínculo
4. banco: grava o usuário com esse id (flush, sem commit)
5. Keycloak: manda o e-mail ["UPDATE_PASSWORD"]                      → 503 se o envio falhar
   falhou 3, 4 ou 5 → apaga no Keycloak e propaga o erro; o banco volta sozinho
```

"Vínculo" é a ligação de uma pessoa com uma organização, com um papel (`admin`, `gestor`
ou `respondente`). Todo login é de um vínculo.

O servidor fala com o Keycloak por um cliente novo da API de administração dele. As
chamadas certas já existem, testadas, no script que monta o ambiente local.

- **Commit:** o do banco acontece quando a rota termina. Não chame `commit()`: um teste de
  arquitetura reprova.
- **A pessoa no Keycloak** nasce sem nome e sem senha:
  `{"username": email, "email": email, "enabled": true, "requiredActions": []}`.
- **O e-mail** vai com `lifespan` de `settings.KEYCLOAK_INVITE_LIFESPAN_SECONDS`. Se
  `settings.FRONTEND_URL` não estiver vazia, vão também `client_id=creed-backend` e
  `redirect_uri={FRONTEND_URL}/login`.
- **Na remoção:** primeiro o banco (flush), depois o Keycloak. Se o Keycloak responder
  404, a pessoa já não existia lá, e isso conta como sucesso.

### Onde isso encosta no código (`creed-backend`)

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/external_services/keycloak/admin.py` (novo) | `create_user(email) -> uuid.UUID` · `assign_realm_role(keycloak_id, role)` · `send_update_password_email(keycloak_id)` · `delete_user(keycloak_id)` · `KeycloakConflictError` · `build_http_client()` |
| `app/shared/exceptions.py` | `ServiceUnavailableError(DomainError)`, que vira 503 no router |
| `app/domains/users/schemas.py` | `UserCreate` sem `keycloak_id` |
| `app/domains/users/service.py` | `create_user_service` na ordem acima; `delete_user_service` apaga também no Keycloak |
| `app/domains/users/router.py` | 503 documentado no `POST` e no `DELETE` |
| `app/domains/authentication/service.py` e `router.py` | Keycloak fora do ar no login e na renovação vira 503 |
| testes | `tests/external_services/keycloak/test_admin.py` (novo), `tests/domains/users/`, `tests/domains/authentication/` e `tests/test_openapi.py` |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| as chamadas da API de administração: token, criar, dar papel | `_service_account_token` e `_criar_no_realm` em [scripts/seed_local.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/scripts/seed_local.py) | o caminho certo, já testado: o id vem no cabeçalho `Location`, e o papel é uma chamada à parte |
| cliente HTTP do Keycloak e o ponto de troca nos testes | [app/external_services/keycloak/client.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/app/external_services/keycloak/client.py) | forma do `admin.py`; reusar o `KeycloakUnavailableError` |
| teste com transporte falso (`httpx.MockTransport`) | [tests/external_services/keycloak/test_client.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/tests/external_services/keycloak/test_client.py) | forma do `test_admin.py` |
| erro externo virando erro de domínio | `AuthenticationService.login` em [app/domains/authentication/service.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/app/domains/authentication/service.py) | forma da tradução |

### Contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/users` (só `admin`) | `{ name, email, link_id }`, sem `keycloak_id` | `201` · `UserResponse` (sem mudança) |
| DELETE | `/api/v1/users/{user_id}` (só `admin`) | — | `204` |
| POST | `/api/v1/authentication/login` e `/api/v1/authentication/renew` | sem mudança | sem mudança |

| Código | Quando |
|---|---|
| 409 | o e-mail já tem acesso, no banco ou no Keycloak |
| 503 | o Keycloak ou o envio de e-mail não respondem: no `POST`, no `DELETE`, no login e na renovação |

Os códigos que já existiam (401, 403, 404, 422) continuam iguais.

### Pronto quando

- [ ] Criar com `{name, email, link_id}`:
  - [ ] cria no banco e no Keycloak, sem senha e com o papel do vínculo;
  - [ ] o e-mail chega ao Mailpit.
- [ ] Mandar `keycloak_id` no corpo não muda nada: o campo é ignorado. Assim, quem ainda
      manda o formato antigo não recebe erro.
- [ ] E-mail que já está no banco → 409, sem chamar o Keycloak. E-mail que só está no
      Keycloak → 409, sem gravar nada.
- [ ] Falha no papel, na gravação ou no envio → nada fica no Keycloak nem no banco. Há um
      teste para cada um dos três pontos.
- [ ] Remover apaga também no Keycloak. Com o Keycloak fora do ar, a resposta é 503 e o
      usuário continua.
- [ ] Login e renovação com o Keycloak fora do ar → 503. Senha errada continua 401.
- [ ] `admin.py` testado com transporte falso:
  - [ ] o formato das chamadas;
  - [ ] o id lido do `Location`;
  - [ ] 409, 5xx e erro de rede;
  - [ ] 404 na remoção.
- [ ] `tests/test_openapi.py` exige o 503 documentado nas quatro rotas.

### Como verificar

```bash
cd creed-backend
pytest tests/external_services/keycloak tests/domains/users tests/domains/authentication tests/test_openapi.py tests/test_arquitetura.py -q
ruff check . && ruff format --check . && mypy app && pytest
pre-commit run mypy --all-files
```

De ponta a ponta, com a CREED-23.8.1 de pé, pelo Swagger (`http://localhost:8000/api/v1/docs`):

1. Criar um participante, um vínculo e o usuário. Espera 201 e um e-mail no Mailpit.
2. Repetir com `docker compose stop mailpit`. Espera 503, e nada criado.
3. Rodar `docker compose stop keycloak` e tentar o login. Espera 503.

### Decisões já tomadas que valem aqui

- **Tudo ou nada.** Se o convite não sai, nada é criado, e quem cadastra tenta de novo. A
  alternativa, "cria e avisa que o e-mail não saiu", volta à mesa quando a tabela de
  membros mostrar status de convite.
- **O acesso nasce ativo.** Quem é criado pode entrar assim que definir a senha.
- **O Keycloak não recebe o nome da pessoa.** Ele guarda credencial, não cadastro.

### Materiais para consumir

| Material | Situação |
|---|---|
| API de administração do Keycloak | ✅ <https://www.keycloak.org/docs-api/latest/rest-api/index.html> |
| Decisão de arquitetura do e-mail | ✅ [ADR-0006](https://github.com/creed-educa-ai/creed-ai-context/blob/0e47cebec332f1addcddd3dfaefbfbc8479a7632/decisoes/adrs/0006-e-mail-transacional.md) |
| Documento da tarefa, com o contrato completo | ⬜ falta anexar — **Luís (AGES III)** |

### Depende de

- **CREED-23.8.1**, que traz as settings e o Mailpit.

A guarda de administrador na remoção de usuário
([creed-backend#47](https://github.com/creed-educa-ai/creed-backend/pull/47)), que também
mexe no `DELETE`, já entrou na `dev` em 27/10: comece da `dev` atual.

### Rastreio

```
Rastreio: 86e35vhxm/2 — creed-ai-context/tarefas/86e35vhxm-convite-de-primeiro-acesso/2_task.md
```

---

## 3 — CREED-23.8.3 - Adicionar membro à organização numa chamada só

### Em uma frase

O servidor passa a ter "adicionar membro": uma chamada só que cria a pessoa, liga a pessoa
à organização com um papel e manda o convite.

### O que muda para quem usa

O painel da empresa já tem o formulário de adicionar membro (e-mail e papel), mas ele
ainda não tem o que chamar. Depois desta entrega, a chamada existe:

- o responsável pela empresa (gestor) convida funcionários e outros gestores da própria
  empresa;
- o administrador da plataforma (a professora e o time CREED) convida em qualquer
  organização, com qualquer papel;
- só administrador convida administrador.

Hoje, chegar ao mesmo resultado exigiria três cadastros separados (pessoa, ligação com a
organização e acesso), todos só para administrador, e uma falha no meio deixaria dados
soltos. Com a chamada única, ou tudo é criado, ou nada.

"Organização" é a instituição parceira; no painel, a empresa. "Participante" é a pessoa,
independente da organização.

### Como pretendemos fazer

A ordem, numa transação só:

```
OrganizationService.get(organization_id, role=..., own_organization_id=...)    → 403 / 404
gestor convidando admin?                                                       → 403
ParticipantService.create_member_participant(name)
LinkService.create_member_link(organization_id, participant_id, role, link_type)
UserService.create_user_service(UserCreate(name=..., email=..., link_id=...))   → a CREED-23.8.2
```

- **`OrganizationService.get`** já responde 403 para organização alheia antes de olhar se
  ela existe.
- **Os dois métodos novos**, de participante e de vínculo, existem porque um domínio não
  pode montar o schema de outro: um teste de arquitetura reprova. Quem monta é o domínio
  dono.
- **`Roles` e `LinkType`** mudam para `app/shared/enums.py`, como o `Prisma` mudou. O tipo
  no banco não muda, e o PR diz isso na seção "Banco".
- **A regra nova fica numa segunda classe, `MemberService`.** Assim a verificação de login
  de toda rota não passa a montar participante e organização.

### Onde isso encosta no código (`creed-backend`)

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/shared/enums.py` | recebe `Roles` e `LinkType` |
| `app/domains/links/models.py` | importa os dois de `shared` |
| `app/domains/links/service.py` | `create_member_link(organization_id, participant_id, role, link_type) -> Link` |
| `app/domains/participants/service.py` | `create_member_participant(name: str) -> Participant` |
| `app/domains/users/schemas.py` | `MemberInvite` |
| `app/domains/users/service.py` | `MemberService(users, participants, links, organizations)` com `invite_member_service(...)` |
| `app/domains/users/dependencies.py` | `get_member_service` e `MemberServiceDep` |
| `app/domains/users/router_members.py` (novo) | `POST /organizations/{organization_id}/members` |
| `app/main.py` | registro do router e descrição da tag `users` |
| `tests/test_arquitetura.py` | o motivo de `users` em `COMPOE_COM_SERVICE_DE` passa a citar participante e organização |
| testes | `tests/domains/users/test_member_service.py` e `test_router_members.py` (novos), os de `links` e `participants`, e `tests/test_openapi.py` |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| segunda classe de service e segundo router no mesmo domínio | `QuestionOptionService` em [app/domains/questions/service.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/app/domains/questions/service.py) e [app/domains/questions/router_options.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/app/domains/questions/router_options.py) | forma do `MemberService` e do `router_members.py` |
| 403 de organização alheia | `OrganizationService.get` em [app/domains/organizacoes/service.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/app/domains/organizacoes/service.py) | reusar, não reescrever |
| teste de rota passando pela verificação de login de verdade | `autenticar_como` em [tests/domains/participants/test_router.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/tests/domains/participants/test_router.py) | forma dos testes de rota |

### Contrato

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/organizations/{organization_id}/members` | `{ name, email, role, type = "emprego" }` | `201` · `UserResponse` |

Os campos:

- `name`: de 2 a 200 caracteres, sem caractere de controle;
- `role`: `admin`, `gestor` ou `respondente`;
- `type`: `emprego`, `mentoria`, `academico` ou `pessoal`.

**Corpo da saída**

```json
{ "id": "uuid", "name": "Pessoa Teste", "email": "pessoa@creed.local", "status": "active",
  "role": "gestor", "link_id": "uuid", "organization_id": "uuid", "created_at": "2026-10-24T14:30:00Z" }
```

**Erros**

| Código | Quando |
|---|---|
| 401 | sem login |
| 403 | papel `respondente`; gestor em outra organização; gestor convidando `admin` |
| 404 | a organização não existe |
| 409 | o e-mail já tem acesso |
| 422 | o corpo está fora do formato |
| 503 | o Keycloak ou o envio de e-mail estão fora do ar |

### Pronto quando

- [ ] Administrador convida em qualquer organização → 201. Pessoa, vínculo e acesso são
      criados, e o e-mail chega ao Mailpit.
- [ ] Sem `type` no corpo, o vínculo nasce `emprego`. Com `type: "mentoria"`, nasce
      mentoria.
- [ ] Gestor convidando:
  - [ ] na própria organização, como gestor ou respondente → 201;
  - [ ] em outra organização → 403;
  - [ ] como administrador → 403.
- [ ] Respondente → 403. Sem login → 401. Organização inexistente → 404.
- [ ] E-mail que já tem acesso → 409, sem pessoa nem vínculo sobrando no banco.
- [ ] O teste de arquitetura passa. Com a consolidação feita, `alembic check` não acusa
      diferença.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/users tests/domains/links tests/domains/participants tests/test_arquitetura.py tests/test_openapi.py -q
ruff check . && ruff format --check . && mypy app && pytest
pre-commit run mypy --all-files

# de ponta a ponta, com o admin de testes logado e a organização do ambiente local
curl -s -w '\n%{http_code}\n' -X POST \
  http://localhost:8000/api/v1/organizations/00000000-0000-0000-0000-000000000001/members \
  -H "Authorization: Bearer <access_token>" -H 'Content-Type: application/json' \
  -d '{"name":"Pessoa Teste","email":"pessoa@creed.local","role":"gestor"}'
```

- **Caso feliz:** 201, e o e-mail chega.
- **Casos de borda:**
  - o mesmo e-mail de novo → 409;
  - a pessoa criada acima, já com senha, convidando com `"role":"admin"` → 403.

### Decisões já tomadas que valem aqui

- **Quem convida quem.** O administrador convida em qualquer organização e com qualquer
  papel; o gestor, só na própria e só como gestor ou respondente; o respondente não
  convida. Se mudar, muda a regra no service.
- **O convite pede o nome da pessoa.** O cadastro exige nome, e usar o e-mail no lugar
  gravaria dado errado.
- **Membro de empresa entra com vínculo de emprego** quando não se diz outro tipo.
- **O mentorando** (tela da CREED-594) usa esta chamada com `type: "mentoria"`, na
  organização da própria CREED.
- **A aprovação de empresa** (CREED-591) usa esta chamada com `role: "gestor"`, para o
  e-mail informado no cadastro.

### Materiais para consumir

| Material | Situação |
|---|---|
| Definições de organização, participante e vínculo | ✅ coladas acima |
| Documento da tarefa, com o contrato completo | ⬜ falta anexar — **Luís (AGES III)** |

### Depende de

CREED-23.8.2.

### Rastreio

```
Rastreio: 86e35vhxm/3 — creed-ai-context/tarefas/86e35vhxm-convite-de-primeiro-acesso/3_task.md
```

---

## 4 — CREED-23.8.4 - Reenviar convite e redefinir senha por e-mail

### Em uma frase

Quem perdeu o link do convite, ou deixou vencer, recebe outro. Quem esqueceu a senha pede
um link pelo próprio e-mail.

### O que muda para quem usa

O link do convite vale 72 horas. Se a pessoa não usou a tempo, o administrador, ou o
gestor da empresa dela, manda de novo. E quem esqueceu a senha não depende mais de
ninguém: na tela de login, "Esqueci minha senha" pede o e-mail e manda um link para definir
uma nova.

Para não revelar quem tem cadastro, o pedido de nova senha responde sempre a mesma coisa,
tenha o e-mail acesso ou não. Só quem tem acesso recebe o e-mail.

### Como pretendemos fazer

- **O mesmo e-mail do convite.** Os dois usam `admin.send_update_password_email`, da
  CREED-23.8.2, com a mesma validade.
- **Reenviar não confere se a pessoa já definiu senha.** Para quem já tem senha, o reenvio
  vira uma redefinição, e está tudo bem.
- **Usuário de outra organização responde 404, não 403**, para não dizer "existe, mas não
  é seu". A organização do usuário vem do vínculo dele, pelo
  `LinkService.get_link_by_id_service`, como a verificação de login já faz.
- **A redefinição passa pelo nosso servidor**, não pela página do Keycloak. O site continua
  sem conhecer o endereço do Keycloak, e a opção "esqueci a senha" do próprio Keycloak
  continua desligada.
- **A rota de redefinição é pública**, como o login.

### Onde isso encosta no código (`creed-backend`)

| Arquivo | O que nasce ou muda ali |
|---|---|
| `app/domains/users/service.py` | `resend_invitation_service(user_id, *, role, own_organization_id)` e `send_password_reset_service(email)` |
| `app/domains/users/router.py` | `POST /users/{user_id}/invitation` |
| `app/domains/authentication/schemas.py` | `PasswordResetRequest` |
| `app/domains/authentication/service.py` | `request_password_reset(email)`, que delega ao `UserService` |
| `app/domains/authentication/router.py` | `POST /authentication/password-reset` |
| testes | `tests/domains/users/`, `tests/domains/authentication/` e `tests/test_openapi.py` |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| rota pública com corpo de entrada | `POST /authentication/login` em [app/domains/authentication/router.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/app/domains/authentication/router.py) | forma da rota de redefinição |
| organização do usuário lida pelo vínculo | `get_active_user_access_by_email` em [app/domains/users/service.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/app/domains/users/service.py) | reusar o caminho |

### Contrato

| Método | Rota | Quem | Entrada | Saída |
|---|---|---|---|---|
| POST | `/api/v1/users/{user_id}/invitation` | `admin`; o `gestor` só para quem é da organização dele | — | `204` |
| POST | `/api/v1/authentication/password-reset` | público | `{ email }` | `204` |

| Código | Quando |
|---|---|
| 401 | reenvio sem login |
| 403 | reenvio por respondente |
| 404 | reenvio de usuário que não existe, ou que é de outra organização (para o gestor) |
| 422 | e-mail fora do formato |
| 503 | envio de e-mail fora do ar. Na redefinição, só aparece quando o e-mail tem acesso |

### Pronto quando

- [ ] Reenvio:
  - [ ] pelo administrador → 204 e um e-mail novo;
  - [ ] pelo gestor da mesma organização → 204; de outra organização → 404;
  - [ ] por respondente → 403;
  - [ ] de usuário inexistente → 404.
- [ ] Redefinição:
  - [ ] e-mail com acesso ativo → 204 e um e-mail;
  - [ ] e-mail sem acesso, ou de acesso inativo → 204 e nenhum e-mail;
  - [ ] com o Mailpit parado e e-mail que tem acesso → 503;
  - [ ] e-mail inválido → 422.
- [ ] `tests/test_openapi.py` tem as duas rotas.

### Como verificar

```bash
cd creed-backend
pytest tests/domains/users tests/domains/authentication tests/test_openapi.py -q
ruff check . && ruff format --check . && mypy app && pytest
pre-commit run mypy --all-files

# caso feliz: 204 e um e-mail no Mailpit
curl -s -o /dev/null -w '%{http_code}\n' -X POST http://localhost:8000/api/v1/authentication/password-reset \
  -H 'Content-Type: application/json' -d '{"email":"pessoa@creed.local"}'

# caso de borda: 204, sem e-mail
curl -s -o /dev/null -w '%{http_code}\n' -X POST http://localhost:8000/api/v1/authentication/password-reset \
  -H 'Content-Type: application/json' -d '{"email":"ninguem@creed.local"}'
```

### Decisões já tomadas que valem aqui

- **Quem reenvia segue a regra de quem convida.**
- **Os dois links valem 72 horas.**
- **"Esqueci minha senha" passa a existir.** Antes, quem perdia a senha pedia outra a um
  administrador.

### Materiais para consumir

| Material | Situação |
|---|---|
| Documento da tarefa, com o contrato completo | ⬜ falta anexar — **Luís (AGES III)** |

### Depende de

CREED-23.8.2. Vem depois da CREED-23.8.3, porque as duas mexem nos mesmos arquivos.

### Rastreio

```
Rastreio: 86e35vhxm/4 — creed-ai-context/tarefas/86e35vhxm-convite-de-primeiro-acesso/4_task.md
```

---

## 5 — CREED-23.8.5 - Primeiro admin de cada ambiente nasce por convite

### Em uma frase

Um comando cria o primeiro administrador de um ambiente, inclusive de produção, mandando
o convite por e-mail, sem senha conhecida.

### O que muda para quem usa

Em produção ainda não existe ninguém com acesso, e ninguém pode cadastrar ninguém sem já
ter acesso. Este comando resolve esse ovo e a galinha: quem cuida do servidor roda o
comando uma vez, com o e-mail e o nome da professora, e ela recebe o convite como qualquer
pessoa. Nenhuma senha passa de mão em mão.

O comando também cria a organização da própria CREED. Nela ficam os administradores da
plataforma e, depois, os mentorandos, que são as pessoas acompanhadas pela professora sem
estar ligadas a uma empresa. Rodar de novo com o mesmo e-mail só reenvia o convite.

### Como pretendemos fazer

O script de dados de teste que já existe só roda no ambiente local e cria usuário com senha
conhecida. Este roda em qualquer ambiente e nunca define senha. Ele faz, em ordem, sem
duplicar nada:

1. garante a organização da CREED (com id fixo) e o documento dela (`DocType.OTHER`, com
   valor sintético);
2. se o e-mail já tem acesso, reenvia o convite (`admin.send_update_password_email`) e
   termina;
3. senão, cria o participante, depois o vínculo (`admin`, `emprego`, na organização da
   CREED), e chama `UserService.create_user_service`.

Detalhes:

- o commit é do próprio script, no fim;
- os argumentos são `--email` e `--nome`, e nenhum dado de pessoa vai para o código;
- a imagem do servidor hoje não leva a pasta `scripts/`, então entra `COPY scripts ./scripts`
  no `Dockerfile`.

### Onde isso encosta no código (`creed-backend`)

| Arquivo | O que nasce ou muda ali |
|---|---|
| `scripts/convidar_primeiro_admin.py` (novo) | o comando |
| `Dockerfile` | `COPY scripts ./scripts` |
| `README.md` | seção "Primeiro admin de um ambiente novo" |
| `tests/test_convidar_primeiro_admin.py` (novo) | primeira execução, segunda execução e outro e-mail |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| script com sessão própria, ids fixos e sem duplicar | `semear` e `_ensure_organization` em [scripts/seed_local.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/scripts/seed_local.py) | forma do comando |
| testes de script | [tests/test_seed_local.py](https://github.com/creed-educa-ai/creed-backend/blob/1d90b2a32ccf8f4dd55212debf8881cbaa996ebe/tests/test_seed_local.py) | forma dos testes |

### Pronto quando

- [ ] A primeira execução no local:
  - [ ] cria a organização da CREED, com o documento;
  - [ ] cria a pessoa, o vínculo de administrador e o acesso;
  - [ ] faz o convite chegar ao Mailpit.
- [ ] A segunda execução com o mesmo e-mail não cria nada e reenvia o convite.
- [ ] Outro e-mail cria outro administrador na mesma organização, sem duplicá-la.
- [ ] Se o envio falha, nada fica no banco nem no Keycloak.
- [ ] A imagem tem `/app/scripts/convidar_primeiro_admin.py`.

### Como verificar

```bash
cd creed-backend
python -m scripts.convidar_primeiro_admin --email admin2@creed.local --nome "Admin Dois"   # convite no Mailpit
python -m scripts.convidar_primeiro_admin --email admin2@creed.local --nome "Admin Dois"   # reenvio
pytest tests/test_convidar_primeiro_admin.py tests/test_seed_local.py -q
docker build -t creed-backend:teste . && docker run --rm creed-backend:teste ls scripts
```

Em produção, depois da publicação do servidor:

```bash
docker compose run --rm back python -m scripts.convidar_primeiro_admin --email <e-mail> --nome "<nome>"
```

O e-mail sai do Gmail do projeto, uma conta nova cujo primeiro e-mail de teste caiu no
spam. Avise a pessoa convidada para olhar o spam.

### Decisões já tomadas que valem aqui

- **O primeiro administrador de produção nasce por convite**, e a primeira convidada é a
  professora. O mesmo comando convida outros administradores.
- **Os mentorandos ficam numa organização da própria CREED**, com vínculo de mentoria e
  papel de respondente, porque todo acesso precisa de uma organização. Se a cliente quiser
  mentorando sem organização nenhuma, muda o modelo de dados.

### Materiais para consumir

| Material | Situação |
|---|---|
| Documento da tarefa | ⬜ falta anexar — **Luís (AGES III)** |

### Depende de

CREED-23.8.2. Pode andar junto com a CREED-23.8.3 e a 23.8.4.

⚠️ O [creed-backend#45](https://github.com/creed-educa-ai/creed-backend/pull/45) também mexe
no `Dockerfile`: o conflito é de uma linha.

### Rastreio

```
Rastreio: 86e35vhxm/5 — creed-ai-context/tarefas/86e35vhxm-convite-de-primeiro-acesso/5_task.md
```

---

## 6 — CREED-23.8.6 - Site sem tela de senha, com recuperação por e-mail e convite de membro

### Em uma frase

O site perde a tela falsa de "definir senha", "Esqueci minha senha" passa a pedir só o
e-mail, e o formulário de adicionar membro passa a pedir o nome e ganha a chamada pronta.

### O que muda para quem usa

Hoje existem duas telas de "nova senha", em `/primeiro-acesso` e `/recuperar-senha`, que
não fazem nada: não falam com o servidor. Elas saem. Quem define a senha passa a ser sempre
a página segura do Keycloak, aberta pelo link do e-mail.

"Esqueci minha senha", na tela de login, leva a uma tela que pede só o e-mail e mostra
sempre a mesma mensagem: "Se este e-mail tiver acesso, enviamos um link para definir uma
nova senha." Assim a tela não revela quem tem cadastro.

No painel da empresa, o formulário de adicionar membro passa a pedir também o nome da
pessoa e ganha a função que chama o servidor. A página do painel, que usa o formulário, é
de outra tarefa (CREED-50).

### Como pretendemos fazer

- **A tela não chama o servidor direto.** O pedido de nova senha passa por um thunk no
  `authenticationSlice.ts`, como o login, e o erro chega à tela como chave de tradução.
- **O formulário de membro só valida e entrega os dados.** Quem liga o envio à chamada e
  cria o estado do convite é a página do painel.
- **Os textos são tipados pelo português** (`en: typeof ptBR`). Chave que sai, sai dos três
  idiomas no mesmo commit, ou a verificação de tipos quebra.
  - Saem as chaves `autenticacao.primeiroAcesso.*`.
  - Saem também os erros que só a tela antiga usa (`senhaCurta`, `confirmacaoObrigatoria`).
    Confira com `grep` antes.

### Onde isso encosta no código (`creed-frontend`)

| Arquivo | O que nasce ou muda ali |
|---|---|
| `src/app/routes.tsx` | sai `/primeiro-acesso`, e `/recuperar-senha` passa a abrir a `RecuperarSenhaView` |
| `src/features/authentication/AlterarSenhaView.tsx` e `.test.tsx` | removidos |
| `src/features/authentication/RecuperarSenhaView.tsx` e `.test.tsx` (novos) | a tela que pede o e-mail |
| `src/features/authentication/authenticationApi.ts` | `requestPasswordReset(email)` |
| `src/features/authentication/authenticationSlice.ts` e `.test.ts` | o thunk `requestPasswordReset` |
| `src/lib/validadores.ts` | sai o `alterarSenhaSchema`, entra o `recuperarSenhaSchema` |
| `src/features/organizations/organizationsApi.ts` (novo) | `inviteMember(organizationId, body)` |
| `src/features/organizations/addMemberSchema.ts` e `AddMemberForm.tsx`, com os testes | o campo `name` |
| `src/types/api.ts` | `PasswordResetRequest`, `MemberInvite` e `UserResponse` |
| `src/i18n/locales/pt-BR.ts`, `en.ts` e `es.ts` | os textos |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| tela de autenticação com layout, formulário e erro do estado | [src/features/authentication/LoginView.tsx](https://github.com/creed-educa-ai/creed-frontend/blob/afd9882beb45be391c91ec478e70f32e7cd18bc7/src/features/authentication/LoginView.tsx) | forma da `RecuperarSenhaView` |
| thunk e chave de erro | `login` e `chaveDeErro` em [authenticationSlice.ts](https://github.com/creed-educa-ai/creed-frontend/blob/afd9882beb45be391c91ec478e70f32e7cd18bc7/src/features/authentication/authenticationSlice.ts) | forma do thunk novo |
| funções sobre o `apiClient` | [authenticationApi.ts](https://github.com/creed-educa-ai/creed-frontend/blob/afd9882beb45be391c91ec478e70f32e7cd18bc7/src/features/authentication/authenticationApi.ts) | forma das funções novas |
| o formulário de membro | [src/features/organizations/AddMemberForm.tsx](https://github.com/creed-educa-ai/creed-frontend/blob/afd9882beb45be391c91ec478e70f32e7cd18bc7/src/features/organizations/AddMemberForm.tsx) | campo novo no mesmo `Field` e `FieldError` |

### Contrato (visto do site)

| Método | Rota | Entrada | Saída |
|---|---|---|---|
| POST | `/api/v1/authentication/password-reset` | `{ email }` | `204` |
| POST | `/api/v1/organizations/{organization_id}/members` | `{ name, email, role, type? }` | `201` · `UserResponse` |

`UserResponse = { id, name, email, status, role, link_id, organization_id, created_at }`.

| Código | O que a tela faz |
|---|---|
| 204 (redefinição) | mostra a mensagem neutra |
| 409 (membro) | erro no campo de e-mail |
| 403, 404, 422 | erro do formulário |
| 503 | "Tente de novo em alguns minutos." |

### Pronto quando

- [ ] `/primeiro-acesso` não abre tela de senha nenhuma, e não sobra import, teste nem
      texto da tela antiga.
- [ ] "Esqueci minha senha", no login, leva a `/recuperar-senha`:
  - [ ] a tela pede só o e-mail, e e-mail inválido mostra erro no campo;
  - [ ] o envio chama `POST /api/v1/authentication/password-reset`;
  - [ ] qualquer 204 mostra a mesma mensagem, e 503 mostra "tente de novo".
- [ ] O formulário de membro pede nome (2 a 200 caracteres), e-mail e papel, e entrega os
      três.
- [ ] `inviteMember('<org>', {...})` faz `POST /api/v1/organizations/<org>/members` com o
      corpo do contrato (teste com o `apiClient` falso).
- [ ] Os textos existem em português, inglês e espanhol.
- [ ] `npm run check` verde.

### Como verificar

```bash
cd creed-frontend
npm run check
npm run dev    # http://localhost:5173/recuperar-senha e http://localhost:5173/primeiro-acesso
```

Sem o servidor da CREED-23.8.4, a tela de redefinição mostra "tente de novo". Quem prova a
tela é o teste com o `apiClient` falso. Com o servidor de pé, o e-mail chega ao Mailpit.

- **Caso feliz:** um e-mail válido mostra a mensagem neutra.
- **Caso de borda:** um e-mail inválido mostra erro no campo, sem chamar o servidor.

### Decisões já tomadas que valem aqui

- **O site não tem tela de senha.** Quem define senha é a página do Keycloak.
- **O convite pede o nome da pessoa.**
- **O formulário oferece respondente e gestor, nunca administrador.** É o que o
  `MEMBER_ROLES` já faz.
- **A regra dos 8 caracteres sai do site** e fica no Keycloak.

### Materiais para consumir

| Material | Situação |
|---|---|
| Protótipo da tela de recuperar senha no Figma, se existir | ⬜ falta o link — **Leonardo (front)** |
| Documento da tarefa, com o contrato completo | ⬜ falta anexar — **Luís (AGES III)** |

### Depende de

Só do contrato acima: pode começar já.

### Rastreio

```
Rastreio: 86e35vhxm/6 — creed-ai-context/tarefas/86e35vhxm-convite-de-primeiro-acesso/6_task.md
```

---

## 7 — CREED-23.8.7 - Produção envia e-mail pelo Gmail do projeto

### Em uma frase

O Keycloak de produção passa a mandar e-mail pelo Gmail do projeto, com os mesmos ajustes
do ambiente local, aplicados por um script.

### O que muda para quem usa

Sem esta entrega, tudo funciona no computador de quem desenvolve, e nada chega a ninguém em
produção. Depois dela, o convite e a redefinição de senha chegam a endereços reais, em
português, e o link abre a página segura da plataforma.

O e-mail sai de um endereço `@gmail.com` do projeto, assinado como "CREED.ai Educa". Sem
domínio próprio, é o único remetente que passa nos filtros de fraude dos provedores: o
serviço de e-mail da AWS (SES) foi avaliado e descartado por isso. A conta é nova, então os
primeiros e-mails podem cair no spam.

### Como pretendemos fazer

São duas partes, nesta ordem.

**1. Passo humano**, do dono da conta do Gmail do projeto (Enzo):

- gerar uma **senha de app** do Google. Ela exige a verificação em duas etapas ligada na
  conta, e nunca é a senha da conta;
- gravar no `/opt/creed/.env` da EC2:
  - `SMTP_HOST=smtp.gmail.com` e `SMTP_PORT=587`;
  - `SMTP_USER` e `SMTP_FROM` com o Gmail do projeto. Os dois são o mesmo endereço,
    porque o Google reescreve qualquer outro remetente;
  - `SMTP_PASSWORD` com a senha de app.

Essas credenciais ficam com o dono da conta e **não vão para o Parameter Store**. É uma
exceção decidida na decisão de arquitetura do e-mail, ao contrário do resto dos segredos
da produção.

O envio já foi testado em 27/10: de dentro da EC2, pela porta 587, e com o *Test
connection* do Keycloak de produção. Essa configuração foi feita **pelo console**, só como
teste. O script abaixo sobrescreve com os valores do `.env`, e a partir dele o arquivo
volta a ser a fonte.

**2. No repositório.** O Keycloak de produção só lê o arquivo de configuração na primeira
subida (`--import-realm`), então o que a CREED-23.8.1 mudou não chega lá sozinho. Um script
novo, `ec2/realm/aplicar-ajustes.sh`:

1. lê os blocos do próprio `realm-creed.json`, no clone que a EC2 já tem;
2. troca as variáveis pelos valores do `.env`, com `envsubst`;
3. aplica com `kcadm.sh`, dentro do container.

Detalhes do script:

- quem roda entra com o próprio administrador do Keycloak, e a senha é pedida no terminal;
- a senha do SMTP vai pela entrada padrão, nunca na linha de comando;
- o script precisa de `jq` e `envsubst` na EC2;
- **não use `kc.sh import --override`**: ele apaga e recria a configuração, **com os
  usuários**.

### Onde isso encosta no código (`creed-infrastructure`)

| Arquivo | O que nasce ou muda ali |
|---|---|
| `ec2/.env.example` | `SMTP_HOST=smtp.gmail.com` e `SMTP_PORT=587`; `SMTP_USER` e `SMTP_FROM` (o mesmo Gmail); `SMTP_PASSWORD` (senha de app, com o aviso de que fica com o dono da conta e fora do Parameter Store); `FRONTEND_URL` |
| `ec2/docker-compose.yml` | no `keycloak`: as `SMTP_*` (com `SMTP_AUTH: "true"`, `SMTP_STARTTLS: "true"` e `SMTP_SSL: "false"`) e `CREED_FRONTEND_URL: ${FRONTEND_URL}`; no `back`: `FRONTEND_URL` |
| `ec2/realm/aplicar-ajustes.sh` (novo) | o script |
| `ec2/README.md` | seção "E-mail (SMTP)": que as credenciais do Gmail são exceção à regra do Parameter Store, quem é o dono da conta, e o que fazer quando a senha de app for revogada. Seção "Ajustar o realm depois da primeira subida" |

### O que já existe e deve ser reusado

| Já existe | Onde | Para quê |
|---|---|---|
| script de operação que explica a ordem e falha cedo | [ec2/deploy.sh](https://github.com/creed-educa-ai/creed-infrastructure/blob/353e11c17829be96a81827952f189a81d0449df3/ec2/deploy.sh) | forma do script novo |
| variável opcional sem valor no compose | `KC_BOOTSTRAP_ADMIN_USERNAME` em [ec2/docker-compose.yml](https://github.com/creed-educa-ai/creed-infrastructure/blob/353e11c17829be96a81827952f189a81d0449df3/ec2/docker-compose.yml) | forma das variáveis novas |
| como a produção está montada | [ec2/README.md](https://github.com/creed-educa-ai/creed-infrastructure/blob/353e11c17829be96a81827952f189a81d0449df3/ec2/README.md) | layout, túnel do console do Keycloak, cuidados |

### Pronto quando

- [ ] `docker compose --env-file .env.example config` valida.
- [ ] `bash -n` e `shellcheck` passam sem erro.
- [ ] Na EC2, o script roda duas vezes sem erro, e o `kcadm.sh get` mostra os valores. A
      senha aparece mascarada.
- [x] De dentro da EC2, um envio pelo `smtp.gmail.com:587` chega (feito em 27/10).
- [ ] Depois do script, o *Test connection* do Keycloak de produção segue passando.
- [ ] O README diz que as credenciais do Gmail são exceção ao Parameter Store, e o que
      fazer quando a senha de app for revogada: gerar outra, atualizar o `.env` e rodar o
      script de novo.
- [ ] Depois da publicação do servidor e da CREED-23.8.5:
  - [ ] o convite do primeiro administrador chega a um endereço real (olhe também o spam:
        a conta é nova);
  - [ ] o link abre com certificado válido;
  - [ ] o login em produção devolve 200.

### Como verificar

```bash
cd creed-infrastructure/ec2
docker compose --env-file .env.example config > /dev/null && echo ok
bash -n realm/aplicar-ajustes.sh && shellcheck realm/aplicar-ajustes.sh

# na EC2, como ec2-user, com o .env preenchido
./realm/aplicar-ajustes.sh
docker compose exec keycloak /opt/keycloak/bin/kcadm.sh get realms/creed --fields smtpServer,defaultLocale,passwordPolicy
```

Depois do script, *Test connection* na aba Email do realm `creed`, pelo túnel do console.

- **Caso feliz:** o `kcadm get` mostra os valores, e o *Test connection* passa.
- **Caso de borda:** rodar o script de novo não muda nada nem falha.

### Decisões já tomadas que valem aqui

- **Os e-mails saem do Gmail do projeto até haver domínio próprio.** Com domínio, o
  serviço de e-mail da AWS volta à mesa, e a troca é só de valores: as `SMTP_*` e o
  script. O servidor da plataforma não muda, porque quem envia é o Keycloak.
- **Os mesmos ajustes do ambiente local:** link de 72 horas, português e link de volta
  para o login.
- **Limites aceitos:** cerca de 500 destinatários por dia (sobra para convites e nova
  senha); risco de spam no começo; remetente `@gmail.com`, menos oficial para a cliente.
- **O primeiro administrador é convidado depois desta entrega**, pela CREED-23.8.5.

### Materiais para consumir

| Material | Situação |
|---|---|
| Decisão de arquitetura do e-mail, com o adendo do Gmail (configuração, testes, limites) | ✅ [ADR-0006](https://github.com/creed-educa-ai/creed-ai-context/blob/0e47cebec332f1addcddd3dfaefbfbc8479a7632/decisoes/adrs/0006-e-mail-transacional.md) |
| Senhas de app do Google | ✅ <https://support.google.com/accounts/answer/185833> |
| Limites de envio do Gmail | ✅ <https://support.google.com/mail/answer/22839> |
| `kcadm.sh`, a linha de comando de administração do Keycloak | ✅ <https://www.keycloak.org/docs/latest/server_admin/#admin-cli> |
| Credenciais do Gmail do projeto e acesso à EC2 | ⬜ dependência de pessoa — **Enzo (CREED-28)** |

### Depende de

- **CREED-23.8.1**, para o script.
- **Para rodar em produção:** a publicação das entregas 1 a 5 na `main` do servidor, que
  depende da consolidação das migrations (CREED-57).

### Rastreio

```
Rastreio: 86e35vhxm/7 — creed-ai-context/tarefas/86e35vhxm-convite-de-primeiro-acesso/7_task.md
```

---

## 8 — CREED-23.8.8 - Documentação do projeto descreve o convite

### Em uma frase

Os documentos do projeto deixam de dizer que a plataforma não envia e-mail e passam a
descrever o convite como ele ficou.

### O que muda para quem usa

Quem chega ao projeto lê, na documentação, como uma pessoa ganha acesso: convite por e-mail,
senha definida na página do Keycloak, "esqueci minha senha" pelo e-mail.

O provedor de e-mail de produção já está documentado: o Gmail do projeto, desde 27/10.
Falta o resto. A pauta da próxima reunião com a cliente ainda diz que a plataforma não
envia e-mail e pergunta sobre uma decisão que já foi derrubada.

### Como pretendemos fazer

Um PR no repositório de documentação (`creed-ai-context`, base `main`), depois das entregas
2 a 7. Cada documento passa a descrever o que já está no código e na produção:

| Documento | Hoje | Depois |
|---|---|---|
| `decisoes/adrs/0006-e-mail-transacional.md` | o adendo de 27/10 já registra o Gmail: configuração, testes, credenciais, limites e o script | dizer que, sem domínio, o link do convite sai com o IP do servidor; status (ainda "Proposto") |
| `context/arquitetura.md` | provedor certo desde 27/10; o fluxo do convite só tem o cadastro de acesso | o fluxo com membros, reenvio e redefinição |
| `context/infraestrutura.md` | a tabela "Onde ficam os segredos" não tem o e-mail | uma linha para a conta do Gmail e a senha de app: com o dono da conta e só no `.env` da EC2, fora do Parameter Store, e como a conta passa para a turma seguinte |
| `tarefas/86e348g6u-autenticacao-da-plataforma/contrato-api.md` | `UserCreate { link_id, email, initial_password }` | `{ name, email, link_id }`, as rotas novas e o 503 |
| `tarefas/86e348g6u-autenticacao-da-plataforma/spec.md` | "recuperação de senha não entra" | aponta para a 23.8 |
| `decisoes/premissas.md` | "esqueci minha senha não existe", ainda aberta | fechada, com o desfecho escrito |
| `pauta/proxima-reuniao.md`, item 3 | diz que a plataforma não envia e-mail e pergunta sobre senha temporária, decisão já derrubada | pergunta à cliente o que o time decidiu sem ela, inclusive o remetente `@gmail.com` até haver domínio |
| `glossario.md` e `catalogo.md` | sem convite, membro e mentorando | os termos novos e o estado atual dos domínios |

Fora deste PR: o site de padrões do time (`creed-docs`, `docs/arquitetura/index.md`) tem o
aviso "convite e e-mail ainda são desenho". Ele muda num PR próprio daquele repositório.

### Pronto quando

- [ ] A busca de "Como verificar" só acha texto histórico, marcado como tal.
- [ ] A decisão de arquitetura do e-mail diz que, sem domínio, o link sai com o IP do
      servidor.
- [ ] A documentação de infraestrutura diz onde ficam a conta do Gmail e a senha de app, e
      como elas passam para a turma seguinte.
- [ ] O contrato bate com a documentação da API do servidor depois das entregas 2 a 4.
- [ ] Nenhuma decisão registrada sumiu: as que fecham mudam de status, com o desfecho
      escrito.
- [ ] A pauta pergunta à cliente o que ainda depende dela: validade do link, texto do
      e-mail, remetente `@gmail.com`, mentorando e empresa aprovada.

### Como verificar

```bash
cd creed-ai-context
grep -rn -i "initial_password\|não existe envio de e-mail\|não existe serviço de e-mail\|não envia e-mail\|email-smtp\|sandbox do SES" --include=*.md --exclude-dir=86e35vhxm-convite-de-primeiro-acesso .
```

A pasta da própria 23.8 fica fora da busca, porque cita esses termos para dizer o que
muda.

### Materiais para consumir

| Material | Situação |
|---|---|
| Decisão de arquitetura do e-mail, com o adendo do Gmail | ✅ [ADR-0006](https://github.com/creed-educa-ai/creed-ai-context/blob/0e47cebec332f1addcddd3dfaefbfbc8479a7632/decisoes/adrs/0006-e-mail-transacional.md) |
| PR da discovery: revisão, documento da tarefa, entregas e decisões | ✅ [creed-ai-context#36](https://github.com/creed-educa-ai/creed-ai-context/pull/36) |
| PR do Gmail no lugar do SES | ✅ [creed-ai-context#37](https://github.com/creed-educa-ai/creed-ai-context/pull/37) |

### Depende de

CREED-23.8.2 a CREED-23.8.7.

### Rastreio

```
Rastreio: 86e35vhxm/8 — creed-ai-context/tarefas/86e35vhxm-convite-de-primeiro-acesso/8_task.md
```
