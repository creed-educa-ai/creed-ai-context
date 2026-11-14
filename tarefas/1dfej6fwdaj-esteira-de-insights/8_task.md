# Task 8 — Prompts v1 e avaliação

**Repo:** o conteúdo entra no **N8N da AWS**, no sub-workflow "gerar insight". O
registro fica no `creed-backend`, em `docker/n8n/`.
**Depende de:** tasks 6 e 7

## Objetivo

Os prompts v1 (regras e individual) e o dossiê v1 entram no sub-workflow. Um workflow de
avaliação, também no N8N, mostra para cerca de 20 perfis que o texto passa nos critérios
automáticos e na leitura humana.

## Arquivos que provavelmente mudam

No N8N:

- o sub-workflow "gerar insight", com os blocos do prompt;
- um workflow de avaliação, com gatilho manual.

No `creed-backend`:

- `docker/n8n/prompts/regras.md` e `docker/n8n/prompts/individual.md`
- `docker/n8n/avaliacao/perfis-individuais.json`
- `docker/n8n/avaliacao/criterios.md`: a lista de termos proibidos e as quatro perguntas
  da leitura humana
- `docker/n8n/avaliacao/resultado-v1.md`
- `docker/n8n/workflows/insight-v1-gerar.json` (exportado de novo) e
  `insight-v1-avaliacao.json`
- `tests/n8n/test_prompts.py`: o texto dos prompts e do dossiê dentro do JSON exportado
  é igual ao dos `.md`

## Molde

Spec, "Abordagem técnica", item 2.3 (blocos e o que um bom insight faz) e "Como
verificar", passo 5.

## Critérios de aceite

**Prompt**

- [ ] Os blocos 1 a 7 da spec estão na ordem, com o breakpoint de cache no fim do
      dossiê.
- [ ] O `prompt_version` é `individual-v1+dossie-v1`.
- [ ] Os `.md` em `docker/n8n/` são a fonte. Um teste falha se o JSON exportado tiver
      outro texto.

**Perfis**

- [ ] Há cerca de 20 perfis individuais sintéticos:
  - alto em tudo, baixo em tudo, plano;
  - destaque e oportunidade com notas coladas;
  - respostas abertas vazias, longas, em espanhol, ou contradizendo a nota;
  - uma resposta aberta com tentativa de instrução;
  - uma com o nome de um colega.

**Avaliação**

- [ ] O workflow de avaliação chama o mesmo sub-workflow para cada perfil.
- [ ] Um nó Code aplica os critérios automáticos:
  - `content` dentro do schema e com os 5 prismas;
  - destaque e oportunidade coerentes com o payload;
  - nenhum número fora do payload;
  - nenhum termo da lista proibida;
  - nenhum nome próprio;
  - texto em pt-BR.

  O resultado sai numa tabela, um perfil por linha.
- [ ] O custo da rodada é estimado e aprovado pelo Luís **antes** de rodar.
- [ ] Na segunda chamada, `cache_read_input_tokens` é maior que zero.
- [ ] Todos os perfis passam nos critérios automáticos.
- [ ] Duas pessoas fazem a leitura humana com as quatro perguntas. Elas e as respostas
      ficam no `resultado-v1.md`:
  - é fiel ao número?
  - usa o dossiê?
  - a recomendação é praticável?
  - o tom é de desenvolvimento?

## Como testar

No N8N: executar o workflow de avaliação e conferir a tabela.

No `creed-backend`:

```bash
pytest tests/n8n -q
```

## Premissas aplicáveis

- P-088: forma do insight
- P-092: insight em pt-BR
- P-093: dossiê
- P-094: desenvolvimento, não diagnóstico
