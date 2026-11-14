# Task 9 — Produção do back

**Repo:** `creed-infrastructure`
**Depende de:** tasks 4 e 5

## Objetivo

A EC2 roda o `insight-worker` ao lado do back, o deploy recria os dois depois da
migration, e o callback só atende pela rede interna. **O serviço `n8n` não muda.**

## Arquivos que provavelmente mudam

- `ec2/docker-compose.yml`:
  - o serviço `insight-worker`;
  - as variáveis novas no `back` e no worker: `N8N_WEBHOOK_URL`, `N8N_WEBHOOK_TOKEN`,
    `N8N_CALLBACK_SECRET` e os `INSIGHT_*`.
- `ec2/deploy.sh`: `up -d --no-deps back insight-worker`, depois da migration
- `ec2/Caddyfile`: 404 para `/api/v1/insights/callback`
- `ec2/README.md`: as variáveis novas e os passos humanos

## Molde

- O próprio `ec2/docker-compose.yml`: o serviço `back` (imagem, tag, `env_file`,
  `mem_limit`).
- O bloco `handle /auth/admin*` do `Caddyfile`: a forma do 404.

## Critérios de aceite

- [ ] O diff não toca o serviço `n8n`.
- [ ] O worker usa a mesma imagem e a mesma tag do back, com o comando
      `python -m app.workers.insights`, `mem_limit: 192m` e
      `restart: unless-stopped`.
- [ ] `N8N_WEBHOOK_URL` aponta para a rede interna:
      `http://n8n:5678/webhook/creed/insights/v1`.
- [ ] O `deploy.sh` recria o back e o worker só depois de a migration terminar com
      código 0. Se a migration falhar, nenhum dos dois é recriado.
- [ ] O Caddy responde 404 a `/api/v1/insights/callback` vindo de fora, e o resto de
      `/api/*` continua como está.
- [ ] O README lista:
  - as variáveis novas;
  - o passo humano de gerar o token e o segredo da volta e guardá-los no `.env` da
    EC2 e no Parameter Store;
  - que os mesmos valores vão para as credenciais do N8N (task 6).
- [ ] `docker compose -f ec2/docker-compose.yml config` valida o arquivo, rodado na
      máquina de quem implementa, sem tocar a EC2.
- [ ] Nada roda contra a EC2. A IA não faz SSH nem roda `aws`.

## Como testar

```bash
docker compose -f ec2/docker-compose.yml --env-file <.env de exemplo> config > /dev/null
bash -n ec2/deploy.sh
```

A prova em produção é a task 12.

## Premissas aplicáveis

Nenhuma.
