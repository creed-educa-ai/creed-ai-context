# Estrutura e nomes

## Idioma

**Inglês por padrão, em todo identificador** — pasta, classe, método, variável, rota,
schema, chave de i18n, nome de teste ([ADR-0005](../decisoes/adrs/0005-idioma-do-codigo.md)).
Não existe mais "nome técnico" e "nome de domínio" com regras diferentes.

A única exceção é **o termo que a cliente usa e que aparece na conversa com ela**. O
critério é exposição, não categoria:

> Esta palavra é dita numa reunião com a professora?
> **Sim** → fica como ela fala. **Não** → inglês.

Rota, service, repository, schema, dependência e teste ninguém mostra para a cliente:
inglês, sempre. Sem acento e sem cedilha em identificador, no que sobrar em português
(`prognosticos`, não `prognósticos`).

> 🟡 **A lista dos termos expostos ainda não está fechada** — `Vinculo`, `Setor`,
> `Prisma`, `Prognostico` e `Respondente` são os candidatos, e a decisão é do time.
> Prazo: antes da primeira migration, porque dois deles são nome de tabela. Ver a
> pendência do [ADR-0005](../decisoes/adrs/0005-idioma-do-codigo.md).

**A tela continua em português.** Código em inglês não é interface em inglês: a chave de
i18n é inglês (`auth.login.submit`), o valor em `pt-BR` é o que a cliente lê. Confundir
as duas coisas entrega uma tela que o público-alvo não entende.

### O código existente não foi renomeado

`app/domains/respondentes/` e `src/features/respondentes/` continuam em português, e o
`PaginaDe[T]` de `app/shared/paginacao.py` também. **Copie deles a forma, não o idioma.**
É desvio conhecido e aceito, registrado nas Consequências do ADR-0005 — não é permissão
para nomear coisa nova em português.

## Backend

| Coisa | Padrão | Exemplo |
|---|---|---|
| Pasta de domínio | `snake_case`, plural | `app/domains/users/` |
| Model | `PascalCase`, **singular** | `class User(Base)` |
| Tabela | `snake_case`, plural | `users` |
| Schema Pydantic | `<Entity><Direção>` | `UserCreate`, `UserUpdate`, `UserResponse` |
| Método de service e de repository | inglês, os dois | `create`, `list`, `get_by_email` |
| Rota | plural, kebab quando composta | `/api/v1/users`, `/api/v1/form-responses` |
| Teste | `test_<arquivo>.py` | `test_service.py` |

> O sufixo do schema de saída diverge: esta tabela dizia `Read` e o molde escreve
> `Response`. Fica `Response`, que é o que existe em código. Conflito antigo, resolvido
> aqui só porque a linha estava sendo reescrita de qualquer jeito.

## Frontend

| Coisa | Padrão | Exemplo |
|---|---|---|
| Pasta de feature | `camelCase`, plural, = nome do domínio | `src/features/users/` |
| View | `PascalCase` + `View` | `UsersView.tsx` |
| Slice | `<feature>Slice.ts` | `usersSlice.ts` |
| API | `<feature>Api.ts` | `usersApi.ts` |
| Teste | `<arquivo>.test.ts(x)` | `usersSlice.test.ts` |
| Chave de i18n | inglês; **o valor é que é português** | `users.list.empty` → "Nenhum usuário" |
| Componente compartilhado | `PascalCase` em `components/ui/` | `Button.tsx` |

## A regra que resolve empate

**Espelhamento.** Domínio do backend e feature do front têm o mesmo nome, sempre.
Nome novo? Escolha o que funciona nos dois lados antes de criar qualquer arquivo.
