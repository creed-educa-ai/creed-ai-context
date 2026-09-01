---
name: estado-front
description: Gerir estado no creed-frontend com Redux Toolkit — criar ou alterar <feature>Slice.ts, thunks, seletores, registrar reducer no store, decidir o que é estado global e o que não é. Use quando a tarefa envolve slice, thunk, store, carregamento de dados, status de requisição ou estado compartilhado entre telas.
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai mexer no estado da aplicação. A régua é
`creed-ai-context/conventions/camadas-do-front.md`; o molde é
`src/features/respondentes/respondentesSlice.ts` e o teste ao lado dele.

<critical>DECIDA PRIMEIRO SE É ESTADO GLOBAL. Vai ao slice: dado de servidor, status da requisição, erro já virado mensagem. NÃO vai: campo de formulário (react-hook-form), aberto/fechado e aba ativa (useState no componente), valor derivado (seletor, nunca campo do state — campo derivado desincroniza).</critical>
<critical>Máquina de status única, igual em toda feature: idle, carregando, pronto, erro. Não invente um `loading: boolean` ao lado dela.</critical>
<critical>O slice NÃO faz HTTP. O thunk chama o `<feature>Api.ts`; se ele não existir, quem resolve é a skill `contrato-front` — não coloque `fetch` aqui.</critical>
<critical>Um thunk, uma responsabilidade. "Carregar e filtrar" são dois — ou o filtro é do backend.</critical>
<critical>O erro vira mensagem pronta no state; a View não interpreta `ApiError`. Use o status do erro para escolher a mensagem: 404 é vazio, 409 é conflito de regra, 5xx é falha genérica.</critical>
<critical>Registre o reducer em `src/app/store.ts` e use `useAppDispatch`/`useAppSelector` de `@/app/hooks` — nunca os genéricos do react-redux, que perdem a tipagem.</critical>
<critical>RTK Query está deliberadamente adiado (nota no molde, ADR-003 §2). Não migre por conta própria: é decisão de ADR.</critical>
<critical>Teste o slice como o molde faz: transição pending, fulfilled com payload e rejected com mensagem. Reducer é lógica pura — não tem desculpa para não ter teste.</critical>
