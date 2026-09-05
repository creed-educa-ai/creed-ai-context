# Task 1 — Menu de navegação responsivo

**Repo:** `creed-frontend`
**Depende de:** nenhuma

## Objetivo

Um menu de navegação compartilhado, visível em todas as rotas, que colapsa em mobile e
tira os rótulos do i18n.

## Arquivos que provavelmente mudam

- `src/components/Navegacao.tsx` — o componente
- `src/components/Navegacao.test.tsx` — os testes
- `src/app/Layout.tsx` — rota-mãe com `<Outlet />`, para o menu valer em todas as telas
- `src/app/routes.tsx` — aninhar as rotas existentes sob o layout
- `src/i18n/locales/pt-BR.ts` e `en.ts` — rótulos em `comum.navegacao`

## Molde

`src/components/SeletorIdioma.tsx` + `SeletorIdioma.test.tsx` — componente
compartilhado que já combina shadcn/ui e i18n, com teste ao lado. Copie a forma dele,
não a de uma feature: o menu não é feature, é transversal
(`../../context/frontend.md`).

## Critérios de aceite

- [ ] O menu aparece em `/` e `/respondentes` — as rotas que existem hoje.
- [ ] Abaixo de 768px (breakpoint `md` do Tailwind) o menu colapsa em botão e abre sobreposto; a partir de 768px fica visível sem interação.
- [ ] Itens apontam só para rotas registradas em `routes.tsx` (P-005).
- [ ] Nenhum texto visível hardcoded: todo rótulo sai de `comum.navegacao`, nos dois idiomas.
- [ ] Navegação por teclado funciona e o menu tem rótulo acessível (`aria-label`), como no molde.

## Como testar

```bash
npm run test:run
npm run check
```

Caso feliz: renderiza os itens das rotas existentes e navega ao clicar.
Caso de borda: em viewport mobile o menu começa fechado e abre no clique do botão.

## Premissas aplicáveis

- P-005 — o menu lista apenas rotas já registradas em `routes.tsx`.
