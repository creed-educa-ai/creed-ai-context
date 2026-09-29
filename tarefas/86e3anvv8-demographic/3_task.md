# Task 3 — Modelo de dados atualizado

**Repo:** `creed-ai-context`
**Depende de:** nenhuma

## Objetivo

O modelo de dados do time registra a tabela de demográficos e a mudança de gênero, para
que ninguém leia o `.dbml` e procure `Participant.gender`.

## Arquivos que provavelmente mudam

- `context/modelo-de-dados.md`: uma linha nova na tabela de decisões (data 2026-09-29) e
  atualização do item #14 (gênero) e do bloco "Perguntas para a cliente"
- `context/modelo-de-dados.proposta.dbml`: `Table ParticipantDemographics` nova, `gender`
  saindo de `Participant`, `Enum Gender` trocado pela lista do front e a `Ref` para
  `Participant`

## Molde

A linha de 2026-09-22 em `context/modelo-de-dados.md` ("`Question` ganha `section`
[C31]"), que registrou uma mudança feita por tarefa depois do fechamento da devolutiva.

## Critérios de aceite

- [ ] `modelo-de-dados.md` tem uma linha datada dizendo: tabela nova 1:1
      `participant_demographics`; `gender` sai de `Participant` e mora nela; `Enum Gender`
      passa a ser `feminino`, `masculino`, `nao_binario`, `prefiro_nao_informar` (sem
      `outro`); etnia e religião como listas; referência à CREED-40 e às premissas
      P-023 a P-027.
- [ ] O item #14 e a pergunta de gênero para a cliente apontam para a P-023, sem apagar
      que a pergunta continua aberta.
- [ ] A proposta `.dbml` tem a tabela nova com as colunas da spec, sem `gender` em
      `Participant`, e continua válida no dbdiagram (colar e ver o diagrama renderizar).
- [ ] O `.dbml` literal (`modelo-de-dados.dbml`) **não** é editado: ele é cópia do que
      está no dbdiagram, e muda só por reexportação.

## Como testar

1. Colar `context/modelo-de-dados.proposta.dbml` em dbdiagram.io: renderiza sem erro e
   mostra a seta `participant_demographics` → `Participant`.
2. `grep -n "gender" context/modelo-de-dados.proposta.dbml`: aparece só na tabela nova.
3. Ler a linha nova do `modelo-de-dados.md` sem abrir a spec: dá para entender o que
   mudou e por quê.

## Premissas aplicáveis

- P-023 — lista de gênero do front, sem o `outro` do modelo.
- P-024 — idade como faixa etária.
