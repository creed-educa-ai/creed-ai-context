Implemente a task abaixo.

TASK: <cole o N_task.md>
MOLDE: <cole os arquivos do domínio/feature respondentes correspondentes>
ARQUIVOS ATUAIS: <cole os arquivos que vão mudar, se já existirem>

Regras:
- Copie a FORMA do molde. Diferença de estrutura precisa de justificativa.
- Camadas: router sem regra · service sem query nem HTTP · repository sem decisão ·
  front sem agregação.
- NÍVEL DO TIME, não código esperto: um colega entende o arquivo em uma passada.
  Sem abstração para um caso só, sem metaprogramação, sem genérico profundo, sem
  herança onde composição resolve, sem padrão que o repo ainda não usa. Se algo disso
  for mesmo necessário, diga em uma linha o que quebrava sem ele.
- Escreva os testes junto: caso feliz + pelo menos um caso de borda. Se for correção
  de bug, o teste precisa falhar sem a correção.
- Escopo fechado: nada além da task. Problema que você notar ao lado vai na lista final,
  não no código.
- Não sugira comandos de git de escrita.
- PARE ANTES DE ESCREVER se houver bifurcação técnica real (efeito visível no código e
  sem resposta no molde/convenção): apresente 2 opções com trade-off e a sua
  recomendação, e espere minha resposta. Máximo 2 paradas. Dúvida de PRODUTO não para:
  vira premissa, você diz que adotou e segue.
- Se houver migration: proponha o arquivo E termine avisando que ele precisa de leitura
  humana linha a linha, listando os pontos de atenção concretos (drop que devia ser
  rename, nullable=False em tabela com dados, down_revision, índice faltando).

Termine EXPLICANDO, nesta ordem — explique decisão, não sintaxe:

O que a task pedia: <uma frase, em linguagem de produto>
Abordagem escolhida e por quê: <2 a 5 linhas, ancoradas no molde/convenção/princípio>
O que descartei: <alternativa → motivo concreto; ou "nenhuma: o molde já fixa a forma">
Mapa do diff: <arquivo → papel na solução>
Os testes provam: <o quê> · Não provam: <o quê e por quê>
Decisões minhas nas paradas: <o que escolhi e o efeito; ou "nenhuma parada">
Onde pode quebrar depois: <riscos concretos, ou "nada previsível">
Para eu conseguir defender: <3 perguntas sobre este diff, cada uma com arquivo:linha
  onde está a resposta — NÃO responda por mim>

Arquivos tocados: <lista>
Comando de teste que EU devo rodar: <comando>
Premissas usadas: <IDs ou nenhuma>
Fora do escopo, observado mas não mexido: <lista ou nada>
