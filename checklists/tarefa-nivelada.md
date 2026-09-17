# Tarefa nivelada

Conferência do que vai para o ClickUp — épico e subtarefas —, aplicada no passo 7 de
[`../workflows/tasks-to-clickup.md`](../workflows/tasks-to-clickup.md).

"Nivelada" quer dizer: **as três pessoas abaixo leem a mesma tarefa e nenhuma precisa
perguntar nada** para começar.

| Quem | O que precisa achar sozinho |
|---|---|
| Quem não está no tema | o que muda no produto, e para quem |
| Dev que não usa o repositório de contexto nem IA | arquivos, métodos, reuso, contrato, comando de teste |
| Dev que usa | o rastreio, no fim |

## Linguagem

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
- [ ] Subtarefa que já existia no board sem rastreio **não foi tocada** — foi reportada.
- [ ] A descrição foi enviada em `markdown_description`: tabela e bloco de código
      chegaram formatados.
- [ ] Nada de produto foi inventado para preencher seção. Lacuna virou premissa
      (`../conventions/premissas-e-duvidas.md`).

## Reprovou?

Item de **linguagem** ou **materiais** reprovado: corrija o `clickup.md` e republique —
é barato, e é o que a tarefa existe para evitar.

Item de **conteúdo técnico** reprovado por falta de informação — e não por redação — o
buraco não é da publicação: é da spec ou da decomposição. Volte a
[`spec-to-tasks.md`](../workflows/spec-to-tasks.md) em vez de preencher no chute.
