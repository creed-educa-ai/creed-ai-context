# Estrutura e nomes

## Idioma

- **Domínio em português** — é o vocabulário da cliente: `respondentes`, `prismas`,
  `prognosticos`. Sem acento e sem cedilha em identificador (`prognosticos`, não
  `prognósticos`).
- **Técnico em inglês** — `router`, `service`, `repository`, `schemas`, `models`,
  `create`, `update`, `list`.

Misturar os dois num mesmo identificador é o erro comum: `criarRespondenteService`
não; `RespondenteService.criar()` sim.

## Backend

| Coisa | Padrão | Exemplo |
|---|---|---|
| Pasta de domínio | `snake_case`, plural | `app/domains/prognosticos/` |
| Model | `PascalCase`, **singular** | `class Respondente(Base)` |
| Tabela | `snake_case`, plural | `respondentes` |
| Schema Pydantic | `<Entidade><Direção>` | `RespondenteCreate`, `RespondenteRead` |
| Rota | plural, kebab quando composta | `/api/v1/respondentes` |
| Teste | `test_<arquivo>.py` | `test_service.py` |

## Frontend

| Coisa | Padrão | Exemplo |
|---|---|---|
| Pasta de feature | `camelCase`, plural, = nome do domínio | `src/features/prognosticos/` |
| View | `PascalCase` + `View` | `PrognosticosView.tsx` |
| Slice | `<feature>Slice.ts` | `prognosticosSlice.ts` |
| API | `<feature>Api.ts` | `prognosticosApi.ts` |
| Teste | `<arquivo>.test.ts(x)` | `prognosticosSlice.test.ts` |
| Componente compartilhado | `PascalCase` em `components/ui/` | `Button.tsx` |

## A regra que resolve empate

**Espelhamento.** Domínio do backend e feature do front têm o mesmo nome, sempre.
Nome novo? Escolha o que funciona nos dois lados antes de criar qualquer arquivo.
