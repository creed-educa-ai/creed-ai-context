# Task 2 — Tela de relatório de adesão

**Repo:** `creed-frontend`
**Depende de:** task 1 (contrato `AdesaoRead`)

## Objetivo

Tela em `features/relatorios/` que lista a adesão por organização, com filtro.

## Arquivos que provavelmente mudam

- `src/types/` (tipo `AdesaoRead`)
- `src/features/relatorios/relatoriosApi.ts`
- `src/features/relatorios/relatoriosSlice.ts`
- `src/features/relatorios/RelatoriosView.tsx`
- `src/features/relatorios/relatoriosSlice.test.ts`
- `src/app/routes.tsx`
- `src/i18n/locales/`

## Molde

`src/features/respondentes/`

## Critérios de aceite

- [ ] Nenhum cálculo de percentual ou soma no front — vem pronto do backend.
- [ ] Chamada HTTP só em `relatoriosApi.ts`, caminho relativo `/api/...`.
- [ ] Sem organização selecionada, lista todas.
- [ ] Texto visível via i18n, não hardcoded.
- [ ] Estado de carregando e de lista vazia tratados.

## Como testar

```bash
npm run check
npm run dev
```

## Premissas aplicáveis

- nenhuma
