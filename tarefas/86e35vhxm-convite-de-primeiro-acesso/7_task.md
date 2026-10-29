# Task 7 — Produção recebe o SMTP e os ajustes do realm

**Repo:** `creed-infrastructure`, mais um passo humano fora do git: as credenciais do
Gmail do projeto no `.env` da EC2.
**Depende de:** task 1, que dá a forma do `realm-creed.json` que o script aplica. Rodar em
produção depende do release das tasks 1–5 na `main` do back, e o release depende da
consolidação das migrations (CREED-57, ADR-0009).
**Branch sugerida:** `feat/86e35vhxm-smtp-na-producao`

## Objetivo

O Keycloak de produção passa a mandar e-mail pelo SMTP do Gmail do projeto, com os mesmos
ajustes de realm do ambiente local. Os ajustes chegam por um script versionado, sem reimportar o realm
e sem clique no console.

## Contexto que você não tem como adivinhar

- **O realm de produção não relê o arquivo.** O compose usa `start --import-realm`, que só
  importa realm que ainda não existe (`ec2/README.md`, "Cuidados"). Tudo o que a task 1
  mudou no `realm-creed.json` precisa de um caminho próprio: o script desta task (spec,
  D11). Não use `kc.sh import --override`: ele apaga e recria o realm, **com os usuários**.
