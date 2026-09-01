# Aprendizado: o código precisa ser defensável

Este harness existe para duas coisas ao mesmo tempo, e a segunda não é decorativa:

1. **Produtividade controlada** — a IA escreve dentro do molde, sem inventar padrão.
2. **Aprendizado de quem entrega** — quem leva o código para o PR sabe explicá-lo.

Se as duas brigarem, ganha a segunda. Um harness que entrega volume de código que o
time não entende produz um repositório que ninguém consegue manter em setembro.

## 1. Por que este arquivo existe

A AGES é um projeto **acadêmico** rodando com processo de indústria. O aluno está aqui
para aprender a construir software, não para intermediar prompts. A recomendação do
professor foi explícita: montar a estrutura de desenvolvimento com IA **junto** com a
cartilha de boas práticas — porque a ferramenta sem a cartilha produz um semestre
inteiro de código órfão.

A autocrítica que originou este arquivo: é fácil, hoje, terminar uma sprint inteira
sem ter lido uma linha do que foi entregue. O harness não impede isso sozinho —
nenhum arquivo de contexto impede. O que ele faz é **tornar o entendimento parte da
entrega**, e não um extra que se faz quando sobra tempo.

## 2. O critério: defensabilidade

> **Você consegue explicar cada decisão do diff, sem abrir o chat, para alguém que não
> acompanhou a task?**

É o único teste que importa. Não é "você leu"; é "você sabe defender". Concretamente,
antes do PR você responde ao [`../checklists/defesa-do-codigo.md`](../checklists/defesa-do-codigo.md).

Não passou? A task não está pronta — e a saída **não é** pedir o código de novo. É:

| Falha | O que fazer |
|---|---|
| Não entendi *o que* o código faz | peça ao modelo para explicar aquele trecho, linha a linha |
| Não entendi *por que* foi feito assim | peça as alternativas descartadas e o motivo |
| Entendi e discordo | mude — a decisão é sua, o modelo não assina o PR |
| É complexo demais para o time ler | [`../conventions/nivel-de-codigo.md`](../conventions/nivel-de-codigo.md); peça a versão simples |

## 3. O que é seu e o que é do modelo

| É do modelo | É seu, sempre |
|---|---|
| Escrever o código dentro do molde | Decidir **o que** vai ser construído |
| Escrever os testes junto | Escolher entre duas abordagens legítimas (§4) |
| Explicar o que fez e por quê | **Entender** a explicação — e discordar quando for o caso |
| Apontar risco e borda | Rodar a suíte, ler o diff inteiro, abrir o PR |
| Propor migration | Ler a migration linha a linha |

A linha divisória não é "tarefa fácil × tarefa difícil". É **julgamento × execução**.
Delegar execução é o objetivo do harness. Delegar julgamento é o que ele impede.

## 4. Parada de decisão

Quando a task chega numa bifurcação técnica real, o agente **para e pergunta** em vez
de escolher sozinho. Critério em [`../workflows/tasks-to-code.md`](../workflows/tasks-to-code.md)
→ "Parada de decisão". O que importa aqui é o seu lado:

- **Responder "tanto faz, decide você" é uma resposta válida** — e fica registrada
  assim no encerramento e no PR. Ninguém finge que você decidiu.
- **Responder errado não quebra nada** — o agente implementa, os testes mostram o
  efeito, e você aprendeu a diferença com um diff na mão. É o ponto.
- **Parada demais vira ruído.** Máximo de 2 por task; o resto o molde resolve.

## 5. Encerramento didático

Toda implementação termina no formato de
[`../templates/entrega-didatica.md`](../templates/entrega-didatica.md): o problema, a
abordagem, **o que foi descartado e por quê**, o mapa do diff, o que os testes provam
e o que não provam, e onde aquilo pode quebrar depois.

As alternativas descartadas são a parte que mais ensina e a que mais se perde. Código
pronto mostra uma solução; a explicação mostra o **espaço de soluções** — que é o que
você leva para a próxima task, e para a próxima cadeira.

## 6. Onde você entra, etapa por etapa

| Etapa | O modelo faz | Você faz — não delegável |
|---|---|---|
| `/spec` | estrutura a tarefa do ClickUp | conferir se é isso mesmo que a cliente pediu |
| `/tasks` | quebra em tasks incrementais | conferir se a ordem faz sentido e cabe na sprint |
| `/implementar` | escreve código + teste, para nas bifurcações | **decidir nas paradas**; ler a entrega didática |
| suíte | roda e reporta | **rodar você mesmo** (DoD) |
| `/revisar` | aponta contra os checklists | julgar o que é exigência e o que é sugestão |
| defesa | — | responder ao checklist de defesa |
| PR | — | descrever, vincular, declarar o uso de IA |

## 7. Sinais de delegação cega

Se algum destes descreve a sua semana, o problema não é o modelo:

- Aceitar o diff sem abrir os arquivos alterados.
- Pedir "arruma isso" três vezes seguidas sem ler o erro.
- Não saber dizer em qual camada a regra de negócio daquela task ficou.
- Descobrir o que a feature faz **no review do colega**.
- Responder "decide você" em todas as paradas de decisão da sprint.
- Copiar o encerramento didático para a descrição do PR sem ter lido.

Nenhum deles é motivo de vergonha isoladamente. Todos juntos, por duas sprints, é o
sintoma de que o semestre está sendo perdido.

## 8. O que este arquivo NÃO é

Não é freio de produtividade e não é ritual. Ninguém precisa reescrever à mão o que a
IA gerou para "provar que entendeu", e explicar não substitui teste — a suíte continua
sendo a prova de que funciona. O objetivo é **produzir mais e entender o que foi
produzido**, não produzir menos.
