Calibre a profundidade da spec desta tarefa. Não escreva a spec.

TAREFA: <id> — <título e descrição>

O projeto tem UM documento por tarefa, não PRD + techspec. Então a profundidade é medida
em dois eixos independentes, e cada eixo manda em metade das seções.

EIXO P — incerteza de produto (um sinal do nível maior já basta):
- P1: a tarefa já diz o resultado e quem usa; nenhuma interpretação nova; nenhuma premissa.
- P2: resultado claro, mas 1–2 lacunas pedem escolha barata de reverter (nome visível,
  ordenação, valor padrão, texto).
- P3: quem usa — ou o que conta como pronto — depende de decisão que a cliente não deu;
  3+ premissas novas; premissa de custo médio/alto; regra de negócio nova (papel,
  permissão, cálculo, ciclo de vida).

EIXO T — complexidade técnica (um sinal do nível maior já basta):
- T1: um repo, dentro do molde, sem contrato novo, sem migration.
- T2: dois repos precisam combinar; contrato de API novo ou alterado; domínio/feature
  novo seguindo o molde.
- T3: migration; agregação nova no banco; mudança em contrato já consumido; infra;
  padrão que não existe no código nem no harness.

SEÇÕES POR NÍVEL — piso fixo em qualquer calibragem: Problema, Escopo (Entra),
Critérios de aceite, Como verificar.
- Quem usa: P2+ (em P3, quebrado por papel)
- Escopo → Não entra: P2+
- Premissas: P2+
- Repos afetados: sempre (uma linha em T1, tabela a partir de T2)
- Contrato: T2+
- Dados: T3 (em T2, só se houver coluna nova)
- Abordagem técnica (opção escolhida E a descartada): T3
- Riscos: nível 2 em qualquer eixo

RESULTADO:
- P1 · T1 → não escreva spec. Diga isso e vá para a lista de tasks.
- Qualquer outra combinação → spec com as seções exigidas, e SÓ elas. Seção dispensada é
  apagada, não preenchida com "N/A".

Responda neste formato:

Calibragem: P<n> · T<n>
| Eixo | Nível | Sinal observado |
|---|---|---|
| Produto | P<n> | <a frase da tarefa que decidiu> |
| Técnico | T<n> | <o sinal: repo, molde, contrato, migration> |
Exigidas: <lista>
Dispensadas: <lista>

Regras:
- Cite o SINAL OBSERVADO na descrição, não impressão. "Parece complexa" não é sinal.
- Empate ou dúvida entre dois níveis: fica o MAIOR, e diga qual sinal decidiu.
- Nenhum sinal observável: P3 · T2, dito por escrito. Não invente sinal para baixar a nota.
