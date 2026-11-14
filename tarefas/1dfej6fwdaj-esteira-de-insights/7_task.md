# Task 7 — Dossiê v1

**Repo:** `creed-backend`, em `docker/n8n/conhecimento/`. É trabalho do time (AGES III e
IV): a IA ajuda a rascunhar as fichas a partir das fontes, mas quem lê e aprova é gente.
**Depende de:** inventário da bibliografia (onde estão os PDFs e as planilhas da
cliente)

## Objetivo

Um dossiê em Markdown, escrito pelo time a partir da bibliografia da cliente, que o
modelo lê inteiro em toda chamada. É o conhecimento que embasa o insight.

## Arquivos que provavelmente mudam

- `docker/n8n/conhecimento/dossie.md`
- `docker/n8n/conhecimento/README.md`: como o dossiê foi feito, quem revisou, onde está
  o inventário e como atualizar

## Molde

Spec, "Abordagem técnica", item 2.2: "Como o time transforma a bibliografia em dossiê".

## Critérios de aceite

- [ ] O inventário das fontes existe **fora do git**, com a referência completa de cada
      uma. O material é da cliente, e o README diz onde está o inventário sem copiá-lo.
- [ ] Há uma ficha por fonte, com:
  - a tese central e os conceitos;
  - a ligação com cada dimensão e cada prisma;
  - o que a fonte diz sobre desenvolvimento e práticas;
  - os trechos-chave **parafraseados**, com a página.
- [ ] A matriz conceitual tem uma linha por prisma e por dimensão (12 linhas). Cada
      linha traz definição, o que sugere uma nota alta, o que sugere uma nota baixa,
      alavancas de desenvolvimento, leituras a evitar e a ficha de origem.
- [ ] A seção "Como ler os números" traz:
  - as escalas (0 a 100 na tela, 1 a 5 nas respostas);
  - as fórmulas, iguais às de `app/domains/prismas/utils.py`;
  - o que são destaque e oportunidade;
  - os limites do instrumento: autoavaliação, num momento do tempo.
- [ ] Há um glossário, a partir do glossário do `creed-docs`.
- [ ] As planilhas viraram tabelas em Markdown, e os gráficos, descrição.
- [ ] O dossiê tem entre 30 e 80 mil tokens. O número fica no cabeçalho, medido pela
      `usage.input_tokens` de uma chamada de fumaça (task 8) ou pela API de contagem de
      tokens, se estiver disponível.
- [ ] Nenhum trecho longo é copiado das fontes. Citação literal só curta e com página.
- [ ] Duas pessoas de AGES III e IV leram o dossiê inteiro, e os nomes estão no
      cabeçalho.

## Como testar

É leitura. A pergunta que decide é: com só o dossiê na mão, alguém de fora do time
consegue explicar o que significa ter segurança psicológica alta e adaptabilidade
cognitiva baixa, e citar de onde veio cada parte da explicação?

## Premissas aplicáveis

- P-093: o conhecimento é um dossiê escrito pelo time; os originais ficam fora do git, e
  a cliente revisa depois
