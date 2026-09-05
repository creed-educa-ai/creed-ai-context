# Task 2 — Visibilidade por papel

**Repo:** `creed-frontend`
**Depende de:** task 1

## Objetivo

Cada item do menu declara quais papéis o enxergam, e quem não tem o papel **não recebe
o item na árvore renderizada**.

## Arquivos que provavelmente mudam

- `src/app/sessaoSlice.ts` — papel do usuário (`admin` | `funcionario`), valor fixo em desenvolvimento
- `src/app/store.ts` — registrar o reducer
- `src/components/Navegacao.tsx` — cada item declara os papéis que o veem
- `src/components/Navegacao.test.tsx` — os dois papéis
- `src/types/api.ts` — o tipo do papel, se ele for viajar para outros lugares depois

Onde a fonte do papel mora é **bifurcação técnica**: `src/app/` (transversal, como
store e routes) ou `src/features/sessao/` (espelhando o molde de feature). O harness não
responde, então vale a parada de decisão de `../../workflows/tasks-to-code.md` — duas
opções, uma recomendação, e o humano decide.

## Molde

`src/features/respondentes/respondentesSlice.ts` para a forma do slice e do seletor;
`respondentesSlice.test.ts` para a forma do teste de estado.

## Critérios de aceite

- [ ] Item restrito a um papel **não é renderizado** para quem não o tem — o nó não existe no DOM, não basta `display:none`.
- [ ] Um `admin` vê "gerenciar funcionários"; um `funcionario` não vê a opção.
- [ ] Trocar o papel no estado muda o menu sem recarregar a página.
- [ ] Item sem papel declarado aparece para todo mundo — o padrão é visível, não escondido.
- [ ] `npm run check` verde.

## Como testar

```bash
npm run test:run
npm run check
```

Caso feliz: renderiza com papel `admin` e a opção restrita está lá.
Caso de borda: renderiza com papel `funcionario` e a opção **não** existe na árvore
(`queryBy...` devolve `null`, não um elemento oculto).

## Premissas aplicáveis

- P-003 — os papéis desta fase são `admin` e `funcionario`, dois níveis apenas.
- P-004 — o papel vem do estado do front até a autenticação existir; a funcionalidade
  não tem tarefa no board (CREED-5 e CREED-13 são protótipo #FIGMA).
