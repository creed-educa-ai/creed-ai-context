# Playbook: criar feature no front

**Quando:** a task cria `src/features/<nome>/` ou adiciona tela a uma feature.

**Molde:** `src/features/respondentes/` — abra os quatro arquivos antes de começar.

## Ordem

1. **Nome** — igual ao domínio do backend. `prognosticos` no back, `prognosticos` no
   front. Sem acento, plural.
2. **`src/types/`** — tipos que espelham os `schemas.py`. O backend é a fonte da
   verdade; divergiu, o front se ajusta.
3. **`<feature>Api.ts`** — chamadas HTTP. **Só aqui.** Caminho relativo `/api/...`
   (o Vite faz proxy); nunca URL absoluta.
4. **`<feature>Slice.ts`** — estado com Redux Toolkit. Segue a forma do slice-exemplo.
5. **`<Feature>View.tsx`** — a tela. Sem `fetch`, sem agregação, sem string literal
   visível (usa `src/i18n/locales/`).
6. **Rota** — registrar em `src/app/routes.tsx`.
7. **`<feature>Slice.test.ts`** — reducers e selectors. Teste de View quando houver
   interação que valha.

## Erros que este playbook existe para evitar

| Erro | Sinal |
|---|---|
| Agregação no front | `.reduce(`, `.filter().length` para montar indicador |
| Fetch fora do Api | `fetch(` ou `axios` na View ou no slice |
| Nome divergente do backend | pasta `analises` para o domínio `prognosticos` |
| Texto hardcoded | string em português dentro do JSX |
| Componente de uma feature em `components/ui/` | só uma feature importa |

## Antes de fechar

```bash
npm run check
```

Verde aqui = o check `qualidade` do CI passa.
