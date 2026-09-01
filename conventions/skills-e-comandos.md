# Skills, comandos e workflows: como escrever um novo

Vale para qualquer automação do harness: slash command do Claude Code, skill,
subagente, workflow de `workflows/`, playbook de `playbooks/` ou prompt colado de
`adaptadores/prompts/`.

Regra de ouro, das duas que seguem sai tudo o mais:

1. **Modelo leve por padrão.** Peso é exceção, e exceção se justifica por escrito.
2. **Passo determinístico por padrão.** Se o passo pode ser um comando, um caminho
   literal ou um template, ele não vira instrução em prosa.

O motivo é o mesmo nos dois casos: automação roda muitas vezes. O que na mão é
"o modelo se vira" vira, na décima execução, dez resultados diferentes e dez vezes
o custo.

## 1. Escolha do modelo

Escreva o modelo **no arquivo**, não deixe herdar da sessão. No Claude Code é o
campo `model:` do frontmatter do comando/skill/subagente; nas outras ferramentas é
o seletor da própria ferramenta, dito na primeira linha do prompt.

| O que a automação faz | Modelo |
|---|---|
| Preencher template, renomear, listar, formatar saída, montar pauta | leve (Haiku) |
| Ler diff, gerar spec/tasks, escrever código dentro de molde existente | médio (Sonnet) |
| Decisão de arquitetura, review de migration, quebrar ambiguidade de produto | pesado — e só o passo que precisa |

Suba um degrau só quando o degrau de baixo **errou de verdade**, com o erro
descrito no PR. Suposição de que "vai ficar melhor com o modelo grande" não é
justificativa.

Corolários:

- **Um passo pesado não torna a automação pesada.** Isole o julgamento num passo e
  delegue só ele (subagente ou comando próprio com outro `model:`). O resto continua
  leve.
- **Raciocínio estendido desligado** por padrão. Ligue por passo, nunca no arquivo
  inteiro.
- **Subagente é caro**: cada spawn começa do zero e re-descobre o contexto. Só quando
  o trabalho é paralelizável de fato ou precisa de contexto isolado.
- **Restrinja as ferramentas** (`allowed-tools`) ao que o passo usa. Menos ferramenta
  disponível = menos caminho para o modelo inventar.

## 2. O que é um passo determinístico

Cada passo declara **entrada → ação → saída verificável**. Se você não consegue dizer
como saber que o passo terminou certo, ele ainda não é um passo.

| Em vez de | Escreva |
|---|---|
| "encontre o arquivo relevante" | o caminho literal: `app/domains/respondentes/service.py` |
| "rode os testes" | o comando exato do repo, e o que significa passar |
| "se necessário, ajuste" | o critério: "se X, faça Y; senão, siga para 4" |
| "gere a documentação" | o template de `templates/` + as seções obrigatórias |
| "verifique se está tudo certo" | o checklist de `checklists/` |
| "tente até funcionar" | "no máximo 2 tentativas; falhou → pare e reporte o erro" |

Mais quatro exigências:

- **Ramificação explícita.** Toda decisão tem tabela de critério e um caso padrão.
  Decisão sem padrão é onde a automação vira loteria.
- **Saída em formato fixo.** Aponte o template. Formato fixo é o que permite ao humano
  conferir de relance e à automação seguinte consumir a saída.
- **Idempotência.** Rodar duas vezes não duplica arquivo, seção nem linha de ledger.
- **Falha barulhenta.** Faltou input, caminho não existe, suíte vermelha: pare e diga.
  Automação que "dá um jeito" esconde o problema para o review.

## 3. Onde o conteúdo mora

O comando é **ponteiro fino**; a regra mora no harness. Repetir a regra dentro do
comando cria duas versões dela, e a do comando envelhece primeiro.

| Você está escrevendo | Vai em |
|---|---|
| Sequência entrada → saída do pipeline | `workflows/` |
| Passo a passo de tarefa técnica recorrente | `playbooks/` |
| Regra ("sempre assim") | `conventions/` |
| O que conferir antes de dar por pronto | `checklists/` |
| Formato do artefato gerado | `templates/` |
| O gatilho para a ferramenta chamar o workflow | `adaptadores/` |

Comando novo do Claude Code nasce em `adaptadores/claude/commands/<nome>.md` e skill nova
em `adaptadores/claude/skills/<nome>/SKILL.md` — a skill é acionada pelo `description`,
não pelo dev, então ele descreve QUANDO usar, não o que ela faz. Os dois nascem com a
marca `GERADO por`, e só existe depois de rodar `scripts/instalar-adaptadores.sh` —
ver `../adaptadores/README.md`. Editar o arquivo instalado é trabalho perdido.

## 4. Antes de abrir o PR da automação nova

- [ ] `model:` declarado, e é o degrau mais baixo que dá conta.
- [ ] Todo passo tem entrada, ação e saída verificável.
- [ ] Nenhum caminho de arquivo descrito em prosa — todos literais.
- [ ] Toda decisão tem critério e caso padrão.
- [ ] Saída aponta um template; conferência aponta um checklist.
- [ ] Rodar duas vezes não duplica nada.
- [ ] Nenhuma regra normativa nova escrita dentro do comando.
- [ ] Rodada em uma tarefa real, com o resultado citado no PR.

## 5. Sinais de que a automação está pesada demais

- O comando tem parágrafo explicando a arquitetura — isso é `context/`, não comando.
- Duas execuções na mesma entrada geram estruturas diferentes.
- O passo diz "analise" sem dizer contra o quê.
- O modelo pesado está no arquivo inteiro porque **um** passo precisava dele.
- Tem subagente onde bastava um `grep`.
