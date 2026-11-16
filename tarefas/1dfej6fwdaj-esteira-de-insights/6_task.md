# Task 6 — Workflow `insight-v1` no N8N da AWS

**Repo:** o workflow é montado no **N8N da EC2**, no editor (`https://<IP>:5679`). O
registro fica no `creed-backend`, em `docker/n8n/`.
**Depende de:**
- task 1 (só o kit; não precisa de código do back rodando);
- **fora do board:** acesso ao editor do N8N da EC2 (a senha compartilhada e um login
  no N8N, por convite do dono da instância).

## Objetivo

No N8N da AWS, um workflow de entrada recebe o `insight-v1` com token e chama um
sub-workflow "gerar insight". O sub-workflow consulta o Bedrock com a credencial que já
existe, e a resposta volta assinada ao back pela rede interna. As falhas viram callback
`failed`.

## Arquivos que provavelmente mudam

No N8N:

- workflow de entrada, sub-workflow de geração e error workflow;
- uma credencial Header Auth para o token da ida;
- uma credencial para o segredo da volta.

**A credencial do Bedrock não muda.**

No `creed-backend` (registro e testes):

- `docker/n8n/workflows/insight-v1-entrada.json`, `insight-v1-gerar.json` e
  `insight-v1-erro.json`, exportados do editor
- `docker/n8n/contrato/saida-n8n.json`: o corpo de volta que o workflow produziu de
  verdade, com o exemplo de ida
- `docker/n8n/README.md`: substitui o da POC; diz o que roda onde e como exportar
- `tests/n8n/test_workflow_v1.py`: a estrutura dos JSON exportados
- `tests/external_services/n8n/test_contrato.py`: valida a `saida-n8n.json`

## Molde

- A pasta `docker/n8n/` da branch `feat/55-workflow-n8n-async` (Gabriel Martins e
  Gustavo Amaro): estrutura, nó de validação e testes sobre o JSON. Créditos no PR.
- Spec, "Abordagem técnica", itens 2.4 e 2.5.

## Critérios de aceite

**Entrada**

- [ ] O webhook é `POST /webhook/creed/insights/v1`, com Header Auth, e responde 202
      na hora.
- [ ] Executado com o `exemplo-ida-individual.json` fixado, o nó de validação aceita o
      payload.
- [ ] Sem um campo obrigatório, o payload vai para a volta como `failed`, com
      `error: "invalid_payload"` e `retryable: false`. Se o que falta é o próprio
      `insight_id` ou o `attempt`, a volta não tem como sair dentro do contrato (o back
      a recusaria com 422): fica só o log, e a varredura do worker cuida do pedido.

**Chamada ao Bedrock**

- [ ] O sub-workflow chama o Bedrock pelo nó HTTP Request, com a credencial AWS que já
      está no N8N.
- [ ] O modelo é o que a credencial libera. A recomendação da spec é o Claude Opus 5.5
      (`anthropic.claude-opus-5-5`); se a credencial liberar outro, o nome fica no
      README.
- [ ] A chamada usa `output_config.format` com o schema do `content` do kit, esforço
      `medium`, `max_tokens` 16000 e um breakpoint de cache de 1 h no fim do bloco do
      dossiê. Até a task 8, o prompt e o dossiê são provisórios.
- [ ] A primeira chamada confere qual endpoint do Bedrock aceita `output_config.format`
      e `cache_control` para o modelo, e o README registra qual foi usado.

**Falhas**

- [ ] `stop_reason: refusal` vira `failed` com `retryable: false`.
- [ ] `stop_reason: max_tokens` vira `failed` com `retryable: true`.
- [ ] Throttling do Bedrock: Retry On Fail com 3 tentativas, depois `failed` com
      `retryable: true`.
- [ ] Um erro em qualquer nó cai no error workflow, que devolve `failed` pelo mesmo
      callback.

**Assinatura e volta**

- [ ] O nó que assina, com o segredo de teste, reproduz exatamente a assinatura do
      `vetor-hmac.json`. A execução fica registrada no README.
- [ ] O nó de volta faz `POST` em `http://back:8000/api/v1/insights/callback`, URL fixa.
      Nenhuma URL vem do payload.
- [ ] Toda volta, `done` ou `failed`, inclusive a do error workflow, leva o `insight_id`
      e o `attempt` iguais aos da ida. O back só aplica um `failed` à tentativa que ainda
      espera a volta (spec, "Volta: N8N → back"; ADR-0010, A8). O error workflow
      recupera o `attempt` do mesmo jeito que recupera o `insight_id`.
- [ ] O segredo de produção fica numa credencial do N8N, nunca como literal num nó.
- [ ] A `saida-n8n.json` é o corpo que o nó de volta montou na execução com o exemplo, e
      valida contra o `volta.schema.json`. O teste é do back.

**Registro**

- [ ] Os JSON exportados não contêm segredo, nem URL de volta além da fixa. Testado em
      `tests/n8n/`.
- [ ] Antes da publicação do back (task 9), o `POST` de volta responde 404, e isso é
      esperado. Durante o desenvolvimento, o nó de volta fica com saída fixada.

## Como testar

No N8N:

1. Executar o workflow de entrada com o exemplo de ida fixado.
2. Conferir o 202, a chamada ao Bedrock, o `content` dentro do schema e a assinatura do
   vetor.

No `creed-backend`:

```bash
pytest tests/n8n tests/external_services/n8n -q
```

## Premissas aplicáveis

- P-087: contrato `insight-v1`
- P-094: tom de desenvolvimento (no prompt provisório também)
