# Front-end — React + TypeScript

Stack: **Vite · TypeScript · Tailwind · Redux Toolkit · Vitest** (ADR-003).

## Anatomia de uma feature

`src/features/<feature>/` — molde vivo em `src/features/respondentes/`:

```
features/respondentes/
├── RespondentesView.tsx      componente de tela
├── respondentesSlice.ts      estado (Redux Toolkit)
├── respondentesApi.ts        chamadas HTTP
└── respondentesSlice.test.ts testes
```

Feature nova espelha o **nome do domínio do backend**. Se o backend tem `prismas`,
o front tem `prismas` — não `prisma`, não `analises`.

## Regras

- **Nada de agregação no front.** Somar, agrupar e derivar indicador é do backend
  (`arquitetura.md`). O front recebe pronto e desenha.
- **Chamada HTTP só em `<feature>Api.ts`.** View não faz `fetch`, slice não faz `fetch`.
- **`src/components/ui/`** é compartilhado; componente que só uma feature usa mora na
  feature.
- **Tipos do backend** vivem em `src/types/` e acompanham os `schemas.py`. Divergiu →
  o backend é a fonte da verdade.
- **i18n**: texto visível passa por `src/i18n/locales/`. Não hardcode string na View.

## Vite e API

O dev server faz proxy de `/api` para `http://localhost:8000`. Não escreva URL absoluta
de backend no código.

## Comandos

| Comando | Cobre |
|---|---|
| `npm run lint` | ESLint |
| `npm run format:check` | Prettier |
| `npm run typecheck` | `tsc -b --noEmit` |
| `npm run test:run` | Vitest |
| `npm run check` | tudo acima, na ordem do CI |

Rodou `npm run check` verde = o check `qualidade` do CI passa.
