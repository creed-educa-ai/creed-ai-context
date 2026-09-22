# Definition of Ready

Portão da **subtarefa publicada no ClickUp**: ela está pronta para alguém pegar e
começar hoje.

## A régua

> **O DoR é medido por quem NÃO usa o `creed-ai-context`.**

Quem desenvolve com o repositório de contexto aberto — e com IA lendo a spec — alcança
informação que a tarefa não precisou escrever. Quem não usa, não alcança. Se o DoR for
medido pela primeira pessoa, a tarefa passa parecendo pronta e chega quebrada na segunda.

Então a régua é sempre a mais exigente das duas. Nivelar por baixo aqui é nivelar por
cima na qualidade: uma tarefa que serve a quem não tem o contexto serve a todo mundo.

Em uma frase: **a subtarefa se basta.** O `creed-ai-context` pode acrescentar profundidade,
nunca ser a única fonte de algo necessário para começar.

## O teste rápido — três perguntas

Antes do checklist, o atalho. Entregue a subtarefa a alguém do time que **não** participou
da especificação e peça que responda, lendo só a tarefa e os anexos dela:

1. **O que muda para quem usa o sistema?**
2. **Por onde eu começo — que arquivo eu abro primeiro?**
3. **Como eu sei que terminei?**

Precisou abrir outra coisa para responder qualquer uma das três — o repositório de
contexto, uma conversa, a cabeça de quem escreveu — **reprovou**. O checklist abaixo
existe para achar o que faltou.

## 1. Escopo e resultado

- [ ] O **título é um resultado**, não uma atividade. "Relatório de adesão por
      organização", não "Criar service e repository".
- [ ] Abre com **uma frase** que diz o que a entrega faz.
- [ ] Tem um bloco de **o que muda para quem usa**, em português corrente: sem sigla,
      sem caminho de arquivo, sem nome de camada.
- [ ] O que **não** entra está dito — é o que impede a entrega de crescer sozinha.
- [ ] A subtarefa **não cruza repositórios**. Back e front são subtarefas separadas.

## 2. Contexto que o dev não tem como adivinhar

- [ ] Termo do domínio (respondente, vínculo, prisma, prognóstico, organização) aparece
      **com a definição colada** na primeira vez. Não "ver glossário".
- [ ] Decisão de produto tomada sem a cliente aparece **em texto**, com o que muda no
      código se ela cair. **`P-012` sozinho não é contexto** — é um código que só quem
      tem o ledger consegue resolver.
- [ ] Decisão de arquitetura que restringe a implementação está explicada ali, ou linkada
      com um endereço que abre fora do repositório.
- [ ] Divergência conhecida entre o que está escrito e o que está no código está avisada.
      Descobrir isso na metade da implementação é o desperdício mais caro do ciclo.

## 3. O recorte técnico, literal

- [ ] **Arquivos propostos com caminho**, e o papel de cada um.
- [ ] **Métodos ou funções que devem nascer**, nomeados.
- [ ] **O que reusar, com caminho** — nunca "aproveite o que já existe". Quem não conhece
      o repositório não sabe o que existe.
- [ ] Onde copiar a forma vai como **link que abre** (permalink do arquivo no GitHub),
      não como nome de pasta.
- [ ] Endpoint novo ou alterado tem **método, rota, entrada, saída e os códigos de erro**.
      Subtarefa de front traz o mesmo contrato, visto de quem consome.

## 4. Como saber que terminou

- [ ] Critérios de aceite **verificáveis**: dá para responder sim ou não olhando a tela,
      a resposta da API ou o teste.
- [ ] "Como verificar" é **comando copiável**, não instrução em prosa.
- [ ] Caso feliz **e** pelo menos um caso de borda, nomeados.

## 5. Material em mãos

- [ ] Todo material citado está **anexado na subtarefa** ou linkado com endereço que abre.
- [ ] Nenhum `⬜` **bloqueante**: pendência que impede começar reprova o DoR. Pendência
      que só atrapalha o acabamento pode ficar, marcada e com dono.
- [ ] Nenhuma frase manda "ver o molde", "seguir a convenção" ou "ler a spec" **como
      única fonte** de algo necessário.
- [ ] Se o material existe só dentro do `creed-ai-context`, ele foi **anexado** — o
      caminho do repositório não substitui o anexo.

## 6. Dependências e ordem

- [ ] Está dito **de que outra subtarefa esta depende**, pelo nome dela.
- [ ] A dependência está concluída — ou o que dá para adiantar sem ela está dito
      (programar contra o contrato acordado, por exemplo).
- [ ] Dependência de algo **fora do board** (um acesso, um ambiente, uma decisão de
      terceiro) está declarada. Dependência invisível é a que atrasa sem explicação.

## Não é motivo para segurar a tarefa

**Falta de resposta da cliente.** Ela é acessível em reunião marcada, e a dúvida de
produto vira premissa registrada — afirmação escrita, com custo de reverter — e a tarefa
começa ([`../conventions/premissas-e-duvidas.md`](../conventions/premissas-e-duvidas.md)).

O que segura a tarefa é a premissa **não escrita**: aí a escolha acontece na cabeça de
quem implementa, sem ninguém saber que foi feita.

## Reprovou — para onde volta

| O que faltou | Volta para |
|---|---|
| Linguagem, material, contexto não colado | a **publicação**: corrija o texto da subtarefa ([`../workflows/tasks-to-clickup.md`](../workflows/tasks-to-clickup.md)) |
| Arquivo, contrato, critério de aceite — informação que ninguém tem | a **decomposição**: a task estava grossa demais ([`../workflows/spec-to-tasks.md`](../workflows/spec-to-tasks.md)) |
| O que a entrega faz, ou para quem | a **spec**: o problema é anterior ([`../workflows/tarefa-to-spec.md`](../workflows/tarefa-to-spec.md)) |

> **E a spec?** Ela não tem portão próprio: está pronta quando dá para escrever, a partir
> dela, subtarefas que passam neste checklist. Se você não consegue preencher a seção
> 4 de uma das entregas, a spec ainda não entendeu a tarefa — e o problema não é falta de
> resposta da cliente.

Jornada inteira, do card cru até aqui:
[`../playbooks/jornada-de-discovery.md`](../playbooks/jornada-de-discovery.md).
