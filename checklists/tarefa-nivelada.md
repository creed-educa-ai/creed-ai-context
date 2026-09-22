# Tarefa nivelada — conferência de publicação

Conferência que **quem publica** faz, no passo 7 de
[`../workflows/tasks-to-clickup.md`](../workflows/tasks-to-clickup.md).

Ela cobre a **mecânica**: o que só quem está publicando consegue ver, e o que quebra se
a rodada seguinte encontrar o board em estado inesperado.

> **O conteúdo da subtarefa não se confere aqui.** O portão é o
> [`definition-of-ready.md`](definition-of-ready.md) — linguagem, contexto colado,
> recorte técnico, critérios de aceite e materiais são dele, e ele é medido por quem não
> usa o `creed-ai-context`. Repetir aquela lista aqui criaria duas versões da mesma
> regra, e esta envelheceria primeiro.

## Rastreio e idempotência

- [ ] A última linha de cada descrição publicada é a linha de `Rastreio:`.
- [ ] O título é um **resultado**, não uma atividade. "Relatório de adesão por
      organização", não "Criar service e repository".
- [ ] O primeiro bloco é entendível por quem nunca ouviu falar do CREED: sem sigla,
      sem caminho de arquivo, sem nome de camada.
- [ ] Nenhum jargão do harness aparece cru — "molde", "spec", "task N", "P-012",
      "P2 · T3", "premissa" viraram frase explicada ou sumiram.
- [ ] Termo do domínio (prisma, prognóstico, respondente, organização) aparece com a
      definição colada na primeira vez.
- [ ] Nenhuma frase manda "ver o molde", "ver o repositório de contexto" ou "seguir a
      convenção" sem dizer, ali mesmo, o que isso significa.

## Conteúdo técnico

- [ ] Os arquivos propostos estão **literais**, com o papel de cada um.
- [ ] Os métodos/funções que devem nascer estão nomeados.
- [ ] O que reusar está nomeado **com caminho** — não "aproveite o que já existe".
- [ ] Endpoint novo ou alterado tem método, rota, entrada, saída **e os códigos de
      erro**. Task de front traz o mesmo contrato, visto do consumidor.
- [ ] "Como verificar" é comando copiável, não instrução em prosa.
- [ ] Os critérios de aceite são verificáveis: dá para responder sim ou não.
- [ ] A subtarefa não cruza repos.

## Materiais

- [ ] Todo material citado está na lista, com ✅ ou ⬜ **e um dono**.
- [ ] Nenhum "veja o anexo" para material marcado ⬜.
- [ ] Material anexado nesta rodada aparece como ✅ **com o nome que ganhou no board** —
      ⬜ que sobrou depois do upload é a tarefa mentindo ao contrário.
- [ ] Premissa citada aparece com o **texto**, não só com o ID.
- [ ] Referência a arquivo de outro repositório é permalink, não nome de pasta.
- [ ] A mensagem final ao humano lista o que falta anexar, subtarefa por subtarefa.

## Publicação

- [ ] A última linha da descrição é a linha de `Rastreio:`.
- [ ] Rodar de novo não criou subtarefa duplicada nem seção repetida no épico.
- [ ] Subtarefa que já existia no board **sem** rastreio não foi tocada — foi reportada.
- [ ] Subtarefa cujo texto não mudou **não** foi reescrita: não se gasta chamada à toa.
- [ ] O `clickup.md` tem o ID de cada subtarefa e o estado de cada escrita. Sem isso a
      próxima rodada não tem como comparar.

## Formato

- [ ] A descrição foi enviada em `markdown_description`, não em `description` — tabela e
      bloco de código chegaram formatados.
- [ ] O título segue o padrão de numeração do épico (`CREED-NN.N - …`).
- [ ] Anexo subiu com nome prefixado pela tarefa: no board o arquivo perde a pasta de
      origem, e dois `README.md` soltos não se distinguem.

## Sincronia entre o board e o repositório

- [ ] Material anexado nesta rodada aparece como ✅ **na descrição**, com o nome que o
      arquivo ganhou no board. `⬜` que sobrou depois do upload é a tarefa pedindo o que
      já está lá.
- [ ] O `clickup.md` reflete o que está no board. Divergência entre os dois faz a rodada
      seguinte pedir de novo o que já foi feito.
- [ ] Nada de produto foi inventado para preencher seção. Lacuna virou premissa
      ([`../conventions/premissas-e-duvidas.md`](../conventions/premissas-e-duvidas.md)).

## Depois desta conferência

Passou aqui, rode o [`definition-of-ready.md`](definition-of-ready.md) em cada subtarefa
— é ele que decide se alguém consegue pegar a tarefa e começar.
