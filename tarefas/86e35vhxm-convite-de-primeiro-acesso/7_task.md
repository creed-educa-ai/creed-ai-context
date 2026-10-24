# Task 7 — Produção recebe o SMTP e os ajustes do realm

**Repo:** `creed-infrastructure`, mais passos no console da AWS, fora do git.
**Depende de:** task 1, que dá a forma do `realm-creed.json` que o script aplica. Rodar em
produção depende do release das tasks 1–5 na `main` do back, e o release depende da
consolidação das migrations (CREED-57, ADR-0009).
**Branch sugerida:** `feat/86e35vhxm-smtp-na-producao`

## Objetivo

O Keycloak de produção passa a mandar e-mail pelo SMTP da AWS, com os mesmos ajustes de
realm do ambiente local. Os ajustes chegam por um script versionado, sem reimportar o realm
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
  2. troca os `${VAR}` pelos valores do `/opt/creed/.env`, com `envsubst`;
  3. aplica com `kcadm.sh` dentro do container:
     - os atributos do realm: `internationalizationEnabled`, `supportedLocales`,
       `defaultLocale`, `passwordPolicy` e `smtpServer`;
     - os `redirectUris` do client `creed-backend`;
     - o perfil (`users/profile`);
  4. mostra o resultado com `kcadm.sh get`.

  Detalhes de execução:
  - **Login:** `kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user <admin pessoal>`. A senha é pedida no terminal.
  - **Senha do SMTP:** vai pela entrada padrão (`-f -`), nunca na linha de comando.
  - **Pacotes:** o script precisa de `jq` e de `envsubst` (pacote `gettext`) na EC2.
- **SMTP da AWS:**
  - host `email-smtp.<região>.amazonaws.com`;
  - porta **587** com `starttls=true` (a porta 25 é limitada pela AWS em EC2);
  - `auth=true`, com usuário e senha da **credencial SMTP** do SES, que não é a chave IAM
    comum;
  - o `from` precisa ser uma identidade verificada no SES.
- **Nada disso está registrado hoje.** A infraestrutura não tem `SMTP_*` no `.env.example`
  nem no Parameter Store (`context/infraestrutura.md`). O passo humano abaixo vem primeiro.
- **Passo humano no console da AWS** (dono: Enzo, CREED-28; o roteiro completo está na
  revisão, §10):
  1. confirmar a região, a identidade verificada (domínio ou e-mail) e se a conta está no
     sandbox;
  2. se estiver no sandbox, pedir *production access*. Sem isso, o convite só chega a
     endereço verificado;
  3. criar a credencial SMTP;
  4. gravar no Parameter Store, e as mesmas linhas no `/opt/creed/.env`:
     - `/creed/prod/SMTP_HOST`, `SMTP_PORT` e `SMTP_FROM` como `String`;
     - `/creed/prod/SMTP_USER` e `SMTP_PASSWORD` como `SecureString`.
- **O compose também recebe as variáveis**, mesmo que o import já tenha passado: se o realm
  for recriado do zero, o arquivo continua honesto. O back recebe `FRONTEND_URL` (a URL do
  Amplify) e, se for preciso outra validade, `KEYCLOAK_INVITE_LIFESPAN_SECONDS`.

## Arquivos que provavelmente mudam

- `ec2/.env.example`: `SMTP_HOST`, `SMTP_PORT`, `SMTP_FROM`, `SMTP_USER` e
  `SMTP_PASSWORD`, com o aviso "Parameter Store, nunca no git", e `FRONTEND_URL`.
- `ec2/docker-compose.yml`:
  - no `keycloak`: as `SMTP_*` (com `SMTP_AUTH: "true"`, `SMTP_STARTTLS: "true"` e
    `SMTP_SSL: "false"`) e `CREED_FRONTEND_URL: ${FRONTEND_URL}`;
  - no `back`: `FRONTEND_URL`.
- `ec2/realm/aplicar-ajustes.sh` (novo).
- `ec2/README.md`: seções "E-mail (SMTP)" e "Ajustar o realm depois da primeira subida".

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
      `kcadm.sh get realms/creed --fields smtpServer,defaultLocale,passwordPolicy,internationalizationEnabled`
      mostra os valores (a senha aparece mascarada).
- [ ] De dentro da EC2,
      `openssl s_client -starttls smtp -connect email-smtp.<região>.amazonaws.com:587 -crlf`
      negocia TLS.
- [ ] Um envio para `success@simulator.amazonses.com` aparece nas estatísticas do SES.
- [ ] Depois do release e da task 5:
  - [ ] o convite do primeiro admin chega a um endereço real;
  - [ ] o link abre `https://<IP>/auth/realms/creed/login-actions/...` com certificado
        válido;
  - [ ] o login em produção devolve 200, o que fecha o último critério da CREED-283.

## Como testar

```bash
cd creed-infrastructure/ec2
docker compose --env-file .env.example config > /dev/null && echo ok
bash -n realm/aplicar-ajustes.sh && shellcheck realm/aplicar-ajustes.sh

# na EC2, como ec2-user, com o .env preenchido
./realm/aplicar-ajustes.sh
docker compose exec keycloak /opt/keycloak/bin/kcadm.sh get realms/creed --fields smtpServer,defaultLocale,passwordPolicy
```

- **Caso feliz:** o `kcadm get` mostra os valores, e o simulador do SES registra o envio.
- **Caso de borda:** rodar o script de novo não muda nada nem falha.

## Premissas aplicáveis

- P-049, P-050 e P-051 — validade, idioma e link de volta, agora em produção.
- P-052 — o primeiro admin, convidado depois desta task.
