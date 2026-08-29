Transforme esta tarefa do ClickUp em uma spec.

TAREFA: <id> — <título e descrição>

Antes: se a tarefa toca um repo só, cabe em um PR, não cria domínio/feature novo, não
muda contrato de API e não tem migration — diga que a spec é desnecessária e pule
direto para a lista de tasks.

Formato da spec:

# <ID> — <título>
## Problema            (o que está ruim hoje, não a solução)
## Quem usa            (quem, e para quê)
## Escopo              (Entra / Não entra — a segunda lista vale tanto quanto a primeira)
## Repos afetados      (tabela repo x o que muda; nome do domínio/feature, igual nos dois lados)
## Contrato            (endpoints: método, rota, entrada, saída — apague se não houver)
## Dados               (tabelas/colunas novas, migration prevista, agregação nova)
## Critérios de aceite (verificáveis: dá para dizer sim ou não)
## Como verificar      (passos concretos que o revisor executa)
## Premissas           (tabela: interpretação adotada x custo de reverter)
## Riscos              (o que pode dar errado e o sinal de que deu)

Regras:
- Apague seção sem conteúdo em vez de escrever "N/A".
- Lacuna de produto vira PREMISSA afirmativa, não pergunta pendurada. Escolha por:
  o que já existe no produto > o mais barato de reverter > o menor escopo > o que não
  trava outra pessoa. Justifique em uma linha.
- Se você não consegue escrever "Como verificar", diga isso — significa que a tarefa
  ainda não foi entendida.
