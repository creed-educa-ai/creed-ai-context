# Task 12 — Integração na AWS, depois da publicação

**Repo:** `creed-infrastructure`, para o roteiro. Quem executa é **uma pessoa**, em
produção: a IA não faz SSH, não roda `aws` e não age em ambiente real.
**Depende de:**
- **Parte 1:** as tasks 6 e 8 prontas no N8N, e as tasks 2 a 5 e 9 publicadas (as
  tasks 10 e 11, se já publicadas, deixam ver o texto no dashboard).
- **Parte 2:** as tasks 13 a 16 publicadas.
- **Fora do board:** acesso SSH à EC2, para o túnel até o banco, e acesso ao editor do
  N8N.

## Objetivo

Um roteiro, executado em produção com uma organização de teste, mostra a ida e a volta
funcionando e as falhas virando estado. É a única vez em que o back e o N8N conversam
antes de alguém de verdade usar.

## Arquivos que provavelmente mudam

- `ec2/roteiro-esteira-de-insights.md` (novo)
- `ec2/README.md`: link para o roteiro

## Molde

As seções do `ec2/README.md` que já são roteiro de passos humanos: "Editor do N8N" e
"Console de admin do Keycloak".

## Critérios de aceite

**Parte 1 — insight individual**

- [ ] Uma organização de teste é criada pelo cadastro e aprovada, com um respondente de
      teste e respostas sintéticas. Nenhum dado real de respondente entra no teste.
- [ ] O insight passa por `pending → dispatched → done`, conferido no banco pelo túnel
      que o README já descreve.
- [ ] A execução no N8N mostra a chamada ao Bedrock e o callback com 204.
- [ ] Com o texto pronto, ele aparece no dashboard do respondente, se as tasks 10 e 11
      já estiverem publicadas.
- [ ] Na segunda execução, `cache_read_input_tokens` é maior que zero.
- [ ] Com o workflow desativado no N8N, um envio novo fica `pending` com backoff.
      Reativado o workflow, o insight chega a `done` sem ação humana.
- [ ] `curl` de fora para `/api/v1/insights/callback` responde 404.

**Parte 2 — insight da empresa**

- [ ] Com 5 respostas de teste no período, aparece um insight da empresa `pending`, e
      depois da espera ele chega a `done`.
- [ ] O texto aparece na visão consolidada da empresa, e os recortes por setor e por
      pessoa ficam sem texto.

**Fim**

- [ ] A organização de teste é apagada pela exclusão de empresa (E-6), e não sobra
      insight dela no banco.
- [ ] O roteiro registra, para cada parte, a data, quem executou e o que passou ou
      falhou.

## Como testar

É o próprio roteiro. Uma falha vira issue na task que entregou a peça, e a parte é
executada de novo depois da correção.

## Premissas aplicáveis

Nenhuma. Testar a integração só depois da publicação foi decisão do Luís em 2026-11-14
(spec, "Abordagem técnica", item 5).
