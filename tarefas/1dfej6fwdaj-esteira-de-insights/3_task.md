# Task 3 — Payload individual e client do N8N

**Repo:** `creed-backend`
**Depende de:** tasks 1 e 2

## Objetivo

Dado um insight individual, o back monta o payload `insight-v1` com as notas do cálculo,
o destaque, a oportunidade e as respostas abertas. O client entrega o payload ao N8N com
token e timeout, e converte qualquer falha numa exceção do domínio.

## Arquivos que provavelmente mudam

- `app/external_services/n8n/client.py`
- `app/external_services/n8n/exceptions.py`: comece com uma exceção (`N8NIndisponivel`)
- `app/domains/insights/repository.py`: respostas descritivas e texto da pergunta, por
  JOIN
- `app/domains/insights/service.py`: monta o payload
- `app/domains/prismas/service.py`: um método que calcula sem a guarda de quem pede (o
  worker não é um usuário), reaproveitando o `compute_prisms_data`
- `app/core/config.py`: `N8N_WEBHOOK_TOKEN`
- `tests/external_services/n8n/test_client.py`
- `tests/domains/insights/test_service.py`, `test_repository.py`
- `tests/domains/prismas/test_service.py`
- `tests/test_arquitetura.py`: `insights` compõe com `prismas`; `insights` lê `answer`
  e `questions` por JOIN

## Molde

- `app/external_services/keycloak/client.py`: `httpx.AsyncClient` injetado, timeout de
  `settings`, `try/except` estreito.
- `playbooks/integrar-servico-externo.md`, "Ordem" e "Erros que este playbook existe
  para evitar".

## Critérios de aceite

- [ ] O payload montado valida contra o modelo da ida do kit e tem a mesma forma do
      `exemplo-ida-individual.json`. Testado com dois perfis: com respostas abertas e
      sem nenhuma (`open_answers` vazia).
- [ ] As notas são as do `PrismaService` para a mesma resposta, na escala de 0 a 100.
      Destaque e oportunidade são o maior e o menor prisma, com a mesma regra de
      desempate do dashboard.
- [ ] `open_answers` traz só as perguntas descritivas respondidas, com o texto da
      pergunta em pt-BR e a resposta como foi escrita.
- [ ] O client faz `POST` em `N8N_WEBHOOK_URL` com
      `Authorization: Bearer {N8N_WEBHOOK_TOKEN}` e o timeout de
      `N8N_TIMEOUT_SECONDS`.
- [ ] O client trata a resposta assim:
  - qualquer `2xx` é sucesso;
  - `4xx`, `5xx`, timeout e erro de conexão viram `N8NIndisponivel`;
  - nenhuma exceção do `httpx` sai do pacote.
- [ ] O client recebe o `httpx.AsyncClient` pronto, nunca em nível de módulo, e não
      importa nada de `app.domains`.
- [ ] Nenhum teste toca a rede: o client é testado com `httpx.MockTransport`.

## Como testar

```bash
pytest tests/external_services/n8n tests/domains/insights tests/domains/prismas -q
pytest tests/test_arquitetura.py -q
ruff check . && ruff format --check . && pre-commit run mypy --all-files
```

Rode também a suíte com a rede desligada: se ficar vermelha ou lenta, algum teste está
falando com o mundo.

## Premissas aplicáveis

- P-087: contrato `insight-v1`
- P-091: payload sem dado pessoal
- P-092: insight em pt-BR
