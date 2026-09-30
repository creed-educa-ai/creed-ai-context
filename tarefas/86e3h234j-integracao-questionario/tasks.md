# Tasks — CREED-48 Integração do back ao front: o questionário

Spec: [`spec.md`](spec.md)

## Progresso

**Um PR no `creed-frontend`, um commit por task**, na branch
`feat/48-integracao-com-backend`, com base na `dev` (`c419d75`). O back já está na `dev`
(PR #31, `5222ad6`).

- [x] 1 — Tipos e chamadas do questionário (`src/types/api.ts`, `responsesApi.ts`) · `creed-frontend`
- [x] 2 — Carregar o questionário no estado (`responsesSlice.ts`, `loadQuestionnaire`, `selectQuestionnaireSections`) · `creed-frontend`
- [x] 3 — A tela de perguntas com dados reais (`FormView.tsx`) · `creed-frontend`
- [x] 4 — Enviar de verdade (`submitResponses`, `RevisaoRespostasRoute.tsx`) · `creed-frontend`

O que cada task entrega, o arquivo que se abre primeiro e o "pronto quando" estão na
tabela "Corte em entregas" da spec. Os `N_task.md` **não foram escritos**: decisão do
Leonardo em 2026-09-30, pela urgência da integração. Nenhuma delas vai para o ClickUp
como subtarefa, porque quem decompôs é quem implementa.

## Ordem

`1 → 2 → 3 → 4`, obrigatória: cada uma usa o que a anterior criou.

## Fora desta rodada

`conventions/contrato-front-back.md` já foi atualizado em 2026-09-30, com o back na `dev`.
Falta a situação da feature `responses` no `catalogo.md`, depois do merge do front. O
resto é o "Não entra" da spec.
