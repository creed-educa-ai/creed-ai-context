# Task 1 — Kit do contrato

**Repo:** `creed-backend`
**Depende de:** nenhuma

## Objetivo

Os contratos de ida e de volta da esteira passam a existir como modelos Pydantic no back
e como arquivos que o N8N usa (schemas, exemplos e um vetor de assinatura). Um teste
impede os dois de divergirem.

## Arquivos que provavelmente mudam

- `app/external_services/n8n/__init__.py`
- `app/external_services/n8n/schemas.py`: os modelos da ida (`scope = "individual"`)
- `app/domains/insights/schemas.py`: `InsightContent` e os modelos da volta (`done` e
  `failed`)
- `app/core/security.py`: só a função pura que calcula a assinatura. O `Depends` que
  confere vem na task 5
- `scripts/exportar_contrato_n8n.py`: escreve os `*.schema.json` a partir dos modelos
- `docker/n8n/contrato/README.md`
- `docker/n8n/contrato/ida.schema.json` e `volta.schema.json`
- `docker/n8n/contrato/exemplo-ida-individual.json`
- `docker/n8n/contrato/exemplo-volta-done.json` e `exemplo-volta-failed.json`
- `docker/n8n/contrato/vetor-hmac.json`
- `tests/external_services/n8n/test_contrato.py`
- `tests/domains/insights/test_schemas.py`

## Molde

- `app/external_services/keycloak/`: é o primeiro serviço externo do back e passa a ser
  o molde do pacote `n8n/` (playbook `integrar-servico-externo.md`).
- `app/domains/users/schemas.py`: forma dos schemas de domínio.

## Critérios de aceite

- [ ] Os modelos seguem o contrato da spec, seção "Contrato": ida com
      `contract_version`, `scope`, `insight_id`, `attempt`, `language`, `result` (notas
      de 0 a 100, destaque e oportunidade) e `open_answers`; volta `done` com `content`,
      `model_id` e `prompt_version`; volta `failed` com `error` e `retryable`.
- [ ] `InsightContent` cobra os tamanhos da spec: `analise` com 2 a 4 parágrafos de até
      900 caracteres, `prismas` com exatamente as 5 chaves do enum `Prisma` e até 320
      caracteres cada, e `recomendacao` com 1 a 3 parágrafos de até 700 caracteres.
- [ ] O modelo da ida não tem campo de nome, e-mail, documento, organização, setor,
      dado demográfico nem `form_response_id`. Um teste lista os campos e falha se um
      desses aparecer.
- [ ] Os três exemplos validam contra os modelos. Versões alteradas são recusadas: sem
      um campo obrigatório, com um sexto prisma, com um parágrafo longo demais.
- [ ] A função de assinatura calcula HMAC-SHA256 sobre `"{timestamp}.{corpo cru}"` e
      reproduz o `sha256=<hex>` do `vetor-hmac.json`. Mudar um byte do corpo, ou o
      timestamp, muda a assinatura.
- [ ] Os `*.schema.json` commitados são iguais ao `model_json_schema()` dos modelos. Se
      divergirem, o teste falha com a mensagem "rode
      `python scripts/exportar_contrato_n8n.py`".
- [ ] O `README.md` do kit diz, para quem monta o workflow, o que é cada arquivo, como
      usar o exemplo de ida e o vetor no N8N, e como regerar os schemas.
- [ ] O segredo do vetor é um valor de teste óbvio (por exemplo,
      `segredo-de-teste-nao-use`), e o README diz que ele nunca vai para produção.

## Como testar

```bash
pytest tests/external_services/n8n tests/domains/insights/test_schemas.py -q
python scripts/exportar_contrato_n8n.py && git diff --exit-code docker/n8n/contrato/
pytest tests/test_arquitetura.py -q
ruff check . && ruff format --check . && pre-commit run mypy --all-files
```

Caso de borda: um `content` com as 5 chaves de prisma mas com uma escrita de outro jeito
(`segurança_psicologica`) é recusado.

## Premissas aplicáveis

- P-087: contrato `insight-v1`
- P-088: forma do insight (análise, um texto por prisma, recomendação)
- P-091: payload sem dado pessoal
- P-092: `language` vai como `pt-BR`
