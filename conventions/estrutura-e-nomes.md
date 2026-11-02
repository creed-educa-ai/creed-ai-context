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

> 🟡 **A lista dos termos expostos ainda não está fechada** — `Prisma`, `Prognostico` e
> `Respondente` são os candidatos, e a decisão é do time. Vínculo e setor já fecharam em
> inglês: `Link` e `Department` (2026-09-29). Valores de enum ficam em português por
> enquanto (`emprego`, `gestor`). Ver a pendência do
> [ADR-0005](../decisoes/adrs/0005-idioma-do-codigo.md).

**A tela continua em português.** Código em inglês não é interface em inglês: a chave de
i18n é inglês (`auth.login.submit`), o valor em `pt-BR` é o que a cliente lê. Confundir
as duas coisas entrega uma tela que o público-alvo não entende.

### O que ainda está em português

**No front**, as pastas, os arquivos e os nomes exportados (componentes, tipos, funções,
actions) passaram para o inglês em 2026-11-02, na refatoração que espelhou o back
(`respondentes` → `demographics`, `painel-de-controle` → `controlPanel`, `cadastro` →
`organizations/SignUpView` etc.). Ficaram em português, e são desvio conhecido:

- **namespaces e chaves de i18n** (`respondentes:`, `painelControle:`, `campos.genero`) —
  renomear mexe nos três locales e em todo `t()`; é um PR próprio;
- **variáveis locais e props** de componentes antigos (`titulo`, `aoEnviar`,
  `nomeEmpresa`, `onAceitar`);
- os campos dos tipos provisórios da tela (`Company`: `nomeEmpresa`, `documento`…), que
  só existem até o back ter o contrato.

**No back**, o `PaginaDe[T]` de `app/shared/paginacao.py` (e por isso o `ListaPaginada<T>`
do front, que o transcreve), e a pasta e a rota `organizacoes`. Nenhum é permissão para
nomear coisa nova em português.

O lado do backend deixou de existir: `app/domains/respondentes/` era estrutura de
scaffold do commit inicial, nunca teve tabela e foi removido. O molde do back passou a
ser `app/domains/users/`, que já nasceu no idioma desta convenção — então **a ressalva
"copie a forma, não o idioma" já não vale para ele**.

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
