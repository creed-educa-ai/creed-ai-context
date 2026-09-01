# Profundidade da spec — calibragem P × T

> Régua aplicada no passo 3 de [`../workflows/tarefa-to-spec.md`](../workflows/tarefa-to-spec.md),
> pelo comando `/calibrar` ou à mão. O formato da saída mora em
> [`../templates/spec-template.md`](../templates/spec-template.md).

O projeto tem **um documento por tarefa**, não PRD + techspec. O mesmo `spec.md` carrega
as duas perguntas:

| Pergunta | De quem seria | Seções que ela ocupa |
|---|---|---|
| O quê, para quem, por quê | PRD | Problema · Quem usa · Escopo · Premissas |
| Como, e o que quebra | techspec | Repos afetados · Contrato · Dados · Abordagem técnica |

Com uma profundidade só, um dos dois lados sempre sai errado: tarefa tecnicamente óbvia e
ambígua de produto vira documento cheio de tabela de endpoint e vazio de decisão; tarefa
de produto óbvio com migration vira o inverso. Por isso a calibragem tem **dois eixos
independentes**, medidos antes da primeira linha da spec.

## Eixo P — incerteza de produto

Quanto do "o quê / para quem" ainda não está decidido.

| Nível | Vale quando **qualquer** sinal aparece |
|---|---|
| **P1** | A tarefa já diz o resultado e quem usa · nenhuma interpretação nova é necessária · nenhuma premissa nova |
| **P2** | O resultado está claro, mas 1–2 lacunas pedem escolha **barata de reverter**: nome visível, ordenação, valor padrão, texto |
| **P3** | Quem usa — ou o que conta como pronto — depende de decisão que a cliente não deu · 3 ou mais premissas novas · qualquer premissa de custo médio/alto · regra de negócio nova (papel, permissão, cálculo, ciclo de vida) |

## Eixo T — complexidade técnica

Quanto do "como" é novo, espalhado ou irreversível.

| Nível | Vale quando **qualquer** sinal aparece |
|---|---|
| **T1** | Um repo · dentro do molde (`respondentes`) · sem contrato novo · sem migration |
| **T2** | Dois repos precisam combinar · contrato de API novo ou alterado · domínio/feature novo seguindo o molde |
| **T3** | Migration · agregação nova no banco · mudança em contrato **já consumido** · infra (Job, Helm, EKS) · padrão que não existe no código nem neste harness |

## Regra de arredondamento

- **Um sinal do nível maior basta.** Os eixos não são média: T3 com um único sinal é T3.
- **Empate ou dúvida entre dois níveis → fica o maior**, e a linha "Sinal" diz qual sinal
  decidiu. Seção a mais custa parágrafo; seção a menos custa retrabalho.
- **Caso padrão, quando nenhum sinal é observável** (descrição vaga demais para classificar):
  **P3 · T2**, e a calibragem registra "sem sinal observável na tarefa". Não invente sinal.

## Seções por nível

Piso fixo, em qualquer calibragem: **Problema · Escopo (Entra) · Critérios de aceite ·
Como verificar**. Sem essas quatro não é spec.

| Seção | Eixo | Exigida a partir de | Dispensada em |
|---|---|---|---|
| Problema | — | sempre | — |
| Quem usa | P | P2 — em **P3, por papel**: quem vê o quê | P1 |
| Escopo → Entra | — | sempre | — |
| Escopo → Não entra | P | P2, item a item | P1 |
| Premissas | P | P2 | P1 sem premissa nova |
| Repos afetados | T | sempre — uma linha em T1, tabela a partir de T2 | — |
| Contrato | T | T2 | T1 |
| Dados | T | T3 — em T2, só se houver coluna nova | T1 |
| Abordagem técnica | T | T3: opção escolhida **e a descartada**, com o motivo | T1, T2 |
| Critérios de aceite | — | sempre | — |
| Como verificar | — | sempre | — |
| Riscos | o maior dos dois | nível 2 em qualquer eixo | P1 · T1 |

**Dispensada = apagada**, não preenchida com "N/A" — é a regra que o template já tinha,
agora com critério em vez de bom senso.

## A combinação decide se existe spec

| Combinação | Resultado |
|---|---|
| **P1 · T1** | **Sem spec.** Vá direto para [`spec-to-tasks`](../workflows/spec-to-tasks.md) — ou ao código. |
| **P1 · T2–T3** | Spec técnica: produto em duas linhas; Contrato, Dados e Abordagem completos. |
| **P2–P3 · T1** | Spec de produto: sem Contrato e sem Dados, com Premissas fundas. |
| **P2–P3 · T2–T3** | Spec completa. |

P1 · T1 é a antiga regra "Quando pular" do workflow, agora com sinal observável no lugar
de julgamento.

## Recalibrar

A calibragem é um bloco no cabeçalho da spec, e recalibrar **substitui** esse bloco —
nunca acrescenta um segundo (rodar duas vezes não duplica nada).

Quando o nível **sobe** (a tarefa mudou no ClickUp, ver [`atualizar-spec`](../workflows/atualizar-spec.md)):
escreva as seções que passaram a ser exigidas. Quando **desce**: a seção que deixou de ser
exigida **não é apagada se já tem conteúdo** — decisão registrada não se joga fora por
mudança de régua.

## Por que o modelo leve dá conta

A régua é uma tabela de sinais observáveis: classificar é casar sinal com linha, não julgar
arquitetura. Por isso `/calibrar` roda em modelo leve, como manda
[`skills-e-comandos.md`](skills-e-comandos.md) §1. Se errar de verdade — erro citado no PR,
não suposição — sobe um degrau.

## Exemplo resolvido — CREED-17

Calibragem: **P3 · T1**

| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P3 | regra de negócio nova (quem vê qual opção do menu) + 3 premissas novas |
| Técnico | T1 | um repo, componente dentro do molde, sem contrato novo, sem migration |

Exigidas: Problema · Quem usa (por papel) · Escopo com "Não entra" item a item · Repos
afetados · Premissas · Critérios · Como verificar · Riscos.
Dispensadas: Contrato · Dados · Abordagem técnica.

Um eixo só teria chamado essa tarefa de "média" e pedido meia tabela de endpoint que não
existe, enquanto o lado que de fato era difícil — quem enxerga o quê — ficaria raso.
