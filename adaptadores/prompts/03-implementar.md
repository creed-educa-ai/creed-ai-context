Implemente a task abaixo.

TASK: <cole o N_task.md>
MOLDE: <cole os arquivos do domínio/feature respondentes correspondentes>
ARQUIVOS ATUAIS: <cole os arquivos que vão mudar, se já existirem>

Regras:
- Copie a FORMA do molde. Diferença de estrutura precisa de justificativa.
- Camadas: router sem regra · service sem query nem HTTP · repository sem decisão ·
  front sem agregação.
- Escreva os testes junto: caso feliz + pelo menos um caso de borda. Se for correção
  de bug, o teste precisa falhar sem a correção.
- Escopo fechado: nada além da task. Problema que você notar ao lado vai na lista final,
  não no código.
- Não sugira comandos de git de escrita.
- Se houver migration: proponha o arquivo E termine avisando que ele precisa de leitura
  humana linha a linha, listando os pontos de atenção concretos (drop que devia ser
  rename, nullable=False em tabela com dados, down_revision, índice faltando).

Termine com:
Arquivos tocados: <lista>
Comando de teste que EU devo rodar: <comando>
Premissas usadas: <IDs ou nenhuma>
Fora do escopo, observado mas não mexido: <lista ou nada>
