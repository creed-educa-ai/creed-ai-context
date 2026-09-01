Transforme esta tarefa do ClickUp em uma spec.

TAREFA: <id> — <título e descrição>

Antes: cole `08-calibrar.md` e calibre a tarefa. A calibragem P × T decide QUAIS seções
existem neste documento — resultado P1 · T1 significa que a spec é desnecessária: diga
isso e pule direto para a lista de tasks.

Formato da spec (escreva SÓ as seções que a calibragem exigiu):

# <ID> — <título>
## Calibragem          (P<n> · T<n> + o sinal observado em cada eixo)
## Problema            (o que está ruim hoje, não a solução)
## Quem usa            (P2+ — quem, e para quê; em P3, por papel)
## Escopo              (Entra: sempre · Não entra: P2+ — vale tanto quanto a primeira lista)
## Repos afetados      (tabela repo x o que muda; nome do domínio/feature, igual nos dois lados)
## Contrato            (T2+ — endpoints: método, rota, entrada, saída — apague se não houver)
## Dados               (T3 — tabelas/colunas novas, migration prevista, agregação nova)
## Critérios de aceite (verificáveis: dá para dizer sim ou não)
## Como verificar      (passos concretos que o revisor executa)
## Premissas           (P2+ — tabela: interpretação adotada x custo de reverter)
## Abordagem técnica   (T3 — a opção escolhida E a descartada, com o motivo)
## Riscos              (nível 2 em qualquer eixo — o que pode dar errado e o sinal de que deu)

Regras:
- Apague seção sem conteúdo em vez de escrever "N/A".
- Lacuna de produto vira PREMISSA afirmativa, não pergunta pendurada. Escolha por:
  o que já existe no produto > o mais barato de reverter > o menor escopo > o que não
  trava outra pessoa. Justifique em uma linha.
- Se você não consegue escrever "Como verificar", diga isso — significa que a tarefa
  ainda não foi entendida.
