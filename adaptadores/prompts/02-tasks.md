Decomponha esta spec em tasks.

SPEC: <cole a spec>

PRIMEIRO: apresente só a lista em alto nível (título + repo + entregável) e espere meu
ok. Não escreva os arquivos ainda.

Regras:
- Cada task é entregável e testável sozinha. "Criar o model" não é task.
- Ordem natural: migration → model/repository → service → router → feature do front →
  i18n/polimento.
- Uma task não cruza repos: back e front viram tasks separadas, e o contrato vai
  escrito na primeira.
- Teste faz parte da task; nunca uma task só de testes.
- Task que não cabe em um dia de uma pessoa está grande demais; "renomear variável"
  está pequena demais — junte na anterior.

Depois do meu ok, cada task no formato:

# Task N — <título>
**Repo:** creed-<repo>
**Depende de:** <task ou nenhuma>
## Objetivo                          (uma frase, um entregável)
## Arquivos que provavelmente mudam
## Molde                             (qual arquivo de respondentes copiar a forma)
## Critérios de aceite
## Como testar                       (comando + casos: feliz e borda)
## Premissas aplicáveis