- **O script** `ec2/realm/aplicar-ajustes.sh`, idempotente:
  1. lê os blocos do `realm-creed.json` no clone que a EC2 já tem
     (`/opt/creed/creed-backend/docker/keycloak/realm-creed.json`, o mesmo que o compose
     monta). É uma fonte só;
  2. troca os `${VAR}` pelos valores do `/opt/creed/.env`, com `jq`, só nos atributos e
     no redirect. *Corrigido em 2026-10-29: a task pedia `envsubst`, mas ele apagaria as
     chaves `${username}`, `${email}`, `${firstName}` e `${lastName}` do perfil e não
     escapa JSON (creed-infrastructure#10);*
  3. aplica com `kcadm.sh` dentro do container:
     - os atributos do realm: `internationalizationEnabled`, `supportedLocales`,
       `defaultLocale`, `passwordPolicy` e `smtpServer`;
     - os `redirectUris` do client `creed-backend`;
     - o perfil (`users/profile`);
  4. mostra o resultado com `kcadm.sh get`.

  Detalhes de execução:
  - **Login:** `kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user <admin pessoal>`.
    O admin é o argumento obrigatório do script (`./realm/aplicar-ajustes.sh <seu admin>`),
    e a senha é pedida no terminal.
  - **Senha do SMTP:** vai pela entrada padrão (`-f -`), nunca na linha de comando.
  - **Pacotes:** o script precisa do `jq` 1.6 ou mais novo na EC2.
- **SMTP do Gmail, não o SES** (adendo de 2026-10-27 do ADR-0006). Sem domínio, o SES
  não tinha remetente que passasse no DMARC.
  - host `smtp.gmail.com`, porta **587** com `starttls=true` e `ssl=false`;
  - `auth=true`; o usuário é o Gmail do projeto e a senha é uma **senha de app** do Google,
    não a senha da conta;
  - o `from` é **o próprio Gmail**: o Google reescreve qualquer outro remetente, então
    `nao-responda@...` não funciona. O `fromDisplayName` segue `CREED.ai Educa`.
- **Já testado em produção** (2026-10-27): a EC2 envia pela 587, e o *Test connection* do
  realm `creed` passou. Essa configuração foi feita **pelo console**, só como teste. O
  script desta task sobrescreve com os valores do `.env`, e a partir dele o arquivo volta a
  ser a fonte.
- **Passo humano** (dono: Enzo, CREED-28): as credenciais do Gmail ficam com ele, não no
  Parameter Store. Antes de o script rodar, ele grava no `/opt/creed/.env`:
  `SMTP_HOST=smtp.gmail.com`, `SMTP_PORT=587`, `SMTP_FROM` e `SMTP_USER` (o Gmail do
  projeto) e `SMTP_PASSWORD` (a senha de app).
- **O compose também recebe as variáveis**, mesmo que o import já tenha passado: se o realm
  for recriado do zero, o arquivo continua honesto. O back recebe `FRONTEND_URL` (a URL do
  Amplify) e, se for preciso outra validade, `KEYCLOAK_INVITE_LIFESPAN_SECONDS`.

## Arquivos que provavelmente mudam

- `ec2/.env.example`:
  - `SMTP_HOST=smtp.gmail.com` e `SMTP_PORT=587`;
  - `SMTP_USER` e `SMTP_FROM`, com o aviso de que os dois são o mesmo Gmail;
  - `SMTP_PASSWORD`, com o aviso: "senha de app do Google, com o dono da conta (Enzo);
    nunca no git e, pelo adendo do ADR-0006, fora do Parameter Store";
  - `FRONTEND_URL`.
- `ec2/docker-compose.yml`:
  - no `keycloak`: as `SMTP_*` (com `SMTP_AUTH: "true"`, `SMTP_STARTTLS: "true"` e
    `SMTP_SSL: "false"`) e `CREED_FRONTEND_URL: ${FRONTEND_URL}`;
  - no `back`: `FRONTEND_URL`.
- `ec2/realm/aplicar-ajustes.sh` (novo).
- `ec2/README.md`: seções "E-mail (SMTP)" e "Ajustar o realm depois da primeira subida".
  A seção de e-mail diz três coisas:
  - as credenciais do Gmail são **exceção** à regra "todo segredo novo vai também para o
    Parameter Store" do próprio README;
  - quem é o dono da conta;
  - o que fazer quando a senha de app for revogada (o Google revoga quando a senha da conta
    muda, e a senha de app só funciona com a verificação em duas etapas ligada): gerar
    outra, atualizar o `.env` e rodar o `aplicar-ajustes.sh` de novo.

## Molde

- Script de operação que explica a ordem e falha cedo: `ec2/deploy.sh`
  (`set -euo pipefail`, comentários do porquê).
- Variável sem valor no compose, para o que é opcional: `KC_BOOTSTRAP_ADMIN_USERNAME`, em
  `ec2/docker-compose.yml`.

## Critérios de aceite

- [ ] `docker compose --env-file .env.example config` valida o compose com as variáveis
      novas.
- [ ] `bash -n realm/aplicar-ajustes.sh` e `shellcheck` passam sem erro.
- [ ] Na EC2, o script roda duas vezes sem erro, e
      `kcadm.sh get realms/creed --fields 'smtpServer(*),defaultLocale,passwordPolicy,internationalizationEnabled'`
      mostra os valores (a senha aparece mascarada). Sem o `(*)`, o `smtpServer` aparece
      vazio, mesmo preenchido.
- [x] De dentro da EC2, um envio pelo `smtp.gmail.com:587` chega (feito em 2026-10-27).
- [ ] Depois do script, o *Test connection* do realm `creed` segue passando.
- [ ] O README diz que as credenciais do Gmail são exceção ao Parameter Store e o que
      fazer quando a senha de app for revogada.
- [ ] Depois do release e da task 5:
  - [ ] o convite do primeiro admin chega a um endereço real. Olhe também o spam: a conta
        do Gmail é nova;
  - [ ] o link abre `https://<IP>/auth/realms/creed/login-actions/...` com certificado
        válido;
  - [ ] o login em produção devolve 200, o que fecha o último critério da CREED-283.

## Como testar

```bash
cd creed-infrastructure/ec2
docker compose --env-file .env.example config > /dev/null && echo ok
bash -n realm/aplicar-ajustes.sh && shellcheck realm/aplicar-ajustes.sh

# na EC2, como ec2-user, com o .env preenchido
./realm/aplicar-ajustes.sh <seu admin do realm master>
docker compose exec keycloak /opt/keycloak/bin/kcadm.sh get realms/creed --fields 'smtpServer(*),defaultLocale,passwordPolicy'
```

- **Caso feliz:** o `kcadm get` mostra os valores, e o *Test connection* do realm passa.
- **Caso de borda:** rodar o script de novo não muda nada nem falha.

## Premissas aplicáveis

- P-049, P-050 e P-051 — validade, idioma e link de volta, agora em produção.
- P-052 — o primeiro admin, convidado depois desta task.
